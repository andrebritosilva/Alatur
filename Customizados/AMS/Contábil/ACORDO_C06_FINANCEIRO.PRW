#Include "Protheus.ch"  

User function FINC06()

Local _cQuery 		:= ''
Local aArea			:= GetArea()
Local _cAliasC06	:= GetNextAlias()
Local cRet 			:= "9"//O valor esperado para return é de 0 a 4, caso não encontre nada retorna 9
Local cFilialSE5	:= SE5->E5_FILIAL
Local cNumFat		:= SE5->E5_NUMERO
Local cPrefixo		:= SE5->E5_PREFIXO


BeginSQL Alias _cAliasC06
	SELECT G5V_XTPC06
	FROM %table:G85% G85 (NOLOCK)
	INNER JOIN %table:G4C% G4C (NOLOCK) ON
		G85_FILREF = G4C.G4C_FILIAL
		AND G85_REGVEN = G4C.G4C_NUMID
		AND G85_CLASS = 'C06'
	    AND G4C.%NotDel%
	INNER JOIN %table:G5V% G5V (NOLOCK) ON				
		G5V_CODACO = G4C.G4C_NUMACD
	    AND G5V_MSBLQL = '2'
		AND G5V_TPFEE = 'C06'
	    AND G5V.%NotDel%
	WHERE 
	    G85_FILIAL = %exp:cFilialSE5%
	    AND G85_NUMFAT = %exp:cNumFat%
	    AND G85_PREFIX = %exp:cPrefixo%
	    AND G85.%NotDel%
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