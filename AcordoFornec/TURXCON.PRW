#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//--------------------------------------------------
	/*/{Protheus.doc} TURXCON
	 Interface de processamento de dados, acordos de fornecedor
	
	@author André Brito
	@since 16/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function TURXCON()

	Local aArea     := GetArea()
	Local cBkp      := FunName()
	Local cTitulo   := "Cobrança Comissão NET  / Acordo de Cancelamento"
	Local oBrowse
    
	SetFunName("TURXCON")
     
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZ1")
	oBrowse:SetDescription(cTitulo)
     
	oBrowse:AddLegend( "SZ1->Z1_STATUS == '1'" , "RED"    ,  "(1) Não processado" )
	oBrowse:AddLegend( "SZ1->Z1_STATUS == '2'" , "GREEN"  ,  "(2) Processado" )
	oBrowse:AddLegend( "SZ1->Z1_STATUS == '3'" , "GRAY"   ,  "(3) RV não localizado na G3R" )
	oBrowse:AddLegend( "SZ1->Z1_STATUS == '4'" , "YELLOW" ,  "(4) Já existe acordo p/ este RV" )
     
	oBrowse:Activate()
    
	SetFunName(cBkp)
     
	RestArea(aArea)
    
Return

//--------------------------------------------------
	/*/{Protheus.doc} MenuDef
	
	@author André Brito
	@since 16/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

Static Function MenuDef()

	Local aArea		:= GetArea()
	Local aRotina 	:= {}

	AADD(aRotina, {"Importar Planilha"	, "U_TURXFORN"		, 0, 3, 0, Nil })
	AADD(aRotina, {"Processar RVs"	    , "U_xTurProc"		, 0, 4, 0, Nil })
	AADD(aRotina, {"Visualizar RV"    	, "U_xVilRv"		, 0, 2, 0, Nil })
	AADD(aRotina, {"Relatório RVs"    	, "U_RelRvs"		, 0, 6, 0, Nil })
	AADD(aRotina, {"Eliminar Resid."    , "U_xTurExc"		, 0, 5, 0, Nil })
	
	RestArea(aArea)
	
Return( aRotina )

//--------------------------------------------------
	/*/{Protheus.doc} xTurProc()
	
	Processamento de registros tendo como finalidade
	a gravação das tabelas G3R/G48
	
	@author André Brito
	@since 16/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function xTurProc()

	Local aArea      := GetArea()
	
	Private aProc    := {}
	Private aNoProc  := {}
	Private aNoLoc   := {}
	Private cElapsed := ""
	Private aAcorRv  := {}
	Private HoraIni  := Time() 
	Private HoraFim 
	Private oProcess
	
	SaveInter()

	oProcess:= MsNewProcess():New( {|lEnd|  U_xEfeProc( oProcess )} )
	oProcess:Activate()
	
	RestInter()
	
	HoraFim  := Time() 
	
	cElapsed := ElapTime( HoraIni, HoraFim )
	
	MsgInfo("Processamento finalizado com sucesso! Tempo de processamento: " + cElapsed,"Concluido")

	RestArea(aArea)

Return .T.

//--------------------------------------------------
	/*/{Protheus.doc} xEfeProc()
	
	Processamento de registros tendo como finalidade
	a gravação das tabelas G3R/G48
	
	@author André Brito
	@since 16/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function xEfeProc(oProcess)
	
	Local aArea		:= GetArea()
	Local cQuery    := ""
	Local cAliAux   := GetNextAlias()
	Local nRecno    := 0
	Local cXFil     := ""
	Local cNumId    := ""
	Local cFornec   := ""
	Local cLoja     := ""
	Local cProduto  := ""
	Local lGrava    := .F.
	Local nTotal    := 0
	Local nAtual    := 0
	
	cQuery := "SELECT R_E_C_N_O_, * FROM "
	cQuery += RetSqlName("SZ1") + " SZ1 "
	cQuery += " WHERE "
	cQuery += " Z1_STATUS = '1'
	cQuery += " AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)
	
	Count To nTotal
	
	oProcess:SetRegua1(nTotal)
	
	(cAliAux)->(DbGoTop())
	
	Do While (cAliAux)->(!Eof())
	
		nRecno := (cAliAux)->R_E_C_N_O_
		
		nAtual++
		
		oProcess:IncRegua1("Processando registro G3R. Aguarde...")// + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
			
		SZ1->(DbGoto(nRecno))
		
		cXFil    := (cAliAux)->Z1_FILIAL
		cNumId   := (cAliAux)->Z1_NUMID
		cFornec  := (cAliAux)->Z1_CODFOR
		cLoja    := (cAliAux)->Z1_LOJA
		cProduto := (cAliAux)->Z1_PRODUTO
		
		lGrava := U_xBuscaG3R(cXFil,cNumId,cFornec,cLoja,cProduto, oProcess)
		
		If !lGrava
		
			RecLock("SZ1", .F.)
		
			SZ1->Z1_STATUS := "3"
		
			MsUnLock()
			
		EndIf
		
		(cAliAux)->(DbSkip())
		
	EndDo

	(cAliAux)->(dbCloseArea())
	
	RestArea(aArea)
	
Return

//--------------------------------------------------
	/*/{Protheus.doc} xBuscaG3R()
	
	Localiza registro na tabela G3R
	
	@author André Brito
	@since 16/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function xBuscaG3R(cXFil,cNumId,cFornec,cLoja,cProduto, oProcess)

	Local aArea		:= GetArea()
	Local lRet      := .F.
	Local cQuery    := ""
	Local cAliAux   := GetNextAlias()
	Local nTotal    := 0
	Local nAtual    := 0
	
	cQuery := "SELECT R_E_C_N_O_, * FROM "
	cQuery += RetSqlName("G3R") + " G3R "
	cQuery += " WHERE "
	cQuery += " G3R_FILIAL = '" + cXFil + "'"
	cQuery += " AND G3R_NUMID = '" + cNumId + "'"
	cQuery += " AND G3R_CONINU = ' ' "
	cQuery += " AND G3R_FORNEC = '" + cFornec + "'"
	cQuery += " AND G3R_LOJA = '" + cLoja + "'"
	cQuery += " AND G3R_PROD = '" + cProduto + "'"
	cQuery += " AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)
	
	Count To nTotal
	
	oProcess:SetRegua2(nTotal)
	
	(cAliAux)->(DbGoTop())
	
	//G3R_FILIAL+G3R_NUMID+G3R_CONINU+G3R_FORNEC+G3R_LOJA+G3R_PROD
	
	Do While (cAliAux)->(!Eof())
		
		nAtual++
		
		oProcess:IncRegua2("Processando registro G48. Aguarde...")// + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
	
		lRet := U_xBuscaG48((cAliAux)->G3R_FILIAL, (cAliAux)->G3R_NUMID, (cAliAux)->G3R_CONINU, (cAliAux)->G3R_FORNEC, (cAliAux)->G3R_LOJA, (cAliAux)->G3R_PROD, (cAliAux)->G3R_IDITEM, (cAliAux)->G3R_NUMSEQ, (cAliAux)->G3R_EMISS )
	
		(cAliAux)->(DbSkip())
		
		
	EndDo
	
	(cAliAux)->(dbCloseArea())

	RestArea(aArea)
	
Return lRet

//--------------------------------------------------
	/*/{Protheus.doc} xBuscaG48()
	
	Localiza registro na tabela G48
	
	@author André Brito
	@since 16/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function xBuscaG48(cXFil, cNumId, cConinu, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao)

	Local aArea		:= GetArea()
	
	DbSelectArea("G48")
	DbSetOrder(8)
	
	If !G48->(DBSeek( cXFil + cNumId + cItem + cSeq + Space(TamSX3("G3R_CONINU")[1]) + cProd )) 

			U_xGrvG48(cXFil, cNumId, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao, Soma1(G48->G48_APLICA),G48->G48_CLIFOR)

			U_xGrvProcSZ1(cXFil, cNumId, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao)

		
	ElseIf G48_CLIFOR = "1" //Se for cliente  
		
		U_xGrvG48(cXFil, cNumId, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao, Soma1(G48->G48_APLICA), G48->G48_CLIFOR)

		U_xGrvProcSZ1(cXFil, cNumId, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao)

	Else
		U_xGrvSZ1(cXFil, cNumId, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao)
	EndIf

	RestArea(aArea)
	
Return .T.

//--------------------------------------------------
	/*/{Protheus.doc} xGrvSZ1()
	
	Grava status na tabela SZ1
	
	@author André Brito
	@since 16/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function xGrvSZ1(cXFil, cNumId, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao)

	Local aArea		:= GetArea()
	
	DbSelectArea("SZ1")
	DbSetOrder(1)

	AADD(aAcorRv, { cXFil, cNumId, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao })
	
	If SZ1->(DBSeek( cXFil + cNumId + cCodFor + cLoja + cProd ))
	
		RecLock( "SZ1", .F. )
					
		/*Caso seja encontrado algum Acordo na G48 para a chave de RV, este deve ser ignorado, ou seja, 
		não deve ser gravado o Acordo de Cancelamento de Fornecedor, 
		o campo SZ?_STATUS deve ser atualizado com “4=JÁ EXISTE ACORDO PARA ESTE RV*/
		
		SZ1->Z1_STATUS  := "4"
			
		MsUnLock()
	
	EndIf

	RestArea(aArea)
	
Return

//--------------------------------------------------
	/*/{Protheus.doc} xGrvG48()
	
	Grava tabela G48 caso não encontre acordo
	
	@author André Brito
	@since 16/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function xGrvG48(cXFil, cNumId, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao, cSoma, cCliFor)

	Local aArea		:= GetArea()
	Local cAplica   := U_xNumApli(cXFil, cNumId, cCodFor, cItem, cSeq, cCliFor)

	DbSelectArea("G48")
	DbSetOrder(8)
	
	Begin Transaction
	
   If !G48->(DBSeek( cXFil + cNumId + cItem + cSeq + Space(TamSX3("G3R_CONINU")[1]) + cProd )) 
   		
		
		RecLock( "G48", .T. )
					
		G48->G48_FILIAL   := cXFil
		G48->G48_NUMID	  := cNumId
		G48->G48_IDITEM   := cItem
		G48->G48_NUMSEQ	  := cSeq
		G48->G48_APLICA	  := cAplica
		G48->G48_CODACD	  := "000280"
		G48->G48_CODREC	  := "00"
		G48->G48_CLIFOR	  := "2"
		G48->G48_DESCR	  := "TARIFA NET VALIDADA"
		G48->G48_NIVEL	  := "03"
		G48->G48_TPVLR	  := "2"
		G48->G48_TPACD	  := "1"
		G48->G48_CLASS	  := "F01"
		G48->G48_CODPRD	  := "000000000000448"
		G48->G48_MOEDA	  := "01"
		G48->G48_STATUS	  := "3"
		G48->G48_COMSER	  := "2"
		G48->G48_INTERV	  := "1"
		G48->G48_MOTINT	  := "10"
		G48->G48_DTINT	  := Stod(dEmissao)
		G48->G48_USUINT	  := "001467"
		G48->G48_NOMUSU	  := "VIC.BOT"
		G48->G48_ESTORN	  := "2"
		G48->G48_OPERA	  := "1"
		G48->G48_DTINCL	  := Stod(dEmissao)
		G48->G48_SEGNEG	  := "1"
		G48->G48_CANSIS	  := "2"
		G48->G48_FILREF	  := cXFil
		G48->G48_NATURE	  := "100101"
		G48->G48_CANFOP	  := "2"
		G48->G48_CANCON	  := "2"
	Else
	
		xGrvSZ1(cXFil, cNumId, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao)
		        
		/*cSeq := xNumSeq(cXFil, cNumId, cCodFor, cItem, cSeq, cCliFor)
		
		RecLock( "G48", .T. )
					
		G48->G48_FILIAL   := cXFil
		G48->G48_NUMID	  := cNumId
		G48->G48_IDITEM   := cItem
		//If G48->G48_CLIFOR	== "2"
		G48->G48_NUMSEQ	  := Soma1(cSeq)
		//Else
			//G48->G48_NUMSEQ	  := cSeq
		//EndIf
		G48->G48_APLICA	  := cAplica
		G48->G48_CODACD	  := "000280"
		G48->G48_CODREC	  := "00"
		G48->G48_CLIFOR	  := "2"
		G48->G48_DESCR	  := "TARIFA NET VALIDADA"
		G48->G48_NIVEL	  := "03"
		G48->G48_TPVLR	  := "2"
		G48->G48_TPACD	  := "1"
		G48->G48_CLASS	  := "F01"
		G48->G48_CODPRD	  := "000000000000448"
		G48->G48_MOEDA	  := "01"
		G48->G48_STATUS	  := "3"
		G48->G48_COMSER	  := "2"
		G48->G48_INTERV	  := "1"
		G48->G48_MOTINT	  := "10"
		G48->G48_DTINT	  := Stod(dEmissao)
		G48->G48_USUINT	  := "001467"
		G48->G48_NOMUSU	  := "VIC.BOT"
		G48->G48_ESTORN	  := "2"
		G48->G48_OPERA	  := "1"
		G48->G48_DTINCL	  := Stod(dEmissao)
		G48->G48_SEGNEG	  := "1"
		G48->G48_CANSIS	  := "2"
		G48->G48_FILREF	  := cXFil
		G48->G48_NATURE	  := "100101"
		G48->G48_CANFOP	  := "2"
		G48->G48_CANCON	  := "2"*/
	
	EndIf
		
	MsUnLock()

	End Transaction

	RestArea(aArea)
	
Return

//--------------------------------------------------
	/*/{Protheus.doc} xGrvProcSZ1()
	
	Grava Status de registro processado
	
	@author André Brito
	@since 16/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function xGrvProcSZ1(cXFil, cNumId, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao)

	Local aArea		:= GetArea()
	
	DbSelectArea("SZ1")
	DbSetOrder(1)
	
	If SZ1->(DBSeek( cXFil + cNumId + cCodFor + cLoja + cProd ))
	
		AADD(aProc, { cXFil, cNumId, cCodFor, cLoja, cProd, cItem, cSeq, dEmissao })
	
		RecLock( "SZ1", .F. )
		
		SZ1->Z1_STATUS  := "2"
			
		MsUnLock()
	
	EndIf

	RestArea(aArea)
	
Return


//--------------------------------------------------
	/*/{Protheus.doc} xGrvProcSZ1()
	
	Visualiza RV de acordo com o item posicionado na tabela SZ1
	
	@author André Brito
	@since 16/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function xVilRv()

Local aArea     := GetArea()

U_TURXVIEW(SZ1->Z1_FILIAL, SZ1->Z1_NUMID)

RestArea(aArea)
	
Return

User Function xNumApli(cXFil, cNumId, cCodFor, cItem, cSeq, cCliFor)

Local aArea      := GetArea()
Local cG3QFilial := cXFil
Local cG3QNumId  := cNumId
Local cG3QIdItem := cItem
Local cG3QNumSeq := cSeq
Local nRet       := 0
Local cAliasG48  := GetNextAlias()
Local nAplica    := 1
Local cQuery     := ""
Local nCont      := 0	

cQuery := "SELECT G48_APLICA, R_E_C_N_O_, * FROM "
cQuery += RetSqlName("G48") + " G48 "
cQuery += " WHERE "
cQuery += " G48_FILIAL = ' " + cG3QFilial + "'" 
cQuery += " AND G48_NUMID = ' " + cG3QNumId + "'" 
cQuery += " AND G48_IDITEM = ' " + cG3QIdItem + "'" 
cQuery += " AND G48_CLIFOR = '2'" 
//cQuery += " AND G48_NUMSEQ = ' " + cG3QNumSeq + "'" 
//cQuery += " AND G48_APLICA = ' " + StrZero(nAplica, TamSx3("G48_APLICA")[1]) + "'" 
cQuery += " AND G48_CONINU = '' "
//cQuery += " AND G48_CLIFOR = ' " + cCliFor + "'" 
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasG48,.T.,.T.)	

(cAliasG48)->(DbGoTop())

Do While (cAliasG48)->(!Eof())

	nCont ++
	nRet := Val((cAliasG48)->G48_APLICA)

(cAliasG48)->(DbSkip())

EndDo

(cAliasG48)->(DbCloseArea())

nRet := StrZero(nRet, TamSx3("G48_APLICA")[1])

If nCont == 0
	nRet := "001"
EndIf

RestArea(aArea)

Return nRet

Static Function xNumSeq(cXFil, cNumId, cCodFor, cItem, cSeq, cCliFor)

Local aArea      := GetArea()
Local cAliasG48  := GetNextAlias()
Local cQuery     := ""
Local cSeq       := 0	

cQuery := "SELECT MAX(G48_NUMSEQ) SEQ FROM "
cQuery += RetSqlName("G48") + " G48 "
cQuery += "WHERE G48_NUMID = '" + cNumId + "' AND G48_CLIFOR = '2'"
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasG48,.T.,.T.)	

cSeq :=(cAliasG48)->SEQ

(cAliasG48)->(DbCloseArea())

RestArea(aArea)

Return cSeq

User Function RelRvs()

Local aPWiz      := {}
Local aRetWiz    := {}
Local lRet       := .T.
Local dDtDe       
Local dDtAte   


aAdd(aPWiz,{ 1,"Data de: "               ,Ctod("") ,"","",""   ,  ,60 ,.F.})
aAdd(aPWiz,{ 1,"Data ate: "              ,Ctod("") ,"","",""   ,  ,60,.F.})

aAdd(aRetWiz,Ctod(""))
aAdd(aRetWiz,Ctod(""))

lRet := ParamBox(aPWiz,"Relatorio RV's'",@aRetWiz,,,,,,) 

If lRet
	dDtDe   := aRetWiz[1] 
	dDtAte  := aRetWiz[2]
	
	RptStatus({|| U_ProcRelRvs(dDtDe, dDtAte) }, "Aguarde...", "Extraindo RV's, aguarde...")
EndIf

Return

User Function ProcRelRvs(dDtDe, dDtAte) 

Local aArea      := GetArea()
Local cAliasRel  := GetNextAlias()
Local cQuery     := ""
Local aCampos    := {}
Local cPath      := "C:\temp"
Local cAba       := ""
Local cTabela    := ""
Local cArquivo   := "RV.XLS"
Local nTotal     := 0
Local nAtual     := 0
Local oExcel
Local oExcelApp
Local _oPlan

aColunas := {}
aLocais  := {} 
oBrush1  := TBrush():New(, RGB(193,205,205))

If !ApOleClient('MsExcel')
    MsgAlert("Falha ao abrir Excel!")
EndIf

oExcel  := FWMSExcel():New()
cAba    := "RV's Processados"
cTabela := "RV's Processados - ALATUR"

// Criação de nova aba 
oExcel:AddworkSheet(cAba)

// Criação de tabela
oExcel:AddTable (cAba,cTabela)

// Criação de colunas 
oExcel:AddColumn(cAba,cTabela,"FILIAL"        	,1,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"RV"          	,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"COD.FORNECEDOR"  ,2,1,.F.)
oExcel:AddColumn(cAba,cTabela,"DESC.FORNECEDOR" ,3,2,.F.)  
oExcel:AddColumn(cAba,cTabela,"LOJA"     	    ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"PRODUTO"   	    ,3,2,.F.)
oExcel:AddColumn(cAba,cTabela,"DESC. PRODUTO"   ,3,2,.F.)  
oExcel:AddColumn(cAba,cTabela,"MOTINT"          ,3,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"DATA"            ,3,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"STATUS"    	    ,3,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"NUMERO ID"       ,2,1,.F.)
oExcel:AddColumn(cAba,cTabela,"PROCESSAMENTO"   ,3,2,.F.) 

cQuery := "SELECT * FROM "
cQuery += RetSqlName("SZ1") + " SZ1 "
cQuery += " WHERE Z1_DATA   >= '" + Dtos(dDtDe)  + "' AND Z1_DATA <= '" + Dtos(dDtAte) + "' " 
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRel,.T.,.T.)	

Count To nTotal
SetRegua(nTotal)

(cAliasRel)->(DbGoTop())

Do While !(cAliasRel)->(Eof())

		nAtual++
        IncRegua()

	   oExcel:AddRow(cAba,cTabela, { (cAliasRel)->Z1_FILIAL ,;
	  (cAliasRel)->Z1_RV        ,; 
	  (cAliasRel)->Z1_CODFOR    ,; 
	  ForRv((cAliasRel)->Z1_CODFOR, (cAliasRel)->Z1_LOJA )    ,; 
	  (cAliasRel)->Z1_LOJA      ,;
	  (cAliasRel)->Z1_PRODUTO   ,;
	  RvProd((cAliasRel)->Z1_PRODUTO)   ,;
	  (cAliasRel)->Z1_MOTINT    ,;
	  Stod((cAliasRel)->Z1_DATA),;
	  VerStatus((cAliasRel)->Z1_STATUS)    ,;
	  (cAliasRel)->Z1_NUMID     ,;
	  (cAliasRel)->Z1_PROC })
	
	(cAliasRel)->(dbskip())
Enddo

If !Empty(oExcel:aWorkSheet)

    oExcel:Activate()
    oExcel:GetXMLFile(cArquivo)
 
    CpyS2T("\SYSTEM\"+cArquivo, cPath)

    oExcelApp := MsExcel():New()
    oExcelApp:WorkBooks:Open(cPath + "\" + cArquivo) // Abre a planilha
	oExcelApp:SetVisible(.T.)
	
EndIf

(cAliasRel)->(DbCloseArea())

RestArea(aArea)

Return 

Static Function VerStatus(cStatus)

Local cTexto := ""

If  Alltrim(cStatus) == "1"
	cTexto := "Não processado"
ElseIf Alltrim(cStatus) == "2"
	cTexto := "Processado"
ElseIf Alltrim(cStatus) == "3"
	cTexto := "RV não localizado na G3R"
ElseIf Alltrim(cStatus) == "4"
	cTexto := "Já existe acordo p/ este RV"
EndIf

Return cTexto

Static Function ForRv(cCod,cLoja)

Local aArea     := GetArea() 
Local cNome     := ""

DbSelectArea("SA2")
DbSetOrder(1)
If DbSeek(xFilial("SA2") + cCod + cLoja)
	cNome := Alltrim(SA2->A2_NOME)
Else
	cNome := "Fornecedor inexistente na base de dados!"
EndIf

RestArea( aArea )

Return cNome

Static Function RvProd(cCod)

Local aArea     := GetArea() 
Local cNome     := ""

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1") + cCod )
	cNome := Alltrim(SB1->B1_DESC)
Else
	cNome := "Fornecedor inexistente na base de dados!"
EndIf

RestArea( aArea )

Return Alltrim(cNome)


//--------------------------------------------------
	/*/{Protheus.doc} xTurExc()
	
	Exclusão de registros processados via planilha
	
	@author André Brito
	@since 16/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function xTurExc()

Local aArea		:= GetArea()
Local lRet      := .T.
Local aPWiz     := {}
Local aRetWiz   := {}
Local cRv       := ""
Local dDtDe      
Local dDtAte 
	
aAdd(aPWiz,{ 2,"Excluir RV's:'"  ,"Todos",{"(1) Não Processado", "(2) Processado","(3) Não Localizado","(4) Já Existente","(*) Todos" },75,"",.T.})
aAdd(aPWiz,{ 1,"Data de: "               ,Ctod("") ,"","",""   ,  ,60 ,.T.})
aAdd(aPWiz,{ 1,"Data ate: "              ,Ctod("") ,"","",""   ,  ,60,.T.})

lRet := ParamBox(aPWiz,"Consulta Estoque por Produto",@aRetWiz,,,,,,,,.T.,.T.)

If lRet
	
	If aRetWiz[1] == "(1) Não Processado"
		cRv := "1"
	ElseIf aRetWiz[1] == "(2) Processado"
		cRv := "2"
	ElseIf aRetWiz[1] == "(3) Não Localizado"
		cRv := "3"
	ElseIf aRetWiz[1] == "(4) Já Existente"
		cRv := "4"
	Else
		cRv := "5"
	EndIf
	
	dDtDe  := aRetWiz[2] 
	dDtAte := aRetWiz[3]
	
	RptStatus({|| ProcDel(cRv, dDtDe, dDtAte) }, "Aguarde...", "Excluindo suas RV's, aguarde...")
Else
	Return
EndIf

Return

Static Function ProcDel(cRv, dDtDe, dDtAte)

Local cQuery    := ""
Local cAliAux   := GetNextAlias()
Local nRecno    := 0
Local nRegExc   := 0
Local HoraIni   := Time() 
Local HoraFim 
Local cElapsed  := ""

cQuery := "SELECT R_E_C_N_O_, * FROM "
cQuery += RetSqlName("SZ1") + " SZ1 "
cQuery += " WHERE Z1_DATA   >= '" + Dtos(dDtDe)  + "' AND Z1_DATA <= '" + Dtos(dDtAte) + "' " 

If cRv != "5"
	cQuery += " AND Z1_STATUS = '" + cRv + "'"
EndIf

cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)
	
	
Do While (cAliAux)->(!Eof())

	nRecno := (cAliAux)->R_E_C_N_O_
		
	SZ1->(DbGoto(nRecno))
	
	nRegExc += 1
	
	RecLock("SZ1",.F.,.T.)
		DbDelete()
	MsUnLock()
	
	(cAliAux)->(DbSkip())
	
EndDo

(cAliAux)->(dbCloseArea())

HoraFim  := Time() 
	
cElapsed := ElapTime( HoraIni, HoraFim )

MsgInfo("Exclusão de " + Alltrim(Str(nRegExc)) + " registros efetudas com sucesso em "+ cElapsed )
	
Return
