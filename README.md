# 📄 Motor de Reportes y Transformación XML (Integración SIU-Mapuche)

![Status](https://img.shields.io/badge/Status-Producción-success)
![Entorno](https://img.shields.io/badge/Ecosistema-SIU_Mapuche-blue)

Este repositorio contiene los scripts de transformación de datos (XSLT) desarrollados para el sistema core de Recursos Humanos de la Universidad Nacional de Cuyo. 

El objetivo de este módulo es interceptar las salidas masivas de datos estructurados en XML y generar dinámicamente código para la creación de reportes institucionales oficiales en formato PDF (viáticos, embargos, cuotas deportivas).

> **Nota de Confidencialidad:** Al tratarse de un desarrollo sobre un ERP propietario (SIU-Mapuche) que maneja información financiera y personal sensible, este repositorio funciona como una **prueba de concepto (Showcase)**. El código fuente es real, pero los archivos de entrada (XML) y salida (PDF) han sido sanitizados con datos ficticios.

## ⚙️ Arquitectura del Proceso

El flujo de trabajo automatiza lo que anteriormente era un proceso administrativo manual, siguiendo este pipeline:

1. **Extracción (Input):** El sistema core genera un `detalle_liquidacion.xml` con la estructura jerárquica de legajos, conceptos salariales y retenciones.
2. **Transformación (Core Logic):** Los scripts `.xsl` actúan como motor de reglas. Parsean los nodos del XML, aplican lógica condicional (ej. evaluar si existen embargos activos) y realizan cálculos matemáticos.
3. **Inyección y Renderizado (Output):** El XSLT construye y emite sentencias en **PHP** (utilizando librerías tipo FPDF/TCPDF) que el motor interno del ERP interpreta para renderizar los documentos finales.

## 📂 Estructura del Repositorio

Para facilitar la lectura del código, el repositorio se divide en el flujo de transformación:

- 📁 `/1-input-mock`: Contiene un ejemplo de la estructura jerárquica XML de la cual se alimentan los scripts.
- 📁 `/2-scripts-xslt`: Contiene la lógica de negocio y las plantillas de transformación.
  - `nota_embargos.xsl`: Lógica para validación de retenciones.
  - `nota_viaticos.xsl`: Parseo de montos y conversión de números a texto.
  - `nota_certificado_deporte.xsl`: Generador de certificados estándar.
- 📁 `/3-output-samples`: Archivos PDF resultantes generados por el motor a partir de los scripts.

## 🛠️ Tecnologías y Habilidades Aplicadas

* **Manejo de Datos Crudos:** Lectura y manipulación de estructuras complejas XML.
* **Transformación:** XSLT (Extensible Stylesheet Language Transformations).
* **Generación Dinámica:** Inyección de código PHP y manejo de librerías de renderizado PDF.
* **Lógica de Negocio:** Integración de normativas contables e institucionales directamente en el código de transformación.
