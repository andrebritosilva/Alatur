//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI034EXT

Ponto de Entrada para informar novos campos para o msexecauto do cadastro de Contatos

@sample	TURI034EXT(cIntID,cExtID,cAlias)
@return	cExtID_PE - String contendo o ExternalID   
@author 	Jacomo Lisa
@since		17/05/2016
@version 	P12.1.7
/*/
//------------------------------------------------------------------------------------------

USER FUNCTION TURI034EXT()
//cExtID := ExecBlock("TURI034EXT",.F.,.F.,{cIntID,cExtID,'G3P'})
Local cIntID_PE 	:= PARAMIXB[1]
Local cExtID_PE	:= PARAMIXB[2]
Local cAlias_PE	:= PARAMIXB[3]
If Empty(cExtID_PE)
	cExtID_PE := cIntID_PE 
Endif	
Return cExtID_PE