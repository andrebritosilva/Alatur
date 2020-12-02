#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"        
#INCLUDE "TOPCONN.CH"          
#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#Include "RwMake.ch"
#INCLUDE "SHELL.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Cor05A01  ºAutor  ³Marcelo Franca      º Data ³  13/12/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle de Cobranca do Titulo a Receber                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Alatur                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function COR05A01()
                                                  
	Local oControle
	Local nOpc:= 0
	
	Local aCombo 	:= { "S=Sim", "N=Não" }
	Local cControle	:= ""
	Local aAuxCombo	:= { "S", "N" }
	Local nAux		:= 0
	
	Private oCobr
	
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA) )

	cControle := SE1->E1_XCOBRA
	
	nAux		:= aScan( aAuxCombo, cControle )
		
	If nAux > 0
		cControle := SubStr(aCombo[nAux],1,1)
	Endif

	Define MsDialog oCobr Title "Controle de Cobrança" From C(130),C(270) To C(270),C(650) Pixel
		
	@ C(005),C(005) Say "Titulo : " + SE1->E1_PREFIXO + " - " + SE1->E1_NUM + " - " + SE1->E1_PARCELA
	@ C(015),C(005) Say "Cliente: " + AllTrim(SA1->A1_NOME) 
	
	@ C(025),C(005) Say "Envia Cobrança?:" 	Size C(050),C(020) Pixel Of oCobr
	@ C(025),C(050) COMBOBOX oControle 	Var cControle ITEMS aCombo Size C(125),C(040) Pixel Of oCobr

	@ C(045),C(060) Button "Ok"	 Size C(030),C(010) Pixel Action (nOpc:=1,oCobr:End() )
	@ C(045),C(105) Button "Cancelar" Size C(030),C(010) Pixel Action (nOpc:=2,oCobr:End() )
	
	Activate MsDialog oCobr Centered   
	
	If nOpc == 1
		SE1->(Reclock("SE1",.F.))
		SE1->E1_XCOBRA	:= cControle
		SE1->(MsUnLock())
	EndIF
	
Return()