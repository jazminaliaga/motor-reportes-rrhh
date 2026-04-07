<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="owner" select="'SIU-Mapuche'"/>
  <xsl:output method="html" encoding="iso-8859-1" indent="no"/>

  <xsl:template match="detalle_liquidacion">
    
    <!-- Utilizado en Informes->Liquidacion->Detalle Liquidacion -->
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
      list($w, $h) = $pdf->DefPageFormat; <!-- Toma el ancho y el alto total de la pagina -->
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
      $certificado = '';
      $fecha = '<xsl:value-of select="datos_adicionales/fecha_actual"/>';
      $fechaMes = '<xsl:value-of select="concat(substring-after(datos_adicionales/fecha_actual, ' de '), ' ')"/>';
      $agente = '<xsl:value-of select="legajos/legajo/agente"/>';
      $documento = '<xsl:value-of select="legajos/legajo/documento/valor"/>';
      $legajo = '<xsl:value-of select="legajos/legajo/nro_legaj"/>';
    
    <!-- Texto del certificado-->
		$titulo = 'REPORTE DE SISTEMA - PRUEBA DE CONCEPTO. Fecha de inicio del caso: ';
		$cuerpoCodigo = ' se aplicó la regla de negocio para el concepto de prueba 61, al usuario ';
		$cuerpoAgente = ''; // Dejalo vacío para que no sume texto extra
		$cuerpoDNI = 'ID-DOC N° ';
		$cuerpoLegajo = 'ID-INTERNO N° ';
		$certifica = 'Documento autogenerado por el pipeline XSLT para demostración técnica en ';
		$cuerpoCierre = 'ENTORNO DE DESARROLLO, a los ';

    <!-- Agrega certificado de deporte a una fila de tabla -->
      $cuerpo = $titulo.$fechaMes.$cuerpoCodigo.$cuerpoAgente.' '.$agente.' '.$cuerpoDNI.' '.$documento.' '.$cuerpoLegajo.' '.$legajo.'.';
      $pdf->MultiCell($ancho_tabla, 10, $cuerpo, 0, 'J', 0, 1);
      $pdf->Ln(5);
      $cierre = $certifica.$cuerpoCierre.' '.$fecha.'.';
      $pdf->MultiCell($ancho_tabla, 10, $cierre, 0, 'J', 0, 1);

    $tabla = '';
    $tabla .= '<table border="0" width="'.$ancho_tabla.'">';
    $tabla .=   '<tr>';
    $tabla .=     '<td>';
    $tabla .=       '<table border="0" width="'.$ancho_tabla.'">';
    $tabla .=         $certificado;
    $tabla .=       '</table>';
    $tabla .=     '</td>';
    $tabla .=   '</tr>';
    $tabla .= '</table>';

    <!-- Agrega la informacion al PDF -->
      $pdf->htmltable($tabla);
      $pdf->AliasNbPages();

    $agentePDF = preg_replace('/[^A-Za-z0-9_-]/', '_', $agente);
    $pdf->Output('certificadoDerporte_' . $agentePDF . '.pdf', 'I');
</xsl:template>

</xsl:stylesheet>