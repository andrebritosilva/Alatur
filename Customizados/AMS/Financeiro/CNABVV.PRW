#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#Include "RPTDEF.CH"

// #########################################################################################
// Projeto: 11.90
// Modulo : Financeiro
// Fonte  : CNABVV.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 28/04/2017 | Ronaldo Bicudo	| Vencimento, Vencimento Prorrogado, Valor e Mora/Juros.
// #########################################################################################
User Function CNABVV(cOpc)

Local nPercMul := SUPERGETMV("MV_LJMULTA", .T. , 5 )   //GetMv("MV_LJMULTA") //valor percentual em multa
Local nPercMJ  := SUPERGETMV("MV_LJUROS" , .T. , 0.03 )//GetMv("MV_LJUROS") //valor percentual em juros/mora
Local nJuros   := 0
Local nMulta   := 0
Local nTotJM   := 0 //Valor total de juros/mora + multa
Local nDias    := 0 //Quantidade de dias para calculo de Juros/Mora
Local _Ret1    
Local _Ret2    := ''	
Local _Ret     := ''
Local _RetJ    := ''
    
If cOpc = '1' //Vencimento
//    If Empty(SE1->E1_XDTPROR)
    	If ALLTRIM(SE1->E1_PORTADO) = '341'
	    	_Ret1 := STRZERO(DAY(SE1->E1_VENCREA),2)+STRZERO(MONTH(SE1->E1_VENCREA),2)+SUBSTR(STRZERO(YEAR(SE1->E1_VENCREA),4),3,2)
    	Else 
			_Ret1 := STRZERO(DAY(SE1->E1_VENCREA),2)+STRZERO(MONTH(SE1->E1_VENCREA),2)+STRZERO(YEAR(SE1->E1_VENCREA),4)
		EndIF
//    Else
//	   	If ALLTRIM(SE1->E1_PORTADO) = '341'
//	    	_Ret1 := STRZERO(DAY(SE1->E1_XDTPROR),2)+STRZERO(MONTH(SE1->E1_XDTPROR),2)+SUBSTR(STRZERO(YEAR(SE1->E1_XDTPROR),4),3,2)
//    	Else 
//			_Ret1 := STRZERO(DAY(SE1->E1_XDTPROR),2)+STRZERO(MONTH(SE1->E1_XDTPROR),2)+STRZERO(YEAR(SE1->E1_XDTPROR),4)    
//        EndIf
//    EndIf
ElseIf cOpc = '2' //Valor Nominal 
	If Empty(SE1->E1_XDTPROR) .OR. ALLTRIM(SE1->E1_XCOBJM) = '2'
		If ALLTRIM(SE1->E1_PORTADO) = '341'
			_Ret2 := STRZERO(SE1->E1_SALDO*100,13) //Valor Itau
		Else                                                  
			_Ret2 := STRZERO(SE1->E1_SALDO*100,15) //Valor Outros Bancos
		EndIf
	Else
		nDias   := Abs(SE1->E1_VENCREA - SE1->E1_XDTPROR)
		//nMulta  := SE1->E1_SALDO * (nPercMul/100)
		//Incluido Ronaldo Bicudo / Totvs - 05/05/2017

			If SE1->E1_XMULTA > 0 
				nMulta := Round(SE1->E1_SALDO * (SE1->E1_XMULTA/100),2)
			ElseIf SA1->A1_XMULTA > 0 
				nMulta := Round(SE1->E1_SALDO * (SA1->A1_XMULTA/100),2)
			Else
				nMulta := Round(SE1->E1_SALDO * (nPercMul/100),2)
			EndIf
		//FIM
		nPercMj := nPercMJ * nDias 
		nJuros  := Round(SE1->E1_SALDO * nPercMJ,2)
		nTotJM  := nJuros + nMulta //Valor total de multa e mora/juros ao dia
		If ALLTRIM(SE1->E1_PORTADO) = '341'
			_Ret2 := STRZERO((SE1->E1_SALDO+nTotJM)*100,13) //Multa Itau
	    Else
			_Ret2 := STRZERO((SE1->E1_SALDO+nTotJM)*100,15) //Multa Outros Bancos 	    
	    EndIf
		//STRZERO(SEE->EE_XJURDIA*10000,15) posicão arquivo (127-141) SEGMENTO P
	EndIf
ElseIf cOPc = '3' //Mora/Juros Itau
	If ALLTRIM(SE1->E1_XCOBJM) = '2'
		If ALLTRIM(SE1->E1_PORTADO) = '341'	
			_RetJ := STRZERO(SE1->E1_SALDO*SUPERGETMV("MV_LJUROS" , .T. , 0.03 ),13) //Juros/Mora Itau
		Else
			_RetJ := STRZERO(SE1->E1_SALDO*SUPERGETMV("MV_LJUROS" , .T. , 0.03 ),15) //Juros/Mora Outros Bancos	
		Endif
	Else
		If ALLTRIM(SE1->E1_PORTADO) = '341'	
			_RetJ := REPLICATE('0',13)
		Else
			//_RetJ := REPLICATE('0',15) utilizado sem registro
			_RetJ := STRZERO(SE1->E1_SALDO*SUPERGETMV("MV_LJUROS" , .T. , 0.03 ),15) //Juros/Mora Outros Bancos	--utiliZado com registro
		Endif	
	EndIF
EndIf

If !Empty(_Ret1)                                                                                                              
	Return(_Ret1)
ElseIf !Empty(_Ret2) 
	Return(_Ret2)
ElseIf !Empty(_RetJ) 
	Return(_RetJ)
Else
	Return(_Ret)
EndIf