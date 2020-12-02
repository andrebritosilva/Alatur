#INCLUDE "PROTHEUS.CH"

User Function MT110APV 

Local lRet     := .F.
Local cCodigo  := SuperGetMV("AL_APRVSOL",.F.,"")

IF __cUserID  $ cCodigo
//Se contiver código do usuário no parametro acessar rotina
//If GetMv(AL_APRVSOL) == .T.
	lRet:=.T.
//EndIf
EndIf

Return lRet
