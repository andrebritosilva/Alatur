#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI018

Funcao de integracao do Complemento de Cliente
Mensagem Unica - TravelCustomer

@sample	TURI018(cXml, cMktRateTrans, cTypeMessage)
@param		cXml - O XML recebido pelo EAI Protheus
			cMktRate - Tipo de transacao
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
Function TURI018(cXml, nTypeTrans, cTypeMessage)

Local lRet        := .T. 
Local cEvento     := 'upsert'
Local cAdapter    := 'TURA018'
Local cMsgUnica   := 'TRAVELCUSTOMER'
Local cMarca      := 'PROTHEUS'
Local cAlias      := 'G4L'
Local cCampo      := 'G4L_CODIGO'
Local oXML        := tXMLManager():New()
Local oModel      := NIL
Local oModelCab   := NIL
Local oModelGrp   := NIL
Local oModelFopA  := NIL //Formas de Pagamentos Adicionadas
Local oModelFopR  := NIL //Formas de Pagamentos Restringidas
Local cBusiCont   := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cListOfGrp  := '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfFamily/Family'
Local cListOfFop  := '/ListOfPaymentForm/PaymentForm'
Local nX, nI, nY  := 0     
Local nCont, nAux := 0 
Local nCntFOP     := 0
Local cXmlRet     := ''
Local cXmlItem    := '' 
Local cXMLGrp     := ''
Local cXMLGrpAux  := ''
Local cXMLFop     := ''
Local cXMLFopAux  := ''
Local cCodAux     := ''
Local aErro       := {}
Local lDelete

//Variaveis DE/PARA
Local cIntID      := ''
Local cExtID      := ''
Local cCliID      := ''
Local cCliExt     := ''
Local cAgenteID   := ''
Local cAgenteExt  := ''
Local cPostoID    := ''
Local cPostoExt   := ''
Local cGrpID      := ''
Local cGrpExt     := ''
Local cFopID      := ''
Local cFopExt     := ''

//Variaveis do cabecalho 
Local cCodeInt    := ''
Local cCliente    := ''
Local cLoja       := ''		
Local cMktRate    := ''		
Local cAgente     := ''
Local cPosto      := ''		
Local cCorp       := ''
Local cEvents     := ''
Local cLazer      := ''
Local cBlocked    := ''
Local lMsblql := AllTrim(GetSx3Cache("G4L_MSBLQL", "X3_CAMPO")) == "G4L_MSBLQL"  
// variareis itens - grupos de produto	
Local cGrpCod     := ''
Local aListGrp    := {}

// variareis itens - formas de pagamento	
Local cCodFop     := '' 
Local aListFop   := {}

Do Case
	Case nTypeTrans == TRANS_SEND
		oModel     := FwModelActive()
		oModelGrp  := oModel:GetModel('G4N_DETAIL') 
		oModelFopA := oModel:GetModel('G4O_ADCION')
		oModelFopR := oModel:GetModel('G4O_RESTR')
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf

		cCodeInt  := AllTrim(oModel:GetValue('G4L_MASTER'  , 'G4L_CODIGO'))
		cCliente  := oModel:GetValue('G4L_MASTER'  , 'G4L_CLIENT')
		cLoja     := oModel:GetValue('G4L_MASTER'  , 'G4L_LOJA')
		cShare	  := AllTrim(oModel:GetValue('G4L_MASTER'  , 'G4L_COMPAR'))
		cMktRate  := AllTrim(oModel:GetValue('G4M_DETAIL'  , 'G4M_TPMERC'))
		cAgente   := AllTrim(oModel:GetValue('G4M_DETAIL'  , 'G4M_CODPRO'))
		cPosto    := AllTrim(oModel:GetValue('G4M_DETAIL'  , 'G4M_CODPOS'))
		cFilPst	  := AllTrim(oModel:GetValue('G4M_DETAIL'  , 'G4M_FILPOS'))
		cCorp     := TurXLogic(oModel:GetValue('G4L_MASTER', 'G4L_CORP')  , TP_CHAR1_RET)
		cEvents   := TurXLogic(oModel:GetValue('G4L_MASTER', 'G4L_EVENTO'), TP_CHAR1_RET)
		cLazer    := TurXLogic(oModel:GetValue('G4L_MASTER', 'G4L_LAZER') , TP_CHAR1_RET)
		If lMsblql 
			cBlocked  := TurXLogic(oModel:GetValue('G4L_MASTER', 'G4L_MSBLQL'), TP_CHAR1_RET)
		Endif
		cIntID    := TURXMakeId(cCodeInt, 'G4L')
		cCliID		:= IntCliExt(,,cCliente,cLoja)[2]//TURXMakeId(cCliente + '|' + cLoja + '|C', 'SA1')
		cAgenteID := IIF(!Empty(cAgente), TURXMakeId(cAgente, 'G3H'), '')
		cPostoID  := TURXMakeId(cPosto, 'G3M',nil ,cFilPst )

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
		cXMLRet +=		'<CustomerCode>' + Alltrim(cCliente) + '|' + Alltrim(cLoja) + '</CustomerCode>'             
		cXMLRet +=		'<CustomerInternalId>' + cCliID + '</CustomerInternalId>'
		cXMLRet +=		'<Share>'+cShare+'</Share>'
		cXMLRet +=		'<MarketRate>' + cMktRate + '</MarketRate>'		
		cXMLRet +=		'<AgentCode>' + cAgente + '</AgentCode>'                   
		cXMLRet +=		'<AgentInternalId>' + cAgenteID + '</AgentInternalId>'         
		cXMLRet +=		'<ServiceStationCode>' + cPosto + '</ServiceStationCode>'      
		cXMLRet +=		'<ServiceStationInternalId>' + cPostoID + '</ServiceStationInternalId>'
		cXMLRet +=		'<Corporate>' + cCorp + '</Corporate>' 
		cXMLRet +=		'<Event>' + cEvents + '</Event>'    
		cXMLRet +=		'<Recreation>' + cLazer + '</Recreation>'
		If lMsblql 
			cXMLRet +=		'<Situation>' + cBlocked + '</Situation>'
		Endif    
		
		//Exclui o De/Para 
		If lDelete
			CFGA070MNT(NIL, cAlias, cCampo, NIL, cIntID, lDelete)
		EndIf
		
		// lista de grupos de produtos
		cXMLGrp := ''
		If oModelGrp:Length(.T.) > 0
			For nX :=  1 To oModelGrp:Length()
				oModelGrp:GoLine(nX)
				If !oModelGrp:IsDeleted()
					cGrpCod := oModelGrp:GetValue('G4N_GRUPO')
					cGrpID  := IntFamExt(,,cGrpCod)[2]//TURXMakeId(cGrpCod, 'SBM')
					If !Empty(cGrpCod)
						cXMLGrpAux := '<FamilyCode>' + AllTrim(cGrpCod) + '</FamilyCode>'                   
						cXMLGrpAux +=	'<FamilyInternalId>' + cGrpID + '</FamilyInternalId>'         
						
						// lista de fop's liberadas para o grupo posicionado
						cXMLFopAux := ''
						If G3K->(DbSeek(xFilial('G3K') + PadR(cGrpCod,TamSx3('G4N_GRUPO')[1])))
							Do While G3K->(!EOF()) .And. G3K->G3K_FILIAL == xFilial('G3K') .And. G3K->G3K_CODGRP == PadR(cGrpCod, TamSx3('G4N_GRUPO')[1])
								// verificando se a FOP foi restringida... Caso afirmativo, não manda 
								If !oModelFopR:SeekLine({{'G4O_FOP', G3K->G3K_CODFOP}})   
									cCodFop := AllTrim(G3K->G3K_CODFOP)
									cFopID  := TURXMakeId(cCodFop, 'G3N')

									cXMLFopAux += '<PaymentForm>'
									cXMLFopAux +=		'<PaymentFormCode>' + cCodFop + '</PaymentFormCode>'
									cXMLFopAux += 	'<PaymentFormInternalId>' + cFopID + '</PaymentFormInternalId>'
									cXMLFopAux += '</PaymentForm>'
								EndIf	
								G3K->(DbSkip())
							EndDo
						EndIf
						
						If oModelFopA:Length(.T.) > 0
							For nI :=  1 To oModelFopA:Length()
								If !oModelFopA:IsDeleted(nI)
									If !Empty(oModelFopA:GetValue('G4O_FOP', nI))
										cCodFOP := AllTrim(oModelFopA:GetValue('G4O_FOP', nI))
										cFopID  := TURXMakeId(cCodFop, 'G3N')
										
										cXMLFopAux +='<PaymentForm>'
										cXMLFopAux +=	'<PaymentFormCode>' + cCodFOP + '</PaymentFormCode>'
										cXMLFopAux +=	'<PaymentFormInternalId>' + cFopID + '</PaymentFormInternalId>'
										cXMLFopAux +='</PaymentForm>'
									EndIf
								EndIf
							Next
						EndIf

						If !Empty(cXMLFopAux)
							cXMLFop  := '<ListOfPaymentForm>' + cXMLFopAux + '</ListOfPaymentForm>'
						EndIf

						If !Empty(cXMLFop)
							cXMLGrpAux += cXMLFop
						EndIf

						If !Empty(cXMLGrpAux)
							cXMLGrp +=	'<Family>' + cXMLGrpAux + '</Family>'
						EndIf
					EndIf
				EndIf
			Next
			
			If !Empty(cXMLGrp)
				cXMLRet += '<ListOfFamily>' + cXMLGrp + '</ListOfFamily>'
			Else
				cXMLRet += '<ListOfFamily />'
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
					cMarca	:= oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
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
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cEvento    := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca     := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID     := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cCliExt    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CustomerInternalId'))
				cShare		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Share'))
				cMktRate   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/MarketRate'))
				cAgenteExt := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/AgentInternalId'))
				cPostoExt  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ServiceStationInternalId'))
				cCorp      := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Corporate'))
				cEvents    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Event'))
				cLazer     := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Recreation'))
				cBlocked   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))
				cCodeInt   := PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo      , cExtID    , @cIntID, 3)), TamSx3('G4L_CODIGO')[1])
				If (aCliente:= IntCliInt(cCliExt,cMarca))[1]
					cCliente   := PadR(aCliente[2][3], TamSx3('G4L_CLIENT')[1])
					cLoja      := PadR(aCliente[2][4], TamSx3('G4L_LOJA')[1])
				Else
					Return aCliente
				Endif
				cAgente    := PadR(AllTrim(TURXRetId(cMarca, 'G3H' , 'G3H_CODAGE', cAgenteExt, NIL    , 3)), TamSx3('G4M_CODPRO')[1])
				cPosto     := PadR(AllTrim(TURXRetId(cMarca, 'G3M' , 'G3M_CODIGO', cPostoExt , NIL    , 3)), TamSx3('G4M_CODPOS')[1])
				cFilPst    := PadR(AllTrim(TURXRetId(cMarca, 'G3M' , 'G3M_CODIGO', cPostoExt , NIL    , 2)), TamSx3('G4M_FILPOS')[1])
				If Upper(cEvento) == 'UPSERT'
					If !Empty(cCodeInt) .And. G4L->(DbSeek(xFilial('G4L') + cCodeInt))
						cEvento := MODEL_OPERATION_UPDATE
					Else
						cEvento  := MODEL_OPERATION_INSERT
						cCodeInt := GetSXENum('G4L', 'G4L_CODIGO')
						cIntID	  := TURXMakeId(cCodeInt, 'G4L')
					EndIf
				ElseIf Upper(cEvento) == 'DELETE'
					If !Empty(cCodeInt) .And. G4L->(DbSeek(xFilial('G4L') + cCodeInt))
						cEvento := MODEL_OPERATION_DELETE
					Else
						lRet    := .F.
						cXmlRet := STR0001	// 'Registro nao encontrado no Protheus.'
					EndIf
				EndIf
				
				If lRet
					oModel := FwLoadModel(cAdapter)
					oModel:SetOperation(cEvento)
					If oModel:Activate()
						oModelCab	:= oModel:GetModel('G4L_MASTER')
						oModelG4M	:= oModel:GetModel('G4M_DETAIL')
						oModelGrp	:= oModel:GetModel('G4N_DETAIL')
						oModelFopA	:= oModel:GetModel('G4O_ADCION')
						oModelFopR	:= oModel:GetModel('G4O_RESTR')
						If cEvento <> MODEL_OPERATION_DELETE
							If cEvento == MODEL_OPERATION_INSERT
								oModelCab:SetValue('G4L_CODIGO', cCodeInt)
								oModelCab:SetValue('G4L_CLIENT', cCliente)
								oModelCab:SetValue('G4L_LOJA'  , cLoja)
							EndIf
							oModelG4M:SetValue('G4M_TPMERC', cMktRate)
							oModelG4M:SetValue('G4M_CODPRO', cAgente)
							oModelG4M:SetValue('G4M_CODPOS', cPosto)
							oModelG4M:SetValue('G4M_FILPOS', cFilPst)
							oModelCab:SetValue('G4L_COMPAR', cShare   )
							oModelCab:SetValue('G4L_CORP'  , TurXLogic(cCorp   , TP_LOGIC_RET))
							oModelCab:SetValue('G4L_EVENTO', TurXLogic(cEvents , TP_LOGIC_RET))
							oModelCab:SetValue('G4L_LAZER' , TurXLogic(cLazer  , TP_LOGIC_RET))
							If lMsblql 
								oModelCab:SetValue('G4L_MSBLQL', TurXLogic(cBlocked, TP_CHAR1_RET))
							Endif

							//Grupo de Produtos
							If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfFamily')) > 0
								For nX := 1 To nCont
									If lRet
										cGrpExt := oXml:XPathGetNodeValue(cListOfGrp + '['+ cValToChar(nX) + ']/FamilyInternalId')
										If (aFamily:= IntFamInt(cGrpExt,cMarca))[1]
											cGrpCod := PadR(aFamily[2][3], TamSx3('G4N_GRUPO')[1])
										Else
											Return aFamily
										Endif
									
										If !oModelGrp:SeekLine({{'G4N_GRUPO', cGrpCod}})  
											If !Empty(oModelGrp:GetValue('G4N_GRUPO'))
												nLine := oModelGrp:AddLine()
												oModelGrp:GoLine(nLine)
											EndIf
											oModelGrp:SetValue('G4N_GRUPO', cGrpCod)
										EndIf

										If 	!oModelGrp:VldLineData()
											lRet := .F.
										Else
											aAdd(aListGrp, cGrpCod)

											// Formas de Pagamento
											If (nCntFOP := oXml:xPathChildCount(cListOfGrp + '[' + cValToChar(nX) + ']/ListOfPaymentForm')) > 0
												aListFop := {}
												// Adicionadas
												For nI := 1 to nCntFOP
													If lRet
														cFopExt := oXml:XPathGetNodeValue(cListOfGrp + '['+ cValToChar(nX) + ']' + cListOfFop + '['+ cValToChar(nI) +']/PaymentFormInternalId')
														cCodFop := PadR(AllTrim(TURXRetId(cMarca, 'G3N', 'G3N_CODIGO', cFopExt, NIL, 3)), TamSx3('G4O_FOP')[1])
														
														//Se não encontrou no Grupo de Produto x FOP, inclui/altera no Adicionados
														If !G3K->(DbSeek(xFilial('G3K') + cGrpCod + cCodFop))
															If !Empty(cCodFop) .And. !oModelFopA:SeekLine({{'G4O_CODGRP', cGrpCod}, {'G4O_FOP', cCodFop}, {'G4O_TIPEXC', '2'}})
																If !Empty(oModelFopA:GetValue('G4O_FOP')) 
																	nLine := oModelFopA:AddLine()
																	oModelFopA:GoLine(nLine)
																EndIf
																oModelFopA:SetValue('G4O_FOP', cCodFop)
															EndIf

															lRet := oModelFopA:VldLineData()
															
														ElseIf oModelFopR:SeekLine({ {'G4O_FOP', cCodFop}})
															oModelFopR:DeleteLine()
														EndIf
														
														If lRet
															aAdd(aListFop, cCodFop)
														Endif
													EndIf
												Next
												
												// se for UPDATE varrer o model para verificar linhas removidas e, caso encontre, remove
												If lRet // .And. cEvento == MODEL_OPERATION_UPDATE
													For nY := 1 to oModelFopA:Length()
														oModelFopA:GoLine(nY)
														If aScan(aListFop, oModelFopA:GetValue('G4O_FOP')) == 0
															oModelFopA:DeleteLine()
														EndIf
													Next
												EndIf
										
												//Adiciono os registros que não estiverem na ListOfPayment no grupo de restringidos
												If G3K->(DbSeek(xFilial('G3K') + cGrpCod))
													Do While lRet .And. G3K->(!EOF()) .And. G3K->G3K_FILIAL == xFilial('G3K') .And. G3K->G3K_CODGRP == cGrpCod
														If aScan(aListFop, G3K->G3K_CODFOP) == 0  
															If !oModelFopR:SeekLine({{'G4O_FOP', G3K->G3K_CODFOP}})
																If !Empty(oModelFopR:GetValue('G4O_FOP'))
																	nLine := oModelFopR:AddLine()
																	oModelFopR:GoLine(nLine)
																EndIf
																oModelFopR:SetValue('G4O_FOP', G3K->G3K_CODFOP)
															EndIf
														
															If lRet := oModelFopR:VldLineData()
																aAdd(aListFop, G3K->G3K_CODFOP)
															EndIf
														EndIf
														G3K->(DbSkip())
													EndDo
											
													// se for UPDATE varrer o model para verificar linhas removidas e, caso encontre, remover o DE/PARA
													If lRet //.And. cEvento == MODEL_OPERATION_UPDATE
														For nY := 1 to oModelFopR:Length()
															oModelFopR:GoLine(nY)
															If aScan(aListFop, oModel:GetValue('G4O_RESTR', 'G4O_FOP')) == 0
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
										If aScan(aListGrp, oModelGrp:GetValue('G4N_GRUPO')) == 0     
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
						ConfirmSX8()
						cIntID := TURXMakeId(cCodeInt, 'G4L') 
						CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID, cEvento == MODEL_OPERATION_DELETE)
						If cEvento <> MODEL_OPERATION_DELETE
							cXmlRet := '<ListOfInternalId>'
							cXmlRet += 	'<InternalId>'
							cXmlRet +=			'<Name>' + cMsgUnica + '</Name>'
							cXmlRet +=			'<Origin>' + cExtID + '</Origin>'
							cXmlRet += 		'<Destination>' + cIntID + '</Destination>'
							cXmlRet +=	 	'</InternalId>'
							cXmlRet += '</ListOfInternalId>'
						Else
							cXmlRet := ''
						EndIf
					Else
						aErro := oModel:GetErrorMessage()
						If !Empty(aErro)
							cErro := STR0002 // 'A integração não foi bem sucedida.'
							cErro += STR0003 + AllTrim(aErro[5]) + '-' + AllTrim(aErro[6])	// 'Foi retornado o seguinte erro: '
							If !Empty(AllTrim(aErro[7]))
								cErro += STR0005 + AllTrim(aErro[7])// 'Solução - '
							EndIf
						Else
							cErro := STR0002 // 'A integração não foi bem sucedida.'
							cErro += STR0004 // 'Verifique os dados enviados.'
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