/**---------------------------------------------------------------------------------------------**/
/** PROPRIETÁRIO: Kontinuer																																			**/
/** MODULO			: Compras																																				**/				
/** FINALIDADE	: Ponto de entrada no final da gravação do pré documento de entrada							**/
/** DATA 				: 10/12/2019																																		**/														 			
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
#Define OP_VIW "000"
/**---------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇÃO: SF1140I()				                	                                   				**/
/** DESCRIÇÃO	  	: Gerencia rotinas																														**/
/**---------------------------------------------------------------------------------------------**/
/**															CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES                       	   		**/	
/**---------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                      **/
/**---------------------------------------------------------------------------------------------**/
/** 10/10/2018 	| Velton Teixeira        | 					-				   |																**/
/**---------------------------------------------------------------------------------------------**/
/**	   					                  			PARAMETROS     	              		      								**/	
/**---------------------------------------------------------------------------------------------**/
/** 													Nenhum parametro esperado para essa rotina                     		**/
/**---------------------------------------------------------------------------------------------**/

User Function SF1140I()

	Local nQtdItPed	:= 0
	Local lQtd 			:= .F.
	Local	lVlr 			:= .F.
	Local lPrazo 		:= .F.
	Local lTolerNeg := GetNewPar("MV_TOLENEG", .F.)
	Local lDescTol	:= SuperGetMv("MV_DESCTOL", .F., .F.)
	Local cEvento		:= ""
	Local cAux			:= ""
	Local cMsg			:= ""
	Local cDiverg		:= ""
	Local cMotBlq   := ""
	Local nTamD1Vun	:= TamSX3("D1_VUNIT")[2]
	Local aASD1 		:= SD1->(GetArea())
	Local aASC7 		:= SC7->(GetArea())


	//Verifica a operacao
	If (ParamIxb[1])

		U_VALIDENT(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)

		//Seta o evendo
		cEvento := "021"

	//Verifica a operação
	ElseIf (ParamIxb[2])

		//Seta o evendo
		cEvento := "022"

	EndIf

	//Verifica se está vazio
	If (!Empty(cEvento))

		//Grava o log
		U_KCOMF023(cEvento)

	EndIf

	//Verifica se a pre-nota está bloquada
	If (Alltrim(SF1->F1_STATUS) $ "B|C")

		//Bloqueio de pré nota
		cEvento := "420"

		
		//Inicia a query
		BeginSQL Alias "SD1TMP"
		
			SELECT		SD1.D1_ITEM, 
								SD1.D1_COD, 
								SD1.D1_QUANT,
								SD1.D1_VUNIT, 
								SD1.D1_PEDIDO, 
								SD1.D1_ITEMPC, 
								SD1.D1_FORNECE, 
								SD1.D1_LOJA, 
								SD1.D1_EMISSAO
			FROM 			%Table:SD1% SD1
			WHERE 		SD1.D1_FILIAL		=	%xFilial:SD1% 
			AND 			SD1.D1_DOC     	= %Exp:SF1->F1_DOC% 
			AND 			SD1.D1_SERIE   	= %Exp:SF1->F1_SERIE% 
			AND 			SD1.D1_FORNECE 	= %Exp:SF1->F1_FORNECE% 
			AND 			SD1.D1_LOJA    	= %Exp:SF1->F1_LOJA% 
			AND 			SD1.%NotDel%
		
		EndSQL

		//Acessa o inicio da query
		SD1TMP->(DbGoTop())
		
		//Looo nos dados
		While !SD1TMP->(Eof())

			//Limpa a variável
			cMotBlq := ""

			//Ordena a tabela de pedidos
			SC7->(DbSetOrder(14))
			
			//Posiciona no pedido de compras
			If SC7->(dbSeek(xFilEnt(xFilial("SC7"),"SC7")+Padr(SD1TMP->D1_PEDIDO,TamSX3("C7_NUM")[1])+PadR(SD1TMP->D1_ITEMPC,TamSX3("C7_ITEM")[1])))
	
				//Carrega o motivo do bloqueio por tolerancia de recebimento
				nQtdItPed := SC7->C7_QUANT-SC7->C7_QUJE
				lQtd 			:= (SD1TMP->D1_QUANT > nQtdItPed) .Or. (lTolerNeg .And. (SD1TMP->D1_QUANT < nQtdItPed))
				lVlr 			:= (SD1TMP->D1_VUNIT > xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,StoD(SD1TMP->D1_EMISSAO),nTamD1Vun,SC7->C7_TXMOEDA)) .Or. (lTolerNeg .And. (SD1TMP->D1_VUNIT < xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,SD1TMP->D1_EMISSAO,nTamD1Vun,SC7->C7_TXMOEDA)))
				lPrazo		:= (StoD(SD1TMP->D1_EMISSAO) > SC7->C7_DATPRF)

				//Limpa a variavel
				cDiverg		:= ""
				cAux			:= ""

				//Atualiza a divergencia
				If lQtd .And. lVlr
					
					//Trava o motivo do bloqueio
					cMotBlq := "03"

					//Atualiza
					cDiverg := "Qtde/Preço"
					cAux += "Item (NF/Pedido)..: " + SD1TMP->D1_ITEM + " / " + SC7->C7_ITEM + ENTER
					cAux += "Código Produto....: " + SD1TMP->D1_COD + ENTER
					cAux += "Qtde (NF/Pedido)..: " + Alltrim(Transform(SD1TMP->D1_QUANT, "@E 999,999,999.99")) + " / " + Alltrim(Transform(nQtdItPed, "@E 999,999,999.99")) + ENTER
					cAux += "Vlr. (NF/Pedido)..: " + Alltrim(Transform(SD1TMP->D1_VUNIT, "@E 999,999,999.9999")) + " / " + Alltrim(Transform(xMoeda(SC7->C7_PRECO, SC7->C7_MOEDA, 1, StoD(SD1TMP->D1_EMISSAO), nTamD1Vun, SC7->C7_TXMOEDA), "@E 999,999,999.9999")) + ENTER
		
				ElseIf lQtd

					//Trava o motivo do bloqueio
					cMotBlq := "01"
					
					//Atualiza
					cDiverg	:=	"Quantidade"
					cAux += "Item (NF/Pedido)..: " + SD1TMP->D1_ITEM + " / " + SC7->C7_ITEM + ENTER
					cAux += "Código Produto....: " + SD1TMP->D1_COD + ENTER
					cAux += "Qtde (NF/Pedido)..: " + Alltrim(Transform(SD1TMP->D1_QUANT, "@E 999,999,999.99")) + " / " + Alltrim(Transform(nQtdItPed, "@E 999,999,999.99")) + ENTER
											
				ElseIf lVlr .Or. (lDescTol .And. Round((SC7->C7_PRECO * SC7->C7_QUANT),2) > (SC7->C7_TOTAL - SC7->C7_VLDESC))
					
					//Trava o motivo do bloqueio
					cMotBlq := "02"

					//Atualiza
					cDiverg := "Preço"
					cAux += "Item (NF/Pedido)..: " + SD1TMP->D1_ITEM + " / " + SC7->C7_ITEM + ENTER
					cAux += "Código Produto....: " + SD1TMP->D1_COD + ENTER
					cAux += "Vlr. (NF/Pedido)..: " + Alltrim(Transform(SD1TMP->D1_VUNIT, "@E 999,999,999.9999")) + " / " + Alltrim(Transform(xMoeda(SC7->C7_PRECO, SC7->C7_MOEDA, 1, StoD(SD1TMP->D1_EMISSAO), TamSX3("D1_VUNIT")[2], SC7->C7_TXMOEDA), "@E 999,999,999.9999")) + ENTER
					
				Elseif !lPrazo
					
					//Atualiza	
					cDiverg	:= "Ok"
				
				EndIf

				//Verifica prazo
				If lPrazo

					//Com divergencia		
					If !Empty(cDiverg)
						
						//Separador
						cDiverg += "/"

						//Trava o motivo do bloqueio
						cMotBlq += "|"

					EndIf	
					
					//Prazo
					cDiverg += "Prz.Entr."

					//Trava o motivo do bloqueio
					cMotBlq += "04"

					//Verifica se já tem item
					If !("Item" $ cAux)

						//Atualiza o items
						cAux += "Item (NF/Pedido)..: " + SD1TMP->D1_ITEM + " / " + SC7->C7_ITEM + ENTER
						cAux += "Código Produto....: " + SD1TMP->D1_COD + ENTER

					EndIf

					cAux += "Entr (NF/Pedido)..: " + Dtoc(Stod(SD1TMP->D1_EMISSAO)) + " / " + Dtoc(SC7->C7_DATPRF) + ENTER 
					
				EndIf

			EndIf

			cAux := "Divergência.......: " + Upper(cDiverg) + ENTER + cAux + Repl("-", 45) + ENTER
			cMsg += cAux

			//Verifica se bloqueou
			If (!Empty(cMotBlq))

				//Grava o log
				U_KCOMF023(cEvento, cMotBlq)
			
			EndIf

			//Próximo registro
			SD1TMP->(DbSkip())
		
		EndDo

		//Fecha a query
		SD1TMP->(DbCloseArea())	

		//Veriica se tem mensagem
		If !EmptY(cMsg)

			//Informa 
			If MsgYesNo("A pré nota foi bloqueada e está aguardando liberação. Gostaria de visualizar os motivos do bloqueio?", "Pré Nota Bloqueada")

				//Visualiza tela de bloqueio
				If (GetNewPar("KON_TBLQNF", .F.))

					//Ordena a tabela
					SCR->(DbSetOrder(1))

					//Posiciona
					If SCR->(DbSeek(xFilial("SCR") + "NF" + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))

						//Visualiza
						//FWExecView ("Visualização de Bloqueio de NF", "MATA094")
						A94Visual(, 2)

					EndIf

				EndIf

				//Atualiza o log
				cMsg := "PRÉ NOTA FISCAL: " + SF1->F1_DOC + "/" + SF1->F1_SERIE + ENTER + ENTER + cMsg

				//Mensagem de log
				U_MsgLog(cMsg, "Bloqueio de Pré-Nota nº " + SF1->F1_DOC + "/" + SF1->F1_SERIE, 1, .F.)

			EndIf

		EndIf
		
		//Restaura a area
		RestArea(aASD1)
		RestArea(aASC7)

	EndIf

	//Inclusão
	If (ParamIxb[1])

		//Atualiza o statos
		U_KCOMF003(SF1->F1_DOC, SF1->F1_SERIE, 3)
		
	EndIf

Return Nil
