#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'TURIDEF.CH'

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI034CAN

Função de integração para cancelamente de um Item de Venda (RV)
Mensagem única do tipo Request - 

@sample	TURI034CAN(cXml, cTypeTrans, cTypeMessage)
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
@since		05/04/2016
@version 	P12
/*/
//-----------------------------------------------------------------------------------------
STATIC FUNCTION IntegDef( cXml, nTypeTrans, cTypeMessage ) 

Local aRet := {}
aRet:= TURI034CAN(cXml, nTypeTrans, cTypeMessage)

Return aRet

Function TURI034CAN(cXml, nTypeTrans, cTypeMessage)

Local oXML		  := tXMLManager():New()
Local cXMLRet	  := "" 
Local cXmlItem	  := ""
Local cMsgUnica	  := "SaleItemCancelation" 
Local cBusiCont	  := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cMarca	  := ""
Local cSegNeg	  := ""
Local cIntID      := ""
Local cRetorno    := ""  	
Local aMessages   := {}
Local aDados      := {}
Local nX	      := 0
Local nY          := 0
Local oModel      := Nil
Local oModelG3Q   := Nil
Local oModelG3R   := Nil
Local oModelG4CA  := Nil
Local lRet		  := .T.
Local lMotivCanc  := .F.
Local lBlind	  := IsBlind()

If Type("Inclui") == "U"
	Private Inclui := .F.
Endif

Do Case
	Case nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
		Do Case
			Case (cTypeMessage == EAI_MESSAGE_WHOIS)		//whois 
				cXmlRet := '1.000'
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS) 
				cMsgUnica  := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessRequest/Operation'))
				cMarca	   := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
				cExtId	   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/SaleRegistryInternalId'))
				cExtItemId := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/SaleItemInternalId'))
				cItemIdCod := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/SaleItemCode'))
				
				// realizando DE/PARA
				cNumId	:= PadR(AllTrim(TURXRetId(cMarca, 'G3P', 'G3P_NUMID' , cExtId	 , @cIntID, 3)), TamSx3('G3P_NUMID' )[1])
				cItemId	:= PadR(AllTrim(TURXRetId(cMarca, 'G3Q', 'G3Q_IDITEM', cExtItemId, Nil    , 4)), TamSx3('G3Q_IDITEM')[1])
				cSeqId	:= PadR(AllTrim(TURXRetId(cMarca, 'G3Q', 'G3Q_IDITEM', cExtItemId, Nil    , 5)), TamSx3('G3Q_NUMSEQ')[1])

				// alteração realizada para cancelamento dos bilhetes/locs duplicados
				If !Empty(cItemIdCod) .And. Len(cItemIdCod) == 4
					cItemId	:= cItemIdCod
					cSeqId	:= "01"
					If !Empty(cExtItemId) .And. Len(cExtItemId) == 2						
						lMotivCanc := .T.
					EndIf
				EndIf			
				
				G3P->(DbSetOrder(1))
				If !Empty(cIntID) .and. G3P->(DbSeek(xFilial("G3P") + cNumID))
					cSegNeg := G3P->G3P_SEGNEG
					T034SetStc({{"lHierarquia",.F.}, {"nSegmento", Val(cSegNeg)}})

					oModel := FwLoadModel("TURA034")
					oModel:SetOperation(MODEL_OPERATION_UPDATE)
					If oModel:Activate()
						oModelG3Q  := oModel:GetModel('G3Q_ITENS')
						oModelG3R  := oModel:GetModel('G3R_ITENS')
						oModelG4CA := oModel:GetModel('G4CA_ITENS')

						If oModel:GetModel("G3Q_ITENS"):SeekLine({{"G3Q_IDITEM", cItemId}, {"G3Q_NUMSEQ", cSeqId}})
							If oModel:GetValue("G3Q_ITENS", "G3Q_STATUS") == "1"
								// validando se o RV pode ser cancelado 
								If T34VldAlt(oModelG3Q:GetValue("G3Q_FILIAL"), oModelG3Q:GetValue("G3Q_NUMID"), oModelG3Q:GetValue("G3Q_IDITEM"), oModelG3Q:GetValue("G3Q_NUMSEQ")) 								
									If lMotivCanc
										Tur034Canc(.F., cExtItemId, @cRetorno)
									Else
										Tur034Canc(.F., , @cRetorno)
									EndIf
								Else
									If !Empty(oModelG3R:GetValue("G3R_CONCIL"))
										aAdd(aMessages, {I18N("Operação não permitida. Esse Item de Venda está conciliado (Cód: #1).", {oModelG3R:GetValue("G3R_CONCIL")}), 1, "IV"})	// "Item de Venda não encontrado"
									EndIf
									
									For nY := 1 To oModelG4CA:Length()
										If !Empty(oModelG4CA:GetValue("G4C_NUMFAT", nY))
											aAdd(aMessages, {I18N("Operação não permitida. Esse Item de Venda está faturado (Cód: #1).", {oModelG4CA:GetValue("G4C_NUMFAT", nY)}), 1, "IV"})	// "Item de Venda não encontrado"
											Exit
										EndIf
									Next nY
								EndIf
							ElseIf oModel:GetValue("G3Q_ITENS", "G3Q_STATUS") == "3"
								aAdd(aMessages, {"Operação não permitida. Esse Item de Venda já está cancelado.", 1, "IV"})	// "Item de Venda não encontrado"
							ElseIf oModel:GetValue("G3Q_ITENS", "G3Q_STATUS") == "2"
								aAdd(aMessages, {I18N("Operação não permitida. Esse Item de Venda não está com status possível de cancelamento (Finalizado)."), 1, "IV"})	
							ElseIf oModel:GetValue("G3Q_ITENS", "G3Q_STATUS") == "4"
								aAdd(aMessages, {I18N("Operação não permitida. Esse Item de Venda não está com status possível de cancelamento (Particionado)."), 1, "IV"})	
							EndIf
						Else
							aAdd(aMessages, {"Operação não permitida. Item de Venda não encontrado.", 1, "IV"})	// "Item de Venda não encontrado"
						Endif
					
					Else
						lRet:=.F.
					Endif
				Else
					aAdd(aMessages, {"Operação não permitida. Registro de Venda não encontrado.", 1, "RV" })	// "Registro de Venda não encontrado"
				Endif
				
				If Len(aMessages) == 0
					If oModel:VldData() .and. oModel:CommitData()
						cXmlRet := '<Status>Success</Status>'
					Else
						aErro   := oModel:GetErrorMessage()
						If lblind
							cErro := MostraErro()
						Else
							cErro := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
							//ConOut("MostraErro: "+ cError)
						EndIf
						cXmlRet := '<Status>Fail</Status>'
						If !Empty(aErro[5]) .or. !Empty(aErro[6]) 
							cXmlRet += '<Observation>' + _NoTags(Alltrim(aErro[5]) + '-' + AllTrim(aErro[6])) + '</Observation>'
						Else
							cXmlRet += '<Observation>' + _NoTags(Alltrim(cErro)) + '</Observation>'
						Endif
						aSize(aErro, 0)
						aErro := Nil
					Endif
				Endif
				If ValType(oModel) == "O"
					oModel:Deactivate()
					oModel:Destroy()	
				Endif
		EndCase
	OtherWise
		aAdd(aMessages, {STR0007, 1, 'PARSE'})	//'A integração não foi bem sucedida.'
		lRet := .F.
EndCase

If Len(aMessages) > 0 
	lRet	:= .F.
	cXmlRet	:= FWEAILOfMessages(aMessages) 
Endif

Return {lRet, cXmlRet, cMsgUnica}