#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TURNAT

Ponto de Entrada para retorno da Natureza 

@type 		Function
@author 	Alatur
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function TURNAT(cFilPesq, cTipo, cClass, cSegNeg, cCodPrd, cCliFor, cCodigo, cLoja )

Local aArea		:= GetArea()
Local cTpProd 	:= ""
Local cNatureza	:= ""

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial('SB1',cFilPesq) + cCodPrd ))
	SBM->(dbSetOrder(1))	
	If SBM->(dbSeek(xFilial('SBM',cFilPesq) + SB1->B1_GRUPO ))
		If SBM->BM_TPSEGP == '1'
			cTpProd := '1' //Aéreo 
		Else
			cTpProd := '2' //Terrestre
		EndIf
	EndIf
EndIf


If cTipo == '1' //Venda

	If cCliFor == '1' //Venda Cliente
		
		If cTpProd == '1' //Venda Cliente Aéreo
		
			cNatureza := "100100"
	
		ElseIf cTpProd == '2' //Venda Cliente Terrestre
		
			cNatureza := "100200"
		
		EndIf
	
	ElseIf cCliFor == '2' //Venda Fornecedor
		
		If cTpProd == '1' //Venda Fornecedor Aéreo
		
			cNatureza := "200100"
	
		ElseIf cTpProd == '2' //Venda Fornecedor Terrestre
		
			cNatureza := "200110"
		
		EndIf
	
	EndIf

ElseIf cTipo == '2' //Reembolso

	If cCliFor == '1' //Reembolso Cliente
	
		If cTpProd == '1' //Reembolso Cliente Aéreo
		
			cNatureza := "100100"
	
		ElseIf cTpProd == '2' //Reembolso Cliente Terrestre
		
			cNatureza := "100200"
		
		EndIf
	
	ElseIf cCliFor == '2' //Reembolso Fornecedor
	
		If cTpProd == '1' //Reembolso Fornecedor Aéreo
		
			cNatureza := "200100"
	
		ElseIf cTpProd == '2' //Reembolso Fornecedor Terrestre
		
			cNatureza := "200110"
		
		EndIf
	
	EndIf

ElseIf cTipo == '5' //Breakage

	If cCliFor == '1' //Breakage Cliente
	
		If cTpProd == '1' //Breakage Cliente Aéreo
		
			cNatureza := "100100"
	
		ElseIf cTpProd == '2' //Breakage Cliente Terrestre
		
			cNatureza := "100200"
		
		EndIf
	
	EndIf

ElseIf cTipo $ '3|4' //Receita e Abat. Receita

	//Função T35PesqPFF retorna Natureza dos Parametros Fiscais e Financeiros

	cNatureza := T35PesqPFF(cFilPesq, cClass, cSegNeg, cCodPrd, cCliFor, cCodigo, cLoja)[1]

EndIf 

RestArea(aArea)

Return cNatureza

