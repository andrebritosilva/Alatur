#INCLUDE "PROTHEUS.CH"
                                                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIESBA37   บAutor  ณMicrosiga          บ Data ณ  13/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Receptor de EAI - Baixa a Receber                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP 11.5 - Sistema Industria                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//User Function SIESBA23(_cXML,cXMLError)
User Function SIESBA37(_cXML)
Local _cError    := ""
Local _cWarning  := ""
Local _cDelimit  := "_"
Local aStru      := {}
Local _lInput    := GetRemoteType() == -1 //-1 = sem remote/ 0 = delphi/ 1 = QT windows/ 2 = QT Linux
Default _cXML    := ""
Conout(_cXML)
IF _lInput // Chamada via ESB/EAI
	
	//Gera o Objeto XML com a estrutura recebida
	oXml := XmlParser(_cXML, _cDelimit, @_cError, @_cWarning)
	
	//Verifica se a estrutura foi criada
	IF !(Empty(_cError) .and. Empty(_cWarning))   
		//cXMLError := _cError     
		_cMotivo := "Verifique a estrutura do arquivo FINA080 - Baixas a Pagar"    
		U_SIXMLMSG("FINA080","Baixas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
//		Break	
		Return()
	ENDIF
	
	_nOperac := Val(oXml:_FINA080:_OPERATION:TEXT)
	_cIDESB  := IIF(Type("oXml:_FINA080:_SE2MASTER:_E2_XIDESB:REALNAME") <> "U",&("oXml:_FINA080:_SE2MASTER:_E2_XIDESB:_VALUE:TEXT"),"")
	
	// Verifica se mensagem trata-se de Produto x Fornecedor
	IF Type('oXml:_FINA080:_SE2MASTER') == "U"
		_cMotivo := "Mensagem invalida para a rotina FINA080 - Baixa a Pagar"   
        //cXMLError:= _cMotivo
		// Gera XML de retorno
		U_SIXMLMSG("FINA080","Baixas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
  //		Break
		Return()
	ENDIF
	
	_cPrefixo := IIF(Type("oXml:_FINA080:_SE2MASTER:_E2_PREFIXO") == "U","",oXml:_FINA080:_SE2MASTER:_E2_PREFIXO:_VALUE:TEXT)
	_cNum     := IIF(Type("oXml:_FINA080:_SE2MASTER:_E2_NUM") == "U","",oXml:_FINA080:_SE2MASTER:_E2_NUM:_VALUE:TEXT)
	_cParcela := IIF(Type("oXml:_FINA080:_SE2MASTER:_E2_PARCELA") == "U","",oXml:_FINA080:_SE2MASTER:_E2_PARCELA:_VALUE:TEXT)
	_cTipo    := IIF(Type("oXml:_FINA080:_SE2MASTER:_E2_TIPO") == "U","",oXml:_FINA080:_SE2MASTER:_E2_TIPO:_VALUE:TEXT)
	_cFornece := IIF(Type("oXml:_FINA080:_SE2MASTER:_E2_FORNECE") == "U","",oXml:_FINA080:_SE2MASTER:_E2_FORNECE:_VALUE:TEXT)
	_cLoja    := IIF(Type("oXml:_FINA080:_SE2MASTER:_E2_LOJA") == "U","",oXml:_FINA080:_SE2MASTER:_E2_LOJA:_VALUE:TEXT)
	_cMotBx   := IIF(Type("oXml:_FINA080:_SE2MASTER:_AUTMOTBX") == "U","",oXml:_FINA080:_SE2MASTER:_AUTMOTBX:_VALUE:TEXT)
	_cBanco   := IIF(Type("oXml:_FINA080:_SE2MASTER:_AUTBANCO") == "U","",oXml:_FINA080:_SE2MASTER:_AUTBANCO:_VALUE:TEXT)
	_cAgencia := IIF(Type("oXml:_FINA080:_SE2MASTER:_AUTAGENCIA") == "U","",oXml:_FINA080:_SE2MASTER:_AUTAGENCIA:_VALUE:TEXT)
	_cConta   := IIF(Type("oXml:_FINA080:_SE2MASTER:_AUTCONTA") == "U","",oXml:_FINA080:_SE2MASTER:_AUTCONTA:_VALUE:TEXT)
	_dDtBaixa := IIF(Type("oXml:_FINA080:_SE2MASTER:_AUTDTBAIXA") == "U",dDataBase,Stod(oXml:_FINA080:_SE2MASTER:_AUTDTBAIXA:_VALUE:TEXT))
	_dDtCred  := IIF(Type("oXml:_FINA080:_SE2MASTER:_AUTDTCREDITO") == "U",dDataBase,Stod(oXml:_FINA080:_SE2MASTER:_AUTDTCREDITO:_VALUE:TEXT))
	_cHist    := IIF(Type("oXml:_FINA080:_SE2MASTER:_AUTHIST") == "U","",oXml:_FINA080:_SE2MASTER:_AUTHIST:_VALUE:TEXT)
	_nDescont := IIF(Type("oXml:_FINA080:_SE2MASTER:_AUTDESCONT") == "U",0,Val(oXml:_FINA080:_SE2MASTER:_AUTDESCONT:_VALUE:TEXT))
	_nMulta   := IIF(Type("oXml:_FINA080:_SE2MASTER:_AUTMULTA") == "U",0,Val(oXml:_FINA080:_SE2MASTER:_AUTMULTA:_VALUE:TEXT))
	_nJuros   := IIF(Type("oXml:_FINA080:_SE2MASTER:_AUTJUROS") == "U",0,Val(oXml:_FINA080:_SE2MASTER:_AUTJUROS:_VALUE:TEXT))
	_nValPag  := IIF(Type("oXml:_FINA080:_SE2MASTER:_AUTVALPAG") == "U",0,Val(oXml:_FINA080:_SE2MASTER:_AUTVALPAG:_VALUE:TEXT))
	_cXIDEAI  := IIF(Type("oXml:_FINA080:_SE2MASTER:_E2_XIDEAI") == "U","",oXml:_FINA080:_SE2MASTER:_E2_XIDEAI:_VALUE:TEXT)

	
	// Verifica faltam campos do cabecalho
	//IF Empty(_cNum) .or. Empty(_cTipo) .or. Empty(_cCliente) .or. Empty(_cLoja) .or. Empty(_cMotBx) .or. Empty(_cBanco) .or. Empty(_cAgencia) .or. Empty(_cConta) .or. _nValRec == 0 
	IF Empty(_cNum) .or. Empty(_cTipo) .or. Empty(_cFornece) .or. Empty(_cLoja) .or. Empty(_cMotBx)  .or. _nValPag == 0
		_cMotivo := "Alguns campos do cabecalho nao foram informados. Verifique!"   
		 //cXMLError:= _cMotivo
		// Gera XML de retorno
		U_SIXMLMSG("FINA080","Baixas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)   
	//	Break
		Return()
	ELSE
		
		_cFornece := Padr(_cFornece,TamSX3("E2_FORNECE")[1])
		_cLoja	  := Padr(_cLoja,TamSX3("E2_LOJA")[1])
		_cPrefixo := Padr(_cPrefixo,TamSX3("E2_PREFIXO")[1])
		_cNum	  := Padr(_cNum,TamSX3("E2_NUM")[1])
		_cParcela := Padr(_cParcela,TamSX3("E2_PARCELA")[1])
		_cTipo	  := Padr(_cTipo,TamSX3("E2_TIPO")[1])
		_cBanco	  := Padr(_cBanco,TamSX3("E2_PORTADO")[1])  
		_cAgencia := Padr(_cAgencia,TamSX3("A6_AGENCIA")[1])
 		_cConta	  := Padr(_cConta,TamSX3("A6_NUMCON")[1])
	//	_cAgencia := Padr(_cAgencia,TamSX3("E1_AGEDEP")[1])
	//	_cConta	  := Padr(_cConta,TamSX3("E1_CONTA")[1])

		
		SE2->(dbSetOrder(6))
		IF !SE2->(dbSeek(XFilial("SE2")+_cFornece+_cLoja+_cPrefixo+_cNum+_cParcela+_cTipo))
			_cMotivo := "O titulo informado nao foi localizado. Verifique!"       
	        //cXMLError:= _cMotivo
			// Gera XML de retorno
			U_SIXMLMSG("FINA080","Baixas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
	  //		Break
			Return()
		ENDIF             
		
		//Valida Banco
		If !Empty(_cBanco)
			SA6->(dbSetOrder(1))
			IF !SA6->(dbSeek(xFilial("SA6")+_cBanco+_cAgencia+_cConta))
				_cMotivo :="Cadastro de Banco nao encontrado.Registro:"+xFilial("SA6")+_cBanco+_cAgencia+_cConta
				U_SIXMLMSG("FINA080","Baixas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
		//		Break
				Return()
			Endif	
		Endif	
		                        
		ConOut( "SIESBA37 - " + DTOC( Date() ) + " " + Time() + " "+xFilial("SA6")+_cBanco+_cAgencia+_cConta + Replicate('-',40) ) 
		ConOut( "SIESBA37 - " + DTOC( Date() ) + " " + Time() + " "+SA6->A6_FILIAL+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON + Replicate('-',40)  )
		Conout( "SIESBA37 - " + DTOC( Date() ) + " " + Time() + " Modulo: " + cModulo ) 
		Conout( "SIESBA37 - " + DTOC( Date() ) + " " + Time() + " Filial: " + cfilant )
		
		aStru := {}
		AADD( aStru, { 'E2_PREFIXO'  , SE2->E2_PREFIXO	, Nil } )	// Prefixo
		AADD( aStru, { 'E2_NUM'  	 , SE2->E2_NUM		, Nil } )	// Numero do titulo
		AADD( aStru, { 'E2_PARCELA'  , SE2->E2_PARCELA	, Nil } )	// Parcela
		AADD( aStru, { 'E2_TIPO'  	 , SE2->E2_TIPO		, Nil } )	// Tipo
		AADD( aStru, { 'E2_FORNECE'  , SE2->E2_FORNECE	, Nil } )	// Fornecedor
		AADD( aStru, { 'E2_LOJA'  	 , SE2->E2_LOJA		, Nil } )	// Loja
		AADD( aStru, { 'AUTMOTBX' 	 , _cMotBx	   		, Nil } )	// Motivo da Baixa
		AADD( aStru, { 'AUTBANCO' 	 , _cBanco			, Nil } )	// Banco
		AADD( aStru, { 'AUTAGENCIA'  , _cAgencia		, Nil } )	// Agencia
		AADD( aStru, { 'AUTCONTA'    , _cConta			, Nil } )	// Conta
		AADD( aStru, { 'AUTDTBAIXA'  , _dDtBaixa		, Nil } )	// Data da Baixa
		AADD( aStru, { 'AUTDTCREDITO', _dDtCred			, Nil } )	// Data do Credito
		AADD( aStru, { 'AUTHIST'     , _cHist			, Nil } )	// Historico da Baixa
		AADD( aStru, { 'AUTDESCONT'  , _nDescont		, Nil , .t. } )	// Desconto
		AADD( aStru, { 'AUTMULTA'    , _nMulta			, Nil , .t. } )	// Multa
		AADD( aStru, { 'AUTJUROS'    , _nJuros			, Nil , .t. } )	// Juros
		AADD( aStru, { 'AUTVALPAG'   , _nValPag			, Nil , .t. } )	// Valor Pago
		AADD( aStru, { 'E2_XIDEAI'    , _cXIDEAI		, Nil } )	// IdentificacAO eai
		
	ENDIF        
	dbSelectArea("SM0")
	dbSeek(cEmpAnt+cFiLANT,.T.)
	conout(cFilAnt)                                    
	conout(SM0->M0_CODFIL)
	
	if CarregaSa6(@_cBanco,,,.T.)
		conout("achou o banco")
	else
		conout("nao achou o banco")
	endif
	
	INCLUI         := .T.
	lMsErroAuto    := .F.
	lMsHelpAuto    := .T.
	lAutoErrNoFile := .T.
	
//	Begin Transaction
	
	ConOut( "SIESBA37 - Antes Execauto" + DTOC( Date() ) + " " + Time() + " "+xFilial("SA6")+_cBanco+_cAgencia+_cConta + Replicate('-',40) ) 
	ConOut( "SIESBA37 - Antes Execauto" + DTOC( Date() ) + " " + Time() + " "+SA6->A6_FILIAL+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON + Replicate('-',40))
	Conout( "SIESBA37 - Antes Execauto" + DTOC( Date() ) + " " + Time() + " Modulo: " + cModulo ) 
	Conout( "SIESBA37 - Antes Execauto" + DTOC( Date() ) + " " + Time() + " Filial: " + cfilant )
	                           
	CMODULO:="FIN"       
	
	MSExecAuto( { | x, y | FINA080( x, y ) }, aStru, _nOperac )                        
	
	ConOut( "SIESBA37 - Depois Execauto" + DTOC( Date() ) + " " + Time() + " "+xFilial("SA6")+_cBanco+_cAgencia+_cConta + Replicate('-',40) ) 
	ConOut( "SIESBA37 - Depois Execauto" + DTOC( Date() ) + " " + Time() + " "+SA6->A6_FILIAL+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON + Replicate('-',40) )
	Conout( "SIESBA37 - Depois Execauto" + DTOC( Date() ) + " " + Time() + " Modulo: " + cModulo ) 
	Conout( "SIESBA37 - Depois Execauto" + DTOC( Date() ) + " " + Time() + " Filial: " + cfilant )
	
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
		U_SIXMLMSG("FINA080","Baixas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
		//cXMLError := _cMotivo		
		Break
	Else
		If (__lSX8)
			ConfirmSX8()
		EndIf
		
		// Gera XML de retorno
		U_SIXMLMSG("FINA080","Baixas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"0","")
		
	EndIf
//	End Transaction
	
ELSE // Chamada via SmartClient
	
	_cData     := Dtos(Date())
	_cTime     := Time()
	_cDateTime := Transform(_cData,"@R 9999-99-99")+"T"+_cTime+"Z"
	_cFile     := "FINA080"+"3"+_cData+StrTran(_cTime,":","")+".XML"
	_dDtCred   := DataValida(dDatabase,.T.)                   
	
	// Montagem das tags do XML
	_cXML += '<TOTVSIntegrator>'
	_cXML += '<GlobalProduct>TOTVS|ESB</GlobalProduct>'
	_cXML += '<GlobalFunctionCode>EAI</GlobalFunctionCode>'
	_cXML += '<GlobalDocumentFunctionCode>FINA080</GlobalDocumentFunctionCode>'
	_cXML += '<GlobalDocumentFunctionDescription>Baixa a Pagar</GlobalDocumentFunctionDescription>'
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
	_cXML += '<Identifier>FINA080</Identifier>'
	_cXML += '<Version>1.0</Version>'
	_cXML += '<FunctionCode>U_SIESBA37</FunctionCode>'
	_cXML += '<Content>'
	_cXML += '<FINA080 Operation="3" version="1.01">'
	_cXML += '<SE2MASTER modeltype="FIELDS">'
	_cXML += '<E2_FILIAL order="1">'
	_cXML += '<value>'+SE2->E2_FILIAL+'</value>'
	_cXML += '</E2_FILIAL>'
	_cXML += '<E2_PREFIXO order="2">'
	_cXML += '<value>'+SE2->E2_PREFIXO+'</value>'
	_cXML += '</E2_PREFIXO>'
	_cXML += '<E2_NUM order="3">'
	_cXML += '<value>'+SE2->E2_NUM+'</value>'
	_cXML += '</E2_NUM>'
	_cXML += '<E2_PARCELA order="4">'
	_cXML += '<value>'+SE2->E2_PARCELA+'</value>'
	_cXML += '</E2_PARCELA>'
	_cXML += '<E2_TIPO order="5">'
	_cXML += '<value>'+SE2->E2_TIPO+'</value>'
	_cXML += '</E2_TIPO>'
	_cXML += '<E2_FORNECE order="6">'
	_cXML += '<value>'+SE2->E2_FORNECE+'</value>'
	_cXML += '</E2_FORNECE>'
	_cXML += '<E2_LOJA order="7">'
	_cXML += '<value>'+SE2->E2_LOJA+'</value>'
	_cXML += '</E2_LOJA>'
	_cXML += '<AUTMOTBX order="8">'
	_cXML += '<value>'+CMOTBX+'</value>'
	_cXML += '</AUTMOTBX>'
	_cXML += '<AUTBANCO order="9">'
	_cXML += '<value>'+CBANCO+'</value>'
	_cXML += '</AUTBANCO>'
	_cXML += '<AUTAGENCIA order="10">'
	_cXML += '<value>'+CAGENCIA+'</value>'
	_cXML += '</AUTAGENCIA>'
	_cXML += '<AUTCONTA order="11">'
	_cXML += '<value>'+CCONTA+'</value>'
	_cXML += '</AUTCONTA>'
	_cXML += '<AUTDTBAIXA order="12">'
	_cXML += '<value>'+Dtos(dBaixa)+'</value>'
	_cXML += '</AUTDTBAIXA>'
	_cXML += '<AUTDTCREDITO order="13">'
	_cXML += '<value>'+Dtos(_dDtCred)+'</value>'
	_cXML += '</AUTDTCREDITO>'
	_cXML += '<AUTHIST order="14">'
	_cXML += '<value>'+cHist080+'</value>'
	_cXML += '</AUTHIST>'
	_cXML += '<AUTVALPAG order="15">'
	_cXML += '<value>'+Alltrim(Transform(nValPag,"@E 99,999,999,999.99"))+'</value>'
	_cXML += '</AUTVALPAG>'
	_cXML += '<E2_XIDEAI order="16">'
	_cXML += '<value>'+SE2->E2_XIDEAI+'</value>'
	_cXML += '</E2_XIDEAI>'
	_cXML += '<AUTDESCONT order="17">'
	_cXML += '<value>'+Alltrim(Transform(nDescont,"@E 99,999,999,999.99"))+'</value>'
	_cXML += '</AUTDESCONT>'
	_cXML += '<AUTMULTA order="18">'
	_cXML += '<value>'+Alltrim(Transform(nMulta,"@E 99,999,999,999.99"))+'</value>'
	_cXML += '</AUTMULTA>'
	_cXML += '<AUTJUROS order="19">'
	_cXML += '<value>'+Alltrim(Transform(nJuros,"@E 99,999,999,999.99"))+'</value>'
	_cXML += '</AUTJUROS>'
	_cXML += '<AUTDECRESC order="20">'
	_cXML += '<value>'+Alltrim(Transform(nDecresc,"@E 99,999,999,999.99"))+'</value>'
	_cXML += '</AUTDECRESC>'
	_cXML += '<AUTACRESC order="21">'
	_cXML += '<value>'+Alltrim(Transform(nAcresc,"@E 99,999,999,999.99"))+'</value>'
	_cXML += '</AUTACRESC>'
	_cXML += '</SE2MASTER>'
	_cXML += '</FINA080>'
	_cXML += '</Content>'
	_cXML += '</Layouts>'
	_cXML += '</Message>'
	_cXML += '</TOTVSIntegrator>'
	
	// Gera็ใo do arquivo
	U_SIXMLDATA(_cXML,_cFile,"FINA080","Baixas a Pagar")
ENDIF

Return()