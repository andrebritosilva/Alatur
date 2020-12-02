#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

User Function REL()     

Local aPWiz     := {}
Local aRetWiz   := {}
Local cFilDe    := ""
Local cFilAte   := "" 
Local cConDe    := "" 
Local dDtDe     := CTOD("//")
Local dDtAte    := CTOD("//")
Local cConci    := 0
Local cHist     := ""
           
Private lInverte  := .F. 
Private cMark     := GetMark()    
Private oMark 
Private oProcess
Private nCont     := 0
Private lVinOk    := .F.
Private cVlrSal   := ""
Private oProcExc

aAdd(aPWiz,{ 1,"Filial de: "             ,Space(TamSX3("CT2_FILIAL")[1]),"","","SM0","",9   ,.F.})
aAdd(aPWiz,{ 1,"Filial ate: "            ,Space(TamSX3("CT2_FILIAL")[1]) ,"","","SM0","",9   ,.F.})
aAdd(aPWiz,{ 1,"Cta. Contabil: "         ,Space(TamSX3("CT2_DEBITO")[1]) ,"","","CT1","",    ,.F.})
aAdd(aPWiz,{ 1,"Data de: "               ,Ctod("") ,"","",""   ,  ,60 ,.F.})
aAdd(aPWiz,{ 1,"Data ate: "              ,Ctod("") ,"","",""   ,  ,60,.F.})
aAdd(aPWiz,{ 2,"Trazer Conciliados: "    ,1,{"Não Conciliados", "Conciliados","Ambos"},60,""     ,.F.}) 
aAdd(aPWiz,{ 1,"Contem no Hist.: "       ,Space(60)   ,"","",""   ,"",    ,.F.})

aAdd(aRetWiz,Space(TamSX3("CT2_FILIAL")[1]))
aAdd(aRetWiz,Space(TamSX3("CT2_FILIAL")[1]))
aAdd(aRetWiz,Space(TamSX3("CT2_DEBITO")[1]))
aAdd(aRetWiz,Ctod(""))
aAdd(aRetWiz,Ctod(""))
aAdd(aRetWiz,Space(40))
aAdd(aRetWiz,Space(20))

ParamBox(aPWiz,"****Relatório Conciliação Contábil - ALATUR JTB *****",@aRetWiz,,,,,,) 

cFilDe  := Alltrim(aRetWiz[1])
cFilAte := Alltrim(aRetWiz[2]) 
cConDe  := Alltrim(aRetWiz[3]) 
dDtDe   := aRetWiz[4] 
dDtAte  := aRetWiz[5] 
cConci  := aRetWiz[6] 
cHist   := Alltrim(aRetWiz[7])

oProcess := MsNewProcess():New( { || XProcRel(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cConci, cHist) } , "Carregando tabela temporária" , "Aguarde..." , .F. )
oProcess:Activate()

//-------------------------------------------------------------------

Function XProcRel(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cConci, cHist)

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
cAba    := "Lançamentos Conciliados"
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

If Valtype(cConci) == "N"
	cConci := "Não conciliados"
EndIf

If cConci == "Não conciliados" //Não conciliados
	cQuery += " AND (CT2_XFLDEB != '" + cConDe + "' AND CT2_XFLCRE != '" + cConDe + "')"
EndIf

If cConci == "Conciliados" //Conciliados
	cQuery += " AND (CT2_XFLDEB = '" + cConDe + "' OR CT2_XFLCRE = '" + cConDe + "')"
EndIf
	
cQuery += " AND D_E_L_E_T_ = ' ' ORDER BY CT2_DATA"

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

//oProcExc:SetRegua1( (cAliAux)->(RecCount()) ) //Alimenta a primeira barra de progresso
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
		//oProcExc:IncRegua1("Processando tabela temporária")	
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
 	//oProcExc:IncRegua2("Gerando a planilha...")	
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
                                  (cArqTrb)->CT2_XIDCRE ,;
                                  (cArqTrb)->CT2_XIDDEB ,;
                                  (cArqTrb)->CT2_XFLCRE ,;
                                  (cArqTrb)->CT2_XFLDEB ,;
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
