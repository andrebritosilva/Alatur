#INCLUDE "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} LPT50TUR()
Contabilização da conciliação de Cartões
@author Mauricio de Barros
@since 10/04/2017
@version 1.0
@return nRet
/*/
//-------------------------------------------------------------------
User Function LPT50Tur(cTipoOper)

Local nRet     := 0
Local aAreaAtu := GetArea()
Local aAreaG4C := G4C->(GetArea())
Local aAreaG91 := G91->(GetArea())
Local aAreaCT5 := CT5->(GetArea())
Local nHdlPrv  := 65536
Local nTotDoc  := 0.00            
Local cQuery   := ""
Local cLoteTur := LoteCont("TUR")
Local lPadT84  := VerPadrao("T84")
Local lPadT85  := VerPadrao("T85")
Local cArquivo  	:= ""

Private _lDigita := .F. 

Private cAliasG4C:= GetNextAlias()	

DEFAULT cTipoOper := "1"  // 1=Contabilização 2=Estorno Contabilização

cQuery:="SELECT G4C.R_E_C_N_O_ AS G4C_RECNO, G3Q.R_E_C_N_O_ AS G3Q_RECNO "
cQuery+=" FROM "+RetSqlName("G4C")+" G4C, "
cQuery+=" "+RetSqlName("G3Q")+" G3Q "
cQuery+=" WHERE 1=1 "
cQuery+=" AND G3Q.G3Q_FILIAL = '"+xFilial('G3Q')+"' "
cQuery+=" AND G3Q.G3Q_DOC= '"+G91->G91_CHAVE+"' "
cQuery+=" AND G3Q_CONORI = ' ' "
cQuery+=" AND G4C.G4C_FILIAL = G3Q.G3Q_FILIAL "
cQuery+=" AND G3Q.D_E_L_E_T_=' ' "
//cQuery+=" AND G4C.G4C_FATCAR= '"+G91->G91_NUMFAT+"' "
cQuery+=" AND G4C.G4C_NUMID = G3Q.G3Q_NUMID "
cQuery+=" AND G4C.G4C_IDITEM = G3Q.G3Q_IDITEM "
cQuery+=" AND G4C.G4C_NUMSEQ = G3Q.G3Q_NUMSEQ "
cQuery+=" AND G4C.G4C_CONINU = G3Q.G3Q_CONINU "
cQuery+=" AND G4C.G4C_CLIFOR = '2' "
cQuery+=" AND G4C.D_E_L_E_T_=' ' "

IF Select(cAliasG4C) > 0 
   (cAliasG4C)->(DbCloseArea())
ENDIF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasG4C,.T.,.T.)

(cAliasG4C)->(DbGoTop())

WHILE ! (cAliasG4C)->(Eof())
	G4C->(DbGoto((cAliasG4C)->G4C_RECNO))
	G3Q->(DbGoto((cAliasG4C)->G3Q_RECNO))
	If cTipoOper == "1" 
       IF lPadT85
           nTotal += DetProva(nHdlPrv,"T85","CTBATUR",cLoteTur,,,,,,,,)
       ENDIF   
    Else
       IF lPadT84
	       nTotal += DetProva(nHdlPrv,"T84","CTBATUR",cLoteTur,,,,,,,,)
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
	G91->(RecLock("G91",.F.))
	G91->G91_LA := 'S'
	G91->(MsUnLock())
EndIF

RestArea(aAreaG4C)
RestArea(aAreaG91)
RestArea(aAreaCT5) 
RestArea(aAreaAtu) 
Return(nRet)