#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"

//--------------------------------------------------
	/*/{Protheus.doc} CMPTUR
	 
    Contabilização da compensação de RA's
	
	@author André Brito / Edelcio
	@since 02/01/2020
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function CMPTUR(_cTipo, _cOpc) 

Local aArea	      := GetArea()
Local nRet		  := 0
Local aAreaSe5    := SE5->(GetArea())

//Variaveis que serão utilizadas nos Lp's Especificos T9* >
Private nVlrRV        := 0
Private nVrlJur       := 0 //Juros de Fee - Apuração Cliente
Private nVlrFat       := 0
Private nVlrParc      := 0
Private _lDigita      := .F. 
Private lCtbTur       := .F.   // Flag para identificar se contabilizou algum item MBARROS 24/03/2017 - Nao Gravar Flag SE5 se nao atendeu a Regra.
Private __cTurProcess := "R" 

Private cAliasQ1 := GetNextAlias()	//CriaTrab(nil,.F.)	//GetNextAlias()
Private cAliasQ2 := GetNextAlias()	//CriaTrab(nil,.F.)	//GetNextAlias()

Public lxLP596 := .f.

IF Type("nTotDoc")="U"
   nTotDoc := 0
ENDIF
  
_lDigita:= .F.

If ISINCALLSTACK("FINA370") .OR. ISINCALLSTACK("CTBAFIN")  
	Pergunte("FIN370",.F.) 
EndIf

//_lDigita:=IIF(mv_par01==1 .OR. _cTipo="2",.T.,.F.)
_lDigita:=IIF(mv_par01==1,.T.,.F.)

If _cTipo = '1' //Contabilização

	If _cOpc = 'FAT' .Or. _cOpc ='BRK' .Or. _cOpc ='CDT' //Faturas de Vendas
		_CMPFAT()
	ElseIF _cOpc = 'APU' //Apuração de Clientes
		_CMPAPUR()
	Else
		Return(nRet)
	EndIf

ElseIf _cTipo = '2'//Estorno das Contabilizações
	If _cOpc = 'FAT' .Or. _cOpc ='BRK' .Or. _cOpc ='CDT' //Faturas de Vendas
		_CMPEFAT()
	ElseIF _cOpc = 'APU' //Apuração de Clientes
		_CMPEPUR()
	Else
		Return(nRet)
	EndIf
EndIf

If  lCtbTur //_cOpc = 'FAT' .OR. _cOpc = 'APU' .OR. _cOpc = 'BRK' .OR. _cOpc = 'CDT' 
	RecLock("SE5",.F.)
		SE5->E5_LA:= 'S'
	Msunlock()
EndIF

RestArea(aAreaSe5) 
RestArea(aArea)

Return(nRet)

//--------------------------------------------------
	/*/{Protheus.doc} CMPFAT
	 
     Contabilização dos Prefixo FAT/APU de Turismo
	
	@author André Brito / Edelcio
	@since 02/01/2020
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

Static Function _CMPFAT()

Local _cQuery    := ''
Local _cQuerya   := ''
Local nTotalLcto := 0
Local aArea      := GetArea()
Local aAreaBkp   := GetArea()
Local cLote      := LoteCont("FIN")
Local cProg      := "CTBAFIN"
Local cArquivo   := ""                  
Local nHdlPrv    := 65536
Local nPerc      := 0

Private _nPIS := 0
Private _nCOF := 0
Private _nCSL := 0

IF (ALLTRIM(SE5->E5_PREFIXO) == 'FAT' .OR. ALLTRIM(SE5->E5_PREFIXO) == 'BRK' .OR. ALLTRIM(SE5->E5_PREFIXO) == 'CDT')
      
	_cQuery:="SELECT SUM(G85_VALOR) VLRFAT FROM "+RetSqlName("G85")+" G85 "
	_cQuery+="WHERE "
	//_cQuery+="G85.G85_FILIAL     = '"+SE5->E5_FILIAL+"' "
	_cQuery+="G85.G85_PREFIX = '"+SE5->E5_PREFIXO+"' "
	_cQuery+="AND G85.G85_NUMFAT = '"+SE5->E5_NUMERO+"' "
	_cQuery+="AND G85.D_E_L_E_T_= '' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQ1,.T.,.T.)
	nVlrFat:=VLRFAT // Valor Total da Fatura.
		
	(cAliasQ1)->(dbCloseArea())
	
	_cQueryA:="SELECT G85_NUMFAT, G85_REGVEN, G85_CLASS, G85_VALOR, G85_GRPPRD, G85_PREFIX,G85_ITVEND,G85_SEQIV,G85_FILREF FROM "+RetSqlName("G85")+" G85 "
	_cQueryA+="WHERE "
	//_cQuerya+="G85.G85_FILIAL= '"+SE5->E5_FILIAL+"' "
	_cQuerya+="G85.G85_NUMFAT = '"+SE5->E5_NUMERO+"' "
	_cQuerya+="AND G85.G85_PREFIX = '"+SE5->E5_PREFIXO+"' "
	_cQuerya+="AND G85.D_E_L_E_T_='' "
	_cQuerya+="AND G85.D_E_L_E_T_='' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuerya),cAliasQ2,.T.,.T.)
	
	dbSelectArea(cAliasQ2)
	dbGoTop()
	while !EOF()
		
		lxLP596 := .t.	//Essa variavel é utilizada no LpTur02.prw
		
		_cArea1 := GetArea()
		
		//Para baixa parcialand
		nVlrParc := (cAliasQ2)->G85_VALOR
		nVlrRV   :=  nVlrParc// (SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
		
		//Posicionamento SE1
		DbSelectArea("SE1")
		SE1->(dbSetOrder(2))//Alterei abaixo para FILORIG
		If SE1->(MsSeek(SE5->E5_FILORIG + SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO ))// PREFIXO, NUMERO, PARCELA, TIPO, CLIFOR e LOJA
		
			nPerc     := ((cAliasQ2)->G85_VALOR / SE1->E1_VALOR) * 100
			nVlrRV    := Round((SE5->E5_VALOR * nPerc) / 100,3)
			
			//Parcial para Imposto
			//PIS
		   	_nPIS := SE1->E1_PIS * nVlrParc // Utilizar esta variavel para o valor PIS
			
			//COFINS
			_nCOF := SE1->E1_COFINS * nVlrParc // Utilizar esta variavel para o valor COFINS
			
			//CSLL
			_nCSL := SE1->E1_CSLL * nVlrParc // Utilizar esta variavel para o valor CSLL
			//
		Endif
		
		RestArea(_cArea1)
		//Chama Lançamento Especifico
		If nVlrRV > 0
			nTotalLcto += DetProva(nHdlPrv,"T62",cProg,cLote) // T01 é o LP especifico
		EndIf
		
		(cAliasQ2)->(DBSKIP())
	EndDo
	
	(cAliasQ2)->(dbCloseArea())
	
	If nTotalLcto > 0
	   nTotDoc += nTotalLcto
	   lCtbTur := .T. // Barros Gerou CTK atendendo as Regras
	EndIf
Else
		
	_cArea1 := GetArea()
	
	DbSelectArea("SE1")
	DbSetOrder(1)
	If DbSeek( SE5->E5_FILIAL + SUBSTR(SE5->E5_DOCUMEN,1,3) + SUBSTR(SE5->E5_DOCUMEN,4,9) + SUBSTR(SE5->E5_DOCUMEN,13,1)  + SUBSTR(SE5->E5_DOCUMEN,14,3) )

		_cQuery:="SELECT SUM(G85_VALOR) VLRFAT FROM "+RetSqlName("G85")+" G85 "
		_cQuery+="WHERE "
		//_cQuery+="G85.G85_FILIAL     = '"+SE1->E1_FILIAL+"' "
		_cQuery+="G85.G85_PREFIX = '"+SE1->E1_PREFIXO+"' "
		_cQuery+="AND G85.G85_NUMFAT = '"+SE1->E1_NUM+"' "
		_cQuery+="AND G85.D_E_L_E_T_= '' "
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQ1,.T.,.T.)
		nVlrFat:=VLRFAT // Valor Total da Fatura.
			
		(cAliasQ1)->(dbCloseArea())
		
		_cQueryA:="SELECT G85_NUMFAT, G85_REGVEN, G85_CLASS, G85_VALOR, G85_GRPPRD, G85_PREFIX,G85_ITVEND,G85_SEQIV,G85_FILREF FROM "+RetSqlName("G85")+" G85 "
		_cQueryA+="WHERE "
		//_cQuerya+="G85.G85_FILIAL= '"+SE1->E1_FILIAL+"' "
		_cQuerya+="G85.G85_NUMFAT = '"+SE1->E1_NUM+"' "
		_cQuerya+="AND G85.G85_PREFIX = '"+SE1->E1_PREFIXO+"' "
		_cQuerya+="AND G85.D_E_L_E_T_='' "
		_cQuerya+="AND G85.D_E_L_E_T_='' "
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuerya),cAliasQ2,.T.,.T.)
		
		dbSelectArea(cAliasQ2)
		dbGoTop()
		while !EOF()
			
			lxLP596 := .t.	//Essa variavel é utilizada no LpTur02.prw
			
			//_cArea1 := GetArea()
			
			//Para baixa parcial
			If SE5->E5_VALOR < SE1->E1_VALOR
				nPerc  := ((cAliasQ2)->G85_VALOR / SE1->E1_VALOR) * 100
				nVlrRV    := Round((SE5->E5_VALOR * nPerc) / 100,3)
			Else
				nVlrParc := (cAliasQ2)->G85_VALOR
				nVlrRV   :=  nVlrParc// (SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO) * nVlrParc // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
			EndIf
			//PIS
		   	_nPIS := SE1->E1_PIS * nVlrParc // Utilizar esta variavel para o valor PIS
			
			//COFINS
			_nCOF := SE1->E1_COFINS * nVlrParc // Utilizar esta variavel para o valor COFINS
			
			//CSLL
			_nCSL := SE1->E1_CSLL * nVlrParc // Utilizar esta variavel para o valor CSLL
			
			RestArea(_cArea1)
			
			//Chama Lançamento Especifico
			If nVlrRV > 0
				nTotalLcto += DetProva(nHdlPrv,"T62",cProg,cLote) // T01 é o LP especifico
			EndIf
			
			(cAliasQ2)->(DBSKIP())
		EndDo
		
		//(cAliasQ2)->(dbCloseArea())
		
		//RestArea(aAreaBkp)
	EndIf
EndIf

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

RestArea(aArea)

Return() 


//--------------------------------------------------
	/*/{Protheus.doc} CMPPUR
	 
     Contabiliza Apuração de Cliente
	
	@author André Brito / Edelcio
	@since 02/01/2020
	@version P12.1.17
	 
	@return andre
	/*/
//--------------------------------------------------

Static Function _CMPAPUR() 

Local cAliasG6M		:= GetArea("G6M")
Local aArea	        := GetArea()
Local aAreaSE5	    := {}
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
Local lSe1          := .F.
Local cNum          := ""
Local cFilSe        := ""
Local cPrefixo      := ""

Private nVlrFat		:= 0
Private nVlrApu		:= 0

_cArea1 := GetArea()

IF(ALLTRIM(SE5->E5_PREFIXO)=='APU' .OR. ALLTRIM(SE1->E1_PREFIXO)=='APU' .OR. SUBSTR(SE5->E5_DOCUMEN,1,3) != "APU")
	
		cFilDes  := SE5->E5_FILORIG
		cPrefixo := SE5->E5_PREFIXO
		cNumero  := SE5->E5_NUMERO
	
	BeginSql Alias cAliasQ1
		SELECT G85_FILIAL,G85_PREFIX,G85_NUMFAT,G85_CODAPU,G85_SEGNEG,G85_CLASS,G85_VALOR,G85_FILREF
		FROM %table:SE5% SE5 (NOLOCK)
		JOIN %table:G85% G85 (NOLOCK) ON (G85_FILIAL=E5_FILIAL AND G85_NUMFAT = E5_NUMERO AND G85.D_E_L_E_T_<>'*')
		JOIN %table:G81% G81 (NOLOCK) ON (G81_IDIFA=G85_IDIFA AND G81_FILREF=G85_FILREF AND G81.D_E_L_E_T_<>'*')
		JOIN %table:G48% G48 (NOLOCK) ON((G48.G48_FILAPU=G81_FILIAL AND G48.G48_CODAPU=G81.G81_CODAPU AND G48.G48_SEGNEG=G81_SEGNEG AND G48.D_E_L_E_T_<>'*' 
											AND G48.G48_CONINU=' ' AND G48.G48_CLIFOR='1')
											OR (G48.G48_FILREF=G81_FILREF AND G48.G48_CODAPU=G81.G81_CODAPU AND G48.G48_SEGNEG=G81_SEGNEG AND G48.D_E_L_E_T_<>'*' 
											AND G48.G48_CONINU=' ' AND G48.G48_CLIFOR='2'))
		JOIN %table:G3Q% G3Q (NOLOCK) ON (G3Q_FILIAL=G48.G48_FILIAL AND G3Q_NUMID=G48.G48_NUMID AND G3Q_IDITEM=G48.G48_IDITEM AND G3Q_NUMSEQ=G48.G48_NUMSEQ 
											AND G3Q.D_E_L_E_T_<>'*' AND G3Q_CONINU=' ')
		WHERE G85.G85_FILIAL = %exp:cFilDes%
		AND   G85.G85_PREFIX = %exp:cPrefixo%
		AND   G85.G85_NUMFAT = %exp:cNumero%
		//AND	  SE5.R_E_C_N_O_ = %exp:nRecSE5%
		AND   SE5.%NotDel% GROUP BY G85_FILIAL,G85_PREFIX,G85_NUMFAT,G85_CODAPU,G85_SEGNEG,G85_CLASS,G85_VALOR,G85_FILREF
	EndSql
	
	dbSelectArea(cAliasQ1)
	(cAliasQ1)->(dbGoTop())
	
	//Apuração de Cliente e Fornecedores
	If (cAliasQ1)->(!EOF())
		
		(cAliasQ1)->(dbGoTop())
		while (cAliasQ1)->(!EOF())

			nVlrApu :=  (cAliasQ1)->G85_VALOR

			If nVlrApu > 0
				nTotalLcto += DetProva(nHdlPrv,"T64",cProg,cLote) // T01 é o LP especifico
			EndIf
			
			(cAliasQ1)->(DBSKIP())
		ENDDO
		
		RestArea(_cArea1)
			
		(cAliasQ1)->(dbCloseArea())
	EndIf
Else

	aAreaSE5	    := GetArea()
	
	DbSelectArea("SE1")
	DbSetOrder(1)
	lSe1 := DbSeek(SE5->E5_FILIAL + SUBSTR(SE5->E5_DOCUMEN,1,3) + SUBSTR(SE5->E5_DOCUMEN,4,9) + SUBSTR(SE5->E5_DOCUMEN,13,1)  + SUBSTR(SE5->E5_DOCUMEN,14,3) )
	
	If lSe1
		cNum          := SE1->E1_NUM
        cFilSe        := SE1->E1_FILORIG
        cPrefixo      := SE1->E1_PREFIXO
	Else
		cNum          := SE5->E5_NUMERO
        cFilSe        := SE5->E5_FILORIG
        cPrefixo      := SE5->E5_PREFIXO
	EndIf
	
		BeginSql Alias cAliasQ1
			SELECT G85_FILIAL,G85_PREFIX,G85_NUMFAT,G85_CODAPU,G85_SEGNEG,G85_CLASS,G85_VALOR,G85_FILREF
			FROM %table:SE5% SE5 (NOLOCK)
			JOIN %table:G85% G85 (NOLOCK) ON (G85_FILIAL=E5_FILIAL AND G85_NUMFAT = E5_NUMERO AND G85.D_E_L_E_T_<>'*')
			JOIN %table:G81% G81 (NOLOCK) ON (G81_IDIFA=G85_IDIFA AND G81_FILREF=G85_FILREF AND G81.D_E_L_E_T_<>'*')
			JOIN %table:G48% G48 (NOLOCK) ON((G48.G48_FILAPU=G81_FILIAL AND G48.G48_CODAPU=G81.G81_CODAPU AND G48.G48_SEGNEG=G81_SEGNEG AND G48.D_E_L_E_T_<>'*' 
			AND G48.G48_CONINU=' ' AND G48.G48_CLIFOR='1')
			OR (G48.G48_FILREF=G81_FILREF AND G48.G48_CODAPU=G81.G81_CODAPU AND G48.G48_SEGNEG=G81_SEGNEG AND G48.D_E_L_E_T_<>'*' 
			AND G48.G48_CONINU=' ' AND G48.G48_CLIFOR='2'))
			JOIN %table:G3Q% G3Q (NOLOCK) ON (G3Q_FILIAL=G48.G48_FILIAL AND G3Q_NUMID=G48.G48_NUMID AND G3Q_IDITEM=G48.G48_IDITEM AND G3Q_NUMSEQ=G48.G48_NUMSEQ 
			AND G3Q.D_E_L_E_T_<>'*' AND G3Q_CONINU=' ')
			WHERE G85.G85_FILIAL = %exp:cFilSe%
			AND   G85.G85_PREFIX = %exp:cPrefixo%
			AND   G85.G85_NUMFAT = %exp:cNum%
			AND   SE5.%NotDel% GROUP BY G85_FILIAL,G85_PREFIX,G85_NUMFAT,G85_CODAPU,G85_SEGNEG,G85_CLASS,G85_VALOR,G85_FILREF
		EndSql
	
	dbSelectArea(cAliasQ1)
	(cAliasQ1)->(dbGoTop())
		
	If (cAliasQ1)->(!EOF())
		
		(cAliasQ1)->(dbGoTop())
		while (cAliasQ1)->(!EOF())
			
			_cArea1 := GetArea()
			
			If SE5->E5_TIPO == "RA "
				nVlrApu :=  SE5->E5_VALOR
			Else
				nVlrApu :=  SE1->E1_VALOR //Verificar para subsituir para E5_VALOR
			EndIf
			If nVlrApu > 0
				nTotalLcto += DetProva(nHdlPrv,"T64",cProg,cLote) // T01 é o LP especifico
			EndIf
			
			RestArea(_cArea1)
			
			(cAliasQ1)->(DBSKIP())
			
		EndDo
	EndIf
EndIf

RestArea(aArea)

If nTotalLcto > 0
   nTotDoc += nTotalLcto
   lCtbTur := .T. // Barros Gerou CTK atendendo as Regras
EndIf
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

Return()


//--------------------------------------------------
	/*/{Protheus.doc} CMPEFAT
	 
    Estornos da Contabilização dos Prefixo FAT/APU de Turismo
	
	@author André Brito / Edelcio
	@since 02/01/2020
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

Static Function _CMPEFAT()

Local _cQuery		:= ''
Local _cQuerya		:= ''
Local nTotalLcto	:= 0
Local aArea			:= GetArea()
Local cLote			:= LoteCont("FIN")
Local cProg			:= "CTBAFIN"
Local cArquivo		:= ""
Local nHdlPrv		:= 65536
Local cDelG85		:= "%G85.D_E_L_E_T_ <> '*'%"
Local nVlrSom       := 0
Local lSe1          := .F.
Local cNum          := ""
Local cFilSe        := ""
Local cPrefixo      := ""

IF (SE5->E5_TIPO == "RA ")
	BeginSql Alias cAliasQ2
		SELECT G85_NUMFAT, G85_REGVEN, G85_CLASS, G85_VALOR, G85_GRPPRD, G85_PREFIX,G85_ITVEND,G85_SEQIV,G85_FILREF
		FROM %table:G85% G85 (NOLOCK)
		WHERE //G85.G85_FILIAL	= %Exp:SE5->E5_FILIAL%
		G85.G85_PREFIX		= %Exp:SUBSTR(SE5->E5_DOCUMEN,1,3)%
		AND G85.G85_NUMFAT		= %Exp:SUBSTR(SE5->E5_DOCUMEN,4,9)%
		AND %Exp:cDelG85%
	EndSql
	
	dbSelectArea(cAliasQ2)
	dbGoTop()
	while !EOF()
	
		_cArea1 := GetArea()
		
		lxLP596 := .t.	//Essa variavel é utilizada no LpTur02.prw
		//Colocar InCallStack
		
		If ISINCALLSTACK("FINA370") .OR. ISINCALLSTACK("CTBAFIN")  
			DbSelectArea("SE1")
			DbSetOrder(1)
			lSe1 := DbSeek(SE5->E5_FILIAL + SUBSTR(SE5->E5_DOCUMEN,1,3) + SUBSTR(SE5->E5_DOCUMEN,4,9) + SUBSTR(SE5->E5_DOCUMEN,13,1)  + SUBSTR(SE5->E5_DOCUMEN,14,3) )
			
			nPerc  := ((cAliasQ2)->G85_VALOR / SE5->E5_VALOR) * 100
			nVlrRV := Round((SE5->E5_VALOR * nPerc) / 100,3)
		Else
			If !lSe1
				nPerc  := ((cAliasQ2)->G85_VALOR / SE5->E5_VALOR) * 100
				nVlrRV := Round((SE5->E5_VALOR * nPerc) / 100,3)
			Else
				nPerc  := ((cAliasQ2)->G85_VALOR / SE1->E1_VALOR) * 100
				nVlrRV := Round((SE1->E1_VALOR * nPerc) / 100,3)
			EndIf
		EndIf
		
		If nVlrRV > 0
			nTotalLcto += DetProva(nHdlPrv,"T63",cProg,cLote) // T01 é o LP especifico
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
Else
	BeginSql Alias cAliasQ2
		SELECT G85_NUMFAT, G85_REGVEN, G85_CLASS, G85_VALOR, G85_GRPPRD, G85_PREFIX,G85_ITVEND,G85_SEQIV,G85_FILREF
		FROM %table:G85% G85 (NOLOCK)
		WHERE //G85.G85_FILIAL	= %Exp:SE5->E5_FILIAL%
		G85.G85_PREFIX		= "FAT"
		AND G85.G85_NUMFAT		= %Exp:SE5->E5_NUMERO%
		AND %Exp:cDelG85%
	EndSql
		
	nVlrSom := SomaG85()
	
	dbSelectArea(cAliasQ2)
	dbGoTop()
		
	while (cAliasQ2)->(!EOF())
		
		_cArea1 := GetArea()
		
		lxLP596 := .t.	//Essa variavel é utilizada no LpTur02.prw
		
		nPerc  := ((cAliasQ2)->G85_VALOR  / nVlrSom) * 100
		nVlrRV    := Round((SE5->E5_VALOR * nPerc) / 100,3)
		
		If nVlrRV > 0
			nTotalLcto += DetProva(nHdlPrv,"T63",cProg,cLote) // T01 é o LP especifico
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
EndIf

RestArea(aArea)

Return()

//--------------------------------------------------
	/*/{Protheus.doc} CMPEPUR
	 
    Contabiliza Apuração de Cliente
	
	@author André Brito / Edelcio
	@since 02/01/2020
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

Static Function _CMPEPUR() 

Local cAliasG6M		:= G6M->(GetArea())
Local aArea	        := GetArea()
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
Local nRecSE5		:= SE5->(RECNO())
Local cTp           := ""
Local cNum          := ""
Local cFilSe        := ""
Local cPrefixo      := ""
Local lSe1          := .F.

Private nVlrFat		:= 0
Private nVlrApu		:= 0

IF (SE5->E5_TIPO == "RA ")

	DbSelectArea("SE1")
	DbSetOrder(1)
	
	lSe1 := DbSeek(SE5->E5_FILIAL+ SUBSTR(SE5->E5_DOCUMEN,1,3) + SUBSTR(SE5->E5_DOCUMEN,4,9) + SUBSTR(SE5->E5_DOCUMEN,13,1)  + SUBSTR(SE5->E5_DOCUMEN,14,3) )
	
	If lSe1
		cNum          := SE1->E1_NUM
        cFilSe        := SE1->E1_FILIAL
        cPrefixo      := SE1->E1_PREFIXO
	Else
		cNum          := SE5->E5_NUMERO
        cFilSe        := SE5->E5_FILIAL
        cPrefixo      := SE5->E5_PREFIXO
	EndIf
	
	BeginSql Alias cAliasQ1
		SELECT G85_FILIAL,G85_PREFIX,G85_NUMFAT,G85_CODAPU,G85_SEGNEG,G85_CLASS,G85_VALOR,G85_FILREF
		FROM %table:SE5% SE5 (NOLOCK)
		JOIN %table:G85% G85 (NOLOCK) ON (G85_FILIAL=E5_FILIAL AND G85_NUMFAT = E5_NUMERO AND G85.D_E_L_E_T_<>'*')
		JOIN %table:G81% G81 (NOLOCK) ON (G81_IDIFA=G85_IDIFA AND G81_FILREF=G85_FILREF AND G81.D_E_L_E_T_<>'*')
		JOIN %table:G48% G48 (NOLOCK) ON((G48.G48_FILAPU=G81_FILIAL AND G48.G48_CODAPU=G81.G81_CODAPU AND G48.G48_SEGNEG=G81_SEGNEG AND G48.D_E_L_E_T_<>'*' 
											AND G48.G48_CONINU=' ' AND G48.G48_CLIFOR='1')
											OR (G48.G48_FILREF=G81_FILREF AND G48.G48_CODAPU=G81.G81_CODAPU AND G48.G48_SEGNEG=G81_SEGNEG AND G48.D_E_L_E_T_<>'*' 
											AND G48.G48_CONINU=' ' AND G48.G48_CLIFOR='2'))
		JOIN %table:G3Q% G3Q (NOLOCK) ON (G3Q_FILIAL=G48.G48_FILIAL AND G3Q_NUMID=G48.G48_NUMID AND G3Q_IDITEM=G48.G48_IDITEM AND G3Q_NUMSEQ=G48.G48_NUMSEQ 
											AND G3Q.D_E_L_E_T_<>'*' AND G3Q_CONINU=' ')
		WHERE G85.G85_FILIAL = %exp:cFilSe%
		AND   G85.G85_PREFIX = "APU"
		AND   G85.G85_NUMFAT = %exp:cNum%
		AND   SE5.%NotDel% GROUP BY G85_FILIAL,G85_PREFIX,G85_NUMFAT,G85_CODAPU,G85_SEGNEG,G85_CLASS,G85_VALOR,G85_FILREF
	EndSql
	
	dbSelectArea(cAliasQ1)
	(cAliasQ1)->(dbGoTop())
	
	//Apuração de Cliente e Fornecedores
	If (cAliasQ1)->(!EOF())
		
		(cAliasQ1)->(dbGoTop())
		while (cAliasQ1)->(!EOF())
			
			//_cArea1 := GetArea()
			
			nVlrApu :=  SE5->E5_VALOR//-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO)+ nImp )- vJurApu) * nVlrParc //- vJurApu // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
			
			//Chama Lançamento Especifico
			If nVlrApu > 0
				nTotalLcto += DetProva(nHdlPrv,"T65",cProg,cLote) // T01 é o LP especifico
			EndIf
			
			//RestArea(_cArea1)
			
			(cAliasQ1)->(DBSKIP())
		ENDDO	
	EndIf
Else

		cNum          := SE5->E5_NUMERO
        cFilSe        := SE5->E5_FILORIG
        cPrefixo      := SE5->E5_PREFIXO
	
		BeginSql Alias cAliasQ1
			SELECT G85_FILIAL,G85_PREFIX,G85_NUMFAT,G85_CODAPU,G85_SEGNEG,G85_CLASS,G85_VALOR,G85_FILREF
			FROM %table:SE5% SE5 (NOLOCK)
			JOIN %table:G85% G85 (NOLOCK) ON (G85_FILIAL=E5_FILIAL AND G85_NUMFAT = E5_NUMERO AND G85.D_E_L_E_T_<>'*')
			JOIN %table:G81% G81 (NOLOCK) ON (G81_IDIFA=G85_IDIFA AND G81_FILREF=G85_FILREF AND G81.D_E_L_E_T_<>'*')
			JOIN %table:G48% G48 (NOLOCK) ON((G48.G48_FILAPU=G81_FILIAL AND G48.G48_CODAPU=G81.G81_CODAPU AND G48.G48_SEGNEG=G81_SEGNEG AND G48.D_E_L_E_T_<>'*' 
												AND G48.G48_CONINU=' ' AND G48.G48_CLIFOR='1')
												OR (G48.G48_FILREF=G81_FILREF AND G48.G48_CODAPU=G81.G81_CODAPU AND G48.G48_SEGNEG=G81_SEGNEG AND G48.D_E_L_E_T_<>'*' 
												AND G48.G48_CONINU=' ' AND G48.G48_CLIFOR='2'))
			JOIN %table:G3Q% G3Q (NOLOCK) ON (G3Q_FILIAL=G48.G48_FILIAL AND G3Q_NUMID=G48.G48_NUMID AND G3Q_IDITEM=G48.G48_IDITEM AND G3Q_NUMSEQ=G48.G48_NUMSEQ 
												AND G3Q.D_E_L_E_T_<>'*' AND G3Q_CONINU=' ')
			WHERE G85.G85_FILIAL = %exp:cFilSe%
			AND   G85.G85_PREFIX = "APU"
			AND   G85.G85_NUMFAT = %exp:cNum%
			AND   SE5.%NotDel% GROUP BY G85_FILIAL,G85_PREFIX,G85_NUMFAT,G85_CODAPU,G85_SEGNEG,G85_CLASS,G85_VALOR,G85_FILREF
		EndSql
		
		dbSelectArea(cAliasQ1)
		(cAliasQ1)->(dbGoTop())
		
		//Apuração de Cliente e Fornecedores
		If (cAliasQ1)->(!EOF())
			
			(cAliasQ1)->(dbGoTop())
			while (cAliasQ1)->(!EOF())
				
				_cArea1 := GetArea()
				
				nVlrApu :=  SE5->E5_VALOR//-SE5->E5_VLJUROS-SE5->E5_VLMULTA-SE5->E5_VLCORRE+SE5->E5_VLDESCO)+ nImp )- vJurApu) * nVlrParc //- vJurApu // UTILIZAR ESTA VARIAVEL NO LP PARA CONTABILIZAR O VALOR.
				
				//Chama Lançamento Especifico
				If nVlrApu > 0
					nTotalLcto += DetProva(nHdlPrv,"T65",cProg,cLote) // T01 é o LP especifico
				EndIf
				
				RestArea(_cArea1)
				
				(cAliasQ1)->(DBSKIP())
			ENDDO	
	EndIf
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
 
//(cAliasQ1)->(dbCloseArea())
	
RestArea(aArea)

Return()

Static Function SomaG85()

Local aArea	    := GetArea()
Local nVlrG85   := 0
Local cDelG85   := "%G85.D_E_L_E_T_ <> '*'%"
Local cAliaQs   := GetNextAlias()

BeginSql Alias cAliaQs
	SELECT SUM(G85_VALOR) SOMA
	FROM %table:G85% G85 (NOLOCK)
	WHERE //G85.G85_FILIAL	= %Exp:SE5->E5_FILIAL%
	G85.G85_PREFIX		= "FAT"
	AND G85.G85_NUMFAT		= %Exp:SE5->E5_NUMERO%
	AND %Exp:cDelG85%
EndSql

nVlrG85 := (cAliaQs)->SOMA
	
(cAliaQs)->(dbCloseArea())

RestArea(aArea)

Return nVlrG85