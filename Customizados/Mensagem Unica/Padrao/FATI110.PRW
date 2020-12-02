#INCLUDE "PROTHEUS.CH"                
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TURXEAI.CH'
//==========================================================================================
/*/{Protheus.doc} FATI110

Funcao de integracao do Cadastro de Grupo de Clientes
Mensagem Unica - CustumerGroup

@sample	FATI110(cXml, cTypeTrans, cTypeMessage)

@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				0 - para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				1 - para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				20 - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				21 - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				22 - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				23 - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)

@return		lRet - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.) 
			cXMLRet - String com o XML de retorno

@author 	Jacomo Lisa
@since		22/09/2015
@version 	P12
/*/
//==========================================================================================
Function FATI110(cXml, nTypeTrans, cTypeMessage)

Local aArea			:= GetArea()
Local lRet			:= .T. 
Local cEvento		:= "upsert"
Local cAdapter		:= "FATA110"
Local cMsgUnica		:= "CustumerGroup"
Local cMarca		:= "PROTHEUS"
Local cAlias		:= "ACY"
Local cCampo		:= "ACY_GRPVEN"
Local oXML			:= tXMLManager():New()
Local oModel		:= nil
Local oModelCab		:= nil
Local cBusiCont		:= '/TOTVSMessage/BusinessMessage/BusinessContent'
Local nX
Local lDelete
Local cXmlRet		:= ""
Local lMsblql		:= AllTrim(GetSx3Cache("ACY_MSBLQL", "X3_CAMPO")) == "ACY_MSBLQL" //FieldPos("ACY_MSBLQL") > 0
//Variaveis de controle
Local cDesc			:= ""
Local cSymbol		:= ""
Local cBlocked		:= ""
//Variaveis da Base Interna
Local cIntID		:= ""
Local cCodeInt		:= ""
//Variaveis da Base Externa
Local cExtID		:= ""


Do Case
	Case nTypeTrans == TRANS_SEND
		oModel:=FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt	:= AllTrim(oModel:GetValue('ACYMASTER',"ACY_GRPVEN"))
		cDesc		:= AllTrim(oModel:GetValue('ACYMASTER',"ACY_DESCRI"))
		If lMsblql
			cBlocked	:= AllTrim(oModel:GetValue('ACYMASTER',"ACY_MSBLQL"))
		Endif
				
		cIntID	:= TURXMakeId(cCodeInt,"ACY")
		//Monta XML de envio de mensagem unica
		
		cXMLRet :=	'<BusinessEvent>'
		cXMLRet +=		'<Entity>'+cMsgUnica+'</Entity>'
		cXMLRet +=		'<Event>'+cEvento+'</Event>'
		cXMLRet +=		'<Identification>'
		cXMLRet +=			'<key name="InternalId">'+cIntID+'</key>'
		cXMLRet +=		'</Identification>'
		cXMLRet +=	'</BusinessEvent>'
		
		cXMLRet +=	'<BusinessContent>'
		cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=		'<Code>'+cCodeInt+'</Code>'
		cXMLRet +=		'<InternalId>'+cIntID+'</InternalId>'
		cXMLRet +=		'<Description>'+cDesc+'</Description>'
		If lMsblql
			cXMLRet +=		'<Situation>'+TurXLogic(cBlocked,TP_CHAR1_RET)+'</Situation>'//Logico
		Endif
		cXMLRet +=	'</BusinessContent>'
		
		//Exclui o De/Para 
		If lDelete
			CFGA070MNT( nil, cAlias, cCampo, nil, cIntID, lDelete )
		Endif
		
		
	Case nTypeTrans == TRANS_RECEIVE .AND. oXML:Parse(cXml)
		Do Case
			Case (cTypeMessage == EAI_MESSAGE_WHOIS )//whois 
				cXmlRet := '1.000'
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE ) //resposta da mensagem Unica TOTVS
				If Empty(oXml:Error())
					cMarca	:=oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product','name')
					For nX:=1 to oXml:xPathChildCount("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId")
						cIntID:=oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId["+cValToChar(nX)+"]/Origin")
						cExtID:=oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId["+cValToChar(nX)+"]/Destination")
						If !Empty(cIntID) .and. !Empty(cExtID)
							CFGA070MNT( cMarca, cAlias, cCampo, cExtID, cIntID)
						Endif
					Next
				Endif
				oXml:=Nil
			Case ( cTypeMessage == EAI_MESSAGE_BUSINESS )//chegada de mensagem de negocios
				
				cEvent		:= Alltrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca		:= Alltrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID		:= Alltrim(oXml:XPathGetNodeValue(cBusiCont+'/InternalId'))
				cDesc		:= Alltrim(oXml:XPathGetNodeValue(cBusiCont+'/Description'))
				cBlocked	:= Alltrim(oXml:XPathGetNodeValue(cBusiCont+'/Situation'))
				
				
				cCodeInt	:= padr(Alltrim(TURXRetId(cMarca,cAlias	,cCampo		,cExtID  ,@cIntID	,3)),TamSx3("ACY_GRPVEN")[1] )
				ACY->(DbSetOrder(1))
				If Upper(cEvent) == 'UPSERT'
					If !Empty(cIntID) .and. ACY->(DbSeek(xFilial("ACY")+cCodeInt))
						cEvent:=MODEL_OPERATION_UPDATE
					Else
						cEvent:=MODEL_OPERATION_INSERT
						cCodeInt := GetSXENum("ACY", "ACY_GRPVEN")
						cIntID := TURXMakeId(cCodeInt,"ACY")
					Endif
				ElseIf Upper(cEvent) == 'DELETE'
					If !Empty(cIntID) .and. ACY->(DbSeek(xFilial("ACY")+cCodeInt))
						cEvent:=MODEL_OPERATION_DELETE
					Else
						lRet:=.F.
						cXmlRet:='Registro nao encontrado no Protheus.'
					Endif
				EndIf
				
				If lRet
					oModel	:=FwLoadModel(cAdapter)
					oModel:SetOperation(cEvent)
					If oModel:Activate()
						oModelCab	:= oModel:GetModel('ACYMASTER')
						If cEvent<> MODEL_OPERATION_DELETE
							If cEvent== MODEL_OPERATION_INSERT
								oModelCab:SetValue("ACY_GRPVEN"	,cCodeInt)
							Endif
								oModelCab:SetValue("ACY_DESCRI"	,cDesc	)
								If lMsblql
									oModelCab:SetValue("ACY_MSBLQL"	,TurXLogic(cBlocked,TP_CHAR1_RET))
								Endif
						Endif
						If oModel:VldData() .and. oModel:CommitData()
							ConfirmSX8()
							CFGA070MNT( cMarca, cAlias, cCampo, cExtID, cIntID,cEvent == MODEL_OPERATION_DELETE)
							If cEvent <> MODEL_OPERATION_DELETE
								cXmlRet+="<ListOfInternalId>"
								cXmlRet+=	'<InternalId>'
								cXmlRet+=		'<Name>'+cMsgUnica+'</Name>'
								cXmlRet+=		'<Origin>'+cExtID+'</Origin>'
								cXmlRet+=		'<Destination>'+cIntID+'</Destination>'
								cXmlRet+=	'</InternalId>'
								cXmlRet+="</ListOfInternalId>"
							Else
								cXmlRet:=""
							Endif
						Else
							aErro:=oModel:GetErrorMessage()
							If !Empty(aErro)
								cErro:='A integracao nao foi bem sucedida.'
								cErro+='Foi retornado o seguinte erro: ' +Alltrim(aErro[5])+'-'+AllTrim(aErro[6])
								If !Empty(Alltrim(aErro[7]))
									cErro+='Solucao - '+AllTrim(aErro[7])
								Endif
							Else
								cErro:='A integracao nao foi bem sucedida. '
								cErro+='Verifique os dados enviados'
							Endif
							lRet := .F.
							aSize(aErro,0)
							aErro:=nil
							cXmlRet:=cErro
						Endif
					
					Else
						lRet:=.F.
					Endif
					oModel:Deactivate()
					oModel:Destroy()	
					
				EndIf
		EndCase
EndCase

Return {lRet, cXMLRet}
