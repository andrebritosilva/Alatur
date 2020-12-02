#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function TURA065()

Local aParam   := PARAMIXB
Local oModel   := Nil
Local cIdPonto := ''
Local cIdModel := ''
Local cIdDig   := IIF(G9I->(FieldPos('G9I_XIDDIG')) > 0, 'G9I_XIDDIG', 'G9I_IDDIG')
Local lId      := G9I->(FieldPos('G9I_XIDDIG')) > 0 .Or. G9I->(FieldPos('G9I_IDDIG')) > 0
 
If aParam <> NIL
      
	oModel   := aParam[1]
	cIdPonto := aParam[2]
	cIdModel := aParam[3]
      
	If cIdPonto == 'MODELPRE' //.And. cIdModel == 'G9I_MASTER'
		If lId 
			oModel:GetModel('G9I_MASTER'):GetStruct():SetProperty(cIdDig, MVC_VIEW_CANCHANGE, .T.) 
		EndIf
	EndIf
EndIf 

Return .T.

User Function TA065FLDS()

Local aParam   := PARAMIXB
Local oModel   := aParam[1]
Local cIdDig   := IIF(G9I->(FieldPos('G9I_XIDDIG')) > 0, 'G9I_XIDDIG', 'G9I_IDDIG')
Local lId      := G9I->(FieldPos('G9I_XIDDIG')) > 0 .Or. G9I->(FieldPos('G9I_IDDIG')) > 0
 
If aParam <> NIL
	If oModel:GetId() == 'G9I_MASTER' .And. lId 
		oModel:GetStruct():SetProperty(cIdDig, MVC_VIEW_CANCHANGE, .T.) 
	EndIf
EndIf 

Return .T.