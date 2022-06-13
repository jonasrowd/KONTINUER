//Bibliotecas necess�rias
#Include "TOTVS.ch"
#Include "RWMAKE.ch"

#Define ENTER CHR(13)+CHR(10) // Pula linha

/*/{Protheus.doc} KCOMF034
    Monta interface gr�fica da rotina
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 10/05/2022
/*/
User Function KCOMF034(cDoc,cSerie,cFornec,cLoja)

    Private aSize     := {}                                                                         // Array com dimens�es para posicionamento de elementos
    Private aGets     := {}                                                                         // Array para capturar as informa��es da consulta padr�o
    Private aL1       := {}                                                                         // Array com dados do Documento        
    Private aL2       := {}                                                                         // Array com dados dos pedidos amarrados na Documento                
    Private aDados    := Array(3)                                                                   // Array unidimensional com 3 posi��es para apresenta��o de informa��es do Documento na tela
    Private oFon1	  := TFont():New("Calibri", 07, 18, Nil, .F., Nil, Nil, Nil, .T., .F.)          // Fonte utilizada na constru��o de textos da tela
    Private oFon2	  := TFont():New("Calibri", 07, 18, Nil, .F., Nil, Nil, Nil, .T., .F.)          // Fonte utilizada para constru��o de textos da tela
    Private oBt01     := Nil                                                                        // Objeto para manipular o bot�o de reinicializa��o de vari�veis
    Private oL1       := Nil                                                                        // Objeto para manipular m�todos do browse dos itens do Documento
    Private oL2       := Nil                                                                        // Objeto para manipular m�todos do browse dos pedidos
    Private oOn		  := LoadBitmap(GetResources(), "BR_VERDE")                                     // Tudo ok com a Documento e o pedido
    Private oSd1	  := LoadBitmap(GetResources(), "BR_AMARELO")                                   // Quantidade divergente entre documento e pedido
    Private oSd2	  := LoadBitmap(GetResources(), "BR_VERMELHO")                                  // Pre�o divergente entre documento e pedido
    Private oSd3	  := LoadBitmap(GetResources(), "BR_LARANJA")                                   // Ambos divergentes, pre�o e quantidade
    Private cFlag     := ""
    Private oT01      := Nil
    Private cPed      := ""

    // Salva o tamanho da tela
    aSize := MsAdvSize(.F.)
        
    //Inicializa o vetor com dados da consulta padr�o
    Aadd(aGets, {Nil, cDoc, "Documento", .T.})
    Aadd(aGets, {Nil, cSerie, "S�rie", .T.})
    Aadd(aGets, {Nil, cFornec, "Fornecedor.", .T.})
    Aadd(aGets, {Nil, cLoja, "Loja", .T.})
    Aadd(aGets, {Nil, KCOMF034W(), "Pedido", .T.})

    //Define a tela 
    Define MsDialog oT01 Title " Confer�ncia do Documento " From 000, 000 To 203, 394 Pixel

    //Maxmiza a tela
    oT01:lMaximized := .T.

    //Grupo 01 cabe�alho da interface gr�fica
    @ 003, 003 To 038, (aSize[5]/2) Title " Cabe�alho do Documento "

    // Dados a serem carregados no cabe�alho da interface gr�fica
    // N�mero do Documento
    TSay():Create(oT01, &("{|| '" + aGets[01][03] + "'}"), 012, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
    @ 020, 007 MsGet aGets[01][01] Var aGets[01][02] Picture "@!" Size 050, 010 Of oT01 Pixel When .F.
    // S�rie do Documento
    TSay():Create(oT01, &("{|| '" + aGets[02][03] + "'}"), 012, 70, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
    @ 020, 70 MsGet aGets[02][01] Var aGets[02][02] Picture "@!" Size 030, 010 Of oT01 Pixel When .F.
    // Fornecedor amarrado na Documento
    TSay():Create(oT01, &("{|| '" + aGets[03][03] + "'}"), 012, 120, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
    @ 020, 120 MsGet aGets[03][01] Var aGets[03][02] Picture "@!" Size 030, 010 Of oT01 Pixel When .F.
    // Loja do fornecedor amarrado na Documento
    TSay():Create(oT01, &("{|| '" + aGets[04][03] + "'}"), 012, 170, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
    @ 020, 170 MsGet  aGets[04][01] Var aGets[04][02] Picture "@!" Size 020, 010 Of oT01 Pixel When .F.

    //Grupo 02 Tela intermedi�ria da interface gr�fica
    @ 041, 003 To 075, (aSize[5]/2) Title " Dados do Documento "

    // Descri��o dos dados a serem carregados na interface gr�fica
    TSay():Create(oT01, &("{|| 'NF/S�rie:       '}"), 049, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(255, 0, 0), Nil, 290, 30)
    TSay():Create(oT01, &("{|| 'Emiss�o:        '}"), 049, 114, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(255, 0, 0), Nil, 290, 30)
    TSay():Create(oT01, &("{|| 'Nome Fornecedor:'}"), 062, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(255, 0, 0), Nil, 290, 30)

    // Preenche os dados na interface intermedi�ria
    aDados[1] := TSay():Create(oT01, &("{|| ''}"), 049, 040, Nil, oFon2, Nil, Nil, Nil, .T., Rgb(0, 0, 205), Nil, 290, 30)
    aDados[2] := TSay():Create(oT01, &("{|| ''}"), 049, 145, Nil, oFon2, Nil, Nil, Nil, .T., Rgb(0, 0, 205), Nil, 290, 30)
    aDados[3] := TSay():Create(oT01, &("{|| ''}"), 062, 065, Nil, oFon2, Nil, Nil, Nil, .T., Rgb(0, 0, 205), Nil, 290, 30)

    // Grupo 03 respons�vel pela interface gr�fica que engloba os itens do Documento e os itens dos pedidos amarrados na Documento
    // @ 009, (aSize[5]/2) - 19 To 24, ((aSize[5]/2) - 03) Title ""

    // Interface gr�fica para montar a tela de itens do Documento 
    @ 078, 003 To ((aSize[6]/2) - 15) , ((aSize[5]/2) * 0.5) Title " Itens do Documento "

    // Legendas relacionadas com os itens do Documento
    TBtnBmp2():New((aSize[6] - 20), 010, 22, 22, 'BR_VERDE', Nil, Nil, Nil, {|| }, oT01, "", Nil, .T.)
    TSay():Create(oT01, &("{|| 'Confere com o Pedido'}"), ((aSize[6]/2) - 09), 20, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(54, 62, 62), Nil, 290, 30)

    TBtnBmp2():New((aSize[6] - 20), 210, 22, 22, 'BR_VERMELHO', Nil, Nil, Nil, {|| }, oT01, "", Nil, .T.)
    TSay():Create(oT01, &("{|| 'Pre�o Divergente'}"), ((aSize[6]/2) - 09), 120, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(54, 62, 62), Nil, 290, 30)

    TBtnBmp2():New((aSize[6] - 20), 410, 22, 22, 'BR_AMARELO', Nil, Nil, Nil, {|| }, oT01, "", Nil, .T.)
    TSay():Create(oT01, &("{|| 'Quantidade Divergente'}"), ((aSize[6]/2) - 09), 220, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(54, 62, 62), Nil, 290, 30)

    TBtnBmp2():New((aSize[6] - 20), 610, 22, 22, 'BR_LARANJA', Nil, Nil, Nil, {|| }, oT01, "", Nil, .T.)
    TSay():Create(oT01, &("{|| 'Ambos Divergentes'}"), ((aSize[6]/2) - 09), 320, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(54, 62, 62), Nil, 290, 30)

    oBt01 := TBtnBmp2():New(38, 410, 23, 23, 'RPMNEW', Nil, Nil, Nil, {|| U_ETIQK009(aGets[1][2],aGets[2][2],aGets[3][2],aGets[4][2],aGets[5][2]) }, oT01, "ETIQUETAS", Nil, .T.)

    // Interface gr�fica para montar a tela de itens dos pedidos
    @ 078, (((aSize[5]/2) * 0.5) + 020) To ((aSize[6]/2) - 15) , (aSize[5]/2) Title " Itens do Pedido "

    // Monta a Grid dos itens do Documento
    KCOMF034A()
    // Monta a Grid dos itens dos pedidos
    KCOMF034B()

    KCOMF034Z()

    // Bot�es no canto inferior direito da tela respons�veis por Confirmar a execu��o da rotina ou cancelar
    @ ((aSize[6]/2) - 11), ((aSize[5]/2) - 78) Button "Confirmar" Size 037, 012 Pixel Of oT01 Action Processa({|| fchkjust() }, "Confirmando confer�ncia...")
    @ ((aSize[6]/2) - 11), ((aSize[5]/2) - 37) Button "Sair"  Size 037, 012 Pixel Of oT01 Action Close(oT01)

    // Ativa a interface gr�fica e apresenta ao usu�rio
    Activate MsDialog oT01 Centered

Return (Nil)

/*/{Protheus.doc} KCOMF034A
    Fun��o que avalia e realiza a persist�ncia dos dados na grid dos itens do Documento
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 11/05/2022
    @param lRefresh, logical, Recebe verdadeiro para reincializar os dados persistidos na Grid
/*/
Static Function KCOMF034A(lRefresh)

    Local   aCabec    := {" ", " Item", " Produto"," Descri��o", " Unid", " Quantidade", " Vlr. Unit.", " Quant. Dif.", " Pedido", " It.Pc"} // Cabe�alho da Grid
    Local   aColCab   := {}                                                                                                                  // Array com dados das posi��es das colunas da grid
    Local   nAlt      := ((aSize[6]/2) - 106)                                                                                                // Array contentado os dados de altura da grid
    Local   nLarg     := (((aSize[5]/2) * 0.5) - 11)                                                                                         // Array contentado os dados da lagura da Grid

    // Seta valor padr�o
    Default lRefresh := .F.                                                                                                                  // Vari�vel padr�o inicializada para controle da atualiza��o da Grid

    // Adiciona a posi��o das colunas
    Aadd(aColCab, nLarg * 0.02)
    Aadd(aColCab, nLarg * 0.035)
    Aadd(aColCab, nLarg * 0.12)
    Aadd(aColCab, nLarg * 0.35) 
    Aadd(aColCab, nLarg * 0.04) 
    Aadd(aColCab, nLarg * 0.09) 
    Aadd(aColCab, nLarg * 0.10) 
    Aadd(aColCab, nLarg * 0.09)
    Aadd(aColCab, nLarg * 0.07)
    Aadd(aColCab, nLarg * 0.045)
                    
    //Verifica se o vetor est� ainda n�o foi preenchido com os dados
    If (Empty(aL1))
        
        //Adidiona os dados ao array
        Aadd(aL1, { "",;  //01 - Item
                    "",;  //02 - Produto
                    "",;  //03 - Descri��o
                    "",;  //04 - Unidade
                    0 ,;  //05 - Quantidade
                    0 ,;  //06 - Vlr. Unit�rio
                    0 ,;  //07 - Saldo a Vincular
                    "",;  //08 - Pedido
                    "",;  //09 - Item Pedido
                    0 ,;  //10 - Prod Vinculado
                    "",;  //11 - NCM
                    .T.;  //12 - Legenda
                    })
    EndIf

    // Verifica se � atualiza��o
    If (!lRefresh)

        //Monta a listbox
        oL1 := TCBrowse():New(087                     ,; //01 - Linha 
                            007                       ,; //02 - Coluna
                            nLarg                     ,; //03 - Largura
                            nAlt                      ,; //04 - Altura
                            Nil                       ,; //05 - Indica o bloco de c�digo da lista de campos. Observa��o: Esse par�metro � utilizado somente quando o browse trabalha com array.
                            aCabec                    ,; //06 - Cabe�alho
                            aColCab                   ,; //07 - Tamanho das colunas 
                            oT01                      ,; //08 - Objeto principal
                            Nil                       ,; //09 - Indica os campos necess�rios para o filtro.
                            Nil                       ,; //10 - Indica o in�cio do intervalo para o filtro.
                            Nil                       ,; //11 - Indica o fim do intervalo para o filtro.
                            Nil                       ,; //12 - Indica o bloco de c�digo que ser� executado ao mudar de linha.
                            {|| }                     ,; //13 - Indica o bloco de c�digo que ser� executado quando clicar duas vezes, com o bot�o esquerdo do mouse, sobre o objeto.
                            Nil                       ,; //14 - Indica o bloco de c�digo que ser� executado quando clicar, com o bot�o direito do mouse, sobre o objeto.
                            oFon2                     ,; //15 - Indica o objeto do tipo TFont utilizado para definir as caracter�sticas da fonte aplicada na exibi��o do conte�do do controle visual.
                            Nil                       ,; //16 - Indica o tipo de ponteiro do mouse.
                            Nil                       ,; //17 - Indica a cor do texto da janela.
                            Nil                       ,; //18 - Indica a cor de fundo da janela.
                            ""                        ,; //19 - Indica a mensagem ao posicionar o ponteiro do mouse sobre o objeto.
                            .F.                       ,; //20 - Compatibilidade.
                            Nil                       ,; //21 - Indica se o objeto � utilizado com array (opcional) ou tabela (obrigat�rio).
                            .T.                       ,; //22 - Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
                            {||}                      ,; //23 - Indica o bloco de c�digo que ser� executado quando a mudan�a de foco da entrada de dados, na janela em que o controle foi criado, estiver sendo efetuada. Observa��o: O bloco de c�digo retornar� verdadeiro (.T.) se o controle permanecer habilitado; caso contr�rio, retornar� falso (.F.).
                            .F.                       ,; //24 - Compatibilidade
                            {||}                      ,; //25 - Indica o bloco de c�digo de valida��o que ser� executado quando o conte�do do objeto for modificado. Retorna verdadeiro (.T.), se o conte�do � v�lido; caso contr�rio, falso (.F.).
                            .T.                       ,; //26 - Indica se habilita(.T.)/desabilita(.F.) a barra de rolagem horizontal.
                            .T.                        ; //27 - Indica se habilita(.T.)/desabilita(.F.) a barra de rolagem vertical.
                            ) 

    EndIf

    // Adiciona os dados que ser�o persistidos na GRid de itens do Documento
    oL1:SetArray(aL1)

        // Visualiza 
        oL1:bLine := {||{If((aL1[oL1:nAt][07] == 0 .AND. aL1[oL1:nAt][10] == 0), oOn,;
                        If((aL1[oL1:nAt][07] == 0 .AND. aL1[oL1:nAt][10] != 0), oSd2,;
                        If((aL1[oL1:nAt][07] != 0 .AND. aL1[oL1:nAt][10] == 0),oSd1,oSd3)))           ,;
                        aL1[oL1:nAt][01]	                             ,; 
                        aL1[oL1:nAt][02]	                             ,; 
                        aL1[oL1:nAt][03]	                             ,;
                        aL1[oL1:nAt][04]	                             ,;
                        Transform(aL1[oL1:nAt][05], "@E 999,999,999.99") ,;
                        Transform(aL1[oL1:nAt][06], "@E 999,999,999.99") ,;
                        Transform(aL1[oL1:nAt][07], "@E 999,999,999.99") ,;
                        aL1[oL1:nAt][08]	                             ,; 
                        aL1[oL1:nAt][09]	                              ;
            }} 

    //Altura da coluna
    oL1:nLinhas := 2

    oL1:lLineDrag := .T.

    // Ajusta as colunas
    oL1:lAdjustColSize := .F.

    // Atualiza
    oL1:Refresh()

Return (Nil)

/*/{Protheus.doc} KCOMF034B
    Fun��o que avalia e realiza a persist�ncia dos dados na grid dos itens dos pedidos
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 11/05/2022
    @param lRefresh, logical, Recebe verdadeiro para reincializar os dados persistidos na Grid
/*/
Static Function KCOMF034B(lRefresh)

    Local   aCabec    := {" ", " Pedido", " Item"," Produto", " Unid", " Qtde.", " Prc Un.", " Sd. a Entr.", " Pre�o Dif."}      // Cabe�alho da GRid de itens dos pedidos
    Local   aColCab   := {}                                                                                                     // Posicionamento das colunas da grid
    Local   nAlt      := ((aSize[6]/2) - 106)                                                                                   // Altura da grid
    Local   nLarg     := (((aSize[5]/2) * 0.5) - 28)                                                                            // Largura da grid

    //Seta valor padr�o
    Default lRefresh := .F.

    //Adiciona a posi��o das colunas
    Aadd(aColCab, nLarg * 0.02)
    Aadd(aColCab, nLarg * 0.07)
    Aadd(aColCab, nLarg * 0.05)
    Aadd(aColCab, nLarg * 0.35)
    Aadd(aColCab, nLarg * 0.04) 
    Aadd(aColCab, nLarg * 0.08) 
    Aadd(aColCab, nLarg * 0.10) 
    Aadd(aColCab, nLarg * 0.10)
    Aadd(aColCab, nLarg * 0.10)
                    
    //Verifica se tem dados
    If (Empty(aL2))
        
        //Adidiona os dados ao array
        Aadd(aL2, {"" ,; //01 - Pedido
                "" ,; //02 - Item do XML (Desativado)
                "" ,; //03 - Item ERP
                "" ,; //04 - Produto
                "" ,; //05 - Unidade
                0  ,; //06 - Quantidade
                0  ,; //07 - Pre�o Unit�rio
                0  ,; //08 - Saldo a Antregar
                0  ,; //09 - Diferen�a
                ""  ; //10 - C�digo do produto
                })
    EndIf

    //Verifica se � atualiza��o
    If (!lRefresh)

        //Monta a listbox
        oL2 := TCBrowse():New(087                       ,; //01 - Linha 
                        (((aSize[5]/2) * 0.5) + 024) ,; //02 - Coluna
                            nLarg                     ,; //03 - Largura
                            nAlt                      ,; //04 - Altura
                            Nil                       ,; //05 - Indica o bloco de c�digo da lista de campos. Observa��o: Esse par�metro � utilizado somente quando o browse trabalha com array.
                            aCabec                    ,; //06 - Cabe�alho
                            aColCab                   ,; //07 - Tamanho das colunas 
                            oT01                      ,; //08 - Objeto principal
                            Nil                       ,; //09 - Indica os campos necess�rios para o filtro.
                            Nil                       ,; //10 - Indica o in�cio do intervalo para o filtro.
                            Nil                       ,; //11 - Indica o fim do intervalo para o filtro.
                            Nil                       ,; //12 - Indica o bloco de c�digo que ser� executado ao mudar de linha.
                            {||}                      ,; //13 - Indica o bloco de c�digo que ser� executado quando clicar duas vezes, com o bot�o esquerdo do mouse, sobre o objeto.
                            Nil                       ,; //14 - Indica o bloco de c�digo que ser� executado quando clicar, com o bot�o direito do mouse, sobre o objeto.
                            oFon2                     ,; //15 - Indica o objeto do tipo TFont utilizado para definir as caracter�sticas da fonte aplicada na exibi��o do conte�do do controle visual.
                            Nil                       ,; //16 - Indica o tipo de ponteiro do mouse.
                            Nil                       ,; //17 - Indica a cor do texto da janela.
                            Nil                       ,; //18 - Indica a cor de fundo da janela.
                            ""                        ,; //19 - Indica a mensagem ao posicionar o ponteiro do mouse sobre o objeto.
                            .F.                       ,; //20 - Compatibilidade.
                            Nil                       ,; //21 - Indica se o objeto � utilizado com array (opcional) ou tabela (obrigat�rio).
                            .T.                       ,; //22 - Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
                            {||}                      ,; //23 - Indica o bloco de c�digo que ser� executado quando a mudan�a de foco da entrada de dados, na janela em que o controle foi criado, estiver sendo efetuada. Observa��o: O bloco de c�digo retornar� verdadeiro (.T.) se o controle permanecer habilitado; caso contr�rio, retornar� falso (.F.).
                            .F.                       ,; //24 - Compatibilidade
                            {||}                      ,; //25 - Indica o bloco de c�digo de valida��o que ser� executado quando o conte�do do objeto for modificado. Retorna verdadeiro (.T.), se o conte�do � v�lido; caso contr�rio, falso (.F.).
                            .T.                       ,; //26 - Indica se habilita(.T.)/desabilita(.F.) a barra de rolagem horizontal.
                            .T.                        ; //27 - Indica se habilita(.T.)/desabilita(.F.) a barra de rolagem vertical.
                            ) 

    EndIf

    //Monta os dados do listbox                    
    oL2:SetArray(aL2)

        //Visualiza
        oL2:bLine := {||{If((aL1[oL2:nAt][07] == 0 .AND. aL1[oL2:nAt][10] == 0), oOn,;
                        If((aL1[oL2:nAt][07] == 0 .AND. aL1[oL2:nAt][10] != 0), oSd2,;
                        If((aL1[oL2:nAt][07] != 0 .AND. aL1[oL2:nAt][10] == 0),oSd1,oSd3)))    ,;	  
                        aL2[oL2:nAt][01]	                      ,; 
                        aL2[oL2:nAt][03]	                      ,;
                        aL2[oL2:nAt][04]	                      ,;
                        aL2[oL2:nAt][05]	                      ,;
                Transform(aL2[oL2:nAt][06], "@E 999,999,999.99")  ,;
                Transform(aL2[oL2:nAt][07], "@E 999,999,999.99")  ,;
                Transform(aL2[oL2:nAt][08], "@E 999,999,999.99")  ,;
                Transform(aL1[oL2:nAt][10], "@E 999,999,999.99") } ;
                } 

    //Altura da coluna
    oL2:nLinhas := 2

    //Ajuste de colunas
    oL2:lAdjustColSize := .F.

    //Atualiza
    oL2:Refresh()

Return (Nil)

/*/{Protheus.doc} KCOMF034Z
    Fun��o executada na valida��o de preenchimento do campo "Documento" no cabe�alho da rotina
    para preenchimento da grid com os itens do pedido e do cabe�alho com os dados na NF.
    @type Function
    @version 12.1.33
    @author Jonas Machado
    @since 10/05/2022
    @return Variant, Retorno nulo
/*/
Static Function KCOMF034Z()

    // Vari�veis locais
    Local aArea      // �rea anteriormente posicionada
    Local aLine      // Auxiliar de montagem das linhas do grid
    Local cAlias     // Alias do arquivo tempor�rio
    
    // Inicializa��o de vari�veis
    aL2    := {}
    aL1    := {}
    aLine  := {}
    aArea  := FwGetArea()
    cAlias := GetNextAlias()

    // Busca pelos itens do Documento
    BEGINSQL ALIAS cAlias
        SELECT
            SF1.F1_DOC,
            SF1.F1_SERIE,
            SF1.F1_EMISSAO,
            SA2.A2_NOME,
            SD1.D1_ITEM,
            SD1.D1_COD,
            SB1.B1_DESC,
            SD1.D1_UM,
            SD1.D1_QUANT,
            SD1.D1_VUNIT,
            (SC7.C7_QUANT - SD1.D1_QUANT) TMP_SLVINC,
            SD1.D1_PEDIDO,
            SD1.D1_ITEMPC,
            SC7.C7_NUM,
            SC7.C7_ITEM,
            SC7.C7_PRODUTO,
            SC7.C7_UM,
            SC7.C7_QUANT,
            SC7.C7_PRECO,
            (SC7.C7_QUANT - SD1.D1_QUANT) SALDO,
            (SC7.C7_QUANT - SD1.D1_QUANT) TMP_SLDENTR,
            (SC7.C7_PRECO - SD1.D1_VUNIT) TMP_DIFPRC
        FROM %TABLE:SD1% SD1 
            INNER JOIN %TABLE:SF1% SF1 ON SF1.F1_FILIAL = SD1.D1_FILIAL
                    AND SF1.F1_DOC = SD1.D1_DOC
                    AND SF1.F1_SERIE = SD1.D1_SERIE
                    AND SF1.F1_FORNECE = SD1.D1_FORNECE
                    AND SF1.F1_LOJA = SD1.D1_LOJA
                    AND SF1.%NOTDEL%
            INNER JOIN %TABLE:SB1% SB1 ON SB1.B1_COD = SD1.D1_COD
                    //AND SB1.B1_FILIAL = SD1.D1_FILIAL
                    AND SB1.%NOTDEL%
            INNER JOIN %TABLE:SA2% SA2 ON SA2.A2_COD = SF1.F1_FORNECE
                    AND SA2.A2_LOJA = SF1.F1_LOJA
                    //AND SA2.A2_FILIAL = SF1.F1_FILIAL
                    AND SA2.%NOTDEL%
            INNER JOIN %TABLE:SC7% SC7 ON SC7.C7_NUM = SD1.D1_PEDIDO
                    AND SC7.C7_FILIAL = SD1.D1_FILIAL
                    AND SC7.C7_PRODUTO = SD1.D1_COD
                    AND SC7.C7_ITEM = SD1.D1_ITEMPC
                    AND SC7.C7_FORNECE = SD1.D1_FORNECE
                    AND SC7.C7_LOJA = SD1.D1_LOJA
                    AND SC7.%NOTDEL%
        WHERE
            SD1.D1_FILIAL      = %XFILIAL:SD1%
            AND SD1.D1_DOC     = %EXP:aGets[1][2]%
            AND SD1.D1_SERIE   = %EXP:aGets[2][2]%
            AND SD1.D1_FORNECE = %EXP:aGets[3][2]%
            AND SD1.D1_LOJA    = %EXP:aGets[4][2]%
            AND SD1.%NOTDEL%
    ENDSQL

    // Posiciona na tempor�ria e move para o topo
    DBSelectArea(cAlias)
    DBGoTop()

    // Atualiza os campos do cabe�alho intermedi�rio
    aDados[1]:cTitle := AllTrim(F1_DOC) + IIf(!Empty(F1_SERIE), "/" + AllTrim(F1_SERIE), "")
    aDados[2]:cTitle := DToC(SToD(F1_EMISSAO))
    aDados[3]:cTitle := AllTrim(A2_NOME)

    // Percorre os registro retornados
    While (!EOF())
        // Inicializa o vetor auxiliar
        aLine := {}

        // Monta a estrutura da linha
        AAdd(aLine, AllTrim(D1_ITEM))     // [01] Item
        AAdd(aLine, AllTrim(D1_COD))      // [02] Produto
        AAdd(aLine, AllTrim(B1_DESC))     // [03] Descri��o
        AAdd(aLine, AllTrim(D1_UM))       // [04] Unidade
        AAdd(aLine, D1_QUANT)             // [05] Quantidade
        AAdd(aLine, D1_VUNIT)             // [06] Vlr. Unit�rio
        AAdd(aLine, TMP_SLVINC)           // [07] Saldo
        AAdd(aLine, AllTrim(D1_PEDIDO))   // [08] Pedido
        AAdd(aLine, AllTrim(D1_ITEMPC))   // [09] Item Pedido
        AAdd(aLine, TMP_DIFPRC)           // [10] Diferen�a de pre�o
        AAdd(aLine, "")                   // [11] NCM (n�o utilizado)
        AAdd(aLine, .T.)                  // [12] Legenda

        // Adiciona a linha ao vetor do grid
        AAdd(aL1, AClone(aLine))

        // Remove o vetor da mem�ria
        FwFreeArray(aLine)

        // Inicializa o vetor auxiliar
        aLine := {}

        // Monta a estrutura da linha
        AAdd(aLine, AllTrim(C7_NUM))     //01 - Pedido
        AAdd(aLine, "")                  //02 - Item do XML (Desativado)
        AAdd(aLine, AllTrim(C7_ITEM))    //03 - Item ERP 
        AAdd(aLine, AllTrim(C7_PRODUTO)) //04 - Produto      
        AAdd(aLine, C7_UM)               //05 - Unidade
        AAdd(aLine, C7_QUANT)            //06 - Quantidade 
        AAdd(aLine, C7_PRECO)            //07 - Pre�o Unit�rio
        AAdd(aLine, SALDO)               //08 - Saldo a Antregar
        AAdd(aLine, TMP_SLDENTR)         //09 - Diferen�a
        AAdd(aLine, C7_PRODUTO)          //10 - C�digo do produto         
        AAdd(aLine, TMP_DIFPRC)          //11 - Diferen�a de pre�o         

        // Adiciona a linha ao vetor do grid
        AAdd(aL2, AClone(aLine))

        // Remove o vetor da mem�ria
        FwFreeArray(aLine)

        // Salta para o pr�ximo registro
        DBSkip()
    End

    // Atualiza a grid de itens do Documento
    KCOMF034A(.T.)

    // Realiza a carga dos itens dos pedidos na grid
    KCOMF034B(.T.)

    // Atualiza
    oT01:Refresh()

    // Fecha a �rea atual
    DBCloseArea()

    // Restaura a �rea anteriormente posicionada
    FwRestArea(aArea)

    // Limpa vetores da mem�ria
    FwFreeArray(aArea)

Return (Nil)

/*/{Protheus.doc} KCOMF034Y
    Persiste os dados nas tabelas customizadas
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 12/05/2022
/*/
Static Function KCOMF034Y(cMotivo)

    Local aArea     := FwGetArea()    // Salva �rea anteriormente posicionada
    Default cMotivo := "Conferido"
    
    // Verifica se n�o h� nenhuma inconsist�ncia antes de persistir os dados no banco
        // Inicia uma transa��o
        BEGIN TRANSACTION
            // Seleciona a �rea do cabe�alho das Documentos avaliadas
            DbSelectArea("ZBY")
            DbSetOrder(1)
            DbSeek(xFilial("ZBY")+aGets[1][2]+aGets[2][2]+aGets[3][2]+aGets[4][2])
            // Persiste os dados na tabela de cabe�alho das Documentos avaliadas
            RecLock("ZBY",.F.)
                ZBY->ZBY_USUA    := cUsername
                ZBY->ZBY_STATUS  := "C"
                ZBY->ZBY_MOTIVO  := cMotivo
            MsUnlock()

            // Fecha a �rea do cabe�alho das Documentos avaliadas
            ZBY->(DbCloseArea())
        
            // Seleciona a �rea dos itens avaliados do Documento
            DbSelectArea("ZBZ")
            DbSetOrder(1)
            DbSeek(xFilial("ZBZ")+aGets[1][2]+aGets[2][2]+aGets[3][2]+aGets[4][2])
                // Percorre os itens do Documento para persistir os dados no banco
                WHILE !EOF()
                    // Grava os itens do Documento
                    RecLock("ZBZ",.F.)
                        ZBZ->ZBZ_DTHORA := DToC(Date()) + " " + Time()
                        ZBZ->ZBZ_USUA   := cUsername
                    MsUnlock()
                    DBSKIP()
                END
            // Fecha a �rea da tabela
            ZBY->(DbCloseArea())
            ZBZ->(DbCloseArea())
        // Encerra a transa��o
        END TRANSACTION

    U_VALIDENT(aGets[1][2], aGets[2][2], aGets[3][2], aGets[4][2])

    // Restaura a �rea anteriormente posicionada
    FwRestArea(aArea)

Return (Nil)

/*/{Protheus.doc} KCOMF034W
    Valida��o da rotina para permitir que o usu�rio fa�a o processo ou n�o.
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 12/05/2022
    @return logical, l_Ret, Caso retorne falso reseta a rotina e apresenta os Helps
/*/
Static Function KCOMF034W()
    
    Local aArea  := FwGetArea()      // Salva a �rea posicionada
    Private cPed := ""                // N�mero do pedido de compra
    // Local cUser := __cUserId
    
    // If !(cUser $ SuperGetMV("MV_VALIDPN", .F., ""))
    //     Help(NIL, NIL, SM0->M0_NOMECOM, NIL, "Usu�rio sem permiss�o para utilizar esta rotina.",;
    //     1, 0, NIL, NIL, NIL, NIL, NIL, {"Utilize o par�metro MV_VALIDPN para obter a permiss�o."})
    //     l_Ret := .F.
    //     Return
    // EndIf

        // Verifica se o alias j� estava aberto, se estiver, fecha
        If Select("TMPDF1") > 0
            TMPDF1->(DbSelectArea("TMPDF1"))
            TMPDF1->(DbCloseArea())
        EndIf

        BEGINSQL ALIAS "TMPDF1"
            SELECT
                DISTINCT
                    F1_STATUS,
                    D1_PEDIDO,
                    F1_DOC,
                    F1_SERIE,
                    F1_FORNECE,
                    F1_LOJA
            FROM 
                %TABLE:SD1% SD1
            INNER JOIN 
                %TABLE:SF1% SF1
            ON
                SF1.F1_FILIAL = SD1.D1_FILIAL
                AND SF1.F1_DOC = SD1.D1_DOC
                AND SF1.F1_SERIE = SD1.D1_SERIE
                AND SF1.F1_FORNECE = SD1.D1_FORNECE
                AND SF1.F1_LOJA = SD1.D1_LOJA
                AND SF1.%NOTDEL%
            WHERE
                SD1.D1_FILIAL      = %XFILIAL:SD1%
                AND SD1.D1_DOC     = %EXP:aGets[1][2]%
                AND SD1.D1_SERIE   = %EXP:aGets[2][2]%
                AND SD1.D1_FORNECE = %EXP:aGets[3][2]%
                AND SD1.D1_LOJA    = %EXP:aGets[4][2]%
                AND SD1.%NOTDEL%
        ENDSQL

        cPed := TMPDF1->D1_PEDIDO

        TMPDF1->(DbCloseArea())

    FwRestArea(aArea)

Return (cPed)

/*/{Protheus.doc} fchkjust
	Tela de justificativa
	@type function
	@version 12.1.25
	@author Jonas Machado
	@since 21/07/2021
	@return variant, Nil
/*/
Static Function fchkjust()

    Local oGet1     := Nil
    Local oSay1     := Nil
    Local oPanel1   := Nil
    Local oSButton1 := Nil
    Local oSButton2 := Nil
    Local cGet1     := Space(100)
    Static oDlgJust := Nil

        DEFINE MSDIALOG oDlgJust TITLE "Observa��es." FROM 000, 000  TO 180, 680 COLORS 0, 16777215 PIXEL

            @ 003, 004 MSPANEL oPanel1 SIZE 327, 078 OF oDlgJust COLORS 0, 16777215 RAISED
            @ 016, 010 SAY oSay1 PROMPT "OBS:" SIZE 063, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
            @ 033, 012 MSGET oGet1 VAR cGet1 SIZE 311, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
            DEFINE SBUTTON oSButton1 FROM 057, 295 TYPE 01 OF oPanel1 ENABLE ACTION {|| KCOMF034Y(cGet1), oDlgJust:end() }
            DEFINE SBUTTON oSButton2 FROM 057, 264 TYPE 02 OF oPanel1 ENABLE ACTION {|| oDlgJust:end() }

        ACTIVATE MSDIALOG oDlgJust CENTERED

        Close(oT01)

    Return (Nil)
