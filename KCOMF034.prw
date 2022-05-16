// Bibliotecas Necessárias
#Include "TOTVS.ch"

/*/{Protheus.doc} KCOMF034
	AxCadastro para criação das tabelas
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

	// Função para montagem de tela básica
	AxCadastro(cString,"Cabeçalho Confirmação Pré-nota",cVldExc,cVldAlt)

Return (Nil)
