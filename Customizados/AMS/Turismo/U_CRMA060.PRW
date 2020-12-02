#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

USER FUNCTION CRMA060()

Local aParam := PARAMIXB
Local xRet := .T.

If aParam <> NIL
	oObj	 := aParam[1]
	cIdPonto := aParam[2]
	cIdModel := aParam[3]

	If cIdPonto == 'MODELVLDACTIVE'
		oObj:GetModel("AC8CONTDET"):SetMaxLine(99999999)
	EndIf
EndIf

RETURN xRet