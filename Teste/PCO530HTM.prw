#include "rwmake.ch"
#include "colors.ch"
#Include "topconn.ch"
#Include "protheus.ch"
#Include "tbiconn.ch"
#Include "APWEBEX.CH"

User Function PCO530HTM()

Local cHtmCopy     := paramixb[1]
Local aDadosCtg    := paramixb[2]
Local cNumCont     := aDadosCtg[3]//""//SUBSTR(cHtmCopy, 6423, 5)
Local cUsuHtm      := RetUsrAli(cNumCont)
Local oProcess     := Nil                                            //Objeto da classe TWFProcess.
Local cMailId      := ""                                            //ID do processo gerado.
Local cHostWF      := "http://187.94.63.204:14010/wf/" //SUPERGETMV("MV_WFPCO",.F.,"http://qbsnct.prd.protheus.totvscloud.com.br:12182/wf/")//"http://187.94.63.204:14010/wf/"        //URL configurado no ini para WF Link.
Local cRest        := "" //SUPERGETMV("MV_RESTPCO",.F.,"https://qbsnct.prd.protheus.totvscloud.com.br:12386/rest")      
Local cTeste       := ""
Local cAliAux      := GetNextAlias()
Local cAuxHtm      := ""
Local aHistCom     := {}
Local cQuery       := ""
Local cAuxHtm      := ""
Local cPasta	   := "\messenger\emp"+ cEmpAnt
Local cArqHTM	   := CriaTrab( NIL , .F. ) + ".htm"
Local nHdl		   := Fcreate(cPasta+ "\" + cArqHTM)
Local cUrl		   := "http://"
Local cAcesse      := "Clique aqui para aprovar sua contigencia!"
Local nPosProduto  := 0
Local nPosData     := 0
Local nPosCusto    := 0
Local nPosClasse   := 0
Local nPosValUnit  := 0
Local nPosQuanti   := 0
Local nPosValTot   := 0
Local _cont        := ""
Local _produto     := ""
Local _datacom     := ""
Local _solicita    := ""
Local _filial      := ""
Local _datasol     := ""
Local _alisolic    := ""
Local _cEmail      := ""
Local _cBloq       := ""
Local _custo       := ""
Local _classe      := ""
Local _cValUnit    := ""
Local _cQuant      := ""
Local _cValTot     := ""
Local _cAliUser    := ""
Local _cValOrc     := ""
Local _cValRe      := ""
Local _cConta      := ""
Local cCodPro      := ""
Local aAreaK1      := {}
Local lSz3         := .F.
Local dEmissao

lSz3 := LocalSz3(cNumCont)

If !lSz3
	
	nPosProduto  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
	nPosData     := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_DATPRF"})
	nPosCusto    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CC"})
	nPosClasse   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CLVL"})
	nPosValUnit  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})
	nPosQuanti   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_QUANT"})
	nPosValTot   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_TOTAL"})
	_cont        := ALI->ALI_CDCNTG
	_produto     := Alltrim(aCols[n][nPosProduto])
	_datacom     := Alltrim(Dtos(aCols[n][nPosData]))
	_solicita    := Alltrim(ALI->ALI_NOMSOL)
	_filial      := ALI->ALI_FILIAL
	_datasol     := DTOC(ALI->ALI_DTSOLI)
	_alisolic    := ALI->ALI_SOLIC
	_cEmail      := ALI->ALI_USER
	_cBloq       := ALI->ALI_CODBLQ
	_custo       := Alltrim(aCols[n][nPosCusto])
	_classe      := Alltrim(aCols[n][nPosClasse])
	_cValUnit    := Alltrim(Str(aCols[n][nPosValUnit]))
	_cQuant      := Alltrim(Str(aCols[n][nPosQuanti]))
	_cValTot     := Alltrim(Str(aCols[n][nPosValTot]))
	_cAliUser    := cUsuHtm//Alltrim(ALI->ALI_USER)
	_cValOrc     := Alltrim(Str(aRec[3]))
	_cValRe      := Alltrim(Str(aRec[2]))
	_cConta      := aRec[4]
	
	aAreaK1 := GetArea()
	
	DbSelectArea("SZ3")
 	DbSetOrder(1)
 	If !DbSeek(xFilial("SZ3") + cNumCont)
	 	RecLock("SZ3",.T.)
	 		
	 		SZ3->Z3_CONT    := _cont         
			SZ3->Z3_PROD    := _produto     
			SZ3->Z3_DATA    := Stod(_datacom)
			//SZ3->Z3_BLOQ  := _cBloq 
			SZ3->Z3_CUSTO   := _custo       
			SZ3->Z3_CLASSE  := _classe       
			SZ3->Z3_VALUNIT := Val(_cValUnit)
			SZ3->Z3_QTD     := Val(_cQuant)
			SZ3->Z3_VALTOT  := Val(_cValTot)
			SZ3->Z3_VALORC  := _cValOrc      
			SZ3->Z3_VALRE   := _cValRe       
			SZ3->Z3_CONTA   := _cConta       
			 	
	 	MsUnLock()
	EndIf
	
	RestArea(aAreaK1)
Else
 	aAreaK1 := GetArea()
 	
 	DbSelectArea("ALI")
 	ALI->(DbSetorder(1))
    If ALI->(DbSeek(xFilial("ALI")+ cNumCont + cUsuHtm))
    
	 	_solicita    := Alltrim(ALI->ALI_NOMSOL)
		_filial      := ALI->ALI_FILIAL
		_datasol     := DTOC(ALI->ALI_DTSOLI)
		_alisolic    := ALI->ALI_SOLIC
		_cEmail      := ALI->ALI_USER
		_cAliUser    := Alltrim(ALI->ALI_USER)
	Else
		_solicita    := "ERRO"
	EndIf
	
 	DbSelectArea("SZ3")
 	DbSetOrder(1)
 	If DbSeek(xFilial("SZ3") + cNumCont)
 	
 	_cont        := SZ3->Z3_CONT
	_produto     := SZ3->Z3_PROD
	_datacom     := Alltrim(Dtos(SZ3->Z3_DATA))
	_cBloq       := "001"//colocar na tabela SZ3 campo bloqueio
	_custo       := SZ3->Z3_CUSTO
	_classe      := SZ3->Z3_CLASSE
	_cValUnit    := Alltrim(Str(SZ3->Z3_VALUNIT))
	_cQuant      := Alltrim(Str(SZ3->Z3_QTD))
	_cValTot     := Alltrim(Str(SZ3->Z3_VALTOT))
	_cValOrc     := SZ3->Z3_VALORC
	_cValRe      := SZ3->Z3_VALRE
	_cConta      := SZ3->Z3_CONTA
	Else
		_cont        := "Erro"
	EndIf
 	
 	RestArea(aAreaK1)
 	
EndIf
/*
Local nPosProduto  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
Local nPosData     := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_DATPRF"})
Local nPosCusto    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CC"})
Local nPosClasse   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CLVL"})
Local nPosValUnit  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})
Local nPosQuanti   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_QUANT"})
Local nPosValTot   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_TOTAL"})

Local _cont        := ALI->ALI_CDCNTG
Local _produto     := Alltrim(aCols[n][nPosProduto])
Local _datacom     := Alltrim(Dtos(aCols[n][nPosData]))
Local _solicita    := Alltrim(ALI->ALI_NOMSOL)
Local _filial      := ALI->ALI_FILIAL
Local _datasol     := DTOC(ALI->ALI_DTSOLI)
Local _alisolic    := ALI->ALI_SOLIC
Local _cEmail      := ALI->ALI_USER
Local _cBloq       := ALI->ALI_CODBLQ
Local _custo       := Alltrim(aCols[n][nPosCusto])
Local _classe      := Alltrim(aCols[n][nPosClasse])
Local _cValUnit    := Alltrim(Str(aCols[n][nPosValUnit]))
Local _cQuant      := Alltrim(Str(aCols[n][nPosQuanti]))
Local _cValTot     := Alltrim(Str(aCols[n][nPosValTot]))
Local _cAliUser    := Alltrim(ALI->ALI_USER)
Local _cValOrc     := Alltrim(Str(aRec[3]))
Local _cValRe      := Alltrim(Str(aRec[2]))
Local _cConta      := aRec[4]
*/

cUrl += alltrim( GetMV( "MV_WFBRWSR" ) )
cUrl += STRTRAN(cPasta, "\", "/")

cCodPro := _produto

_custo   := U_xRetCusto(_filial,_custo)
_classe  := U_xRetClasse(_filial,_classe)
_produto := U_xRetProduto(_filial,_produto)
_cConta  := U_xRetConta(_filial,_cConta)
_cEmail  := UsrRetMail(_cEmail)
_cEmail  := Alltrim(_cEmail)
aHistCom := U_xHistCom(_filial)

cQuery := "SELECT TOP 5 C7_EMISSAO, C7_FORNECE, C7_PRECO, C7_QUANT, C7_TOTAL  FROM "
cQuery += RetSqlName("SC7") + " SC7 "
cQuery += " WHERE C7_PRODUTO='" + cCodPro + "'"
cQuery += " AND D_E_L_E_T_ = ' ' ORDER BY C7_TOTAL DESC "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

(cAliAux)->(dbGotop())


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
cAuxHtm += "obj.cuser = '" + __cUserId + "'" + Chr(13) + Chr(10)
cAuxHtm += "obj.email = '" + _cEmail + "'" + Chr(13) + Chr(10)
cAuxHtm += "obj.empresa = '" + cEmpAnt + "'" + Chr(13) + Chr(10)
cAuxHtm += "obj.filial = '" + cFilAnt + "'" + Chr(13) + Chr(10)
cAuxHtm += "obj.bloqueio = '" + _cBloq + "'" + Chr(13) + Chr(10) 
cAuxHtm += "obj.alisolic = '" + _alisolic + "'" + Chr(13) + Chr(10)

//cAuxHtm += '$http.post("http://localhost:8082/rest/WSRESTField",obj).' + Chr(13) + Chr(10) 
cAuxHtm += '$http.post("http://alatur.totvs.com.br:8006/rest/WSRESTField",obj).' + Chr(13) + Chr(10)
cAuxHtm += "success(function(dados) {"+ Chr(13) + Chr(10)

//cAuxHtm += 'window.location.assign("http://localhost:8085/U_RetPco.apw?cparam=1&cCont=' + _cont + '&cUser=' + __cUserId + '&cEmpresa=' + cEmpAnt +'&Filial=' + cFilAnt + '");'+ Chr(13) + Chr(10)
cAuxHtm += 'window.location.assign("http://187.94.63.204:14010/workflow/Sucesso.html");'+ Chr(13) + Chr(10)
cAuxHtm += "console.log(dados)"+ Chr(13) + Chr(10) 
cAuxHtm += "}).error(function(erro) {"+ Chr(13) + Chr(10)
//cAuxHtm += 'window.location.assign("http://localhost:8085/U_RetPco.apw?cparam=1&cCont=' + _cont + '&cUser=' + __cUserId + '&cEmpresa=' + cEmpAnt +'&Filial=' + cFilAnt + '");'+ Chr(13) + Chr(10)
cAuxHtm += 'window.location.assign("http://187.94.63.204:14010/workflow/Sucesso.html");'+ Chr(13) + Chr(10)
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
cAuxHtm += "<td colspan='2' class='top_bg' height='50px'>O usuario " + UPPER(aDadosCtg[13]) + " esta solicitando contigenciamento para a seguinte verba</td>"
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
_cValRe := Val(_cValRe)
_cValRe := Alltrim(Transform( _cValRe, "@E 999,999,999.99" ))
cAuxHtm += "<td width='60%' class='form2'><strong>R$ " + _cValRe + "</strong></td>"
cAuxHtm += "</tr>"
cAuxHtm += "<tr>"
cAuxHtm += "<td width='40%' class='form1'>Vlr. Contingencia</td>"
_cValTot := Val(_cValTot)
_cValRe  := STRTRAN (_cValRe, ".", "")
_cValOrc := STRTRAN (_cValOrc, ".", "")
_cValTot := (Val(_cValRe) - Val(_cValOrc)) * 100
_cValTot := Alltrim(Transform( _cValTot, "@E 999,999,999.99" ))
cAuxHtm += "<td width='60%' class='form2'><strong>R$ " + _cValTot + "</strong></td>"
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
cAuxHtm += '<a class="links" href="'+cUrl+"\"+cArqHTM+'"><Font size=5 color= White>'+ cAcesse +'</font></a>' + CRLF
cAuxHtm += "</center>"
cAuxHtm += "</div>"
cAuxHtm += "</div>"
cAuxHtm += "</td>"
cAuxHtm += "</tr>"
cAuxHtm += "</table>"
cAuxHtm += "</form>"
cAuxHtm += "</body>"
cAuxHtm += "</html>"

FWrite(nHdl,cAuxHtm,Len(cAuxHtm))	

//Fecha LOG
FClose(nHdl)                            

Ms_Flush()

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

Static Function RetUsrAli(cNumCont)

Local cCodUsr   := ""
Local aArea	    := GetArea()
Local cAliAux   := GetNextAlias()
Local cQuery    := ""

cQuery := "SELECT * FROM " + RetSqlName("ALI") + " ALI" 
cQuery += " WHERE ALI_CDCNTG = '" + cNumCont + "' AND D_E_L_E_T_ = '' ORDER BY ALI_NIVEL"

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

(cAliAux)->(dbGotop())

Do While !(cAliAux)->(Eof())
	
	If (cAliAux)->ALI_STATUS == "02"
		cCodUsr := (cAliAux)->ALI_USER
	EndIf
	
	(cAliAux)->(dbskip())
	
Enddo

RestArea(aArea)

Return cCodUsr



Static Function LocalSz3(cNumCont)

Local aArea	:= GetArea()
Local lRet  := .T.

DbSelectArea("SZ3")
DbSetOrder(1)

If DbSeek(xFilial("SZ3") + cNumCont)
	lRet := .T.
Else
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet