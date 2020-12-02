#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"

// #########################################################################################
// Projeto: 11.90
// Modulo : SIGATUR
// Fonte  : Tratativa lp
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 18/01/17 | Totvs	    | Tratativa Lançamento Padrão SIGATUR
// #########################################################################################
User function 530_BXTUR(_cTipo) // Recebe o código da Classe

Local nRet:= 0
Local _cQuery := ''
Local _cQuerya := ''
Local nVlrFat := 0
Local nVlrParc := 0
Local nTotalLcto := 0
Local aArea := GetArea()
//Local aAreaSef := SEF->(GetArea())
//Local aAreaSe1 := SE1->(GetArea())
//Local aAreaSe2 := SE2->(GetArea())
//Local aAreaSe5 := SE5->(GetArea())
//Local aAreaCT5 := CT5->(GetArea())
Local cLote   := LoteCont("FIN")
Local cProg   := "FINA080"
Local cConcil := ""
Local cFatura := ""
Local cArquivo  	:= ""
Local nHdlPrv := 65536
//MBARROS Local nHdlPrv := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
//Local _lDigt
Local cDelG4C	:= "%G4C.D_E_L_E_T_ <> '*'%"
Local cDelG6I	:= "%G6I.D_E_L_E_T_ <> '*'%"

Private nVlrRV := 0
Private cAlias := GetNextAlias()
Private cAlias1 := GetNextAlias()
Private _lDigita
Private __cTurProcess := "P"

Public cAlias9 := GetNextAlias()

Public lxLP520 := .f.

IF Type("nTotDoc") == "U"
	nTotDoc := 0
ENDIF

_lDigita:= .F.

If ISINCALLSTACK("FINA370") .OR. ISINCALLSTACK("CTBAFIN")
	Pergunte("FIN370",.F.)
ElseIf ISINCALLSTACK("FINA080") .OR. ISINCALLSTACK("FINA750")
	Pergunte("FIN080",.F.)
ElseIf ISINCALLSTACK("FINA090")
	Pergunte("FIN090",.F.)
EndIf

_lDigita:=IIF(mv_par01==1,.T.,.F.)


If ALLTRIM(SE5->E5_PREFIXO) $ "FTC/ADC" 
	//Conciliação de Cartões
	_cQuerya:="SELECT G90_CODIGO FROM "+RetSqlName("G90")+" G90 "
	_cQuerya+="WHERE "
	_cQuerya+="G90.G90_FILIAL = '"+xFilial("G90")+"' "
	_cQuerya+="AND G90.G90_NUMFAT = '"+SE5->E5_NUMERO+"' "
//	_cQuerya+="AND G90.D_E_L_E_T_= '' "
//	_cQuerya+="AND G90.D_E_L_E_T_= '' "
	_cQuerya+="AND G90.D_E_L_E_T_ <> '*' "
ElseIf ALLTRIM(SE5->E5_PREFIXO) $ "FAP" 
	//Conciliação Aerea
	_cQuerya:="SELECT G8Y_FATURA FROM "+RetSqlName("G8Y")+" G8Y "
	_cQuerya+="WHERE "
	_cQuerya+="G8Y.G8Y_FILREF = '"+SE5->E5_FILIAL+"' "
	_cQuerya+="AND G8Y.G8Y_PREFIX = '"+SE5->E5_PREFIXO+"' "
	_cQuerya+="AND G8Y.G8Y_NUM = '"+SE5->E5_NUMERO+"' "
//	_cQuerya+="AND G8Y.D_E_L_E_T_ = '' "
	_cQuerya+="AND G8Y.D_E_L_E_T_ <> '*' "
Else
	//Conciliação Terrestre
	_cQuerya:="SELECT G8Y_DOC, G8Y_CONCIL, G8Y_VALOR  FROM "+RetSqlName("G8Y")+" G8Y "
	_cQuerya+="WHERE "
	_cQuerya+="G8Y.G8Y_FILIAL = '"+SE5->E5_FILIAL+"' "
	_cQuerya+="AND G8Y.G8Y_DOC = '"+SE5->E5_NUMERO+"' "
	_cQuerya+="AND G8Y.G8Y_FORNEC = '"+SE5->E5_CLIFOR+"' "
	_cQuerya+="AND G8Y.G8Y_TIPO = '"+SE5->E5_TIPO+"' "
//	_cQuerya+="AND G8Y.D_E_L_E_T_ = '' "
//	_cQuerya+="AND G8Y.D_E_L_E_T_ = '' "
	_cQuerya+="AND G8Y.D_E_L_E_T_ <> '*' 
EndIf

_cQuerya:= 	ChangeQuery(_cQuerya)
//cAlias1	:=	GetNextAlias()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuerya),cAlias1,.F.,.T.)
dbGoTop()

If ALLTRIM(SE5->E5_PREFIXO) $ "FTC/ADC"
	cConcil := (cAlias1)->G90_CODIGO
	(cAlias1)->(dbCloseArea())
ElseIf ALLTRIM(SE5->E5_PREFIXO) $ "FAP"
	cFatura := (cAlias1)->G8Y_FATURA
	(cAlias1)->(dbCloseArea())
Else
	cConcil := (cAlias1)->G8Y_CONCIL
	(cAlias1)->(dbCloseArea())
EndIf

If !Empty(cConcil)
	_cQuery:="SELECT SUM(G4C_VALOR) VLRFAT FROM "+RetSqlName("G4C")+" G4C "
	_cQuery+="WHERE "
	_cQuery+="G4C.G4C_FILIAL = '"+SE5->E5_FILIAL+"' "
	If ALLTRIM(SE5->E5_PREFIXO) $ "FTC/ADC"
		_cQuery+="AND G4C.G4C_CARTUR = '"+cConcil+"' "
		_cQuery+="AND G4C.G4C_FATCAR = '"+SE5->E5_NUMERO+"' "
	Else
		_cQuery+="AND G4C.G4C_CONORI = '"+cConcil+"' "
		_cQuery+="AND SUBSTRING(G4C.G4C_NATUR,1,3) = '200' "
	EndIF
//	_cQuery+="AND G4C.D_E_L_E_T_ = '' "
	_cQuery+="AND G4C.D_E_L_E_T_ <> '*' "
	
	_cQuery := 	ChangeQuery(_cQuery)
	//cAlias	:=	GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAlias,.F.,.T.)
	
ElseIf !Empty(cFatura)
	//cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT SUM(G4C_VALOR) VLRFAT
		FROM %Table:G6I% G6I
		INNER JOIN %table:G4C% G4C ON
		G4C_FILIAL = %Exp:SE5->E5_FILIAL%
		AND G4C_NUMID = G6I.G6I_NUMID
		AND G4C_IDITEM = G6I.G6I_IDITEM
		AND G4C_CLIFOR = '2'
		AND G4C_CLASS = " "
//		AND G4C.%NotDel%
		AND %Exp:cDelG4C%
		Where G6I_FILIAL = %Exp:xFilial("G6I")%
		AND G6I_FATURA = %Exp:cFatura%
//		AND G6I.%NotDel%
		AND %Exp:cDelG6I%
	EndSql
EndIF

If Select(cAlias) > 0
	nVlrFat:=(cAlias)->VLRFAT // Valor Total da Fatura.
	
	(cAlias)->(dbCloseArea())
	
	If !Empty(cConcil)
		_cQueryb:="SELECT G4C_NUMFAT, G4C_NUMID, G4C_IDITEM, G4C_NUMSEQ, G4C_CLASS, G4C_VALOR, G4C_CONORI, G4C_CONINU, G4C_GRPPRD, G4C_OPERAC, G4C_FATCAR, G4C_CLIFOR FROM "+RetSqlName("G4C")+" G4C "
		_cQueryb+="WHERE "
		_cQueryb+="G4C.G4C_FILIAL = '"+SE5->E5_FILIAL+"' "
		If ALLTRIM(SE5->E5_PREFIXO) $ "FTC/ADC"
			_cQueryb+="AND G4C.G4C_CARTUR = '"+cConcil+"' "
			_cQueryb+="AND G4C.G4C_FATCAR = '"+SE5->E5_NUMERO+"' "
		Else
			_cQueryb+="AND G4C.G4C_CONORI = '"+cConcil+"' "
			_cQueryb+="AND SUBSTRING(G4C.G4C_NATUR,1,3) = '200' "
		EndIF
//		_cQueryb+="AND G4C.D_E_L_E_T_ = '' "
		_cQueryb+="AND G4C.D_E_L_E_T_ <> '*' "
		
		_cQueryb := ChangeQuery(_cQueryb)
		cAlias9	:=	GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQueryb),cAlias9,.F.,.T.)
		
	ElseIf !Empty(cFatura)
		cAlias9 := GetNextAlias()
		
		BeginSql Alias cAlias9
			SELECT G4C_NUMFAT, G4C_NUMID, G4C_IDITEM, G4C_NUMSEQ, G4C_CLASS, G4C_OPERAC, G4C_VALOR, G4C_CONORI, G4C_CONINU, G4C_GRPPRD, G4C_FATCAR, G4C_CLIFOR
			FROM %Table:G6I% G6I
			INNER JOIN %table:G4C% G4C ON
			G4C_FILIAL = %Exp:SE5->E5_FILIAL%
			AND G4C_NUMID = G6I.G6I_NUMID
			AND G4C_IDITEM = G6I.G6I_IDITEM
			AND G4C_CLIFOR = '2'
			AND G4C_CLASS = " "
//			AND G4C.%NotDel%
			AND %Exp:cDelG4C%
			Where G6I_FILIAL = %Exp:xFilial("G6I")%
			AND G6I_FATURA = %Exp:cFatura%
//			AND G6I.%NotDel%
			AND %Exp:cDelG6I%
		EndSql
		
	EndIf
	
	dbSelectArea(cAlias9)
	dbGoTop()
	while !EOF()
		
		_cArea1 := GetArea()
		
		//Para baixa parcial
		nVlrParc := G4C_VALOR/nVlrFat
		nVlrRV := (SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
		
		If _cTipo == '1'
			//Chama Lançamento Especifico
			nTotalLcto += DetProva(nHdlPrv,"T89",cProg,cLote) // T89 é o LP especifico para contas a Pagar
		ElseIf _cTipo == '2'       //Estorno
			nTotalLcto += DetProva(nHdlPrv,"T88",cProg,cLote) // T89 é o LP especifico para contas a Pagar   (estorno)
		Endif
		
		RestArea(_cArea1)
		
		(cAlias9)->(DBSKIP())
	ENDDO
	
	//Treco abaixo do rodaprava e ca100incl para rodar em conjunto com o CTBAFIN, antes estava sem isso funciona no CTBAFINTUR
	If nHdlPrv > 0
		Rodaprova(nHdlPrv,nTotalLcto)
		If nTotalLcto > 0
			//nTotalLcto := 0
			//Cria transacao para garantir atualizacao do documento
//			Begin Transaction
				cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.,,SE5->E5_DTDISPO)
//			End Transaction
		Endif
	EndIf

	nRet:=0
	
	(cAlias9)->(dbCloseArea())
	
	RestArea(aArea)
	If nTotalLcto > 0
		nTotDoc += nTotalLcto
		SE5->(RecLock("SE5",.F.))
		SE5->E5_LA:= 'S'
		Msunlock()
	Endif
EndIf

//RestArea(aAreaSef)
//RestArea(aAreaSe1)
//RestArea(aAreaSe2)
//RestArea(aAreaSe5)
//RestArea(aAreaCT5)
RestArea(aArea)

Return(nRet)