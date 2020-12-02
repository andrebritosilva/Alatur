#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*
Tipos de Mensagem
#DEFINE EAI_MESSAGE_PROTHEUS 	"10" // EAI Mensagem Protheus
#DEFINE EAI_MESSAGE_MVC 		"11" // EAI Mensagem Protheus com MVC
#DEFINE EAI_MESSAGE_BUSINESS 	"20" // EAI Mensagem Unica Business Message
#DEFINE EAI_MESSAGE_RESPONSE 	"21" // EAI Mensagem Unica Response Message
#DEFINE EAI_MESSAGE_RECEIPT 	"22" // EAI Mensagem Unica Receipt Message
#DEFINE EAI_MESSAGE_WHOIS 		"23" // EAI Mensagem Unica WhoIs Message
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIXMLMSG   บAutor  ณMicrosiga          บ Data ณ  08/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Geracao de XML para retorno                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ _cRotina = Rotina geradora                                 ณฑฑ
ฑฑณ          ณ _cOper   = Operacao (3=Inclusao;4=Alteracao;5=Exclusao)    ณฑฑ
ฑฑณ          ณ _cID     = ID da Msg (Campo ALIAS_XIDESB)                  ณฑฑ
ฑฑณ          ณ _cRet    = Retorno (0=Sucesso;1=Falha)                     ณฑฑ
ฑฑณ          ณ _cMotivo = Mensagem de erro (Somente no caso de FALHA)     ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - Sistema Industria                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SIXMLMSG(_cRotina,_cDescricao,_cOper,_cID,_cRet,_cMotivo,_cNumNF,_cNumPed)
Local _cError    := ""
Local _cWarning  := ""
Local _cDelimit  := "_"
Local _cXMLRET	 := ""
Local _cData     := Dtos(Date())
Local _cHora     := Time()
Local _cDestino  := GetNewPar("SI_ESBINP","\ESB\Input") // Informa a pasta destino dos arquivos XML
Local _cFile     := Alltrim(_cRotina)+Alltrim(_cOper)+_cData+StrTran(_cHora,":","")+".XML"
Default _cNumNF  := ""
Default _cNumPed := ""

ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "SIXMLMSG Inicio " )	

// Montagem das tags do XML
_cXMLRET += '<TOTVSIntegrator>'
_cXMLRET += '<ID>'+_cID+'</ID>'
_cXMLRET += '<DATA>'+_cData+'</DATA>'
_cXMLRET += '<HORA>'+_cHora+'</HORA>'
IF !Empty(_cNumNF)
	_cXMLRET += '<PEDIDO>'+_cNumNF+'</PEDIDO>'
	_cXMLRET += '<NOTA>'+_cNumPed+'</NOTA>'
ENDIF
_cXMLRET += '<RETORNO>'+_cRet+'</RETORNO>'
_cXMLRET += '<MOTIVO>'+NoAcentoESB(_cMotivo)+'</MOTIVO>'
_cXMLRET += '<GlobalDocumentFunctionCode>'+Alltrim(_cRotina)+'</GlobalDocumentFunctionCode>'
_cXMLRET += '<GlobalDocumentFunctionDescription>'+_cDescricao+'</GlobalDocumentFunctionDescription>'
_cXMLRET += '</TOTVSIntegrator>'

/*IF _cRet == "0" // sucesso
	_cDestino += "\success_message\"
ELSE // falha
	_cDestino += "\message_failure\"
ENDIF*/

U_SIXMLDATA(_cXMLRET,_cFile,_cRotina,_cDescricao,_cDestino,.T.)
ConOut( "SIESBA08 - " + DTOC( Date() ) + " " + Time() + " " + "SIXMLMSG Final " )	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIESBID    บAutor  ณMicrosiga          บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento da mensagem de erro do EAI                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - Sistema Industria                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SIESBID(aErr)
Local lHelp   := .F.
Local lTabela := .F.
Local cLinha  := ""
Local aRet    := {}
Local nI      := 0

For nI := 1 to LEN( aErr)
	cLinha  := UPPER( aErr[nI] )
	cLinha  := STRTRAN( cLinha,CHR(13), " " )
	cLinha  := STRTRAN( cLinha,CHR(10), " " )
	
	If SUBS( cLinha, 1, 4 ) == 'HELP'
		lHelp := .T.
	EndIf
	
	If SUBS( cLinha, 1, 6 ) == 'TABELA'
		lHelp   := .F.
		lTabela := .T.
	EndIf
	
	If  lHelp .or. ( lTabela .AND. '< -- INVALIDO' $  cLinha )
		aAdd( aRet,  StrTran(cLinha,'< -- INVALIDO','( INVALIDO )') )
	EndIf
	
Next

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNoAcentoESBบAutor  ณMicrosiga          บ Data ณ  23/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao responsavel por retirar caracteres especiais das     บฑฑ
ฑฑบ          ณString                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - Sistema Industria                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function NoAcentoESB(cMens)
Local _cByte,_ni,_nByte
Local _s1   := "แ้ํ๓๚" + "มษอำฺ" + "โ๊๎๔๛" + "ยสฮิÛ" + "ไ๋๏๖ü" + "ฤหฯึÜ" + "เ่์๒๙" + "ภศฬาู"  + "ใ๕รี" + "็ว"
Local _s2   := "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU"  + "aoAO" + "cC"
Local _nPos :=0
Local _cRet := ''

For _ni := 1 To Len(_s1)
	IF (_nPos := At(Subs(_s1,_ni,1),cMens)) > 0
		cMens := StrTran(cMens,Subs(_s1,_ni,1),Subs(_s2,_ni,1))
	ENDIF
Next

cMens := StrTran( cMens, 'บ', ' ')		//-- Remove o Caracter 1.'o'
cMens := StrTran( cMens, 'ช', ' ')		//-- Remove o Caracter 1.'a'
cMens := StrTran( cMens, '&', ' ')		//-- Remove o Caracter &
cMens := StrTran( cMens, 'ด', ' ')		//-- Remove o Caracter ด

cMens := NoAcento(cMens)

Return(AllTrim(cMens))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIXMLDATA  บAutor  ณMicrosiga          บ Data ณ  08/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Geracao de XML de dados                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ oXML        = Objeto do XML                                ณฑฑ
ฑฑณ          ณ _cFile      = Nome do arquivo                              ณฑฑ
ฑฑณ          ณ _cRotina    = Nome da Rotina                               ณฑฑ
ฑฑณ          ณ _cDescricao = Descricao da Rotina                          ณฑฑ
ฑฑณ          ณ _cFile      = Nome do arquivo                              ณฑฑ
ฑฑณ          ณ _cRotina    = Nome da Rotina                               ณฑฑ
ฑฑณ          ณ _cDescricao = Descricao da Rotina                          ณฑฑ
ฑฑณ          ณ _cDestino   = Pasta de gravacao                            ณฑฑ
ฑฑณ          ณ _lReturn    = Flag de mensagem de retorno                  ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - Sistema Industria                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/

User Function SIXMLDATA(_cXML,_cFile,_cRotina,_cDescricao,_cDestino,_lReturn)
Local _lUsaEAI    := GetNewPar("SI_USOEAI",.T.)            // Informa se envia para EAI ou FileSystem
Local _cDocType   := PROC_ASYNC
Default _cDestino := GetNewPar("SI_ESBOUT","\ESB\Output\") // Informa a pasta destino dos arquivos XML
Default _lReturn  := .F.

IF _lUsaEAI // envio para EAI
	
	IF _lReturn // Mensagem de retorno sempre ้ sincrono
		_cDocType   := PROC_ASYNC
	ELSE
		SZZ->(dbSetOrder(1))
		IF SZZ->(dbSeek(XFilial("SZZ")+_cRotina))
			IF SZZ->ZZ_METODO == "1" // Sincrono
				_cDocType := PROC_SYNC
			ELSE
				_cDocType := PROC_ASYNC
			ENDIF
		ELSE
			_cDocType := PROC_ASYNC
		ENDIF
	ENDIF                                                        
    
   	_cDocType := PROC_ASYNC
	oFWEAI:= FWEAI():New()
	oFWEAI:SetFuncCode(Alltrim(_cRotina) )
	oFWEAI:SetFuncDescription(Alltrim(_cDescricao) )
	oFWEAI:SetDocType( _cDocType ) // < PROC_SYNC = Sincrono, PROC_ASYNC = Assincrono >
	oFWEAI:AddLayout( _cRotina , '1.0' , _cRotina , _cXML )
	oFWEAI:SetTypeMessage( EAI_MESSAGE_PROTHEUS  )
	oFWEAI:SetSendChannel( EAI_CHANNEL_ESB ) //< EAI_CHANNEL_ESB = ESB, EAI_CHANNEL_EAI = EAI >
	oFWEAI:CXML := _cXML
	oFWEAI:Activate()
	
	If !oFWEAI:Save() // Gera a mensagem EAI
		Conout("ESB >> Mensagem ("+_cRotina+") nใo processada!")
	Endif
	
ELSE
	//Verifica se o diretorio de gravacao do XML existe
	IF !lIsDir( _cDestino )
		//Cria diretorio
		IF !MontaDir( _cDestino ) // Verifica se criou o diretorio
			Conout("ESB --> Erro na cria็ใo do diretorio "+_cDestino+". Consulte ADM do Sistema!")
			Return()
		ENDIF
	ENDIF
	
	_cDelimit := "_"
	_cError   := ""
	_cWarning := ""
	
	// Transforma a string XML em Objeto
	oXML := XMLParser( _cXML, _cDelimit, @_cError, @_cWarning )
	
	//Verifica se a estrutura foi criada
	IF !(Empty(_cError) .and. Empty(_cWarning))
		Conout("ESB --> Erro na cria็ใo do XML")
		Return()
	ENDIF
	
	// Salva o XML em disco
	XMLSaveFile( oXML, _cDestino + _cFile, .T. )
ENDIF

Return()
