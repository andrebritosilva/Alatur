#Include "Protheus.ch"  

User function FATC06()

Local _cQuery 		:= ''
Local aArea			:= GetArea()
Local _cAliasC06	:= GetNextAlias()
Local cRet 			:= "9"//O valor esperado para return é de 0 a 4, caso não encontre nada retorna 9
Local cNumRv		:= G85->G85_REGVEN
Local cTpAc			:= G85->G85_CLASS

BeginSQL Alias _cAliasC06
	SELECT G5V_XTPC06
	FROM %table:G85% G85 (NOLOCK)
	INNER JOIN %table:G4C% G4C (NOLOCK) ON
		G85_FILREF = G4C.G4C_FILIAL
		AND G85_REGVEN = G4C.G4C_NUMID  
		AND G85_ITVEND = G4C.G4C_IDITEM
		AND G85_SEQIV  = G4C.G4C_NUMSEQ
		AND G85_CLASS = 'C06'
	INNER JOIN %table:G5V% G5V (NOLOCK) ON				
			G5V_CODACO = G4C.G4C_NUMACD
	    AND G5V_MSBLQL = '2'
		AND G5V_TPFEE = 'C06'
	WHERE G4C.%NotDel%
	    AND G85.G85_REGVEN = %exp:cNumRv%
	    AND G85_CLASS = %exp:cTpAc%
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