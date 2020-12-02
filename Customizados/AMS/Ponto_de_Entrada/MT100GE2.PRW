#INCLUDE "PROTHEUS.CH"

// #########################################################################################
// Projeto: 12.6
// Modulo : Compras
// Fonte  : MT100GE2.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 25/10/16 |TOTVS	| PE para gravar banco, agencia e conta do Fornecedor no CP
// #########################################################################################


User Function MT100GE2()

Local _aArea    := GetArea() 
Local _aAreaSa2 := SA2->(GetArea())

RecLock("SE2",.F.)
	SE2->E2_ITEMD := SD1->D1_ITEMCTA
MsUnlock()	

DbSelectArea("SA2")
DbSetOrder(1)
If SA2->(MsSeek(xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA),.T.))
	RecLock("SE2",.F.)
		SE2->E2_FORBCO := ALLTRIM(SA2->A2_BANCO)
		SE2->E2_FORAGE := ALLTRIM(SA2->A2_AGENCIA) 
		SE2->E2_FAGEDV := ALLTRIM(SA2->A2_DVAGE)
		SE2->E2_FORCTA := ALLTRIM(SA2->A2_NUMCON) 		
		SE2->E2_FCTADV := ALLTRIM(SA2->A2_DVCTA)		
	SE2->(MsUnlock())	
EndIf

RestArea(_aAreaSa2)
RestArea(_aArea)

Return()