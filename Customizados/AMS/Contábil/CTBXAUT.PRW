#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
 

//-------------------------------------------------------------------
/*/{Protheus.doc}CTBXAUT
Conciliação automática contábil - ALATUR 
@author André Luiz Brito Silva
@since  03/05/2019
@version 12
/*/
//-------------------------------------------------------------------

User Function CTBXAUT()

Local oPanel
Local oNewPag
Local oStepWiz    := Nil
Local oDlg        := Nil
Local oPanelBkg

Private cFilDe    := ""
Private cFilAte   := ""
Private cConDe    := Space(20)
Private dDtDe     := CTOD("//")
Private dDtAte    := CTOD("//")
Private cCombo1   := ""
Private cHist     := ""
 
 	//MsgInfo("Esse assistente irá auxiliar na parametrização da conciliação contábil.","Bem vindo ao robô contabil!")
 	
    DEFINE DIALOG oDlg TITLE 'Robô de Conciliação Contábil' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )
    oDlg:nWidth := 500
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
    oNewPag:SetConstruction({|Panel|cria_pg1(Panel, @cFilde, @cFilAte, @cConDe, @dDtDe, @dDtAte, @cCombo1, @cHist)})
    //Define o bloco ao clicar no botão Próximo
    oNewPag:SetNextAction({||valida_pg1(@cFilde, @cFilAte, @cConDe, @dDtDe, @dDtAte, @cCombo1, @cHist)})
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
    oNewPag := oStepWiz:AddStep("2", {|Panel|cria_pg2(Panel, @cFilde, @cFilAte, @cConDe, @dDtDe, @dDtAte, @cCombo1, @cHist)})
    oNewPag:SetStepDescription ("Finalizado")//("Robo Trabalhando")
    oNewPag:SetNextAction({|| Aviso("Termino","Conciliação Finalizada!",{"Fechar"},1), .T., oDlg:End()})
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
   /* oNewPag := oStepWiz:AddStep("3", {|Panel|cria_pg3(Panel, @cFilde, @cFilAte, @cConDe, @dDtDe, @dDtAte, @cCombo1, @cHist)})
    oNewPag:SetStepDescription("Finalizado")
    oNewPag:SetNextAction({|| Aviso("Termino","Conciliação Finalizada!",{"Fechar"},1), .T., oDlg:End()})
    oNewPag:SetCancelAction({||Alert("Cancelado"), .T., oDlg:End()})
    oNewPag:SetCancelWhen({||.F.})*/
    oStepWiz:Activate()
    
    ACTIVATE DIALOG oDlg CENTER
    oStepWiz:Destroy()
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc}cria_pg1
Conciliação automática contábil - ALATUR 
Construção da página 1 - Wizard
@author André Luiz Brito Silva
@since  03/05/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function cria_pg1(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cCombo1, cHist)
    
Local oTGet0
Local oTGet1
Local oTGet2
Local oTGet3
Local oTGet4
Local oCombo1
Local aItems  := {'Não Conciliados','Conciliados','Ambos'}
Local cCombo1 := aItems[1]  
    
oSay1   := TSay():New(10,10,{||'Filial De: '},oPanel,,,,,,.T.,,,200,20)//Texto
cFilDe  := Space(8)
oTGet1  := tGet():New(20,10,{|u| if(PCount()>0,cFilDe:=u,cFilDe)}, oPanel ,50,9,PesqPict("CT2","CT2_FILIAL"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"SM0","cFilDe")

oSay1   := TSay():New(40,10,{||'Filial Até: '},oPanel,,,,,,.T.,,,200,20)//Texto
cFilAte := Space(8)
oTGet1  := tGet():New(50,10,{|u| if(PCount()>0,cFilAte:=u,cFilAte)}, oPanel ,50,9,PesqPict("CT2","CT2_FILIAL"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"SM0","cFilAte")

oSay1   := TSay():New(70,10,{||'Conta Contábil: '},oPanel,,,,,,.T.,,,200,20)//Texto
cConDe  := Space(20)
oTGet1  := tGet():New(80,10,{|u| if(PCount()>0,cConDe:=u,cConDe)}, oPanel ,50,9,PesqPict("CT2","CT2_CREDIT"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"CT1","cConDe")

oSay4  	:= TSay():New(100,10,{|| 'Data De: '},oPanel,,,,,,.T.,,,200,20)
oTGet4 	:= tGet():New(110,10,{|u| if(PCount()>0,dDtDe:=u,dDtDe)}, oPanel ,50,9,"@D",{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"dDtAte")

oSay4  	:= TSay():New(130,10,{|| 'Data Até: '},oPanel,,,,,,.T.,,,200,20)
oTGet4 	:= tGet():New(140,10,{|u| if(PCount()>0,dDtAte:=u,dDtAte)}, oPanel ,50,9,"@D",{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"dDtAte")

//oCombo1 := TComboBox():New(160,10,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItems,100,20,oPanel,,{|| },,,,.T.,,,,,,,,,'cCombo1')

oSay1   := TSay():New(160,10,{||'Contém no Histórico Ex.: (Teste1;Teste2;Teste3): '},oPanel,,,,,,.T.,,,200,40)//Texto
cHist  := Space(40)
oTGet1  := tGet():New(170,10,{|u| if(PCount()>0,cHist:=u,cHist)}, oPanel ,100,9,PesqPict("CT2","CT2_HIST"),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"cHist")

Return
 
 
//----------------------------------------
// Validação do botão Próximo da página 1
//----------------------------------------
Static Function valida_pg1(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cCombo1, cHist)

If Empty(cFilde) .Or. Empty(cFilAte)
	MsgAlert( "Por favor preencha a filial corretamente!", "Filial Inválida" )
	Return .F.
EndIf

If Empty(cConDe)
	MsgAlert( "Por favor preencha a conta!", "Conta Inválida" )
	Return .F.
EndIf

If Empty(dDtDe) .Or. Empty(dDtAte)
	MsgAlert( "Por favor preencha a data corretamente!", "Data Inválida" )
	Return .F.
EndIf

Return .T.
 
//-------------------------------------------------------------------
/*/{Protheus.doc}cria_pg2
Conciliação automática contábil - ALATUR 
Construção da página 2 - Wizard
@author André Luiz Brito Silva
@since  03/05/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function cria_pg2(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cCombo1, cHist)

Private oProcess

oProcess := MsNewProcess():New( { || ProcCon(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cCombo1, cHist) } , "Realizando conciliação contábil" , "Aguarde..." , .F. )
oProcess:Activate()
	//MsAguarde( { || ProcCon(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cCombo1, cHist) },,"Robô conciliando lançamentos contábeis...")
	
	//MsgRun("Robô conciliando lançamentos contábeis...","Aguarde...",{|| ProcCon(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cCombo1, cHist)})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}ProcCon
Conciliação automática contábil - ALATUR 
Construção da página 1 - Wizard
@author André Luiz Brito Silva
@since  03/05/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function ProcCon(oPanel, cFilde, cFilAte, cConDe, dDtDe, dDtAte, cCombo1, cHist)

Local oCombo1
Local oTGet1
Local oTGet2
Local oTGet3
Local _oAla    := Nil
Local aCampos  := {}
Local cQuery   := ""
Local cAliAux  := GetNextAlias()
Local cAliCon  := GetNextAlias()
Local nSldDeb  := 0
Local nSldCrd  := 0
Local nSldAcm  := 0
Local aButtons := {}
Local aSays    := {}
Local nOpca    := 0
Local cIdLanc  := ""
Local cIdDeb   := XIdMaxDeb()
Local cIdCre   := XIdMaxCre()
Local nIdDeb   := 0
Local nIdCre   := 0
Local aRecno   := {}
Local cArqTrb  := GetNextAlias()
Local cHrGst   := ""
Local cHoraIn  := Time()
Local cAuxHis  := ""
Local lClosed  := .F.
Local lSoma    := .F.
    
Private nQtdProc := 0 //Quantidade registros processados
Private nQtdVin  := 0 //Quantidade registros vinculados
    
Static oProcExc 
    
    If cIdCre > cIdDeb
    	cIdLanc := cIdCre
    Else
    	cIdLanc := cIdDeb
    EndIf

	//Criação de campos para tabela temporária
	AADD(aCampos,{"CT2_REC"      ,"N",20,0})
	AADD(aCampos,{"CT2_FILIAL"   ,"C",TamSX3("CT2_FILIAL")[1],0})
	AADD(aCampos,{"CT2_DEBITO"   ,"C",TamSX3("CT2_DEBITO")[1],0})
	AADD(aCampos,{"CT2_CREDIT"  ,"C",TamSX3("CT2_CREDIT")[1],0})
	AADD(aCampos,{"CT2_XNUMDO"   ,"C",TamSX3("CT2_XNUMDO")[1],0})
	AADD(aCampos,{"CT2_SALDO"    ,"N",16                     ,2})
	AADD(aCampos,{"CT2_ID"       ,"C",26,0})
	 
	cQuery := "WITH CREDITO AS ( "
	//cQuery += "SELECT CT2_FILIAL, CT2_XNUMDO, CT2_CREDIT, SUM(CT2_VALOR) CREDITO "
	cQuery += "SELECT CT2_XNUMDO, CT2_CREDIT, SUM(CT2_VALOR) CREDITO "
	cQuery += "FROM " + RetSqlName("CT2") + " WHERE "
	cQuery += "CT2_FILIAL   Between '" + cFilDe    + "' AND '" + cFilAte  + "' AND "
	cQuery += "CT2_CREDIT = '" + cConDe + "' AND "
	cQuery += "CT2_DATA   >= '" + Dtos(dDtDe)  + "' AND CT2_DATA <= '" + Dtos(dDtAte) + "' "
	//cQuery += "AND CT2_XCTBFL <> 'S' "
	
	//Caso seja informado 'Contém no Histórico'
	/*If !Empty(Alltrim(cHist))
		cHist := Alltrim(cHist)
		cHist := StrTran( cHist, ";", "%' OR CT2_HIST LIKE '%" )
		cHist := StrTran( cHist, "(", " AND CT2_HIST LIKE '%" )
		cHist := StrTran( cHist, ")", "%'" )
		cQuery += cHist
	EndIf*/
		
	cQuery += "AND D_E_L_E_T_ = ' ' "
	//cQuery += "GROUP BY CT2_FILIAL, CT2_XNUMDO, CT2_CREDIT"
	cQuery += "GROUP BY CT2_XNUMDO, CT2_CREDIT"
	cQuery += "),"
	cQuery += "DEBITO AS (" 
	//cQuery += "SELECT CT2_FILIAL, CT2_XNUMDO, CT2_DEBITO, SUM(CT2_VALOR) DEBITO "
	cQuery += "SELECT CT2_XNUMDO, CT2_DEBITO, SUM(CT2_VALOR) DEBITO "
	cQuery += "FROM " + RetSqlName("CT2") + " WHERE "
	cQuery += "CT2_FILIAL   Between '" + cFilDe    + "' AND '" + cFilAte  + "' AND "
	cQuery += "CT2_DEBITO = '" + cConDe + "' AND "
	cQuery += "CT2_DATA   >= '" + Dtos(dDtDe)  + "' AND CT2_DATA <= '" + Dtos(dDtAte) + "' "
	//cQuery += "AND CT2_XCTBFL <> 'S' "
	
	//Caso seja informado 'Contém no Histórico'
	/*If !Empty(Alltrim(cHist))
		cHist := Alltrim(cHist)
		cHist := StrTran( cHist, ";", "%' OR CT2_HIST LIKE '%" )
		cHist := StrTran( cHist, "(", " AND CT2_HIST LIKE '%" )
		cHist := StrTran( cHist, ")", "%'" )
		cQuery += cHist
	EndIf*/
	
	cQuery += "AND D_E_L_E_T_ = ' ' "
	//cQuery += "GROUP BY CT2_FILIAL, CT2_XNUMDO, CT2_DEBITO"
	cQuery += "GROUP BY CT2_XNUMDO, CT2_DEBITO"
	cQuery += " ) "
	//cQuery += "SELECT CREDITO.CT2_FILIAL, CREDITO.CT2_XNUMDO, CREDITO.CREDITO-DEBITO.DEBITO as CT2_SALDO "
	cQuery += "SELECT CREDITO.CT2_XNUMDO, CREDITO.CREDITO-DEBITO.DEBITO as CT2_SALDO "
//	cQuery += "FROM CREDITO INNER JOIN DEBITO ON CREDITO.CT2_XNUMDO = DEBITO.CT2_XNUMDO ORDER BY CT2_FILIAL, CT2_XNUMDO"
	cQuery += "FROM CREDITO INNER JOIN DEBITO ON CREDITO.CT2_XNUMDO = DEBITO.CT2_XNUMDO ORDER BY CT2_XNUMDO"
	
	//cQuery := ChangeQuery(cQuery) 
	 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)
	
	oProcess:SetRegua1( (cAliAux)->(RecCount()) ) //Alimenta a primeira barra de progresso
	
	If _oAla <> Nil
		_oAla:Delete() 
		_oAla := Nil
	EndIf
	
	// Criando o objeto do arquivo temporário
	_oAla := FwTemporaryTable():New(cArqTrb)
	
	// Criando a estrutura do objeto  
	_oAla:SetFields(aCampos)
	
	// Criando o indice da tabela
	_oAla:AddIndex("1",{"CT2_XNUMDO"})
	
	_oAla:Create()
	
	//Montando tabela temporária
	
	(cAliAux)->(dbGotop())

	Do While !(cAliAux)->(Eof())		
		If (cAliAux)->CT2_SALDO == 0
			
			If Len(cIdLanc) == 20
				cIdLanc := __cUserID + Soma1(cIdLanc)
			Else
				cIdLanc := Soma1(cIdLanc)
			EndIf
			
			lClosed := .T.
				
			cQuery := "SELECT R_E_C_N_O_, * FROM "
			cQuery += RetSqlName("CT2") + " CT2 "
			cQuery += " WHERE "
			cQuery += " CT2_XNUMDO = '" + (cAliAux)->CT2_XNUMDO  + "'  " 
			cQuery += " AND CT2_FILIAL   Between '" + cFilDe    + "' AND '" + cFilAte  + "' " 
			cQuery += " AND CT2_DATA   >= '" + Dtos(dDtDe)  + "' AND CT2_DATA <= '" + Dtos(dDtAte) + "' "
			cQuery += " AND ( CT2_CREDIT = '" + cConDe + "' OR CT2_DEBITO = '" + cConDe + "')"
			//cQuery += " AND ((CT2_CREDIT BETWEEN '" + cConDe + "' AND '" + cConDe + "')"
			//cQuery += " OR ( CT2_DEBITO BETWEEN '" + cConDe + "' AND '" + cConDe + "')) "
			
			/*If !Empty(Alltrim(cHist))
				cHist := Alltrim(cHist)
				cHist := StrTran( cHist, ";", "%' OR CT2_HIST LIKE '%" )
				cHist := StrTran( cHist, "(", " AND CT2_HIST LIKE '%" )
				cHist := StrTran( cHist, ")", "%'" )
				cQuery += cHist
			EndIf*/
			
			cQuery += " AND D_E_L_E_T_ = ' ' " 
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliCon,.T.,.T.)
			
			Do While !(cAliCon)->(Eof())
				RecLock(cArqTrb,.T.)
					(cArqTrb)->CT2_FILIAL     := (cAliCon)->CT2_FILIAL
					(cArqTrb)->CT2_DEBITO     := (cAliCon)->CT2_DEBITO
					(cArqTrb)->CT2_CREDITO    := (cAliCon)->CT2_CREDITO
					(cArqTrb)->CT2_REC        := (cAliCon)->R_E_C_N_O_
					(cArqTrb)->CT2_XNUMDO     := (cAliCon)->CT2_XNUMDO
					(cArqTrb)->CT2_ID         := cIdLanc
				MsUnLock()
				(cAliCon)->(dbskip())
			EndDo
		EndIf
		
		If lClosed
			(cAliCon)->(DbCloseArea())
			cAliCon := ""
			cAlicon := GetNextAlias()
		EndIf
		
		 lClosed := .F.
		 
		(cAliAux)->(dbskip())
	Enddo
	
		
	(cArqTrb)->(dbGotop())
	
	nQtdProc := 0 
	nQtdVin  := 0
	
	DbSelectArea("CT2")
	
	BEGIN TRANSACTION
	
	Do While (cArqTrb)->(!Eof()) 
		
		CT2->(DbGoto((cArqTrb)->CT2_REC))
			
		oProcess:SetRegua2( CT2->(RecCount()) ) //Alimenta a primeira barra de progresso
		
		nQtdProc += 1
		
		oProcess:IncRegua2("Verificando e gravando IDs de conciliação...")
			
		If Alltrim(CT2_XNUMDO) == Alltrim((cArqTrb)->CT2_XNUMDO) //.And. Alltrim(CT2_FILIAL) == Alltrim((cArqTrb)->CT2_FILIAL)
			 	
		 	RecLock("CT2",.F.)
		 	
		 	//cIdLanc := Soma1(cIdLanc)
		 	
			If Empty(CT2->CT2_XFLCRE) .And. Alltrim(CT2_CREDIT) == Alltrim(cConDe) 
				CT2->CT2_XIDCRE   := (cArqTrb)->CT2_ID //ID sequencial da conciliação contábil – vinculo de lançamentos a crédito
				CT2->CT2_XTPCRE   := "A" //Identifica se o lançamento foi conciliado de forma automática (A) ou manual (M).
				CT2->CT2_XFLCRE   := (cArqTrb)->CT2_CREDIT //Flag de conciliação contábil, identifica se o registro já foi conciliado.
				If Empty(CT2->CT2_XSTAT)
					CT2->CT2_XSTAT    := "1"
				EndIf
				CT2->CT2_XAUXCR   := RIGHT((cArqTrb)->CT2_ID, 20)
				nQtdVin += 1 //Acumulo a quantidade de registros processados
			EndIf
			
			If Empty(CT2->CT2_XFLDEB) .And. Alltrim(CT2_DEBITO) == Alltrim(cConDe)
				CT2->CT2_XIDDEB   := (cArqTrb)->CT2_ID//ID sequencial da conciliação contábil – vinculo de lançamentos a débito
				CT2->CT2_XTPDEB   := "A" //Identifica se o lançamento foi conciliado de forma automática (A) ou manual (M).
				CT2->CT2_XFLDEB   := (cArqTrb)->CT2_DEBITO  //Flag de conciliação contábil, identifica se o registro já foi conciliado.
				If Empty(CT2->CT2_XSTAT)
					CT2->CT2_XSTAT    := "1"
				EndIf
				CT2->CT2_XAUXDE   := RIGHT((cArqTrb)->CT2_ID, 20)
				nQtdVin += 1 //Acumulo a quantidade de registros processados
			EndIf
			
			If (!Empty(CT2->CT2_XFLCRE) .And. !Empty(CT2->CT2_XFLDEB) )
				CT2->CT2_XCTBFL   := "S"
				If Empty(CT2->CT2_XSTAT)
					CT2->CT2_XSTAT    := "2"
				EndIf
			EndIf
			
			CT2->(MsUnLock())	
		
		EndIf
	
	(cArqTrb)->(DbSkip())		
			
	EndDo
	
	END TRANSACTION
	
		cHrGst := ElapTime ( cHoraIn, TIME() )
		
		AADD(aButtons, { 1,.T.,{|| FechaBatch() }} )
		AADD(aButtons, { 2,.T.,{|| nOpca := 1 ,FechaBatch()}})
		AADD(aSays,"Registros Processados: " + Alltrim(Str(nQtdProc)) )
		AADD(aSays,"Registros Vinculados: "  + Alltrim(Str(nQtdVin)) + CRLF ) 
		AADD(aSays,"Início do Processamento: "  + cHoraIn ) 
		AADD(aSays,"Término do Processamento: "  + TIME() )
		AADD(aSays,"Tempo Gasto: "  + cHrGst )
		/*If nQtdVin > 0
			AADD(aSays,"Número de ID gravado: "  + cIdLanc ) 
		EndIf */
		
		FormBatch( "Log de Processamento", aSays, aButtons ,,,445)
		
		//MsAguarde( { || GerRelCon() },,"Exportando os registros para Excel")
		
		(cArqTrb)->(DbCloseArea())
		
		/*If nQtdVin > 0
			If MsgYesNo( "Deseja imprimir os registros conciliados em Planilha?", "Gerar Planilha" )
				//MsgRun("Gerando Planilha Excel no Server","Aguarde...",{|| GerRelCon(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cCombo1, cHist) })
				oProcExc := MsNewProcess():New( { || GerRelCon(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cCombo1, cHist) } , "Gerando Planilha" , "Aguarde..." , .F. )
				oProcExc:Activate()
			EndIf
		EndIf*/
		
		If _oAla <> Nil
			_oAla:Delete()
			_oAla := Nil
		Endif
		
		MsgAlert( "Confirme e finalize a conciliação :) ", "Processamento Finalizado!" )
		
Return
 

//-------------------------------------------------------------------
/*/{Protheus.doc}GerRelCon
Conciliação automática contábil - ALATUR 
Gera relatório em Excel com os registros processados
@author André Luiz Brito Silva
@since  03/05/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function GerRelCon(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cCombo1, cHist)

Local cArquivo  := "CONCI.XLS"
Local oExcelApp := Nil
Local cPath     := "C:\Conciliados"
Local nTotal    := 0
Local oExcel
Local oExcelApp
Local _oPlan
Local cQuery    := ""
Local cAliAux   := GetNextAlias()
Local aCampos   := {}
Local cArqTrb   := GetNextAlias()

aColunas := {}
aLocais  := {} 
oBrush1  := TBrush():New(, RGB(193,205,205))

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
AADD(aCampos,{"CT2_XIDDEB"   ,"C",TamSX3("CT2_XIDDEB")[1],0})
AADD(aCampos,{"CT2_XIDCRE"   ,"C",TamSX3("CT2_XIDCRE")[1],0})
AADD(aCampos,{"CT2_XFLDEB"   ,"C",TamSX3("CT2_XFLDEB")[1],0})
AADD(aCampos,{"CT2_XFLCRE"   ,"C",TamSX3("CT2_XFLCRE")[1],0})
AADD(aCampos,{"CT2_XTPDEB"   ,"C",TamSX3("CT2_XTPDEB")[1],0})
AADD(aCampos,{"CT2_XTPCRE"   ,"C",TamSX3("CT2_XTPCRE")[1],0})

If !ApOleClient('MsExcel')

    MsgAlert("Falha ao abrir Excel!")
    //Return

EndIf

oExcel  := FWMSExcel():New()
cAba    := "Lançamentos Processados"
cTabela := "Lançamentos Conciliados - ALATUR"

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


cQuery := "SELECT * FROM "
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += " WHERE "
cQuery += " CT2_FILIAL   Between '" + cFilDe    + "' AND '" + cFilAte  + "' " 
cQuery += " AND ((CT2_CREDIT BETWEEN '" + cConDe + "' AND '" + cConDe + "')"
cQuery += " OR ( CT2_DEBITO BETWEEN '" + cConDe + "' AND '" + cConDe + "')) "
cQuery += " AND CT2_DATA   >= '" + Dtos(dDtDe)  + "' AND CT2_DATA <= '" + Dtos(dDtAte) + "' " 
cQuery += " AND ( CT2_XFLCRE = '" + cConDe + "' OR CT2_XFLDEB = '" + cConDe + "')"
//cQuery += " AND (CT2_XFLDEB != ' ' OR CT2_XFLCRE != ' ') "
cQuery += " AND D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

oProcExc:SetRegua1( (cAliAux)->(RecCount()) ) //Alimenta a primeira barra de progresso
//Impressão Relatório

If _oPlan <> Nil
	_oPlan:Delete() 
	_oPlan := Nil
EndIf

// Criando o objeto do arquivo temporário
_oPlan := FwTemporaryTable():New(cArqTrb)

// Criando a estrutura do objeto  
_oPlan:SetFields(aCampos)

// Criando o indice da tabela
_oPlan:AddIndex("1",{"CT2_XNUMDO"})

_oPlan:Create()


Do While !(cAliAux)->(Eof())
		oProcExc:IncRegua1("Processando tabela temporária")	
		RecLock(cArqTrb,.T.)
		(cArqTrb)->CT2_FILIAL    := Alltrim((cAliAux)->CT2_FILIAL)
		(cArqTrb)->CT2_DATA      := STOD((cAliAux)->CT2_DATA) 
		(cArqTrb)->CT2_LOTE      := Alltrim((cAliAux)->CT2_LOTE)
		(cArqTrb)->CT2_SBLOTE    := Alltrim((cAliAux)->CT2_SBLOTE)
		(cArqTrb)->CT2_DOC       := Alltrim((cAliAux)->CT2_DOC)
		(cArqTrb)->CT2_XNUMDO    := Alltrim((cAliAux)->CT2_XNUMDO)
		(cArqTrb)->CT2_TPSALD    := Alltrim((cAliAux)->CT2_TPSALD)
		(cArqTrb)->CT2_DC        := Alltrim((cAliAux)->CT2_DC)
		(cArqTrb)->CT2_DEBITO    := Alltrim((cAliAux)->CT2_DEBITO)
		(cArqTrb)->CT2_CREDIT    := Alltrim((cAliAux)->CT2_CREDIT)
		(cArqTrb)->CT2_VALOR     := (cAliAux)->CT2_VALOR
		(cArqTrb)->CT2_HIST      := Alltrim((cAliAux)->CT2_HIST)
		(cArqTrb)->CT2_ORIGEM    := Alltrim((cAliAux)->CT2_ORIGEM)
		(cArqTrb)->CT2_XIDDEB    := Alltrim((cAliAux)->CT2_XIDDEB)
		(cArqTrb)->CT2_XIDCRE    := Alltrim((cAliAux)->CT2_XIDCRE)
		(cArqTrb)->CT2_XFLDEB    := Alltrim((cAliAux)->CT2_XFLDEB)
		(cArqTrb)->CT2_XFLCRE    := Alltrim((cAliAux)->CT2_XFLCRE)
		(cArqTrb)->CT2_XTPDEB    := Alltrim((cAliAux)->CT2_XTPDEB)
		(cArqTrb)->CT2_XTPCRE    := Alltrim((cAliAux)->CT2_XTPCRE)
		MsUnLock()
		(cAliAux)->(dbskip())
	Enddo
	
DbselectArea(cArqTrb)
dbGoTop()

While !(cArqTrb)->(Eof())
 	oProcExc:IncRegua2("Gerando a planilha...")	
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

End

If !Empty(oExcel:aWorkSheet)

    oExcel:Activate()
    oExcel:GetXMLFile(cArquivo)
 
    CpyS2T("\SYSTEM\"+cArquivo, cPath)

    oExcelApp := MsExcel():New()
    oExcelApp:WorkBooks:Open(cPath + "\" + cArquivo) // Abre a planilha
	oExcelApp:SetVisible(.T.)
	
EndIf

If _oPlan <> Nil
	_oPlan:Delete()
	_oPlan := Nil
Endif
    
Return(.T.)
 
//--------------------------
// Construção da página 3
//--------------------------
Static Function cria_pg3(oPanel,cFilde, cFilAte, cConDe, dDtDe, dDtAte, cCombo1, cHist)

Local oBtnPanel := TPanel():New(0,0,"",oPanel,,,,,,40,40)

oBtnPanel:Align := CONTROL_ALIGN_ALLCLIENT

oTButton1 := TButton():New( 010, 010, "Imprimir Razão Genérico" ,oBtnPanel,{|| U_REL()} , 120,20,,,.F.,.T.,.F.,,.F.,,,.F. )
   //oTButton2 := TButton():New( 040, 010, "Consultar",oBtnPanel,{|| Aviso("Atenção","Consultar",{"Continuar"},1)}, 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
 
Return

Static Function XIdMaxDeb()

Local cIdDeb    := ""
Local cQuery    := ""
Local cAliAux   := GetNextAlias()

cQuery := "SELECT MAX(CT2_XAUXDE) AS IDDEB FROM"
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += " WHERE "
cQuery += " D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

cIdDeb := (cAliAux)->IDDEB

Return cIdDeb


Static Function XIdMaxCre()

Local cIdCre    := ""
Local cQuery    := ""
Local cAliAux   := GetNextAlias()

cQuery := "SELECT MAX(CT2_XAUXCR) AS IDCRE FROM"
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += " WHERE "
cQuery += " D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

cIdCre := (cAliAux)->IDCRE

Return cIdCre