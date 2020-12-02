#include "protheus.ch"
#include "fivewin.ch"
#INCLUDE "AP5MAIL.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEnvMail   บAutor  ณKurts               บ Data ณ  28/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPrograma executado via JOB responsavel por enviar os e-mailsบฑฑ
ฑฑบ          ณcontidos na tabela SZM.                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function J_EnvMai()
              			
	Local _cQuery		:= ""
	Local lOk			:= .F.
	Local aTabelas		:= {"SZM"}
	Local aExcTent		:= {}
	Local nContSuc		:=	0
	Local nContErro		:=	0
	Local nContDesp		:=	0
	Local _lConnect		:= .T.
	Local nTenta		:= 0
	Local nRenvio		:= 0
	Local cPath			:= "\CAP_TMP\XML\"
	
	Local oServer 		:= TMailManager():New()
	Local oMessage 		:= TMailMessage():New()

	Private cErrorMsg	:= ""
	Private cChave		:= ""

	ConOut("J_EnvMai (U_J_EnvMai): "+Dtos(Date())+" - "+Time()+" - Iniciando Job Envio de E-mails - Obtendo e-mails para enviar")
	
	RPCClearEnv()//LIMPA O AMBIENTE
	RPCSetType(3)//DEFINE O AMBIENTE NรO CONSOME LICENวA
	RPCSetEnv('01','01SP0001',/*cUser*/,/*pass*/,'FIN',,/*aTabelas*/)//PREPARA O AMBIENTE
	
	nTenta	:=	SuperGetMV("AL_NRTENTA"	, 		, 3) 
	nRenvio	:=	SuperGetMV("AL_NRENVIO"	, 		, 999) 
	
	//MONTA QUERY DE E-MAIL QUE ESTรO ESPERANDO PARA SER ENVIADOS
	_cQuery	:=	"	SELECT TOP " + AllTrim(Str(nRenvio)) + " ZM_FILIAL, ZM_SERVER, ZM_ACCOUNT, ZM_PASS, ZM_FROM, ZM_TO, ZM_CC, ZM_BCC, " 				+ CRLF //Transformar o 100 em parametrs
	_cQuery	+=	"	ZM_SUBJECT, ZM_BODY, ZM_ATTACH, ZM_AUTO, ZM_EMISSAO, ZM_CHAVE, R_E_C_N_O_ "											+ CRLF
	_cQuery	+=	"	FROM " + RETSQLNAME("SZM")																		 + CRLF
	_cQuery	+=	"	WHERE " 																						 + CRLF
	_cQuery	+=	"	ZM_ENVIADO = 'F' " 																				 + CRLF													
	_cQuery	+=	"	AND (ZM_NOTIFIC = 'T' OR (ZM_NOTIFIC = 'F' AND ZM_NRTENTA <= " + AllTrim(Str(nTenta)) + "  )) "	 + CRLF
	_cQuery	+=	"	AND D_E_L_E_T_ = '' " 																			 + CRLF
	_cQuery	+=	"	ORDER BY ZM_NRTENTA " 																			 + CRLF
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"MAILTO",.F.,.T.)
	
	TCSetField("MAILTO","ZM_EMISSAO","D",8,0)	
	
	MemoWrite("J_EnvMai.SQL",_cQuery)
	
	If MAILTO->(!Eof())
		
		DbSelectArea("MAILTO")

		While MAILTO->(!Eof())
			
			DbSelectArea("SZM")
			SZM->(DbGoTo(MAILTO->R_E_C_N_O_))
			
			IF LEN(ALLTRIM(SZM->ZM_BODY)) == 6 
				_cBody	:=	MSMM(SZM->ZM_BODY,,,, 3)
			ELSE
				_cBody 	:= ALLTRIM(SZM->ZM_BODY)
			EndIF
			
			DbSelectArea("MAILTO")
					
			If !Empty(MAILTO->ZM_TO)
				
				//FAZ A CONEXรO APENAS UMA VEZ POR ENVIO
				If _lConnect
					Conout("J_EnvMai (U_J_EnvMai): " + Dtos(Date()) +" - " + Time() + " - Conectando ao SMTP")
						
					oServer:SetUseTLS( .T. )
					//oServer:Init('', "smtp.office365.com" , Alltrim(MAILTO->ZM_ACCOUNT) , Alltrim(MAILTO->ZM_PASS) , 0 , 587)
					oServer:Init('', SubStr(AllTrim(MAILTO->ZM_SERVER),1,Len(AllTrim(MAILTO->ZM_SERVER))-4) , Alltrim(MAILTO->ZM_ACCOUNT) , Alltrim(MAILTO->ZM_PASS) , 0 , Val(SubStr(AllTrim(MAILTO->ZM_SERVER),Len(AllTrim(MAILTO->ZM_SERVER))-3))     )
					
					oServer:SetSmtpTimeOut( 120 )
					
					nErro := oServer:SmtpConnect()
				
					If nErro <> 0
						conout( "J_EnvMai: " + Dtos(Date()) + " - " + Time() + " - ERROR:" + oServer:GetErrorString( nErro ) )
						oServer:SMTPDisconnect()
						RpcClearEnv() 
						Return .F.
					Endif
				
					nErro := oServer:SmtpAuth( Alltrim(MAILTO->ZM_ACCOUNT) , Alltrim(MAILTO->ZM_PASS))
				
					If nErro <> 0
						conout( "J_EnvMai: " + Dtos(Date()) + " - " + Time() + " - ERROR:" + oServer:GetErrorString( nErro ) )
						oServer:SMTPDisconnect()
						RpcClearEnv() 
						Return .F.
					Endif
					
					//Conecta apenas no primeiro envio
					_lConnect	:=	.F.
				EndIf

				//================================================================
				// Verifica se e um e-mail valido. Caso nao seja, nem tenta enviar
				//================================================================

				If MailIs(Alltrim(MAILTO->ZM_CC), .T., .T.) .And. MailIs(Alltrim(MAILTO->ZM_TO), .T., .T.) 		

					oMessage:Clear()
					oMessage:cFrom                  := Alltrim(MAILTO->ZM_FROM)
					oMessage:cTo                    := Alltrim(MAILTO->ZM_TO)
					oMessage:cCc                    := Alltrim(MAILTO->ZM_CC)
					oMessage:cSubject               := Alltrim(MAILTO->ZM_SUBJECT)
					oMessage:cBody                  := _cBody
  
					//ADICIONA UM ATTACH
					If !Empty((MAILTO->ZM_ATTACH))  
						//VERIFICA SE O ARQUIVO EXISTE NA ORIGEM
						If File(MAILTO->ZM_ATTACH)
							If oMessage:AttachFile(Alltrim(MAILTO->ZM_ATTACH)) < 0
								Conout( "J_EnvMai: " + Dtos(Date()) + " - " + Time() + " - Erro ao ANEXAR o arquivo referente ao  R_E_C_N_O_  " + cValToChar(MAILTO->R_E_C_N_O_) + ".")
								RpcClearEnv() 
								Return .F.
							Else
								//ADICIONA UMA TAG INFORMANDO QUE ษ UM ATTACH E O NOME DO ARQUIVO
								oMessage:AddAtthTag( 'Content-Disposition: attachment; filename="' + Alltrim(StrTran(MAILTO->ZM_ATTACH,cPath,"")) + '"')
							EndIf
						EndIF
					EndIf 
					
					nErro := oMessage:Send( oServer )
					  
					//TRATA O ENVIO DO EMAIL, CASO SEJA BEM SUCEDIDO FAZEMOS AS DEVIDAS TRATATIVAS
					If nErro <> 0
					   
					   ConOut("J_EnvMai: " + Dtos(Date()) + " - " + Time() + " - Tentativa de enviar registro SEM SUCESSO com R_E_C_N_O_ - " + cValToChar(MAILTO->R_E_C_N_O_))
					   conout("J_EnvMai: " + Dtos(Date()) + " - " + Time() + " - Erro no envio: " + oServer:GetErrorString( nErro ) )
					   DbSelectArea("SZM")

					   RecLock("SZM",.F.)
					   SZM->ZM_NRTENTA	:= (SZM->ZM_NRTENTA + 1)
					   SZM->(MsUnlock())
					   
					   nContErro++ //Soma contador de e-mails nใo enviados
					   
					   /*
					   	Desconeta servidor e manda conectar antes do proximo envio.
					   
					   	Em Marco/2018, percebemos que quando o envio de um e-mail da problema, os demais nao sao enviados
					   	possivelmente porque o servidor e desconectado. Reconectando o servidor resolve o problema
					   */
					   
					   ConOut("J_EnvMai: " + Dtos(Date()) + " - " + Time() + " - Mandando reconectar servidor para corrigir problema apos erro no envio de e-mail")					   					   
					   oServer:SMTPDisconnect()
					   _lConnect	:=	.T.
					Else
					   
					   nContSuc++
					   
					   ConOut("J_EnvMai: " + Dtos(Date()) + " - " + Time() + " - " + cValToChar(MAILTO->R_E_C_N_O_) + " - Ultimo R_E_C_N_O_ enviado")
					   
					   DbSelectArea("SZM")
					   RecLock("SZM",.F.)
					   SZM->ZM_ENVIADO	:=	.T.
					   SZM->ZM_DTENV := DATE()
					   SZM->ZM_HRENV := TIME()
					   SZM->(MsUnlock())
					   
					   lOk := .T.
					   
					EndIf	
				Else
					nContDesp++
					
					IncNumT(MAILTO->R_E_C_N_O_) //Incrementa o ZM_NRTENTA para que o registro deixe de ser enviado apos x tentativas
					Conout("J_EnvMai (U_J_EnvMai): " + Dtos(Date()) + " - " + Time() + " - A T E N ว ร O -  E-mail nใo pode ser enviado " +  Alltrim(MAILTO->ZM_TO))
					
				Endif
			EndIf
			
			If SZM->ZM_NRTENTA > nTenta .AND. SZM->ZM_NOTIFIC .AND. !SZM->ZM_ENVIADO .AND. SZM->ZM_EMISSAO == dDatabase
				//AADD(aExcTent,{Alltrim(MAILTO->ZM_FROM), Alltrim(MAILTO->ZM_TO), cErrorMsg, MAILTO->R_E_C_N_O_, MAILTO->ZM_FILIAL})
				AADD(aExcTent,{ SubStr(Dtos(MAILTO->ZM_EMISSAO),7,2) + "/" + SubStr(Dtos(MAILTO->ZM_EMISSAO),5,2) + "/" + SubStr(Dtos(MAILTO->ZM_EMISSAO),3,2) , Alltrim(MAILTO->ZM_TO), MAILTO->ZM_FILIAL,cErrorMsg, AllTrim(MAILTO->ZM_CHAVE)})
				cChave:= AllTrim(MAILTO->ZM_CHAVE)
			EndIf
			
			If lOk .and. !Empty(MAILTO->ZM_ATTACH)	// se enviou e-mail, matamos o anexo - Magal em 05/11/2013
				If File(AllTrim(MAILTO->ZM_ATTACH))
					fErase(AllTrim(MAILTO->ZM_ATTACH))
				EndIf	
			Endif
			
			lOk 		:= .F.
			cErrorMsg 	:= ""
			
			DbSelectArea("MAILTO")
			MAILTO->(DbSkip())
			
			//Evitando o limite de envio maximo de emails por minuto imposto pelo Office365
			Sleep(3000)
		EndDo
	Endif
	
	MAILTO->(DbCloseArea())
	DelAntig()
	
	If !Empty(aExcTent)

		MailTI(aExcTent)
		
		If MailIs(Alltrim(SZM->ZM_CC), .T., .T.) .And. MailIs(Alltrim(SZM->ZM_TO), .T., .T.) 		
		
			oMessage:Clear()
			oMessage:cFrom                  := Alltrim(SZM->ZM_FROM)
			oMessage:cTo                    := Alltrim(SZM->ZM_TO)
			oMessage:cCc                    := Alltrim(SZM->ZM_CC)
			oMessage:cSubject               := Alltrim(SZM->ZM_SUBJECT)
			oMessage:cBody                  := SZM->ZM_BODY
			  
			nErro := oMessage:Send( oServer )
								  
			//TRATA O ENVIO DO EMAIL, CASO SEJA BEM SUCEDIDO FAZEMOS AS DEVIDAS TRATATIVAS
			If nErro <> 0
								   
				ConOut("J_EnvMai: " + Dtos(Date()) + " - " + Time() + " - Tentativa de enviar registro SEM SUCESSO - E-mail de lista de erri ")
				conout("J_EnvMai: " + Dtos(Date()) + " - " + Time() + " - Erro no envio: " + oServer:GetErrorString( nErro ) )
			   	DbSelectArea("SZM")
			
			   	RecLock("SZM",.F.)
			   	SZM->ZM_NRTENTA	:= (SZM->ZM_NRTENTA + 1)
			   	SZM->(MsUnlock())
								   
				nContErro++ //Soma contador de e-mails nใo enviados
								   
				/*
				Desconeta servidor e manda conectar antes do proximo envio.
						   
				Em Marco/2018, percebemos que quando o envio de um e-mail da problema, os demais nao sao enviados
				possivelmente porque o servidor e desconectado. Reconectando o servidor resolve o problema
				*/
								   
				ConOut("J_EnvMai: " + Dtos(Date()) + " - " + Time() + " - Mandando reconectar servidor para corrigir problema apos erro no envio de e-mail")					   					   
				oServer:SMTPDisconnect()
				_lConnect	:=	.T.
				
			Else
							   
				nContSuc++
								   
				ConOut("J_EnvMai: " + Dtos(Date()) + " - " + Time() + " - E-Mail com lista de erro enviado")
								   
				DbSelectArea("SZM")
				RecLock("SZM",.F.)
				SZM->ZM_ENVIADO	:=	.T.
				SZM->ZM_DTENV := DATE()
				SZM->ZM_HRENV := TIME()
				SZM->(MsUnlock())
								   
				lOk := .T.
								   
			EndIf	
		Else
			
			nContDesp++
							
		   	RecLock("SZM",.F.)
		   	SZM->ZM_NRTENTA	:= (SZM->ZM_NRTENTA + 1)
		   	SZM->(MsUnlock())
			Conout("J_EnvMai (U_J_EnvMai): " + Dtos(Date()) + " - " + Time() + " - A T E N ว ร O -  E-mail nใo pode ser enviado " +  Alltrim(SZM->ZM_TO))
							
		Endif
		

	EndIf
	
	Conout("J_EnvMai (U_J_EnvMai): " + Dtos(Date()) + " - " + Time() + " - DESCONECTANDO DO SMTP")
	oServer:SMTPDisconnect()
	
	ConOut("J_EnvMai (U_J_EnvMai): " + Dtos(Date()) + " - " + Time() + " - FINALIZANDO JOB DE ENVIO DE E-MAIL.")
	ConOut("J_EnvMai (U_J_EnvMai): " + Dtos(Date()) + " - " + Time() + " - ENVIADOS COM SUCESSO: " + cValToChar(nContSuc) + " - NAO ENVIADOS: " + cValToChar(nContErro) + " - DESPREZADOS POR ENDERECO INVALIDO: " + cValToChar(nContDesp))

	RpcClearEnv() 
	
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDelAntig  บAutor  ณKurts               บ Data ณ  28/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao responsavel por deletar os e-mails gerados a mais    บฑฑ
ฑฑบ          ณdias do que o contido no parametro ET_ARMEMAI, visando nao  บฑฑ
ฑฑบ          ณacumular registros desnecessแrios na tabela.                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function DelAntig()

	Local _nDiasArm	:=	SuperGetMV("AL_ARMEMAI", NIL, 30)
	Local _cDtLim	:=	Dtos(dDataBase - _nDiasArm)
	Local _cQuery	:=	""
	
	_cQuery	:=	"	DELETE " + RETSQLNAME("SZM")
	_cQuery	+=	"	WHERE "
	_cQuery	+=	"		ZM_EMISSAO <= '" + _cDtLim + "'"
	
	TCSQLEXEC(_cQuery)

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณJ_ENVMAI  บAutor  ณMicrosiga           บ Data ณ  09/27/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Incrementa o ZM_NRTENTA de acordo com o R_E_C_N_O_        บฑฑ
ฑฑบ          ณ  informado                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function IncNumT(_nRecno)

	Local _aArea		:= GetArea()
	Local _aAreaSZM		:= SZM->(GetArea())

	Default _nRecno	:=	0

	If(_nRecno > 0)

		DbSelectArea("SZM")
		SZM->(DbGoTo(_nRecno))
		
		If(SZM->(Recno()) == _nRecno)
			
			RecLock("SZM",.F.)
			SZM->ZM_NRTENTA	:= (SZM->ZM_NRTENTA + 1)
			MsUnlock()
			
		Endif
		
	Endif
	
	RestArea(_aAreaSZM)
	RestArea(_aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMailTI    บAutor  ณMarcelo - Ethosx    บ Data ณ  27/09/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao responsavel por enviar e-mail informando os que estaoบฑฑ
ฑฑบ          ณbloqueados na fila de envio do SZM                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MailTI(aExcTent)

	Local cFiles	:= ""
	Local cServer	:= SuperGetMv("MV_RELSERV"	, NIL	, "smtp.office365.com:587")
	Local cAccount	:= SuperGetMv("MV_RELACNT"	, NIL	, "erpp@alatur.com")
	Local cPass		:= SuperGetMv("MV_RELPSW" 	, NIL	, "456!@vbnm")
	Local cFrom		:= SuperGetMv("MV_RELFROM"	, NIL	, "erpp@alatur.com")
	Local cMailTo	:= SuperGetMv("AL_MAILTI"	, NIL	, "")
	Local cMailCc	:= ""
	Local cMailBcc	:= ""
	Local cSubject	:= "Composi็ใo de Pagamentos - E-mail(s) nใo enviado(s)"
	Local cBody		:= ""			//Texto da Mensagem
	Local lText		:= .T.
	Local cErroMsg	:= ""
	Local _i		:= 0
	Local cFilE2	:= ""
	Local cCorpo	:= ""
	
	cBody    := '<html>'
	cBody    += '<head>'
	cBody    += '  <meta content="text/html; charset=ISO-8859-1 http-equiv="content-type">'
	cBody    += '  <title>E-mails BLOQUEADOS na fila SZM</title>'
	cBody    += '  <meta content="Etilux" name="author">'
	cBody    += '  <meta content="Utilizado para informar o TI sobre os e-mails que tiveram mais de 50 tentativas de envio e nao puderam ser enviados" name="description">'
	cBody    += '</head>'
	cBody    += '<body style="color: rgb(0, 0, 0); background-color: rgb(168, 168, 168); alink="#000099" link="#000099" vlink="#990099">'
	cBody    += '<div style="text-align: left;">'
	
	cCorpo   := 		'Prezado, ' + CRLF + CRLF
	cBody    += 		'<br> Prezado, <br>'
	
	cCorpo   += 		'Segue lista de registros que excederam o n๚mero mแximo de tentativas de envio e nใo puderam ser enviados.' + CRLF
	cBody    +=    		'<br> Segue lista de registros que excederam o n&uacute;mero de tentativas de envio e n&atilde;o puderam ser enviados.<br>'

	cCorpo   += 		'Favor tomar as devidas a็๕es..' + CRLF
	cBody    +=    		'<br> Favor tomar as devidas a&ccedil;&otilde;es.<br>'
	
	cCorpo   += 		CRLF + CRLF
	cBody    += 		'<br><br>'
	
	cBody    += '     <table style="width: 728px; height: 244px; text-align: left; margin-left: auto; margin-right: auto;" border="0" cellpadding="0" cellspacing="0">'
	cBody    += '        <tbody>'
	cBody    += '          <tr bgcolor="#ffffff">'
	cBody    += '            <td class="formulario2"><table width="100%" border="1" cellspacing="1" cellpadding="1">'
	cBody    += ' 		      <tr>'
	cBody    += '             <th width="10%" bgcolor="#999999" scope="col"><span class="style4">Filial</span></th>'
	cBody    += '             <th width="10%" bgcolor="#999999" scope="col"><span class="style4">Forn-Lj</span></th>'
	cBody    += '             <th width="10%" bgcolor="#999999" scope="col"><span class="style4">Emissao</span></th>'
	cBody    += '             <th width="20%" bgcolor="#999999" scope="col"><span class="style4">Para</span></th>'
	cBody    += '             <th width="50%" bgcolor="#999999" scope="col"><span class="style4">Erro</span></th>'
	cBody    += '             </tr>'
	
	For _i := 1 to Len(aExcTent)
		
		cBody += '	 	  <tr>'
	
		cCorpo   += 		AllTrim(aExcTent[_i,3]) + ' - ' + AllTrim(aExcTent[_i,5]) + ' - ' + AllTrim(aExcTent[_i,1]) + ' - ' + AllTrim(aExcTent[_i,2]) + ' - ' + AllTrim(aExcTent[_i,4]) + CRLF
	
		cBody += '			<td width="10%"><div align="center">' 	+ aExcTent[_i,3] + '</div></td>' //Filial
		cBody += '			<td width="10%"><div align="center">' 	+ aExcTent[_i,5] + '</div></td>' //Filial
		cBody += '		 	<td width="10%"><div align="center">' 	+ aExcTent[_i,1] + '</div></td>' //Emissao
		cBody += '		 	<td width="20%"><div align="left">' 	+ aExcTent[_i,2] + '</div></td>' //Para
		cBody += '		 	<td width="50%"><div align="left">'  	+ aExcTent[_i,4] + '</div></td>' //Erro
		cBody += '	   	 </tr>'
	
	Next
	
	cBody    += '          </table></td>'
	cBody    += '          </tr>'
	cBody    += '          <tr bgcolor="#ffffff">'
	cBody    += '            <td class="tituloAtencao" height="19">&nbsp;</td>'
	cBody    += '          </tr>'
	cBody    += '        </tbody>'
	cBody    += '      </table>'
	
	cCorpo   += 		CRLF + CRLF
	cCorpo   += 		'Esta mensagem pode conter informa็๕es confidenciais e/ou privilegiadas, se voc๊ nใo for o seu destinatแrio, favor comunicar imediatamente ao remetente e destruir todas as informa็๕es e suas c๓pias.' + CRLF
	cCorpo   += 		'This message may contain information which is confidential and/or privileged. If you are not the intended recipient, please advise the sender immediately and destroy it and all copies.' + CRLF
	cBody    += 		'<br><br>'
	cBody    += 		'<br>Esta mensagem pode conter informa&ccedil;&otilde;es confidenciais e/ou privilegiadas, se voc&ecirc; n&atilde;o for o seu destinat&aacute;rio, favor comunicar imediatamente ao remetente e destruir todas as informa&ccedil;&otilde;es e suas c&oacute;pias. <br>'
	cBody    += 		'This message may contain information which is confidential and/or privileged. If you are not the intended recipient, please advise the sender immediately and destroy it and all copies. <br>'
	
	
	cBody    += '      <span style="font-family: Arial Narrow;"></span><span=""></span></td>'
	cBody    += '    </tr>'
	cBody    += '  </tbody>'
	cBody    += '</table>'
	cBody    += '</div>'
	cBody    += '</body>'
	cBody    += '</html>'
	
	U_EMAILTO(cServer, cAccount, cPass, cFrom, cMailTo, cMailCc, cMailBcc, cSubject, cBody, cFiles, lText,,,,xFilial("SE2"), cCorpo,"LISTA NAO ENVIADA") 

Return()


/*
Funcao: MailIs
Autor: Leandro Boni
Data: 29/08/2016
Descricao: Valida se o e-mail passado e valido, permitidno validar diversos e-mails separados por ';'.
A funcao de validacao de cada e-mail e a isEmail (Padrao TOTVS)

_cEmails - String contendo o e-mail a ser validado ou os e-mails a serem validados (Separados por ';')
_lMultiple - Indica se a validacao sera apenas para UM E-MAIL ou para MULTIPLOS E-MAILS (Default: .F.)
_lShowError - Indica se deve exibir Alert em caso de erro ou apenas retornar boolean (Default: .F.)
*/

Static Function MailIs(_cEmails, _lMultiple, _lShowError)

	Local _lRet		:=	.F.
	Local _aEmails	:=	{}
	Local _nValid	:=	0
	Local _nAT		:=	0

	Default _cEmails		:=	""
	Default _lShowError		:=	.F.
	Default _lMultiple		:=	.F.

	If !Empty(_cEmails)
		If(_lMultiple) //Caso existam, valida varios e-mails separados por ';'
			_aEmails	:=	StrTokArr(Rtrim(_cEmails), ";")
		Else
			Aadd(_aEmails, Rtrim(_cEmails))
		Endif
		
		If Len(_aEmails) = 1

			_lMultiple:= .F.

		EndIf

		//Verifica se TODOS os e-mails informados sao validos
		For _nAT := 1 To Len(_aEmails)
			If !Empty(_aEmails[_nAT]) .And. IsEmail(_aEmails[_nAT])
				_nValid	:=	_nValid + 1
			Endif
		Next

		//Somente permite continuar caso TODOS os e-mails informados sejam validos
		If _nValid == Len(_aEmails)
			_lRet	:=	.T.

			If Substring(Rtrim(_cEmails), Len(Rtrim(_cEmails)), 1) == ";"
				If _lShowError
					Conout("J_EnvMai (U_J_EnvMai): "+Dtos(Date())+" - "+Time() + " - O ๚ltimo caracter NรO deve ser um ';'")
				 
					cErrorMsg:= "O ๚ltimo caracter do E-Mail NรO deve ser um ';'"
					
				Endif

				_lRet	:=	.F.				
			Endif
		Else
			If _lShowError
				If _lMultiple
					Conout("J_EnvMai (U_J_EnvMai): "+Dtos(Date())+" - "+Time() + " - O(s) E-mail(s) informado(s) ้(sใo) invแlido(s)! Verifique...")
					cErrorMsg:= "O(s) E-mail(s) informado(s) ้(sใo) invแlido(s)! Verifique..."
				Else
					Conout("J_EnvMai (U_J_EnvMai): "+Dtos(Date())+" - "+Time() + " - O E-mail informado ้ invแlido! Verifique...")
					cErrorMsg:= "O E-mail informado ้ invแlido! Verifique..."
				Endif

				_lRet	:=	.F.
			Endif
		Endif
	Else
		_lRet	:=	.T.
	Endif

Return _lRet