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
	oBrowse:SetDescription("Pr�-Notas a Classificar")

	// Defini��o da legenda
	oBrowse:AddLegend( "ZBY_STATUS=='I' .AND. ZBY_SITUAC == 'A'", "GREEN"   , "Analisado, Sem Restri��o" )
	oBrowse:AddLegend( "ZBY_STATUS=='P' .AND. ZBY_SITUAC == 'A'", "RED"     , "Analisado, Prc Divergente" )
	oBrowse:AddLegend( "ZBY_STATUS=='Q' .AND. ZBY_SITUAC == 'A'", "YELLOW" 	, "Analisado, Qtde Divergente" )
	oBrowse:AddLegend( "ZBY_STATUS=='A' .AND. ZBY_SITUAC == 'A'", "ORANGE" 	, "Analisado, Prc/Qtde Divergentes" )

	oBrowse:SetFilterDefault("ZBY->ZBY_OK == ' '")

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
	    // ADD OPTION aRotina TITLE 'Incluir'    			ACTION 'VIEWDEF.KCOMF037' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	    // ADD OPTION aRotina TITLE 'Alterar'    			ACTION 'VIEWDEF.KCOMF037' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	    // ADD OPTION aRotina TITLE 'Excluir'    			ACTION 'VIEWDEF.KCOMF037' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
		ADD OPTION aRotina TITLE 'Classificar'     		ACTION 'U_CustomClas' OPERATION 6 ACCESS 0
		ADD OPTION aRotina TITLE 'Documento de Entrada' ACTION 'U_ExecPadrao("MATA103")' OPERATION 7 ACCESS 0
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
    oModel:SetDescription("Natureza do Gasto")

    // DESCRI��O DOS SUBMODELOS
    oModel:GetModel("ZBYMASTER"):SetDescription("Pr�-Notas a Classificar")
    oModel:GetModel("ZBZDETAIL"):SetDescription("Itens Analisados")
    
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
    oView:EnableTitleView("VIEW_ZBZ", "ITENS ANALISADOS PR�-NOTA", 0)

    oView:SetViewProperty('VIEW_ZBY' , 'SETLAYOUT' , {FF_LAYOUT_HORZ_DESCR_TOP,10} ) 

Return (oView)

/*/{Protheus.doc} CustomClas
	Abre a fun��o para classificar a pr�-nota
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
/*/
User Function CustomClas()

	Local aArea := FwGetArea()

	// Verifica se o alias j� estava aberto, se estiver, fecha
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
			AND F1_STATUS = ' '
			AND %NOTDEL%
	ENDSQL

	aRotina := FwLoadMenuDef("MATA103")

	DbSelectArea("SF1")
	DbGoto(TmpRec->Recno)
	A103NFiscal("SF1",SF1->(Recno()),4,.f.,.f.)

	TmpRec->(DbCloseArea())

	FwRestArea(aArea)

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

	aAdd(aLegenda,{"BR_VERDE"   , "Analisado, Sem Restri��o" })
	aAdd(aLegenda,{"BR_VERMELHO"     , "Analisado, Prc Divergente" })
	aAdd(aLegenda,{"BR_AMARELO"  , "Analisado, Qtde Divergente" })
	aAdd(aLegenda,{"BR_LARANJA"  , "Analisado, Prc/Qtde Divergentes" })
	// aAdd(aLegenda,{"BR_AZUL_CLARO", "Rejei. Prc Divergente" })
	// aAdd(aLegenda,{"BR_PINK" 	 , "Rejei. Qtde Divergente" })
	// aAdd(aLegenda,{"BR_PRETO" 	 , "Rejei. Prc/Qtde Divergentes" })

	BrwLegenda("Pr�-Notas a Classificar", "", aLegenda )

Return (Nil)
