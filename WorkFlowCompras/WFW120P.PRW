#include "rwmake.ch"
#Include "protheus.ch"
#Include "tbiconn.ch"
#Include "APWEBEX.CH"

User Function WFW120P()

Local oProcess    := Nil                           //Objeto da classe TWFProcess.
Local cMailId     := ""                            //ID do processo gerado.
Local cHostWF     := "http://187.94.63.204:14010"   //URL configurado no ini para WF Link.
Local cTo         := "andrebritosilva@gmail.com"   //Destinatário de email.          

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01MG0006"

// Instanciamos a classe TWFProcess informando o código e nome do processo.

oProcess := TWFProcess():New("000001", "Treinamento")

// Criamos a tafefa principal que será respondida pelo usuário.

oProcess:NewTask("FORMULARIO", "\Workflow\WF_FORM.html")

// Atribuímos valor a um dos campos do formulário.

oProcess:oHtml:ValByName("TEXT_TIME", Time() )

// Informamos em qual diretório será gerado o formulário.

oProcess:cTo                := "HTML"  

// Informamos qual função será executada no evento de timeout.

oProcess:bTimeOut        := {{"u_wfTimeout()", 0, 0, 5 }}

// Informamos qual função será executada no evento de retorno.  

oProcess:bReturn        := "u_WfTeste()"

// Iniciamos a tarefa e recuperamos o nome do arquivo gerado.  

cMailID := oProcess:Start()    

//-------------------------------------------------------------------

// "LINK"

//-------------------------------------------------------------------

// Criamos o ling para o arquivo que foi gerado na tarefa anterior.

oProcess:NewTask("LINK", "\workflow\WF_LINK.html")

// Atribuímos valor a um dos campos do formulário.

oProcess:oHtml:ValByName("A_LINK", cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm")        

// Informamos o destinatário do email contendo o link.

oProcess:cTo                := cTo          

// Informamos o assunto do email.

oProcess:cSubject        := "Workflow via link."

// Iniciamos a tarefa e enviamos o email ao destinatário.

oProcess:Start()    

User Function WfTeste()
Local lRet := .T.
lRet := .F.
Return