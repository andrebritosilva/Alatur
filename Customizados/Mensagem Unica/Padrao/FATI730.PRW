#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FATI730

Função de integração do Cadastro de Grupo Societário
Mensagem única - CorporateGroup

@sample		FATI730(cXml, cTypeTrans, cTypeMessage)
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transação
				0 - para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				1 - para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				20 - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				21 - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				22 - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				23 - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return		lRet - Variável lógica, indicando se o processamento foi executado com sucesso (.T.) ou não (.F.) 
			cXMLRet - String com o XML de retorno
			cMsgUnica - String com o nome da Mensagem Unica
@author 	Jacomo Lisa
@since		22/09/2015
@version 	P12.1.8
/*/
//------------------------------------------------------------------------------------------
Function FATI730(cXml, nTypeTrans, cTypeMessage)

Local lRet       := .T. 
Local cEvento    := 'upsert'
Local cAdapter   := 'FATA730'
Local cMsgUnica  := 'CorporateGroup'
Local cMarca     := 'PROTHEUS'
Local cAlias     := 'AGT'
Local cCampo     := 'AGT_CODIGO'
Local oXML       := tXMLManager():New()
Local oModel     := NIL
Local oModelCab  := NIL
Local oModelDet  := NIL
Local aDetalhe   := nil
Local cBusiCont  := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cListItens := '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfCorporateGroup/CorporateGroup'
Local cXmlRet    := ''
Local cXmlItem   := ''
Local aErro      := nil
Local nX, nCont  := 0
Local nLine      := 0
Local lDelete    := .F.
Local lMsblql    := AllTrim(GetSx3Cache("AGT_MSBLQL", "X3_CAMPO")) == "AGT_MSBLQL"
Local cIntId     := ''
Local cExtID     := ''
Local cCodInt    := ''
Local cDesc      := ''
Local cCliente   := ''
Local cLoja      := ''
Local nOpc       := 0
Local aIntID     := {}
Local aCliente   := {}
Local cMsgErro   := ""
Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf

		cCodInt	:= AllTrim(oModel:GetValue('AGTMASTER', 'AGT_CODIGO'))
		cDesc	:= AllTrim(oModel:GetValue('AGTMASTER', 'AGT_DESCRI'))
		
		If lMsblql
			cBlocked  := TURXLogic(oModel:GetValue('AGTMASTER', 'AGT_MSBLQL'), TP_CHAR1_RET)	
		Endif
		
		cIntID	  := TURXMakeId(cCodInt, 'AGT')
		
		//Monta XML de envio de mensagem unica
		cXMLRet := FWEAIBusEvent( cMsgUnica,oModel:GetOperation(), { { "InternalId", cIntID } } ) 
		
		cXMLRet +=	'<BusinessContent>'
		cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=		'<Code>' + cCodInt  + '</Code>'
		cXMLRet +=		'<InternalId>' + cIntID + '</InternalId>'
		cXMLRet +=		'<Description>' + _NoTags(cDesc) + '</Description>'
		If lMsblql
			cXMLRet +=		'<Situation>' + cBlocked + '</Situation>'//Logico
		Endif
		
		If ExistBlock("FATI030SECAP")
			cXmlPERet := ExecBlock("FATI030SECAP",.F.,.F.,{cXMLRet,cEvento,oModel})
			If ValType(cXmlPERet) == "C"
				cXMLRet +=cXmlPERet
			EndIf
		EndIf
		
		//Grava ou Exclui o De/Para 
		If lDelete
			CFGA070MNT(cMarca, 'AGT', 'AGT_CODIGO', , cIntID, lDelete)
		Endif
		
		oModelDet := oModel:GetModel('AGUDETAIL')
		If oModelDet:Length() > 0
			cXmlItem :=	""
			For nX := 1 to oModelDet:Length()
				oModelDet:GoLine(nX)
				
				If !oModelDet:IsDeleted() .Or. lDelete 
					cXmlItem += '<CorporateGroup>'
					cXmlItem += 	'<CustomerVendorCode>' + oModel:GetValue('AGUDETAIL', 'AGU_CODCLI') + '|' + oModel:GetValue('AGUDETAIL', 'AGU_LOJCLI') + '|C' + '</CustomerVendorCode>'
					cXmlItem +=		'<CustomerVendorInternalId>' + IntCliExt(,, oModel:GetValue('AGUDETAIL', 'AGU_CODCLI'), oModel:GetValue('AGUDETAIL', 'AGU_LOJCLI') ,"2.000")[2] + '</CustomerVendorInternalId>'
					
					If ExistBlock("FATI030SEDET")
						cXmlPERet := ExecBlock("FATI030SEDET",.F.,.F.,{cXMLRet,cEvento,oModel})
						If ValType(cXmlPERet) == "C"
							cXmlItem += cXmlPERet
						EndIf
					EndIf
					
					cXmlItem += '</CorporateGroup>'
				Endif
			Next
			If !Empty(cXmlItem)
				cXMLRet += '<ListOfCorporateGroup>'+cXmlItem +'</ListOfCorporateGroup>'
			EndIf	
		Endif
		cXMLRet += '</BusinessContent>'
		
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
						cName  := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Name')
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
				cEvento		:= AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca		:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cDesc		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Description'))
				cBlocked	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				aDetalhe	:= {}
				cCodInt		:= PadR(AllTrim(TURXRetId(cMarca, 'AGT', 'AGT_CODIGO'    , cExtID  , @cIntId, 3)), TamSx3('AGT_CODIGO')[1])
				If Empty(cCodInt)
					cCodInt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Code'))
					cIntId	:= TURXMakeId(cCodInt, 'AGT') 
				Endif
				If Upper(cEvento) == 'UPSERT'
					If AGT->(DbSeek(xFilial('AGT') + cCodInt))
						nOpc := MODEL_OPERATION_UPDATE
					Else
						nOpc := MODEL_OPERATION_INSERT
					Endif
				ElseIf Upper(cEvento) == 'DELETE'
					If AGT->(DbSeek(xFilial('AGT') + cCodInt))
						nOpc := MODEL_OPERATION_DELETE
						lDelete := .T.
					Else
						lRet    := .F.
						cMsgErro := STR0001 	// "Registro nao encontrado no Protheus."
					Endif
				EndIf
				
				If lRet
					oModel	:= FwLoadModel(cAdapter)
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oModelCab := oModel:GetModel('AGTMASTER')
						If nOpc <> MODEL_OPERATION_DELETE
							If nOpc == MODEL_OPERATION_INSERT
								oModelCab:SetValue('AGT_CODIGO'  , cCodInt)
							Endif
							oModelCab:SetValue('AGT_DESCRI'  , cDesc)
							If lMsblql
								oModelCab:SetValue('AGT_MSBLQL'	, TURXLogic(cBlocked, TP_CHAR1_RET))
							Endif
							If ExistBlock("FATI030RECAP")
								ExecBlock("FATI030RECAP",.F.,.F.,{oXml,nOpc,oModelCab})
							EndIf
						Endif
						aAdd(aIntID,{cMsgUnica,cExtID,cIntID,cAlias,cCampo})
					Else
						lRet := .F.
					Endif

					If lRet
						If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfCorporateGroup') ) > 0
							oModelDet := oModel:GetModel('AGUDETAIL')
							
							For nX := 1 To nCont
								If lRet
									cExtId  := AllTrim(oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/CustomerVendorInternalId'))
									If (aCliente := IntCliInt(cExtID,cMarca))[1] 
										cCliente	:= PadR(aCliente[2][3], TamSx3('A1_COD')[1])
										cLoja		:= PadR(aCliente[2][4], TamSx3('A1_LOJA')[1])
									Else
										lRet     := .F.
										cMsgErro := aCliente[2]
									Endif
									
									If lRet .and. !lDelete 
										If !oModelDet:SeekLine({{'AGU_CODCLI', cCliente}, {'AGU_LOJCLI',cLoja}})
											If !Empty(oModel:GetValue('AGUDETAIL',"AGU_CODCLI"))
												nLine := oModelDet:AddLine()
												oModelDet:GoLine(nLine)
											Endif
											oModelDet:SetValue('AGU_CODCLI', cCliente)
											oModelDet:SetValue('AGU_LOJCLI', cLoja)
											If ExistBlock("FATI030RECAP")
												ExecBlock("FATI030RECAP",.F.,.F.,{oXml,nOpc,oModelDet})
											EndIf
										EndIf
									Endif
								
									If  (lRet .and. !oModelDet:VldLineData()) .or. !lRet
										lRet := .F.
									Else
										aAdd(aDetalhe, cCliente+cLoja)
									EndIf
								EndIf
							Next
							
							If lRet
								For nX := 1 To oModelDet:Length()
									oModelDet:GoLine(nX)
									If !lDelete .and. aScan(aDetalhe, oModel:GetValue('AGUDETAIL', 'AGU_CODCLI') + oModel:GetValue('AGUDETAIL', 'AGU_LOJCLI') ) == 0
										oModelDet:DeleteLine()
									Endif	
								Next
							EndIf
						Endif
					Endif
		
					If lRet .And. oModel:VldData() .And. oModel:CommitData()
						cXmlRet := ""
						For nX := 1 To Len(aIntID) 
							cXmlRet+=	'<InternalId>'
							cXmlRet+=		'<Name>'+aIntID[nX][1]+'</Name>'
							cXmlRet+=		'<Origin>'+aIntID[nX][2]+'</Origin>'
							cXmlRet+=		'<Destination>'+aIntID[nX][3]+'</Destination>'
							cXmlRet+=	'</InternalId>'
//							CFGA070MNT( cMarca, cAlias, cCampo, cExtID, cIntID,lDelete)
							CFGA070MNT( cMarca, aIntID[nX][4], aIntID[nX][5], aIntID[nX][2], aIntID[nX][3],lDelete)
						Next
						If !lDelete .and. !Empty(cXmlRet)
							cXmlRet:="<ListOfInternalId>" +cXmlRet+ "</ListOfInternalId>"
						Endif
					Else
						aErro := oModel:GetErrorMessage()
						If !Empty(cMsgErro)
							cErro := STR0002 		//'A integração não foi bem sucedida.'
							cErro += STR0003 + cMsgErro //'Foi retornado o seguinte erro: '
						ElseIf !Empty(aErro)
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
TxDestroy(oXml)
TxDestroy(aDetalhe)
TxDestroy(aIntID)
TxDestroy(aCliente)
Return {lRet, cXMLRet, cMsgUnica}