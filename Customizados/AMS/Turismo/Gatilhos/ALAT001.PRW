#INCLUDE "Protheus.ch"


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ALAT001

Fonte utilizado para gatilhar informações de acordo com o modelo e campo informado

@sample 	ALAT001(cModelo, cCampo)
@param 		cModelo - String - nome do submodelo 
			cCampo - String - nome do campo 
@return	uValor - Variável - informação que será gatilhada
@author    Thiago Tavares
@since		02/12/2016
@version	P12.1.14
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function ALAT001(cModelo, cCampo)

Local aArea    := GetArea()
Local oModel   := FwModelActive()
Local uValor   := oModel:GetValue(cModelo, cCampo)
Local cFornec  := ''
Local cLoja    := '' 
Local cRptForn := SuperGetMv('MV_RPTFORN', .T., '')
Local cRptLoja := SuperGetMv('MV_RPTLOJA', .T., '')

If cCampo == 'G3R_FORREP' .Or. cCampo == 'G3R_LOJREP' 
	cFornec := oModel:GetValue('G3R_ITENS', 'G3R_FORNEC')
	cLoja   := oModel:GetValue('G3R_ITENS', 'G3R_LOJA'  )
	
	If Posicione('G4S', 1, xFilial('G4S') + cFornec + cLoja, 'G4S_BSP') == '1'
		oModel:GetModel('G3R_ITENS'):SetValue('G3R_FORREP', cRptForn)
		oModel:GetModel('G3R_ITENS'):SetValue('G3R_LOJREP', cRptLoja)
	EndIf
EndIf

If ValType(uValor) == 'N'
	uValor := Str(uValor)
EndIf

RestArea(aArea)

Return uValor