/**---------------------------------------------------------------------------------------------**/
/** PROPRIETÁRIO: Kontinuer																																			**/
/** MODULO			: Compras																																				**/				
/** FINALIDADE	: Ponto de entrada no final da gravação do documento de entrada									**/
/** DATA 				: 14/11/2018																																		**/														 			
/**---------------------------------------------------------------------------------------------**/
/**                                 DECLARAÇÃO DAS BIBLIOTECAS                         					**/
/**---------------------------------------------------------------------------------------------**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "totvs.ch"   
#Include "protheus.ch"
#Include "parmtype.ch"   

/**---------------------------------------------------------------------------------------------**/
/**                                   DEFINIÇÃO DE PALAVRAS					                  					**/
/**---------------------------------------------------------------------------------------------**/
#Define ENTER CHR(13)+CHR(10) 
/**---------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇÃO: MT103FIM()				                                                   				**/
/** DESCRIÇÃO	  	: Geencia as chamadas de rotina																								**/
/**---------------------------------------------------------------------------------------------**/
/**															CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES                       	   		**/	
/**---------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                      **/
/**---------------------------------------------------------------------------------------------**/
/** 14/11/2018 	| Velton Teixeira        | 					-				   |																**/
/**---------------------------------------------------------------------------------------------**/
/**	   					                  			PARAMETROS     	              		      								**/	
/**---------------------------------------------------------------------------------------------**/
/** 													Nenhum parametro esperado para essa rotina                     		**/
/**---------------------------------------------------------------------------------------------**/

User Function MT103FIM()

	Local nOpc 		:= ParamIxb[1]
	Local lConf		:= (ParamIxb[2] == 1)
	Local cNumNf	:= SF1->F1_DOC
	Local cSerNf	:= SF1->F1_SERIE
	Local cForNf	:= SF1->F1_FORNECE
	Local cLojNf	:= SF1->F1_LOJA
	Local cTipNf	:= SF1->F1_TIPO 
	Local lRetb		:=	.T.
	Local cTpDoc	:= "NF"

	If (nOpc == 3 .Or. nOpc == 4)
		U_VALIDENT(cNumNf,cSerNf,cForNf,cLojNf)
	EndIf

	//Verifica se confirmou
	If (lConf)  //validar tb o estorno na szb

		//Atualiza o status
		U_KCOMF003(SF1->F1_DOC, SF1->F1_SERIE, nOpc)
				
		//Atualiza a SZB/SZC
		MT103FIMA(nOpc)

		//Verifica se é inclusão
		If (nOpc == 3 .OR. nOpc == 4)

			//Verifica se inclusão
			If (nOpc == 3)
			
				//Tracker de classificalção
				U_KCOMF023("030", "", "")

			//Classificação
			ElseIf (nOpc == 4 .AND. l103Class)

				//Tracker de classificalção
				U_KCOMF023("024", "", "")

			EndIf 

			//Verifica se é devolução de compras
			If (cTipNf == "D")

				//Grava o projeot
				GravaProj(cNumNf, cSerNf, cForNf, cLojNf)

			EndIf

			iF!(lRetb := MsgYesNo("Existe Complementos para a nota fiscal?","Apontamento Ordem de Produção","YESNO"))

				//Seleção dos produtos
				MT103FIMB()
				If ExistBlock("KCOMF031")
					U_KCOMF031(cNumNf,cSerNf,cForNf,cLojNf)
				Endif

			EndIf

			//Valida o tipo de nota
			If (cTipNf == "N")
				
				//Chama a rotina de complemento de nota fiscal
				U_KCOMF017()

			EndIf

			// atualiza o vinculo no controle de drawback - Rodrigo Cesar Candido
			GravaDrawback()

		EndIf

		If (nOpc == 3 .OR. nOpc == 4) 
			AjustRE5()	
		EndIf 

		// se exclusão
		If nOpc == 5

			// remove vinculo com drawback
			U_KCOMF16D(cTpDoc, nOpc, cNumNf)

		EndIf

		//INCLUIR LOOP DE IMPRESSÃO DE PEDIDO 

	EndIf

	iF!(lRetb)

	EndIf
  
Return Nil

/**---------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇAO  : GravaProj()				                                                   			**/
/** DESCRIÇÃO		  	: Rotina de gravação do projeto												                      **/
/**---------------------------------------------------------------------------------------------**/
/**															CRIAÇÃO /ALTERAÇÃO / MANUTENÇÕES                            		**/	
/**---------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                      **/
/**---------------------------------------------------------------------------------------------**/
/** 03/12/2021	| Velton Teixeira        | 					-				   |																**/
/**---------------------------------------------------------------------------------------------**/
/**	   					                  			PARAMETROS     	              		      								**/	
/**---------------------------------------------------------------------------------------------**/
/** 													Nenhum parametro esperado para essa rotina                     		**/
/**---------------------------------------------------------------------------------------------**/

Static Function GravaProj(cNumNf, cSerNf, cForNf, cLojNf)

	Local aASD1  := SD1->(GetArea())

	//Ordena a tabela 
	SD1->(DbSetOrder(1))

	//Posiciona no primeiro regisro
	SD1->(DbSeek(xFilial("SD1") + cNumNf + cSerNf +  cForNf + cLojNf))

	//Loop nos itens da SC6
	While (!SD1->(Eof()) .AND. SD1->D1_FILIAL == xFilial("SD1") .AND. SD1->D1_DOC == cNumNf .AND. SD1->D1_SERIE == cSerNf .AND. SD1->D1_FORNECE == cForNf .AND. SD1->D1_LOJA == cLojNf )
		
		//Verifica se tem nota de origem
		If !(Empty(SD1->D1_NFORI))

			//Seleciona os dados da nota fiscal
			cQr := " SELECT 	SD2.D2_KPROJET,
			cQr += " 			SD2.D2_KORDER,
			cQr += " 			SD2.D2_KNOMPRO,SD2.D2_KPOSICA, SD2.D2_KPOSENG, SD2.D2_KSUBPOS, SD2.D2_OP, SD2.D2_TRT
			cQr += " FROM 		" + RetSqlName("SD2") + " SD2 (NOLOCK)
			cQr += " WHERE 		SD2.D2_FILIAL 	= '" + xFilial("SD2") + "'
			cQr += " AND 			SD2.D2_DOC			= '" + SD1->D1_NFORI + "'
			cQr += " AND 			SD2.D2_SERIE		= '" + SD1->D1_SERIORI + "'
			cQr += " AND 			SD2.D2_CLIENTE	= '" + SD1->D1_FORNECE + "'
			cQr += " AND 			SD2.D2_LOJA			= '" + SD1->D1_LOJA + "'
			cQr += " AND 			SD2.D2_ITEM			= '" + SD1->D1_ITEMORI + "'
			cQr += " AND 			SD2.D_E_L_E_T_ = ''

			//Define o alias de dados da query
			TcQuery cQr New Alias "QNFD"

			//Posiciona no inicio da area
			QNFD->(DbGoTop())

			//Verifica se tem dados
			If (!QNFD->(Eof()))

				//Trava a tabela
				RecLock("SD1", .F.)

				SD1->D1_KPROJET := QNFD->D2_KPROJET
				SD1->D1_KORDER 	:= QNFD->D2_KORDER
				SD1->D1_KNOMPRO	:= QNFD->D2_KNOMPRO
				
				// campo unico para compor a chave do projeto - Rodrigo Cesar Candido
										//(cChave, cProjeto, 			cOrder, 			cPosicao, 		cSubPos, 			cItEng, cItPcp, 		cOp, 			cTrt,	 cNomePrj)
				SD1->D1_KCHVPRJ := U_KFATA16(Nil, QNFD->D2_KPROJET, QNFD->D2_KORDER, QNFD->D2_KPOSICA, QNFD->D2_KSUBPOS, QNFD->D2_KPOSENG, Nil,  QNFD->D2_OP,  QNFD->D2_TRT, QNFD->D2_KNOMPRO)

				//FALTA INCLUIR CAMPOS NA SD1 PARA TRATAR DEVOLUÇÕES 

				//Libera a tabela
				SD1->(MsUnLock())

			EndIf

			//Fecha a query
			QNFD->(DbCloseArea())

		EndIf

		//Próximo registro
		SD1->(DbSkip())

	EndDo

	//Restaura a area
	RestArea(aASD1)

Return Nil

//Ajuste dos movimentos RE5
Static Function AjustRE5()
	Local aArea 	:= GetArea()
	Local aAreaD1	:= SD1->(GetArea())
	Local aAreaF1	:= SF1->(GetArea())	
	Local aAreaD3	:= SD3->(GetArea())		
	Local _cFornec 	:= SF1->F1_FORNECE 
	Local _cLOja 	:= SF1->F1_LOJA
	Local _cSerie 	:= SF1->F1_SERIE
	Local _cNota 	:= SF1->F1_DOC
	Local __cDtE	:= Dtos(SF1->F1_DTDIGIT)

	Local 	__cOp 	:= ""
	Local	__cCodP	:= ""
	Local	__cTRT	:= ""
	Local	__cGrp	:= ""
	Local	__cNumS	:= ""
	//Local	__cCodP := ""
	Local	__cCodO := ""
	Local	__cCodN := ""
	//Local 	_cSD3	:= RetSqlName("SD3")
	Local __cCodPr	:= ""
	Local cFilAtu	:= SF1->F1_FILIAL

	DbSelectArea("SD1")
	SD1->(DbSetOrder(1)) //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
	SD1->(DbGoTop())
	If SD1->(DbSeek(cFilAtu + _cNota + _cSerie + _cFornec + _cLOja))
		
		While !SD1->(EOF()) .And. SD1->D1_FILIAL == cFilAtu .And. SD1->D1_DOC == _cNota .And. SD1->D1_SERIE == _cSerie.And. SD1->D1_FORNECE == _cFornec .And. SD1->D1_LOJA == _cLOja
		
			__cOp 	:= SD1->D1_OP
			__cCodPr:= SD1->D1_COD
			__cTRT	:= SD1->D1_TRT
			__cGrp	:= SD1->D1_GRUPO
			__cNumS	:= SD1->D1_NUMSEQ
			

			__cCodP := SD1->D1_KPROJET
			__cCodO := SD1->D1_KORDER
			__cCodN := SD1->D1_KNOMPRO

			If !Empty(__cCodP)	.And. !Empty(__cTRT) //D1_OP,D1_COD,D1_TRT,D1_GRUPO,D1_NUMSEQ,D1_KPROJET,D1_KORDER,D1_KNOMPRO
				
				DbSelectArea("SD3")
				SD3->(DbOrderNickName("BUSD3RE5")) //D3_FILIAL, D3_DOC, D3_COD, D3_NUMSEQ, D3_CF, D3_TRT, D3_EMISSAO, R_E_C_N_O_, D_E_L_E_T_
				SD3->(DbGoTop())
				If SD3->(DbSeek( xFilial("SD3") + _cNota + __cCodPr + __cNumS + 'RE5' + __cTRT + __cDtE)) 
					
					RecLock("SD3",.F.)
					SD3->D3_KPROJET	:= __cCodP
					SD3->D3_KORDER	:= __cCodO
					SD3->D3_KNOMPRO	:= __cCodN
					SD3->(MsUnLock())

				EndIf
				
				/*
				cQry := " UPDATE "+_cSD3+""
				cQry +=	" SET D3_KPROJET = '"+ __cCodP +"' , D3_KORDER = '"+ __cCodO +"' , D3_KNOMPRO = '"+ __cCodN +"'  "
				cQry +=	" WHERE D_E_L_E_T_ = '' "
				cQry +=	" AND D3_FILIAL = '"+ xFilial("SD3") +"' "
				cQry +=	" AND D3_DOC 	= '"+_cNota+"' "
				cQry +=	" AND D3_COD 	= '"+__cCodP+"' "
				cQry +=	" AND D3_NUMSEQ = '"+__cNumS+"' "
				cQry +=	" AND D3_CF 	= 'RE5' "
				cQry +=	" AND D3_TRT 	= '"+__cTRT+"' "
				cQry +=	" AND D3_EMISSAO = '"+__cDtE+"' "
						
				If TCSqlExec(cQry) < 0 //D3_DOC,D3_NUMSEQ,D3_EMISSAO,D3_TRT,D3_COD,D3_CF
					Conout("")
					Conout("TCSQLError() " + TCSQLError())
					Conout("")
				EndIf	
				*/
			EndIf 
		
			SD1->(DbSkip())
		
		EndDo

	EndIf


	RestArea(aArea)
	RestArea(aAreaD1)
	RestArea(aAreaF1)
	RestArea(aAreaD3)
Return()


/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: MT103FIMA()												                                                            **/
/** DESCRICAO	  	: Geerencia as demais funções											            					                			  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO / ALTERACOES / MANUTENCOES                       	   			 				**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                  		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 27/11/2018 	| Velton Teixeira        |                        |   																						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 																		Nenhum Parâmetro Esperado para a Rotina                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/ 

Static Function MT103FIMA(nOpc)
	
	Local cQr		:= ""	

	cQr := " SELECT  		SD1.D1_COD,
	cQr += "					 	SD1.D1_QUANT,
	cQr += "				 		SD1.D1_NFORI,
	cQr += "				 		SD1.D1_SERIORI,
	cQr += "				 		SD2.D2_PEDIDO,
	cQr += "						SD2.D2_ITEMPV,
	cQr += "						SC6.C6_KNUMOP,
	cQr	+= "						SC6.C6_XTRT,
	cQr	+= "						SZB.ZB_DATAPED,
	cQr += "						SZB.ZB_SEQPED
	
	cQr += " FROM				" + RetSqlName("SD1") + "	SD1						 
	
	cQr += " LEFT JOIN 	" + RetSqlName("SD2") + " SD2
	cQr += " ON					SD2.D2_FILIAL		= '" + xFilial("SD2") + "'
	cQr += " AND				SD2.D2_DOC			= SD1.D1_NFORI
	cQr += " AND 				SD2.D2_SERIE		= SD1.D1_SERIORI
	cQr += " AND 				SD2.D2_ITEM			= SD1.D1_ITEMORI
	cQr += " AND 				SD2.D_E_L_E_T_	= ''
	
	cQr += " LEFT JOIN 	" + RetSqlName("SC6") + " SC6
	cQr += " ON					SC6.C6_FILIAL		= '" + xFilial("SC6") + "'
	cQr += " AND				SC6.C6_NUM			= SD2.D2_PEDIDO
	cQr += " AND 				SC6.C6_ITEM			= SD2.D2_ITEMPV
	cQr += " AND 				SC6.C6_PRODUTO	= SD1.D1_COD
	cQr += " AND 				SC6.D_E_L_E_T_	= ''
	
	cQr += " LEFT JOIN 	" + RetSqlName("SZB") + " SZB
	cQr += " ON					SZB.ZB_FILIAL		= '" + xFilial("SZB") + "'
	cQr += " AND				SZB.ZB_PEDIDO		= SD2.D2_PEDIDO
	cQr += " AND 				SZB.ZB_COD			= SD1.D1_COD
	cQr += " AND 				SZB.ZB_TRT			= SC6.C6_XTRT
	cQr += " AND				SZB.ZB_OP 			= SUBSTRING(SC6.C6_KNUMOP, 1, 6) 
	cQr += " AND				SZB.ZB_ITEM 		= SUBSTRING(SC6.C6_KNUMOP, 7, 2) 
	cQr += " AND				SZB.ZB_SEQ 			= SUBSTRING(SC6.C6_KNUMOP, 9, 3) 	
	cQr += " AND 				SZB.D_E_L_E_T_	= ''
	
	cQr += " WHERE			SD1.D1_FILIAL		= '" + xFilial("SD1") + "' 
	cQr += " AND 				SD1.D1_DOC			= '" + cNFiscal + "'
	cQr += " AND 				SD1.D1_SERIE		= '" + cSerie + "'
	cQr += " AND 				SD1.D1_FORNECE	= '" + cA100For + "'
	cQr += " AND 				SD1.D1_LOJA			= '" + cLoja + "'
	cQr += " AND 				SD1.D1_IDENTB6 != ''
	cQr += " AND 				SD1.D_E_L_E_T_	= ''
	
	//Define a area de dados da query
	TcQuery cQr New Alias "QSD1"
	
	//Acessa o inicio da query
	QSD1->(DbGoTop())
	
	//Loop nos itens
	While (!QSD1->(Eof()))
		
		//Inclusão
		If (nOpc == 3 .OR. nOpc == 5)
			
			//Trava a tabela
			RecLock("SZC", .T.)
			
			//Grava
			SZC->ZC_FILIAL		:= xFilial("SZC")
			SZC->ZC_OP			:= QSD1->C6_KNUMOP
			SZC->ZC_COD			:= QSD1->D1_COD
			SZC->ZC_TRT			:= QSD1->C6_XTRT
			SZC->ZC_SEQPED		:= QSD1->ZB_SEQPED
			SZC->ZC_PEDIDO		:= QSD1->D2_PEDIDO
			SZC->ZC_DATAPED		:= Stod(QSD1->ZB_DATAPED)
			SZC->ZC_NFRET		:= cNFiscal
			SZC->ZC_SERRET		:= cSerie
			SZC->ZC_DTRET		:= Date()
			SZC->ZC_QTDRET		:= QSD1->D1_QUANT
			
			//Libera a tabela
			SZC->(MsUnLock())
			
			//Atualiza a SZB
			//U_ATURR(QSD1->D1_COD, QSD1->C6_KNUMOP, QSD1->C6_XTRT, QSD1->D2_PEDIDO, QSD1->ZB_SEQPED)
				
		EndIf
		
		//Próximo registro
		QSD1->(DbSkip())
	
	EndDo

	//Fecha a query
	QSD1->(DbCloseArea())
	
Return Nil

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: MT103FIMB()												                                                            **/
/** DESCRICAO	  	: Verifica se tem ordem de produção vinculada a compra         					                			  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO / ALTERACOES / MANUTENCOES                       	   			 				**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                  		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 27/11/2018 	| Velton Teixeira        |                        |   																						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 																		Nenhum Parâmetro Esperado para a Rotina                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/ 

Static Function MT103FIMB()
	Local cQr	:= ""
	Local cMsg	:= ""	
	Local nX	:= 0
	Local aMsg	:= {}
	Local aAux	:= {}
	Local aASD1	:= SD1->(GetArea())


	cQr := " SELECT  		SD1.D1_COD,
	cQr += "				SD1.D1_OP
	cQr += " FROM			" + RetSqlName("SD1") + "	SD1						 
	cQr += " WHERE			SD1.D1_FILIAL		= '" + xFilial("SD1") + "' 
	cQr += " AND 			SD1.D1_DOC			= '" + cNFiscal + "'
	cQr += " AND 			SD1.D1_SERIE		= '" + cSerie + "'
	cQr += " AND 			SD1.D1_FORNECE		= '" + cA100For + "'
	cQr += " AND 			SD1.D1_LOJA			= '" + cLoja + "'
	cQr += " AND 			SD1.D1_OP 			!= ''
	cQr += " AND 			SD1.D_E_L_E_T_		= ''

	//Define a area de dados da query
	TcQuery cQr New Alias "QSD1"

	//Acessa o inicio da query
	QSD1->(DbGoTop())

	//Loop nos itens
	While (!QSD1->(Eof()))
		
		//Método de apontamento
		If (GetNewPar("KON_NEWAPT", .T.)) 

		
			//Chama a rotina de avaliação
			aAux := U_KCOMF007(QSD1->D1_OP,QSD1->D1_COD)		
		
		Else
		
			//Chama a rotina de avaliação
			aAux := U_KCOMF005(QSD1->D1_OP, .T.)
		
		EndIf
			
		//Grava a mensagem
		Aadd(aMsg, {QSD1->D1_COD, QSD1->D1_OP, aAux[02]})
		
		//Próximo registro
		QSD1->(DbSkip())

	EndDo

	//Fecha a query
	QSD1->(DbCloseArea())

	//Restuarua a area
	RestArea(aASD1)

	//Verifica se tem mensagem
	If (!Empty(aMsg))
		
		//Monta uma descrição	
		cMsg := " ::::::::::::::::: APONTAMENTO DE PRODUCAO ::::::::::::::::::::::"
		cMsg += ENTER
		cMsg += ENTER
		
		//Loop nos itens
		For nX := 1 To Len(aMsg)
			
			//Monta a mensagem
			cMsg += "Produto: " + Alltrim(aMsg[nX][1]) + " | Op.: " +  Alltrim(aMsg[nX][2]) + ENTER
			cMsg += Alltrim(aMsg[nX][3]) + ENTER + ENTER
		
		//Próximo registro
		Next nX

	EndIf

	//Verifica se tem mensagem
	If (!Empty(cMsg))

		//Mensagem
		MsgLog(cMsg, "Apontamento de Producao", 1, .F.)

	EndIf
	
Return Nil	
	
/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: MsgLog()												                                                            	**/
/** DESCRICAO	  	: Tela de Exibição do log																			 					                			  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO / ALTERACOES / MANUTENCOES                       	   			 				**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                  		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 22/02/2018 	| Velton Teixeira        |                        |   																						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 																		Nenhum Parâmetro Esperado para a Rotina                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/ 

Static Function MsgLog(cMsg, cTitulo, nTipo, lEdit)
 	
 	Local lRetMens	 := .F.
  Local oBtnOk			:= "" 
  Local cTxtConf 		:= ""
  Local oBtnCnc			:= ""
  Local cTxtCancel 	:= ""
  //Local nIni				:= 1
  //Local nFim				:= 50    
  Local oBtnSlv			:= Nil
  Local oDlgMens 		:= Nil
  Local oMsg				:= Nil
  Local oFntTxt 		:= TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
    
  Default cMsg    	:= "..."
  Default cTitulo 	:= "zMsgLog"
  Default nTipo   	:= 1 // 1=Ok; 2= Confirmar e Cancelar
  Default lEdit   	:= .F.
   
  //Definindo os textos dos botões
  If(nTipo == 1)
     cTxtConf:='&Ok'
  Else
    cTxtConf:='&Confirmar'
    cTxtCancel:='C&ancelar'
  EndIf
 
  //Criando a janela centralizada com os botões
  Define MsDialog oDlgMens Title cTitulo From 000, 000 To 300, 900 Pixel
  
  //Get com o Log
  @ 002, 004 Get oMsg Var cMsg Of oDlgMens MultiLine Size 445, 121 Font oFntTxt HScroll Pixel
  
  //Verifica se edita
  If !lEdit
  	
  	//Grava como edição
  	oMsg:lReadOnly := .T.
  
  EndIf
       
  //Se for Tipo 1, cria somente o botão OK
   If (nTipo==1)
   	
   	 //Botões
     @ 127, 397 Button oBtnOk Prompt cTxtConf Size 051, 019 Action (lRetMens:=.T., oDlgMens:End()) OF oDlgMens Pixel
       
	//Senão, cria os botões OK e Cancelar
	ElseIf (nTipo==2)
		
		//Botões
    @ 127, 397 Button oBtnOk  Prompt cTxtConf   Size 051, 009 Action (lRetMens:=.T., oDlgMens:End()) OF oDlgMens Pixel
    @ 137, 397 Button oBtnCnc Prompt cTxtCancel Size 051, 009 Action (lRetMens:=.F., oDlgMens:End()) OF oDlgMens Pixel
	
	EndIf
      
  //Botão de Salvar em Txt
  @ 127, 004 Button oBtnSlv Prompt "&Salvar em .txt" Size 051, 019 Action (fSalvArq(cMsg, cTitulo)) OF oDlgMens Pixel
   
  Activate MsDialog oDlgMens Centered
 
Return lRetMens
 
/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: fSalvArq()											                                                            	**/
/** DESCRICAO	  	: Salva o arquivo																							 					                			  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO / ALTERACOES / MANUTENCOES                       	   			 				**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                  		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 21/02/2018 	| Velton Teixeira        |                        |   																						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 																		Nenhum Parâmetro Esperado para a Rotina                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/ 
 
Static Function fSalvArq (cMsg, cTitulo)
  
  Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
  Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
  Local lOk      := .T.
  Local cTexto   := ""
   
  //Pegando o caminho do arquivo
  cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
 
  //Se o nome não estiver em branco    
  If !Empty(cFileNom)
    
    //Teste de existência do diretório
    If !ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
      
      //Mensagem
      Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
      
      //Sai da rotina
      Return Nil
    
    EndIf
     
    //Montando a mensagem
    cTexto := "Função   - "+ FunName()       + CRLF
    cTexto += "Usuário  - "+ cUserName       + CRLF
    cTexto += "Data     - "+ dToC(dDataBase) + CRLF
    cTexto += "Hora     - "+ Time()          + CRLF
    cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra
     
    //Testando se o arquivo já existe
    If File(cFileNom)
    	
    	//Mensgem
    	lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
    
    EndIf
     
    If lOk
    
    	//Grava o arquivo
      MemoWrite(cFileNom, cTexto)
      MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
    
    EndIf
  
  EndIf

Return Nil
	
Return Nil

/**-----------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: GravaDrawback                          	                                                        **/
/** DESCRICAO     : Função para vincular a NF no controle de Drawback                                               **/
/**-----------------------------------------------------------------------------------------------------------------**/
/**                                     CRIACAO / ALTERACOES / MANUTENCOES                                          **/
/**-----------------------------------------------------------------------------------------------------------------**/
/** Data        | Desenvolvedor          | Solicitacao              | Descricao                                     **/
/**-----------------------------------------------------------------------------------------------------------------**/
/** 15/01/2022  | Rodrigo Cesar Candido  |                          |                                               **/
/**-----------------------------------------------------------------------------------------------------------------**/
/*                                      PARAMETROS                                                                  **/
/**-----------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado.                                                                                      **/
/**-----------------------------------------------------------------------------------------------------------------**/
Static Function GravaDrawback()

	Local aArea 	:= GetArea()
	Local cQuery 	:= ""
	Local cAlias 	:= ""
	Local cTpDoc	:= "NF"

	// query
	cQuery := " SELECT R_E_C_N_O_ RECSD1 "
	cQuery += " FROM "+ RetSqlName("SD1") + " SD1 " 
	cQuery += " WHERE 1=1 "
	cQuery += " 	AND D1_FILIAL 	= '"+ xFilial("SD1") +"'"
	cQuery += " 	AND D1_DOC 		= '"+ SF1->F1_DOC +"'"
	cQuery += " 	AND D1_SERIE 	= '"+ SF1->F1_SERIE +"'"
	cQuery += " 	AND D1_FORNECE 	= '"+ SF1->F1_FORNECE +"'"
	cQuery += " 	AND D1_LOJA 	= '"+ SF1->F1_LOJA +"'"
	cQuery += " 	AND D1_KPROJET != ' ' "
	cQuery += " 	AND D_E_L_E_T_ != '*' "

	// executa
	cAlias := MpSysOpenQuery(cQuery)

	// indice
	SD1->(DbSetOrder(1))

	// loop
	While !(cAlias)->(EoF())
		
		// posiciona
		SD1->(DbGoTo((cAlias)->RECSD1))

		// atualiza o vinculo no Z09
		U_KCOMF016(cTpDoc, SD1->D1_DOC)

		// proximo
		(cAlias)->(DbSkip())
	
	EndDo
	
	// fecha alias
	(cAlias)->(DbCloseArea())

	// restaura
	RestArea(aArea)

Return
