#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI019

Funcao de integracao do Complemento de Fornecedor
Mensagem Unica - TravelVendor

@sample	TURI019(cXml, cTypeTrans, cTypeMessage)
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
@since		23/10/2015
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Function TURI019(cXml, nTypeTrans, cTypeMessage)

Local lRet        := .T. 
Local cEvento     := 'upsert'
Local cAdapter    := 'TURA019'
Local cMsgUnica   := 'TRAVELVENDOR'
Local cMarca      := 'PROTHEUS'
Local cAlias      := 'G4R'
Local cCampo      := 'G4R_FORNEC'
Local oXML        := tXMLManager():New()
Local oModel      := NIL
Local oModelCab   := NIL
Local oModelTur   := NIL
Local oModelBrk   := NIL
Local oModelGrp   := NIL
Local oModelFopA  := NIL //Formas de Pagamentos Adicionadas
Local oModelFopR  := NIL //Formas de Pagamentos Restringidas
Local cBusiCont   := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cListBrk    := '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfBrokerSystems/BrokerSystems'
Local cListOfGrp  := '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfFamily/Family'
Local cListOfFop  := '/ListOfPaymentForm/PaymentForm'
Local nX, nI, nY  := 0     
Local nCont, nAux := 0 
Local nCntFOP     := 0
Local cXmlRet     := ''
Local cXmlItem    := '' 
Local cXMLBrk     := ''
Local cXMLGrp     := ''
Local cXMLGrpAux  := ''
Local cXMLFop     := ''
Local cXMLFopAux  := ''
Local cCodAux     := ''
Local aErro       := {}
Local lDelete
Local lMsblql		:= AllTrim(GetSx3Cache("G4R_MSBLQL", "X3_CAMPO")) == "G4R_MSBLQL" 
//Variaveis DE/PARA
Local cIntID      := ''
Local cExtID      := ''
Local cBrkID      := ''
Local cBrkExt     := ''
Local cGrpID      := ''
Local cGrpExt     := ''
Local cFopID      := ''
Local cFopExt     := ''

//Variaveis do cabecalho 
Local cForn       := ''		
Local cLoja       := ''		
Local cReport     := ''		
Local cBSPVendor  := ''
Local cIATA       := ''		
Local cShortIATA  := ''
Local cPhone      := ''
Local cFax        := ''
Local cEmail      := ''
Local cBlocked    := ''

// variareis itens - sistemas de origem	
Local cBrkCod     := ''
Local cCodGDS     := ''
Local aListBrk    := {}
	
// variareis itens - grupos de produto	
Local cGrpCod     := ''
Local cRefund     := ''
Local cDeadLine   := ''
Local cTpDLine    := ''
Local aListGrp    := {}

// variareis itens - formas de pagamento	
Local cCodFop     := '' 
Local cDestin     := ''
Local cEntType    := ''
Local aListFopA   := {}
Local aListFopR   := {}

Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
				
		cForn      := oModel:GetValue('G4R_MASTER', 'G4R_FORNEC')
		cLoja      := oModel:GetValue('G4R_MASTER', 'G4R_LOJA')
		cType      := AllTrim(oModel:GetValue('G4S_DETAIL', 'G4S_TIPO'))
		cReport    := AllTrim(oModel:GetValue('G4S_DETAIL', 'G4S_REPORT'))
		cBSPVendor := AllTrim(oModel:GetValue('G4S_DETAIL', 'G4S_BSP'))
		cIATA      := AllTrim(oModel:GetValue('G4S_DETAIL', 'G4S_IATA'))
		cShortIATA := AllTrim(oModel:GetValue('G4S_DETAIL', 'G4S_ABIATA'))
		cPhone     := AllTrim(oModel:GetValue('G4S_DETAIL', 'G4S_FONE'))
		cFax       := AllTrim(oModel:GetValue('G4S_DETAIL', 'G4S_FAX'))
		cEmail     := AllTrim(oModel:GetValue('G4S_DETAIL', 'G4S_EMAIL'))
		If lMsblql
			cBlocked   := TurXLogic(oModel:GetValue('G4R_MASTER', 'G4R_MSBLQL'), TP_CHAR1_RET)
		Endif 
		cIntID     := IntForExt(,,cForn,cLoja)[2]//TURXMakeId(cForn + '|' + cLoja + '|F', 'SA2')

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
		cXMLRet +=		'<VendorCode>' + Alltrim(cForn) + '|' + Alltrim(cLoja) + '</VendorCode>'             
		cXMLRet +=		'<VendorInternalId>' + cIntID + '</VendorInternalId>'
		cXMLRet +=		'<Type>' + cType + '</Type>'
		cXMLRet +=		'<ReportingVendor>' + cReport + '</ReportingVendor>'        
		cXMLRet +=		'<BSPVendor>' + cBSPVendor + '</BSPVendor>'              
		cXMLRet +=		'<IATA>' + cIATA + '</IATA>'                   
		cXMLRet +=		'<ShortIATA>' + cShortIATA + '</ShortIATA>'
		
		cXMLRet +=		'<ListOfCommunicationInformation>'
		cXMLRet +=	 		'<CommunicationInformation>'
		cXMLRet +=				'<PhoneNumber>'+cPhone+'</PhoneNumber>'
		cXMLRet +=				'<FaxNumber>'+cFAX+'</FaxNumber>'
		cXMLRet +=				'<Email>'+cEmail+'</Email>'
		cXMLRet +=			'</CommunicationInformation>'
		cXMLRet +=		'</ListOfCommunicationInformation>'
		
		/*cXMLRet +=		'<DepartmentReservePhone>' + cPhone + '</DepartmentReservePhone>'
		cXMLRet +=		'<DepartmentReserveFax>' + cFax + '</DepartmentReserveFax>'
		cXMLRet +=		'<DepartmentReserveEmail>' + cEmail + '</DepartmentReserveEmail>'*/
		If lMsblql
			cXMLRet +=		'<Situation>' + cBlocked + '</Situation>'
		Endif    
		
		//Exclui o De/Para 
		If lDelete
			CFGA070MNT( NIL, cAlias, cCampo, NIL, cIntID, lDelete )
		EndIf
		
		// lista de sistemas de origem
		cXMLBrk := ''
		If oModel:GetModel('G8L_DETAIL'):Length(.T.) > 0
			For nX := 1 To oModel:GetModel('G8L_DETAIL'):Length()
				If !oModel:GetModel('G8L_DETAIL'):IsDeleted(nX)
					cBrkCod := AllTrim(oModel:GetModel('G8L_DETAIL'):GetValue('G8L_CODSIS', nX))
					cBrkID  := TURXMakeId(cBrkCod, 'G8O')
					cCodGDS := AllTrim(oModel:GetModel('G8L_DETAIL'):GetValue('G8L_CODGDS', nX))

					If !Empty(cBrkCod)
						cXMLBrk += '<BrokerSystems>'
						cXMLBrk +=		'<BrokerSystemCode>' + cBrkCod + '</BrokerSystemCode>'                   
						cXMLBrk +=		'<BrokerSystemInternalId>' + cBrkID + '</BrokerSystemInternalId>'         
						cXMLBrk +=		'<BrokerCode>' + cCodGDS + '</BrokerCode>'             
						cXMLBrk += '</BrokerSystems>'
					EndIf
				EndIf
			Next
			If !Empty(cXMLBrk)
				cXMLRet += '<ListOfBrokerSystems>' + cXMLBrk + '</ListOfBrokerSystems>'
			EndIf
		EndIf

		// lista de grupos de produtos
		cXMLGrp := ''
		If oModel:GetModel('G4T_DETAIL'):Length(.T.) > 0
			For nX := 1 To oModel:GetModel('G4T_DETAIL'):Length()
				oModel:GetModel('G4T_DETAIL'):GoLine(nX)
				If !oModel:GetModel('G4T_DETAIL'):IsDeleted()
					cGrpCod   := AllTrim(oModel:GetModel('G4T_DETAIL'):GetValue('G4T_GRUPO'))
					cGrpID    := TURXMakeId(cGrpCod, 'SBM')
					cRefund   := AllTrim(oModel:GetModel('G4T_DETAIL'):GetValue('G4T_REEMB'))
					cDeadLine := cValToChar(oModel:GetModel('G4T_DETAIL'):GetValue('G4T_PRAZO'))
					cTpDLine  := AllTrim(oModel:GetModel('G4T_DETAIL'):GetValue('G4T_TIPO'))

					If !Empty(cGrpCod)
						cXMLGrpAux := '<FamilyCode>' + cGrpCod + '</FamilyCode>'                   
						cXMLGrpAux += '<FamilyInternalId>' + cGrpID + '</FamilyInternalId>'         
						cXMLGrpAux += '<Refund>' + cRefund + '</Refund>'      
						cXMLGrpAux += '<Deadline>' + cDeadLine + '</Deadline>'    
						cXMLGrpAux += '<DeadlineType>' + cTpDLine + '</DeadlineType>'
						
						// lista de fop's liberadas para o grupo posicionado
						cXMLFopAux := ''
						If G3K->(DbSeek(xFilial('G3K') + PadR(cGrpCod, TamSx3('G4T_GRUPO')[1])))
							Do While G3K->(!EOF()) .And. G3K->G3K_FILIAL == xFilial('G3K') .And. G3K->G3K_CODGRP == PadR(cGrpCod, TamSx3('G4T_GRUPO')[1])
								// verificando se a FOP foi restringida... Caso afirmativo, não manda 
								If !oModel:GetModel('G4U_RESTR'):SeekLine({{'G4U_FOP', G3K->G3K_CODFOP}})  
									cCodFop  := AllTrim(G3K->G3K_CODFOP)
									cFopID   := TURXMakeId(cCodFop, 'G3N')
									cDestin  := G3K->G3K_DEST
									cEntType := G3K->G3K_PESSOA

									cXMLFopAux += '<PaymentForm>'
									cXMLFopAux +=		'<PaymentFormCode>' + cCodFop + '</PaymentFormCode>'
									cXMLFopAux += 	'<PaymentFormInternalId>' + cFopID + '</PaymentFormInternalId>'
									cXMLFopAux +=		'<Destination>' + cDestin + '</Destination>'
									cXMLFopAux += 	'<EntityType>' + cEntType + '</EntityType>'
									cXMLFopAux += '</PaymentForm>'
								EndIf	
								G3K->(DbSkip())
							EndDo
						EndIf
						
						// lista de fop's adicionadas
						If oModel:GetModel('G4U_ADCION'):Length(.t.) > 0
							For nI := 1 To oModel:GetModel('G4U_ADCION'):Length()
								oModel:GetModel('G4U_ADCION'):GoLine(nI)
								If !oModel:GetModel('G4U_ADCION'):IsDeleted()
									If !Empty(oModel:GetModel('G4U_ADCION'):GetValue('G4U_FOP')) 
										cCodFop  := AllTrim(oModel:GetModel('G4U_ADCION'):GetValue('G4U_FOP'))
										cFopID   := TURXMakeId(cCodFop, 'G3N')
										cDestin  := oModel:GetModel('G4U_ADCION'):GetValue('G4U_DESTIN')
										cEntType := oModel:GetModel('G4U_ADCION'):GetValue('G4U_TIPCLI')
										 
										cXMLFopAux += '<PaymentForm>'
										cXMLFopAux +=		'<PaymentFormCode>' + cCodFop + '</PaymentFormCode>'
										cXMLFopAux +=		'<PaymentFormInternalId>' + cFopID + '</PaymentFormInternalId>'
										cXMLFopAux +=		'<Destination>' + cDestin + '</Destination>'
										cXMLFopAux +=		'<EntityType>' + cEntType + '</EntityType>'
										cXMLFopAux += '</PaymentForm>'
									EndIf
								EndIf
							Next
						EndIf

						If !Empty(cXMLFopAux)
							cXMLFop := '<ListOfPaymentForm>' + cXMLFopAux + '</ListOfPaymentForm>'
						EndIf

						If !Empty(cXMLFop)
							cXMLGrpAux += cXMLFop
						EndIf

						If !Empty(cXMLGrpAux)
							cXMLGrp += '<Family>' + cXMLGrpAux + '</Family>'
						EndIf
					EndIf
				EndIf
			Next
			
			If !Empty(cXMLGrp)
				cXMLRet += '<ListOfFamily>' + cXMLGrp + '</ListOfFamily>'
			EndIf
		EndIf
		cXMLRet +=	'</BusinessContent>'
		
	Case nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
			
			//resposta da mensagem Unica TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				If Empty(oXml:Error())
					cMarca := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
					For nX := 1 to oXml:xPathChildCount('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId')
						cName  := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Name')
						cIntID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Origin')
						cExtID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Destination')

						If !Empty(cIntID) .And. !Empty(cExtID)
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID)
						EndIf
					Next
				EndIf
				oXml := NIL
				
			//chegada de mensagem de negocios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS )
				cEvento    := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca     := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtId     := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/VendorInternalId'))
				cType      := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Type'))
				cReport    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ReportingVendor'))
				cBSPVendor := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/BSPVendor'))
				cIATA      := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/IATA'))
				cShortIATA := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ShortIATA'))
				cPhone     := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DepartmentReservePhone'))
				cFax       := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DepartmentReserveFax'))
				cEmail     := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DepartmentReserveEmail'))
				cBlocked   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				
				If (aForn := IntForInt(cExtId,cMarca))[1]
					cForn      := PadR(aForn[2][3], TamSx3('G4R_FORNEC')[1])
					cLoja      := PadR(aForn[2][4], TamSx3('G4R_LOJA')[1])
				Else
					Return aForn
				Endif
			
				If Upper(cEvento) == 'UPSERT'
					If G4R->(DbSeek(xFilial('G4R') + cForn + cLoja))
						cEvento := MODEL_OPERATION_UPDATE
					Else
						cEvento := MODEL_OPERATION_INSERT
					EndIf
				ElseIf Upper(cEvento) == 'DELETE'
					If G4R->(DbSeek(xFilial('G4R') + cForn + cLoja))
						cEvento := MODEL_OPERATION_DELETE
					Else
						lRet    := .F.
						cXmlRet := STR0001	// 'Registro nao encontrado no Protheus.'
					EndIf
				EndIf
				
				If lRet
					oModel	:= FwLoadModel(cAdapter)
					oModel:SetOperation(cEvento)
					If oModel:Activate()
						oModelCab  := oModel:GetModel('G4R_MASTER')
						oModelTur  := oModel:GetModel('G4S_DETAIL')
						oModelBrk  := oModel:GetModel('G8L_DETAIL')
						oModelGrp  := oModel:GetModel('G4T_DETAIL')
						oModelFopA := oModel:GetModel('G4U_ADCION')
						oModelFopR := oModel:GetModel('G4U_RESTR')
						If cEvento <> MODEL_OPERATION_DELETE
							If cEvento == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G4R_FORNEC', cForn)
								oModelCab:SetValue('G4R_LOJA'  , cLoja)
							EndIf
							oModelTur:SetValue('G4S_TIPO'  , cType)
							oModelTur:SetValue('G4S_REPORT', cReport)
							oModelTur:SetValue('G4S_BSP'   , cBSPVendor)
							oModelTur:SetValue('G4S_IATA'  , cIATA)
							oModelTur:SetValue('G4S_ABIATA', cShortIATA)
							oModelTur:SetValue('G4S_FONE'  , cPhone)
							oModelTur:SetValue('G4S_FAX'   , cFax)
							oModelTur:SetValue('G4S_EMAIL' , cEmail)
							If lMsblql
								oModelCab:SetValue('G4R_MSBLQL', TurXLogic(cBlocked, TP_CHAR1_RET))
							Endif
							
							// Sistemas de Origem 
							If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfBrokerSystems')) > 0
								For nX := 1 To nCont
									If lRet
										cBrkExt := oXml:XPathGetNodeValue(cListBrk + '[' + cValToChar(nX) + ']/BrokerSystemInternalId')
										cCodGDS := PadR(AllTrim(oXml:XPathGetNodeValue(cListBrk + '[' + cValToChar(nX) + ']/BrokerCode')), TamSx3('G8L_CODGDS')[1])
										cBrkCod := PadR(AllTrim(TURXRetId(cMarca, 'G8O', 'G8O_CODIGO', cBrkExt, NIL, 3)), TamSx3('G8L_CODSIS')[1])
										
										If !oModelBrk:SeekLine({{'G8L_CODSIS', cBrkCod}, {'G8L_CODGDS', cCodGDS}}) 
											If !Empty(oModelBrk:GetValue('G8L_CODSIS')) 
												nLine := oModelBrk:AddLine()
												oModelBrk:GoLine(nLine)
											EndIf 
											oModelBrk:SetValue('G8L_CODSIS', cBrkCod)
											oModelBrk:SetValue('G8L_CODGDS', cCodGDS)
										EndIf
	
										If 	!oModelBrk:VldLineData()
											lRet := .F.
										Else
											aAdd(aListBrk, cBrkCod + cCodGDS)
										EndIf
									EndIf	
								Next
								
								// se for UPDATE varrer o model para verificar linhas removidas e, caso encontre, remover o DE/PARA
								If lRet .And. cEvento == MODEL_OPERATION_UPDATE
									For nX := 1 To oModelBrk:Length()
										oModelBrk:GoLine(nX)
										If aScan(aListBrk,oModelBrk:GetValue('G8L_CODSIS') + oModelBrk:GetValue('G8L_CODGDS')) == 0       
											oModelBrk:DeleteLine()
										EndIf	
									Next
								EndIf
							EndIf
							
							// Grupo de Produtos
							If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfFamily')) > 0
								For nX := 1 To nCont
									If lRet
										cGrpExt   := oXml:XPathGetNodeValue(cListOfGrp + '[' + cValToChar(nX) + ']/FamilyInternalId')
										cRefund   := oXml:XPathGetNodeValue(cListOfGrp + '[' + cValToChar(nX) + ']/Refund')
										cDeadLine := Val(AllTrim(oXml:XPathGetNodeValue(cListOfGrp + '[' + cValToChar(nX) +']/Deadline')))
										cTpDLine  := oXml:XPathGetNodeValue(cListOfGrp + '['+ cValToChar(nX) + ']/DeadlineType')
										If (aFamily := IntFamInt(cGrpExt,cMarca))[1]
											cGrpCod   := PadR(aFamily[2][3], TamSx3('G4T_GRUPO')[1])
										Else
											Return aFamily
										Endif
										
										If !oModelGrp:SeekLine({{'G4T_GRUPO', cGrpCod}})  
											If !Empty(oModelGrp:GetValue('G4T_GRUPO'))
												nLine := oModelGrp:AddLine()
												oModelGrp:GoLine(nLine)
											EndIf
											oModelGrp:SetValue('G4T_GRUPO', cGrpCod)
										EndIf
										oModelGrp:SetValue('G4T_REEMB', cRefund)
										oModelGrp:SetValue('G4T_PRAZO', cDeadLine)
										oModelGrp:SetValue('G4T_TIPO' , cTpDLine)
									
										If 	!oModelGrp:VldLineData()
											lRet := .F.
										Else
											aAdd(aListGrp, cGrpCod)
											
											// Formas de Pagamento
											If (nCntFOP := oXml:xPathChildCount(cListOfGrp + '[' + cValToChar(nX) +']' + '/ListOfPaymentForm')) > 0
												aListFop := {}
												// Adicionadas
												For nI := 1 to nCntFOP
													If lRet
														cFopExt  := oXml:XPathGetNodeValue(cListOfGrp + '[' + cValToChar(nX) + ']' + cListOfFop + '[' + cValToChar(nI) + ']/PaymentFormInternalId')
														cDestin  := oXml:XPathGetNodeValue(cListOfGrp + '[' + cValToChar(nX) + ']' + cListOfFop + '[' + cValToChar(nI) + ']/Destination')
														cEntType := oXml:XPathGetNodeValue(cListOfGrp + '[' + cValToChar(nX) + ']' + cListOfFop + '[' + cValToChar(nI) + ']/EntityType')
														cCodFop  := PadR(AllTrim(TURXRetId(cMarca, 'G3N', 'G3N_CODIGO', cFopExt, NIL, 3)), TamSx3('G4U_FOP')[1])
			
														//Se não encontrou no Grupo de Produto x FOP, inclui/altera no Adicionados
														If !G3K->(DbSeek(xFilial('G3K') + cGrpCod + cCodFop))
															If !Empty(cCodFop) .And. !oModelFopA:SeekLine({{'G4U_FOP', cCodFop}})
																If !Empty(oModelFopA:GetValue('G4U_FOP')) 
																	nLine := oModelFopA:AddLine()
																	oModelFopA:GoLine(nLine)
																EndIf
																oModelFopA:SetValue('G4U_FOP', cCodFop)
															EndIf
															oModelFopA:SetValue('G4U_DESTIN', cDestin)
															oModelFopA:SetValue('G4U_TIPCLI', cEntType)
				
															lRet := oModelFopA:VldLineData()
															
														ElseIf oModelFopR:SeekLine({{'G4U_FOP', cCodFop}})
															oModelFopR:DeleteLine()
														EndIf
														
														If lRet
															aAdd(aListFop, cCodFop)
														Endif
													EndIf
												Next
												If lRet // .And. cEvento == MODEL_OPERATION_UPDATE
													For nY := 1 to oModelFopA:Length()
														oModelFopA:GoLine(nY)
														If aScan(aListFop, oModelFopA:GetValue('G4U_FOP')) == 0
															oModelFopA:DeleteLine()
														EndIf
													Next
												EndIf
												

												// Restringidas... Adicionar os registros que não estiverem na ListOfPayment 
												If G3K->(DbSeek(xFilial('G3K') + cGrpCod))
													Do While lRet .And. G3K->(!EOF()) .And. G3K->G3K_FILIAL == xFilial('G3K') .And. G3K->G3K_CODGRP == cGrpCod
														If aScan(aListFop, G3K->G3K_CODFOP) == 0  
															If !oModelFopR:SeekLine({{'G4U_FOP', G3K->G3K_CODFOP}})
																If !Empty(oModelFopR:GetValue('G4U_FOP'))
																	nLine := oModelFopR:AddLine()
																	oModelFopR:GoLine(nLine)
																EndIf
																oModelFopR:SetValue('G4U_FOP', G3K->G3K_CODFOP)
															EndIf
															oModelFopR:SetValue('G4U_DESTIN', cDestin)
															oModelFopR:SetValue('G4U_TIPCLI', cEntType)
														
															If lRet := oModelFopR:VldLineData()
																aAdd(aListFop, G3K->G3K_CODFOP)
															EndIf
														EndIf
														G3K->(DbSkip())
													EndDo
													
													// se for UPDATE varrer o model para verificar linhas removidas e, caso encontre, remover o DE/PARA
													If lRet 
														For nY := 1 to oModelFopR:Length()
															oModelFopR:GoLine(nY)
															If aScan(aListFop, oModel:GetValue('G4U_RESTR', 'G4U_FOP')) == 0
																oModelFopR:DeleteLine()
															EndIf
														Next
													EndIf
												EndIf
											EndIf
										EndIf
									EndIf
								Next
								
								// se for UPDATE varrer o model para verificar linhas removidas e, caso encontre, remover o DE/PARA
								If lRet .And. cEvento == MODEL_OPERATION_UPDATE
									For nX := 1 To oModelGrp:Length()
										oModelGrp:GoLine(nX)
										If aScan(aListGrp, oModelGrp:GetValue('G4T_GRUPO')) == 0     
											oModelGrp:DeleteLine()
										EndIf	
									Next
								EndIf
							EndIf
						EndIf
					Else
						lRet := .F.
					EndIf
					
					If lRet .And. oModel:VldData() .And. oModel:CommitData()
						cIntID := TURXMakeId(cForn + '|' + cLoja+'|F', 'G4R')
						CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID, cEvento == MODEL_OPERATION_DELETE)
						If cEvento <> MODEL_OPERATION_DELETE
							cXmlRet := '<ListOfInternalId>'
							cXmlRet += 	'<InternalId>'
							cXmlRet +=		'<Name>' + cMsgUnica + '</Name>'
							cXmlRet +=		'<Origin>' + cExtID + '</Origin>'
							cXmlRet += 		'<Destination>' + cIntID + '</Destination>'
							cXmlRet +=	'</InternalId>'
							cXmlRet += '</ListOfInternalId>'
						Else
							cXmlRet := ''
						EndIf
					Else
						aErro := oModel:GetErrorMessage()
						If !Empty(aErro)
							cErro := STR0002 	// 'A integração não foi bem sucedida.'
							cErro += STR0003 + AllTrim(aErro[5]) + '-' + AllTrim(aErro[6])	// 'Foi retornado o seguinte erro: '
							If !Empty(AllTrim(aErro[7]))
								cErro += STR0005 + AllTrim(aErro[7])	// 'Solução - '
							EndIf
						Else
							cErro := STR0002 		// 'A integração não foi bem sucedida.'
							cErro += STR0004 		// 'Verifique os dados enviados.'
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