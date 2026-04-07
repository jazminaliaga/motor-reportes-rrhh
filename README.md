# 📄 Motor de Reportes y Transformación XML (Integración SIU-Mapuche)

![Status](https://img.shields.io/badge/Status-Producción-success)
![Entorno](https://img.shields.io/badge/Ecosistema-SIU_Mapuche-blue)

Este repositorio contiene los scripts de transformación de datos (XSLT) desarrollados para integrarse con el sistema core de Recursos Humanos. 

El objetivo de este módulo es interceptar las salidas masivas de datos estructurados en XML y generar dinámicamente código (PHP/FPDF) para la creación de reportes institucionales oficiales en formato PDF (viáticos, embargos, cuotas deportivas).

> 🔒 **Política de Seguridad y Compliance:** Al tratarse de un desarrollo sobre un ERP propietario que maneja información financiera y personal sensible, este repositorio funciona estrictamente como una **prueba de concepto (Showcase)** para exhibir la lógica de ingeniería. 
> 
> Para prevenir la exposición de datos y la falsificación de documentos institucionales, **no se adjuntan los PDFs resultantes**. El código fuente de transformación (XSLT) es real, pero el archivo de entrada (XML) ha sido sanitizado con datos ficticios.

## ⚙️ Arquitectura del Proceso

El flujo de trabajo automatiza procesos administrativos manuales siguiendo este pipeline:

1. **Extracción (Input):** El sistema core genera un `detalle_liquidacion.xml` con la estructura jerárquica de legajos, conceptos salariales y retenciones.
2. **Transformación (Core Logic):** Los scripts `.xsl` actúan como motor de reglas. Parsean los nodos del XML, aplican lógica condicional (ej. evaluar si existen embargos activos) y realizan cálculos matemáticos.
3. **Inyección y Renderizado (Output):** El XSLT construye y emite sentencias que el motor interno del ERP interpreta para renderizar los documentos finales.

## 📂 Estructura del Repositorio

- 📁 `/1-input-mock`: Contiene un ejemplo sanitizado de la estructura jerárquica XML de la cual se alimentan los scripts.
- 📁 `/2-scripts-xslt`: Contiene la lógica de negocio y las plantillas de transformación.
  - `nota_embargos.xsl`: Lógica para validación de retenciones y conceptos.
  - `nota_viaticos.xsl`: Parseo de montos y conversión de números a texto.
  - `nota_certificado_deporte.xsl`: Generador de certificados estándar.

## 🛠️ Tecnologías y Habilidades Aplicadas

* **Manejo de Datos Crudos:** Lectura y manipulación de estructuras complejas XML.
* **Transformación:** XSLT (Extensible Stylesheet Language Transformations).
* **Generación Dinámica:** Inyección de código y manejo de librerías de renderizado.
* **Lógica de Negocio:** Integración de normativas contables e institucionales directamente en el código de transformación.
