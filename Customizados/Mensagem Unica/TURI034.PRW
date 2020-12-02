#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TURIDEF.CH"

//==========================================================================================
/*/{Protheus.doc} TURI034

Função de integração do Registro de Venda Mensagem Única - SaleRegistry

@sample	TURI034(cXml, cTypeTrans, cTypeMessage)

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

@author 	Jacomo Lisa
@since		28/09/2015
@version 	P12
/*/
//==========================================================================================
Function TURI034(cXml, nTypeTrans, cTypeMessage)

Local oModel      := Nil
Local oModelCab   := Nil
Local oModelG3Q   := Nil
Local oModelG3R   := Nil
Local oModelG3S   := Nil
Local oModelG3T   := Nil
Local oModelG3U   := Nil
Local oModelG3V   := Nil
Local oModelG3W   := Nil
Local oModelG3X   := Nil
Local oModelG3Y   := Nil
Local oModelG3Z   := Nil
Local oModelG40   := Nil
Local oModelG41   := Nil
Local oModelG42   := Nil
Local oModelG43   := Nil
Local oModelG44   := Nil
Local oModelG45   := Nil
Local oModelG46   := Nil
Local oModelG47   := Nil
Local oModelG49   := Nil
Local oModelG4A   := Nil
Local oModelG4B   := Nil
Local oModelG4D   := Nil
Local oModelG4E   := Nil
Local cCodOldUsr  := __cUserId
Local cThreadLog  := "Thr" + cValToChar(Randomize(0, 100000)) + "_" + cValToChar(ThreadId())
Local cTimeIni    := Time()
Local cRForn      := ""
Local cRForLj     := ""
Local nPos        := 0

//Variaveis de controle tanto para ENVIO - TRANS_SEND como para RECEBIMENTO - TRANS_RECEIVE  
Local cXmlRet     := "" 
Local cEvent      := "upsert"
Local cMarca      := ""
Local cCliente    := ""
Local cLoja       := ""
Local cIntID      := ""
Local cFilRV      := ""
Local cNumID      := ""
Local cIdItem	  := ""
Local cNumSeq	  := ""
Local cSeqID      := ""
Local cSegID      := ""
Local cCodPax	  := ""
Local nX          := 0
Local nI          := 0
Local nT          := 0
Local nZ          := 0
Local nA          := 0
Local n1          := 0
Local nCont       := 0 
Local nCont1      := 0
Local nOpc        := 0
Local lRet        := .T.
Local lDelete     := .F.

//Variaveis de controle para ENVIO - TRANS_SEND 
Local cXMLBus     := "" //Utilizada para o BusinessContent
Local cXmlLSale   := "" //Utilizada para List of Itens
Local cXmlSale    := "" //Utilizada para Itens
Local cSaleId	  := ""
Local cIntItemID  := ""
Local cItemId	  := ""
Local cCard       := ""
Local cApport     := ""
Local cItemG4A    := ""
Local cDocReserv  := ""
Local cFares      := ""
Local cQuoted     := ""
Local cRates      := ""
Local cExtraTp    := "" 
Local cImposto    := ""
Local cPassanger  := ""
Local cPaxId      := ""
Local cReemb      := ""
Local cSegment    := ""

//Variaveis de controle para RECEBIMENTO - TRANS_RECEIVE 
Local oXML        := tXMLManager():New()
Local cBusiCont   := "/TOTVSMessage/BusinessMessage/BusinessContent"
Local aMsgUnic    := {}
Local aIntID      := {}
Local aDetalhe    := {}
Local aClient     := {}
Local aDados      := {}
Local aProd       := {}
Local aVldChvExt  := {}
Local aPassenger  := {}
Local aForn       := {}
Local aMldSeg     := {'G3T', 'G3U', 'G3V', 'G3W', 'G3X', 'G3Y', 'G3Z', 'G40', 'G41', 'G42', 'G43'}
Local cExtID      := ""
Local cName       := "" 
Local cSegNeg     := ""
Local cCustomer   := ""   
Local cAgente     := ""
Local cCodVend    := ""
Local cTimeMid    := ""
Local cMsgErro    := ""
Local cListItens  := ""
Local cTpEmiss    := ""
Local cExtCli     := ""
Local cProd	      := ""
Local cExtFop     := ""
Local cFormaPgt   := ""
Local cMoedaCli   := ""
Local cSolicit    := ""
Local cDoc	      := ""
Local cListOfCard := ""
Local cOwner      := ""
Local cCardExt    := ""
Local cCodBan     := ""
Local cListOfApp  := ""
Local cCliEntit   := ""
Local cLjEntit    := ""
Local cAddExtID   := ""
Local cPercetn    := ""
Local cTpEnt	  := ""
Local cItemEnt    := ""
Local cListReserv := ""
Local cVendor	  := ""
Local cPosto	  := ""
Local cRepVendor  := ""
Local cMoeda	  := ""
Local cEmission   := ""
Local cBookAgt    := ""
Local cFrontSys   := ""
Local cForn       := ""
Local cForLj      := ""
Local cListOfQuo  := ""
Local cAeroOri    := ""
Local cAeroDes    := ""
Local cListOfRat  := ""
Local cCodTx	  := ""
Local cListOfExt  := ""
Local cListOfTax  := ""
Local cTax	      := ""
Local cListPassag := ""
Local cExtPax     := ""
Local cContato    := ""
Local cListAddEnt := ""
Local cLjExtEnt   := ""
Local cItemExtId  := ""

//Variaveis para controlar a inclusao de novas linhas nos submodelos
Local lAddG3Q     := .F.
Local lAddG3S     := .F.
Local lAddG3T     := .F.
Local lAddG3U     := .F.
Local lAddG3V     := .F.
Local lAddG3W     := .F.
Local lAddG3X     := .F.
Local lAddG3Y     := .F.
Local lAddG3Z     := .F.
Local lAddG40     := .F.
Local lAddG41     := .F.
Local lAddG42     := .F.
Local lAddG43     := .F.
Local lAddG45     := .F.
Local lAddG46     := .F.
Local lAddG47     := .F.
Local lAddG49     := .F.
Local lAddG4D     := .F.

If Type("Inclui") == "U"
	Private Inclui := .F.
EndIf

If nTypeTrans == TRANS_SEND
	oModel    := FwModelActive()
	oModelCab := oModel:GetModel('G3P_FIELDS')

	If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
		cEvent := 'delete'
	EndIf

	cCliente  := oModelCab:GetValue("G3P_CLIENT")
	cLoja	  := oModelCab:GetValue("G3P_LOJA")
	cIntID	  := TURXMakeId(AllTrim(oModelCab:GetValue("G3P_NUMID")), "G3P")

	//Monta XML de Business Event de envio de mensagem unica
	cXMLRet := FWEAIBusEvent("SaleRegistry", oModel:GetOperation(), {{"InternalId", cIntID}})
	cXMLBus :=	'<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXMLBus +=	'<BranchId>' + cFilAnt + '</BranchId>'
	cXMLBus +=	'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
	cXMLBus +=	'<Code>' + AllTrim(oModelCab:GetValue("G3P_NUMID")) + '</Code>'
	cXMLBus +=	'<InternalId>' + cIntID + '</InternalId>'
	cXMLBus +=	'<TradingProcess>' + AllTrim(oModelCab:GetValue("G3P_SEGNEG")) + '</TradingProcess>'
	cXMLBus +=	'<IssueDate>' + TxDtStamp(oModelCab:GetValue("G3P_EMISS")) + '</IssueDate>'
	cXMLBus +=	'<ProcessYear>' + AllTrim(oModelCab:GetValue("G3P_ANO")) + '</ProcessYear>'
	cXMLBus +=	'<CustomerCode>' + AllTrim(cCliente) + "|" + AllTrim(cLoja) + "|C" + '</CustomerCode>'
	cXMLBus +=	'<CustomerInternalId>' + IntCliExt( , , cCliente, cLoja)[2] + '</CustomerInternalId>'
	cXMLBus +=	'<ServiceStationCode>' + AllTrim(oModelCab:GetValue("G3P_POSTO")) + '</ServiceStationCode>'
	cXMLBus +=	'<ServiceStationInternalId>' + TURXMakeId(AllTrim(oModelCab:GetValue("G3P_POSTO")), "G3M", , oModelCab:GetValue("G3P_FILPST")) + '</ServiceStationInternalId>'
	cXMLBus +=	'<Observation>' + _NoTags(AllTrim(oModelCab:GetValue("G3P_OBS"))) + '</Observation>'
	cXMLBus +=	'<Description>' + _NoTags(AllTrim(oModelCab:GetValue("G3P_DESCRI"))) + '</Description>'
	cXMLBus +=	'<InitialDate>' + TxDtStamp(oModelCab:GetValue("G3P_DTINI")) + '</InitialDate>'
	cXMLBus +=	'<FinalDate>' + TxDtStamp(oModelCab:GetValue("G3P_DTFIM")) + '</FinalDate>'
	cXMLBus +=	'<Destination>' + AllTrim(oModelCab:GetValue("G3P_DESTIN")) + '</Destination>'
	cXMLBus +=	'<TravelAgentCode>' + AllTrim(oModelCab:GetValue("G3P_AGENT")) + '</TravelAgentCode>'
	cXMLBus +=	'<TravelAgentInternalId>' + TURXMakeId(AllTrim(oModelCab:GetValue("G3P_AGENT")), "G3H") + '</TravelAgentInternalId>'
	cXMLBus +=	'<ExternalSalesRegistryId>' + AllTrim(oModelCab:GetValue("G3P_CODEX")) + '</ExternalSalesRegistryId>'

	// Itens de Venda ----------------------------------------------------------------------------------------------------------------------
	oModelG3Q := oModel:GetModel('G3Q_ITENS')
	If !oModelG3Q:IsEmpty()
		cXmlLSale := ""
		For nX := 1 to oModelG3Q:Length()
			oModelG3Q:GoLine(nX)
			cXmlSale   := ""
			cIdItem	   := AllTrim(oModelG3Q:GetValue('G3Q_IDITEM'))
			cNumSeq	   := AllTrim(oModelG3Q:GetValue('G3Q_NUMSEQ'))
			cSaleId	   := cIdItem  + "|" + cNumSeq
			cIntItemID := AllTrim(oModelCab:GetValue("G3P_NUMID")) + "|" + cSaleId
			cItemId	   := TurxMakeID(cIntItemID, 'G3Q')
		
			If lDelete .Or. oModelG3Q:IsDeleted()
				CFGA070MNT(Nil, 'G3Q', 'G3Q_IDITEM', Nil, cItemId, .T.)
			EndIf
			
			If (lDelete .Or. !oModelG3Q:IsDeleted()) .And. !Empty(oModelG3Q:GetValue('G3Q_OPERAC')) .And. !(oModelG3Q:GetValue('G3Q_OPERAC') $ '5,6')
				cXmlSale += '<SaleItemCode>' + cSaleId + '</SaleItemCode>'
				cXmlSale += '<SaleItemInternalId>' + cItemId + '</SaleItemInternalId>'
				cXmlSale += '<OperationType>' + AllTrim(oModelG3Q:GetValue('G3Q_OPERAC')) + '</OperationType>'
				cXmlSale += '<DocumentType>' + AllTrim(oModelG3Q:GetValue('G3Q_TPDOC')) + '</DocumentType>'
				cXmlSale += '<OriginProcessNumber>' + AllTrim(oModelG3Q:GetValue('G3Q_DOCORI')) + '</OriginProcessNumber>'
				cXmlSale += '<ProcessNumber>' + AllTrim(oModelG3Q:GetValue('G3Q_DOC')) + '</ProcessNumber>'
				cXmlSale += '<ConjugateAmount>' + AllTrim(oModelG3Q:GetValue('G3Q_CONJUG')) + '</ConjugateAmount>'
				cXmlSale += '<IssueDate>' + TxDtStamp(oModelG3Q:GetValue('G3Q_EMISS')) + '</IssueDate>'
				cXmlSale += '<BroadcastTypeCode>' + AllTrim(oModelG3Q:GetValue('G3Q_TPEMIS')) + '</BroadcastTypeCode>'
				cXmlSale += '<BroadcastTypeInternalId>' + TurxMakeID(AllTrim(oModelG3Q:GetValue('G3Q_TPEMIS')),'G5O') + '</BroadcastTypeInternalId>'
				cXmlSale += '<CustomerCode>' + AllTrim(oModelG3Q:GetValue('G3Q_CLIENT')) + '|' + AllTrim(oModelG3Q:GetValue('G3Q_LOJA')) + '|C' + '</CustomerCode>'
				cXmlSale += '<CustomerInternalId>' + IntCliExt( , , oModelG3Q:GetValue('G3Q_CLIENT'), oModelG3Q:GetValue('G3Q_LOJA'))[2] + '</CustomerInternalId>'
				cXmlSale += '<ItemCode>' + AllTrim(oModelG3Q:GetValue('G3Q_PROD')) + '</ItemCode>'
				cXmlSale += '<ItemInternalId>' + IntProExt( , , oModelG3Q:GetValue('G3Q_PROD'))[2] + '</ItemInternalId>'
				cXmlSale += '<Destination>' + AllTrim(oModelG3Q:GetValue('G3Q_DESTIN')) + '</Destination>'
				cXmlSale += '<PaymentFormCode>' + AllTrim(oModelG3Q:GetValue('G3Q_FORMPG')) + '</PaymentFormCode>'
				cXmlSale += '<PaymentFormInternalId>' + TurxMakeID(AllTrim(oModelG3Q:GetValue('G3Q_FORMPG')), 'G3N') + '</PaymentFormInternalId>'
				cXmlSale += '<TravelCurrencyCode>' + AllTrim(oModelG3Q:GetValue('G3Q_MOEDCL')) + '</TravelCurrencyCode>'
				cXmlSale += '<TravelCurrencyInternalId>' + TurxMakeID(AllTrim(oModelG3Q:GetValue('G3Q_MOEDCL')), 'G5T') + '</TravelCurrencyInternalId>'
				cXmlSale += '<Exchange>' + cValToChar(oModelG3Q:GetValue('G3Q_TXCAMB')) + '</Exchange>'
				cXmlSale += '<RequestInternalId>' + TurxMakeID(AllTrim(oModelG3Q:GetValue('G3Q_SOLIC')), "SU5") + '</RequestInternalId>'
				cXmlSale += '<RequestDate>' + TxDtStamp(oModelG3Q:GetValue('G3Q_DTSOLI')) + '</RequestDate>'
				cXmlSale += '<ServiceOrder>' + AllTrim(oModelG3Q:GetValue('G3Q_ORDER')) + '</ServiceOrder>'
				cXmlSale += '<ServiceOrderItem>' + AllTrim(oModelG3Q:GetValue('G3Q_ITOS')) + '</ServiceOrderItem>'
			
				// Dados do cartão ----------------------------------------------------------------------------------------------------------------------
				cCard     := ""
				oModelG4D := oModel:GetModel('G4D_ITENS')
				If !oModelG4D:IsEmpty()
					For nI := 1 to oModelG4D:Length()
						oModelG4D:GoLine(nI)
						cSeqID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG4D:GetValue('G4D_SEQ')), 'G4D')
								
						If (lDelete .Or. !oModelG4D:IsDeleted()) .And. !EMPTY(oModelG4D:GetValue('G4D_PROPRI'))
							cCard += '<PaymentCreditCard>'
							cCard +=	'<SequenceCode>' + AllTrim(oModelG4D:GetValue('G4D_SEQ')) + '</SequenceCode>'
							cCard +=	'<SequenceInternalId>' + cSeqID + '</SequenceInternalId>'
							cCard +=	'<Owner>' + AllTrim(oModelG4D:GetValue('G4D_PROPRI')) + '</Owner>'
							cCard +=	'<CardCode>' + AllTrim(oModelG4D:GetValue('G4D_CODCAR')) + '</CardCode>'
							cCard +=	'<CardInternalId>' + TurXMakeID(AllTrim(oModelG4D:GetValue('G4D_CODCAR')), IIF(AllTrim(oModelG4D:GetValue('G4D_PROPRI')) == "1", 'G3J', 'G3D')) + '</CardInternalId>'
							cCard +=	'<CardNumber>' + AllTrim(oModelG4D:GetValue('G4D_NUMCAR')) + '</CardNumber>'
							cCard +=	'<CardCompany>' + AllTrim(oModelG4D:GetValue('G4D_CODBAN')) + '</CardCompany>'
							cCard +=	'<CardOwnerName>' + AllTrim(oModelG4D:GetValue('G4D_TITULA')) + '</CardOwnerName>'
							cCard +=	'<CardExpiringMonth>' + AllTrim(oModelG4D:GetValue('G4D_MESVAL')) + '</CardExpiringMonth>'
							cCard +=	'<CardExpiringYear>' + AllTrim(oModelG4D:GetValue('G4D_ANOVAL')) + '</CardExpiringYear>'
							cCard +=	'<InstallmentsAmount>' + cValToChar(oModelG4D:GetValue('G4D_QTDPAR')) + '</InstallmentsAmount>'
							cCard +=	'<ApprovalCode>' + AllTrim(oModelG4D:GetValue('G4D_NSU')) + '</ApprovalCode>'
							cCard +=	'<TransactionDate>' + TxDtStamp(oModelG4D:GetValue('G4D_DTOPER')) + '</TransactionDate>'
							cCard += '</PaymentCreditCard>'
						EndIf

						If lDelete .Or. oModelG4D:IsDeleted()
							CFGA070MNT(Nil, 'G4D', 'G4D_SEQ', Nil, cSeqID, .T.)
						EndIf
					Next nI

					If !Empty(cCard)
						cXmlSale += '<ListOfPaymentCreditCard>' + cCard + '</ListOfPaymentCreditCard>'
					EndIf
				EndIf
			
				// Rateio ----------------------------------------------------------------------------------------------------------------------
				cApport	  := ""
				oModelG4A := oModel:GetModel('G4A_ITENS')
				If !oModelG4A:IsEmpty()
					For nI := 1 to oModelG4A:Length()
						oModelG4A:GoLine(nI)
						If (lDelete .Or. !oModelG4A:IsDeleted()) .And. !Empty(oModelG4A:GetValue('G4A_PERRAT'))
							cItemG4A := IIF(!Empty(AllTrim(oModelG4A:GetValue('G4A_ITEM'))), TurXMakeID(cCliente + "|" + cLoja + "|" + AllTrim(oModelG4A:GetValue('G4A_TPENT')) + "|" + AllTrim(oModelG4A:GetValue('G4A_ITEM')), "G3G"), "")
						
							cApport += '<Apportionment>'
							cApport +=		'<AdditionalEntityTypeCode>' + AllTrim(oModelG4A:GetValue('G4A_TPENT')) + '</AdditionalEntityTypeCode>'
							cApport +=		'<AdditionalEntityTypeInternalId>' + TurXMakeID(AllTrim(oModelG4A:GetValue('G4A_TPENT')), 'G3E') + '</AdditionalEntityTypeInternalId>'
							cApport += 		'<ReferenceStoreCode>' + cCliente + "|" + oModelG4A:GetValue('G4A_LOJA') + "|C" + '</ReferenceStoreCode>'
							cApport += 		'<ReferenceStoreInternalId>' + IntCLiExt( , , cCliente, oModelG4A:GetValue('G4A_LOJA'))[2] + '</ReferenceStoreInternalId>'
							cApport += 		'<AdditionalEntityItemCode>' + AllTrim(AllTrim(oModelG4A:GetValue('G4A_ITEM'))) + '</AdditionalEntityItemCode>'
							cApport += 		'<AdditionalEntityItemInternalId>' + cItemG4A + '</AdditionalEntityItemInternalId>'
							cApport += 		'<Percentage>' + cValToChar(oModelG4A:GetValue('G4A_PERRAT')) + '</Percentage>'
							cApport += '</Apportionment>'
						EndIf
					Next nI
					
					If !Empty(cApport)
						cXmlSale += '<ListOfApportionment>' + cApport + '</ListOfApportionment>'
					EndIf
				EndIf

				// Documento de Reserva ----------------------------------------------------------------------------------------------------------------------
				cDocReserv := ""
				oModelG3R  := oModel:GetModel('G3R_ITENS')
				If !oModelG3R:IsEmpty()
					For nI := 1 to oModelG3R:Length()
						oModelG3R:GoLine(nI)
						If (lDelete .Or. !oModelG3R:IsDeleted()) .And. !Empty(oModelG3R:GetValue('G3R_FORNEC'))
							cDocReserv += '<BookingDocument>'
							cDocReserv += 	'<DocumentCode>' + cSaleId + '</DocumentCode>'
							cDocReserv += 	'<DocumentInternalId>' + cItemId + '</DocumentInternalId>'
							cDocReserv += 	'<ProductVendorCode>' + oModelG3R:GetValue('G3R_FORNEC') + "|" + oModelG3R:GetValue('G3R_LOJA') + "|F" + '</ProductVendorCode>'
							cDocReserv += 	'<ProductVendorInternalId>' + IntForExt( , , oModelG3R:GetValue('G3R_FORNEC'), oModelG3R:GetValue('G3R_LOJA'))[2] + '</ProductVendorInternalId>'
							cDocReserv += 	'<Destination>' + AllTrim(oModelG3R:GetValue('G3R_DESTIN')) + '</Destination>'
							cDocReserv +=	'<ServiceStationCode>' + AllTrim(oModelG3R:GetValue('G3R_POSTOR')) + '</ServiceStationCode>'
							cDocReserv +=	'<ServiceStationInternalId>' + TURXMakeId(AllTrim(oModelG3R:GetValue('G3R_POSTOR')), "G3M") + '</ServiceStationInternalId>'
							cDocReserv += 	'<ServiceStationPCC>' + AllTrim(oModelG3R:GetValue('G3R_PCC')) + '</ServiceStationPCC>'
							cDocReserv += 	'<ReportVendorCode>' + IIF(!Empty(oModelG3R:GetValue('G3R_FORREP') + oModelG3R:GetValue('G3R_LOJREP')), oModelG3R:GetValue('G3R_FORREP') + "|" + oModelG3R:GetValue('G3R_LOJREP') + "|F", "") + '</ReportVendorCode>'
							cDocReserv += 	'<ReportVendorInternalId>' + IIF(!Empty(oModelG3R:GetValue('G3R_FORREP') + oModelG3R:GetValue('G3R_LOJREP')), IntForExt( , , oModelG3R:GetValue('G3R_FORREP'), oModelG3R:GetValue('G3R_LOJREP'))[2], "") + '</ReportVendorInternalId>'
							cDocReserv += 	'<TravelCurrencyCode>' + AllTrim(oModelG3R:GetValue('G3R_MOEDA')) + '</TravelCurrencyCode>'
							cDocReserv += 	'<TravelCurrencyInternalId>' + TurXMakeID(AllTrim(oModelG3R:GetValue('G3R_MOEDA')), 'G5T') + '</TravelCurrencyInternalId>'
							cDocReserv +=	'<EmissionAgentCode>' + AllTrim(oModelG3R:GetValue('G3R_AGEMIS')) + '</EmissionAgentCode>'
							cDocReserv +=	'<EmissionAgentInternalId>' + TurXMakeID(AllTrim(oModelG3R:GetValue('G3R_AGEMIS')), 'G3H') + '</EmissionAgentInternalId>'
							cDocReserv += 	'<BookingAgentCode>' + AllTrim(oModelG3R:GetValue('G3R_AGRESE')) + '</BookingAgentCode>'
							cDocReserv += 	'<BookingAgentInternalId>' + TurXMakeID(AllTrim(oModelG3R:GetValue('G3R_AGRESE')), 'G3H') + '</BookingAgentInternalId>'
							cDocReserv += 	'<TourCode>' + AllTrim(oModelG3R:GetValue('G3R_TOURCD')) + '</TourCode>'
							cDocReserv += 	'<BookingObservations>'+ _NoTags(AllTrim(oModelG3R:GetValue('G3R_OBS'))) + '</BookingObservations>'
							cDocReserv +=	'<FrontSystemCode>' + AllTrim(oModelG3R:GetValue('G3R_SISORI')) + '</FrontSystemCode>'
							cDocReserv +=	'<FrontSystemInternalId>' + TurXMakeID(AllTrim(oModelG3R:GetValue('G3R_SISORI')), 'G4K') + '</FrontSystemInternalId>'
							cDocReserv += 	'<GDSLocator>' + AllTrim(oModelG3R:GetValue('G3R_LOCGDS')) + '</GDSLocator>'
							cDocReserv += 	'<BookingConfirmationDate>' + TxDtStamp(oModelG3R:GetValue('G3R_DTCONF')) + '</BookingConfirmationDate>'
							cDocReserv += 	'<BookingConfirmationType>' + AllTrim(oModelG3R:GetValue('G3R_FORMCF')) + '</BookingConfirmationType>'
							cDocReserv +=	'<BookingConfirmationCode>' + AllTrim(oModelG3R:GetValue('G3R_IDCONF')) + '</BookingConfirmationCode>'
						
							// Tarifas -----------------------------------------------------------------------------------------
							cFares    := ""
							oModelG44 := oModel:GetModel('G44_ITENS')
							If !oModelG44:IsEmpty()
								If (lDelete .Or. !oModelG44:IsDeleted()) .And. !Empty(oModelG44:GetValue('G44_TPTAR'))
									cFares += '<Fares>'
									cFares += 	'<TravelCurrencyCode>' + AllTrim(oModelG44:GetValue('G44_MOEDFO')) + '</TravelCurrencyCode>'
									cFares += 	'<TravelCurrencyInternalId>' + TurXMakeID(AllTrim(oModelG44:GetValue('G44_MOEDFO')), 'G5T') + '</TravelCurrencyInternalId>'
									cFares += 	'<BaseFare>' + AllTrim(oModelG44:GetValue('G44_BASTAR')) + '</BaseFare>'
									cFares += 	'<FareType>' + AllTrim(oModelG44:GetValue('G44_TPTAR')) + '</FareType>'
									cFares +=	'<BaseFareValue>' + cValToChar(oModelG44:GetValue('G44_TARBAS')) + '</BaseFareValue>'
									cFares += 	'<Exchange>' + cValToChar(oModelG44:GetValue('G44_TXCAMB')) + '</Exchange>'
									cFares += 	'<MinorFareValue>' + cValToChar(oModelG44:GetValue('G44_MENOR')) + '</MinorFareValue>'
									cFares += 	'<MaxFareValue>' + cValToChar(oModelG44:GetValue('G44_MAIOR')) + '</MaxFareValue>'
									cFares +=	'<FullFareValue>' + cValToChar(oModelG44:GetValue('G44_CHEIA')) + '</FullFareValue>'
									cFares += 	'<NoDealFareValue>' + cValToChar(oModelG44:GetValue('G44_PUBLIC')) + '</NoDealFareValue>'
									cFares += 	'<OpportunityFareValue>' + cValToChar(oModelG44:GetValue('G44_OPORTU')) + '</OpportunityFareValue>'
									cFares += 	'<EarlyCheckinFareValue>' + cValToChar(oModelG44:GetValue('G44_EARLY')) + '</EarlyCheckinFareValue>'
									cFares += 	'<LateCheckoutFareValue>' + cValToChar(oModelG44:GetValue('G44_LATE')) + '</LateCheckoutFareValue>'
									cFares += 	'<FoodServiceFareValue>' + cValToChar(oModelG44:GetValue('G44_PLALIM')) + '</FoodServiceFareValue>'
									cFares += '</Fares>'
								EndIf
							EndIf

							If !Empty(cFares)
								cDocReserv += cFares
							EndIf

							// Tarifas Cotadas -----------------------------------------------------------------------------------------
							cQuoted	  := ""
							oModelG45 := oModel:GetModel('G45_ITENS')
							If !oModelG45:IsEmpty()
								For nT := 1 to oModelG45:Length()
									oModelG45:GoLine(nT)
									cSeqID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG45:GetValue('G45_SEQ')), 'G45')
									
									If (lDelete .Or. !oModelG45:IsDeleted()) .And. !Empty(oModelG45:GetValue('G45_CODCIA'))
										cQuoted += '<QuotedFares>'
										cQuoted +=		'<QuotedFareCode>' + AllTrim(oModelG45:GetValue('G45_SEQ')) + '</QuotedFareCode>'
										cQuoted +=		'<QuotedFareInternalId>' + cSeqID + '</QuotedFareInternalId>'
										cQuoted +=		'<AirlineShortName>' + AllTrim(oModelG45:GetValue('G45_CODCIA')) + '</AirlineShortName>'
										cQuoted +=		'<AirportOriginCode>' + AllTrim(oModelG45:GetValue('G45_AERORI')) + '</AirportOriginCode>'
										cQuoted +=		'<AirportOriginInternalId>' + TurXMakeID(AllTrim(oModelG45:GetValue('G45_AERORI')), 'G3B') + '</AirportOriginInternalId>'
										cQuoted +=		'<AirportDestinyCode>' + AllTrim(oModelG45:GetValue('G45_AERDES')) + '</AirportDestinyCode>'
										cQuoted +=		'<AirportDestinyInternalId>' + TurXMakeID(AllTrim(oModelG45:GetValue('G45_AERDES')), 'G3B') + '</AirportDestinyInternalId>'
										cQuoted +=		'<DepartureTime>' + AllTrim(oModelG45:GetValue('G45_HRFIM')) + '</DepartureTime>'
										cQuoted +=		'<ConnectionsAmount>' + cValToChar(oModelG45:GetValue('G45_QTDCON')) + '</ConnectionsAmount>'
										cQuoted +=		'<ScalesAmount>' + cValToChar(oModelG45:GetValue('G45_QTDESC')) + '</ScalesAmount>'
										cQuoted +=		'<TravelCurrencyCode>' + AllTrim(oModelG45:GetValue('G45_MOEDTC')) + '</TravelCurrencyCode>'
										cQuoted +=		'<TravelCurrencyInternalId>' + TurXMakeID(AllTrim(oModelG45:GetValue('G45_MOEDTC')), 'G5T') + '</TravelCurrencyInternalId>'
										cQuoted +=		'<FareValue>' + cValToChar(oModelG45:GetValue('G45_TARIFA')) + '</FareValue>'
										cQuoted +=		'<TaxValue>' + cValToChar(oModelG45:GetValue('G45_TAXA')) + '</TaxValue>'
										cQuoted += '</QuotedFares>'
									EndIf

									If lDelete .Or. oModelG45:IsDeleted()
										CFGA070MNT(Nil, 'G45', 'G45_SEQ', Nil, cSeqID, .T.)
									EndIf
								Next nT
							EndIf

							If !Empty(cQuoted)
								cDocReserv += '<ListOfQuotedFares>' + cQuoted + '</ListOfQuotedFares>'
							EndIf
						
							// Taxas -----------------------------------------------------------------------------------------
							cRates	  := ""
							oModelG46 := oModel:GetModel('G46_ITENS')
							If !oModelG46:IsEmpty()
								For nT := 1 to oModelG46:Length()
									oModelG46:GoLine(nT)
									cSeqID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG46:GetValue('G46_SEQTAX')), "G46")
						
									If (lDelete .Or. !oModelG46:IsDeleted()) .And. !Empty(oModelG46:GetValue('G46_EMISS'))
										cRates += '<Rates>'
										cRates += 	'<RatesCode>' + AllTrim(oModelG46:GetValue('G46_SEQTAX')) + '</RatesCode>'
										cRates += 	'<RatesInternalId>' + cSeqID + '</RatesInternalId>'
										cRates += 	'<IssueDate>' + TxDtStamp(oModelG46:GetValue('G46_EMISS')) + '</IssueDate>'
										cRates += 	'<TravelRatesCode>' + AllTrim(oModelG46:GetValue('G46_CODTX')) + '</TravelRatesCode>'
										cRates += 	'<TravelRatesInternalId>' + TurXMakeID(AllTrim(oModelG46:GetValue('G46_CODTX')), "G3A") + '</TravelRatesInternalId>'
										cRates += 	'<Value>' + cValToChar(oModelG46:GetValue('G46_VLBASE')) + '</Value>'
										cRates += 	'<TravelCurrencyCode>' + AllTrim(oModelG46:GetValue('G46_MOEDFO')) + '</TravelCurrencyCode>'
										cRates += 	'<TravelCurrencyInternalId>' + TurXMakeID(AllTrim(oModelG46:GetValue('G46_MOEDFO')), 'G5T') + '</TravelCurrencyInternalId>'
										cRates += 	'<Exchange>' + cValToChar(oModelG46:GetValue('G46_TXCAMB')) + '</Exchange>'
										cRates += 	'<Observations>' + _NoTags(AllTrim(oModelG46:GetValue('G46_OBS'))) + '</Observations>'
										cRates += '</Rates>'
									EndIf

									If lDelete .Or. oModelG46:IsDeleted()
										CFGA070MNT(Nil, 'G46', 'G46_SEQTAX', Nil, cSeqID, .T.)
									EndIf
								Next nT
							EndIf

							If !Empty(cRates)
								cDocReserv += '<ListOfRates>' + cRates + '</ListOfRates>'
							EndIf
						
							// Extras -----------------------------------------------------------------------------------------
							cExtraTp  := ""
							oModelG47 := oModel:GetModel('G47_ITENS')
							If !oModelG47:IsEmpty()
								For nT := 1 to oModelG47:Length()
									oModelG47:GoLine(nT)
									cSeqID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG47:GetValue('G47_SEQ')), "G47")

									If (lDelete .Or. !oModelG47:IsDeleted()) .And. !Empty(oModelG47:GetValue('G47_EMISS'))
										cExtraTp += '<Extras>'
										cExtraTp += 	'<ExtrasCode>' + AllTrim(oModelG47:GetValue('G47_SEQ')) + '</ExtrasCode>'
										cExtraTp += 	'<ExtrasInternalId>' + cSeqID + '</ExtrasInternalId>'
										cExtraTp += 	'<IssueDate>' + TxDtStamp(oModelG47:GetValue('G47_EMISS')) + '</IssueDate>'
										cExtraTp += 	'<Description>' + AllTrim(oModelG47:GetValue('G47_EXTRA')) + '</Description>'
										cExtraTp += 	'<TravelCurrencyCode>' + AllTrim(oModelG47:GetValue('G47_MOEDFO')) + '</TravelCurrencyCode>'
										cExtraTp += 	'<TravelCurrencyInternalId>' + TurXMakeID(AllTrim(oModelG47:GetValue('G47_MOEDFO')), 'G5T') + '</TravelCurrencyInternalId>'
										cExtraTp += 	'<Exchange>' + cValToChar(oModelG47:GetValue('G47_TXCAMB')) + '</Exchange>'
										cExtraTp += 	'<UnitaryValue>' + cValToChar(oModelG47:GetValue('G47_VLUNIT')) + '</UnitaryValue>'
										cExtraTp += 	'<Quantity>' + cValToChar(oModelG47:GetValue('G47_QUANT')) + '</Quantity>'
										cExtraTp += 	'<AmountValue>' + cValToChar(oModelG47:GetValue('G47_TOTFOR')) + '</AmountValue>'
										cExtraTp += 	'<Observations>' + _NoTags(AllTrim(oModelG47:GetValue('G47_OBS'))) + '</Observations>'
										cExtraTp += '</Extras>'
									EndIf

									If lDelete .Or. oModelG47:IsDeleted()
										CFGA070MNT(Nil, 'G47', 'G47_SEQ', Nil, cSeqID, .T.)
									EndIf
								Next nT
							EndIf

							If !Empty(cExtraTp)
								cDocReserv += '<ListOfExtras>' + cExtraTp + '</ListOfExtras>'
							EndIf
						
							// Impostos -----------------------------------------------------------------------------------------
							cImposto  := ""
							oModelG49 := oModel:GetModel('G49_ITENS')
							If !oModelG47:IsEmpty()
								For nT := 1 to oModelG49:Length()
									oModelG49:GoLine(nT)
									cSeqID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG49:GetValue('G49_SEQ')), "G49")
							
									If (lDelete .Or. !oModelG49:IsDeleted()) .And. !Empty(oModelG49:GetValue('G49_CODIMP'))
										cImposto += '<Taxes>'
										cImposto +=		'<TravelTaxCode>' + AllTrim(oModelG49:GetValue('G49_SEQ')) + '</TravelTaxCode>'
										cImposto +=		'<TravelTaxInternalId>' + cSeqID + '</TravelTaxInternalId>'
										cImposto +=		'<TaxCode>' + AllTrim(oModelG49:GetValue('G49_CODIMP')) + '</TaxCode>'
										cImposto +=		'<TaxInternalId>' + TurXMakeID(AllTrim(oModelG49:GetValue('G49_CODIMP')), 'G5R') + '</TaxInternalId>'
										cImposto +=		'<Description>' + AllTrim(oModelG49:GetValue('G49_DESIMP')) + '</Description>'
										cImposto +=		'<TravelCurrencyCode>' + AllTrim(oModelG49:GetValue('G49_MOEDA')) + '</TravelCurrencyCode>'
										cImposto +=		'<TravelCurrencyInternalId>' + TurXMakeID(AllTrim(oModelG49:GetValue('G49_MOEDA')), 'G5T') + '</TravelCurrencyInternalId>'
										cImposto +=		'<TaxCalculationBase>' + cValToChar(oModelG49:GetValue('G49_BASE')) + '</TaxCalculationBase>'
										cImposto +=		'<TaxRate>' + cValToChar(oModelG49:GetValue('G49_ALIQ')) + '</TaxRate>'
										cImposto +=		'<AppliedTaxValue>' + cValToChar(oModelG49:GetValue('G49_VALOR')) + '</AppliedTaxValue>'
										cImposto += '</Taxes>'
									EndIf

									If lDelete .Or. oModelG49:IsDeleted()
										CFGA070MNT(Nil, 'G49', 'G49_SEQ', Nil, cSeqID, .T.)
									EndIf
								Next nT
							EndIf

							If !Empty(cImposto)
								cDocReserv += '<ListOfTaxes>' + cImposto + '</ListOfTaxes>'
							EndIf
						
							// Passageiros -----------------------------------------------------------------------------------------
							cPassanger := ""
							oModelG3S  := oModel:GetModel('G3S_ITENS')
							If !oModelG3S:IsEmpty()
								For nT := 1 to oModelG3S:Length()
									oModelG3S:GoLine(nT)
									cCodPax	:= AllTrim(oModelG3S:GetValue('G3S_CODPAX'))
									cPaxId  := TurXMakeID(cIntItemID + "|" + cCodPax, "G3S")
									
									If (lDelete .Or. !oModelG3S:IsDeleted()) .And. !Empty(oModelG3S:GetValue('G3S_TPPAX'))
										cPassanger += '<Passenger>'
										cPassanger += 	'<PassengerCode>' + cCodPax + '</PassengerCode>'
										cPassanger += 	'<PassengerInternalId>' + cPaxId + '</PassengerInternalId>'
										cPassanger += 	'<ContactCode>' + AllTrim(oModelG3S:GetValue('G3S_CONTAT')) + '</ContactCode>'
										cPassanger += 	'<ContactInternalId>' + TurXMakeID(AllTrim(oModelG3S:GetValue('G3S_CONTAT')), "SU5") + '</ContactInternalId>'
										cPassanger += 	'<PAXType>' + AllTrim(oModelG3S:GetValue('G3S_TPPAX')) + '</PAXType>'
										cPassanger += 	'<Treatment>' + AllTrim(oModelG3S:GetValue('G3S_TRATAM')) + '</Treatment>'
										cPassanger += 	'<FirstName>' + AllTrim(oModelG3S:GetValue('G3S_PRINOM')) + '</FirstName>'
										cPassanger += 	'<LastName>' + AllTrim(oModelG3S:GetValue('G3S_ULTNOM')) + '</LastName>'
										cPassanger += 	'<FullName>' + AllTrim(oModelG3S:GetValue('G3S_NOME')) + '</FullName>'
										cPassanger += 	'<Registration>' + AllTrim(oModelG3S:GetValue('G3S_MATRIC')) + '</Registration>'
										cPassanger += 	'<Gender>' + AllTrim(oModelG3S:GetValue('G3S_SEXO')) + '</Gender>'
										cPassanger += 	'<Nationality>' + AllTrim(oModelG3S:GetValue('G3S_NACION')) + '</Nationality>'
										cPassanger +=	'<BirthDate>' + TxDtStamp(oModelG3S:GetValue('G3S_DTNASC')) + '</BirthDate>'
										cPassanger += 	'<PAXEmail>' + AllTrim(oModelG3S:GetValue('G3S_EMAIL')) + '</PAXEmail>'
										cPassanger += 	'<VIP>' + AllTrim(oModelG3S:GetValue('G3S_VIP')) + '</VIP>'
										cPassanger += 	'<Outsourced>' + AllTrim(oModelG3S:GetValue('G3S_TERCEI')) + '</Outsourced>'

										// Informações Adicionais -----------------------------------------------------------------------------------------
										cAddEntit := ""
										oModelG4B := oModel:GetModel('G4B_ITENS')
										If !oModelG4B:IsEmpty()
											For nA := 1 to oModelG4B:Length()
												oModelG4B:GoLine(nA)
												cItemG4B := ""
												If (lDelete .Or. !oModelG4B:IsDeleted()) .And. !Empty(oModelG4B:GetValue('G4B_LOJA'))
													If !Empty(oModelG4B:GetValue('G4B_ITEM')) 
														G3G->(DbSetOrder(1))	// G3G_FILIAL+G3G_CLIENT+G3G_LOJA+G3G_TIPO+G3G_ITEM
														If G3G->(DbSeek(xFilial('G3G') + cCliente + oModelG4B:GetValue('G4B_LOJA') + oModelG4B:GetValue('G4B_TPENT') + AllTrim(oModelG4B:GetValue('G4B_ITEM'))))
															cItemG4B := TurXMakeID(cCliente + "|" + oModelG4B:GetValue('G4B_LOJA') + "|" + oModelG4B:GetValue('G4B_TPENT') + "|" + oModelG4B:GetValue('G4B_ITEM'), "G3G")
														EndIf
													EndIf

													cAddEntit += '<AdditionalEntities>'
													cAddEntit +=	'<AdditionalEntityTypeCode>' + oModelG4B:GetValue('G4B_TPENT') + '</AdditionalEntityTypeCode>'
													cAddEntit +=	'<AdditionalEntityTypeInternalId>' + TurXMakeID(oModelG4B:GetValue('G4B_TPENT'), 'G3E') + '</AdditionalEntityTypeInternalId>'
													cAddEntit +=	'<ReferenceStoreCode>' + cCliente + "|" + oModelG4B:GetValue('G4B_LOJA') + '</ReferenceStoreCode>'
													cAddEntit +=	'<ReferenceStoreInternalId>' + TurXMakeID(cCliente + "|" + oModelG4B:GetValue('G4B_LOJA') + "|C" , 'SA1') + '</ReferenceStoreInternalId>'
													cAddEntit +=	'<AdditionalEntityItemCode>' + AllTrim(oModelG4B:GetValue('G4B_ITEM')) + '</AdditionalEntityItemCode>'
													cAddEntit += 	'<AdditionalEntityItemInternalId>' + cItemG4B + '</AdditionalEntityItemInternalId>'
													cAddEntit += '</AdditionalEntities>'
												EndIf
											Next nA
										EndIf

										If !Empty(cAddEntit)
											cPassanger += '<ListOfAdditionalEntities>' + cAddEntit + '</ListOfAdditionalEntities>'
										EndIf

										cPassanger += '</Passenger>'
									EndIf

									If lDelete .Or. oModelG3S:IsDeleted()
										CFGA070MNT(Nil, 'G3S', 'G3S_CODPAX', Nil, cPaxId, .T.)
									EndIf
								Next nT
							EndIf

							If !Empty(cPassanger)
								cDocReserv += '<ListOfPassenger>' + cPassanger + '</ListOfPassenger>'
							EndIf

							// Reembolso -----------------------------------------------------------------------------------------
							cReemb    := ""
							oModelG4E := oModel:GetModel('G4E_ITENS')
							If !oModelG4E:IsEmpty()
								If (lDelete .Or. !oModelG4E:IsDeleted()) .And. !Empty(oModelG4E:GetValue('G4E_MOTREE'))
									cReemb += '<Refund>'
									cReemb += 	'<DocumentRequest>' + AllTrim(oModelG4E:GetValue('G4E_DTSOLI')) + '</DocumentRequest>'
									cReemb += 	'<RefundType>' + AllTrim(oModelG4E:GetValue('G4E_TPREE')) + '</RefundType>'
									cReemb += 	'<RefundReasonCode>' + AllTrim(oModelG4E:GetValue('G4E_MOTREE')) + '</RefundReasonCode>'
									cReemb += 	'<RefundReasonInternalId>' + TurXMakeId(AllTrim(oModelG4E:GetValue('G4E_MOTREE')), 'G8P') + '</RefundReasonInternalId>'
									cReemb += 	'<FinancialDestiny>' + AllTrim(oModelG4E:GetValue('G4E_DESTFN')) + '</FinancialDestiny>'
									cReemb += 	'<PredictionOfReceipt>' + TxDtStamp(oModelG4E:GetValue('G4E_DTPREV')) + '</PredictionOfReceipt>'
									cReemb += 	'<DateOfCreditAgency>' + TxDtStamp(oModelG4E:GetValue('G4E_DTCRED')) + '</DateOfCreditAgency>'
									cReemb += 	'<InternalNote>' + _NoTags(AllTrim(oModelG4E:GetValue('G4E_OBSINT'))) + '</InternalNote>'
									cReemb += 	'<BaseFare>' + AllTrim(oModelG4E:GetValue('G4E_BASTAR')) + '</BaseFare>'
									cReemb += 	'<FareType>' + AllTrim(oModelG4E:GetValue('G4E_TPTAR')) + '</FareType>'
									cReemb += 	'<TravelCurrencyCode>' + AllTrim(oModelG4E:GetValue('G4E_MOEDFO')) + '</TravelCurrencyCode>'
									cReemb += 	'<TravelCurrencyInternalId>' + TurxMakeId(AllTrim(oModelG4E:GetValue('G4E_MOEDFO')), 'G5T') + '</TravelCurrencyInternalId>'
									cReemb += 	'<Exchange>' + cValToChar(oModelG4E:GetValue('G4E_TXCAMB')) + '</Exchange>'
									cReemb += 	'<FarePaid>' + cValToChar(oModelG4E:GetValue('G4E_TARPAG')) + '</FarePaid>'
									cReemb += 	'<CurrencyCode>' + AllTrim(oModelG4E:GetValue('G4E_MOEDA')) + '</CurrencyCode>'
									cReemb += 	'<CurrencyInternalId>' + TurxMakeId(AllTrim(oModelG4E:GetValue('G4E_MOEDA')), 'G5T') + '</CurrencyInternalId>'
									cReemb += 	'<NationalFarePaid>' + cValToChar(oModelG4E:GetValue('G4E_TPGINT')) + '</NationalFarePaid>'
									cReemb += 	'<FaresUsed>' + cValToChar(oModelG4E:GetValue('G4E_TARUTI')) + '</FaresUsed>'
									cReemb += 	'<FaresRefunded>' + cValToChar(oModelG4E:GetValue('G4E_TREEMB')) + '</FaresRefunded>'
									cReemb += 	'<RatesPaid>' + cValToChar(oModelG4E:GetValue('G4E_TXPG')) + '</RatesPaid>'
									cReemb += 	'<RatesRefunded>' + cValToChar(oModelG4E:GetValue('G4E_TXREEM')) + '</RatesRefunded>'
									cReemb += 	'<ExtrasPaid>' + cValToChar(oModelG4E:GetValue('G4E_EXTPG')) + '</ExtrasPaid>'
									cReemb += 	'<ExtrasRefunded>' + cValToChar(oModelG4E:GetValue('G4E_EXREEM')) + '</ExtrasRefunded>'
									cReemb += 	'<CalculationNote>' + _NoTags(AllTrim(oModelG4E:GetValue('G4E_OBSCAL'))) + '</CalculationNote>'
									cReemb += '</Refund>'
								EndIf
							EndIf

							If !Empty(cReemb)
								cDocReserv += cReemb
							EndIf

							// Segmento AEREO -----------------------------------------------------------------------------------------
							cSegment  := ""
							oModelG3T := oModel:GetModel('G3T_ITENS')
							If !oModelG3T:IsEmpty()
								For nZ := 1 to oModelG3T:Length()
									oModelG3T:GoLine(nZ)
									cSegID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3T:GetValue('G3T_ID')), "G3T")
								
									If (lDelete .Or. !oModelG3T:IsDeleted()) .And. !Empty(oModelG3T:GetValue('G3T_CODFOR'))
										cSegment += '<SegmentAir>'
										cSegment += 	'<SegmentCode>' + AllTrim(oModelG3T:GetValue('G3T_ID')) + '</SegmentCode>'
										cSegment += 	'<SegmentInternalId>' + cSegID + '</SegmentInternalId>'
										cSegment += 	'<IntegrationID>' + AllTrim(oModelG3T:GetValue('G3T_IDINTE')) + '</IntegrationID>'
										cSegment += 	'<PassengerCode>' + AllTrim(oModelG3T:GetValue('G3T_CODPAX')) + '</PassengerCode>'
										cSegment += 	'<PassengerInternalId>' + TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3T:GetValue('G3T_CODPAX')), "G3S") + '</PassengerInternalId>'
										cSegment += 	'<Locator>' + AllTrim(oModelG3T:GetValue('G3T_LOC')) + '</Locator>'
										cSegment += 	'<ProductVendorCode>' + oModelG3T:GetValue('G3T_CODFOR') + '|' + oModelG3T:GetValue('G3T_LOJAF') + '|F' + '</ProductVendorCode>'
										cSegment += 	'<ProductVendorInternalId>' + IntForExt( , , oModelG3T:GetValue('G3T_CODFOR'), oModelG3T:GetValue('G3T_LOJAF'))[2] + '</ProductVendorInternalId>'
										cSegment += 	'<GDS>' + AllTrim(oModelG3T:GetValue('G3T_GDS')) + '</GDS>'
										cSegment += 	'<Aircraft>' + AllTrim(oModelG3T:GetValue('G3T_AERONA')) + '</Aircraft>'
										cSegment += 	'<AirportOriginCode>' + Posicione('G3B', 2, xFilial("G3B") + AllTrim(oModelG3T:GetValue('G3T_TERORI')), 'G3B_CODIGO') + '</AirportOriginCode>'
										cSegment += 	'<AirportOriginInternalId>' + TurXMakeID(Posicione('G3B', 2, xFilial("G3B") + AllTrim(oModelG3T:GetValue('G3T_TERORI')), 'G3B_CODIGO'), 'G3B') + '</AirportOriginInternalId>'
										cSegment += 	'<AirportDestinyCode>' + Posicione('G3B', 2, xFilial("G3B") + AllTrim(oModelG3T:GetValue('G3T_TERDST')), 'G3B_CODIGO') + '</AirportDestinyCode>'
										cSegment += 	'<AirportDestinyInternalId>' + TurXMakeID(Posicione('G3B', 2, xFilial("G3B") + AllTrim(oModelG3T:GetValue('G3T_TERDST')), 'G3B_CODIGO'), 'G3B') + '</AirportDestinyInternalId>'
										cSegment += 	'<ServiceClassCode>' + AllTrim(oModelG3T:GetValue('G3T_CLASRV')) + '</ServiceClassCode>'
										cSegment += 	'<ServiceClassInternalId>' + TurXMakeID(oModelG3T:GetValue('G3T_CODFOR') + '|' + oModelG3T:GetValue('G3T_LOJAF') + "|" + AllTrim(oModelG3T:GetValue('G3T_CLASRV')), 'G3C') + '</ServiceClassInternalId>'
										cSegment += 	'<FlightNumber>' + AllTrim(oModelG3T:GetValue('G3T_NRVOO')) + '</FlightNumber>'
										cSegment += 	'<DepartureDate>' + TxDtStamp(oModelG3T:GetValue('G3T_DTSAID')) + '</DepartureDate>'
										cSegment += 	'<DepartureTime>' + AllTrim(oModelG3T:GetValue('G3T_HRINI')) + '</DepartureTime>'
										cSegment += 	'<ArrivalDate>' + TxDtStamp(oModelG3T:GetValue('G3T_DTCHEG')) + '</ArrivalDate>'
										cSegment += 	'<ArrivalTime>' + AllTrim(oModelG3T:GetValue('G3T_HRFIM')) + '</ArrivalTime>'
										cSegment += 	'<StopType>' + AllTrim(oModelG3T:GetValue('G3T_TPPARA')) + '</StopType>'
										cSegment += 	'<FlightTime>' + AllTrim(oModelG3T:GetValue('G3T_TMPVOO')) + '</FlightTime>'
										cSegment += 	'<StopQuantity>' + cValToChar(oModelG3T:GetValue('G3T_QTDESC')) + '</StopQuantity>'
										cSegment += 	'<Observation>' + _NoTags(AllTrim(oModelG3T:GetValue('G3T_OBS'))) + '</Observation>'
										cSegment += '</SegmentAir>'
									EndIf

									If lDelete .Or. oModelG3T:IsDeleted()
										CFGA070MNT(Nil, 'G3T', 'G3T_ID', Nil, cSegID, .T.)
									EndIf
								Next nZ
							EndIf

							If !Empty(cSegment)
								cDocReserv += '<ListOfSegmentAir>' + cSegment + '</ListOfSegmentAir>'
							EndIf

							// Segmento HOTEL -----------------------------------------------------------------------------------------
							cSegment  := ""
							oModelG3U := oModel:GetModel('G3U_ITENS')
							If !oModelG3U:IsEmpty()
								For nZ := 1 to oModelG3U:Length()
									oModelG3U:GoLine(nZ)
									cSegID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3U:GetValue('G3U_ID')), "G3U")

									If (lDelete .Or. !oModelG3U:IsDeleted()) .And. !Empty(oModelG3U:GetValue('G3U_DTINI'))
										cSegment += '<SegmentHotel>'
										cSegment += 	'<SegmentCode>' + AllTrim(oModelG3U:GetValue('G3U_ID')) + '</SegmentCode>'
										cSegment += 	'<SegmentInternalId>' + cSegID + '</SegmentInternalId>'
										cSegment += 	'<IntegrationID>' + AllTrim(oModelG3U:GetValue('G3U_IDINTE')) + '</IntegrationID>'
										cSegment += 	'<PassengerCode>' + AllTrim(oModelG3U:GetValue('G3U_CODPAX')) + '</PassengerCode>'
										cSegment += 	'<PassengerInternalId>' + TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3U:GetValue('G3U_CODPAX')), "G3S") + '</PassengerInternalId>'
										cSegment += 	'<TravelCity>' + AllTrim(oModelG3U:GetValue('G3U_CIDHOT')) + '</TravelCity>'
										cSegment += 	'<CheckinDate>' + TxDtStamp(oModelG3U:GetValue('G3U_DTINI')) + '</CheckinDate>'
										cSegment += 	'<CheckoutDate>' + TxDtStamp(oModelG3U:GetValue('G3U_DTFIM')) + '</CheckoutDate>'
										cSegment += 	'<CheckinTime>' + AllTrim(oModelG3U:GetValue('G3U_HRINI')) + '</CheckinTime>'
										cSegment += 	'<CheckoutTime>' + AllTrim(oModelG3U:GetValue('G3U_HRFIM')) + '</CheckoutTime>'
										cSegment += 	'<HotelProductType>' + AllTrim(oModelG3U:GetValue('G3U_TPPROD')) + '</HotelProductType>'
										cSegment += 	'<NumberOfProducts>' + cValToChar(oModelG3U:GetValue('G3U_QTDPRD')) + '</NumberOfProducts>'
										cSegment += 	'<RoomCode>' + AllTrim(oModelG3U:GetValue('G3U_CATPRO')) + '</RoomCode>'
										cSegment += 	'<ApartamentTypeCode>' + AllTrim(oModelG3U:GetValue('G3U_CODAPO')) + '</ApartamentTypeCode>'
										cSegment += 	'<ApartamentTypeInternalId>' + TurXMakeID(AllTrim(oModelG3U:GetValue('G3U_CODAPO')), 'G4J') + '</ApartamentTypeInternalId>'
										cSegment += 	'<CancellationDeadline>' + TxDtStamp(oModelG3U:GetValue('G3U_PRZCAN')) + '</CancellationDeadline>'
										cSegment += 	'<NoShowWarranty>' + AllTrim(oModelG3U:GetValue('G3U_NOSHOW')) + '</NoShowWarranty>'
										cSegment += 	'<FoodServiceCode>' + AllTrim(oModelG3U:GetValue('G3U_PLALIM')) + '</FoodServiceCode>'
										cSegment += 	'<BrokerSystemCode>' + AllTrim(oModelG3U:GetValue('G3U_BROKER')) + '</BrokerSystemCode>'
										cSegment += 	'<BrokerSystemInternalId>' + TurXMakeID(AllTrim(oModelG3U:GetValue('G3U_BROKER')), 'G8O') + '</BrokerSystemInternalId>'
										cSegment += 	'<Observation>' + _NoTags(AllTrim(oModelG3U:GetValue('G3U_OBS'))) + '</Observation>'
										cSegment += '</SegmentHotel>'
									EndIf
								
									If lDelete .Or. oModelG3U:IsDeleted()
										CFGA070MNT(Nil, 'G3U', 'G3U_ID', Nil, cSegID, .T.)
									EndIf
								Next nZ
							EndIf
							
							If !Empty(cSegment)
								cDocReserv += '<ListOfSegmentHotel>' + cSegment + '</ListOfSegmentHotel>'
							EndIf

							// Segmento CARRO -----------------------------------------------------------------------------------------
							cSegment  := ""
							oModelG3V := oModel:GetModel('G3V_ITENS')
							If !oModelG3V:IsEmpty()
								For nZ := 1 to oModelG3V:Length()
									oModelG3V:GoLine(nZ)
									cSegID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3V:GetValue('G3V_ID')), "G3V")

									If (lDelete .Or. !oModelG3V:IsDeleted()) .And. !Empty(oModelG3V:GetValue('G3V_CIDRET'))
										cSegment += '<SegmentVehicle>'
										cSegment += 	'<SegmentCode>' + AllTrim(oModelG3V:GetValue('G3V_ID')) + '</SegmentCode>'
										cSegment += 	'<SegmentInternalId>' + cSegID + '</SegmentInternalId>'
										cSegment += 	'<IntegrationID>' + AllTrim(oModelG3V:GetValue('G3V_IDINTE')) + '</IntegrationID>'
										cSegment += 	'<PassengerCode>' + AllTrim(oModelG3V:GetValue('G3V_CODPAX')) + '</PassengerCode>'
										cSegment += 	'<PassengerInternalId>' + TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3V:GetValue('G3V_CODPAX')), "G3S") + '</PassengerInternalId>'
										cSegment += 	'<PickUpCityCode>' + AllTrim(oModelG3V:GetValue('G3V_CIDRET')) + '</PickUpCityCode>' 
										cSegment += 	'<PickUpCityInternalId>' + TurXMakeID(AllTrim(oModelG3V:GetValue('G3V_CIDRET')), 'G5S') + '</PickUpCityInternalId>' 
										cSegment += 	'<PickUpLocation>' + AllTrim(oModelG3V:GetValue('G3V_LOCRET')) + '</PickUpLocation>'
										cSegment += 	'<ReturnCityCode>' + AllTrim(oModelG3V:GetValue('G3V_CIDDEV')) + '</ReturnCityCode>'
										cSegment += 	'<ReturnCityInternalId>' + TurXMakeID(AllTrim(oModelG3V:GetValue('G3V_CIDDEV')), 'G5S') + '</ReturnCityInternalId>'
										cSegment += 	'<ReturnLocation>' + AllTrim(oModelG3V:GetValue('G3V_LOCDEV')) + '</ReturnLocation>'
										cSegment += 	'<NumberOfVehicle>' + cValToChar(oModelG3V:GetValue('G3V_QTDPRD')) + '</NumberOfVehicle>'
										cSegment += 	'<VehicleCategoryCode>' + AllTrim(oModelG3V:GetValue('G3V_CATAUT')) + '</VehicleCategoryCode>'
										cSegment += 	'<VehicleCategoryInternalId>' + TurXMakeID(AllTrim(oModelG3V:GetValue('G3V_CATAUT')), 'G4Y') + '</VehicleCategoryInternalId>'
										cSegment += 	'<VehicleTypeCode>' + AllTrim(oModelG3V:GetValue('G3V_TPAUT')) + '</VehicleTypeCode>'
										cSegment += 	'<VehicleTypeInternalId>' + TurXMakeID(AllTrim(oModelG3V:GetValue('G3V_TPAUT')), 'G4Z') + '</VehicleTypeInternalId>'
										cSegment += 	'<DirectionTypeCode>' + AllTrim(oModelG3V:GetValue('G3V_TRADIR')) + '</DirectionTypeCode>'
										cSegment += 	'<DirectionTypeInternalId>' + TurXMakeID(AllTrim(oModelG3V:GetValue('G3V_TRADIR')), 'G50') + '</DirectionTypeInternalId>'
										cSegment += 	'<FuelTypeCode>' + TurXMakeID(AllTrim(oModelG3V:GetValue('G3V_COMBAR')), 'G51') + '</FuelTypeCode>'
										cSegment += 	'<FuelTypeInternalId>' + TurXMakeID(AllTrim(oModelG3V:GetValue('G3V_COMBAR')), 'G51') + '</FuelTypeInternalId>'
										cSegment += 	'<PickUpDate>' + TxDtStamp(oModelG3V:GetValue('G3V_DTINI')) + '</PickUpDate>'
										cSegment += 	'<PickUpTime>' + AllTrim(oModelG3V:GetValue('G3V_HRINI')) + '</PickUpTime>'
										cSegment += 	'<ReturnDate>' + TxDtStamp(oModelG3V:GetValue('G3V_DTFIM')) + '</ReturnDate>'
										cSegment += 	'<ReturnTime>' + AllTrim(oModelG3V:GetValue('G3V_HRFIM')) + '</ReturnTime>'
										cSegment += 	'<BrokerSystemCode>' + AllTrim(oModelG3V:GetValue('G3V_BROKER')) + '</BrokerSystemCode>'
										cSegment += 	'<BrokerSystemInternalId>' + TurXMakeID(AllTrim(oModelG3V:GetValue('G3V_BROKER')), 'G8O') + '</BrokerSystemInternalId>'
										cSegment += 	'<Daily>' + cValToChar(oModelG3V:GetValue('G3V_QTDDIA')) + '</Daily>'
										cSegment += 	'<CancellationDeadline>' + TxDtStamp(oModelG3V:GetValue('G3V_DTCANC')) + '</CancellationDeadline>'
										cSegment += 	'<NoShowWarranty>' + AllTrim(oModelG3V:GetValue('G3V_NOSHOW')) + '</NoShowWarranty>'
										cSegment += 	'<Observation>' + _NoTags(AllTrim(oModelG3V:GetValue('G3V_OBS'))) + '</Observation>'
										cSegment += '</SegmentVehicle>'
									EndIf
									
									If lDelete .Or. oModelG3V:IsDeleted()
										CFGA070MNT(Nil, 'G3V', 'G3V_ID', Nil, cSegID, .T.)
									EndIf
								Next nZ
							EndIf

							If !Empty(cSegment)
								cDocReserv += '<ListOfSegmentVehicle>' + cSegment + '</ListOfSegmentVehicle>'
							EndIf

							// Segmento RODOVIARIO -----------------------------------------------------------------------------------------
							cSegment  := ""
							oModelG3W := oModel:GetModel('G3W_ITENS')
							If !oModelG3W:IsEmpty()
								For nZ := 1 to oModelG3W:Length()
									oModelG3W:GoLine(nZ)
									cSegID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3W:GetValue('G3W_ID')), "G3W")

									If (lDelete .Or. !oModelG3W:IsDeleted()) .And. !Empty(oModelG3W:GetValue('G3W_CIDEMB'))
										cSegment += '<SegmentRoad>'
										cSegment += 	'<SegmentCode>' + AllTrim(oModelG3W:GetValue('G3W_ID')) + '</SegmentCode>'
										cSegment += 	'<SegmentInternalId>' + cSegID + '</SegmentInternalId>'
										cSegment += 	'<IntegrationID>' + AllTrim(oModelG3W:GetValue('G3W_IDINTE')) + '</IntegrationID>'
										cSegment += 	'<PassengerCode>' + AllTrim(oModelG3W:GetValue('G3W_CODPAX')) + '</PassengerCode>'
										cSegment += 	'<PassengerInternalId>' + TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3W:GetValue('G3W_CODPAX')), "G3S") + '</PassengerInternalId>'
										cSegment += 	'<VehicleDescription>' + AllTrim(oModelG3W:GetValue('G3W_VEICUL')) + '</VehicleDescription>'
										cSegment += 	'<RoadLineCode>' + AllTrim(oModelG3W:GetValue('G3W_LINHA')) + '</RoadLineCode>'
										cSegment += 	'<RoadLineInternalId>' + TurXMakeID(AllTrim(oModelG3W:GetValue('G3W_LINHA')), 'G8M') + '</RoadLineInternalId>'
										cSegment += 	'<StretchCode>' + AllTrim(oModelG3W:GetValue('G3W_LINHA')) + "|" + AllTrim(oModelG3W:GetValue('G3W_TRECHO')) + '</StretchCode>'
										cSegment += 	'<StretchInternalId>' + TurXMakeID(AllTrim(oModelG3W:GetValue('G3W_LINHA')) + "|" + AllTrim(oModelG3W:GetValue('G3W_TRECHO')), 'G8N') + '</StretchInternalId>'
										cSegment += 	'<BusCategory>' + AllTrim(oModelG3W:GetValue('G3W_CATBUS')) + '</BusCategory>'
										cSegment += 	'<DepartureCityCode>' + AllTrim(oModelG3W:GetValue('G3W_CIDEMB')) + '</DepartureCityCode>'
										cSegment += 	'<DepartureCityInternalId>' + TurXMakeID(AllTrim(oModelG3W:GetValue('G3W_CIDEMB')), 'G5S') + '</DepartureCityInternalId>'
										cSegment += 	'<ArrivalCityCode>' + AllTrim(oModelG3W:GetValue('G3W_CIDDES')) + '</ArrivalCityCode>'
										cSegment += 	'<ArrivalCityInternalId>' + TurXMakeID(AllTrim(oModelG3W:GetValue('G3W_CIDDES')), 'G5S') + '</ArrivalCityInternalId>'
										cSegment += 	'<ArrivalLocation>' + AllTrim(oModelG3W:GetValue('G3W_LOCDES')) + '</ArrivalLocation>'
										cSegment += 	'<DepartureDate>' + TxDtStamp(oModelG3W:GetValue('G3W_DTINI')) + '</DepartureDate>'
										cSegment += 	'<DepartureTime>' + AllTrim(oModelG3W:GetValue('G3W_HRINI')) + '</DepartureTime>'
										cSegment += 	'<ArrivalDate>' + TxDtStamp(oModelG3W:GetValue('G3W_DTFIM')) + '</ArrivalDate>'
										cSegment += 	'<ArrivalTime>' + AllTrim(oModelG3W:GetValue('G3W_HRFIM')) + '</ArrivalTime>'
										cSegment += 	'<Observation>' + _NoTags(AllTrim(oModelG3W:GetValue('G3W_OBS'))) + '</Observation>'
										cSegment += '</SegmentRoad>'
									EndIf

									If lDelete .Or. oModelG3W:IsDeleted()
										CFGA070MNT(Nil, 'G3W', 'G3W_ID', Nil, cSegID, .T.)
									EndIf
								Next nZ
							EndIf
							If !Empty(cSegment)
								cDocReserv += '<ListOfSegmentRoad>' + cSegment + '</ListOfSegmentRoad>'
							EndIf
						
							// Segmento TREM -----------------------------------------------------------------------------------------
							cSegment  := ""
							oModelG3X := oModel:GetModel('G3X_ITENS')
							If !oModelG3X:IsEmpty()
								For nZ := 1 to oModelG3X:Length()
									oModelG3X:GoLine(nZ)
									cSegID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3X:GetValue('G3X_ID')), "G3X")

									If (lDelete .Or. !oModelG3X:IsDeleted()) .And. !Empty(oModelG3X:GetValue('G3X_CTTREM'))
										cSegment += '<SegmentTrain>'
										cSegment += 	'<SegmentCode>' + AllTrim(oModelG3X:GetValue('G3X_ID')) + '</SegmentCode>'
										cSegment += 	'<SegmentInternalId>' + cSegID + '</SegmentInternalId>'
										cSegment += 	'<IntegrationID>' + AllTrim(oModelG3X:GetValue('G3X_IDINTE')) + '</IntegrationID>'
										cSegment += 	'<PassengerCode>' + AllTrim(oModelG3X:GetValue('G3X_CODPAX')) + '</PassengerCode>'
										cSegment += 	'<PassengerInternalId> ' + TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3X:GetValue('G3X_CODPAX')), "G3S") + '</PassengerInternalId>'
										cSegment += 	'<Description>' + AllTrim(oModelG3X:GetValue('G3X_DESFER')) + '</Description>'
										cSegment += 	'<Category>' + AllTrim(oModelG3X:GetValue('G3X_CTTREM')) + '</Category>'
										cSegment += 	'<Number>' + AllTrim(oModelG3X:GetValue('G3X_NRTREM')) + '</Number>'
										cSegment += 	'<StopQuantity>' + cValToChar(oModelG3X:GetValue('G3X_QTDPAR')) + '</StopQuantity>'
										cSegment += 	'<DepartureCityCode>' + AllTrim(oModelG3X:GetValue('G3X_CIDEMB')) + '</DepartureCityCode>'
										cSegment += 	'<DepartureCityInternalId>' + TurXMakeID(AllTrim(oModelG3X:GetValue('G3X_CIDEMB')), 'G5S') + '</DepartureCityInternalId>'
										cSegment += 	'<ArrivalCityCode>' + AllTrim(oModelG3X:GetValue('G3X_CIDDES')) + '</ArrivalCityCode>'
										cSegment += 	'<ArrivalCityInternalId>' + TurXMakeID(AllTrim(oModelG3X:GetValue('G3X_CIDDES')), 'G5S') + '</ArrivalCityInternalId>'
										cSegment += 	'<DepartureDate>' + TxDtStamp(oModelG3X:GetValue('G3X_DTINI')) + '</DepartureDate>'
										cSegment += 	'<DepartureTime>' + AllTrim(oModelG3X:GetValue('G3X_HRINI')) + '</DepartureTime>'
										cSegment += 	'<ArrivalDate>' + TxDtStamp(oModelG3X:GetValue('G3X_DTFIM')) + '</ArrivalDate>'
										cSegment += 	'<ArrivalTime>' + AllTrim(oModelG3X:GetValue('G3X_HRFIM')) + '</ArrivalTime>'
										cSegment += 	'<Observation>' + _NoTags(AllTrim(oModelG3X:GetValue('G3X_OBS'))) + '</Observation>'
										cSegment += '</SegmentTrain>'
									EndIf

									If lDelete .Or. oModelG3X:IsDeleted()
										CFGA070MNT(Nil, 'G3X', 'G3X_ID', Nil, cSegID, .T.)
									EndIf
								Next nZ
							EndIf

							If !Empty(cSegment)
								cDocReserv += '<ListOfSegmentTrain>' + cSegment + '</ListOfSegmentTrain>'
							EndIf

							// Segmento CRUZEIRO -----------------------------------------------------------------------------------------
							cSegment  := ""
							oModelG3Y := oModel:GetModel('G3Y_ITENS')
							If !oModelG3Y:IsEmpty()
								For nZ := 1 to oModelG3Y:Length()
									oModelG3Y:GoLine(nZ)
									cSegID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3Y:GetValue('G3Y_ID')), "G3Y")

									If (lDelete .Or. !oModelG3Y:IsDeleted()) .And. !Empty(oModelG3Y:GetValue('G3Y_CODNAV'))
										cSegment += '<SegmentMaritime>'
										cSegment += 	'<SegmentCode>'+ AllTrim(oModelG3Y:GetValue('G3Y_ID')) + '</SegmentCode>'
										cSegment += 	'<SegmentInternalId>' + cSegID + '</SegmentInternalId>'
										cSegment += 	'<IntegrationID>' + AllTrim(oModelG3Y:GetValue('G3Y_IDINTE')) + '</IntegrationID>'
										cSegment += 	'<PassengerCode>' + AllTrim(oModelG3Y:GetValue('G3Y_CODPAX')) + '</PassengerCode>'
										cSegment += 	'<PassengerInternalId>' + TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3Y:GetValue('G3Y_CODPAX')), "G3S") + '</PassengerInternalId>'
										cSegment += 	'<ShipCode>' + TurXMakeID(AllTrim(oModelG3Y:GetValue('G3Y_CODNAV')), 'G4H') + '</ShipCode>'
										cSegment += 	'<ShipInternalId>' + TurXMakeID(AllTrim(oModelG3Y:GetValue('G3Y_CODNAV')), 'G4H') + '</ShipInternalId>'
										cSegment += 	'<CruiseDescription>' + _NoTags(AllTrim(oModelG3Y:GetValue('G3Y_DESNAV'))) + '</CruiseDescription>'
										cSegment += 	'<MainCityCode>' + AllTrim(oModelG3Y:GetValue('G3Y_CIDPRI')) + '</MainCityCode>'
										cSegment += 	'<MainCityInternalId>' + TurXMakeID(AllTrim(oModelG3Y:GetValue('G3Y_CIDPRI')), 'G5S') + '</MainCityInternalId>'
										cSegment += 	'<DepartureCityCode>' + AllTrim(oModelG3Y:GetValue('G3Y_CIDEMB')) + '</DepartureCityCode>'
										cSegment += 	'<DepartureCityInternalId>' + TurXMakeID(AllTrim(oModelG3Y:GetValue('G3Y_CIDEMB')), 'G5S') + '</DepartureCityInternalId>'
										cSegment += 	'<InitialDate>' + TxDtStamp(oModelG3Y:GetValue('G3Y_DTINI')) + '</InitialDate>'
										cSegment += 	'<FinalDate>' + TxDtStamp(oModelG3Y:GetValue('G3Y_DTFIM')) + '</FinalDate>'
										cSegment += 	'<InitialTime>' + AllTrim(oModelG3Y:GetValue('G3Y_HRINI')) + '</InitialTime>'
										cSegment += 	'<FinalTime>' + AllTrim(oModelG3Y:GetValue('G3Y_HRFIM')) + '</FinalTime>'
										cSegment += 	'<CabinTypeCode>' + AllTrim(oModelG3Y:GetValue('G3Y_TPCABI')) + '</CabinTypeCode>'
										cSegment += 	'<CabinTypeInternalId>' + TurXMakeID(AllTrim(oModelG3Y:GetValue('G3Y_TPCABI')), 'G4I') + '</CabinTypeInternalId>'
										cSegment += 	'<CabinNumber>' + AllTrim(oModelG3Y:GetValue('G3Y_NRCABI')) + '</CabinNumber>'
										cSegment += 	'<CancellationDeadline>' + TxDtStamp(oModelG3Y:GetValue('G3Y_DTCANC')) +'</CancellationDeadline>'
										cSegment += 	'<Observation>' + _NoTags(AllTrim(oModelG3Y:GetValue('G3Y_OBS'))) + '</Observation>'
										cSegment += '</SegmentMaritime>'
									EndIf

									If lDelete .Or. oModelG3Y:IsDeleted()
										CFGA070MNT(Nil, 'G3Y', 'G3Y_ID', Nil, cSegID, .T.)
									EndIf
								Next nZ
							EndIf

							If !Empty(cSegment)
								cDocReserv += '<ListOfSegmentMaritime>' + cSegment + '</ListOfSegmentMaritime>'
							EndIf

							// Segmento PACOTE -----------------------------------------------------------------------------------------
							cSegment  := ""
							oModelG3Z := oModel:GetModel('G3Z_ITENS')
							If !oModelG3Z:IsEmpty()
								For nZ := 1 to oModelG3Z:Length()
									oModelG3Z:GoLine(nZ)
									cSegID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3Z:GetValue('G3Z_ID')), "G3Z")

									If (lDelete .Or. !oModelG3Z:IsDeleted()) .And. !Empty(oModelG3Z:GetValue('G3Z_CIDPRI'))
										cSegment += '<SegmentPackage>'
										cSegment += 	'<SegmentCode>' + AllTrim(oModelG3Z:GetValue('G3Z_ID')) + '</SegmentCode>'
										cSegment += 	'<SegmentInternalId>' + cSegID + '</SegmentInternalId>'
										cSegment += 	'<IntegrationID>' + AllTrim(oModelG3Z:GetValue('G3Z_IDINTE')) + '</IntegrationID>'
										cSegment += 	'<PassengerCode>' + AllTrim(oModelG3Z:GetValue('G3Z_CODPAX')) + '</PassengerCode>'
										cSegment += 	'<PassengerInternalId>' + TurXMakeID(cIntItemID + "|" + AllTrim(oModelG3Z:GetValue('G3Z_CODPAX')), "G3S") + '</PassengerInternalId>'
										cSegment += 	'<PackageDescription>' + _NoTags(AllTrim(oModelG3Z:GetValue('G3Z_DESPAC'))) + '</PackageDescription>'
										cSegment += 	'<MainCityCode>' + AllTrim(oModelG3Z:GetValue('G3Z_CIDPRI')) + '</MainCityCode>'
										cSegment += 	'<MainCityInternalId>' + TurXMakeID(AllTrim(oModelG3Z:GetValue('G3Z_CIDPRI')), 'G5S') + '</MainCityInternalId>'
										cSegment += 	'<DepartureCityCode>' + AllTrim(oModelG3Z:GetValue('G3Z_CIDEMB')) + '</DepartureCityCode>'
										cSegment += 	'<DepartureCityInternalId>' + TurXMakeID(AllTrim(oModelG3Z:GetValue('G3Z_CIDEMB')), 'G5S') + '</DepartureCityInternalId>'
										cSegment += 	'<InitialDate>' + TxDtStamp(oModelG3Z:GetValue('G3Z_DTINI')) + '</InitialDate>'
										cSegment += 	'<InitialTime>' + TxDtStamp(oModelG3Z:GetValue('G3Z_DTFIM')) + '</InitialTime>'
										cSegment += 	'<FinalDate>' + AllTrim(oModelG3Z:GetValue('G3Z_HRINI')) + '</FinalDate>'
										cSegment += 	'<FinalTime>' + AllTrim(oModelG3Z:GetValue('G3Z_HRFIM')) + '</FinalTime>'
										cSegment += 	'<NumberOfPackage>' + cValToChar(oModelG3Z:GetValue('G3Z_QTDPAC')) + '</NumberOfPackage>'
										cSegment += 	'<CancellationDeadline>' + TxDtStamp(oModelG3Z:GetValue('G3Z_DTCANC')) + '</CancellationDeadline>'
										cSegment += 	'<Observation>' + _NoTags(AllTrim(oModelG3Z:GetValue('G3Z_OBS'))) + '</Observation>'
										cSegment += '</SegmentPackage>'
									EndIf

									If lDelete .Or. oModelG3Z:IsDeleted()
										CFGA070MNT(Nil, 'G3Z', 'G3Z_ID', Nil, cSegID, .T.)
									EndIf
								Next nZ
							EndIf

							If !Empty(cSegment)
								cDocReserv += '<ListOfSegmentPackage>' + cSegment + '</ListOfSegmentPackage>'
							EndIf

							// Segmento TOUR -----------------------------------------------------------------------------------------
							cSegment  := ""
							oModelG40 := oModel:GetModel('G40_ITENS')
							If !oModelG40:isEmpty()
								For nZ := 1 to oModelG40:Length()
									oModelG40:GoLine(nZ)
									cSegID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG40:GetValue('G40_ID')), "G40")

									If (lDelete .Or. !oModelG40:IsDeleted()) .And. !Empty(oModelG40:GetValue('G40_CIDPRI'))
										cSegment += '<SegmentTour>'
										cSegment += 	'<SegmentCode>' + AllTrim(oModelG40:GetValue('G40_ID')) + '</SegmentCode>'
										cSegment += 	'<SegmentInternalId>' + cSegID + '</SegmentInternalId>'
										cSegment += 	'<IntegrationID>' + AllTrim(oModelG40:GetValue('G40_IDINTE')) + '</IntegrationID>'
										cSegment += 	'<PassengerCode>' + AllTrim(oModelG40:GetValue('G40_CODPAX')) + '</PassengerCode>'
										cSegment += 	'<PassengerInternalId>' + TurXMakeID(cIntItemID + "|" + AllTrim(oModelG40:GetValue('G40_CODPAX')), "G3S") + '</PassengerInternalId>'
										cSegment += 	'<TourName>' + AllTrim(oModelG40:GetValue('G40_NMTOUR')) + '</TourName>'
										cSegment += 	'<TourDescription>' + _NoTags(AllTrim(oModelG40:GetValue('G40_DSTOUR'))) + '</TourDescription>'
										cSegment += 	'<MainCityCode>' + AllTrim(oModelG40:GetValue('G40_CIDPRI')) + '</MainCityCode>'
										cSegment += 	'<MainCityInternalId>' + TurXMakeID(AllTrim(oModelG40:GetValue('G40_CIDPRI')), 'G5S') + '</MainCityInternalId>'
										cSegment += 	'<DepartureCityCode>' + AllTrim(oModelG40:GetValue('G40_CIDEMB')) + '</DepartureCityCode>'
										cSegment += 	'<DepartureCityInternalId>' + TurXMakeID(AllTrim(oModelG40:GetValue('G40_CIDEMB')), 'G5S') + '</DepartureCityInternalId>'
										cSegment += 	'<DepartureLocation>' + AllTrim(oModelG40:GetValue('G40_LOCEMB')) + '</DepartureLocation>'
										cSegment += 	'<ArrivalLocation>' + AllTrim(oModelG40:GetValue('G40_LOCDES')) + '</ArrivalLocation>'
										cSegment += 	'<InitialDate>' + TxDtStamp(oModelG40:GetValue('G40_DTINI')) + '</InitialDate>'
										cSegment += 	'<FinalDate>' + TxDtStamp(oModelG40:GetValue('G40_DTFIM')) + '</FinalDate>'
										cSegment += 	'<InitialTime>' + AllTrim(oModelG40:GetValue('G40_HRINI')) + '</InitialTime>'
										cSegment += 	'<FinalTime>' + AllTrim(oModelG40:GetValue('G40_HRFIM')) + '</FinalTime>'
										cSegment += 	'<CancellationDeadline>' + TxDtStamp(oModelG40:GetValue('G40_DTCANC')) + '</CancellationDeadline>'
										cSegment += 	'<Observation>' +_NoTags(AllTrim(oModelG40:GetValue('G40_OBS'))) + '</Observation>'
										cSegment += '</SegmentTour>'
									EndIf
								
									If lDelete .Or. oModelG40:IsDeleted()
										CFGA070MNT(Nil, 'G40', 'G40_ID', Nil, cSegID, .T.)
									EndIf
								Next nZ
							EndIf

							If !Empty(cSegment)
								cDocReserv += '<ListOfSegmentTour>' + cSegment + '</ListOfSegmentTour>'
							EndIf
						
							// Segmento SEGURO -----------------------------------------------------------------------------------------
							cSegment  := ""
							oModelG41 := oModel:GetModel('G41_ITENS')
							If !oModelG41:IsEmpty()
								For nZ := 1 to oModelG41:Length()
									oModelG41:GoLine(nZ)
									cSegID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG41:GetValue('G41_ID')), "G41")

									If (lDelete .Or. !oModelG41:IsDeleted()) .And. !Empty(oModelG41:GetValue('G41_DTINI'))
										cSegment += '<SegmentInsurance>'
										cSegment += 	'<SegmentCode>' + AllTrim(oModelG41:GetValue('G41_ID')) + '</SegmentCode>'
										cSegment += 	'<SegmentInternalId>' + cSegID + '</SegmentInternalId>'
										cSegment += 	'<IntegrationID>' + AllTrim(oModelG41:GetValue('G41_IDINTE')) + '</IntegrationID>'
										cSegment += 	'<PassengerCode>' + AllTrim(oModelG41:GetValue('G41_CODPAX')) + '</PassengerCode>'
										cSegment += 	'<PassengerInternalId>' + TurXMakeID(cIntItemID + "|" + AllTrim(oModelG41:GetValue('G41_CODPAX')), "G3S") + '</PassengerInternalId>'
										cSegment += 	'<InsurancePlanCode>' + AllTrim(oModelG41:GetValue('G41_PLSEGU')) + '</InsurancePlanCode>'
										cSegment += 	'<InsurancePlanInternalId>' + TurXMakeID(AllTrim(oModelG41:GetValue('G41_PLSEGU')), 'G4G') + '</InsurancePlanInternalId>'
										cSegment += 	'<BeneficiaryName>' + AllTrim(oModelG41:GetValue('G41_APOLIC')) + '</BeneficiaryName>'
										cSegment += 	'<BeneficiaryAddress>' + AllTrim(oModelG41:GetValue('G41_ENDBEN')) + '</BeneficiaryAddress>'
										cSegment += 	'<BeneficiaryPhone>' + AllTrim(oModelG41:GetValue('G41_TELBEN')) + '</BeneficiaryPhone>'
										cSegment += 	'<PolicyNumber>' + AllTrim(oModelG41:GetValue('G41_NUMAPO')) + '</PolicyNumber>'
										cSegment += 	'<InitialDate>' + TxDtStamp(oModelG41:GetValue('G41_DTINI')) + '</InitialDate>'
										cSegment += 	'<FinalDate>' + TxDtStamp(oModelG41:GetValue('G41_DTFIM')) + '</FinalDate>'
										cSegment += 	'<Observation>' + _NoTags(AllTrim(oModelG41:GetValue('G41_OBS'))) + '</Observation>'
										cSegment += '</SegmentInsurance>'
									EndIf
								
									If lDelete .Or. oModelG41:IsDeleted()
										CFGA070MNT(Nil, 'G41', 'G41_ID', Nil, cSegID, .T.)
									EndIf
								Next nZ
							EndIf

							If !Empty(cSegment)
								cDocReserv += '<ListOfSegmentInsurance>' + cSegment + '</ListOfSegmentInsurance>'
							EndIf

							// Segmento VISTO -----------------------------------------------------------------------------------------
							cSegment  := ""
							oModelG42 := oModel:GetModel('G42_ITENS')
							If !oModelG42:IsEmpty()
								For nZ := 1 to oModelG42:Length()
									oModelG42:GoLine(nZ)
									cSegID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG42:GetValue('G42_ID')), "G42")

									If (lDelete .Or. !oModelG42:IsDeleted()) .And. !Empty(oModelG42:GetValue('G42_PAIS'))
										cSegment += '<SegmentVisa>'
										cSegment += 	'<SegmentCode>' + AllTrim(oModelG41:GetValue('G41_ID')) + '</SegmentCode>'
										cSegment += 	'<SegmentInternalId>' + cSegID + '</SegmentInternalId>'
										cSegment += 	'<IntegrationID>' + AllTrim(oModelG42:GetValue('G42_IDINTE')) + '</IntegrationID>'
										cSegment += 	'<PassengerCode>' + AllTrim(oModelG42:GetValue('G42_CODPAX')) + '</PassengerCode>'
										cSegment += 	'<PassengerInternalId>' + TurXMakeID(cIntItemID + "|" + AllTrim(oModelG42:GetValue('G42_CODPAX')), "G3S") + '</PassengerInternalId>'
										cSegment += 	'<CountryCode>' + AllTrim(oModelG42:GetValue('G42_PAIS')) + '</CountryCode>'
										cSegment += 	'<VisaTypeCode>' + AllTrim(oModelG42:GetValue('G42_TPVIST')) + '</VisaTypeCode>'
										cSegment += 	'<VisaTypeInternalId>' + TurXMakeID(AllTrim(oModelG42:GetValue('G42_TPVIST')), 'G4F') + '</VisaTypeInternalId>'
										cSegment += 	'<Observation>' + _NoTags(AllTrim(oModelG42:GetValue('G42_OBS'))) + '</Observation>'
										cSegment += '</SegmentVisa>'
									EndIf
								
									If lDelete .Or. oModelG42:IsDeleted()
										CFGA070MNT(Nil, 'G42', 'G42_ID', Nil, cSegID, .T.)
									EndIf
								Next nZ
							EndIf

							If !Empty(cSegment)
								cDocReserv += '<ListOfSegmentVisa>' + cSegment + '</ListOfSegmentVisa>'
							EndIf

							// Segmento OUTROS-----------------------------------------------------------------------------------------
							cSegment  := ""
							oModelG43 := oModel:GetModel('G43_ITENS')
							If !oModelG43:IsEmpty()
								For nZ := 1 to oModelG43:Length()
									oModelG43:GoLine(nZ)
									cSegID := TurXMakeID(cIntItemID + "|" + AllTrim(oModelG43:GetValue('G43_ID')), "G43")

									If (lDelete .Or. !oModelG43:IsDeleted()) .And. !Empty(oModelG43:GetValue('G43_DTINI'))
										cSegment += '<OtherSegment>'
										cSegment += 	'<SegmentCode>' + AllTrim(oModelG43:GetValue('G43_ID')) + '</SegmentCode>'
										cSegment += 	'<SegmentInternalId>' + cSegID + '</SegmentInternalId>'
										cSegment += 	'<IntegrationID>' + AllTrim(oModelG43:GetValue('G43_IDINTE')) + '</IntegrationID>'
										cSegment += 	'<PassengerCode>' + AllTrim(oModelG43:GetValue('G43_CODPAX')) + '</PassengerCode>'
										cSegment += 	'<PassengerInternalId>' + TurXMakeID(cIntItemID + "|" + AllTrim(oModelG43:GetValue('G43_CODPAX')), "G3S") + '</PassengerInternalId>'
										cSegment += 	'<ServiceDescription>' + _NoTags(AllTrim(oModelG43:GetValue('G43_DSSERV'))) + '</ServiceDescription>'
										cSegment += 	'<DepartureCityCode>' + AllTrim(oModelG43:GetValue('G43_CIDEMB')) + '</DepartureCityCode>'
										cSegment += 	'<DepartureCityInternalId>' + TurXMakeID(AllTrim(oModelG43:GetValue('G43_CIDEMB')), 'G5S') + '</DepartureCityInternalId>'
										cSegment += 	'<ArrivalCityCode>' + AllTrim(oModelG43:GetValue('G43_CIDDES')) + '</ArrivalCityCode>'
										cSegment += 	'<ArrivalCityInternalId>' + TurXMakeID(AllTrim(oModelG43:GetValue('G43_CIDDES')), 'G5S') + '</ArrivalCityInternalId>'
										cSegment += 	'<InitialDate>' + TxDtStamp(oModelG43:GetValue('G43_DTINI')) + '</InitialDate>'
										cSegment += 	'<FinalDate>' + TxDtStamp(oModelG43:GetValue('G43_DTFIM')) + '</FinalDate>'
										cSegment += 	'<Observation>' + _NoTags(AllTrim(oModelG43:GetValue('G43_OBS'))) + '</Observation>'
										cSegment += '</OtherSegment>'
									EndIf
								
									If lDelete .Or. oModelG43:IsDeleted()
										CFGA070MNT(Nil, 'G43', 'G43_ID', Nil, cSegID, .T.)
									EndIf
								Next nZ
							EndIf

							If !Empty(cSegment)
								cDocReserv += '<ListOfOtherSegment>' + cSegment + '</ListOfOtherSegment>'
							EndIf 
							cDocReserv += '</BookingDocument>'
						EndIf
					Next nI
					
					If !Empty(cDocReserv)
						cXmlSale += cDocReserv
					EndIf
				EndIf

				If !Empty(cXmlSale)
					cXmlLSale += '<SaleItem>' + cXmlSale + '</SaleItem>'
				EndIf
			EndIf
		Next nX
	EndIf

	If !Empty(cXmlLSale)
		cXMLBus += '<ListOfSaleItem>' + cXmlLSale + '</ListOfSaleItem>'
	EndIf

	If !Empty(cXMLBus)
		cXMLRet += '<BusinessContent>' + cXMLBus + '</BusinessContent>'
	EndIf

	//Exclui o De/Para 
	If lDelete
		CFGA070MNT(Nil, "G3P", "G3P_NUMID", Nil, cIntID, lDelete)
	EndIf

ElseIf nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
	If (cTypeMessage == EAI_MESSAGE_WHOIS )//whois
		cXmlRet := '1.000'

	ElseIf (cTypeMessage == EAI_MESSAGE_RESPONSE) //resposta da mensagem Única TOTVS
		If Empty(oXml:Error())
			aMsgUnic := {}
			Ti34aMsgUn(aMsgUnic)
			cMarca := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
			For nX := 1 to oXml:xPathChildCount("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId")
				cName  := Upper(oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[" + cValToChar(nX) + "]/Name"))
				cIntID := oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[" + cValToChar(nX) + "]/Origin")
				cExtID := oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[" + cValToChar(nX) + "]/Destination")
				If !Empty(cIntID) .And. !Empty(cExtID)
					If (nPos := aScan(aMsgUnic, {|x| Upper(AllTrim(x[1])) == AllTrim(cName)})) > 0
						CFGA070MNT(cMarca, aMsgUnic[nPos][2], aMsgUnic[nPos][3], cExtID, cIntID)
					EndIf
				EndIf
			Next nX
			TxDestroy(aMsgUnic)
		EndIf
		oXml := Nil

	ElseIf (cTypeMessage == EAI_MESSAGE_BUSINESS)//chegada de mensagem de negócios
		aIntID    := {}
		aDetalhe  := {}
		cEvent    := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
		cMarca    := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
		cExtID    := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
		cSegNeg   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TradingProcess'))
		cCustomer := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CustomerInternalId'))
		cAgente   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TravelAgentInternalId'))
		cNumID    := PadR(AllTrim(TURXRetId(cMarca, "G3P", "G3P_NUMID", cExtID, @cIntID, 3)), TamSx3("G3P_NUMID")[1])
		cTimeMid  := Time()

		If Upper(cEvent) == 'UPSERT'
			If !Empty(cIntID)
				G3P->(DbSetOrder(1)) 	// G3P_FILIAL+G3P_NUMID+G3P_SEGNEG
				IF G3P->(DbSeek(xFilial("G3P") + cNumID))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lRet     := .F.
					cMsgErro := STR0001		// "Registro não encontrado no Protheus."
				EndIf
			Else
				nOpc   := MODEL_OPERATION_INSERT
				Inclui := .T.
			EndIf

		ElseIf Upper(cEvent) == 'DELETE'
			G3P->(DbSetOrder(1)) 	// G3P_FILIAL+G3P_NUMID+G3P_SEGNEG
			If !Empty(cIntID) .And. G3P->(DbSeek(xFilial("G3P") + cNumID))
				nOpc := MODEL_OPERATION_DELETE
			Else
				lRet     := .F.
				cMsgErro := STR0001		// "Registro não encontrado no Protheus."
			EndIf
		EndIf
		
		If lRet .And. oXml:XPathHasNode(cBusiCont + '/CustomerInternalId')
			If (aClient := IntCliInt(cCustomer,cMarca))[1]
				cCliente := PadR(aClient[2][3],TamSx3("G3P_CLIENT")[1])
				cLoja	 := PadR(aClient[2][4],TamSx3("G3P_LOJA")[1])
			Else
				lRet     := .F.
				cMsgErro := aClient[2]
			EndIf
			TxDestroy(aClient)
		EndIf

		If lRet
			If oXml:XPathHasNode(cBusiCont + '/TravelAgentInternalId')
				cAgente	:= PadR(AllTrim(TURXRetId(cMarca, "G3H", "G3H_CODAGE", cAgente, Nil, 3, @cMsgErro)), TamSx3("G3P_AGENT")[1])
				If !Empty(cMsgErro)
					lRet := .F.
				Else
					If Empty(cAgente)
						lRet     := .F.
						cMsgErro := STR0013 	//"Agente de Viagem não informado"
					Else
						G3H->(DbSetOrder(1))	// G3H_FILIAL+G3H_CODAGE+G3H_CODVEN
						If !G3H->(DbSeek(xFilial("G3H") + cAgente))
							lRet     := .F.
							cMsgErro := STR0014		//"Agente não encontrado ou registro bloqueado"
						ElseIf Empty(cCodVend := G3H->G3H_CODVEN) .Or. Empty(__cUserId := Posicione("SA3", 1, xFilial("SA3") + cCodVend, "A3_CODUSR"))
							lRet     := .F.
							cMsgErro := STR0015 	//"Agente não vinculado a nenhum usuário do protheus"
						EndIf
					EndIf
				EndIf
			EndIf

			If lRet
				If Empty(cSegNeg) .And. nOpc == MODEL_OPERATION_UPDATE
					cSegNeg := Posicione('G3P', 1, xFilial('G3P') + cNumID, 'G3P_SEGNEG')
				EndIf
	
				T034SetStc({{"lHierarquia", .F.}, {"nSegmento", Val(cSegNeg)}})
				oModel := FwLoadModel("TURA034")
				oModel:SetOperation(nOpc)
				lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
	
				If oModel:Activate()
					oModelCab := oModel:GetModel('G3P_FIELDS')
					oModelG3Q := oModel:GetModel('G3Q_ITENS')
					oModelG3R := oModel:GetModel('G3R_ITENS')
					oModelG3S := oModel:GetModel('G3S_ITENS')
					oModelG3T := oModel:GetModel('G3T_ITENS')
					oModelG3U := oModel:GetModel('G3U_ITENS')
					oModelG3V := oModel:GetModel('G3V_ITENS')
					oModelG3W := oModel:GetModel('G3W_ITENS')
					oModelG3X := oModel:GetModel('G3X_ITENS')
					oModelG3Y := oModel:GetModel('G3Y_ITENS')
					oModelG3Z := oModel:GetModel('G3Z_ITENS')
					oModelG40 := oModel:GetModel('G40_ITENS')
					oModelG41 := oModel:GetModel('G41_ITENS')
					oModelG42 := oModel:GetModel('G42_ITENS')
					oModelG43 := oModel:GetModel('G43_ITENS')
					oModelG44 := oModel:GetModel('G44_ITENS')
					oModelG45 := oModel:GetModel('G45_ITENS')
					oModelG46 := oModel:GetModel('G46_ITENS')
					oModelG47 := oModel:GetModel('G47_ITENS')
					oModelG49 := oModel:GetModel('G49_ITENS')
					oModelG4A := oModel:GetModel('G4A_ITENS')
					oModelG4B := oModel:GetModel('G4B_ITENS')
					oModelG4D := oModel:GetModel('G4D_ITENS')
					oModelG4E := oModel:GetModel('G4E_ITENS')
				
					cFilRV := oModelCab:GetValue("G3P_FILIAL")
					cNumID := oModelCab:GetValue("G3P_NUMID")
					cIntID := TurXMakeID(cNumID, 'G3P')
					If !lDelete
						If nOpc == MODEL_OPERATION_INSERT
							SA1->(DbSetOrder(1))	// A1_FILIAL+A1_COD+A1_LOJA
							SA1->(DbSeek(xFilial('SA1') + cCliente + cLoja))
							oModelCab:SetValue("G3P_CLIENT", cCliente)
							oModelCab:SetValue("G3P_LOJA"  , cLoja)
						EndIf
						
						TxGetNdXml(oXml, cBusiCont + '/IssueDate'			   , oModelCab, "G3P_EMISS")
						TxGetNdXml(oXml, cBusiCont + '/Destination'			   , oModelCab, "G3P_DESTIN")
						TxGetNdXml(oXml, cBusiCont + '/Observation'			   , oModelCab, "G3P_OBS")
						TxGetNdXml(oXml, cBusiCont + '/InitialDate'			   , oModelCab, "G3P_DTINI")
						TxGetNdXml(oXml, cBusiCont + '/FinalDate'			   , oModelCab, "G3P_DTFIM")
						TxGetNdXml(oXml, cBusiCont + '/Description'			   , oModelCab, "G3P_DESCRI")
						TxGetNdXml(oXml, cBusiCont + '/ExternalSalesRegistryId', oModelCab, "G3P_CODEX")
					EndIf
	
					If ExistBlock("TURI034EXT")
						cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G3P'})
					EndIf
					
					aAdd(aIntID, {"SaleRegistry", cExtID, cIntID, "G3P", "G3P_NUMID"})
						
					// Itens de Venda ----------------------------------------------------------------------------------------------------------------------
					If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfSaleItem')) > 0
						For nX := 1 To nCont
							lAddG3S    := .F.
							lAddG3T    := .F.
							lAddG3U    := .F.
							lAddG3V    := .F.
							lAddG3W    := .F.
							lAddG3X    := .F.
							lAddG3Y    := .F.
							lAddG3Z    := .F.
							lAddG40    := .F.
							lAddG41    := .F.
							lAddG42    := .F.
							lAddG43    := .F.
							lAddG45    := .F.
							lAddG46    := .F.
							lAddG47    := .F.
							lAddG49    := .F.
							lAddG4D    := .F.
							aDados     := {}
							cListItens := cBusiCont + "/ListOfSaleItem/SaleItem[" + cValToChar(nX) + "]"
							cExtID	   := AllTrim(oXml:XPathGetNodeValue(cListItens + "/SaleItemInternalId"))
							cTpEmiss   := AllTrim(oXml:XPathGetNodeValue(cListItens + "/BroadcastTypeInternalId"))
							cExtCli    := AllTrim(oXml:XPathGetNodeValue(cListItens + "/CustomerInternalId"))
							cProd	   := AllTrim(oXml:XPathGetNodeValue(cListItens + "/ItemInternalId"))
							cExtFop    := AllTrim(oXml:XPathGetNodeValue(cListItens + "/PaymentFormInternalId"))
							cMoedaCli  := AllTrim(oXml:XPathGetNodeValue(cListItens + "/TravelCurrencyInternalId"))
							cSolicit   := AllTrim(oXml:XPathGetNodeValue(cListItens + "/RequestInternalId"))
							cDoc	   := Upper(AllTrim(oXml:XPathGetNodeValue(cListItens + "/ProcessNumber")))
							
							// validação de duplicidade chave externa - Item de Venda
							If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G3Q'), 'G3Q', cExtID))[1]
								lRet     := .F.
								cMsgErro := I18N(STR0016, {'G3Q', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
								oModel:SetErrorMessage("G3Q_ITENS", "G3Q_IDITEM", "G3Q_ITENS", "G3Q_IDITEM", "TI034ChvDpl", cMsgErro , STR0017, cExtID)	// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
								Exit		// Saindo do laço G3Q
							EndIf							
							
							cIntID  := ""
							cIdItem	:= PadR(AllTrim(TURXRetId(cMarca, "G3Q", "G3Q_IDITEM", cExtID, @cIntID, 4)), TamSx3("G3Q_IDITEM")[1])
							cNumSeq	:= PadR(AllTrim(TURXRetId(cMarca, "G3Q", "G3Q_IDITEM", cExtID, Nil	  , 5)), TamSx3("G3Q_NUMSEQ")[1])

							If (aClient	:= IntCliInt(cExtCli, cMarca))[1]
								cCliente := PadR(aClient[2][3], TamSx3("G3Q_CLIENT")[1])
								cLoja    := PadR(aClient[2][4], TamSx3("G3Q_LOJA")[1])
							Else
								lRet     := .F.
								cMsgErro := aClient[2]
								TxDestroy(aClient)
								Exit		// Saindo do laço G3Q
							EndIf
							TxDestroy(aClient)
							
							If (aProd := IntProInt(cProd, cMarca))[1]
								cProd := PadR(AllTrim(TURXRetId(cMarca, "SB1", "B1_COD", cProd, Nil, 3)), TamSx3("G3Q_PROD")[1])
							Else
								lRet     := .F.
								cMsgErro := aProd[2]
								TxDestroy(aProd)
								Exit		// Saindo do laço G3Q
							EndIf
							TxDestroy(aProd)

							If nOpc == MODEL_OPERATION_UPDATE .And. !T34VldAlt(cFilRV, cNumID, cIdItem, cNumSeq)
								lRet     := .F.
								cMsgErro := "Não é possível realizar alterações no Item de Venda que esteja em conciliação ou que tenha algum Item Financeiro faturado."
								Exit		// Saindo do laço G3Q
							EndIf
							
							cTpEmiss  := PadR(AllTrim(TURXRetId(cMarca, "G5O", "G5O_CODIGO", cTpEmiss , Nil, 3)), TamSx3("G3Q_TPEMIS")[1])
							cFormaPgt := PadR(AllTrim(TURXRetId(cMarca, "G3N", "G3N_CODIGO", cExtFop  , Nil, 3  , @cMsgErro)), TamSx3("G3Q_FORMPG")[1])
							cMoedaCli := PadR(AllTrim(TURXRetId(cMarca, "G5T", "G5T_CODIGO", cMoedaCli, Nil, 3)), TamSx3("G3Q_MOEDCL")[1])
							cSolicit  := PadR(AllTrim(TURXRetId(cMarca, "SU5", "U5_CODCONT", cSolicit , Nil, 3)), TamSx3("G3Q_SOLIC")[1])

							If oXml:XPathHasNode(cListItens + "/PaymentFormInternalId")	.And. !Empty(cExtFop) .And. !Empty(cMsgErro)
								lRet := .F.
								Exit		// Saindo do laço G3Q
							EndIf

							If Empty(cIntID)
								cIdItem	:= IIF(oModelG3Q:Length() == 1 .And. !lAddG3Q .And. oModelG3Q:IsEmpty(), StrZero(1, TamSx3("G3Q_IDITEM")[1]), StrZero(Val(oModelG3Q:GetValue("G3Q_IDITEM", oModelG3Q:Length())) + 1, TamSx3("G3Q_IDITEM")[1]))
								cNumSeq := "01"
							EndIf
							
							If !lDelete .And. !oModelG3Q:SeekLine({{"G3Q_IDITEM", cIdItem}, {"G3Q_NUMSEQ", cNumSeq}})
								If !Empty(oModelG3Q:GetValue('G3Q_IDITEM'))
									nLine := oModelG3Q:AddLine()
									oModelG3Q:GoLine(nLine)
								EndIf
								cNumSeq	:= oModelG3Q:GetValue("G3Q_NUMSEQ")
							EndIf
							cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq), "G3Q")

							If !lDelete
								aAdd(aDados, {"G3Q_IDITEM", cIdItem	 , cListItens + "/SaleItemInternalId"})
								aAdd(aDados, {"G3Q_OPERAC",          , cListItens + "/OperationType"})
								aAdd(aDados, {"G3Q_TPDOC" ,          , cListItens + "/DocumentType"})
								aAdd(aDados, {"G3Q_DOCORI",          , cListItens + "/OriginProcessNumber"})
								aAdd(aDados, {"G3Q_DOC"   , cDoc     , cListItens + "/ProcessNumber"})
								aAdd(aDados, {"G3Q_CONJUG",          , cListItens + "/ConjugateAmount"})
								aAdd(aDados, {"G3Q_EMISS" ,          , cListItens + "/IssueDate"})
								aAdd(aDados, {"G3Q_TPEMIS", cTpEmiss , cListItens + "/BroadcastTypeInternalId"})
								aAdd(aDados, {"G3Q_CLIENT", cCliente , cListItens + "/CustomerInternalId"})
								aAdd(aDados, {"G3Q_LOJA"  , cLoja    , cListItens + "/CustomerInternalId"})
								aAdd(aDados, {"G3Q_PROD"  , cProd    , cListItens + "/ItemInternalId"})
								aAdd(aDados, {"G3Q_DESTIN",          , cListItens + "/Destination"})
								aAdd(aDados, {"G3Q_FORMPG", cFormaPgt, cListItens + "/PaymentFormInternalId"})
								aAdd(aDados, {"G3Q_MOEDCL", cMoedaCli, cListItens + "/TravelCurrencyInternalId"})
								aAdd(aDados, {"G3Q_TXCAMB",          , cListItens + "/Exchange"})
								aAdd(aDados, {"G3Q_SOLIC" , cSolicit , cListItens + "/RequestInternalId"})
								aAdd(aDados, {"G3Q_DTSOLI",          , cListItens + "/RequestDate"})
								aAdd(aDados, {"G3Q_ORDER" ,          , cListItens + "/ServiceOrder"})
								aAdd(aDados, {"G3Q_ITOS"  ,          , cListItens + "/ServiceOrderItem"})
							EndIf

							If ExistBlock("TURI034EXT")
								cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G3Q'})
							EndIf

							For n1 := 1 to Len(aDados)
								If !TxGetNdXml(oXml, aDados[n1][3], oModelG3Q, aDados[n1][1], aDados[n1][2])
									lRet := .F.
									Exit
								EndIf
							Next n1
							TxDestroy(aDados)

							If lRet
								aAdd(aIntID, {'SaleItem', cExtID, cIntID, 'G3Q', 'G3Q_IDITEM'})
								aAdd(aDetalhe, {'G3Q', cIdItem + cNumSeq})
	
								// Dados do cartão ----------------------------------------------------------------------------------------------------------------------
								If (nCont1 := oXml:xPathChildCount(cListItens + '/ListOfPaymentCreditCard')) > 0
									For nT := 1 To nCont1
										aDados      := {}
										cListOfCard := cListItens + '/ListOfPaymentCreditCard/PaymentCreditCard[' + cValToChar(nT) + "]"
										cExtID      := AllTrim(oXml:XPathGetNodeValue(cListOfCard + '/SequenceInternalId'))
										cOwner      := AllTrim(oXml:XPathGetNodeValue(cListOfCard + '/Owner'))
										cCardExt    := AllTrim(oXml:XPathGetNodeValue(cListOfCard + '/CardInternalId'))
										cCodBan     := AllTrim(oXml:XPathGetNodeValue(cListOfCard + '/CardCompany'))
									
										// validação de duplicidade chave externa - Dados do Cartão
										If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G4D'), 'G4D', cExtID))[1]
											lRet     := .F.
											cMsgErro := I18N(STR0016, {'G4D', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
											oModel:SetErrorMessage("G4D_ITENS", "G4D_SEQ", "G4D_ITENS", "G4D_SEQ", "TI034ChvDpl", cMsgErro, STR0017, cExtID)	// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
											Exit		// Saindo do laço G4D
										Else
											cIntID  := ""
											cSeqID  := PadR(AllTrim(TURXRetId(cMarca, "G4D", "G4D_SEQ", cExtID, @cIntID, 6)), TamSx3("G4D_SEQ")[1])
											cCodBan := IIF(!Empty(cCodBan), StrZero(Val(cCodBan), TamSx3("G4D_CODBAN")[1]), "")
	
											If cOwner == '1'
												G3J->(DbSetOrder(1))	// G3J_FILIAL+G3J_CODIGO
												cCodCard := PadR(AllTrim(TURXRetId(cMarca, "G3J", "G3J_CODIGO", cCardExt, Nil, 3, @cMsgErro)), TamSx3("G4D_CODCAR")[1])
											Else
												G3D->(DbSetOrder(1))	// G3D_FILIAL+G3D_CODIGO
												cCodCard := PadR(AllTrim(TURXRetId(cMarca, "G3D", "G3D_CODIGO", cCardExt, Nil, 3, @cMsgErro)), TamSx3("G4D_CODCAR")[1])
											EndIf
	
											If !Empty(cCardExt) .And. !Empty(cMsgErro)
												lRet := .F.
												Exit		// Saindo do laço G4D
											EndIf
			
											If Empty(cIntID)
												cSeqID := IIF(oModelG4D:Length() == 1 .And. !lAddG4D, StrZero(1, TamSx3("G4D_SEQ")[1]), StrZero(Val(oModelG4D:GetValue("G4D_SEQ", oModelG4D:Length())) + 1, TamSx3("G4D_SEQ")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSeqID), "G4D")
											EndIf
											
											If !lDelete .And. !oModelG4D:SeekLine({{"G4D_SEQ", cSeqID}})
												If !Empty(oModelG4D:GetValue('G4D_PROPRI'))
													nLine := oModelG4D:AddLine()
													oModelG4D:GoLine(nLine)
												EndIf
											EndIf
											
											If !lDelete
												aAdd(aDados, {"G4D_SEQ"	  , cSeqID	, cListOfCard + '/SequenceInternalId'})
												aAdd(aDados, {"G4D_PROPRI",			, cListOfCard + '/Owner'})
												aAdd(aDados, {"G4D_CODCAR", cCodCard, cListOfCard + '/CardInternalId'})
												aAdd(aDados, {"G4D_NUMCAR",			, cListOfCard + '/CardNumber'})
												aAdd(aDados, {"G4D_CODBAN", cCodBan	, cListOfCard + '/CardCompany'})
												aAdd(aDados, {"G4D_TITULA",			, cListOfCard + '/CardOwnerName'})
												aAdd(aDados, {"G4D_MESVAL",			, cListOfCard + '/CardExpiringMonth'})
												aAdd(aDados, {"G4D_ANOVAL",			, cListOfCard + '/CardExpiringYear'})
												aAdd(aDados, {"G4D_QTDPAR",			, cListOfCard + '/InstallmentsAmount'})
												aAdd(aDados, {"G4D_NSU"	  ,			, cListOfCard + '/ApprovalCode'})
												aAdd(aDados, {"G4D_DTOPER",			, cListOfCard + '/TransactionDate'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G4D'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG4D, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
	
											If lRet
												If !oModelG4D:VldLineData() 
													lRet := .F.
													Exit		// Saindo do laço G4D
												EndIf
												lAddG4D := .T.
												aAdd(aIntID, {'PaymentCreditCard', cExtID, cIntID, 'G4D', 'G4D_SEQ'})
												aAdd(aDetalhe, {'G4D', cIdItem + cNumSeq + cSeqID})
											Else
												Exit		// Saindo do laço G4D	
											EndIf
										EndIf
									Next nT
									
									If !lRet
										Exit	// Saindo do laço G3Q
									EndIf
								EndIf
								
								// Rateio ----------------------------------------------------------------------------------------------------------------------
								If (nCont1 := oXml:xPathChildCount(cListItens + '/ListOfApportionment')) > 0
									For nT := 1 To nCont1
										aDados	   := {}
										cListOfApp := cListItens + '/ListOfApportionment/Apportionment[' + cValToChar(nT) + "]"
										cLjEntit   := AllTrim(oXml:XPathGetNodeValue(cListOfApp + '/ReferenceStoreInternalId'))
										cExtID	   := AllTrim(oXml:XPathGetNodeValue(cListOfApp + '/AdditionalEntityTypeInternalId'))
										cAddExtID  := AllTrim(oXml:XPathGetNodeValue(cListOfApp + '/AdditionalEntityItemInternalId'))
										cPercetn   := AllTrim(oXml:XPathGetNodeValue(cListOfApp + '/Percentage'))
										
										cIntID	   := ""
										cTpEnt	   := PadR(AllTrim(TURXRetId(cMarca, "G3E", "G3E_CODIGO", cExtID, @cIntID, 3)), TamSx3("G4A_TPENT")[1])

										If !Empty(cAddExtID)
											cItemEnt := PadR(AllTrim(TURXRetId(cMarca, "G3G", "G3G_ITEM", cAddExtID, Nil, 6)), TamSx3("G4A_ITEM")[1])
										Else
											cItemEnt := AllTrim(oXml:XPathGetNodeValue(cListOfApp + '/AdditionalEntityItemCode'))
										EndIf
										
										If (aClient := IntCliInt(cLjEntit,cMarca))[1]
											cLjEntit := PadR(aClient[2][4], TamSx3("G4A_LOJA")[1])
										Else
											lRet     := .F.
											cMsgErro := aClient[2]
											TxDestroy(aClient)
											Exit		// Saindo do laço G4A 
										EndIf
										TxDestroy(aClient)
										
										If !lDelete .And. !oModelG4A:SeekLine({{"G4A_TPENT", cTpEnt}, {'G4A_LOJA', cLjEntit}, {'G4A_ITEM', cItemEnt}})
											If !Empty(oModelG4A:GetValue('G4A_TPENT'))
												nLine := oModelG4A:AddLine()
												oModelG4A:GoLine(nLine)
											EndIf
										EndIf
	
										If !lDelete
											aAdd(aDados, {"G4A_TPENT" , cTpEnt})
											aAdd(aDados, {"G4A_LOJA"  , cLjEntit})
											aAdd(aDados, {"G4A_ITEM"  , cItemEnt})
											aAdd(aDados, {"G4A_PERRAT", Val(cPercetn)})
										EndIf
	
										For n1 := 1 to Len(aDados)
											If !TxSetVal(oModelG4A, aDados[n1][1], aDados[n1][2])
												lRet := .F.
												Exit
											EndIf
										Next n1
										TxDestroy(aDados)
	
										If lRet
											If !oModelG4A:VldLineData() 
												lRet := .F.
												Exit		// Saindo do laço G4A
											EndIf
											aAdd(aDetalhe, {'G4A', cIdItem + cNumSeq + cLjEntit + cTpEnt + cItemEnt})
										Else
											Exit		// Saindo do laço G4A	
										EndIf
									Next nT
	
									If !lRet
										Exit		// Saindo do laço G3Q
									EndIf
								EndIf
							
								// Documento de Reserva ----------------------------------------------------------------------------------------------------------------------
								cListReserv := cListItens + '/BookingDocument'
								If oXml:XPathHasNode(cListReserv)
									aDados	   := {}
									cVendor	   := AllTrim(oXml:XPathGetNodeValue(cListReserv + "/ProductVendorInternalId"))
									cPosto	   := AllTrim(oXml:XPathGetNodeValue(cListReserv + "/ServiceStationInternalId"))
									cRepVendor := AllTrim(oXml:XPathGetNodeValue(cListReserv + "/ReportVendorInternalId"))
									cMoeda	   := AllTrim(oXml:XPathGetNodeValue(cListReserv + "/TravelCurrencyInternalId"))
									cEmission  := AllTrim(oXml:XPathGetNodeValue(cListReserv + "/EmissionAgentInternalId"))
									cBookAgt   := AllTrim(oXml:XPathGetNodeValue(cListReserv + "/BookingAgentInternalId"))
									cFrontSys  := AllTrim(oXml:XPathGetNodeValue(cListReserv + "/FrontSystemInternalId"))
									
									If (aForn := IntForInt(cVendor, cMarca))[1]
										cForn  := PadR(aForn[2][3], TamSx3("G3R_FORNEC")[1])
										cForLj := PadR(aForn[2][4], TamSx3("G3R_LOJA")[1])
									Else
										lRet     := .F. 
										cMsgErro := aForn[2]
										TxDestroy(aForn)
										Exit		// Saindo do laço G3Q
									EndIf
									TxDestroy(aForn)
	
									cPosto := PadR(AllTrim(TURXRetId(cMarca, "G3M", "G3M_CODIGO", cPosto, Nil, 3, @cMsgErro)), TamSx3("G3R_POSTOR")[1])
									If !Empty(cMsgErro)
										lRet := .F.
										Exit		// Saindo do laço G3Q
									EndIf
	
									If !Empty(cRepVendor)
										If (aForn := IntForInt(cRepVendor,cMarca))[1]
											cRForn  := PadR(aForn[2][3], TamSx3("G3R_FORREP")[1])
											cRForLj	:= PadR(aForn[2][4], TamSx3("G3R_LOJREP")[1])
										Else
											lRet     := .F. 
											cMsgErro := aForn[2]
											TxDestroy(aForn)
											Exit		// Saindo do laço G3Q
										EndIf
										TxDestroy(aForn)
									EndIf
	
									cMoeda	  := PadR(AllTrim(TURXRetId(cMarca, "G5T", "G5T_CODIGO", cMoeda	  , Nil, 3)), TamSx3("G3R_MOEDA")[1])
									cEmission := PadR(AllTrim(TURXRetId(cMarca, "G3H", "G3H_CODAGE", cEmission, Nil, 3)), TamSx3("G3R_AGEMIS")[1])
									cBookAgt  := PadR(AllTrim(TURXRetId(cMarca, "G3H", "G3H_CODAGE", cBookAgt , Nil, 3)), TamSx3("G3R_AGRESE")[1])
									cFrontSys := PadR(AllTrim(TURXRetId(cMarca, "G4K", "G4K_CODIGO", cFrontSys, Nil, 3)), TamSx3("G3R_SISORI")[1])
									
									If !lDelete
										aAdd(aDados, {'G3R_FORNEC', cForn	 , cListReserv + "/ProductVendorInternalId"})
										aAdd(aDados, {'G3R_LOJA'  , cForLj	 , cListReserv + "/ProductVendorInternalId"})
										aAdd(aDados, {'G3R_DESTIN',			 , cListReserv + "/Destination"})
										aAdd(aDados, {'G3R_POSTOR', cPosto	 , cListReserv + "/ServiceStationInternalId"})
										aAdd(aDados, {'G3R_FORREP', cRForn	 , cListReserv + "/ReportVendorInternalId"})
										aAdd(aDados, {'G3R_LOJREP', cRForLj	 , cListReserv + "/ReportVendorInternalId"})
										aAdd(aDados, {'G3R_MOEDA' , cMoeda	 , cListReserv + "/TravelCurrencyInternalId"})
										aAdd(aDados, {'G3R_AGEMIS', cEmission, cListReserv + "/EmissionAgentInternalId"})
										aAdd(aDados, {'G3R_AGRESE', cBookAgt , cListReserv + "/BookingAgentInternalId"})
										aAdd(aDados, {'G3R_TOURCD', 		 , cListReserv + "/TourCode"})
										aAdd(aDados, {'G3R_OBS'   ,			 , cListReserv + "/BookingObservations"})
										aAdd(aDados, {'G3R_SISORI', cFrontSys, cListReserv + "/FrontSystemInternalId"})
										aAdd(aDados, {'G3R_LOCGDS',			 , cListReserv + "/GDSLocator"})
										aAdd(aDados, {'G3R_DTCONF',			 , cListReserv + "/BookingConfirmationDate"})
										aAdd(aDados, {'G3R_FORMCF',			 , cListReserv + "/BookingConfirmationType"})
										aAdd(aDados, {'G3R_IDCONF',			 , cListReserv + "/BookingConfirmationCode"})
									EndIf
	
									For n1 := 1 to Len(aDados)
										If !TxGetNdXml(oXml, aDados[n1][3], oModelG3R, aDados[n1][1], aDados[n1][2])
											lRet := .F.
											Exit
										EndIf
									Next n1
									TxDestroy(aDados)
	
									If !lRet
										Exit		// Saindo do laço G3Q
									EndIf
	
									// Tarifas Cotadas ----------------------------------------------------------------------------------------------------------------------
									If (nCont1 := oXml:xPathChildCount(cListReserv + '/ListOfQuotedFares')) > 0
										For nT := 1 To nCont1
											aDados	   := {}
											cListOfQuo := cListReserv + '/ListOfQuotedFares/QuotedFares[' + cValToChar(nT) + "]"
											cExtID	   := AllTrim(oXml:XPathGetNodeValue(cListOfQuo + '/QuotedFareInternalId'))
											cAeroOri   := AllTrim(oXml:XPathGetNodeValue(cListOfQuo + '/AirportOriginInternalId'))
											cAeroDes   := AllTrim(oXml:XPathGetNodeValue(cListOfQuo + '/AirportDestinyInternalId'))
											cMoeda	   := AllTrim(oXml:XPathGetNodeValue(cListOfQuo + '/TravelCurrencyInternalId'))
	
											// validação de duplicidade chave externa - Tarifas cotadas
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G45'), 'G45', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G45', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G45_ITENS", "G45_SEQ", "G45_ITENS", "G45_SEQ", "TI034ChvDpl", cMsgErro, STR0017, cExtID)	// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G45
											EndIf 
	
											cIntID   := ""
											cSeqID	 := PadR(AllTrim(TURXRetId(cMarca, "G45", "G45_SEQ"	  , cExtID	, @cIntID, 6)), TamSx3("G45_SEQ")[1])
											cMoeda   := PadR(AllTrim(TURXRetId(cMarca, "G5T", "G5T_CODIGO", cMoeda	, Nil	 , 3)), TamSx3("G45_MOEDTC")[1])
											cAeroOri := PadR(AllTrim(TURXRetId(cMarca, "G3B", "G3B_CODIGO", cAeroOri, Nil	 , 3)), TamSx3("G45_AERORI")[1])
											cAeroDes := PadR(AllTrim(TURXRetId(cMarca, "G3B", "G3B_CODIGO", cAeroDes, Nil	 , 3)), TamSx3("G45_AERDES")[1])
											
											If Empty(cIntID)
												cSeqID := IIF(oModelG45:Length() == 1 .And. !lAddG45, StrZero(1, TamSx3("G45_SEQ")[1]), StrZero(Val(oModelG45:GetValue("G45_SEQ", oModelG45:Length())) + 1, TamSx3("G45_SEQ")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSeqID), "G45")
											EndIf
											
											If !lDelete .And. !oModelG45:SeekLine({{"G45_SEQ", cSeqID}})
												If !Empty(oModelG45:GetValue('G45_CODCIA'))
													nLine := oModelG45:AddLine()
													oModelG45:GoLine(nLine)
												EndIf
											EndIf
											
											If !lDelete
												aAdd(aDados, {'G45_SEQ'   , cSeqID  , cListOfQuo + '/QuotedFareInternalId'})
												aAdd(aDados, {'G45_CODCIA',		    , cListOfQuo + '/AirlineShortName'})
												aAdd(aDados, {'G45_AERORI', cAeroOri, cListOfQuo + '/AirportOriginInternalId'})
												aAdd(aDados, {'G45_AERDES', cAeroDes, cListOfQuo + '/AirportDestinyInternalId'})
												aAdd(aDados, {'G45_HRFIM' ,			, cListOfQuo + '/DepartureTime'})
												aAdd(aDados, {'G45_QTDCON',			, cListOfQuo + '/ConnectionsAmount'})
												aAdd(aDados, {'G45_QTDESC',			, cListOfQuo + '/ScalesAmount'})
												aAdd(aDados, {'G45_MOEDTC', cMoeda 	, cListOfQuo + '/TravelCurrencyInternalId'})
												aAdd(aDados, {'G45_TARIFA',			, cListOfQuo + '/FareValue'})
												aAdd(aDados, {'G45_TAXA'  ,			, cListOfQuo + '/TaxValue'})
											EndIf
											
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G45'})
											EndIf
											
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG45, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
											
											If lRet
												If !oModelG45:VldLineData() 
													lRet := .F.
													Exit		// Saindo do laço G45
												EndIf
												lAddG45 := .T.
												aAdd(aIntID  , {'QuotedFares', cExtID, cIntID, 'G45', 'G45_SEQ'})
												aAdd(aDetalhe, {'G45', cIdItem + cNumSeq + cSeqID})
											Else
												Exit		// Saindo do laço G45	
											EndIf
										Next nT
	
										If !lRet 
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
	
									// Taxas ----------------------------------------------------------------------------------------------------------------------
									If (nCont1 := oXml:xPathChildCount(cListReserv  + '/ListOfRates')) > 0
										For nT := 1 To nCont1
											aDados     := {}
											cListOfRat := cListReserv + '/ListOfRates/Rates[' + cValToChar(nT) + "]"
											cExtID	   := AllTrim(oXml:XPathGetNodeValue(cListOfRat + '/RatesInternalId'))
											cCodTx	   := AllTrim(oXml:XPathGetNodeValue(cListOfRat + '/TravelRatesInternalId'))
											cMoeda	   := AllTrim(oXml:XPathGetNodeValue(cListOfRat + '/TravelCurrencyInternalId'))
	
											// validação de duplicidade chave externa - Taxas
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G46'), 'G46', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G46', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G46_ITENS", "G46_SEQTAX", "G46_ITENS", "G46_SEQTAX", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G46
											EndIf 
	
											cIntID := ''
											cSeqID := PadR(AllTrim(TURXRetId(cMarca, "G46", "G46_SEQTAX", cExtID, @cIntID, 6)), TamSx3("G46_SEQTAX")[1])
											cMoeda := PadR(AllTrim(TURXRetId(cMarca, "G5T", "G5T_CODIGO", cMoeda, Nil    , 3)), TamSx3("G46_MOEDFO")[1])
											cCodTx := PadR(AllTrim(TURXRetId(cMarca, "G3A", "G3A_CODIGO", cCodTx, Nil    , 3)), TamSx3("G46_CODTX" )[1])
											
											If Empty(cIntID)
												cSeqID := IIF(oModelG46:Length() == 1 .And. !lAddG46, StrZero(1, TamSx3("G46_SEQTAX")[1]), StrZero(Val(oModelG46:GetValue("G46_SEQTAX", oModelG46:Length())) + 1, TamSx3("G46_SEQTAX")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSeqID), "G46")
											EndIf
											
											If !lDelete .And. !oModelG46:SeekLine({{"G46_SEQTAX", cSeqID}})
												If !Empty(oModelG46:GetValue('G46_CODTX'))
													nLine := oModelG46:AddLine()
													oModelG46:GoLine(nLine)
												EndIf
											EndIf
	
											If !lDelete
												aAdd(aDados, {'G46_SEQTAX', cSeqID, cListOfRat + '/RatesInternalId'})
												aAdd(aDados, {'G46_EMISS' ,       , cListOfRat + '/IssueDate'})
												aAdd(aDados, {'G46_CODTX' , cCodTx, cListOfRat + '/TravelRatesInternalId'})
												aAdd(aDados, {'G46_VLBASE',		  , cListOfRat + '/Value'})
												aAdd(aDados, {'G46_MOEDFO', cMoeda, cListOfRat + '/TravelCurrencyInternalId'})
												aAdd(aDados, {'G46_TXCAMB',		  , cListOfRat + '/Exchange'})
												aAdd(aDados, {'G46_OBS'	  ,		  , cListOfRat + '/Observations'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G46'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG46, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
	
											If lRet
												If !oModelG46:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G46
												EndIf
												lAddG46 := .T.
												aAdd(aIntID,   {'Rates', cExtID, cIntID, 'G46', 'G46_SEQTAX'})
												aAdd(aDetalhe, {'G46'  , cIdItem + cNumSeq + cSeqID})
											Else
												Exit		// Saindo do laço G46
											EndIf
										Next nT
										
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
									
									// Extras ----------------------------------------------------------------------------------------------------------------------
									If (nCont1 := oXml:xPathChildCount(cListReserv + '/ListOfExtras')) > 0
										For nT := 1 To nCont1
											aDados	   := {}
											cListOfExt := cListReserv + '/ListOfExtras/Extras[' + cValToChar(nT) + "]"
											cExtID	   := AllTrim(oXml:XPathGetNodeValue(cListOfExt + '/ExtrasInternalId'))
											cMoeda	   := AllTrim(oXml:XPathGetNodeValue(cListOfExt + '/TravelCurrencyInternalId'))
											
											// validação de duplicidade chave externa - Extras
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G47'), 'G47', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G47', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G47_ITENS", "G47_SEQ", "G47_ITENS", "G47_SEQ", "TI034ChvDpl", cMsgErro, STR0017, cExtID)	// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada." 
												Exit		// Saindo do laço G47
											EndIf
											 
											cIntID := ''
											cSeqID := PadR(AllTrim(TURXRetId(cMarca, "G47", "G47_SEQ"	, cExtID, @cIntID, 6)), TamSx3("G47_SEQ")[1])
											cMoeda := PadR(AllTrim(TURXRetId(cMarca, "G5T", "G5T_CODIGO", cMoeda, Nil    , 3)), TamSx3("G47_MOEDFO")[1])
											
											If Empty(cIntID)
												cSeqID := IIF(oModelG47:Length() == 1 .And. !lAddG47, StrZero(1, TamSx3("G47_SEQ")[1]), StrZero(Val(oModelG47:GetValue("G47_SEQ", oModelG47:Length())) + 1, TamSx3("G47_SEQ")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSeqID), "G47")
											EndIf
											
											If !lDelete .And. !oModelG47:SeekLine({{"G47_SEQ", cSeqID}})
												If !Empty(oModelG47:GetValue('G47_EMISS'))
													nLine := oModelG47:AddLine()
													oModelG47:GoLine(nLine)
												EndIf
											EndIf 
	
											If !lDelete
												aAdd(aDados, {'G47_SEQ'	  , cSeqID, cListOfExt + '/ExtrasInternalId'})
												aAdd(aDados, {'G47_EMISS' ,       , cListOfExt + '/IssueDate'})
												aAdd(aDados, {'G47_EXTRA' ,       , cListOfExt + '/Description'})
												aAdd(aDados, {'G47_MOEDFO', cMoeda, cListOfExt + '/TravelCurrencyInternalId'})
												aAdd(aDados, {'G47_TXCAMB',       , cListOfExt + '/Exchange'})
												aAdd(aDados, {'G47_VLUNIT',       , cListOfExt + '/UnitaryValue'})
												aAdd(aDados, {'G47_QUANT' ,       , cListOfExt + '/Quantity'})
												aAdd(aDados, {'G47_TOTFOR',       , cListOfExt + '/AmountValue'})
												aAdd(aDados, {'G47_OBS'	  ,       , cListOfExt + '/Observations'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G47'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG47, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
											
											If lRet
												If !oModelG47:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G47
												EndIf
												lAddG47 := .T.
												aAdd(aIntID,   {'Extras', cExtID, cIntID, 'G47', 'G47_SEQ'})
												aAdd(aDetalhe, {'G47'   , cIdItem + cNumSeq + cSeqID})
											Else
												Exit		// Saindo do laço G47
											EndIf
										Next nT
	
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
									
									// Impostos ----------------------------------------------------------------------------------------------------------------------
									If (nCont1 := oXml:xPathChildCount(cListReserv + '/ListOfTaxes')) > 0
										For nT := 1 To nCont1
											cListOfTax := cListReserv + '/ListOfTaxes/Taxes[' + cValToChar(nT) + "]"
											aDados	   := {}
											cExtID	   := AllTrim(oXml:XPathGetNodeValue(cListOfTax + '/TravelTaxInternalId'))
											cTax	   := AllTrim(oXml:XPathGetNodeValue(cListOfTax + '/TaxInternalId'))
											cMoeda	   := AllTrim(oXml:XPathGetNodeValue(cListOfTax + '/TravelCurrencyInternalId'))
											
											// validação de duplicidade chave externa - Impostos
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G49'), 'G49', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G49', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G49_ITENS", "G49_SEQ", "G49_ITENS", "G49_SEQ", "TI034ChvDpl", cMsgErro, STR0017, cExtID)	// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G49
											EndIf 
	
											cIntID := ''
											cSeqID := PadR(AllTrim(TURXRetId(cMarca, "G49", "G49_SEQ"	, cExtID, @cIntID, 6)), TamSx3("G49_SEQ")[1])
											cMoeda := PadR(AllTrim(TURXRetId(cMarca, "G5T", "G5T_CODIGO", cMoeda, Nil	 , 3)), TamSx3("G49_MOEDA")[1])
											cTax   := PadR(AllTrim(TURXRetId(cMarca, "G5R", "G5R_CODIGO", cTax	, Nil	 , 3)), TamSx3("G49_CODIMP")[1])
											
											If Empty(cIntID)
												cSeqID	:= IIF(oModelG49:Length() == 1 .And. !lAddG49, StrZero(1, TamSx3("G49_SEQ")[1]), StrZero(Val(oModelG49:GetValue("G49_SEQ", oModelG49:Length())) + 1, TamSx3("G49_SEQ")[1]))
												cIntID	:= TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSeqID), "G49")
											EndIf
											
											If !lDelete .And. !oModelG49:SeekLine({{"G49_SEQ", cSeqID}})
												If !Empty(oModelG49:GetValue('G49_CODIMP'))
													nLine := oModelG49:AddLine()
													oModelG49:GoLine(nLine)
												EndIf
											EndIf
	
											If !lDelete
												aAdd(aDados, {'G49_SEQ'   , cSeqID, cListOfTax + '/TravelTaxInternalId'})
												aAdd(aDados, {'G49_CODIMP', cTax  , cListOfTax + '/TaxInternalId'})
												aAdd(aDados, {'G49_DESIMP',		  , cListOfTax + '/Description'})
												aAdd(aDados, {'G49_MOEDA' , cMoeda, cListOfTax + '/TravelCurrencyInternalId'})
												aAdd(aDados, {'G49_BASE'  ,		  , cListOfTax + '/TaxCalculationBase'})
												aAdd(aDados, {'G49_ALIQ'  ,		  , cListOfTax + '/TaxRate'})
												aAdd(aDados, {'G49_VALOR' ,       , cListOfTax + '/AppliedTaxValue'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G49'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG49, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
											
											If lRet
												If !oModelG49:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G49
												EndIf
												lAddG49 := .T.
												aAdd(aIntID  , {'Taxes', cExtID, cIntID, 'G49', 'G49_SEQ'})
												aAdd(aDetalhe, {'G49'  , cIdItem + cNumSeq + cSeqID})
											Else
												Exit		// Saindo do laço G49
											EndIf
										Next nT
										
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
											
									// Passageiros ----------------------------------------------------------------------------------------------------------------------
									If lRet .And. (nCont1 := oXml:xPathChildCount(cListReserv + '/ListOfPassenger')) > 0
										For nT := 1 To nCont1
											aDados      := {}
											cListPassag := cListReserv + '/ListOfPassenger/Passenger[' + cValToChar(nT) + ']'
											cExtPax     := AllTrim(oXml:XPathGetNodeValue(cListPassag + "/PassengerCode"))
											cExtID      := AllTrim(oXml:XPathGetNodeValue(cListPassag + "/PassengerInternalId"))
											cContato    := AllTrim(oXml:XPathGetNodeValue(cListPassag + "/ContactInternalId"))
											
											// validação de duplicidade chave externa - Passageiros
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G3S'), 'G3S', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G3S', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G3S_ITENS", "G3S_CODPAX", "G3S_ITENS", "G3S_CODPAX", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G3S
											EndIf 
	
											cIntID   := ''
											cCodPax  := PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cExtID  , @cIntID, 6)), TamSx3("G3S_CODPAX")[1])
											cContato := PadR(AllTrim(TURXRetId(cMarca, "SU5", "U5_CODCONT", cContato, Nil	 , 3)), TamSx3("G3S_CONTAT")[1])
											
											If Empty(cIntID)
												cCodPax	:= IIF(oModelG3S:Length() == 1 .And. !lAddG3S, StrZero(1, TamSx3("G3S_CODPAX")[1]), StrZero(Val(oModelG3S:GetValue("G3S_CODPAX", oModelG3S:Length())) + 1, TamSx3("G3S_CODPAX")[1]))
												cIntID	:= TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cCodPax), "G3S")
											EndIf
											
											If !lDelete .And. !oModelG3S:SeekLine({{"G3S_CODPAX", cCodPax}})
												If !Empty(oModelG3S:GetValue('G3S_TPPAX')) .or. oModelG3S:IsDeleted()
													nLine := oModelG3S:AddLine()
													oModelG3S:GoLine(nLine)
												EndIf
											EndIf
	
											If !lDelete .And. FwFldGet('G3R_DETPAX') == "1"
												aAdd(aDados, {"G3S_CODPAX", cCodPax	, cListPassag + "/PassengerInternalId"})
												aAdd(aDados, {'G3S_CONTAT', cContato, cListPassag + "/ContactInternalId"})
												aAdd(aDados, {"G3S_TPPAX" ,			, cListPassag + '/PAXType'})
												aAdd(aDados, {"G3S_TRATAM",			, cListPassag + '/Treatment'})
												aAdd(aDados, {"G3S_PRINOM",			, cListPassag + '/FirstName'})
												aAdd(aDados, {"G3S_ULTNOM",			, cListPassag + '/LastName'})
												aAdd(aDados, {"G3S_NOME"  ,			, cListPassag + '/FullName'})
												aAdd(aDados, {"G3S_MATRIC",			, cListPassag + '/Registration'})
												aAdd(aDados, {"G3S_SEXO"  ,			, cListPassag + '/Gender'})
												aAdd(aDados, {"G3S_NACION",			, cListPassag + '/Nationality'})
												aAdd(aDados, {"G3S_DTNASC",			, cListPassag + '/BirthDate'})
												aAdd(aDados, {"G3S_EMAIL" ,			, cListPassag + '/PAXEmail'})
												aAdd(aDados, {"G3S_VIP"	  ,			, cListPassag + '/VIP'})
												aAdd(aDados, {"G3S_TERCEI",			, cListPassag + '/Outsourced'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G3S'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG3S, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
	
											If !lRet 
												Exit		// Saindo do laço G3S
											EndIf
	
											If oModel:GetOperation() == MODEL_OPERATION_UPDATE
												Tur034InfA()
											EndIf
	
											aAdd(aPassenger, {cExtPax, cCodPax})
											aAdd(aIntID    , {'Passenger', cExtID, cIntID, 'G3S', 'G3S_CODPAX'})
											aAdd(aDetalhe  , {'G3S', cIdItem + cNumSeq + cCodPax})
									
											// Informações adicionais ----------------------------------------------------------------------------------------------------------------------
											If (nCont2 := oXml:xPathChildCount(cListPassag + '/ListOfAdditionalEntities')) > 0
												For nA := 1 To nCont2
													cListAddEnt	:= cListPassag + '/ListOfAdditionalEntities/AdditionalEntities[' + cValToChar(nA) + ']'
											
													If !Empty(cExtID := AllTrim(oXml:XPathGetNodeValue(cListAddEnt + "/AdditionalEntityTypeInternalId")))
														cIntID	  := ""
														cLjExtEnt := AllTrim(oXml:XPathGetNodeValue(cListAddEnt + "/ReferenceStoreInternalId"))
														cTpEnt	  := PadR(AllTrim(TURXRetId(cMarca, "G3E", "G3E_CODIGO", cExtID, @cIntID, 3, @cMsgErro)), TamSx3("G4B_TPENT")[1])
														
														If !Empty(cExtID) .And. !Empty(cMsgErro)
															lRet := .F.
															Exit		// Saindo do laço G4B
														EndIf
														
														If !Empty(cItemExtId := AllTrim(oXml:XPathGetNodeValue(cListAddEnt + "/AdditionalEntityItemInternalId")))
															cItemEnt := PadR(AllTrim(TURXRetId(cMarca, "G3G", "G3G_ITEM", cItemExtId, Nil, 6, @cMsgErro)), TamSx3("G4B_ITEM")[1])
															If Empty(cItemEnt) .And. !Empty(cMsgErro)
																lRet     := .F.
																Exit		// Saindo do laço G4B
															EndIf
														Else
															cItemEnt := PadR(AllTrim(oXml:XPathGetNodeValue(cListAddEnt + "/AdditionalEntityItemCode")), TamSx3("G4B_ITEM")[1])
														EndIf

														If !Empty(cLjExtEnt)
															If (aClient := IntCliInt(cLjExtEnt,cMarca))[1]
																cCliEntit := PadR(aClient[2][3], TamSx3("A1_COD")[1])
																cLjEntit  := PadR(aClient[2][4], TamSx3("G4B_LOJA")[1])
															Else
																lRet     := .F.
																cMsgErro :=  aClient[2]
																TxDestroy(aClient)
																Exit		// Saindo do laço G4B
															EndIf
															TxDestroy(aClient)
														EndIf

														G3F->(DbSetOrder(1))	// G3F_FILIAL+G3F_CODCLI+G3F_LOJA+G3F_TIPO
														G3G->(DbSetOrder(1))	// G3G_FILIAL+G3G_CLIENT+G3G_LOJA+G3G_TIPO+G3G_ITEM
														cSolucao := STR0011 + RTrim(cCodPax)	// "Verifique as Entidades do Passageiro: "
														If !G3F->(DbSeek(xFilial('G3F') + cCliEntit + cLjEntit + cTpEnt))
															lRet     := .F.
															cMsgErro := STR0010		// "Tipo de Entidade não vinculada ao Cliente"
															cReferen := RTrim(cTpEnt) + " - " + RTrim(Posicione("G3E", 1, xFilial("G3E") + cTpEnt, "G3E->G3E_DESCR"))
															oModel:SetErrorMessage("G4B_ITENS", 'G4B_TPENT', "G4B_ITENS", 'G4B_TPENT', "Turi034EntAdd1", cMsgErro, cSolucao, cReferen)
															Exit		// Saindo do laço G4B
														Else
															If (cSegNeg == '1' .And. !G3F->G3F_CORP) .Or. (cSegNeg == '2' .And. !G3F->G3F_EVENTO) .Or. (cSegNeg == '3' .And. !G3F->G3F_LAZER) 
																Loop
															EndIf   
															  
															If !Empty(cItemExtId) .And. !G3G->(DbSeek(xFilial('G3G') + cCliEntit + cLjEntit + cTpEnt + cItemEnt))
																lRet     := .F.
																cMsgErro := STR0012		// "Item da Entidade não vinculada ao Cliente"
																cReferen := RTrim(cItemEnt) + " " + RTrim(Posicione("G3G", 1, xFilial("G3G") + cCliEntit + cLjEntit + cTpEnt + cItemEnt, "G3G->G3G_DESCR"))
																oModel:SetErrorMessage("G4B_ITENS", 'G4B_ITEM', "G4B_ITENS", 'G4B_ITEM', "Turi034EntAdd2", cMsgErro, cSolucao, cReferen)
																Exit		// Saindo do laço G4B
															EndIf
														EndIf

														If !lDelete
															If oModelG4B:SeekLine({{'G4B_TPENT', cTpEnt}})
																If !oModelG4B:SetValue('G4B_ITEM', cItemEnt)
																	lRet := .F.
																EndIf
																
																If lRet .And. !oModelG4B:SetValue('G4B_LOJA', cLjEntit)
																	lRet := .F.
																EndIf
															Else
																lRet := .F.
																oModel:SetErrorMessage("G4B_ITENS", 'G4B_TPENT', "G4B_ITENS", 'G4B_TPENT', "Turi034EntAdd", STR0010, STR0011 + RTrim(cCodPax), RTrim(cTpEnt) + " - " + RTrim(Posicione("G3E", 1, xFilial("G3E") + cTpEnt, "G3E->G3E_DESCR"))) 	// "Tipo de Entidade não vinculada ao Cliente"	"Verifique as Entidades do Passageiro: "
															EndIf
														EndIf

														If lRet 
															If !oModelG4B:VldLineData()
																lRet := .F.
																Exit		// Saindo do laço G4B
															EndIf
														Else
															Exit		// Saindo do laço G4B
														EndIf
													EndIf
												Next nA
											EndIf
											
											If lRet 
												If !oModelG3S:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G3S
												EndIf
											Else
												Exit		// Saindo do laço G3S
											EndIf
										Next nT
										
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
							
									// Reembolso ----------------------------------------------------------------------------------------------------------------------
									cReemb := cListReserv + '/Refund'
									If oXml:XPathHasNode(cReemb)
										aDados	  := {}
										cMotReemb := AllTrim(oXml:XPathGetNodeValue(cReemb + "/RefundReasonInternalId"))
										cMoedaFor := AllTrim(oXml:XPathGetNodeValue(cReemb + "/TravelCurrencyInternalId"))
										cMoeda	  := AllTrim(oXml:XPathGetNodeValue(cReemb + "/CurrencyInternalId"))
										cMotReemb := PadR(AllTrim(TURXRetId(cMarca, "G8P", "G8P_CODIGO", cMotReemb, Nil, 3)), TamSx3("G4E_MOTREE")[1])
										cMoedaFor := PadR(AllTrim(TURXRetId(cMarca, "G5T", "G5T_CODIGO", cMoedaFor, Nil, 3)), TamSx3("G4E_MOEDA")[1])
										cMoeda	  := PadR(AllTrim(TURXRetId(cMarca, "G5T", "G5T_CODIGO", cMoeda	  , Nil, 3)), TamSx3("G4E_MOEDA")[1])
										
										If !lDelete
											aAdd(aDados, {'G4E_DTSOLI',			 , cReemb + "/DocumentRequest"})
											aAdd(aDados, {'G4E_MOTREE', cMotReemb, cReemb + "/RefundReasonInternalId"})
											aAdd(aDados, {'G4E_TPREE' ,			 , cReemb + "/RefundType"})
											aAdd(aDados, {'G4E_DESTFN',			 , cReemb + "/FinancialDestiny"})
											aAdd(aDados, {'G4E_DTPREV',			 , cReemb + "/PredictionOfReceipt"})
											aAdd(aDados, {'G4E_DTCRED',			 , cReemb + "/DateOfCreditAgency"})
											aAdd(aDados, {'G4E_OBSINT',			 , cReemb + "/InternalNote"})
											aAdd(aDados, {'G4E_TPTAR' ,			 , cReemb + "/FareType"})
											aAdd(aDados, {'G4E_MOEDFO', cMoedaFor, cReemb + "/TravelCurrencyInternalId"})
											aAdd(aDados, {'G4E_TXCAMB',			 , cReemb + "/Exchange"})
											aAdd(aDados, {'G4E_TARPAG',			 , cReemb + "/FarePaid"})
											aAdd(aDados, {'G4E_MOEDA' , cMoeda	 , cReemb + "/CurrencyInternalId"})
											aAdd(aDados, {'G4E_TPGINT',			 , cReemb + "/NationalFarePaid"})
											aAdd(aDados, {'G4E_TARUTI',			 , cReemb + "/FaresUsed"})
											aAdd(aDados, {'G4E_TREEMB',			 , cReemb + "/FaresRefunded"})
											aAdd(aDados, {'G4E_TXPG'  ,			 , cReemb + "/RatesPaid"})
											aAdd(aDados, {'G4E_TXREEM',			 , cReemb + "/RatesRefunded"})
											aAdd(aDados, {'G4E_EXTPG' ,			 , cReemb + "/ExtrasPaid"})
											aAdd(aDados, {'G4E_EXREEM',			 , cReemb + "/ExtrasRefunded"})
											aAdd(aDados, {'G4E_OBSCAL',			 , cReemb + "/CalculationNote"})
										EndIf
										
										For n1 := 1 to Len(aDados)
											If !TxGetNdXml(oXml, aDados[n1][3], oModelG4E, aDados[n1][1], aDados[n1][2])
												lRet :=  .F.
												Exit
											EndIf
										Next n1
										TxDestroy(aDados)
	
										If lRet 
											If !oModelG4E:VldLineData()
												lRet := .F.
												Exit		// Saindo do laço G3Q
											EndIf
										Else
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
							
									// Segmento AEREO ----------------------------------------------------------------------------------------------------------------------
									If (nCont2 := oXml:xPathChildCount(cListReserv + '/ListOfSegmentAir')) > 0
										For nA := 1 To nCont2
											aDados    := {}
											cSegment  := cListReserv + '/ListOfSegmentAir/SegmentAir[' + cValToChar(nA) + ']'
											cExtID    := AllTrim(oXml:XPathGetNodeValue(cSegment + "/SegmentInternalId"))
											cExtCdPax := AllTrim(oXml:XPathGetNodeValue(cSegment + "/PassengerCode"))
											cPassagId := AllTrim(oXml:XPathGetNodeValue(cSegment + "/PassengerInternalId"))
											cFornExt  := AllTrim(oXml:XPathGetNodeValue(cSegment + "/ProductVendorInternalId"))
											cAeroOri  := AllTrim(oXml:XPathGetNodeValue(cSegment + "/AirportOriginInternalId"))
											cAeroDes  := AllTrim(oXml:XPathGetNodeValue(cSegment + "/AirportDestinyInternalId"))
											cClasse   := AllTrim(oXml:XPathGetNodeValue(cSegment + "/ServiceClassInternalId"))
											
											// validação de duplicidade chave externa - Seg AEREO
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G3T'), 'G3T', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G3T', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G3T_ITENS", "G3T_ID", "G3T_ITENS", "G3T_ID", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G3T
											EndIf 
	
											cIntID := ""
											cSegID := PadR(AllTrim(TURXRetId(cMarca, "G3T", "G3T_ID", cExtID, @cIntID, 6)), TamSx3("G3T_ID")[1])
											If (aForn := IntForInt(cFornExt, cMarca))[1]
												cFornec	:= PadR(aForn[2][3],TamSx3("A2_COD")[1])
												cLoja	:= PadR(aForn[2][4],TamSx3("A2_LOJA")[1])
											Else
												lRet     := .F.
												cMsgErro := aForn[2]
												TxDestroy(aForn)
												Exit		// Saindo do laço G3T
											EndIf
											TxDestroy(aForn)	
											
											cAeroOri := PadR(AllTrim(TURXRetId(cMarca, "G3B", "G3B_CODIGO", cAeroOri , Nil, 3)), TamSx3("G3T_TERORI")[1])
											cAeroDes := PadR(AllTrim(TURXRetId(cMarca, "G3B", "G3B_CODIGO", cAeroDes , Nil, 3)), TamSx3("G3T_TERDST")[1])
											cClasse  := PadR(AllTrim(TURXRetId(cMarca, "G3C", "G3C_CODIGO", cClasse	 , Nil, 5)), TamSx3("G3T_CLASRV")[1])
											cPassag  := PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cPassagId, Nil, 6)), TamSx3("G3S_CODPAX")[1])
											cAeroOri := Posicione('G3B', 1, xFilial("G3B") + cAeroOri, 'G3B_SIGLA')
											cAeroDes := Posicione('G3B', 1, xFilial("G3B") + cAeroDes, 'G3B_SIGLA')
	
											If Empty(cPassag) .And. (nPos := aScan(aPassenger,{|X| AllTrim(X[1]) == cExtCdPax})) <> 0
												cPassag := aPassenger[nPos][2]
											EndIf
											
											If Empty(cIntID)
												cSegID := IIF(oModelG3T:Length() == 1 .And. !lAddG3T, StrZero(1, TamSx3("G3T_ID")[1]), StrZero(Val(oModelG3T:GetValue("G3T_ID", oModelG3T:Length())) + 1, TamSx3("G3T_ID")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSegID), "G3T")
											EndIf
											
											If !lDelete .And. !oModelG3T:SeekLine({{'G3T_ID', cSegID}})
												If !Empty(oModelG3T:GetValue('G3T_ID'))
													nLine := oModelG3T:AddLine()
													oModelG3T:GoLine(nLine)
												EndIf
											EndIf

											If !lDelete
												T034SetStc({{"__cPassag", cPassag}})
												aAdd(aDados, {'G3T_ID'	  , cSegID	, cSegment + "/SegmentInternalId"})
												aAdd(aDados, {'G3T_CODPAX', cPassag	, cSegment + "/PassengerCode"})
												aAdd(aDados, {'G3T_IDINTE',			, cSegment + "/IntegrationID"})
												aAdd(aDados, {'G3T_LOC'	  ,			, cSegment + "/Locator"})
												aAdd(aDados, {'G3T_CODFOR', cFornec	, cSegment + "/ProductVendorInternalId"})
												aAdd(aDados, {'G3T_LOJAF' , cLoja	, cSegment + "/ProductVendorInternalId"})
												aAdd(aDados, {'G3T_GDS'	  ,			, cSegment + "/GDS"})
												aAdd(aDados, {'G3T_AERONA',			, cSegment + "/Aircraft"})
												aAdd(aDados, {'G3T_TERDST', cAeroDes, cSegment + "/AirportDestinyInternalId"})
												aAdd(aDados, {'G3T_TERORI', cAeroOri, cSegment + "/AirportOriginInternalId"})
												aAdd(aDados, {'G3T_CLASRV', cClasse	, cSegment + "/ServiceClassInternalId"})
												aAdd(aDados, {'G3T_NRVOO' ,			, cSegment + "/FlightNumber"})
												aAdd(aDados, {'G3T_DTSAID',			, cSegment + "/DepartureDate"})
												aAdd(aDados, {'G3T_HRINI' ,			, cSegment + "/DepartureTime"})
												aAdd(aDados, {'G3T_DTCHEG',			, cSegment + "/ArrivalDate"})
												aAdd(aDados, {'G3T_HRFIM' ,			, cSegment + "/ArrivalTime"})
												aAdd(aDados, {'G3T_TPPARA',			, cSegment + "/StopType"})
												aAdd(aDados, {'G3T_TMPVOO',			, cSegment + "/FlightTime"})
												aAdd(aDados, {'G3T_QTDESC',			, cSegment + "/StopQuantity"})
												aAdd(aDados, {'G3T_OBS'	  ,			, cSegment + "/Observation"})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G3T'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG3T, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
	
											If lRet 
												If !oModelG3T:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G3T
												EndIf
												lAddG3T := .T.
												aAdd(aIntID, {'SegmentAir', cExtID, cIntID, 'G3T', 'G3T_ID'})
												aAdd(aDetalhe, {'G3T', cIdItem + cNumSeq + cSegID})
											Else
												Exit		// Saindo do laço G3T
											EndIf
										Next nA 
	
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
	
									// Segmento HOTEL ----------------------------------------------------------------------------------------------------------------------
									If (nCont2 := oXml:xPathChildCount(cListReserv + '/ListOfSegmentHotel')) > 0
										For nA := 1 To nCont2
											aDados	  := {}
											cSegment  := cListReserv + '/ListOfSegmentHotel/SegmentHotel[' + cValToChar(nA) + ']'
											cExtID	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/SegmentInternalId'))
											cCatApt	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/ApartamentTypeInternalId'))
											cBroker	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/BrokerSystemInternalId'))
											cPassagId := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerInternalId'))
											cExtCdPax := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerCode'))
											
											// validação de duplicidade chave externa - Seg HOTEL
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G3U'), 'G3U', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G3U', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G3U_ITENS", "G3U_ID", "G3U_ITENS", "G3U_ID", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G3U
											EndIf 
	
											cIntID	:= ""
											cSegID	:= PadR(AllTrim(TURXRetId(cMarca, "G3U", "G3U_ID"	 , cExtID	, @cIntID, 6)), TamSx3("G3U_ID")[1])
											cCatApt	:= PadR(AllTrim(TURXRetId(cMarca, "G4J", "G4J_CODIGO", cCatApt	, Nil	 , 3)), TamSx3("G3U_CODAPO")[1])
											cBroker	:= PadR(AllTrim(TURXRetId(cMarca, "G8O", "G8O_CODIGO", cBroker	, Nil	 , 3)), TamSx3("G3U_BROKER")[1])
											cPassag	:= PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cPassagId, Nil	 , 6)), TamSx3("G3S_CODPAX")[1])
	
											If Empty(cPassag) .And. (nPos := aScan(aPassenger, {|X| AllTrim(X[1]) == cExtCdPax})) <> 0
												cPassag := aPassenger[nPos][2]
											EndIf
											
											If Empty(cIntID)
												cSegID := IIF(oModelG3U:Length() == 1 .And. !lAddG3U, StrZero(1, TamSx3("G3U_ID")[1]), StrZero(Val(oModelG3U:GetValue("G3U_ID", oModelG3U:Length())) + 1, TamSx3("G3U_ID")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSegID), "G3U")
											EndIf
											
											If !lDelete .And. !oModelG3U:SeekLine({{'G3U_ID', cSegID}})
												If !Empty(oModelG3U:GetValue('G3U_ID'))
													nLine := oModelG3U:AddLine()
													oModelG3U:GoLine(nLine)
												EndIf
											EndIf
											
											If !lDelete
												T034SetStc({{"__cPassag", cPassag}})
												aAdd(aDados, {'G3U_ID'	  , cSegID , cSegment + '/SegmentInternalId'})
												aAdd(aDados, {'G3U_CODPAX', cPassag, cSegment + '/PassengerCode'})
												aAdd(aDados, {'G3U_IDINTE',		   , cSegment + '/IntegrationID'})
												aAdd(aDados, {'G3U_DTINI' ,		   , cSegment + '/CheckinDate'})
												aAdd(aDados, {'G3U_DTFIM' ,		   , cSegment + '/CheckoutDate'})
												aAdd(aDados, {'G3U_HRINI' ,		   , cSegment + '/CheckinTime'})
												aAdd(aDados, {'G3U_HRFIM' ,		   , cSegment + '/CheckoutTime'})
												aAdd(aDados, {'G3U_TPPROD',		   , cSegment + '/HotelProductType'})
												aAdd(aDados, {'G3U_QTDPRD',		   , cSegment + '/NumberOfProducts'})
												aAdd(aDados, {'G3U_CODAPO', cCatApt, cSegment + '/ApartamentTypeInternalId'}) //G4J
												aAdd(aDados, {'G3U_CATPRO',		   , cSegment + '/RoomCode'})
												aAdd(aDados, {'G3U_PRZCAN',		   , cSegment + '/CancellationDeadline'})
												aAdd(aDados, {'G3U_NOSHOW',		   , cSegment + '/NoShowWarranty'})
												aAdd(aDados, {'G3U_PLALIM',		   , cSegment + '/FoodServiceCode'})
												aAdd(aDados, {'G3U_BROKER', cBroker, cSegment + '/BrokerSystemInternalId'})	//G8O
												aAdd(aDados, {'G3U_OBS'	  ,		   , cSegment + '/Observation'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G3U'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG3U, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)

											If lRet 
												If !oModelG3U:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G3U
												EndIf
												lAddG3U := .T.
												aAdd(aIntID, {'SegmentHotel', cExtID, cIntID, 'G3U', 'G3U_ID'})
												aAdd(aDetalhe, {'G3U', cIdItem + cNumSeq + cSegID})
											Else
												Exit		// Saindo do laço G3U
											EndIf
										Next nA
	
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
									
									// Segmento CARRO ----------------------------------------------------------------------------------------------------------------------
									If (nCont2 := oXml:xPathChildCount(cListReserv + '/ListOfSegmentVehicle')) > 0
										For nA := 1 To nCont2
											aDados	  := {}
											cSegment  := cListReserv + '/ListOfSegmentVehicle/SegmentVehicle[' + cValToChar(nA) + ']'
											cExtID	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/SegmentInternalId'))
											cPassagId := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerInternalId'))
											cExtCdPax := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerCode'))
											cCidRet	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PickUpCityInternalId'))
											cCidDev	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/ReturnCityInternalId'))
											cCatVeic  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/VehicleCategoryInternalId'))
											cTpVeic   := AllTrim(oXml:XPathGetNodeValue(cSegment + '/VehicleTypeInternalId'))
											cDirec	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/DirectionTypeInternalId'))
											cFuel	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/FuelTypeInternalId'))
											cBroker	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/BrokerSystemInternalId'))
											
											// validação de duplicidade chave externa - Seg CARRO
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G3V'), 'G3V', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G3V', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G3V_ITENS", "G3V_ID", "G3V_ITENS", "G3V_ID", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G3V
											EndIf 
														
											cIntID	 := ""
											cSegID	 := PadR(AllTrim(TURXRetId(cMarca, "G3V", "G3V_ID"	  , cExtID	 , @cIntID, 6)), TamSx3("G3V_ID")[1])
											cCidRet	 := PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidRet	 , Nil	  , 3)), TamSx3("G3V_CIDRET")[1])
											cCidDev	 := PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidDev	 , Nil	  , 3)), TamSx3('G3V_CIDDEV')[1])
											cCatVeic := PadR(AllTrim(TURXRetId(cMarca, "G4Y", "G4Y_CODIGO", cCatVeic , Nil	  , 3)), TamSx3('G3V_CATAUT')[1])
											cTpVeic	 := PadR(AllTrim(TURXRetId(cMarca, "G4Z", "G4Z_CODIGO", cTpVeic	 , Nil	  , 3)), TamSx3('G3V_TPAUT')[1])
											cDirec	 := PadR(AllTrim(TURXRetId(cMarca, "G50", "G50_CODIGO", cDirec	 , Nil	  , 3)), TamSx3('G3V_TRADIR')[1])
											cFuel	 := PadR(AllTrim(TURXRetId(cMarca, "G51", "G51_CODIGO", cFuel	 , Nil	  , 3)), TamSx3('G3V_COMBAR')[1])
											cBroker	 := PadR(AllTrim(TURXRetId(cMarca, "G8O", "G8O_CODIGO", cBroker	 , Nil	  , 3)), TamSx3("G3U_BROKER")[1])
											cPassag	 := PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cPassagId, Nil	  , 6)), TamSx3("G3S_CODPAX")[1])
	
											If Empty(cPassag) .And. (nPos := aScan(aPassenger, {|X| AllTrim(X[1]) == cExtCdPax})) <> 0
												cPassag := aPassenger[nPos][2]
											EndIf
											
											If Empty(cIntID)
												cSegID := IIF(oModelG3V:Length() == 1 .And. !lAddG3V, StrZero(1, TamSx3("G3V_ID")[1]), StrZero(Val(oModelG3V:GetValue("G3V_ID", oModelG3V:Length())) + 1, TamSx3("G3V_ID")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSegID), "G3V")
											EndIf
											
											If !lDelete .And. !oModelG3V:SeekLine({{'G3V_ID', cSegID}})
												If !Empty(oModelG3V:GetValue('G3V_CIDRET'))
													nLine := oModelG3V:AddLine()
													oModelG3V:GoLine(nLine)
												EndIf
											EndIf
	
											If !lDelete
												T034SetStc({{"__cPassag", cPassag}})
												aAdd(aDados, {'G3V_ID'	  , cSegID	, cSegment + '/SegmentInternalId'})
												aAdd(aDados, {'G3V_CODPAX', cPassag	, cSegment + '/PassengerCode'})
												aAdd(aDados, {'G3V_IDINTE',			, cSegment + '/IntegrationID'})
												aAdd(aDados, {'G3V_CIDRET', cCidRet	, cSegment + '/PickUpCityInternalId'})
												aAdd(aDados, {'G3V_LOCRET',			, cSegment + '/PickUpLocation'})
												aAdd(aDados, {'G3V_CIDDEV', cCidDev	, cSegment + '/ReturnCityInternalId'})
												aAdd(aDados, {'G3V_LOCDEV',			, cSegment + '/ReturnLocation'})
												aAdd(aDados, {'G3V_QTDPRD',			, cSegment + '/NumberOfVehicle'})
												aAdd(aDados, {'G3V_CATAUT', cCatVeic, cSegment + '/VehicleCategoryInternalId'})
												aAdd(aDados, {'G3V_TPAUT' , cTpVeic	, cSegment + '/VehicleTypeInternalId'})
												aAdd(aDados, {'G3V_TRADIR', cDirec	, cSegment + '/DirectionTypeInternalId'})
												aAdd(aDados, {'G3V_COMBAR', cFuel	, cSegment + '/FuelTypeInternalId'})
												aAdd(aDados, {'G3V_DTINI' ,			, cSegment + '/PickUpDate'})
												aAdd(aDados, {'G3V_HRINI' ,			, cSegment + '/PickUpTime'})
												aAdd(aDados, {'G3V_DTFIM' ,			, cSegment + '/ReturnDate'})
												aAdd(aDados, {'G3V_HRFIM' ,			, cSegment + '/ReturnTime'})
												aAdd(aDados, {'G3V_BROKER', cBroker	, cSegment + '/BrokerSystemInternalId'})
												aAdd(aDados, {'G3V_QTDDIA',			, cSegment + '/Daily'})
												aAdd(aDados, {'G3V_DTCANC',			, cSegment + '/CancellationDeadline'})
												aAdd(aDados, {'G3V_NOSHOW',			, cSegment + '/NoShowWarranty'})
												aAdd(aDados, {'G3V_OBS'	  ,			, cSegment + '/Observation'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G3V'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG3V, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
	
											If lRet 
												If !oModelG3V:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G3V
												EndIf
												lAddG3V := .T.
												aAdd(aIntID, {'SegmentVehicle', cExtID, cIntID, 'G3V', 'G3V_ID'})
												aAdd(aDetalhe, {'G3V', cIdItem + cNumSeq + cSegID})
											Else
												Exit		// Saindo do laço G3V
											EndIf
										Next nA
	
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
	
									// Segmento RODOVIARIO ----------------------------------------------------------------------------------------------------------------------
									If (nCont2 := oXml:xPathChildCount(cListReserv + '/ListOfSegmentRoad')) > 0
										For nA := 1 To nCont2
											aDados	  := {}
											cSegment  := cListReserv + '/ListOfSegmentRoad/SegmentRoad[' + cValToChar(nA) + ']'
											cExtID	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/SegmentInternalId'))
											cPassagId := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerInternalId'))
											cExtCdPax := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerCode'))
											cLinha	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/RoadLineInternalId'))
											cTrecho	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/StretchInternalId'))
											cCidEmb	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/DepartureCityInternalId'))
											cCidDest  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/ArrivalCityInternalId'))
											
											// validação de duplicidade chave externa - Seg RODOVIARIO
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G3W'), 'G3W', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G3W', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G3W_ITENS", "G3W_ID", "G3W_ITENS", "G3W_ID", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G3W
											EndIf 
											
											cIntID	 := ""
											cSegID 	 := PadR(AllTrim(TURXRetId(cMarca, "G3W", "G3W_ID"	  , cExtID	 , @cIntID, 6)), TamSx3("G3W_ID")[1])
											cCidEmb	 := PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidEmb	 , Nil	  , 3)), TamSx3("G3W_CIDEMB")[1])
											cCidDest := PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidDest , Nil	  , 3)), TamSx3("G3W_CIDDES")[1])
											cLinha	 := PadR(AllTrim(TURXRetId(cMarca, "G8M", "G8M_CODIGO", cLinha	 , Nil	  , 3)), TamSx3("G3W_LINHA")[1])
											cTrecho	 := PadR(AllTrim(TURXRetId(cMarca, "G8N", "G8N_CODIGO", cTrecho	 , Nil	  , 4)), TamSx3("G3W_TRECHO")[1])
											cPassag	 := PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cPassagId, Nil	  , 6)), TamSx3("G3S_CODPAX")[1])
	
											If Empty(cPassag) .And. (nPos := aScan(aPassenger, {|X| AllTrim(X[1]) == cExtCdPax})) <> 0
												cPassag := aPassenger[nPos][2]
											EndIf
											
											If Empty(cIntID)
												cSegID := IIF(oModelG3W:Length() == 1 .And. !lAddG3W, StrZero(1, TamSx3("G3W_ID")[1]), StrZero(Val(oModelG3W:GetValue("G3W_ID", oModelG3W:Length())) + 1, TamSx3("G3W_ID")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSegID), "G3W")
											EndIf
											
											If !lDelete .And. !oModelG3W:SeekLine({{'G3W_ID', cSegID}})
												If !Empty(oModelG3W:GetValue('G3W_CIDEMB'))
													nLine := oModelG3W:AddLine()
													oModelG3W:GoLine(nLine)
												EndIf
											EndIf
											
											If !lDelete
												T034SetStc({{"__cPassag",cPassag}})
												aAdd(aDados, {'G3W_ID'	  , cSegID	, cSegment + '/SegmentInternalId'})
												aAdd(aDados, {'G3W_CODPAX', cPassag	, cSegment + '/PassengerCode'})
												aAdd(aDados, {'G3W_IDINTE',			, cSegment + '/IntegrationID'})
												aAdd(aDados, {'G3W_VEICUL',			, cSegment + '/VehicleDescription'})
												aAdd(aDados, {'G3W_LINHA' , cLinha	, cSegment + '/RoadLineInternalId'})
												aAdd(aDados, {'G3W_TRECHO', cTrecho	, cSegment + '/StretchInternalId'})
												aAdd(aDados, {'G3W_CATBUS',			, cSegment + '/BusCategory'})
												aAdd(aDados, {'G3W_CIDEMB', cCidEmb	, cSegment + '/DepartureCityInternalId'})
												aAdd(aDados, {'G3W_CIDDES', cCidDest, cSegment + '/ArrivalCityInternalId'})
												aAdd(aDados, {'G3W_LOCDES',			, cSegment + '/ArrivalLocation'})
												aAdd(aDados, {'G3W_DTINI' ,			, cSegment + '/DepartureDate'})
												aAdd(aDados, {'G3W_HRINI' ,			, cSegment + '/DepartureTime'})
												aAdd(aDados, {'G3W_DTFIM' ,			, cSegment + '/ArrivalDate'})
												aAdd(aDados, {'G3W_HRFIM' ,			, cSegment + '/ArrivalTime'})
												aAdd(aDados, {'G3W_OBS'	  ,			, cSegment + '/Observation'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G3W'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG3W, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
	
											If lRet 
												If !oModelG3W:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G3W
												EndIf
												lAddG3W := .T.
												aAdd(aIntID, {'SegmentRoad', cExtID, cIntID, 'G3W', 'G3W_ID'})
												aAdd(aDetalhe, {'G3W', cIdItem + cNumSeq + cSegID})
											Else 
												Exit		// Saindo do laço G3W
											EndIf
										Next nA
	
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
									
									// Segmento TREM ----------------------------------------------------------------------------------------------------------------------
									If (nCont2 := oXml:xPathChildCount(cListReserv + '/ListOfSegmentTrain')) > 0
										For nA := 1 To nCont2
											aDados	  := {}
											cSegment  := cListReserv + '/ListOfSegmentTrain/SegmentTrain[' + cValToChar(nA) + ']'
											cExtID	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/SegmentInternalId'))
											cExtCdPax := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerCode'))
											cPassagId := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerInternalId'))
											cCidOri	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/DepartureCityInternalId'))
											cCidDes	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/ArrivalCityInternalId'))
											
											// validação de duplicidade chave externa - Seg TREM
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G3X'), 'G3X', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G3X', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G3X_ITENS", "G3X_ID", "G3X_ITENS", "G3X_ID", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G3X
											EndIf 
											
											cIntID	:= ""
											cSegID	:= PadR(AllTrim(TURXRetId(cMarca, "G3X", "G3X_ID"	 , cExtID	, @cIntID, 6)), TamSx3("G3X_ID")[1])
											cCidOri	:= PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidOri	, Nil	 , 3)), TamSx3("G3X_CIDEMB")[1])
											cCidDes	:= PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidDes	, Nil	 , 3)), TamSx3("G3X_CIDEMB")[1])
											cPassag	:= PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cPassagId, Nil	 , 6)), TamSx3("G3S_CODPAX")[1])
	
											If Empty(cPassag) .And. (nPos := aScan(aPassenger, {|X| AllTrim(X[1]) == cExtCdPax})) <> 0
												cPassag := aPassenger[nPos][2]
											EndIf
											
											If Empty(cIntID)
												cSegID := IIF(oModelG3X:Length() == 1 .And. !lAddG3X, StrZero(1, TamSx3("G3X_ID")[1]), StrZero(Val(oModelG3X:GetValue("G3X_ID", oModelG3X:Length())) + 1, TamSx3("G3X_ID")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSegID), "G3X")
											EndIf
											
											If !lDelete .And. !oModelG3X:SeekLine({{'G3X_ID', cSegID}})
												If !Empty(oModelG3X:GetValue('G3X_CIDEMB'))
													nLine := oModelG3X:AddLine()
													oModelG3X:GoLine(nLine)
												EndIf
											EndIf
	
											If !lDelete
												T034SetStc({{"__cPassag",cPassag}})
												aAdd(aDados,{'G3X_ID'	 , cSegID , cSegment + '/SegmentInternalId'})
												aAdd(aDados,{'G3X_CODPAX', cPassag, cSegment + '/PassengerCode'})
												aAdd(aDados,{'G3X_IDINTE',		  , cSegment + '/IntegrationID'})
												aAdd(aDados,{'G3X_DESFER',		  , cSegment + '/Description'})
												aAdd(aDados,{'G3X_CTTREM',		  , cSegment + '/Category'})
												aAdd(aDados,{'G3X_NRTREM',		  , cSegment + '/Number'})
												aAdd(aDados,{'G3X_QTDPAR',		  , cSegment + '/StopQuantity'})
												aAdd(aDados,{'G3X_CIDEMB', cCidOri, cSegment + '/DepartureCityInternalId'})
												aAdd(aDados,{'G3X_CIDDES', cCidDes, cSegment + '/DepartureCityInternalId'})
												aAdd(aDados,{'G3X_DTINI' ,		  , cSegment + '/DepartureDate'})
												aAdd(aDados,{'G3X_HRINI' ,		  , cSegment + '/DepartureTime'})
												aAdd(aDados,{'G3X_DTFIM' ,		  , cSegment + '/ArrivalDate'})
												aAdd(aDados,{'G3X_HRFIM' ,		  , cSegment + '/ArrivalTime'})
												aAdd(aDados,{'G3X_OBS'	 ,		  , cSegment + '/Observation'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G3X'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG3X, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
	
											If lRet 
												If !oModelG3X:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G3X
												EndIf
												lAddG3X := .T.
												aAdd(aIntID, {'SegmentTrain', cExtID, cIntID, 'G3X', 'G3X_ID'})
												aAdd(aDetalhe, {'G3X', cIdItem + cNumSeq + cSegID})
											Else
												Exit		// Saindo do laço G3X
											EndIf
										Next nA
	
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
	
									// Segmento CRUZEIRO ----------------------------------------------------------------------------------------------------------------------
									If (nCont2 := oXml:xPathChildCount(cListReserv + '/ListOfSegmentMaritime')) > 0
										For nA := 1 To nCont2
											aDados	:= {}
											cSegment  := cListReserv + '/ListOfSegmentMaritime/SegmentMaritime[' + cValToChar(nA) + ']'
											cExtID	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/SegmentInternalId'))
											cExtCdPax := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerCode'))
											cPassagId := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerInternalId'))
											cCodNav	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/ShipInternalId'))
											cCidPri	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/MainCityInternalId'))
											cCidEmb	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/DepartureCityInternalId'))
											cTpCabin  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/CabinTypeInternalId'))
											
											// validação de duplicidade chave externa - Seg CRUZEIRO
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G3Y'), 'G3Y', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G3Y', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G3Y_ITENS", "G3Y_ID", "G3Y_ITENS", "G3Y_ID", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G3Y
											EndIf 
											
											cIntID	 := ""
											cSegID	 := PadR(AllTrim(TURXRetId(cMarca, "G3Y", "G3Y_ID"	  , cExtID	 , @cIntID, 6)), TamSx3("G3Y_ID")[1])
											cCidPri	 := PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidPri	 , Nil	  , 3)), TamSx3("G3Y_CIDPRI")[1])
											cCidEmb	 := PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidEmb	 , Nil	  , 3)), TamSx3("G3Y_CIDEMB")[1])
											cCodNav	 := PadR(AllTrim(TURXRetId(cMarca, "G4H", "G4H_CODIGO", cCodNav	 , Nil	  , 3)), TamSx3("G3Y_CODNAV")[1])
											cTpCabin := PadR(AllTrim(TURXRetId(cMarca, "G4I", "G4I_CODIGO", cTpCabin , Nil	  , 3)), TamSx3("G3Y_TPCABI")[1])
											cPassag	 := PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cPassagId, Nil	  , 6)), TamSx3("G3S_CODPAX")[1])
	
											If Empty(cPassag) .And. (nPos := aScan(aPassenger, {|X| AllTrim(X[1]) == cExtCdPax})) <> 0
												cPassag := aPassenger[nPos][2]
											EndIf
											
											If Empty(cIntID)
												cSegID := IIF(oModelG3Y:Length() == 1 .And. !lAddG3Y, StrZero(1, TamSx3("G3Y_ID")[1]), StrZero(Val(oModelG3Y:GetValue("G3Y_ID", oModelG3Y:Length())) + 1, TamSx3("G3Y_ID")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID)+ "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSegID), "G3Y")
											EndIf
	
											If !lDelete .And. !oModelG3Y:SeekLine({{'G3Y_ID', cSegID}})
												If !Empty(oModelG3Y:GetValue('G3Y_CODNAV'))
													nLine := oModelG3Y:AddLine()
													oModelG3Y:GoLine(nLine)
												EndIf
											EndIf
											
											If !lDelete
												T034SetStc({{"__cPassag",cPassag}})
												aAdd(aDados, {'G3Y_ID'    , cSegID  , cSegment + '/SegmentInternalId'})
												aAdd(aDados, {'G3Y_IDINTE',			, cSegment + '/IntegrationID'})
												aAdd(aDados, {'G3Y_CODPAX', cPassag	, cSegment + '/PassengerCode'})
												aAdd(aDados, {'G3Y_CODNAV', cCodNav	, cSegment + '/ShipInternalId'})
												aAdd(aDados, {'G3Y_DESNAV',			, cSegment + '/CruiseDescription'})
												aAdd(aDados, {'G3Y_CIDPRI', cCidPri	, cSegment + '/MainCityInternalId'})
												aAdd(aDados, {'G3Y_CIDEMB', cCidEmb	, cSegment + '/DepartureCityInternalId'})
												aAdd(aDados, {'G3Y_DTINI' ,			, cSegment + '/InitialDate'})
												aAdd(aDados, {'G3Y_DTFIM' ,			, cSegment + '/FinalDate'})
												aAdd(aDados, {'G3Y_HRINI' ,			, cSegment + '/InitialTime'})
												aAdd(aDados, {'G3Y_HRFIM' ,			, cSegment + '/FinalTime'})
												aAdd(aDados, {'G3Y_TPCABI', cTpCabin, cSegment + '/CabinTypeInternalId'})
												aAdd(aDados, {'G3Y_NRCABI',			, cSegment + '/CabinNumber'})
												aAdd(aDados, {'G3Y_DTCANC',			, cSegment + '/CancellationDeadline'})
												aAdd(aDados, {'G3Y_OBS'	  ,			, cSegment + '/Observation'})
											EndIf
											
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G3Y'})
											EndIf
											
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml,aDados[n1][3],oModelG3Y,aDados[n1][1],aDados[n1][2] )
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
	
											If lRet 
												If !oModelG3Y:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G3Y
												EndIf
												lAddG3Y := .T.
												aAdd(aIntID, {'SegmentMaritime', cExtID, cIntID, 'G3Y', 'G3Y_ID'})
												aAdd(aDetalhe, {'G3Y', cIdItem + cNumSeq + cSegID})
											Else
												Exit		// Saindo do laço G3Y
											EndIf
										Next nA
	
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
	
									// Segmento PACOTE ----------------------------------------------------------------------------------------------------------------------
									If (nCont2 := oXml:xPathChildCount(cListReserv + '/ListOfSegmentPackage')) > 0
										For nA := 1 To nCont2
											aDados	  := {}
											cSegment  := cListReserv + '/ListOfSegmentPackage/SegmentPackage[' + cValToChar(nA) + ']'
											cExtID	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/SegmentInternalId'))
											cPassagId := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerInternalId'))
											cExtCdPax := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerCode'))
											cCidPri	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/MainCityInternalId'))
											cCidDes	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/DepartureCityInternalId'))
											
											// validação de duplicidade chave externa - Seg CARRO
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G3Z'), 'G3Z', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G3Z', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G3Z_ITENS", "G3Z_ID", "G3Z_ITENS", "G3Z_ID", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G3Z
											EndIf 
											
											cIntID	:= ""
											cSegID	:= PadR(AllTrim(TURXRetId(cMarca, "G3Z", "G3Z_ID"	 , cExtID	, @cIntID, 6)), TamSx3("G3Z_ID")[1])
											cCidPri	:= PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidPri	, Nil	 , 3)), TamSx3("G3Z_CIDPRI")[1])
											cCidDes	:= PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidDes	, Nil	 , 3)), TamSx3("G3Z_CIDEMB")[1])
											cPassag	:= PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cPassagId, Nil	 , 6)), TamSx3("G3S_CODPAX")[1])
	
											If Empty(cPassag) .And. (nPos := aScan(aPassenger, {|X| AllTrim(X[1])== cExtCdPax})) <> 0
												cPassag := aPassenger[nPos][2]
											EndIf
											
											If Empty(cIntID)
												cSegID := IIF(oModelG3Z:Length() == 1 .And. !lAddG3Z, StrZero(1, TamSx3("G3Z_ID")[1]), StrZero(Val(oModelG3Z:GetValue("G3Z_ID", oModelG3Z:Length())) + 1, TamSx3("G3Z_ID")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSegID), "G3Z")
											EndIf
	
											If !lDelete .And. !oModelG3Z:SeekLine({{'G3Z_ID', cSegID}})
												If !Empty(oModelG3Z:GetValue('G3Z_CIDPRI'))
													nLine := oModelG3Z:AddLine()
													oModelG3Z:GoLine(nLine)
												EndIf
											EndIf
	
											If !lDelete
												T034SetStc({{"__cPassag",cPassag}})
												aAdd(aDados, {'G3Z_ID'	  , cSegID , cSegment + '/SegmentInternalId'})
												aAdd(aDados, {'G3Z_IDINTE',		   , cSegment + '/IntegrationID'})
												aAdd(aDados, {'G3Z_CODPAX', cPassag, cSegment + '/PassengerCode'})
												aAdd(aDados, {'G3Z_CIDPRI', cCidPri, cSegment + '/MainCityInternalId'})
												aAdd(aDados, {'G3Z_DESPAC',		   , cSegment + '/PackageDescription'})
												aAdd(aDados, {'G3Z_CIDEMB', cCidDes, cSegment + '/DepartureCityInternalId'})
												aAdd(aDados, {'G3Z_DTINI' ,		   , cSegment + '/InitialDate'})
												aAdd(aDados, {'G3Z_DTFIM' ,		   , cSegment + '/FinalDate'})
												aAdd(aDados, {'G3Z_HRINI' ,		   , cSegment + '/InitialTime'})
												aAdd(aDados, {'G3Z_HRFIM' ,		   , cSegment + '/FinalTime'})
												aAdd(aDados, {'G3Z_QTDPAC',		   , cSegment + '/NumberOfPackage'})
												aAdd(aDados, {'G3Z_DTCANC',		   , cSegment + '/CancellationDeadline'})
												aAdd(aDados, {'G3Z_OBS'	  ,		   , cSegment + '/Observation'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G3Z'})
											EndIf
											
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG3Z, aDados[n1][1], aDados[n1][2])
													lRet := .f.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
											
											If lRet 
												If !oModelG3Z:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G3Z
												EndIf
												lAddG3Z := .T.
												aAdd(aIntID,{'SegmentPackage', cExtID, cIntID, 'G3Z', 'G3Z_ID'})
												aAdd(aDetalhe,{'G3Z', cIdItem + cNumSeq + cSegID})
											Else
												Exit		// Saindo do laço G3Z
											EndIf
										Next nA
	
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
	
									// Segmento TOUR ----------------------------------------------------------------------------------------------------------------------
									If (nCont2 := oXml:xPathChildCount(cListReserv + '/ListOfSegmentTour')) > 0
										For nA := 1 To nCont2
											aDados	  := {}
											cSegment  := cListReserv + '/ListOfSegmentTour/SegmentTour[' + cValToChar(nA) + ']'
											cExtID	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/SegmentInternalId'))
											cPassagId := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerInternalId'))
											cExtCdPax := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerCode'))
											cCidPri	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/MainCityInternalId'))
											cCidEmb	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/DepartureCityInternalId'))
											
											// validação de duplicidade chave externa - Seg TOUR
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G40'), 'G40', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G40', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G40_ITENS", "G40_ID", "G40_ITENS", "G40_ID", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G40
											EndIf 
											
											cIntID	:= ""
											cSegID	:= PadR(AllTrim(TURXRetId(cMarca, "G40", "G40_ID"	 , cExtID	, @cIntID, 6)), TamSx3("G40_ID")[1])
											cCidPri	:= PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidPri	, Nil	 , 3)), TamSx3("G40_CIDPRI")[1])
											cCidEmb	:= PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidEmb	, Nil	 , 3)), TamSx3("G40_CIDEMB")[1])
											cPassag	:= PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cPassagId, Nil	 , 6)), TamSx3("G3S_CODPAX")[1])
	
											If Empty(cPassag) .And. (nPos := aScan(aPassenger, {|X| AllTrim(X[1]) == cExtCdPax})) <> 0
												cPassag := aPassenger[nPos][2]
											EndIf
	
											If Empty(cIntID)
												cSegID := IIF(oModelG40:Length() == 1 .And. !lAddG40, StrZero(1, TamSx3("G40_ID")[1]), StrZero(Val(oModelG40:GetValue("G40_ID", oModelG40:Length())) + 1, TamSx3("G40_ID")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSegID), "G40")
											EndIf
	
											If !lDelete .And. !oModelG40:SeekLine({{'G40_ID', cSegID}})
												If !Empty(oModelG40:GetValue('G40_CIDPRI'))
													nLine := oModelG40:AddLine()
													oModelG40:GoLine(nLine)
												EndIf
											EndIf
											
											If !lDelete
												T034SetStc({{"__cPassag",cPassag}})
												aAdd(aDados, {'G40_ID'	  , cSegID , cSegment + '/SegmentInternalId'})
												aAdd(aDados, {'G40_IDINTE',		   , cSegment + '/IntegrationID'})
												aAdd(aDados, {'G40_CODPAX', cPassag, cSegment + '/PassengerCode'})
												aAdd(aDados, {'G40_NMTOUR',		   , cSegment + '/TourName'})
												aAdd(aDados, {'G40_DSTOUR',		   , cSegment + '/TourDescription'})
												aAdd(aDados, {'G40_CIDPRI', cCidPri, cSegment + '/MainCityInternalId'})
												aAdd(aDados, {'G40_CIDEMB', cCidEmb, cSegment + '/DepartureCityInternalId'})
												aAdd(aDados, {'G40_LOCEMB',		   , cSegment + '/DepartureLocation'})
												aAdd(aDados, {'G40_LOCDES',		   , cSegment + '/ArrivalLocation'})
												aAdd(aDados, {'G40_DTINI' ,		   , cSegment + '/InitialDate'})
												aAdd(aDados, {'G40_DTFIM' ,		   , cSegment + '/FinalDate'})
												aAdd(aDados, {'G40_HRINI' ,		   , cSegment + '/InitialTime'})
												aAdd(aDados, {'G40_HRFIM' ,		   , cSegment + '/FinalTime'})
												aAdd(aDados, {'G40_DTCANC',		   , cSegment + '/CancellationDeadline'})
												aAdd(aDados, {'G40_OBS'	  ,		   , cSegment + '/Observation'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G40'})
											EndIf
											
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG40, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
	
											If lRet 
												If !oModelG40:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G40
												EndIf
												lAddG40 := .T.
												aAdd(aIntID, {'SegmentTour', cExtID, cIntID, 'G40', 'G40_ID'})
												aAdd(aDetalhe, {'G40', cIdItem + cNumSeq + cSegID})
											Else
												Exit		// Saindo do laço G40
											EndIf
										Next nA
	
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
	
									// Segmento SEGURO ----------------------------------------------------------------------------------------------------------------------
									If (nCont2 := oXml:xPathChildCount(cListReserv + '/ListOfSegmentInsurance')) > 0
										For nA := 1 To nCont2
											aDados	  := {}
											cSegment  := cListReserv + '/ListOfSegmentInsurance/SegmentInsurance[' + cValToChar(nA) + ']'
											cExtID	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/SegmentInternalId'))
											cPassagId := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerInternalId'))
											cExtCdPax := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerCode'))
											cPlSeg	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/InsurancePlanInternalId'))
											
											// validação de duplicidade chave externa - Seg SEGURO
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G41'), 'G41', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G41', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G41_ITENS", "G41_ID", "G41_ITENS", "G41_ID", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G41
											EndIf 
											
											cIntID	:= ""
											cSegID	:= PadR(AllTrim(TURXRetId(cMarca, "G41", "G41_ID"	 , cExtID	, @cIntID, 6)), TamSx3("G41_ID")[1])
											cPlSeg	:= PadR(AllTrim(TURXRetId(cMarca, "G4G", "G4G_CODIGO", cPlSeg	, Nil	 , 3)), TamSx3("G41_PLSEGU")[1])
											cPassag	:= PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cPassagId, Nil	 , 6)), TamSx3("G3S_CODPAX")[1])
											
											If Empty(cPassag) .And. (nPos := aScan(aPassenger, {|X| AllTrim(X[1]) == cExtCdPax})) <> 0
												cPassag := aPassenger[nPos][2]
											EndIf
											
											If Empty(cIntID)
												cSegID := IIF(oModelG41:Length() == 1 .And. !lAddG41, StrZero(1, TamSx3("G41_ID")[1]), StrZero(Val(oModelG41:GetValue("G41_ID", oModelG41:Length())) + 1, TamSx3("G41_ID")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSegID), "G41")
											EndIf
	
											If !lDelete .And. !oModelG41:SeekLine({{'G41_ID', cSegID}})
												If !Empty(oModelG41:GetValue('G41_DTINI'))
													nLine := oModelG41:AddLine()
													oModelG41:GoLine(nLine)
												EndIf
											EndIf
											
											If !lDelete
												T034SetStc({{"__cPassag", cPassag}})
												aAdd(aDados, {'G41_ID'	  , cSegID , cSegment + '/SegmentInternalId'})
												aAdd(aDados, {'G41_IDINTE',		   , cSegment + '/IntegrationID'})
												aAdd(aDados, {'G41_CODPAX', cPassag, cSegment + '/PassengerCode'})
												aAdd(aDados, {'G41_PLSEGU', cPlSeg , cSegment + '/InsurancePlanInternalId'})
												aAdd(aDados, {'G41_APOLIC',		   , cSegment + '/BeneficiaryName'})
												aAdd(aDados, {'G41_ENDBEN',		   , cSegment + '/BeneficiaryAddress'})
												aAdd(aDados, {'G41_TELBEN',		   , cSegment + '/BeneficiaryPhone'})
												aAdd(aDados, {'G41_NUMAPO',		   , cSegment + '/PolicyNumber'})
												aAdd(aDados, {'G41_DTINI' ,		   , cSegment + '/InitialDate'})
												aAdd(aDados, {'G41_DTFIM' ,		   , cSegment + '/FinalDate'})
												aAdd(aDados, {'G41_OBS'	  ,		   , cSegment + '/Observation'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G41'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG41, aDados[n1][1], aDados[n1][2])
													lRet :=  .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
	
											If lRet 
												If !oModelG41:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G41
												EndIf
												lAddG41 := .T.
												aAdd(aIntID, {'SegmentInsurance', cExtID, cIntID, 'G41', 'G41_ID'})
												aAdd(aDetalhe, {'G41', cIdItem + cNumSeq + cSegID})
											Else
												Exit		// Saindo do laço G41
											EndIf
										Next nA
	
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
										
									// Segmento VISTO ----------------------------------------------------------------------------------------------------------------------
									If (nCont2 := oXml:xPathChildCount(cListReserv + '/ListOfSegmentVisa')) > 0
										For nA := 1 To nCont2
											aDados	  := {}
											cSegment  := cListReserv + '/ListOfSegmentVisa/SegmentVisa[' + cValToChar(nA) + ']'
											cExtID	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/SegmentInternalId'))
											cIdSegInt := AllTrim(oXml:XPathGetNodeValue(cSegment + '/IntegrationID'))
											cPassagId := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerInternalId'))
											cExtCdPax := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerCode'))
											cTpVisto  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/VisaTypeInternalId'))
											
											// validação de duplicidade chave externa - Seg VISTO
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G42'), 'G42', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G42', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G42_ITENS", "G42_ID", "G42_ITENS", "G42_ID", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G42
											EndIf 
											
											cIntID	 := ""
											cSegID	 := PadR(AllTrim(TURXRetId(cMarca, "G42", "G42_ID"	  , cExtID	 , @cIntID, 6)), TamSx3("G42_ID")[1])
											cTpVisto := PadR(AllTrim(TURXRetId(cMarca, "G4F", "G4F_CODIGO", cTpVisto , Nil	  , 3)), TamSx3("G42_TPVIST")[1])
											cPassag	 := PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cPassagId, Nil	  , 6)), TamSx3("G3S_CODPAX")[1])
	
											If Empty(cPassag) .And.	(nPos := aScan(aPassenger, {|X| AllTrim(X[1]) == cExtCdPax})) <> 0
												cPassag := aPassenger[nPos][2]
											EndIf
											
											If Empty(cIntID)
												cSegID := IIF(oModelG42:Length() == 1 .And. !lAddG42, StrZero(1, TamSx3("G42_ID")[1]), StrZero(Val(oModelG42:GetValue("G42_ID", oModelG42:Length())) + 1, TamSx3("G42_ID")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSegID), "G42")
											EndIf
	
											If !lDelete .And. !oModelG42:SeekLine({{'G42_ID', cSegID}})
												If !Empty(oModelG42:GetValue('G42_PAIS'))
													nLine := oModelG42:AddLine()
													oModelG42:GoLine(nLine)
												EndIf
											EndIf 
											
											If !lDelete
												T034SetStc({{"__cPassag", cPassag}})
												aAdd(aDados, {'G42_ID'	  , cSegID	 , cSegment + '/SegmentInternalId'})
												aAdd(aDados, {'G42_IDINTE', cIdSegInt, cSegment + '/IntegrationID'})
												aAdd(aDados, {'G42_CODPAX', cPassag	 , cSegment + '/PassengerCode'})
												aAdd(aDados, {'G42_PAIS'  ,			 , cSegment + '/CountryCode'})
												aAdd(aDados, {'G42_TPVIST', cTpVisto , cSegment + '/VisaTypeInternalId'})
												aAdd(aDados, {'G42_OBS'	  ,			 , cSegment + '/Observation'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G42'})
											EndIf
	
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml,aDados[n1][3],oModelG42,aDados[n1][1],aDados[n1][2] )
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
											
											If lRet 
												If !oModelG42:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G42
												EndIf
												lAddG42 := .T.
												aAdd(aIntID, {'SegmentVisa', cExtID, cIntID, 'G42', 'G42_ID'})
												aAdd(aDetalhe, {'G42', cIdItem + cNumSeq + cSegID})
											Else
												Exit		// Saindo do laço G42
											EndIf
										Next nA
	
										If !lRet
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
										
									// Segmento OUTROS ----------------------------------------------------------------------------------------------------------------------
									If (nCont2 := oXml:xPathChildCount(cListReserv + '/ListOfOtherSegment')) > 0
										For nA := 1 To nCont2
											aDados	  := {}
											cSegment  := cListReserv + '/ListOfOtherSegment/OtherSegment[' + cValToChar(nA) + ']'
											cExtID	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/SegmentInternalId'))
											cPassagId := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerInternalId'))
											cExtCdPax := AllTrim(oXml:XPathGetNodeValue(cSegment + '/PassengerCode'))
											cCidEmb	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/DepartureCityInternalId'))
											cCidDes	  := AllTrim(oXml:XPathGetNodeValue(cSegment + '/ArrivalCityInternalId'))
											
											// validação de duplicidade chave externa - Seg OUTROS
											If nOpc == MODEL_OPERATION_INSERT .And. (aVldChvExt := TXVldChvExt(RetSqlName('G43'), 'G43', cExtID))[1]
												lRet     := .F.
												cMsgErro := I18N(STR0016, {'G43', aVldChvExt[2]})	// "A chave externa enviada para a endidade #1 já foi utilizada para integração do RV #2"
												oModel:SetErrorMessage("G43_ITENS", "G43_ID", "G43_ITENS", "G43_ID", "TI034ChvDpl", cMsgErro, STR0017, cExtID)		// "Reenvie o XML enviando um InternalId que ainda não foi utilizado para a entidade informada."
												Exit		// Saindo do laço G43
											EndIf 
											
											cIntID	:= ""
											cSegID	:= PadR(AllTrim(TURXRetId(cMarca, "G43", "G43_ID"	 , cExtID	, @cIntID, 6)), TamSx3("G43_ID")[1])
											cCidEmb	:= PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidEmb	, Nil	 , 3)), TamSx3("G43_CIDEMB")[1])
											cCidDes	:= PadR(AllTrim(TURXRetId(cMarca, "G5S", "G5S_CODIGO", cCidDes	, Nil	 , 3)), TamSx3("G43_CIDDES")[1])
											cPassag	:= PadR(AllTrim(TURXRetId(cMarca, "G3S", "G3S_CODPAX", cPassagId, Nil	 , 6)), TamSx3("G3S_CODPAX")[1])
	
											If Empty(cPassag) .And. (nPos := aScan(aPassenger, {|X| AllTrim(X[1]) == cExtCdPax})) <> 0
												cPassag := aPassenger[nPos][2]
											EndIf
											
											If Empty(cIntID)
												cSegID := IIF(oModelG43:Length() == 1 .And. !lAddG43, StrZero(1, TamSx3("G43_ID")[1]), StrZero(Val(oModelG43:GetValue("G43_ID", oModelG43:Length())) + 1, TamSx3("G43_ID")[1]))
												cIntID := TURXMakeId(AllTrim(cNumID) + "|" + AllTrim(cIdItem) + "|" + AllTrim(cNumSeq) + "|" + AllTrim(cSegID), "G43")
											EndIf
	
											If !lDelete .And. !oModelG43:SeekLine({{'G43_ID', cSegID}})
												If !Empty(oModelG43:GetValue('G43_DTINI'))
													nLine := oModelG43:AddLine()
													oModelG43:GoLine(nLine)
												EndIf
											EndIf 
	
											If !lDelete
												T034SetStc({{"__cPassag", cPassag}})
												aAdd(aDados, {'G43_ID'	  , cSegID , cSegment + '/SegmentInternalId'})
												aAdd(aDados, {'G43_IDINTE',		   , cSegment + '/IntegrationID'})
												aAdd(aDados, {'G43_CODPAX', cPassag, cSegment + '/PassengerCode'})
												aAdd(aDados, {'G43_DSSERV',		   , cSegment + '/ServiceDescription'})
												aAdd(aDados, {'G43_CIDEMB', cCidEmb, cSegment + '/DepartureCityInternalId'})
												aAdd(aDados, {'G43_CIDDES', cCidDes, cSegment + '/ArrivalCityInternalId'})
												aAdd(aDados, {'G43_DTINI' ,		   , cSegment + '/InitialDate'})
												aAdd(aDados, {'G43_DTFIM' ,		   , cSegment + '/FinalDate'})
												aAdd(aDados, {'G43_OBS'	  ,		   , cSegment + '/Observation'})
											EndIf
	
											If ExistBlock("TURI034EXT")
												cExtID := ExecBlock("TURI034EXT", .F., .F., {cIntID, cExtID, 'G43'})
											EndIf
											
											For n1 := 1 to Len(aDados)
												If !TxGetNdXml(oXml, aDados[n1][3], oModelG43, aDados[n1][1], aDados[n1][2])
													lRet := .F.
													Exit
												EndIf
											Next n1
											TxDestroy(aDados)
											
											If lRet 
												If !oModelG43:VldLineData()
													lRet := .F.
													Exit		// Saindo do laço G43
												EndIf
												lAddG43 := .T.
												aAdd(aIntID, {'OtherSegment', cExtID, cIntID, 'G43', 'G43_ID'})
												aAdd(aDetalhe, {'G43', cIdItem + cNumSeq + cSegID})
											Else
												Exit		// Saindo do laço G43
											EndIf
										Next nA
	
										If !lRet 
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
	
									// Tarifas ----------------------------------------------------------------------------------------------------------------------
									If oXml:XPathHasNode(cListReserv + "/Fares")
										aDados := {}
										cMoeda := AllTrim(oXml:XPathGetNodeValue(cListReserv + '/Fares/TravelCurrencyInternalId'))
										cMoeda := PadR(AllTrim(TURXRetId(cMarca, "G5T", "G5T_CODIGO", cMoeda, Nil, 3)), TamSx3("G44_MOEDFO")[1])
	
										If !lDelete
											aAdd(aDados, {'G44_MOEDFO', cMoeda, cListReserv + '/Fares/TravelCurrencyInternalId'})
											aAdd(aDados, {'G44_BASTAR',       , cListReserv + '/Fares/BaseFare'})
											aAdd(aDados, {'G44_TPTAR' ,       , cListReserv + '/Fares/FareType'})
											aAdd(aDados, {'G44_TARBAS',       , cListReserv + '/Fares/BaseFareValue'})
											aAdd(aDados, {'G44_TXCAMB',       , cListReserv + '/Fares/Exchange'})
											aAdd(aDados, {'G44_MENOR' ,       , cListReserv + '/Fares/MinorFareValue'})
											aAdd(aDados, {'G44_MAIOR' ,       , cListReserv + '/Fares/MaxFareValue'})
											aAdd(aDados, {'G44_CHEIA' ,       , cListReserv + '/Fares/FullFareValue'})
											aAdd(aDados, {'G44_PUBLIC',       , cListReserv + '/Fares/NoDealFareValue'})
											aAdd(aDados, {'G44_OPORTU',       , cListReserv + '/Fares/OpportunityFareValue'})
											aAdd(aDados, {'G44_EARLY' ,       , cListReserv + '/Fares/EarlyCheckinFareValue'})
											aAdd(aDados, {'G44_LATE'  ,       , cListReserv + '/Fares/LateCheckoutFareValue'})
											aAdd(aDados, {'G44_PLALIM',       , cListReserv + '/Fares/FoodServiceFareValue'})
										EndIf
	
										For n1 := 1 to Len(aDados)
											If oModelG3Q:GetValue("G3Q_TPSEG") != "2" .And. (aDados[n1][1] == "G44_EARLY" .Or. aDados[n1][1] == "G44_LATE") 
												Loop
											EndIf
											If !TxGetNdXml(oXml,aDados[n1][3], oModelG44, aDados[n1][1], aDados[n1][2])
												lRet := .F.
												Exit
											EndIf
										Next n1
										TxDestroy(aDados)
	
										If lRet 
											If !oModelG44:VldLineData()
												lRet := .F.
												Exit		// Saindo do laço G3Q
											EndIf
										Else
											Exit		// Saindo do laço G3Q
										EndIf
									EndIf
									
									If lRet 
										If !oModelG3R:VldLineData()
											lRet := .F.
											Exit		// Saindo do laço G3Q
										EndIf
									Else
										Exit
									EndIf
								EndIf

								If lRet 
									If !oModelG3Q:VldLineData()
										lRet := .F.
										Exit		// Saindo do laço G3Q
									EndIf
									lAddG3Q := .T.
								Else
									Exit		
								EndIf
							Else
								Exit		// Saindo do laço G3Q
							EndIf
						Next nX
					EndIf
					
					If lRet
						cNumID := AllTrim(FwFldGet("G3P_NUMID"))
						If lDelete
							T034DelXXF(lDelete)
						Else
							Ti034SetDel(oModel)
							For nX := 1	 To oModelG3Q:Length()
								oModelG3Q:GoLine(nX)
								cIdItem := AllTrim(FwFldGet('G3Q_IDITEM'))
								cNumSeq	:= AllTrim(FwFldGet('G3Q_NUMSEQ'))
								
								If oModelG3Q:IsEmpty() .And. oModelG3Q:Length() > 0 .And. !lDelete
									oModelG3Q:DeleteLine()
								ElseIf !lDelete .And. aScan(aDetalhe, {|X| AllTrim(X[1]) == 'G3Q' .And. X[2] == FwFldGet('G3Q_IDITEM') + FwFldGet('G3Q_NUMSEQ')}) == 0
									Loop
								EndIf
	
								For nT := 1 To oModelG4D:Length()
									oModelG4D:GoLine(nT)
									cSeqID := oModelG4D:GetValue('G4D_SEQ')
									If !lDelete .And. aScan(aDetalhe, {|X| AllTrim(X[1]) == 'G4D' .And. X[2] == cIdItem + cNumSeq + cSeqID}) == 0
										oModelG4D:DeleteLine()
										cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + cSeqID, "G4D")
										CFGA070MNT(Nil, "G4D", "G4D_SEQ", Nil, cIntID, .T.)
									EndIf
								Next
															
								For nI := 1 To oModelG4A:Length()
									oModelG4A:GoLine(nI)
									cLjEntit := oModelG4A:GetValue('G4A_LOJA')
									cTpEnt	 := oModelG4A:GetValue('G4A_TPENT')
									cItemEnt := oModelG4A:GetValue('G4A_ITEM')
									If !lDelete .And. aScan(aDetalhe, {|X| AllTrim(X[1]) == 'G4A' .And. X[2] == cIdItem + cNumSeq + cLjEntit + cTpEnt + cItemEnt}) == 0
										oModelG4A:DeleteLine()
									EndIf
								Next
								
								For nI := 1 To oModelG3R:Length()
									oModelG3R:GoLine(nI)
									For nT := 1 To oModelG45:Length()
										oModelG45:GoLine(nT)
										oModelG45:SetNoDeleteLine(.F.)
										cSeqID := FwFldGet('G45_SEQ')
										If !lDelete .And. aScan(aDetalhe, {|X| AllTrim(X[1]) == 'G45' .And. X[2] == cIdItem + cNumSeq + cSeqID}) == 0
											oModelG45:DeleteLine()
											cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + cSeqID, "G45")
											CFGA070MNT(Nil, "G45", "G45_SEQ", Nil, cIntID, .T.)
										EndIf
									Next nT
									
									For nT := 1 To oModelG46:Length()
										oModelG46:GoLine(nT)
										cSeqID := FwFldGet('G46_SEQTAX')
										If !lDelete .And. aScan(aDetalhe, {|X| AllTrim(X[1]) == 'G46' .And. X[2] == cIdItem + cNumSeq + cSeqID}) == 0
											oModelG46:DeleteLine()
											cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + cSeqID, "G46")
											CFGA070MNT(Nil, "G46", "G46_SEQTAX", Nil, cIntID, .T.)
											oModelG3R:SetValue("G3R_TAXA", oModelG3R:GetValue("G3R_TAXA") - oModelG46:GetValue("G46_VLTAXA"))
										EndIf
									Next nT
									
									For nT := 1 To oModelG47:Length()
										oModelG47:GoLine(nT)
										cSeqID := FwFldGet('G47_SEQ')
										If !lDelete .And. aScan(aDetalhe, {|X| AllTrim(X[1])== 'G47' .And. X[2] == cIdItem + cNumSeq + cSeqID}) == 0
											oModelG47:DeleteLine()
											cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + cSeqID, 'G47')
											CFGA070MNT(Nil, 'G47', "G47_SEQ", Nil, cIntID, .T.)
											oModelG3R:SetValue("G3R_EXTRAS", oModelG3R:GetValue("G3R_EXTRAS") - oModelG47:GetValue("G47_TOTAL"))
										EndIf
									Next nT
									 
									For nT := 1 To oModelG49:Length()
										oModelG49:GoLine(nT)
										cSeqID := FwFldGet('G49_SEQ')
										If !lDelete
											If aScan(aDetalhe, {|X| AllTrim(X[1]) == 'G49' .And. X[2] == cIdItem + cNumSeq + cSeqID}) == 0
												oModelG49:DeleteLine()
												cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + cSeqID, 'G49')
												CFGA070MNT(Nil, 'G49', "G49_SEQ", Nil, cIntID, .T.)
												oModelG3R:SetValue("G3R_VLRIMP", oModelG3R:GetValue("G3R_VLRIMP") - oModelG49:GetValue("G49_VALOR"))
											EndIf
										EndIf
									Next nT
									
									For nT := 1 To oModelG3S:Length()
										oModelG3S:GoLine(nT)
										cCodPax := FwFldGet('G3S_CODPAX')
										
										If !lDelete .And. aScan(aDetalhe, {|X| AllTrim(X[1]) == 'G3S' .And. X[2] == cIdItem + cNumSeq + cCodPax}) == 0
											oModelG3S:DeleteLine()
											cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + cCodPax, "G3S")
											CFGA070MNT(Nil, "G3S", "G3S_CODPAX", Nil, cIntID, .T.)
										EndIf
									Next nT
									
									//Lista de Segmentos
									For nCont := 1 To Len(aMldSeg)
										cModel := aMldSeg[nCont] + "_ITENS"
										For nT := 1 to oModel:GetModel(cModel):Length()
											oModel:GetModel(cModel):GoLine(nT)
											cSegID := oModel:GetModel(cModel):GetValue(aMldSeg[nCont] + "_ID")
											If !lDelete .And. aScan(aDetalhe, {|X| AllTrim(X[1]) == aMldSeg[nCont] .And. X[2] == cIdItem + cNumSeq + cSegID}) == 0
												oModel:GetModel(cModel):DeleteLine()
												cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + cSegID, aMldSeg[nCont])
												CFGA070MNT(Nil, aMldSeg[nCont], aMldSeg[nCont] + '_ID', Nil, cIntID, .T.)
											EndIf
										Next nT
									Next nCont
								Next nI
							Next nX
						EndIf
					
						TxTraceLog( , cThreadLog, cTimeIni, cTimeMid, "Antes Acordo")
						cTimeMid := Time()
					
						TURA34Next()

						TxTraceLog( , cThreadLog, cTimeIni, cTimeMid, "Pós Acordo")
						cTimeMid := Time()

						If InTransaction()
							DisarmTransaction()
						EndIf	
				
						If !oModel:VldData() .OR. oModel:HasErrorMessage() 
							lRet    := .F.
							cXmlRet := Ti034Erro(oModel)
						Else
							If (lRet:= oModel:CommitData())
								cXmlRet := ""
								If !lDelete
									For nX := 1 To Len(aIntID)
										cXmlRet += '<InternalId>'
										cXmlRet +=		'<Name>'+aIntID[nX][1]+'</Name>'
										cXmlRet +=		'<Origin>'+aIntID[nX][2]+'</Origin>'
										cXmlRet +=		'<Destination>'+aIntID[nX][3]+'</Destination>'
										cXmlRet += '</InternalId>'
										CFGA070MNT(cMarca, aIntID[nX][4], aIntID[nX][5], aIntID[nX][2], aIntID[nX][3], lDelete)
									Next nX
									
									If !Empty(cXmlRet)
										cXmlRet := "<ListOfInternalId>" + cXmlRet + "</ListOfInternalId>"
										cXmlRet += "<ThreadId>" + cThreadLog + "</ThreadId>"
									EndIf
								EndIf
							EndIf
							TxTraceLog( , cThreadLog, cTimeIni, cTimeMid, "Pós Commit")
						EndIf
					EndIf
		
					If !lRet 
						cXmlRet := Ti034Erro(oModel, cMsgErro) 
					EndIf
					oModel:Deactivate()
					oModel:Destroy()						
				EndIf
				
			EndIf 

			TxDestroy(oXML)
			TxDestroy(aDetalhe)
			TxDestroy(aIntID)
		EndIf
	EndIf
EndIf

__cUserId := cCodOldUsr
TxTraceLog( , cThreadLog, cTimeIni)

Return {lRet, cXMLRet, "SaleRegistry"}

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} Ti034SetDel

Função utilizada para habilitar a exclusão de linhas nos submodelos 

@type 		Function
@author 	Jacomo Lisa
@since 		16/05/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Static Function Ti034SetDel(oModel)

oModel:GetModel('G3Q_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G3R_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G3S_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G3T_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G3U_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G3V_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G3W_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G3X_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G3Y_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G3Z_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G40_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G41_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G42_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G43_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G44_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G45_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G46_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G47_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G48A_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G48B_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G49_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G4A_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G4CA_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G4CB_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G4D_ITENS'):SetNoDeleteLine(.F.)
oModel:GetModel('G4E_ITENS'):SetNoDeleteLine(.F.)

Return .T.

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} Ti034Erro

Função utilizada para habilitar a exclusão de linhas nos submodelos 

@type 		Function
@author 	Jacomo Lisa
@since 		16/05/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Static Function Ti034Erro(oModel, cMsgErro)

Local cErro := ""
Local aErro := {}
Local aArea := GetArea()
Default oModel := Nil

If !Empty(cMsgErro)
	cErro := chr(13) + chr(10) + STR0002 + chr(13) + chr(10)	// "A integração não foi bem sucedida."
	cErro += STR0003// "Foi retornado o seguinte erro: "
	cErro += cMsgErro + chr(13) + chr(10)

Elseif ValType(oModel) == "O" .And. !Empty(aErro := oModel:GetErrorMessage())
	cErro := chr(13) + chr(10) + STR0002 + chr(13) + chr(10)	// "A integração não foi bem sucedida."
	cErro += STR0003// "Foi retornado o seguinte erro: "
	If !Empty(_NoTags(AllTrim(aErro[4])))
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek(PadR(aErro[4],10)))
			cErro += AllTrim(X3TITULO()) + '(' + _NoTags(AllTrim(aErro[4])) + ')' + chr(13) + chr(10)
		EndIf
	EndIf

	cErro += _NoTags(AllTrim(aErro[5]) + '-' + AllTrim(aErro[6])) + chr(13) + chr(10)

	If !Empty(_NoTags(AllTrim(aErro[8])))
		cErro += STR0009 + _NoTags(AllTrim(aErro[8])) + chr(13) + chr(10) //' Referencia:'
	EndIf

	If !Empty(AllTrim(StrTran(oModel:GetErrorMessage()[7], chr(13) + chr(10), '')))
		cErro += STR0005 + _NoTags(AllTrim(aErro[7]))	//'Solução - '
	EndIf
	aSize(aErro, 0)
	aErro := Nil
Else
	cErro := STR0002// "A integração não foi bem sucedida."
	cErro += STR0004//'Verifique os dados enviados'
EndIf

RestArea(aArea)

Return cErro

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} T034DelXXF

Função utilizada para limpar o De/Para na exclusão de um RV   

@type 		Function
@author 	Jacomo Lisa
@since 		16/05/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Function T034DelXXF(lDelete)

Local oModel	:= FwModelActive()
Local oModelG3Q	:= oModel:GetModel('G3Q_ITENS')
Local oModelG3R	:= oModel:GetModel('G3R_ITENS')
Local oModelG45	:= oModel:GetModel('G45_ITENS')
Local oModelG46	:= oModel:GetModel('G46_ITENS')
Local oModelG47	:= oModel:GetModel('G47_ITENS')
Local oModelG49	:= oModel:GetModel('G49_ITENS')
Local oModelG3S	:= oModel:GetModel('G3S_ITENS')
Local oModelG4D	:= oModel:GetModel('G4D_ITENS')
Local aMldSeg	:= {'G3T', 'G3U', 'G3V', 'G3W', 'G3X', 'G3Y', 'G3Z', 'G40', 'G41', 'G42', 'G43'}
Local cNumID    := AllTrim(FwFldGet('G3P_NUMID'))
Local nT        := 0
Local nX        := 0
Local nI        := 0
Local nCont     := 0 

Ti034SetDel(oModel)

For nX := 1	 To oModelG3Q:Length()
	oModelG3Q:GoLine(nX)
	cIdItem	:= AllTrim(FwFldGet('G3Q_IDITEM'))
	cNumSeq	:= AllTrim(FwFldGet('G3Q_NUMSEQ'))
	
	For nT := 1 to oModelG4D:Length()
		oModelG4D:GoLine(nT)
		If lDelete .Or. oModelG4D:IsDeleted(nT)
			cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + oModelG4D:GetValue('G4D_SEQ'), "G4D")
			CFGA070MNT(Nil, "G4D", "G4D_SEQ", , cIntID, .T.)
		EndIf
	Next nT
	
	For nI := 1 To oModelG3R:Length()
		oModelG3R:GoLine(nI)
		For nT := 1 to oModelG45:Length()
			oModelG45:GoLine(nI)
			If lDelete .Or. oModelG45:IsDeleted()
				cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + oModelG45:GetValue('G45_SEQ'), "G45")
				CFGA070MNT(Nil, "G45", "G45_SEQ", , cIntID, .T.)
			EndIf
		Next nT

		For nT := 1 to oModelG46:Length()
			oModelG46:GoLine(nT)
			If lDelete .Or. oModelG46:IsDeleted()
				cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + oModelG46:GetValue('G46_SEQTAX'), "G46")
				CFGA070MNT(Nil, "G46", "G46_SEQTAX", , cIntID, .T.)
			EndIf
		Next nT

		For nT := 1 to oModelG47:Length()
			oModelG47:GoLine(nT)
			If lDelete .Or. oModelG47:IsDeleted()
				cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + oModelG47:GetValue('G47_SEQ'), 'G47')
				CFGA070MNT(Nil, 'G47', "G47_SEQ", , cIntID, .T.)
			EndIf
		Next nT

		For nT := 1 to oModelG49:Length()
			oModelG49:GoLine(nT)
			If lDelete .Or. oModelG49:IsDeleted()
				cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + oModelG49:GetValue('G49_SEQ'), 'G49')
				CFGA070MNT(Nil, 'G49', "G49_SEQ", , cIntID, .T.)
			EndIf
		Next nT

		For nT := 1 to oModelG3S:Length()
			oModelG3S:GoLine(nT)
			If lDelete .Or. oModelG3S:IsDeleted()
				cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + oModelG3S:GetValue('G3S_CODPAX'), "G3S")
				CFGA070MNT(Nil, "G3S", "G3S_CODPAX", , cIntID, .T.)
			EndIf
		Next nT

		//Lista de Segmentos
		For nCont := 1 to Len(aMldSeg)
			cModel := aMldSeg[nCont]+"_ITENS"
			For nT := 1 to oModel:GetModel(cModel):Length()
				oModel:GetModel(cModel):GoLine(nT)
				cSegID := oModel:GetModel(cModel):GetValue(aMldSeg[nCont] + "_ID")
				If lDelete .Or. oModel:GetModel(cModel):IsDeleted()
					cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq + "|" + cSegID, aMldSeg[nCont])
					CFGA070MNT(Nil, aMldSeg[nCont], aMldSeg[nCont] + '_ID', , cIntID, .T.)
				EndIf
			Next nT
		Next nCont
	Next nI

	If lDelete
		cIntID := TURXMakeId(cNumID + "|" + cIdItem + "|" + cNumSeq, "G3Q")
		CFGA070MNT(Nil, 'G3Q','G3Q_IDITEM', , cIntID, .T.)
	EndIf
Next nX

If lDelete
	CFGA070MNT(Nil, 'G3P','G3P_NUMID', , TURXMakeId(cNumID, "G3P"), .T.)
EndIf

Return Nil

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} TxSetNode()

Função utilizada para validar e carregar os valores no campo.

@type 		Function
@author 	Jacomo Lisa
@since 		16/05/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Function TI034Ajust(oModel, cCampo)

Local lRet     := .T.
Default cCampo := ""

Do Case
	//G3Q ----------------------
	Case cCampo == "G3Q_CLIENT"
		If !Empty(oModel:GetValue('G3Q_LOJA'))
			lRet := oModel:LoadValue('G3Q_LOJA', "")
		EndIf

	//G3R ----------------------	
	Case cCampo == "G3R_FORNEC"
		If !Empty(oModel:GetValue('G3R_LOJA'))
			lRet := oModel:LoadValue('G3R_LOJA', "")
		EndIf
	Case cCampo == "G3R_FORREP"
		If !Empty(oModel:GetValue('G3R_LOJREP'))
			lRet := oModel:LoadValue('G3R_LOJREP', "")
		EndIf

	//G3T ----------------------	
	Case cCampo == "G3T_CODFOR"
		If !Empty(oModel:GetValue('G3T_LOJAF'))
			lRet := oModel:LoadValue('G3T_LOJAF', "")
		EndIf
	Case cCampo == "G3T_DTSAID"
		If !Empty(oModel:GetValue('G3T_DTCHEG'))
			lRet := oModel:LoadValue('G3T_DTCHEG', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3T_HRINI'))
			lRet := oModel:LoadValue('G3T_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3T_HRFIM'))
			lRet := oModel:LoadValue('G3T_HRFIM', "")
		EndIf
	Case cCampo == "G3T_HRINI"
		If !Empty(oModel:GetValue('G3T_HRFIM'))
			lRet := oModel:LoadValue('G3T_HRFIM', "")
		EndIf

	//G3U ----------------------	
	Case cCampo == "G3U_DTINI"
		If !Empty(oModel:GetValue('G3U_DTFIM'))
			lRet := oModel:LoadValue('G3U_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3U_HRINI'))
			lRet := oModel:LoadValue('G3U_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3U_HRFIM'))
			lRet := oModel:LoadValue('G3U_HRFIM', "")
		EndIf
	Case cCampo == "G3U_HRINI"
		If !Empty(oModel:GetValue('G3U_HRFIM'))
			lRet := oModel:LoadValue('G3U_HRFIM', "")
		EndIf

	//G3V ----------------------	
	Case cCampo == "G3V_DTINI"
		If !Empty(oModel:GetValue('G3V_DTFIM'))
			lRet := oModel:LoadValue('G3V_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3V_HRINI'))
			lRet := oModel:LoadValue('G3V_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3V_HRFIM'))
			lRet := oModel:LoadValue('G3V_HRFIM', "")
		EndIf
	Case cCampo == "G3V_HRINI"
		If !Empty(oModel:GetValue('G3V_HRFIM'))
			lRet := oModel:LoadValue('G3V_HRFIM', "")
		EndIf

	//G3W ----------------------	
	Case cCampo == "G3W_LINHA"
		If !Empty(oModel:GetValue('G3W_TRECHO'))
			lRet := oModel:LoadValue('G3W_TRECHO', "")
		EndIf
	Case cCampo == "G3W_DTINI"
		If !Empty(oModel:GetValue('G3W_DTFIM'))
			lRet := oModel:LoadValue('G3W_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3W_HRINI'))
			lRet := oModel:LoadValue('G3W_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3W_HRFIM'))
			lRet := oModel:LoadValue('G3W_HRFIM', "")
		EndIf
	Case cCampo == "G3W_HRINI"
		If !Empty(oModel:GetValue('G3W_HRFIM'))
			lRet := oModel:LoadValue('G3W_HRFIM', "")
		EndIf

	//G3X ----------------------	
	Case cCampo == "G3X_DTINI"
		If !Empty(oModel:GetValue('G3X_DTFIM'))
			lRet := oModel:LoadValue('G3X_DTFIM', CtoD(""))
		EndIf

	//G3Y ----------------------	
	Case cCampo == "G3Y_DTINI"
		If !Empty(oModel:GetValue('G3Y_DTFIM'))
			lRet := oModel:LoadValue('G3Y_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3Y_HRINI'))
			lRet := oModel:LoadValue('G3Y_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3Y_HRFIM'))
			lRet := oModel:LoadValue('G3Y_HRFIM', "")
		EndIf
	Case cCampo == "G3Y_HRINI"
		If !Empty(oModel:GetValue('G3Y_HRFIM'))
			lRet := oModel:LoadValue('G3Y_HRFIM', "")
		EndIf

	//G3Z ----------------------	
	Case cCampo == "G3Z_DTINI"
		If !Empty(oModel:GetValue('G3Z_DTFIM'))
			lRet := oModel:LoadValue('G3Z_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3Z_HRINI'))
			lRet := oModel:LoadValue('G3Z_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3Z_HRFIM'))
			lRet := oModel:LoadValue('G3Z_HRFIM', "")
		EndIf
	Case cCampo == "G3Z_HRINI"
		If !Empty(oModel:GetValue('G3Z_HRFIM'))
			lRet := oModel:LoadValue('G3Z_HRFIM', "")
		EndIf

	//G40 ----------------------	
	Case cCampo == "G40_DTINI"
		If !Empty(oModel:GetValue('G40_DTFIM'))
			lRet := oModel:LoadValue('G40_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G40_HRINI'))
			lRet := oModel:LoadValue('G40_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G40_HRFIM'))
			lRet := oModel:LoadValue('G40_HRFIM', "")
		EndIf
	Case cCampo == "G40_HRINI"
		If !Empty(oModel:GetValue('G40_HRFIM'))
			lRet := oModel:LoadValue('G40_HRFIM', "")
		EndIf

	//G41 ----------------------	
	Case cCampo == "G41_DTINI"
		If !Empty(oModel:GetValue('G41_DTFIM'))
			lRet := oModel:LoadValue('G41_DTFIM', CtoD(""))
		EndIf

	//G43 ----------------------	
	Case cCampo == "G43_DTINI"
		If !Empty(oModel:GetValue('G43_DTFIM'))
			lRet := oModel:LoadValue('G43_DTFIM', CtoD(""))
		EndIf
EndCase

Return

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} Ti34aMsgUn(aMsgUnic)

Função utilizada para preencher o Array que contem os dados do  de/para

@type 		Function
@author 	Jacomo Lisa
@since 		28/10/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Function Ti34aMsgUn(aMsgUnic)

aAdd(aMsgUnic, {'SaleRegistry'	   , 'G3P', 'G3P_NUMID'})
aAdd(aMsgUnic, {'SaleItem'		   , 'G3Q', 'G3Q_IDITEM'})
aAdd(aMsgUnic, {'QuotedFares'	   , 'G45', 'G45_SEQ'})
aAdd(aMsgUnic, {'Rates'			   , 'G46', 'G46_SEQTAX'})
aAdd(aMsgUnic, {'Extras'		   , 'G47', 'G47_SEQ'})
aAdd(aMsgUnic, {'Taxes'			   , 'G49', 'G49_SEQ'})
aAdd(aMsgUnic, {'Passenger'		   , 'G3S', 'G3S_CODPAX'})
aAdd(aMsgUnic, {'SegmentAir'	   , 'G3T', 'G3T_ID'})
aAdd(aMsgUnic, {'SegmentHotel'	   , 'G3U', 'G3U_ID'})
aAdd(aMsgUnic, {'SegmentVehicle'   , 'G3V', 'G3V_ID'})
aAdd(aMsgUnic, {'SegmentRoad'	   , 'G3W', 'G3W_ID'})
aAdd(aMsgUnic, {'SegmentTrain'	   , 'G3X', 'G3X_ID'})
aAdd(aMsgUnic, {'SegmentMaritime'  , 'G3Y', 'G3Y_ID'})
aAdd(aMsgUnic, {'SegmentPackage'   , 'G3Z', 'G3Z_ID'})
aAdd(aMsgUnic, {'SegmentTour'	   , 'G40', 'G40_ID'})
aAdd(aMsgUnic, {'SegmentInsurance' , 'G41', 'G41_ID'})
aAdd(aMsgUnic, {'SegmentVisa'	   , 'G42', 'G42_ID'})
aAdd(aMsgUnic, {'OtherSegment'	   , 'G43', 'G43_ID'})
aAdd(aMsgUnic, {'PaymentCreditCard', 'G4D', 'G4D_SEQ'})

Return