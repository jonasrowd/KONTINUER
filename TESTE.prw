#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#INCLUDE "FWEditPanel.CH"

// FUN��O PRINCIPAL
User Function KCOMF035()
	Private l_Browse   := .T.
	Private oBrowse
	 
    //Iniciamos a constru��o b�sica de um Browse.
	oBrowse := FWMBrowse():New()
	 
    //Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
	oBrowse:SetAlias("ZBY")
	 
    //Definimos o t�tulo que ser� exibido como m�todo SetDescription
	oBrowse:SetDescription("Natureza do Gasto")

    oBrowse:Activate()
Return (NIL)

Static Function MenuDef()
	Local aRotina := {}
     
    //Adicionando op��es
    IF (IIF(Type("l_Browse") == "L", l_Browse, .F.)) == .T.
	    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.KCOMF035' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.KCOMF035' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.KCOMF035' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.KCOMF035' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	    ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'U_fImpZBY' OPERATION 8 ACCESS 0
	ENDIF
Return aRotina


// REGRAS DE NEG�CIO
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
    oModel:GetModel("ZBYMASTER"):SetDescription("Natureza do Gasto")
    oModel:GetModel("ZBZDETAIL"):SetDescription("Entidades COnt�beis")
    
    oModel:GetModel("ZBZDETAIL"):SetOptional(.T.)
Return oModel

// INTERFACE GR�FICA
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
    oView:EnableTitleView("VIEW_ZBZ", "ENTIDADES CONT�BEIS", 0)

    oView:SetViewProperty('VIEW_ZBY' , 'SETLAYOUT' , {FF_LAYOUT_HORZ_DESCR_TOP,10} ) 
Return (oView)
