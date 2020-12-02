#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc}CTBXMNL
Painel de conciliação Contabil - ALATUR 
@author André Luiz Brito Silva
@since  03/05/2019
@version 12
/*/
//-------------------------------------------------------------------

User Function CTBXMNL()

Local oDlg
Local oRadio
Local nRadio
Local nOpca  := 1

While nOpca == 1

	DEFINE MSDIALOG oDlg FROM  94,1 TO 300,293 TITLE "Painel de Conciliação Contábil - ALATUR" PIXEL 

		@ 05,17 Say "Painel de Conciliação Contábil Manual - ALATUR" SIZE 150,7 OF oDlg PIXEL  

		@ 17,07 TO 82, 140 OF oDlg  PIXEL

		@ 25,10 Radio 	oRadio VAR nRadio;
						ITEMS 	"Com Filtro",;
								"Com Totalizador"; 		//"Saldos contabeis"
						SIZE 110,10 OF oDlg PIXEL

	DEFINE SBUTTON FROM 85,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
	DEFINE SBUTTON FROM 85,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso
                                                               //	para saida com ESC

	If nOpca == 1
		If nRadio == 1
			U_CTBXMAN()					// CTBXMAN - FWMarkBrowse
		ElseIf nRadio == 2
			U_CTBXCON()					// CTBXCON - MSSelect
		EndIf
	EndIf

EndDo

Return