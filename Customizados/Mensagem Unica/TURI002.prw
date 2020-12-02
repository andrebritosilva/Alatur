#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI002

Função de integração do Cadastro de Terminal de Passageiros
Mensagem Única - PassengerTerminal

@sample	TURI002(cXml, cTypeTrans, cTypeMessage)
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
@since		22/09/2015
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Function TURI002(cXml, nTypeTrans, cTypeMessage)

Local lRet      := .T. 
Local cEvento   := 'upsert'
Local cAdapter  := 'TURA002'
Local cMsgUnica := 'PASSENGERTERMINAL'
Local cMarca    := 'PROTHEUS'
Local cAlias    := 'G3B'
Local cCampo    := 'G3B_CODIGO'
Local oXML      := tXMLManager():New()
Local oModel    := NIL
Local oModelCab := NIL
Local cBusiCont := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cXmlRet   := ''
Local aErro     := nil
Local nX
Local lDelete

//Variaveis DE/PARA
Local cIntID    := ''
Local cExtID    := ''
Local cCityID   := ''

//Variaveis de controle
Local cCodeInt  := ''
Local cDesc     := ''
Local cSigla    := ''
Local cTipo     := ''
Local cCountry  := ''
Local cState    := ''	
Local cCity     := ''
Local cBlocked  := ''

Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt := AllTrim(oModel:GetValue('G3BMASTER', 'G3B_CODIGO'))
		cDesc    := AllTrim(oModel:GetValue('G3BMASTER', 'G3B_DESCR'))
		cSigla   := AllTrim(oModel:GetValue('G3BMASTER', 'G3B_SIGLA'))
		cTipo    := AllTrim(oModel:GetValue('G3BMASTER', 'G3B_TIPO'))
		cCountry := AllTrim(oModel:GetValue('G3BMASTER', 'G3B_PAIS'))
		cState	  := AllTrim(oModel:GetValue('G3BMASTER', 'G3B_EST'))
		cCity    := AllTrim(oModel:GetValue('G3BMASTER', 'G3B_CODMUN'))
		cBlocked := TURXLogic(oModel:GetValue('G3BMASTER', 'G3B_MSBLQL'), TP_CHAR1_RET)
		cIntID   := TURXMakeId(cCodeInt, 'G3B')
		cCityID  := TURXMakeId(cCity, 'G5S')

		//Monta XML de envio de mensagem unica
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=		'<Entity>' + cMsgUnica + '</Entity>'
		cXMLRet +=		'<Event>' + cEvento + '</Event>'
		cXMLRet +=		'<Identification>'
		cXMLRet +=			'<key name="InternalId">' + cIntID + '</key>'
		cXMLRet +=		'</Identification>'
		cXMLRet += '</BusinessEvent>'
		
		cXMLRet += '<BusinessContent>'
		cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=		'<Code>' + cCodeInt + '</Code>'
		cXMLRet +=		'<InternalId>' + cIntID + '</InternalId>'
		cXMLRet +=		'<Description>' + _NoTags(cDesc) + '</Description>'
		cXMLRet +=		'<Initials>' + cSigla +'</Initials>'
		cXMLRet +=		'<Type>' + cTipo + '</Type>'
		cXMLRet +=		'<CountryCode>' + cCountry + '</CountryCode>'
		cXMLRet +=		'<StateCode>' + CState + '</StateCode>'
		cXMLRet +=		'<CityCode>' + cCity + '</CityCode>'
		cXMLRet +=		'<CityInternalId>' + cCityID + '</CityInternalId>'
		cXMLRet +=		'<Situation>' + cBlocked + '</Situation>'
		cXMLRet += '</BusinessContent>'
		
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
					cMarca := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
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
				cSigla   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Initials'))
				cTipo    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Type'))
				cCountry := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CountryCode'))
				cState	  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/StateCode'))
				cCityID  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CityInternalId')) 
				cBlocked := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				cCodeInt := PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo      , cExtID , @cIntID, 3)), TamSx3('G3B_CODIGO')[1] )
				cCity    := PadR(AllTrim(TURXRetId(cMarca, 'G5S' , 'G5S_CODIGO', cCityID, NIL    , 3)), TamSx3('G3B_CODMUN')[1] )
					
				If Upper(cEvento) == 'UPSERT'
					If !Empty(cIntID) .And. G3B->(DbSeek(xFilial('G3B') + cCodeInt))
						cEvento := MODEL_OPERATION_UPDATE
					Else
						cEvento  := MODEL_OPERATION_INSERT
						cCodeInt := GetSXENum('G3B', 'G3B_CODIGO')
						cIntID   := TURXMakeId(cCodeInt, 'G3B')
					Endif
				ElseIf Upper(cEvento) == 'DELETE'
					If !Empty(cIntID) .And. G3B->(DbSeek(xFilial('G3B') + cCodeInt))
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
						oModelCab := oModel:GetModel('G3BMASTER')
						If cEvento <> MODEL_OPERATION_DELETE
							If cEvento == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G3B_CODIGO', cCodeInt)
							Endif
							oModelCab:SetValue('G3B_SIGLA' , cSigla)
							oModelCab:SetValue('G3B_TIPO'  , cTipo)
							oModelCab:SetValue('G3B_DESCR' , cDesc)
							oModelCab:SetValue('G3B_SIGLA' , cSigla)
							oModelCab:SetValue('G3B_TIPO'  , cTipo)
							oModelCab:SetValue('G3B_PAIS'  , cCountry)
							oModelCab:SetValue('G3B_EST'   , cState)
							oModelCab:SetValue('G3B_CODMUN', cCity)     
							oModelCab:SetValue('G3B_MSBLQL', TURXLogic(cBlocked, TP_CHAR1_RET))
						Endif
						If oModel:VldData() .And. oModel:CommitData()
							ConfirmSX8()
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID,cEvento == MODEL_OPERATION_DELETE)
							If cEvento <> MODEL_OPERATION_DELETE
								cXmlRet += '<ListOfInternalId>'
								cXmlRet +=		'<InternalId>'
								cXmlRet +=			'<Name>'+cMsgUnica+'</Name>'
								cXmlRet +=			'<Origin>'+cExtID+'</Origin>'
								cXmlRet +=			'<Destination>'+cIntID+'</Destination>'
								cXmlRet +=		'</InternalId>'
								cXmlRet += '</ListOfInternalId>'
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
TxDestroy(oXml)
Return {lRet, cXMLRet, cMsgUnica}