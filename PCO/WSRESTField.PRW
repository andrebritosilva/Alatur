#Include "Protheus.ch"
#Include "RESTFUL.ch"
#Include "tbiconn.ch"

WSRESTFUL WSRESTField DESCRIPTION "teste"

	WSMETHOD POST  DESCRIPTION "teste"    WSSYNTAX "/teste "

END WSRESTFUL

WSMETHOD POST  WSSERVICE WSRESTField

	Local oObj
	//Local aSM0 := AdmAbreSM0()
	
	RpcSetType(3)
	RpcSetEnv( "01", "01MG0006" )
	//RpcSetEnv("99","01")//empresa e filial
	
	cContent := ::GetContent()
	
	if FWJsonDeserialize(cContent, @oObj)	
	
		::SetContentType("application/json")

		motivo       := oObj:motivo
        aprovacao    := oObj:aprovacao
        contingencia := oObj:contingencia
        usuario      := oObj:usuario
        cUsuario     := oObj:cuser
        email        := oObj:email
        cFilPco      := oObj:filial
		bloqueio     := oObj:bloqueio
		alisolic     := oObj:alisolic
		
		xLibCont(cFilPco,bloqueio,motivo,aprovacao,contingencia,usuario,cUsuario,email,alisolic)
		
		::SetResponse("{'OK','Contigencia Liberada'}")
		ConOut( "Entrou 1")	
	
	else
	
		::SetResponse("{'erro','Falha ao incializar objeto'}")
		//SetRestFault(500,'falha ao inicializar o objeto')
		ConOut( "Entrou 2")
	endIf	
	
return .T.

Static Function xLibCont(cFilPco,bloqueio,motivo,aprovacao,contingencia,usuario,cUsuario,email,alisolic)

Local aArea     := GetArea() 
Local cFilMail	:= cFilPco
Local cCDCNTG	:= Alltrim(contingencia)
Local cCODBLQ	:= Alltrim(bloqueio)
Local cUsuario  := usuario
Local lLibera   := IIF(aprovacao == '1',.T.,.F.)
Local cAliAux   := GetNextAlias()
Local cUseCont  := ""
Local cQuery    := ""

cQuery := "SELECT * FROM "
cQuery += RetSqlName("ALI") + " ALI "
cQuery += "WHERE ALI_CDCNTG = '" + cCDCNTG + "' AND ALI_STATUS = '02'"
cQuery += " AND D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

cUseCont := (cAliAux)->ALI_USER

ALI->(DbSetorder(1))
IF ALI->(DbSeek(xFilial("ALI")+cCDCNTG + cUseCont))
                  
	If ALI->ALI_STATUS $ "03/05"
		ConOut( "Solicitação de contingencia ja liberada!")	 //"Solicitação de contingencia ja liberada!"
	ElseIf ALI->ALI_STATUS == "01"
		ConOut( "Solicitação de contingencia aguardando liberacao de nivel anterior!") //"Solicitação de contingencia aguardando liberacao de nivel anterior!"
	ElseIf ALI->ALI_STATUS $ "04/06"
		ConOut( "Solicitação de contingencia ja cancelada!") //"Solicitação de contingencia ja cancelada!"
	Else
		If lLibera
			PCOA500GER(.T., cCODBLQ, cUseCont)
		Else
			PCOA530ALC(6, cCodBlq,,.T., cUseCont) //Rejeitando liberação se resposta negativa	
		EndIf	
			                                                               				
	EndIF
Else
	ConOut( "Contigência não encontrada!")	 //"Solicitação de contingencia ja liberada!"
	aprovacao := "2"
	motivo := "Contigencia não encontrada!"
Endif
	
  If aprovacao == "2"
  	xEnvMailPco(cFilPco,bloqueio,motivo,aprovacao,contingencia,usuario,cUsuario,email,alisolic)
  EndIf
	
RestArea(aArea)

Return

Static Function xEnvMailPco(cFilPco,bloqueio,motivo,aprovacao,contingencia,usuario,cUsuario,email,alisolic)

Local aArea     := GetArea()
Local oProcess  := Nil                              //Objeto da classe TWFProcess.
Local oHtml	    := NIL			//Objeto utilizado para montar o E-Mail
Local oP		:= NIL
Local cTo       := ""
Local cSenha    := BuscaSenha(contingencia)

email := UsrRetMail(alisolic)
// Instanciamos a classe TWFProcess informando o código e nome do processo.

oProcess := TWFProcess():New("000001", "Treinamento")

// Criamos a tafefa principal que será respondida pelo usuário.

If aprovacao == "1"
	oProcess:NewTask("FORMULARIO", "\Workflow\Aprovado.html")
Else
	oProcess:NewTask("FORMULARIO", "\Workflow\Reprovado.html")
EndIf
// Atribuímos valor a um dos campos do formulário.

oProcess:oHtml:ValByName("cUsuario", "'" + usuario + "'" )
oProcess:oHtml:ValByName("cCont", "'" + contingencia + "'" )
oProcess:oHtml:ValByName("motivo", "'" + motivo + "'" )
If aprovacao == "1"
	oProcess:oHtml:ValByName("senha", "'" + cSenha + "'" )
EndIf

oProcess:cTo                := email 

If aprovacao == "1"
	oProcess:bTimeOut        := {{"u_wfTimeout()", 0, 0, 5 }}

	oProcess:bReturn        := "u_wfRetorno()"
EndIf

If aprovacao == "1"
	oProcess:cSubject        := "Contigencia " + contingencia + " Aprovada"
Else
	oProcess:cSubject        := "Contigencia " + contingencia + " Reprovada"
EndIf

cMailID := oProcess:Start()    

//-------------------------------------------------------------------
// "LINK" 
//-------------------------------------------------------------------

// Criamos o link para o arquivo que foi gerado na tarefa anterior.

/*oProcess:NewTask("LINK", "\workflow\WF_LINK.html")

// Atribuímos valor a um dos campos do formulário.

//oProcess:oHtml:ValByName("A_LINK", cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm")        

// Informamos o destinatário do email contendo o link.*/

oProcess:cTo                := cTo          

// Informamos o assunto do email.

oProcess:cSubject        := "Workflow Aprovacao Contigencia"

// Iniciamos a tarefa e enviamos o email ao destinatário.

oProcess:Start()    

RestArea(aArea)

Return

Static Function BuscaSenha()

Local aArea  := GetArea()
Local cSenha := ""

DbSelectArea("ALJ")
DbSetOrder(1)
If DbSeek(xFilial("ALJ") + contingencia )
	cSenha := PcoCtngKey()
Else
	cSenha := "Solicite a senha!"
EndIf

RestArea(aArea)

Return cSenha