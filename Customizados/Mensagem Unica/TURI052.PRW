#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI052

Funcao de integracao do Cadastro de Linhas e Trechos
Mensagem única - RoadLineStretch

@sample	TURI052(cXml, cTypeTrans, cTypeMessage)
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
@since		30/10/2015
@version 	P12.1.8
/*/
//------------------------------------------------------------------------------------------
Function TURI052(cXml, nTypeTrans, cTypeMessage)

Local lRet       := .T. 
Local cEvento    := 'upsert'
Local cAdapter   := 'TURA052'
Local cMsgUnica  := 'RoadLineStretch'
Local cMarca     := 'PROTHEUS'
Local cVersao    := ''
Local cAlias     := 'G8M'
Local cCampo     := 'G8M_CODIGO'
Local oXML       := tXMLManager():New()
Local oModel     := NIL
Local oModelCab  := NIL
Local oModelDet  := NIL
Local aDetalhe   := {}
Local cBusiCont  := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cListItens := '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfStretches/Stretch'
Local cXmlRet    := ''
Local cXmlItem   := ''
Local cItemNovo  := ''
Local aErro      := {}
Local nX, nCont  := 0
Local nLine      := 0
Local lDelete
Local lMsblql	 := AllTrim(GetSx3Cache("G8M_MSBLQL", "X3_CAMPO")) == "G8M_MSBLQL" //FieldPos('G8M_MSBLQL') > 0 	
Local aIntID	:= {}	
//Variaveis de Controle do Xml
Local cSigla     := ''		
Local cDesc      := ''
Local cForn      := ''		
Local cLoja      := ''		
Local cCityOri   := ''	
Local cCityDes   := ''
Local cDist      := ''		
Local cTime      := ''		
Local cBlocked   := ''	
Local cItemCod   := ''

//Variaveis da Base Interna
Local cIntID     := ''
Local cCodeInt   := ''
Local cVendorId  := ''	
Local cCityOriId := ''
Local cCityDesId := ''

//Variaveis da Base Externa
Local cExtID   := ''

Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt   := Alltrim(oModel:GetValue('G8MMASTER', 'G8M_CODIGO'))
		cSigla     := Alltrim(oModel:GetValue('G8MMASTER', 'G8M_SIGLA') )
		cDesc      := Alltrim(oModel:GetValue('G8MMASTER', 'G8M_DESCR') )
		cForn      := oModel:GetValue('G8MMASTER', 'G8M_CODFOR')
		cLoja      := oModel:GetValue('G8MMASTER', 'G8M_LJFOR') 
		cCityOri   := Alltrim(oModel:GetValue('G8MMASTER', 'G8M_CIDINI'))
		cCityDes   := Alltrim(oModel:GetValue('G8MMASTER', 'G8M_CIDFIM'))
		cDist      := cValToChar(oModel:GetValue('G8MMASTER', 'G8M_DIST'))
		cTime      := cValToChar(oModel:GetValue('G8MMASTER', 'G8M_TEMPO'))
		If lMsblql
			cBlocked   := oModel:GetValue('G8MMASTER', 'G8M_MSBLQL')
		Endif
		cIntID     := TURXMakeId(cCodeInt, 'G8M')
		cVendorId  := IntForExt(,,cForn, cLoja)[2]//TURXMakeId(cForn + '|' + cLoja + '|F', 'SA2')
		cCityOriId := TURXMakeId(cCityOri, 'G5S')
		cCityDesId := TURXMakeId(cCityDes, 'G5S')
		
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
		cXMLRet +=		'<Initials>'+ cSigla + '</Initials>'
		cXMLRet +=		'<Description>' + _NoTags(cDesc) + '</Description>'
		cXMLRet +=		'<VendorCode>' + cForn + '|' + cLoja + '</VendorCode>'             
		cXMLRet +=		'<VendorInternalId>' + cVendorId + '</VendorInternalId>'     
		cXMLRet +=		'<DepartureCity>' + cCityOri + '</DepartureCity>'          
		cXMLRet +=		'<DepartureCityInternalId>' + cCityOriId + '</DepartureCityInternalId>'
		cXMLRet +=		'<ArrivalCity>' + cCityDes + '</ArrivalCity>'            
		cXMLRet +=		'<ArrivalCityInternalId>' + cCityDesId + '</ArrivalCityInternalId>'  
		cXMLRet +=		'<Distance>' + cDist + '</Distance>'               
		cXMLRet +=		'<Minutes>' + cTime + '</Minutes>'                
		If lMsblql
			cXMLRet +=		'<Situation>' + TurXLogic(cBlocked, TP_CHAR1_RET) + '</Situation>'
		Endif

		//Grava ou Exclui o De/Para 
		If lDelete
			CFGA070MNT(NIL, cAlias, cCampo, , cIntID, lDelete)
		Endif
		
		oModelDet := oModel:GetModel("G8NDETAIL")
		If oModelDet:Length(.T.) > 0
			cXmlItem := ""
			For nX := 1 to oModelDet:Length()
				oModelDet:GoLine(nX)
				
				cItemCod	:= oModel:GetValue('G8NDETAIL', 'G8N_CODIGO')
				cCity		:= oModel:GetValue('G8NDETAIL', 'G8N_CIDTRC')
				cDistance	:= cValToChar(oModel:GetValue('G8NDETAIL', 'G8N_DIST'))
				cIntID		:= TURXMakeId(cCodeInt + '|' + cItemCod  , 'G8N')
				cCityId	:= TURXMakeId(cCity, 'G5S')
				
				If (!oModelDet:IsDeleted() .Or. lDelete ).and. !Empty(cCity)
					cXmlItem += '<Stretch>'
					cXmlItem +=	'<ItemCode>' + cItemCod + '</ItemCode>'
					cXmlItem +=	'<ItemInternalId>' + cIntID + '</ItemInternalId>'
					cXmlItem +=	'<StretchCity>' + cCity + '</StretchCity>'
					cXmlItem +=	'<StretchCityInternalId>' + cCityId + '</StretchCityInternalId>'
					cXmlItem +=	'<StretchDistance>' + cDistance + '</StretchDistance>'
					cXmlItem += '</Stretch>'
				Endif

				//Exclui o De/Para
				If oModelDet:IsDeleted() .Or. lDelete
					CFGA070MNT(NIL, 'G8N', 'G8N_CODIGO', , cIntID, .T.)
				Endif
			Next

			If !Empty(cXmlItem)
				cXMLRet += '<ListOfStretches>' + cXmlItem + '</ListOfStretches>'
			Endif
		Endif
		cXMLRet +=	'</BusinessContent>'
		
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
						cName  := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Name')
						cIntID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Origin')
						cExtID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Destination')

						If !Empty(cIntID) .And. !Empty(cExtID)
							If Upper(AllTrim(cName)) == Upper(AllTrim(cMsgUnica))
								CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID)
							Else 
								CFGA070MNT(cMarca, 'G8N', 'G8N_CODIGO', cExtID, cIntID)
							Endif
						Endif
					Next
				Endif
				oXml := NIL
			
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cEvent     := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca     := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID     := AllTrim(oXml:XPathGetNodeValue(cBusiCont     + '/InternalId'))
				cSigla     := AllTrim(oXml:XPathGetNodeValue(cBusiCont     + '/Initials'))
				cDesc      := AllTrim(oXml:XPathGetNodeValue(cBusiCont     + '/Description'))
				cVendorExt := AllTrim(oXml:XPathGetNodeValue(cBusiCont     + '/VendorInternalId'))
				cCityOriEx := AllTrim(oXml:XPathGetNodeValue(cBusiCont     + '/DepartureCityInternalId'))
				cCityDesEx := AllTrim(oXml:XPathGetNodeValue(cBusiCont     + '/ArrivalCityInternalId'))
				cDist      := Val(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Distance')))
				cTime      := Val(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Minutes')))
				cBlocked   := AllTrim(oXml:XPathGetNodeValue(cBusiCont     + '/Situation'))
				cCodeInt   := PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo      , cExtID,     @cIntID, 3)), TamSx3('G8M_CODIGO')[1])
				If (aForn := IntForInt(cVendorExt,cMarca))[1]
					cForn      := PadR(aForn[2][3], TamSx3('G8M_CODFOR')[1])
					cLoja      := PadR(aForn[2][4], TamSx3('G8M_LJFOR')[1])
				Else
					Return aForn
				Endif
				cCityOri   := PadR(AllTrim(TURXRetId(cMarca, 'G5S' , 'G5S_CODIGO', cCityOriEx, NIL    , 3)), TamSx3('G8M_CIDINI')[1])
				cCityDes   := PadR(AllTrim(TURXRetId(cMarca, 'G5S' , 'G5S_CODIGO', cCityDesEx, NIL    , 3)), TamSx3('G8M_CIDFIM')[1])
				
				If Upper(cEvent) == 'UPSERT'
					If !Empty(cIntID) .And. G8M->(DbSeek(xFilial('G8M') + cCodeInt))
						cEvent := MODEL_OPERATION_UPDATE
					Else
						cEvent   := MODEL_OPERATION_INSERT
						cCodeInt := GetSXENum('G8M', 'G8M_CODIGO')
						cIntID	 := TURXMakeId(cCodeInt, 'G8N')
					Endif
				ElseIf Upper(cEvent) == 'DELETE'
					If !Empty(cIntID) .And. G8M->(DbSeek(xFilial('G8M') + cCodeInt))
						cEvent := MODEL_OPERATION_DELETE
						lDelete := .t.
					Else
						lRet    := .F.
						cXmlRet := STR0001	// 'Registro nao encontrado no Protheus.'
					Endif
				EndIf
				
				If lRet
					oModel := FwLoadModel(cAdapter)
					oModel:SetOperation(cEvent)
					G5S->(DBSETORDER(1))
					If oModel:Activate()
						oModelCab := oModel:GetModel('G8MMASTER')
						If cEvent <> MODEL_OPERATION_DELETE
							If cEvent == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G8M_CODIGO', cCodeInt)
							Endif
							oModelCab:SetValue('G8M_DESCR' , cDesc)
							oModelCab:SetValue('G8M_SIGLA' , cSigla)
							oModelCab:SetValue('G8M_CODFOR', cForn)
							oModelCab:SetValue('G8M_LJFOR' , cLoja)
							oModelCab:SetValue('G8M_CIDINI', cCityOri)
							oModelCab:SetValue('G8M_CIDFIM', cCityDes)
							oModelCab:SetValue('G8M_DIST'  , cDist)
							oModelCab:SetValue('G8M_TEMPO' , cTime)
							If lMsblql
								oModelCab:SetValue('G8M_MSBLQL', TurXLogic(cBlocked, TP_CHAR1_RET))
							endif
						Endif
						aAdd(aIntID,{cMsgUnica,cExtID,cIntID,cAlias,cCampo})
					Else
						lRet := .F.
					Endif

					If lRet
						If (nCont := oXml:xPathChildCount(cBusiCont+'/ListOfStretches') ) > 0
							oModelDet	:= oModel:GetModel('G8NDETAIL')
							cXmlItem := ""
							For nX := 1 To nCont
								If lRet
									cExtIdDet := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/ItemInternalId')
									cCityExt  := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/StretchCityInternalId')
									cDistance := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/StretchDistance')

									cIntID    := ''
									cItemCod  := PadR(AllTrim(TURXRetId(cMarca, 'G8N', 'G8N_CODIGO', cExtIdDet, @cIntID, 4)), TamSx3('G8N_CODIGO')[1])
									cCityId   := PadR(AllTrim(TURXRetId(cMarca, 'G5S', 'G5S_CODIGO', cCityExt , NIL    , 3)), TamSx3('G8N_CIDTRC')[1])
									
									If cEvent <> MODEL_OPERATION_DELETE
										If cEvent == MODEL_OPERATION_INSERT
											cItemCod := StrZero(nX,TamSx3("G8N_CODIGO")[1])
										ElseIf cEvent == MODEL_OPERATION_UPDATE .AND. EMPTY(cItemCod)
											//Pegar o Ultimo Valor e incrementar
											cItemCod := StrZero(Val(oModelDet:GetValue("G8N_CODIGO",oModelDet:Length()))+1,TamSx3("G8N_CODIGO")[1])
										Endif
										
										If !oModelDet:SeekLine({{'G8N_CODIGO', cItemCod}})
											If !Empty(oModel:GetValue('G8NDETAIL', 'G8N_CODIGO'))
												nLine := oModelDet:AddLine()
												oModelDet:GoLine(nLine)
											Endif
											oModelDet:SetValue('G8N_CODIGO', cItemCod)
										Endif
										
										oModelDet:SetValue('G8N_CIDTRC', cCityId)
										oModelDet:SetValue('G8N_DIST'  , Val(cDistance))
									Endif
									
									If 	!oModelDet:VldLineData()
										lRet := .F.
									Else
										cIntID   := TURXMakeId(cCodeInt + '|' + cItemCod, 'G8N')
										aAdd(aIntID,{'Stretches',cExtIdDet,cIntID,'G8N','G8N_CODIGO'})
										aAdd(aDetalhe, cItemCod)
									EndIf
								EndIf
							Next
							
							If lRet
								For nX := 1 To oModelDet:Length()
									oModelDet:GoLine(nX)
									If aScan(aDetalhe, AllTrim(oModel:GetValue('G8NDETAIL', 'G8N_CODIGO'))) == 0 .And. cEvent <> MODEL_OPERATION_DELETE    
										oModelDet:DeleteLine()
										cItemCod := AllTrim(oModel:GetValue('G8NDETAIL', 'G8N_CODIGO'))
										cIntID   := TURXMakeId(cCodeInt + '|' + cItemCod, 'G8N')
										CFGA070MNT(NIL, 'G8N', 'G8N_CODIGO', , cIntID, .T.)
									Endif	
								Next
							EndIf
						Endif
					Endif
		
					If lRet .And. oModel:VldData() .And. oModel:CommitData()
						ConfirmSX8()
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
						If !Empty(aErro)
							cErro := STR0002 	// 'A integração não foi bem sucedida.'
							cErro += STR0003 + AllTrim(aErro[5]) + '-' + AllTrim(aErro[6])	// 'Foi retornado o seguinte erro: '
							If !Empty(AllTrim(aErro[7]))
								cErro += STR0005 + AllTrim(aErro[7])	// 'Solução - '
							Endif
						Else
							cErro := STR0002 		// 'A integração não foi bem sucedida.'
							cErro += STR0004 		// 'Verifique os dados enviados.'
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