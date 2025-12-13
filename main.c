#include <stdio.h>
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "sleep.h"
#include "stdlib.h" 

// =============================================================
// --- 1. DETECCIÓN DE UART (DRIVER NO BLOQUEANTE) ---
// =============================================================
#if defined(XPAR_XUARTPS_NUM_INSTANCES) 
    #include "xuartps_hw.h"
    #ifdef XPAR_XUARTPS_0_BASEADDR
        #define UART_BASE XPAR_XUARTPS_0_BASEADDR
    #else
        #define UART_BASE 0xE0001000 
    #endif
    #define KBHIT() (!(Xil_In32(UART_BASE + XUARTPS_SR_OFFSET) & XUARTPS_SR_RXEMPTY))

#elif defined(XPAR_UARTLITE_0_BASEADDR) 
    #include "xuartlite_l.h"
    #define UART_BASE XPAR_UARTLITE_0_BASEADDR
    #define KBHIT() (!XUartLite_IsReceiveEmpty(UART_BASE))

#else
    #define KBHIT() 0
    #warning "UART no detectada. La interaccion por teclado no funcionara."
#endif

// =============================================================
// --- 2. MAPEO DE HARDWARE ---
// =============================================================
#if defined(XPAR_MY_DAC_AXI_0_BASEADDR)
    #define DAC_BASE XPAR_MY_DAC_AXI_0_BASEADDR
    #define ADC_BASE XPAR_MY_ADC_AXI_0_BASEADDR
#else
    #define DAC_BASE 0x43C10000 
    #define ADC_BASE 0x43C00000 
#endif

#define DSP_BASE ADC_BASE 

// Offsets de Registros (Coinciden con tu VHDL modificado a 5 bits)
#define REG_CTRL      0    // slv_reg0 (RW): Bit 0 = Start
#define REG_ADC_RAW   4    // slv_reg1 (R) : Dato Crudo ADC
#define REG_DSP_MAV   8    // slv_reg2 (R) : Valor Medio Absoluto
#define REG_DSP_FREQ  12   // slv_reg3 (R) : Frecuencímetro
#define REG_ADC_FILT  16   // slv_reg4 (R) : Salida Filtro FIR (Moving Average)

// DAC
#define REG_DAC_DATA  4
#define REG_DAC_GO    12
#define REG_PRESCALER 8    

#define VREF 3.3f
#define DAC_CENTER 2048 
#define LUT_SIZE 64

// =============================================================
// --- 3. CONFIGURACIÓN ---
// =============================================================
const int FREQ_DELAYS[4] = { 20000, 5000, 1000, 0 };
const char *FREQ_LABELS[4] = { "MUY LENTO", "LENTO", "RAPIDO", "MAXIMO" };

typedef enum { WAVE_SINE, WAVE_TRIANGLE, WAVE_SQUARE, WAVE_SAWTOOTH } WaveType;

typedef struct {
    WaveType type;
    int amp_index;  // 0-15
    int freq_index; // 0-3
    int noise_en;   // 1 = Inyectar Ruido Digital
    int running;   
} GeneratorConfig;

GeneratorConfig sys_config = {WAVE_SINE, 15, 2, 0, 0};

const u32 LUT_SINE[LUT_SIZE] = {
    2048, 2248, 2447, 2642, 2831, 3013, 3185, 3346,
    3495, 3630, 3750, 3853, 3939, 4007, 4056, 4085,
    4095, 4085, 4056, 4007, 3939, 3853, 3750, 3630,
    3495, 3346, 3185, 3013, 2831, 2642, 2447, 2248,
    2048, 1847, 1648, 1453, 1264, 1082, 910,  749,
    600,  465,  345,  242,  156,  88,   39,   10,
    0,    10,   39,   88,   156,  242,  345,  465,
    600,  749,  910,  1082, 1264, 1453, 1648, 1847
};

// =============================================================
// --- 4. FUNCIONES LÓGICAS ---
// =============================================================

void print_volts(float voltage) {
    int whole = (int)voltage;
    int thousandths = (int)((voltage - whole) * 1000);
    if(thousandths < 0) thousandths = -thousandths;
    xil_printf("%d.%03d V", whole, thousandths);
}

// BitSlip Software (Recuperación de trama SPI)
u32 Corregir_BitSlip(u32 raw, u32 esperado) {
    u32 candidato, mejor_val = raw;
    int menor_error = abs((int)raw - (int)esperado);
    int umbral = 50; 

    for(int s=1; s<=3; s++) {
        candidato = (raw << s) & 0xFFF;
        int err = abs((int)candidato - (int)esperado);
        if (err < (menor_error - umbral)) { menor_error = err; mejor_val = candidato; }
        
        candidato = (raw >> s) & 0xFFF;
        err = abs((int)candidato - (int)esperado);
        if (err < (menor_error - umbral)) { menor_error = err; mejor_val = candidato; }
    }
    if(abs((int)raw - (int)esperado) < 100) return raw;
    return mejor_val; 
}

// Captura con Oversampling (3 intentos)
u32 Capturar_Dato_Rapido(u32 dac_target_val) {
    u32 mejor_val = 0;
    int mejor_error = 99999;
    
    Xil_Out32(DAC_BASE + REG_DAC_DATA, dac_target_val); // Enviar al DAC
    
    for(int i=0; i<3; i++) { 
        Xil_Out32(DAC_BASE + REG_DAC_GO, 1);
        for(volatile int k=0; k<10; k++); 
        
        Xil_Out32(ADC_BASE + REG_CTRL, 1); // Start ADC
        Xil_Out32(DAC_BASE + REG_DAC_GO, 0);
        Xil_Out32(ADC_BASE + REG_CTRL, 0);
        
        for(volatile int w=0; w<1500; w++); // Espera conversión
        
        u32 raw = Xil_In32(ADC_BASE + REG_ADC_RAW) & 0xFFFF;
        u32 corr = Corregir_BitSlip(raw, dac_target_val);
        int err = abs((int)corr - (int)dac_target_val);
        
        if(err < mejor_error) { mejor_error = err; mejor_val = corr; }
        if(err < 20) break; 
    }
    return mejor_val;
}

// Generador de Onda con Inyección de Ruido
u32 Obtener_Muestra(int index) {
    u32 raw_sample = DAC_CENTER;
    
    switch(sys_config.type) {
        case WAVE_SINE: raw_sample = LUT_SINE[index]; break;
        case WAVE_TRIANGLE:
            if(index < (LUT_SIZE/2)) raw_sample = (u32)((index * 4095) / (LUT_SIZE/2));
            else raw_sample = (u32)(4095 - ((index - (LUT_SIZE/2)) * 4095) / (LUT_SIZE/2));
            break;
        case WAVE_SQUARE: raw_sample = (index < (LUT_SIZE/2)) ? 4095 : 0; break;
        case WAVE_SAWTOOTH: raw_sample = (u32)((index * 4095) / (LUT_SIZE - 1)); break;
    }

    float factor = (float)sys_config.amp_index / 15.0f;
    int centrado = (int)raw_sample - DAC_CENTER;
    int escalado = (int)(centrado * factor);
    
    // RUIDO DIGITAL (Para demostrar el filtro HW)
    if(sys_config.noise_en) {
        int ruido = (rand() % 400) - 200; // +/- 200 LSBs
        escalado += ruido;
    }

    int final_val = DAC_CENTER + escalado;
    if(final_val > 4095) final_val = 4095;
    if(final_val < 0) final_val = 0;
    
    return (u32)final_val;
}

// =============================================================
// --- 5. INTERFAZ DE USUARIO ---
// =============================================================

void Mostrar_Menu() {
    int pct = (sys_config.amp_index * 100) / 15;
    
    xil_printf("\n\r\n\r===========================================\n\r");
    xil_printf("   GENERADOR DE FUNCIONES & HDMI MONITOR   \n\r");
    xil_printf("===========================================\n\r");
    xil_printf("  [1-4] Forma:      %s\n\r", 
        (sys_config.type == WAVE_SINE) ? "SENO" : 
        (sys_config.type == WAVE_TRIANGLE) ? "TRIANGULO" : 
        (sys_config.type == WAVE_SQUARE) ? "CUADRADA" : "SIERRA");
        
    xil_printf("  [+/-] Amplitud:   %d %% (Nivel %d/15)\n\r", pct, sys_config.amp_index);
    xil_printf("  [F]   Velocidad:  %s\n\r", FREQ_LABELS[sys_config.freq_index]);
    xil_printf("  [N]   RUIDO TEST: [%s]\n\r", sys_config.noise_en ? "ON" : "OFF");
        
    xil_printf("-------------------------------------------\n\r");
    xil_printf("  INFO: El HDMI muestra la senal LIMPIA (Filtrada)\n\r");
    xil_printf("  [R] EJECUTAR SISTEMA\n\r");
    xil_printf("Seleccion > ");
}

void Procesar_Input(char key) {
    switch(key) {
        case '1': sys_config.type = WAVE_SINE; break;
        case '2': sys_config.type = WAVE_TRIANGLE; break;
        case '3': sys_config.type = WAVE_SQUARE; break;
        case '4': sys_config.type = WAVE_SAWTOOTH; break;
        case '+': if(sys_config.amp_index < 15) sys_config.amp_index++; break;
        case '-': if(sys_config.amp_index > 0) sys_config.amp_index--; break;
        case 'f': case 'F': 
            sys_config.freq_index++; if(sys_config.freq_index > 3) sys_config.freq_index = 0; 
            break;
        case 'n': case 'N': sys_config.noise_en = !sys_config.noise_en; break;
        case 'R': case 'r': sys_config.running = 1; break;
    }
}

// =============================================================
// --- 6. PROGRAMA PRINCIPAL ---
// =============================================================

void Run_App() {
    Xil_Out32(DAC_BASE + REG_PRESCALER, 32); 
    Xil_Out32(ADC_BASE + REG_PRESCALER, 32);

    while(1) {
        sys_config.running = 0;
        Mostrar_Menu();
        char key = inbyte(); 
        Procesar_Input(key);

        if(sys_config.running) {
            int current_delay = FREQ_DELAYS[sys_config.freq_index];
            xil_printf("\n\r>>> EJECUTANDO... [Pulsa 't' para TRAZA, otra tecla para SALIR] <<<\n\r");
            
            xil_printf("DAC Sent | ADC RAW  | ADC FILT |   MAV    | Freq HW \n\r");
            xil_printf("----------------------------------------------------\n\r");

            // Soft Start
            for(int j=0; j<=DAC_CENTER; j+=100) { Capturar_Dato_Rapido(j); usleep(2000); }

            u32 dac_val, adc_val, dsp_mav, dsp_freq, dsp_filt;
            float v_dac, v_adc, v_mav, v_filt;
            int counter = 0;
            int traza_activa = 0;

            while(1) {
                if(KBHIT()) {
                    char c = inbyte();
                    if(c == 't' || c == 'T') {
                        traza_activa = 1; 
                        xil_printf("\n\r--- INICIO TRAZA (1 Ciclo) ---\n\r");
                    } else {
                        sys_config.running = 0;
                        break; 
                    }
                }

                for(int i=0; i<LUT_SIZE; i++) {
                    dac_val = Obtener_Muestra(i); 
                    adc_val = Capturar_Dato_Rapido(dac_val); 
                    
                    if(traza_activa) {
                         // Mostrar datos ASCII
                         dsp_filt = Xil_In32(DSP_BASE + REG_ADC_FILT);
                         v_adc = ((float)adc_val / 4095.0) * VREF;
                         v_filt = ((float)dsp_filt / 4095.0) * VREF;
                         
                         xil_printf("[%02d] Raw: %d.%03d | Filt: %d.%03d\n\r", i, 
                            (int)v_adc, (int)((v_adc-(int)v_adc)*1000),
                            (int)v_filt, (int)((v_filt-(int)v_filt)*1000));
                            
                         if(i == LUT_SIZE - 1) { 
                             traza_activa = 0; 
                             xil_printf("--- FIN TRAZA ---\n\r"); 
                             xil_printf("DAC Sent | ADC RAW  | ADC FILT |   MAV    | Freq HW \n\r"); 
                         }
                    }
                    else if(i == 16) { // Monitor en pico
                        counter++;
                        if(counter > 10) { 
                            counter = 0;
                            // LEER HARDWARE
                            dsp_freq = Xil_In32(DSP_BASE + REG_DSP_FREQ);
                            dsp_mav  = Xil_In32(DSP_BASE + REG_DSP_MAV);
                            dsp_filt = Xil_In32(DSP_BASE + REG_ADC_FILT);
                            
                            v_dac  = ((float)dac_val / 4095.0) * VREF;
                            v_adc  = ((float)adc_val / 4095.0) * VREF;
                            v_mav  = ((float)dsp_mav / 4095.0) * VREF;
                            v_filt = ((float)dsp_filt / 4095.0) * VREF;
                            
                            xil_printf(" "); print_volts(v_dac);
                            xil_printf(" | "); print_volts(v_adc);   
                            xil_printf(" | "); print_volts(v_filt);  
                            xil_printf(" | "); print_volts(v_mav);
                            xil_printf(" |  %d Hz\n\r", dsp_freq);
                        }
                    }
                    if(current_delay > 0) usleep(current_delay);
                }
            }
            
            // Soft Stop
            for(int j=DAC_CENTER; j>=0; j-=100) { Capturar_Dato_Rapido(j); usleep(2000); }
            Capturar_Dato_Rapido(0);
        }
    }
}

int main() {
    xil_printf("\n\r--- INICIO SISTEMA ---\n\r");
    Run_App();
    return 0;
}