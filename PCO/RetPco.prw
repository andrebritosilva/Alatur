#include "rwmake.ch"
#include "colors.ch"
#Include "topconn.ch"
#Include "protheus.ch"
#Include "tbiconn.ch"
#Include "APWEBEX.CH"

User Function RetPco()

Local cAuxHtm := ""

_empresa   := alltrim(HttpGet->cEmpresa) 
_filial    := alltrim(HttpGet->Filial)

Prepare Environment Empresa _empresa Filial _filial

WEB EXTENDED INIT cAuxHtm

__cont     := alltrim(HttpGet->cCont) 
__usuario  := alltrim(HttpGet->cUser)

cAuxHtm := "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'><html xmlns='http://www.w3.org/1999/xhtml'><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><style type='text/css'>.button {font-family: Verdana, Arial, Helvetica , sans-serif;font-size: 10px;color: #000000;border: 1px ridge #CC6600;font-weight: bold;margin: 1px;padding: 10px;background-color: #ECEEEB;}.text {font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 11px;color: 660000;text-decoration: none;font-style: normal;}.title {font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 13px;color: 660000;text-decoration: none;font-weight: bold;}.table {border-bottom: 1px solid #999;border-right: 1px solid #999;border-left: 1px solid #999;border-top: 1px solid #999;margin: 1em auto;}.form0 {font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 13px;color: #FFF;text-decoration: none;font-weight: bold;background-color: #788EA7}.form1 {font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 10px;color: #000000;text-decoration: none;font-weight: bold;background-color: #ECF0EE;}.form2 {font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 11px;color: #333333;text-decoration: none;background-color: #F7F9F8;}.form3 {font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 9px;color: #333333;text-decoration: none;background-color: #F7F9F8;font-weight: bold}.form4 {font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 16px;color: #F00;text-decoration: none;}.links {font-family: Arial, Helvetica, sans-serif;font-size: 11px;color: 660000;text-decoration: underline;font-style: normal;}.top_bg {background-color: darkgray;center repeat-x;margin: 0;padding: 0;font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 13px;text-decoration: none;font-weight: bold;text-align: center;color: #FFF}</style>"
cAuxHtm += '<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.1/angular.min.js"></script>'
cAuxHtm += "<script language='JavaScript' type='text/javascript'>"
cAuxHtm += "</script><title>Aprova&ccedil;&atilde;o de Cota&ccedil;&otilde;es de Compra</title></head><body ng-app='app' ng-controller='MainController as main'><table width='90%' class='table'><tr>"
cAuxHtm += "<td width='93%' height='50' align='center' class='top_bg' style='font-size: 13px'>Resposta Enviada!</td></tr></table><form action='MailTo:%WFMAILTO%' method='POST' name='frmWFCotacao'><table width='90%' class='table'><tr></tr></table><table width='90%' align='center'><tr><td height='52'><div class='top_bg'><div><center>"
cAuxHtm += "<font size='1px' face='verdana'>Envio de aprovacao de contigencia - Alatur</font>"
cAuxHtm += "</center></div></div></td></tr></table></form></body></html>"

WEB EXTENDED END

Return cAuxHtm