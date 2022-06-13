// Bibliotecas necess�rias
#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#INCLUDE "FWEditPanel.CH"

/*/{Protheus.doc} KCOMF037
	Rotina customizada para visualizar as pr�-notas que v�o sendo avaliadas antes de serem classificadas, 
	para que possam verificar o tipo de classifica��o ou se ser� devolu��o sem maiores dificuldades.
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
/*/
User Function KCOMF037()

	Private l_Browse	:= .T.
	Private oBrowse

    //Iniciamos a constru��o b�sica de um Browse.
	oBrowse := FWMBrowse():New()

    //Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
	oBrowse:SetAlias("ZBY")

    //Definimos o t�tulo que ser� exibido como m�todo SetDescription
	oBrowse:SetDescription("Documentos para Confer�ncia")

	// Defini��o da legenda
	oBrowse:AddLegend( "ZBY_STATUS == ' ' .AND. ZBY_SITUAC == 'L' ", "GREEN"   , "N�o Conferido" )
	oBrowse:AddLegend( "ZBY_STATUS == 'I' .AND. ZBY_SITUAC == 'I' ", "BLUE"    , "Inutilizada" )
	oBrowse:AddLegend( "ZBY_STATUS != ' ' ", "RED"   , "Conferido" )

	//oBrowse:SetFilterDefault("ZBY->ZBY_OK == ' '")

	oBrowse:Activate()

Return (Nil)

/*/{Protheus.doc} MenuDef
	Defini��o do menu da rotina
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@return Array, aRotina, Array contendo as fun��es do menu da rotina
/*/
Static Function MenuDef()

	Local aRotina := {}

    //Adicionando op��es
    If (IIF(Type("l_Browse") == "L", l_Browse, .F.)) == .T.
	    ADD OPTION aRotina TITLE 'Visualizar'  			ACTION 'VIEWDEF.KCOMF037' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
		ADD OPTION aRotina TITLE 'Conferir'     		ACTION 'U_fConfere(ZBY->ZBY_DOC,ZBY->ZBY_SERIE,ZBY->ZBY_FORNEC,ZBY->ZBY_LOJA,ZBY->ZBY_STATUS)' OPERATION 6 ACCESS 0
		ADD OPTION aRotina TITLE 'Inutilizar'     		ACTION 'U_fInutiliza(ZBY->ZBY_DOC,ZBY->ZBY_SERIE,ZBY->ZBY_FORNEC,ZBY->ZBY_LOJA,ZBY->ZBY_STATUS)' OPERATION 7 ACCESS 0
		ADD OPTION aRotina TITLE 'Legenda'     			ACTION 'U_fLegZBY' OPERATION 11 ACCESS 0
	EndIf

Return (aRotina)

/*/{Protheus.doc} ModelDef
	Defini��o do modelo de dados da rotina
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@return object, oModel,	Retorna o objeto contendo o modelo de dados da rotina
/*/
Static Function ModelDef()

    // INSTANCIA O MODELO
    Local oModel := MPFormModel():New('ModelName',,{|oModel| .T.},)

    // INSTANCIA OS SUBMODELOS
    Local oStruZBY := FwFormStruct(1, "ZBY")
    Local oStruZBZ := FwFormStruct(1, "ZBZ")

    // DEFINE SE OS SUBMODELOS SER�O FIELD OU GRID
    oModel:AddFields("ZBYMASTER", NIL, oStruZBY)
    oModel:AddGrid("ZBZDETAIL", "ZBYMASTER", oStruZBZ)

    // DEFINE A RELA��O ENTRE OS SUBMODELOS
    oModel:SetRelation("ZBZDETAIL", {{"ZBZ_FILIAL", "ZBY_FILIAL"}, {"ZBZ_DOC", "ZBY_DOC"}, {"ZBZ_SERIE", "ZBY_SERIE"},{"ZBZ_FORNEC", "ZBY_FORNEC"},{"ZBZ_LOJA", "ZBY_LOJA"}}, ZBZ->(IndexKey(1)))

    oModel:SetPrimaryKey({ 'ZBY_FILIAL', 'ZBY_DOC', 'ZBY_SERIE' })

    oModel:GetModel('ZBZDETAIL'):SetUniqueLine( { 'ZBZ_DOC', 'ZBZ_SERIE','ZBZ_FORNEC','ZBZ_LOJA'} )

    // DESCRI��O DO MODELO
    oModel:SetDescription("Confer�ncia de Entradas")

    // DESCRI��O DOS SUBMODELOS
    oModel:GetModel("ZBYMASTER"):SetDescription("Entradas a Conferir")
    oModel:GetModel("ZBZDETAIL"):SetDescription("Itens a Conferir")
    oModel:GetModel("ZBZDETAIL"):SetOptional(.T.)

Return (oModel)

/*/{Protheus.doc} ViewDef
	Defini��o da vis�o de dados da rotina
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@return object, oView, Retorna o objeto com a estrutura da rotina
/*/
Static Function ViewDef()

    // INSTANCIA A VIEW
    Local oView := FwFormView():New()

    // INSTANCIA AS SUBVIEWS
    Local oStruZBY := FwFormStruct(2, "ZBY")
    Local oStruZBZ := FwFormStruct(2, "ZBZ")

    // RECEBE O MODELO DE DADOS
    Local oModel := ModelDef()

    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    // CRIA ESTRUTURA VISUAL DE CAMPOS
    oView:AddField("VIEW_ZBY", oStruZBY, "ZBYMASTER")

    // CRIA A ESTRUTURA VISUAL DAS GRIDS
    oView:AddGrid("VIEW_ZBZ", oStruZBZ, "ZBZDETAIL")

    // CRIA BOXES HORIZONTAIS
    oView:CreateHorizontalBox("EMCIMA", 35)
    oView:CreateHorizontalBox("EMBAIXO", 65)

    // RELACIONA OS BOXES COM AS ESTRUTURAS VISUAIS
    oView:SetOwnerView("VIEW_ZBY", "EMCIMA")
    oView:SetOwnerView("VIEW_ZBZ", "EMBAIXO")

    // DEFINE OS T�TULOS DAS SUBVIEWS
    oView:EnableTitleView("VIEW_ZBY")
    oView:EnableTitleView("VIEW_ZBZ", "Itens a Conferir", 0)

    oView:SetViewProperty('VIEW_ZBY' , 'SETLAYOUT' , {FF_LAYOUT_HORZ_DESCR_TOP,10} ) 

Return (oView)

/*/{Protheus.doc} fLegZBY
	Exibe um prompt com as legendas da rotina
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
/*/
User Function fLegZBY

	Local aLegenda := {}

	aAdd(aLegenda,{"BR_VERDE"    , "N�o Conferido" })
	aAdd(aLegenda,{"BR_AZUL"  , "Inutilizado" })
	aAdd(aLegenda,{"BR_VERMELHO" , "Conferido" })

	BrwLegenda("Documentos a Conferir", "", aLegenda )

Return (Nil)

User Function fConfere(_cDoc,_cSerie,_cForn,_cLoja,_cStatus)
	If Empty(_cStatus)
		U_KCOMF034(_cDoc,_cSerie,_cForn,_cLoja)
	Else
		Help(NIL, NIL, SM0->M0_NOMECOM, NIL, "Este documento j� foi conferido.",;
        1, 0, NIL, NIL, NIL, NIL, NIL, {"Para efetuar a confer�ncia, selecione um documento com status VERDE."})
	EndIf

Return Nil

User Function fInutiliza(_cDoc,_cSerie,_cForn,_cLoja,_cStatus)

	DbSelectArea("ZBY")
	DbSetOrder(1)
	DbSeek(xFilial("ZBY")+_cDoc+_cSerie+_cForn+_cLoja)
	If ZBY->ZBY_STATUS == "I"
		If MsgYesNo("Deseja RESTAURAR este documento na rotina?", "Restaurar o documento")
			RecLock("ZBY",.F.)
				ZBY->ZBY_STATUS := " "
				ZBY->ZBY_SITUAC := "L"
			MsUnlock()
		EndIf
	Else
		If (MsgYesNo("Deseja Inutilizar este documento na rotina?", "Inutilizar o documento") .And. ZBY->ZBY_STATUS <> "C")
			RecLock("ZBY",.F.)
				ZBY->ZBY_STATUS := "I"
				ZBY->ZBY_SITUAC := "I"
			MsUnlock()
		EndIf
	EndIf

Return Nil
