#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATI020A.CH"
#INCLUDE "FWADAPTEREAI.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI020
Funcao de integracao com o adapter EAI para tratamento da mensagem CUSTOMERVENDORINFORMATION

Onde se recebe o CPF/CNPJ do fornecedor e retorna a lista de fornecedores com o CPF/CNPJ com 
os seguintes dados: codigo, loja, nome fantasia e nome

@param		cXml			Variável com conteúdo XML para envio/recebimento.
@param		nTypeTrans		Tipo de transação. (Envio/Recebimento)
@param		cTypeMessage	Tipo de mensagem. (Business Type, WhoIs, etc)

@author	Leonardo Quintania
@version	P12
@since	05/06/2015
@return  lRet - (boolean)  Indica o resultado da execução da função
         cXmlRet - (caracter) Mensagem XML para envio
/*/
//-------------------------------------------------------------------------------------------------
Function MATI020A(cXML, nTypeTrans, cTypeMessage)
Local cError   := ""
Local cWarning := ""
Local cVersao  := ""
Local lRet     := .T.
Local cXmlRet  := ""
Local aRet     := {}
Local aAreaXX4 := {}

Private oXml    := Nil
	
//Mensagem de Entrada
If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
		
		oXml := xmlParser(cXml, "_", @cError, @cWarning)
		
		If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
			// Versão da mensagem
			If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") == "C" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text,".")[1]
			Else
				lRet    := .F.
				cXmlRet := STR0001 //"Versão da mensagem não informada!" 
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0002 //"Erro no parser!"
		EndIf
		
		If lRet .And. cVersao == "1"
			aRet := v1000(cXml, nTypeTrans, cTypeMessage)
			lRet    := aRet[1]
			cXMLRet := aRet[2]
		ElseIf cVersao # "1"
			lRet    := .F.
			cXmlRet := STR0003 //"A versão da mensagem informada não foi implementada!"
		EndIf
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXml)
		lRet    := aRet[1]
		cXMLRet := aRet[2]
	Endif
	
// Mensagem de Saida	
ElseIf nTypeTrans == TRANS_SEND
	dbSelectArea("XX4")
	aAreaXX4 := XX4->(GetArea())
	
	XX4->(dbSetOrder(1))
	IF XX4->(dbSeek(xFilial("XX4") + PADR("MATA020A", Len(XX4_ROTINA)) + PADR("CUSTOMERVENDORINFORMATION", Len(XX4_MODEL))))
		If Empty(XX4->XX4_SNDVER)
			lRet    := .F.
			cXmlRet := STR0004 //"Versão não informada no cadastro do adapter."
		Else
			cVersao := StrTokArr(XX4->XX4_SNDVER, ".")[1]
		EndIf
	Else
		lRet    := .F.
		cXmlRet := STR0005 //"Adapter não encontrado!"
	EndIf
	
	If lRet .And. cVersao == "1"
		aRet := v1000(cXml, nTypeTrans, cTypeMessage)
		lRet    := aRet[1]
		cXMLRet := aRet[2]
	ElseIf cVersao # "1"
		lRet    := .F.
		cXmlRet := STR0006 //"A versão da mensagem informada não foi implementada!"
	EndIf
	RestArea(aAreaXX4)
EndIf


Return {lRet, cXmlRet}

/*/{Protheus.doc} v1000
Funcao de integracao com o adapter EAI para consulta de informações do cadastro 
de clientes (SA1) utilizando o conceito de mensagem unica.
@author Leonardo Quintania
@since	05/06/2015
@version 1.0
@param 	cXML - Variavel com conteudo xml para envio/recebimento.     
@param nTypeTrans - Tipo de transacao. (Envio/Recebimento)          
@param cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) 
@return 
	aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.                                       
		aRet[1] - (boolean) Indica o resultado da execução da função 
		aRet[2] - (caracter) Mensagem Xml para envio                 
/*/
Static Function v1000( cXML, nTypeTrans, cTypeMessage )
Local aArea		:= GetArea()
Local aRet			:= {}
Local cDocNumber	:= ""
Local cXMLRet 	:= ""
Local cError		:= ""
Local cWarning	:= ""
Local lRet			:= .T.

Private oXmlM020

//Trata o recebimento de mensagens
If ( nTypeTrans == TRANS_RECEIVE )
	
	//Trata o recebimento de dados (BusinessContent)
	If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
		
		oXmlM020 := XmlParser( cXml, "_", @cError, @cWarning )
		
		//Verifica se houve erro na criacao do objeto XML
		If ( oXmlM020 <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )
			
			// Caso seja Fornecedor
			If ( AllTrim( Upper( oXmlM020:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text ) ) == "VENDOR")
				//--------------------------------------------------------------------------------------
				//-- Tratamento utilizando a tabela XXF com um De/Para de codigos
				//--------------------------------------------------------------------------------------
				// CPF ou CNPJ
				If ( Type( "oXmlM020:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text" ) <> "U" )
					cDocNumber:= oXmlM020:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text
				EndIf
				
				If Empty(cDocNumber) //Tratamento em caso não mande documento
					lRet		:= .F.
					cXMLRet	:= "Não foi informado número do documento na mensagem!"
				Else
					BeginSql Alias "TMPSA2"
						SELECT 
							SA2.A2_COD,SA2.A2_LOJA,SA2.A2_NOME,SA2.A2_NREDUZ
							FROM %Table:SA2% SA2
						WHERE
							SA2.A2_FILIAL = %xFilial:SA2%
							AND A2_CGC = %Exp:cDocNumber%
							AND SA2.%notDel% 
						ORDER BY SA2.A2_COD,SA2.A2_LOJA
					EndSql
					
					cXMLRet += "<ListOfCustomerVendorInformationResult>"
					
					If TMPSA2->(!Eof())
						While TMPSA2->(!Eof())						
							cXMLRet += "<CustomerVendorInformationResult>"
							cXMLRet += "<Exists>True</Exists>"
							cXMLRet += "<Code>" + TMPSA2->(A2_COD)  + "</Code>"
							cXMLRet += "<StoreId>" + TMPSA2->(A2_LOJA)  + "</StoreId>"
							cXMLRet += "<Name>" + TMPSA2->(A2_NOME) + "</Name>"
							cXMLRet += "<ShortName>" + TMPSA2->(A2_NREDUZ) + "</ShortName>"
							cXMLRet += "</CustomerVendorInformationResult>"
							TMPSA2->(dbSkip())
						EndDo
					Else
						cXMLRet += "<CustomerVendorInformationResult>"
						cXMLRet += "<Exists>False</Exists>"
						cXMLRet += "</CustomerVendorInformationResult>"
					EndIf
					
					cXMLRet += "</ListOfCustomerVendorInformationResult>"
					TMPSA2->(dbCloseArea())
				EndIf
			ElseIf AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)) == "CUSTOMER"
				aRet := FWIntegDef("MATA030A", cTypeMessage, nTypeTrans, cXml)
            	If !Empty(aRet)
              	lRet := aRet[1]
              	cXmlRet := aRet[2]
				EndIf
			EndIf
		Else
			//Tratamento em caso de falha ao gerar o objeto XML
			lRet        := .F.
			cXMLRet := STR0007 + cWarning
		EndIf		
	
	//Tratamento de solicitacao de versao
	ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
		cXMLRet := "1.000"
	EndIf
	
//Tratamento de envio de mensagens
ElseIf ( nTypeTrans == TRANS_SEND )
	
	cXMLRet += "<BusinessRequest>"
	cXMLRet += 	"<Operation>MATA020B</Operation>"						
	cXMLRet += "</BusinessRequest>"
	
	cXMLRet += "<BusinessContent>"
	
	cXMLRet += 	"<CompanyInternalId>" + cEmpAnt + "|" + xFilial("SA2") + "</CompanyInternalId>"
	cXMLRet += 	"<CompanyId>" + cEmpAnt + "</CompanyId>"
	cXMLRet += 	"<BranchId>" + xFilial("SA2") + "</BranchId>"
	cXMLRet += 	"<Type>001</Type>"
	
	cXMLRet += "<BusinessContent>"
	cXMLRet +=  "<DocumentNumber>"+SA2->A1_CGC+"</DocumentNumber>"
	cXMLRet +=  "<Type>VENDOR</Type>"
	cXMLRet += "</BusinessContent>"
	
EndIf

RestArea(aArea)
Return { lRet, cXMLRet }
