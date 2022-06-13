//Bibliotecas necessárias
#Include "TOTVS.ch"
#Include "RWMAKE.ch"

#Define ENTER CHR(13)+CHR(10) // Pula linha

/*/{Protheus.doc} KCOMF034
    Monta interface gráfica da rotina
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 10/05/2022
/*/
User Function KCOMF034(cDoc,cSerie,cFornec,cLoja)

    Private aSize     := {}                                                                         // Array com dimensões para posicionamento de elementos
    Private aGets     := {}                                                                         // Array para capturar as informações da consulta padrão
    Private aL1       := {}                                                                         // Array com dados do Documento        
    Private aL2       := {}                                                                         // Array com dados dos pedidos amarrados na Documento                
    Private aDados    := Array(3)                                                                   // Array unidimensional com 3 posições para apresentação de informações do Documento na tela
    Private oFon1	  := TFont():New("Calibri", 07, 18, Nil, .F., Nil, Nil, Nil, .T., .F.)          // Fonte utilizada na construção de textos da tela
    Private oFon2	  := TFont():New("Calibri", 07, 18, Nil, .F., Nil, Nil, Nil, .T., .F.)          // Fonte utilizada para construção de textos da tela
    Private oBt01     := Nil                                                                        // Objeto para manipular o botão de reinicialização de variáveis
    Private oL1       := Nil                                                                        // Objeto para manipular métodos do browse dos itens do Documento
    Private oL2       := Nil                                                                        // Objeto para manipular métodos do browse dos pedidos
    Private oOn		  := LoadBitmap(GetResources(), "BR_VERDE")                                     // Tudo ok com a Documento e o pedido
    Private oSd1	  := LoadBitmap(GetResources(), "BR_AMARELO")                                   // Quantidade divergente entre documento e pedido
    Private oSd2	  := LoadBitmap(GetResources(), "BR_VERMELHO")                                  // Preço divergente entre documento e pedido
    Private oSd3	  := LoadBitmap(GetResources(), "BR_LARANJA")                                   // Ambos divergentes, preço e quantidade
    Private cFlag     := ""
    Private oT01      := Nil
    Private cPed      := ""

    // Salva o tamanho da tela
    aSize := MsAdvSize(.F.)
        
    //Inicializa o vetor com dados da consulta padrão
    Aadd(aGets, {Nil, cDoc, "Documento", .T.})
    Aadd(aGets, {Nil, cSerie, "Série", .T.})
    Aadd(aGets, {Nil, cFornec, "Fornecedor.", .T.})
    Aadd(aGets, {Nil, cLoja, "Loja", .T.})
    Aadd(aGets, {Nil, KCOMF034W(), "Pedido", .T.})

    //Define a tela 
    Define MsDialog oT01 Title " Conferência do Documento " From 000, 000 To 203, 394 Pixel

    //Maxmiza a tela
    oT01:lMaximized := .T.

    //Grupo 01 cabeçalho da interface gráfica
    @ 003, 003 To 038, (aSize[5]/2) Title " Cabeçalho do Documento "

    // Dados a serem carregados no cabeçalho da interface gráfica
    // Número do Documento
    TSay():Create(oT01, &("{|| '" + aGets[01][03] + "'}"), 012, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
    @ 020, 007 MsGet aGets[01][01] Var aGets[01][02] Picture "@!" Size 050, 010 Of oT01 Pixel When .F.
    // Série do Documento
    TSay():Create(oT01, &("{|| '" + aGets[02][03] + "'}"), 012, 70, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
    @ 020, 70 MsGet aGets[02][01] Var aGets[02][02] Picture "@!" Size 030, 010 Of oT01 Pixel When .F.
    // Fornecedor amarrado na Documento
    TSay():Create(oT01, &("{|| '" + aGets[03][03] + "'}"), 012, 120, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
    @ 020, 120 MsGet aGets[03][01] Var aGets[03][02] Picture "@!" Size 030, 010 Of oT01 Pixel When .F.
    // Loja do fornecedor amarrado na Documento
    TSay():Create(oT01, &("{|| '" + aGets[04][03] + "'}"), 012, 170, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
    @ 020, 170 MsGet  aGets[04][01] Var aGets[04][02] Picture "@!" Size 020, 010 Of oT01 Pixel When .F.

    //Grupo 02 Tela intermediária da interface gráfica
    @ 041, 003 To 075, (aSize[5]/2) Title " Dados do Documento "

    // Descrição dos dados a serem carregados na interface gráfica
    TSay():Create(oT01, &("{|| 'NF/Série:       '}"), 049, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(255, 0, 0), Nil, 290, 30)
    TSay():Create(oT01, &("{|| 'Emissão:        '}"), 049, 114, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(255, 0, 0), Nil, 290, 30)
    TSay():Create(oT01, &("{|| 'Nome Fornecedor:'}"), 062, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(255, 0, 0), Nil, 290, 30)

    // Preenche os dados na interface intermediária
    aDados[1] := TSay():Create(oT01, &("{|| ''}"), 049, 040, Nil, oFon2, Nil, Nil, Nil, .T., Rgb(0, 0, 205), Nil, 290, 30)
    aDados[2] := TSay():Create(oT01, &("{|| ''}"), 049, 145, Nil, oFon2, Nil, Nil, Nil, .T., Rgb(0, 0, 205), Nil, 290, 30)
    aDados[3] := TSay():Create(oT01, &("{|| ''}"), 062, 065, Nil, oFon2, Nil, Nil, Nil, .T., Rgb(0, 0, 205), Nil, 290, 30)

    // Grupo 03 responsável pela interface gráfica que engloba os itens do Documento e os itens dos pedidos amarrados na Documento
    // @ 009, (aSize[5]/2) - 19 To 24, ((aSize[5]/2) - 03) Title ""

    // Interface gráfica para montar a tela de itens do Documento 
    @ 078, 003 To ((aSize[6]/2) - 15) , ((aSize[5]/2) * 0.5) Title " Itens do Documento "

    // Legendas relacionadas com os itens do Documento
    TBtnBmp2():New((aSize[6] - 20), 010, 22, 22, 'BR_VERDE', Nil, Nil, Nil, {|| }, oT01, "", Nil, .T.)
    TSay():Create(oT01, &("{|| 'Confere com o Pedido'}"), ((aSize[6]/2) - 09), 20, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(54, 62, 62), Nil, 290, 30)

    TBtnBmp2():New((aSize[6] - 20), 210, 22, 22, 'BR_VERMELHO', Nil, Nil, Nil, {|| }, oT01, "", Nil, .T.)
    TSay():Create(oT01, &("{|| 'Preço Divergente'}"), ((aSize[6]/2) - 09), 120, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(54, 62, 62), Nil, 290, 30)

    TBtnBmp2():New((aSize[6] - 20), 410, 22, 22, 'BR_AMARELO', Nil, Nil, Nil, {|| }, oT01, "", Nil, .T.)
    TSay():Create(oT01, &("{|| 'Quantidade Divergente'}"), ((aSize[6]/2) - 09), 220, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(54, 62, 62), Nil, 290, 30)

    TBtnBmp2():New((aSize[6] - 20), 610, 22, 22, 'BR_LARANJA', Nil, Nil, Nil, {|| }, oT01, "", Nil, .T.)
    TSay():Create(oT01, &("{|| 'Ambos Divergentes'}"), ((aSize[6]/2) - 09), 320, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(54, 62, 62), Nil, 290, 30)

    oBt01 := TBtnBmp2():New(38, 410, 23, 23, 'RPMNEW', Nil, Nil, Nil, {|| U_ETIQK009(aGets[1][2],aGets[2][2],aGets[3][2],aGets[4][2],aGets[5][2]) }, oT01, "ETIQUETAS", Nil, .T.)

    // Interface gráfica para montar a tela de itens dos pedidos
    @ 078, (((aSize[5]/2) * 0.5) + 020) To ((aSize[6]/2) - 15) , (aSize[5]/2) Title " Itens do Pedido "

    // Monta a Grid dos itens do Documento
    KCOMF034A()
    // Monta a Grid dos itens dos pedidos
    KCOMF034B()

    KCOMF034Z()

    // Botões no canto inferior direito da tela responsáveis por Confirmar a execução da rotina ou cancelar
    @ ((aSize[6]/2) - 11), ((aSize[5]/2) - 78) Button "Confirmar" Size 037, 012 Pixel Of oT01 Action Processa({|| fchkjust() }, "Confirmando conferência...")
    @ ((aSize[6]/2) - 11), ((aSize[5]/2) - 37) Button "Sair"  Size 037, 012 Pixel Of oT01 Action Close(oT01)

    // Ativa a interface gráfica e apresenta ao usuário
    Activate MsDialog oT01 Centered

Return (Nil)

/*/{Protheus.doc} KCOMF034A
    Função que avalia e realiza a persistência dos dados na grid dos itens do Documento
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 11/05/2022
    @param lRefresh, logical, Recebe verdadeiro para reincializar os dados persistidos na Grid
/*/
Static Function KCOMF034A(lRefresh)

    Local   aCabec    := {" ", " Item", " Produto"," Descrição", " Unid", " Quantidade", " Vlr. Unit.", " Quant. Dif.", " Pedido", " It.Pc"} // Cabeçalho da Grid
    Local   aColCab   := {}                                                                                                                  // Array com dados das posições das colunas da grid
    Local   nAlt      := ((aSize[6]/2) - 106)                                                                                                // Array contentado os dados de altura da grid
    Local   nLarg     := (((aSize[5]/2) * 0.5) - 11)                                                                                         // Array contentado os dados da lagura da Grid

    // Seta valor padrão
    Default lRefresh := .F.                                                                                                                  // Variável padrão inicializada para controle da atualização da Grid

    // Adiciona a posição das colunas
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
                    
    //Verifica se o vetor está ainda não foi preenchido com os dados
    If (Empty(aL1))
        
        //Adidiona os dados ao array
        Aadd(aL1, { "",;  //01 - Item
                    "",;  //02 - Produto
                    "",;  //03 - Descrição
                    "",;  //04 - Unidade
                    0 ,;  //05 - Quantidade
                    0 ,;  //06 - Vlr. Unitário
                    0 ,;  //07 - Saldo a Vincular
                    "",;  //08 - Pedido
                    "",;  //09 - Item Pedido
                    0 ,;  //10 - Prod Vinculado
                    "",;  //11 - NCM
                    .T.;  //12 - Legenda
                    })
    EndIf

    // Verifica se é atualização
    If (!lRefresh)

        //Monta a listbox
        oL1 := TCBrowse():New(087                     ,; //01 - Linha 
                            007                       ,; //02 - Coluna
                            nLarg                     ,; //03 - Largura
                            nAlt                      ,; //04 - Altura
                            Nil                       ,; //05 - Indica o bloco de código da lista de campos. Observação: Esse parâmetro é utilizado somente quando o browse trabalha com array.
                            aCabec                    ,; //06 - Cabeçalho
                            aColCab                   ,; //07 - Tamanho das colunas 
                            oT01                      ,; //08 - Objeto principal
                            Nil                       ,; //09 - Indica os campos necessários para o filtro.
                            Nil                       ,; //10 - Indica o início do intervalo para o filtro.
                            Nil                       ,; //11 - Indica o fim do intervalo para o filtro.
                            Nil                       ,; //12 - Indica o bloco de código que será executado ao mudar de linha.
                            {|| }                     ,; //13 - Indica o bloco de código que será executado quando clicar duas vezes, com o botão esquerdo do mouse, sobre o objeto.
                            Nil                       ,; //14 - Indica o bloco de código que será executado quando clicar, com o botão direito do mouse, sobre o objeto.
                            oFon2                     ,; //15 - Indica o objeto do tipo TFont utilizado para definir as características da fonte aplicada na exibição do conteúdo do controle visual.
                            Nil                       ,; //16 - Indica o tipo de ponteiro do mouse.
                            Nil                       ,; //17 - Indica a cor do texto da janela.
                            Nil                       ,; //18 - Indica a cor de fundo da janela.
                            ""                        ,; //19 - Indica a mensagem ao posicionar o ponteiro do mouse sobre o objeto.
                            .F.                       ,; //20 - Compatibilidade.
                            Nil                       ,; //21 - Indica se o objeto é utilizado com array (opcional) ou tabela (obrigatório).
                            .T.                       ,; //22 - Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
                            {||}                      ,; //23 - Indica o bloco de código que será executado quando a mudança de foco da entrada de dados, na janela em que o controle foi criado, estiver sendo efetuada. Observação: O bloco de código retornará verdadeiro (.T.) se o controle permanecer habilitado; caso contrário, retornará falso (.F.).
                            .F.                       ,; //24 - Compatibilidade
                            {||}                      ,; //25 - Indica o bloco de código de validação que será executado quando o conteúdo do objeto for modificado. Retorna verdadeiro (.T.), se o conteúdo é válido; caso contrário, falso (.F.).
                            .T.                       ,; //26 - Indica se habilita(.T.)/desabilita(.F.) a barra de rolagem horizontal.
                            .T.                        ; //27 - Indica se habilita(.T.)/desabilita(.F.) a barra de rolagem vertical.
                            ) 

    EndIf

    // Adiciona os dados que serão persistidos na GRid de itens do Documento
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
    Função que avalia e realiza a persistência dos dados na grid dos itens dos pedidos
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 11/05/2022
    @param lRefresh, logical, Recebe verdadeiro para reincializar os dados persistidos na Grid
/*/
Static Function KCOMF034B(lRefresh)

    Local   aCabec    := {" ", " Pedido", " Item"," Produto", " Unid", " Qtde.", " Prc Un.", " Sd. a Entr.", " Preço Dif."}      // Cabeçalho da GRid de itens dos pedidos
    Local   aColCab   := {}                                                                                                     // Posicionamento das colunas da grid
    Local   nAlt      := ((aSize[6]/2) - 106)                                                                                   // Altura da grid
    Local   nLarg     := (((aSize[5]/2) * 0.5) - 28)                                                                            // Largura da grid

    //Seta valor padrão
    Default lRefresh := .F.

    //Adiciona a posição das colunas
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
                0  ,; //07 - Preço Unitário
                0  ,; //08 - Saldo a Antregar
                0  ,; //09 - Diferença
                ""  ; //10 - Código do produto
                })
    EndIf

    //Verifica se é atualização
    If (!lRefresh)

        //Monta a listbox
        oL2 := TCBrowse():New(087                       ,; //01 - Linha 
                        (((aSize[5]/2) * 0.5) + 024) ,; //02 - Coluna
                            nLarg                     ,; //03 - Largura
                            nAlt                      ,; //04 - Altura
                            Nil                       ,; //05 - Indica o bloco de código da lista de campos. Observação: Esse parâmetro é utilizado somente quando o browse trabalha com array.
                            aCabec                    ,; //06 - Cabeçalho
                            aColCab                   ,; //07 - Tamanho das colunas 
                            oT01                      ,; //08 - Objeto principal
                            Nil                       ,; //09 - Indica os campos necessários para o filtro.
                            Nil                       ,; //10 - Indica o início do intervalo para o filtro.
                            Nil                       ,; //11 - Indica o fim do intervalo para o filtro.
                            Nil                       ,; //12 - Indica o bloco de código que será executado ao mudar de linha.
                            {||}                      ,; //13 - Indica o bloco de código que será executado quando clicar duas vezes, com o botão esquerdo do mouse, sobre o objeto.
                            Nil                       ,; //14 - Indica o bloco de código que será executado quando clicar, com o botão direito do mouse, sobre o objeto.
                            oFon2                     ,; //15 - Indica o objeto do tipo TFont utilizado para definir as características da fonte aplicada na exibição do conteúdo do controle visual.
                            Nil                       ,; //16 - Indica o tipo de ponteiro do mouse.
                            Nil                       ,; //17 - Indica a cor do texto da janela.
                            Nil                       ,; //18 - Indica a cor de fundo da janela.
                            ""                        ,; //19 - Indica a mensagem ao posicionar o ponteiro do mouse sobre o objeto.
                            .F.                       ,; //20 - Compatibilidade.
                            Nil                       ,; //21 - Indica se o objeto é utilizado com array (opcional) ou tabela (obrigatório).
                            .T.                       ,; //22 - Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
                            {||}                      ,; //23 - Indica o bloco de código que será executado quando a mudança de foco da entrada de dados, na janela em que o controle foi criado, estiver sendo efetuada. Observação: O bloco de código retornará verdadeiro (.T.) se o controle permanecer habilitado; caso contrário, retornará falso (.F.).
                            .F.                       ,; //24 - Compatibilidade
                            {||}                      ,; //25 - Indica o bloco de código de validação que será executado quando o conteúdo do objeto for modificado. Retorna verdadeiro (.T.), se o conteúdo é válido; caso contrário, falso (.F.).
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
    Função executada na validação de preenchimento do campo "Documento" no cabeçalho da rotina
    para preenchimento da grid com os itens do pedido e do cabeçalho com os dados na NF.
    @type Function
    @version 12.1.33
    @author Jonas Machado
    @since 10/05/2022
    @return Variant, Retorno nulo
/*/
Static Function KCOMF034Z()

    // Variáveis locais
    Local aArea      // Área anteriormente posicionada
    Local aLine      // Auxiliar de montagem das linhas do grid
    Local cAlias     // Alias do arquivo temporário
    
    // Inicialização de variáveis
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

    // Posiciona na temporária e move para o topo
    DBSelectArea(cAlias)
    DBGoTop()

    // Atualiza os campos do cabeçalho intermediário
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
        AAdd(aLine, AllTrim(B1_DESC))     // [03] Descrição
        AAdd(aLine, AllTrim(D1_UM))       // [04] Unidade
        AAdd(aLine, D1_QUANT)             // [05] Quantidade
        AAdd(aLine, D1_VUNIT)             // [06] Vlr. Unitário
        AAdd(aLine, TMP_SLVINC)           // [07] Saldo
        AAdd(aLine, AllTrim(D1_PEDIDO))   // [08] Pedido
        AAdd(aLine, AllTrim(D1_ITEMPC))   // [09] Item Pedido
        AAdd(aLine, TMP_DIFPRC)           // [10] Diferença de preço
        AAdd(aLine, "")                   // [11] NCM (não utilizado)
        AAdd(aLine, .T.)                  // [12] Legenda

        // Adiciona a linha ao vetor do grid
        AAdd(aL1, AClone(aLine))

        // Remove o vetor da memória
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
        AAdd(aLine, C7_PRECO)            //07 - Preço Unitário
        AAdd(aLine, SALDO)               //08 - Saldo a Antregar
        AAdd(aLine, TMP_SLDENTR)         //09 - Diferença
        AAdd(aLine, C7_PRODUTO)          //10 - Código do produto         
        AAdd(aLine, TMP_DIFPRC)          //11 - Diferença de preço         

        // Adiciona a linha ao vetor do grid
        AAdd(aL2, AClone(aLine))

        // Remove o vetor da memória
        FwFreeArray(aLine)

        // Salta para o próximo registro
        DBSkip()
    End

    // Atualiza a grid de itens do Documento
    KCOMF034A(.T.)

    // Realiza a carga dos itens dos pedidos na grid
    KCOMF034B(.T.)

    // Atualiza
    oT01:Refresh()

    // Fecha a área atual
    DBCloseArea()

    // Restaura a área anteriormente posicionada
    FwRestArea(aArea)

    // Limpa vetores da memória
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

    Local aArea     := FwGetArea()    // Salva área anteriormente posicionada
    Default cMotivo := "Conferido"
    
    // Verifica se não há nenhuma inconsistência antes de persistir os dados no banco
        // Inicia uma transação
        BEGIN TRANSACTION
            // Seleciona a área do cabeçalho das Documentos avaliadas
            DbSelectArea("ZBY")
            DbSetOrder(1)
            DbSeek(xFilial("ZBY")+aGets[1][2]+aGets[2][2]+aGets[3][2]+aGets[4][2])
            // Persiste os dados na tabela de cabeçalho das Documentos avaliadas
            RecLock("ZBY",.F.)
                ZBY->ZBY_USUA    := cUsername
                ZBY->ZBY_STATUS  := "C"
                ZBY->ZBY_MOTIVO  := cMotivo
            MsUnlock()

            // Fecha a área do cabeçalho das Documentos avaliadas
            ZBY->(DbCloseArea())
        
            // Seleciona a área dos itens avaliados do Documento
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
            // Fecha a área da tabela
            ZBY->(DbCloseArea())
            ZBZ->(DbCloseArea())
        // Encerra a transação
        END TRANSACTION

    U_VALIDENT(aGets[1][2], aGets[2][2], aGets[3][2], aGets[4][2])

    // Restaura a área anteriormente posicionada
    FwRestArea(aArea)

Return (Nil)

/*/{Protheus.doc} KCOMF034W
    Validação da rotina para permitir que o usuário faça o processo ou não.
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 12/05/2022
    @return logical, l_Ret, Caso retorne falso reseta a rotina e apresenta os Helps
/*/
Static Function KCOMF034W()
    
    Local aArea  := FwGetArea()      // Salva a área posicionada
    Private cPed := ""                // Número do pedido de compra
    // Local cUser := __cUserId
    
    // If !(cUser $ SuperGetMV("MV_VALIDPN", .F., ""))
    //     Help(NIL, NIL, SM0->M0_NOMECOM, NIL, "Usuário sem permissão para utilizar esta rotina.",;
    //     1, 0, NIL, NIL, NIL, NIL, NIL, {"Utilize o parâmetro MV_VALIDPN para obter a permissão."})
    //     l_Ret := .F.
    //     Return
    // EndIf

        // Verifica se o alias já estava aberto, se estiver, fecha
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

        DEFINE MSDIALOG oDlgJust TITLE "Observações." FROM 000, 000  TO 180, 680 COLORS 0, 16777215 PIXEL

            @ 003, 004 MSPANEL oPanel1 SIZE 327, 078 OF oDlgJust COLORS 0, 16777215 RAISED
            @ 016, 010 SAY oSay1 PROMPT "OBS:" SIZE 063, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
            @ 033, 012 MSGET oGet1 VAR cGet1 SIZE 311, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
            DEFINE SBUTTON oSButton1 FROM 057, 295 TYPE 01 OF oPanel1 ENABLE ACTION {|| KCOMF034Y(cGet1), oDlgJust:end() }
            DEFINE SBUTTON oSButton2 FROM 057, 264 TYPE 02 OF oPanel1 ENABLE ACTION {|| oDlgJust:end() }

        ACTIVATE MSDIALOG oDlgJust CENTERED

        Close(oT01)

    Return (Nil)
