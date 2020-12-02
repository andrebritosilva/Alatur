#Include "Protheus.ch"  

User function TPC06()

Local _cQuery 		:= ''
Local aArea			:= GetArea()
Local _cAliasC06	:= GetNextAlias()
Local cRet 			:= "9"//O valor esperado para return é de 0 a 4, caso não encontre nada retorna 9
Local cNumAcd		:= G4C->G4C_NUMACD
Local cNumId		:= G4C->G4C_NUMID

BeginSQL Alias _cAliasC06
	SELECT G5V_XTPC06
	FROM %table:G4C% G4C (NOLOCK)
	INNER JOIN %table:G5V% G5V (NOLOCK) ON
		G5V_CODACO = G4C.G4C_NUMACD
	    AND G5V_MSBLQL = '2'
		AND G5V_TPFEE = 'C06'
		AND G5V.%NotDel%
	WHERE G4C.%NotDel%
	    AND G4C.G4C_NUMACD = %exp:cNumAcd%
	    AND G4C_NUMID = %exp:cNumId%
EndSQL

If Select((_cAliasC06)) > 0
	If !Empty((_cAliasC06)->G5V_XTPC06)
		cRet := (_cAliasC06)->G5V_XTPC06
	EndIf
	//DbCloseArea((_cAliasc06))
	(_cAliasC06)->(dbCloseArea())
EndIf

RestArea(aArea)

Return(cRet)