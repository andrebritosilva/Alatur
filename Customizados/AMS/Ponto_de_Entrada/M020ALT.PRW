#include "PROTHEUS.CH"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M020ALT	 ºAutor  ³Totvs     º Data ³  11/11/16            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE para alterar dados do Complemento de Fornececedor pelo  º±±
±±º          ³ Cadastro de Fornecedor. Campos: Razão Social e Municipio.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12 - Alatur                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M020ALT()

Local _xRet := .T.
Local _aArea    := GetArea()
Local _aAreaSa2 := SA2->(GetArea())
Local _aAreaG4R := G4R->(GetArea())

DbSelectArea("G4R")
DbSetOrder(1)
If G4R->(MsSeek(xFilial("G4R")+SA2->(A2_COD+A2_LOJA),.T.))
	
	//Se Alterado Razão Social/Nome do Fornecedor o sistema deve alterar também na tabela G4L (Complemento de Fornecedor-Turismo)
	If ALLTRIM(G4R->G4R_XNOME) <> ALLTRIM(SA2->A2_NOME)
		RecLock("G4R",.F.)
	   		G4R->G4R_XNOME := SA2->A2_NOME
		G4R->(MsUnlock())
	EndIf
	//Se Alterado Razão Nome do Municipio do Fornecedor o sistema deve alterar também na tabela G4L (Complemento de Fornecedor-Turismo)
	If ALLTRIM(G4R->G4R_XMUN) <> ALLTRIM(SA2->A2_MUN)
		RecLock("G4R",.F.)
	   		G4R->G4R_XMUN := SA2->A2_MUN
		G4R->(MsUnlock())
	EndIf
	
EndIf

RestArea(_aAreaG4R)
RestArea(_aAreaSa2)
RestArea(_aArea)

Return(_xRet)