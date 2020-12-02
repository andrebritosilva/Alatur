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

User Function BXTUR(_cTipo,_cOpc) // Recebe o código da Classe

Local nRet		:= 0
Local aAreaAtu	:= GetArea()
Local aAreaSe5 := SE5->(GetArea())

//Variaveis que serão utilizadas nos Lp's Especificos T9* >
Private nVlrRV   := 0
Private nVrlJur  := 0 //Juros de Fee - Apuração Cliente
Private nVlrFat  := 0
Private nVlrParc := 0
Private _lDigita := .F. 
Private lCtbTur  := .F.   // Flag para identificar se contabilizou algum item MBARROS 24/03/2017 - Nao Gravar Flag SE5 se nao atendeu a Regra.
Private __cTurProcess := "R" 

Private cAliasQ1 := GetNextAlias()	//CriaTrab(nil,.F.)	//GetNextAlias()
Private cAliasQ2 := GetNextAlias()	//CriaTrab(nil,.F.)	//GetNextAlias()

Public lxLP520 := .f.

IF Type("nTotDoc")="U"
   nTotDoc := 0
ENDIF

/* 
If ISINCALLSTACK("FINA370") .OR. ISINCALLSTACK("CTBAFIN")  .OR. ISINCALLSTACK("FINA070") .OR. ISINCALLSTACK("FINA110")
	Pergunte("FIN370",.F.)
	_lDigita:=IIF(mv_par01==1 .OR. _cTipo="2",.T.,.F.)
Else
	_lDigita:= .F.
EndIf 
*/
  
_lDigita:= .F.

If ISINCALLSTACK("FINA370") .OR. ISINCALLSTACK("CTBAFIN")  
	Pergunte("FIN370",.F.) 
ElseIf ISINCALLSTACK("FINA070").OR.ISINCALLSTACK("FINA740")
	Pergunte("FIN070",.F.)   
ElseIf ISINCALLSTACK("FINA110")
	Pergunte("FIN110",.F.)
EndIf

//_lDigita:=IIF(mv_par01==1 .OR. _cTipo="2",.T.,.F.)
_lDigita:=IIF(mv_par01==1,.T.,.F.)

If _cTipo = '1' //Contabilização
	If _cOpc = 'FAT' .Or. _cOpc ='BRK' .Or. _cOpc ='CDT' //Faturas de Vendas
		_CTBAFAT()
	ElseIF _cOpc = 'JUR' //Juros de Apuração de Cliente - Fee
		_JURAPUR()
	ElseIF _cOpc = 'APU' //Apuração de Clientes
		_CTBAPUR()
	ElseIf _cOpc = 'CON' //Conciliação Terrestre
		_CTBACON() 
	Else
		Return(nRet)
	EndIf
ElseIf _cTipo = '2'//Estorno das Contabilizações
	If _cOpc = 'FAT' .Or. _cOpc ='BRK' .Or. _cOpc ='CDT' //Faturas de Vendas
		_CTBEFAT()
	ElseIF _cOpc = 'JUR' //Juros de Apuração de Cliente - Fee
		_JUREPUR()
	ElseIF _cOpc = 'APU' //Apuração de Clientes
		_CTBEPUR()
	ElseIf _cOpc = 'CON' //Conciliação Terrestre
		_CTBECON()
	Else
		RestArea(aAreaSe5) 
		RestArea(aAreaAtu)
		Return(nRet)
	EndIf
EndIf

If  lCtbTur //_cOpc = 'FAT' .OR. _cOpc = 'APU' .OR. _cOpc = 'BRK' .OR. _cOpc = 'CDT' 
	RestArea(aAreaSe5)
	SE5->(RecLock("SE5",.F.))
	SE5->E5_LA:= 'S'
	Msunlock()
EndIF

RestArea(aAreaSe5) 
RestArea(aAreaAtu)

return(nRet)

//Contabilização dos Prefixo FAT/APU de Turismo
Static Function _CTBAFAT()

Local _cQuery := ''
Local _cQuerya := ''
Local nTotalLcto := 0
Local aArea := GetArea()
Local cLote   := LoteCont("FIN")
Local cProg   := "CTBAFIN"
Local cArquivo := ""                  
Local nHdlPrv := 65536
// MBARROS  Local nHdlPrv := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
//Local _nPorcPIS := 0
//Local _nPorcCOF := 0
//Local _nPorcCSL := 0

Private _nPIS := 0
Private _nCOF := 0
Private _nCSL := 0
                       
_cQuery:="SELECT SUM(G85_VALOR) VLRFAT FROM "+RetSqlName("G85")+" G85 "
_cQuery+="WHERE "
_cQuery+="G85.G85_FILIAL     = '"+SE5->E5_FILIAL+"' "
_cQuery+="AND G85.G85_PREFIX = '"+SE5->E5_PREFIXO+"' "
_cQuery+="AND G85.G85_NUMFAT = '"+SE5->E5_NUMERO+"' "
_cQuery+="AND G85.D_E_L_E_T_= '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQ1,.T.,.T.)
nVlrFat:=VLRFAT // Valor Total da Fatura.
	
(cAliasQ1)->(dbCloseArea())

_cQueryA:="SELECT G85_NUMFAT, G85_REGVEN, G85_CLASS, G85_VALOR, G85_GRPPRD, G85_PREFIX,G85_ITVEND,G85_SEQIV,G85_FILREF FROM "+RetSqlName("G85")+" G85 "
_cQueryA+="WHERE "
_cQuerya+="G85.G85_FILIAL= '"+SE5->E5_FILIAL+"' "
_cQuerya+="AND G85.G85_NUMFAT = '"+SE5->E5_NUMERO+"' "
_cQuerya+="AND G85.G85_PREFIX = '"+SE5->E5_PREFIXO+"' "
_cQuerya+="AND G85.D_E_L_E_T_='' "
_cQuerya+="AND G85.D_E_L_E_T_='' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuerya),cAliasQ2,.T.,.T.)

dbSelectArea(cAliasQ2)
dbGoTop()
while !EOF()
	
	lxLP520 := .t.	//Essa variavel é utilizada no LpTur02.prw
	
	_cArea1 := GetArea()
	
	//Para baixa parcial
	nVlrParc := (cAliasQ2)->G85_VALOR/nVlrFat
	nVlrRV := (SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
	
	//Posicionamento SE1
	SE1->(dbSetOrder(2))
	If SE1->(MsSeek(xFilial("SE1")+ SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO ))// PREFIXO, NUMERO, PARCELA, TIPO, CLIFOR e LOJA
	
	
		//Parcial para Imposto
		//PIS
	   	_nPIS := SE1->E1_PIS * nVlrParc // Utilizar esta variavel para o valor PIS
		
		//COFINS
		_nCOF := SE1->E1_COFINS * nVlrParc // Utilizar esta variavel para o valor COFINS
		
		//CSLL
			_nCSL := SE1->E1_CSLL * nVlrParc // Utilizar esta variavel para o valor CSLL
		//
	Endif	
	
	//Chama Lançamento Especifico
	If nVlrRV > 0
		nTotalLcto += DetProva(nHdlPrv,"T99",cProg,cLote) // T01 é o LP especifico
	EndIf
	RestArea(_cArea1)
	
	(cAliasQ2)->(DBSKIP())
ENDDO


If nTotalLcto > 0
   nTotDoc += nTotalLcto
   lCtbTur := .T. // Barros Gerou CTK atendendo as Regras
ENDIF   		

//Trecho abaixo do rodaprova e ca100incl para rodar em conjunto com o CTBAFIN, antes estava sem isso funciona no CTBAFINTUR
If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documento
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.,,SE5->E5_DTDISPO)
//		End Transaction
	Endif
EndIf

nRet:=0 

(cAliasQ2)->(dbCloseArea())

Return() 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    

Static Function _JURAPUR() //Contabiliza Juros de Fee Apuração de Cliente

Local aAliasG6M		:= GetArea("G6M")
Local _cQuery		:= ''
Local nTotalLcto	:= 0
Local cLote			:= LoteCont("FIN")
Local cProg			:= "CTBAFIN"
Local cArquivo		:= ""
Local nHdlPrv		:= 65536
//Local nHdlPrv := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento

Private nVrlJur    := 0
Private nValJur    := 0

_cQuery:="SELECT G85_FILIAL, G85_NUMFAT, G85_CODAPU, G85_SEGNEG, G85_CLASS, G85_FILREF FROM "+RetSqlName("G85")+" G85 "
_cQuery+="WHERE "
_cQuery+="G85.G85_FILIAL= '"+SE5->E5_FILIAL+"' "
_cQuery+="AND G85.G85_PREFIX = '"+SE5->E5_PREFIXO+"' "
_cQuery+="AND G85.G85_NUMFAT = '"+SE5->E5_NUMERO+"' "
_cQuery+="AND G85.D_E_L_E_T_= '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQ1,.T.,.T.)

DbSelectArea(cAliasQ1)
(cAliasQ1)->(DbGoTop())

DbSelectArea("G6M")
DbSetOrder(1)
While (cAliasQ1)->(!EOF())
	_aArea1 := GetArea()
	
	If G6M->(MSSeek(xFilial("G6M")+(cAliasQ1)->(G85_CODAPU+G85_SEGNEG+G85_CLASS)))
		While !EOF() .AND. G6M->G6M_FILIAL+G6M->G6M_CODAPU+G6M->G6M_SEGNEG+G6M->G6M_TIPOAC == xFilial("G6M")+(cAliasQ1)->(G85_CODAPU+G85_SEGNEG+G85_CLASS)
//			If G6M->G6M_FILREF == (cAliasQ1)->(G85_FILREF)
			If Alltrim(G6M->G6M_FILIAL) == Substr((cAliasQ1)->(G85_FILREF),1,2)
				nVrlJur := G6M->G6M_VLTXAD
			EndIf
			DBSKIP()
		ENDDO	
	ENDIF  
	//Chama Lançamento Especifico
	If nVrlJur > 0
		nTotalLcto += DetProva(nHdlPrv,"T98",cProg,cLote) // T98 é o LP especifico
	EndIf
	RestArea(_aArea1)
	(cAliasQ1)->(DBSKIP())
ENDDO

If nTotalLcto > 0
   nTotDoc += nTotalLcto
   lCtbTur := .T. // Barros Gerou CTK atendendo as Regras
ENDIF   		

//Treco abaixo do rodaprava e ca100incl para rodar em conjunto com o CTBAFIN, antes estava sem isso funciona no CTBAFINTUR
If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documento
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.,,SE5->E5_DTDISPO)
//		End Transaction
	Endif
EndIf

nRet:=0

(cAliasQ1)->(dbCloseArea())

RestArea(aAliasG6M)

Return()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function _CTBAPUR() //Contabiliza Fee Apuração de Cliente

Local cAliasG6M		:= GetArea("G6M")
Local _cQuery		:= 0
Local nTotalLcto	:= 0
Local cLote			:= LoteCont("FIN")
Local cProg			:= "CTBAFIN"
Local cArquivo		:= ""
Local nHdlPrv		:= 65536
//Local nHdlPrv    := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
Local nImp			:= 0
Local nJurApu		:= 0
Local vJurApu		:= 0 
Local nVrlJur		:= 0
Local cAliasG6M		:= GetNextAlias()
Local cDelG85		:= "%G85.D_E_L_E_T_ <> '*'%"
Local cDelG48		:= "%G48.D_E_L_E_T_ <> '*'%"
Local nRecSE5		:= SE5->(RECNO())

Private nVlrFat		:= 0
Private nVlrApu		:= 0

BeginSql Alias cAliasQ1
	SELECT G85_FILIAL,G85_PREFIX,G85_NUMFAT,G85_CODAPU,G85_SEGNEG,G85_CLASS,G85_VALOR,G85_FILREF,G48_VLACD,G3Q_GRPPRD,G48_NUMID
	FROM %table:SE5% SE5 (NOLOCK)
	JOIN %table:G85% G85 (NOLOCK) ON (G85_FILIAL=E5_FILIAL AND G85_NUMFAT = E5_NUMERO AND G85.D_E_L_E_T_<>'*')
	JOIN %table:G81% G81 (NOLOCK) ON (G81_IDIFA=G85_IDIFA AND G81_FILREF=G85_FILREF AND G81.D_E_L_E_T_<>'*')
	JOIN %table:G48% G48 (NOLOCK) ON((G48.G48_FILAPU=G81_FILIAL AND G48.G48_CODAPU=G81.G81_CODAPU AND G48.G48_SEGNEG=G81_SEGNEG AND G48.D_E_L_E_T_<>'*' 
										AND G48.G48_CONINU=' ' AND G48.G48_CLIFOR='1')
										OR (G48.G48_FILREF=G81_FILREF AND G48.G48_CODAPU=G81.G81_CODAPU AND G48.G48_SEGNEG=G81_SEGNEG AND G48.D_E_L_E_T_<>'*' 
										AND G48.G48_CONINU=' ' AND G48.G48_CLIFOR='2'))
	JOIN %table:G3Q% G3Q (NOLOCK) ON (G3Q_FILIAL=G48.G48_FILIAL AND G3Q_NUMID=G48.G48_NUMID AND G3Q_IDITEM=G48.G48_IDITEM AND G3Q_NUMSEQ=G48.G48_NUMSEQ 
										AND G3Q.D_E_L_E_T_<>'*' AND G3Q_CONINU=' ')
	WHERE G85.G85_FILIAL = %exp:SE5->E5_FILIAL%
	AND   G85.G85_PREFIX = %exp:SE5->E5_PREFIXO%
	AND   G85.G85_NUMFAT = %exp:SE5->E5_NUMERO%
	AND	  SE5.R_E_C_N_O_ = %exp:nRecSE5%
	AND   SE5.%NotDel% 
EndSql
/*/
_cQuery:="SELECT G85_FILIAL, G85_PREFIX, G85_NUMFAT, G85_CODAPU, G85_SEGNEG, G85_CLASS, G85_VALOR, G85_FILREF FROM "+RetSqlName("G85")+" G85 "
_cQuery+="WHERE "
_cQuery+="G85.G85_FILIAL= '"+SE5->E5_FILIAL+"' "
_cQuery+="AND G85.G85_PREFIX = '"+SE5->E5_PREFIXO+"' "
_cQuery+="AND G85.G85_NUMFAT = '"+SE5->E5_NUMERO+"' "
_cQuery+="AND G85.D_E_L_E_T_= '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQ1,.T.,.T.)
/*/
DbSelectArea(cAliasQ1)
(cAliasQ1)->(DbGoTop())
/*/
DbSelectArea("G6M")
DbSetOrder(1)
If G6M->(MSSeek(xFilial("G6M")+(cAliasQ1)->(G85_CODAPU+G85_SEGNEG+G85_CLASS)))

	While !EOF() .AND. G6M->G6M_FILIAL+G6M->G6M_CODAPU+G6M->G6M_SEGNEG+G6M->G6M_TIPOAC == xFilial("G6M")+(cAliasQ1)->(G85_CODAPU+G85_SEGNEG+G85_CLASS)
		If G6M->G6M_FILREF == (cAliasQ1)->(G85_FILREF)
			nVrlJur := G6M->G6M_VLTXAD
		EndIf
		DBSKIP()
	ENDDO	
ENDIF  
/*/
BeginSql Alias cAliasG6M
	SELECT SUM(G6M_VLTXAD) nVLTXAD
	FROM %table:G6M% G6M (NOLOCK)
	WHERE G6M_CODAPU	= %exp:(cAliasQ1)->(G85_CODAPU)%
	AND G6M_SEGNEG		= %exp:(cAliasQ1)->(G85_SEGNEG)%
	AND G6M_TIPOAC		= %exp:(cAliasQ1)->(G85_CLASS)%                                                        
	AND G6M.%NotDel% 
EndSql

//nJurApu :=  nVrlJur        
nJurApu := (cAliasG6M)->nVLTXAD
/*/
_cQueryA:="SELECT G4C_NUMFAT,G4C_NUMID,G4C_IDITEM,G4C_NUMSEQ,G4C_CONINU,G4C_CLASS,G4C_VALOR,G4C_GRPPRD FROM "+RetSqlName("G4C")+" G4C "
_cQueryA+="WHERE "
_cQuerya+="G4C.G4C_CODAPU= '"+(cAliasQ1)->G85_CODAPU+"' "
_cQuerya+="AND G4C.G4C_CLASS <> 'C07'"
//_cQuerya+="AND G4C.G4C_NUMFAT = '"+(cAliasQ1)->G85_NUMFAT+"' "
//_cQuerya+="AND G4C.D_E_L_E_T_='' "
_cQuerya+="AND G4C.D_E_L_E_T_ <> '*' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuerya),cAliasQ2,.T.,.T.)
/*/
dbSelectArea(cAliasQ1)
(cAliasQ1)->(dbGoTop())

//Apuração de Cliente e Fornecedores
If (cAliasQ1)->(!EOF())
	While (cAliasQ1)->(!EOF())
		nVlrFat:=nVlrFat+(cAliasQ1)->(G48_VLACD)			// Valor Total da Fatura.
		(cAliasQ1)->(DBSKIP())
	EndDo
	
	(cAliasQ1)->(dbGoTop())
	while (cAliasQ1)->(!EOF())
		
		_cArea1 := GetArea()
		
		//Para baixa parcial
		nVlrParc := (cAliasQ1)->(G48_VLACD)/nVlrFat
		vJurApu :=  nJurApu
		nVlrApu := (((SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO)+ nImp )- vJurApu) * nVlrParc //- vJurApu // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
		//
		//Chama Lançamento Especifico
		If nVlrApu > 0
			nTotalLcto += DetProva(nHdlPrv,"T97",cProg,cLote) // T01 é o LP especifico
		EndIf
		
		RestArea(_cArea1)
		
		(cAliasQ1)->(DBSKIP())
	ENDDO
Else //Apuração de Metas
/*/
	while (cAliasQ1)->(!EOF())
		nVlrFat:=nVlrFat+(cAliasQ1)->G85_VALOR // Valor Total da Fatura.
		(cAliasQ1)->(DBSKIP())
	ENDDO
	
	(cAliasQ1)->(dbGoTop())
	while (cAliasQ1)->(!EOF())
		
		_cArea1 := GetArea()
		
		//Para baixa parcial
		nVlrParc := (cAliasQ1)->G85_VALOR/nVlrFat
		vJurApu :=  nJurApu * nVlrParc
		nVlrApu := ((SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc) - vJurApu // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
		//
		//Chama Lançamento Especifico
		If nVlrApu > 0
			nTotalLcto += DetProva(nHdlPrv,"T97",cProg,cLote) // T01 é o LP especifico
		EndIf
		
		RestArea(_cArea1)
		
		(cAliasQ1)->(DBSKIP())
	ENDDO	
/*/	
EndIf

If nTotalLcto > 0
   nTotDoc += nTotalLcto
   lCtbTur := .T. // Barros Gerou CTK atendendo as Regras
ENDIF   		

//Treco abaixo do rodaprava e ca100incl para rodar em conjunto com o CTBAFIN, antes estava sem isso funciona no CTBAFINTUR
If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documento
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.,,SE5->E5_DTDISPO)
//		End Transaction
		If nVlrApu > 0
			DbSelectArea("SE5")
			RecLock("SE5",.F.)
			E5_LA := ''
			MsUnLock()
		EndIf
	Endif
EndIf

(cAliasQ1)->(dbCloseArea())
(cAliasG6M)->(dbCloseArea())

nRet:=0

Return()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function _CTBEFAT()//Estornos da Contabilização dos Prefixo FAT/APU de Turismo

Local _cQuery		:= ''
Local _cQuerya		:= ''
Local nTotalLcto	:= 0
Local aArea			:= GetArea()
Local cLote			:= LoteCont("FIN")
Local cProg			:= "CTBAFIN"
Local cArquivo		:= ""
//Local nHdlPrv := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
Local nHdlPrv		:= 65536
Local cDelG85		:= "%G85.D_E_L_E_T_ <> '*'%"

/*/
_cQuery:="SELECT SUM(G85_VALOR) VLRFAT FROM "+RetSqlName("G85")+" G85 "
_cQuery+="WHERE "
_cQuery+="G85.G85_FILIAL     = '"+SE5->E5_FILIAL+"' "
_cQuery+="AND G85.G85_PREFIX = '"+SE5->E5_PREFIXO+"' "
_cQuery+="AND G85.G85_NUMFAT = '"+SE5->E5_NUMERO+"' "
_cQuery+="AND G85.D_E_L_E_T_= '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQ1,.T.,.T.)
/*/
BeginSql Alias cAliasQ1
	SELECT SUM(G85_VALOR) VLRFAT 
	FROM %table:G85% G85 (NOLOCK)
	WHERE G85.G85_FILIAL	= %Exp:SE5->E5_FILIAL%
	AND G85.G85_PREFIX		= %Exp:SE5->E5_PREFIXO%
	AND G85.G85_NUMFAT		= %Exp:SE5->E5_NUMERO%
	AND %Exp:cDelG85%
EndSql

nVlrFat:=(cAliasQ1)->VLRFAT // Valor Total da Fatura.
//(cAliasQ1)->(dbCloseArea())
BeginSql Alias cAliasQ2
	SELECT G85_NUMFAT, G85_REGVEN, G85_CLASS, G85_VALOR, G85_GRPPRD, G85_PREFIX,G85_ITVEND,G85_SEQIV,G85_FILREF
	FROM %table:G85% G85 (NOLOCK)
	WHERE G85.G85_FILIAL	= %Exp:SE5->E5_FILIAL%
	AND G85.G85_PREFIX		= %Exp:SE5->E5_PREFIXO%
	AND G85.G85_NUMFAT		= %Exp:SE5->E5_NUMERO%
	AND %Exp:cDelG85%
EndSql
/*/
_cQueryA:="SELECT G85_NUMFAT, G85_REGVEN, G85_CLASS, G85_VALOR, G85_GRPPRD, G85_PREFIX,G85_ITVEND,G85_SEQIV,G85_FILREF FROM "+RetSqlName("G85")+" G85 "
_cQueryA+="WHERE "
_cQuerya+="G85.G85_FILIAL= '"+SE5->E5_FILIAL+"' "
_cQuerya+="AND G85.G85_NUMFAT = '"+SE5->E5_NUMERO+"' "
_cQuerya+="AND G85.G85_PREFIX = '"+SE5->E5_PREFIXO+"' "
_cQuerya+="AND G85.D_E_L_E_T_='' "
_cQuerya+="AND G85.D_E_L_E_T_='' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuerya),cAliasQ2,.T.,.T.)
/*/
dbSelectArea(cAliasQ2)
dbGoTop()
while !EOF()
	
	lxLP520 := .t.	//Essa variavel é utilizada no LpTur02.prw
	
	_cArea1 := GetArea()
	
	//Para baixa parcial
	nVlrParc := (cAliasQ2)->G85_VALOR/nVlrFat
	nVlrRV := (SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
	//
	
	//Chama Lançamento Especifico
	If nVlrRV > 0
		nTotalLcto += DetProva(nHdlPrv,"T96",cProg,cLote) // T01 é o LP especifico
	EndIf
	RestArea(_cArea1)
	
	(cAliasQ2)->(DBSKIP())
ENDDO

If nTotalLcto > 0
   nTotDoc += nTotalLcto
   lCtbTur := .T. // Barros Gerou CTK atendendo as Regras
ENDIF   		

//Treco abaixo do rodaprava e ca100incl para rodar em conjunto com o CTBAFIN, antes estava sem isso funciona no CTBAFINTUR
If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documento
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.,,SE5->E5_DTDISPO)
//		End Transaction
	Endif
EndIf

nRet:=0 
(cAliasQ2)->(dbCloseArea())

Return()

Static Function _JUREPUR() //Contabiliza Juros de Fee Apuração de Cliente

Local aAliasAtu		:= GetArea()
//Local cAliasG6M		:= GetArea("G6M")
Local aAliasG6M		:= G6M->(GetArea())
Local _cQuery		:= ''
Local nTotalLcto	:= 0
Local cLote			:= LoteCont("FIN")
Local cProg			:= "CTBAFIN"
Local cArquivo		:= ""
Local nHdlPrv		:= 65536
//Local nHdlPrv := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento

Private nVrlJur		:= 0
Private nValJur		:= 0

_cQuery:="SELECT G85_FILIAL, G85_NUMFAT, G85_CODAPU, G85_SEGNEG, G85_CLASS, G85_FILREF FROM "+RetSqlName("G85")+" G85 "
_cQuery+="WHERE "
_cQuery+="G85.G85_FILIAL= '"+SE5->E5_FILIAL+"' "
_cQuery+="AND G85.G85_PREFIX = '"+SE5->E5_PREFIXO+"' "
_cQuery+="AND G85.G85_NUMFAT = '"+SE5->E5_NUMERO+"' "
_cQuery+="AND G85.D_E_L_E_T_= '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQ1,.T.,.T.)

DbSelectArea(cAliasQ1)
(cAliasQ1)->(DbGoTop())

DbSelectArea("G6M")
DbSetOrder(1)
While (cAliasQ1)->(!EOF())
	_aArea1 := GetArea()
	
	If G6M->(MSSeek(xFilial("G6M")+(cAliasQ1)->(G85_CODAPU+G85_SEGNEG+G85_CLASS)))
		While !EOF() .AND. G6M->G6M_FILIAL+G6M->G6M_CODAPU+G6M->G6M_SEGNEG+G6M->G6M_TIPOAC == xFilial("G6M")+(cAliasQ1)->(G85_CODAPU+G85_SEGNEG+G85_CLASS)
			//If G6M->G6M_FILREF == (cAliasQ1)->(G85_FILREF)
				nVrlJur := G6M->G6M_VLTXAD
			//EndIf
			DBSKIP()
		ENDDO	
	ENDIF  
	
	//Chama Lançamento Especifico
	If nVrlJur > 0
		nTotalLcto += DetProva(nHdlPrv,"T95",cProg,cLote) // T98 é o LP especifico
	EndIf
	
	RestArea(_aArea1)
	
	(cAliasQ1)->(DBSKIP())
ENDDO

If nTotalLcto > 0
   nTotDoc += nTotalLcto
   lCtbTur := .T. // Barros Gerou CTK atendendo as Regras
ENDIF   		

//Treco abaixo do rodaprava e ca100incl para rodar em conjunto com o CTBAFIN, antes estava sem isso funciona no CTBAFINTUR
If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documento
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.,,SE5->E5_DTDISPO)
//		End Transaction
	Endif
EndIf

nRet:=0 

(cAliasQ1)->(dbCloseArea())

RestArea(aAliasG6M)
RestArea(aAliasAtu)

Return()
////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function _CTBEPUR() //Contabiliza Fee Apuração de Cliente

//Local cAliasG6M		:= GetArea("G6M")
Local cAliasG6M		:= G6M->(GetArea())
Local _cQuery		:= 0
Local nTotalLcto	:= 0
Local cLote			:= LoteCont("FIN")
Local cProg			:= "CTBAFIN"
Local cArquivo		:= ""
Local nHdlPrv		:= 65536
//Local nHdlPrv    := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
Local nImp			:= 0
Local nJurApu		:= 0
Local vJurApu		:= 0 
Local nVrlJur		:= 0

Private nVlrFat		:= 0
Private nVlrApu		:= 0

_cQuery:="SELECT G85_FILIAL, G85_PREFIX, G85_NUMFAT, G85_CODAPU, G85_SEGNEG, G85_CLASS, G85_VALOR, G85_FILREF FROM "+RetSqlName("G85")+" G85 "
_cQuery+="WHERE "
_cQuery+="G85.G85_FILIAL= '"+SE5->E5_FILIAL+"' "
_cQuery+="AND G85.G85_PREFIX = '"+SE5->E5_PREFIXO+"' "
_cQuery+="AND G85.G85_NUMFAT = '"+SE5->E5_NUMERO+"' "
_cQuery+="AND G85.D_E_L_E_T_ <> '*' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQ1,.T.,.T.)

DbSelectArea(cAliasQ1)
(cAliasQ1)->(DbGoTop())
If !Eof()
	DbSelectArea("G6M")
	DbSetOrder(1)
	If G6M->(MSSeek(xFilial("G6M")+(cAliasQ1)->(G85_CODAPU+G85_SEGNEG+G85_CLASS)))
		While !EOF() .AND. G6M->G6M_FILIAL+G6M->G6M_CODAPU+G6M->G6M_SEGNEG+G6M->G6M_TIPOAC == xFilial("G6M")+(cAliasQ1)->(G85_CODAPU+G85_SEGNEG+G85_CLASS)
			//If G6M->G6M_FILREF == (cAliasQ1)->(G85_FILREF)
				nVrlJur := G6M->G6M_VLTXAD
			//EndIf
			DBSKIP()
		ENDDO	
	ENDIF  
	
	nJurApu :=  nVrlJur
	
	_cQueryA:="SELECT G4C_NUMFAT,G4C_NUMID,G4C_IDITEM,G4C_NUMSEQ,G4C_CONINU,G4C_CLASS, G4C_VALOR, G4C_GRPPRD FROM "+RetSqlName("G4C")+" G4C "
	_cQueryA+="WHERE "
	_cQuerya+="G4C.G4C_CODAPU= '"+(cAliasQ1)->G85_CODAPU+"' "
	_cQuerya+="AND G4C.G4C_CLASS <> 'C07' "
	//_cQuerya+="AND G4C.G4C_PREFIX = '"+(cAliasQ1)->G85_PREFIX+"' "
	//_cQuerya+="AND G4C.G4C_NUMFAT = '"+(cAliasQ1)->G85_NUMFAT+"' "
	//_cQuerya+="AND G4C.D_E_L_E_T_='' "
	_cQuerya+="AND G4C.D_E_L_E_T_ <> '*' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuerya),cAliasQ2,.T.,.T.)
	
	dbSelectArea(cAliasQ2)
	(cAliasQ2)->(dbGoTop())
	//Apuração de Cliente e Fornecedores
	If (cAliasQ2)->(!EOF())
		While (cAliasQ2)->(!EOF())
			nVlrFat:=nVlrFat+(cAliasQ2)->G4C_VALOR // Valor Total da Fatura.
			(cAliasQ2)->(DBSKIP())
		ENDDO
		(cAliasQ2)->(dbGoTop())
		while (cAliasQ2)->(!EOF())
			_cArea1 := GetArea()
			
			//Para baixa parcial
			/*
			nVlrParc := (cAliasQ2)->G4C_VALOR/nVlrFat
			nJurApu := nVrlJur / nVlrParc
			nVlrApu := ((SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc) - nJurApu // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
			*/
			nVlrParc := (cAliasQ2)->G4C_VALOR/nVlrFat
			vJurApu :=  nJurApu
			nVlrApu := (((SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO)+ nImp )- vJurApu) * nVlrParc // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
	
			//
			//Chama Lançamento Especifico
			If nVlrApu > 0
				nTotalLcto += DetProva(nHdlPrv,"T94",cProg,cLote) // T01 é o LP especifico
			EndIf
			
			RestArea(_cArea1)
			
			(cAliasQ2)->(DBSKIP())
		ENDDO
	Else //Apuração de Metas
		while (cAliasQ1)->(!EOF())
			nVlrFat:=nVlrFat+(cAliasQ1)->G85_VALOR // Valor Total da Fatura.
			(cAliasQ1)->(DBSKIP())
		ENDDO
		(cAliasQ1)->(dbGoTop())
		while (cAliasQ1)->(!EOF())
			_cArea1 := GetArea()
			//Para baixa parcial
			nVlrParc := (cAliasQ1)->G85_VALOR/nVlrFat
			vJurApu :=  nJurApu * nVlrParc
			nVlrApu := ((SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc) - vJurApu // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
			//
			//Chama Lançamento Especifico
			If nVlrApu > 0
				nTotalLcto += DetProva(nHdlPrv,"T94",cProg,cLote) // T01 é o LP especifico
			EndIf
			RestArea(_cArea1)
			(cAliasQ1)->(DBSKIP())
		ENDDO	
	EndIf
	
	If nTotalLcto > 0
	   nTotDoc += nTotalLcto
	   lCtbTur := .T. // Barros Gerou CTK atendendo as Regras
	ENDIF   		
	
	//Treco abaixo do rodaprava e ca100incl para rodar em conjunto com o CTBAFIN, antes estava sem isso funciona no CTBAFINTUR
	If nHdlPrv > 0
		Rodaprova(nHdlPrv,nTotalLcto)
		If nTotalLcto > 0
			nTotalLcto := 0
			//Cria transacao para garantir atualizacao do documento
	//		Begin Transaction
			cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.,,SE5->E5_DTDISPO)
	//		End Transaction
		Endif
	EndIf
	(cAliasQ2)->(dbCloseArea())
EndIf

nRet:=0 

RestArea(cAliasG6M)

Return()

//Contabilização dos Prefixo NF Conciliações Terrestre e Reembolso de Turismo
Static Function _CTBACON()

Local _cQuery		:= ''
Local _cQuerya		:= ''
Local nTotalLcto	:= 0
Local aArea			:= GetArea()
Local cLote			:= LoteCont("FIN")
Local cProg			:= "CTBAFIN"
Local cArquivo		:= ""                  
Local nHdlPrv		:= 65536
// MBARROS  Local nHdlPrv := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
//Local _nPorcPIS := 0
//Local _nPorcCOF := 0
//Local _nPorcCSL := 0

Private _nPIS		:= 0
Private _nCOF		:= 0
Private _nCSL		:= 0

Public cAliasQ1		:= GetNextAlias()	//CriaTrab(nil,.F.)	//GetNextAlias() 
Public cAliasQ2		:= GetNextAlias()	//CriaTrab(nil,.F.)	//GetNextAlias()
                       
_cQuery:="SELECT G8Y_VALOR, G8Y_CONCIL, G8Y_FILREF FROM "+RetSqlName("G8Y")+" G8Y "
_cQuery+="WHERE "
_cQuery+="G8Y.G8Y_FILIAL     = '"+SE5->E5_FILIAL+"' "
_cQuery+="AND G8Y.G8Y_PREFIX = '"+SE5->E5_PREFIXO+"' "
_cQuery+="AND G8Y.G8Y_NUM    = '"+SE5->E5_NUMERO+"' "
_cQuery+="AND G8Y.G8Y_TIPO   = '"+SE5->E5_TIPO+"' "
//_cQuery+="AND G8Y.D_E_L_E_T_= '' "
_cQuery+="AND G8Y.D_E_L_E_T_  <> '*' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQ1,.T.,.T.)
nVlrFat := (cAliasQ1)->G8Y_VALOR  // Valor Total da Conciliação.

_cQueryA:="SELECT G4C_NUMID, G4C_OPERAC, G4C_CLASS, G4C_GRPPRD, G4C_NATUR, G4C_VALOR, G4C_CONORI  FROM "+RetSqlName("G4C")+" G4C "	
_cQueryA+="WHERE "
_cQuerya+="G4C.G4C_FILIAL= '"+(cAliasQ1)->G8Y_FILREF+"' "
_cQuerya+="AND G4C.G4C_CONORI = '"+(cAliasQ1)->G8Y_CONCIL+"' "
_cQuerya+="AND G4C.G4C_CLIFOR = '2' " //Filtra somente fornecedor
//_cQuerya+="AND G4C.D_E_L_E_T_='' "
//_cQuerya+="AND G4C.D_E_L_E_T_='' "
_cQuerya+="AND G4C.D_E_L_E_T_ <> '*' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuerya),cAliasQ2,.T.,.T.)
     
dbSelectArea(cAliasQ2)
dbGoTop()
while !EOF()	
	
	_cArea1 := GetArea()
	
	//Para baixa parcial
	nVlrParc := (cAliasQ2)->G4C_VALOR/nVlrFat
	nVlrRV := (SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
	
	//Posicionamento SE1
	SE1->(dbSetOrder(2))
	If SE1->(MsSeek(xFilial("SE1")+ SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO ))// PREFIXO, NUMERO, PARCELA, TIPO, CLIFOR e LOJA
		//Parcial para Imposto
		//PIS
	   	_nPIS := SE1->E1_PIS * nVlrParc // Utilizar esta variavel para o valor PIS
		//COFINS
		_nCOF := SE1->E1_COFINS * nVlrParc // Utilizar esta variavel para o valor COFINS
		//CSLL
		_nCSL := SE1->E1_CSLL * nVlrParc // Utilizar esta variavel para o valor CSLL
		//
	Endif	
	//Chama Lançamento Especifico
	If nVlrRV > 0
		nTotalLcto += DetProva(nHdlPrv,"T79",cProg,cLote) // T01 é o LP especifico
	EndIf
	RestArea(_cArea1)
	
	(cAliasQ2)->(DBSKIP())
ENDDO

If nTotalLcto > 0
   nTotDoc += nTotalLcto
   lCtbTur := .T. // Barros Gerou CTK atendendo as Regras
ENDIF   		

//Treco abaixo do rodaprava e ca100incl para rodar em conjunto com o CTBAFIN, antes estava sem isso funciona no CTBAFINTUR
If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documento
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.,,SE5->E5_DTDISPO)
//		End Transaction
	Endif
EndIf

nRet:=0 

(cAliasQ1)->(dbCloseArea())
(cAliasQ2)->(dbCloseArea())

Return()

//Estorno Contabilização dos Prefixo NF Conciliações Terrestre e Reembolso de Turismo
Static Function _CTBECON()

Local _cQuery		:= ''
Local _cQuerya		:= ''
Local nTotalLcto	:= 0
Local aArea			:= GetArea()
Local cLote			:= LoteCont("FIN")
Local cProg			:= "CTBAFIN"
Local cArquivo		:= ""
//Local nHdlPrv := HeadProva(cLote,cProg,Subs(cUsuario,7,6),@cArquivo) //Cabeçalho do Lançamento
Local nHdlPrv		:= 65536

Public cAliasQ1		:= GetNextAlias()	//CriaTrab(nil,.F.)	//GetNextAlias() 
Public cAliasQ2		:= GetNextAlias()	//CriaTrab(nil,.F.)	//GetNextAlias()

_cQuery:="SELECT G8Y_VALOR, G8Y_CONCIL, G8Y_FILREF FROM "+RetSqlName("G8Y")+" G8Y "
_cQuery+="WHERE "
_cQuery+="G8Y.G8Y_FILIAL     = '"+SE5->E5_FILIAL+"' "
_cQuery+="AND G8Y.G8Y_PREFIX = '"+SE5->E5_PREFIXO+"' "
_cQuery+="AND G8Y.G8Y_NUM    = '"+SE5->E5_NUMERO+"' "
_cQuery+="AND G8Y.G8Y_TIPO   = '"+SE5->E5_TIPO+"' "
//_cQuery+="AND G8Y.D_E_L_E_T_= '' "
_cQuery+="AND G8Y.D_E_L_E_T_ <> '*' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQ1,.T.,.T.)
nVlrFat := (cAliasQ1)->G8Y_VALOR  // Valor Total da Conciliação.
	
_cQueryA:="SELECT G4C_NUMID, G4C_OPERAC, G4C_CLASS, G4C_GRPPRD, G4C_NATUR, G4C_VALOR, G4C_CONORI  FROM "+RetSqlName("G4C")+" G4C "
_cQueryA+="WHERE "
_cQuerya+="G4C.G4C_FILIAL= '"+(cAliasQ1)->G8Y_FILREF+"' "
_cQuerya+="AND G4C.G4C_CONORI = '"+(cAliasQ1)->G8Y_CONCIL+"' "
_cQuerya+="AND G4C.G4C_CLIFOR = '2' " //Filtra somente fornecedor
//_cQuerya+="AND G4C.D_E_L_E_T_='' "
//_cQuerya+="AND G4C.D_E_L_E_T_='' "
_cQuerya+="AND G4C.D_E_L_E_T_ <> '*' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuerya),cAliasQ2,.T.,.T.)
     
dbSelectArea(cAliasQ2)
dbGoTop()
while !EOF()	
	
	_cArea1 := GetArea()
	
	//Para baixa parcial
	nVlrParc := (cAliasQ2)->G4C_VALOR/nVlrFat
	nVlrRV   := (SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
	//
	
	//Chama Lançamento Especifico
	If nVlrRV > 0
		nTotalLcto += DetProva(nHdlPrv,"T78",cProg,cLote) // T01 é o LP especifico
	EndIf
	RestArea(_cArea1)
	
	(cAliasQ2)->(DBSKIP())
ENDDO

If nTotalLcto > 0
   nTotDoc += nTotalLcto
   lCtbTur := .T. // Barros Gerou CTK atendendo as Regras
ENDIF   		

//Treco abaixo do rodaprava e ca100incl para rodar em conjunto com o CTBAFIN, antes estava sem isso funciona no CTBAFINTUR
If nHdlPrv > 0
	Rodaprova(nHdlPrv,nTotalLcto)
	If nTotalLcto > 0
		nTotalLcto := 0
		//Cria transacao para garantir atualizacao do documento
//		Begin Transaction
		cA100Incl(cArquivo,nHdlPrv,3,cLote,_lDigita,.F.,,SE5->E5_DTDISPO)
//		End Transaction
	Endif
EndIf

nRet:=0  

(cAliasQ1)->(dbCloseArea())
(cAliasQ2)->(dbCloseArea())

Return()