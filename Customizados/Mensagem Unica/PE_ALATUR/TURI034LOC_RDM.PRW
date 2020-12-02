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

USER FUNCTION T034LOCXML()
//cExtID := ExecBlock("T034LOCXML",.F.,.F.,{cXMLRet,aDados,nLinha})
Local aDados	:= PARAMIXB[2]
Local nLinha	:= PARAMIXB[3]
Local cXml		:= ""
If Len(aDados) >0 
	cXml :='<SaleItemExternalId>'+Alltrim(CFGA070Ext('PROTHEUS' , "G3Q", 'G3Q_IDITEM',aDados[nLinha,6]))+'</SaleItemExternalId>'
Endif	
Return cXml