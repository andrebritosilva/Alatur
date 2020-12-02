#INCLUDE "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} LPT40TUR()
Contabilização APURACAO FEE aberta pela G4C-Item Financeiro
@author Mauricio de Barros
@since 05/04/2017
@version 1.0
@return nRet
/*/
//-------------------------------------------------------------------
User Function LPT40Tur(cTipoOper)

Local nRet     := 0
Local aAreaAtu := GetArea()
Local aAreaG4C := G4C->(GetArea())
Local aAreaG81 := G81->(GetArea())
Local aAreaCT5 := CT5->(GetArea())
Local nHdlPrv  := 65536
Local nTotDoc  := 0.00            
Local cQuery   := ""
Local cAliasG4C:= GetNextAlias()	
Local cLoteTur := LoteCont("TUR")
Local lPadT82  := VerPadrao("T82")
Local lPadT83  := VerPadrao("T83")
Local cArquivo  	:= ""

Private _lDigita := .F. 

DEFAULT cTipoOper := "1"  // 1=Contabilização 2=Estorno Contabilização

cQuery:="SELECT R_E_C_N_O_ AS G4C_RECNO "
cQuery+=" FROM "+RetSqlName("G4C")+" G4C "
cQuery+=" WHERE "
cQuery+=" G4C.G4C_CODAPU= '"+G81->G81_CODAPU+"' "
cQuery+=" AND G4C.G4C_CLASS = '"+G81->G81_CLASS+"' "
cQuery+=" AND G4C.G4C_FILIAL = '"+G81->G81_FILREF+"' "
cQuery+=" AND G4C.D_E_L_E_T_=' ' "

IF Select(cAliasG4C) > 0 
   (cAliasG4C)->(DbCloseArea())
ENDIF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasG4C,.T.,.T.)

(cAliasG4C)->(DbGoTop())

WHILE ! (cAliasG4C)->(Eof())
	G4C->(DbGoto((cAliasG4C)->G4C_RECNO))
	If cTipoOper == "1" 
       IF lPadT83
           nTotal += DetProva(nHdlPrv,"T83","CTBATUR",cLoteTur,,,,,,,,)
       ENDIF   
    Else
       IF lPadT82
	       nTotal += DetProva(nHdlPrv,"T82","CTBATUR",cLoteTur,,,,,,,,)
       ENDIF
    Endif
    (cAliasG4C)->(DbSkip(+1))
END

nTotalLcto := nTotal

//Treco abaixo do rodaprava e ca100incl para rodar em conjunto com o CTBAFIN, antes estava sem isso funciona no CTBAFINTUR
If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documento
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLoteTur,_lDigita,.F.)
//		End Transaction
	Endif
EndIf


IF Select(cAliasG4C) > 0 
   (cAliasG4C)->(DbCloseArea())
ENDIF
    
If  nTotal > 0.00  // Contabilizou alguma linha G4C
	//RestArea(aArea) //Cadu 04/07/17 - Estava apresentando erro.log de variavel não existe aArea, como esta fazendo lock na G81, entendo que
	//seja essa area a ser restaurada, por isso mudei para aAreaG81
	RestArea(aAreaG81)
	G81->(RecLock("G81",.F.))
	G81->G81_LA := 'S'
	G81->(MsunLock())
EndIF

RestArea(aAreaG4C)
RestArea(aAreaG81)
RestArea(aAreaCT5) 
RestArea(aAreaAtu) 
Return(nRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} IsT40Tur()
Verifica as Classificacoes que deverão ser contabilizados pelos LP´s T82 e T83
@author Mauricio de Barros
@since 05/04/2017
@version 1.0
@return nRet
/*/
//-------------------------------------------------------------------
User Function IsT40Tur()                                            

Local lRetorno := AllWaysFalse()

IF Alltrim(G81->G81_CLASS) $ "C01|C05|C06|C07|F01|F02|F03|F04|F05"
   lRetorno := AllWaysTrue()
ENDIF
   
Return lRetorno