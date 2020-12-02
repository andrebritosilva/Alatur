#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA290.CH"

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} F290CON

Ponto de entrada utilizado para calculcar a data de vencimento da fatura

@type 		Function
@author 	Thiago Tavares
@since 		30/01/2017
@version 	12.1.14
/*/
//+----------------------------------------------------------------------------------------
User Function F290CON_XXX() 

Local aArea     := GetArea()
Local oModel    := FwModelActive()
Local oDlg      := Nil
Local oGet      
Local oPanel1   := Nil
Local oPanel2   := Nil 
Local cCond     := IIF(!Empty(PARAMIXB[2]), PARAMIXB[2], IIF(nModulo != 89, Space(TamSX3("E4_CODIGO")[1]), oModel:GetValue('G8C_MASTER', 'G8C_CONDPG')))
Local cCadastro := OemToAnsi(STR0005) // "Aglutinação de Titulos"
Local cPrefix   := ''
Local cFatura   := ''
Local cTipo     := ''  
Local cCondicao := ''
Local nValor    := PARAMIXB[1]
Local nValTot   := 0
Local nOpca     := 0
Local dVencto   := StoD('')
Local dDatCont  := dDatabase
Local aParc     := {}
Local aRet      := {}
Local aSize     := {}
Local lPanelFin := IsPanelFin()

// Detalhe do array PARAMIXB
// 1 - nValor
// 2 - cCondicao
// 3 - cMarca
// 4 - nBasePcc
// 5 - nPisFat
// 6 - nCofFat
// 7 - nCslFat

If !Empty(cCond) .And. nModulo == 89
	DbSelectArea('SE4')
	SE4->(DbSetOrder(1))		// E4_FILIAL+E4_CODIGO
	If SE4->(DbSeek(xFilial('SE4') + cCond))
		aParc := StrToKArr(SE4->E4_COND, ',') 
		If Len(aParc) == 1 .And. AllTrim(aParc[1]) == '00'
			dVencto := oModel:GetValue('G8C_MASTER', 'G8C_VENCIM') 
		EndIf
	EndIf
	SE4->(DbCloseArea())
	
	RestArea(aArea)

	aAdd(aRet, {dVencto, nValor})
Else 
	aSize := MsAdvSize( , .F., 400)
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDlg:lMaximized := .T.
	
	oPanel1 := TPanel():New(0, 0, '', oDlg, oDlg:oFont, .T., .T., , , 45, 45, .T., .T.)
	oPanel1:Align := CONTROL_ALIGN_TOP
	
	oPanel2 := TPanel():New(0, 0, '', oDlg, oDlg:oFont, .T., .T., , , 20, 20, .T., .T.)
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	@ 003,010 TO 040,125 OF oPanel1 Pixel
	@ 003,127 TO 040,500 OF oPanel1 Pixel
	
	@ 015,015 Say STR0052 Of oPanel1 Pixel   //"Condição: "
	@ 015,045 MSGET cCond F3 "SE4" Picture "!!!" Of oPanel1 Pixel Hasbutton Valid If(nOpca <> 0, ExistCpo('SE4', cCond) .And. Fa290Cond(cCond), .T.)		
	
	DEFINE SBUTTON FROM 015,085	TYPE 1 ACTION (If(!Empty(cCond)	.And. ExistCpo('SE4', cCond) .And. Fa290Cond(cCond), ;
																nOpca := F290SelFat(oDlg, 1, @cCond, @nValor, @nValTot, @aRet, @cPrefix, @cFatura, @cTipo, dDatCont, oPanel2, oPanel1),;
																nOpca := 0)) ENABLE OF oPanel1
	
	If lPanelFin  //Chamado pelo Painel Financeiro			
		ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg, {|| nOpca := 1, oDlg:End()}, {|| oDlg:End()})																												
	Else				
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpca := 1, oDlg:End()}, {|| oDlg:End()})
	Endif				                                  

	cCondicao := IIF(nOpca == 0, "   ", cCond)
	aRet      := Condicao(nValor, cCondicao, 0)
EndIf 

Return aRet