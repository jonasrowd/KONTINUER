/**---------------------------------------------------------------------------------------------------------------**/
/** CLIENTE     : Kontinuer     										  										  **/
/** SOLICITANTE	: Marcos Sulivan  		  					                                          			  **/
/** DATA 		: 02/03/2021	   																				  **/
/** MODULO		: Compras			                  	   							    						  **/
/** FINALIDADE	:                                                                    							  **/
/** RESPONSAVEL	:           																	  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**                                          DECLARACAO DAS BIBLIOTECAS                                           **/
/**---------------------------------------------------------------------------------------------------------------**/

#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "totvs.ch"
#Include "tbiconn.ch"
#Include "ap5mail.ch"

/**---------------------------------------------------------------------------------------------------------------**/
/**                                           DEFINICAO DE PALAVRAS 	  			 							  **/
/**---------------------------------------------------------------------------------------------------------------**/

#Define ENTER CHR(13)+CHR(10)

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: MT100TOK 													                                  **/
/** DESCRICAO: Validação na confirmação do documento de entrada                                                   **/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO / ALTERACOES / MANUTENCOES      **/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                   **/
/**---------------------------------------------------------------------------------------------------------------**/
/** 26/02/2021		| Alberto Percegona     |                        |   										  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  		PARAMETROS     	              		     						  **/
/**---------------------------------------------------------------------------------------------------------------**/
/** 														                              						  **/
/**---------------------------------------------------------------------------------------------------------------**/
User Function MT100TOK()
Local aArea			:=	GetArea()
Local lRet			:=	.T.
Private cNfO		:=	""


//COMENTADO EM 05/06/2022 - MIGRACAO PARA 33
/*
If (IsInCallStack("MATA920"))

    Return .T.

EndIf
*/

If ! VldOpFin(lRet)
    return .f.
EndIf

lRet := VALITENS()

//ENVIA EMAIL DE ATO CONCESSORIO
If lRet
    //ENVIA EMAIL DE ATO CONCESSORIO
    //EnvAto()

EndIf

//Verifica se validou
//COMENTADO EM 05/06/2022 - MIGRACAO PARA 33
/*
If (lRet)
    
    //Atualiza 
    lRet := StaticCall(PE_MT100LOK, VldAllEmp)

EndIf
*/

//Verifica se validou
If (lRet)
    
    //Valida operação x Usuario
    lRet := VldOpxUsr()

EndIf

U_VALIDENT(CNFISCAL, CSERIE, CA100FOR, CLOJA) // Adicionado por Jonas Machado - Samcorp

RestArea(aArea)

Return lRet

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: VldOpxUsr 													                                  **/
/** DESCRICAO: Valida operação x usuarios                                                                         **/
/**---------------------------------------------------------------------------------------------------------------**/
/**							           RIACAO / ALTERACOES / MANUTENCOES                                          **/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	    | Desenvolvedor          | Solicitacao         		| Descricao                               **/
/**---------------------------------------------------------------------------------------------------------------**/
/** 15/12/2021		| Velton Teixeira        | Marcos Sulivan           |   									  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  		PARAMETROS     	              		     						  **/
/**---------------------------------------------------------------------------------------------------------------**/
/** 														                              						  **/
/**---------------------------------------------------------------------------------------------------------------**/

Static Function VldOpxUsr()

  Local lRet        := .T.
  Local nPosOper    := Ascan(aHeader, {|x| Alltrim(X[2]) == "D1_OPER"})
  Local nX          := 0  

  For nX := 1 To Len(aCols)
    
    //Verifica se nao esta deletado
    If (!aCols[nX][Len(aCols[nX])] .AND. !Empty(aCols[nX][nPosOper]))
  
      //Ordena a tabela
      ZCO->(DbSetOrder(1))

      //Posiciona
      If ZCO->(DbSeek(xFilial("ZCO") + __cUserId + "E"))

        //Verifica se o usuário tem permissao para selecionar a operacao
        If !(Alltrim(aCols[nX][nPosOper]) $ ZCO->ZCO_OPER .OR. Alltrim(ZCO->ZCO_OPER) == "**")

          //Atualiza o retorno
          lRet := .F.

         //Mensagem  
          U_MSGLOG("Usuário sem permissao para utilizar a operação informada, as operações permitidas são: " + ENTER + ENTER + Alltrim(ZCO->ZCO_DET), "Valida Operação", 1, .F.)

          //Sai do Loop  
          Exit

        EndIf

      Else

        //Atualiza o retorno
        lRet := .F.

        //Mensagem
        U_MSGLOG("Usuário sem cadastro no controle de operações fiscais x usuários", "Valida Operação", 1, .F.)
        
        //Sai do loop
        Exit

      EndIf

    EndIf
 
  //Proximo
  Next nX


Return lRet


/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: MT100TOK 													                                  **/
/** DESCRICAO: Validação na confirmação do documento de entrada                                                   **/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO / ALTERACOES / MANUTENCOES      **/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                   **/
/**---------------------------------------------------------------------------------------------------------------**/
/** 26/02/2021		| Alberto Percegona     |                        |   										  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  		PARAMETROS     	              		     						  **/
/**---------------------------------------------------------------------------------------------------------------**/
/** 														                              						  **/
/**---------------------------------------------------------------------------------------------------------------**/

Static Function VldOpFin(lRet)
Local cMsg      := ""
Local cOpc      := ""
Local nX        := 0
Local nPosOp    := Ascan(aHeader, {|x| Alltrim(x[2]) == "D1_OP"})
Local aASC2     := SC2->(GetArea())
Local aLista    := {}

//Loop nos itens
For nX := 1 To Len(aCols)

    //Verifica se não está deletado
    If (!aCols[nX][Len(aCols[nX])] .AND. !Empty(aCols[nX][nPosOp]))

        If !(Alltrim(aCols[nX][nPosOp]) $ cOpc)

            //Adiciona o separador
            cOpc += If (!Empty(cOpc), "|", "")

            //Adiciona a Op
            cOpc += Alltrim(aCols[nX][nPosOp])

        EndIf

    EndIf

    //Próximo registro
Next nX

//Tem dados de Op
If (!Empty(cOpc))

    //Adiciona a lista
    aLista := StrToKarr(cOpc, "|")

    //Loop dos itens
    For nX := 1 To Len(aLista)

        //Ordena a tabela
        SC2->(DbSetOrder(1))

        //Posiciona na Ordem de produção
        If SC2->(DbSeek(xFilial("SC2") + aLista[nX]   ))

            //Verifica se está encerrada
            If (SC2->C2_TPOP == "F" .AND. !Empty(SC2->C2_DATRF) .AND. SC2->C2_QUJE >= SC2->C2_QUANT)

                //Atualiza o retorno
                lRet := .F.

                //Mensagem
                cMsg += aLista[nX] + ENTER

            EndIf

        EndIf

        //Próximo registro
    Next nX

EndIf

//Verifica a mensagem
If (!Empty(cMsg))

    //Incrementa a mensagem
    cMsg := "As Ordens de Produção abaixo encontram-se encerradas e não poderão ser apontadas no documento de entrada:" + cMsg

    //Mensagem
    MsgLog(cMsg, "Valida OP's informadas", 1, .F.)

EndIf

//Restaura a area
RestArea(aASC2)

Return lRet

/**---------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: MsgLog()												                    **/
/** DESCRICAO	  	: Tela de Exibição do log											        **/
/**---------------------------------------------------------------------------------------------**/
/**								CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES                       	   	**/	
/**---------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                      **/
/**---------------------------------------------------------------------------------------------**/
/** 23/09/2019 	| Marcos Sulivan         | 					   |								**/
/**---------------------------------------------------------------------------------------------**/
/**	   						PARAMETROS     	 				             		      			**/	
/**---------------------------------------------------------------------------------------------**/
/** 						Nenhum parametro esperado para essa rotina                 	    	**/
/**---------------------------------------------------------------------------------------------**/

Static Function MsgLog(cMsg, cTitulo, nTipo, lEdit)

    Local lRetMens	 	:= .F.
    Local oBtnOk			:= ""
    Local cTxtConf 		:= ""
    Local oBtnCnc			:= ""
    Local cTxtCancel 		:= ""
    //ocal nIni			:= 1
    //Local nFim			:= 50
    Local oBtnSlv			:= Nil
    Local oDlgMens 		:= Nil
    Local oMsg			:= Nil
    Local oFntTxt 		:= TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
    Default cMsg    		:= "..."
    Default cTitulo 		:= "zMsgLog"
    Default nTipo   		:= 1 // 1=Ok; 2= Confirmar e Cancelar
    Default lEdit   		:= .F.

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

/**---------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: fSalvArq()											                        **/
/** DESCRICAO	  	: Salva o arquivo	 	 					                			    **/
/**---------------------------------------------------------------------------------------------**/
/**								CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES                       	   	**/	
/**---------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                      **/
/**---------------------------------------------------------------------------------------------**/
/** 23/09/2019 	| Marcos Sulivan         | 					   |								**/
/**---------------------------------------------------------------------------------------------**/
/**	   						PARAMETROS     	 				             		      			**/	
/**---------------------------------------------------------------------------------------------**/
/** 						Nenhum parametro esperado para essa rotina                 	    	**/
/**---------------------------------------------------------------------------------------------**/

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

/**---------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO:  EnvAto											                        **/
/** DESCRICAO	  	: envia email quando pedido tem ato concessorio iinformado	                			    **/
/**---------------------------------------------------------------------------------------------**/
/**								CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES                       	   	**/	
/**---------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                      **/
/**---------------------------------------------------------------------------------------------**/
/** 30/04/2021 	| Marcos Sulivan         | 					   |								**/
/**---------------------------------------------------------------------------------------------**/
/**	   						PARAMETROS     	 				             		      			**/	
/**---------------------------------------------------------------------------------------------**/
/** 						Nenhum parametro esperado para essa rotina                 	    	              **/
/**---------------------------------------------------------------------------------------------**/

Static Function EnvAto()

    Local aArea			:=	GetArea()

    QSC7AT(SF1->F1_DOC,SF1->F1_SERIE)

    QSC7AT->(DbGoTop())

    If  !(EMPTY(QSC7AT->ATO))

        //U_KCOMF009(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)

    EndIf

    QSC7AT->(DbCloseArea())

    RestArea(aArea)

RETURN nil

/**********************************************************************************************************************************/
/** Static Function QSC7AT			                                                                                                 **/
/** Consulta pedido ato concessorio														. 															                                                             **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição -                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/

Static Function QSC7AT(cDoc,cSerie)

    //Grava area
    Local aArea := GetArea()

    //Query
    Local cQry  := ""

    cQry += "		SELECT
    //	SD1.D1_DOC		NF
    //,	SD1.D1_SERIE	SERIE
    //,	SD1.D1_PEDIDO	PEDIDO
    //,	SD1.D1_ITEMPC	ITEMPC
    //,	SD1.D1_COD		PRODUTO
    cQry += "		SC7.C7_KATOCON	ATO

    cQry += "		FROM		" + RetSqlName("SD1") + " SD1

    cQry += "		LEFT JOIN	SC7010 SC7
    cQry += "		ON	SC7.C7_NUM		=	SD1.D1_PEDIDO
    cQry += "		AND	SC7.C7_ITEM		=	SD1.D1_ITEMPC
    cQry += "		AND SC7.C7_FORNECE	=	SD1.D1_FORNECE

    cQry += "		WHERE	SD1.D_E_L_E_T_	=	''

    cQry += "		AND SD1.D1_DOC		=	'" + cDoc + "'
    cQry += "		AND SD1.D1_SERIE	=	'" + cSerie + "'
    cQry += "		GROUP BY SC7.C7_KATOCON


    //Executa query
    TcQuery cQry New Alias "QSC7AT"

    //Restaura area
    RestArea(aArea)

return

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: MT100TOK 													                                  **/
/** DESCRICAO: Validação na confirmação do documento de entrada                                                   **/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO / ALTERACOES / MANUTENCOES      **/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                   **/
/**---------------------------------------------------------------------------------------------------------------**/
/** 26/02/2021		| Alberto Percegona     |                        |   										  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  		PARAMETROS     	              		     						  **/
/**---------------------------------------------------------------------------------------------------------------**/
/** 														                              						  **/
/**---------------------------------------------------------------------------------------------------------------**/

Static Function VALITENS()

    Local aArea		:=	GetArea()
    Local aASB2     := SB2->(GetArea())
    Local _TesSF4   := ""
    Local _MovSB1   := ""
    Local lRet      := .T.        
    Local _D1Cod    := Space(15)   
    Local _D1TES    := Space(3)    
    Local _F4RET    := Space(1)    
    Local _D1TRT    := Space(3)    
    Local _D1QTD    := 0    
    Local cCodOp	:= Space(11)
    Local cNfOri	:= Space(09)
    Local cSrOri	:= Space(03)
    Local cDesprd	:= Space(2)
    Local cItOri    := Space(2)
    Local cItemNf   := Space(2)
    Local nX        := 1
    Local cTesSai   := ""

    //Local cMsg      := ""
    //Local cOpc      := ""
    //Local aLista    := {}

    //Loop nos itens
    For nX := 1 To Len(aCols)

        //Verifica se não está deletado
        If (!aCols[nX][Len(aCols[nX])])

            //POSICAO
            nCol := Ascan( AHeader,{ |X| UPPER( AllTrim(X[2]) )=='D1_COD' } ) 
            _D1Cod := aCols[nX,nCol] // Le Numero do Pedido 

            nCol := Ascan( AHeader,{ |X| UPPER( AllTrim(X[2]) )=='D1_OP' } ) 
            cCodOp := aCols[nX,nCol] // Le Numero da OP
                                                   
            nCol := Ascan( AHeader,{ |X| UPPER( AllTrim(X[2]) )=='D1_TES' } ) 
            _D1TES := aCols[nX,nCol]      // Le TES 
            
            nCol := Ascan( AHeader,{ |X| UPPER( AllTrim(X[2]) )=='D1_TRT' } )             
            _D1TRT := aCols[nX,nCol]      // TRT
            
            nCol := Ascan( AHeader,{ |X| UPPER( AllTrim(X[2]) )=='D1_QUANT' } )          
            _D1QTD := aCols[nX,nCol]      // quantidade
            
            nCol 	:= Ascan( AHeader,{ |X| UPPER( AllTrim(X[2]) )=='D1_KDESPRD' } ) 
            cDesprd := aCols[nX,nCol]      // DESTINO PRODUTO

            nCol 	:= Ascan( AHeader,{ |X| UPPER( AllTrim(X[2]) )=='D1_NFORI' } ) 
            cNfOri := aCols[nX,nCol]      // NOTA FISCAL DE ORIGEM 

            nCol 	:= Ascan( AHeader,{ |X| UPPER( AllTrim(X[2]) )=='D1_ITEMORI' } ) 
            cItOri := aCols[nX,nCol]      // NOTA FISCAL DE ORIGEM 

            nCol 	:= Ascan( AHeader,{ |X| UPPER( AllTrim(X[2]) )=='D1_SERIORI' } ) 
            cSrOri := aCols[nX,nCol]      // SERIE NOTA FISCAL DE ORIGEM 

            nCol 	:= Ascan( AHeader,{ |X| UPPER( AllTrim(X[2]) )=='D1_ITEM' } ) 
            cItemNf := aCols[nX,nCol]      // SERIE NOTA FISCAL DE ORIGEM


            _TesSF4 := Posicione('SF4',1,xFilial('SF4')+_D1TES,'F4_ESTOQUE')    //S=SIM OU N=NAO
            _MovSB1 := Posicione('SB1',1,xFilial('SB1')+_D1Cod,'B1_XESTOQU')    //S=SIM OU N=NAO 
            _F4RET  := Posicione('SF4',1,xFilial('SF4')+_D1TES,'F4_PODER3')     //S=SIM OU N=NAO

            //VALIDAR O TIPO DA ENTRADA
            If(CTIPO = 'N')

                If(_F4RET == 'N'.AND. AllTrim(cNfOri) == "")


                        If (_TesSF4 == "S" .and. _MovSB1 == "N")	  
                                    
                            MSGSTOP("Divergencia no controle do estoque. Corrija a TES e/ou Produto." + "Item " + cItemNf, "Verifique") 
                            lRet := .F.
                                    
                        ElseIf 	(SubStr(_D1Cod,1,4) == "1710")  .OR. ( SubStr(_D1Cod,1,4) == "1701")                                                  

                            MSGSTOP("Não permitida a compra do tipo do produto " + "Item " + cItemNf, "Verifique") 
                            lRet := .F. 
                                
                        //PRODUTOS COM 4020 OBRIGATORIAMENTE DEM TER OP.		
                        ElseIf (SubStr(_D1Cod,1,4) == "4020")
                                    
                            If(	alltrim(cCodOp) == ""  .OR.	alltrim(_D1TRT) == ""  )

                                MSGSTOP("Ordem de Produção não informada ou TRT" + "Item " + cItemNf, "Verifique")
                                lRet := .F.
                                    
                            EndIf

                        ElseIf (SubStr(_D1Cod,1,4) == "1703" .OR. SubStr(_D1Cod,1,4) == "1704")
                            
                            //ATIVIDADE INTERNA DEVERA TER OP, CASO CONTRÁRIO A OP SERA ZERADA.
                            If(cDesprd $ "AI|IN|PI")
                                
                                If(	alltrim(cCodOp) == ""  .OR.	alltrim(_D1TRT) == ""  )

                                    MSGSTOP("Ordem de Produção não informada ou TRT" + "Item " + cItemNf, "Verifique")
                                    lRet := .F.

                                EndIf 

                            ElseIf(cDesprd $ "AE|XS|PX")   

                                If(	!(alltrim(cCodOp) == "")  .OR.	!(alltrim(_D1TRT) == "")  )

                                    MSGSTOP("Ordem de Produção não Permitida ou TRT" + " Item " + cItemNf, "Verifique")
                                    lRet := .F.

                                EndIf 


                            EndIf

                        Endif

                ElseIf(_F4RET == 'D' .AND. !(AllTrim(cNfOri) == "") ) 

                    //FUNCAO PARA VALIDAR SE TES DA NOTA DE SAIDA MOVIMENTOU ESTOQUE, E SER UTILIZADA NA VALIDAÇÃO DE ENTRADA.
                    QD2F4E(cNfOri,cSrOri,_D1Cod,cItOri)
                                
                    //Inicio da query
                    QD2F4E->(DbGoTop())

                    cTesSai	:=	QD2F4E->F4_ESTOQUE

                    //Fecha query
                    QD2F4E->(DbCloseArea())	

                    If!( cTesSai  ==  _TesSF4 )

                        MSGSTOP("Divergencia no controle do estoque. Corrija a TES e/ou Produto." + "Item " + cItemNf, "Verifique")
                        lRet := .F.
                                       
                    EndIf

                EndIf 

            ElseIf (CTIPO = 'C')

                SB2->(DbSetOrder(1))

                //Posiciona na Ordem de produção
                If SB2->(DbSeek(xFilial("SB2") + _D1Cod)) .AND. !Empty(cCodOp)

                    //Verifica se está encerrada
                    If (SB2->B2_QATU <= 0 )

                        //Atualiza o retorno
                        MSGSTOP("Produto Sem saldo, lançe como despesa." + "Item " + cItemNf, "Verifique")
                        lRet := .F.

                    
                    EndIf

                EndIf

            EndIf

        Endif 

    Next nX

RestArea(aArea)	
RestArea(aASB2)

Return lRet


/**********************************************************************************************************************************/
/** Static Function QD2F4E	                                                                                                 **/
/** Consulta de nota fiscal retornando se a TES movimenta estoque ou não														. 															                                                             **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição -                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/

Static Function QD2F4E(cDocOri,cSerOri,cProdOri,cItOr)

//Grava area
Local aArea := GetArea()

//Query
Local cQry  := ""

cQry += "		 		 SELECT SF4.F4_ESTOQUE

cQry += "		 		 FROM 	"+ RetSqlName("SD2") +"	SD2

cQry += "		 		 LEFT JOIN		"+ RetSqlName("SF4") +"	SF4
cQry += "		 		 ON	SF4.F4_CODIGO	=	SD2.D2_TES
cQry += "		 		 AND SF4.D_E_L_E_T_ = ''

cQry += "		 		 WHERE	SD2.D_E_L_E_T_ = ''
cQry += "		 		 AND		SF4.D_E_L_E_T_ = ''
cQry += "		 		 AND		SD2.D2_DOC		=	'"+ cDocOri +"'
cQry += "		 		 AND		SD2.D2_SERIE	=	'"+ cSerOri +"'
cQry += "		 		 AND		SD2.D2_COD		=	'"+ cProdOri +"'
cQry += "		 		 AND		SD2.D2_ITEM		=	'"+ cItOr +"'


//Executa query
TcQuery cQry New Alias "QD2F4E"

//Restaura area
RestArea(aArea)
	
return
