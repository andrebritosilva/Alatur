#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'TURIDEF.CH'



//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} TURICRED

Função de integração de avaliação de credito
Mensagem única do tipo Request - 

@sample	TURICRED(cXml, cTypeTrans, cTypeMessage)
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transação
				0 - para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				1 - para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				20 - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				21 - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				22 - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				23 - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return	lRet - Variável lógica, indicando se o processamento foi executado com sucesso (.T.) ou não (.F.) 
			cXMLRet - String com o XML de retorno
			cMsgUnica - String com o nome da Mensagem Unica
@author 	Jacomo Lisa
@since		05/04/2016
@version 	P12
/*/
//-----------------------------------------------------------------------------------------
STATIC FUNCTION IntegDef( cXml, nTypeTrans, cTypeMessage ) 
	Local aRet := {}
	aRet:= TURICRED( cXml, nTypeTrans, cTypeMessage )
Return aRet


Function TURICRED(cXml, nTypeTrans, cTypeMessage)
Local lRet		:= .T.
Local cXMLRet	:= "" 
Local cMsgUnica	:= "TourismCreditEvaluation" 
Local oXML      := tXMLManager():New()
Local cBusiCont := '/TOTVSMessage/BusinessMessage/BusinessContent'


Local cCliente	:= ""
Local cLoja		:= ""
Local cArqAC		:= ''
Local cSegTur		:= ""
Local nValor		:= ""
Local cMoeda		:= ""
Local cCustomer	:= ""
Local cCodBlq		:= ""
Local aMessages := {}

Do Case
	Case nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
		Do Case
			Case (cTypeMessage == EAI_MESSAGE_WHOIS)//whois 
				cXmlRet := '1.000'
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS) 
				cMsgUnica	:= AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessRequest/Operation'))
				cMarca	:= oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
				cCustomer	:= AllTrim(	oXml:XPathGetNodeValue(cBusiCont + '/CustomerInternalId'))
				nValor		:= VAL(		oXml:XPathGetNodeValue(cBusiCont + '/Value'))
				cMoeda		:= Alltrim(	oXml:XPathGetNodeValue(cBusiCont + '/TravelCurrencyInternalId'))
				cSegTur	:= AllTrim(	oXml:XPathGetNodeValue(cBusiCont + '/Segment'))
				
				
				cCliente	:= PadR(AllTrim(TURXRetId(cMarca, 'SA1', 'A1_COD'    , cCustomer  , NIL, 3)), TamSx3('A1_COD')[1])
				cLoja		:= PadR(AllTrim(TURXRetId(cMarca, 'SA1', 'A1_COD'    , cCustomer  , NIL, 4)), TamSx3('A1_LOJA')[1])
				cMoeda		:= PadR(AllTrim(TURXRetId(cMarca, 'G5T', 'G5T_CODIGO', cMoeda, nil, 3)), TamSx3('G5T_CODIGO')[1])
				
				If Empty(cCliente+cLoja) .or. !SA1->(ExistCpo('SA1',cCliente+cLoja))
					aAdd( aMessages, { "Cliente não encontrado", 1, 'Cliente' } )
				Endif
				If Empty(cMoeda) .or. !G5T->(ExistCpo('G5T',cMoeda))
					aAdd( aMessages, { "Moeda não encontrada", 1, 'Moeda' } )
				Endif
				If Len(aMessages) == 0 
					aRet := TURA18AVCRED(cCliente,cLoja,Val(cSegTur),nValor,cMoeda,@cCodBlq)
					
					cXmlRet := '<Operation>'+cMsgUnica+'</Operation>'
					cXmlRet += '<Situation>'+ If(aRet[1],'Accepted','Denied')+'</Situation>'
					If !Empty(cCodBlq)
						cXmlRet += '<Reason>'+ cCodBlq+'-'+If(cCodBlq == '1',STR0007,STR0008 ) +'</Reason>'
					Endif
					cXmlRet += '<Observation>'+ aRet[2]+'</Observation>'
				Endif
				
		EndCase
	OtherWise
		aAdd( aMessages, { STR0002, 1, 'parse' } )
		lRet := .F.
EndCase
If Len(aMessages) > 0 
	lRet		:= .F.
	cXmlRet	:= FWEAILOfMessages( aMessages ) 
Endif
Return { lRet, cXmlRet, cMsgUnica}
