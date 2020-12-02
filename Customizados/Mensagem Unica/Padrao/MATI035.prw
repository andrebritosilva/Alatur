#Include "PROTHEUS.CH"
#Include "FWADAPTEREAI.CH"
#Include "FWMVCDEF.CH"
#Include "MATI035.CH"
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATI035   ºAutor  ³Microsiga           º Data ³  11/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações do cadastro de grupo de produtos (SBM)º±±
±±º          ³ utilizando o conceito de mensagem unica.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA035                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MATI035( cXML, nTypeTrans, cTypeMessage )
	
	Local aAreaXX4	:= XX4->(GetArea())
	Local aArea		:= GetArea()
	Local lRet			:= .T.
	Local cXmlRet		:= ""
	Local oXmlGrp		:= Nil
	Local cXmlErro	:= ""
	Local cXmlWarn	:= ""
	Local cVersao		:= "1"
	
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
			oXmlGrp:= XmlParser( cXml, '_', @cXmlErro, @cXmlWarn)
			If oXmlGrp <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
				// Versão da mensagem
				If ValType("oXmlGrp:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXmlGrp:_TOTVSMessage:_MessageInformation:_version:Text)
					cVersao := StrTokArr(oXmlGrp:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
				Else
					lRet    := .F.
					cXmlRet := STR0008 //"Versão da mensagem não informada!"
					Return {lRet, cXmlRet}
				EndIf
			Else
				lRet    := .F.
				cXmlRet := STR0009 //"Erro no parser!"
				Return {lRet, cXmlRet}
			EndIf
			
			If  Alltrim(oXmlGrp:_TOTVSMessage:_MessageInformation:_version:Text) == "2.002"
				aRet := v2002(cXml, nTypeTrans, cTypeMessage)
			ElseIf cVersao == "1"
				aRet := v1000(cXml, nTypeTrans, cTypeMessage)
			ElseIf cVersao == "2"
				aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXmlGrp)
			Else
				lRet    := .F.
				cXmlRet := STR0010 //"A versão da mensagem informada não foi implementada!"
				Return {lRet, cXmlRet}
			EndIf
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXmlGrp)
		Endif
	ElseIf nTypeTrans == TRANS_SEND //Tratamento do envio de mensagens
		aAreak4 := XX4->(GetArea())
		XX4->(dbSetOrder(1))
		If XX4->(dbSeek(xFilial('XX4') + PADR('MATA035', Len(XX4_ROTINA)) + PADR('FAMILY', Len(XX4_MODEL))))
			If Empty(XX4->XX4_SNDVER)
				lRet    := .F.
				cXmlRet := STR0011 //"Versão não informada no cadastro do adapter."
				Return {lRet, cXmlRet}
			Else
				cVersao := StrTokArr(XX4->XX4_SNDVER, ".")[1]
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0012 //"Adapter não encontrado!"
			Return {lRet, cXmlRet}
		EndIf
		If Alltrim(XX4->XX4_SNDVER) == "2.002"
			aRet := v2002(cXml, nTypeTrans, cTypeMessage)
		ElseIf cVersao == "1"
			aRet := v1000(cXml, nTypeTrans, cTypeMessage)
		ElseIf cVersao == "2"
			aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXmlGrp)
		Else
			lRet    := .F.
			cXmlRet := STR0010 //"A versão da mensagem informada não foi implementada!"
			Return {lRet, cXmlRet}
		EndIf
		RestArea(aAreaXX4)
	EndIf
	RestArea(aArea)
	
//	cXMLRet := EncodeUTF8(cXMLRet)
	
	lRet    := aRet[1]
	cXMLRet := aRet[2]
	
Return { lRet, cXMLRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} I035Oper
Rotina para integração por EAI

@since 05/11/2012
@version P11
@params	lStatus    - indicação do status do processamento [Referencia]
@params	cXmlStatus - conteúdo de retorno [Referencia]
@params	oMdlOper   - modelo de dados para rotina automática [Referencia]
@params	oXmlOper   - conteúdo para processamento
@params	cMarca     - sistema com o qual a integração está sendo realizada
@params	cValExtern - chave do registro na aplicação de origem da mensagem
@return	Posicao 1  - LOGICAL - indica o status do processamento
@return	Posicao 2  - CHAR    - Xml/Conteúdo de retorno do processamento
/*/
//-------------------------------------------------------------------
Static Function I035Oper( lStatus, cXmlStatus, oMdlOper, oXmlOper, cMarca, cValExtern, cVersao )
	
	Local oMdlCab   := oMdlOper:GetModel(cModelDef)
	Local lDeleta   := oMdlOper:GetOperation()==MODEL_OPERATION_DELETE
	Local cIntVal   := ""
	Local aRet		  := {}
	
	Default cVersao := "001"
	
	If Inclui
		cIntVal := GetSXENum('SBM','BM_GRUPO')
	Else
		If cVersao == "001"
			cIntVal := IntFamInt(cValExtern, cMarca, "1.000")
		Else
			cIntVal := IntFamInt(cValExtern, cMarca, "2.000")[2,3]
		Endif
	EndIf
	
	If !lDeleta
		
		If XmlChildEx(oXmlOper, '_BUSINESSCONTENT') <> Nil
			
			If lStatus
				lStatus := oMdlCab:SetValue('BM_LENREL', 1)
			EndIf
			
			If lStatus .And. Inclui .And. !Empty(cIntVal) .And. !Empty(cValExtern)
				lStatus := oMdlCab:SetValue('BM_GRUPO', cIntVal )
			EndIf
			
			If lStatus .And. XmlChildEx(oXmlOper:_BusinessContent, '_DESCRIPTION') <> Nil
				lStatus := oMdlCab:SetValue('BM_DESC', oXmlOper:_BusinessContent:_Description:Text)
			EndIf
			
			If lStatus .And. XmlChildEx(oXmlOper:_BusinessContent, '_FAMILYCLASSIFICATIONCODE') <> Nil
				lStatus := oMdlCab:SetValue('BM_TIPGRU', oXmlOper:_BusinessContent:_FamilyClassificationCode:Text)
			EndIf
			
		Else
			lStatus := .F.
			cXmlStatus := STR0007 //'Estrutura invalida, tag "BusinessContent" não existe'
		EndIf
		
	EndIf
	
	lStatus := lStatus .And. oMdlOper:VldData()
	
	If cVersao == "001"
		aRet := IntFamExt(cEmpAnt,xFilial("SBM"),cIntVal,"1.000")
	Else
		aRet := IntFamExt(cEmpAnt,xFilial("SBM"),cIntVal,"2.000")
	Endif
	
	If aRet[1]
		cIntVal := aRet[2]
	Else
		lStatus := .F.
	Endif
	
	If lStatus
		
		oMdlOper:CommitData()
		
		If cVersao <> "001"
			cXmlStatus := '<ListOfInternalId>'
			cXmlStatus += 	'<InternalId>'
			cXmlStatus += 		'<Name>Family</Name>'
			cXmlStatus += 		'<Origin>'+ cValExtern +'</Origin>'
			cXmlStatus += 		'<Destination>'+ cIntVal +'</Destination>'
			cXmlStatus += 	'</InternalId>'
			cXmlStatus += '</ListOfInternalId>'
		Elseif cVersao == "001"
			cXmlStatus := '<ListOfInternalId>'
			cXmlStatus += 	'<Family>'
			cXmlStatus += 		'<Origin>'+ cValExtern +'</Origin>'
			cXmlStatus += 		'<Destination>'+ cIntVal +'</Destination>'
			cXmlStatus += 	'</Family>'
			cXmlStatus += '</ListOfInternalId>'
		EndIf
		
		//De/Para
		If lDeleta
			CFGA070Mnt(    Nil, 'SBM', 'BM_GRUPO', Nil, cIntVal, .T. ) // remove do de/para
		ElseIf Inclui
			CFGA070Mnt( cMarca, 'SBM', 'BM_GRUPO', cValExtern, cIntVal )
		EndIf
		
	Else
		If !aRet[1]
			cXmlStatus := aRet[2]
		Else
			//  Identificar erro do modelo para retorno
			cXmlStatus := ApErroMvc( oMdlOper )
		Endif
	EndIf
	
Return { lStatus, cXmlStatus}

//-------------------------------------------------------------------
/*/{Protheus.doc} ApErroMvc
Apura o erro do mvc retornando uma string

@since 06/11/2012
@version P11
@params	oModel     - modelo de dados para rotina automática
@return	cErro      - erro apurado no modelo
/*/
//-------------------------------------------------------------------
Static Function ApErroMvc( oModel )
	
	Local cErro  := ' '
	Local aErros := oModel:GetErrorMessage()
	Local nX     := 0
	
	For nX := 1 To Len(aErros)
		If Valtype(aErros[nX])=='C'
			cErro += StrTran(StrTran(StrTran(StrTran(aErros[nX],"<",""),"-",""),">",""),"/", "") + ("|")
		EndIf
	Next nX
	
Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} v1000
Versão 1 para mensagem Family

@since 16/12/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function v1000( cXML, nTypeTrans, cTypeMessage )
	Local aArea		:= GetArea()
	Local lRet			:= .T.
	Local oXmlGrp		:= Nil
	Local oModel		:= Nil
	Local oXmlBusin	:= Nil
	Local cXMLRet		:= ""
	Local cEvento		:= "upsert"
	Local cXmlErro	:= ""
	Local cXmlWarn	:= ""
	Local cExtVal		:= ""
	Local cMarca		:= ""
	Local cAlias		:= "SBM"
	Local cCampo		:= "BM_GRUPO"
	Local cGrupo		:= ""
	Local aRet			:= {}
	
	If ( Type("Inclui") == "U" )
		Private Inclui := .F.
	EndIf
	If ( Type("Altera") == "U" )
		Private Altera := .F.
	EndIf
	
	If ( nTypeTrans == TRANS_RECEIVE ) //Tratamento do recebimento de mensagens
		If ( cTypeMessage == EAI_MESSAGE_BUSINESS ) //Business Message
			oXmlGrp	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
			If oXmlGrp <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn) //Valida se houve erro no parser
				cMarca := oXmlGrp:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				oModel 	:= FwLoadModel('MATA035')
				oXmlBusin	:=oXMlGrp:_TotvsMessage:_BusinessMessage
				If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil
					cEvento := oXmlBusin:_BusinessEvent:_Event:Text
					If XmlChildEx(oXmlBusin:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent:_Identification, '_KEY') <> Nil
						cExtVal := oXmlBusin:_BusinessEvent:_Identification:_Key:Text
					EndIf
					If !Empty(cExtVal)
						DbSelectArea("SBM")
						DbSetOrder(1)
						
						aRet := IntFamInt(cExtVal, cMarca, "1.000")
						
						If !aRet[1] .And. Upper(cEvento) == "UPSERT"
							oModel:SetOperation( MODEL_OPERATION_INSERT )
							Inclui := .T.
							Altera := .F.
						Elseif aRet[1] .AND. upper(cEvento) == "UPSERT" .AND. SBM->(DbSeek(xFilial("SBM") + Padr(aRet[2],TamSx3("BM_GRUPO")[1])))
							oModel:SetOperation( MODEL_OPERATION_UPDATE )
							Altera := .T.
							Inclui := .F.
						Elseif aRet[1] .AND. upper(cEvento) == "DELETE" .AND. SBM->(DbSeek(xFilial("SBM") + Padr(aRet[2],TamSx3("BM_GRUPO")[1])))
							Inclui := .F.
							Altera := .F.
							oModel:SetOperation( MODEL_OPERATION_DELETE )
						Elseif !aRet[1]
							lRet := .F.
							cXMLRet := aRet[2]
						Endif
						
						If lRet
							lRet := oModel:Activate()
							If lRet
								I035Oper( @lRet, @cXmlRet, @oModel, oXmlBusin, cMarca, cExtVal )
							Else
								cXmlRet := ApErroMvc( oModel )
							EndIf
						Endif
					Else
						lRet := .F.
						cXMLRet := STR0004 //"Chave do registro não enviada, é necessária para cadastrar o de-para"
					EndIf
				Else
					lRet := .F.
					cXmlRet := STR0005 //'Tag de operação "Event" inexistente'
				EndIf
			Else
				lRet := .F.
				cXMLRet := 	STR0006 + ' | ' + cXmlErro + ' | ' + cXmlWarn //'Xml mal formatado '
			EndIf
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE //Response Message
			oXmlGrp := XmlParser(cXml, "_", @cXmlErro, @cXmlWarn)
			If oXmlGrp <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
				If ValType("oXmlGrp:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
					cMarca :=  oXmlGrp:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				EndIf
				If ValType("oXmlGrp:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text") <> "U"
					cExtVal := oXmlGrp:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text
				EndIf
				CFGA070INT( cMarca,  cAlias ,cCampo, cExtVal )
			Else
				lRet := .F.
			EndIf
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS //WhoIs Message
			cXMLRet := '1.000|2.000|2.001|2.002'
		EndIf
	ElseIf nTypeTrans == TRANS_SEND //Tratamento do envio de mensagens
		cGrupo := SBM->BM_GRUPO
		If Inclui .Or. Altera //-- Inclusao ou Alteracao
			//Monta XML de envio de mensagem unica
			cXMLRet += '<BusinessEvent>'
			cXMLRet +=     '<Entity>Family</Entity>'
			cXMLRet +=     '<Event>' + cEvento + '</Event>'
			cXMLRet +=     '<Identification>'
			cXMLRet +=         '<key name="InternalId">' + xFilial('SBM') + cGrupo + '</key>'
			cXMLRet +=     '</Identification>'
			cXMLRet += '</BusinessEvent>'
			
			cXMLRet += '<BusinessContent>'
			cXMLRet += 	'<Code>' + cGrupo + '</Code>'
			cXMLRet += 	'<Description>' + SBM->BM_DESC + '</Description>'
			cXMLRet += '</BusinessContent>'
		Else //-- Exclusao
			cEvento := 'delete'
			cXMLRet := '<BusinessEvent>'
			cXMLRet +=     '<Entity>Family</Entity>'
			cXMLRet +=     '<Event>' + cEvento + '</Event>'
			cXMLRet +=     '<Identification>'
			cXMLRet +=         '<key name="InternalId">' + xFilial('SBM') + cGrupo + '</key>'
			cXMLRet +=     '</Identification>'
			cXMLRet += '</BusinessEvent>'
			
			cXMLRet +='<BusinessContent>'
			cXMLRet += 	'<Code>' + cGrupo + '</Code>'
			cXMLRet += 	'<Description>' + SBM->BM_DESC + '</Description>'
			cXMLRet +='</BusinessContent>'
			
			CFGA070Mnt(,cAlias,cCampo,, xFilial('SBM')+cGrupo, .T. )
		EndIf
	EndIf
	RestArea(aArea)
Return { lRet, cXMLRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} v2000
Versão 2 para mensagem Family

@since 16/12/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function v2000( cXML, nTypeTrans, cTypeMessage, oXmlGrp )
	Local lRet 		:= .T.
	Local cXMLRet		:= ""
	Local cEvento		:= "upsert"
	Local cXmlErro	:= ""
	Local cXmlWarn	:= ""
	Local oXmlBusin	:= NIL
	Local cValExt		:= "" //Codigo externo utilizada no De/Para de codigos - Tabela XXF
	Local cValInt		:= "" //Codigo interno utilizado no De/Para de codigos - Tabela XXF
	Local cAlias		:= "SBM"
	Local cCampo		:= 'BM_GRUPO'
	Local cMarca		:= ""
	Local cError		:= ""
	Local nCount		:= 0
	Local aRet			:= {}
	
	If ( Type("Inclui") == "U" )
		Private Inclui := .F.
	EndIf
	If ( Type("Altera") == "U" )
		Private Altera := .F.
	EndIf
	
	DbSelectArea("SBM")
	SBM->(DbSetOrder(1))
	
	If ( nTypeTrans == TRANS_RECEIVE ) //Tratamento do recebimento de mensagens
		
		If ( cTypeMessage == EAI_MESSAGE_BUSINESS ) //Business Message
			cMarca := oXmlGrp:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			oModel 	:= FwLoadModel('MATA035')
			oXmlBusin	:= oXMlGrp:_TotvsMessage:_BusinessMessage
			If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil
				cEvento := oXmlBusin:_BusinessEvent:_Event:Text
				// InternalId
				If ValType("oXmlGrp:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_INTERNALID:Text") == "C" .And. !Empty(oXmlGrp:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
					cValExt := oXmlGrp:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
					
					aRet := IntFamInt(cValExt, cMarca, "2.000")
					
					If !aRet[1] .And. Upper(cEvento) == "UPSERT"
						Inclui := .T.
						Altera := .F.
						oModel:SetOperation( MODEL_OPERATION_INSERT )
					Elseif aRet[1] .And.	Upper(cEvento) == "UPSERT" .AND. SBM->(MsSeek(xFilial("SBM") + PadR(aRet[2,3],TamSx3("BM_GRUPO")[1])))
						Altera := .T.
						Inclui := .F.
						oModel:SetOperation( MODEL_OPERATION_UPDATE )
					Elseif aRet[1] .AND. Upper(cEvento) == "DELETE" .AND. SBM->(MsSeek(xFilial("SBM") + PadR(aRet[2,3],TamSx3("BM_GRUPO")[1])))
						Inclui := .F.
						Altera := .F.
						oModel:SetOperation( MODEL_OPERATION_DELETE )
					Elseif !aRet[1]
						lRet := .F.
						cXMLRet := aRet[2]
					Endif
					
					If lRet
						lRet := oModel:Activate()
						If lRet
							I035Oper( @lRet, @cXmlRet, @oModel, oXmlBusin, cMarca, cValExt, "002" )
						Else
							cXmlRet := ApErroMvc( oModel )
						EndIf
					Endif
					
				Else
					lRet := .F.
					cXMLRet := STR0013 //"O código do InternalId é obrigatório!"
				EndIf
			Else
				lRet := .F.
				cXmlRet := STR0005 //"Tag de operação "Event" inexistente"
			EndIf
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE //Response Message
			oXML	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
			If oXML <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
				// Se não houve erros na resposta
				If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
					// Verifica se a marca foi informada
					If ValType("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
						cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
					Else
						lRet    := .F.
						cXmlRet := STR0014 //"Erro no retorno. O Product é obrigatório!"
						Return {lRet, cXmlRet}
					EndIf
					// Se não for array
					If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "A"
						// Transforma em array
						XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
					EndIf
					
					// Verifica se o código interno foi informado
					If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text)
						cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text
					Else
						lRet    := .F.
						cXmlRet := STR0015 //"Erro no retorno. O OriginalInternalId é obrigatório!"
						Return {lRet, cXmlRet}
					EndIf
					// Verifica se o código externo foi informado
					If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text)
						cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text
					Else
						lRet    := .F.
						cXmlRet := STR0016 //"Erro no retorno. O DestinationInternalId é obrigatório!"
						Return {lRet, cXmlRet}
					EndIf
					// Obtém a mensagem original enviada
					If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
						cXML := Alltrim(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
					Else
						lRet    := .F.
						cXmlRet := STR0017 //"Conteúdo do MessageContent vazio!"
						Return {lRet, cXmlRet}
					EndIf
					
					AdpLogEAI(3, "cValInt: ", cValInt)
					AdpLogEAI(3, "cValExt: ", cValExt)
					
					oXML := XmlParser( cXML, '_', @cXmlErro, @cXmlWarn) // Faz o parse do XML em um objeto
					If oXML != Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn) // Se não houve erros no parse
						If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
							CFGA070Mnt(cProduct, cAlias, cCampo, cValExt, cValInt, .F.)// Insere / Atualiza o registro na tabela XXF (de/para)
						ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
							CFGA070Mnt(cProduct, cAlias, cCampo, cValExt, cValInt, .T.)// Exclui o registro na tabela XXF (de/para)
						Else
							lRet := .F.
							cXmlRet := STR0018 //"Evento do retorno inválido!"
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0018 //"Erro no parser do retorno!"
						Return {lRet, cXmlRet}
					EndIf
				Else
					// Se não for array
					If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
						// Transforma em array
						XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
					EndIf
					// Percorre o array para obter os erros gerados
					For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
						cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
					Next nCount
					lRet := .F.
					cXmlRet := cError
				EndIf
			EndIf
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS //WhoIs Message
			cXMLRet := '1.000|2.000|2.001|2.002'
		EndIf
		
	ElseIf nTypeTrans == TRANS_SEND //Tratamento do envio de mensagens
		//Verifica se é uma exclusão
		If !Inclui .And. !Altera
			cEvento := 'delete'
		EndIf
		cGrupo := SBM->BM_GRUPO
		//Monta XML de envio de mensagem unica
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>Family</Entity>'
		cXMLRet +=     '<Event>' + cEvento + '</Event>'
		cXMLRet +=     '<Identification>'
		cXMLRet +=         '<key name="Code">' + cGrupo + '</key>'
		cXMLRet +=     '</Identification>'
		cXMLRet += '</BusinessEvent>'
		
		cXMLRet += '<BusinessContent>'
		cXMLRet += 	'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet += 	'<BranchId>' + xFilial("SBM") + '</BranchId>'
		cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + xFilial("SBM") + '</CompanyInternalId>'
		cXMLRet +=    '<Code>' + cGrupo + '</Code>'
		cXMLRet +=    '<InternalId>' + cEmpAnt + '|' + xFilial("SBM")+ "|" + cGrupo + '</InternalId>'
		cXMLRet +=    '<Description>' + _NoTags(AllTrim(SBM->BM_DESC)) + '</Description>'
		cXMLRet +=    '<FamilyType>' + SBM->BM_TIPGRU + '</FamilyType>'
		cXMLRet +=    '<FamilyClassificationCode>' + SBM->BM_CLASGRU + '</FamilyClassificationCode>'
		cXMLRet += '</BusinessContent>'
		
	EndIf
	
Return { lRet, cXMLRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} v2002

Versão 3 para mensagem Family

@sample	v2002(cXml, cTypeTrans, cTypeMessage)
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
@since		02/10/2015
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function v2002( cXML, nTypeTrans, cTypeMessage)
	Local lRet       := .T.
	Local cEvento    := 'upsert'
	Local cAdapter   := 'MATA035'
	Local cMsgUnica  := 'FAMILY'
	Local cMarca     := 'PROTHEUS'
	Local cVersao    := ''
	Local cAlias     := 'SBM'
	Local cCampo     := 'BM_GRUPO'
	Local oXML       := tXMLManager():New()
	Local oModel     := NIL
	Local oModelCab  := NIL
	Local oModelDet  := NIL
	Local aRet       := {}
	Local aDetalhe   := {}
	Local cBusiCont  := '/TOTVSMessage/BusinessMessage/BusinessContent'
	Local cListItens := '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfPaymentForm/PaymentForm'
	Local nX,nCont,nY:= 0
	Local nLine      := 0
	Local lDelete
	Local cXmlRet    := ''
	Local cXmlItem   := ''
	Local aIntID	 := {}
	Local cModelDef	 := ""
	Local nOldModulo := nModulo
	//Variaveis de Controle do Xml
	Local cItemCod   := ''
	Local cDesc      := ''
	Local cFamily    := ''
	Local cConcil    := ''
	Local cSegment   := ''
	Local lCorp      := .F.
	Local lEvento    := .F.
	Local lLazer     := .F.
	Local cBlocked   := ''
	
	//Variaveis da Base Interna
	Local cIntID     := ''
	Local cCodeInt   := ''
	
	//Variaveis da Base Externa
	Local cExtID	:= ''
	Local cCodeExt	:= ''
	Local cAuxIdDet	:= ''
	Local cFopCode	:= ''
	Local aStruct		:= {}
	Local aGrupo		:= {}
	
	Do Case
	Case nTypeTrans == TRANS_SEND
		oModel		:= FwModelActive()
		cModelDef	:= oModel:aModelStruct[1][2]
		aStruct	:= oModel:GetModel(cModelDef):GetStruct():aFields
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt := oModel:GetValue(cModelDef, 'BM_GRUPO')
		cIntID	  := IntFamExt(,,cCodeInt)[2] //TURXMakeId(cCodeInt, 'SBM')
		
		//Monta XML de envio de mensagem unica
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=		'<Entity>' + cMsgUnica + '</Entity>'
		cXMLRet +=		'<Event>' + cEvento + '</Event>'
		cXMLRet +=		'<Identification>'
		cXMLRet += 		'<key name="InternalId">' + cIntID + '</key>'
		cXMLRet += 	'</Identification>'
		cXMLRet += '</BusinessEvent>'
		
		cXMLRet += '<BusinessContent>'
		cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=		'<Code>' + cCodeInt + '</Code>'
		cXMLRet +=		'<InternalId>' + cIntID + '</InternalId>'
		
		IF TxValCpo(aStruct,'BM_DESC') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_DESC'))
			cXMLRet +=		'<Description>' + _NoTags(AllTrim(oModel:GetValue(cModelDef, 'BM_DESC'))) + '</Description>'
		Endif
		
		IF TxValCpo(aStruct,'BM_TIPGRU') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_TIPGRU'))
			cXMLRet +=		'<FamilyType>' + AllTrim(oModel:GetValue(cModelDef, 'BM_TIPGRU')) + '</FamilyType>'
		Endif
		IF TxValCpo(aStruct,'BM_CLASGRU') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_CLASGRU'))
			cXMLRet +=		'<FamilyClassificationCode>' + AllTrim(oModel:GetValue(cModelDef, 'BM_CLASGRU')) + '</FamilyClassificationCode>'
		Endif
		
		IF TxValCpo(aStruct,'BM_CODGRT') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_CODGRT'))
			cXMLRet +=		'<TourismType>' + AllTrim(oModel:GetValue(cModelDef, 'BM_CODGRT')) + '</TourismType>'
		Endif
		IF TxValCpo(aStruct,'BM_CONC') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_CONC'))
			cXMLRet +=		'<Conciliation>' + AllTrim(oModel:GetValue(cModelDef, 'BM_CONC')) + '</Conciliation>'
		Endif
		IF TxValCpo(aStruct,'BM_TPSEGP') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_TPSEGP'))
			cXMLRet +=		'<SegmentType>' + AllTrim(oModel:GetValue(cModelDef, 'BM_TPSEGP')) + '</SegmentType>'
		Endif
		IF TxValCpo(aStruct,'BM_CORP') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_CORP'))
			cXMLRet += 	'<Corporate>' + TurXLogic(oModel:GetValue(cModelDef, 'BM_CORP'), TP_CHAR1_RET) + '</Corporate>'
		Endif
		IF TxValCpo(aStruct,'BM_EVENTO') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_EVENTO'))
			cXMLRet +=		'<Event>' + TurXLogic(oModel:GetValue(cModelDef, 'BM_EVENTO'), TP_CHAR1_RET) + '</Event>'
		Endif
		IF TxValCpo(aStruct,'BM_LAZER') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_LAZER'))
			cXMLRet +=		'<Recreation>' + TurXLogic(oModel:GetValue(cModelDef, 'BM_LAZER'), TP_CHAR1_RET) + '</Recreation>'
		Endif
		IF TxValCpo(aStruct,'BM_MSBLQL') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_MSBLQL'))
			cXMLRet +=		'<Situation>' + TurXLogic(oModel:GetValue(cModelDef, 'BM_MSBLQL'), TP_CHAR1_RET) + '</Situation>'
		Endif
		If lDelete //Exclui o De/Para
			CFGA070MNT(NIL, cAlias, cCampo, , cIntID, lDelete)
		Endif
		
		oModelDet := oModel:GetModel('G3KDETAIL')
		If ValType(oModelDet) == 'O' .and. oModelDet:Length(.t.) > 0
			
			For nX := 1 to oModelDet:Length()
				oModelDet:goline(nX)
				
				cItemCod := oModel:GetValue('G3KDETAIL', 'G3K_CODFOP')
				cDest    := oModel:GetValue('G3KDETAIL', 'G3K_DEST')
				cPerson  := oModel:GetValue('G3KDETAIL', 'G3K_PESSOA')
				cIntID   := TURXMakeId(cItemCod, 'G3N')
				
				//Se Alteração/Inclusão e a linha estiver apagado, não manda Family -- Se for Exclusão manda a linha para controle
				
				If (!oModelDet:IsDeleted() .Or. lDelete ).and. !Empty(cItemCod)
					cXmlItem += '<PaymentForm>'
					cXmlItem +=		'<PaymentFormCode>' + cItemCod + '</PaymentFormCode>'
					cXmlItem +=		'<PaymentFormInternalId>' + cIntID + '</PaymentFormInternalId>'
					cXmlItem +=		'<Destination>' + cDest + '</Destination>'
					cXmlItem +=		'<Person>' + cPerson + '</Person>'
					cXmlItem += '</PaymentForm>'
				Endif
				
			Next
			
		Endif
		
		If !Empty(cXmlItem)
			cXMLRet += '<ListOfPaymentForm>' +cXmlItem+ '</ListOfPaymentForm>'
		endif
		cXMLRet += '</BusinessContent>'
		
	Case nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
		Do Case
			//whois
		Case (cTypeMessage == EAI_MESSAGE_WHOIS)
			cXMLRet := '1.000|2.000|2.001|2.002'
			
			//resposta da mensagem Unica TOTVS
		Case (cTypeMessage == EAI_MESSAGE_RESPONSE)
			If Empty(oXml:Error())
				cMarca	:= oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
				For nX := 1 to oXml:xPathChildCount('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId')
					cName  := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Name')
					cIntID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Origin')
					cExtID := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Destination')
					If !Empty(cIntID) .And. !Empty(cExtID)
						If Upper(Alltrim(cName)) == Alltrim(cMsgUnica)
							CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID)
						Endif
					Endif
				Next
			Endif
			oXml := NIL
			
			//chegada de mensagem de negocios
		Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
			cEvent   := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
			cMarca   := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
			cCodeExt := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Code'))
			cExtID   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
			If (aGrupo := IntFamInt(cExtID, cMarca))[1]
				cCodeInt := PadR(aGrupo[2,3], TamSx3('BM_GRUPO')[1])
			Endif
			
			If Upper(cEvent) == 'UPSERT'
				If !Empty(cCodeInt) .And. SBM->(DbSeek(xFilial('SBM') + cCodeInt))
					cEvent   := MODEL_OPERATION_UPDATE
				Else
					cEvent   := MODEL_OPERATION_INSERT
					cCodeInt := cCodeExt
				Endif
				
			ElseIf Upper(cEvent) == 'DELETE'
				If !Empty(cCodeInt) .And. SBM->(DbSeek(xFilial('SBM') + cCodeInt))
					cEvent  := MODEL_OPERATION_DELETE
					lDelete := .T.
				Else
					lRet    := .F.
					cXmlRet := STR0001 //'Registro não encontrado no Protheus.'
				Endif
			EndIf
			
			If lRet
				If !Empty(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TourismType')))
					nModulo := 89//Garante que o Model Carregado seja do modulo de Turismo
					cModelDef := "SBMMASTER"
				Else
					nModulo := 05
					cModelDef := "MATA035_SBM"
				Endif
				oModel	:= FwLoadModel(cAdapter)
				
				aStruct := oModel:GetModel(cModelDef):GetStruct():aFields
				
				oModel:SetOperation(cEvent)
				If oModel:Activate()
					oModelCab	:= oModel:GetModel(cModelDef)
					oModelDet	:= oModel:GetModel('G3KDETAIL')
					
					If cEvent <> MODEL_OPERATION_DELETE
						If cEvent == MODEL_OPERATION_INSERT
							oModelCab:SetValue('BM_GRUPO', cCodeInt)
						Endif
						
						If TxValCpo(aStruct,'BM_DESC')
							TxGetNdXml(oXml, cBusiCont + '/Description',oModelCab,'BM_DESC' )
						Endif
						If TxValCpo(aStruct,'BM_TIPGRU')
							TxGetNdXml(oXml, cBusiCont + '/FamilyType',oModelCab,'BM_TIPGRU' )
						Endif
						IF TxValCpo(aStruct,'BM_CLASGRU')
							TxGetNdXml(oXml, cBusiCont + '/FamilyClassificationCode',oModelCab,'BM_CLASGRU' )
						Endif
						IF TxValCpo(aStruct,'BM_CODGRT')
							TxGetNdXml(oXml, cBusiCont + '/TourismType',oModelCab,'BM_CODGRT' )
						Endif
						If TxValCpo(aStruct,'BM_CONC')
							TxGetNdXml(oXml, cBusiCont + '/Conciliation',oModelCab,'BM_CONC' )
						Endif
						If TxValCpo(aStruct,'BM_TPSEGP')
							TxGetNdXml(oXml, cBusiCont + '/SegmentType',oModelCab,'BM_TPSEGP' )
						Endif
						If TxValCpo(aStruct,'BM_CORP' )
							TxGetNdXml(oXml, cBusiCont + '/Corporate',oModelCab,'BM_CORP' )
						Endif
						If TxValCpo(aStruct,'BM_EVENTO')
							TxGetNdXml(oXml, cBusiCont + '/Event',oModelCab,'BM_EVENTO' )
						Endif
						If TxValCpo(aStruct,'BM_LAZER')
							TxGetNdXml(oXml, cBusiCont + '/Recreation',oModelCab,'BM_LAZER' )
						Endif
						If TxValCpo(aStruct,'BM_MSBLQL')
							TxGetNdXml(oXml, cBusiCont + '/Situation',oModelCab,'BM_MSBLQL' )
						Endif
					Endif
					cIntID := IntFamExt(,,cCodeInt)[2]
					aAdd(aIntID,{cMsgUnica,cExtID,cIntID,cAlias,cCampo})
				Else
					lRet := .F.
				Endif
				
				If lRet .and. ValType(oModelDet) == "O"
					If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfPaymentForm') ) > 0
						
						For nX := 1 To nCont
							If lRet
								cFopCode  := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/PaymentFormCode')
								cExtIdDet := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/PaymentFormInternalId')
								cDest     := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/Destination')
								cPerson   := oXml:XPathGetNodeValue(cListItens + '[' + cValToChar(nX) + ']/Person')
								cIntID    := ''
								cItemCod  := PadR(AllTrim(TURXRetId(cMarca, 'G3N', 'G3N_CODIGO', cExtIdDet, NIL, 3)), TamSx3('G3K_CODFOP')[1])
								
								If cEvent <> MODEL_OPERATION_DELETE
									// caso seja inserção e não tem DE/PARA da G8R
									// recuperar o código da FORMA DE PAGTO através do DE/PARA da G3N
									
									If !oModelDet:SeekLine({{'G3K_CODFOP', cItemCod},{'G3K_DEST'  , cDest},{'G3K_PESSOA', cPerson}})
										If !Empty(oModelDet:GetValue( 'G3K_CODFOP'))
											nLine := oModelDet:AddLine()
											oModelDet:GoLine(nLine)
										EndIf
										oModelDet:SetValue('G3K_CODFOP', cItemCod)
									EndIf
									oModelDet:SetValue('G3K_DEST'  , cDest)
									oModelDet:SetValue('G3K_PESSOA', cPerson)
								Endif
								
								If 	!oModelDet:VldLineData()
									lRet := .F.
								Else
									aAdd(aDetalhe, cItemCod+cDest+cPerson)
								EndIf
							EndIf
						Next
						
					Endif
					If lRet
						For nX := 1 To oModelDet:Length()
							oModelDet:GoLine(nX)
							If !lDelete .And. aScan(aDetalhe, oModelDet:GetValue('G3K_CODFOP') +oModelDet:GetValue('G3K_DEST') + oModelDet:GetValue('G3K_PESSOA')) == 0
								oModelDet:DeleteLine()
							Endif
						Next
					EndIf
					
				Endif
				
				If lRet .And. oModel:VldData() .And. oModel:CommitData()
					cXmlRet := ""
					For nY := 1 To Len(aIntID)
						If cEvent <> MODEL_OPERATION_DELETE
							cXmlRet+=	'<InternalId>'
							cXmlRet+=		'<Name>'+aIntID[nY][1]+'</Name>'
							cXmlRet+=		'<Origin>'+aIntID[nY][2]+'</Origin>'
							cXmlRet+=		'<Destination>'+aIntID[nY][3]+'</Destination>'
							cXmlRet+=	'</InternalId>'
						Endif
						//							CFGA070MNT( cMarca, cAlias, cCampo, cExtID, cIntID,lDelete)
						CFGA070MNT( cMarca, aIntID[nY][4], aIntID[nY][5], aIntID[nY][2], aIntID[nY][3],lDelete)
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
	
	nModulo := nOldModulo
	
Return {lRet, cXMLRet, cMsgUnica}


/*/{Protheus.doc} IntFamExt
Monta o internalId do Family

@since 19/09/14
@version P11

@params	cEmpresa	- Empresa utilizado na integração
@params	cFil		- Filial utilizada na integração
@params	cFamily	- Código do grupo de produto
@params	cVersao	- Versão da mensagem utilizada

@return	Posicao 1  - LOGICAL - indica o status do processamento
@return	Posicao 2  - CHAR    - Xml/Conteúdo de retorno do processamento
/*/

Function IntFamExt(cEmpresa,cFil,cFamily,cVersao)
	
	Local   aResult  := {}
	
	Default cEmpresa := cEmpAnt
	Default cFil     := xFilial('SBM')
	Default cVersao  := '2.000'
	
	If cVersao == '1.000'
		aAdd(aResult, .T.)
		aAdd(aResult, cFil + cFamily)
	ElseIf cVersao == '2.000' .Or. cVersao == '2.001' .Or. cVersao == '2.002'
		aAdd(aResult, .T.)
		aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cFamily))
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0019 + Chr(10) + STR0020 + " 1.000,2.000,2.001,2.002") //"Versão do grupo de produto não suportada." --- "As versões suportadas são:"
	EndIf
Return aResult

/*/{Protheus.doc} IntFamInt
Busca o internalId do Family

@since 19/09/14
@version P11

@params	cInternalId	- InternalId a ser pesquisado
@params	cRefer			- Marca
@params	cVersao		- Versão da mensagem utilizada

@return	Posicao 1  - LOGICAL - indica o status do processamento
@return	Posicao 2  - CHAR    - Xml/Conteúdo de retorno do processamento
/*/

Function IntFamInt(cInternalID, cRefer, cVersao)
	
	Local   aResult  := {}
	Local   aTemp    := {}
	Local   cTemp    := ''
	Local   cAlias   := 'SBM'
	Local   cField   := 'BM_GRUPO'
	
	Default cVersao  := '2.000'
	
	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
	
	If Empty(cTemp)
		aAdd(aResult, .F.)
		aAdd(aResult, STR0021 + " -> " + cInternalID) //"Grupo de produto não encontrado no de/para!"
	Else
		If cVersao == '1.000'
			aAdd(aResult, .T.)
			aAdd(aTemp,SubStr(cTemp,TamSx3("BM_FILIAL")[1]+1,TamSX3('BM_GRUPO')[1]))
			aAdd(aResult,aTemp)
		ElseIf cVersao == '2.000' .Or. cVersao == '2.001' .Or. cVersao == '2.002'
			aAdd(aResult, .T.)
			aTemp := Separa(cTemp, '|')
			aAdd(aResult,aTemp)
		Else
			aAdd(aResult,.F.)
			aAdd(aResult,STR0019 + Chr(10) + STR0020 + " 1.000,2.000,2.001,2.002") //"Versão do grupo de produto não suportada." --- "As versões suportadas são:"
		EndIf
	EndIf
	
Return aResult
