#Include "Protheus.ch"
#Include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETGRPPRD ºAutor  ³Microsiga           º Data ³  01/09/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna Grupo do Produto através da Fatura.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Alatur.                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function retGrpPrd()
Local cRet := ""
Local aArea := GetArea()
Local aAreaG85 := G85->(GetArea())
Local aAreaG48 := G48->(GetArea())
Local aAreaG4C := G4C->(GetArea())
Local cQuery := ""
Local cTab := ""

If (AllTrim(G85->G85_PREFIX) == "APU")
	cQuery := "SELECT TOP 1 T0.G4C_GRPPRD" + CRLF
	cQuery += "FROM " + RetSQLName("G4C") + " T0" + CRLF
	cQuery += "WHERE T0.G4C_FILIAL = '" + xFilial("G4C") + "'" + CRLF
	cQuery += "	AND T0.G4C_NUMID = (" + CRLF
	cQuery += "		SELECT TOP 1 T1.G48_NUMID" + CRLF
	cQuery += "		FROM " + RetSQLName("G48") + " T1" + CRLF
	cQuery += "		WHERE T1.G48_FILIAL = '" + xFilial("G48") + "'" + CRLF
	cQuery += "			AND T1.G48_CODAPU = '" + G85->G85_CODAPU + "'" + CRLF
	cQuery += "			AND T1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "	AND T0.D_E_L_E_T_ = ''"
	
	cQuery := ChangeQuery(cQuery)
	
	cTab := GetNextAlias()
	
	TcQuery cQuery NEW ALIAS ((cTab))
	
	DbSelectArea((cTab))
	(cTab)->(DbGoTop())
	
	While ((cTab)->(!Eof()))
		cRet := AllTrim((cTab)->G4C_GRPPRD)

		(cTab)->(DbSkip())
	Enddo
	
	(cTab)->(DbCloseArea())
Endif

RestArea(aAreaG4C)
RestArea(aAreaG48)
RestArea(aAreaG85)
RestArea(aArea)
Return(cRet)