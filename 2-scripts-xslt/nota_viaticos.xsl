<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="owner" select="'SIU-Mapuche'"/>
  <xsl:output method="html" encoding="iso-8859-1" indent="no"/>

  <xsl:template match="detalle_liquidacion">
    
    <!-- Utilizado en Informes->Liquidación->Detalle Liquidación -->
      ini_set('max_execution_time','0');

    <!-- OPCIONES CONFIGURABLES EN EL POPUP DE IMPRESIÓN -->
      <!-- Logo -->
      define('LOGO', (isset($logo))? $logo : 'logo_institucion.png');
      define('LOGO_X', (isset($logo_x))? $logo_x : 15);
      define('LOGO_Y', (isset($logo_y))? $logo_y : 5);
      define('LOGO_W', (isset($logo_w))? $logo_w : 35);
      define('LOGO_H', (isset($logo_h))? $logo_h : 14);
      
    <!-- Opciones de página -->
      <!-- Márgenes-->
      define('IZQ', (isset($izq))? $izq : 20);
      define('TOP', (isset($top))? $top : 20);
      define('DER', (isset($der))? $der : 20);
      <!-- Formato de página -->
      define('TIPO', (isset($sze))? $sze : 'a4');
      define('POS', (isset($pos))? $pos : 'p');

    <!-- PDF generales -->
      $pdf = new PDF(POS, 'mm', TIPO);
      $pdf->SetFont('Arial', '', 4);
      $pdf->setTitulo(' ');
      $pdf->set_path_personalizacion($pdf_dir_personalizado);
      $pdf->SetMargins(IZQ, TOP, DER);
      $pdf->set_imagen_encabezado(LOGO, LOGO_X, LOGO_Y, LOGO_W, LOGO_H);
    
    <!-- Define los límites de la página -->
      list($w, $h) = $pdf->DefPageFormat; <!-- Toma el ancho y largo total de la página -->
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

    $tabla_datos  =   '<tr bgcolor="#c6c6c6">';

    <!-- Datos sacados del xml -->
      $tabla_datos .= '</tr>';
      $nota = '';
      $fecha = '<xsl:value-of select="datos_adicionales/fecha_actual"/>';
      $agente = '<xsl:value-of select="legajos/legajo/agente"/>';
      $documento = '<xsl:value-of select="legajos/legajo/documento/valor"/>';
      $legajo = '<xsl:value-of select="legajos/legajo/nro_legaj"/>';
      $montosAcumulados = 0;
      $horasCalculadas  = 0;
      $notasGeneradas = [];

    <!-- Itera todos los cargos por legajo para sacar las horas -->
      <xsl:for-each select="legajos/legajo/cargos/cargo">

        <!-- Datos del cargo -->
          $uAcademica = '<xsl:value-of select="codc_uacad"/>';
          $categoria = '<xsl:value-of select="codc_categ"/>';
          $horas = <xsl:value-of select="cant_horas"/>;
          $monto1 = floatval('<xsl:value-of select="sum(conceptos/concepto[codn_conce='1']/impp_conce)"/>');
          $monto86 = floatval('<xsl:value-of select="conceptos/concepto[codn_conce='86']/impp_conce"/>');
          $montoTotal = ($monto86 != null) ? ($monto1 + $monto86) : $monto1;
          $montosAcumulados += $montoTotal;
          $claveAgrupada = $claveAgrupada ?? '';
          $data = $data ?? '';

          <!-- Verifica si la categoría es válida -->
          if (esCodigoValido($categoria)) {  
            <!-- Determina la clave agrupada -->
              $sufijo = substr($categoria, -2);
              $claveAgrupada = ($sufijo == "SE" || $sufijo == "SU") ? $sufijo : (substr($categoria, 0, 2) == "JC" ? "JC" : null);

            <!-- Crear una clave única combinando la clave agrupada y la unidad académica -->
              $claveUnica = $claveAgrupada . '_' . $uAcademica;
            <!-- Si la clave única no existe, inicializar con la unidad académica actual -->
              if (!isset($horasPorCategoria[$claveUnica])) {
                  $horasPorCategoria[$claveUnica] = [
                      'uAcademica' => $uAcademica,
                      'horas' => 0,
                      'montosAcumulados' => 0,
                  ];
              }

              <!-- Acumula horas y montos en la clave única -->
              $horasPorCategoria[$claveUnica]['horas'] += $horas;
              $horasPorCategoria[$claveUnica]['montosAcumulados'] += $montoTotal;

          } else {
            <!-- Datos del cargo -->
              $categoria = '<xsl:value-of select="codc_categ"/>';
              $descCategoria = '<xsl:value-of select="desc_categ"/>';
              $descDedicacion = '<xsl:value-of select="desc_dedic"/>';

            <!-- Texto de la nota -->
				$titulo = 'REPORTE AUTOGENERADO (MOCK DATA) ';
				$cuerpoFecha = 'Registro de proceso con fecha: ';
				$cuerpoAgente = 'Se procesó la información del usuario de prueba ';
				$cuerpoDNI = 'ID-DOC N° ';
				$cuerpoLegajo = 'ID-INTERNO N° ';
				$cuerpoCategoria = 'Clasificación asignada: ';
				$cuerpoRetribucion = 'Valor de prueba calculado: $';
				$cuerpoFirmaNombre = 'USUARIO DE SISTEMA';
				$cuerpoFirmaDir = 'ÁREA DE DESARROLLO';
				$cuerpoFirmaUniversidad = 'ENTORNO DE PRUEBA';
				$montoSuma = $monto1 + $monto86;
				$montoTexto = montos($monto1, $monto86, $montoSuma, $claveAgrupada, $montoSuma);
				$montosAcumulados -= $montoSuma;

            <!-- Impresión de la nota -->
            $pdf->addPage(); <!-- Agrega una pagina por cada cargo -->
            $tituloNota = $titulo . $agente;
            $pdf->MultiCell($ancho_tabla, 10, $tituloNota, 0, 'C', 0, 1); <!-- Titulo centrado -->
            $pdf->Ln(5); <!-- Salto de línea -->
            $cuerpo = $cuerpoFecha . $fecha . ' ' . $cuerpoAgente . $agente . ' ' . $cuerpoDNI . $documento . ' ' .
                  $cuerpoLegajo . $legajo . ' ' . $cuerpoCategoria  . dedicacion($categoria, $descCategoria, $descDedicacion) .
                  ($monto86 != null ? ' (Mayor Responsabilidad)' : '') . ' ' .
                  $cuerpoRetribucion . $montoTotal . 
                  ' (' . $montoTexto . ').';
            $pdf->MultiCell($ancho_tabla, 10, $cuerpo, 0, 'J', 0, 1); <!-- Cuerpo justificado -->
            $pdf->Ln(15);<!-- Salto de línea -->
            <!-- Firma -->
              $pdf->SetX(210- $ancho_tabla*0.9); <!-- alinea a la derecha-->
              $pdf->MultiCell($ancho_tabla, 5, $cuerpoFirmaNombre, 0, 'C', 0, 1);
              $pdf->SetX(210 - $ancho_tabla*0.9); <!-- alinea a la derecha-->
              $pdf->MultiCell($ancho_tabla, 5, $cuerpoFirmaDir, 0, 'C', 0, 1);
              $pdf->SetX(210 - $ancho_tabla*0.9); <!-- alinea a la derecha-->
              $pdf->MultiCell($ancho_tabla, 5, $cuerpoFirmaUniversidad, 0, 'C', 0, 1);
          }
      </xsl:for-each>

    <xsl:for-each select="legajos/legajo/cargos/cargo">
      $montosAcumulados += $data['montosAcumulados'];
    </xsl:for-each>

    if ($claveAgrupada != null) {
      $resumenHoras = '';
      $notasGeneradas = [];

      foreach ($horasPorCategoria as $categoriaCompleta => $data) {
          $categoria = explode('_', $categoriaCompleta)[0];
          $uAcademica = $data['uAcademica'];

          if (!isset($notasGeneradas[$uAcademica])) {
            <!-- Inicializa la nota para la unidad académica-->
            $notasGeneradas[$uAcademica] = [
              'cuerpo' => '',
              'horas' => 0,
              'montosAcumulados' => 0
            ];
          }

          $notasGeneradas[$uAcademica]['cuerpo'] .= "\nUnidad Académica: " . $uAcademica . 
                                                    ", Categoría: " . $categoria . 
                                                    ", Horas: " . $data['horas'];
          $notasGeneradas[$uAcademica]['horas'] += $data['horas'];
          $notasGeneradas[$uAcademica]['montosAcumulados'] += $data['montosAcumulados'];
      }

      <!-- Itera todos los cargos por legajo para sacar las notas -->
        <xsl:for-each select="legajos/legajo/cargos/cargo">
          <!-- Datos del cargo -->
            $categoria = '<xsl:value-of select="codc_categ"/>';
            $descCategoria = '<xsl:value-of select="desc_categ"/>';
            $uAcademica = '<xsl:value-of select="codc_uacad"/>';

          <!-- Texto de la nota -->
            $titulo = 'REPORTE AUTOGENERADO (MOCK DATA) ';
			$cuerpoFecha = 'Registro de proceso con fecha: ';
			$cuerpoAgente = 'Se procesó la información del usuario de prueba ';
			$cuerpoDNI = 'ID-DOC N° ';
			$cuerpoLegajo = 'ID-INTERNO N° ';
			$cuerpoCategoria = 'Clasificación asignada: ';
			$cuerpoRetribucion = 'Valor de prueba calculado: $';
			$cuerpoFirmaNombre = 'USUARIO DE SISTEMA';
			$cuerpoFirmaDir = 'ÁREA DE DESARROLLO';
			$cuerpoFirmaUniversidad = 'ENTORNO DE PRUEBA';

        </xsl:for-each>

      <!-- Arreglo de linea de nota -->
        
      foreach ($notasGeneradas as $uAcademica => $nota) {
        $pdf->addPage();
        $cuerpoRetribucion = 'Su retribución es de $';
        
        $tituloNota = $titulo . $agente;
        $pdf->MultiCell($ancho_tabla, 10, $tituloNota, 0, 'C', 0, 1); <!-- Titulo centrado -->
        $pdf->Ln(5); <!-- Salto de línea -->
        
        $cuerpo = $cuerpoFecha . $fecha . ' ' . $cuerpoAgente . $agente . ' ' . $cuerpoDNI . $documento . ' ' .
              $cuerpoLegajo . $legajo . ' ' . $nota['cuerpo'] .
              '&#10;' . $cuerpoRetribucion . $nota['montosAcumulados'] . ' (' . formatoMonto($nota['montosAcumulados']) . '). ';
        $pdf->MultiCell($ancho_tabla, 10, $cuerpo, 0, 'J', 0, 1); <!-- Cuerpo justificado -->
        $pdf->Ln(15);<!-- Salto de línea -->
      
      <!-- Firma -->
        $pdf->SetX(210- $ancho_tabla*0.9); <!-- alinea a la derecha-->
        $pdf->MultiCell($ancho_tabla, 5, $cuerpoFirmaNombre, 0, 'C', 0, 1);
        $pdf->SetX(210 - $ancho_tabla*0.9); <!-- alinea a la derecha-->
        $pdf->MultiCell($ancho_tabla, 5, $cuerpoFirmaDir, 0, 'C', 0, 1);
        $pdf->SetX(210 - $ancho_tabla*0.9); <!-- alinea a la derecha-->
        $pdf->MultiCell($ancho_tabla, 5, $cuerpoFirmaUniversidad, 0, 'C', 0, 1);
      }
        
    }

    <!-- Agregar descripción de la dedicación -->
    function dedicacion($categoria, $descCategoria, $descDedicacion) {
      $categorias_con_dedicacion = [
        "ADJ1", "ADJ2", "ADJ3", "AYP1", "AYP2", "AYP3", "AYSG", "CFAC", "CFAP", "CFBC", "CFBP", "CFCC", "CFCP", 
        "CFDC", "CFDP", "CFEC", "CFEP", "CUAC", "CUBC", "DEC1", "DEC2", "DEC3", "DECS", "JTP1", "JTP2", "JTP3", 
        "PAS1", "PAS2", "PAS3", "PTT1", "PTT2", "PTT3", "REC3", "SEF1", "SEF2", "SEF3", "SEFS", "SEU1", "SEU2", 
        "SEU3", "SEUS", "VID1", "VID2", "VID3", "VIDS", "VIR1", "VIR2", "VIR3", "VIRS"
      ];

      $infoCategoria = ($descCategoria != '' ? $descCategoria : $categoria);
      if (in_array($categoria, $categorias_con_dedicacion)) {
          $infoCategoria .= ' ' . $descDedicacion;
      }

      return ($infoCategoria);
    }

    <!-- Busca si el código del cargo coincide con alguno de la lista -->
      function esCodigoValido($categoria) {
        $codigosValidos = [
            "10SE", "10SU", "11SE", "11SU", "12SE", "12SU", "13SE", "13SU",
            "14SE", "14SU", "15SE", "15SU", "16SE", "16SU", "17SE", "17SU",
            "18SE", "18SU", "19SE", "19SU", "1SE", "1SU", "20SE", "20SU",
            "21SE", "21SU", "22SE", "22SU", "23SE", "23SU", "24SE", "24SU",
            "25SE", "25SU", "26SE", "26SU", "27SE", "27SU", "28SE", "28SU",
            "29SE", "29SU", "2SE", "2SU", "30SE", "30SU", "31SE", "31SU",
            "32SE", "32SU", "33SE", "33SU", "34SE", "34SU", "35SE", "35SU",
            "36SE", "36SU", "3SE", "3SU", "4SE", "4SU", "5SE", "5SU", "6SE",
            "6SU", "7SE", "7SU", "8SE", "8SU", "9SE", "9SU", "JC01", "JC02",
            "JC03", "JC04", "JC05", "JC06", "JC07", "JC08", "JC09", "JC10",
            "JC11", "JC12"
        ];
        return in_array($categoria, $codigosValidos);
      }

    <!-- Elige monto a escribir -->
      function montos($monto1, $monto86, $montoSuma, $claveAgrupada, $montosAcumulados) {
        if (mayorResp($monto86) == true)
          return formatoMonto($montoSuma);
        elseif ($claveAgrupada != null)
          return formatoMonto($montosAcumulados);
        elseif ($claveAgrupada == null)
          return formatoMonto($montoSuma);
      }

    <!-- Formatea monto -->
      function formatoMonto($monto) {
        $monto = number_format($monto, 2, '.', ''); // Asegurar que tenga 2 decimales
        $partes = explode('.', $monto);
        $montoEntero = (int) $partes[0];
        $montoDecimal = (int) $partes[1];

        $letrasEntero = escribirMonto($montoEntero);
        $letrasDecimal = $montoDecimal &gt; 0 ? ' con ' . $montoDecimal . '/100' : '';

        return $letrasEntero . $letrasDecimal . ' pesos';
      }

    <!-- Escribe monto -->
      function escribirMonto($monto) {
        $unidad = ['', 'uno', 'dos', 'tres', 'cuatro', 'cinco', 'seis', 'siete', 'ocho', 'nueve', 'diez', 'once', 'doce', 'trece', 'catorce', 'quince', 'dieciséis', 'diecisiete', 'dieciocho', 'diecinueve'];
        $decena = ['', '', 'veinte', 'treinta', 'cuarenta', 'cincuenta', 'sesenta', 'setenta', 'ochenta', 'noventa'];
        $centena = ['', 'ciento', 'doscientos', 'trescientos', 'cuatrocientos', 'quinientos', 'seiscientos', 'setecientos', 'ochocientos', 'novecientos'];
        
        <!-- Asegura que el monto es un número entero -->
          $numero = (int)$monto;

        if ($numero &lt; 20) {
            return $unidad[$numero];
        } elseif ($numero &lt; 100) {
            return $decena[(int)($numero / 10)] . ($numero % 10 != 0 ? ' y ' . $unidad[$numero % 10] : '');
        } elseif ($numero &lt; 1000) {
            $centenaIndex = (int)($numero / 100);
            $resto = $numero % 100;
            <!-- Si es 100 exacto, usa "cien"; de lo contrario, "ciento + resto" -->
            if ($centenaIndex == 1 and $resto == 0) {
            return 'cien';
            } else {
              return $centena[$centenaIndex] . ($resto != 0 ? ' ' . escribirMonto($resto) : '');
            }
        } elseif ($numero &lt; 1000000) {
          $miles = (int)($numero / 1000);
          $resto = $numero % 1000;
          <!-- Maneja el caso especial cuando los miles terminan en 1 -->
          if ($miles % 10 == 1 and $miles != 11) {
              $milesTexto = escribirMonto($miles - 1) . ' un';
          } else {
              $milesTexto = escribirMonto($miles);
          }
          return $milesTexto . ' mil' . ($resto != 0 ? ' ' . escribirMonto($resto) : '');
        } elseif ($numero &lt; 1000000000) {
            $millones = (int)($numero / 1000000);
            return ($millones == 1 ? 'un millón' : escribirMonto($millones) . ' millones') . ($numero % 1000000 != 0 ? ' ' . escribirMonto($numero % 1000000) : '');
        }
        return '';
      }

    <!-- Retorna true si encuentra concepto 86 (Mayor responsabilidad) -->
      function mayorResp($monto86) {
        if($monto86 !== null) 
          return true;
        return false;
      }

    $tabla = '';
    $tabla .= '<table border="0" width="'.$ancho_tabla.'">';
    $tabla .=   '<tr>';
    $tabla .=     '<td>';
    $tabla .=       '<table border="0" width="'.$ancho_tabla.'">';
    $tabla .=         $nota;
    $tabla .=       '</table>';
    $tabla .=     '</td>';
    $tabla .=   '</tr>';
    $tabla .= '</table>';

    <!-- Agrega la informacion al PDF -->
      $pdf->htmltable($tabla);
      $pdf->AliasNbPages();

    $agentePDF = preg_replace('/[^A-Za-z0-9_-]/', '_', $agente);
    $pdf->Output('viatico_' . $agentePDF . '.pdf', 'I');

  </xsl:template>

</xsl:stylesheet>