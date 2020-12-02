#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} DELSXTUR
Função para ajuste dos SX do módulo Sigatur
@author    Marcelo Cardoso Barbosa
@version   1.00
@since     26/02/2016
/*/
Function DELSXTUR()

	Local aDelSX    := {}
	Local nDelSX    := 0
	Local cAreaDel  := ""
	Local nOrderDel := ""
	Local cKeyDel   := ""
	Local lLock     := .F.
	
	AAdd(aDelSX, {"SXB", 1, "G5S", })
	AAdd(aDelSX, {"SXB", 1, "G5SS1"})
	AAdd(aDelSX, {"SXB", 1, "G5SS1"})
	AAdd(aDelSX, {"SXB", 1, "G3C"  })
	
	AAdd(aDelSX, {"SX3", 2, "G4W_DESCRI" })
	AAdd(aDelSX, {"SX3", 2, "G4W_CLASSI" })
	AAdd(aDelSX, {"SX3", 2, "G4W_TPACO"  })
	AAdd(aDelSX, {"SX3", 2, "G4W_TPENT"  })
	AAdd(aDelSX, {"SX3", 2, "G4W_FORAPL" })
	AAdd(aDelSX, {"SX3", 2, "G4W_VIGINI" })
	AAdd(aDelSX, {"SX3", 2, "G4W_VIGFIM" })
	AAdd(aDelSX, {"SX3", 2, "G4W_OBSERV" })
	AAdd(aDelSX, {"SX3", 2, "G4W_DESCFT" })
	AAdd(aDelSX, {"SX3", 2, "G5V_ACOORI" })
	AAdd(aDelSX, {"SX3", 2, "G5V_BASAPUC"})
	AAdd(aDelSX, {"SX3", 2, "G5V_TPVAL"  })
	AAdd(aDelSX, {"SX3", 2, "G5V_NIVEL"  })
	AAdd(aDelSX, {"SX3", 2, "G4X_TPENT"  })
	AAdd(aDelSX, {"SX3", 2, "G4X_APLCRV" })
	//G3C
	
	AAdd(aDelSX, {"SIX", 1, "G3P"})
	AAdd(aDelSX, {"SIX", 1, "G3Q"})
	AAdd(aDelSX, {"SIX", 1, "G3R"})
	AAdd(aDelSX, {"SIX", 1, "G3S"})
	AAdd(aDelSX, {"SIX", 1, "G3T"})
	AAdd(aDelSX, {"SIX", 1, "G3U"})
	AAdd(aDelSX, {"SIX", 1, "G3V"})
	AAdd(aDelSX, {"SIX", 1, "G3X"})
	AAdd(aDelSX, {"SIX", 1, "G3W"})
	AAdd(aDelSX, {"SIX", 1, "G3Y"})
	AAdd(aDelSX, {"SIX", 1, "G3Z"})
	AAdd(aDelSX, {"SIX", 1, "G40"})
	AAdd(aDelSX, {"SIX", 1, "G41"})
	AAdd(aDelSX, {"SIX", 1, "G42"})
	AAdd(aDelSX, {"SIX", 1, "G43"})
	AAdd(aDelSX, {"SIX", 1, "G44"})
	AAdd(aDelSX, {"SIX", 1, "G45"})
	AAdd(aDelSX, {"SIX", 1, "G46"})
	AAdd(aDelSX, {"SIX", 1, "G47"})
	AAdd(aDelSX, {"SIX", 1, "G48"})
	AAdd(aDelSX, {"SIX", 1, "G49"})
	AAdd(aDelSX, {"SIX", 1, "G4A"})
	AAdd(aDelSX, {"SIX", 1, "G4B"})
	AAdd(aDelSX, {"SIX", 1, "G4C"})
	AAdd(aDelSX, {"SIX", 1, "G4D"})
	AAdd(aDelSX, {"SIX", 1, "G4E"})
	
	AAdd(aDelSX, {"SX2", 1, "G3P"})
	AAdd(aDelSX, {"SX2", 1, "G3Q"})
	AAdd(aDelSX, {"SX2", 1, "G3R"})
	AAdd(aDelSX, {"SX2", 1, "G3S"})
	AAdd(aDelSX, {"SX2", 1, "G3T"})
	AAdd(aDelSX, {"SX2", 1, "G3U"})
	AAdd(aDelSX, {"SX2", 1, "G3V"})
	AAdd(aDelSX, {"SX2", 1, "G3X"})
	AAdd(aDelSX, {"SX2", 1, "G3W"})
	AAdd(aDelSX, {"SX2", 1, "G3Y"})
	AAdd(aDelSX, {"SX2", 1, "G3Z"})
	AAdd(aDelSX, {"SX2", 1, "G40"})
	AAdd(aDelSX, {"SX2", 1, "G41"})
	AAdd(aDelSX, {"SX2", 1, "G42"})
	AAdd(aDelSX, {"SX2", 1, "G43"})
	AAdd(aDelSX, {"SX2", 1, "G44"})
	AAdd(aDelSX, {"SX2", 1, "G45"})
	AAdd(aDelSX, {"SX2", 1, "G46"})
	AAdd(aDelSX, {"SX2", 1, "G47"})
	AAdd(aDelSX, {"SX2", 1, "G48"})
	AAdd(aDelSX, {"SX2", 1, "G49"})
	AAdd(aDelSX, {"SX2", 1, "G4A"})
	AAdd(aDelSX, {"SX2", 1, "G4B"})
	AAdd(aDelSX, {"SX2", 1, "G4C"})
	AAdd(aDelSX, {"SX2", 1, "G4D"})
	AAdd(aDelSX, {"SX2", 1, "G4E"})
	
	AAdd(aDelSX, {"SX3", 1, "G3P"})
	AAdd(aDelSX, {"SX3", 1, "G3Q"})
	AAdd(aDelSX, {"SX3", 1, "G3R"})
	AAdd(aDelSX, {"SX3", 1, "G3S"})
	AAdd(aDelSX, {"SX3", 1, "G3T"})
	AAdd(aDelSX, {"SX3", 1, "G3U"})
	AAdd(aDelSX, {"SX3", 1, "G3V"})
	AAdd(aDelSX, {"SX3", 1, "G3X"})
	AAdd(aDelSX, {"SX3", 1, "G3W"})
	AAdd(aDelSX, {"SX3", 1, "G3Y"})
	AAdd(aDelSX, {"SX3", 1, "G3Z"})
	AAdd(aDelSX, {"SX3", 1, "G40"})
	AAdd(aDelSX, {"SX3", 1, "G41"})
	AAdd(aDelSX, {"SX3", 1, "G42"})
	AAdd(aDelSX, {"SX3", 1, "G43"})
	AAdd(aDelSX, {"SX3", 1, "G44"})
	AAdd(aDelSX, {"SX3", 1, "G45"})
	AAdd(aDelSX, {"SX3", 1, "G46"})
	AAdd(aDelSX, {"SX3", 1, "G47"})
	AAdd(aDelSX, {"SX3", 1, "G48"})
	AAdd(aDelSX, {"SX3", 1, "G49"})
	AAdd(aDelSX, {"SX3", 1, "G4A"})
	AAdd(aDelSX, {"SX3", 1, "G4B"})
	AAdd(aDelSX, {"SX3", 1, "G4C"})
	AAdd(aDelSX, {"SX3", 1, "G4D"})
	AAdd(aDelSX, {"SX3", 1, "G4E"})
	
	AAdd(aDelSX, {"SX9", 1, "G3P"})
	AAdd(aDelSX, {"SX9", 1, "G3Q"})
	AAdd(aDelSX, {"SX9", 1, "G3R"})
	AAdd(aDelSX, {"SX9", 1, "G3S"})
	AAdd(aDelSX, {"SX9", 1, "G3T"})
	AAdd(aDelSX, {"SX9", 1, "G3U"})
	AAdd(aDelSX, {"SX9", 1, "G3V"})
	AAdd(aDelSX, {"SX9", 1, "G3X"})
	AAdd(aDelSX, {"SX9", 1, "G3W"})
	AAdd(aDelSX, {"SX9", 1, "G3Y"})
	AAdd(aDelSX, {"SX9", 1, "G3Z"})
	AAdd(aDelSX, {"SX9", 1, "G40"})
	AAdd(aDelSX, {"SX9", 1, "G41"})
	AAdd(aDelSX, {"SX9", 1, "G42"})
	AAdd(aDelSX, {"SX9", 1, "G43"})
	AAdd(aDelSX, {"SX9", 1, "G44"})
	AAdd(aDelSX, {"SX9", 1, "G45"})
	AAdd(aDelSX, {"SX9", 1, "G46"})
	AAdd(aDelSX, {"SX9", 1, "G47"})
	AAdd(aDelSX, {"SX9", 1, "G48"})
	AAdd(aDelSX, {"SX9", 1, "G49"})
	AAdd(aDelSX, {"SX9", 1, "G4A"})
	AAdd(aDelSX, {"SX9", 1, "G4B"})
	AAdd(aDelSX, {"SX9", 1, "G4C"})
	AAdd(aDelSX, {"SX9", 1, "G4D"})
	AAdd(aDelSX, {"SX9", 1, "G4E"})
	
	AAdd(aDelSX, {"SX5", 1, xFilial("SX5") + "X511"})
	AAdd(aDelSX, {"SX5", 1, xFilial("SX5") + "X514"})
	AAdd(aDelSX, {"SX5", 1, xFilial("SX5") + "X515"})
	AAdd(aDelSX, {"SX5", 1, xFilial("SX5") + "X517"})
	
	AAdd(aDelSX, {"G8B", 1, "*"})
	 
	AAdd(aDelSX, {"SIX", 1, "G4X4"})
	
	For nDelSX := 1 To Len(aDelSX)
	
		cAreaDel  := aDelSX[nDelSX][1]
		nOrderDel := aDelSX[nDelSX][2]
		cKeyDel   := aDelSX[nDelSX][3]
	
		DBSelectArea(cAreaDel)
		DBSetOrder(nOrderDel)
		If DBSeek(cKeyDel)
			
			nTamKey := Len(AllTrim(cKeyDel))
			
			While !EOF() .and. IIf( cKeyDel <> "*",  SubStr(&(AllTrim(IndexKey(nOrderDel))),1, nTamKey) == cKeyDel, .T.)  
			
				RecLock(cAreaDel, .F.)
				
				DBDelete()
				
				MSUnLock()
				
				DBSelectArea(cAreaDel)
				DBSkip()
				
				
			End
		
		EndIf
	
	Next
	
	DBSelectArea("SX3")
	DBSetOrder(2)
	If DBSeek("G3J_TIPO")
	
		RecLock("SX3", .F.)
		
		SX3->X3_CBOX    := ""
		SX3->X3_CBOXSPA := ""
		SX3->X3_CBOXENG := ""
		
		MSUnLock()
	
	EndIf

	DBSelectArea("SX3")
	DBSetOrder(2)
	If DBSeek("G3D_TIPO")
	
		RecLock("SX3", .F.)
		
		SX3->X3_CBOX    := ""
		SX3->X3_CBOXSPA := ""
		SX3->X3_CBOXENG := ""
		
		MSUnLock()
	
	EndIf
	
	DBSelectArea("SX7")
	DBSetOrder(1)
	
	lLock := IIf(DBSeek("G3J_MVALID001"), .F., .T.)
	
	RecLock("SX7", lLock)
		
	SX7->X7_CAMPO   := "G3J_MVALID"
	SX7->X7_SEQUENC := "001"
	SX7->X7_REGRA   := "FWFldPut('G3J_MVALID',StrZero(Val(M->G3J_MVALID),2))"
	SX7->X7_CDOMIN  := "G3J_MVALID"
	SX7->X7_TIPO    := "P"
	SX7->X7_SEEK    := "N"
	SX7->X7_ALIAS   := "   "
	SX7->X7_ORDEM   := 0
	SX7->X7_CHAVE   := ""
	SX7->X7_CONDIC  := "!EMPTY(M->G3J_MVALID)"
	SX7->X7_PROPRI  := "S"
		
	MSUnLock()

Return