#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI010

Funcao de integracao do Posto de Atendimento
Mensagem Unica - ServiceStation

@sample	TURI010(cXml, cTypeTrans, cTypeMessage)
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				0 - para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				1 - para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				20 - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				21 - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				22 - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				23 - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return	lRet - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.) 
			cXMLRet - String com o XML de retorno
			cMsgUnica - String com o nome da Mensagem Unica
@author 	Jacomo Lisa
@since		22/09/2015
@version 	P12.1.8
/*/
//------------------------------------------------------------------------------------------
Function TURI010(cXml, nTypeTrans, cTypeMessage)

Local lRet      := .T. 
Local cEvento   := 'upsert'
Local cAdapter  := 'TURA010'
Local cMsgUnica := 'SERVICESTATION'
Local cMarca    := 'PROTHEUS'
Local cAlias    := 'G3M'
Local cCampo    := 'G3M_CODIGO'
Local oXML      := tXMLManager():New()
Local oModel    := NIL
Local oModelCab := NIL
Local cBusiCont := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cXmlRet   := ''
Local aErro     := {}
Local nX
Local lDelete

//Variaveis DE/PARA
Local cIntID    := ''
Local cExtID    := ''
Local cCityID   := ''

//Variaveis de controle
Local cCodeInt  := ''
Local cDesc     := ''
Local cAddress  := ''    
Local cCompl    := '' 
Local cState    := ''       
Local cCityCode := ''   
Local cZipCode  := ''
Local cDDI      := ''
Local cDDD      := ''
Local cPhone    := ''
Local cFAX      := ''
Local cEmail    := ''
Local cWebSite  := ''
Local cIATA     := ''
Local cShort    := ''	
Local cPCC      := ''
Local cBlocked  := ''

Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt  := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_CODIGO'))
		cDesc     := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_DESCR'))
		cAddress  := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_END'))
		cCompl    := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_COMPL'))
		cState    := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_EST'))
		cCityCode := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_CODMUN'))
		cZipCode  := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_CEP'))
		cDDI      := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_DDI'))
		cDDD      := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_DDD'))
		cPhone    := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_FONE'))
		cFAX      := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_FAX'))
		cEmail    := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_EMAIL'))
		cWebSite  := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_SITE'))
		cIATA     := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_NIATA'))
		cShort    := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_ABREV'))
		cPCC      := AllTrim(oModel:GetValue('G3MMASTER', 'G3M_PCC'))
		cBlocked  := TURXLogic(oModel:GetValue('G3MMASTER', 'G3M_MSBLQL'), TP_CHAR1_RET)
		cIntID    := TURXMakeId(cCodeInt, 'G3M')
		cCityID   := TURXMakeId(cCityCode, 'G5S')

		//Monta XML de envio de mensagem unica
		cXMLRet :=	'<BusinessEvent>'
		cXMLRet +=		'<Entity>' + cMsgUnica + '</Entity>'
		cXMLRet +=		'<Event>' + cEvento + '</Event>'
		cXMLRet +=		'<Identification>'
		cXMLRet +=			'<key name="InternalId">' + cIntID + '</key>'
		cXMLRet +=		'</Identification>'
		cXMLRet +=	'</BusinessEvent>'
		
		cXMLRet +=	'<BusinessContent>'
		cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=		'<Code>' + cCodeInt + '</Code>'
		cXMLRet +=		'<InternalId>' + cIntID + '</InternalId>'
		cXMLRet +=		'<Description>' + _NoTags(cDesc) + '</Description>'
		cXMLRet +=		'<Address>'
		cXMLRet +=			'<Address>' + cAddress + '</Address>'
		cXMLRet +=			'<Complement>' + cCompl + '</Complement>'
		cXMLRet +=			'<City>'
		cXMLRet +=				'<CityCode>' + cCityCode + '</CityCode>'
		cXMLRet +=				'<CityInternalId>' + cCityID + '</CityInternalId>'
		cXMLRet +=				'<CityDescription>' + AllTrim(Posicione("G5S", 1, xFilial("G5S") + cCityCode, "G5S_CIDADE")) + '</CityDescription>'   
		cXMLRet +=			'</City>'     
		cXMLRet +=			'<State>'
		cXMLRet +=				'<StateCode>' + cState + '</StateCode>'
		cXMLRet +=				'<StateInternalId>' + cState + '</StateInternalId>'
		cXMLRet +=				'<StateDescription>' + Alltrim(POSICIONE("SX5",1,xFilial("SX5")+"12"+cState,"X5_DESCRI")) + '</StateDescription>'   
		cXMLRet +=			'</State>'
		cXMLRet +=			'<ZIPCode>' + cZipCode + '</ZIPCode>'    
		cXMLRet +=		'</Address>'
		cXMLRet +=		'<ListOfCommunicationInformation>'
		cXMLRet +=			'<CommunicationInformation>'
		cXMLRet +=		 		'<PhoneNumber>'+If(!Empty(cPhone), cDDI+cDDD+cPhone,'')+'</PhoneNumber>'
		cXMLRet +=		 		'<FaxNumber>'+If(!Empty(cFAX), cDDI+cDDD+cFAX,'')+'</FaxNumber>'
		cXMLRet +=	 			'<HomePage>'+cWebSite+'</HomePage>'
		cXMLRet +=	 			'<Email>'+cEmail+'</Email>'
		cXMLRet +=	 		'</CommunicationInformation>'
		cXMLRet +=		'</ListOfCommunicationInformation>'
		cXMLRet +=		'<IATA>' + cIATA + '</IATA>'
		cXMLRet +=		'<ShortIATA>' + cShort + '</ShortIATA>'
		cXMLRet +=		'<PCC>' + cPCC + '</PCC>'
		cXMLRet +=		'<Situation>' + cBlocked + '</Situation>'
		cXMLRet +=	'</BusinessContent>'
		
		//Exclui o De/Para 
		If lDelete
			CFGA070MNT(NIL, cAlias, cCampo, NIL, cIntID, lDelete)
		Endif

	Case nTypeTrans == TRANS_RECEIVE .AND. oXML:Parse(cXml)
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS ) 
				cXmlRet := '1.000'
				
			//resposta da mensagem Unica TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				If Empty(oXml:Error())
					cMarca	:= oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product','name')
					For nX := 1 to oXml:xPathChildCount('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId')
						cIntID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Origin')
						cExtID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Destination')
						If !Empty(cIntID) .and. !Empty(cExtID)
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID)
						Endif
					Next
				Endif
				oXml := NIL
			
			//chegada de mensagem de negocios	
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cEvento   := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca    := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cDesc     := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Description'))
				cAddress  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Address/Address'))
				cCompl    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Address/Complement'))
				cState    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Address/State/StateCode'))
				cCityCode := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Address/City/CityInternalId'))
				cZipCode  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Address/ZIPCode'))
//				cDDI      := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DDI'))
//				cDDD      := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DDD'))
				cPhone    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ListOfCommunicationInformation/CommunicationInformation/PhoneNumber'))
				cFAX      := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ListOfCommunicationInformation/CommunicationInformation/FaxNumber'))
				cEmail    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ListOfCommunicationInformation/CommunicationInformation/Email'))
				cWebSite  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ListOfCommunicationInformation/CommunicationInformation/HomePage'))
				cIATA     := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/IATA'))
				cShort    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ShortIATA'))
				cPCC      := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/PCC'))
				cBlocked  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				cCodeInt  := PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo      , cExtID   , @cIntID, 3)), TamSx3('G3M_CODIGO')[1])
				cCityCode := PadR(AllTrim(TURXRetId(cMarca, 'G5S' , 'G5S_CODIGO', cCityCode, NIL    , 3)), TamSx3('G5S_CODIGO')[1])
				
				aTelefone := RemDddTel(cPhone)
				aFaxfone := RemDddTel(cFAX)    
				If Upper(cEvento) == 'UPSERT'
					If !Empty(cIntID) .and. G3M->(DbSeek(xFilial('G3M') + cCodeInt))
						cEvento := MODEL_OPERATION_UPDATE
					Else
						cEvento  := MODEL_OPERATION_INSERT
						cCodeInt := GetSXENum('G3M', 'G3M_CODIGO')
						cIntID   := TURXMakeId(cCodeInt, 'G3M')
					Endif
				ElseIf Upper(cEvento) == 'DELETE'
					If !Empty(cIntID) .and. G3M->(DbSeek(xFilial('G3M') + cCodeInt))
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
						oModelCab := oModel:GetModel('G3MMASTER')
						If cEvento <> MODEL_OPERATION_DELETE
							If cEvento == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G3M_CODIGO', cCodeInt)
							Endif
							oModelCab:SetValue('G3M_DESCR' , cDesc)
							oModelCab:SetValue('G3M_END'   , cAddress)
							oModelCab:SetValue('G3M_COMPL' , cCompl)
							oModelCab:SetValue('G3M_EST'   , cState)
							If !Empty(oModel:GetValue('G3MMASTER', 'G3M_EST'))
								oModelCab:SetValue('G3M_CODMUN', cCityCode)
							Endif
							oModelCab:SetValue('G3M_CEP'   , cZipCode)
							oModelCab:SetValue('G3M_DDI'   , aTelefone[3])
							oModelCab:SetValue('G3M_DDD'   , aTelefone[2])
							oModelCab:SetValue('G3M_FONE'  , aTelefone[1])
							oModelCab:SetValue('G3M_FAX'   , aFaxfone[1])
							oModelCab:SetValue('G3M_EMAIL' , cEmail)
							oModelCab:SetValue('G3M_SITE'  , cWebSite)
							oModelCab:SetValue('G3M_NIATA' , cIATA)
							oModelCab:SetValue('G3M_ABREV' , cShort)
							oModelCab:SetValue('G3M_PCC'   , cPCC)
							oModelCab:SetValue('G3M_MSBLQL', TURXLogic(cBlocked, TP_CHAR1_RET))
						Endif

						If oModel:VldData() .and. oModel:CommitData()
							ConfirmSX8()
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID, cEvento == MODEL_OPERATION_DELETE)
							If cEvento <> MODEL_OPERATION_DELETE
								cXmlRet += '<ListOfInternalId>'
								cXmlRet += 	'<InternalId>'
								cXmlRet +=			'<Name>' + cMsgUnica + '</Name>'
								cXmlRet +=			'<Origin>' + cExtID + '</Origin>'
								cXmlRet +=			'<Destination>' + cIntID + '</Destination>'
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

Return {lRet, cXMLRet, cMsgUnica}

