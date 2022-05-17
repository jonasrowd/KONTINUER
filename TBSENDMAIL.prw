// Bibliotecas Necessárias
#Include "TOTVS.ch"
#include "AP5MAIL.ch"
#Include "TBICONN.ch"

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
	c_Password	:= GETMV("MV_RELPSW")	//Senha da Conta de E-Mail para envio de relatorios
	c_Autentic	:= GETMV("MV_RELPSW")	//Senha para autenticacäo no servidor de e-mail
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
