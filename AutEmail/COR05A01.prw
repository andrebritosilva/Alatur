#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"        
#INCLUDE "TOPCONN.CH"          
#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#Include "RwMake.ch"
#INCLUDE "SHELL.CH" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Cor05A01  �Autor  �Marcelo Franca      � Data �  13/12/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Controle de Cobranca do Titulo a Receber                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Alatur                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function COR05A01()
                                                  
	Local oControle
	Local nOpc:= 0
	
	Local aCombo 	:= { "S=Sim", "N=N�o" }
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

	Define MsDialog oCobr Title "Controle de Cobran�a" From C(130),C(270) To C(270),C(650) Pixel
		
	@ C(005),C(005) Say "Titulo : " + SE1->E1_PREFIXO + " - " + SE1->E1_NUM + " - " + SE1->E1_PARCELA
	@ C(015),C(005) Say "Cliente: " + AllTrim(SA1->A1_NOME) 
	
	@ C(025),C(005) Say "Envia Cobran�a?:" 	Size C(050),C(020) Pixel Of oCobr
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