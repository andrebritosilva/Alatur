#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIESBA35   บAutor  ณMicrosiga          บ Data ณ  24/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Receptor de EAI - Alteracao de Titulos a Receber           บฑฑ
ฑฑบ          ณ  Altera็ใo de (vencimento, acr้scimo ou decr้scimo)        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP 11.5 - Sistema Industria                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SIESBA35()
Local _cOper     := "4"
Local _cError    := ""
Local _cWarning  := ""
Local _cDelimit  := "_"
Local aStru      := {}
Local _cXML      := ""
Local _cData     := Dtos(Date())
Local _cTime     := Time()
Local _cDateTime := Transform(_cData,"@R 9999-99-99")+"T"+_cTime+"Z"
Local _cFile     := "FINA040"+_cOper+_cData+StrTran(_cTime,":","")+".XML"
Local _lInput    := GetRemoteType() == -1 //-1 = sem remote/ 0 = delphi/ 1 = QT windows/ 2 = QT Linux

IF _lInput // Chamada via ESB/EAI
	Return
ENDIF

dbSelectArea("SE1")

// Montagem das tags do XML
_cXML += '<TOTVSIntegrator>'
_cXML += '<GlobalProduct>TOTVS|ESB</GlobalProduct>'
_cXML += '<GlobalFunctionCode>EAI</GlobalFunctionCode>'
_cXML += '<GlobalDocumentFunctionCode>FINA040</GlobalDocumentFunctionCode>'
_cXML += '<GlobalDocumentFunctionDescription>Contas a Receber</GlobalDocumentFunctionDescription>'
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
_cXML += '<Identifier>FINA040</Identifier>'
_cXML += '<Version>1.0</Version>'
_cXML += '<FunctionCode></FunctionCode>'
_cXML += '<Content>'
_cXML += '<FINA040 Operation="'+_cOper+'" version="1.01">'
_cXML += '<SE1MASTER modeltype="FIELDS" >'

// Montagem das TAGs
For i := 1 To FCount()
	_cXML += '<'+FieldName(i)+' order="'+Alltrim(Str(i))+'">'
	_cXML += '<value>'+Alltrim(CValtoChar(&("SE1->"+FieldName(i))))+'</value>'
	_cXML += '</'+FieldName(i)+'>'
Next

_cXML += '</SE1MASTER>'
_cXML += '</FINA040>'
_cXML += '</Content>'
_cXML += '</Layouts>'
_cXML += '</Message>'
_cXML += '</TOTVSIntegrator>'

// Transforma a string XML em Objeto
//oXML := XMLParser( _cXML, _cDelimit, @_cError, @_cWarning )

//Verifica se a estrutura foi criada
//IF !(Empty(_cError) .and. Empty(_cWarning))
//	Return()
//ENDIF

// Gera็ใo do arquivo
//U_SIXMLDATA(oXML,_cFile)
// Gera็ใo do arquivo
U_SIXMLDATA(_cXML,_cFile,"FINA040","Contas a Receber")


Return()
