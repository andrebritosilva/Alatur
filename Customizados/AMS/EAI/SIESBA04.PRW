#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SIESBA04   ºAutor  ³Microsiga          º Data ³  03/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Receptor de EAI - Título a Pagar                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 11.5 - Sistema Industria                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//User Function SIESBA04(_cXML,cXMLError) 
User Function SIESBA04(_cXML)  
Local _cError    := ""
Local _cWarning  := ""
Local _cDelimit  := "_"
Local aStru      := {}
Local _lInput    := GetRemoteType() == -1 //-1 = sem remote/ 0 = delphi/ 1 = QT windows/ 2 = QT Linux
Local _cTesNaoEnvia  := GetNewPar("SI_NOTES","005,006")
Default _cXML    := ""   
Private	_aTotRat := {}
Conout(_cXML)
IF _lInput // Chamada via ESB/EAI
        
IF  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/  
		SZZ->(dbSetOrder(1))
		IF SZZ->(dbSeek(XFilial("SZZ")+"FINA050")).And. (SZZ->ZZ_TPINT == '1' ) //Se existe a integracao e se ha a opção for somente envio.
	   		Return()  	     // Encerra e Sai.
		ENDIF	
	ENDIF

//Gera o Objeto XML com a estrutura recebida
oXml := XmlParser(_cXML, _cDelimit, @_cError, @_cWarning)

//Verifica se a estrutura foi criada
IF !(Empty(_cError) .and. Empty(_cWarning))    
	_cMotivo := "Verifique a estrutura do arquivo FINA050 - Contas a Pagar"    
	U_SIXMLMSG("FINA050","Contas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
	Break	
	Return()
ENDIF

_nOperac := Val(oXml:_FINA050:_OPERATION:TEXT)
_cIDESB  := IIF(Type("oXml:_FINA050:_SE2MASTER:_E2_XIDESB:REALNAME") <> "U",&("oXml:_FINA050:_SE2MASTER:_E2_XIDESB:_VALUE:TEXT"),"")

// Verifica se mensagem trata-se de títulos a pagar
IF Type('oXml:_FINA050:_SE2MASTER') == "U"
	_cMotivo := "Mensagem invalida para a rotina FINA050 - Titulos a Pagar"  
	// Gera XML de retorno
	U_SIXMLMSG("FINA050","Contas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)  
    Break
	Return()
ENDIF

IF Type("oXml:_FINA050:_SE2MASTER:_E2_NUM:REALNAME") == "U" .or. Type("oXml:_FINA050:_SE2MASTER:_E2_TIPO:REALNAME") == "U" .or. Type("oXml:_FINA050:_SE2MASTER:_E2_FORNECE:REALNAME") == "U" .or. Type("oXml:_FINA050:_SE2MASTER:_E2_LOJA:REALNAME") == "U"
	_cMotivo := "Campos obrigatórios não preechidos (E2_NUM, E2_TIPO, E2_FORNECE, E2_LOJA). Verifique!"   
	// Gera XML de retorno
	U_SIXMLMSG("FINA050","Contas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
    Break
	Return()
ENDIF

SX3->(dbSetOrder(1))
SX3->(dbGoTop())
SX3->(dbSeek("SE2"))

// Carrega vetor com os campos
While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == "SE2"
	IF Type("oXml:_FINA050:_SE2MASTER:_"+Alltrim(SX3->X3_CAMPO)+":REALNAME") <> "U"
		// Carrega conteudo do variavel
		_cCampo := &("oXml:_FINA050:_SE2MASTER:_"+Alltrim(SX3->X3_CAMPO)+":_VALUE:TEXT")
		
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
	_cMotivo := "Nenhum campo localizado"                              
	U_SIXMLMSG("FINA050","Contas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
	//cXMLError:= _cMotivo
	Break
	Return()
ENDIF

// Verifica se tem rateio
IF Type('oXml:_FINA050:_SE2MASTER:_CV4DETAIL') <> "U"
	
//	_nItRat:= IIF(Type("oXml:_FINA050:_SE2MASTER:_CV4DETAIL:_ITEMS:_ITEM") == "A",Len(oXml:_FINA050:_SE2MASTER:_CV4DETAIL:_ITEMS:_ITEM),1)
	_nItRat:= IIF(Type("oXml:_FINA050:_SE2MASTER:_CV4DETAIL:_ITEM") == "A",Len(oXml:_FINA050:_SE2MASTER:_CV4DETAIL:_ITEM),1)
	
	_aStruCV4 := CV4->(DbStruct())
	_aTotRat := {}
	
	For x := 1 to _nItRat
		_aRateio := {}   
		For y := 1 to Len(_aStruCV4)
			
			If Type("oXml:_FINA050:_SE2MASTER:_CV4DETAIL:_ITEM["+Alltrim(Str(x))+"]:_"+Alltrim(_aStruCV4[y,1])+":REALNAME") <> "U"
				// Carrega conteudo do variavel
				
				_cCpoRat := &("oXml:_FINA050:_SE2MASTER:_CV4DETAIL:_ITEM["+Alltrim(Str(x))+"]:_"+Alltrim(_aStruCV4[y,1])+":TEXT")
				
				// Faz tratamento do dado
				IF _aStruCV4[y][2] == "C"
					_cCpoRat := PadR(_cCpoRat,_aStruCV4[y][3])
				ELSEIF _aStruCV4[y][2] == "N"
					_cCpoRat := Val(_cCpoRat)
				ELSEIF _aStruCV4[y][2] == "D"
					_cCpoRat := Stod(_cCpoRat)
				ENDIF
				
				// Carrega vetor do rateio para rotina automatica
				Aadd(_aRateio,{Alltrim(_aStruCV4[y][1]),_cCpoRat,NIL} )
				
			ENDIF
			
		Next
		
		Aadd(_aTotRat,_aRateio)

	Next
	
ENDIF

INCLUI         := .T.
lMsErroAuto    := .F.
lMsHelpAuto    := .T.
lAutoErrNoFile := .T.

SE2->( dbSetOrder( 1 ) )

//Begin Transaction

MSExecAuto( { | x, y | FINA050( x, y ) }, aStru, _nOperac )

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
	U_SIXMLMSG("FINA050","Contas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
	Break
Else
	If (__lSX8)
		ConfirmSX8()
	EndIf
	
	// Gera XML de retorno
	U_SIXMLMSG("FINA050","Contas a Pagar",Alltrim(Str(_nOperac)),_cIDESB,"0","")
	
EndIf
//End Transaction
Else // Chamado via Smartclient
//Verifica se origina de uma nota com TES que nao deve enviar o xml para o Legado.

	SD1->(dbSetOrder(1))
	IF SD1->(dbSeek(XFilial("SD1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)) .AND. SD1->D1_TES $ _cTesNaoEnvia   .and.;
	SE2->E2_ORIGEM <> "FINA050"
	//Se o tes informado na nota for um TES que nao deve enviar xml, aborta. 
	//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA     
	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                                                                                                               
	  		Return()  	     // Encerra e Sai.
	ENDIF			
      
     dbSelectArea("SE2")        
	_cData     := Dtos(Date())
	_cTime     := Time()
	_cDateTime := Transform(_cData,"@R 9999-99-99")+"T"+_cTime+"Z"
	_cOper     := IIF(IsInCallStack("FA050Inclu"),"3",IIF(IsInCallStack("FA050Alter"),"4",IIF(IsInCallStack("FA050Delet"),"5","0")))     
	If IsInCallStack("a103nfiscal") .And. _cOper = "0"  
		If  Inclui 
			_cOper     := "3"
		Else
			_cOper     := "5"
		Endif
	Endif
	_cFile     := "FINA050"+SE2->E2_NUM+_cOper+_cData+StrTran(_cTime,":","")+".XML"

	// Montagem das tags do XML
	_cXML += '<TOTVSIntegrator>'
	_cXML += '<GlobalProduct>TOTVS|ESB</GlobalProduct>'
	_cXML += '<GlobalFunctionCode>EAI</GlobalFunctionCode>'
	_cXML += '<GlobalDocumentFunctionCode>FINA050</GlobalDocumentFunctionCode>'
	_cXML += '<GlobalDocumentFunctionDescription>Contas a Pagar</GlobalDocumentFunctionDescription>'
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
	_cXML += '<Identifier>FINA050</Identifier>'
	_cXML += '<Version>1.0</Version>'
	_cXML += '<FunctionCode></FunctionCode>'
	_cXML += '<Content>'
	_cXML += '<FINA050 Operation="'+_cOper+'" version="1.01">'
	_cXML += '<SE2MASTER modeltype="FIELDS">'
		// Montagem das TAGs
	For i := 1 To FCount()
		_cXML += '<'+FieldName(i)+' order="'+Alltrim(Str(i))+'">'
		If Type(FieldName(i)) = "D" 
			_cXML += '<value>'+DTOS((&("SE2->"+FieldName(i))))+'</value>' 
		Else
		_cXML += '<value>'+Alltrim(CValtoChar(&("SE2->"+FieldName(i))))+'</value>'
		Endif
		_cXML += '</'+FieldName(i)+'>'
	Next
	_cXML += '</SE2MASTER>'
	_cXML += '</FINA050>'
	_cXML += '</Content>'
	_cXML += '</Layouts>'
	_cXML += '</Message>'
	_cXML += '</TOTVSIntegrator>'
	                                 
	// Transforma a string XML em Objeto
	oXML := XMLParser( _cXML, _cDelimit, @_cError, @_cWarning )
	
	//Verifica se a estrutura foi criada
	IF !(Empty(_cError) .and. Empty(_cWarning))
		Return()
	ENDIF
	
	// Geração do arquivo
 
	U_SIXMLDATA(_cXML,_cFile,"FINA050","Contas a Pagar" )   
	
Endif
	
Return()
