#INCLUDE "PROTHEUS.CH"

// #########################################################################################
// Projeto: 12.6
// Modulo : Financeiro
// Fonte  : FA110JUR.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 10/05/17 | Totvs             | PE muda valor de Juros na Baixa a Receber
// #########################################################################################

User Function FA110JUR()
                          
Local _nPercMJ  := SUPERGETMV("MV_LJUROS" , .T. , 0.03 )//GetMv("MV_LJUROS") //valor percentual em juros/mora
Local _ValPer   := 0
Local _nDias    := 0

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

Return(nJuros)