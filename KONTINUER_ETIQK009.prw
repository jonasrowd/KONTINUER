#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} ETIQK009
	Fonte responsável pela impressão de etiquetas com base nos itens do documento de entrada.
	@type Function
	@version 12.1.33
	@author Jonas Machado
	@since 10/06/2022
	@param _cDoc, character, parâmetro que identifica o documento de entrada.
	@param _cSerie, character, parâmetro que identifica a série do documento de entrada.
	@param _cForn, character, parâmetro que identifica o fornecedor do documento de entrada. 	
	@param _cLoja, character, parâmetro que identifica a loja do documento de entrada.
	@param _cPed, character, parâmetro que identifica o pedido do documento de entrada.
/*/
User Function ETIQK009(_cDoc,_cSerie,_cForn,_cLoja,_cPed)

	Local	aArea		:=	GetArea()
	Local	cPedido		:=	_cPed
	Local	aItQtd		:= {'1-Quant. Inf','2-Quant. Orig','3-Quant. Peças'}
	Local	aItEA		:= {'S-Sim','N-Não'}
	Private	cForn		:=	POSICIONE("SA2",1,XFILIAL("SA2")+_cForn+_cLoja,"A2_NOME")
	Private	CdFor		:=	_cForn
	Private	cLoja		:=	_cLoja
	Private	nTp			:=	0
	Private	nQtd		:=	1
	Private	cProd		:=	Space(15)
	Private	aPedidos	:=	{}
	Private	oPedidos	:= 	Nil
	Private	oQuantd		:=	Nil
	Private cPorta  	:= "LPT1"
	Static oDlg

	DEFINE DIALOG oDlg	TITLE "Impressão de Etiqueta"	FROM 000,000 TO 400,800 PIXEL

	@ 003, 005 SAY oSay1 PROMPT "Pedido" 		SIZE 025, 007 OF oDlg PIXEL
	@ 013, 005 SAY oSayA PROMPT cPedido 		SIZE 036, 010 OF oDlg PIXEL

	@ 003, 030 SAY oSay2 PROMPT "Código / Loja" 		SIZE 060, 007 OF oDlg PIXEL
	@ 013, 030 SAY oSayB PROMPT CdFor + " / " + cLoja 	SIZE 061, 018 OF oDlg PIXEL

	@ 003, 080 SAY oSay3 PROMPT "Documento / Série" 	SIZE 060, 007 OF oDlg PIXEL
	@ 013, 080 SAY oSayC PROMPT CdFor + " / " + cLoja 	SIZE 061, 018 OF oDlg PIXEL

	@ 003, 200 SAY oSay4 PROMPT "Fornecedor" 	SIZE 035, 007 OF oDlg PIXEL
	@ 013, 200 SAY oSayD PROMPT cForn			SIZE 200, 010 OF oDlg PIXEL

	@ 030, 005 SAY oSay4 PROMPT "Quant. Impressao" 		SIZE 040, 007 OF oDlg PIXEL
	@ 037, 005 MSGET oQuantd VAR nQtd 		SIZE 036, 010 OF oDlg PIXEL Picture "@E 999"

	// Usando Create3
	@ 030, 070 SAY oSay5 PROMPT "Tipo Quantidade" 		SIZE 040, 007 OF oDlg PIXEL
	cCombo1	:= 	aItQtd[1]
	oCombo1 :=  TComboBox():Create(oDlg,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},037,070,aItQtd,050,018,,{||},,,,.T.,,,,,,,,,'cCombo1')

	// Usando Create
	@ 030, 132 SAY oSay5 PROMPT "Em Aberto" 		SIZE 040, 007 OF oDlg PIXEL
	cCombo2	:= 	aItEA[2]
	oCombo2 :=  TComboBox():Create(oDlg,{|u|if(PCount()>0,cCombo2:=u,cCombo2)},037,132,aItEA,040,018,,{||},,,,.T.,,,,,,,,,'cCombo2')

	@ 060, 005 SAY oSay1 PROMPT "Impressora" 		SIZE 060, 007 OF oDlg PIXEL
	@ 067, 005 MsComboBox oPorta Var cPorta Items {"LPT1", "LPT2"} Size 055, 007 Of oDlg PIXEL

	//@ 031, 112 MSGET oCidade VAR cCidade SIZE 110, 010 OF oDlg PIXEL
	@ 031, 325 BUTTON oButton1 PROMPT "Filtrar" SIZE 037, 012 OF oDlg ACTION Processa({|| FilC7(cPedido,cProd,_cDoc,_cSerie,_cForn,_cLoja)},"Aguarde...") PIXEL

	@ 181, 325 BUTTON oButton1 PROMPT "Imprimir" SIZE 037, 012 OF oDlg ACTION Processa({|| U_ETIQK008(aPedidos)},"Aguarde...") PIXEL
	@ 181, 247 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL

	ACTIVATE DIALOG oDlg CENTERED

	RestArea(aArea)

Return

/**********************************************************************************************************************************/
/*CONSULTA A PEDIDO DE COMPRA OU NOTA FISCAL
/**********************************************************************************************************************************/
Static Function QryC7(cNumPed,cProd,_cDoc,_cSerie,_cForn,_cLoja)
	
	Local aArea := GetArea()
	
	//Query
	Local cQry  := ""    

	
	If(Alltrim(cProd) == '') //PESQUISA POR PEDIDO
		
			cQry += "		SELECT	
			cQry += "		SC7.C7_PRODUTO	PRODUTO
			cQry += "	,	SC7.C7_DESCRI	DESCRICAO
			cQry += "	,	SC7.C7_QUANT	QTDE
			cQry += "	,	SD1.D1_QUANT	QTDED1
			cQry += "	,	SC7.C7_XPRODES	DESENHO
			cQry += "	,	SC7.C7_OP		OP                
			cQry += "	,	SC7.C7_NUMSC	NUMSC
			cQry += "	, 	SC7.C7_ITEMSC	ITEMSC
			cQry += "	,	SD1.D1_DOC		NF
			cQry += "	,	SD1.D1_SERIE	SERIE
			cQry += "	,	SC7.C7_NUM		PEDIDO
			cQry += "	,	SA2.A2_NOME		FORNECEDOR
			cQry += "	,	SA2.A2_COD		CODFOR
			cQry += "	,	SA2.A2_LOJA		LOJAFOR     
			cQry += "	,	SC7.C7_ITEM		ITEMPC   
			cQry += "	,	SC7.C7_LOCAL	LOCALL
			cQry += "	,	SB1.B1_TIPO		TIPO
			cQry += "	,	SB1.B1_UM		UMEDIDA	
			cQry += "	, 	SC7.C7_XPRODOP	PRODOP 
			cQry += "	,  	SC7.C7_XDPROD	DPROD
			cQry += "	, 	SC7.C7_XTRT		XTRT
			cQry += "	,   SB1.B1_DESC		DESCP
			cQry += "	, 	SC7.C7_KDESPRD 	KDESPRD
			cQry += "	, 	SC7.C7_XQTD2 	C7_XQTD2

			//-------- INCLUI DADOS DO PRODUTO PAI NA ETIQUETA
			cQry += "	,(
			cQry += "	SELECT   TOP 1 SD4A.D4_OP 
			cQry += "	FROM	"+ RetSqlName("SD4") +"		SD4A
			cQry += "	WHERE	SD4A.D_E_L_E_T_ = ''
			cQry += "	AND		SD4A.D4_COD = SC7.C7_XPRODOP
			cQry += "	AND		SUBSTRING(SD4A.D4_OP,1,8) =	SUBSTRING(SC7.C7_OP,1,8)
			cQry += "	)	OP_PAI

			cQry += "	,(
			cQry += "	SELECT  TOP 1 SD4B.D4_TRT

			cQry += "	FROM	"+ RetSqlName("SD4") +"		SD4B
			cQry += "	WHERE	SD4B.D_E_L_E_T_ = ''
			cQry += "	AND		SD4B.D4_COD = SC7.C7_XPRODOP
			cQry += "	AND		SUBSTRING(SD4B.D4_OP,1,8) =	SUBSTRING(SC7.C7_OP,1,8)

			cQry += "	)	TRT_PAI

			cQry += "	,(
			cQry += "	SELECT  COUNT(1)	
			cQry += "	FROM	"+ RetSqlName("SD4") +"		SD4C
			cQry += "	WHERE	SD4C.D_E_L_E_T_ = ''
			cQry += "	AND		SD4C.D4_COD = SC7.C7_XPRODOP
			cQry += "	AND		SUBSTRING(SD4C.D4_OP,1,8) =	SUBSTRING(SC7.C7_OP,1,8)
			cQry += "	)CONT_PAI
		//-----
			cQry += "	FROM	"+ RetSqlName("SC7") +"	SC7
		
			cQry += "	INNER JOIN	"+ RetSqlName("SD1") +"	SD1
			cQry += "	ON	SD1.D1_PEDIDO = SC7.C7_NUM 
			cQry += "	AND SD1.D1_ITEMPC = SC7.C7_ITEM  
			cQry += "	AND SD1.D_E_L_E_T_ = ''      
			
			
			cQry += "	LEFT JOIN	"+ RetSqlName("SA2") +"	SA2
			cQry += "	ON	SA2.A2_COD = SC7.C7_FORNECE
			cQry += "	AND	SA2.A2_LOJA	= SC7.C7_LOJA
			cQry += "	AND SA2.D_E_L_E_T_ = ''
			
			cQry += "	LEFT JOIN	"+ RetSqlName("SB1") +"	SB1
			cQry += "	ON	SB1.B1_COD	=	SC7.C7_PRODUTO
			cQry += "	AND SB1.D_E_L_E_T_	=	''
			

		
			cQry += "	WHERE	SC7.D_E_L_E_T_	= ''
			
			if SubStr(cCombo2,1,1) == "S"
			
				cQry += "	AND   (SC7.C7_QUANT - SC7.C7_QUJE) > 0
			
			EndIf
			// Adicionado por Jonas Machado - Samcorp
			If (cNumPed <> "")
				cQry += "	AND	SC7.C7_NUM   =  '"+ cNumPed +"' 
				cQry += "	AND	SD1.D1_DOC   =  '"+ _cDoc +"'
				cQry += "	AND	SD1.D1_SERIE   =  '"+ _cSerie +"'
				cQry += "	AND	SD1.D1_FORNECE   =  '"+ _cForn +"'
				cQry += "	AND	SD1.D1_LOJA   =  '"+ _cLoja +"' 
			EndIf  
			cQry += "	ORDER BY 1
	Else	//FILTRO POR PRODUTO
	
			cQry += "	SELECT		SB1.B1_COD		PRODUTO
			cQry += "	,			SB1.B1_DESC		DESCRICAO
			cQry += "	,			SB1.B1_UM		UMEDIDA
			cQry += "	,			SB1.B1_LOCPAD	ARMAZEM
			cQry += "	,			SB1.B1_TIPO		TIPO
			cQry += "	,			SB1.B1_XDES		DESENHO
					

		
			cQry += "	FROM	"+ RetSqlName("SB1") +"	SB1
		
			cQry += "	WHERE	SB1.D_E_L_E_T_ = ''
			cQry += "	AND SB1.B1_COD =  '"+ cProd +"'   
			cQry += "	ORDER BY 1
			
			
	EndIf
			
	TcQuery cQry New Alias "QSC7"
	
	RestArea(aArea)
	
return


//******************************

//******************************

Static Function FilC7(cPed,cProd,_cDoc,_cSerie,_cForn,_cLoja)    

	Local aArea 		:= GetArea()
	Local nLinhas 	:= 0
	
	QryC7(cPed,cProd,_cDoc,_cSerie,_cForn,_cLoja) // Adicionado por Jonas Machado - Samcorp
	
	QSC7->(dbGoTop())
	
	nLinhas:=QSC7->(RecCount())

	ProcRegua(nLinhas)
	
		
	cForn		:=	QSC7->FORNECEDOR
	CdFor		:=	QSC7->CODFOR
	cLoja		:=	QSC7->LOJAFOR
 
	aPedidos:={}
	
	While QSC7->(!Eof())

		If(Alltrim(cProd) =='')  
		
				If SubStr(cCombo1,1,1) == "1"

						nQtd	:=  QSC7->QTDED1 // Adicionado por Jonas Machado - Samcorp
				
				ElseIf SubStr(cCombo1,1,1) == "2"
				
						nQtd	:=	QSC7->QTDE	
						
				ElseIf SubStr(cCombo1,1,1) == "3"
				
						nQtd	:=	QSC7->C7_XQTD2	
				
				EndIf  
		
							 	 	
				aadd(aPedidos,{						QSC7->PRODUTO,;		
													QSC7->DESCRICAO,;    
													nQtd			,;     
													QSC7->QTDE		,;
													QSC7->DESENHO	,;
													QSC7->OP		,;
													QSC7->NUMSC		,;
													QSC7->ITEMSC	,;
													QSC7->NF		,;
													QSC7->SERIE		,;
													QSC7->PEDIDO	,;
													QSC7->FORNECEDOR,;
													QSC7->CODFOR	,;
													QSC7->ITEMPC	,;
													QSC7->LOCALL	,;
													QSC7->TIPO		,;
													QSC7->UMEDIDA	,;
													QSC7->LOJAFOR	,;
													QSC7->PRODOP	,;
													QSC7->DPROD		,;
													QSC7->XTRT		,;
													QSC7->KDESPRD 	,;
													QSC7->OP_PAI 	,;
													QSC7->TRT_PAI 	,;
													QSC7->CONT_PAI ;
									})
		
									
									oPedidos := TCBrowse():New(067, 005,400, 080,,,,oDlg   ,,,,,{|| lEditCell(aPedidos,oPedidos,"@E 999,999,999.99",3) },,,,,,,.F.,,.T.,,.F.,,,)		
									oPedidos:AddColumn(TCColumn():New("Produto"  				, {|| aPedidos[oPedidos:nAt,01]},"@!"				,,,"LEFT"	, 030,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Descrição"  			, {|| aPedidos[oPedidos:nAt,02]},"@!"				,,,"LEFT"	, 160,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Qtde. Imprimir"  , {|| aPedidos[oPedidos:nAt,03]},"@E 999,999,999.99",,,"RIGHT"	, 050,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Qtde."  					, {|| aPedidos[oPedidos:nAt,04]},"@E 999,999,999.99",,,"RIGHT"	, 050,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Armazem"  				, {|| aPedidos[oPedidos:nAt,15]},"@!"				,,,"RIGHT"	, 050,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Un. Medida" 			, {|| aPedidos[oPedidos:nAt,17]},"@!"				,,,"LEFT"	, 060,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Tipo"  					, {|| aPedidos[oPedidos:nAt,16]},"@!"				,,,"LEFT"	, 060,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Desenho"  				, {|| aPedidos[oPedidos:nAt,05]},"@!"				,,,"LEFT"	, 060,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("OP"  						, {|| aPedidos[oPedidos:nAt,06]},"@!"				,,,"LEFT"	, 060,.F.,.F.,,{|| .F. },,.F., ) )				 

									oPedidos:AddColumn(TCColumn():New("PRODOP"  				, {|| aPedidos[oPedidos:nAt,19]},"@!"				,,,"LEFT"	, 060,.F.,.F.,,{|| .F. },,.F., ) )				 
									oPedidos:AddColumn(TCColumn():New("DPROD"						, {|| aPedidos[oPedidos:nAt,20]},"@!"				,,,"LEFT"	, 060,.F.,.F.,,{|| .F. },,.F., ) )				 

						
		Else    

				aadd(aPedidos,{		QSC7->PRODUTO	,; 		
									QSC7->DESCP	,;      
									0				,;       
									QSC7->UMEDIDA	,; 
									QSC7->ARMAZEM	,; 
									QSC7->TIPO		,; 
									QSC7->DESENHO	;
									})
									
									oPedidos := TCBrowse():New(067, 005,400, 080,,,,oDlg   ,,,,,{|| lEditCell(aPedidos,oPedidos,"@E 999,999,999.99",3) },,,,,,,.F.,,.T.,,.F.,,,)		
									oPedidos:AddColumn(TCColumn():New("Produto"  				, {|| aPedidos[oPedidos:nAt,01]},"@!"								,,,"LEFT"	, 030,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Descrição"  			, {|| aPedidos[oPedidos:nAt,02]},"@!"								,,,"LEFT"		, 160,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Qtde. Imprimir"  , {|| aPedidos[oPedidos:nAt,03]},"@E 999,999,999.99",,,"RIGHT"	, 050,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Armazem"  				, {|| aPedidos[oPedidos:nAt,05]},"@!"								,,,"RIGHT"	, 050,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Unidade"					, {|| aPedidos[oPedidos:nAt,04]},"@!"								,,,"LEFT"	, 060,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Tipo"  					, {|| aPedidos[oPedidos:nAt,06]},"@!"								,,,"LEFT"	, 060,.F.,.F.,,{|| .F. },,.F., ) )
									oPedidos:AddColumn(TCColumn():New("Desenho"  				, {|| aPedidos[oPedidos:nAt,07]},"@!"				,,,"LEFT"	, 060,.F.,.F.,,{|| .F. },,.F., ) )
									
									oPedidos:AddColumn(TCColumn():New("PRODOP"  				, {|| aPedidos[oPedidos:nAt,19]},"@!"				,,,"LEFT"	, 060,.F.,.F.,,{|| .F. },,.F., ) )				 
									oPedidos:AddColumn(TCColumn():New("DPROD"						, {|| aPedidos[oPedidos:nAt,20]},"@!"				,,,"LEFT"	, 060,.F.,.F.,,{|| .F. },,.F., ) )				 

		EndIf
					
	QSC7->(DbSkip())

	EndDo		
	
	oPedidos:SetArray(aPedidos)  //Define um array para o browse					
	oPedidos:bWhen := { || Len(aPedidos) > 0 } //Se o array estiver vazio, o browse fica desabilitado
	oPedidos:Refresh()		
  
  QSC7->(dbCloseArea())	
  nQtd :=	1
  
	//Restaura area
	RestArea(aArea)
Return


/**********************************************************************************************************************************/
/**********************************************************************************************************************************/
user function ETIQK008(aPedidos)
	
  local cTextoZpl  	:= ""  
  Local nLastKey	:= 0  
  Local x,i			:=	1
  Private cProg   	:= "ETIQK002"       
  Private lCmp    	:= .T. 
  Private cTit    	:= "Etiqueta Recebimento"   
  Private cTam    	:= "M"                     
  Private nTipo   	:= 18 
  Private cRel    	:= ""	
  Private cString 	:= "" 						
  Private nLin    	:= 001    
  Private aReturn := { "Zebrado", 1, "Administracao", 1, 3, cPorta, , 1 }           
  //Private aReturn 	:= { "Zebrado", 1, "Administracao", 2, 2, cPorta, , 1 }
  Private m_pag   	:= 1

  //cRel := SetPrint(nil,  cProg, nil, @cTit	,nil, nil, nil, .T., nil, .F.	,nil	,nil	, nil)    
  cRel := SetPrint(nil,  cProg, nil, cTit	,nil, nil, nil, .T., nil, lCmp		,cTam	,nil	, .T., nil, 'EPSON.DRV', .T., .F., cPorta) 
  
    //Verifica se o usuário cancelou
  If (nLastKey == 27)
	  Return nil
  EndIf

  //Chama a impressao 
  SetDefault(aReturn, nil)
     
  //Verifica se o usuário cancelou
  If (nLastKey == 27)
	  Return nil
  EndIf      
  
  nTipo := Iif(aReturn[4] == 1, 15, 18) 

  For i := 1 to len(aPedidos)

	If(aPedidos[i][3] > 0)  
  
  		For	x := 1	to aPedidos[i][3]

				nLin := MlCount(cTextoZpl) 
				If(Alltrim(cProd) =='')
				
					cTextoZpl := Memoread("\etiqueta\ETIQUETA_RECEBIMENTO.prn")
				
					If(Alltrim(aPedidos[i][16]) == 'SV' )
				
						cTextoZpl := StrTran(cTextoZpl, ".PROD.", Alltrim(aPedidos[i][19]) )
						cTextoZpl := StrTran(cTextoZpl, ".DESC1.", SubStr( Alltrim(aPedidos[i][20]),1,30) ) 
						cTextoZpl := StrTran(cTextoZpl, ".DESC2.", SubStr( Alltrim(aPedidos[i][20]),31,60) )      
							
					Else
				             
						cTextoZpl := StrTran(cTextoZpl, ".PROD.", Alltrim(aPedidos[i][01]) )
						cTextoZpl := StrTran(cTextoZpl, ".DESC1.", SubStr( Alltrim(aPedidos[i][02]),1,30) ) 
						cTextoZpl := StrTran(cTextoZpl, ".DESC2.", SubStr( Alltrim(aPedidos[i][02]),31,60) ) 
				
					EndIf
				
					//cTextoZpl := StrTran(cTextoZpl, ".OPT."	, Alltrim(aPedidos[i][06]) ) 
					If	SUBSTRING(Alltrim(aPedidos[i][01]),1,4) == '4020'  .AND. aPedidos[i][25] <= 1

						//cTextoZpl := StrTran(cTextoZpl, ".OP."	, Alltrim(aPedidos[i][23]) + Alltrim(aPedidos[i][24]) ) 
						cTextoZpl := StrTran(cTextoZpl, ".OP."	, Alltrim(aPedidos[i][23]) + Alltrim(aPedidos[i][24]) ) 
						cTextoZpl := StrTran(cTextoZpl, ".OPT."	, Alltrim(aPedidos[i][23])  )   
						cTextoZpl := StrTran(cTextoZpl, ".TRT."	, Alltrim(aPedidos[i][24]) ) 

					ElseIf	aPedidos[i][25] > 1
						
						cTextoZpl := StrTran(cTextoZpl, ".OP."	, SUBSTRING(Alltrim(aPedidos[i][23]),1,6)  ) 
						cTextoZpl := StrTran(cTextoZpl, ".OPT."	, SUBSTRING(Alltrim(aPedidos[i][23]),1,6)  )   
						cTextoZpl := StrTran(cTextoZpl, ".TRT."	, '***' ) 

					else
						
						cTextoZpl := StrTran(cTextoZpl, ".OPT."	, Alltrim(aPedidos[i][06]) + Alltrim(aPedidos[i][21]) )

					EndIf

					cTextoZpl := StrTran(cTextoZpl, ".SC."	, Alltrim(aPedidos[i][07]) 		+"/" + Alltrim(aPedidos[i][08]) )    
					cTextoZpl := StrTran(cTextoZpl, ".PC."	, Alltrim(aPedidos[i][11])  	+"/" + Alltrim(aPedidos[i][14]) )
					cTextoZpl := StrTran(cTextoZpl, ".AZ."	, Alltrim(aPedidos[i][15]) )
					cTextoZpl := StrTran(cTextoZpl, ".NF."	, Alltrim(aPedidos[i][09]) )
					cTextoZpl := StrTran(cTextoZpl, ".SR."	, Alltrim(aPedidos[i][10]) ) 
					cTextoZpl := StrTran(cTextoZpl, ".TP."	, Alltrim(aPedidos[i][16]))
					cTextoZpl := StrTran(cTextoZpl, ".UM."	, Alltrim(aPedidos[i][17]) )  
					cTextoZpl := StrTran(cTextoZpl, ".DES."	, Alltrim(aPedidos[i][05]) ) 
					//cTextoZpl := StrTran(cTextoZpl, ".TRT."	, Alltrim(aPedidos[i][21]) ) 
					cTextoZpl := StrTran(cTextoZpl, ".SEQ."	, Alltrim(aPedidos[i][21]) ) 
					cTextoZpl := StrTran(cTextoZpl, ".QTD."	, Alltrim(aPedidos[i][04]) ) 
					cTextoZpl := StrTran(cTextoZpl, ".ARM."	, Alltrim(aPedidos[i][15]) ) 

					//IN=ATIVI. INTERNA;PV=POS VENDA;XS=ATIVI. EXTERNA;ES=ESTOQUE;SV=SERVICO;AD=ADMINISTRATIVO   				
						If(Alltrim(aPedidos[i][22]) = "PV")
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "POS VENDA" ) 
										
						ElseIf(Alltrim(aPedidos[i][22]) $  "IN|AI") // ATIVIDADE INTERNA, CONSUMO EM OP
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "ATIVI. INTERNA") 
										
						ElseIf(Alltrim(aPedidos[i][22]) $ "XS|AE|") // ATIVIDADE EXTERNA, DEVERÁ IR PARA O ARMAZEM DE ESTOQUE
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "ATIVI. EXTERNA" ) 
										
						ElseIf(Alltrim(aPedidos[i][22]) = "ES")//COMPRA PARA ESTOQUE
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "ESTOQUE" ) 
										
						ElseIf(Alltrim(aPedidos[i][22]) = "SV")//COMPRA PARA ESTOQUE
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "SERV. REQUIS" ) 
										
						ElseIf(Alltrim(aPedidos[i][22]) = "AD")//COMPRA PARA ESTOQUE
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "ADMINISTRATIVO " ) 

						ElseIf(Alltrim(aPedidos[i][22]) = "CO")//COMPRA PARA ESTOQUE
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "MAT CONSUMO" )

						ElseIf(Alltrim(aPedidos[i][22]) = "PS")//COMPRA PARA ESTOQUE
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "SERV.POS VENDA" )

						ElseIf(Alltrim(aPedidos[i][22]) = "GA")//COMPRA PARA ESTOQUE
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "GARANTIA" )

						ElseIf(Alltrim(aPedidos[i][22]) = "PI")//COMPRA PARA ESTOQUE
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "INTERNA POS.V" )
						
						ElseIf(Alltrim(aPedidos[i][22]) = "PX")//COMPRA PARA ESTOQUE
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "EXTERNA POS.V" )
						
						ElseIf(Alltrim(aPedidos[i][22]) = "MA")//COMPRA PARA PROJETO
						
										cTextoZpl := StrTran(cTextoZpl, ".DP."	, "PROJETOS" )
						EndIf                   			
				
				else
				cTextoZpl := Memoread("\etiqueta\ETIQUETA_RECEBIMENTO_PRODUTO.prn")
				cTextoZpl := StrTran(cTextoZpl, ".PROD.", Alltrim(aPedidos[i][01]) )
				cTextoZpl := StrTran(cTextoZpl, ".DESC.", Alltrim(aPedidos[i][02]) ) 
				cTextoZpl := StrTran(cTextoZpl, ".AZ."	, Alltrim(aPedidos[i][05]) )
				
				cTextoZpl := StrTran(cTextoZpl, ".TP."	, Alltrim(aPedidos[i][06]))
				cTextoZpl := StrTran(cTextoZpl, ".UM."	, Alltrim(aPedidos[i][07]))   
				
				     
           
				EndIf			
				@ 1, 1 PSay cTextoZpl
				//Set Device To Screen
				Set Device to Print
				Set Printer to LPT1
	    
		Next
		
	EndIf
							
  Next

  //Finaliza a impressão
  Ms_Flush()
  PrnFlush()
  
  Set Device to screen 
   
Return Nil       
