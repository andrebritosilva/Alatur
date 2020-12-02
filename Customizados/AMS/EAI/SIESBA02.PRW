#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SIESBA02   ºAutor  ³Microsiga          º Data ³  28/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Receptor de EAI - Cadastro de Fornecedores                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 11.5 - Sistema Industria                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SIESBA02(_cXML,_nOpc)
Local _cError    := ""
Local _cWarning  := ""
Local _cDelimit  := "_"
Local aStru      := {}
Local _lInput    := GetRemoteType() == -1 //-1 = sem remote/ 0 = delphi/ 1 = QT windows/ 2 = QT Linux
Default _cXML    := ""                            

IF _lInput // Chamada via ESB/EAI
Conout(_cXML)         

	SZZ->(dbSetOrder(1))
	IF SZZ->(dbSeek(XFilial("SZZ")+"MATA020")).And. (SZZ->ZZ_TPINT == '1' ) //Se existe a integracao e se ha a opção for somente envio.         
		Return()  // Encerra e Sai.
	ENDIF	
    
	//Gera o Objeto XML com a estrutura recebida
	oXml := XmlParser(_cXML, _cDelimit, @_cError, @_cWarning)
	
	//Verifica se a estrutura foi criada
	IF !(Empty(_cError) .and. Empty(_cWarning))
		Return()
	ENDIF
	
	_nOperac := Val(oXml:_MATA020:_OPERATION:TEXT)
	_cIDESB  := IIF(Type("oXml:_MATA020:_SA2MASTER:_A2_XIDESB:REALNAME") <> "U",&("oXml:_MATA020:_SA2MASTER:_A2_XIDESB:_VALUE:TEXT"),"")
	
	// Verifica se mensagem trata-se de fornecedores
	IF Type('oXml:_MATA020:_SA2MASTER') == "U"
		_cMotivo := "Mensagem invalida para a rotina MATA020 - Fornecedores"
		// Gera XML de retorno
		U_SIXMLMSG("MATA020","Fornecedores",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
		Return()
	ENDIF
	
	SX3->(dbSetOrder(1))
	SX3->(dbGoTop())
	SX3->(dbSeek("SA2"))
	
	// Carrega vetor com os campos
	While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == "SA2"
		IF Type("oXml:_MATA020:_SA2MASTER:_"+Alltrim(SX3->X3_CAMPO)+":REALNAME") <> "U"
			// Carrega conteudo do variavel
			_cCampo := &("oXml:_MATA020:_SA2MASTER:_"+Alltrim(SX3->X3_CAMPO)+":_VALUE:TEXT")
			
			// Faz tratamento do dado
			IF SX3->X3_TIPO == "C"
				_cCampo := PadR(_cCampo,SX3->X3_TAMANHO)
			ELSEIF SX3->X3_TIPO == "N"
				_cCampo := Val(_cCampo)
			ELSEIF SX3->X3_TIPO == "D"
				_cCampo := Stod(_cCampo)
			ENDIF
			IF SX3->X3_CONTEXT == "V"
				Loop
				SX3->(dbSkip())
			ENDIF
			
			// Carrega vetor para rotina automatica
			aAdd( aStru, {Alltrim(SX3->X3_CAMPO),_cCampo, NIL } )
		ENDIF
		SX3->(dbSkip())
	Enddo
	
	// Nenhum campo localizado
	IF Len(aStru) == 0
		Return()
	ENDIF
	
	INCLUI         := .T.
	lMsErroAuto    := .F.
	lMsHelpAuto    := .T.
	lAutoErrNoFile := .T.
	
//	Begin Transaction
	MSExecAuto( { | x, y | MATA020( x, y ) }, aStru, _nOperac )

	If lMsErroAuto
		If (__lSX8)
			RollBackSX8()
		EndIf
		
		DisarmTransaction()
		
		// Tratamento da Mensagem de erro do MSExecAuto
		aLogErr  := GetAutoGRLog()
		aLogErr2 := U_SIESBID(aLogErr)
		_cMotivo := ""
		
		For i := 1 to Len(aLogErr2)
			_cMotivo += aLogErr2[i]
		Next
		
		// Gera XML de retorno
		U_SIXMLMSG("MATA020","Fornecedores",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
		
		Break
	Else
		If (__lSX8)
			ConfirmSX8()
		EndIf
		
		// Gera XML de retorno
		U_SIXMLMSG("MATA020","Fornecedores",Alltrim(Str(_nOperac)),_cIDESB,"0","")
		
	EndIf
//	End Transaction
ELSE // Chamada via SmartClient
	
	_cData     := Dtos(Date())
	_cTime     := Time()
	_cDateTime := Transform(_cData,"@R 9999-99-99")+"T"+_cTime+"Z"
	_cOper     := Alltrim(Str(_nOpc))
	_cFile     := "MATA020"+_cOper+_cData+StrTran(_cTime,":","")+".XML"
	
	// Verifica tipo de operacao
	IF _cOper == "0"
		Return()
	ENDIF
	
	dbSelectArea("SA2")
	
	// Montagem das tags do XML
	_cXML += '<TOTVSIntegrator>'
	_cXML += '<GlobalProduct>TOTVS|ESB</GlobalProduct>'
	_cXML += '<GlobalFunctionCode>EAI</GlobalFunctionCode>'
	_cXML += '<GlobalDocumentFunctionCode>MATA020</GlobalDocumentFunctionCode>'
	_cXML += '<GlobalDocumentFunctionDescription>Cadastro de Fornecedores</GlobalDocumentFunctionDescription>'
	_cXML += '<DocVersion>1.0</DocVersion>'
	_cXML += '<DocDateTime>'+_cDateTime+'</DocDateTime>'
	_cXML += '<DocIdentifier></DocIdentifier>'
	_cXML += '<DocCompany>'+cEmpAnt+'</DocCompany>'
	_cXML += '<DocBranch>'+cFilAnt+'</DocBranch>'
	_cXML += '<DocName></DocName>'
	_cXML += '<DocFederalID></DocFederalID>'
	_cXML += '<DocType>2</DocType>'
	_cXML += '<Message>'
	_cXML += '<Layouts>'
	_cXML += '<Identifier>MATA020</Identifier>'
	_cXML += '<Version>1.0</Version>'
	_cXML += '<FunctionCode></FunctionCode>'
	_cXML += '<Content>'
	_cXML += '<MATA020 Operation="'+_cOper+'" version="1.01">'
	_cXML += '<SA2MASTER modeltype="FIELDS" >'
	
	// Montagem das TAGs
	For i := 1 To FCount()
		_cXML += '<'+FieldName(i)+' order="'+Alltrim(Str(i))+'">'    
		If Type(FieldName(i)) = "D" 
			_cXML += '<value>'+DTOS((&("SA2->"+FieldName(i))))+'</value>' 
		Else
			_cXML += '<value>'+Alltrim(CValtoChar(&("SA2->"+FieldName(i))))+'</value>'
		Endif
		_cXML += '</'+FieldName(i)+'>'
	Next
	
	_cXML += '</SA2MASTER>'
	_cXML += '</MATA020>'
	_cXML += '</Content>'
	_cXML += '</Layouts>'
	_cXML += '</Message>'
	_cXML += '</TOTVSIntegrator>'
	
	// Geração do arquivo
	U_SIXMLDATA(_cXML,_cFile,"MATA020","Fornecedores")
	
ENDIF

Return()
