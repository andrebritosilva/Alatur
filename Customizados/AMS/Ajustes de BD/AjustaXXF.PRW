#Include "Totvs.ch"

User Function AJSTXXFSA1()

Local cAliasXXF := GetNextAlias()
Local lAchou    := .F.

BeginSQL Alias cAliasXXF
	SELECT * FROM XXF WHERE RTRIM(XXF_REFER) = 'PROTHEUS' AND XXF_ALIAS = 'SA2' AND XXF_TABLE = 'SA2010' AND SUBSTRING(XXF_INTVAL, LEN(RTRIM(XXF_INTVAL)) - 1, LEN(RTRIM(XXF_INTVAL))) = '|C' AND D_E_L_E_T_ = ''
EndSQL

ProcRegua((cAliasXXF)->(ScopeCount()))

(cAliasXXF)->(DbGoTop())
While (cAliasXXF)->(!EOF())
	// VERIFICAR SE JÁ EXISTE O DE/PARA PARA O CLIENTE
	XXF->(DbGoTop())
	XXF->(DbSetOrder(1))	// XXF_REFER+XXF_TABLE+XXF_ALIAS+XXF_FIELD+XXF_EXTVAL+XXF_INTVAL
	If XXF->(DbSeek("PROTHEUS       SA1010SA1A1_COD    " + (cAliasXXF)->XXF_EXTVAL + (cAliasXXF)->XXF_INTVAL))
		lAchou := .T.		
	EndIf

	XXF->(DbGoTop())
	XXF->(DbSetOrder(3))	// XXF_TABLE+XXF_ALIAS+XXF_FIELD+XXF_INTVAL	
	If XXF->(DbSeek((cAliasXXF)->XXF_TABLE + (cAliasXXF)->XXF_ALIAS + (cAliasXXF)->XXF_FIELD + (cAliasXXF)->XXF_INTVAL))
		If XXF->(RecLock("XXF", .F.))
			If lAchou 			
				XXF->(DbDelete())
			Else
				XXF->XXF_ALIAS := "SA1"
				XXF->XXF_TABLE := "SA1010"
				XXF->XXF_FIELD := "A1_COD"
			EndIf
			XXF->(MsUnLock())
		EndIf
	EndIf

	(cAliasXXF)->(DbSkip())
	lAchou := .F.
	IncProc()
EndDo
(cAliasXXF)->(DbCloseArea())

Alert("Processo finalizado.")

Return