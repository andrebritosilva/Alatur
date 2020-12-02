//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMKI070

Ponto de Entrada para informar novos campos para o msexecauto do cadastro de Contatos

@sample	TMKI070RE(cXml, cTypeTrans, cTypeMessage)
@return	aRet - Vetor Contendo todos os dados necessários para a execução do execauto  
@author 	Jacomo Lisa
@since		28/04/2016
@version 	P12.1.7
/*/
//------------------------------------------------------------------------------------------

USER FUNCTION TMKI070RE()
//aRetPe := ExecBlock("TMKI070RE",.F.,.F.,{aContato,nOpc,oXml})
Local aContatos 	:= PARAMIXB[1]
Local nOpc			:= PARAMIXB[2]
Local oXml			:= PARAMIXB[3]
Local aRet:= {}

If !Empty(AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/Vendedor')))
	aAdd(aContatos,{"U5_CODSA3"	,AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/Vendedor'))       	,nil})
EndIf
	
Return aContatos


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMKI070

Ponto de Entrada para informar Novas Tags no XML de Envio

@sample	TMKI070SE(cXml, cTypeTrans, cTypeMessage)
@return	cRet - String contendo as Novas Tags no XML de Envio
@author 	Jacomo Lisa
@since		28/04/2016
@version 	P12.1.7
/*/
//------------------------------------------------------------------------------------------

USER FUNCTION TMKI070SE()
///ExecBlock("TMKI070RE",.F.,.F.,{cXMLRet,cEvento})
Local cEvento := PARAMIXB[2]
Local cRet
If Upper(cEvento) <> 'DELETE'
	cRet:= '<Vendedor>'+SU5->U5_CODSA3+'</Vendedor>'
Endif
Return cRet