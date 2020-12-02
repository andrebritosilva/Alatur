#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} LP597TUR()
Contabilização da conciliação Compensações aberto por RV
@author Mauricio de Barro
@since 10/04/2017
@version 1.0
@return nRet
/*/
//-------------------------------------------------------------------
User Function LP597Tur(cTipoOper)

Local nRet     := 0
Local aAreaAtu := GetArea()
Local aAreaG4C := G4C->(GetArea())
Local aAreaG8C := G8C->(GetArea())
Local aAreaG3R := G3R->(GetArea())
Local aAreaCT5 := CT5->(GetArea())
Local aAreaSE5 := SE5->(GetArea())
Local nHdlPrv  := 65536
Local cQuery   := ""
Local cProg   := "CTBAFIN"
//Local cLoteTur := LoteCont("TUR")
Local cLote    := LoteCont("FIN")
Local lPadT86  := VerPadrao("T86")
Local lPadT87  := VerPadrao("T87")
Local nTotLiq  := 0.00
Local nTotItem := 0.00
Local nPercProp:= 0.00
Local cArquivo  	:= ""
Local nVlrSe5 := 0
Local cNumDoc := ""

DEFAULT cTipoOper := "1"  // 1=Contabilização 2=Estorno Contabilização

PRIVATE _lDigita := .F.
PRIVATE __VALG4C := 0.00
PRIVATE __cTurProcess := "P"
PRIVATE cAlias9:= GetNextAlias() 

IF Type("nTotDoc")="U"
	nTotDoc := 0
ENDIF

IF Type("nTotal")="U"
	PUBLIC nTotal := 0
ENDIF

_lDigita:= .F.

If ISINCALLSTACK("FINA370") .OR. ISINCALLSTACK("CTBAFIN")
	Pergunte("FIN370",.F.)
ElseIf ISINCALLSTACK("FINA070").OR.ISINCALLSTACK("FINA740")
	Pergunte("FIN070",.F.)
ElseIf ISINCALLSTACK("FINA110")
	Pergunte("FIN110",.F.)
EndIf

_lDigita:=IIF(mv_par01==1,.T.,.F.)

IF ! ALLTRIM(SE5->E5_PREFIXO) $ "FAP/FTC/FF/ADC"
	Return 0
Endif

//Guardo o valor do registro posicionado para procurar dentro da SE5, pois posso ter baixa de mesmo prefixo e numero de titulo, vindo de filiais diferentes
nVlrSe5 := SE5->E5_VALOR

//Se o registro posicionado for PA, preciso procurar o titulo desse adiantamento
If Alltrim(SE5->E5_TIPO) == 'PA' .AND. Alltrim(SE5->E5_TIPODOC) == 'BA'

	dbSelectArea("SE5")
	dbSetOrder(7)//Filial+Prefixo+Numero+Parcela+Tipo+Fornecedor+Loja
	dbSeek(xFilial("SE5")+Alltrim(SE5->E5_DOCUMEN))
	
	If !Found()
		Return 0
	EndIf
	
	cNumDoc := SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO

	While SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO == cNumDoc
	    If SE5->E5_VALOR == nVlrSe5
	    	Exit                          	
	    Else
			dbSkip()
		EndIf
	EndDo

EndIf

IF  ALLTRIM(SE5->E5_PREFIXO) == "FAP"
	cQuery := "SELECT G4C.G4C_NUMID,G4C.G4C_CONINU,G4C.G4C_IDITEM,G4C.G4C_NUMSEQ,G4C.G4C_CLASS,G4C.G4C_VALOR,G4C.G4C_OPERAC, G4C.R_E_C_N_O_ AS G4C_RECNO, G3R.R_E_C_N_O_ AS G3R_RECNO "
	cQuery += " FROM "+RetSqlName("G4C")+" G4C, "
	cQuery += " "+RetSqlName("G3R")+" G3R "
	cQuery += " WHERE 1=1 "
	cQuery += " AND G3R.G3R_FILIAL = '"+SE5->E5_FILIAL  +"' "
	cQuery += " AND G3R_FORNEC     = '"+SE5->E5_FORNECE +"' "
	cQuery += " AND G3R_LOJA       = '"+SE5->E5_LOJA    +"' "
	cQuery += " AND G3R_FATURA     = '"+SE5->E5_NUMERO  +"' "
//	cQuery += " AND G3R.D_E_L_E_T_ = ' ' "
	cQuery += " AND G3R.D_E_L_E_T_ <> '*' "
	cQuery += " AND G4C.G4C_FILIAL = G3R.G3R_FILIAL "
//	cQuery += " AND G4C.D_E_L_E_T_ = ' ' "
	cQuery += " AND G4C.D_E_L_E_T_ <> '*' "
	cQuery += " AND G4C.G4C_NUMID  = G3R.G3R_NUMID  "
	cQuery += " AND G4C.G4C_IDITEM = G3R.G3R_IDITEM "
	cQuery += " AND G4C.G4C_NUMSEQ = G3R.G3R_NUMSEQ "
	cQuery += " AND G4C.G4C_CLIFOR = '2' "
	cQuery += " ORDER BY G4C_NUMID "
ELSEIF  ALLTRIM(SE5->E5_PREFIXO) $ "FTC/ADC" //.AND. ALLTRIM(SE2->E2_ORIGEM) = 'TURA061'
	
	cQuery := "SELECT G4C.G4C_NUMID,G4C.G4C_IDITEM,G4C.G4C_CONINU,G4C.G4C_NUMSEQ,G4C.G4C_CLASS,G4C.G4C_FATCAR,G4C.G4C_CARTUR,G4C.G4C_CLIFOR,G4C.G4C_VALOR,"
	cQuery += "G4C.G4C_OPERAC, G4C.R_E_C_N_O_ AS G4C_RECNO, G90.R_E_C_N_O_ AS G90_RECNO  "
	cQuery += " FROM "+RetSqlName("G4C")+" G4C, "
	cQuery += " "+RetSqlName("G90")+" G90 "
	cQuery += " WHERE 1=1 "
	cQuery += " AND G90.G90_FILIAL = '"+xFilial("G90")  +"' "
	cQuery += " AND G90.G90_NUMFAT = '"+SE5->E5_NUMERO  +"' "
	cQuery += " AND G90.G90_CODFOR = '"+SE5->E5_CLIFOR  +"' "
//	cQuery += " AND G90.D_E_L_E_T_ = ' ' "
	cQuery += " AND G90.D_E_L_E_T_ <> '*' "
	cQuery += " AND G4C.G4C_FILIAL = '"+SE5->E5_FILIAL +"' "
	cQuery += " AND G4C.G4C_FATCAR = G90.G90_NUMFAT "
	cQuery += " AND G4C.G4C_CARTUR = G90.G90_CODIGO "
	//cQuery += " AND G4C.G4C_DOC = G91.G91_CHAVE "
//	cQuery += " AND G4C.D_E_L_E_T_ = ' ' "
	cQuery += " AND G4C.D_E_L_E_T_ <> '*' "
	cQuery += " AND G4C.G4C_CLIFOR = '2' "
	cQuery += " ORDER BY G4C_NUMID "
	
ELSE
	/*cQuery := "SELECT G4C.G4C_NUMID,G4C.G4C_IDITEM, G4C.G4C_CONINU,G4C.G4C_NUMSEQ,G4C.G4C_CLASS,G4C.G4C_VALOR,G4C.G4C_OPERAC,G4C.R_E_C_N_O_ AS G4C_RECNO, G8C.R_E_C_N_O_ AS G8C_RECNO "
	cQuery += " FROM "+RetSqlName("G4C")+" G4C, "
	cQuery += " "+RetSqlName("G8C")+" G8C "
	cQuery += " WHERE 1=1 "
	cQuery += " AND G8C.G8C_FILIAL = '"+SE5->E5_FILORIG +"' "
	cQuery += " AND G8C_FORNEC     = '"+SE5->E5_FORNECE +"' "
	cQuery += " AND G8C_LOJA       = '"+SE5->E5_LOJA    +"' "
	cQuery += " AND G8C_FATURA     = '"+SE5->E5_NUMERO  +"' "
	cQuery += " AND G8C.D_E_L_E_T_ = ' ' "
	cQuery += " AND G4C.G4C_FILIAL = G8C.G8C_FILIAL "
	cQuery += " AND G4C.D_E_L_E_T_ = ' ' "
	cQuery += " AND G4C.G4C_CONORI = G8C.G8C_CONCIL "
	cQuery += " AND G4C.G4C_CLIFOR = '2' "
	cQuery += " ORDER BY G4C_NUMID "*/
	
	cQuery := "SELECT G4C.G4C_NUMID,G4C.G4C_IDITEM, G4C.G4C_CONINU,G4C.G4C_NUMSEQ,G4C.G4C_CLASS,G4C.G4C_VALOR,G4C.G4C_OPERAC,G4C.R_E_C_N_O_ AS G4C_RECNO, G8Y.R_E_C_N_O_ AS G8Y_RECNO "
	cQuery += " FROM "+RetSqlName("G4C")+" G4C, "
	cQuery += " "+RetSqlName("G8Y")+" G8Y "
	cQuery += " WHERE 1=1 "
	cQuery += " AND G8Y.G8Y_FILIAL = '"+SE5->E5_FILORIG +"' "
	cQuery += " AND G8Y_FORNEC     = '"+SE5->E5_FORNECE +"' "
	cQuery += " AND G8Y_LOJA       = '"+SE5->E5_LOJA    +"' "
	cQuery += " AND G8Y_FATURA     = '"+SE5->E5_NUMERO  +"' "
	cQuery += " AND G8Y_TIPO       = '"+SE5->E5_TIPO    +"' "
    cQuery += " AND G8Y_PREFIX     = '"+SE5->E5_PREFIXO +"' "	
//	cQuery += " AND G8Y.D_E_L_E_T_ = ' ' "
	cQuery += " AND G8Y.D_E_L_E_T_ <> '*' "
	cQuery += " AND G4C.G4C_FILIAL = G8Y.G8Y_FILREF "
//	cQuery += " AND G4C.D_E_L_E_T_ = ' ' "
	cQuery += " AND G4C.D_E_L_E_T_ <> '*' "
	cQuery += " AND G4C.G4C_CONORI = G8Y.G8Y_CONCIL "
	cQuery += " AND G4C.G4C_CLIFOR = '2' "
	cQuery += " ORDER BY G4C_NUMID "

ENDIF

IF Select(cAlias9) > 0
	(cAlias9)->(DbCloseArea())
ENDIF

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias9,.T.,.T.)

(cAlias9)->(DbGoTop())

nTotLiq := 0

WHILE ! (cAlias9)->(Eof())
	nTotLiq += ( (cAlias9)->G4C_VALOR * IIF( (cAlias9)->G4C_CLASS == "   ",1,-1 ))
	(cAlias9)->(DbSkip(+1))
END

nPercProp := SE5->E5_VALOR / nTotLiq

(cAlias9)->(DbGoTop())

WHILE !(cAlias9)->(Eof())
	
	cNumID := (cAlias9)->G4C_NUMID
	nTotItem := 0.00
	
	While ! (cAlias9)->(Eof()) .AND. cNumID == (cAlias9)->G4C_NUMID
		IF (cAlias9)->G4C_CLASS == "   "  // Posiciono no G4C, G8C ou G3R
			G4C->(DbGoto((cAlias9)->G4C_RECNO))
			IF ALLTRIM(SE5->E5_PREFIXO) == "FAP"
				IF (cAlias9)->(FieldPos("G3R_RECNO")) > 0
					G3R->(DbGoto((cAlias9)->G3R_RECNO))
				EndIf
			ELSEIF ALLTRIM(SE5->E5_PREFIXO) $ "FTC/ADC"
				IF (cAlias9)->(FieldPos("G90_RECNO")) > 0
					G90->(DbGoto((cAlias9)->G90_RECNO))
				EndIf
				//G91->(DbGoto((cAlias9)->G91_RECNO))
			ELSE
				IF (cAlias9)->(FieldPos("G8Y_RECNO")) > 0
					G8Y->(DbGoto((cAlias9)->G8Y_RECNO))
				EndIf
			ENDIF
			//nTotItem += ( (cAlias9)->G4C_VALOR * IIF( (cAlias9)->G4C_CLASS == "   ",1,-1 ))//14/09 - Comentado essa linha e mudado para linha 185
			//nTotItem += ( nTotLiq * IIF( (cAlias9)->G4C_CLASS == "   ",1,-1 ))
		ENDIF
		nTotItem += ( (cAlias9)->G4C_VALOR * IIF( (cAlias9)->G4C_CLASS == "   ",1,-1 ))
		(cAlias9)->(DbSkip(+1))
	EndDo
	
	__VALG4C := Round((nTotItem*nPercProp),2)
	                       	
//	If Alltrim(SE5->E5_PREFIXO) <> 'FTI'
		RestArea(aAreaSE5)
 //	EndIf
	
	If cTipoOper == "1" 
       IF lPadT87
           nTotal += DetProva(nHdlPrv,"T87",cProg,cLote)
       ENDIF   
    Else
       IF lPadT86
	       nTotal += DetProva(nHdlPrv,"T86",cProg,cLote)
       ENDIF
    Endif
END

nTotalLcto := nTotal

//07/2017 - Incluido o trecho abaixo para tratar particularidade do PA
//RestArea(aAreaSE5) //Antes de fazer a contabilização abaixo, preciso voltar o registro do SE5
If nTotalLcto > 0 // incluir
	If cTipoOper == '1' //Inclusão
		nTotalLcto += DetProva(nHdlPrv,"T70",cProg,cLote)
	ElseIf cTipoOper == "2" //Estorno
		nTotalLcto += DetProva(nHdlPrv,"T71",cProg,cLote)
	EndIf
EndIf

RestArea(aAreaSE5)

//Treco abaixo do rodaprava e ca100incl para rodar em conjunto com o CTBAFIN, antes estava sem isso funciona no CTBAFINTUR
If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documento
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.,,SE5->E5_DTDISPO)
		//Incluido esse IF para tratar a questão do PA
		If  nTotal > 0.00  // Contabilizou alguma linha G4C
			nTotDoc += nTotal
			If cTipoOper = '1' //Inclusão
				SE5->(RecLock("SE5",.F.))
				SE5->E5_LA := 'S'
				SE5->(MsUnLock())
			Else
				SE5->(RecLock("SE5",.F.))//ajustar
				SE5->E5_LA:= ''
				Msunlock()
			EndIf
		EndIF
//		End Transaction
	Endif
EndIf

IF Select(cAlias9) > 0
	(cAlias9)->(DbCloseArea())
ENDIF

/* Comentado esse trecho e colocado ele dentro do if do RodaProva
If  nTotal > 0.00  // Contabilizou alguma linha G4C
nTotDoc += nTotal
SE5->(RecLock("SE5",.F.))
SE5->E5_LA := 'S'
SE5->(MsUnLock())
EndIF
*/

RestArea(aAreaG4C)
RestArea(aAreaG8C)
RestArea(aAreaG3R)
RestArea(aAreaCT5)
RestArea(aAreaAtu)
RestArea(aAreaSE5)

Return(nRet)