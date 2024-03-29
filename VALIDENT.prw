#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} VALIDENT
    Fun��o desenvolvida para realizar valida��es de exist�ncia de registros no banco de dados.
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 09/06/2022
/*/
User Function VALIDENT(_cDoc, _cSerie, _cForn, _cLoja)

    // Inicializa��o de vari�veis
	Local aArea := GetArea()
    Local c_Tes := ""
    Local c_Status := ""

    DEFAULT CNFISCAL    := _cDoc
    DEFAULT CSERIE      := _cSerie
    DEFAULT CA100FOR    := _cForn
    DEFAULT CLOJA       := _cLoja   

	BEGINSQL ALIAS "TMPCHT"
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

	If Eof()

        // Busca pelos itens da pr�-nota
        BEGINSQL ALIAS "TMPDOC"
            SELECT
                SF1.F1_DOC,
                SF1.F1_SERIE,
                SF1.F1_EMISSAO,
                SD1.D1_ITEM,
                SD1.D1_COD,
                SD1.D1_TP,
                SD1.D1_UM,
                SD1.D1_QUANT,
                SD1.D1_VUNIT,
                SD1.D1_TOTAL,
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
                AND SD1.D1_TIPO = 'N'
                AND SD1.D1_PEDIDO != ''
        ENDSQL

        BEGIN TRANSACTION

            TMPDOC->(dBgOtOP())

			// Persiste os dados na tabela de itens da pr�-nota
			While TMPDOC->(!EOF())
                    // Grava os itens da pr�-nota
                    RecLock("ZBZ",.T.)
                        ZBZ->ZBZ_FILIAL := FWXFILIAL("ZBZ")
                        ZBZ->ZBZ_DOC    := CNFISCAL
                        ZBZ->ZBZ_SERIE  := CSERIE
                        ZBZ->ZBZ_FORNEC := CA100FOR
                        ZBZ->ZBZ_LOJA   := CLOJA
                        ZBZ->ZBZ_NOME   := Posicione('SA2',1,xFilial('SA2')+CA100FOR+CLOJA,'A2_NOME')
                        ZBZ->ZBZ_EMISSA := STOD(TMPDOC->F1_EMISSAO)
                        ZBZ->ZBZ_PRODUT := TMPDOC->D1_COD
                        ZBZ->ZBZ_DOCQTD := TMPDOC->D1_QUANT
                        ZBZ->ZBZ_DOCUNM := TMPDOC->D1_UM
                        ZBZ->ZBZ_DOCVLR := TMPDOC->D1_VUNIT
                        ZBZ->ZBZ_DOCDIF := TMPDOC->TMP_DIFPRC
                        ZBZ->ZBZ_PEDNUM := TMPDOC->D1_PEDIDO
                        ZBZ->ZBZ_PEDITM := TMPDOC->D1_ITEMPC
                        ZBZ->ZBZ_PEDQTD := TMPDOC->TMP_SLDENTR
                        ZBZ->ZBZ_PEDUNM := TMPDOC->C7_UM
                        ZBZ->ZBZ_PEDVLR := TMPDOC->C7_PRECO
                        ZBZ->ZBZ_PEDFAL := TMPDOC->SALDO
                        ZBZ->ZBZ_PEDDIF := TMPDOC->TMP_DIFPRC
                        ZBZ->ZBZ_DTHORA := ""
                        ZBZ->ZBZ_USUA   := ""
                    MsUnlock()

				TMPDOC->(DbSkip())
			End

            TMPDOC->(dBgOtOP())
            
            IF TMPDOC->(!EOF())
                // Persiste os dados na tabela de cabe�alho de documentos a serem avaliados
                RecLock("ZBY",.T.)
                    ZBY->ZBY_FILIAL  := FWXFILIAL("ZBY")
                    ZBY->ZBY_DOC     := CNFISCAL
                    ZBY->ZBY_SERIE   := CSERIE
                    ZBY->ZBY_FORNEC  := CA100FOR
                    ZBY->ZBY_LOJA    := CLOJA
                    ZBY->ZBY_EMISSA  := STOD(TMPDOC->F1_EMISSAO)
                    ZBY->ZBY_NOME    := Posicione('SA2',1,xFilial('SA2')+CA100FOR+CLOJA,'A2_NOME')
                    ZBY->ZBY_DTHORA  := DToC(Date()) + " " + Time()
                    ZBY->ZBY_USUA    := ""
                    ZBY->ZBY_STATUS  := ""
                    ZBY->ZBY_SITUAC  := "L"
                    ZBY->ZBY_MOTIVO  := ""
                    ZBY->ZBY_OK      := ""
                MsUnlock()
            ENDIF

		END TRANSACTION

        TMPDOC->(DbCloseArea())

    ELSE

        // Busca pelos itens da pr�-nota
        BEGINSQL ALIAS "TMPDOC"
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
                AND SD1.D1_PEDIDO != ''
        ENDSQL

        DbSelectArea("TMPDOC")
        c_Tes := TMPDOC->D1_TES

        If (c_Status == "C" .AND. !EMPTY(c_Tes))
            U_KCOM034V(CNFISCAL, CSERIE, CA100FOR, CLOJA)
        EndIf

        TMPDOC->(DbCloseArea())
	ENDIF
    TMPCHT->(DbCloseArea())
	RestArea(aArea)

Return Nil
