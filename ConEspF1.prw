#Include 'TOTVS.ch'

User Function ConEspF1()
   Local oDlg, oLbx
   Local aCpos  := {}
   Local aRet   := {}
   Local cAlias := GetNextAlias()
   Local lRet   := .F.

BEGINSQL ALIAS cAlias
SELECT DISTINCT F1_DOC,F1_SERIE, F1_FORNECE, F1_LOJA
FROM SD1010 SD1 
INNER JOIN SF1010 SF1 ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.D_E_L_E_T_= ' ' 
WHERE  F1_STATUS='' AND D1_PEDIDO !='' AND SD1.D_E_L_E_T_= ' ' AND NOT EXISTS (
   SELECT ZBY.* FROM ZBY010 ZBY WHERE ZBY_DOC=SF1.F1_DOC AND ZBY_SERIE=SF1.F1_SERIE AND ZBY_FORNEC=SF1.F1_FORNECE AND ZBY_LOJA=SF1.F1_LOJA
)
ENDSQL

   While (cAlias)->(!Eof())
      aAdd(aCpos,{(cAlias)->(F1_DOC), (cAlias)->(F1_SERIE), (cAlias)->(F1_FORNECE), (cAlias)->(F1_LOJA)})
      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())

   If Len(aCpos) < 1
      aAdd(aCpos,{" "," "," "," "})
   EndIf

   DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Pr�-Notas" FROM 0,0 TO 240,500 PIXEL

     @ 10,10 LISTBOX oLbx FIELDS HEADER 'Documento', 'S�rie', 'Fornecedor', 'Loja' SIZE 230,95 OF oDlg PIXEL

     oLbx:SetArray( aCpos )
     oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4]}}
     oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3],aCpos[oLbx:nAt,4]}}}

  DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3], aCpos[oLbx:nAt,4]})  ENABLE OF oDlg
  ACTIVATE MSDIALOG oDlg CENTER

  If Len(aRet) > 0 .And. lRet
     If Empty(aRet[1])
        lRet := .F.
     Else
        SF1->(dbSetOrder(1))
        SF1->(dbSeek(xFilial("SF1")+aRet[1]+IF(EMPTY(aRet[2]), Space(TamSx3("F1_SERIE")[01]),aRet[2])+aRet[3]+aRet[4]))
     EndIf
  EndIf
Return lRet
