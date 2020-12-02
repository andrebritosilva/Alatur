#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIESBA08   บAutor  ณMicrosiga          บ Data ณ  27/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Receptor de EAI - Pedido de Venda                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP 11.5 - Sistema Industria                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//User Function SIESBA08(_cXML,cXMLError) 
User Function SIESBA08(_cXML)
Local _cError   := ""
Local _cWarning := ""                                   
Local _cDelimit := "_"
Local _lInput   := GetRemoteType() == -1 //-1 = sem remote/ 0 = delphi/ 1 = QT windows/ 2 = QT Linux
Local _lRateio  := .f.
Local _aRateio  := {}
Local _aTotRat  := {}
Local _cFilial	:= ""
Default _cXML   := ""                                                
Conout(_cxml)
IF !_lInput // Chamada via ESB/EAI                                                            
	Return
ENDIF
ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + Replicate('-',40) )
ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "XmlParser " )
ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
dDatabase := date()
//Gera o Objeto XML com a estrutura recebida
oXml := XmlParser(_cXML, _cDelimit, @_cError, @_cWarning)

//Verifica se a estrutura foi criada
IF !(Empty(_cError) .and. Empty(_cWarning))
	//cXMLError := _cError
	_cMotivo := "Verifique a estrutura do arquivo MATA410 - Pedido de Vendas"    
	U_SIXMLMSG("MATA410","Pedido de Vendas",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
	Return()
ENDIF

_nOperac := Val(oXml:_MATA410:_OPERATION:TEXT)
_cIDESB  := IIF(Type("oXml:_MATA410:_SC5MASTER:_C5_XIDESB:REALNAME") <> "U",&("oXml:_MATA410:_SC5MASTER:_C5_XIDESB:_VALUE:TEXT"),"")
_cFilial := IIF(Type("oXml:_MATA410:_SC5MASTER:_C5_XIDESB:REALNAME") <> "U",&("oXml:_MATA410:_SC5MASTER:_C5_FILIAL:_VALUE:TEXT"),"")
	
// Verifica se mensagem trata-se de Pedido de Venda
IF Type('oXml:_MATA410:_SC5MASTER') == "U" .or. Type("oXml:_MATA410:_SC5MASTER:_SC6DETAIL") == "U"
	_cMotivo := "Mensagem invalida para a rotina MATA410 - Pedido de Venda"
      //  cXMLError:= _cMotivo
	// Gera XML de retorno
	U_SIXMLMSG("MATA410","Pedido de Vendas ",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
	Return()
ENDIF

_aCab := {}
                
ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "SX3 SC5" )
ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
SX3->(dbSetOrder(1))
SX3->(dbGoTop())
SX3->(dbSeek("SC5"))

// Calcula numero do pedido caso nao tenha sido informado no XML
/*IF Type("oXml:_MATA410:_SC5MASTER:_C5_NUM:REALNAME") == "U"
	_cNumPV := GetSX8Num("SC5","C5_NUM")
	aAdd( _aCab, {"C5_NUM",_cNumPV, NIL } )
ENDIF*/

// Carrega vetor com os campos
While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == "SC5"
	IF Type("oXml:_MATA410:_SC5MASTER:_"+Alltrim(SX3->X3_CAMPO)+":REALNAME") <> "U"
		// Carrega conteudo do variavel
		_cCampo := &("oXml:_MATA410:_SC5MASTER:_"+Alltrim(SX3->X3_CAMPO)+":_VALUE:TEXT")
		
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
		aAdd( _aCab, {Alltrim(SX3->X3_CAMPO),_cCampo, NIL } )
	ENDIF
	SX3->(dbSkip())
Enddo

IF Type("oXml:_MATA410:_SC5MASTER:_FATAUT:REALNAME") <> "U" .and. Alltrim(oXml:_MATA410:_SC5MASTER:_FATAUT:_VALUE:TEXT) == "S"
	_lFatAuto := .T.
	_cSerie   := IIF(Type("oXml:_MATA410:_SC5MASTER:_SERIE:REALNAME") <> "U",oXml:_MATA410:_SC5MASTER:_SERIE:_VALUE:TEXT,"")
ELSE
	_lFatAuto := .f.
ENDIF

_aItem    := {}
_aTotItem := {}

_nLaco := IIF(Type("oXml:_MATA410:_SC5MASTER:_SC6DETAIL:_ITEMS:_ITEM") == "A",Len(oXml:_MATA410:_SC5MASTER:_SC6DETAIL:_ITEMS:_ITEM),1)

For i := 1 to _nLaco
	
	SX3->(dbSetOrder(1))
	SX3->(dbGoTop())
	SX3->(dbSeek("SC6"))
	
	_cItemPV := ""
	
	// Carrega vetor com os campos                                    
	ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "SX3 SC6" )
	ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
	While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == "SC6"
		
		IF Type("oXml:_MATA410:_SC5MASTER:_SC6DETAIL:_ITEMS:_ITEM"+IIF(_nLaco>1,"["+Alltrim(Str(i))+"]:",":")+"_"+Alltrim(SX3->X3_CAMPO)+":REALNAME") <> "U"
			// Carrega conteudo do variavel
			_cCampo := &("oXml:_MATA410:_SC5MASTER:_SC6DETAIL:_ITEMS:_ITEM"+IIF(_nLaco>1,"["+Alltrim(Str(i))+"]:",":")+"_"+Alltrim(SX3->X3_CAMPO)+":TEXT")
			
			// Faz tratamento do dado
			IF SX3->X3_TIPO == "C"
				_cCampo := PadR(_cCampo,SX3->X3_TAMANHO)
			ELSEIF SX3->X3_TIPO == "N"
			  	_cCampo := Val(_cCampo)
			ELSEIF SX3->X3_TIPO == "D"
				_cCampo := Stod(_cCampo)
			ENDIF
			IF SX3->X3_CONTEXT == "V"
				SX3->(dbSkip())
				Loop
			ENDIF
			
			IF Alltrim(SX3->X3_CAMPO) == "C6_ITEM"
				_cItemPV := _cCampo
			ENDIF
			
			// Carrega vetor para rotina automatica
			Aadd(_aItem,{Alltrim(SX3->X3_CAMPO),_cCampo,NIL} )
		ENDIF
		SX3->(dbSkip())
	Enddo
	
	// Verifica se te rateio no item
	IF Type("oXml:_MATA410:_SC5MASTER:_SC6DETAIL:_ITEMS:_ITEM"+IIF(_nLaco>1,"["+Alltrim(Str(i))+"]:",":")+"_AGGDETAIL:REALNAME") <> "U"
		
		_nItRat :=IIF(Type("oXml:_MATA410:_SC5MASTER:_SC6DETAIL:_ITEMS:_ITEM"+IIF(_nLaco>1,"["+Alltrim(Str(i))+"]:",":")+"_AGGDETAIL:_ITEM")=="A",Len(&("oXml:_MATA410:_SC5MASTER:_SC6DETAIL:_ITEMS:_ITEM"+IIF(_nLaco>1,"["+Alltrim(Str(i))+"]:",":")+"_AGGDETAIL:_ITEM")),1)
		
		_aStruAGG := AGG->(DbStruct())
		
		Aadd(_aTotRat,{_cItemPV})
		lFirst := .T.
		For x := 1 to _nItRat
			_aRateio := {}
			For y := 1 to Len(_aStruAGG)
				
			 //	IF Type("oXml:_MATA410:_SC5MASTER:_SC6DETAIL:_ITEMS:_ITEM["+Alltrim(Str(i))+"]:_AGGDETAIL:_ITEM"+IIF(_nItRat>1,"["+Alltrim(Str(x))+"]:",":")+"_"+Alltrim(_aStruAGG[y][1])+":REALNAME") <> "U"
			 IF Type("oXml:_MATA410:_SC5MASTER:_SC6DETAIL:_ITEMS:_ITEM"+IIF(_nLaco>1,"["+Alltrim(Str(i))+"]:",":")+"_AGGDETAIL:_ITEM"+IIF(_nItRat>1,"["+Alltrim(Str(x))+"]:",":")+"_"+Alltrim(_aStruAGG[y][1])+":REALNAME") <> "U"
					// Carrega conteudo do variavel
//					_cCpoRat := &("oXml:_MATA410:_SC5MASTER:_SC6DETAIL:_ITEMS:_ITEM["+Alltrim(Str(i))+"]:_AGGDETAIL:_ITEM"+IIF(_nItRat>1,"["+Alltrim(Str(x))+"]:",":")+"_"+Alltrim(_aStruAGG[y][1])+":TEXT")
					_cCpoRat := &("oXml:_MATA410:_SC5MASTER:_SC6DETAIL:_ITEMS:_ITEM"+IIF(_nLaco>1,"["+Alltrim(Str(i))+"]:",":")+"_AGGDETAIL:_ITEM"+IIF(_nItRat>1,"["+Alltrim(Str(x))+"]:",":")+"_"+Alltrim(_aStruAGG[y][1])+":TEXT")
					
					// Faz tratamento do dado
					IF _aStruAGG[y][2] == "C"
						_cCpoRat := PadR(_cCpoRat,_aStruAGG[y][3])
					ELSEIF _aStruAGG[y][2] == "N"
						_cCpoRat := Val(_cCpoRat)
					ELSEIF _aStruAGG[y][2] == "D"
						_cCpoRat := Stod(_cCpoRat)
					ENDIF
					
					// Carrega vetor do rateio para rotina automatica
					Aadd(_aRateio,{Alltrim(_aStruAGG[y][1]),_cCpoRat,NIL} )
					
				ENDIF
				
			Next
		
			If lFirst
				Aadd(_aTotRat[Len(_aTotRat)],{_aRateio})	
				lFirst := .F.
			Else   
//				Aadd(_aTotRat[Len(_aTotRat)][i+1],{})	 
				Aadd(_aTotRat[Len(_aTotRat)][Len(_aTotRat[Len(_aTotRat)])],{})	 
//			   	_aTotRat[Len(_aTotRat)][_nItRat][Len(_aTotRat[Len(_atotrat)][_nItRat])]:=_aRateio //_aTotRat[Len(_aTotRat)][_nItRat][_nItRat]:=_aRateio
//			   	_aTotRat[Len(_aTotRat)][i+1][Len(_aTotRat[Len(_atotrat)][i+1])]:=_aRateio //_aTotRat[Len(_aTotRat)][_nItRat][_nItRat]:=_aRateio
//			   	_aTotRat[Len(_aTotRat)][Len(_aTotRat[Len(_aTotRat)])][Len(_aTotRat[Len(_atotrat)][x])]:=_aRateio
			   	_aTotRat[Len(_aTotRat)][Len(_aTotRat[Len(_aTotRat)])][x]:=_aRateio
			Endif	
		Next    
			
	                                                              
	ENDIF
	
	Aadd(_aTotItem, _aItem )
	_aItem := {}
Next

IF Len(_aTotRat) > 0
	_lRateio := .t.
ENDIF

INCLUI         := .T.
lMsErroAuto    := .F.
lMsHelpAuto    := .T.
lAutoErrNoFile := .T.

ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "ExecAuto " )
ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
// Inserido por Carlos Queiroz em 02/04/13
//Begin Transaction

MSExecAuto( {|a,b,c,d,e,f,g,h,i,j| MATA410(a,b,c,d,e,f,g,h,i,j)}, _aCab , _aTotItem , _nOperac,,,,,If(_lRateio,_aTotRat,),,)

If lMsErroAuto
	ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "ExecAuto Erro " )	
	ConOut( "SIESBA08 - database " + DTOC(ddatabase) )

	// inserido por Carlos Queiroz em 02/04/13
	DisarmTransaction()
	
	// Tratamento da Mensagem de erro do MSExecAuto
	aLogErr  := GetAutoGRLog()
	aLogErr2 := U_SIESBID(aLogErr)
	_cMotivo := ""
	
	For i := 1 to Len(aLogErr2)
		_cMotivo += aLogErr2[i]
	Next
	
	// Gera XML de retorno                                                     
	ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "XML retorno " )	
	ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
	U_SIXMLMSG("MATA410","Pedido de Vendas ",Alltrim(Str(_nOperac)),_cIDESB,"1",_cMotivo)
	//cXMLError := _cMotivo
    
	// inserido por Carlos Queiroz em 02/04/13
       //DisarmTransaction()
	
	Break
Else
   	ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Inicia nota " )	
   	ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
	IF _lFatAuto // gera็ใo da nota fiscal de saํda
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Retorna numero da nota fiscal para o arquivo de Tabelas 	 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
		If	SX5->(dbSeek(_cFilial+"01"+_cSerie))  //   Posiciona no x5 
		   /*	While !VldSX5Num(SX5->X5_DESCRI,_cSerie,.F.)
				SX5->(DbSeek(_cFilial+'01'+_cSerie))
				RecLock("SX5",.F.)
					Replace X5_DESCRI  With Soma1(cNum)
					Replace X5_DESCENG With Soma1(cNum)
					Replace X5_DESCSPA With Soma1(cNum)
				SX5->(MsUnlock())  
			EndDo */
		      
			If VldSX5Num(SX5->X5_DESCRI,_cSerie,.F.)       //valida o numero da nota encontrado
				_aRetFat := SIESB08Fat(_cSerie)	
				ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Gerou Nota " )	
				ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
				IF !_aRetFat[1] //Erro na emissao da nota
					// Gera XML de retorno   
					DisarmTransaction()                                                   
					ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Gerou Resposta 1 " )	
					ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
					U_SIXMLMSG("MATA410","Pedido de Vendas ",Alltrim(Str(_nOperac)),_cIDESB,"1",_aRetFat[2])
					// inserido por Carlos Queiroz em 02/04/13
			 //		DisarmTransaction()
				ELSE
					// Gera XML de retorno                                                              
					ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Gerou Resposta 2 " )	
					ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
					U_SIXMLMSG("MATA410","Pedido de Vendas ",Alltrim(Str(_nOperac)),_cIDESB,"0","",SC5->C5_NUM,_aRetFat[3])
					//Break
				ENDIF
			Else   //se o numero da nota nao for validado.
			// Gera XML de retorno 
				DisarmTransaction()                                                                     
				ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Gerou Resposta 5 " )	
				U_SIXMLMSG("MATA410","Pedido de Vendas ",Alltrim(Str(_nOperac)),_cIDESB,"1","Problema na numera็ใo da Nota.",SC5->C5_NUM,)			
				ConOut( "SIESBA08 - database " + DTOC(ddatabase) )                      
				//Break
			Endif		
			
		Else	
		// Gera XML de retorno
			DisarmTransaction()                                                                      
			ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Gerou Resposta 3 " )	
			U_SIXMLMSG("MATA410","Pedido de Vendas ",Alltrim(Str(_nOperac)),_cIDESB,"1","Numero de Serie nao encontrado",SC5->C5_NUM,)			
			ConOut( "SIESBA08 - database " + DTOC(ddatabase) )                      
		//Break
		Endif				
	ELSE
		// Gera XML de retorno
		ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Gerou Resposta 4 " )	
		ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
		U_SIXMLMSG("MATA410","Pedido de Vendas ",Alltrim(Str(_nOperac)),_cIDESB,"0","",SC5->C5_NUM)
		//Break
	ENDIF
	
EndIf

// inserido por Carlos Queiroz em 02/04/13
//End Transaction

ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Acabou a mensagem " )	
ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIESB08Fat บAutor  ณMicrosiga          บ Data ณ  17/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Emite nota fiscal de saida                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIESB08Fat(_cSerie)
Local aPvlNfs   := {}
Local aBloqueio := {}
Local _cMens    := ""
Local _aRet     := {.f.,"",""}
Local _cArea    := GetArea()

// Liberacao de pedido 
ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Libera Pedido " ) 
ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
Ma410LbNfs(2,@aPvlNfs,@aBloqueio)

// Checa itens liberados                                                         
ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Checa itens " ) 
ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
// restaura SX1 da rotina de transf.

If Empty(aBloqueio) .And. !Empty(aPvlNfs)
	// parametros da nota fiscal
	lMostraCtb := .F.
	lAglutCtb  := .F.
	lCtbOnLine := .F.
	lCtbCusto  := .F.
	lReajuste  := .F.
	lAtuSA7    := .F.
	lECF       := .F.
	
	// Gera nota fiscal de saํda                                          
	ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Gera Nota " ) 
	ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
	_cNota := MaPvlNfs(aPvlNfs,_cSerie,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajuste,1,1,lAtuSA7,lECF)
	
	// Nota gerada                     
	IF !Empty(_cNota)
		_aRet[1] := .t.
		_aRet[3] := _cNota
	ELSE // nao gerou a nota fiscal
		_aRet[2] := "Ocorreu um erro na gera็ใo da nota fiscal. Verifique problema no ERP"
	ENDIF
	
ELSE
	IF SC5->C5_BLQ$("1/2")
		_cMens := "Bloqueio de Regra/Verba"
	ELSEIF !Empty(SC5->C5_LIBEROK) .and. Empty(SC5->C5_NOTA) .and. Empty(SC5->C5_BLQ) .and. SIESB08BLQ(2)
		_cMens := "Bloqueio de Credito"
	ELSEIF  !Empty(SC5->C5_LIBEROK) .and. Empty(SC5->C5_NOTA) .and. Empty(SC5->C5_BLQ) .and. SIESB08BLQ(4)
		_cMens := "Bloqueio de Estoque"
	ENDIF
	_aRet[2] := _cMens
ENDIF

RestArea(_cArea)
Return(_aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIESB08BLQ บAutor  ณMicrosiga          บ Data ณ  17/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica status dos pedidos com SC9                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIESB08BLQ(_nOpc)
Local _lRet    := .F.
Local _cQuery  := ""
Local _cArqTRB := CriaTrab(nil,.f.)
Local _cArea   := GetArea()
ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "Verifica Bloqueio " )	
ConOut( "SIESBA08 - database " + DTOC(ddatabase) )
IF _nOpc == 1 // liberado
	_cQuery := "SELECT C9_PEDIDO FROM "+RetSqlName("SC9")+" WHERE D_E_L_E_T_ = ' ' AND C9_FILIAL = '"+SC5->C5_FILIAL+"' AND C9_PEDIDO = '"+SC5->C5_NUM+"' AND C9_BLCRED = '  ' AND C9_BLEST = '  '"
ELSEIF _nOpc == 2 // credito
	_cQuery := "SELECT C9_PEDIDO FROM "+RetSqlName("SC9")+" WHERE D_E_L_E_T_ = ' ' AND C9_FILIAL = '"+SC5->C5_FILIAL+"' AND C9_PEDIDO = '"+SC5->C5_NUM+"' AND C9_BLCRED <> '  ' AND C9_BLCRED NOT IN('10','09')"
ELSEIF _nOpc == 3 // rejeitado
	_cQuery := "SELECT C9_PEDIDO FROM "+RetSqlName("SC9")+" WHERE D_E_L_E_T_ = ' ' AND C9_FILIAL = '"+SC5->C5_FILIAL+"' AND C9_PEDIDO = '"+SC5->C5_NUM+"' AND C9_BLCRED = '09'"
ELSE // rejeitado
	_cQuery := "SELECT C9_PEDIDO FROM "+RetSqlName("SC9")+" WHERE D_E_L_E_T_ = ' ' AND C9_FILIAL = '"+SC5->C5_FILIAL+"' AND C9_PEDIDO = '"+SC5->C5_NUM+"' AND C9_BLEST <> '  ' AND C9_BLEST <> '10' AND C9_BLEST <> 'ZZ'"
ENDIF
_cQuery := ChangeQuery(_cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqTRB,.t.,.t.)

IF (_cArqTRB)->(!Eof())
	_lRet := .T.
ENDIF

(_cArqTRB)->(dbCloseArea())
RestArea(_cArea)
Return(_lRet)
