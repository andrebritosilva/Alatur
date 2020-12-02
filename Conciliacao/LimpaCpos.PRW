#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
 

//-------------------------------------------------------------------
/*/{Protheus.doc}CTBXAUT
Desconciliação automática contábil - ALATUR 
@author André Luiz Brito Silva
@since  03/05/2019
@version 12
/*/
//-------------------------------------------------------------------

User Function LimpaCpos()

Local oPanel
Local oNewPag
Local cFilDe    := ""
Local cFilAte   := ""
Local cConDe    := Space(20)
Local dDtDe     := CTOD("//")
Local dDtAte    := CTOD("//")
Local cCombo1   := ""
Local cIDDes    := ""
Local cHist     := ""
Local cGrupo    := Space(4)
Local oStepWiz  := Nil
Local oDlg      := Nil
Local oPanelBkg := Nil
 
 
 	MsgInfo("Esse assistente irá auxiliar na parametrização da desconciliação contábil.","Realização da Desconciliação Contábil")

//Para que a tela da classe FWWizardControl fique no layout com bordas arredondadas
//iremos fazer com que a janela do Dialog oculte as bordas e a barra de titulo
//para isso usaremos os estilos WS_VISIBLE e WS_POPUP
DEFINE DIALOG oDlg TITLE 'Desconciliação Contábil' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )
    oDlg:nWidth  := 500
    oDlg:nHeight := 650
 
    oPanelBkg:= tPanel():New(0,0,"",oDlg,,,,,,200,200)
    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT
 
    //Instancia a classe FWWizard
oStepWiz:= FWWizardControl():New(oPanelBkg)
oStepWiz:ActiveUISteps()

//----------------------
// Pagina 1
//----------------------
oNewPag := oStepWiz:AddStep("1")
//Altera a descrição do step
oNewPag:SetStepDescription("Informe os parametros")
//Define o bloco de construção
oNewPag:SetConstruction({|Panel|criaLim1(Panel, @cFilde, @cFilAte, @cConDe, @dDtDe, @dDtAte, @cIDDes, @cHist)})
//Define o bloco ao clicar no botão Próximo
oNewPag:SetNextAction({||validaDes1(@cFilde, @cFilAte, @cConDe, @dDtDe, @dDtAte, @cIDDes, @cHist)})
//Define o bloco ao clicar no botão Cancelar
oNewPag:SetCancelAction({||Alert("Cancelado"), .T., oDlg:End()})

//----------------------
// Pagina 2
//----------------------
/*
    
    Adiciona um novo Step ao wizard
 
    Parametros da propriedade AddStep
    cID - ID para o step
    bConstruct - Bloco de construção da tela
 
    */
oNewPag := oStepWiz:AddStep("2", {|Panel|criaLim2(Panel, @cFilde, @cFilAte, @cConDe, @dDtDe, @dDtAte, @cIdDes, @cHist)})
oNewPag:SetStepDescription("Robô limpando os campos")
oNewPag:SetNextAction({||.T./*valida_pg2(@cFilde, @cFilAte, @cConDe, @dDtDe, @dDtAte, @cCombo1, @cHist)*/})
 
    //Define o bloco ao clicar no botão Voltar
oNewPag:SetCancelAction({||Alert("Cancelado"), .T., oDlg:End()})
//Ser na propriedade acima (SetCancelAction) o segundo parametro estiver com .F., não será possível voltar
//para a página anterior

oNewPag:SetPrevAction({|| .T.})
oNewPag:SetPrevTitle("Voltar")

//----------------------
// Pagina 3
//----------------------
oNewPag := oStepWiz:AddStep("3", {|Panel|criaLim3(Panel)})
oNewPag:SetStepDescription("Finalizado")
oNewPag:SetNextAction({|| Aviso("Termino","Desconciliação Finalizada",{"Fechar"},1), .T., oDlg:End()})
oNewPag:SetCancelAction({||Alert("Cancelado"), .T., oDlg:End()})
oNewPag:SetCancelWhen({||.F.})
oStepWiz:Activate()

ACTIVATE DIALOG oDlg CENTER
oStepWiz:Destroy()
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc}cria_pg1
Desconciliação automática contábil - ALATUR 
Construção da página 1 - Wizard
@author André Luiz Brito Silva
@since  03/05/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function criaLim1(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cIdDes, cHist)
    
Local oTGet0
Local oTGet1
Local oTGet2
Local oTGet3
Local oTGet4
Local oCombo1
Local cProxId  := GetSxeNum("CT2","CT2_XIDCRE","CT2_XIDCRE")
Local cId      := ""

//Verificar Lógica, conversar com Michelle
cId := Val(cProxId)
cId := cId - 1
cIdDes := StrZero( cId,TamSX3("CT2_XIDCRE")[1])

oSay1   := TSay():New(10,10,{||'Filial De: '},oPanel,,,,,,.T.,,,200,20)//Texto
cFilDe  := Space(20)
oTGet1  := tGet():New(20,10,{|u| if(PCount()>0,cFilDe:=u,cFilDe)}, oPanel ,50,9,PesqPict("CT2","CT2_FILIAL"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"SM0","cFilDe")

oSay1   := TSay():New(40,10,{||'Filial Até: '},oPanel,,,,,,.T.,,,200,20)//Texto
cFilAte := Space(20)
oTGet1  := tGet():New(50,10,{|u| if(PCount()>0,cFilAte:=u,cFilAte)}, oPanel ,50,9,PesqPict("CT2","CT2_FILIAL"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"SM0","cFilAte")

oSay1   := TSay():New(70,10,{||'Conta Contábil: '},oPanel,,,,,,.T.,,,200,20)//Texto
cConDe  := Space(20)
oTGet1  := tGet():New(80,10,{|u| if(PCount()>0,cConDe:=u,cConDe)}, oPanel ,50,9,PesqPict("CT2","CT2_CREDIT"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"CT1","cConDe")

oSay4  	:= TSay():New(100,10,{|| 'Data De: '},oPanel,,,,,,.T.,,,200,20)
oTGet4 	:= tGet():New(110,10,{|u| if(PCount()>0,dDtDe:=u,dDtDe)}, oPanel ,50,9,"@D",{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"dDtAte")

oSay4  	:= TSay():New(130,10,{|| 'Data Até: '},oPanel,,,,,,.T.,,,200,20)
oTGet4 	:= tGet():New(140,10,{|u| if(PCount()>0,dDtAte:=u,dDtAte)}, oPanel ,50,9,"@D",{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"dDtAte")

oSay1   := TSay():New(160,10,{||'Número de ID a desconciliar: '},oPanel,,,,,,.T.,,,200,40)//Texto
cIdDes  := Space(20)
oTGet1  := tGet():New(170,10,{|u| if(PCount()>0,cIdDes:=u,cIdDes)}, oPanel ,70,9,PesqPict("CT2","CT2_XIDCRE"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"cIdDes")

//oCombo1 := TComboBox():New(160,10,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItems,100,20,oPanel,,{|| },,,,.T.,,,,,,,,,'cCombo1')

/*oSay1   := TSay():New(190,10,{||'Contém no Histórico: '},oPanel,,,,,,.T.,,,200,40)//Texto
cHist  := Space(40)
oTGet1  := tGet():New(200,10,{|u| if(PCount()>0,cHist:=u,cHist)}, oPanel ,50,9,PesqPict("CT2","CT2_HIST"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"cHist")*/

Return
 
 
//----------------------------------------
// Validação do botão Próximo da página 1
//----------------------------------------
Static Function validaDes1(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cIdDes, cHist)

Return .T.
 
//-------------------------------------------------------------------
/*/{Protheus.doc}criaDes2
Desconciliação automática contábil - ALATUR 
Construção da página 2 - Wizard
@author André Luiz Brito Silva
@since  03/05/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function criaLim2(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cIdDes, cHist)
	
Private oProcess
//MsgRun("Realizando desconciliação...","Aguarde...",{|| ProcDes(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cIdDes, cHist) })
oProcess := MsNewProcess():New( { || Clean(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cIdDes, cHist) } , "Realizando desconciliação contábil" , "Aguarde..." , .F. )
oProcess:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}ProcDes
Desconciliação automática contábil - ALATUR 
Construção da página 1 - Wizard
@author André Luiz Brito Silva
@since  03/05/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function Clean(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cIdDes, cHist)

Local cQuery    := ""
Local cAliAux   := GetNextAlias()
Local nSldDeb   := 0
Local nSldCrd   := 0
Local nSldAcm   := 0
Local aButtons  := {}
Local aSays     := {}
Local nOpca     := 0
Local cIdLanc   := GetSxeNum("CT2","CT2_XIDCRE")
Local aRecno    := {}
Local cArquivo  := "DESCONCI.XLS"
Local oExcelApp := Nil
Local cPath     := "C:\Conciliados"
Local nTotal    := 0
Local oExcel	:= Nil
Local oExcelApp := Nil
Local _oRel     := Nil
Local _oDesPlan := Nil
Local cQuery    := ""
Local aCpo      := {}
Local aCampos   := {}
Local aCpos     := {}
Local cArqTrb   := GetNextAlias()
Local cArqRel   := GetNextAlias()
Local lClosed   := .F.

Private nQtdProc := 0 //Quantidade registros processados
Private nQtdVin  := 0 //Quantidade registros vinculados

cIdLanc := cIdDes

AADD(aCampos,{"CT2_FILIAL"   ,"C",TamSX3("CT2_FILIAL")[1],0})
AADD(aCampos,{"CT2_DATA"     ,"D",TamSX3("CT2_DATA"  )[1],0})
AADD(aCampos,{"CT2_LOTE"     ,"C",TamSX3("CT2_LOTE"  )[1],0})
AADD(aCampos,{"CT2_SBLOTE"   ,"C",TamSX3("CT2_SBLOTE")[1],0})
AADD(aCampos,{"CT2_DOC"      ,"C",TamSX3("CT2_DOC"   )[1],0})
AADD(aCampos,{"CT2_XNUMDO"   ,"C",TamSX3("CT2_XNUMDO")[1],0})
AADD(aCampos,{"CT2_TPSALD"   ,"C",TamSX3("CT2_TPSALD")[1],0})
AADD(aCampos,{"CT2_DC"       ,"C",TamSX3("CT2_DC"    )[1],0})
AADD(aCampos,{"CT2_DEBITO"   ,"C",TamSX3("CT2_DEBITO")[1],0})
AADD(aCampos,{"CT2_CREDIT"   ,"C",TamSX3("CT2_CREDIT")[1],0})
AADD(aCampos,{"CT2_VALOR"    ,"N",TamSX3("CT2_VALOR" )[1],2})
AADD(aCampos,{"CT2_HIST"     ,"C",TamSX3("CT2_HIST"  )[1],0})
AADD(aCampos,{"CT2_ORIGEM"   ,"C",TamSX3("CT2_ORIGEM")[1],0})
AADD(aCampos,{"CT2_XIDCRE"   ,"C",TamSX3("CT2_XIDCRE")[1],0})
AADD(aCampos,{"CT2_XIDDEB"   ,"C",TamSX3("CT2_XIDDEB")[1],0})
AADD(aCampos,{"CT2_XTPCON"   ,"C",TamSX3("CT2_XTPCON")[1],0})


cQuery := "SELECT R_E_C_N_O_ , * FROM "
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += "WHERE "
cQuery += "(CT2_CREDIT = '" + cConDe + "' OR CT2_DEBITO = '" + cConDe + "')"
cQuery += " AND CT2_DATA   >= '" + Dtos(dDtDe)  + "' AND CT2_DATA <= '" + Dtos(dDtAte) + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

oProcess:SetRegua1( (cAliAux)->(RecCount()) ) //Alimenta a primeira barra de progresso

DbSelectArea("CT2")
CT2->(DbSetOrder(1))

Do While (cAliAux)->(!Eof())

	oProcess:IncRegua1("Processando desconciliação contábil")
	
	CT2->(DbGoTo((cAliAux)->(R_E_C_N_O_) ))
	nQtdProc += 1 
	nQtdVin  += 1
	RecLock("CT2",.F.)

	CT2->CT2_XIDCRE := '' 
	CT2->CT2_XIDDEB := '' 
	CT2->CT2_XTPCON := ''
	CT2->CT2_XCTBFL := ''
	
	CT2->(MsUnlock())
	
	(cAliAux)->(DbSkip())
	
EndDo
	

(cAliAux)->(DbCloseArea())

If lClosed
	(cArqTrb)->(DbCloseArea())
EndIf

MsgAlert( "Clique em avançar e continue...", "Desconciliação Finalizada!" )
		
Return
  
//--------------------------
// Construção da página 3
//--------------------------
Static Function criaLim3(oPanel)
    Local oBtnPanel := TPanel():New(0,0,"",oPanel,,,,,,40,40)
    oBtnPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    oTButton1 := TButton():New( 010, 010, "Imprimir Razão Genérico" ,oBtnPanel,{|| U_CTBR400G()} , 120,20,,,.F.,.T.,.F.,,.F.,,,.F. )
   //oTButton2 := TButton():New( 040, 010, "Consultar",oBtnPanel,{|| Aviso("Atenção","Consultar",{"Continuar"},1)}, 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
 
Return
