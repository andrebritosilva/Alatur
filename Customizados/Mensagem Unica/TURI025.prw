#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI025

Funcao de integracao do Cadastro de Grupos de Fornecedor
Mensagem única - VendorGroup

@sample	TURI025(cXml, cTypeTrans, cTypeMessage)
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				0 - para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				1 - para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				20 - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				21 - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				22 - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				23 - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return		lRet - Variável lógica, indicando se o processamento foi executado com sucesso (.T.) ou naoo (.F.) 
			cXMLRet - String com o XML de retorno
			cMsgUnica - String com o nome da Mensagem Unica
@author 	Thiago Tavares
@since		29/10/2015
@version 	P12.1.8
/*/
//------------------------------------------------------------------------------------------
Function TURI025(cXml, nTypeTrans, cTypeMessage)

Local aArea			:= GetArea()
Local lRet			:= .T. 
Local cEvento		:= 'upsert'
Local cAdapter		:= 'TURA025'
Local cMsgUnica		:= 'VENDORGROUP'
Local cMarca		:= 'PROTHEUS'
Local cVersao		:= ''
Local cAlias		:= 'G5M'
Local cCampo		:= 'G5M_CODIGO'
Local oXML			:= tXMLManager():New()
Local oModel		:= NIL
Local oModelCab		:= NIL
Local oModelDet		:= NIL
Local aRet			:= {}
Local aDetalhe		:= {}
Local cBusiCont		:= '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cListItens	:= '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfVendor/Vendor'
Local nX,nCont 		:= 0
Local lDelete
Local cXmlRet		:= ''
Local cXmlItem		:= ''
Local aErro			:= {}
Local lMsblql		:= AllTrim(GetSx3Cache("G5M_MSBLQL", "X3_CAMPO")) == "G5M_MSBLQL" //FieldPos('G5M_MSBLQL') > 0		
//Variaveis de Controle do Xml		
Local cDesc		:= ''
Local cTipo		:= ''
Local cPorProd	:= ''
Local cGrpProd	:= ''
Local cBlocked	:= ''
Local cItemCod	:= ''

//Variaveis da Base Interna
Local cIntID	:= ''
Local cCodeInt	:= ''
Local cGrpInt	:= ''
Local cFornInt	:= ''
Local cLojaInt	:= ''

//Variaveis da Base Externa
Local cExtID	:= ''
Local cCodeExt	:= ''
Local cGrpExt	:= ''
Local cFornExt	:= ''

Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt := AllTrim(oModel:GetValue('G5MMASTER', 'G5M_CODIGO'))
		cDesc    := AllTrim(oModel:GetValue('G5MMASTER', 'G5M_DESCR'))
		cTipo    := AllTrim(oModel:GetValue('G5MMASTER', 'G5M_TIPO'))
		cPorProd := AllTrim(oModel:GetValue('G5MMASTER', 'G5M_PORPRD'))
		cGrpProd := oModel:GetValue('G5MMASTER', 'G5M_GRPPRD')
		If lMsblql
			cBlocked := AllTrim(oModel:GetValue('G5MMASTER', 'G5M_MSBLQL'))
		Endif
		cIntID   := TURXMakeId(cCodeInt, 'G5M')
		
		If cPorProd == '1' 
			cGrpInt := IntFamExt(,,cGrpProd)[2]//TURXMakeId(cGrpProd, 'SBM')
		EndIf

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
		cXMLRet +=		'<Description>' + _noTags(cDesc) + '</Description>'
		cXMLRet +=		'<Type>' + cTipo + '</Type>'
		cXMLRet +=		'<PerProduct>' + cPorProd + '</PerProduct>'
		cXMLRet +=		'<FamilyCode>' + Alltrim(cGrpProd) + '</FamilyCode>'
		cXMLRet +=		'<FamilyInternalId>' + cGrpInt + '</FamilyInternalId>'
		If lMsblql
			cXMLRet +=		'<Situation>' + TurXLogic(cBlocked, TP_CHAR1_RET) + '</Situation>'
		Endif
		
		//Grava ou Exclui o De/Para 
		If lDelete
			CFGA070MNT(NIL, cAlias, cCampo, , cIntID, lDelete)
		Endif
		
		oModelDet := oModel:GetModel('G5NDETAIL')
		If oModelDet:Length(.T.) > 0
			cXMLItem := ""
			For nX := 1 To oModelDet:Length()
				oModelDet:goline(nX)

				cFornInt := AllTrim(oModel:GetValue('G5NDETAIL', 'G5N_FORNEC')) 				
				cLojaInt := AllTrim(oModel:GetValue('G5NDETAIL', 'G5N_LOJA'))
				
				// Se Alteração/Inclusão e a linha estiver apagado, não manda  
				// Se Exclusão manda a linha para controle	
				If (!oModelDet:IsDeleted() .or. lDelete) .AND. !Empty(cFornInt + cLojaInt ) 
					cXMLItem +=	'<Vendor>'
					cXMLItem +=		'<VendorCode>' + cFornInt +'|'+ cLojaInt + '</VendorCode>'
					cXMLItem +=		'<VendorInternalId>' + TURXMakeId(cFornInt +'|' + cLojaInt+'|F', 'SA2') + '</VendorInternalId>'
					cXMLItem +=	'</Vendor>'
				Endif
			Next
			If !Empty(cXMLItem) 
				cXMLRet +=	'<ListOfVendor>' + cXMLItem + '</ListOfVendor>'
			EndIf
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
				cEvent   := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca   := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cCodeExt := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Code'))
				cExtID   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cDesc    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Description'))
				cTipo    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Type'))
				cPorProd := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/PerProduct'))
				cGrpExt  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/FamilyInternalId'))
				cBlocked := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				cCodeInt := PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo, cExtID , @cIntID, 3)), TamSx3('G5M_CODIGO')[1])
				If !Empty(cGrpExt)
					If (aFamily := IntFamInt(cGrpExt,cMarca))[1]
						cGrpInt  := PadR(aFamily[2][3], TamSx3('BM_GRUPO')[1])
					Else
						Return aFamily
					Endif
				Endif
					
				G5M->(DbSetOrder(1))
				If Upper(cEvent) == 'UPSERT'
					If !Empty(cIntID) .And. G5M->(DbSeek(xFilial('G5M') + cCodeInt))
						cEvent := MODEL_OPERATION_UPDATE
					Else
						cEvent   := MODEL_OPERATION_INSERT
						cCodeInt := cCodeExt
						cIntID   := TURXMakeId(cCodeInt, 'G5M')
					Endif
				ElseIf Upper(cEvent) == 'DELETE'
					If !Empty(cIntID) .And. G5M->(DbSeek(xFilial('G5M') + cCodeInt))
						cEvent := MODEL_OPERATION_DELETE
					Else
						lRet    := .F.
						cXmlRet := STR0001 	// "Registro não encontrado no Protheus."
					Endif
				EndIf

				If lRet
					oModel := FwLoadModel(cAdapter)
					oModel:SetOperation(cEvent)
					If oModel:Activate()
						// preenchendo os dados do cabecalho
						oModelCab := oModel:GetModel('G5MMASTER')
						If cEvent <> MODEL_OPERATION_DELETE
							If cEvent == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G5M_CODIGO', cCodeInt)
							Endif
							oModelCab:SetValue('G5M_DESCR' , cDesc)
							oModelCab:SetValue('G5M_TIPO'  , cTipo)
							
							If cEvent <> MODEL_OPERATION_UPDATE
								oModelCab:SetValue('G5M_PORPRD', cPorProd)
							Endif
							If cPorProd == '1'
								oModelCab:SetValue('G5M_GRPPRD', cGrpInt)
							EndIf
							If lMsblql
								oModelCab:SetValue('G5M_MSBLQL', TurXLogic(cBlocked, TP_CHAR1_RET))
							Endif
						Endif

						// preenchendo os dados dos itens
						If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfVendor')) > 0
							oModelDet := oModel:GetModel('G5NDETAIL')
							For nX := 1 To nCont
								cFornExt := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/VendorInternalId')
								If (aForn := IntForInt(cFornExt,cMarca))[1]
									cFornInt := PadR(aForn[2][3], TamSx3('G5N_FORNEC')[1])
									cLojaInt := PadR(aForn[2][4], TamSx3('G5N_LOJA' )[1])
								Else
									Return aForn
								Endif

								If cEvent <> MODEL_OPERATION_DELETE
									If !oModelDet:SeekLine({{'G5N_FORNEC', cFornInt}, {'G5N_LOJA', cLojaInt}})  
										If !Empty(oModelDet:GetValue('G5N_FORNEC'))	
											oModelDet:GoLine(oModelDet:AddLine())
										EndIf
										oModelDet:SetValue('G5N_FORNEC', cFornInt)
										oModelDet:SetValue('G5N_LOJA'  , cLojaInt)
									EndIf
								Endif
								aADD(aDetalhe,cFornInt + cLojaInt) 
							Next
						EndIf
						For nX := 1 to oModel:GetModel('G5NDETAIL'):Length()
							oModel:GetModel('G5NDETAIL'):GoLine(nX)
							If ascan(aDetalhe,oModel:GetModel('G5NDETAIL'):GetValue('G5N_FORNEC')+ oModel:GetModel('G5NDETAIL'):GetValue('G5N_LOJA') ) == 0 .and. cEvent <> MODEL_OPERATION_DELETE 
								If oModel:GetModel('G5NDETAIL'):CanDeleteLine()
									oModel:GetModel('G5NDETAIL'):DeleteLine()
								Endif
							Endif
						Next

						If oModel:VldData() .And. oModel:CommitData()
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID, cEvent == MODEL_OPERATION_DELETE)
							If cEvent <> MODEL_OPERATION_DELETE
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
								cErro := STR0002 	// "A integração não foi bem sucedida."
								cErro += STR0003 + AllTrim(aErro[5]) + '-' + AllTrim(aErro[6])	// "Foi retornado o seguinte erro: "
								If !Empty(AllTrim(aErro[7]))
									cErro += STR0005 + AllTrim(aErro[7])	// "Solução - "
								Endif
							Else
								cErro := STR0002 		// "A integração não foi bem sucedida."
								cErro += STR0004 		// "Verifique os dados enviados."
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
