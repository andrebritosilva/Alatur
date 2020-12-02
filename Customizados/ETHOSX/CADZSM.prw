#include "protheus.ch"
#include "RWMAKE.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CADSZM    ºAutor  ³Marcelo - Ethosx    º Data ³  02/10/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
      
User Function CADZSM()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
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
	
		MsgInfo("E-mail já enviado. Não é possível alterar registro","Atenção!!!")
	
	EndIf
		
Return()

User Function SZMleg()

	aLegenda := {	{"BR_VERDE","E-Mail Enviado"},;
					{"BR_AMARELO","E-Mail em Processo de Envio"},;// ENVIAR PROPOSTA
					{"BR_VERMELHO","E-Mail Não Enviado"}}

	BrwLegenda("Situação do Controle de E-Mail","Legenda",aLegenda)
	
return

User Function SZMINC()

	MsgInfo("Opção INCLUIR não está disponível.","Atenção!!!")

Return