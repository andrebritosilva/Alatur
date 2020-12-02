#INCLUDE "PROTHEUS.CH"

// #########################################################################################
// Projeto: 12.6
// Modulo : Financeiro
// Fonte  : FA070POS.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 05/05/17 | Totvs             | PE muda valor de Multa na Baixa a Receber
// #########################################################################################

User Function FA070POS()

Local _nPercMul := SUPERGETMV("MV_LJMULTA", .T. , 5 )   //GetMv("MV_LJMULTA") //valor percentual em multa
Local _nPercMJ  := SUPERGETMV("MV_LJUROS" , .T. , 0.03 )//GetMv("MV_LJUROS") //valor percentual em juros/mora
Local _ValPer   := 0
Local _nDias    := 0

//Multa Especifico Alatur
If Alltrim(SE1->E1_XCOBJM) <> '2' //2=NÃO COBRA Multa
	If !Empty(SE1->E1_XDTPROR)
		If dDataBase > SE1->E1_XDTPROR
			If SE1->E1_XMULTA > 0 //Campo especifico para calculo de multa na baixa do titulos a receber
				nMulta := ROUND(SE1->E1_SALDO * (SE1->E1_XMULTA /100),2)
			ElseIF SA1->A1_XMULTA > 0 //Campo especifico para calculo de multa na baixa do titulos a receber
				nMulta := ROUND(SE1->E1_SALDO * (SA1->A1_XMULTA /100),2)
			Else
				nMulta := ROUND(SE1->E1_SALDO * (_nPercMul /100),2)
			EndIf
		EndIf
	ElseIf dDataBase > SE1->E1_VENCREA
		If SE1->E1_XMULTA > 0 //Campo especifico para calculo de multa na baixa do titulos a receber
			nMulta := ROUND(SE1->E1_SALDO * (SE1->E1_XMULTA /100),2)
		ElseIF SA1->A1_XMULTA > 0 //Campo especifico para calculo de multa na baixa do titulos a receber
			nMulta := ROUND(SE1->E1_SALDO * (SA1->A1_XMULTA /100),2)
		Else
			nMulta := ROUND(SE1->E1_SALDO * (_nPercMul /100),2)
		EndIf
	Else
		nMulta := 0
	EndIf
Else
	nMulta := 0
EndIf

//Juros/Mora Especifico Alatur
If Alltrim(SE1->E1_XCOBJM) <> '2' //2=NÃO COBRA JUROS/MORA
	If !Empty(SE1->E1_XDTPROR)
		If dDataBase > SE1->E1_XDTPROR
			//If dDatabase = SE1->E1_VENCREA 
				_nDias  := Abs(SE1->E1_VENCREA - SE1->E1_XDTPROR)
			//Else
			//	_nDias  := Abs(dDatabase - SE1->E1_XDTPROR)
			//EndIf
			If _nDias > 0
				_ValPer := (_nPercMJ/100) * _nDias
				nJuros := Round(SE1->E1_SALDO * _ValPer,2)
			EndIf
		EndIf
	ElseIf dDataBase > SE1->E1_VENCREA
		nJuros := nJuros
	Else
		nJuros := 0
	EndIf
Else
	nJuros := 0
EndIf

Return Nil