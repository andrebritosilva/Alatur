#Include 'Protheus.ch'
#Include 'RwMake.ch'

User Function PCOA5301()
	
Local aArea  := GetArea()

Public xBloq   := {}
Public cTexto  := Paramixb[1]
Public aRec    := Paramixb[2]
   
xBloq 	:= aClone(aRec)
     
RestArea(aArea)
    
Return cTexto