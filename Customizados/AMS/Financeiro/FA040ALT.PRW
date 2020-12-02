#INCLUDE "PROTHEUS.CH"

// #########################################################################################
// Projeto: 12.6
// Modulo : Financeiro
// Fonte  : FA070POS.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 13/07/17 | Totvs             | PE gatilha e Valida CAmpo Customizado de Data de Prorrogação
// #########################################################################################

User Function FA040ALT() 

Local lRet := .T.
      
//If Empty(SE1->E1_XDTPROR)
	If M->E1_VENCREA <> SE1->E1_VENCREA
		M->E1_XDTPROR := SE1->E1_VENCREA
	EndIf 
//EndIf            

Return(lRet)