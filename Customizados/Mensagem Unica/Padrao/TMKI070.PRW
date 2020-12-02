#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMKI070

Função de integração do Cadastro de contatos
Mensagem Única - Contact

@sample	TMKI070(cXml, cTypeTrans, cTypeMessage)
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
@since		28/09/2015
@version 	P12.1.8
/*/
//------------------------------------------------------------------------------------------
Function TMKI070(cXml, nTypeTrans, cTypeMessage)

	Local lRet      := .T.
	Local cEvento   := 'upsert'
	Local cMsgUnica := 'Contact'
	Local cMarca    := 'PROTHEUS'
	Local cAlias    := 'SU5'
	Local cCampo    := 'U5_CODCONT'
	Local oXML      := tXMLManager():New()
	Local oModel    := NIL
	Local oModelCab := NIL
	Local cBusiCont := '/TOTVSMessage/BusinessMessage/BusinessContent'
	Local cXmlRet   := ''
	Local cXmlComm  := ""
	Local aErro     := {}
	Local nX
	Local lDelete
	Local lMsblql	:= AllTrim(GetSx3Cache("U5_MSBLQL", "X3_CAMPO")) == "U5_MSBLQL" //FieldPos('SU5_MSBLQL') > 0
	Local nOpc    := 0
	//Variaveis DE/PARA
	Local cIntID    := ''
	Local cExtID    := ''
	Local aContato	:= nil
	//Variaveis de controle
	Local cCodeInt  := ''
	Local cThreadLog:= cValToChar(Randomize(0,100000))+"_"
	Local cTimeIni	:= Time()
	Local lBlind	:= IsBlind()

	Private lMsErroAuto    	:= .F.
	Do Case
		Case nTypeTrans == TRANS_SEND
		oModel := FwModelActive()

		If lDelete := !ALTERA .AND. !INCLUI
			cEvento := 'delete'
		EndIf

		cIntID	  := TURXMakeId(SU5->U5_CODCONT, 'SU5')

		//Monta XML de envio de mensagem unica
		cXMLRet := FWEAIBusEvent( cMsgUnica,IF(lDelete,5,3), { { "InternalId", cIntID } } )

		cXMLRet +=	'<BusinessContent>'
		cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=		'<Code>' + ALLTRIM(SU5->U5_CODCONT) + '</Code>'
		cXMLRet +=		'<InternalId>' + ALLTRIM(cIntID) + '</InternalId>'
		cXMLRet +=		'<Name>'+ALLTRIM(SU5->U5_CONTAT)+'</Name>'
		cXMLRet +=		'<GovernmentalInformation>'
		cXMLRet +=			'<Id name="CPF" scope="Federal">'+Alltrim(SU5->U5_CPF)+'</Id>'
		cXMLRet +=		'</GovernmentalInformation>'
		cXMLRet +=		'<Address>'
		cXMLRet +=			'<Address>'+ALLTRIM(SU5->U5_END)+'</Address>'
		cXMLRet +=			'<City>'
		cXMLRet +=				'<CityCode>'+ALLTRIM(SU5->U5_MUN)+'</CityCode>'
		cXMLRet +=				'<CityInternalId>'+ALLTRIM(SU5->U5_MUN)+'</CityInternalId>'
		cXMLRet +=				'<CityDescription>'+ALLTRIM(SU5->U5_MUN)+'</CityDescription>'
		cXMLRet +=			'</City>'
		cXMLRet +=			'<District>'+ALLTRIM(SU5->U5_BAIRRO)+'</District>'
		cXMLRet +=			'<State>'
		cXMLRet +=				'<StateCode>'+ALLTRIM(SU5->U5_EST)+'</StateCode>'
		cXMLRet +=				'<StateInternalId>'+ALLTRIM(SU5->U5_EST)+'</StateInternalId>'
		cXMLRet +=				'<StateDescription>'+Alltrim(POSICIONE("SX5",1,xFilial("SX5")+"12"+SU5->U5_EST,"X5_DESCRI"))+'</StateDescription>'
		cXMLRet +=			'</State>'
		cXMLRet +=			'<Country>'
		cXMLRet +=				'<CountryCode>'+ALLTRIM(SU5->U5_PAIS)+'</CountryCode>'
		cXMLRet +=				'<CountryInternalId>'+ALLTRIM(SU5->U5_PAIS)+'</CountryInternalId>'
		cXMLRet +=			'</Country>'
		cXMLRet +=			'<ZIPCode>'+ALLTRIM(SU5->U5_CEP)+'</ZIPCode>'
		cXMLRet +=		'</Address>'

		If !Empty(SU5->U5_FONE)
			cXmlComm +=	'<CommunicationInformation>'
			cXmlComm +=		'<Type>2</Type>'
			cXmlComm +=		'<PhoneNumber>'+ Alltrim(SU5->U5_CODPAIS)+ Alltrim(SU5->U5_DDD)+ Alltrim(SU5->U5_FONE)+ '</PhoneNumber>'
			cXmlComm +=	'</CommunicationInformation>'
		Endif

		If !Empty(SU5->U5_FCOM1)
			cXmlComm +=	'<CommunicationInformation>'
			cXmlComm +=		'<Type>'+"1"+'</Type>'
			cXmlComm +=		'<PhoneNumber>'+Alltrim(SU5->U5_CODPAIS)+Alltrim(SU5->U5_DDD)+Alltrim(SU5->U5_FCOM1)+'</PhoneNumber>'
			cXmlComm +=	'</CommunicationInformation>'
		Endif

		If !Empty(SU5->U5_CELULAR)
			cXmlComm +=	'<CommunicationInformation>'
			cXmlComm +=		'<Type>'+"5"+'</Type>'
			cXmlComm +=		'<PhoneNumber>'+Alltrim(SU5->U5_CODPAIS)+Alltrim(SU5->U5_DDD)+Alltrim(SU5->U5_CELULAR)+'</PhoneNumber>'
			cXmlComm +=	'</CommunicationInformation>'
		Endif

		If !Empty(SU5->U5_EMAIL)	 .or. !Empty(SU5->U5_URL)
			cXmlComm +=	'<CommunicationInformation>'
			cXmlComm +=		'<HomePage>'+Alltrim(SU5->U5_URL)+'</HomePage>'
			cXmlComm +=		'<Email>'+Alltrim(SU5->U5_EMAIL)+'</Email>'
			cXmlComm +=	'</CommunicationInformation>'
		Endif

		If !Empty(cXmlComm)
			cXMLRet +=	 '<ListOfCommunicationInformation>'+cXmlComm+'</ListOfCommunicationInformation>'
		Endif
		cXMLRet +=		'<Treatment>'+ALLTRIM(SU5->U5_TRATA)+'</Treatment>'
		cXMLRet +=		'<Gender>'+ALLTRIM(SU5->U5_SEXO)+'</Gender>'
		cXMLRet +=		'<Birthday>'+TxDtStamp(SU5->U5_NIVER)+'</Birthday>'
		cXMLRet +=		'<Requester>'+ALLTRIM(SU5->U5_SOLICTE)+'</Requester>'
		If lMsblql
			cXMLRet +=		'<Situation>' + ALLTRIM(SU5->U5_MSBLQL) + '</Situation>'
		Endif

		If ExistBlock("TMKI070SE")
			cXmlPERet := ExecBlock("TMKI070SE",.F.,.F.,{cXMLRet,cEvento})
			If ValType(cXmlPERet) == "C"
				cXMLRet +=cXmlPERet
			EndIf
		EndIf

		cXMLRet +=	'</BusinessContent>'

		//Exclui o De/Para
		If lDelete
			CFGA070MNT(NIL, cAlias, cCampo, NIL, cIntID, lDelete)
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
			cEvento  := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
			cMarca   := AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))

			cExtID   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
			cIntId	:= ""
			cCodeInt := PadR(AllTrim(TURXRetId(cMarca, cAlias, cCampo, cExtID, @cIntID, 3)), TamSx3('U5_CODCONT')[1])

			If Upper(cEvento) == 'UPSERT'
				If SU5->(DbSeek(xFilial('SU5') + cCodeInt))
					nOpc := 4
				Else
					nOpc := 3
					cCodeInt := NewNumCont() //AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Code'))
					cIntID   := TURXMakeId(cCodeInt, 'SU5')
				Endif
			ElseIf Upper(cEvento) == 'DELETE'
				If SU5->(DbSeek(xFilial('SU5') + cCodeInt))
					nOpc := 5
				Else
					lRet    := .F.
					cXmlRet := STR0001 		// "Registro não encontrado no Protheus."
				Endif
			EndIf

			If lRet
				aContato := {}
				aAdd(aContato,{"U5_FILIAL"	,xFilial('SU5')														,nil})
				aAdd(aContato,{"U5_CODCONT"	,cCodeInt															,nil})
				aAdd(aContato,{"U5_CONTAT"	,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Name'))  				,nil})
				aAdd(aContato,{"U5_CPF"		,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/GovernmentalInformation/Id'))  	,nil})
				aAdd(aContato,{"U5_END"		,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Address/Address'))				,nil})
				aAdd(aContato,{"U5_BAIRRO"	,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Address/District'))				,nil})
				aAdd(aContato,{"U5_CEP"		,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Address/ZIPCode'))				,nil})
				aAdd(aContato,{"U5_MUN"		,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Address/City/CityCode'))		,nil})
				aAdd(aContato,{"U5_EST"		,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Address/State/StateCode'))		,nil})
				aAdd(aContato,{"U5_PAIS"		,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Address/Country/CountryCode'))	,nil})

				If (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfCommunicationInformation') ) > 0
					For nX := 1 To nCont
						cListItens	:=cBusiCont + '/ListOfCommunicationInformation/CommunicationInformation'+ '[' + cValToChar(nX) + ']'
						If oXml:XPathHasNode(cListItens+'/Type')
							cType  := Alltrim(oXml:XPathGetNodeValue(cListItens+'/Type'))
							cTelefone := AllTrim(oXml:XPathGetNodeValue(cListItens+'/PhoneNumber'))
							aTelefone := RemDddTel(cTelefone)

							If cType == "1"
								aAdd(aContato,{"U5_FCOM1",AllTrim(aTelefone[1])	,nil})
							ElseIf cType == '2'
								aAdd(aContato,{"U5_FONE"	,AllTrim(aTelefone[1])  	,nil})
							ElseIf cType == '5'
								aAdd(aContato,{"U5_CELULAR"	,AllTrim(aTelefone[1])   	,nil})
							Endif

							IF !Empty(aTelefone[2])
								aAdd(aContato,{"U5_DDD"		,AllTrim(aTelefone[2]) 	,nil})
							Endif
							IF !Empty(aTelefone[3])
								aAdd(aContato,{"U5_DDI"		,AllTrim(aTelefone[3]) 	,nil})
							Endif

						Endif

						If oXml:XPathHasNode(cListItens+'/Email')
							aAdd(aContato,{"U5_EMAIL"	,upper(AllTrim(oXml:XPathGetNodeValue(cListItens+'/Email')))           	,nil})
						Endif
						If oXml:XPathHasNode(cListItens+'/HomePage')
							aAdd(aContato,{"U5_URL"	,AllTrim(oXml:XPathGetNodeValue(cListItens+'/HomePage'))           	,nil})
						Endif

					Next
				Endif

				aAdd(aContato,{"U5_TRATA"	,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Treatment'))       	,nil})
				aAdd(aContato,{"U5_SEXO"	,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Gender'))          	,nil})
				aAdd(aContato,{"U5_NIVER"	,TxDtStamp(oXml:XPathGetNodeValue(cBusiCont + '/Birthday'),.F.)     ,nil})
				aAdd(aContato,{"U5_SOLICTE"	,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Requester'))       	,nil})
				If lMsblql
					aAdd(aContato,{"U5_MSBLQL"	,AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Situation'))    	,nil})
				Endif

				// ponto de entrada inserido para controlar dados especificos do cliente
				If ExistBlock("TMKI070RE")
					aRetPe := ExecBlock("TMKI070RE",.F.,.F.,{aContato,nOpc,oXml})
					If ValType(aRetPe) == "A" .And. ValType(aRetPe[1]) == "A"
						aContato 	:= aClone(aRetPe)
					EndIf
				EndIf
				aContato := OrdenaArray(aContato)

				If InTransaction()
					DisarmTransaction()
				EndIf

				MSExecAuto({|x,y,z|TMKA070(x,y,,,z)},aContato,nOpc,.T.)
				TxDestroy(aContato)
				If lMsErroAuto
					If lBlind
						cErro := MostraErro()
					Else
						cErro := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
						//ConOut("MostraErro: "+ cError)
					EndIf
					IF !Empty(cErro)
						cXmlRet := "<![CDATA[" + Alltrim(cErro) + "]]>"
					Else
						cXmlRet := "<![CDATA[" + 'FALHA NA INTEGRACAO' + "]]>"
					Endif
					DisarmTransaction()
					lRet := .F.
				Endif
				If lRet
					CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID,nOpc == 5 )
					If nOpc <> 5
						cXmlRet +=	'<ListOfInternalId>'
						cXmlRet +=		'<InternalId>'
						cXmlRet +=			'<Name>' + cMsgUnica + '</Name>'
						cXmlRet +=			'<Origin>' + cExtID + '</Origin>'
						cXmlRet +=			'<Destination>' + cIntID + '</Destination>'
						cXmlRet += 		'</InternalId>'
						cXmlRet +=	'</ListOfInternalId>'
					Else
						cXmlRet := ''
					Endif
				Endif
			EndIf
		EndCase
	EndCase
	TxDestroy(oXml)
	TxTraceLog(,cThreadLog,cTimeIni)

Return {lRet, cXMLRet, cMsgUnica}

/*/{Protheus.doc} OrdenaArray
Ordena o array da rotina automatica para a ordem definida
no dicionario de dados

@param   aArray		Array a ser ordenado

@author  Jacomo Lisa
@version P12
@since   29/04/2016
@return  aArray - Array retornado conforme dicionario  de dados
/*/

Static Function OrdenaArray(aArray)

	Local aRet		:= {}
	Local aAux		:= {}
	Local nI		:= 0
	Local nPos		:= 0

	For nI := 1 To Len(aArray)
		aAdd(aAux,{aArray[nI,1],X3Ordem(aArray[nI,1])})
	Next nI

	aAux := aSort(aAux,,,{|x,y| x[2] < y[2]})

	For nI := 1 To Len(aAux)
		nPos := aScan(aArray,{|x| AllTrim(x[1]) == aAux[nI,1]})
		If nPos > 0
			aAdd(aRet,{aArray[nPos,1],aArray[nPos,2],aArray[nPos,3]})
		Endif
	Next nI
	aSize(aAux,0)
	aAux := Nil
Return aRet

/*/{Protheus.doc} X3Ordem
Busca a ordem do campo no dicionario de dados

@param   cCampo        Campo a ser verificado

@author  Jacomo Lisa
@version P12
@since   29/04/2016
@return  aArray - Array retornado conforme dicionario  de dados
/*/
Static Function X3Ordem(cCampo)

	Local aArea	:= GetArea()
	Local nOrdem	:= 0

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(cCampo))
		nOrdem := SX3->X3_ORDEM
	Endif

	RestArea(aArea)

Return
