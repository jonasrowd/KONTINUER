// Bibliotecas Necess�rias
#Include "TOTVS.ch"

/*/{Protheus.doc} KCOMF035
	AxCadastro para cria��o das tabelas
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 13/05/2022
/*/
User Function KCOMF035()

	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

	Private cString := "ZBZ"	// Alias da Tabela a ser aberta/criada

	dbSelectArea("ZBZ")
	dbSetOrder(1)

	// Fun��o para montagem de tela b�sica
	AxCadastro(cString,"Itens Confirma��o Pr�-nota",cVldExc,cVldAlt)

Return (Nil)
