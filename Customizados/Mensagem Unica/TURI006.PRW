#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI006

Função de integração do Cadastro de Entidades Adicionais
Mensagem única - AdditionalEntity

@sample	TURI006(cXml, cTypeTrans, cTypeMessage)
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
Function TURI006(cXml, nTypeTrans, cTypeMessage)

Local lRet        := .T. 
Local cEvento     := 'upsert'
Local cAdapter    := 'TURA006'
Local cMsgUnica   := 'AdditionalEntity'
Local cMarca      := 'PROTHEUS'
Local cVersao     := ''
Local cAlias      := 'G3F'
Local cCampo      := 'G3F_TIPO'
Local oXML        := tXMLManager():New()
Local oModel      := NIL
Local oModelCab   := NIL
Local oModelDet   := NIL
Local cBusiCont   := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cListItens  := '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfAdditionalEntities/AdditionalEntities'
Local cXmlRet     := ''
Local cItemNovo   := ''
Local aErro       := {}
Local nX, nCont   := 0
Local nLine       := 0
Local lDelete		:= .F.
Local nOpc			:= 0

//Variaveis DE/PARA		
Local cIntID	:= ''
Local cExtID	:= ''
Local cCliID	:= ''
Local cTpEntID	:= ''
Local cItemID	:= ''
Local aIntID	:= {}		
//Variaveis de Controle do Xml		
Local cCodeInt    := ''
Local cCliente    := '' 
Local cLoja       := '' 
Local cTpEnt      := '' 
Local cShare      := ''		
Local cRequired   := ''	
Local cMask       := ''		
Local cValidate   := ''	
Local cCorp       := '' 
Local cEventos    := ''
Local cLazer      := '' 
Local cBlocked    := ''	
Local cItemCod    := ''
Local cDesc       := ''

Do Case
	Case nTypeTrans == TRANS_SEND
		If !Empty(cXml)
			cXmlRet := cXml
		Else
			lRet := Ti006Send(@cXmlRet)	
		Endif
		
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
							If Upper(Alltrim(cName)) == Upper(Alltrim(cMsgUnica))
								CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID)
							Else 
								CFGA070MNT(cMarca, 'G3G', 'G3G_ITEM', cExtID, cIntID)
							Endif
						Endif
					Next
				Endif
				oXml := NIL
				
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cEvento   := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca    := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cTpEntID  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/AdditionalEntityTypeInternalId'))
				cCliID    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CustomerInternalId'))
				cShare    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Share'))
				cRequired := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Required'))
				cMask     := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Mask'))
				cValidate := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Validate'))
				cCorp     := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Corporate'))
				cEventos  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Event'))
				cLazer    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Recreation'))
				cBlocked  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				
				If (aCliente := IntCliInt(cCliID,cMarca))[1] 
					cCliente	:= PadR(aCliente[2][3], TamSx3('A1_COD')[1])
					cLoja		:= PadR(aCliente[2][4], TamSx3('A1_LOJA')[1])
				Else
					lRet:= .F.
					cXmlRet := aCliente[2]
				Endif
				cTpEnt    := PadR(AllTrim(TURXRetId(cMarca, 'G3E', 'G3E_CODIGO', cTpEntID, NIL, 3)), TamSx3('G3E_CODIGO')[1])
					
				If Upper(cEvento) == 'UPSERT'
					If G3F->(DbSeek(xFilial('G3F') + cCliente + cLoja + cTpEnt))
						nOpc := MODEL_OPERATION_UPDATE
					Else
						nOpc := MODEL_OPERATION_INSERT
					Endif
				ElseIf Upper(cEvento) == 'DELETE'
					If G3F->(DbSeek(xFilial('G3F') + cCliente + cLoja + cTpEnt))
						If G3F->G3F_VALIDA <> '1'
							nOpc := MODEL_OPERATION_DELETE
						Else
							nOpc := MODEL_OPERATION_UPDATE
						Endif
						lDelete := .T.
					Else
						lRet    := .F.
						cXmlRet := STR0001 	// "Registro nao encontrado no Protheus."
					Endif
				Else
					lRet		:= .F.
					cXmlRet	:= STR0002 	// "A integração não foi bem sucedida."
				EndIf
				
				If lRet
					oModel	:= FwLoadModel(cAdapter)
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oModelCab := oModel:GetModel('G3FMASTER')
						If !lDelete
							If nOpc == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G3F_CODCLI', cCliente)
								oModelCab:SetValue('G3F_LOJA'  , cLoja)
								oModelCab:SetValue('G3F_TIPO'  , cTpEnt)
							Endif
							oModelCab:SetValue('G3F_COMPAR'	, TURXLogic(cShare, TP_CHAR1_RET))
							oModelCab:SetValue('G3F_OBRIGA'	, TURXLogic(cRequired, TP_CHAR1_RET))
							oModelCab:SetValue('G3F_MASCAR'	, cMask)
							oModelCab:SetValue('G3F_VALIDA'	, TURXLogic(cValidate, TP_CHAR1_RET))
							oModelCab:SetValue('G3F_CORP'	, TURXLogic(cCorp, TP_LOGIC_RET))
							oModelCab:SetValue('G3F_EVENTO'	, TURXLogic(cEventos, TP_LOGIC_RET))
							oModelCab:SetValue('G3F_LAZER'	, TURXLogic(cLazer, TP_LOGIC_RET))
							oModelCab:SetValue('G3F_MSBLQL'	, TURXLogic(cBlocked, TP_CHAR1_RET))
						Endif
						cIntID := TURXMakeId(cCliente + '|' + cLoja + '|' + cTpEnt , 'G3F')
						aAdd(aIntID,{cMsgUnica,cExtID,cIntID,cAlias,cCampo})
					Else
						lRet := .F.
					Endif

					If lRet
						If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfAdditionalEntities') ) > 0
							oModelDet := oModel:GetModel('G3GDETAIL')
							
							For nX := 1 To nCont
								If lRet
									cExtId  := AllTrim(oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/ItemInternalId'))
									cDesc    := AllTrim(oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/Description'))
									cIntID   := ''
									cItemCod := PadR(AllTrim(TURXRetId(cMarca, 'G3G', 'G3G_ITEM', cExtId, @cIntID, 6)), TamSx3('G3G_ITEM')[1])

									If Empty(cItemCod)
										cItemCod := AllTrim(oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/ItemCode'))
									EndIf									

									If !lDelete
										If !oModelDet:SeekLine({{'G3G_ITEM', cItemCod}}) .And. Empty(cIntID)
											If !Empty(oModel:GetValue('G3GDETAIL',"G3G_ITEM"))
												nLine := oModelDet:AddLine()
												oModelDet:GoLine(nLine)
											Endif
											oModelDet:SetValue('G3G_ITEM', cItemCod)
										EndIf
										oModelDet:SetValue('G3G_DESCR', cDesc)
									Else
										If oModelDet:SeekLine({{'G3G_ITEM', cItemCod}})
											oModelDet:DeleteLine()
										Endif
									Endif
								
									If 	!oModelDet:VldLineData()
										lRet := .F.
									Else
										cIntID   := TURXMakeId(cCliente + '|' + cLoja + '|' + cTpEnt + '|' + cItemCod, 'G3G')
										aAdd(aIntID,{'ADDITIONALENTITIESITEM',cExtID,cIntID,'G3G','G3G_ITEM'})
									EndIf
								EndIf
							Next
							If lDelete .and. nOpc == MODEL_OPERATION_UPDATE .and. oModelDet:Length(.T.) = 0
								oModel:Deactivate()
								oModel:SetOperation(MODEL_OPERATION_DELETE)
								oModel:Activate()
							Endif
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


Function Ti006Send(cXMLRet)
Local oModel		:= FwModelActive()
Local oModelCab	:= oModel:GetModel('G3FMASTER')
Local oModelDet	:= oModel:GetModel('G3GDETAIL')
Local cMsgUnica	:= 'AdditionalEntity'
Local cMarca		:= "PROTHEUS"
Local lDelete		:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local cXMLRet		:= ""
Local cXML_Event	:= "" 
Local cXml_Capa	:= ""
Local cXml_Item	:= ""
Local cXml_Item1	:= ""
Local cXml_Item2	:= ""
Local nLinha		:= 0
Local nCount		:= 0
Local cEvento		:= "upsert"
Local lRet			:= .T.
Local aDeletados	:= {}
Local nMaxTam		:= 1500
If lDelete
	cEvento := 'delete'
EndIf

cCliente	:= AllTrim(oModelCab:GetValue('G3F_CODCLI'))
cLoja		:= AllTrim(oModelCab:GetValue('G3F_LOJA'))
cTpEnt		:= AllTrim(oModelCab:GetValue('G3F_TIPO'))
cShare		:= TURXLogic(oModelCab:GetValue('G3F_COMPAR'), TP_CHAR1_RET)		
cRequired	:= TURXLogic(oModelCab:GetValue('G3F_OBRIGA'), TP_CHAR1_RET)	
cMask		:= AllTrim(oModelCab:GetValue('G3F_MASCAR'))		
cValidate	:= TURXLogic(oModelCab:GetValue('G3F_VALIDA'), TP_CHAR1_RET)	
cCorp		:= TURXLogic(oModelCab:GetValue('G3F_CORP'), TP_CHAR1_RET) 
cEventos	:= TURXLogic(oModelCab:GetValue('G3F_EVENTO'), TP_CHAR1_RET)
cLazer		:= TURXLogic(oModelCab:GetValue('G3F_LAZER'), TP_CHAR1_RET)
cBlocked	:= TURXLogic(oModelCab:GetValue('G3F_MSBLQL'), TP_CHAR1_RET)
	
cIntID		:= TURXMakeId(cCliente + '|' + cLoja + '|' + cTpEnt, 'G3F')
cCliID		:= IntCliExt(,, cCliente, cLoja)[2]//TURXMakeId(cCliente + '|' + cLoja + '|C', 'SA1')	
cTpEntID	:= TURXMakeId(cTpEnt, 'G3E')

//Monta XML de envio de mensagem unica
cXML_Event	:= FWEAIBusEvent( cMsgUnica,oModel:GetOperation(), { { "InternalId", cIntID } } )

cXml_Capa += TxSetNode('CompanyId'							, cEmpAnt	)
cXml_Capa += TxSetNode('BranchId'							, cFilAnt	)
cXml_Capa += TxSetNode('CompanyInternalId'					, cEmpAnt + '|' + cFilAnt)
cXml_Capa += TxSetNode('CustomerCode'						, cCliente +'|'+ cLoja  )
cXml_Capa += TxSetNode('CustomerInternalId'				, cCliID )
cXml_Capa += TxSetNode('AdditionalEntityTypeCode'			, cTpEnt)
cXml_Capa += TxSetNode('AdditionalEntityTypeInternalId'	, cTpEntId)
cXml_Capa += TxSetNode('InternalId'							, cIntID )
cXml_Capa += TxSetNode('Share' 								, cShare ) 
cXml_Capa += TxSetNode('Required'							, cRequired )  
cXml_Capa += TxSetNode('Mask'								, cMask )
cXml_Capa += TxSetNode('Validate'							, cValidate	)
cXml_Capa += TxSetNode('Corporate'							, cCorp 		)
cXml_Capa += TxSetNode('Event' 								, cEventos	)
cXml_Capa += TxSetNode('Recreation'							, cLazer 	)
cXml_Capa += TxSetNode('Situation'							, cBlocked	)

//Grava ou Exclui o De/Para 
If lDelete
	CFGA070MNT(cMarca, 'G3F', 'G3F_TIPO', , cIntID, lDelete)
Endif

// envia a lista de itens apenas quando o campo G3F_LISTA == 1
If cValidate == "1"

	If oModelDet:Length() > 0
		For nLinha := 1 to oModelDet:Length()
			oModelDet:goline(nLinha)
			nCount ++
			cItemCod := AllTrim(oModelDet:GetValue('G3G_ITEM'))
			cDesc    := AllTrim(oModelDet:GetValue('G3G_DESCR'))
			cItemID  := TURXMakeId(cCliente + '|' + cLoja + '|' + cTpEnt + '|' + cItemCod, 'G3G')
				
			If !oModelDet:IsDeleted() .Or. lDelete 
				cXml_Item2	:= TxSetNode('ItemCode'			, cItemCod	)
				cXml_Item2	+= TxSetNode('ItemInternalId'	, cItemID	)
				cXml_Item2	+= TxSetNode('Description'		, cDesc	)
				cXml_Item1	+= TxSetNode('AdditionalEntities',cXml_Item2)
			ElseIf oModelDet:IsDeleted() .and. !lDelete 
				aAdd(aDeletados,nLinha)
			Endif
	
			//Exclui o De/Para
			If oModelDet:IsDeleted() .Or. lDelete
				CFGA070MNT(cMarca, 'G3G', 'G3G_ITEM', , cItemID, .T.)
			Endif
			If nCount >= nMaxTam .or. nLinha == oModelDet:Length()
				cXml_Item	:= TxSetNode('ListOfAdditionalEntities',cXml_Item1)
				cXMLRet	:= cXML_Event
				cXMLRet	+= TxSetNode('BusinessContent',cXml_Capa+cXml_Item)
				lRet		:= FWIntegDef( "TURA006", /*cTypeMessage*/, /*cType*/, cXMLRet )[1]
				If lRet 
					nCount		:= 0
					cXml_Item	:= ""
					cXml_Item1	:= ""
				Else
					Exit
				Endif
			Endif
		Next
		
	Endif
	If lRet
		For nLinha := 1 to Len(aDeletados)
			oModelDet:GoLine(aDeletados[nLinha])
			nCount++
			cItemCod := AllTrim(oModelDet:GetValue('G3G_ITEM'))
			cDesc    := AllTrim(oModelDet:GetValue('G3G_DESCR'))
			cItemID  := TURXMakeId(cCliente + '|' + cLoja + '|' + cTpEnt + '|' + cItemCod, 'G3G')
			
			cXml_Item2	:= TxSetNode('ItemCode'			, cItemCod	)
			cXml_Item2	+= TxSetNode('ItemInternalId'	, cItemID	)
			cXml_Item2	+= TxSetNode('Description'		, cDesc	)
			cXml_Item1	+= TxSetNode('AdditionalEntities',cXml_Item2)
			
			If nCount >= nMaxTam .or. nLinha == Len(aDeletados)
				cXml_Item	:= TxSetNode('ListOfAdditionalEntities',cXml_Item1)
				cXMLRet	:= FWEAIBusEvent( cMsgUnica,MODEL_OPERATION_DELETE, { { "InternalId", cIntID } } )
				cXMLRet	+= TxSetNode('BusinessContent',cXml_Capa+cXml_Item)
				lRet		:= FWIntegDef( "TURA006", /*cTypeMessage*/, /*cType*/, cXMLRet )[1]
				If lRet 
					nCount		:= 0
					cXml_Item	:= ""
					cXml_Item1	:= ""
				Else
					Exit
				Endif
			Endif
		Next
	Endif
Else
	cXMLRet := cXML_Event
	cXMLRet += TxSetNode('BusinessContent',cXml_Capa)
	lRet := FWIntegDef( "TURA006", /*cTypeMessage*/, /*cType*/, cXMLRet )[1]
EndIf	

Return lRet