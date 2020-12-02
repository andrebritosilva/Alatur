#include "protheus.ch" 
#Include "RWMAKE.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBXCON
Conciliação Manual Alatur

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------
           
User Function ctbxcon()     

Local aPWiz       := {}
Local aRetWiz     := {}
Local cFilDe      := ""
Local cFilAte     := "" 
Local cConDe      := "" 
Local dDtDe       := CTOD("//")
Local dDtAte      := CTOD("//")
Local cConci      := 0
Local cHist       := ""
Local aLoadRes    := Array(6)
           
Private lInverte  := .F. 
Private cMark     := GetMark()    
Private oMark 
Private oProcess
Private nCont     := 0
Private lVinOk    := .F.
Private cVlrSal   := ""
Private cIdLanc   := ""
Private lCarga    := .T.
Private cUltId    := ""
Private cDcTot    := ""
Private cDcVlr    := ""
Private nQtdReg   := 0
Private lConcilia := .F.
Private lFecha    := .F.

aAdd(aPWiz,{ 1,"Filial de: "             ,Space(TamSX3("CT2_FILIAL")[1]),"","","SM0","",9   ,.T.})
aAdd(aPWiz,{ 1,"Filial ate: "            ,Space(TamSX3("CT2_FILIAL")[1]) ,"","","SM0","",9   ,.T.})
aAdd(aPWiz,{ 1,"Cta. Contabil: "         ,Space(TamSX3("CT2_DEBITO")[1]) ,"","","CT1","",    ,.T.})
aAdd(aPWiz,{ 1,"Data de: "               ,Ctod("") ,"","",""   ,  ,60 ,.T.})
aAdd(aPWiz,{ 1,"Data ate: "              ,Ctod("") ,"","",""   ,  ,60,.T.})
aAdd(aPWiz,{ 2,"Trazer Conciliados: "    ,1,{"Não Conciliados", "Conciliados","Ambos"},60,""     ,.F.}) 
aAdd(aPWiz,{ 1,"Historico(01):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(02):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(03):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(04):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(05):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(06):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(07):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(08):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(09):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(10):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(11):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(12):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(13):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(14):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(15):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(16):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(17):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(18):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(19):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(20):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(21):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(22):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(23):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(24):"          ,Space(250)   ,"","",""   ,"",    ,.F.})
aAdd(aPWiz,{ 1,"Historico(25):"          ,Space(250)   ,"","",""   ,"",    ,.F.})

/*If aLoadRes[1] == nil 
	For nCont := 1 to Len(aLoadRes) 
		If nCont > 6
			Exit
		EndIf
		aLoadRes[nCont] := xAload('respala',aPWiz,nCont)
	Next
EndIf

aRetWiz := { If (Empty(aLoadRes[1]) ,Space(TamSX3("CT2_FILIAL")[1]),aLoadRes[1]),;
			 If (Empty(aLoadRes[2])  ,Space(TamSX3("CT2_FILIAL")[1]),aLoadRes[2]),;
			 If (Empty(aLoadRes[3])  ,Space(TamSX3("CT2_DEBITO")[1]),aLoadRes[3]),;
			 If (Empty(aLoadRes[4])  ,Ctod("")                      ,aLoadRes[4]),;
			 If (Empty(aLoadRes[5])  ,Ctod("")                      ,aLoadRes[5])}*/

aAdd(aRetWiz,Space(TamSX3("CT2_FILIAL")[1]))
aAdd(aRetWiz,Space(TamSX3("CT2_FILIAL")[1]))
aAdd(aRetWiz,Space(TamSX3("CT2_DEBITO")[1]))
aAdd(aRetWiz,Ctod(""))
aAdd(aRetWiz,Ctod(""))
aAdd(aRetWiz,Space(40))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))
aAdd(aRetWiz,Space(20))

ParamBox(aPWiz,"*** Conciliação Manual Contábil - ALATUR JTB ***",aRetWiz,,,,2000,5000,,,.T.,.T.) 

cFilDe   := Alltrim(aRetWiz[1])
cFilAte  := Alltrim(aRetWiz[2]) 
cConDe   := Alltrim(aRetWiz[3]) 
dDtDe    := aRetWiz[4] 
dDtAte   := aRetWiz[5] 
cConci   := aRetWiz[6] 
cHist1   := Alltrim(aRetWiz[7])
cHist2   := Alltrim(aRetWiz[8])
cHist3   := Alltrim(aRetWiz[9])
cHist4   := Alltrim(aRetWiz[10])
cHist5   := Alltrim(aRetWiz[11])
cHist6   := Alltrim(aRetWiz[12])
cHist7   := Alltrim(aRetWiz[13])
cHist8   := Alltrim(aRetWiz[14])
cHist9   := Alltrim(aRetWiz[15])
cHista   := Alltrim(aRetWiz[16])
cHistb   := Alltrim(aRetWiz[17])
cHistc   := Alltrim(aRetWiz[18])
cHistd   := Alltrim(aRetWiz[19])
cHiste   := Alltrim(aRetWiz[20])
cHistf   := Alltrim(aRetWiz[21])
cHistg   := Alltrim(aRetWiz[22])
cHisth   := Alltrim(aRetWiz[23])
cHisti   := Alltrim(aRetWiz[24])
cHistj   := Alltrim(aRetWiz[25])
cHistk   := Alltrim(aRetWiz[26])
cHistl   := Alltrim(aRetWiz[27])
cHistm   := Alltrim(aRetWiz[28])
cHistn   := Alltrim(aRetWiz[29])
cHisto   := Alltrim(aRetWiz[30])
cHistp   := Alltrim(aRetWiz[31])

//xAlSave('RespAla',aRetWiz,"")

oProcess := MsNewProcess():New( { || XProcMan(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cConci, cHist1, cHist2, cHist3, cHist4, cHist5, cHist6, cHist7, cHist8, cHist9, cHista, cHistb, cHistc, cHistd, cHiste, cHistf, cHistg, cHisth, cHisti, cHistj, cHistk, cHistl, cHistm, cHistn, cHisto, cHistp) } , "Carregando tabela temporária" , "Aguarde..." , .F. )
oProcess:Activate()

//-------------------------------------------------------------------
/*/{Protheus.doc} XProcMan
Montagem de tabela temporária de acordo com os parametros informados,
usando o MSSelect.

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function XProcMan(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cConci, cHist1, cHist2, cHist3, cHist4, cHist5, cHist6, cHist7, cHist8, cHist9, cHista, cHistb, cHistc, cHistd, cHiste, cHistf, cHistg, cHisth, cHisti, cHistj, cHistk, cHistl, cHistm, cHistn, cHisto, cHistp)
 
Local aCpoBro     := {} 
Local oDlgLocal 
Local aCores      := {}
Local aSize       := {} 
Local oPanel 
Local oSay1	 
Local cArqTrb     := GetNextAlias()
Local cAliAux     := GetNextAlias()
Local oConta
Local cPictCta    := PesqPict("CT2","CT2_DEBITO")
Local cPictVlr    := PesqPict("CT2","CT2_VALOR")
Local aCampos     := {}
Local cQuery      := ""
Local _oConMan
Local oCheck1 
Local lCheck      := .F.
Local oChk
Local cTeste      := "D"

Private oTotDeb
Private oTotCre
Private oTotSal
Private nTotDeb   := 0
Private nTotCre   := 0
Private nTotSal   := 0
Private cConta    := ""
Private oVlrDeb
Private oVlrCre
Private oVlrSal
Private nVlrDeb   := 0 
Private nVlrCre   := 0
Private nVlrSal   := 0
Private cVlrSal   := "0"
Private cTotSal   := ""
Private oVlrDc  

cConta  := cConDe
MsgRun("Calculando movimentos a debito...","Aguarde...",{|| nTotDeb := xMovDeb(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cConci)})
MsgRun("Calculando movimentos a credito...","Aguarde...",{|| nTotCre := xMovCre(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cConci)})
nTotSal := (nTotDeb - nTotCre)

If nTotSal < 0

	nTotSal := ABS(nTotSal)
	cTotSal := STR(nVlrSal) + " C"
	cDCTot  := "Cre."
	
ElseIf nTotSal > 0

	cTotSal := STR(nTotSal) + " D" 
	cDCTot  := "Deb."
	
ElseIf nTotSal == 0

	cTotSal := STR(nTotSal)
	//cVlrSal := Alltrim(cVlrSal)
EndIf

cDCVlr := " "

AADD(aCampos,{"CT2_XOK"      ,"C",TamSX3("CT2_XOK")[1],0})
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
AADD(aCampos,{"CT2_RECNO"    ,"N",20,0})
AADD(aCampos,{"CT2_XSTAT"    ,"C",TamSX3("CT2_XSTAT")[1],0})

cQuery := "SELECT R_E_C_N_O_, * FROM "
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += " WHERE "
cQuery += " CT2_FILIAL   Between '" + cFilDe    + "' AND '" + cFilAte  + "' " 
cQuery += " AND ((CT2_CREDIT = '" + cConDe + "' OR CT2_DEBITO = '" + cConDe + "'))"
//cQuery += " OR ( CT2_DEBITO BETWEEN '" + cConDe + "' AND '" + cConDe + "')) "
cQuery += " AND CT2_DATA   >= '" + Dtos(dDtDe)  + "' AND CT2_DATA <= '" + Dtos(dDtAte) + "' " 

If Valtype(cConci) == "N"
	cConci := "Não conciliados"
EndIf

/*If cConci == "Não conciliados" //Não conciliados
	cQuery += " AND (CT2_XFLDEB = ' ' AND CT2_XFLCRE = ' ') "
EndIf*/

If cConci == "Não conciliados" //Não conciliados
	cQuery += " AND (CT2_XFLDEB != '" + cConDe + " ' AND CT2_XFLCRE != '" + cConDe + "' )"
	//cQuery += "  OR (CT2_XFLCRE != '" + cConDe + " ' AND CT2_XFLDEB = '" + cConDe + "' ))"
EndIf

/*If cConci == "Conciliados" //Conciliados
	cQuery += " AND (CT2_XFLDEB != ' ' OR CT2_XFLCRE != ' ') "
EndIf*/
If cConci == "Conciliados" //Conciliados
	cQuery += " AND (CT2_XFLDEB = '" + cConDe + "' OR CT2_XFLCRE = '" + cConDe + "') "
EndIf

If !Empty(Alltrim(cHist1))
	cQuery += "AND ( CT2_HIST LIKE '%" + cHist1 + "%'"
	
	If !Empty(Alltrim(cHist2))
		cQuery += "OR CT2_HIST LIKE '%" + cHist2 + "%'"
	EndIf
	If !Empty(Alltrim(cHist3))
		cQuery += "OR CT2_HIST LIKE '%" + cHist3+ "%'"
	EndIf
	If !Empty(Alltrim(cHist4))
		cQuery += "OR CT2_HIST LIKE '%" + cHist4 + "%'"
	EndIf
	If !Empty(Alltrim(cHist5))
		cQuery += "OR CT2_HIST LIKE '%" + cHist5 + "%'"
	EndIf
	If !Empty(Alltrim(cHist6))
		cQuery += "OR CT2_HIST LIKE '%" + cHist6 + "%'"
	EndIf
	If !Empty(Alltrim(cHist7))
		cQuery += "OR CT2_HIST LIKE '%" + cHist7 + "%'"
	EndIf
	If !Empty(Alltrim(cHist8))
		cQuery += "OR CT2_HIST LIKE '%" + cHist8 + "%'"
	EndIf
	If !Empty(Alltrim(cHist9))
		cQuery += "OR CT2_HIST LIKE '%" + cHist9 + "%'"
	EndIf
	If !Empty(Alltrim(cHista))
		cQuery += "OR CT2_HIST LIKE '%" + cHista + "%'"
	EndIf
	If !Empty(Alltrim(cHistb))
		cQuery += "OR CT2_HIST LIKE '%" + cHistb + "%'"
	EndIf
	If !Empty(Alltrim(cHistc))
		cQuery += "OR CT2_HIST LIKE '%" + cHistc + "%'"
	EndIf
	If !Empty(Alltrim(cHistd))
		cQuery += "OR CT2_HIST LIKE '%" + cHistd + "%'"
	EndIf
	If !Empty(Alltrim(cHiste))
		cQuery += "OR CT2_HIST LIKE '%" + cHiste + "%'"
	EndIf
	If !Empty(Alltrim(cHistf))
		cQuery += "OR CT2_HIST LIKE '%" + cHistf + "%'"
	EndIf
	If !Empty(Alltrim(cHistg))
		cQuery += "OR CT2_HIST LIKE '%" + cHistg + "%'"
	EndIf
	If !Empty(Alltrim(cHisth))
		cQuery += "OR CT2_HIST LIKE '%" + cHisth + "%'"
	EndIf
	If !Empty(Alltrim(cHisti))
		cQuery += "OR CT2_HIST LIKE '%" + cHisti + "%'"
	EndIf
	If !Empty(Alltrim(cHistj))
		cQuery += "OR CT2_HIST LIKE '%" + cHistj + "%'"
	EndIf
	If !Empty(Alltrim(cHistk))
		cQuery += "OR CT2_HIST LIKE '%" + cHistk + "%'"
	EndIf
	If !Empty(Alltrim(cHistl))
		cQuery += "OR CT2_HIST LIKE '%" + cHistl + "%'"
	EndIf
	If !Empty(Alltrim(cHistm))
		cQuery += "OR CT2_HIST LIKE '%" + cHistm + "%'"
	EndIf
	If !Empty(Alltrim(cHistn))
		cQuery += "OR CT2_HIST LIKE '%" + cHistn + "%'"
	EndIf
	If !Empty(Alltrim(cHisto))
		cQuery += "OR CT2_HIST LIKE '%" + cHisto + "%'"
	EndIf
	If !Empty(Alltrim(cHistp))
		cQuery += "OR CT2_HIST LIKE '%" + cHistp + "%'"
	EndIf
	cQuery += ")"
EndIf


/*If !Empty(Alltrim(cHist))
	cHist := Alltrim(cHist)
	cHist := StrTran( cHist, ";", "%' OR CT2_HIST LIKE '%" )
	cHist := StrTran( cHist, "(", " AND CT2_HIST LIKE '%" )
	cHist := StrTran( cHist, ")", "%'" )
	cQuery += cHist
EndIf*/

cQuery += " AND D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

If _oConMan <> Nil
	_oConMan:Delete() 
	_oConMan := Nil
EndIf

// Criando o objeto do arquivo temporário
_oConMan := FwTemporaryTable():New("cArqTrb")

// Criando a estrutura do objeto  
_oConMan:SetFields(aCampos)

// Criando o indice da tabela
_oConMan:AddIndex("1",{"CT2_XNUMDO"})

_oConMan:Create()

(cAliAux)->(dbGoTop())

Do While (cAliAux)->(!Eof())
	
	RecLock("cArqTrb",.T.)
	
	nQtdReg ++ 
	
	cArqTrb->CT2_XOK       := (cAliAux)->CT2_XOK
	cArqTrb->CT2_FILIAL    := (cAliAux)->CT2_FILIAL
	cArqTrb->CT2_DATA      := STOD((cAliAux)->CT2_DATA)
	cArqTrb->CT2_LOTE      := (cAliAux)->CT2_LOTE
	cArqTrb->CT2_SBLOTE    := (cAliAux)->CT2_SBLOTE
	cArqTrb->CT2_DOC       := (cAliAux)->CT2_DOC
	cArqTrb->CT2_XNUMDO    := (cAliAux)->CT2_XNUMDO
	cArqTrb->CT2_TPSALD    := (cAliAux)->CT2_TPSALD
	cArqTrb->CT2_DC        := (cAliAux)->CT2_DC
	cArqTrb->CT2_DEBITO    := (cAliAux)->CT2_DEBITO
	cArqTrb->CT2_CREDIT    := (cAliAux)->CT2_CREDIT
	cArqTrb->CT2_VALOR     := (cAliAux)->CT2_VALOR
	cArqTrb->CT2_HIST      := Alltrim((cAliAux)->CT2_HIST)
	cArqTrb->CT2_ORIGEM    := Alltrim((cAliAux)->CT2_ORIGEM)
	cArqTrb->CT2_XIDCRE    := (cAliAux)->CT2_XIDCRE
	cArqTrb->CT2_XIDDEB    := (cAliAux)->CT2_XIDDEB
	cArqTrb->CT2_XTPCRE    := (cAliAux)->CT2_XTPCRE
	cArqTrb->CT2_XTPDEB    := (cAliAux)->CT2_XTPDEB
	cArqTrb->CT2_XSTAT     := (cAliAux)->CT2_XSTAT
	cArqTrb->CT2_RECNO     := (cAliAux)->R_E_C_N_O_
	
	MsUnLock()
	
	(cAliAux)->(DbSkip())
		
EndDo

DbGoTop() 


aCpoBro     := {{ "CT2_XOK"      ,, "Marcacao"         ,"@!"},;                
               {  "CT2_FILIAL"   ,, "Filial"           ,PesqPict("CT2","CT2_FILIAL")},;              
               {  "CT2_DATA"     ,, "Data"             ,PesqPict("CT2","CT2_DATA")},;
               {  "CT2_DEBITO"   ,, "Conta Deb."       ,PesqPict("CT2","CT2_DEBITO")},;
               {  "CT2_CREDIT"   ,, "Conta Cre."       ,PesqPict("CT2","CT2_CREDIT")},;
               {  "CT2_VALOR"    ,, "Valor"            ,PesqPict("CT2","CT2_VALOR")},; 
               {  "CT2_XNUMDO"   ,, "Num. Documento"   ,PesqPict("CT2","CT2_XNUMDO")},;
               {  "CT2_HIST"     ,, "Historico"        ,PesqPict("CT2","CT2_HIST")},;
               {  "CT2_ORIGEM"   ,, "Origem"           ,PesqPict("CT2","CT2_ORIGEM")},;
               {  "CT2_LOTE"     ,, "Lote"             ,PesqPict("CT2","CT2_LOTE")},;              
               {  "CT2_SBLOTE"   ,, "Sub. Lote"        ,PesqPict("CT2","CT2_SBLOTE")},;
               {  "CT2_DOC"      ,, "Documento"        ,PesqPict("CT2","CT2_DOC")},;
               {  "CT2_TPSALD"   ,, "Tipo de Saldo"    ,PesqPict("CT2","CT2_TPSALD")},;
               {  "CT2_DC"       ,, "Deb/Cre"          ,PesqPict("CT2","CT2_DC")},;
               {  "CT2_XIDDEB"   ,, "ID Debito"        ,PesqPict("CT2","CT2_XIDDEB")},;
               {  "CT2_XIDCRE"   ,, "ID Credito"       ,PesqPict("CT2","CT2_XIDCRE")},;
               {  "CT2_XTPDEB"   ,, "Tipo de Con."     ,PesqPict("CT2","CT2_XTPDEB")},;
               {  "CT2_XTPCRE"   ,, "Tipo de Con."     ,PesqPict("CT2","CT2_XTPCRE")}}
aSize := MSADVSIZE()

DEFINE MSDIALOG oDlg TITLE "*** Conciliação Manual Alatur ***" From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL 

oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,35,35,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_TOP

@0.70,01 	Say "Conta Selecionada:" Of oPanel // "Valor Total Bens Fiscais :"
@0.70,10 	Say oConta 	VAR cConta 	Picture cPictCta Of oPanel

@25,10 CHECKBOX oChk VAR lCheck PROMPT "Selecionar Todos" SIZE 60,007 PIXEL OF oPanel ON CLICK XConInv(lCheck, cConDe) 

@0.70,20	Say "Total Conta Deb.:" Of oPanel 
@0.70,30 	Say oTotDeb VAR nTotDeb Picture cPictVlr Of oPanel

@1.4,20 	Say "Total Conta Cre.:" Of oPanel 
@1.4,30 	Say oTotCre VAR nTotCre Picture cPictVlr Of oPanel

@2.10,20 	Say "Saldo Total Cta. " + cDCTot + ": " Of oPanel 
@2.10,30 	Say oTotSal VAR nTotSal Picture cPictVlr Of oPanel

@0.70,40 	Say "Valor Debito:" Of oPanel 
@0.70,45 	Say oVlrDeb VAR nVlrDeb Picture cPictVlr Of oPanel

@1.4,40 	Say "Valor Credito:" Of oPanel 
@1.4,45 	Say oVlrCre VAR nVlrCre Picture cPictVlr Of oPanel
	
@2.10,40 	Say "Saldo Total:" Of oPanel  
@2.10,45 	Say oVlrSal VAR /*nVlrSal*/ nVlrSal Picture cPictVlr Of oPanel
@2.10,53	Say oVlrDc  VAR /*nVlrSal*/ cDCVlr Of oPanel
																				    
@15,500 button "Conciliar" size 45,11 pixel of oPanel action {||XGrvVin(),If(lConcilia,oDlg:end(),lConcilia := .F.)}//XGrvVin()

@15,550 button "Desconciliar" size 45,11 pixel of oPanel action XDesVin(cConDe)

@15,600 button "Sair" size 45,11 pixel of oPanel action {||oDlg:end(),lConcilia := .F.}  

aCores := {} 
 
AADD(aCores,{"cArqTrb->CT2_XSTAT == ' '"	,"BR_VERMELHO"})
AADD(aCores,{"cArqTrb->CT2_XSTAT == '1'"	,"BR_VERMELHO"	})
AADD(aCores,{"cArqTrb->CT2_XSTAT == '2'"	,"BR_VERDE"	})

//oMark := MsSelect():New("cArqTrb","CT2_XOK","",aCpoBro,@lInverte,@cMark,{40,oDlg:nLeft+1,oDlg:nBottom-335,oDlg:nRight-660},,,,,aCores)
oMark := MsSelect():New("cArqTrb","CT2_XOK","",aCpoBro,@lInverte,@cMark,{40,1,oDlg:nBottom - 400,oDlg:nRight-750},,,,,aCores) 
oMark:bMark := {| | Disp(cMark)} 
//oMark:bAllMark := {|| XConInv(cArqTrb) }

//ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()}) 

ACTIVATE MSDIALOG oDlg CENTERED

//cAliAux->(DbCloseArea())
If lConcilia
	("cArqTrb")->(dbCloseArea())
	U_CTBXCON()
EndIf

If _oConMan <> Nil
	_oConMan:Delete() 
	_oConMan := Nil
EndIf
 

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Disp
Funcao executada ao Marcar/Desmarcar um registro.  

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------


Static Function Disp(cMark) 

Local cMarca := cMark

RecLock("cArqTrb",.F.) 

If Marked("CT2_XOK")    

	cArqTrb->CT2_XOK := cMarca  
	
	If Alltrim(cArqTrb->CT2_DEBITO) == cConta 
	
		nVlrDeb += cArqTrb->CT2_VALOR
		
	EndIf
	
	If Alltrim(cArqTrb->CT2_CREDIT) == cConta 
		
		nVlrCre += cArqTrb->CT2_VALOR
		
	EndIf
	
	nCont += 1
	
Else 

	cArqTrb->CT2_XOK := "" 
	
	If Alltrim(cArqTrb->CT2_DEBITO) == cConta 
	
		nVlrDeb -= cArqTrb->CT2_VALOR
		
	EndIf
	
	If Alltrim(cArqTrb->CT2_CREDIT) == cConta
	 
		nVlrCre -= cArqTrb->CT2_VALOR
		
	EndIf
	
	nCont -= 1

EndIf

MSUNLOCK() 


nVlrSal := (nVlrDeb - nVlrCre)

If nVlrSal < 0

	nVlrSal := ABS(nVlrSal)
	cVlrSal := STR(nVlrSal) + " C"
	cDCVlr  := "C"

ElseIf nVlrSal > 0

	cVlrSal := STR(nVlrSal) + " D" 
	cDCVlr  := "D"

ElseIf nVlrSal == 0

	cVlrSal := STR(nVlrSal)
	cDCVlr  := " "

EndIf

cVlrSal := TRANSFORM(cVlrSal, "@E 999.999.999.999,99")

oVlrCre:Refresh()
oVlrDeb:Refresh()
oVlrSal:Refresh()
oVlrDc:Refresh()

oMark:oBrowse:Refresh() 

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} XGrvVin
Gravação de IDs de acordo com os registros selecionados

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function XGrvVin() 

If nVlrSal == 0 
	MsAguarde( { || XGrvCon() },,"Verificando os números de IDs para não repeti-los!")
Else
	MsgAlert( "O saldo não está zerado para conciliar!", "Saldo" )
	Return
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XGrvCon
Gravação de IDs de acordo com os registros selecionados

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function XGrvCon()

Local cIdDeb   := ""
Local cIdCre   := ""
Local nIdDeb   := 0
Local nIdCre   := 0
Local cStatus  := ""
Local lVinc    := .F.
Local cIdAux   := ""

If lCarga

	cIdDeb   := XIdDeb()
	cIdCre   := XIdCre()
	
EndIf

If lCarga

	If cIdDeb > cIdCre
	
		cIdLanc := cIdDeb
		
	Else
	
		cIdLanc := cIdCre
		
	EndIf
	
	lCarga   := .F.
	
EndIf

If !Empty(cUltId)

	cIdAux  := cIdLanc
	cIdLanc := Soma1(cUltId)
	
Else

	cIdAux  := cIdLanc
	cIdLanc := __cUserID + Soma1(cIdLanc)
	
EndIf
    
DbSelectArea("cArqTrb") 
DbGotop()

BEGIN TRANSACTION

Do While ("cArqTrb")->(!Eof()) //.And. nCont >0
	
	
	If !Empty(cArqTrb->CT2_XOK)
	 
		If nVlrSal == 0
		 
			nRecno := cArqTrb->CT2_RECNO
			
			CT2->(DbGoto(nRecno))
			
			If Empty(CT2->CT2_XFLCRE) .And. Alltrim(CT2_CREDIT) == Alltrim(cConta) 
				
				RecLock("CT2",.F.)
				
				CT2->CT2_XIDCRE   := cIdLanc //ID sequencial da conciliação contábil – vinculo de lançamentos a crédito
				CT2->CT2_XTPCRE   := "M" //Identifica se o lançamento foi conciliado de forma automática (A) ou manual (M).
				CT2->CT2_XFLCRE   := cArqTrb->CT2_CREDIT //Flag de conciliação contábil, identifica se o registro já foi conciliado.
				CT2->CT2_XAUXCR   := RIGHT(cIdLanc, 20)
				
				cUltId := cIdLanc
				lVinc  := .T.
				
				If Empty(CT2->CT2_XOK)
				
					CT2->CT2_XOK   := cMark
					
				EndIf
				
				If Empty(CT2->CT2_XSTAT)
				
					cStatus  := "1"
					CT2->CT2_XSTAT    := "1"
					
				EndIf
				
				MsUnLock()
				
				RecLock("cArqTrb",.F.)
				
				cArqTrb->CT2_XIDCRE := cIdLanc
				cArqTrb->CT2_XTPCRE := 'M'
				
				MsUnLock()
				
			EndIf
					
			If Empty(CT2->CT2_XFLDEB) .And. Alltrim(CT2_DEBITO) == Alltrim(cConta)
			
				RecLock("CT2",.F.)
				
				CT2->CT2_XIDDEB   := cIdLanc//ID sequencial da conciliação contábil – vinculo de lançamentos a débito
				CT2->CT2_XTPDEB   := "M" //Identifica se o lançamento foi conciliado de forma automática (A) ou manual (M).
				CT2->CT2_XFLDEB   := cArqTrb->CT2_DEBITO //Flag de conciliação contábil, identifica se o registro já foi conciliado.
				CT2->CT2_XAUXDE   := RIGHT(cIdLanc, 20)
				
				lVinc  := .T.
				cUltId := cIdLanc
				
				If Empty(CT2->CT2_XOK)
				
					CT2->CT2_XOK   := cMark
					
				EndIf
				
				If Empty(CT2->CT2_XSTAT)
				
					cStatus           := "1"
					CT2->CT2_XSTAT    := "1"
					
				EndIf
				
				MsUnLock()
				
				RecLock("cArqTrb",.F.)
				
				cArqTrb->CT2_XIDDEB := cIdLanc
				cArqTrb->CT2_XTPDEB := 'M'
				
				MsUnLock()
				
			EndIf
					
			If ( !Empty(CT2->CT2_XFLCRE) .And. !Empty(CT2->CT2_XFLDEB) )
			
				RecLock("CT2",.F.)
				
				CT2->CT2_XCTBFL   := "S"
				CT2->CT2_XSTAT    := "2"
				cStatus           := "2"
				
				MsUnLock()
			EndIf
			
			nCont -= 1

		Else
			MsgAlert( "O saldo não está zerado para conciliar!", "Saldo" )
			cIdLanc := cIdAux
			Exit
		EndIf
	EndIf
	
	If lVinc .And. !Empty(cArqTrb->CT2_XOK)
	
		RecLock("cArqTrb",.F.)
		
			cArqTrb->CT2_XSTAT := cStatus
			cArqTrb->CT2_XOK   := ""
			
		MsUnLock()
	Else	
		//cArqTrb->CT2_XOK   := ""
	EndIf
	
	If lVinc
	
		nVlrDeb := 0 
		nVlrCre := 0
		nVlrSal := 0
		
	EndIf

	("cArqTrb")->(DbSkip())
		
EndDo

END TRANSACTION

DbSelectArea("cArqTrb") 
DbGotop()

//(cArqTrb)->(dbCloseArea())

lConcilia := .T.

oVlrCre:Refresh()
oVlrDeb:Refresh()
oVlrSal:Refresh()
oVlrDc:Refresh()

oMark:oBrowse:Refresh() 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XGrvCon
Desconciliação de IDs de acordo com os registros selecionados

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function XDesVin(cConDe) 
	
	If nVlrSal == 0 
		MsAguarde( { || XDesCon(cConDe) },,"Verificando os números de IDs para não repeti-los!")
	Else
		MsgAlert( "O saldo não está zerado para conciliar!", "Saldo" )
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XGrvCon
Desconciliação de IDs de acordo com os registros selecionados

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function XDesCon(cConDe)

Local lVinc := .F.

DbSelectArea("cArqTrb") 
DbGotop()

BEGIN TRANSACTION

Do While ("cArqTrb")->(!Eof()) //.And. nCont >0
	
	If !Empty(cArqTrb->CT2_XOK) //.And. (!Empty(CT2->CT2_XFLCRE) .Or. !Empty(CT2->CT2_XFLDEB))
	
		If nVlrSal == 0 
	
			nRecno := cArqTrb->CT2_RECNO
			
			CT2->(DbGoto(nRecno))
			
			RecLock("CT2",.F.)
			
			lVinc := .T.
			
			If Alltrim(cConDe) == Alltrim (CT2->CT2_XFLCRE)
			
				CT2->CT2_XIDCRE := '' 
				CT2->CT2_XFLCRE := '' 
				CT2->CT2_XTPCRE := ''
				CT2->CT2_XAUXCR := ''
				
			EndIf
			
			If Alltrim(cConDe) == Alltrim (CT2->CT2_XFLDEB)
			
				CT2->CT2_XIDDEB := '' 
				CT2->CT2_XFLDEB := '' 
				CT2->CT2_XTPDEB := ''
				CT2->CT2_XAUXDE := ''
				
			EndIf
			
			If Empty(CT2->CT2_XIDDEB) .And.  !Empty(CT2->CT2_XIDCRE)
				CT2->CT2_XSTAT  := '1'
			EndIf
			
			If !Empty(CT2->CT2_XIDDEB) .And.  Empty(CT2->CT2_XIDCRE)
				CT2->CT2_XSTAT  := '1'
			EndIf
			
			If Empty(CT2->CT2_XIDDEB) .And.  Empty(CT2->CT2_XIDCRE)
				CT2->CT2_XSTAT  := ' '
			EndIf
			
			CT2->CT2_XCTBFL := ''
			CT2->CT2_XOK    := ''
			
			cStatus := ""
			nCont -= 1
			MsUnLock()
		Else
			MsgAlert( "O saldo não está zerado para desconciliar!", "Saldo" )
			Exit
		EndIf
		
	ElseIf !Empty(cArqTrb->CT2_XOK)
		MsgInfo("Foi selecionado um registro não conciliado: " + cArqTrb->CT2_DOC,"Não Conciliado")
		Exit
	EndIf
	
	If lVinc .And. cArqTrb->CT2_XOK != " "
	
		RecLock("cArqTrb",.F.)
		
			cArqTrb->CT2_XSTAT    := ""
			cArqTrb->CT2_XOK      := ""
			
			If Alltrim(cConDe) == Alltrim (cArqTrb->CT2_DEBITO)
				cArqTrb->CT2_XIDDEB   := ""
				cArqTrb->CT2_XTPDEB   := ""
			EndIf
			
			If Alltrim(cConDe) == Alltrim (cArqTrb->CT2_CREDIT)
				cArqTrb->CT2_XIDCRE   := ""
				cArqTrb->CT2_XTPCRE   := ""
			EndIf
			
		MsUnLock()
	EndIf
	
	If lVinc
	
		nVlrDeb := 0 
		nVlrCre := 0
		nVlrSal := 0
		
	EndIf

	("cArqTrb")->(DbSkip())
		
EndDo

END TRANSACTION

DbSelectArea("cArqTrb") 
DbGotop()

cIdLanc   := ""
lCarga    := .T.
cUltId    := ""

oVlrCre:Refresh()
oVlrDeb:Refresh()
oVlrSal:Refresh()
oVlrDc:Refresh()
	
oMark:oBrowse:Refresh() 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XConInv
Função que realiza a marcação/desmarcação de todos os registros da tabela temporária

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function XConInv(lCheck, cConDe)

Local aArea := GetArea()

dbSelectArea( "cArqTrb" ) 
dbGotop() 

Do While !EoF()
 
    If lCheck
    
		If RecLock( "cArqTrb", .F. ) 
			
			If Empty(cArqTrb->CT2_XOK)
				cArqTrb->CT2_XOK  := cMark 
				
				If Alltrim(cArqTrb->CT2_CREDIT) == Alltrim(cConDe)
					nVlrCre += cArqTrb->CT2_VALOR
				EndIf
			
				If Alltrim(cArqTrb->CT2_DEBITO) == Alltrim(cConDe)
					nVlrDeb += cArqTrb->CT2_VALOR
				EndIf
				
				nVlrSal := (nVlrDeb - nVlrCre)
			
			EndIf
			
			MsUnLock() 
		
		EndIf 
		
		If !Empty(cArqTrb->CT2_XOK)
		
			/*If Alltrim(cArqTrb->CT2_CREDIT) == Alltrim(cConDe)
				nVlrCre += cArqTrb->CT2_VALOR
			EndIf
			
			If Alltrim(cArqTrb->CT2_DEBITO) == Alltrim(cConDe)
				nVlrDeb += cArqTrb->CT2_VALOR
			EndIf*/
			
		EndIf
	Else
	
		If RecLock( "cArqTrb", .F. ) 
			
			If !Empty(cArqTrb->CT2_XOK)
				cArqTrb->CT2_XOK  := ''
				
				If Alltrim(cArqTrb->CT2_CREDIT) == Alltrim(cConDe)
					nVlrCre -= cArqTrb->CT2_VALOR
				EndIf
			
				If Alltrim(cArqTrb->CT2_DEBITO) == Alltrim(cConDe)
					nVlrDeb -= cArqTrb->CT2_VALOR
				EndIf
				nVlrSal := (nVlrDeb - nVlrCre)
			EndIf 
			
			MsUnLock() 
		
		EndIf 
		
		If Empty(cArqTrb->CT2_XOK)
		
			/*If Alltrim(cArqTrb->CT2_CREDIT) == Alltrim(cConDe)
				nVlrCre -= cArqTrb->CT2_VALOR
			EndIf
			
			If Alltrim(cArqTrb->CT2_DEBITO) == Alltrim(cConDe)
				nVlrDeb -= cArqTrb->CT2_VALOR
			EndIf*/			
		EndIf
	
	EndIf
	
	dbSkip() 

EndDo 

//nVlrSal := (nVlrDeb - nVlrCre)

If nVlrSal < 0

	nVlrSal := ABS(nVlrSal)
	cVlrSal := STR(nVlrSal) + " C"

ElseIf nVlrSal > 0

	cVlrSal := STR(nVlrSal) + " D" 

ElseIf nVlrSal == 0

	cVlrSal := STR(nVlrSal)

EndIf

RestArea(aArea)

oVlrCre:Refresh()
oVlrDeb:Refresh()
oVlrSal:Refresh()

oMark:oBrowse:Refresh() 

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} xMovDeb
Busca os movimentos a débito da conta selecionada de acordo com os 
parametros informados no início da rotina

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function xMovDeb(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cConci)

Local cQuery  := ""
Local cAliDeb := GetNextAlias()
Local nDebito := 0

cQuery := " SELECT SUM (CT2_VALOR) AS DEBITO FROM  "
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += " WHERE "
cQuery += " CT2_DEBITO = '" + cConDe + "' "
cQuery += " AND CT2_FILIAL   Between '" + cFilDe    + "' AND '" + cFilAte  + "' " 
cQuery += " AND CT2_DATA   >= '" + Dtos(dDtDe)  + "' AND CT2_DATA <= '" + Dtos(dDtAte) + "' " 

If Valtype(cConci) == "N"
	cConci := "Não conciliados"
EndIf

If cConci == "Não conciliados" //Não conciliados
	cQuery += " AND (CT2_XFLDEB = ' ' OR CT2_XFLCRE = ' ') "
EndIf

If cConci == "Conciliados" //Conciliados
	cQuery += " AND (CT2_XFLDEB != ' ' AND CT2_XFLCRE != ' ') "
EndIf

cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliDeb,.T.,.T.)

nDebito := (cAliDeb)->DEBITO

(cAliDeb)->(DbCloseArea())

Return nDebito

//-------------------------------------------------------------------
/*/{Protheus.doc} xMovCre
Busca os movimentos a débito da conta selecionada de acordo com os 
parametros informados no início da rotina

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------
 
Static Function xMovCre(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cConci)

Local cQuery   := ""
Local cAliCre  := GetNextAlias()
Local nCredito := 0

cQuery := " SELECT SUM (CT2_VALOR) AS CREDITO FROM  "
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += " WHERE "
cQuery += " CT2_CREDIT = '" + cConDe + "' "
cQuery += " AND CT2_FILIAL   Between '" + cFilDe    + "' AND '" + cFilAte  + "' " 
cQuery += " AND CT2_DATA   >= '" + Dtos(dDtDe)  + "' AND CT2_DATA <= '" + Dtos(dDtAte) + "' " 

If Valtype(cConci) == "N"
	cConci := "Não conciliados"
EndIf

If cConci == "Não conciliados" //Não conciliados
	cQuery += " AND (CT2_XFLDEB = ' ' AND CT2_XFLCRE = ' ') "
EndIf

If cConci == "Conciliados" //Conciliados
	cQuery += " AND (CT2_XFLDEB != ' ' OR CT2_XFLCRE != ' ') "
EndIf

cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliCre,.T.,.T.)

nCredito := (cAliCre)->CREDITO

(cAliCre)->(DbCloseArea())

Return nCredito

//-------------------------------------------------------------------
/*/{Protheus.doc} XIdDeb
Busca o maior número de ID a débito

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------

Function XIdDeb()

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

(cAliAux)->(dbCloseArea())

Return cIdDeb

//-------------------------------------------------------------------
/*/{Protheus.doc} XIdCre
Busca o maior número de ID a credito

@author André Brito
@since 14/06/2019
@version P12
/*/
//-------------------------------------------------------------------

Function XIdCre()

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

(cAliAux)->(dbCloseArea())

Return cIdCre

//---------------------------------------------------------------------------

Function xAlSave(cLoad,aParametros,cBloq)

Local nx

Local cWrite   := cBloq+"Arquivo de configuracao - Alatur "+CRLF
Local cBarra   := If(issrvunix(), "/", "\")
Local cCaminho := "C:\temp"

For nx := 1 to Len(aParametros)
	If ValType(aParametros[nx]) == "C"
		cWrite += aParametros[nx] + CRLF
	ElseIf ValType(aParametros[nx]) == "N"
		cWrite += Str(aParametros[nx]) + CRLF
	ElseIf ValType(aParametros[nx]) == "D"
		cWrite += DTOC(aParametros[nx]) + CRLF
	Else
		cWrite += "X"+CRLF
	EndIf

Next

//MemoWrit(cCaminho + ".PRB",cWrite)

MemoWrit(cBarra + "PROFILE" + cBarra +Alltrim(cLoad)+".PRB",cWrite)

Return

//-------------------------------------------------------------------

Function xAload(cLoad,aParametros,nx,xDefault,lDefault)
local ny
Local cBarra 		:= If(issrvunix(), "/", "\")
Local cTypeData 	:= NIL
Local cCaminho      := "C:\temp"
DEFAULT lDefault 	:= .F.

If File(cBarra + "PROFILE" + cBarra + Alltrim(cLoad) + ".PRB")
	If FT_FUse(cBarra + "PROFILE" + cBarra + Alltrim(cLoad)+".PRB")<> -1
		FT_FGOTOP()
		If nx == 0
			cLinha := FT_FREADLN()
			FT_FUSE()
			Return Substr(cLinha,1,1)
		EndIf
		For ny := 1 to nx
			FT_FSKIP()
		Next
		cLinha := FT_FREADLN()
		If !lDefault
			xRet := Substr(cLinha,1,Len(cLinha))
		Else
			xRet := xDefault
		Endif
		FT_FUSE()
	EndIf
Else
	xRet := xDefault
EndIf

If Alltrim(xRet) == "X"
	xRet := ""
EndIf

Return Alltrim(xRet)