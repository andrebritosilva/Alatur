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

User Function CTBXDES()

Local oPanel
Local oNewPag
Local cFilDe    := ""
Local cFilAte   := ""
Local cConDe    := Space(20)
Local cConAte   := Space(20)
Local dDtDe     := CTOD("//")
Local dDtAte    := CTOD("//")
Local cCombo1   := ""
Local cIDDe     := ""
Local cIDAte    := ""
Local cHist     := ""
Local cGrupo    := Space(4)
Local oStepWiz  := Nil
Local oDlg      := Nil
Local oPanelBkg := Nil
 
 
//MsgInfo("Esse assistente irá auxiliar na parametrização da desconciliação contábil.","Realização da Desconciliação Contábil")

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
oNewPag:SetConstruction({|Panel|criaDes1(Panel, @cFilde, @cFilAte, @cConDe, @cConAte, @dDtDe, @dDtAte, @cIDDe, @cIdAte, @cHist)})
//Define o bloco ao clicar no botão Próximo
oNewPag:SetNextAction({||validaDes1(@cFilde, @cFilAte, @cConDe, @cConAte, @dDtDe, @dDtAte, @cIDDe, @cIdAte, @cHist)})
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
oNewPag := oStepWiz:AddStep("2", {|Panel|criaDes2(Panel, @cFilde, @cFilAte, @cConDe, @cConAte, @dDtDe, @dDtAte, @cIdDe, @cIdAte, @cHist)})
oNewPag:SetStepDescription("Finalizado")
oNewPag:SetNextAction({|| Aviso("Termino","Desconciliação Finalizada",{"Fechar"},1), .T., oDlg:End()})
//oNewPag:SetNextAction({||.T./*valida_pg2(@cFilde, @cFilAte, @cConDe, @dDtDe, @dDtAte, @cCombo1, @cHist)*/})
 
    //Define o bloco ao clicar no botão Voltar
oNewPag:SetCancelAction({||Alert("Cancelado"), .T., oDlg:End()})
//Ser na propriedade acima (SetCancelAction) o segundo parametro estiver com .F., não será possível voltar
//para a página anterior

oNewPag:SetPrevAction({|| .T.})
oNewPag:SetPrevTitle("Voltar")

//----------------------
// Pagina 3
//----------------------
/*oNewPag := oStepWiz:AddStep("3", {|Panel|criaDes3(Panel, @cFilde, @cFilAte, @cConDe, @cConAte, @dDtDe, @dDtAte, @cIdDe, @cIdAte, @cHist)})
oNewPag:SetStepDescription("Finalizado")
oNewPag:SetNextAction({|| Aviso("Termino","Desconciliação Finalizada",{"Fechar"},1), .T., oDlg:End()})
oNewPag:SetCancelAction({||Alert("Cancelado"), .T., oDlg:End()})
oNewPag:SetCancelWhen({||.F.})*/
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

Static Function criaDes1(oPanel, cFilde, cFilAte, cConDe, cConAte, dDtDe, dDtAte, cIdDe, cIdAte, cHist)
    
Local oTGet0
Local oTGet1
Local oTGet2
Local oTGet3
Local oTGet4
Local oCombo1
Local cProxId  := GetSxeNum("CT2","CT2_XIDCRE","CT2_XIDCRE")
Local cId      := ""

//Verificar Lógica, conversar com Michelle
/*cId := Val(cProxId)
cId := cId - 1
cIdDes := StrZero( cId,TamSX3("CT2_XIDCRE")[1])*/

oSay1   := TSay():New(20,10,{||'Filial De: '},oPanel,,,,,,.T.,,,200,20)//Texto
cFilDe  := Space(8)
oTGet1  := tGet():New(30,10,{|u| if(PCount()>0,cFilDe:=u,cFilDe)}, oPanel ,50,9,PesqPict("CT2","CT2_FILIAL"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"SM0","cFilDe")

oSay1   := TSay():New(20,100,{||'Filial Até: '},oPanel,,,,,,.T.,,,200,20)//Texto
cFilAte := Space(8)
oTGet1  := tGet():New(30,100,{|u| if(PCount()>0,cFilAte:=u,cFilAte)}, oPanel ,50,9,PesqPict("CT2","CT2_FILIAL"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"SM0","cFilAte")

oSay1   := TSay():New(60,10,{||'Conta Contábil De: '},oPanel,,,,,,.T.,,,200,20)//Texto
cConDe  := Space(20)
oTGet1  := tGet():New(70,10,{|u| if(PCount()>0,cConDe:=u,cConDe)}, oPanel ,50,9,PesqPict("CT2","CT2_CREDIT"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"CT1","cConDe")

oSay1   := TSay():New(60,100,{||'Conta Contábil Ate: '},oPanel,,,,,,.T.,,,200,20)//Texto
cConAte  := Space(20)
oTGet1  := tGet():New(70,100,{|u| if(PCount()>0,cConAte:=u,cConAte)}, oPanel ,50,9,PesqPict("CT2","CT2_CREDIT"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"CT1","cConAte")

oSay4  	:= TSay():New(100,10,{|| 'Data De: '},oPanel,,,,,,.T.,,,200,20)
oTGet4 	:= tGet():New(110,10,{|u| if(PCount()>0,dDtDe:=u,dDtDe)}, oPanel ,50,9,"@D",{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"dDtAte")

oSay4  	:= TSay():New(100,100,{|| 'Data Até: '},oPanel,,,,,,.T.,,,200,20)
oTGet4 	:= tGet():New(110,100,{|u| if(PCount()>0,dDtAte:=u,dDtAte)}, oPanel ,50,9,"@D",{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"dDtAte")

oSay1   := TSay():New(140,10,{||'Número de ID De: '},oPanel,,,,,,.T.,,,200,40)//Texto
cIdDe   := Space(20)
oTGet1  := tGet():New(150,10,{|u| if(PCount()>0,cIdDe:=u,cIdDe)}, oPanel ,70,9,PesqPict("CT2","CT2_XIDCRE"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"cIdDe")

oSay1   := TSay():New(140,100,{||'Número de ID Ate: '},oPanel,,,,,,.T.,,,200,40)//Texto
cIdAte  := Space(20)
oTGet1  := tGet():New(150,100,{|u| if(PCount()>0,cIdAte:=u,cIdAte)}, oPanel ,70,9,PesqPict("CT2","CT2_XIDCRE"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"cIdAte")


//oCombo1 := TComboBox():New(160,10,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItems,100,20,oPanel,,{|| },,,,.T.,,,,,,,,,'cCombo1')

/*oSay1   := TSay():New(190,10,{||'Contém no Histórico: '},oPanel,,,,,,.T.,,,200,40)//Texto
cHist  := Space(40)
oTGet1  := tGet():New(200,10,{|u| if(PCount()>0,cHist:=u,cHist)}, oPanel ,50,9,PesqPict("CT2","CT2_HIST"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"cHist")*/

Return
 
 
//----------------------------------------
// Validação do botão Próximo da página 1
//----------------------------------------
Static Function validaDes1(cFilde, cFilAte, cConDe, cConAte, dDtDe, dDtAte, cIdDe, cIdAte, cHist)

If Empty(cFilde) .Or. Empty(cFilAte)
	MsgAlert( "Por favor preencha a filial corretamente!", "Filial Inválida" )
	Return .F.
EndIf

If Empty(cConDe) .Or. Empty(cConAte)
	MsgAlert( "Por favor preencha a conta!", "Conta Inválida" )
	Return .F.
EndIf

If Empty(dDtDe) .Or. Empty(dDtAte)
	MsgAlert( "Por favor preencha a data corretamente!", "Data Inválida" )
	Return .F.
EndIf
 

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

Static Function criaDes2(oPanel, cFilde, cFilAte, cConDe, cConAte, dDtDe, dDtAte, cIdDe, cIdAte, cHist)
	
Private oProcess
//MsgRun("Realizando desconciliação...","Aguarde...",{|| ProcDes(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cIdDes, cHist) })
oProcess := MsNewProcess():New( { || ProcDes(oPanel, cFilde, cFilAte, cConDe, cConAte, dDtDe, dDtAte, cIdDe, cIdAte, cHist) } , "Realizando desconciliação contábil" , "Aguarde..." , .F. )
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

Static Function ProcDes(oPanel, cFilde, cFilAte, cConDe, cConAte, dDtDe, dDtAte, cIdDe, cIdAte, cHist)

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
Local cHoraIn   := Time()

Private nQtdProc := 0 //Quantidade registros processados
Private nQtdVin  := 0 //Quantidade registros vinculados

//cIdLanc := cIdDes

If Empty(cIdDe)
	cIdDe := "00000000000000000000000000"
EndIf

If Empty(cIdAte)
	cIdAte := "99999999999999999999999999"
EndIf

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
AADD(aCampos,{"CT2_XTPCRE"   ,"C",TamSX3("CT2_XTPCRE")[1],0})
AADD(aCampos,{"CT2_XTPDEB"   ,"C",TamSX3("CT2_XTPDEB")[1],0})
AADD(aCampos,{"CT2_XFLDEB"   ,"C",TamSX3("CT2_XFLDEB")[1],0})
AADD(aCampos,{"CT2_XFLCRE"   ,"C",TamSX3("CT2_XFLCRE")[1],0})

AADD(aCPOS,  {"CT2_XNUMDO"   ,"C",TamSX3("CT2_XNUMDO")[1],0})
AADD(aCpos,  {"RECNO"        ,"N",10,0})

cQuery := "SELECT R_E_C_N_O_ , * FROM "
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += "WHERE "
cQuery += " CT2_DATA   >= '" + Dtos(dDtDe)  + "' AND CT2_DATA <= '" + Dtos(dDtAte) + "' " 
cQuery += " AND ((CT2_CREDIT BETWEEN '" + cConDe + "' AND '" + cConAte + "')"
cQuery += " OR ( CT2_DEBITO BETWEEN '" + cConDe + "' AND '" + cConAte + "')) "
cQuery += " AND ((CT2_XIDCRE BETWEEN '" + cIdDe + "' AND '" + cIdAte + "')"
cQuery += " OR ( CT2_XIDDEB BETWEEN '" + cIdDe + "' AND '" + cIdAte + "')) "
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

oProcess:SetRegua1( (cAliAux)->(RecCount()) ) //Alimenta a primeira barra de progresso

If _oRel <> Nil
	_oRel:Delete() 
	_oRel:= Nil
EndIf

// Criando o objeto do arquivo temporário
_oRel := FwTemporaryTable():New(cArqRel)

// Criando a estrutura do objeto  
_oRel:SetFields(aCpos)

// Criando o indice da tabela
_oRel:AddIndex("1",{"CT2_XNUMDO"})

_oRel:Create()

DbSelectArea("CT2")
CT2->(DbSetOrder(1))

	nQtdProc := 0 
	nQtdVin  := 0

BEGIN TRANSACTION

Do While (cAliAux)->(!Eof())

	oProcess:IncRegua1("Processando desconciliação contábil")
	//nQtdProc += 1
	CT2->(DbGoTo((cAliAux)->(R_E_C_N_O_) ))
	//nQtdProc += 1 
	RecLock("CT2",.F.)
	
	If Alltrim(cConDe) == Alltrim(CT2->CT2_XFLCRE)
		CT2->CT2_XIDCRE := ''
		CT2->CT2_XFLCRE := ''  
		CT2->CT2_XTPCRE := ''
		CT2->CT2_XAUXCR := ''
		CT2->CT2_XCTBFL := ''
		nQtdVin  += 1
	EndIf
	If Alltrim(cConDe) == Alltrim(CT2->CT2_XFLDEB)
		CT2->CT2_XIDDEB := '' 
		CT2->CT2_XFLDEB := ''
		CT2->CT2_XTPDEB := ''
		CT2->CT2_XAUXDE := ''
		CT2->CT2_XCTBFL := ''
		nQtdVin  += 1
	EndIf
	
	If Empty(CT2->CT2_XFLDEB) .And. Empty(CT2->CT2_XFLCRE)
		CT2->CT2_XCTBFL := ''
		CT2->CT2_XSTAT  := ''
	EndIf
	
		CT2->CT2_XOK    := ''
		
	CT2->(MsUnlock())
	
	RecLock(cArqRel,.T.)
	
	(cArqRel)->RECNO    := (cAliAux)->(R_E_C_N_O_)
	
	MsUnLock()
	
	(cAliAux)->(DbSkip())
	
EndDo

END TRANSACTION

cHrGst := ElapTime ( cHoraIn, TIME() )
	
AADD(aButtons, { 1,.T.,{|| FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| nOpca := 1 ,FechaBatch()}})
//AADD(aSays,"Registros Processados: " + Alltrim(Str(nQtdProc)) )
AADD(aSays,"Registros Desconciliados: "  + Alltrim(Str(nQtdVin)) + CRLF  )
AADD(aSays,"Início do Processamento: "  + cHoraIn ) 
AADD(aSays,"Término do Processamento: "  + TIME() )
AADD(aSays,"Tempo Gasto: "  + cHrGst )
/*If nQtdVin > 0
	AADD(aSays,"Número de ID desconciliado: "  + cIdLanc )
EndIf */

FormBatch( "Log de Processamento", aSays, aButtons ,,,445)
/* 
If nQtdVin > 0
	If MsgYesNo( "Deseja imprimir os registros desconciliados em planilha?", "Gerar Planilha" )
		//MsgRun("Gerando Planilha Excel no Server","Aguarde...",{|| GerRelDes(cAliAux) })
		lClosed := .T.
		aColunas := {}
		aLocais  := {} 
		oBrush1  := TBrush():New(, RGB(193,205,205))
		
		If !ApOleClient('MsExcel')
		
		    MsgAlert("Falha ao abrir Excel!")
		    Return
		
		EndIf
		
		oExcel  := FWMSExcel():New()
		cAba    := "Lançamentos Processados"
		cTabela := "Lançamentos Desconciliados - ALATUR"
		
		// Criação de nova aba 
		oExcel:AddworkSheet(cAba)
		
		// Criação de tabela
		oExcel:AddTable (cAba,cTabela)
		
		// Criação de colunas 
		oExcel:AddColumn(cAba,cTabela,"FILIAL"        	,1,2,.F.) 
		oExcel:AddColumn(cAba,cTabela,"DATA"          	,3,2,.F.) 
		oExcel:AddColumn(cAba,cTabela,"LOTE"  			,2,1,.F.) 
		oExcel:AddColumn(cAba,cTabela,"SUB-LOTE"     	,3,2,.F.) 
		oExcel:AddColumn(cAba,cTabela,"DOCUMENTO"   	,3,2,.F.) 
		oExcel:AddColumn(cAba,cTabela,"NUM.DOCUMENTO"   ,1,2,.F.) 
		oExcel:AddColumn(cAba,cTabela,"TIPO DE SALDO"   ,2,1,.F.) 
		oExcel:AddColumn(cAba,cTabela,"DC"    			,2,1,.F.) 
		oExcel:AddColumn(cAba,cTabela,"CONTA DEBITO"    ,2,1,.F.)
		oExcel:AddColumn(cAba,cTabela,"CONTA CREDITO"   ,2,1,.F.) 
		oExcel:AddColumn(cAba,cTabela,"VALOR"       	,2,1,.F.) 
		oExcel:AddColumn(cAba,cTabela,"HISTORICO"  		,3,2,.F.)
		oExcel:AddColumn(cAba,cTabela,"ORIGEM"  		,3,2,.F.)
		oExcel:AddColumn(cAba,cTabela,"ID DEBITO"  		,3,2,.F.)
		oExcel:AddColumn(cAba,cTabela,"ID CREDITO"  	,3,2,.F.)
		oExcel:AddColumn(cAba,cTabela,"FLAG DEB."  		,3,2,.F.)
		oExcel:AddColumn(cAba,cTabela,"FLAG CRE."    	,3,2,.F.)
		oExcel:AddColumn(cAba,cTabela,"TP CONCILI. DEB.",3,2,.F.)
		oExcel:AddColumn(cAba,cTabela,"TP CONCILI. CRE.",3,2,.F.) 
		
		If _oDesPlan <> Nil
			_oDesPlan:Delete() 
			_oDesPlan := Nil
		EndIf
		
		// Criando o objeto do arquivo temporário
		_oDesPlan := FwTemporaryTable():New(cArqTrb)
		
		// Criando a estrutura do objeto  
		_oDesPlan:SetFields(aCampos)
		
		// Criando o indice da tabela
		_oDesPlan:AddIndex("1",{"CT2_XNUMDO"})
		
		_oDesPlan:Create()
		
		(cArqRel)->(dbGoTop())
		
		oProcess:SetRegua2( (cArqRel)->(RecCount()) ) //Alimenta a primeira barra de progresso
			
		DbSelectArea("CT2")
		
		Do While (cArqRel)->(!Eof())
			
			oProcess:IncRegua2("Gerando os registros desconciliados na planilha...")
			
			CT2->(DbGoTo((cArqRel)->RECNO ))
			
			RecLock(cArqTrb,.T.)
			
			(cArqTrb)->CT2_FILIAL    := Alltrim(CT2->CT2_FILIAL)
			(cArqTrb)->CT2_DATA      := CT2->CT2_DATA 
			(cArqTrb)->CT2_LOTE      := Alltrim(CT2->CT2_LOTE)
			(cArqTrb)->CT2_SBLOTE    := Alltrim(CT2->CT2_SBLOTE)
			(cArqTrb)->CT2_DOC       := Alltrim(CT2->CT2_DOC)
			(cArqTrb)->CT2_XNUMDO    := Alltrim(CT2->CT2_XNUMDO)
			(cArqTrb)->CT2_TPSALD    := Alltrim(CT2->CT2_TPSALD)
			(cArqTrb)->CT2_DC        := Alltrim(CT2->CT2_DC)
			(cArqTrb)->CT2_DEBITO    := Alltrim(CT2->CT2_DEBITO)
			(cArqTrb)->CT2_CREDIT    := Alltrim(CT2->CT2_CREDIT)
			(cArqTrb)->CT2_VALOR     := CT2->CT2_VALOR
			(cArqTrb)->CT2_HIST      := Alltrim(CT2->CT2_HIST)
			(cArqTrb)->CT2_ORIGEM    := Alltrim(CT2->CT2_ORIGEM)
			(cArqTrb)->CT2_XIDDEB    := Alltrim((cAliAux)->CT2_XIDDEB)
			(cArqTrb)->CT2_XIDCRE    := Alltrim((cAliAux)->CT2_XIDCRE)
			(cArqTrb)->CT2_XFLDEB    := Alltrim((cAliAux)->CT2_XFLDEB)
			(cArqTrb)->CT2_XFLCRE    := Alltrim((cAliAux)->CT2_XFLCRE)
			(cArqTrb)->CT2_XTPDEB    := Alltrim((cAliAux)->CT2_XTPDEB)
			(cArqTrb)->CT2_XTPCRE    := Alltrim((cAliAux)->CT2_XTPCRE)
			
			MsUnLock()
			
			(cArqRel)->(dbskip())
			
		EndDo
			
		(cArqTrb)->(dbGoTop())
	
		While !(cArqTrb)->(Eof())
		 
		    // Criação de Linhas 
		    oExcel:AddRow(cAba,cTabela, { (cArqTrb)->CT2_FILIAL ,;
		                                  (cArqTrb)->CT2_DATA   ,; 
		                                  (cArqTrb)->CT2_LOTE   ,; 
		                                  (cArqTrb)->CT2_SBLOTE ,;
		                                  (cArqTrb)->CT2_DOC    ,;
		                                  (cArqTrb)->CT2_XNUMDO ,;
		                                  (cArqTrb)->CT2_TPSALD ,;
		                                  (cArqTrb)->CT2_DC     ,;
		                                  (cArqTrb)->CT2_DEBITO ,;
		                                  (cArqTrb)->CT2_CREDIT ,;
		                                  (cArqTrb)->CT2_VALOR  ,;
		                                  (cArqTrb)->CT2_HIST   ,;
		                                  (cArqTrb)->CT2_ORIGEM ,;
		                                  (cArqTrb)->CT2_XIDDEB ,;
		                                  (cArqTrb)->CT2_XIDCRE ,;
		                                  (cArqTrb)->CT2_XFLDEB ,;
		                                  (cArqTrb)->CT2_XFLCRE ,;
		                                  (cArqTrb)->CT2_XTPDEB ,;
		                                  (cArqTrb)->CT2_XTPCRE })
				
		    (cArqTrb)->(dbSkip())
		
		EndDo
		
		If !Empty(oExcel:aWorkSheet)
		
		    oExcel:Activate()
		    oExcel:GetXMLFile(cArquivo)
		 
		    CpyS2T("\SYSTEM\"+cArquivo, cPath)
		
		    oExcelApp := MsExcel():New()
		    oExcelApp:WorkBooks:Open(cPath + "\" + cArquivo) // Abre a planilha
			oExcelApp:SetVisible(.T.)
			
		EndIf
				
	EndIf
EndIf

(cAliAux)->(DbCloseArea())
*/
If lClosed
	(cArqTrb)->(DbCloseArea())
EndIf

If _oRel <> Nil
	_oRel:Delete()
	_oRel := Nil
Endif

If _oDesPlan <> Nil
	_oDesPlan:Delete()
	_oDesPlan := Nil
Endif

MsgAlert( "Confirme e finalize a desconciliação :)", "Desconciliação Finalizada!" )
		
Return
  
//--------------------------
// Construção da página 3
//--------------------------
Static Function criaDes3(oPanel, cFilde, cFilAte, cConDe, cConAte, dDtDe, dDtAte, cIdDe, cIdAte, cHist)
    Local oBtnPanel := TPanel():New(0,0,"",oPanel,,,,,,40,40)
    oBtnPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    oTButton1 := TButton():New( 010, 010, "Imprimir Razão Genérico" ,oBtnPanel,{|| U_REL()} , 120,20,,,.F.,.T.,.F.,,.F.,,,.F. )
   //oTButton2 := TButton():New( 040, 010, "Consultar",oBtnPanel,{|| Aviso("Atenção","Consultar",{"Continuar"},1)}, 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
 
Return
