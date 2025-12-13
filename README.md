# Generaci-n-y-An-lisis-de-Se-ales-basado-en-System-on-Chip-SoC-
Generación y Análisis de Señales basado en System-on-Chip (SoC)

El wrapper completo se realiza creando un 'BlockDesign' y añadiendo las IPs de los tres componentes (ADC, DAC y HDMI) y la IP del procesador ZYNQ7000. Se conectan los resets activos bajo al DAC y ADC y el reset activo alto al HDMI. Se genera un ClockWizard de 100MHz para todos los componentes y por ultimos hacemos externas las salidas que estan definidas en el archivo .xdc

La correcta ejecución de este proyecto se realiza creando una plataforma en VITIS con el archivo .xsa y una aplicacion que tenga en sources el código main.c.
Si se ejecuta el programa desde Adept con el .bit solo se veran los ejes y la señal en 0V, ya que necesitamos la terminal para ejecutar la generación y adquisición de las ondas.
