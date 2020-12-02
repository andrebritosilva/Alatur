#INCLUDE "PROTHEUS.CH"

// #########################################################################################
// Projeto: 12.6
// Modulo : Financeiro
// Fonte  : FA110MUL.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 05/05/17 | Totvs             | PE muda valor de Multa na Baixa a Receber
// #########################################################################################

User Function FA110MUL()

Local _nPercMul := SUPERGETMV("MV_LJMULTA", .T. , 5 )   //GetMv("MV_LJMULTA") //valor percentual em multa

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

Return (nMulta)