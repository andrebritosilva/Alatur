#include 'protheus.ch'
#include 'parmtype.ch'

//====================================================================================================================
/*/{Protheus.doc} UpdConcil(cFilRV, cNumId, cIdItem, cNumSeq, cConcil, cProd)
Ajuste para corrigir problema ocorrido durante a inutilização pela conciliação - DSERTUR-2024

@author antenor.silva
@since 18/09/2018
@version P12
@return NIL
/*/
//====================================================================================================================
user function Antenor(cFilRV, cNumId, cIdItem, cNumSeq, cConcil, cProd)
Local aArea		:= GetArea()
Local aAreaAux	:= ''
Local aTabelas	:= {'G3Q','G4A','G3S','G3R','G44','G46','G48','G4B','G4C','G9K'}
Local cTabAux	:= ''
Local nX		:= 0
Local cQuery    := ''
Local lRet		:= .T.

DEFAULT cFilRV	:= '01SP0005'
DEFAULT cNumId	:= '1810732291'
DEFAULT cIdItem	:= '0001'
DEFAULT cNumSeq	:= '01'
DEFAULT cConcil	:= '111602'
DEFAULT cProd	:= '2'

BEGIN TRANSACTION
		
	For nX := 1 to Len(aTabelas)
	
		cQuery   := ''
		aAreaAux := &(aTabelas[nX])->(GetArea())		
		cQuery := "UPDATE " + RetSQLName(aTabelas[nX]) 
		cQuery += " SET " + aTabelas[nX] + "_CONINU = '" + cConcil + "' " 
		cQuery += " WHERE " + aTabelas[nX] + "_FILIAL = '" + cFilRV + "' AND  "+ aTabelas[nX] +"_NUMID = '" + cNumId + "' AND "+ aTabelas[nX] +"_IDITEM = '" + cIdItem + "' AND "+ aTabelas[nX] +"_NUMSEQ = '" + cNumSeq + "' AND "+ aTabelas[nX] +"_CONORI = "+ aTabelas[nX] +"_CONINU "
		cQuery += IIF(TCSrvType() == "AS/400", "AND @DELETED@ = ' ' ", "AND D_E_L_E_T_ = ' '")
	
		If TCSQLExec(cQuery) < 0
			DisarmTransaction()
			Break
		EndIf	
		RestArea(aAreaAux)
		
	Next nX
	
	Do Case
		Case cProd == '1' //aéreo
			cTabAux := 'G3T'
		Case cProd == '2' //hotel
			cTabAux := 'G3U'
		Case cProd == '3' //carro
			cTabAux := 'G3V'
		Case cProd == '4' //rodoviário
			cTabAux := 'G3W'
		Case cProd == '5' //cruzeiro
			cTabAux := 'G3Y'
		Case cProd == '6' //trem
			cTabAux := 'G3X'
		Case cProd == '7' //visto
			cTabAux := 'G42'
		Case cProd == '8' //seguro
			cTabAux := 'G41'
		Case cProd == '9' //tour
			cTabAux := 'G40'
		Case cProd == 'A' //pacote
			cTabAux := 'G3Z'
		Case cProd == 'B' //outros
			cTabAux := 'G43'
	End Case

	cQuery := ''
	aAreaAux := &(cTabAux)->(GetArea())		
	cQuery := "UPDATE " + RetSQLName(cTabAux) 
	cQuery += " SET "+ cTabAux +"_CONINU = '" + cConcil + "' "
	cQuery += " WHERE "+ cTabAux +"_FILIAL = '" + cFilRV + "' AND "+ cTabAux +"_NUMID = '" + cNumId + "' AND "+ cTabAux +"_IDITEM = '" + cIdItem + "' AND "+ cTabAux +"_NUMSEQ = '" + cNumSeq + "' AND "+ cTabAux +"_CONORI = "+ cTabAux +"_CONINU "
	cQuery += IIF(TCSrvType() == "AS/400", "AND @DELETED@ = ' ' ", "AND D_E_L_E_T_ = ' '") 

	If TCSQLExec(cQuery) < 0
		DisarmTransaction()
		lRet := .F. 
		Break
	EndIf
	RestArea(aAreaAux)		
	
END TRANSACTION	

MsgAlert("Processo finalizado.")

RestArea(aArea)
return