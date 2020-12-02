#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI011

Funcao de integracao do Cadastro de Formas de Pagamento
Mensagem Única - TravelPaymentTerm

@sample	TURI055(cXml, cTypeTrans, cTypeMessage)
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				0 - para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				1 - para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				20 - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				21 - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				22 - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				23 - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return	lRet - Variável lógica, indicando se o processamento foi executado com sucesso (.T.) ou naoo (.F.) 
			cXMLRet - String com o XML de retorno
			cMsgUnica - String com o nome da Mensagem Unica
@author 	Jacomo Lisa
@since		22/09/2015
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Function TURI011(cXml, nTypeTrans, cTypeMessage)

Local lRet       := .T. 
Local cEvento    := 'upsert'
Local cAdapter   := 'TURA011'
Local cMsgUnica  := 'TravelPaymentTerm'
Local cMarca     := 'PROTHEUS'
Local cVersao    := ''
Local cAlias     := 'G3N'
Local cCampo     := 'G3N_CODIGO'
Local oXML       := tXMLManager():New()
Local oModel     := NIL
Local oModelCab  := NIL
Local oModelDet  := NIL
Local aDetalhe   := {}
Local cBusiCont  := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cListItens := '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfItens/Itens'
Local cXmlRet    := ''
Local cXmlItem   := ''
Local cItemNovo  := ''
Local aErro      := {}
Local nX, nCont  := 0
Local nLine      := 0
Local lDelete
		
// Variaveis de Controle do Xml
// Cabeçalho		
Local cDesc      := ''
Local lCorp      := .F. 
Local lEvento    := .F.
Local lLazer     := .F. 
Local cBlocked   := ''	
// Itens
Local cItemCod   := ''
Local cType      := ''
Local cPercent   := ''
Local cOricp     := ''
Local cCondcp    := ''
Local cNatcp     := ''
Local cOricr     := ''
Local cCondcr    := ''
Local cNatcr     := ''

//Variaveis da Base Interna
Local cIntID     := ''
Local cCodeInt   := ''

//Variaveis da Base Externa
Local cExtID     := ''
Local cCodeExt   := ''

Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt := oModel:GetValue('G3NMASTER', 'G3N_CODIGO')
		cDesc    := oModel:GetValue('G3NMASTER', 'G3N_DESCR')
		lCorp    := oModel:GetValue('G3NMASTER', 'G3N_CORP') 
		lEvento  := oModel:GetValue('G3NMASTER', 'G3N_EVENTO') 
		lLazer   := oModel:GetValue('G3NMASTER', 'G3N_LAZER') 
		cBlocked := oModel:GetValue('G3NMASTER', 'G3N_MSBLQL')
		cIntID	  := TURXMakeId(cCodeInt, 'G3N')

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
		cXMLRet +=		'<Code>' + cCodeInt  + '</Code>'
		cXMLRet +=		'<InternalId>' + cIntID+ '</InternalId>'
		cXMLRet +=		'<Description>' + _NoTags(AllTrim(cDesc)) + '</Description>'
		cXMLRet +=		'<Corporate>' + TurXLogic(lCorp, TP_CHAR1_RET) + '</Corporate>'
		cXMLRet +=		'<Event>' + TurXLogic(lEvento, TP_CHAR1_RET) + '</Event>'
		cXMLRet +=		'<Recreation>' + 	TurXLogic(lLazer, TP_CHAR1_RET) + '</Recreation>'
		cXMLRet +=		'<Situation>' + TurXLogic(cBlocked, TP_CHAR1_RET) + '</Situation>'

		//Grava ou Exclui o De/Para 
		If lDelete
			CFGA070MNT(NIL, cAlias, cCampo, , cIntID,lDelete)
		Endif
		
		oModelDet := oModel:GetModel('G3ODETAIL')
		If oModelDet:Length() > 0
			cXMLRet += '<ListOfItens>'
			For nX := 1 to oModelDet:Length()
				oModelDet:GoLine(nX)
				
				cItemCod := Alltrim(oModel:GetValue('G3ODETAIL', 'G3O_ITEM'))
				cType    := Alltrim(oModel:GetValue('G3ODETAIL', 'G3O_TIPO'))
				cPercent := cValToChar(oModel:GetValue('G3ODETAIL', 'G3O_PERC'))
				cOricp   := Alltrim(oModel:GetValue('G3ODETAIL', 'G3O_ORICP'))
				cCondcp  := oModel:GetValue('G3ODETAIL', 'G3O_CONDCP')
				cNatcp   := Alltrim(oModel:GetValue('G3ODETAIL', 'G3O_NATCP'))
				cOricr   := Alltrim(oModel:GetValue('G3ODETAIL', 'G3O_ORICR'))
				cCondcr  := oModel:GetValue('G3ODETAIL', 'G3O_CONDCR')
				cNatcr   := Alltrim(oModel:GetValue('G3ODETAIL', 'G3O_NATCR'))
				cIntID   := TURXMakeId(cCodeInt + '|' + cItemCod, 'G3O')
					
				If !oModelDet:IsDeleted() .Or. lDelete //Se Alteracao/Inclusao a linha estiver apagado, nao manda Family -- Se for Exclusao manda a linha para controle
					cXMLRet += '<Itens>'
					cXMLRet +=		'<ItemCode>' + cItemCod + '</ItemCode>'
					cXMLRet +=		'<ItemInternalId>' + cIntID + '</ItemInternalId>'
					cXMLRet +=		'<Type>' + cType + '</Type>'
					cXMLRet +=		'<Percent>' + cPercent + '</Percent>'
					cXMLRet +=		'<PaymentOrigin>' + cOricp + '</PaymentOrigin>'
					cXMLRet +=		'<PaymentConditionCode>' + Alltrim(cCondcp) + '</PaymentConditionCode>'
					cXMLRet +=		'<PaymentConditionInternalId>' + If(!Empty(cCondcp),IntConExt(,,cCondcp)[2],'') + '</PaymentConditionInternalId>'
					cXMLRet +=		'<PaymentNature>' + cNatcp + '</PaymentNature>'
					cXMLRet +=		'<ReceiptOrigin>' + cOricr + '</ReceiptOrigin>'
					cXMLRet +=		'<ReceiptConditionCode>' + Alltrim(cCondcr) + '</ReceiptConditionCode>'
					cXMLRet +=		'<ReceiptConditionInternalId>' + If(!Empty(cCondcr),IntConExt(,,cCondcr)[2],'') + '</ReceiptConditionInternalId>'//TURXMakeId(cCondcr,'SE4')
					cXMLRet +=		'<ReceiptNature>' + cNatcr + '</ReceiptNature>'
					cXMLRet += '</Itens>'
				Endif
				//Exclui o De/Para
				If oModelDet:IsDeleted() .Or. lDelete
					CFGA070MNT( NIL, 'G3O', 'G3O_ITEM', , cIntID, .T.)
				Endif
				
			Next
			cXMLRet += '</ListOfItens>'
		Endif
		cXMLRet += '</BusinessContent>'
		
	Case nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
				
			//resposta da mensagem Única TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				If Empty(oXml:Error())
					cMarca	:= oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
					For nX := 1 to oXml:xPathChildCount('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId')
						cName  := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Name')
						cIntID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Origin')
						cExtID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Destination')
						If !Empty(cIntID) .And. !Empty(cExtID)
							If Upper(AllTrim(cName)) == Upper(AllTrim(cMsgUnica))
								CFGA070MNT( cMarca, cAlias, cCampo, cExtID, cIntID)
							Else 
								CFGA070MNT( cMarca, 'G3O', 'G3O_ITEM', cExtID, cIntID)
							Endif
						Endif
					Next
				Endif
				oXml := NIL
			
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cEvent   := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca   := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cDesc    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Description'))
				lCorp    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Corporate'))
				lEvento  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Event'))
				lLazer   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Recreation'))
				cBlocked := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				cCodeInt := PadR(AllTrim(TURXRetId(cMarca,cAlias,cCampo,cExtID  ,@cIntID,3)),TamSx3('G3N_CODIGO')[1] )
					
				If Upper(cEvent) == 'UPSERT'
					If !Empty(cIntID) .And. G3N->(DbSeek(xFilial('G3N')+ cCodeInt))
						cEvent := MODEL_OPERATION_UPDATE
					Else
						cEvent   := MODEL_OPERATION_INSERT
						cCodeInt := GetSXENum('G3N', 'G3N_CODIGO')
					Endif
									
				ElseIf Upper(cEvent) == 'DELETE'
					If !Empty(cIntID) .And. G3N->(DbSeek(xFilial('G3N')+cCodeInt))
						cEvent := MODEL_OPERATION_DELETE
					Else
						lRet    := .F.
						cXmlRet := STR0001 //'Registro não encontrado no Protheus.'
					Endif
				EndIf
				
				If lRet
					oModel := FwLoadModel(cAdapter)
					oModel:SetOperation(cEvent)
					If oModel:Activate()
						oModelCab := oModel:GetModel('G3NMASTER')
						If cEvent <> MODEL_OPERATION_DELETE
							If cEvent == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G3N_CODIGO', cCodeInt)
							Endif
							oModelCab:SetValue('G3N_DESCR' , cDesc)
							oModelCab:SetValue('G3N_CORP'  , TurXLogic(lCorp   , TP_LOGIC_RET))
							oModelCab:SetValue('G3N_EVENTO', TurXLogic(lEvento , TP_LOGIC_RET))
							oModelCab:SetValue('G3N_LAZER' , TurXLogic(lLazer  , TP_LOGIC_RET))
							oModelCab:SetValue('G3N_MSBLQL', TurXLogic(cBlocked, TP_CHAR1_RET))
						Endif
					Else
						lRet := .F.
					Endif
					
					If lRet
						If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfItens') ) > 0
							oModelDet	:= oModel:GetModel('G3ODETAIL')
							
							For nX := 1 To nCont
								If lRet
									cExtIdDet := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/ItemInternalId')
									cType     := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/Type')
									cPercent  := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/Percent')
									cOricp    := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/PaymentOrigin')
									cCondcp   := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/PaymentConditionInternalId')
									cNatcp    := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/PaymentNature')
									cOricr    := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/ReceiptOrigin')
									cCondcr   := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/ReceiptConditionInternalId')
									cNatcr    := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/ReceiptNature')
									cIntID    := ''
									
									cItemCod  := PadR(AllTrim(TURXRetId(cMarca, 'G3O', 'G3O_ITEM'	, cExtIdDet	, @cIntID	, 4)), TamSx3('G3O_ITEM')[1])
									If !Empty(cCondcp)
										If (aCondCP:= IntConInt(cCondcp, cMarca,))[1]
											cCondcp   := PadR(aCondCP[2][3], TamSx3('G3O_CONDCP')[1])
										Else
											Return aCondCP 
										Endif
									Endif
									If !Empty(cCondcr)
										If (aCondCR:= IntConInt(cCondcr, cMarca,))[1]
											cCondcr   := PadR(aCondCR[2][3], TamSx3('G3O_CONDCR')[1])
										Else
											Return aCondCR
										Endif
									Endif
									If cEvent <> MODEL_OPERATION_DELETE
										If cEvent == MODEL_OPERATION_INSERT
											cItemCod := StrZero(nX, TamSx3('G3O_ITEM')[1])
										ElseIf cEvent == MODEL_OPERATION_UPDATE .And. EMPTY(cItemCod)  
											//Pegar o Ultimo Valor e incrementar
											If Empty(cItemNovo)
												cItemCod := cItemNovo := StrZero(Val(oModelDet:GetValue('G3O_ITEM', oModelDet:Length())) + 1, TamSx3('G3O_ITEM')[1])
											Else 
												cItemCod := cItemNovo := StrZero(Val(cItemNovo) + 1, TamSx3('G3O_ITEM')[1])
											EndIf
										Endif
										
										If !oModelDet:SeekLine({{'G3O_CODIGO', cCodeInt}, {'G3O_ITEM', cItemCod}})
											nLine := oModelDet:AddLine()
											oModelDet:GoLine(nLine)
										Endif
										
										If Empty(oModel:GetValue('G3ODETAIL', 'G3O_ITEM'))
											oModelDet:SetValue('G3O_ITEM', cItemCod)
										Endif
										If oModelDet:CanSetValue('G3O_TIPO')
											oModelDet:SetValue('G3O_TIPO'  , cType)
										Endif
										If oModelDet:CanSetValue('G3O_PERC')
											oModelDet:SetValue('G3O_PERC'  , Val(cPercent))
										Endif
										If oModelDet:CanSetValue('G3O_ORICP')
											oModelDet:SetValue('G3O_ORICP' , cOricp)
										Endif
										If oModelDet:CanSetValue('G3O_CONDCP')
											oModelDet:SetValue('G3O_CONDCP', cCondcp)
										Endif
										If oModelDet:CanSetValue('G3O_NATCP')	
											oModelDet:SetValue('G3O_NATCP' , cNatcp)
										Endif
										If oModelDet:CanSetValue('G3O_ORICR')
											oModelDet:SetValue('G3O_ORICR' , cOricr)
										Endif
										If oModelDet:CanSetValue('G3O_CONDCR')
											oModelDet:SetValue('G3O_CONDCR', cCondcr)
										Endif
										If oModelDet:CanSetValue('G3O_NATCR')
											oModelDet:SetValue('G3O_NATCR' , cNatcr)
										Endif
									Endif
									
									If !oModelDet:VldLineData()
										lRet := .F.
									Else
										cIntID := TURXMakeId(cCodeInt+'|'+cItemCod,'G3O')
										cXmlItem += '<InternalId>'
										cXmlItem +=	'<Name>ITENS</Name>'
										cXmlItem +=	'<Origin>' + cExtIdDet + '</Origin>'
										cXmlItem += 	'<Destination>' + cIntID + '</Destination>'
										cXmlItem += '</InternalId>'
										CFGA070MNT(cMarca, 'G3O', 'G3O_ITEM', cExtIdDet, cIntID, cEvent == MODEL_OPERATION_DELETE)
										aAdd(aDetalhe, cItemCod)
									EndIf
								EndIf
							Next
							
							If lRet
								For nX := 1 To oModelDet:Length()
									oModelDet:GoLine(nX)
									If aScan(aDetalhe, oModel:GetValue('G3ODETAIL', 'G3O_ITEM')) == 0 .And. cEvent <> MODEL_OPERATION_DELETE    
										oModelDet:DeleteLine()
										cItemCod := AllTrim(oModel:GetValue('G3ODETAIL', 'G3O_ITEM'))
										cIntID   := TURXMakeId(cCodeInt + '|' + cItemCod, 'G3O')
										CFGA070MNT(NIL, 'G3O', 'G3O_ITEM', , cIntID, .T.)
									Endif	
								Next
							EndIf
						Endif
					Endif
						
		
					If lRet .And. oModel:VldData() .And. oModel:CommitData()
						ConfirmSX8()
						cIntID := TURXMakeId(cCodeInt, 'G3N')
						CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID, cEvent == MODEL_OPERATION_DELETE)
						If cEvent <> MODEL_OPERATION_DELETE
							cXmlRet := '<ListOfInternalId>'
							cXmlRet += 	'<InternalId>'
							cXmlRet += 		'<Name>' + cMsgUnica + '</Name>'
							cXmlRet += 		'<Origin>' + cExtID + '</Origin>'
							cXmlRet += 		'<Destination>' + cIntID + '</Destination>'
							cXmlRet += 	'</InternalId>'
							cXmlRet += 	cXmlItem
							cXmlRet += '</ListOfInternalId>'
						Else
							cXmlRet := ''
						Endif
					Else
						aErro := oModel:GetErrorMessage()
						If !Empty(aErro)
							cErro := STR0002 		//'A integração não foi bem sucedida.'
							cErro += STR0003 + AllTrim(aErro[5]) + '-' + AllTrim(aErro[6]) //'Foi retornado o seguinte erro: '
							If !Empty(AllTrim(aErro[7]))
								cErro += STR0005 + AllTrim(aErro[7]) //'Solução - '
							Endif
						Else
							cErro := STR0002		// 'A integração não foi bem sucedida. '
							cErro += STR0004		// 'Verifique os dados enviados'
						Endif
						aSize(aErro, 0)
						aErro   := NIL
						lRet    := .F.
						cXmlRet := cErro
					Endif
					oModel:Deactivate()
					oModel:Destroy()
				EndIf
		EndCase
EndCase

Return {lRet, cXMLRet, cMsgUnica}