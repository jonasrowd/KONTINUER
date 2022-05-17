// Bibliotecas necessárias
#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

/*/{Protheus.doc} KCOMF037
	Rotina customizada para visualizar as pré-notas que vão sendo avaliadas antes de serem classificadas, 
	para que possam verificar o tipo de classificação ou se será devolução sem maiores dificuldades.
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
/*/
User Function KCOMF037()

	Private l_Browse	:= .T.
	Private oBrowse

    //Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

    //Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZBY")

    //Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription("Pré-Notas a Classificar")

	// Definição da legenda
	oBrowse:AddLegend( "ZBY_STATUS=='I' .AND. ZBY_SITUAC == 'A'", "GREEN"   , "Aprov. Sem Restrição" )
	oBrowse:AddLegend( "ZBY_STATUS=='P' .AND. ZBY_SITUAC == 'A'", "RED"     , "Aprov. Prc Divergente" )
	oBrowse:AddLegend( "ZBY_STATUS=='Q' .AND. ZBY_SITUAC == 'A'", "YELLOW" 	, "Aprov. Qtde Divergente" )
	oBrowse:AddLegend( "ZBY_STATUS=='A' .AND. ZBY_SITUAC == 'A'", "BLUE" 	, "Aprov. Prc/Qtde Divergentes" )
	oBrowse:AddLegend( "ZBY_STATUS=='P' .AND. ZBY_SITUAC == 'R'", "LIGHTBLU", "Rejei. Prc Divergente" )
	oBrowse:AddLegend( "ZBY_STATUS=='Q' .AND. ZBY_SITUAC == 'R'", "PINK" 	, "Rejei. Qtde Divergente" )
	oBrowse:AddLegend( "ZBY_STATUS=='A' .AND. ZBY_SITUAC == 'R'", "BLACK" 	, "Rejei. Prc/Qtde Divergentes" )

	oBrowse:Activate()

Return (Nil)

/*/{Protheus.doc} MenuDef
	Definição do menu da rotina
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@return Array, aRotina, Array contendo as funções do menu da rotina
/*/
Static Function MenuDef()

	Local aRotina := {}

    //Adicionando opções
    If (IIF(Type("l_Browse") == "L", l_Browse, .F.)) == .T.
	    ADD OPTION aRotina TITLE 'Visualizar'  			ACTION 'VIEWDEF.KCOMF037' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	    // ADD OPTION aRotina TITLE 'Incluir'    			ACTION 'VIEWDEF.KCOMF037' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	    // ADD OPTION aRotina TITLE 'Alterar'    			ACTION 'VIEWDEF.KCOMF037' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	    // ADD OPTION aRotina TITLE 'Excluir'    			ACTION 'VIEWDEF.KCOMF037' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
		ADD OPTION aRotina TITLE 'Classificar'     		ACTION 'CustomClas' OPERATION 7 ACCESS 0
		ADD OPTION aRotina TITLE 'Documento de Entrada' ACTION 'U_ExecPadrao("MATA103")' OPERATION 8 ACCESS 0
		ADD OPTION aRotina TITLE 'Legenda'     			ACTION 'U_fLegZBY' OPERATION 11 ACCESS 0
	EndIf

Return (aRotina)

/*/{Protheus.doc} ModelDef
	Definição do modelo de dados da rotina
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@return object, oModel,	Retorna o objeto contendo o modelo de dados da rotina
/*/
Static Function ModelDef()

	Local oModel
	Local oStr1:= FWFormStruct(1,'ZBY')
	Local oStr2:=  FWFormStruct(1,'ZBZ')

	oModel := MPFormModel():New('ModelName',,{|oModel| ZBYTUDOOK(oModel)},)
	oModel:SetDescription('MODEL1')
	oModel:addFields('FIELDZBY',,oStr1,{|oFieldZBY, cAcao, cCampo, cValor| fVldZBY(oFieldZBY, cAcao, cCampo, cValor)})
	oModel:addGrid('GRIDZBZ','FIELDZBY',oStr2,{|oGridZBZ, nLinha, cAcao, cCampo, cValor| fVldZBZ(oGridZBZ, nLinha, cAcao, cCampo, cValor)},;
		{|oGridZBZ, nLinha| ZBZLOK(oGridZBZ, nLinha)})
	oModel:SetRelation('GRIDZBZ', { { 'ZBY_FILIAL', 'ZBZ_FILIAL' }, { 'ZBY_DOC', 'ZBZ_DOC' },;
		{ 'ZBY_SERIE', 'ZBZ_SERIE' }, { 'ZBY_FORNEC', 'ZBZ_FORNEC' },{ 'ZBY_LOJA', 'ZBZ_LOJA' } }, ZBZ->(IndexKey(1)) )
	oModel:GetModel('GRIDZBZ'):SetUniqueLine( { 'ZBZ_FILIAL', 'ZBZ_DOC', 'ZBZ_SERIE', 'ZBZ_FORNEC', 'ZBZ_LOJA' } )
	oModel:SetPrimaryKey({'ZBY_FILIAL', 'ZBY_DOC', 'ZBY_SERIE', 'ZBY_FORNEC', 'ZBY_LOJA' })
	oModel:getModel('FIELDZBY'):SetDescription('FIELDZBY')
	oModel:getModel('GRIDZBZ'):SetDescription('GRIDZBZ')

Return (oModel)

/*/{Protheus.doc} ViewDef
	Definição da visão de dados da rotina
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@return object, oView, Retorna o objeto com a estrutura da rotina
/*/
Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStr1:= FWFormStruct(2, 'ZBY')
	Local oStr2:= FWFormStruct(2, 'ZBZ')

	oView := FWFormView():New()

	oView:SetModel(oModel)
	// oView:SetViewCanActivate({|oView| fVldAcao(oView)})

	oView:AddField('FORM1' , oStr1,'FIELDZBY' )
	oView:AddGrid('FORM3' , oStr2,'GRIDZBZ')

	oView:CreateHorizontalBox( 'BOXFORM1', 15)
	oView:CreateHorizontalBox( 'BOXFORM3', 85)
	oView:SetOwnerView('FORM3','BOXFORM3')
	oView:SetOwnerView('FORM1','BOXFORM1')
	oView:SetViewProperty('FORM1' , 'SETLAYOUT' , {FF_LAYOUT_HORZ_DESCR_TOP,10} )

	oView:AddUserButton('Localizar','',{|| fLocate()})

Return (oView)

/*/{Protheus.doc} fVldAcao
	Valida a ação do usuário na interação com alteração ou exclusão
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@return Logical, lRet, Se retornar .T. permite a operação
/*/
// Static Function fVldAcao(oView)

	//     Local nOperacao  := oView:GetOperation()
	//     Local lRet       := .T.

	// 	If (nOperacao == 4 .Or. nOperacao == 5)
	// 		ShowHelpDlg("Classificação de Pré-Nota", {"Opção não disponível para o registro selecionado"},5,;
	// 					{"Opção disponível somente na rotina padrão."},5)
	//         lRet := .F.
	// 	Endif

// Return (lRet)

/*/{Protheus.doc} fVldZBZ
	Função para validação de compos dos itens
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@param o_GridZBZ, object, Objeto com a grid de dados da rotina
	@param n_Linha, numeric, Número da linha posicionada
	@param c_Acao, character, Ação realizada
	@param c_Campo, character, Nome do campo acionado
	@param c_Valor, character, Valor alterado
	@return Logica, lRet, Retorna verdadeiro para permitir
/*/
Static Function fVldZBZ(o_GridZBZ, n_Linha, c_Acao, c_Campo, c_Valor)

    // Local o_Model    := FWModelActive()
    // Local o_FieldZBY := o_Model:GetModel('FIELDZBY')
    Local a_Area     := GetArea()
	Local l_Ret 	 := .T.
	/*
	IF c_Acao == "SETVALUE" .And. c_Campo $ "ZBY_STATUS" .And. !Empty(c_Valor)

	ENDIF
	*/
	RestArea(a_Area)
Return (l_Ret)

/*/{Protheus.doc} fVldZBY
	Rotina para validar campos do cabeçalho
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@param o_FieldZBY, object, Objeto contendo a estrutura da grid
	@param c_Acao, character, Ação realizada
	@param c_Campo, character, Campo acionado
	@param c_Valor, character, Valor alterado
	@return Logica, lRet, Retorna verdadeiro para permitir
/*/
Static Function fVldZBY(o_FieldZBY, c_Acao, c_Campo, c_Valor)
    // Local o_Model    := FWModelActive()
    // Local o_GridZBZ  := o_Model:GetModel('GRIDZBZ')
    Local a_Area     := GetArea()
    // Local n_Linha    := 1
	Local l_Ret 	 := .T.
	/*
	IF c_Acao == "SETVALUE" .And. c_Campo $ "ZBY_DOC"
		For n_Linha:=1 To o_GridZBZ:Length()
			If o_GridZBZ:IsDeleted(n_Linha) == .F. .And. !Empty(o_GridZBZ:GetValue("ZBZ_DOC", n_Linha))
					l_Ret := .F.
					Exit
			Endif
		Next
	ENDIF
	*/
	RestArea(a_Area)
Return (l_Ret)

/*/{Protheus.doc} ZBYTUDOOK
	Ponto para validar o TudoOk da rotina
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@param o_Model, object, Objeto contendo o modelo de dados
	@return lRet, Logical, Se verdadeiro, permite a gravação do TudoOk
/*/
Static Function ZBYTUDOOK(o_Model)

	// Local o_FieldZBY := o_Model:GetModel('FIELDZBY')
    // Local o_GridZBZ  := o_Model:GetModel('GRIDZBZ')
    Local a_Area     := GetArea()
    // Local n_Linha    := 1
	Local l_Ret 	 := .T.
	/*
	IF INCLUI .Or. ALTERA
		For n_Linha:=1 To o_GridZBZ:Length()
			If o_GridZBZ:IsDeleted(n_Linha) == .F. .And. !Empty(o_GridZBZ:GetValue("ZBZ_DOC", n_Linha))
			Endif
		Next
    ENDIF
	*/
	RestArea(a_Area)

Return (l_Ret)

/*/{Protheus.doc} ZBZLOK
	Ponto para verificar o tudo ok da linha
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@param o_GridZBZ, object, Objeto com a grid da rotina
	@param n_Linha, numeric, Linha posicionada
	@return lRet, Logical, REtonar verdadeiro para permitir prosseguir
/*/
Static Function ZBZLOK(o_GridZBZ, n_Linha)

    Local a_Area    := GetArea()
    Local l_Ret     := .T.
	/*
    IF INCLUI .Or. ALTERA

    ENDIF
	*/
    RestArea(a_Area)

Return (l_Ret)

/*/{Protheus.doc} CustomClas
	Abre a função para classificar a pré-nota
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
/*/
Static Function CustomClas()

	Local aArea := GetArea()

	// Verifica se o alias já estava aberto, se estiver, fecha
	If Select("TmpRec") > 0
		TmpRec->(DbSelectArea("TmpRec"))
		TmpRec->(DbCloseArea())
	EndIf

	BEGINSQL ALIAS "TmpRec"
		SELECT
			R_E_C_N_O_ Recno
		FROM
			%TABLE:SF1%
		WHERE
			F1_FILIAL = %EXP:XFILIAL("SF1")%
			AND F1_DOC = %EXP:ZBY->ZBY_DOC%
			AND F1_SERIE = %EXP:ZBY->ZBY_SERIE%
			AND F1_FORNECE = %EXP:ZBY->ZBY_FORNEC%
			AND F1_LOJA = %EXP:ZBY->ZBY_LOJA%
			AND %NOTDEL%
			AND F1_STATUS = ' '
	ENDSQL

	If Msgyesno("Deseja Efetuar a Classificação da Nota " + ZBY->ZBY_DOC+' / '+Alltrim(ZBY->ZBY_SERIE) + " Agora ?")

		aRotina := {;
			{ "Pesquisar",   "AxPesqui",    0, 1}, ;
			{ "Visualizar",  "A103NFiscal", 0, 2}, ;
			{ "Incluir",     "A103NFiscal", 0, 3}, ;
			{ "Classificar", "A103NFiscal", 0, 4}, ;
			{ "Retornar",    "A103Devol",   0, 3}, ;
			{ "Excluir",     "A103NFiscal", 3, 5}, ;
			{ "Imprimir",    "A103Impri",   0, 4}, ;
			{ "Legenda",     "A103Legenda", 0, 2} }

		DbSelectArea("SF1")
		DbGoto(TmpRec->Recno)
		A103NFiscal("SF1",SF1->(Recno()),4,.f.,.f.)

		TmpRec->(DbCloseArea())

	EndIf

	RetArea(aArea)

Return (Nil)

/*/{Protheus.doc} fLocate
	Localiza pelo índice
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
/*/
Static Function fLocate

	Local oDlgPesq
	Local oCampo, oExpr
	Local aCpos		:= {}
	Local aCampo	:= {}
	Local cTitulo	:= "Localizar"
	Local cCampo	:= ""
	Local cExpr		:= ""
	Local nOpc		:= 2
	Local o_View    := FWViewActive()
	Local o_GridZBZ := o_View:GetModel('GRIDZBZ')
	Local a_Seek    := {}

	DBSELECTAREA("SX3")
	SX3->(DBSEEK("ZBZ"))
	WHILE SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "ZBZ"
		IF X3USO(SX3->X3_USADO) == .F.
			SX3->(DBSKIP())
			LOOP
		ENDIF

		AADD( aCpos , SX3->X3_TITULO )
		AADD( aCampo,{SX3->X3_CAMPO, SX3->X3_TITULO, .T., "01", SX3->X3_TAMANHO, IF(Empty(SX3->X3_PICTURE), Space(45), SX3->X3_PICTURE), SX3->X3_TIPO, SX3->X3_DECIMAL})

		SX3->(DBSKIP())
	END

	DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(cTitulo) FROM 000,000 TO 100,405 PIXEL

	@ 05,005 SAY OemToAnsi("Campo:") SIZE 20,8 PIXEL OF oDlgPesq
	@ 05,060 SAY OemToAnsi("Expressão:") SIZE 30,8 PIXEL OF oDlgPesq

	cCampo := aCpos[1]
	@ 15,05 COMBOBOX oCampo VAR cCampo ITEMS aCpos SIZE 50,50 OF oDlgPesq PIXEL ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq)
	cExpr := CalcField(oCampo:nAt,aCampo)

	@ 15,60 MSGET oExpr VAR cExpr SIZE 140,10 PIXEL OF oDlgPesq PICTURE AllTrim(aCampo[oCampo:nAt,6]) FONT oDlgPesq:oFont

	DEFINE SBUTTON o1 FROM 35,145  TYPE 01  ACTION (nOpc:=1, a_Seek := {aCampo[oCampo:nAt, 1], cExpr}, oDlgPesq:End()) OF oDlgPesq When .T.
	DEFINE SBUTTON o2 FROM 35,175  TYPE 02  ACTION (nOpc:=2, oDlgPesq:End()) OF oDlgPesq When .T.

	o1:cToolTip := "Localizar"

	ACTIVATE MSDIALOG oDlgPesq CENTERED

	IF nOpc == 1
		o_GridZBZ:SeekLine({a_Seek})
		o_View:Refresh()
	ENDIF

Return (Nil)

/*/{Protheus.doc} fLegZBY
	Exibe um prompt com as legendas da rotina
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
/*/
User Function fLegZBY

	Local aLegenda := {}

	aAdd(aLegenda,{"BR_VERDE"   , "Aprov. Sem Restrição" })
	aAdd(aLegenda,{"BR_VERMELHO"     , "Aprov. Prc Divergente" })
	aAdd(aLegenda,{"BR_AMARELO"  , "Aprov. Qtde Divergente" })
	aAdd(aLegenda,{"BR_AZUL"  , "Aprov. Prc/Qtde Divergentes" })
	aAdd(aLegenda,{"BR_AZUL_CLARO", "Rejei. Prc Divergente" })
	aAdd(aLegenda,{"BR_PINK" 	 , "Rejei. Qtde Divergente" })
	aAdd(aLegenda,{"BR_PRETO" 	 , "Rejei. Prc/Qtde Divergentes" })

	BrwLegenda("Pré-Notas a Classificar", "", aLegenda )

Return (Nil)
