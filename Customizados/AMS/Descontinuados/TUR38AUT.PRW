#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

#DEFINE TIPOLAYOUT	1
#DEFINE DIRETORIO	2
#DEFINE ARQUIVO		3
#DEFINE LAYOUTMILE	4
#DEFINE VALORFATUR	5

#DEFINE BSP		1
#DEFINE GOL		2
#DEFINE AVIANCA	3
#DEFINE TAM		4

/*/{Protheus.doc} TUR38AUT
Rotina para simulação de automação de importação de fatura aérea
@type function
@author osmar.junior
@since 27/09/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function T38Automa()
	Processa( {|| TUR38AUT() }, "Aguarde...", "Fazendo a importação dos arquivos.",.F.)
Return

Function TUR38AUT()

	Local   lImpOk    	:= .F.
	Local   lProsseg    := .T.
	Local   aDirect     := {}
	Local   cDrive      := ""
	Local   cDir        := ""
	Local   cNome       := ""
	Local   cExt        := ""
	Local   cErro       := ""
	Local   cPath       := ""
	Local   nArq        := 0
	Local   cOldArea    := Alias()
	Local   aOldArea    := GetArea()	
	Local 	aG6HArea 	:= G6H->(GetArea())
	Local   aResult		:= {}
	
	Local	aArquivos	:=	ListaArq()	
	Local	cInicio		:= ''
	Local	cFim		:= ''
	
					
	//Private	oMileImport := FWMile():New(.T.)		
	Private cTURA038Fl  := ""
	Private lTURA038OK  := .T.
	Private nTipoImp    := 1 	 
	Private cFornec     := ""
	Private cLoja       := ""
	
	RestArea(aOldArea)

	Pergunte("TURA038IMP", .F.)
	//MV_PAR01(N)  Layout ?   
	//MV_PAR02(N)  Arquivo ou Diretorio ?        
	//MV_PAR03(C)  Arquivo ?                     
	//MV_PAR04(C)  Codigo Fornecedor da Fatura ? 
	//MV_PAR05(C)  Loja do Fornecedor da Fatura ?
	//MV_PAR06(C)  Moeda ?                       
	//MV_PAR07(C)  Periodicidade ?               
	//MV_PAR08(C)  Periodo ?                     
	//MV_PAR09(C)  Importar vendas zeradas ?     
	//MV_PAR10(N)  Filtra IATA para importacao ? 
	//MV_PAR11(C)  Quais IATAS ?                                 
	
	If lProsseg
		//__CINTERNET := "Automatico"	
		Conout( 'INICIO DAS IMPORTAÇÕES************************************'  )
		ProcRegua(Len(aArquivos))
		For nArq := 1 To Len(aArquivos)
			IncProc() 
			cInicio := TIME()
			Conout( 'Importando o item ' + ALLTRIM( STR(nArq) ) + ' de ' + ALLTRIM( STR(Len(aArquivos)) ) + ' arquivos.' )
			Conout( "Importação do arquivo: " + aArquivos[nArq][ARQUIVO] + '  ' + cInicio )
			
			AtuPerg("TURA038IMP", "MV_PAR01", aArquivos[nArq][TIPOLAYOUT]) 							//Layout ?
			AtuPerg("TURA038IMP", "MV_PAR02", 1)													//Arquivo ou Diretorio ? 
			AtuPerg("TURA038IMP", "MV_PAR03", aArquivos[nArq][DIRETORIO]+aArquivos[nArq][ARQUIVO]) //Arquivo ? 
			
			Pergunte("TURA038IMP", .F.)
			lProsseg	:= .T.
			lImpOk 		:= .F.
			MV_PAR01 	:= aArquivos[nArq][TIPOLAYOUT]
			MV_PAR02 	:= 1
			MV_PAR03 	:= aArquivos[nArq][DIRETORIO]+aArquivos[nArq][ARQUIVO]			
			MV_PAR04	:= 'FA0002'
			MV_PAR05	:= '01'
			cTURA038Fl := aArquivos[nArq][ARQUIVO]
			
			SplitPath( MV_PAR03, @cDrive, @cDir, @cNome, @cExt )		
			If File(AllTrim(MV_PAR03))	
				AAdd(aDirect, {cNome + cExt, 100, dDataBase, Time(), Space(1)})            	    		
				cPath := cDrive + cDir	
			Else	
				cErro :=  'Arquivo inexistente: '+cTURA038Fl	
				lProsseg  := .F.
				AADD( aResult, { LoadBitmap( GetResources(), "BR_VERMELHO")	,Tipo(aArquivos[nArq][TIPOLAYOUT]) ,aArquivos[nArq][LAYOUTMILE], aArquivos[nArq][ARQUIVO], 0 , cErro ,"","","",.F. } )
			EndIf				
			
			If lProsseg
				DBSelectArea("G6H")
				DBSetOrder(5) // G6H_FILIAL + G6H_ARQUIV
				If DBSeek(xFilial("G6H") + ALLTRIM(Upper(cTURA038Fl)))
						cErro :='Não é possível importar o arquivo, pois já existe uma fatura gravada a partir de um arquivo com este nome: '+cTURA038Fl 
						lProsseg := .F.						
						AADD( aResult, { LoadBitmap( GetResources(), "BR_VERMELHO")	,Tipo(aArquivos[nArq][TIPOLAYOUT]) ,aArquivos[nArq][LAYOUTMILE], aArquivos[nArq][ARQUIVO], 0 , cErro ,"","","",.F. } )	
				EndIf
					
				DBSelectArea("G6H")
				RestArea(aG6HArea) 
			EndIf
			
						
			If lProsseg
				lImpOk	:=	TURA038IMP(.T.,aArquivos[nArq])
				//If ALLTRIM(STR(aArquivos[nArq][TIPOLAYOUT])) $ '1|3|4'		
							
					//oMileImport := FWMILE():New()				
					//oMileImport:SetOperation("1")				
					//oMileImport:SetLayout(aArquivos[nArq][LAYOUTMILE])				
					//oMileImport:SetTXTFile(MV_PAR03)				
					//If oMileImport:Activate()				
						//oMileImport:Import()
					//	FwMsgRun(,{|| oMileImport:Import()},,'"Aguarde... Realizando importação."')
				
					//	If oMileImport:Error()			
					//		cErro := oMileImport:GetError()
					//		AADD( aResult, { .F., aArquivos[nArq][ARQUIVO], 0 , cErro } )
					//	Else
					//		lImpOk := .T.					
					//	EndIf					
					//	oMileImport:Deactivate()				
					//Else				
					//	cErro := oMileImport:GetError()	
					//	AADD( aResult, { .F., aArquivos[nArq][ARQUIVO], 0 , cErro } ) 			
					//EndIf
					
				//Else	
				//	U_TURA038G(aArquivos[nArq][ARQUIVO],aArquivos[nArq][DIRETORIO])
				//	ValidValor(aArquivos[nArq],aResult )				
				//EndIf
						
			EndIf
			
			DBSelectArea("G6H")
			DBSetOrder(5) // G6H_FILIAL + G6H_ARQUIV
			DBSeek(xFilial("G6H") + ALLTRIM(aArquivos[nArq][ARQUIVO]))	
			
			If lImpOk .AND. aArquivos[nArq][TIPOLAYOUT] == 3
				CancelaAcm( aArquivos[nArq][ARQUIVO] )								
			EndIf
			
			cFim := TIME()
			
			If lImpOk
				ValidValor(aArquivos[nArq],aResult,cInicio,cFim)				
			EndIf			
			
			Conout( "Fim da importação    : "  + aArquivos[nArq][ARQUIVO] + '  ' + cFim  )	
			
		Next nArq
				
	EndIf

	Conout( 'FIM DAS IMPORTAÇÕES***************************************'  )
	
	DBSelectArea(cOldArea)
	RestArea(aOldArea)
	
	//GravaLog(aResult)
	Apresenta(aResult)
	
Return

/*/{Protheus.doc} CancelaACM
Função para cancelamento de bilhetes ACM(8957...)
@type function
@author osmar.junior
@since 27/09/2017
@version 1.0
@param cArquivo, character, (Nome do arquivo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function CancelaACM(cArquivo)

	Local oModel 	:= Nil
	Local oMdlG6I	:= Nil
	Local oMdlG6H	:= Nil
	Local nI	 	:= 0
	Local nValor	:= 0
	
	DBSelectArea("G6H")
	DBSetOrder(5) // G6H_FILIAL + G6H_ARQUIV
	If DBSeek(xFilial("G6H") + ALLTRIM(cArquivo))	
					
		oModel := FWLoadModel('TURA038')
		oModel:SetOperation( MODEL_OPERATION_UPDATE )		
		oModel:GetModel( 'G6IDETAIL' ):SetLoadFilter( { { 'G6I_BILHET', "'8957'", MVC_LOADFILTER_CONTAINS },;
														{ 'G6I_TIPOIT', "'5'" } } )
		oModel:Activate()
		
		oMdlG6I	:= oModel:GetModel( 'G6IDETAIL' )
		oMdlG6H	:= oModel:GetModel( 'G6HMASTER' )
		
		For nI := 1 To oMdlG6I:Length()	
				
			oMdlG6I:GoLine( nI )		
			If SUBSTR(oMdlG6I:GetValue( 'G6I_BILHET' ),1,4)=='8957'
			
				oMdlG6I:LoadValue( 'G6I_STATUS'	, '2' )			
				If oMdlG6I:GetValue( 'G6I_TPOPER' ) == '1' //1=DEBITO |2=CREDITO
					oMdlG6H:LoadValue( 'G6H_VALOR', oMdlG6H:GetValue( 'G6H_VALOR' ) - oMdlG6I:GetValue( 'G6I_VLRLIQ' ) )
				Else
					oMdlG6H:LoadValue( 'G6H_VALOR', oMdlG6H:GetValue( 'G6H_VALOR' ) + oMdlG6I:GetValue( 'G6I_VLRLIQ' ) )
				EndIf
			EndIf				
				
		Next nI		
		
		If oModel:VldData()
			oModel:CommitData()
		Else
			Help(" ",1,"CancelaACM",,'Erro ao tentar cancelar item.',1,0)	
		EndIf
			
		oModel:DeActivate()
		
	EndIf
Return

/*/{Protheus.doc} ValidValor
Função para verificação de valor (Array e fatura)
@type function
@author osmar.junior
@since 27/09/2017
@version 1.0
@param aTeste, array, (Dados para validar)
@param aResult, array, (Resultado da validação)
@param cInicio, character, (Hora de inicio)
@param cFim, character, (Hora da finalização)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function ValidValor(aTeste,aResult,cInicio,cFim)

	Local cRet := ''
	Local nValor	:= 0
	Local oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
	Local cTipo		:= Tipo(aTeste[TIPOLAYOUT])
	Local cTotTempo	:= ElapTime(cInicio,cFim)
	Local nQtdeItens:= QtdeItens(G6H->G6H_FATURA)

	nValor := G6H->G6H_VALOR
	
	If nValor == aTeste[VALORFATUR] 
		AADD( aResult, { oVerde		,cTipo ,aTeste[LAYOUTMILE], aTeste[ARQUIVO], nValor , 'OK'																, cInicio, cFim, cTotTempo,nQtdeItens, .F. } )
		Conout( 'OK :' + ALLTRIM(STR(nValor)) )
	Else
		AADD( aResult, { oVermelho	,cTipo ,aTeste[LAYOUTMILE], aTeste[ARQUIVO], nValor , "Diferença : " + ALLTRIM(STR(nValor - aTeste[VALORFATUR]))		, cInicio, cFim, cTotTempo,nQtdeItens, .F. } )	
		Conout( 'Divergencia :' + ALLTRIM(STR(nValor - aTeste[VALORFATUR]) ))
	EndIf

Return cRet

/*/{Protheus.doc} Apresenta
Função de apresentação das importações
@type function
@author osmar.junior
@since 27/09/2017
@version 1.0
@param aResult, array, (Resultados a serem apresentados)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function Apresenta(aResult)     
                             
	Local	oDlg 
	Local   oGrp 
	Local   oGridAtd 
	Local   aH          := {} 
	
	AADD(aH, {"Status"     	, "Status" 		, "@BMP"				, 03 , 00, , , "L", "ZZZ", , , })
	AADD(aH, {"Tipo"     	, "Tipo" 		, "@!"					, 06 , 00, , , "C", "ZZZ", , , }) 
	AADD(aH, {"Fonte"     	, "Fonte"	 	, "@!"					, 12 , 00, , , "C", "ZZZ", , , }) 
	AADD(aH, {"Arquivo"     , "Arquivo" 	, "@!"					, 30 , 00, , , "C", "ZZZ", , , }) 
	AADD(aH, {"Valor"		, "Valor"		, "@E 999,999,999.99"	, 12 , 00, , , "N", "ZZZ", , , }) 
	AADD(aH, {"Observacao" 	, "Observacao"	, "@!"					, 60, 00, ,  , "C", "ZZZ", , , })   
	AADD(aH, {"Inicio" 		, "Inicio"		, "99:99:99"			, 10, 00, ,  , "C", "ZZZ", , , })
	AADD(aH, {"Fim   " 		, "Fim   "		, "99:99:99"			, 10, 00, ,  , "C", "ZZZ", , , })    
	AADD(aH, {"Tempo " 		, "Tempo "		, "99:99:99"			, 10, 00, ,  , "C", "ZZZ", , , })
	AADD(aH, {"Qtde Itens" 	, "Qtde Itens"	, "99999"				, 10, 00, ,  , "N", "ZZZ", , , })
	
	oDlg := TDialog():New( 000, 000, 400, 800, "Resultado", , , , , , , , , .T., , , , , , .F.) 

	oGridAtd:= MsNewGetDados():New( 001, 001, 180, 400, , , , , , , 9999, , , , oDlg, aH, aResult, , )       
	//-- -- Ativa Janela DIalog 
	oDlg:Activate( , , , .T., {||}, , {||}, , ) 
      
Return 


/*/{Protheus.doc} AtuPerg
Função para persistir parametros de pergunte
@type function
@author osmar.junior
@since 27/09/2017
@version 1.0
@param cPergAux, character, (Pergunte)
@param cParAux, character, (Parametro)
@param xConteud, variável, (Conteúdo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
//AtuPerg("TURA038IMP", "MV_PAR01", "000001") //Layout ?
//AtuPerg("TURA038IMP", "MV_PAR02", "000001") //Arquivo ou Diretorio ? 
//AtuPerg("TURA038IMP", "MV_PAR03", "000001") //Arquivo ?  
/*/Static Function AtuPerg(cPergAux, cParAux, xConteud)

    Local aArea      := GetArea()
    Local nPosCont   := 8
    Local nPosPar    := 14
    Local nLinEncont := 0
    Local aPergAux   := {}
    Default xConteud := ''
     
    //Se não tiver pergunta, ou não tiver ordem
    If Empty(cPergAux) .Or. Empty(cParAux)
        Return
    EndIf
     
    //Chama a pergunta em memória
    Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)
     
    //Procura a posição do MV_PAR
    nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })
     
    //Se encontrou o parâmetro
    If nLinEncont > 0
        //Caracter
        If ValType(xConteud) == 'C'
            &(cParAux+" := '"+xConteud+"'")
         
        //Data
        ElseIf ValType(xConteud) == 'D'
            &(cParAux+" := sToD('"+dToS(xConteud)+")'")
             
        //Numérico ou Lógico
        ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
            &(cParAux+" := "+cValToChar(xConteud)+"")
         
        EndIf
         
        //Chama a rotina para salvar os parâmetros
        __SaveParam(cPergAux, aPergAux)
    EndIf
     
    RestArea(aArea)
Return


/*/{Protheus.doc} Tipo
Tipo de Importação
@type function
@author osmar.junior
@since 27/09/2017
@version 1.0
@param nLayout, numérico, (Tipo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function Tipo(nLayout)

	Local cRet := ''

	Do Case
		Case nLayout == 1       				
			cRet := 'BSP'
		Case nLayout == 2			    
			cRet := 'GOL'
		Case nLayout == 3
			cRet := 'AVIANCA'
		Case nLayout == 4
			cRet := 'TAM'
	EndCase

Return cRet


/*/{Protheus.doc} QtdeItens
Função que retorna a quantidade de itens na Fatura (G6I)
@type function
@author osmar.junior
@since 27/09/2017
@version 1.0
@param cFatura, character, (Código da fatura)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function QtdeItens(cFatura)

	Local nQtde 		:= 0
	Local cAliasQry 	:= GetNextAlias()

	BeginSql Alias cAliasQry
	
		SELECT COUNT(*) QTDE
		FROM %table:G6I% G6I
		WHERE 
		G6I.G6I_FILIAL			= %xFilial:G6I% AND
		UPPER(G6I.G6I_FATURA)	= %Exp:cFatura% AND
		G6I.%NotDel%
	
	EndSql

	If (cAliasQry)->(!EOF())
		nQtde := (cAliasQry)->QTDE
	EndIf	
	(cAliasQry)->( DbCloseArea() )

Return nQtde


/*/{Protheus.doc} GravaLog
Função que faz a gravação do resultado em arquivo
@type function
@author osmar.junior
@since 27/09/2017
@version 1.0
@param aResult, array, (Resultado da importação)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function GravaLog(aResult)

	Local cNomeArq 	:= 'Log_Autom_Importacao.csv'
	Local cTexto	:= 'Tipo;Fonte;Arquivo;Valor;Observacao;Inicio;Fim;Tempo;Qtde Itens'+CRLF

	AEVAL(aResult, { | Linha |  cTexto +=;
										Linha[2]+';'+;
										Linha[3]+';'+;
										Linha[4]+';'+;
										STR(Linha[5])+';'+;
										Linha[6]+';'+;
										Linha[7]+';'+;
										Linha[8]+';'+;
										Linha[9]+';'+;
										STR(Linha[10])+;
										CRLF;
							 }  )
	
	MemoWrite( cNomeArq, cTexto )

Return

/*/{Protheus.doc} MyApresenta
Função para teste de apresentação e gravação de resultado
@type function
@author osmar.junior
@since 27/09/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function MyApresenta()

	Local aResult:={}
	Local oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
	Local cInicio	:= TIME()
	Local cFim		:= TIME()
	Local cTotal	:= ElapTime(cInicio,cFim)
	Local nQtde		:= QtdeItens('000000379')	
				
	AADD( aResult, { oVerde		,Tipo(1), 'TURA038B'	, 'C:\CCCC'	, 10.000	,'OK'			,cInicio,cFim,cTotal,nQtde, .F. } )
	AADD( aResult, { oVermelho	,Tipo(2), 'U_TURA038G'	, 'C:\AAAA' , 500		,'DIVERGENCIA'	,cInicio,cFim,cTotal,nQtde, .F. } )
	AADD( aResult, { oVermelho	,Tipo(3), 'TURA038H'	, 'C:\BBB' 	, 500000	,'DIVERGENCIA'	,cInicio,cFim,cTotal,nQtde, .F. } )
					
	Apresenta(aResult) 
	GravaLog(aResult)
	
Return

/*/{Protheus.doc} ListaArq
Função que retorna a lista de faturas a serem importadas
@type function
@author osmar.junior
@since 27/09/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function ListaArq()

	Local aArquivos	:= {}

	//TESTE INDIVIDUAL
	//Local	aArquivos := {{ 1,	'C:\_FATURAS AEREAS_\BSP\'		,'BR.GRU.P.170420.540txt.txt'	,'TURA038B'		,68119.43	}}							
	//Local	aArquivos := {{ 4,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3765_120517-200517.txt'	,'TURA038I'		,7772.9		}}
	//Local	aArquivos := {{ 3,	'C:\_FATURAS AEREAS_\AVIANCA\'	,'BR.GRU.P.170120.540.txt'		,'TURA038H'		,70970.39	}}
	//Local	aArquivos := {{ 2,	'C:\_FATURAS AEREAS_\GOL\'		,'230417GOL57530056.txt'		,'U_TURA038G'	,0			}}
	
	/* 
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170110.540.T',	'TURA038H',	-72911.91	}  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170120.540.T',	'TURA038H',	70970.39    }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170131.540.T',	'TURA038H',	69492.89    }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170210.540.T',	'TURA038H',	-304058.92  }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170220.540.T',	'TURA038H',	37543.81    }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170228.540.T',	'TURA038H',	22348.74    }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170310.540.T',	'TURA038H',	-194387.42  }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170320.540.T',	'TURA038H',	29368.93    }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170331.540.T',	'TURA038H',	75726.56    }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170410.540.T',	'TURA038H',	-181018.17  }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170420.540.T',	'TURA038H',	68119.43    }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170430.540.T',	'TURA038H',	56478.83    }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170510.540.T',	'TURA038H',	-196977.02  }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170520.540.T',	'TURA038H',	31545.25    }  )
	AADD(aArquivos,		{AVIANCA	,'C:\_FATURAS AEREAS_\AVIANCA\'	,	'BR.GRU.P.170531.540.T',	'TURA038H',	62766.45    }  )
	*/
	
	/*
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170308.540.W',	'TURA038B',	9422.67     }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170408.540.W',	'TURA038B',	-38130.58   }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170508.540.W',	'TURA038B',	-417525.29  }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170608.540.W',	'TURA038B',	102283.19   }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170708.540.W',	'TURA038B',	-115123.28  }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170215.540.W',	'TURA038B',	-49403.16   }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170315.540.W',	'TURA038B',	-186936.19  }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170415.540.W',	'TURA038B',	40620.76    }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170515.540.W',	'TURA038B',	-14699.48   }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170615.540.W',	'TURA038B',	-251866.89  }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170223.540.W',	'TURA038B',	-423651.68  }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170323.540.W',	'TURA038B',	-39572.35   }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170423.540.W',	'TURA038B',	-178121.65  }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170523.540.W',	'TURA038B',	-61623.9    }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170623.540.W',	'TURA038B',	-26971.67   }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170228.540.W',	'TURA038B',	-47973.07   }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170331.540.W',	'TURA038B',	-15571.48   }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170430.540.W',	'TURA038B',	-27995.32   }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170531.540.W',	'TURA038B',	-103175.5   }  )
	AADD(aArquivos,		{BSP	,'C:\_FATURAS AEREAS_\BSP\',		'BR.GRU.P.170630.540.W',	'TURA038B',	8587.55     }  )	
	*/
	
	/*
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SJK2209_010917-100917.txt'	,'TURA038I',	728.75 		}  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5435_010917-100917.txt'	,'TURA038I',	-39.47		}  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5385_010917-100917.txt'	,'TURA038I',	18576.50  	}  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5304_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5250_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5248_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5247_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5246_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5245_010917-100917.txt'	,'TURA038I',	-599.62     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5231_010917-100917.txt'	,'TURA038I',	149.26      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5230_010917-100917.txt'	,'TURA038I',	191.88      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5229_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5228_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5225_010917-100917.txt'	,'TURA038I',	-553.1      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5224_010917-100917.txt'	,'TURA038I',	1210.69     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5222_010917-100917.txt'	,'TURA038I',	6873.96     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5220_010917-100917.txt'	,'TURA038I',	169.74      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5219_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5217_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5216_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5215_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5214_010917-100917.txt'	,'TURA038I',	96.96       }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5213_010917-100917.txt'	,'TURA038I',	-443.84     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5212_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5211_010917-100917.txt'	,'TURA038I',	148.94      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5210_010917-100917.txt'	,'TURA038I',	456.52           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5209_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5208_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5206_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5203_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5202_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5201_010917-100917.txt'	,'TURA038I',	-253.31     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5200_010917-100917.txt'	,'TURA038I',	2313.07     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5199_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5198_010917-100917.txt'	,'TURA038I',	566.27           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5196_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5194_010917-100917.txt'	,'TURA038I',	965.18           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5193_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5192_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5191_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5190_010917-100917.txt'	,'TURA038I',	-1072.51    }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5187_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5186_010917-100917.txt'	,'TURA038I',	141.75      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5184_010917-100917.txt'	,'TURA038I',	433.8       }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5182_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5181_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5179_010917-100917.txt'	,'TURA038I',	144.85      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5178_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5175_010917-100917.txt'	,'TURA038I',	-190.53     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5174_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5172_010917-100917.txt'	,'TURA038I',	6666.36     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5171_010917-100917.txt'	,'TURA038I',	123.00           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5168_010917-100917.txt'	,'TURA038I',	-38.98      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5166_010917-100917.txt'	,'TURA038I',	185.7       }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5164_010917-100917.txt'	,'TURA038I',	243.60           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5163_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5162_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5157_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5156_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5153_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5152_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5151_010917-100917.txt'	,'TURA038I',	15365.60    }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5150_010917-100917.txt'	,'TURA038I',	563.83           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5146_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5143_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5142_010917-100917.txt'	,'TURA038I',	-422.76           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5141_010917-100917.txt'	,'TURA038I',	154.63      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5140_010917-100917.txt'	,'TURA038I',	2239.14        }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5139_010917-100917.txt'	,'TURA038I',	149.91      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5137_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5135_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO5131_010917-100917.txt'	,'TURA038I',	-2596.43           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO3350_010917-100917.txt'	,'TURA038I',	210         }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO3335_010917-100917.txt'	,'TURA038I',	110         }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO2982_010917-100917.txt'	,'TURA038I',	255.47      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'SAO2691_010917-100917.txt'	,'TURA038I',	707.88      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3817_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3816_010917-100917.txt'	,'TURA038I',	-464.12     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3786_010917-100917.txt'	,'TURA038I',	154.54      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3784_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3783_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3782_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3781_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3780_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3779_010917-100917.txt'	,'TURA038I',	-77.8       }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3777_010917-100917.txt'	,'TURA038I',	-38.9       }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3776_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3775_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3773_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3771_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3770_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3769_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3768_010917-100917.txt'	,'TURA038I',	172.50      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3767_010917-100917.txt'	,'TURA038I',	339.62      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3766_010917-100917.txt'	,'TURA038I',	-169.99     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3765_010917-100917.txt'	,'TURA038I',	15430.25    }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3764_010917-100917.txt'	,'TURA038I',	-1782.68    }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3763_010917-100917.txt'	,'TURA038I',	452.07      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3762_010917-100917.txt'	,'TURA038I',	199.21      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'RIO3172_010917-100917.txt'	,'TURA038I',	169.16      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'QSB1910_010917-100917.txt'	,'TURA038I',	-181.93     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0537_010917-100917.txt'	,'TURA038I',	3785.66     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0517_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0516_010917-100917.txt'	,'TURA038I',	0           }  ) 
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0515_010917-100917.txt'	,'TURA038I',	5287.93     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0512_010917-100917.txt'	,'TURA038I',	499.52      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0511_010917-100917.txt'	,'TURA038I',	4091.96     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0510_010917-100917.txt'	,'TURA038I',	1466.37     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0509_010917-100917.txt'	,'TURA038I',	9422.48     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0508_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0507_010917-100917.txt'	,'TURA038I',	 760.40    }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0484_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'JOI0424_010917-100917.txt'	,'TURA038I',	312.93      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'CWB3304_010917-100917.txt'	,'TURA038I',	4400.94     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'CWB3302_010917-100917.txt'	,'TURA038I',	-551.03     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'CWB3299_010917-100917.txt'	,'TURA038I',	2206.01     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'CWB3298_010917-100917.txt'	,'TURA038I',	-13721.83   }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'CWB3297_010917-100917.txt'	,'TURA038I',	3942.04     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'CPQ2881_010917-100917.txt'	,'TURA038I',	-227.81     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'CPQ2879_010917-100917.txt'	,'TURA038I',	0           }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'BHZ3254_010917-100917.txt'	,'TURA038I',	415.42      }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'BHZ3253_010917-100917.txt'	,'TURA038I',	-674.71     }  )
	AADD(aArquivos,		{TAM,	'C:\_FATURAS AEREAS_\TAM\'		,'BHZ3252_010917-100917.txt'	,'TURA038I',	-40.25      }  )
	*/
	
	//AADD(aArquivos,		{ AVIANCA,	'C:\_FATURAS AEREAS_\ZENDESK\1070319\'		,'arquivo importação.txt'	,'TURA038H',	64346.55     }  )
	//AADD(aArquivos,		{ AVIANCA,	'C:\_FATURAS AEREAS_\ZENDESK\1304005\'		,'BR.GRU.P.170820.540.T'	,'TURA038H',	46078.63     }  )
	//AADD(aArquivos,		{ AVIANCA,	'C:\_FATURAS AEREAS_\ZENDESK\1343896\'		,'fatura.txt'				,'TURA038H',	56872.40     }  )
	 
	//AADD(aArquivos,		{ BSP,	'C:\_FATURAS AEREAS_\20171204\1256518\'		,'BR.GRU.P.170810  .540.T.txt'	,'TURA038B',	-247145.81     }  )
	//AADD(aArquivos,		{ AVIANCA,	'C:\_FATURAS AEREAS_\20171204\1343896\'	 ,'fatura.txt'				,'TURA038H',	56872.40     }  )
	//AADD(aArquivos,		{ AVIANCA,	'C:\BKP\20170215BKP\c-totvs\Chamado s\2016\PCDEF-ZENDESK-1304005\'		,'BR.GRU.P.170820.540.T'				,'TURA038H',	46078.63     }  )
	
	//*************************************** FOP DUPLA
	//AADD(aArquivos,		{ AVIANCA,	'C:\_FATURAS AEREAS_\TESTE-FOP-DUPLA\'		,'AVIANCA-FOP-DUPLA.T'		,'TURA038H',	0     }  )
	//AADD(aArquivos,		{ BSP,		'C:\_FATURAS AEREAS_\TESTE-FOP-DUPLA\'		,'BSP-FOP-DUPLA.W'			,'TURA038B',	0     }  )
	//AADD(aArquivos,		{ TAM,		'C:\_FATURAS AEREAS_\TESTE-FOP-DUPLA\'		,'TAM-FOP-DUPLA.txt'		,'TURA038I',	0     }  )
	//AADD(aArquivos,		{ GOL,		'C:\_FATURAS AEREAS_\TESTE-FOP-DUPLA\'		,'GOL-FOP-DUPLA.txt'		,'U_TURA038G',	0     }  )
	//AADD(aArquivos,		{ TAM,		'C:\_FATURAS AEREAS_\TESTE-FOP-DUPLA\'		,'TAM-FOP e BILHETE-DUPLA.txt'		,'TURA038I',	40.74     }  )
	
	AADD(aArquivos,		{ TAM,		'C:\_FATURAS AEREAS_\TESTE-FOP-DUPLA\TAM\'		,'SAO5131_210817-310817.txt'	,'TURA038I',	-383814.05  }  )
	AADD(aArquivos,		{ AVIANCA,	'C:\_FATURAS AEREAS_\TESTE-FOP-DUPLA\AVIANCA\'	,'BR.GRU.P.170831.540.T'		,'TURA038H',	  56872.40  }  )
	AADD(aArquivos,		{ BSP,		'C:\_FATURAS AEREAS_\TESTE-FOP-DUPLA\BSP\'		,'BR.GRU.P.170915.540.W'		,'TURA038B',	 -43635.04  }  )	
		
		
	
	
	
Return aArquivos