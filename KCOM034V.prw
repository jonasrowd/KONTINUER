// Bibliotecas Necessárias
#Include "TOTVS.ch"
#Include "AP5MAIL.ch"
#Include "TBICONN.ch"
#Include "TopConn.ch"

#Define ENTER CHR(13)+CHR(10) // Pula linha

/*/{Protheus.doc} KCOM034V
    WF de aprovação ou rejeição do Documento
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 13/05/2022
/*/
User Function KCOM034V(_cDoc, _cSerie, _cForn, _cLoja)

	Local c_Cabec   := ""
	Local cDest	:= SuperGetMv("KR_MAILPRE",, "follow-up@kontinuer.com")

    // Função para enviar e-mail
	EnviarEmail(cDest, c_Cabec, cUsername, DToC(Date()) + " " + Time(), _cDoc, _cSerie, _cForn, _cLoja)

Return (Nil)

/*/{Protheus.doc} EnviarEmail
    Função para enviar e-mails
    @type function
    @version 12.1.33
    @author Jonas Machado
    @since 13/05/2022
    @param _cEmail, character, E-mail destinatário, pode-se criar o parâmetro
    @param _cCabec, character, Cabeçalho
    @param _cNome, character, Nome do usuário logado
    @param _cPeriodo, character, Emissão do documento
/*/
Static Function EnviarEmail(_cEmail, _cCabec, _cNome, _cPeriodo, _cDoc, _cSerie, _cForn, _cLoja)

	Local _cCorpo := "" // Corpo do e-mail
    Local nX := 0 
	Local cPedido := ""
	Local cSolic := ""

	//Ordene a tabela
	SA2->(DbSetOrder(1))

	//Posiciona no fornecedor
	SA2->(DbSeek(xFilial("SA2") + _cForn + _cLoja))

    _cCorpo := '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    _cCorpo += '<html>
	_cCorpo += '<head>
	_cCorpo += '  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
	_cCorpo += '  <title>FOLLOWUP</title>
	_cCorpo += '</head>
	_cCorpo += '<body>
	_cCorpo += '<table style="text-align: left; font-weight: bold; color: rgb(255, 255, 255); width: 1650px; height: 35px;" border="0" cellpadding="0" cellspacing="0">
	_cCorpo += '  <tbody>
	_cCorpo += '    <tr>
	_cCorpo += '      <td style="text-align: center; background-color: rgb(51, 51, 51);"><big><big><big>ANÁLISE DE DOCUMENTOS DE ENTRADA</big></big></big></td>
	_cCorpo += '    </tr>
	_cCorpo += '  </tbody>
	_cCorpo += '</table>
	_cCorpo += '<br>
	_cCorpo += '<br>
	_cCorpo += '<table style="text-align: left; width: 1650px; height: 110px;" border="0" cellpadding="2" cellspacing="0">
	_cCorpo += '  <tbody>
	_cCorpo += '    <tr>
	_cCorpo += '      <td style="vertical-align: top; background-color: rgb(238, 238, 238);"><span style="color: rgb(204, 0, 0); font-weight: bold;">&nbsp;Dados do Fornecedor :
	_cCorpo += '			<br><big><span style="color: rgb(0, 0, 0);">&nbsp; '+ SA2->A2_COD + '/' + SA2->A2_LOJA +  ' - ' + SA2->A2_NOME +'</span>
	_cCorpo += '			<br><span style="color: rgb(0, 0, 0);">&nbsp;' + Alltrim(SA2->A2_END) + If (!Empty(SA2->A2_COMPLEM), " - " + Alltrim(SA2->A2_COMPLEM), "") + If (!Empty(SA2->A2_BAIRRO), " - " + SA2->A2_BAIRRO, "") +'</span>
	_cCorpo += '      <br><span style="color: rgb(0, 0, 0);">&nbsp;'+ Alltrim(SA2->A2_MUN) + "/" + SA2->A2_EST +  " - CEP: " + Transform(SA2->A2_CEP, "@R 99.999-999")
	_cCorpo += '			<br>&nbsp;CNPJ: '+Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")+'</span></big></span><big><span  style="font-weight: bold;"> - I.E: '+SA2->A2_INSCR+'</span></big></td>
    _cCorpo += '  </tr>
	_cCorpo += '  </tbody>
	_cCorpo += '</table>
	_cCorpo += '<br>

    // Verifica se o alias já estava aberto, se estiver, fecha
    If Select("TMPZBY") > 0
        TMPZBY->(DbSelectArea("TMPZBY"))
        TMPZBY->(DbCloseArea())
    EndIf

    BEGINSQL ALIAS "TMPZBY"
        SELECT
            ZBY.*
        FROM 
            %TABLE:ZBY% ZBY
	    WHERE
            ZBY_FILIAL     = %XFILIAL:ZBY%
            AND ZBY_DOC    = %EXP:_cDoc%
            AND ZBY_SERIE  = %EXP:_cSerie%
            AND ZBY_FORNEC = %EXP:_cForn%
            AND ZBY_LOJA   = %EXP:_cLoja%
            AND ZBY.%NOTDEL%
    ENDSQL
    
	_cCorpo += '<table style="text-align: left; width: 1650px; height: 44px;" border="0" cellpadding="0" cellspacing="3">
	_cCorpo += '  <tbody>
	_cCorpo += '    <tr>
	_cCorpo += '      <td style="background-color: rgb(238, 238, 238);"><span style="color: rgb(204, 0, 0); font-weight: bold;">&nbsp;Documento:
	_cCorpo += '      <br><big><span style="color: rgb(0, 0, 0);">&nbsp;'+TMPZBY->ZBY_DOC+'</span></big></span></td>
	_cCorpo += '      <td style="background-color: rgb(238, 238, 238);"><span style="color: rgb(204, 0, 0); font-weight: bold;">&nbsp;Série:
	_cCorpo += '      <br><big><span style="color: rgb(0, 0, 0);">&nbsp;'+TMPZBY->ZBY_SERIE+'</span></big></span></td>
	_cCorpo += '      <td style="background-color: rgb(238, 238, 238);"><span style="color: rgb(204, 0, 0); font-weight: bold;">&nbsp;Emissão:
	_cCorpo += '	    <br><big><span style="color: rgb(0, 0, 0);">&nbsp;'+TMPZBY->ZBY_EMISSA+'</span></big></span></td>
	_cCorpo += '    </tr>
	_cCorpo += '  </tbody>
	_cCorpo += '</table>
	_cCorpo += '<br>
	_cCorpo += '<table style="text-align: left; width: 1650px; height: 38px;" border="0" cellpadding="0" cellspacing="0">
	_cCorpo += '  <tbody>
	_cCorpo += '    <tr>
	_cCorpo += '      <td style="background-color: rgb(238, 238, 238);"><span style="color: rgb(204, 0, 0); font-weight: bold;">&nbsp;Solicitante:<br><big><span style="color: rgb(0, 0, 0);">&nbsp;%SOLIC%</span></big></span></td>
	_cCorpo += '		</tr>
	_cCorpo += '  </tbody>
	_cCorpo += '</table>
	_cCorpo += '<br>
	_cCorpo += '<table style="text-align: left; width: 1650px; height: 41px;" border="0" cellpadding="0" cellspacing="0"> 
	_cCorpo += '	<tbody>
	_cCorpo += '    <tr>
	_cCorpo += '      <td style="background-color: rgb(238, 238, 238);"><span style="color: rgb(204, 0, 0); font-weight: bold;">&nbsp;Motivo:<br><big><span style="color: rgb(0, 0, 0);">&nbsp;%OBS%</span></big></span></td>
	_cCorpo += '    </tr>
	_cCorpo += '  </tbody>
	_cCorpo += '</table>
	_cCorpo += '<br>
	_cCorpo += '<br>
	_cCorpo += '<table style="text-align: left; width: 1650px; height: 137px;" border="0" cellpadding="0" cellspacing="2">
	_cCorpo += '  <tbody>
	_cCorpo += '    <tr style="font-weight: bold;">
	_cCorpo += '      <td rowspan="1" colspan="15" style="text-align: center; width: 111px; background-color: rgb(237, 237, 237); height: 31px;"><big><big>QUADRO COMPARATIVO</big></big></td>
	_cCorpo += '    </tr>
	_cCorpo += '    <tr>
	_cCorpo += '      <td style="font-weight: bold; color: rgb(255, 255, 255); background-color: rgb(0, 0, 0); text-align: center; height: 31px;">ITEM</td>
	_cCorpo += '      <td style="font-weight: bold; color: rgb(255, 255, 255); background-color: rgb(0, 0, 0); text-align: center; height: 31px;">CÓDIGO</td>
	_cCorpo += '      <td style="font-weight: bold; color: rgb(255, 255, 255); background-color: rgb(0, 0, 0); text-align: center; height: 31px;">DESCRIÇÃO</td>
	_cCorpo += '      <td style="font-weight: bold; color: rgb(255, 255, 255); background-color: rgb(0, 0, 0); text-align: center; height: 31px;">QTDE NF.</td>
	_cCorpo += '      <td style="font-weight: bold; color: rgb(255, 255, 255); background-color: rgb(0, 0, 0); text-align: center; height: 31px;">QTDE PED.</td>
	_cCorpo += '      <td style="font-weight: bold; color: rgb(255, 255, 255); background-color: rgb(0, 0, 0); text-align: center; height: 31px;">UN.NF</td>
	_cCorpo += '      <td style="font-weight: bold; color: rgb(255, 255, 255); background-color: rgb(0, 0, 0); text-align: center; height: 31px;">UN.PED</td>
	_cCorpo += '      <td style="font-weight: bold; color: rgb(255, 255, 255); background-color: rgb(0, 0, 0); text-align: center; height: 31px;">V.UNITNF</td>
	_cCorpo += '      <td style="font-weight: bold; color: rgb(255, 255, 255); background-color: rgb(0, 0, 0); text-align: center; height: 31px;">V.UNIPED</td>
	_cCorpo += '      <td style="font-weight: bold; color: rgb(255, 255, 255); background-color: rgb(0, 0, 0); text-align: center; height: 31px;">OBSERVAÇÃO</td>
	_cCorpo += '    </tr>

    KCOMF034C(_cDoc, _cSerie, _cForn, _cLoja)

	//Acessa o inicio da query
	QWF->(DbGoTop())

	cPedido := If(!Empty(QWF->C7_NUM), QWF->C7_NUM, "")

	//Loop nos itens
	While (!QWF->(Eof()))
        nX++
		_cCorpo += '    <tr>
		_cCorpo += '      <td style="height: 31px; xbackground-color: rgb(255, 255, 255); text-align: center;">%IT%</td>
		_cCorpo += '      <td style="height: 31px; xbackground-color: rgb(255, 255, 255); ">&nbsp;%COD%</td>
		_cCorpo += '      <td style="height: 31px; xbackground-color: rgb(255, 255, 255); ">&nbsp;%DESC%</td>
		_cCorpo += '      <td style="height: 31px; xbackground-color: rgb(255, 255, 255); ">&nbsp;%QTD%</td>
		_cCorpo += '      <td style="height: 31px; xbackground-color: rgb(255, 255, 255); ">&nbsp;%QTD2%</td>
		_cCorpo += '      <td style="height: 31px; xbackground-color: rgb(255, 255, 255); ">&nbsp;%UN%</td>
		_cCorpo += '      <td style="height: 31px; xbackground-color: rgb(255, 255, 255); ">&nbsp;%UN2%</td>
		_cCorpo += '      <td style="height: 31px; xbackground-color: rgb(255, 255, 255); text-align: right;">&nbsp;%VUNIT%&nbsp;</td>
		_cCorpo += '      <td style="height: 31px; xbackground-color: rgb(255, 255, 255); text-align: right;">%VUNIT2%&nbsp;</td>
		_cCorpo += '      <td style="height: 31px; xbackground-color: rgb(255, 255, 255);">&nbsp;%OBS%</td>
		_cCorpo += '    </tr>

		//Substitui os itens
		_cCorpo := StrTran(_cCorpo, "%IT%"			, QWF->D1_ITEMPC)
		_cCorpo := StrTran(_cCorpo, "%COD%"			, QWF->C7_PRODUTO)
		_cCorpo := StrTran(_cCorpo, "%DESC%"		, U_StrxHtml(Alltrim(QWF->B1_DESC)))
		_cCorpo := StrTran(_cCorpo, "%QTD%"			, Alltrim(Transform(QWF->D1_QUANT, "@E 999,999,999")))
		_cCorpo := StrTran(_cCorpo, "%QTD2%"		, Alltrim(Transform(QWF->C7_QUANT, "@E 999,999,999")))
		_cCorpo := StrTran(_cCorpo, "%UN%"			, QWF->D1_UM)
		_cCorpo := StrTran(_cCorpo, "%UN2%"			, QWF->C7_UM)
		_cCorpo := StrTran(_cCorpo, "%VUNIT%"		, Alltrim(Transform(QWF->D1_VUNIT, "@E 999,999,999.99")))
		_cCorpo := StrTran(_cCorpo, "%VUNIT2%"		, Alltrim(Transform(QWF->C7_PRECO, "@E 999,999,999.99")))
		_cCorpo := StrTran(_cCorpo, "%OBS%"			, Alltrim(QWF->C7_OBS))

		//Próximo registro
		QWF->(DbSkip())

	EndDo

	//Fecha a query
	QWF->(DbCloseArea())

	KCOMF010E(_cDoc, _cSerie, _cForn, _cLoja, cPedido)

	//Verifica se o solicitante foi incluído
	If !(Alltrim(UsrFullName(QWG->SOLIC)) $ cSolic .AND. !Empty(QWG->SOLIC))

		//Adiciona o separador
		cSolic += If (!Empty(cSolic), ENTER, "")
		cSolic += Alltrim(UsrFullName(QWG->SOLIC)) + " [" + Alltrim(UsrRetMail(QWG->SOLIC)) + "]"
		
		//Verifica se tem email
		If (!Empty(UsrRetMail(QWG->SOLIC)))

			//Separador
			_cEmail += If (!Empty(_cEmail), ";", "")				

			//Incrementa o email de cópia
			_cEmail +=  Alltrim(UsrRetMail(QWG->SOLIC))
		
		EndIf

	EndIf

	//Substitui a tag
	_cCorpo := StrTran(_cCorpo, "%SOLIC%", cSolic)

	QWG->(DbCloseArea())

	//Finaliza
	_cCorpo += '  </tbody>
	_cCorpo += '</table>
	_cCorpo += '</body>
	_cCorpo += '</html>    

	// Envia os dados para a rotina que envia o email.
	StartJob("U_TBSENDMAIL()", GetEnvServer(), .F., cEmpAnt, cFilAnt, _cEmail, _cCorpo, AllTrim(SM0->M0_NOMECOM) + " - CONFERÊNCIA DE RECEBIMENTO", .F.)

Return (Nil)

Static Function KCOMF034C(_cDoc, _cSerie, _cForn, _cLoja)

        BEGINSQL ALIAS "QWF"
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
                AND SD1.D1_DOC = %EXP:_cDoc%
                AND SD1.D1_SERIE = %EXP:_cSerie%
                AND SD1.D1_FORNECE = %EXP:_cForn%
                AND SD1.D1_LOJA = %EXP:_cLoja%
                AND SD1.%NOTDEL%
        ENDSQL
	
Return Nil

/*/{Protheus.doc} TBSENDMAIL
	Função responsável pela conexão e envio do WF
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 13/05/2022
	@param c_Emp, character, Grupo de empresa
	@param c_Filial, character, Filial da Empresa
	@param c_To, character, Destinatário
	@param c_Body, character, Corpo do e-mail
	@param c_Subj, character, Assunto do e-mail
	@param l_ExibeTela, logical, Flag das mensagens de envio/erro
	@param a_Anexo, array, Permite enviar anexos 
/*/
User Function TBSENDMAIL(c_Emp, c_Filial, c_To, c_Body, c_Subj, l_ExibeTela, a_Anexo)
	DEFAULT c_Subj			:= "Mensagem enviada pelo Protheus - Totvs"
	DEFAULT c_Body			:= "Mensagem enviada pelo Protheus - Totvs"
	DEFAULT l_ExibeTela 	:= .F.	//Define se a tela de envio/erros devem ser exibidas ao final de cada processamento
	DEFAULT a_Anexo			:= {}	//Anexos

	RPCSetType(3) 

	PREPARE ENVIRONMENT EMPRESA c_Emp FILIAL c_Filial MODULO 'EST'

	DBSELECTAREA("SX6")

	c_Server   	:= GETMV("MV_RELSERV")	//Nome do Servidor de Envio de E-mail utilizado nos relatorios
	c_Account  	:= GETMV("MV_RELACNT")	//Conta a ser utilizada no envio de E-Mail para os relatorios
	c_Envia    	:= GETMV("MV_RELFROM")	//E-mail utilizado no campo FROM no envio de relatorios por e-mail
	c_Password	:= ""
	c_Autentic	:= ""
	// c_Password	:= GETMV("MV_RELPSW")	//Senha da Conta de E-Mail para envio de relatorios
	// c_Autentic	:= GETMV("MV_RELPSW")	//Senha para autenticacäo no servidor de e-mail
	l_Autentic	:= GETMV("MV_RELAUTH")	//Servidor de EMAIL necessita de Autenticacao?
	c_Erro		:= ""

	IF c_To == NIL .or. Empty( c_To )
		Aviso(SM0->M0_NOMECOM,"O e-mail não pôde ser enviado, pois o primeiro parâmetro (DESTINATÁRIO) não foi preenchido.",{"Ok"},2,"Erro de envio!")
		CONOUT("O e-mail não pôde ser enviado, pois o primeiro parâmetro (DESTINATÁRIO) não foi preenchido.")
		Return(.F.)
	ENDIF

	// Conecta ao servidor SMTP
	CONNECT SMTP SERVER c_Server ACCOUNT c_Account PASSWORD c_Password RESULT lConectou

	// Caso o servidor SMTP do cliente necessite de autenticacao, será necessario habilitar o parametro MV_RELAUTH
	IF l_Autentic
		If !MailAuth( c_Account, c_Autentic )
			IF l_ExibeTela
				Aviso(SM0->M0_NOMECOM,"Falha na autenticação do Usuário!",{"Ok"},1,"Atenção")
			ENDIF
			CONOUT("Falha na autenticação do Usuário!")
			DISCONNECT SMTP SERVER RESULT lDisConectou
			Return(.F.)
		Endif
	ENDIF

	// Verifica se houve conexao com o servidor SMTP
	If !lConectou
		IF l_ExibeTela
			Aviso(SM0->M0_NOMECOM,"Erro ao conectar servidor de E-Mail (SMTP) - " + c_Server+CHR(10)+CHR(13)+;
				"Solicite ao Administrador que seja verificado os parâmetros e senhas do servidor de E-Mail (SMTP)",{"Ok"},3,"Atenção!")
		ENDIF
		CONOUT("Erro ao conectar servidor de E-Mail (SMTP) - " + c_Server+CHR(10)+CHR(13)+"Solicite ao Administrador que seja verificado os parâmetros e senhas do servidor de E-Mail (SMTP)")
		Return(.F.)
	Endif

	// Envia o e-mail
	IF LEN(a_Anexo) >= 1
		SEND MAIL FROM c_Envia TO Alltrim(c_To) SUBJECT c_Subj BODY c_Body ATTACHMENT a_Anexo[1] RESULT lEnviado
	ELSE
		SEND MAIL FROM c_Envia TO Alltrim(c_To) SUBJECT c_Subj BODY c_Body RESULT lEnviado
	ENDIF

	
	// Verifica possíveis erros durante o envio do e-mail
	If lEnviado
		IF l_ExibeTela
			Aviso(SM0->M0_NOMECOM,"Foi enviado e-mail para "+c_To+" com sucesso!",{"Ok"},3,"Informação!")
		ENDIF
		CONOUT("Foi enviado e-mail para "+c_To+" com sucesso!")
	Else
		GET MAIL ERROR c_Erro
		IF l_ExibeTela
			Aviso(SM0->M0_NOMECOM,c_Erro,{"Ok"},3,"Atenção!")
		ENDIF
		CONOUT(c_Erro)
		Return(.F.)
	Endif

	// Desconecta o servidor de SMTP
	DISCONNECT SMTP SERVER Result lDisConectou

Return (.T.)

/**---------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇÃO	: KCOMF01E()			                                                 					**/
/** DESCRIÇÃO	  		: Seleciona os dados do WF										               								**/
/**---------------------------------------------------------------------------------------------**/
/**															CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES                       	   		**/	
/**---------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                      **/
/**---------------------------------------------------------------------------------------------**/
/** 11/01/2022	| Velton Teixeira        |         -				   |															  **/
/**---------------------------------------------------------------------------------------------**/
/**	   					                  			PARAMETROS     	              		      								**/	
/**---------------------------------------------------------------------------------------------**/
/** 										Nenhum parametro esperado para essa rotina                     					**/
/**---------------------------------------------------------------------------------------------**/ 

Static Function KCOMF010E(_cDoc, _cSerie, _cForn, _cLoja, cPedido)

	Local cQr := ""

	cQr := " SELECT DISTINCT		SC7.C7_XSOLCIT		SOLIC
	cQr += " FROM 			" + RetSqlName("SD1") + " SD1

	cQr += " LEFT JOIN 	" + RetSqlName("SC7") + " SC7
	cQr += " ON 				SC7.C7_FILIAL 	= '" + xFilial("SC7") + "'
	cQr += " AND 				SC7.C7_NUM			= SD1.D1_PEDIDO
	cQr += " AND 				SC7.C7_ITEM			= SD1.D1_ITEMPC
	cQr += " AND 				SC7.D_E_L_E_T_	= ''

	cQr += " WHERE 			SD1.D1_FILIAL  	= '" + xFilial("SD1") + "'
	cQr += " AND 				SD1.D1_DOC    	= '" + _cDoc + "'
	cQr += " AND 				SD1.D1_SERIE   	= '" + _cSerie + "'
	cQr += " AND 				SD1.D1_FORNECE 	= '" + _cForn + "'
	cQr += " AND 				SD1.D1_LOJA    	= '" + _cLoja + "'
	cQr += " AND 				SD1.D1_PEDIDO  	= '" + cPedido + "'
	cQr += " AND 				SD1.D_E_L_E_T_ 	= ''

	//Define o alias de dados da query
	TcQuery cQr New Alias "QWG"
	
Return Nil
