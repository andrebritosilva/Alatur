#include "rwmake.ch"
#include "colors.ch"
#Include "topconn.ch"
#Include "protheus.ch"
#Include "tbiconn.ch"
#Include "APWEBEX.CH"

User Function xGerCont()

Local cAuxHtm   := ""
Local aHistCom  := {}
Local cQuery    := ""
Local cAliAux   := GetNextAlias()
Local dEmissao
  
_cEmpresa  := alltrim(HttpGet->cEmpAnt) 
_cFilial   := alltrim(HttpGet->cFilAnt)

Prepare Environment Empresa _cEmpresa Filial _cFilial

cQuery := "SELECT TOP 5 C7_EMISSAO, C7_FORNECE, C7_PRECO, C7_QUANT, C7_TOTAL  FROM "
cQuery += RetSqlName("SC7") + " SC7 "
cQuery += " WHERE"
cQuery += " D_E_L_E_T_ = ' ' ORDER BY C7_TOTAL DESC "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

(cAliAux)->(dbGotop())

WEB EXTENDED INIT cAuxHtm

_cont     := alltrim(HttpGet->cCont) 
_produto  := alltrim(HttpGet->cProd)
_datacom  := alltrim(HttpGet->cDataCom)
_solicita := alltrim(HttpGet->cSol)
_datasol  := alltrim(HttpGet->cDtSol)
_custo    := alltrim(HttpGet->cCusto)
_classe   := alltrim(HttpGet->cClasse)
_filial   := alltrim(HttpGet->cPcoFil)
_cValUnit := alltrim(HttpGet->cValUnit)
_cQuant   := alltrim(HttpGet->cQuant)
_cValTot  := alltrim(HttpGet->cValTot)
_cAliUser := alltrim(HttpGet->cAliUser)
_cValTot  := alltrim(HttpGet->cValTot)
_cUser    := alltrim(HttpGet->cUserId)
_cConta   := alltrim(HttpGet->cConta)
_cValOrc  := alltrim(HttpGet->cValOrc)
_cValRe   := alltrim(HttpGet->cValRe)
_cEmail   := Alltrim(HttpGet->cEmail)
_cAprova  := Alltrim(UsrFullName(_cEmail))

_custo   := U_xRetCusto(_filial,_custo)
_classe  := U_xRetClasse(_filial,_classe)
_produto := U_xRetProduto(_filial,_produto)
_cConta  := U_xRetConta(_filial,_cConta)
_cEmail  := UsrRetMail(_cEmail)
_cEmail  := Alltrim(_cEmail)
aHistCom := U_xHistCom(_filial)

//nt.apw?cparam=1&cCont=' + cCont + '&cProd=' + cProduto + '&cDataCom=' + cDataCom + '&cCusto=' + cCusto +'&cClasse=' +cClasse +'&cSol=' +cSol +

cAuxHtm := "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
cAuxHtm += "<html xmlns='http://www.w3.org/1999/xhtml'>"
cAuxHtm += "<head>"
cAuxHtm += "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
cAuxHtm += "<style type='text/css'>"
cAuxHtm += ".button {"
cAuxHtm += "font-family: Verdana, Arial, Helvetica , sans-serif;"
cAuxHtm += "font-size: 10px;"
cAuxHtm += "color: #000000;"
cAuxHtm += "border: 1px ridge #CC6600;"
cAuxHtm += "font-weight: bold;"
cAuxHtm += "margin: 1px;"
cAuxHtm += "padding: 10px;"
cAuxHtm += "background-color: #ECEEEB;"
cAuxHtm += "}"
cAuxHtm += ".text {"
cAuxHtm += "font-family: Verdana, Arial, Helvetica, sans-serif;"
cAuxHtm += "font-size: 11px;"
cAuxHtm += "color: 660000;"
cAuxHtm += "text-decoration: none;"
cAuxHtm += "font-style: normal;"
cAuxHtm += "}"
cAuxHtm += ".title {"
cAuxHtm += "font-family: Verdana, Arial, Helvetica, sans-serif;"
cAuxHtm += "font-size: 13px;"
cAuxHtm += "color: 660000;"
cAuxHtm += "text-decoration: none;"
cAuxHtm += "font-weight: bold;"
cAuxHtm += "}"
cAuxHtm += ".table {"
cAuxHtm += "border-bottom: 1px solid #999;"
cAuxHtm += "border-right: 1px solid #999;"
cAuxHtm += "border-left: 1px solid #999;"
cAuxHtm += "border-top: 1px solid #999;"
cAuxHtm += "margin: 1em auto;"
cAuxHtm += "}"
cAuxHtm += ".form0 {"
cAuxHtm += "font-family: Verdana, Arial, Helvetica, sans-serif;"
cAuxHtm += "font-size: 13px;"
cAuxHtm += "color: #FFF;"
cAuxHtm += "text-decoration: none;"
cAuxHtm += "font-weight: bold;"
cAuxHtm += "background-color: #788EA7"
cAuxHtm += "}"
cAuxHtm += ".form1 {"
cAuxHtm += "font-family: Verdana, Arial, Helvetica, sans-serif;"
cAuxHtm += "font-size: 10px;"
cAuxHtm += "color: #000000;"
cAuxHtm += "text-decoration: none;"
cAuxHtm += "font-weight: bold;"
cAuxHtm += "background-color: #ECF0EE;"
cAuxHtm += "}"
cAuxHtm += ".form2 {"
cAuxHtm += "font-family: Verdana, Arial, Helvetica, sans-serif;"
cAuxHtm += "font-size: 11px;"
cAuxHtm += "color: #333333;"
cAuxHtm += "text-decoration: none;"
cAuxHtm += "background-color: #F7F9F8;"
cAuxHtm += "}"
cAuxHtm += ".form3 {"
cAuxHtm += "font-family: Verdana, Arial, Helvetica, sans-serif;"
cAuxHtm += "font-size: 9px;"
cAuxHtm += "color: #333333;"
cAuxHtm += "text-decoration: none;"
cAuxHtm += "background-color: #F7F9F8;"
cAuxHtm += "font-weight: bold"
cAuxHtm += "}"
cAuxHtm += ".form4 {"
cAuxHtm += "font-family: Verdana, Arial, Helvetica, sans-serif;"
cAuxHtm += "font-size: 16px;"
cAuxHtm += "color: #F00;"
cAuxHtm += "text-decoration: none;"
cAuxHtm += "}"
cAuxHtm += ".links {"
cAuxHtm += "font-family: Arial, Helvetica, sans-serif;"
cAuxHtm += "font-size: 11px;"
cAuxHtm += "color: 660000;"
cAuxHtm += "text-decoration: underline;"
cAuxHtm += "font-style: normal;"
cAuxHtm += "}"
cAuxHtm += ".top_bg {"
cAuxHtm += "background-color: darkgray;"
cAuxHtm += "center repeat-x;"
cAuxHtm += "margin: 0;"
cAuxHtm += "padding: 0;"
cAuxHtm += "font-family: Verdana, Arial, Helvetica, sans-serif;"
cAuxHtm += "font-size: 13px;"
cAuxHtm += "text-decoration: none;"
cAuxHtm += "font-weight: bold;"
cAuxHtm += "text-align: center;"
cAuxHtm += "color: #FFF"
cAuxHtm += "}"
cAuxHtm += "</style>" + Chr(13) + Chr(10) 
cAuxHtm += '<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.1/angular.min.js"></script>'+ Chr(13) + Chr(10) 
cAuxHtm += "<script language='JavaScript' type='text/javascript'>" + Chr(13) + Chr(10) 
cAuxHtm += 'var app = angular.module("app", [])'+ Chr(13) + Chr(10) 
cAuxHtm += "app.controller('MainController', function($http) {" + Chr(13) + Chr(10) 
cAuxHtm += "var main = this" + Chr(13) + Chr(10) 
cAuxHtm += "main.Send = function() {" + Chr(13) + Chr(10) 

cAuxHtm += "var obj = {}"+ Chr(13) + Chr(10)

cAuxHtm += "obj.motivo = main.motivo"+ Chr(13) + Chr(10) 
cAuxHtm += "obj.aprovacao = main.radio"+ Chr(13) + Chr(10) 
cAuxHtm += "obj.contingencia = '" + _cont + "'" + Chr(13) + Chr(10) 
cAuxHtm += "obj.usuario = '" + _cAliUser + "'" + Chr(13) + Chr(10)
cAuxHtm += "obj.cuser = '" + _cUser + "'" + Chr(13) + Chr(10)
cAuxHtm += "obj.email = '" + _cEmail + "'" + Chr(13) + Chr(10)
cAuxHtm += "obj.empresa = '" + _cEmpresa + "'" + Chr(13) + Chr(10)
cAuxHtm += "obj.filial = '" + _cFilial + "'" + Chr(13) + Chr(10)

//cAuxHtm += '$http.post("http://localhost:8082/rest/WSRESTField",obj).' + Chr(13) + Chr(10) 
cAuxHtm += '$http.post("http://187.94.63.204:8006/rest/WSRESTField",obj).' + Chr(13) + Chr(10)
cAuxHtm += "success(function(dados) {"+ Chr(13) + Chr(10)

//cAuxHtm += 'window.location.assign("http://localhost:8085/U_RetPco.apw?cparam=1&cCont=' + _cont + '&cUser=' + _cUser + '&cEmpresa=' + _cEmpresa +'&Filial=' + _cFilial + '");'+ Chr(13) + Chr(10)
cAuxHtm += 'window.location.assign("http://187.94.63.204:14010/wf/U_RetPco.apw?cparam=1&cCont=' + _cont + '&cUser=' + _cUser + '&cEmpresa=' + _cEmpresa +'&Filial=' + _cFilial + '");'+ Chr(13) + Chr(10)
cAuxHtm += "console.log(dados)"+ Chr(13) + Chr(10) 
cAuxHtm += "}).error(function(erro) {"+ Chr(13) + Chr(10)
//cAuxHtm += 'window.location.assign("http://localhost:8085/U_RetPco.apw?cparam=1&cCont=' + _cont + '&cUser=' + _cUser + '&cEmpresa=' + _cEmpresa +'&Filial=' + _cFilial + '");'+ Chr(13) + Chr(10)
cAuxHtm += 'window.location.assign("http://187.94.63.204:14010/wf/U_RetPco.apw?cparam=1&cCont=' + _cont + '&cUser=' + _cUser + '&cEmpresa=' + _cEmpresa +'&Filial=' + _cFilial + '");'+ Chr(13) + Chr(10)
cAuxHtm += "console.log(erro);"+ Chr(13) + Chr(10) 
cAuxHtm += "})"+ Chr(13) + Chr(10) 
cAuxHtm += "}"+ Chr(13) + Chr(10) 
cAuxHtm += "})"+ Chr(13) + Chr(10) 
// }
cAuxHtm += "</script>"
cAuxHtm += "<title>Aprova&ccedil;&atilde;o de Cota&ccedil;&otilde;es de Compra</title>"
cAuxHtm += "</head>"
cAuxHtm += '<body ng-app="app" ng-controller="MainController as main">'
cAuxHtm += "<table width='90%' class='table'>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='93%' height='50' align='center' class='top_bg' style='font-size: 13px'>SOLICITACAO DE CONTIGENCIA: " + _cont + "</td>"
cAuxHtm += "</tr>"
cAuxHtm += "</table>"
cAuxHtm += "<form action='MailTo:%WFMAILTO%' method='POST' name='frmWFCotacao'>"
cAuxHtm += "<table width='90%' class='table'>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='100%'>"
cAuxHtm += "<table width='100%' style='border-bottom:1px solid #999'>"
cAuxHtm += "<tr>"
cAuxHtm += "<td colspan='2' class='top_bg' height='50px'>O usuario " + _cAliUser + " " + UPPER(Alltrim(_solicita)) + " esta solicitando contigenciamento para a seguinte verba</td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='40%' class='form1'>Aprovador</td>"
cAuxHtm += "<td width='60%' class='form2'><strong>" + NoAcento(_cAprova) + "</strong></td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='40%' class='form1'>Conta Orcamentaria</td>"
cAuxHtm += "<td width='60%' class='form2'><strong>" + NoAcento(_cConta) + "</strong></td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='40%' class='form1'>Vlr. Orcado p/ Periodo</td>"
_cValOrc := Val(_cValOrc)
_cValOrc := Alltrim(Transform( _cValOrc, "@E 999,999,999.99" ))
cAuxHtm += "<td width='60%' class='form2'><strong>R$ " + _cValOrc + "</strong></td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='40%' class='form1'>Vlr. Utilizado</td>"
_cValTot := Val(_cValTot)
_cValTot := Alltrim(Transform( _cValTot, "@E 999,999,999.99" ))
cAuxHtm += "<td width='60%' class='form2'><strong>R$ " + _cValTot + "</strong></td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='40%' class='form1'>Vlr. Contingencia</td>"
_cValRe := Val(_cValRe)
_cValRe := Alltrim(Transform( _cValRe, "@E 999,999,999.99" ))
cAuxHtm += "<td width='60%' class='form2'><strong>R$ " + _cValRe + "</strong></td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td class='form1'>Classe Valor</td>"
cAuxHtm += "<td class='form2'><strong>" + _classe + "</strong></td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td class='form1'>Centro de Custo</td>"
cAuxHtm += "<td class='form2'><strong>" + _custo + "</strong></td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td class='form1'>Produto</td>"
cAuxHtm += "<td class='form2'><strong>" + _produto + "</strong></td>"
cAuxHtm += "</tr>"
cAuxHtm += "</table>"
cAuxHtm += "</td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='100%'>&nbsp;</td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='100%'>"
cAuxHtm += "<table width='100%' style='border-bottom:1px solid #999'>"
cAuxHtm += "<tr>"
cAuxHtm += "<td colspan='12' class='top_bg' height='50px'>Ultimas Compras</td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='17%' class='form1'>Data Compra</td>"
cAuxHtm += "<td width='34%' class='form1'>Fornecedor</td>"
cAuxHtm += "<td width='20%' class='form1'>Valor Unitario</td>"
cAuxHtm += "<td width='10%' class='form1'>Quantidade</td>"
cAuxHtm += "<td width='19%' class='form1'>Valor Total</td>"
cAuxHtm += "</tr>"

Do While !(cAliAux)->(Eof())
	dEmissao := STOD((cAliAux)->C7_EMISSAO)
	dEmissao := Dtoc(dEmissao)
	cAuxHtm += "<tr>"
	cAuxHtm += "<td class='form2'>" + dEmissao + "</td>"
	cAuxHtm += "<td class='form2'>" + U_xBusFornec(,(cAliAux)->C7_FORNECE) + "</td>"
	cAuxHtm += "<td class='form2'>R$ " + Alltrim(Transform((cAliAux)->C7_PRECO,"@E 999,999,999.99")) + "</td>"
	cAuxHtm += "<td class='form2'>" + Alltrim(Str((cAliAux)->C7_QUANT))   + "</td>"
	cAuxHtm += "<td class='form2'>R$ " + Alltrim(Transform((cAliAux)->C7_TOTAL,"@E 999,999,999.99")) + "</td>"
	cAuxHtm += "</tr>"
	
	(cAliAux)->(dbskip())
EndDo

(cAliAux)->(DbCloseArea())

cAuxHtm += "</table>"
cAuxHtm += "</td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='100%'>&nbsp;</td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td>"
cAuxHtm += "<table width='21%' style='border-bottom:1px solid #999' align='left'>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='100%' colspan='2' class='top_bg' height='25px'>Aprovacao</td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='100%' class='form1'>Aprovar</td>"
cAuxHtm += "<td width='75%' class='form2' align='right'><span style='font-family: Gotham, ' Helvetica Neue ', Helvetica, Arial, sans-serif; font-style: normal; font-size: 12px;'>"
cAuxHtm += "<input type='radio' name='radio' id='radio2' value='1' ng-model='main.radio' />"
cAuxHtm += "</span></td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='100%' class='form1'>Reprovar</td>"
cAuxHtm += "<td width='75%' class='form2' align='right'><span style='font-family: Gotham, ' Helvetica Neue ', Helvetica, Arial, sans-serif; font-style: normal; font-size: 12px;'>"
cAuxHtm += "<input type='radio' name='radio' id='radio' value='2' ng-model='main.radio' />"
cAuxHtm += "</span></td>"
cAuxHtm += "</tr>"
cAuxHtm += "</table>"
cAuxHtm += "<table width='21%' style='border-bottom:1px solid #999' align='center'>"
cAuxHtm += "<tr>"
cAuxHtm += "<td colspan='2' class='top_bg' height='25px'>Motivo</td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='86%' class='form1'><textarea name='textarea' cols='50' rows='5' id='textarea' ng-model='main.motivo'></textarea></td>"
cAuxHtm += "</tr>"
cAuxHtm += "</table>"
cAuxHtm += "</td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='100%'><input type='button' name='cmdEnviar2' id='cmdEnviar2' class='button' value='   Enviar   ' ng-click='main.Send()' /></td>"
cAuxHtm += "</tr>"
cAuxHtm += "</table>"
cAuxHtm += "<table width='90%' align='center'>"
cAuxHtm += "<tr>"
cAuxHtm += "<td height='52'>"
cAuxHtm += "<div class='top_bg'>"
cAuxHtm += "<div>"
cAuxHtm += "<center>"
cAuxHtm += "<font size='1px' face='verdana'>Planejamento e Controle Orcamentario - Alatur</font>"
cAuxHtm += "</center>"
cAuxHtm += "</div>"
cAuxHtm += "</div>"
cAuxHtm += "</td>"
cAuxHtm += "</tr>"
cAuxHtm += "</table>"
cAuxHtm += "</form>"
cAuxHtm += "</body>"
cAuxHtm += "</html>"

WEB EXTENDED END

Return cAuxHtm

User Function xRetCusto(_filial,_custo)

Local aArea := GetArea()
Local cDesc := ""

DbSelectArea("CTT")
DbSetOrder(1)

If CTT->(DBSeek( _filial + _custo ))
	cDesc := CTT->CTT_DESC01 
Else
	cDesc := "Nao possui Centro de Custo"
EndIf

RestArea(aArea)

Return Alltrim(cDesc)    

User Function xRetClasse(_filial,_classe)

Local aArea := GetArea()
Local cDesc := ""

DbSelectArea("CTH")
DbSetOrder(1)

If CTH->(DBSeek( _filial + _classe ))
	cDesc := CTH->CTH_DESC01 
Else
	cDesc := "Nao possui Classe Valor"
EndIf

RestArea(aArea)

Return Alltrim(cDesc)    

User Function xRetProduto(_filial,_produto)

Local aArea := GetArea()
Local cDesc := ""

DbSelectArea("SB1")
DbSetOrder(1)

If SB1->(DbSeek(xFilial("SB1") + _produto))
	cDesc := SB1->B1_DESC 
Else
	cDesc := "Produto sem descricao"
EndIf

RestArea(aArea)

Return Alltrim(cDesc)  


User Function xHistCom(cFilHist)

Local aArea     := GetArea()
Local aHist     := {}
Local cAliAux   := GetNextAlias()
Local cQuery    := ""
Local cFornec   := ""

cQuery := "SELECT TOP 5 * FROM "
cQuery += RetSqlName("SC7") + " SC7 "
cQuery += "WHERE "
cQuery += "D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY  C7_TOTAL DESC"
	
cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

(cAliAux)->(dbGotop())

Do While !(cAliAux)->(Eof())

	cFornec := U_xBusFornec(cFilHist, (cAliAux)->C7_FORNECE)

	aAdd(aHist,{(cAliAux)->C7_EMISSAO,(cAliAux)->C7_EMISSAO, cFornec,(cAliAux)->C7_PRECO, (cAliAux)->C7_QUANT, (cAliAux)->C7_TOTAL } )
	
	(cAliAux)->(dbskip())
	
Enddo

RestArea(aArea)

Return aHist

User Function xBusFornec(cFilHist, cFornec)

Local aArea	:= GetArea()
Local cDesc := ""

DbSelectArea("SA2")
DbSetOrder(1)

If SA2->(DBSeek( xFilial("SA2") + cFornec ))
	cDesc := Alltrim(SA2->A2_NOME)
Else
	cDesc := "Fornec. não encontrado"
EndIf

RestArea(aArea)

Return cDesc

User Function xRetConta(_filial,_cConta)

Local aArea	:= GetArea()
Local cDesc := ""

DbSelectArea("AK5")
DbSetOrder(1)

If AK5->(DBSeek( _filial + _cConta ))
	cDesc := Alltrim(AK5->AK5_DESCRI)
Else
	cDesc := "Fornec. não encontrado"
EndIf

cDesc := Alltrim(cDesc)

RestArea(aArea)

Return cDesc