#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

CADASTRO DE Relacionamento Entidade x Contato - DEFINE MODELO DE DADOS (MVC) 

@sample 	CRMI060M()
@return     oModel                       
@author  	Serviços
@since   	17/10/2016
@version  	P12
/*/
//------------------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStruct := FWFormStruct(1,'AC8',/*bAvalCampo*/,/*lViewUsado*/)

oModel := MPFormModel():New('CRMI060',/*bPreValidacao*/,{|| CRMI060OK()}/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('AC8MASTER',/*cOwner*/,oStruct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetPrimaryKey({})
oModel:SetDescription('Relacionamento Entidade x Contato') // Relacionamento Entidade x Contato

Return(oModel)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

CADASTRO DE TAXAS - DEFINE AROTINA (MVC) 

@sample 	CRMI060()
@return     aRotina                       
@author  	Serviços
@since   	17/10/2016
@version  	P12
/*/
//------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'	ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0 // Pesquisar
ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.CRMI060'	OPERATION 2	ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.CRMI060'	OPERATION 3	ACCESS 0 // Incluir
ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.CRMI060'	OPERATION 4	ACCESS 0 // Incluir  
ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.CRMI060'	OPERATION 5	ACCESS 0 // Excluir

Return(aRotina)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA060IOK()

Função de Tudo Ok para validar a chave do registro.

@sample 	CRMA060IOK()
@return    lNotExist                        
@author  	Serviços
@since   	17/10/2016
@version  	P12
/*/
//------------------------------------------------------------------------------------------

Static Function CRMI060OK()
Return ExistChav('AC8',FwFldGet('AC8_CODCON')+FwFldGet('AC8_ENTIDA')+xFilial('AC8')+FwFldGet('AC8_CODENT'),1)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMI060

Função de integração do Cadastro de Relacionamento entre Entidade X Contato
Mensagem única - ContactRelationship

@sample	CRMI060(cXml, cTypeTrans, cTypeMessage)
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
Function CRMI060(cXml, nTypeTrans, cTypeMessage)

Local lRet        := .T. 
Local cEvento     := 'upsert'
Local cAdapter    := 'CRMA060'
Local cMsgUnica   := 'ContactRelationship'
Local cMarca      := 'PROTHEUS'
Local cVersao     := ''
Local cAlias      := 'AC8'
Local cCampo      := 'AC8_CODCON'
Local oXML        := tXMLManager():New()
Local oModel      := NIL
Local oModelAC8   := NIL
Local oModelDet   := NIL
Local aDetalhe    := {}
Local cBusiCont   := '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cListItens  := '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfContacts/Contact'
Local cXmlRet     := ''
Local cXMLItem		:= ""
Local aErro       := {}
Local nX, nCont   := 0
Local nLine       := 0
Local lDelete
Local nOpc			:= 3
Local cMsgErro	:= ""
//Variaveis DE/PARA		
Local cIntID	:= ''
Local cExtID	:= ''
Local cItemID	:= ''
//Variaveis de Controle do Xml		
Local cCodeInt    := ''
Local cCliente    := '' 
Local cLoja       := '' 
Local cItemCod    := ''
Local aCliente    := nil
Local cErro		:= ""
Local cThreadLog	:= cValToChar(Randomize(0,100000))+"_"
Local cTimeIni	:= Time()
Do Case
	Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf

		cCliLoja	:= AllTrim(oModel:GetValue('AC8MASTER', 'AC8_CODENT'))
		cCliente	:= Alltrim(SubStr(cCliLoja,1,TamSx3('A1_COD')[1])) 
		cLoja		:= Alltrim(SubStr(cCliLoja,TamSx3('A1_COD')[1]+1))
		cEntidade	:= If( AllTrim(oModel:GetValue('AC8MASTER', 'AC8_ENTIDA')) == 'SA1', "1","")
		cIntID		:= IntCliExt(,,cCliente,cLoja)[2]//TURXMakeId(cCliente+"|"+cLoja+"|C", 'SA1')

		//Monta XML de envio de mensagem unica
		cXMLRet := FWEAIBusEvent( cMsgUnica,oModel:GetOperation(), { { "InternalId", cIntID } } ) 
		
		cXMLRet +=	'<BusinessContent>'
		cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=		'<Code>' + cCliente +'|'+ cLoja +'|C' + '</Code>'
		cXMLRet +=		'<InternalId>' + cIntID + '</InternalId>'
		cXMLRet +=		'<Entity>' + cEntidade + '</Entity>'
		
		oModelDet := oModel:GetModel('AC8CONTDET')
		cXMLItem:= ""
		For nX := 1 to oModelDet:Length()
			oModelDet:goline(nX)
			
			cItemCod := oModel:GetValue('AC8CONTDET', 'AC8_CODCON')
				
			If !oModelDet:IsDeleted() .Or. Upper(cEvento) == 'DELETE' 
				cXMLItem += '<Contact>'
				cXMLItem +=		'<ContactCode>' + cItemCod + '</ContactCode>'
				cXMLItem +=		'<ContactInternalId>' + TurXMakeID(cItemCod,'SU5') + '</ContactInternalId>'
				cXMLItem += '</Contact>'
			Endif
		Next
		
		If !Empty(cXMLItem)
			cXMLRet +=	'<ListOfContacts>'+cXMLItem +'</ListOfContacts>'
		Endif
		cXMLRet += '</BusinessContent>'
		
	Case nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
			
			//resposta da mensagem única TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				oXml := NIL
				
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cEvento	:= AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca		:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cExtID		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				cEntity	:= PadR(If(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Entity'))=="1","SA1",""), TamSx3('AC8_ENTIDA')[1])
				
				If (aCliente := IntCliInt(cExtID,cMarca))[1] 
					cCliente	:= PadR(aCliente[2][3], TamSx3('A1_COD')[1])
					cLoja		:= PadR(aCliente[2][4], TamSx3('A1_LOJA')[1])
				Else
					lRet     := .F.
					cMsgErro := aCliente[2]
				Endif
				TxDestroy(aCliente)
				AC8->(DBSETORDER(2)) //AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON					
				
				If lRet
					If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfContacts') ) > 0
						
						For nX := 1 To nCont
							cExtId		:= AllTrim(oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/ContactInternalId'))
							cItemCod	:= PadR(AllTrim(TURXRetId(cMarca, 'SU5', 'U5_CODCONT', cExtId, NIL, 3,@cErro)), TamSx3('AC8_CODCON')[1])
							If !Empty(cExtId) .and. !Empty(cErro)
								lRet := .F.
								cMsgErro := cErro
							Endif
							If Upper(cEvento) == 'UPSERT'
								If !AC8->(DbSeek(xFilial('AC8') + cEntity + xFilial('SA1') + PadR(cCliente + cLoja,TamSx3('AC8_CODENT')[1])+ cItemCod))
									nOpc := MODEL_OPERATION_INSERT
								Else
									loop
								Endif
							ElseIf Upper(cEvento) == 'DELETE'
								If AC8->(DbSeek(xFilial('AC8') + cEntity + xFilial('SA1') + PadR(cCliente + cLoja,TamSx3('AC8_CODENT')[1])+ cItemCod))
									nOpc := MODEL_OPERATION_DELETE
									lDelete := .T.
								Else
									lRet    := .F.
									cMsgErro := STR0001+ Chr(13) + Chr(10) // "Registro nao encontrado no Protheus." 
									cMsgErro += STR0009 + cCliente + cLoja
									Exit
								Endif
							EndIf
						
							If lRet
								oModel	:= FwLoadModel('CRMI060')
								oModel:SetOperation(nOpc)
								If oModel:Activate()
									oModelAC8 := oModel:GetModel('AC8MASTER')
									
									If !lDelete
										If 	!oModelAC8:SetValue('AC8_ENTIDA', cEntity)
											lRet := .F.
											Exit
										Endif
										If lRet .and. !oModelAC8:SetValue('AC8_CODENT', cCliente + cLoja)
											lRet := .F.
											Exit
										Endif
										If lRet .and. !oModelAC8:SetValue('AC8_CODCON', cItemCod)
											lRet := .F.
											Exit
										Endif
									Endif
								Else
									lRet := .F.
								Endif						
								
								If lRet .And. oModel:VldData() .And. oModel:CommitData()
									cXmlRet := ""
								Else
									cMsgErro := Ci060Erro(oModel)
									lRet := .F.
									Exit
								Endif
								oModel:Deactivate()
								oModel:Destroy()
							EndIf
						Next
						
					Endif
				
				Endif
				IF !lRet 
					cXmlRet := cMsgErro
				Endif
		EndCase
EndCase
TxDestroy(oXml)
//TxTraceLog(,cThreadLog, cTimeIni)
Return {lRet, cXMLRet, cMsgUnica}

Static Function Ci060Erro(oModel)
Local cErro := ""
Local aErro:=oModel:GetErrorMessage()
Local aArea := GetArea()
If !Empty(aErro)
	cErro := chr(13)+chr(10)+STR0002+chr(13)+chr(10)// "A integração não foi bem sucedida."
	cErro += STR0003// "Foi retornado o seguinte erro: "
	If !Empty(_NoTags(Alltrim(aErro[4])))
		SX3->(DBSETORDER(2))
		If SX3->(DBSEEK(Padr(aErro[4],10)))
			cErro += AllTrim(X3TITULO()) +'('+_NoTags(Alltrim(aErro[4]))+')' +chr(13)+chr(10)
		Endif
	Endif
	
	cErro += _NoTags(Alltrim(aErro[5])+'-'+AllTrim(aErro[6])) +chr(13)+chr(10)
	
	If !Empty(_NoTags(Alltrim(aErro[8])))
		cErro += STR0009+_NoTags(Alltrim(aErro[8]))+ chr(13)+chr(10) //' Referencia:'
	Endif
	If !Empty(Alltrim(strtran(oModel:GetErrorMessage()[7], chr(13)+chr(10), '')))
		cErro += STR0005+_NoTags(AllTrim(aErro[7]))//'Solução - '
	Endif
Else
	cErro := STR0002// "A integração não foi bem sucedida."
	cErro += STR0004//'Verifique os dados enviados'
Endif
aSize(aErro,0)
aErro:=nil
RestArea(aArea)							
oModel:Deactivate()
oModel:Destroy()	
Return cErro
