#Include "TOTVS.ch"

/*/{Protheus.doc} VALIDENT
    Função desenvolvida para realizar validações de existência de registros no banco de dados.
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 09/06/2022
/*/
User Function VALIDENT(_cDoc, _cSerie, _cForn, _cLoja)

    // Inicialização de variáveis
	Local aArea := FwGetArea()
	Local cAlias 	:= GetNextAlias()
	Local _cAlias := GetNextAlias()
    Local c_Tes := ""
    Local c_Status := ""

    DEFAULT CNFISCAL    := _cDoc
    DEFAULT CSERIE      := _cSerie
    DEFAULT CA100FOR    := _cForn
    DEFAULT CLOJA       := _cLoja   

	BEGINSQL ALIAS cALIAS
	SELECT 
		ZBY_FILIAL
		, ZBY_DOC   
		, ZBY_SERIE 
		, ZBY_FORNEC
		, ZBY_LOJA  
        , ZBY_STATUS
	FROM 
		%TABLE:ZBY%
	WHERE
		ZBY_FILIAL = %XFILIAL:ZBY%
		AND ZBY_DOC = %EXP:CNFISCAL%
		AND ZBY_SERIE = %EXP:CSERIE%
		AND ZBY_FORNEC = %EXP:CA100FOR%
		AND ZBY_LOJA = %EXP:CLOJA%
		AND %NOTDEL%
	ENDSQL

    c_Status := ZBY_STATUS

	IF EOF()
        // Busca pelos itens da pré-nota
        BEGINSQL ALIAS _cAlias
            SELECT
                SF1.F1_DOC,
                SF1.F1_SERIE,
                SF1.F1_EMISSAO,
                SA2.A2_NOME,
                SD1.D1_ITEM,
                SD1.D1_COD,
                SB1.B1_DESC,
                SD1.D1_TP,
                SD1.D1_UM,
                SD1.D1_QUANT,
                SD1.D1_VUNIT,
                SD1.D1_TOTAL,
                (SC7.C7_QUANT - SC7.C7_QUJE) - SD1.D1_QUANT  TMP_SLVINC,
                SD1.D1_PEDIDO,
                SD1.D1_ITEMPC,
                SC7.C7_NUM,
                SC7.C7_ITEM,
                SC7.C7_PRODUTO,
                SC7.C7_UM,
                SC7.C7_QUANT,
                SC7.C7_PRECO,
                (SC7.C7_QUANT - SC7.C7_QUJE) SALDO,
                (SC7.C7_QUANT - SC7.C7_QUJE) - SD1.D1_QUANT TMP_SLDENTR,
                (SC7.C7_PRECO - SD1.D1_VUNIT) TMP_DIFPRC,
                C7_XLARG,
                C7_XCOMPR,
                C7_XQTD2,
                C7_XPRODES,
                C7_OP,
                C7_OBS,
                D1_TP,
                C7_XTRT
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
                INNER JOIN
                    %TABLE:SB1% SB1
                    ON
                        SB1.B1_COD = SD1.D1_COD
                        //AND SB1.B1_FILIAL = SD1.D1_FILIAL
                        AND SB1.%NOTDEL%
                INNER JOIN
                    %TABLE:SA2% SA2
                    ON
                        SA2.A2_COD = SF1.F1_FORNECE
                        AND SA2.A2_LOJA = SF1.F1_LOJA
                        //AND SA2.A2_FILIAL = SF1.F1_FILIAL
                        AND SA2.%NOTDEL%
                INNER JOIN 
                    %TABLE:SC7% SC7
                    ON
                        SC7.C7_NUM = SD1.D1_PEDIDO
                        AND SC7.C7_FILIAL = SD1.D1_FILIAL
                        AND SC7.C7_PRODUTO = SD1.D1_COD
                        AND SC7.C7_ITEM = SD1.D1_ITEMPC
                        AND SC7.C7_FORNECE = SD1.D1_FORNECE
                        AND SC7.C7_LOJA = SD1.D1_LOJA
                        AND SC7.%NOTDEL%
            WHERE
                SD1.D1_FILIAL = %XFILIAL:SD1%
                AND SD1.D1_DOC = %EXP:CNFISCAL%
                AND SD1.D1_SERIE = %EXP:CSERIE%
                AND SD1.D1_FORNECE = %EXP:CA100FOR%
                AND SD1.D1_LOJA = %EXP:CLOJA%
                AND SD1.%NOTDEL%
                AND SD1.D1_TIPO == 'N'
                AND SD1.D1_PEDIDO != ""
        ENDSQL

        BEGIN TRANSACTION

            // Persiste os dados na tabela de cabeçalho de documentos a serem avaliados
            RecLock("ZBY",.T.)
                ZBY->ZBY_FILIAL  := FWXFILIAL("ZBY")
                ZBY->ZBY_DOC     := CNFISCAL
                ZBY->ZBY_SERIE   := CSERIE
                ZBY->ZBY_FORNEC  := CA100FOR
                ZBY->ZBY_LOJA    := CLOJA
                ZBY->ZBY_EMISSA  := CtOD(_cAlias->F1_EMISSAO)
                ZBY->ZBY_NOME    := _cAlias->A2_NOME
                ZBY->ZBY_DTHORA  := DToC(Date()) + " " + Time()
                ZBY->ZBY_USUA    := cUsername
                ZBY->ZBY_STATUS  := ""
                ZBY->ZBY_SITUAC  := "L"
                ZBY->ZBY_MOTIVO  := ""
                ZBY->ZBY_OK      := ""
            MsUnlock()

			// Persiste os dados na tabela de itens da pré-nota
			While !EOF()
                    // Grava os itens da pré-nota
                    RecLock("ZBZ",.T.)
                        ZBZ->ZBZ_FILIAL := FWXFILIAL("ZBZ")
                        ZBZ->ZBZ_DOC    := CNFISCAL
                        ZBZ->ZBZ_SERIE  := CSERIE
                        ZBZ->ZBZ_FORNEC := CA100FOR
                        ZBZ->ZBZ_LOJA   := CLOJA
                        ZBZ->ZBZ_NOME   := _cAlias->A2_NOME
                        ZBZ->ZBZ_EMISSA := CtOD(_cAlias->F1_EMISSAO)
                        ZBZ->ZBZ_PRODUT := _cAlias->D1_PRODUTO
                        ZBZ->ZBZ_DOCQTD := _cAlias->D1_QUANT
                        ZBZ->ZBZ_DOCUNM := _cAlias->D1_UM
                        ZBZ->ZBZ_DOCVLR := _cAlias->D1_VUNIT
                        ZBZ->ZBZ_DOCDIF := _cAlias->TMP_DIFPRC
                        ZBZ->ZBZ_PEDNUM := _cAlias->D1_PEDIDO
                        ZBZ->ZBZ_PEDITM := _cAlias->D1_ITEMPC
                        ZBZ->ZBZ_PEDQTD := _cAlias->TMP_SLDENTR
                        ZBZ->ZBZ_PEDUNM := _cAlias->C7_UM
                        ZBZ->ZBZ_PEDVLR := _cAlias->C7_PRECO
                        ZBZ->ZBZ_PEDFAL := _cAlias->SALDO
                        ZBZ->ZBZ_PEDDIF := _cAlias->TMP_DIFPRC
                        ZBZ->ZBZ_DTHORA := DToC(Date()) + " " + Time()
                        ZBZ->ZBZ_USUA   := ""
                    MsUnlock()
				DbSkip()
			End

		END TRANSACTION

        _cAlias->(DbCloseArea())

    ELSE
        // Busca pelos itens da pré-nota
        BEGINSQL ALIAS _cAlias
            SELECT SD1.*
            FROM
                %TABLE:SD1% SD1
            WHERE
                SD1.D1_FILIAL = %XFILIAL:SD1%
                AND SD1.D1_DOC = %EXP:CNFISCAL%
                AND SD1.D1_SERIE = %EXP:CSERIE%
                AND SD1.D1_FORNECE = %EXP:CA100FOR%
                AND SD1.D1_LOJA = %EXP:CLOJA%
                AND SD1.%NOTDEL%
                AND SD1.D1_TIPO = 'N'
                AND SD1.D1_PEDIDO != ""
        ENDSQL

        c_Tes := D1_TES

        If (c_Status == "C" .AND. !EMPTY(c_Tes))
            U_KCOM034V(CNFISCAL, CSERIE, CA100FOR, CLOJA)
        else
            U_KCOM034V(CNFISCAL, CSERIE, CA100FOR, CLOJA) // Adicionei o Else Para Testar
        EndIf
	ENDIF

	RestArea(aArea)

Return Nil
