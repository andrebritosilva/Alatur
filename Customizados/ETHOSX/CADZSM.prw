#include "protheus.ch"
#include "RWMAKE.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CADSZM    �Autor  �Marcelo - Ethosx    � Data �  02/10/19   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
      
User Function CADZSM()

	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������
	
	Private nTenta	:=	SuperGetMV("AL_NRTENTA"	, 		, 3) 
	Private cString := "SZM"
	Private cUSADM	:= SuperGetMV("AL_ADMSZM"	, 		, "000001")
	Private cCadastro := "Controle Envio de E-Mail"
	
	Private aCores := {	{"SZM->ZM_ENVIADO"				, 'BR_VERDE'},;
						{"!SZM->ZM_ENVIADO .AND. SZM->ZM_NRTENTA > nTenta " , 'BR_VERMELHO'},;
						{"!SZM->ZM_ENVIADO .AND. SZM->ZM_NRTENTA <= nTenta " , 'BR_AMARELO'}}
						
	If __cUserId $ cUSADM
	
		aRotina := 	{ 	{"Pesquisar"   				,"AxPesqui"     						,0,1},;
						{"Visualizar"  				,"AxVisual"     						,0,2},;
						{"Incluir"     				,"U_SZMINC()"     						,0,3},;
						{"Alterar"     				,"U_SZMALT()"							,0,4},;
						{"Legenda"     				,"U_SZMleg()" 	 						,0,6}}    				

	Else
	
		aRotina := 	{ 	{"Pesquisar"   				,"AxPesqui"     						,0,1},;
						{"Visualizar"  				,"AxVisual"     						,0,2},;
						{"Legenda"     				,"U_SZMleg()" 	 						,0,6}}    			
	
	
	EndIf
		                           
	DbSelectArea("SZM") 
	DbSetOrder(1)

	mBrowse(6,1,22,75,"SZM",,,,,,aCores,,,,,.F.,,,)

Return

User Function SZMALT()

	Local nOpca := 0
	Local aParam := {}
	Local cZM_TO:= SZM->ZM_TO
	
	Private aButtons := {}
	
	If !SZM->ZM_ENVIADO

		AxAltera("SZM",SZM->(Recno()),4,,,)

		If AllTrim(cZM_TO) <> AllTrim(SZM->ZM_TO)
		
			RecLock("SZM",.F.)
			
			SZM->ZM_NRTENTA := 0
			
			SZM->(MsUnlock())
		
		EndIf
	
	Else
	
		MsgInfo("E-mail j� enviado. N�o � poss�vel alterar registro","Aten��o!!!")
	
	EndIf
		
Return()

User Function SZMleg()

	aLegenda := {	{"BR_VERDE","E-Mail Enviado"},;
					{"BR_AMARELO","E-Mail em Processo de Envio"},;// ENVIAR PROPOSTA
					{"BR_VERMELHO","E-Mail N�o Enviado"}}

	BrwLegenda("Situa��o do Controle de E-Mail","Legenda",aLegenda)
	
return

User Function SZMINC()

	MsgInfo("Op��o INCLUIR n�o est� dispon�vel.","Aten��o!!!")

Return