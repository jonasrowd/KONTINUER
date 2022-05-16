// Bibliotecas Necess�rias
#Include "TOTVS.ch"

/*/{Protheus.doc} KCOMF034
	AxCadastro para cria��o das tabelas
	@type function
	@version 12.1.33
	@author Jonas Machado
	@since 13/05/2022
/*/
User Function KCOMF034()

	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

	Private cString := "ZBY"	// Alias da Tabela a ser aberta/criada

	dbSelectArea("ZBY")
	dbSetOrder(1)

	// Fun��o para montagem de tela b�sica
	AxCadastro(cString,"Cabe�alho Confirma��o Pr�-nota",cVldExc,cVldAlt)

Return (Nil)
