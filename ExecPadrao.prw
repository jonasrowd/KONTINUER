#Include "Totvs.ch"

/*/{Protheus.doc} ExecPadrao
	Macro execução para chamada de rotina padrão
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 16/05/2022
	@param c_Rotina, character, Nome da rotina a ser executada
/*/
User Function ExecPadrao(c_Rotina) 

	Local cFuncAtual := AllTrim(FunName())

	SetFunName(c_Rotina) &(AllTrim(c_Rotina)+"()") 

	SetFunName(cFuncAtual) 

Return (Nil)
