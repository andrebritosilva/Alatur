#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA040MENU

Ponto de entrada utilizado para inserir novas opcoes no array aRotina

@type 		Function
@author 	Thiago Tavares
@since 		09/11/2016
@version 	12.1.13
/*/
//+----------------------------------------------------------------------------------------
User Function TA040MENU()

Local aRotina := PARAMIXB[1]

ADD OPTION aRotina TITLE 'Rel. Receita' ACTION 'U_ALAR001' OPERATION 6 ACCESS 0 

Return aRotina