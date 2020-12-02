#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI015

Função de integração do Cadastro de Tipos de Cabines
Mensagem única - CabinType

@sample	TURI015(cXml, cTypeTrans, cTypeMessage)
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transação
				0 - para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				1 - para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				20 - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				21 - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				22 - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				23 - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return	lRet - Variável lógica, indicando se o processamento foi executado com sucesso (.T.) ou nÃ£o (.F.) 
			cXMLRet - String com o XML de retorno
			cMsgUnica - String com o nome da Mensagem Unica
@author 	Jacomo Lisa
@since		22/09/2015
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Function TURI015(cXml, nTypeTrans, cTypeMessage)

Local lRet      := .T. 
Local cEvento   := 'upsert'
Local cAdapter  := 'TURA015'
Local cMsgUnica := 'CabinType'
Local cMarca    := 'PROTHEUS'
Local cAlias    := 'G4I'
Local cCampo    := 'G4I_CODIGO'
Local oXML      := tXMLManager():New()
Local oModel    := nil
Local oModelCab := nil
Local cBusiCont := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cXmlRet   := ''
Local aErro     := {}
Local nX
Local lDelete
Local lMsblql	:= AllTrim(GetSx3Cache("G4I_MSBLQL", "X3_CAMPO")) == "G4I_MSBLQL" //FieldPos('G4I_MSBLQL') > 0
		
//Variaveis de controle
Local cDesc     := ''
Local cBlocked  := ''

//Variaveis da Base Interna
Local cIntID    := ''
Local cCodeInt  := ''

//Variaveis da Base Externa
Local cExtID    := ''

Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt := oModel:GetValue('MASTER', 'G4I_CODIGO')
		cDesc    := oModel:GetValue('MASTER', 'G4I_DESCR')
		If lMsblql
			cBlocked := oModel:GetValue('MASTER', 'G4I_MSBLQL')
		Endif
		cIntID	  := TURXMakeId(cCodeInt, 'G4I')

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
		cXMLRet +=		'<Description>' + _NoTags(AllTrim(cDesc)) + '</Description>'
		If lMsblql
			cXMLRet +=		'<Situation>' + TURXLOGIC(cBlocked, TP_CHAR1_RET) + '</Situation>'
		Endif
		cXMLRet +=	'</BusinessContent>'
		
		//Exclui o De/Para 
		If lDelete
			CFGA070MNT( nil, cAlias, cCampo, nil, cIntID, lDelete )
		Endif
		
	Case nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
			
			//resposta da mensagem única TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				If Empty(oXml:Error())
					cMarca	:= oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product','name')
					For nX := 1 to oXml:xPathChildCount('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId')
						cIntID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Origin')
						cExtID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Destination')
						If !Empty(cIntID) .And. !Empty(cExtID)
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID)
						Endif
					Next
				Endif
				oXml := Nil
			
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cEvent   := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca   := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID   := AllTrim(oXml:XPathGetNodeValue(cBusiCont+'/InternalId'))
				cDesc    := AllTrim(oXml:XPathGetNodeValue(cBusiCont+'/Description'))
				cBlocked := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				cCodeInt := PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo, cExtID, @cIntID, 3)), TamSx3('G4I_CODIGO')[1])
					
				If Upper(cEvent) == 'UPSERT'
					If !Empty(cIntID) .And. G4I->(DbSeek(xFilial('G4I') + cCodeInt))
						cEvent := MODEL_OPERATION_UPDATE
					Else
						cEvent   := MODEL_OPERATION_INSERT
						cCodeInt := GetSXENum('G4I', 'G4I_CODIGO')
						cIntID   := TURXMakeId(cCodeInt,'G4I')
					Endif
				ElseIf Upper(cEvent) == 'DELETE'
					If !Empty(cIntID) .And. G4I->(DbSeek(xFilial('G4I') + cCodeInt))
						cEvent := MODEL_OPERATION_DELETE
					Else
						lRet    :=.F.
						cXmlRet := STR0001 	// "Registro nao encontrado no Protheus."
					Endif
				EndIf
				
				If lRet
					oModel	:= FwLoadModel(cAdapter)
					oModel:SetOperation(cEvent)
					If oModel:Activate()
						oModelCab := oModel:GetModel('MASTER')
						If cEvent <> MODEL_OPERATION_DELETE
							If cEvent == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G4I_CODIGO', cCodeInt)
							Endif
							oModelCab:SetValue('G4I_DESCR' , cDesc)
							If lMsblql
								oModelCab:SetValue('G4I_MSBLQL', TURXLOGIC(cBlocked, TP_CHAR1_RET))
							Endif
						Endif
						If oModel:VldData() .And. oModel:CommitData()
							ConfirmSX8()
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID,cEvent == MODEL_OPERATION_DELETE)
							If cEvent <> MODEL_OPERATION_DELETE
								cXmlRet +='<ListOfInternalId>'
								cXmlRet +=		'<InternalId>'
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
								cErro := STR0002 		// "A integração não foi bem sucedida."
								cErro += STR0003 + AllTrim(aErro[5]) + '-' + AllTrim(aErro[6])  	// "Foi retornado o seguinte erro: "
								If !Empty(AllTrim(aErro[7]))
									cErro += STR0005 + AllTrim(aErro[7])	// "Solução - "
								Endif
							Else
								cErro := STR0002 		// "A integração não foi bem sucedida."
								cErro += STR0004 		// "Verifique os dados enviados"
							Endif
							aSize(aErro,0)
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