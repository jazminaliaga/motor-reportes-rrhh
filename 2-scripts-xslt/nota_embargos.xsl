<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="owner" select="'SIU-Mapuche'"/>
  <xsl:output method="html" encoding="iso-8859-1" indent="no"/>

  <xsl:template match="detalle_liquidacion">
    <!-- Inicializa variables y configuraciones -->
      ini_set('max_execution_time','0');

    <!-- OPCIONES CONFIGURABLES EN EL POPUP DE IMPRESIÓN -->
      <!-- Logo -->
      define('LOGO', (isset($logo))? $logo : 'logo_institucion.png');
      define('LOGO_X', (isset($logo_x))? $logo_x : 15);
      define('LOGO_Y', (isset($logo_y))? $logo_y : 5);
      define('LOGO_W', (isset($logo_w))? $logo_w : 35);
      define('LOGO_H', (isset($logo_h))? $logo_h : 14);
      
    <!-- Opciones de página -->
      <!-- Márgenes -->
      define('IZQ', (isset($izq))? $izq : 20);
      define('TOP', (isset($top))? $top : 20);
      define('DER', (isset($der))? $der : 20);
      // - Formato de pÃ¡gina
      define('TIPO', (isset($sze))? $sze : 'a4');
      define('POS', (isset($pos))? $pos : 'p');

    <!-- PDF generales -->
      $pdf = new PDF(POS, 'mm', TIPO);
      $pdf->SetFont('Arial', '', 4);
      $pdf->setTitulo(' ');
      $pdf->set_path_personalizacion($pdf_dir_personalizado);
      $pdf->SetMargins(IZQ, TOP, DER);
      $pdf->set_imagen_encabezado(LOGO, LOGO_X, LOGO_Y, LOGO_W, LOGO_H);
      //$pdf->AliasNbPages();
    
    <!-- Define los lí­mites de la hoja -->
      list($w, $h) = $pdf->getDefaultPageSize(); <!-- Toma el ancho y el alto total de la pagina -->
      if (strtoupper(POS) == 'P') {
        define('MAX_HEIGHT', $h);
        define('MAX_WIDTH', ($w - IZQ - DER));
      } else {
        define('MAX_HEIGHT', $w);
        define('MAX_WIDTH', $h - IZQ - DER);
      
      } 

    $tamaÃ±o_letra= 12; 
    $tamaÃ±o_letra_grande= $tamaÃ±o_letra+2;
    $tamaÃ±o_letra_mini  = $tamaÃ±o_letra-2;

    $pdf->SetFont('Arial','',$tamaÃ±o_letra);

    $ancho_tabla = MAX_WIDTH;
    $posX = IZQ;
    $posY = TOP + 20;
    $pdf->setXY($posX,$posY);

    <!-- Setea el dia y hora del pie de pagina -->
      $pdf->set_fecha();
      $pdf->set_hora();
      $pdf->setVersion('<xsl:value-of select="datos_adicionales/version"/>');
      $ancho_col = $ancho_tabla;

    $pdf->addPage();

    $tabla_datos  =   '<tr bgcolor="#c6c6c6">';

    <!-- Datos el xml -->
        $tabla_datos .= '</tr>';
        $informe = '';
        $fecha = '<xsl:value-of select="datos_adicionales/fecha_actual"/>';
        $agente = '<xsl:value-of select="legajos/legajo/agente"/>';
        $documento = '<xsl:value-of select="legajos/legajo/documento/valor"/>';
        $legajo = '<xsl:value-of select="legajos/legajo/nro_legaj"/>';
        $tieneEmbargo = 'no';
        $conceptosEmbargo = '';

    <xsl:for-each select="legajos/legajo/cargos/cargo/conceptos/concepto">
      $concepto = '<xsl:value-of select="codn_conce"/>';

      if (tieneConcepto($concepto)) {
        $tieneEmbargo = ' ';
        $tipoEmbargo = '<xsl:value-of select="desc_corta"/>';
        $conceptosEmbargo .= $concepto . ': ' . $tipoEmbargo . "\n";
      }
    </xsl:for-each>

    <!-- Texto del informe -->
      $direPersonal = 'Destinatario de Prueba';
      $direNombre = 'Area de Auditoría Técnica';
      $sobreD = 'S                   /                   D';
      $sangria = str_repeat(chr(160), 45);
      
      // Mantenemos tu lógica exacta, pero con texto de "log de sistema"
      $cuerpoInfo = $sangria . 'El motor de validación XSLT informa que el usuario de prueba ' . $agente . ', ID-DOC N° ' . $documento . ', ID-INTERNO N° ' . $legajo . ', ' . $tieneEmbargo;

      if ($tieneEmbargo == ' ') {
        $cuerpoInfo .= 'registra las siguientes retenciones activas bajo la regla de evaluación:';
        $cuerpoInfo .= "\n" . $conceptosEmbargo;
      } else {
        $cuerpoInfo .= ' registra validaciones negativas para retenciones o conceptos especiales en el actual ciclo de procesamiento.';
      }

      $cierre = 'Fin del reporte autogenerado.';
      $cuerpoFirmaNombre = 'SISTEMA AUTOMATIZADO';
      $cuerpoFirmaDir = 'PIPELINE DE EXTRACCIÓN';
      $cuerpoFirmaUniversidad = 'ENTORNO LOCAL DE PRUEBA';
    
    <!-- Agrega informe a una fila de tabla -->
      $pdf->MultiCell($ancho_tabla, 5, 'Mendoza, ' . $fecha, 0, 'R', 0, 1);
      $pdf->Ln(2); <!-- Salto de línea -->

      $pdf->MultiCell($ancho_tabla, 5, $direPersonal, 0, 'L', 0, 1);
      $pdf->MultiCell($ancho_tabla, 5, $direNombre, 0, 'L', 0, 1);
      $pdf->MultiCell($ancho_tabla, 5, $sobreD, 0, 'L', 0, 1);
      $pdf->Ln(5);

      $pdf->MultiCell($ancho_tabla, 10, $cuerpoInfo, 0, 'J', 0, 1);
      $pdf->Ln(5);
      $pdf->SetX(210- $ancho_tabla*0.9); <!-- alinea a la derecha-->
      $pdf->MultiCell($ancho_tabla, 10, $cierre, 0, 'C', 0, 1);
      $pdf->Ln(5);

    <!-- Firma -->
      $pdf->SetX(210- $ancho_tabla*0.9); <!-- alinea a la derecha-->
      $pdf->MultiCell($ancho_tabla, 5, $cuerpoFirmaNombre, 0, 'C', 0, 1);
      $pdf->SetX(210 - $ancho_tabla*0.9); <!-- alinea a la derecha-->
      $pdf->MultiCell($ancho_tabla, 5, $cuerpoFirmaDir, 0, 'C', 0, 1);
      $pdf->SetX(210 - $ancho_tabla*0.9); <!-- alinea a la derecha-->
      $pdf->MultiCell($ancho_tabla, 5, $cuerpoFirmaUniversidad, 0, 'C', 0, 1);

    <!-- Comprueba si tiene embargos -->
    function tieneConcepto($concepto) {
        if ($concepto == 52 || $concepto == 180 || $concepto == 181 || $concepto == 182 || $concepto == 338)
            return true;
    }
        

    $tabla = '';
    $tabla .= '<table border="0" width="'.$ancho_tabla.'">';
    $tabla .=   '<tr>';
    $tabla .=     '<td>';
    $tabla .=       '<table border="0" width="'.$ancho_tabla.'">';
    $tabla .=         $informe;
    $tabla .=       '</table>';
    $tabla .=     '</td>';
    $tabla .=   '</tr>';
    $tabla .= '</table>';

    <!-- Agrega la informacion al PDF -->
      $pdf->htmltable($tabla);
      $pdf->AliasNbPages();

    $agentePDF = preg_replace('/[^A-Za-z0-9_-]/', '_', $agente);
    $pdf->Output('InformeEmbargos_' . $agentePDF . '.pdf', 'I');
</xsl:template>

</xsl:stylesheet>