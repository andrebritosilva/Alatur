#INCLUDE "PROTHEUS.CH"

User function CTBCLRFLG()

local cCampo := ""

If	CV3->CV3_LP == "T30" .OR.;
	CV3->CV3_LP == "T31" .OR.;
	CV3->CV3_LP == "T32" .OR.;
	CV3->CV3_LP == "T33" .OR.;
	CV3->CV3_LP == "T34" .OR.;
	CV3->CV3_LP == "T35" .OR.;
	CV3->CV3_LP == "T36" .OR.;
	CV3->CV3_LP == "T37"
	cCampo := "G4C_LACONC"
EndIf

Return cCampo