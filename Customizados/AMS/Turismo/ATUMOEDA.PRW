#include "PROTHEUS.CH"
#include "topconn.ch"
                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuMoeda   บAutor  ณTotvs     บ Data ณ  21/09/16            บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca Moeda pelo codigo informado pela Alatur do arquivo   บฑฑ
ฑฑบ          ณ txt que ้ carregado pelo Mille                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P12 - Alatur    x                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AtuMoeda(_cxA)
           
Local aAreaAtu	:= GetArea()
Local cMoeda	:= ''
Local _cQuery	:= ''
     
_cQuery := " SELECT G5T_CODIGO FROM "+ RetsqlName("G5T")
_cQuery += " WHERE G5T_FILIAL = '"+xFilial("G9L")+ "'"
_cQuery += " AND G5T_SIMBOL = '"+_cxA+ "'" 
_cQuery += " AND G5T_MSBLQL = '2'" 
_cQuery += " AND D_E_L_E_T_ <> '*'"

TcQuery ChangeQuery(_cQuery) New Alias "G5TCOD"

DbSelectArea("G5TCOD")
G5TCOD->(DbGotop())

cMoeda := G5TCOD->G5T_CODIGO

G5TCOD->(DbCloseArea())

/*DbSelectArea("G5T")
DbGoTop()
DbSetOrder(4)
If MsSeek(xFilial("G9L")+_cxA)

	cMoeda := G5T->G5T_CODIGO
	
EndIf

G5T->(DbCloseArea())
*/
RestArea(aAreaAtu)

Return(cMoeda)