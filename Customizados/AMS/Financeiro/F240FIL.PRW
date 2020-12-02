#Include "Protheus.ch"

//--------------------------------------------------------------------
/*/{Protheus.doc} F240FIL
Filtro do Bordero de Pagamento com Impostos.

@author Felipe Morais
@since  29/08/2016
@version 1.0
/*/
//--------------------------------------------------------------------

User Function F240FIL()
Local cRet := ""

If (AllTrim(cModPgto) == "30")
	cRet := "!Empty(E2_CODBAR) .And. SubStr(E2_CODBAR, 1, 3) == '" + cPort240 + "'"
Elseif (AllTrim(cModPgto) == "31")
//	cRet := "!Empty(E2_CODBAR) .And. SubStr(E2_CODBAR, 1, 1) <> '8' .And. SubStr(E2_CODBAR, 1, 3) <> '" + cPort240 + "'"
	cRet := "!Empty(E2_CODBAR) .And. SubStr(E2_CODBAR, 1, 1) <> '8'"
Elseif (AllTrim(cModPgto) == "01")
	cRet := "Empty(E2_CODBAR) .And. U_240Forn(E2_FORNECE, E2_LOJA)"
Elseif (AllTrim(cModPgto) == "03")
	cRet := "Empty(E2_CODBAR) .And. U_240Forn(E2_FORNECE, E2_LOJA)"
Endif
Return(cRet)

//--------------------------------------------------------------------
/*/{Protheus.doc} 240Forn
Filtro do Bordero de Pagamento com Impostos.

@author Felipe Morais
@since  29/08/2016
@version 1.0
/*/
//--------------------------------------------------------------------

User Function 240Forn(cFornece, cLoja)
Local lRet := .T.
Local aArea := GetArea()
Local aAreaSA2 := SA2->(GetArea())

DbSelectArea("SA2")
SA2->(DbSetOrder(1))
If (SA2->(DbSeek(xFilial("SA2") + cFornece + cLoja)))
	If (AllTrim(cModPgto) == "01")
		lRet := Iif(AllTrim(SA2->A2_BANCO) == cPort240, .T., .F.)
	Else
		lRet := Iif(AllTrim(SA2->A2_BANCO) <> cPort240, .T., .F.)
	Endif
Endif

RestArea(aAreaSA2)
RestArea(aArea)
Return(lRet)