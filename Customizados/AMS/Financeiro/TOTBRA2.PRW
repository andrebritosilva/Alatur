#INCLUDE "RWMAKE.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  TOTBRA    ºAutor  ³Ronaldo Bicudo      º Data ³  12/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula o valor total do tralling, decrescimo e acrescimo  º±±
±±º          ³   														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10 Estre                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TOTBRA2()   // Soma Valores

Local _cBor1 := MV_PAR01
Local _cBor2 := MV_PAR02
//Alterado Ronaldo Bicudo - Analista Totvs - 21/12/2011
Local _cBanc := MV_PAR05
//Local _cAgen := MV_PAR06
//Local _cCont := MV_PAR07  
//Final da Alteração
_nSoma := 0.00
_cAreaSE2 := GetArea("SE2")
_cAreaSEA := GetArea("SEA")
_cQuery :=" SELECT E2_SALDO,E2_ACRESC,E2_DECRESC,E2_NUMBOR FROM "+ RetsqlName("SE2")
_cQuery += " WHERE E2_NUMBOR >= '"+_cBor1+ "'"
_cQuery += " AND E2_NUMBOR <= '"+_cBor2+ "'" 
_cQuery += " AND E2_PORTADO = '"+_cBanc+ "'"
_cQuery += " AND D_E_L_E_T_ = ''"      

TcQuery _cQuery New Alias "SE2TMP"

DbSelectArea("SE2TMP")
SE2TMP->(DbGotop())

While ! SE2TMP->(EOF())
	_nSoma += (SE2TMP->E2_SALDO+SE2TMP->E2_ACRESC)-SE2TMP->E2_DECRESC
	SE2TMP->(DbSkip())
Enddo

_nSoma := STRZERO(_nSoma*100,17)

RestArea(_cAreaSE2)
RestArea(_cAreaSEA)
SE2TMP->(DbCloseArea())   

Return(_nSoma)