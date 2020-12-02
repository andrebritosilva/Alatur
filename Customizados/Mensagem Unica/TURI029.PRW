#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI029

Função de integração do Cadastro de Impostos Turismo
Mensagem Única - Tax

@sample	TURI029(cXml, cTypeTrans, cTypeMessage)
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
@since		28/09/2015
@version 	P12.1.8
/*/
//------------------------------------------------------------------------------------------
Function TURI029(cXml, nTypeTrans, cTypeMessage)

Local lRet      := .T. 
Local cEvento   := 'upsert'
Local cAdapter  := 'TURA029'
Local cMsgUnica := 'Tax'
Local cMarca    := 'PROTHEUS'
Local cAlias    := 'G5R'
Local cCampo    := 'G5R_CODIGO'
Local oXML      := tXMLManager():New()
Local oModel    := NIL
Local oModelCab := NIL
Local cBusiCont := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cXmlRet   := ''
Local aErro     := {}
Local nX
Local lDelete
Local lMsblql	:= AllTrim(GetSx3Cache("G5R_MSBLQL", "X3_CAMPO")) == "G5R_MSBLQL" //FieldPos('G5R_MSBLQL') > 0
//Variaveis DE/PARA
Local cIntID    := ''
Local cExtID    := ''

//Variaveis de controle
Local cCodeInt	:= ''
Local cDesc		:= ''
Local cBlocked	:= ''
Local cAliq		:= ""			
Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt := AllTrim(oModel:GetValue('G5RMASTER', 'G5R_CODIGO'))
		cDesc    := AllTrim(oModel:GetValue('G5RMASTER', 'G5R_DESCR'))
		cAliq    := cValToChar(oModel:GetValue('G5RMASTER', 'G5R_ALIQT'))
		If lMsblql
			cBlocked := TURXLogic(oModel:GetValue('G5RMASTER', 'G5R_MSBLQL'), TP_CHAR1_RET)
		Endif
		cIntID	  := TURXMakeId(cCodeInt, 'G5R')

		//Monta XML de envio de mensagem unica
		cXMLRet := FWEAIBusEvent( cMsgUnica,oModel:GetOperation(), { { "InternalId", cIntID } } ) 
		
		cXMLRet +=	'<BusinessContent>'
		cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=		'<Code>' + cCodeInt + '</Code>'
		cXMLRet +=		'<InternalId>' + cIntID + '</InternalId>'
		cXMLRet +=		'<Description>' + _NoTags(cDesc) + '</Description>'
		cXMLRet +=		'<TaxRate>' + cAliq + '</TaxRate>'
		If lMsblql
			cXMLRet +=		'<Situation>' + cBlocked + '</Situation>'
		Endif
		cXMLRet +=	'</BusinessContent>'
		
		//Exclui o De/Para 
		If lDelete
			CFGA070MNT(NIL, cAlias, cCampo, NIL, cIntID, lDelete)
		Endif
		
	Case nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
			
			//resposta da mensagem única TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				If Empty(oXml:Error())
					cMarca	:= oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
					For nX := 1 to oXml:xPathChildCount('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId')
						cIntID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Origin')
						cExtID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Destination')
						If !Empty(cIntID) .And. !Empty(cExtID)
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID)
						Endif
					Next
				Endif
				oXml := NIL
			
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cEvento  := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca   := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cDesc    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Description'))
				cAliq    := VAL(oXml:XPathGetNodeValue(cBusiCont + '/TaxRate'))
				cBlocked := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				cCodeInt := PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo, cExtID, @cIntID, 3)), TamSx3('G5R_CODIGO')[1])
					
				If Upper(cEvento) == 'UPSERT'
					If !Empty(cIntID) .And. G5R->(DbSeek(xFilial('G5R') + cCodeInt))
						cEvento := MODEL_OPERATION_UPDATE
					Else
						cEvento  := MODEL_OPERATION_INSERT
						cCodeInt := T029GetNum()
						cIntID   := TURXMakeId(cCodeInt, 'G5R')
					Endif
				ElseIf Upper(cEvento) == 'DELETE'
					If !Empty(cIntID) .And. G5R->(DbSeek(xFilial('G5R') + cCodeInt))
						cEvento := MODEL_OPERATION_DELETE
					Else
						lRet    := .F.
						cXmlRet := STR0001 		// "Registro não encontrado no Protheus."
					Endif
				EndIf
				
				If lRet
					oModel := FwLoadModel(cAdapter)
					oModel:SetOperation(cEvento)
					If oModel:Activate()
						oModelCab := oModel:GetModel('G5RMASTER')
						If cEvento <> MODEL_OPERATION_DELETE
							If cEvento == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G5R_CODIGO', cCodeInt)
							Endif
							oModelCab:SetValue('G5R_DESCR'	, cDesc)
							oModelCab:SetValue('G5R_ALIQT'	, cAliq)
							If lMsblql
								oModelCab:SetValue('G5R_MSBLQL', TURXLogic(cBlocked, TP_CHAR1_RET))
							Endif
						Endif
						If oModel:VldData() .And. oModel:CommitData()
							ConfirmSX8()
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID,cEvento == MODEL_OPERATION_DELETE)
							If cEvento <> MODEL_OPERATION_DELETE
								cXmlRet +=	'<ListOfInternalId>'
								cXmlRet +=		'<InternalId>'
								cXmlRet +=			'<Name>' + cMsgUnica + '</Name>'
								cXmlRet +=			'<Origin>' + cExtID + '</Origin>'
								cXmlRet +=			'<Destination>' + cIntID + '</Destination>'
								cXmlRet += 		'</InternalId>'
								cXmlRet +=	'</ListOfInternalId>'
							Else
								cXmlRet := ''
							Endif
						Else
							aErro := oModel:GetErrorMessage()
							If !Empty(aErro)
								cErro := STR0002	// "A integração não foi bem sucedida."
								cErro += STR0003 + AllTrim(aErro[5]) + '-' + AllTrim(aErro[6])		// "Foi retornado o seguinte erro: "
								If !Empty(AllTrim(aErro[7]))
									cErro += STR0005 + AllTrim(aErro[7])	// "Solução - "
								Endif
							Else
								cErro := STR0002	// "A integração não foi bem sucedida. "
								cErro += STR0004 	// "Verifique os dados enviados."
							Endif
							aSize(aErro, 0)
							aErro   := NIL
							lRet    := .F.
							cXmlRet := cErro
						Endif
					Else
						lRet := .F.
					Endif
					oModel:Deactivate()
					oModel:Destroy()	
				EndIf
		EndCase
EndCase

Return {lRet, cXMLRet, cMsgUnica}

Static Function T029GetNum()
Local cNewNumCont	:= GetSXENum('G5R','G5R_CODCONT')
Local nStack		:= GetSX8Len() 
Local lContinua	:= .T.
Local aArea		:= GetArea()

While lContinua
	lContinua := G5R->(DbSeek(xFilial("G5R")+cNewNumCont))
	If lContinua
		While GetSX8Len() > nStack 
			ConfirmSX8()
		EndDo
		cNewNumCont := GetSXENum('G5R','G5R_CODCONT')
	EndIf
EndDo
RestArea(aArea)
Return cNewNumCont
