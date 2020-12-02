#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LPTUR594()
Contabilização Compensação Contas a Receber aberta pela G4C-Item Financeiro
@author Ronaldo Bicudo
@since 27/06/2017
@version 12.1.006
@return nRet
/*/
//-------------------------------------------------------------------

User Function LP596TUR(nOpc)

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
Private nVlrRV := 0

If ISINCALLSTACK("FINA370") .OR. ISINCALLSTACK("CTBAFIN")
	Pergunte("FIN370",.F.)            
	_lDigita:=IIF(mv_par01==1,.T.,.F.)
ElseIf ISINCALLSTACK("FINA330")
	Pergunte("FINA330",.F.)    
	_lDigita:=IIF(mv_par07==1,.T.,.F.)
EndIf
    
If ALLTRIM(SE5->E5_PREFIXO) = 'APU' 
	cAlias1 := GetNextAlias()
	//Query para trazer os valores do RV
	BeginSql Alias cAlias1
		SELECT SUM(G4C_VALOR) VLRRV
		FROM %Table:G85% G85
		INNER JOIN %Table:G4C% G4C ON
		G4C_FILIAL = G85.G85_FILREF
		AND G4C_CODAPU = G85.G85_CODAPU
		AND G4C_CLIFOR = '2'
		AND G4C.%notDel%
		INNER JOIN %table:G3Q% G3Q ON
		G3Q_FILIAL = G4C.G4C_FILIAL
		AND G3Q_NUMID = G4C.G4C_NUMID
		AND G3Q_IDITEM = G4C.G4C_IDITEM
		AND G3Q_NUMSEQ = G4C.G4C_NUMSEQ
		AND G3Q_OPERAC <> '2'
		AND G3Q.%NotDel%
		Where G85_FILIAL = %Exp:SE5->E5_FILIAL%
		AND G85_PREFIX = %Exp:SE5->E5_PREFIXO% 	
		AND G85_NUMFAT = %Exp:SE5->E5_NUMERO% 	
		AND G85.%notDel%
		
	EndSql 

ElseIF ALLTRIM(SE1->E1_PREFIXO) = 'APU'
	cAlias1 := GetNextAlias()
	//Query para trazer os valores do RV
	BeginSql Alias cAlias1
		SELECT SUM(G4C_VALOR) VLRRV
		FROM %Table:G85% G85
		INNER JOIN %Table:G4C% G4C ON
		G4C_FILIAL = G85.G85_FILREF
		AND G4C_CODAPU = G85.G85_CODAPU
		AND G4C_CLIFOR = '2'
		AND G4C.%notDel%
		INNER JOIN %table:G3Q% G3Q ON
		G3Q_FILIAL = G4C.G4C_FILIAL
		AND G3Q_NUMID = G4C.G4C_NUMID
		AND G3Q_IDITEM = G4C.G4C_IDITEM
		AND G3Q_NUMSEQ = G4C.G4C_NUMSEQ
		AND G3Q_OPERAC <> '2'
		AND G3Q.%NotDel%
		Where G85_FILIAL = %Exp:SE1->E1_FILIAL%
		AND G85_PREFIX = %Exp:SE1->E1_PREFIXO% 	
		AND G85_NUMFAT = %Exp:SE1->E1_NUM% 	
		AND G85.%notDel%
	EndSql 

ElseIf SUBSTR(SE5->E5_DOCUMEN,1,3) = 'APU'                      
	cAlias1 := GetNextAlias()
	//Query para trazer os valores do RV
	BeginSql Alias cAlias1
		SELECT SUM(G4C_VALOR) VLRRV
		FROM %Table:G85% G85
		INNER JOIN %Table:G4C% G4C ON
		G4C_FILIAL = G85.G85_FILREF
		AND G4C_CODAPU = G85.G85_CODAPU
		AND G4C_CLIFOR = '2'
		AND G4C.%notDel%
		INNER JOIN %table:G3Q% G3Q ON
		G3Q_FILIAL = G4C.G4C_FILIAL
		AND G3Q_NUMID = G4C.G4C_NUMID
		AND G3Q_IDITEM = G4C.G4C_IDITEM
		AND G3Q_NUMSEQ = G4C.G4C_NUMSEQ
		AND G3Q_OPERAC <> '2'
		AND G3Q.%NotDel%
		Where G85_FILIAL = %Exp:SE5->E5_FILIAL%
		AND G85_PREFIX = %Exp:SUBSTR(SE5->E5_DOCUMEN,1,3)% 	
		AND G85_NUMFAT = %Exp:SUBSTR(SE5->E5_DOCUMEN,4,9)% 	
		AND G85.%notDel%
	EndSql
EndIf                 

If Select((cAlias1)) > 0
	nVlRFat:=(cAlias1)->VLRRV // Valor Total dos RV's.
	(cAlias1)->(DbCloseArea())
EndIf

If ALLTRIM(SE5->E5_PREFIXO) = 'APU' 
	cAlias2 := GetNextAlias()

	BeginSql Alias cAlias2
		SELECT G4C_NUMID, G4C_IDITEM, G4C_NUMSEQ, G4C_CLASS, G4C_GRPPRD, G4C_VALOR, G4C_OPERAC
		FROM %Table:G85% G85
		INNER JOIN %Table:G4C% G4C ON
		G4C_FILIAL = G85.G85_FILREF
		AND G4C_CODAPU = G85.G85_CODAPU
		AND G4C_CLIFOR = '2'
		AND G4C.%notDel%
		INNER JOIN %table:G3Q% G3Q ON
		G3Q_FILIAL = G4C.G4C_FILIAL
		AND G3Q_NUMID = G4C.G4C_NUMID
		AND G3Q_IDITEM = G4C.G4C_IDITEM
		AND G3Q_NUMSEQ = G4C.G4C_NUMSEQ
		AND G3Q_OPERAC <> '2'
		AND G3Q.%NotDel%
		Where G85_FILIAL = %Exp:SE5->E5_FILIAL%
		AND G85_PREFIX = %Exp:SE5->E5_PREFIXO% 	
		AND G85_NUMFAT = %Exp:SE5->E5_NUMERO% 	
		AND G85.%notDel%
	EndSql 

ElseIF ALLTRIM(SE1->E1_PREFIXO) = 'APU'
	cAlias2 := GetNextAlias()

	BeginSql Alias cAlias2
		SELECT G4C_NUMID, G4C_IDITEM, G4C_NUMSEQ, G4C_CLASS, G4C_GRPPRD, G4C_VALOR, G4C_OPERAC
		FROM %Table:G85% G85
		INNER JOIN %TABLE:G4C% G4C ON
		G4C_FILIAL = G85.G85_FILREF
		AND G4C_CODAPU = G85.G85_CODAPU
		AND G4C_CLIFOR = '2'
		AND G4C.%notDel%
		INNER JOIN %table:G3Q% G3Q ON
		G3Q_FILIAL = G4C.G4C_FILIAL
		AND G3Q_NUMID = G4C.G4C_NUMID
		AND G3Q_IDITEM = G4C.G4C_IDITEM
		AND G3Q_NUMSEQ = G4C.G4C_NUMSEQ
		AND G3Q_OPERAC <> '2'
		AND G3Q.%NotDel%
		Where G85_FILIAL = %Exp:SE1->E1_FILIAL%
		AND G85_PREFIX = %Exp:SE1->E1_PREFIXO% 	
		AND G85_NUMFAT = %Exp:SE1->E1_NUM% 	
		AND G85.%notDel%
	EndSql 

ElseIf SUBSTR(SE5->E5_DOCUMEN,1,3) = 'APU'                      
	cAlias2 := GetNextAlias()

	BeginSql Alias cAlias2
		SELECT G4C_NUMID, G4C_IDITEM, G4C_NUMSEQ, G4C_CLASS, G4C_GRPPRD, G4C_VALOR, G4C_OPERAC
		FROM %Table:G85% G85
		INNER JOIN %Table:G4C% G4C ON
		G4C_FILIAL = G85.G85_FILREF
		AND G4C_CODAPU = G85.G85_CODAPU
		AND G4C_CLIFOR = '2'
		AND G4C.%notDel%
		INNER JOIN %table:G3Q% G3Q ON
		G3Q_FILIAL = G4C.G4C_FILIAL
		AND G3Q_NUMID = G4C.G4C_NUMID
		AND G3Q_IDITEM = G4C.G4C_IDITEM
		AND G3Q_NUMSEQ = G4C.G4C_NUMSEQ
		AND G3Q_OPERAC <> '2'
		AND G3Q.%NotDel%
		Where G85_FILIAL = %Exp:SE5->E5_FILIAL%
		AND G85_PREFIX = %Exp:SUBSTR(SE5->E5_DOCUMEN,1,3)% 	
		AND G85_NUMFAT = %Exp:SUBSTR(SE5->E5_DOCUMEN,4,9)% 	
		AND G85.%notDel%
	EndSql
	                      
EndIf                 

While !(cAlias2)->(EOF())
	nVlrParc := (cAlias2)->G4C_VALOR/nVlRFat
	nVlrRV   := (SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
	
	//Chama Lançamento Especifico
	If nOpc = '1' //Inclusão
		nTotalLcto += DetProva(nHdlPrv,"T75",cProg,cLote) 
	Else
		nTotalLcto += DetProva(nHdlPrv,"T74",cProg,cLote) 
	EndIf
	(cAlias2)->(DbSkip())
EndDo
           
If nTotalLcto > 0
	If nOpc = '1' //Inclusão
		nTotalLcto += DetProva(nHdlPrv,"T73",cProg,cLote) 
    Else
		nTotalLcto += DetProva(nHdlPrv,"T72",cProg,cLote)     
    EndIf
EndIf             

If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		//nTotal := 0
		//Cria transacao para garantir atualizacao do documento
//		Begin Transaction
			cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.)
			If nOpc = '1' //Inclusão
				SE5->(RecLock("SE5",.F.))
					SE5->E5_LA:= 'S'
				Msunlock()
			Else
				SE5->(RecLock("SE5",.F.))
					SE5->E5_LA:= ''
				Msunlock()
			EndIf
//		End Transaction
	Endif
EndIf

If Select((cAlias2)) > 0
	(cAlias2)->(DbCloseArea())
EndIf

RestArea(aAreaSef)
RestArea(aAreaSe1)
RestArea(aAreaSe2)
RestArea(aAreaSe5)
RestArea(aAreaCT5)
RestArea(aArea)

Return(nRet)