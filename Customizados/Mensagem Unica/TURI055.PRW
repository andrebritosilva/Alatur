#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI055

Funcao de integracao do Cadastro de Classificacao de Cartao
Mensagem única - CardClassification

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
@version 	P12.1.8
/*/
//------------------------------------------------------------------------------------------
Function TURI055(cXml, nTypeTrans, cTypeMessage)

Local lRet       := .T. 
Local cEvento    := 'upsert'
Local cAdapter   := 'TURA055'
Local cMsgUnica  := 'CARDCLASSIFICATION'
Local cMarca     := 'PROTHEUS'
Local cName      := ''
Local cVersao    := ''
Local cAlias     := 'G8Q'
Local cCampo     := 'G8Q_CODIGO'
Local oXML       := tXMLManager():New()
Local oModel     := NIL
Local oModelCab  := NIL
Local oModelDet  := NIL
Local aDetalhe   := {}
Local cBusiCont  := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cListItens := '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfFamily/Family'
Local cXmlRet    := ''
Local cXmlItem   := ''
Local cItemNovo  := ''
Local aErro      := {}
Local nX, nCont  := 0
Local nLine      := 0
Local lDelete
Local lMsblql	:= AllTrim(GetSx3Cache("G8Q_MSBLQL", "X3_CAMPO")) == "G8Q_MSBLQL" //FieldPos('G8Q_MSBLQL') > 0
		
//Variaveis de Controle do Xml		
Local cDesc      := ''
Local cBlocked   := ''	
Local cItemCod   := ''

//Variaveis da Base Interna
Local cIntID     := ''
Local cCodeInt   := ''

//Variaveis da Base Externa
Local cExtID     := ''
Local cExtIdDet  := ''
Local cAuxIdDet  := ''
Local cGrpCode   := ''  

Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt := oModel:GetValue('G8QMASTER', 'G8Q_CODIGO')
		cDesc    := oModel:GetValue('G8QMASTER', 'G8Q_DESCR')
		If lMsblql
			cBlocked := oModel:GetValue('G8QMASTER', 'G8Q_MSBLQL')
		Endif
		cIntID	  := TURXMakeId(cCodeInt, 'G8Q')

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
			cXMLRet +=		'<Situation>' + TurXLogic(cBlocked, TP_CHAR1_RET) + '</Situation>'//Logico
		Endif

		//Grava ou Exclui o De/Para 
		If lDelete
			CFGA070MNT(NIL, cAlias, cCampo, , cIntID, lDelete)
		EndIf
		
		oModelDet := oModel:GetModel('G8RDETAIL')
		If oModelDet:Length(.T.) > 0
			cXmlItem := ''
			For nX := 1 to oModelDet:Length()
				oModelDet:GoLine(nX)
				
				cItemCod := oModel:GetValue('G8RDETAIL', 'G8R_CODGRP')
				cIntID   := IntFamExt(,,cItemCod)[2]//TURXMakeId(cItemCod, 'SBM')
					
				If !oModelDet:IsDeleted() .Or. lDelete //Se Alteração/Inclusão e a linha estiver apagado, não manda Family -- Se for Exclusão manda a linha para controle
					cXmlItem += '<Family>'
					cXmlItem += 	'<FamilyCode>' + cItemCod + '</FamilyCode>'
					cXmlItem +=	'<FamilyInternalId>' + cIntID + '</FamilyInternalId>'
					cXmlItem += '</Family>'
				EndIf
				
			Next

			If !Empty(cXmlItem)
				cXMLRet += '<ListOfFamily>' + cXmlItem + '</ListOfFamily>'
			EndIf
		Else
			cXMLRet += '<ListOfFamily/>'
		EndIf
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
							If Upper(Alltrim(cName)) == Alltrim(cMsgUnica)
								CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID)
							Else 
								CFGA070MNT(cMarca, 'G8R', 'G8R_CODGRP', cExtID, cIntID)
							EndIf
						EndIf
					Next
				EndIf
				oXml := NIL
				
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cEvent		:= AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca		:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cDesc		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Description'))
				cBlocked	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				cCodeInt	:= PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo, cExtID, @cIntID, 3)), TamSx3('G8Q_CODIGO')[1])
					
				If Upper(cEvent) == 'UPSERT'
					If !Empty(cIntID) .And. G8Q->(DbSeek(xFilial('G8Q') + cCodeInt))
						cEvent := MODEL_OPERATION_UPDATE
					Else
						cEvent   := MODEL_OPERATION_INSERT
						cCodeInt := GetSXENum('G8Q', 'G8Q_CODIGO')
					EndIf
				ElseIf Upper(cEvent) == 'DELETE'
					If !Empty(cIntID) .And. G8Q->(DbSeek(xFilial('G8Q') + cCodeInt))
						cEvent := MODEL_OPERATION_DELETE
					Else
						lRet    := .F.
						cXmlRet := STR0001 //'Registro não encontrado no Protheus.'
					EndIf
				EndIf
				
				If lRet
					oModel := FwLoadModel(cAdapter)
					oModel:SetOperation(cEvent)
					If oModel:Activate()
						oModelCab := oModel:GetModel('G8QMASTER')
						If cEvent <> MODEL_OPERATION_DELETE
							If cEvent == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G8Q_CODIGO', cCodeInt)
							EndIf
							oModelCab:SetValue('G8Q_DESCR' , cDesc)
							If lMsblql
								oModelCab:SetValue('G8Q_MSBLQL', TurXLogic(cBlocked, TP_CHAR1_RET))
							Endif
						EndIf
					Else
						lRet := .F.
					EndIf

					If lRet
						If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfFamily') ) > 0
							oModelDet := oModel:GetModel('G8RDETAIL')
							cXmlItem  := ''
							
							For nX := 1 To nCont
								If lRet
									cExtIdDet := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/FamilyInternalId')
									cIntID    := ''
									If (aFamily := IntFamInt(cExtIdDet, cMarca))[1]
										cItemCod  := PadR(aFamily[2][3], TamSx3('G8R_CODGRP')[1])
									Else
										Return aFamily
									Endif
									If cEvent <> MODEL_OPERATION_DELETE
									
										If !oModelDet:SeekLine({{'G8R_CODGRP', cItemCod}})
											If nX > 1  
												nLine := oModelDet:AddLine()
												oModelDet:GoLine(nLine)
											EndIf 
										EndIf
								
										If Empty(oModel:GetValue('G8RDETAIL', 'G8R_CODGRP'))
											oModelDet:SetValue('G8R_CODGRP', cItemCod)
										EndIf
									EndIf
	
									If 	!oModelDet:VldLineData()
										lRet := .F.
									Else
										aAdd(aDetalhe, cItemCod)
									EndIf
								EndIf
							Next
							
							If lRet
								For nX := 1 To oModelDet:Length()
									oModelDet:GoLine(nX)
									If aScan(aDetalhe, AllTrim(oModel:GetValue('G8RDETAIL', 'G8R_CODGRP'))) == 0 .And. cEvent <> MODEL_OPERATION_DELETE    
										oModelDet:DeleteLine()
									EndIf	
								Next
							EndIf
						EndIf
					EndIf
						
					If lRet .And. oModel:VldData() .And. oModel:CommitData()
						ConfirmSX8()
						cIntID := TURXMakeId(cCodeInt, 'G8Q')
						CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID, cEvent == MODEL_OPERATION_DELETE)
						If cEvent <> MODEL_OPERATION_DELETE
							cXmlRet := '<ListOfInternalId>'
							cXmlRet += 	'<InternalId>'
							cXmlRet +=			'<Name>' + cMsgUnica + '</Name>'
							cXmlRet +=			'<Origin>' + cExtID + '</Origin>'
							cXmlRet +=			'<Destination>' + cIntID + '</Destination>'
							cXmlRet += 	'</InternalId>'
							cXmlRet += '</ListOfInternalId>'
						Else
							cXmlRet := ''
						EndIf
					Else
						aErro := oModel:GetErrorMessage()
						If !Empty(aErro)
							cErro := STR0002 		//'A integração não foi bem sucedida.'
							cErro += STR0003 + AllTrim(aErro[5]) + '-' + AllTrim(aErro[6]) //'Foi retornado o seguinte erro: ' 
							If !Empty(AllTrim(aErro[7]))
								cErro += STR0005 + AllTrim(aErro[7]) //'Solução - '
							EndIf
						Else
							cErro := STR0002		// 'A integração não foi bem sucedida. '
							cErro += STR0004		// 'Verifique os dados enviados'
						EndIf
						aSize(aErro, 0)
						aErro   := NIL
						lRet    := .F.
						cXmlRet := cErro
					EndIf
					oModel:Deactivate()
					oModel:Destroy()
				EndIf
		EndCase
EndCase

Return {lRet, cXMLRet, cMsgUnica}