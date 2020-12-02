#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'TURIDEF.CH'

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI034FEE

Função de integração para retornar o valor do FEE a ser cobrado via POS 
Mensagem única do tipo Request 

@sample	TURI034FEE(cXml, cTypeTrans, cTypeMessage)
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
aRet:= TURI034FEE(cXml, nTypeTrans, cTypeMessage)

Return aRet

Function TURI034FEE(cXml, nTypeTrans, cTypeMessage)

Local lRet		 := .T.
Local cXMLRet	 := "" 
Local cXmlItem	 := ""
Local cMsgUnica	 := "SaleRegistryFee" 
Local oXML		 := tXMLManager():New()
Local cBusiCont	 := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cMarca	 := ""
Local cSegNeg	 := ""
Local cIdItemCod := "" 
Local aMessages  := {}
Local aDados     := {}
Local cIntID     := ""	
Local nX	     := 0
Local oModel     := Nil
Local lMotivCanc := .F.

If Type("Inclui") == "U"
	Private Inclui := .F.
Endif

Do Case
	Case nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
		Do Case
			Case (cTypeMessage == EAI_MESSAGE_WHOIS)//whois 
				cXmlRet := '1.000'
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS) 
				cMsgUnica  := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessRequest/Operation'))
				cMarca	   := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
				cExtId	   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/SaleRegistryInternalId'))
				cExtItemId := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/SaleItemInternalId'))
				cItemIdCod := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/SaleItemCode'))
				
				// realizando DE/PARA
				cNumId	:= PadR(AllTrim(TURXRetId(cMarca, 'G3P', 'G3P_NUMID' , cExtId	 , @cIntID, 3)), TamSx3('G3P_NUMID' )[1])
				cItemId	:= PadR(AllTrim(TURXRetId(cMarca, 'G3Q', 'G3Q_IDITEM', cExtItemId, Nil    , 4)), TamSx3('G3Q_IDITEM')[1])
				cSeqId	:= PadR(AllTrim(TURXRetId(cMarca, 'G3Q', 'G3Q_IDITEM', cExtItemId, Nil    , 5)), TamSx3('G3Q_NUMSEQ')[1])

				// alteração realizada para cancelamento dos bilhetes/locs duplicados
				If !Empty(cItemIdCod) .And. Len(cItemIdCod) == 4
					cItemId	:= cItemIdCod
					cSeqId	:= "01"
					If !Empty(cExtItemId) .And. Len(cExtItemId) == 2						
						lMotivCanc := .T.
					EndIf
				EndIf			
				
				G3P->(DbSetOrder(1))
				If !Empty(cIntID) .and. G3P->(DbSeek(xFilial("G3P") + cNumID))
					cSegNeg := G3P->G3P_SEGNEG
					T034SetStc({{"lHierarquia",.F.}, {"nSegmento", Val(cSegNeg)}})

					oModel := FwLoadModel("TURA034")
					oModel:SetOperation(MODEL_OPERATION_UPDATE)
					If oModel:Activate()
						If oModel:GetModel('G3Q_ITENS'):SeekLine({{"G3Q_IDITEM", cItemId},{"G3Q_NUMSEQ", cSeqId}})
							If lMotivCanc
								Tur034Canc( .F. , cExtItemId )
							Else
								Tur034Canc()
							EndIf
						Else
							aAdd(aMessages, {"Item de Venda não encontrado", 1, "IV"})	// "Item de Venda não encontrado"
						Endif
					
					Else
						lRet:=.F.
					Endif
				Else
					aAdd(aMessages, {"Registro de Venda não encontrado", 1, "RV" })	// "Registro de Venda não encontrado"
				Endif
				
				If Len(aMessages) == 0
					If oModel:VldData() .and. oModel:CommitData()
						cXmlRet := '<Status>Success</Status>'
					Else
						aErro   := oModel:GetErrorMessage()
						cXmlRet := '<Status>Fail</Status>'
						If !Empty(aErro[5]) .or. !Empty(aErro[6]) 
							cXmlRet += '<Observation>' + _NoTags(Alltrim(aErro[5]) + '-' + AllTrim(aErro[6])) + '</Observation>'
						Else
							cXmlRet += '<Observation>' + _NoTags(Alltrim(MostraErro())) + '</Observation>'
						Endif
						aSize(aErro, 0)
						aErro := Nil
					Endif
				Endif
				If ValType(oModel) == "O"
					oModel:Deactivate()
					oModel:Destroy()	
				Endif
		EndCase
	OtherWise
		aAdd(aMessages, {STR0007, 1, 'PARSE'})	//'A integração não foi bem sucedida.'
		lRet := .F.
EndCase

If Len(aMessages) > 0 
	lRet	:= .F.
	cXmlRet	:= FWEAILOfMessages(aMessages) 
Endif

Return {lRet, cXmlRet, cMsgUnica}