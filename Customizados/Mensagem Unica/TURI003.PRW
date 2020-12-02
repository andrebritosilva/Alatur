#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI003

Função de integração do Cadastro de Classes de Serviços
Mensagem única - ServiceClass

@sample	TURI003(cXml, cTypeTrans, cTypeMessage)
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transação
				0 - para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				1 - para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				20 - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				21 - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				22 - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				23 - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return		lRet - Variável lógica, indicando se o processamento foi executado com sucesso (.T.) ou nÃ£o (.F.) 
			cXMLRet - String com o XML de retorno
			cMsgUnica - String com o nome da Mensagem Unica
@author 	Jacomo Lisa
@since		22/09/2015
@version 	P12.1.8
/*/
//------------------------------------------------------------------------------------------
Function TURI003(cXml, nTypeTrans, cTypeMessage)

Local lRet      := .T. 
Local cEvento   := 'upsert'
Local cAdapter  := 'TURA003'
Local cMsgUnica := 'SERVICECLASS'
Local cMarca    := 'PROTHEUS'
Local cAlias    := 'G3C'
Local cCampo    := 'G3C_CODIGO'
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
Local cFornID   := ''

//Variaveis de controle
Local cCodeInt  := ''
Local cCodeExt  := ''
Local cDesc     := ''
Local cForn     := ''
Local cLoja     := ''
Local cBlocked  := ''
Local aForn		:= Nil
Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt := AllTrim(oModel:GetValue('G3CMASTER', 'G3C_CODIGO'))
		cForn    := oModel:GetValue('G3CMASTER', 'G3C_CODFOR')
		cLoja    := oModel:GetValue('G3CMASTER', 'G3C_LJFOR')
		cDesc    := AllTrim(oModel:GetValue('G3CMASTER', 'G3C_DESCR'))
		cBlocked := TURXLogic(oModel:GetValue('G3CMASTER', 'G3C_MSBLQL'), TP_CHAR1_RET)
		cIntID   := TURXMakeId(Alltrim(cForn) + '|' + Alltrim(cLoja) + '|' + Alltrim(cCodeInt), 'G3C')
		cFornID  := IntForExt(,,cForn,cLoja)[2]//TURXMakeId(cForn + '|' + cLoja + '|F', 'SA2')

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
		cXMLRet +=		'<VendorCode>' + cForn +'|'+ cLoja + '</VendorCode>'
		cXMLRet +=		'<VendorInternalId>' + cFornID + '</VendorInternalId>'
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
				cCodeExt := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Code'))
				cExtID   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cFornID  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/VendorInternalId'))
				cDesc    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Description'))
				cBlocked := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				cCodeInt := PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo  , cExtID , @cIntID, 5)), TamSx3('G3C_CODIGO')[1])
				If (aForn :=IntForInt(cFornID,cMarca) )[1]
					cForn    := PadR(aForn[2][3], TamSx3('G3C_CODFOR')[1])
					cLoja    := PadR(aForn[2][4], TamSx3('G3C_LJFOR' )[1])
				Else
					lRet    := .F. 
					cXmlRet := aForn[2]
				Endif
				TxDestroy(aForn)
				
				G3C->(DbSetOrder(2))
				If lRet
					If Upper(cEvento) == 'UPSERT'
						If !Empty(cIntID) .And. G3C->(DbSeek(xFilial('G3C') + cForn+ cLoja + cCodeInt))
							cEvento := MODEL_OPERATION_UPDATE
						Else
							cEvento  := MODEL_OPERATION_INSERT
							cCodeInt := cCodeExt
							cIntID   := TURXMakeId(Alltrim(cForn)+ '|'+ Alltrim(cLoja) + '|' + cCodeInt, 'G3C')
						Endif
					ElseIf Upper(cEvento) == 'DELETE'
						If !Empty(cIntID) .And. G3C->(DbSeek(xFilial('G3C') + cForn+ cLoja + cCodeInt))
							cEvento := MODEL_OPERATION_DELETE
						Else
							lRet    := .F.
							cXmlRet := STR0001 	// 'Registro não encontrado no Protheus.'
						Endif
					EndIf
				Endif
				If lRet
					oModel := FwLoadModel(cAdapter)
					oModel:SetOperation(cEvento)
					If oModel:Activate()
						oModelCab := oModel:GetModel('G3CMASTER')
						If cEvento <> MODEL_OPERATION_DELETE
							If cEvento== MODEL_OPERATION_INSERT
								oModelCab:SetValue('G3C_CODIGO', cCodeInt)
								oModelCab:SetValue('G3C_CODFOR', cForn)
								oModelCab:SetValue('G3C_LJFOR' , cLoja)
							Endif
							oModelCab:SetValue('G3C_DESCR' , cDesc)
							oModelCab:SetValue('G3C_MSBLQL', TURXLogic(cBlocked, TP_CHAR1_RET))
						Endif

						If oModel:VldData() .And. oModel:CommitData()
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID, cEvento== MODEL_OPERATION_DELETE)
							If cEvento <> MODEL_OPERATION_DELETE
								cXmlRet += '<ListOfInternalId>'
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
								cErro := STR0002 	// 'A integração não foi bem sucedida.'
								cErro += STR0003 + AllTrim(aErro[5]) + '-' + AllTrim(aErro[6])	// 'Foi retornado o seguinte erro: '
								If !Empty(AllTrim(aErro[7]))
									cErro += STR0005 + AllTrim(aErro[7])	// 'Solução - '
								Endif
							Else
								cErro := STR0002 	// 'A integração não foi bem sucedida.'
								cErro += STR0004 // 'Verifique os dados enviados'
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