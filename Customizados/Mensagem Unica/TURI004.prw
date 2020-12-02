#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI004

Funcao de integracao do Cartoes de turismo
Mensagem Unica - AgencyCreditCard

@sample	TURI004(cXml, cTypeTrans, cTypeMessage)
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
Function TURI004(cXml, nTypeTrans, cTypeMessage)

Local lRet        := .T. 
Local cEvento     := 'upsert'
Local cAdapter    := 'TURA004'
Local cMsgUnica   := 'AGENCYCREDITCARD'
Local cMarca      := 'PROTHEUS'
Local cAlias      := 'G3D'
Local cCampo      := 'G3D_CODIGO'
Local oXML        := tXMLManager():New()
Local oModel      := NIL
Local oModelCab   := NIL
Local cBusiCont   := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cXmlRet     := ''
Local aErro       := {}
Local nX
Local lDelete

//Variaveis DE/PARA
Local cIntID      := ''
Local cExtID      := ''
Local cClassID    := ''
Local cFornID     := ''

//Variaveis de controle
Local cCodeInt    := ''
Local cDesc       := ''
Local cClassCode  := ''
Local cCardNumb   := ''
Local cSecurCode  := ''
Local cBandCode   := ''
Local cCardHolder := ''
Local cMonthExpir := ''
Local cYearExpir  := ''
Local nUseDtOf    := 0
Local nUseDtUntil := 0
Local cConcilia   := ''
Local cConcDay    := '' 
Local cConcExp    := ''
Local nInvcClose  := 0
Local nInvcExp    := 0
Local cForn       := ''
Local cLoja       := ''
Local cCorp       := ''
Local cEventos    := ''
Local cLazer      := ''
Local cBlocked    := ''

Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt   := AllTrim(oModel:GetValue('G3DMASTER', 'G3D_CODIGO'))
		cDesc      := AllTrim(oModel:GetValue('G3DMASTER', 'G3D_DESCR'))
		cClassCode := AllTrim(oModel:GetValue('G3DMASTER', 'G3D_TIPO'))
		cCardNumb  := AllTrim(oModel:GetValue('G3DMASTER', 'G3D_NCARD'))
		cSecurCode := AllTrim(oModel:GetValue('G3DMASTER', 'G3D_CODSEG'))

		//Quando for inclusao descriptografa o numero do Cartao e o Codigo de seguranca
		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			cCardNumb	:= If(!Empty(cCardNumb) ,rc4crypt(TurHex2Crypt(cCardNumb) , cCodeInt, .F.),"")
			cSecurCode	:= If(!Empty(cSecurCode),rc4crypt(TurHex2Crypt(cSecurCode), cCodeInt, .F.),"")
		Endif

		cBandCode   := AllTrim(oModel:GetValue('G3DMASTER', 'G3D_CODBAN'))
		cCardHolder := AllTrim(oModel:GetValue('G3DMASTER', 'G3D_TITULA'))
		cMonthExpir := AllTrim(oModel:GetValue('G3DMASTER', 'G3D_MVALID'))
		cYearExpir  := AllTrim(oModel:GetValue('G3DMASTER', 'G3D_AVALID'))
		nUseDtOf    := oModel:GetValue('G3DMASTER', 'G3D_DIADE')
		nUseDtUntil := oModel:GetValue('G3DMASTER', 'G3D_DIAATE')
		cConcilia   := TURXLogic(oModel:GetValue('G3DMASTER', 'G3D_CONC'), TP_CHAR1_RET)
		cConcDay    := AllTrim(oModel:GetValue('G3DMASTER', 'G3D_DCONC'))
		cConcExp    := AllTrim(oModel:GetValue('G3DMASTER', 'G3D_PCONC'))
		nInvcClose  := oModel:GetValue('G3DMASTER', 'G3D_DFECHA')
		nInvcExp    := oModel:GetValue('G3DMASTER', 'G3D_DVENC')
		cForn       := oModel:GetValue('G3DMASTER', 'G3D_CODFOR')
		cLoja       := oModel:GetValue('G3DMASTER', 'G3D_LJFOR')
		cCorp       := TURXLogic(oModel:GetValue('G3DMASTER', 'G3D_CORP'), TP_CHAR1_RET)
		cEventos    := TURXLogic(oModel:GetValue('G3DMASTER', 'G3D_EVENTO'), TP_CHAR1_RET)
		cLazer      := TURXLogic(oModel:GetValue('G3DMASTER', 'G3D_LAZER'), TP_CHAR1_RET)
		cBlocked    := TURXLogic(oModel:GetValue('G3DMASTER', 'G3D_MSBLQL'), TP_CHAR1_RET)
		cIntID      := TURXMakeId(cCodeInt, 'G3D')
		cClassID    := TURXMakeId(cClassCode, 'G8Q')
		cFornID     := IntForExt(,, cForn, cLoja,)[2]//TURXMakeId(cForn + '|' + cLoja + '|F', 'SA2') 
		
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
		cXMLRet +=		'<CardClassificationCode>' + cClassCode + '</CardClassificationCode>'
		cXMLRet +=		'<CardClassificationInternalId>' + cClassID + '</CardClassificationInternalId>'
		cXMLRet +=		'<CardNumber>' + cCardNumb + '</CardNumber>'
		cXMLRet +=		'<SecurityCode>' + cSecurCode + '</SecurityCode>'
		cXMLRet +=		'<CardComapny>' + cBandCode + '</CardComapny>'
		cXMLRet +=		'<CardHolderName>' + cCardHolder + '</CardHolderName>'
		cXMLRet +=		'<ExpirationMonth>' + cMonthExpir + '</ExpirationMonth>'
		cXMLRet +=		'<ExpirationYear>' + cYearExpir + '</ExpirationYear>'
		cXMLRet +=		'<UseDayOf>' + cValToChar(nUseDtOf) + '</UseDayOf>'
		cXMLRet +=		'<UseDayUntil>' + cValToChar(nUseDtUntil) + '</UseDayUntil>'
		cXMLRet +=		'<Conciliation>' + cConcilia + '</Conciliation>'
		cXMLRet +=		'<ConciliationDay>' + cConcDay + '</ConciliationDay>'
		cXMLRet +=		'<DeadLineConciliation>' + cConcExp + '</DeadLineConciliation>'
		cXMLRet +=		'<InvoiceClosingDay>' + cValToChar(nInvcClose) + '</InvoiceClosingDay>'
		cXMLRet +=		'<InvoiceExpirationDay>' + cValToChar(nInvcExp) + '</InvoiceExpirationDay>'
		cXMLRet +=		'<VendorCode>' + cForn + '|' + cLoja + '</VendorCode>'
		cXMLRet +=		'<VendorInternalID>' + cFornID + '</VendorInternalID>'
		cXMLRet +=		'<Corporate>' + cCorp + '</Corporate>' 
		cXMLRet +=		'<Event>' + cEventos + '</Event>'
		cXMLRet +=		'<Recreation>' + cLazer + '</Recreation>'
		cXMLRet +=		'<Situation>' + cBlocked + '</Situation>'
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
			
			//resposta da mensagem Unica TOTVS
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
				
			//chegada de mensagem de negocios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS )
				cEvento     := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca      := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID      := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cDesc       := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Description'))
				cClassID    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CardClassificationInternalId'))
				cCardNumb   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CardNumber'))
				cSecurCode  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/SecurityCode'))
				cBandCode   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CardComapny'))
				cCardHolder := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CardHolderName'))
				cMonthExpir := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ExpirationMonth'))
				cYearExpir  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ExpirationYear'))
				nUseDtOf    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/UseDayOf'))
				nUseDtUntil := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/UseDayUntil'))
				cConcilia   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Conciliation'))
				cConcDay    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ConciliationDay'))
				cConcExp    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DeadLineConciliation'))
				nInvcClose  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InvoiceClosingDay'))
				nInvcExp    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InvoiceExpirationDay'))
				cFornID     := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/VendorInternalID'))
				cCorp       := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Corporate'))
				cEventos    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Event'))
				cLazer      := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Recreation'))
				cBlocked    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				cCodeInt    := PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo      , cExtID  , @cIntID, 3)), TamSx3('G3D_CODIGO')[1])
				cClassCode  := PadR(AllTrim(TURXRetId(cMarca, 'G8Q' , 'G8Q_CODIGO', cClassID, NIL    , 3)), TamSx3('G3D_TIPO')[1])
				
				If (aForn:= IntForInt(cFornID, cMarca))[1]
					cForn       := PadR(aForn[2][3], TamSx3('G3D_CODFOR')[1])
					cLoja       := PadR(aForn[2][4], TamSx3('G3D_LJFOR')[1])
				Else
					Return {.F.,aForn[2]}
				Endif
				
				If Upper(cEvento) == 'UPSERT'
					If !Empty(cIntID) .And. G3D->(DbSeek(xFilial('G3D') + cCodeInt))
						cEvento := MODEL_OPERATION_UPDATE
					Else
						cEvento  := MODEL_OPERATION_INSERT
						cCodeInt := GetSXENum('G3D', 'G3D_CODIGO')
						cIntID   := TURXMakeId(cCodeInt, 'G3D')
					Endif
				ElseIf Upper(cEvento) == 'DELETE'
					If !Empty(cIntID) .And. G3D->(DbSeek(xFilial('G3D') + cCodeInt))
						cEvento := MODEL_OPERATION_DELETE
					Else
						lRet    := .F.
						cXmlRet := STR0001 	// "Registro nao encontrado no Protheus."
					Endif
				EndIf
				
				If lRet
					oModel := FwLoadModel(cAdapter)
					oModel:SetOperation(cEvento)
					If oModel:Activate()
						oModelCab := oModel:GetModel('G3DMASTER')
						If cEvento <> MODEL_OPERATION_DELETE
							If cEvento == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G3D_CODIGO', cCodeInt)
								oModelCab:SetValue('G3D_TIPO'  , cClassCode)
								oModelCab:SetValue('G3D_CODSEG', cSecurCode)
								oModelCab:SetValue('G3D_CODBAN', cBandCode)
								oModelCab:SetValue('G3D_NCARD' , cCardNumb)
							Endif
							oModelCab:SetValue('G3D_DESCR' , cDesc)
							oModelCab:SetValue('G3D_TITULA', cCardHolder)
							oModelCab:SetValue('G3D_MVALID', cMonthExpir)
							oModelCab:SetValue('G3D_AVALID', cYearExpir)
							oModelCab:SetValue('G3D_DIADE' , Val(nUseDtOf	))
							oModelCab:SetValue('G3D_DIAATE', Val(nUseDtUntil))
							oModelCab:SetValue('G3D_CONC'  , cConcilia)
							
							If oModelCab:CanSetValue("G3D_DCONC")
								oModelCab:SetValue('G3D_DCONC' , cConcDay)
							Endif
							If oModelCab:CanSetValue("G3D_PCONC")
								oModelCab:SetValue('G3D_PCONC' , cConcExp)
							Endif
							oModelCab:SetValue('G3D_DFECHA', Val(nInvcClose))
							oModelCab:SetValue('G3D_DVENC' , Val(nInvcExp))
							oModelCab:SetValue('G3D_CODFOR', cForn)
							oModelCab:SetValue('G3D_LJFOR' , cLoja)
							oModelCab:SetValue('G3D_CORP'  , TURXLogic(cCorp   , TP_LOGIC_RET))
							oModelCab:SetValue('G3D_EVENTO', TURXLogic(cEventos, TP_LOGIC_RET))
							oModelCab:SetValue('G3D_LAZER' , TURXLogic(cLazer  , TP_LOGIC_RET))
							oModelCab:SetValue('G3D_MSBLQL', TURXLogic(cBlocked, TP_CHAR1_RET))
						Endif

						If oModel:VldData() .And. oModel:CommitData()
							ConfirmSX8()
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID, cEvento == MODEL_OPERATION_DELETE)
							If cEvento <> MODEL_OPERATION_DELETE
								cXmlRet := '<ListOfInternalId>'
								cXmlRet += 	'<InternalId>'
								cXmlRet +=			'<Name>' + cMsgUnica + '</Name>'
								cXmlRet +=			'<Origin>' + cExtID + '</Origin>'
								cXmlRet +=			'<Destination>' + cIntID + '</Destination>'
								cXmlRet += 	'</InternalId>'
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