#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LPTUR594()
Contabilização Compensação entre Carteiras aberta pela G4C-Item Financeiro
@author Ronaldo Bicudo
@since 12/06/2017
@version 12.1.006
@return nRet
/*/
//-------------------------------------------------------------------

User Function LPTUR594(nOpc)

Local nRet := 0
Local aArea    := GetArea()
Local aAreaSef := SEF->(GetArea())
Local aAreaSe1 := SE1->(GetArea())
Local aAreaSe2 := SE2->(GetArea())
Local aAreaSe5 := SE5->(GetArea())
Local aAreaCT5 := CT5->(GetArea())
Local nVlrParc := 0
Local nVlRFat  := 0
Local cLote    := LoteCont("FIN")
Local cProg    := "CTBTURFIN"
Local cArquivo := ""
Local nTotalLcto := 0
Local nHdlPrv  := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
Local cAlias1

Private cAlias2
Private _lDigita
Private nVlrRV   := 0

If ISINCALLSTACK("FINA370") .OR. ISINCALLSTACK("CTBAFIN")
	Pergunte("FIN370",.F.)
ElseIf ISINCALLSTACK("FINA080") .OR. ISINCALLSTACK("FINA750")
	Pergunte("FIN080",.F.)
ElseIf ISINCALLSTACK("FINA090")
	Pergunte("FIN090",.F.)
ElseIF ISINCALLSTACK("FINA450")
	Pergunte("FIN0450",.F.)
EndIf

_lDigita:=IIF(mv_par01==1,.T.,.F.)

If Alltrim(SE5->E5_PREFIXO) == 'FAP'
	cAlias1  := GetNextAlias()
	
	BeginSQL Alias cAlias1
		SELECT SUM(G4C_VALOR) VLRRV
		FROM %table:G8Y% G8Y
		INNER JOIN %table:G3R% G3R ON
		G3R_FILIAL = G8Y.G8Y_FILREF
		AND G3R_FATURA = G8Y.G8Y_FATURA
		AND G3R.%NotDel%
		INNER JOIN %table:G4C% G4C ON
		G4C_FILIAL = G3R.G3R_FILIAL
		AND G4C_NUMID = G3R.G3R_NUMID
		AND G4C_CLIFOR = '2'
		AND G4C_OPERAC <> '2'
		AND G4C.%NotDel%
		WHERE G8Y_FILREF = %Exp:SE5->E5_FILIAL%
		AND G8Y_PREFIX = %Exp:SE5->E5_PREFIXO%
		AND G8Y_NUM = %Exp:SE5->E5_NUMERO%
		AND G8Y_FORNEC = %Exp:SE5->E5_CLIFOR% 
		AND G8Y_LOJA = %Exp:SE5->E5_LOJA% 
		AND G8Y.%NotDel%
	EndSQL
	
ElseIf Alltrim(SE5->E5_PREFIXO) == 'RPS'
	cAlias1  := GetNextAlias()
	
	BeginSQL Alias cAlias1
		SELECT SUM(G4C_VALOR) VLRRV
		FROM %table:G8Y% G8Y
		INNER JOIN %table:G3R% G3R ON
		G3R_FILIAL = G8Y.G8Y_FILREF
		AND G3R_CONCIL = G8Y.G8Y_CONCIL
		AND G3R.%NotDel%
		INNER JOIN %table:G4C% G4C ON
		G4C_FILIAL = G3R.G3R_FILIAL
		AND G4C_NUMID = G3R.G3R_NUMID
		AND G4C_CLIFOR = '2'
		AND G4C_OPERAC <> '2'
		AND G4C_CONORI <> ' '
		AND G4C.%NotDel%
		WHERE G8Y_FILREF = %Exp:SE5->E5_FILIAL%
		AND G8Y_PREFIX = %Exp:SE5->E5_PREFIXO%
		AND G8Y_NUM = %Exp:SE5->E5_NUMERO%
		AND G8Y_FORNEC = %Exp:SE5->E5_CLIFOR% 
		AND G8Y_LOJA = %Exp:SE5->E5_LOJA% 
		AND G8Y.%NotDel%
	EndSQL	

ElseIf Alltrim(SE5->E5_PREFIXO) = 'NF'
	cAlias1  := GetNextAlias()
	
	BeginSQL Alias cAlias1
		SELECT SUM(G4C_VALOR) VLRRV
		FROM %table:G8Y% G8Y
		INNER JOIN %table:G3R% G3R ON
		G3R_FILIAL = G8Y.G8Y_FILREF
		AND G3R_FATURA = G8Y.G8Y_FATURA
		AND G3R.%NotDel%
		INNER JOIN %table:G4C% G4C ON
		G4C_FILIAL = G3R.G3R_FILIAL
		AND G4C_NUMID = G3R.G3R_NUMID
		AND G4C_CLIFOR = '2'
		AND G4C_OPERAC = '2'
		AND G4C.%NotDel%
		WHERE G8Y_FILREF = %Exp:SE5->E5_FILIAL%
		AND G8Y_PREFIX = %Exp:SE5->E5_PREFIXO%
		AND G8Y_NUM = %Exp:SE5->E5_NUMERO%
		AND G8Y_FORNEC = %Exp:SE5->E5_CLIFOR% 
		AND G8Y_LOJA = %Exp:SE5->E5_LOJA% 
		AND G8Y.%NotDel%
	EndSQL

EndIf

If Select((cAlias1)) > 0
	nVlRFat:=(cAlias1)->VLRRV // Valor Total dos RV's.
	(cAlias1)->(DbCloseArea())
EndIf

If Alltrim(SE5->E5_PREFIXO) = 'FAP'
	cAlias2  := GetNextAlias()
	
	BeginSQL Alias cAlias2
		SELECT G4C_NUMFAT, G4C_NUMID, G4C_IDITEM, G4C_NUMSEQ, G4C_CLASS, G4C_VALOR, G4C_CONORI, G4C_CONINU, G4C_GRPPRD, G4C_OPERAC, G4C_FATCAR, G4C_CLIFOR
		FROM %table:G8Y% G8Y
		INNER JOIN %table:G3R% G3R ON
		G3R_FILIAL = G8Y.G8Y_FILREF
		AND G3R_FATURA = G8Y.G8Y_FATURA
		AND G3R.%NotDel%
		INNER JOIN %table:G4C% G4C ON
		G4C_FILIAL = G3R.G3R_FILIAL
		AND G4C_NUMID = G3R.G3R_NUMID
		AND G4C_CLIFOR = '2'
		AND G4C_OPERAC <> '2'
		AND G4C.%NotDel%
		WHERE G8Y_FILREF = %Exp:SE5->E5_FILIAL%
		AND G8Y_PREFIX = %Exp:SE5->E5_PREFIXO%
		AND G8Y_NUM = %Exp:SE5->E5_NUMERO%
		AND G8Y_FORNEC = %Exp:SE5->E5_CLIFOR% 
		AND G8Y_LOJA = %Exp:SE5->E5_LOJA% 
		AND G8Y.%NotDel%
	EndSQL

ElseIf Alltrim(SE5->E5_PREFIXO) = 'RPS'
	cAlias2  := GetNextAlias()
	
	BeginSQL Alias cAlias2
		SELECT G4C_NUMFAT, G4C_NUMID, G4C_IDITEM, G4C_NUMSEQ, G4C_CLASS, G4C_VALOR, G4C_CONORI, G4C_CONINU, G4C_GRPPRD, G4C_OPERAC, G4C_FATCAR, G4C_CLIFOR
		FROM %table:G8Y% G8Y
		INNER JOIN %table:G3R% G3R ON
		G3R_FILIAL = G8Y.G8Y_FILREF
		AND G3R_CONCIL = G8Y.G8Y_CONCIL
		AND G3R.%NotDel%
		INNER JOIN %table:G4C% G4C ON
		G4C_FILIAL = G3R.G3R_FILIAL
		AND G4C_NUMID = G3R.G3R_NUMID
		AND G4C_CLIFOR = '2'
		AND G4C_OPERAC <> '2'
		AND G4C_CONORI <> ' '
		AND G4C.%NotDel%
		WHERE G8Y_FILREF = %Exp:SE5->E5_FILIAL%
		AND G8Y_PREFIX = %Exp:SE5->E5_PREFIXO%
		AND G8Y_NUM = %Exp:SE5->E5_NUMERO%
		AND G8Y_FORNEC = %Exp:SE5->E5_CLIFOR% 
		AND G8Y_LOJA = %Exp:SE5->E5_LOJA% 
		AND G8Y.%NotDel%
	EndSQL

ElseIf Alltrim(SE5->E5_PREFIXO) = 'NF'
	cAlias2  := GetNextAlias()
	
	BeginSQL Alias cAlias2
		SELECT G4C_NUMFAT, G4C_NUMID, G4C_IDITEM, G4C_NUMSEQ, G4C_CLASS, G4C_VALOR, G4C_CONORI, G4C_CONINU, G4C_GRPPRD, G4C_OPERAC, G4C_FATCAR, G4C_CLIFOR
		FROM %table:G8Y% G8Y
		INNER JOIN %table:G3R% G3R ON
		G3R_FILIAL = G8Y.G8Y_FILREF
		AND G3R_FATURA = G8Y.G8Y_FATURA
		AND G3R.%NotDel%
		INNER JOIN %table:G4C% G4C ON
		G4C_FILIAL = G3R.G3R_FILIAL
		AND G4C_NUMID = G3R.G3R_NUMID
		AND G4C_CLIFOR = '2'
		AND G4C_OPERAC = '2'
		AND G4C.%NotDel%
		WHERE G8Y_FILREF = %Exp:SE5->E5_FILIAL%
		AND G8Y_PREFIX = %Exp:SE5->E5_PREFIXO%
		AND G8Y_NUM = %Exp:SE5->E5_NUMERO%
		AND G8Y_FORNEC = %Exp:SE5->E5_CLIFOR% 
		AND G8Y_LOJA = %Exp:SE5->E5_LOJA% 
		AND G8Y.%NotDel%
	EndSQL
	
EndIf

If Select((cAlias2)) > 0

	dbGoTop()
	
	While !(cAlias2)->(EOF())
		nVlrParc := (cAlias2)->G4C_VALOR/nVlRFat
		nVlrRV   := (SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
		
		//Chama Lançamento Especifico
		If nOpc = '1' //Inclusão
			nTotalLcto += DetProva(nHdlPrv,"T77",cProg,cLote) 
		Else
			nTotalLcto += DetProva(nHdlPrv,"T76",cProg,cLote) 
		EndIf
		(cAlias2)->(DbSkip())
	EndDo
	
	If nHdlPrv > 0
		Rodaprova(nHdlPrv,nTotalLcto)
		If nTotalLcto > 0
			//nTotal := 0
			//Cria transacao para garantir atualizacao do documento
//			Begin Transaction
			cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.)
			SE5->(RecLock("SE5",.F.))
				SE5->E5_LA:= 'S'
			Msunlock()
//			End Transaction
		Endif
	EndIf

	//DbSelectArea(cAlias2)
	(cAlias2)->(DbCloseArea())

EndIf

RestArea(aAreaSef)
RestArea(aAreaSe1)
RestArea(aAreaSe2)
RestArea(aAreaSe5)
RestArea(aAreaCT5)
RestArea(aArea)

Return(nRet)