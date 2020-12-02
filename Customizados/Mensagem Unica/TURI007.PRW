#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI007

Função de integração do Cadastro de Agentes de Viagem
Mensagem única - TravelAgent

@sample	TURI007(cXml, cTypeTrans, cTypeMessage)
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
@version 	P12.1.8
/*/
//------------------------------------------------------------------------------------------
Function TURI007(cXml, nTypeTrans, cTypeMessage)

Local lRet       := .T. 
Local cEvento    := 'upsert'
Local cAdapter   := 'TURA007'
Local cMsgUnica  := 'TRAVELAGENT'
Local cMarca     := 'PROTHEUS'
Local cVersao    := ''
Local cName      := ''
Local cAlias     := 'G3H'
Local cCampo     := 'G3H_CODAGE'
Local oXML       := tXMLManager():New()
Local oModel     := NIL
Local oModelCab  := NIL
Local oModelDet  := NIL
Local aDetalhe   := {}
Local cBusiCont  := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cListItens := '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfServiceStation/ServiceStation'
Local aMldDet    := { 'G3IDETAIL', 'G3IEVENTO', 'G3ILAZER' }
Local cXmlRet    := ''
Local cXmlItem   := ''
Local cItemNovo  := ''
Local aErro      := {}
Local aMsgUnic   := Nil
Local nX, nCont  := 0
Local nLine      := 0
Local nAux       := 0
Local lDelete
Local lMsblql	:= AllTrim(GetSx3Cache("G3H_MSBLQL", "X3_CAMPO")) == "G3H_MSBLQL" //FieldPos('G3H_MSBLQL') > 0
		
//Variaveis DE/PARA
Local cIntID     := ''
Local cExtID     := ''
Local cPostoID   := ''

//Variaveis de Controle do Xml		
Local cCodeInt   := ''
Local cCodeExt   := ''
Local cTpAgnt    := ''
Local cIntCode   := ''
Local cTpACorp   := ''
Local cTpAEvent  := ''
Local cTpARecr   := ''
Local cBlocked   := ''
Local cItemCod   := ''
Local cPstCode   := ''
Local cTpSegmt   := ''
Local cTpSegAux  := ''

Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt  := AllTrim(oModel:GetValue('G3HMASTER', 'G3H_CODAGE'))
		cName     := AllTrim(oModel:GetValue('G3HMASTER', 'G3H_NOMEAG'))
		cTpAgnt   := TURXLogic(oModel:GetValue('G3HMASTER', 'G3H_TIPO'), TP_CHAR1_RET)
		cIntCode  := AllTrim(oModel:GetValue('G3HMASTER', 'G3H_INTEGR'))
		cTpACorp  := AllTrim(oModel:GetValue('G3HMASTER', 'G3H_TPATCO'))
		cTpAEvent := AllTrim(oModel:GetValue('G3HMASTER', 'G3H_TPATEV'))
		cTpARecr  := AllTrim(oModel:GetValue('G3HMASTER', 'G3H_TPATLZ'))
		If lMsblql
			cBlocked  := TURXLogic(oModel:GetValue('G3HMASTER', 'G3H_MSBLQL'), TP_CHAR1_RET)
		Endif
		cIntID	   := TURXMakeId(cCodeInt, 'G3H')

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
		cXMLRet +=		'<Name>' + _NoTags(cName) + '</Name>'
		cXMLRet +=		'<TypeOfAgent>' + cTpAgnt + '</TypeOfAgent>'
		cXMLRet +=		'<IntegrationCode>' + cIntCode + '</IntegrationCode>'
		cXMLRet +=		'<TypeOfAttendanceCorporate>' + cTpACorp + '</TypeOfAttendanceCorporate>'
		cXMLRet +=		'<TypeOfAttendanceEvent>' + cTpAEvent + '</TypeOfAttendanceEvent>'
		cXMLRet +=		'<TypeOfAttendanceRecreation>' + cTpARecr + '</TypeOfAttendanceRecreation>'
		If lMsblql
			cXMLRet +=		'<Situation>' + cBlocked + '</Situation>'
		Endif

		//Grava ou Exclui o De/Para 
		If lDelete
			CFGA070MNT( NIL, cAlias, cCampo, , cIntID,lDelete)
		Endif
		
		If oModel:GetModel('G3IDETAIL'):Length(.T.) > 0 .Or. oModel:GetModel('G3IEVENTO'):Length(.T.) > 0 .Or. oModel:GetModel('G3ILAZER'):Length(.T.) > 0
			For nCont := 1 to Len(aMldDet)
				For nX := 1 to oModel:GetModel(aMldDet[nCont]):Length()
					cPstCode	:= AllTrim(oModel:GetModel(aMldDet[nCont]):GetValue('G3I_POSTO', nX))
					cFilPst		:= AllTrim(oModel:GetModel(aMldDet[nCont]):GetValue('G3I_FILPST', nX))
					If !Empty(cPstCode)
						cTpSegmt := cValToChar(nCont)
						cIntID   := TURXMakeId(cPstCode, 'G3M',nil,cFilPst )
							
						If !oModel:GetModel(aMldDet[nCont]):IsDeleted(nX) .Or. lDelete //Se Altera/Inclui a linha estiver deletada, nao manda Lista de Itens -- Se for Exclusao manda a linha para controle
							cXmlItem += '<ServiceStation>'
							cXmlItem += 	'<ServiceStationCode>' + cPstCode + '</ServiceStationCode>'
							cXmlItem +=		'<ServiceStationSegment>' + cTpSegmt + '</ServiceStationSegment>'
							cXmlItem +=		'<ServiceStationInternalId>' + cIntID + '</ServiceStationInternalId>'
							cXmlItem += '</ServiceStation>'
						Endif
					Endif
				Next
			Next

			If !Empty(cXmlItem)
				cXMLRet +=	'<ListOfServiceStation>' + cXmlItem + '</ListOfServiceStation>'
			Else
				cXMLRet +=	'<ListOfServiceStation/>'
			Endif
		Endif
		cXMLRet +=	'</BusinessContent>'
		
	Case nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
			
			//resposta da mensagem Única TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				If Empty(oXml:Error())
					aMsgUnic := {}
					TI007Ents(aMsgUnic)
					cMarca	:= oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
					For nX := 1 to oXml:xPathChildCount('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId')
						cName  := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Name')
						cIntID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Origin')
						cExtID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Destination')
						If !Empty(cIntID) .and. !Empty(cExtID)
							If (nPos := aScan(aMsgUnic,{|x| Upper(Alltrim(x[1])) == AllTrim(cName)})) > 0
								CFGA070MNT(cMarca, aMsgUnic[nPos][2], aMsgUnic[nPos][3], cExtID, cIntID)
							EndIf
						EndIf
					Next
				Endif
				oXml:=Nil

			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)

				cEvento   := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca    := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cCodeExt  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Code'))
				cExtID    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cName     := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Name'))
				cTpAgnt   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TypeOfAgent'))
				cIntCode  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/IntegrationCode'))
				cTpACorp  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TypeOfAttendanceCorporate'))
				cTpAEvent := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TypeOfAttendanceEvent'))
				cTpARecr  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TypeOfAttendanceRecreation'))
				cBlocked  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				
				cCodeInt  := PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo, cExtID, @cIntID, 3)), TamSx3('G3H_CODAGE')[1])
					
				If Upper(cEvento) == 'UPSERT'
					If !Empty(cIntID) .And. G3H->(DbSeek(xFilial('G3H') + cCodeInt))
						cEvento := MODEL_OPERATION_UPDATE
					Else
						cEvento  := MODEL_OPERATION_INSERT
						cCodeInt := cCodeExt
						cIntID   := TURXMakeId(cCodeInt, 'G3H')
					Endif
				ElseIf Upper(cEvento) == 'DELETE'
					If !Empty(cIntID) .And. G3H->(DbSeek(xFilial('G3H') + cCodeInt))
						cEvento := MODEL_OPERATION_DELETE
					Else
						lRet    := .F.
						cXmlRet := STR0001 //'Registro nao encontrado no Protheus.'
					Endif
				EndIf				
				If lRet
					oModel := FwLoadModel(cAdapter)
					oModel:SetOperation(cEvento)
					If oModel:Activate()
						oModelCab := oModel:GetModel('G3HMASTER')
						If cEvento <> MODEL_OPERATION_DELETE
							If cEvento == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G3H_CODAGE', cCodeInt)
							Endif

							oModelCab:SetValue('G3H_NOMEAG', cName)
							oModelCab:SetValue('G3H_TIPO'  , TURXLogic(cTpAgnt, TP_CHAR1_RET))
							oModelCab:SetValue('G3H_INTEGR', cIntCode)
							oModelCab:SetValue('G3H_TPATCO', cTpACorp )
							oModelCab:SetValue('G3H_TPATEV', cTpAEvent)
							oModelCab:SetValue('G3H_TPATLZ', cTpARecr )
							If lMsblql
								oModelCab:SetValue('G3H_MSBLQL', TURXLogic(cBlocked, TP_CHAR1_RET))
							Endif
						Endif
					Else
						lRet := .F.
					Endif
	
					If lRet
						If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfServiceStation') ) > 0
							For nX := 1 To nCont
								If lRet
									cPostoID	:= oXml:XPathGetNodeValue(cListItens+"["+ cValToChar(nX) +"]/ServiceStationInternalId")
									cTpSegmt	:= oXml:XPathGetNodeValue(cListItens+"["+ cValToChar(nX) +"]/ServiceStationSegment")
									cItemCod	:= padr(Alltrim(TURXRetId(cMarca, "G3M", "G3M_CODIGO",cPostoID,@cIntID	,3)),TamSx3("G3M_CODIGO")[1] )
									cFilPst		:= padr(Alltrim(TURXRetId(cMarca, "G3M", "G3M_CODIGO",cPostoID,nil		,2)),TamSx3("G3I_FILPST")[1] )
								
									If cEvento <> MODEL_OPERATION_DELETE 
										If !oModel:GetModel(aMldDet[Val(cTpSegmt)]):SeekLine({{"G3I_FILPST",cFilPst},{"G3I_POSTO",cItemCod}})
											If !Empty(oModel:GetValue(aMldDet[Val(cTpSegmt)],"G3I_POSTO"))
												nLine := oModel:GetModel(aMldDet[Val(cTpSegmt)]):AddLine()
												oModel:GetModel(aMldDet[Val(cTpSegmt)]):GoLine(nLine)
											Endif
											oModel:GetModel(aMldDet[Val(cTpSegmt)]):SetValue("G3I_FILPST"	,cFilPst)
											oModel:GetModel(aMldDet[Val(cTpSegmt)]):SetValue("G3I_POSTO"	,cItemCod)
	
										EndIf
										
									Endif
									
									If 	!oModel:GetModel(aMldDet[Val(cTpSegmt)]):VldLineData()
										lRet := .F.
									Else
										aAdd(aDetalhe, cTpSegmt + cFilPst + cItemCod)
									EndIf
								EndIf
							Next

							If lRet
								For nCont := 1 to Len(aMldDet)
									For nX := 1 to oModel:GetModel(aMldDet[nCont]):Length()
										cPstCode := oModel:GetModel(aMldDet[nCont]):GetValue('G3I_POSTO', nX)
										cFilPst  := oModel:GetModel(aMldDet[nCont]):GetValue('G3I_FILPST', nX)
										cTpSegmt := cValToChar(nCont)
										If !Empty(cPstCode) .And. aScan(aDetalhe, cTpSegmt + cFilPst + cPstCode) == 0 .And. cEvento <> MODEL_OPERATION_DELETE 
											oModel:GetModel(aMldDet[nCont]):GoLine(nX)   
											oModel:GetModel(aMldDet[nCont]):DeleteLine()
										Endif	
									Next
								Next
							Endif
						EndIf
					Endif

					If lRet .And. oModel:VldData() .And. oModel:CommitData()
						cIntID := TURXMakeId(cCodeInt, 'G3H')
						CFGA070MNT(cMarca, cAlias,cCampo, cExtID, cIntID, cEvento == MODEL_OPERATION_DELETE)
						If cEvento <> MODEL_OPERATION_DELETE
							cXmlRet := '<ListOfInternalId>'
							cXmlRet += 	'<InternalId>'
							cXmlRet +=		'<Name>' + cMsgUnica + '</Name>'
							cXmlRet +=		'<Origin>' + cExtID + '</Origin>'
							cXmlRet +=		'<Destination>' + cIntID + '</Destination>'
							cXmlRet +=		'</InternalId>'
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

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} TI007Ents(aMsgUnic)
Função utilizada para preencher o Array que contem os dados do de/para

@type 		Function
@author 	Jacomo Lisa
@since 		28/10/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Function TI007Ents(aMsgUnic)

aAdd(aMsgUnic, {"TRAVELAGENT"   , "G3H", "G3H_CODAGE"})
aAdd(aMsgUnic, {"SERVICESTATION", "G3M", "G3M_CODIGO"})

Return