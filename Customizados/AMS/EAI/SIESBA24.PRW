#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIESBA24   บAutor  ณMicrosiga          บ Data ณ  28/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Receptor de EAI - Documento de Entrada                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP 11.5 - Sistema Industria                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SIESBA24(_nOpc)
Local _cError   := ""
Local _cWarning := ""
Local _cDelimit := "_"
Local _cXML     := ""
Local _lInput   := GetRemoteType() == -1 //-1 = sem remote/ 0 = delphi/ 1 = QT windows/ 2 = QT Linux
Default _nOpc   := 3 // Inclusao

IF _lInput // Chamada via ESB/EAI
	Return
ENDIF

_cData     := Dtos(Date())
_cTime     := Time()
_cDateTime := Transform(_cData,"@R 9999-99-99")+"T"+_cTime+"Z"
_cOper     := Alltrim(Str(_nOpc))
_cFile     := "MATA103"+_cOper+_cData+StrTran(_cTime,":","")+".XML"

// Montagem das tags do XML
_cXML += '<TOTVSIntegrator>'
_cXML += '<GlobalProduct>TOTVS|ESB</GlobalProduct>'
_cXML += '<GlobalFunctionCode>EAI</GlobalFunctionCode>'
_cXML += '<GlobalDocumentFunctionCode>MATA103</GlobalDocumentFunctionCode>'
_cXML += '<GlobalDocumentFunctionDescription>Documento de Entrada</GlobalDocumentFunctionDescription>'
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
_cXML += '<Identifier>MATA103</Identifier>'
_cXML += '<Version>1.0</Version>'
_cXML += '<FunctionCode></FunctionCode>'
_cXML += '<Content>'
_cXML += '<MATA103 Operation="'+_cOper+'" version="1.01">'
_cXML += '<SF1MASTER modeltype="FIELDS">'

dbSelectArea("SF1")
// Montagem das TAGs do cabe็alho
IF _cOper == "5" // exclusใo
	_cXML += '<F1_FILIAL order="1">'
	_cXML += '<value>'+SF1->F1_FILIAL+'</value>'
	_cXML += '</F1_FILIAL>'
	_cXML += '<F1_DOC order="2">'
	_cXML += '<value>'+SF1->F1_DOC+'</value>'
	_cXML += '</F1_DOC>'
	_cXML += '<F1_SERIE order="3">'
	_cXML += '<value>'+SF1->F1_SERIE+'</value>'
	_cXML += '</F1_SERIE>'
	_cXML += '<F1_FORNECE order="4">'
	_cXML += '<value>'+SF1->F1_FORNECE+'</value>'
	_cXML += '</F1_FORNECE>'
	_cXML += '<F1_LOJA order="5">'
	_cXML += '<value>'+SF1->F1_LOJA+'</value>'
	_cXML += '</F1_LOJA>'
	_cXML += '<F1_FORMUL order="6">'
	_cXML += '<value>'+SF1->F1_FORMUL+'</value>'
	_cXML += '</F1_FORMUL>'
ELSE
	// Montagem das TAGs do cabe็alho
	For i := 1 To FCount()
		_cXML += '<'+FieldName(i)+' order="'+Alltrim(Str(i))+'">'
		_cXML += '<value>'+Alltrim(CValtoChar(&("SF1->"+FieldName(i))))+'</value>'
		_cXML += '</'+FieldName(i)+'>'
	Next
	
	_cXML += '<SD1DETAIL modeltype="GRID">'
	_cXML += '<items>'
	
	dbSelectArea("SD1")
	SD1->(dbsetOrder(1))
	SD1->(dbseek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
	
	_nItem := 1
	While SD1->(!Eof()) .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		
		_cXML += '<item id="'+Alltrim(Str(_nItem))+'" deleted="0">'
		// Campos do SD1
		For i := 1 To FCount()
			_cXML += '<'+FieldName(i)+'>'+Alltrim(CValtoChar(&("SD1->"+FieldName(i))))+'</'+FieldName(i)+'>'
		Next
		_cXML += '</item>'
		
		_nItem++
		SD1->(dbSkip())
	Enddo
	
	_cXML += '</items>'
	_cXML += '</SD1DETAIL>'
ENDIF
_cXML += '</SF1MASTER>'
_cXML += '</MATA103>'
_cXML += '</Content>'
_cXML += '</Layouts>'
_cXML += '</Message>'
_cXML += '</TOTVSIntegrator>'

// Gera็ใo do arquivo
U_SIXMLDATA(_cXML,_cFile,"MATA103","Documento de Entrada")

Return()
