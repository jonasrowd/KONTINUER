#Include "TOTVS.ch"

/*/{Protheus.doc} MT103PN
	Ponto de entrada antes da classifica��o para exibir mensagem informando como foi verificada a pr�-nota
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@return Logical, lOk, Retorno .T. permite o acesso � rotina
/*/
User Function MT103PN()

	Local lOk := .T. 			// Vari�vel de controle
	Local aArea := GetArea()
	Local cMsg := ""

	// Verifica se o alias j� estava aberto, se estiver, fecha
	If Select("TMPCLA") > 0
		TMPCLA->(DbSelectArea("TMPCLA"))
		TMPCLA->(DbCloseArea())
	EndIf

	BEGINSQL ALIAS "TMPCLA"
		SELECT
			ZBY_DOC,
			ZBY_SERIE,
			ZBY_FORNEC,
			ZBY_LOJA,
			ZBY_STATUS,
			ZBY_SITUAC
		FROM 
			%TABLE:ZBY% ZBY
		INNER JOIN 
			%TABLE:SF1% SF1
		ON 
			ZBY_FILIAL = F1_FILIAL
			AND ZBY_DOC = F1_DOC
			AND ZBY_SERIE = F1_SERIE
			AND ZBY_FORNEC = F1_FORNECE
			AND ZBY_LOJA = F1_LOJA
			AND SF1.%NOTDEL%
		WHERE
			ZBY_FILIAL = %XFILIAL:ZBY%
			AND ZBY_DOC = %EXP:cNFiscal%
			AND ZBY_SERIE = %EXP:cSerie%
			AND ZBY_FORNEC = %EXP:cA100For%
			AND ZBY_LOJA = %EXP:cLoja%
			AND F1_STATUS = ' '
			AND ZBY.%NOTDEL%
	ENDSQL

	If !Eof()

		// Testa os casos dos status da legenda para exibir ao usu�rio a informa��o.
		Do Case

		Case (TMPCLA->ZBY_STATUS=='I' .AND. TMPCLA->ZBY_SITUAC == 'A')
			cMsg := "Aprovada Sem Restri��o do Pedido de Compras"
		Case (TMPCLA->ZBY_STATUS=='P' .AND. TMPCLA->ZBY_SITUAC == 'A')
			cMsg := "Aprovada com Pre�o Divergente do Pedido de Compras"
		Case (TMPCLA->ZBY_STATUS=='Q' .AND. TMPCLA->ZBY_SITUAC == 'A')
			cMsg := "Aprovada com Quantidade Divergente do Pedido de Compras"
		Case (TMPCLA->ZBY_STATUS=='A' .AND. TMPCLA->ZBY_SITUAC == 'A')
			cMsg := "Aprovada com Pre�o e Quantidade Divergentes do Pedido de Compras"
		EndCase

		lOk := IIf((TMPCLA->ZBY_STATUS=='I' .AND. TMPCLA->ZBY_SITUAC == 'A'),.F.,MsgYesNo("Esta Pr�-Nota foi "+ cMsg +".", "Deseja continuar a classifica��o?"))

	EndIf

	TMPCLA->(DbCloseArea())

	// cnfiscal == documento cserie serie ca100for fornecedor cloja loja cespecie especie ccondicao condicao de pagamento tem o acols e o aheader tbm

	RestArea(aArea)

Return lOk
