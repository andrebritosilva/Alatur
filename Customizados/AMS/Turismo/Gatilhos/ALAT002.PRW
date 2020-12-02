#INCLUDE "Protheus.ch"


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ALAT002

Fonte utilizado para gatilhar informações de acordo com o modelo e campo informado

Funcao utilizada no gatilho do campo G3R_LOJA

@sample 	ALAT001()
@author     TOTVS..
@since		12/2016
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function ALAT002()

Local cFornec  := FwFldGet("G3R_FORNEC")
Local cLoja    := FwFldGet("G3R_LOJA")
Local cRet     := ''
Local cRptForn := CriaVar("G3R_FORREP")
Local cRptLoja := CriaVar("G3R_LOJREP")

cRptForn := SuperGetMv('MV_RPTFORN', .T., '')
cRptLoja := SuperGetMv('MV_RPTLOJA', .T., '')

If Posicione('G4S', 1, xFilial('G4S') + cFornec + cLoja, 'G4S_BSP') == '1'
	FwFldPut("G3R_FORREP",cRptForn)
	FwFldPut("G3R_LOJREP",cRptLoja)                                           
EndIf

Return(cRet)