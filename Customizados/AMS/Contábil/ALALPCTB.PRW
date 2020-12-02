#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ALALPCTB  ºAutor  ³Microsiga           º Data ³  06/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Retorna o conteúdo desejado no LP                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ pLP - Código do LP                                         º±±
±±º          ³ pSeq - Sequencia                                           º±±
±±º          ³ pOPC - Opção = CD-Conta Debito                             º±±
±±º          ³                CC-Conta Credito                            º±±
±±º          ³                VL-Valor                                    º±±
±±º          ³                HS-Historico                                º±±
±±º          ³                1D- Centro de Custo Debito                  º±±
±±º          ³                1C- Centro de Custo Credito                 º±±
±±º          ³                2D- Item Contábil Debito                    º±±
±±º          ³                2C- Item Contábil Credito                   º±±
±±º          ³                3D- Classe de Valor Debito                  º±±
±±º          ³                3C- Classe de Valor Credito                 º±±
±±º          ³                5D- Entidade 5 Debito                       º±±
±±º          ³                5C- Entidade 5 Credito                      º±±
±±º          ³                6D- Entidade 6 Debito                       º±±
±±º          ³                6C- Entidade 6 Credito                      º±±
±±º          ³                7D- Entidade 7 Debito                       º±±
±±º          ³                7C- Entidade 7 Credito                      º±±
±±º          ³                8D- Entidade 8 Debito                       º±±
±±º          ³                8C- Entidade 8 Credito                      º±±
±±º          ³ pPar - Conteudo adicional                                  º±±
±±º          ³ U_LPCTB("T00","001","CD","")								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ABC                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION LPCTB(pLP, pSEQ, pOPC, pPAR)

LOCAL _RET
LOCAL _aAREA := GETAREA()

PRIVATE cLP := IF(VALTYPE(pLP)=="C" ,pLP ,"")
PRIVATE cSEQ:= IF(VALTYPE(pSEQ)=="C",pSEQ,"")
PRIVATE cOPC:= IF(VALTYPE(pOPC)=="C",pOPC,"")
PRIVATE cPAR:= IF(VALTYPE(pPAR)=="C",pPAR,"")
IF EMPTY(cLP)
	RETURN("")
ENDIF

If cLP == "T24" .and. cSEQ == "000"
	_RET := _LPT24000()
ElseIf cLP == "T40" .and. cSEQ == "000"
	_RET := _LPT40000()
ElseIf cLP == "T24" .and. cSEQ == "045"
	_RET := _LPT24045()
ElseIf cLP == "T24" .and. cSEQ == "046"
	_RET := _LPT24046()
ElseIf cLP == "T30" .and. cSEQ == "020"
	_RET := _LPT30020()
ElseIf cLP == "T30" .and. cSEQ == "920"
	_RET := _LPT30920()
ElseIf cLP == "T30" .and. cSEQ == "030"
	_RET := _LPT30030()
ElseIf cLP == "T30" .and. cSEQ == "930"
	_RET := _LPT30930()
ElseIf cLP == "T44" .and. cSEQ == "001"
	_RET := _LPT44001()
ElseIf cLP == "T45" .and. cSEQ == "001"
	_RET := _LPT45001()
Else
	_RET := _LPT00001()
EndIf

Restarea(_aAREA)

RETURN(_RET)

/************************************** T00/001 - ITEM DE VENDA                 */
STATIC FUNCTION _LPT00001

Local cRet      := "3" //1=Cartão Cliente / 2 = Cartão Agencia / 3 = Não existe Cartão para este RV
Local cQuery    := ''
Local cAliasQ1  := GetNextAlias()	//CriaTrab(nil,.F.)	//GetNextAlias()
Local cAliasG4C := GetArea("G4C")
//alert(copc)

If cOPC == "VL"
	
	DbSelectArea("G4D")
	DbSetOrder(1)
	If G4D->(MSSeek(XFILIAL("G4D")+G4C->G4C_NUMID+G4C->G4C_IDITEM+G4C->G4C_NUMSEQ))
		If ALLTRIM(G4D->G4D_PROPRI) == "1" //Cartão do Cliente
			cRet := "1"
		Elseif ALLTRIM(G4D->G4D_PROPRI) == "2" //Cartão da Agencia
			cRet := "2"
		Else
			G3Q->(DbSetOrder(1))
			IF G3Q->(DbSeek(xFilial("G3Q")+G4C->(G4C_NUMID+G4C_IDITEM+G4C_NUMSEQ+G4C_CONINU),.F.)) .AND. G3Q->G3Q_FORMPG == "000011"
				cRet := "1"
			ELSE
				cRet := "3"
			ENDIF
		EndIf
	Else // nao encontre G4D
		G3Q->(DbSetOrder(1))
		IF G3Q->(DbSeek(xFilial("G3Q")+G4C->(G4C_NUMID+G4C_IDITEM+G4C_NUMSEQ+G4C_CONINU),.F.)) .AND. G3Q->G3Q_FORMPG == "000011"
			cRet := "1"
		ELSE
			cRet := "3"
		ENDIF
	EndIf
	
ElseIf cOPC == "VL2"
	
	cRet := ALLTRIM(G85->G85_GRPPRD)
	
	If !Empty(G85->G85_CODAPU)
		_cQuery := " SELECT G4C_CODAPU, G4C_GRPPRD FROM "+ RetsqlName("G4C")
		_cQuery += " WHERE G4C_FILIAL = '"+G85->G85_FILIAL+ "'"
		_cQuery += " AND G4C_CODAPU = '"+G85->G85_CODAPU+ "'"
		//_cQuery += " AND D_E_L_E_T_ = ''"
		_cQuery += " AND D_E_L_E_T_ <> '*'"
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQ1,.T.,.T.)
		
		DbSelectArea(cAliasQ1)
		
		IF (cAliasQ1)->(!EOF())
			cRet := ALLTRIM((cAliasQ1)->G4C_GRPPRD)
		EndIf
		
		(cAliasQ1)->(DbCloseArea())
	Else
		DbSelectArea("G4C")
		DbSetOrder(1)
		If G4C->(MSSeek(G85->(G85_FILIAL+G85_REGVEN+G85_ITVEND+G85_SEQIV)))
			cRet := ALLTRIM(G4C->G4C_GRPPRD)
		EndIf
	EndIf
	
EndIf

RestArea(cAliasG4C)

Return(cRet)

/************************************** T24/000 - DESCONTA/JUROS DAS Apurações */
STATIC FUNCTION _LPT24000

Local cRet      := 0
Local cAliasG6M := GetArea("G6M")

If cOPC == "VL"
	If !Empty(G85->G85_CODAPU)
		DbSelectArea("G6M")
		DbSetOrder(1)
		If G6M->(MSSeek(G6M->G6M_FILIAL+G85->(G85_CODAPU+G85_CLASS)))
			cRet := (G85->G85_VALOR - G6M->G6M_VLTXAD) + G6M->G6M_VLDESC
		Else
			cRet := G85->G85_VALOR
		EndIf
	Else
		cRet := G85->G85_VALOR
	EndIf
EndIF

RestArea(cAliasG6M)

Return(cRet)


/************************************** T40/000 - Descrição dos Clientes/Fornecedores das Apurações */
STATIC FUNCTION _LPT40000

Local cRet := ''
Local cAliasSA1 := GetArea("SA1")
Local cAliasSA2 := GetArea("SA2")

If SUBSTR(ALLTRIM(G81->G81_CLASS),1,1) = 'C'
	DbSelectArea("SA1")
	DbSetOrder(1)
	If SA1->(MSSeek(SA1->A1_FILIAL+G81->(G81_CLIENT+G81_LOJA)))
		cRet := ALLTRIM(SA1->A1_NOME)
	EndIf
Else
	DbSelectArea("SA2")
	DbSetOrder(1)
	If SA2->(MSSeek(SA2->A2_FILIAL+G81->(G81_CLIENT+G81_LOJA)))
		cRet := ALLTRIM(SA2->A2_NOME)
	EndIf
EndIf

RestArea(cAliasSA1)
RestArea(cAliasSA2)

Return(cRet)

//************************************** T24/045 - Rateio das Apurações pelos RV's */
Static Function _LPT24045()

Local nRet			:= 0
Local _cQuery		:= ''
Local _cQuery2		:= ''
Local _cLa			:= 'N'
Local _cNumApu		:= ''
Local _cClass		:= ''
Local nTotalLcto	:= 0
Local cLote			:= LoteCont("TUR")
Local cProg			:= "CTBATUR"
Local cArquivo		:= ""
Local nHdlPrv		:= HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
Local _lDigita
Local cAliasG85		:= GetNextAlias()
Local cAliasG6M		:= GetNextAlias()
Local cDelG85		:= "%G85.D_E_L_E_T_ <> '*'%"
Local cDelG6M		:= "%G6M.D_E_L_E_T_ <> '*'%"
Local cDelG81		:= "%G81.D_E_L_E_T_ <> '*'%"

Public _cAliasG4C := GetNextAlias()

If ISINCALLSTACK("CTBATUR")
	Pergunte("CTBATUR",.F.)
	_lDigita:=IIF(mv_par01==1,.T.,.F.)
Else
	_lDigita:= .F.
EndIf

_cQuery:="SELECT G4C_FILIAL, G4C_NUMID, G4C_IDITEM, G4C_NUMSEQ, G4C_CODAPU, G4C_CLASS, G4C_VALOR, G4C_GRPPRD, G4C_CODIGO, G4C_LOJA, G4C_OPERAC FROM "+RetSqlName("G4C")+" G4C "
_cQuery+="WHERE "
_cQuery+="G4C.G4C_CODAPU= '"+G85->G85_CODAPU+"' "
_cQuery+="AND G4C.G4C_CLASS = '"+G85->G85_CLASS+"' "
_cQuery+="AND G4C.G4C_FILIAL = '"+G85->G85_FILREF+"' "
//_cQuery+="AND G4C.D_E_L_E_T_='' "
_cQuery+="AND G4C.D_E_L_E_T_<>'*' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAliasG4C,.T.,.T.)

dbSelectArea(_cAliasG4C)
(_cAliasG4C)->(dbGoTop())

If !Empty((_cAliasG4C)->G4C_CODAPU)
	_cLa := 'S'
	_cNumApu := (_cAliasG4C)->G4C_CODAPU
	_cClass  := (_cAliasG4C)->G4C_CLASS
EndIf

If cOPC = '1' //Contabiliza Apuração Cliente
	while !EOF()
		If (_cAliasG4C)->G4C_VALOR > 0
			nTotalLcto += DetProva(nHdlPrv,"T90",cProg,cLote) // T01 é o LP especifico
		EndIf
		(_cAliasG4C)->(DBSKIP())
	ENDDO
ElseIf cOPC = '2' //Estorno da Contabiliza Apuração Cliente
	while !EOF()
		If (_cAliasG4C)->G4C_VALOR > 0
			nTotalLcto += DetProva(nHdlPrv,"T91",cProg,cLote) // T01 é o LP especifico
		EndIf
		(_cAliasG4C)->(DBSKIP())
	ENDDO
	
EndIF

If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documento
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.)
//		End Transaction
	Endif
EndIf

If _cLa = 'S'
/*/	
	_cQuery2 := "UPDATE " + RetSqlName("G85") + " G85 SET G85_LA = '"+_cLa+"'"
	_cQuery2 += " WHERE  G85_FILREF = '" +xFilial("G85") +"'"
	_cQuery2 += " AND G85_CODAPU = '"+ _cNumApu +"'"
	_cQuery2 += " AND G85_CLASS = '"+ _cClass +"'"	
//	_cQuery2 += " AND (SELECT G6M_VLTXAD   FROM "+RetSqlName("G6M")+" G6M " //SUBQUERY SO FARA O UPDATE SE G6M_VLTXAD FOR MENOU OU IGUAL A ZERO
//	_cQuery2 += " WHERE  G6M_FILREF = '" + G85->G85_FILREF + "'"
//	_cQuery2 +="  AND G6M_CODAPU = '" +G85->G85_CODAPU +"'" + " AND G6M.D_E_L_E_T_ <> '*' ) <= 0 "
	_cQuery2 += " AND D_E_L_E_T_ <> '*'"
	
	TCSQLEXEC(_cQuery2)
/*/

//G85 para a G81 
//G85_FILREF+G85_CODAPU+G85_IDFA	G81_FILREF+G81_CODAPU+G81_IDFA

//G81 para a G6M
//G81_FILIAL+G81_CODAPU+G81_SEGNEG+G81_CLASS	G6M_FILIAL+G6M_CODAPU+G6M_SEGNEG+G6M_TIPOAC

	BeginSQL Alias cAliasG85
		SELECT G85_FILREF, G85_CODAPU, G85.R_E_C_N_O_ AS G85REC,G81_FILIAL,G81_CODAPU,G81_SEGNEG,G81_CLASS
		FROM %table:G85% G85 (NOLOCK), %table:G81% G81 (NOLOCK)
		WHERE G85_FILREF	= %Exp:xFilial("G85")%
		AND G85_CODAPU		= %exp:_cNumApu%
		AND G85_CLASS		= %exp:_cClass%
		AND G85_FILREF		= %exp:G81->G81_FILREF%
		AND G85_CODAPU		= %exp:G81->G81_CODAPU%
		AND G85_IDIFA		= %exp:G81->G81_IDIFA%
    	AND %Exp:cDelG85%
    	AND %Exp:cDelG81%
	EndSQL

	BeginSql Alias cAliasG6M
		SELECT G6M_VLTXAD
		FROM %table:G6M% G6M (NOLOCK)
		JOIN %table:G81% G81 (NOLOCK)
		ON G6M_FILIAL		= G81_FILIAL
		AND G81_CODAPU		= G6M_CODAPU
		AND G81_SEGNEG		= G6M_SEGNEG
		AND G81_CLASS		= G6M_TIPOAC
		WHERE G6M_FILIAL	= %Exp:(cAliasG85)->G81_FILIAL%
		AND G6M_CODAPU	 	= %exp:(cAliasG85)->G81_CODAPU%
		AND G6M_SEGNEG		= %exp:(cAliasG85)->G81_SEGNEG%
		AND G6M_TIPOAC		= %exp:(cAliasG85)->G81_CLASS%
	   	AND %Exp:cDelG6M%
		AND %Exp:cDelG81%
	EndSql
	
	If Select((cAliasG85)) > 0 .and. (cAliasG6M)->G6M_VLTXAD <= 0
		aAreaG85 := G85->(GetArea())
		DbSelectArea("G85")
		DbGoto((cAliasG85)->G85REC)
		RecLock("G85",.F.)
			G85_LA := _cLa
		MsUnLock()
		RestArea(aAreaG85)
	EndIf
	If Select(cAliasG85) > 0
		(cAliasG85)->(DbCloseArea())
	EndIf
	If Select(cAliasG6M) > 0
		(cAliasG6M)->(DbCloseArea())
	EndIf
EndIf

IF Select(_cAliasG4C) > 0
	(_cAliasG4C)->(DbCloseArea())
ENDIF
Return(nRet)


//************************************** T24/046 -  */
Static Function _LPT24046()

Local nRet			:= 0
Local _cQuery		:= ''
Local _cQuery2		:= ''
Local _cLa			:= 'N'
Local _cNumApu		:= ''
Local _cClass		:= ''
Local nTotalLcto	:= 0
Local cLote			:= LoteCont("TUR")
Local cProg			:= "CTBATUR"
Local cArquivo		:= ""
Local nHdlPrv		:= HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
Local _lDigita
Local cAliasG4C		:= GetNextAlias()
Local cAliasG85		:= GetNextAlias()
Local cAliasG6M		:= GetNextAlias()
Local cDelG4C		:= "%G4C.D_E_L_E_T_ <> '*'%"
Local cDelG85		:= "%G85.D_E_L_E_T_ <> '*'%"
Local cDelG6M		:= "%G6M.D_E_L_E_T_ <> '*'%"
Local cDelG81		:= "%G81.D_E_L_E_T_ <> '*'%"

Private nVLTXAD		:= 0

Public _cAliasG4C := GetNextAlias()

If ISINCALLSTACK("CTBATUR")
	Pergunte("CTBATUR",.F.)
	_lDigita:=IIF(mv_par01==1,.T.,.F.)
Else
	_lDigita:= .F.
EndIf

If !Empty(G85->G85_CODAPU)
	_cLa := 'S'
	_cNumApu := G85->G85_CODAPU
	_cClass  := G85->G85_CLASS

	BeginSQL Alias cAliasG85
		SELECT G85_FILREF, G85_CODAPU, G85.R_E_C_N_O_ AS G85REC,G81_FILIAL,G81_CODAPU,G81_SEGNEG,G81_CLASS
		FROM %table:G85% G85 (NOLOCK), %table:G81% G81 (NOLOCK)
		WHERE G85_FILREF	= %Exp:xFilial("G85")%
		AND G85_CODAPU		= %exp:_cNumApu%
		AND G85_CLASS		= %exp:_cClass%
		AND G85_FILREF		= G81_FILREF
		AND G85_CODAPU		= G81_CODAPU
		AND G85_IDIFA		= G81_IDIFA
	   	AND %Exp:cDelG85%
	   	AND %Exp:cDelG81%
	EndSQL
	cQueryG85 := GetLastQuery()[2]
	BeginSql Alias cAliasG6M
		SELECT G6M_VLTXAD
		FROM %table:G6M% G6M (NOLOCK)
		JOIN %table:G81% G81 (NOLOCK)
		ON G81_FILIAL		= G6M_FILIAL
		AND G81_CODAPU		= G6M_CODAPU
		AND G81_SEGNEG		= G6M_SEGNEG
		AND G81_CLASS		= G6M_TIPOAC
		WHERE G6M_FILIAL	= %Exp:(cAliasG85)->G81_FILIAL%
		AND G6M_CODAPU	 	= %exp:_cNumApu%
		AND G6M_SEGNEG		= %exp:(cAliasG85)->G81_SEGNEG%
		AND G6M_TIPOAC		= %exp:_cClass%
	   	AND %Exp:cDelG6M%
		AND %Exp:cDelG81%
	EndSql
	cQueryG6M := GetLastQuery()[2]
	nVLTXAD := (cAliasG6M)->G6M_VLTXAD		// variavel para contabilização
	If (cAliasG6M)->G6M_VLTXAD > 0
		If cOPC = '1' //Contabiliza Apuração Cliente
			While !EOF()
				If (cAliasG6M)->G6M_VLTXAD > 0
					nTotalLcto += DetProva(nHdlPrv,"T81",cProg,cLote) // T01 é o LP especifico
				EndIf
				(cAliasG6M)->(DBSKIP())
			EndDo
		ElseIf cOPC = '2' //Estorno da Contabiliza Apuração Cliente
			While !EOF()
				If (cAliasG6M)->G6M_VLTXAD > 0
					nTotalLcto += DetProva(nHdlPrv,"T83",cProg,cLote) // T01 é o LP especifico
				EndIf
				(cAliasG6M)->(DBSKIP())
			EndDo
		EndIF
	
		If nHdlPrv > 0
			Rodaprova(nHdlPrv,nTotalLcto)
			If nTotalLcto > 0
				nTotalLcto := 0
				//Cria transacao para garantir atualizacao do documento
				cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.)
			Endif
		EndIf
		If _cLa = 'S'
			aAreaG85 := G85->(GetArea())
			DbSelectArea("G85")
			DbGoto((cAliasG85)->G85REC)
			RecLock("G85",.F.)
				G85_LA := _cLa
			MsUnLock()
			RestArea(aAreaG85)
		EndIf
	EndIf
	If Select(cAliasG85) > 0
		(cAliasG85)->(DbCloseArea())
	EndIf
	If Select(cAliasG6M) > 0
		(cAliasG6M)->(DbCloseArea())
	EndIf
EndIf

IF Select(_cAliasG4C) > 0
	(_cAliasG4C)->(DbCloseArea())
ENDIF

Return(nRet)
//************************************** T44/001 - Contabilização Apuração de Metas Inconsistencias */
Static Function _LPT44001()

Local nRet      := 0
Local _cQuery   := ''
Local _cQuery2  := ''
Local _cQuery3  := ''
Local _cQuery4  := ''
Local nTotalLcto := 0
Local cLote      := LoteCont("TUR")
Local cProg      := "CTBATUR"
Local cArquivo   := ""
Local nHdlPrv    := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
Local _cAlG6Efai := "" //Alias da Faixa Desejada
Local _cAlG6Efat := "" //Alias da Faixa Apurado
Local _nPercFai  := 0
Local _nPercFat  := 0
Local _aAliasG6D := GetArea("G6D")
Local _cLa       := 'N'
Local _cCodApu   := ''
Local _lUsaFlag := GetNewPar("MV_CTBFLAG",.F.)
Local _lDigita

Private _nVlrIncon := 0 //valor da inconsistencia maior ou menor
Private _nVlrInter := 0 //valor da inconsistencia inteiro (-)
Private cAliasG6O  := GetNextAlias()

If ISINCALLSTACK("CTBATUR")
	Pergunte("CTBATUR",.F.)
	_lDigita:=IIF(mv_par01==1,.T.,.F.)
Else
	_lDigita:= .F.
EndIf

_cQuery:="SELECT G6O_FILIAL, G6O_CODAPU, G6O_CODACD, G6O_CODREV, G6O_VLBASE, G6O_VALOR, G6O_FAIXA, G6O_FXATU FROM "+RetSqlName("G6O")+" G6O "
_cQuery+="WHERE G6O.G6O_FILIAL = '"+G6L->G6L_FILIAL+"' "
_cQuery+="AND G6O.G6O_CODAPU = '"+G6L->G6L_CODAPU+"' "
_cQuery+="AND G6O.D_E_L_E_T_= '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasG6O,.T.,.T.)

dbSelectArea(cAliasG6O)
(cAliasG6O)->(dbGoTop())

DbSelectArea("G6D")
G6D->(DbSetOrder(1))

while (cAliasG6O)->(!EOF())
	
	If ALLTRIM((cAliasG6O)->G6O_FXATU) <> ALLTRIM((cAliasG6O)->G6O_FAIXA)
		If G6D->(MSSeek(G6D->G6D_FILIAL+(cAliasG6O)->(G6O_CODACD+G6O_CODREV)))
			If ALLTRIM(G6D->G6D_TPVLR) = '2' // por valor fixo
				_cAlG6Efai := GetNextAlias()
				_cAlG6Efat := GetNextAlias()
				
				_cQuery2:="SELECT G6E_CODACO, G6E_CODREV, G6E_FAIXA, G6E_VALOR FROM "+RetSqlName("G6E")+" G6E "
				_cQuery2+="WHERE G6E.G6E_FILIAL = " + (cAliasG6O)->G6O_FILIAL+"' "
				_cQuery2+="AND G6E.G6E_CODACO= '"+(cAliasG6O)->G6O_CODACD+"' "
				_cQuery2+="AND G6E.G6E_CODREV= '"+(cAliasG6O)->G6O_CODREV+"' "
				_cQuery2+="AND G6E.G6E_FAIXA=  '"+(cAliasG6O)->G6O_FAIXA+"' "	//Faixa Desejada
				_cQuery2+="AND G6E.D_E_L_E_T_= ''"
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery2),_cAlG6Efai,.T.,.T.)
				
				_cQuery3:="SELECT G6E_CODACO, G6E_CODREV, G6E_FAIXA, G6E_VALOR FROM "+RetSqlName("G6E")+" G6E "
				_cQuery3+="WHERE G6E.G6E_FILIAL = " + (cAliasG6O)->G6O_FILIAL+"' "
				_cQuery3+="AND G6E.G6E_CODACO= '"+(cAliasG6O)->G6O_CODACD+"' "
				_cQuery3+="AND G6E.G6E_CODREV= '"+(cAliasG6O)->G6O_CODREV+"' "
				_cQuery3+="AND G6E.G6E_FAIXA=  '"+(cAliasG6O)->G6O_FXATU+"' "  //Faixa Apurada
				_cQuery3+="AND G6E.D_E_L_E_T_= '' "
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery3),_cAlG6Efat,.T.,.T.)
				//Faixa Desejada           //Faixa Apurada
				_nVlrIncon := (_cAlG6Efai)->G6E_VALOR - (_cAlG6Efat)->G6E_VALOR
				
				If _nVlrIncon < 0
					_nVlrInter := _nVlrIncon * -1
				Else
					_nVlrInter := _nVlrIncon
				EndIf
				
				(_cAlG6Efat)->(DbCloseArea())
				(_cAlG6Efai)->(DbCloseArea())
				
			ElseIf ALLTRIM(G6D->G6D_TPVLR) = '1' // por porcentagem
				_cAlG6Efai := GetNextAlias()
				_cAlG6Efat := GetNextAlias()
				
				_cQuery2:="SELECT G6E_CODACO, G6E_CODREV, G6E_FAIXA, G6E_VALOR FROM "+RetSqlName("G6E")+" G6E "
				_cQuery2+="WHERE G6E.G6E_FILIAL = " + (cAliasG6O)->G6O_FILIAL+"' "
				_cQuery2+="AND G6E.G6E_CODACO= '"+(cAliasG6O)->G6O_CODACD+"' "
				_cQuery2+="AND G6E.G6E_CODREV= '"+(cAliasG6O)->G6O_CODREV+"' "
				_cQuery2+="AND G6E.G6E_FAIXA=  '"+(cAliasG6O)->G6O_FAIXA+"' "	//Faixa Desejada
				_cQuery2+="AND G6E.D_E_L_E_T_= '' "
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery2),_cAlG6Efai,.T.,.T.)
				
				_cQuery3:="SELECT G6E_CODACO, G6E_CODREV, G6E_FAIXA, G6E_VALOR FROM "+RetSqlName("G6E")+" G6E "
				_cQuery3+="WHERE G6E.G6E_FILIAL = " + (cAliasG6O)->G6O_FILIAL+"' "
				_cQuery3+="AND G6E.G6E_CODACO= '"+(cAliasG6O)->G6O_CODACD+"' "
				_cQuery3+="AND G6E.G6E_CODREV= '"+(cAliasG6O)->G6O_CODREV+"' "
				_cQuery3+="AND G6E.G6E_FAIXA=  '"+(cAliasG6O)->G6O_FXATU+"' "  //Faixa Apurada
				_cQuery3+="AND G6E.D_E_L_E_T_= '' "
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery3),_cAlG6Efat,.T.,.T.)
				
				_nPercFai := (_cAlG6Efai)->G6E_VALOR / 100 //Faixa Desejada
				_nPercFat := (_cAlG6Efat)->G6E_VALOR / 100 //Faixa Apurada
				
				_nVlrIncon := ((cAliasG6O)->G6O_VLBASE * _nPercFai) - ((cAliasG6O)->G6O_VLBASE * _nPercFat)
				
				If _nVlrIncon < 0
					_nVlrInter := _nVlrIncon * -1
				Else
					_nVlrInter := _nVlrIncon
				EndIf
				
				(_cAlG6Efat)->(DbCloseArea())
				(_cAlG6Efai)->(DbCloseArea())
				
			EndIf
			
			If _nVlrInter > 0
				nTotalLcto += DetProva(nHdlPrv,"T92",cProg,cLote) // T01 é o LP especifiCO / aTabRecOri := {"SE5",SE5->RECNO()}
			EndIf
			_cCodApu :=	(cAliasG6O)->(G6O_CODAPU)
		EndIf
	Else
		If _nVlrInter = 0
			nTotalLcto += DetProva(nHdlPrv,"T92",cProg,cLote) // T01 é o LP especifico / aTabRecOri := {"SE5",SE5->RECNO()}
		EndIf
		_cCodApu :=	(cAliasG6O)->(G6O_CODAPU)
	EndIf
	
	(cAliasG6O)->(DBSKIP())
	
ENDDO

If nTotalLcto > 0
	_cLa := 'S'
EndIf

If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documentWo
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.)
//		End Transaction
	Endif
EndIf

If _cLa = 'S'
	_cQuery4 := "UPDATE " + RetSqlName("G6L") + " SET G6L_LA = '"+ _cLa +"'"
	_cQuery4 += " WHERE  G6L_CODAPU = '"+ _cCodApu +"'"
	_cQuery4 += " AND D_E_L_E_T_ <> '*'"
	
	TCSQLEXEC(_cQuery4)
EndIf

G6D->(DbCloseArea())
RestArea(_aAliasG6D)
(cAliasG6O)->(DbCloseArea())

Return(nRet)

//************************************** T45/001 - Estorno Contabilização Apuração de Metas Inconsistencias */
Static Function _LPT45001()

Local nRet      := 0
Local _cQuery   := ''
Local _cQuery2  := ''
Local _cQuery3  := ''
Local _cQuery4  := ''
Local nTotalLcto := 0
Local cLote      := LoteCont("TUR")
Local cProg      := "CTBATUR"
Local cArquivo   := ""
Local nHdlPrv    := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
Local _cAlG6Efai := "" //Alias da Faixa Desejada
Local _cAlG6Efat := "" //Alias da Faixa Apurado
Local _nPercFai  := 0
Local _nPercFat  := 0
Local _aAliasG6D := GetArea("G6D")
Local _cLa       := ''
Local _cCodApu   := ''
Local _lDigita

Private _nVlrIncon := 0 //valor da inconsistencia maior ou menor
Private _nVlrInter := 0 //valor da inconsistencia inteiro (-)
Private cAliasG6O  := GetNextAlias()

If ISINCALLSTACK("CTBATUR")
	Pergunte("CTBATUR",.F.)
	_lDigita:=IIF(mv_par01==1,.T.,.F.)
Else
	_lDigita:= .F.
EndIf

_cQuery:="SELECT G6O_FILIAL, G6O_CODAPU, G6O_CODACD, G6O_CODREV, G6O_VLBASE, G6O_VALOR, G6O_FAIXA, G6O_FXATU FROM "+RetSqlName("G6O")+" G6O "
_cQuery+="WHERE G6O.G6O_FILIAL = " +G6L->G6L_FILIAL+"' "
_cQuery+="AND G6O.G6O_CODAPU = '"+G6L->G6L_CODAPU+"' "
_cQuery+="AND G6O.D_E_L_E_T_= '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasG6O,.T.,.T.)

dbSelectArea(cAliasG6O)
(cAliasG6O)->(dbGoTop())

DbSelectArea("G6D")
G6D->(DbSetOrder(1))

while (cAliasG6O)->(!EOF())
	
	If ALLTRIM((cAliasG6O)->G6O_FXATU) <> ALLTRIM((cAliasG6O)->G6O_FAIXA)
		If G6D->(MSSeek(G6D->G6D_FILIAL+(cAliasG6O)->(G6O_CODACD+G6O_CODREV)))
			If ALLTRIM(G6D->G6D_TPVLR) = '2' // por valor fixo
				_cAlG6Efai := GetNextAlias()
				_cAlG6Efat := GetNextAlias()
				
				_cQuery2:="SELECT G6E_CODACO, G6E_CODREV, G6E_FAIXA, G6E_VALOR FROM "+RetSqlName("G6E")+" G6E "
				_cQuery2+="WHERE G6E.G6E_FILIAL = " + (cAliasG6O)->G6O_FILIAL+"' "
				_cQuery2+="AND G6E.G6E_CODACO= '"+(cAliasG6O)->G6O_CODACD+"' "
				_cQuery2+="AND G6E.G6E_CODREV= '"+(cAliasG6O)->G6O_CODREV+"' "
				_cQuery2+="AND G6E.G6E_FAIXA=  '"+(cAliasG6O)->G6O_FAIXA+"' "	//Faixa Desejada
				_cQuery2+="AND G6E.D_E_L_E_T_= ''"
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery2),_cAlG6Efai,.T.,.T.)
				
				_cQuery3:="SELECT G6E_CODACO, G6E_CODREV, G6E_FAIXA, G6E_VALOR FROM "+RetSqlName("G6E")+" G6E "
				_cQuery3+="WHERE G6E.G6E_FILIAL = " + (cAliasG6O)->G6O_FILIAL+"' "
				_cQuery3+="AND G6E.G6E_CODACO= '"+(cAliasG6O)->G6O_CODACD+"' "
				_cQuery3+="AND G6E.G6E_CODREV= '"+(cAliasG6O)->G6O_CODREV+"' "
				_cQuery3+="AND G6E.G6E_FAIXA=  '"+(cAliasG6O)->G6O_FXATU+"' "  //Faixa Apurada
				_cQuery3+="AND G6E.D_E_L_E_T_= '' "
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery3),_cAlG6Efat,.T.,.T.)
				//Faixa Desejada           //Faixa Apurada
				_nVlrIncon := (_cAlG6Efai)->G6E_VALOR - (_cAlG6Efat)->G6E_VALOR
				
				If _nVlrIncon < 0
					_nVlrInter := _nVlrIncon * -1
				Else
					_nVlrInter := _nVlrIncon
				EndIf
				
				(_cAlG6Efat)->(DbCloseArea())
				(_cAlG6Efai)->(DbCloseArea())
				
			ElseIf ALLTRIM(G6D->G6D_TPVLR) = '1' // por porcentagem
				_cAlG6Efai := GetNextAlias()
				_cAlG6Efat := GetNextAlias()
				
				_cQuery2:="SELECT G6E_CODACO, G6E_CODREV, G6E_FAIXA, G6E_VALOR FROM "+RetSqlName("G6E")+" G6E "
				_cQuery2+="WHERE G6E.G6E_FILIAL = " + (cAliasG6O)->G6O_FILIAL+"' "
				_cQuery2+="AND G6E.G6E_CODACO= '"+(cAliasG6O)->G6O_CODACD+"' "
				_cQuery2+="AND G6E.G6E_CODREV= '"+(cAliasG6O)->G6O_CODREV+"' "
				_cQuery2+="AND G6E.G6E_FAIXA=  '"+(cAliasG6O)->G6O_FAIXA+"' "	//Faixa Desejada
				_cQuery2+="AND G6E.D_E_L_E_T_= '' "
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery2),_cAlG6Efai,.T.,.T.)
				
				_cQuery3:="SELECT G6E_CODACO, G6E_CODREV, G6E_FAIXA, G6E_VALOR FROM "+RetSqlName("G6E")+" G6E "
				_cQuery3+="WHERE G6E.G6E_FILIAL = " + (cAliasG6O)->G6O_FILIAL+"' "
				_cQuery3+="AND G6E.G6E_CODACO= '"+(cAliasG6O)->G6O_CODACD+"' "
				_cQuery3+="AND G6E.G6E_CODREV= '"+(cAliasG6O)->G6O_CODREV+"' "
				_cQuery3+="AND G6E.G6E_FAIXA=  '"+(cAliasG6O)->G6O_FXATU+"' "  //Faixa Apurada
				_cQuery3+="AND G6E.D_E_L_E_T_= '' "
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery3),_cAlG6Efat,.T.,.T.)
				
				_nPercFai := (_cAlG6Efai)->G6E_VALOR / 100 //Faixa Desejada
				_nPercFat := (_cAlG6Efat)->G6E_VALOR / 100 //Faixa Apurada
				
				_nVlrIncon := ((cAliasG6O)->G6O_VLBASE * _nPercFai) - ((cAliasG6O)->G6O_VLBASE * _nPercFat)
				
				If _nVlrIncon < 0
					_nVlrInter := _nVlrIncon * -1
				Else
					_nVlrInter := _nVlrIncon
				EndIf
				
				(_cAlG6Efat)->(DbCloseArea())
				(_cAlG6Efai)->(DbCloseArea())
				
			EndIf
			
			If _nVlrInter > 0
				nTotalLcto += DetProva(nHdlPrv,"T93",cProg,cLote) // T01 é o LP especifico
			EndIf
			_cCodApu :=	(cAliasG6O)->(G6O_CODAPU)
		EndIf
	Else
		If _nVlrInter = 0
			nTotalLcto += DetProva(nHdlPrv,"T93",cProg,cLote) // T01 é o LP especifico
		EndIf
		_cCodApu :=	(cAliasG6O)->(G6O_CODAPU)
	EndIf
	
	(cAliasG6O)->(DBSKIP())
	
ENDDO

If nTotalLcto > 0
	_cLa := 'N'
EndIf

If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documentWo
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.)
//		End Transaction
	Endif
EndIf

If _cLa = 'N'
	_cQuery4 := "UPDATE " + RetSqlName("G6L") + " SET G6L_LA = '"+ _cLa +"'"
	_cQuery4 += " WHERE  G6L_CODAPU = '"+ _cCodApu +"'"
	_cQuery4 += " AND D_E_L_E_T_ <> '*'"
	
	TCSQLEXEC(_cQuery4)
EndIf

G6D->(DbCloseArea())
RestArea(_aAliasG6D)
(cAliasG6O)->(DbCloseArea())

Return(nRet)

//************************************** T30/020 - Contabilização dos Acertos das Conciliações */
Static Function _LPT30020()

Local nRet := 0
Local _cQuery  := ''
Local _cQuery2 := ''
Local _cAliaG4C1 := GetNextAlias()
Local _cAliaG4C2 := GetNextAlias()

If !Empty(G4C->G4C_CONORI)
	//Antiga - Query para trazer os valores do Rv conciliados
	_cQuery:="SELECT G4C_VALOR, G4C_NUMID,G4C_IDITEM,G4C_NUMSEQ FROM "+RetSqlName("G4C")+" G4C "
	_cQuery+="WHERE "
	_cQuery+="G4C.G4C_FILIAL = '"+G4C->G4C_FILIAL+"' "
    _cQuery+="AND G4C.G4C_NUMID = '"+G4C->G4C_NUMID+"' "   //LINHA INCLUIDA EM 02/02/18 POR FABIO CAMPOS	
	_cQuery+="AND G4C.G4C_IDITEM = '"+G4C->G4C_IDITEM+"' "  //LINHA INCLUIDA EM 02/02/18 POR FABIO CAMPOS	
	_cQuery+="AND G4C.G4C_NUMSEQ = '"+G4C->G4C_NUMSEQ+"' "	 //LINHA INCLUIDA EM 02/02/18 POR FABIO CAMPOS
	_cQuery+="AND G4C.G4C_CLIFOR= '"+G4C->G4C_CLIFOR+"' "
	_cQuery+="AND G4C.G4C_NUMACD= '"+G4C->G4C_NUMACD+"' "
	_cQuery+="AND G4C.G4C_CLASS = '"+G4C->G4C_CLASS+"' "
	_cQuery+="AND G4C.G4C_CODIGO = '"+G4C->G4C_CODIGO+"' "
	_cQuery+="AND G4C.G4C_LOJA  = '"+G4C->G4C_LOJA+"' "
	_cQuery+="AND G4C.G4C_SEGNEG = '"+G4C->G4C_SEGNEG+"' "
	_cQuery+="AND G4C.G4C_CONORI = '"+G4C->G4C_CONORI+"' "  
	_cQuery+="AND G4C.G4C_CONINU= '' "
	_cQuery+="AND G4C.G4C_LA <> 'S' "
	//_cQuery+="AND G4C.D_E_L_E_T_= '' "
	_cQuery+="AND G4C.D_E_L_E_T_<> '*' "	
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAliaG4C1,.T.,.T.)
	
	//Query para trazer os valores do RV sem conciliação inutilizada
	_cQuery2:="SELECT G4C_VALOR, G4C_NUMID,G4C_IDITEM,G4C_NUMSEQ FROM "+RetSqlName("G4C")+" G4C "
	_cQuery2+="WHERE "
	_cQuery2+="G4C.G4C_FILIAL = '"+G4C->G4C_FILIAL+"' "
    _cQuery2+="AND G4C.G4C_NUMID = '"+G4C->G4C_NUMID+"' "   //LINHA INCLUIDA EM 02/02/18 POR FABIO CAMPOS	
 	_cQuery2+="AND G4C.G4C_IDITEM = '"+G4C->G4C_IDITEM+"' "  //LINHA INCLUIDA EM 02/02/18 POR FABIO CAMPOS	
 	_cQuery2+="AND G4C.G4C_NUMSEQ = '"+G4C->G4C_NUMSEQ+"' "	 //LINHA INCLUIDA EM 02/02/18 POR FABIO CAMPOS   
	_cQuery2+="AND G4C.G4C_CLIFOR = '"+G4C->G4C_CLIFOR+"' "
	_cQuery2+="AND G4C.G4C_NUMACD = '"+G4C->G4C_NUMACD+"' "
	_cQuery2+="AND G4C.G4C_CLASS = '"+G4C->G4C_CLASS+"' "
	_cQuery2+="AND G4C.G4C_CODIGO = '"+G4C->G4C_CODIGO+"' "
	_cQuery2+="AND G4C.G4C_LOJA  = '"+G4C->G4C_LOJA+"' "
	_cQuery2+="AND G4C.G4C_SEGNEG = '"+G4C->G4C_SEGNEG+"' "
	_cQuery2+="AND G4C.G4C_CONORI= '' "
	_cQuery2+="AND G4C.G4C_CONINU= '"+G4C->G4C_CONORI+"' "
	_cQuery2+="AND G4C.G4C_LA <> 'S' "
	//_cQuery2+="AND G4C.D_E_L_E_T_= '' "
	_cQuery2+="AND G4C.D_E_L_E_T_<> '*' "	
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery2),_cAliaG4C2,.T.,.T.)
	
	If (_cAliaG4C1)->(!EOF()) .and. (_cAliaG4C2)->(!EOF())
		If (_cAliaG4C1)->G4C_VALOR <> (_cAliaG4C2)->G4C_VALOR
			
			nRet := (_cAliaG4C1)->G4C_VALOR - (_cAliaG4C2)->G4C_VALOR
			
			If nRet < 0 //Se valor negativo
				nRet := ABS(nRet) //Tornar valor positivo
			EndIf
			
		EndIf
		
	EndIf
	
EndIf

IF select(_cAliaG4C1) > 0
	(_cAliaG4C1)->(DbCloseArea())
ENDIF

IF select(_cAliaG4C2) > 0
	(_cAliaG4C2)->(DbCloseArea())
ENDIF
Return(nRet)

//************************************** T30/920 - Contabiliziação dos Acertos das Conciliações debito e credito Terrestre */
Static Function _LPT30920()

Local cRet := ''
Local nRet := 1
Local _cQuery  := ''
Local _cQuery2 := ''
Local _cAliaG4C3 := GetNextAlias()
Local _cAliaG4C4 := GetNextAlias()

If !Empty(G4C->G4C_CONORI)
	//Query para trazer os valores do Rv conciliados
	_cQuery:="SELECT G4C_VALOR FROM "+RetSqlName("G4C")+" G4C "
	_cQuery+="WHERE "
	_cQuery+="G4C.G4C_FILIAL = '"+G4C->G4C_FILIAL+"' "
	_cQuery+="AND G4C.G4C_CLIFOR = '"+G4C->G4C_CLIFOR+"' "
	_cQuery+="AND G4C.G4C_NUMACD = '"+G4C->G4C_NUMACD+"' "
	_cQuery+="AND G4C.G4C_CLASS = '"+G4C->G4C_CLASS+"' "
	_cQuery+="AND G4C.G4C_CODIGO = '"+G4C->G4C_CODIGO+"' "
	_cQuery+="AND G4C.G4C_LOJA = '"+G4C->G4C_LOJA+"' "
	_cQuery+="AND G4C.G4C_SEGNEG = '"+G4C->G4C_SEGNEG+"' "
	_cQuery+="AND G4C.G4C_CONORI= '"+G4C->G4C_CONORI+"' "
	_cQuery+="AND G4C.G4C_CONINU= '' "
	_cQuery+="AND G4C.G4C_LA <> 'S' "
	//_cQuery+="AND G4C.D_E_L_E_T_= '' "
	_cQuery+="AND G4C.D_E_L_E_T_<> '*' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAliaG4C3,.T.,.T.)
	
	//Query para trazer os valores do RV sem concililção inutilizada
	_cQuery2:="SELECT G4C_VALOR FROM "+RetSqlName("G4C")+" G4C "
	_cQuery2+="WHERE "
	_cQuery2+="G4C.G4C_FILIAL = '"+G4C->G4C_FILIAL+"' "
	_cQuery2+="AND G4C.G4C_CLIFOR = '"+G4C->G4C_CLIFOR+"' "
	_cQuery2+="AND G4C.G4C_NUMACD = '"+G4C->G4C_NUMACD+"' "
	_cQuery2+="AND G4C.G4C_CLASS = '"+G4C->G4C_CLASS+"' "
	_cQuery2+="AND G4C.G4C_CODIGO = '"+G4C->G4C_CODIGO+"' "
	_cQuery2+="AND G4C.G4C_LOJA = '"+G4C->G4C_LOJA+"' "
	_cQuery2+="AND G4C.G4C_SEGNEG = '"+G4C->G4C_SEGNEG+"' "
	_cQuery2+="AND G4C.G4C_CONORI= '' "
	_cQuery2+="AND G4C.G4C_CONINU= '"+G4C->G4C_CONORI+"' "
	_cQuery2+="AND G4C.G4C_LA <> 'S' "
	//_cQuery2+="AND G4C.D_E_L_E_T_= '' "
	_cQuery2+="AND G4C.D_E_L_E_T_<> '*' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery2),_cAliaG4C4,.T.,.T.)
	
	If (_cAliaG4C3)->(!EOF()) .and. (_cAliaG4C4)->(!EOF())
		If (_cAliaG4C3)->G4C_VALOR <> (_cAliaG4C4)->G4C_VALOR
			
			nRet := (_cAliaG4C3)->G4C_VALOR - (_cAliaG4C4)->G4C_VALOR
			
			If nRet < 0 //Se valor negativo
				cRet := '2' //Quando o valor do acerto for menor que o valor do RV
			Else
				cRet := '1' //Quando o valor do acerto for maior que o valor do RV
			EndIf
			
		EndIf
		
	EndIf
	
EndIf

IF select(_cAliaG4C3) > 0
	(_cAliaG4C3)->(DbCloseArea())
ENDIF

IF select(_cAliaG4C4) > 0
	(_cAliaG4C4)->(DbCloseArea())
ENDIF

Return(cRet)

//************************************** T30/030 - Contabiliziação dos Acertos das Conciliações debito e credito Aereo*/
Static Function _LPT30030()

Local nRet := 0
Local _cQuery  := ''
Local _cAliaG4C5 := GetNextAlias()

//Query para trazer os valores do Rv conciliados com acerto
_cQuery:="SELECT G4C_VALOR FROM "+RetSqlName("G4C")+" G4C "
_cQuery+="WHERE "
_cQuery+="G4C.G4C_FILIAL = '"+G4C->G4C_FILIAL+"' "
_cQuery+="AND G4C.G4C_CLIFOR = '"+G4C->G4C_CLIFOR+"' "
_cQuery+="AND G4C.G4C_NUMID = '"+G4C->G4C_NUMID+"' "
_cQuery+="AND G4C.G4C_IDITEM = '"+G4C->G4C_IDITEM+"' "
_cQuery+="AND G4C.G4C_NUMSEQ = '"+G4C->G4C_NUMSEQ+"' " //INCLUSÃO DA LINHA FEITA POR FABIO CAMPOS EM 29/01/18
_cQuery+="AND G4C.G4C_CLASS = '"+G4C->G4C_CLASS+"' "
_cQuery+="AND G4C.G4C_CODIGO = '"+G4C->G4C_CODIGO+"' "
_cQuery+="AND G4C.G4C_LOJA = '"+G4C->G4C_LOJA+"' "
_cQuery+="AND G4C.G4C_SEGNEG = '"+G4C->G4C_SEGNEG+"' "
_cQuery+="AND G4C.G4C_ACERTO= '1' "//1=Acerto / 2=Não teve Acerto
_cQuery+="AND G4C.G4C_LA <> 'S' "
//_cQuery+="AND G4C.D_E_L_E_T_= '' "
_cQuery+="AND G4C.D_E_L_E_T_<> '*' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAliaG4C5,.T.,.T.)

If (_cAliaG4C5)->(!EOF())
	If (_cAliaG4C5)->G4C_VALOR > 0
		
		nRet := ABS((_cAliaG4C5)->G4C_VALOR)
	Else
		
		nRet := (_cAliaG4C5)->G4C_VALOR
	EndIf
EndIf

IF select(_cAliaG4C5) > 0
	(_cAliaG4C5)->(DbCloseArea())
ENDIF

Return(nRet)

//************************************** T30/930 - Contabiliziação dos Acertos das Conciliações debito e credito Terrestre */
Static Function _LPT30930()

Local cRet := ''
Local nRet := 1
Local _cQuery  := ''
Local _cAliaG4C6 := GetNextAlias()

//Query para trazer os valores do Rv conciliados
_cQuery:="SELECT G4C_VALOR FROM "+RetSqlName("G4C")+" G4C "
_cQuery+="WHERE "
_cQuery+="G4C.G4C_FILIAL = '"+G4C->G4C_FILIAL+"' "
_cQuery+="AND G4C.G4C_CLIFOR = '"+G4C->G4C_CLIFOR+"' "
_cQuery+="AND G4C.G4C_NUMID = '"+G4C->G4C_NUMID+"' "
_cQuery+="AND G4C.G4C_IDITEM = '"+G4C->G4C_IDITEM+"'
_cQuery+="AND G4C.G4C_CLASS = '"+G4C->G4C_CLASS+"' "
_cQuery+="AND G4C.G4C_CODIGO = '"+G4C->G4C_CODIGO+"' "
_cQuery+="AND G4C.G4C_LOJA = '"+G4C->G4C_LOJA+"' "
_cQuery+="AND G4C.G4C_SEGNEG = '"+G4C->G4C_SEGNEG+"' "
_cQuery+="AND G4C.G4C_ACERTO= '1' "//1=Acerto / 2=Não teve Acerto
_cQuery+="AND G4C.G4C_LA <> 'S' "
//_cQuery+="AND G4C.D_E_L_E_T_= '' "
_cQuery+="AND G4C.D_E_L_E_T_<> '*' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAliaG4C6,.T.,.T.)

If (_cAliaG4C6)->(!EOF())
	
	nRet := (_cAliaG4C6)->G4C_VALOR
	
	If nRet < 0 //Se valor negativo
		cRet := '2' //Quando o valor do acerto for menor que o valor do RV
	Else
		cRet := '1' //Quando o valor do acerto for maior que o valor do RV
	EndIf
	
EndIf

IF select(_cAliaG4C6) > 0
	(_cAliaG4C6)->(DbCloseArea())
ENDIF

Return(cRet)