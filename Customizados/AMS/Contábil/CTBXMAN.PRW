#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBXMAN
Conciliação Manual - ALATUR

@author André Brito
@since 15/05/2019
@version P12
/*/
//-------------------------------------------------------------------
User Function CTBXMAN()

Local oBrowse
Local _oConMan      
Local aPWiz     := {}
Local aRetWiz   := {}
Local cQuery    := ""
Local cFilDe  	:= ""
Local cFilAte 	:= "" 
Local cConci  	:= "" 
Local cHist   	:= "" 
Local dDtDe   	:= CTOD("//") 
Local dDtAte  	:= CTOD("//")
Local cArqTrb   := GetNextAlias()
Local aCampos   := {}
Local cFiltro   := ""

Private oMark
Private nTotDeb := 0
Private nTotCre := 0
Private nTotSal := 0
Private nValDeb := 0
Private nValCre := 0
Private nValSal := 0
Private aRotina := MenuDef()
Private cConDe  := "" 
Private nCont   := 0
Private aRecno  := {}
Private lCarga  := .T.
Private cUltId  := ""

//aAdd(aPWiz,{ 1,"Filial de: "               ,Space(TamSX3("CT2_FILIAL")[1]) ,"","","SM0","",9   ,.F.})
//aAdd(aPWiz,{ 1,"Filial ate: "              ,Space(TamSX3("CT2_FILIAL")[1]) ,"","","SM0","",9   ,.F.})
aAdd(aPWiz,{ 1,"Conta Referência: "        ,Space(TamSX3("CT2_DEBITO")[1]) ,"","","CT1","",    ,.F.})
//aAdd(aPWiz,{ 1,"Data de: "                 ,Ctod("")                       ,"","",""   ,  ,60  ,.F.})
//aAdd(aPWiz,{ 1,"Data ate: "                ,Ctod("")                       ,"","",""   ,  ,60  ,.F.})
//aAdd(aPWiz,{ 2,"Trazer Conciliados: "    ,1,{"Não Conciliados", "Conciliados", "Ambos"},60,""     ,.F.}) 
//aAdd(aPWiz,{ 1,"Contem no Hist.: "       ,Space(20)   ,"","",""   ,"",    ,.F.})

//aAdd(aRetWiz,Space(TamSX3("CT2_FILIAL")[1]))
//aAdd(aRetWiz,Space(TamSX3("CT2_FILIAL")[1]))
aAdd(aRetWiz,Space(TamSX3("CT2_DEBITO")[1]))
//aAdd(aRetWiz,Ctod(""))
//aAdd(aRetWiz,Ctod(""))
//aAdd(aRetWiz,Space(40))
//aAdd(aRetWiz,Space(20))

ParamBox(aPWiz,"***** Conciliação Manual Contábil - ALATUR JTB *****",@aRetWiz,,,,,,) 

//cFilDe  := aRetWiz[1]
//cFilAte := aRetWiz[2] 
cConDe  := aRetWiz[1] 
//dDtDe   := aRetWiz[4] 
//dDtAte  := aRetWiz[5] 
//cConci  := aRetWiz[6] 
//cHist   := aRetWiz[7]

//cFiltro := " CT2_FILIAL >= '" + cFilDe + "' .And. CT2_FILIAL <= '" + cFilAte + "'"
//cFiltro += " .And. CT2_CREDIT  == '" + Alltrim(cConDe) + "' .OR. CT2_DEBITO  == '" + Alltrim(cConDe) + "'"

SetKey( VK_F6, { || XPanelF6()} )

//oBrowse := FWmBrowse():New()

oMark := FWMarkBrowse():New() 
oMark:SetAlias('CT2')
oMark:SetOnlyFields( { 'CT2_OK', 'CT2_FILIAL' , 'CT2_DATA' , 'CT2_LOTE' , 'CT2_SBLOTE' , 'CT2_DOC' , 'CT2_DC' , 'CT2_TPSALD' , 'CT2_XNUMDO' ,'CT2_HIST', 'CT2_DEBITO' , 'CT2_CREDIT' , 'CT2_VALOR' , 'CT2_XIDCRE' , 'CT2_XIDDEB', 'CT2_XFLCRE' , 'CT2_XFLDEB'} )
//oMark:SetSemaphore(.T.)
oMark:SetDescription('Conciliação Lançamentos Contábeis')
oMark:SetFieldMark( 'CT2_XOK' )
//oMark:SetAllMark( { || oMark:AllMark() } ) 
oMark:bMark	:= {|| xVldCon(oMark:cMark, cConDe)}
oMark:SetAllMark( { ||  XMarkCon( oMark ) } )
//oMark:bAllMark := { || XMarkCon( oMark )}
oMark:AddLegend( "!EMPTY(CT2_XIDCRE) .Or. !EMPTY(CT2_XIDDEB)" ,"GREEN"    , "Conciliado"  )
oMark:AddLegend( "EMPTY(CT2_XIDCRE) .And. EMPTY(CT2_XIDDEB)"  ,"RED"    , "Não Conciliado"  )
//oMark:SetFilterDefault( @cFiltro )
oMark:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

//ADD OPTION aRotina TITLE 'Visualizar' ACTION 'CTBXVIEW'         OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Conciliar'     ACTION 'U_XPROCCON()'      OPERATION 6 ACCESS 0
ADD OPTION aRotina TITLE 'Desconciliar'  ACTION 'U_XPROCDES()'      OPERATION 6 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
User Function XPROCCON()

MsAguarde( { || XGrvProc() },,"Atualizando IDs e Flags, por favor aguarde...")

Return

//-------------------------------------------------------------------

User Function XPROCDES()

MsAguarde( { || XGrvDes() },,"Atualizando IDs e Flags, por favor aguarde...")

Return

//-------------------------------------------------------------------

Function XGrvDes()

Local aArea    := GetArea()
Local cMarca   := oMark:Mark()
Local lInverte := oMark:IsInvert()
Local nCt      := 0
Local lZera    := .T.
Local nA       := 0
Local nxPos    := 0

//BEGIN TRANSACTION

For nA := 1 To Len(aRecno)

	If aRecno[nA] != Nil
		
		CT2->(dbGoto(aRecno[nA])) 
		
		If nxPos == 0
			nxPos := aRecno[nA]
		EndIf
		
		If oMark:IsMark(cMarca)
		
			If nValSal == 0 
				nCt ++
				RecLock("CT2",.F.)
				
				CT2->CT2_XIDCRE := '' 
				CT2->CT2_XIDDEB := '' 
				CT2->CT2_XFLCRE := '' 
				CT2->CT2_XFLDEB := '' 
				CT2->CT2_XTPCRE := ''
				CT2->CT2_XTPDEB := ''
				CT2->CT2_XCTBFL := ''
				CT2->CT2_XSTAT  := ''
				CT2->CT2_XOK    := ''
				MsUnLock()
			Else
				MsgAlert( "O saldo não está zerado para desconciliar!", "Saldo" )
				lZera := .F.
				Exit
			EndIf
			
		EndIf
	
		CT2->( dbSkip() )
	EndIf
Next

//END TRANSACTION

ApMsgInfo( 'Foram desconciliados ' + AllTrim( Str( nCt ) ) + ' registros.' )

If lZera
	nValDeb := 0 
	nValCre := 0
	nValSal := 0
EndIf

oMark:GoTo(nxPos)

//RestArea( aArea )

Return

//-------------------------------------------------------------------

Function XGrvProc()

Local aArea    := GetArea()
Local cMarca   := oMark:Mark()
Local lInverte := oMark:IsInvert()
Local nCt      := 0
Local cIdLanc  := ""
Local cIdDeb   := ""
Local cIdCre   := ""
Local nIdDeb   := 0
Local nIdCre   := 0
Local nA       := 0
Local nxPos    := 0
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

//BEGIN TRANSACTION

For nA := 1 To Len(aRecno)
	
	If aRecno[nA] != Nil
		
		CT2->(dbGoto(aRecno[nA])) 
		If nxPos == 0
			nxPos := aRecno[nA]
		EndIf
		If oMark:IsMark(cMarca)
			If nValSal == 0 
				If Empty(CT2->CT2_XFLCRE) .And. Alltrim(CT2->CT2_CREDIT) == Alltrim(cConDe) 
						
					RecLock("CT2",.F.)
					
						CT2->CT2_XIDCRE   := cIdLanc //ID sequencial da conciliação contábil – vinculo de lançamentos a crédito
						CT2->CT2_XTPCRE   := "M" //Identifica se o lançamento foi conciliado de forma automática (A) ou manual (M).
						CT2->CT2_XFLCRE   := CT2->CT2_CREDIT //Flag de conciliação contábil, identifica se o registro já foi conciliado.
						
						cUltId := cIdLanc
						lVinc := .T.
						
						If Empty(CT2->CT2_XSTAT)
							CT2->CT2_XSTAT   := "1"
						EndIf
					
					MsUnLock()
						
				EndIf
				
				nCt ++
				nCont --
				
				If Empty(CT2->CT2_XFLDEB) .And. Alltrim(CT2->CT2_DEBITO) == Alltrim(cConDe)
					
					RecLock("CT2",.F.)
					
						CT2->CT2_XIDDEB   := cIdLanc//ID sequencial da conciliação contábil – vinculo de lançamentos a débito
						CT2->CT2_XTPDEB  := "M" //Identifica se o lançamento foi conciliado de forma automática (A) ou manual (M).
						CT2->CT2_XFLDEB   := CT2->CT2_DEBITO //Flag de conciliação contábil, identifica se o registro já foi conciliado.
						
						cUltId := cIdLanc
						lVinc := .T.
						
						If Empty(CT2->CT2_XSTAT)
							CT2->CT2_XSTAT    := "1"
						EndIf
					
					MsUnLock()
						
				EndIf
				
				If ( !Empty(CT2->CT2_XFLCRE) .And. !Empty(CT2->CT2_XFLDEB) )
					RecLock("CT2",.F.)
					
						CT2->CT2_XCTBFL   := "S"
						CT2->CT2_XSTAT    := "2"
					
					MsUnLock()
				EndIf
				
			Else
				MsgAlert( "O saldo não está zerado para conciliar!", "Saldo" )
				Exit
			EndIf
		EndIf
	EndIf
	//CT2->( dbSkip() )
Next nA

//END TRANSACTION

ApMsgInfo( 'Foram conciliados ' + AllTrim( Str( nCt ) ) + ' registros.' )

oMark:GoTo(nxPos)

/*nValDeb := 0 
nValCre := 0
nValSal := 0*/

//RestArea( aArea )

Return 

//-------------------------------------------------------------------
Static Function xVldCon(cMarca, cConDe)

Local oModel    := FWModelActive()
Local lRet      := .T.
Local nRecno    := 0
Local nPosVet   := 0
Local lPass     := .F.
Local aArea     := GetArea()

If oMark:IsMark()
	If Alltrim(CT2->CT2_DEBITO) == Alltrim(cConDe) 
		nValDeb += CT2->CT2_VALOR
		nCont ++
		lPass := .T.
	EndIf
	If Alltrim(CT2->CT2_CREDIT) == Alltrim(cConDe)
		nValCre += CT2->CT2_VALOR
		nCont ++
		lPass := .T.
	EndIf
	If lPass
		aAdd( aRecno, Recno() ) 
	EndIf
	
Else
	If Alltrim(CT2->CT2_DEBITO) == Alltrim(cConDe) 
		nValDeb -= CT2->CT2_VALOR
		nCont --
		lPass := .T.
	EndIf
	If Alltrim(CT2->CT2_CREDIT) == Alltrim(cConDe)
		nValCre -= CT2->CT2_VALOR
		nCont --
		lPass := .T.
	EndIf
	nRecno  := Recno()
	nPosVet := ASCAN(aRecno, nRecno)
	
	If lPass 
		aDel( aRecno, nPosVet )
	EndIf
	
EndIf
//Se negativo Credito
//Se positivo Debito

nValSal := (nValDeb - nValCre)

RestArea( aArea )

Return 

//-------------------------------------------------------------------

/*Static Function XFilCon(cFilDe,cFilAte,cConDe,dDtDe,dDtAte)
Local cFiltro   := ""
Local cAliAux   := GetNextAlias()

cFiltro := " CT2_FILIAL >= '" + cFilDe + "' .And. CT2_FILIAL <= '" + cFilAte + "'"
cFiltro += " .And. CT2_CREDIT  == '" + Alltrim(cConDe) + "' .OR. CT2_DEBITO  == '" + Alltrim(cConDe) + "'"
//cFiltro += " .And. CT2_DATA >= " dDtDe  " .And. CT2_DATA <= "  dDtAte  " "
	
*/

Static Function XMarkCon( oMark )  

MsAguarde( { || XMarcaCon(oMark) },,"Marcando os registros...")

Return

Static Function XMarcaCon( oMark ) 

Local cAlias	:= oMark:Alias()
Local cMark		:= oMark:Mark()
Local nRecno	:= (cAlias)->(Recno())

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() )

	If RecLock( cAlias, .F. )
		( cAlias )->CT2_XOK := Iif( ( cAlias )->CT2_XOK == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() )
	EndIf
	
	If !Empty((cAlias)->CT2_XOK)
		If Alltrim( (cAlias)->CT2_CREDIT) == Alltrim(cConDe)
			nValCre += (cAlias)->CT2_VALOR
		EndIf
		If Alltrim((cAlias)->CT2_DEBITO) == Alltrim(cConDe)
			nValDeb += (cAlias)->CT2_VALOR
		EndIf
	EndIf
	
	If Empty((cAlias)->CT2_XOK)
		If Alltrim( (cAlias)->CT2_CREDIT) == Alltrim(cConDe)
			nValCre -= (cAlias)->CT2_VALOR
		EndIf
		If Alltrim((cAlias)->CT2_DEBITO) == Alltrim(cConDe)
			nValDeb -= (cAlias)->CT2_VALOR
		EndIf
	EndIf

	( cAlias)->( DBSkip() )
EndDo

nValSal := (nValDeb - nValCre)

( cAlias )->( DBGoto( nRecno ) )

oMark:Refresh()

Return()


Static Function XPanelF6( ) 

Local aButtons := {}
Local aSays    := {}
Local nOpca    := 0
Local nVlrCre  := 0	
Local nVlrDeb  := 0
Local nVlrSal  := 0

nVlrCre  := nValCre
nVlrDeb  := nValDeb
nVlrSal  := nValSal

If nVlrSal < 0
	nVlrSal := ABS(nVlrSal)
	nVlrSal := Str(nVlrSal) + " C"
ElseIf nVlrSal > 0
	nVlrSal := Str(nVlrSal) + " D"
ElseIf nVlrSal == 0
	nVlrSal := Str(nVlrSal)
EndIf

AADD(aButtons, { 1,.T.,{|| FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| nOpca := 1 ,FechaBatch()}})

AADD(aSays,"Valor selecionado a debito: " + Alltrim(Str(nVlrDeb)) ) //+ Alltrim(Str(nQtdVin)) + CRLF ) 
AADD(aSays,"Valor selecionado a credito: " + Alltrim(Str(nVlrCre)) ) //+ Alltrim(Str(nQtdProc)) )
AADD(aSays,"Saldo total selecionado: " + Alltrim(nVlrSal) ) // + cHoraIn ) 

FormBatch( "Visualizando valores selecionados", aSays, aButtons ,,,445)

Return