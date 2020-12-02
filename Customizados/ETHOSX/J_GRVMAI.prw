#include "protheus.ch"
#include "fivewin.ch"
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³J_GRVMAI  ºAutor  ³MARCELO - ETHOSX    ºDATA  ³  26/09/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Programa para receber dados do e-mail e grava-los em uma    º±±
±±º          ³tabela para que posteriormente sejam enviados por um JOB.   º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function J_GRVMAI()

	Local _cQuery		:= ""

	Local _ni			:= 0
	Local nDias			:= 0
	Local cFilE2		:= ""

	Local cServer		:= ""
	Local cAccount		:= ""
	Local cPass			:= ""
	Local cFrom			:= ""
	Local cTo			:= ""
	Local cCc			:= ""
	Local cBcc			:= ""
	Local cBody			:= ""
	Local lText			:= .T.

	Local cFTPserv		:= ""
	Local cFTPUser		:= ""
	Local cFTPPass		:= ""
	Local nFTPport		:= 0
	
	Local _aUpResul		:= {}
	Local lCsv			:= .T.
	Local lAuto			:= .T.
	Local lNotific		:= .T.
	Local lEnvPad		:= .F.
	
	Private dAuxDat		:= Ctod("  /  /    ")
	Private cSubject	:= ""
	Private aHeader 	:= {}
	Private nHandle		
	Private cPath  		:= ""
	Private cFiles		:= ""
	
	Private _lJoinha	:= .T.
	Private cMailCsv	:= ""
	Private cArCSV		:= ""
	Private cNomeEmp	:= ""	
	Private cCorpo		:= ""
	Private cChave		:= ""
	
	RPCClearEnv()//LIMPA O AMBIENTE
	RPCSetType(3)//DEFINE O AMBIENTE NÃO CONSOME LICENÇA
	RPCSetEnv('01','01SP0001',/*cUser*/,/*pass*/,'FIN',,/*aTabelas*/)//PREPARA O AMBIENTE
    
	MakeDir("\CAP_TMP\XML\")
	
	cPath  		:= "\CAP_TMP\XML\"
	
	ConOut("J_GRVMAI (U_J_GRVMAI): " + Dtos(Date()) + " - " + Time() + " - Iniciando Job Gravação dos E-Mails para Envio")
	
	nDias			:= SuperGetMV("AL_DIASVEN"	, 		, 3) //Parametro de quantidade de dias dos titulos vencidos (ex.D-1, D-2....)//ambrosini
	cAccount		:= SuperGetMv("MV_RELACNT"	, NIL	, "erpp@alatur.com") //erpp@alatur.com //SuperGetMV("AL_CONTEMA", , "marcelo.franca@ethosx.com.br") //Parametro de conta de envio de email para fornecedores 	//ambrosini
	cPass			:= SuperGetMv("MV_RELPSW" 	, NIL	, "456!@vbnm") //456!@vb nm//SuperGetMV("AL_PASSEMA", , "ethosx@2017") //Parametro de senha de email para envio a fornecedores	//ambrosini
	cServer			:= SuperGetMv("MV_RELSERV"	, NIL	, "smtp.office365.com:587") //smtp.office365.com:587
	cFrom			:= SuperGetMv("MV_RELFROM"	, NIL	, "erpp@alatur.com") //erpp@alatur.com	
	cMailCsv		:= SuperGetMv("AL_MAILCSV"	, NIL	, "alaturjtb@sbkbs.com.br") //erpp@alatur.com	

	cFTPserv		:= SuperGetMv("AL_FTPEND"	, NIL	, "ftp.sbkbpo.com.br" )
	nFTPport		:= SuperGetMv("AL_FTPPOR"	, NIL	, 21 )
	cFTPUser		:= SuperGetMv("AL_FTPUSER"	, NIL	, "alaturjtb3" )
	cFTPPass		:= SuperGetMv("AL_FTPSENH"	, NIL	, "@Sbk4l4t7r" )
	
	//CRIACAO DAS COLUNAS DO CSV
	
	aAdd(aHeader,{"Emissao"	 					,"E2_EMISSAO"	,"D",08,0})
	aAdd(aHeader,{"Filial"	 					,"E2_FILIAL"	,"C",08,0})
	aAdd(aHeader,{"Prefixo"	 					,"E2_PREFIXO"	,"C",03,0})
	aAdd(aHeader,{"Numero da Nota"				,"E2_NUM"		,"C",09,0})
	aAdd(aHeader,{"Fatura Localiza"				,"E2_XFATFOR"	,"C",20,0})
	aAdd(aHeader,{"Parcela"	 					,"E2_PARCELA"	,"C",01,0})
	aAdd(aHeader,{"Tipo"	 					,"E2_TIPO"		,"C",03,0})
	aAdd(aHeader,{"CNPJ"	 					,"A2_CGC"		,"C",14,0})
	aAdd(aHeader,{"Fornecedor"	 				,"E2_FORNECE"	,"C",09,0})
	aAdd(aHeader,{"Loja"	 					,"E2_LOJA"		,"C",04,0})
	aAdd(aHeader,{"Nome Fornecedor"	 			,"A2_NOME"		,"C",100,0})
	aAdd(aHeader,{"Valor Titulo"	 			,"E2_VALOR"		,"N",16,2})
	aAdd(aHeader,{"Valor Pago"	 				,"E5_VALOR"		,"N",14,2})
	aAdd(aHeader,{"Data Vencimento"	 			,"E2_VENCTO"	,"D",08,0})
	aAdd(aHeader,{"Vencimento Real"	 			,"E2_VENCREA"	,"D",08,0})
	aAdd(aHeader,{"Data do Pagamento"	 		,"E2_BAIXA"		,"D",08,0})
	aAdd(aHeader,{"Hisórico"	 				,"E5_HISTOR"	,"C",40,0})
	aAdd(aHeader,{"Tipo Movimento"	 			,"E5_TIPODOC"	,"C",02,0})		
	aAdd(aHeader,{"Banco"			 			,"E5_BANCO"		,"C",03,0})		
	aAdd(aHeader,{"Agencia"	 					,"E5_AGENCIA"	,"C",05,0})		
	aAdd(aHeader,{"Conta"	 					,"E5_CONTA"		,"C",10,0})		
	aAdd(aHeader,{"Cheque"	 					,"E5_NUMCHEQ"	,"C",15,0})		

	//MONTA QUERY DE E-MAIL QUE ESTÃO ESPERANDO PARA SER ENVIADOS
    
	If Select("MAILTO") > 0
		DbSelectArea("MAILTO")
		MAILTO->(DbCloseArea())
	EndIf

	//QUERY OBTENDO DADOS
	_cQuery := " SELECT SUBSTRING(E2_FILIAL,1,2) AS FILIAL, E2_FILIAL, E2_FORNECE, E2_LOJA, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_TIPO, E2_EMISSAO, E2_VALLIQ, E2_VALOR, E2_VENCTO, E2_VENCREA, E2_BAIXA, E2_XFATFOR, E2_CODBAR, E2_LINDIG, A2_NOME, A2_EMAIL, A2_CGC ,G4V_EMAIL, SE2.R_E_C_N_O_ AS RECNO, E5_HISTOR, E5_TIPODOC, E5_VALOR, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ " + CRLF
	_cQuery += " FROM " + RetSqlName("SE2") + " SE2 " + CRLF
	_cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON (E2_FORNECE = SA2.A2_COD AND E2_LOJA = SA2.A2_LOJA) AND SA2.D_E_L_E_T_ = ' ' " 
	_cQuery += " LEFT OUTER JOIN " + RetSqlName("G4V") + " G4V ON (E2_FORNECE = G4V_FORNEC AND E2_LOJA = G4V_LOJA) AND G4V.D_E_L_E_T_ = ' ' " 

	_cQuery += " LEFT OUTER JOIN " + RetSqlName("SE5") + " SE5 ON (E2_FILIAL = SE5.E5_FILIAL AND E2_FORNECE = SE5.E5_CLIFOR AND E2_LOJA = SE5.E5_LOJA AND E2_NUM = SE5.E5_NUMERO AND E2_PREFIXO = SE5.E5_PREFIXO AND E2_PARCELA = SE5.E5_PARCELA) AND SE5.D_E_L_E_T_ = ' ' " 

	_cQuery += " WHERE " + CRLF
    //aqui
    
    dAuxDat:= dDatabase
    
	For _ni:= 1 to nDias
	
		dAuxDat:= DataValida(dAuxDat-1,.F.)
	
	Next

	_cQuery += " E2_BAIXA =  '" + dtos(dAuxDat) + "' " + CRLF 
	_cQuery += " AND SE2.E2_TIPO =  'FTF' " + CRLF
	_cQuery += " AND SE2.D_E_L_E_T_ <> '*' " + CRLF
	_cQuery += " ORDER BY SUBSTRING(SE2.E2_FILIAL,1,2),SE2.E2_FORNECE,SE2.E2_LOJA " + CRLF

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"MAILTO",.F.,.T.)

	TCSetField("MAILTO","E2_BAIXA","D",8,0)
	TCSetField("MAILTO","E2_EMISSAO","D",8,0)	
	TCSetField("MAILTO","E2_VENCTO","D",8,0)	
	TCSetField("MAILTO","E2_VENCREA","D",8,0)	

	MemoWrite("ENVMAIL.SQL",_cQuery) //grava na system arquivo de query.
	
	MAILTO->(DbGoTop())
	
	If MAILTO->(!Eof())

		nHandle := MsfCreate(cPath + "CONSOLIDADO_CAP_GRUPOAJ_" +  SubStr(dtos(dAuxDat),7,2) + "-" + SubStr(dtos(dAuxDat),5,2) + "-" + SubStr(dtos(dAuxDat),1,4)  + "_" + SubStr(Time(),1,2) + "_" + SubStr(Time(),4,2) + "_" + SubStr(Time(),7,2) +  ".CSV",0)
	
		cArCSV:= cPath + "CONSOLIDADO_CAP_GRUPOAJ_" +  SubStr(dtos(dAuxDat),7,2) + "-" + SubStr(dtos(dAuxDat),5,2) + "-" + SubStr(dtos(dAuxDat),1,4) + "_" + SubStr(Time(),1,2) + "_" + SubStr(Time(),4,2) + "_" + SubStr(Time(),7,2) + ".CSV"
		
		If nHandle == -1

		   conout("J_GRVMAI (U_J_GRVMAI): " + Dtos(Date()) + " - " + Time() + " - Falha ao criar arquivo CSV - erro " )
		   lCsv:= .F.

		Else
		
			For _ni := 1 to len(aHeader)
				
				if _ni = (len(aHeader))
					fWrite(nHandle, aHeader[_ni,1] )
				Else
					fWrite(nHandle, aHeader[_ni,1] + ";" )
				endif
			
			Next _ni
		
			fWrite(nHandle, CRLF )
			ConOut("J_GRVMAI (U_J_GRVMAI): " + Dtos(Date()) + " - " + Time() + " - Arquivo CSV criado inicialmente ")
			lCsv:= .T.
		
		EndIf
		
		DbSelectArea("MAILTO")
		
		While MAILTO->(!Eof()) .And. lCsv
		
			IF !Empty(MAILTO->G4V_EMAIL)
			
				cTo := AllTrim(MAILTO->G4V_EMAIL)
				
			ElseiF !Empty(MAILTO->A2_EMAIL)
			
				cTo := AllTrim(MAILTO->A2_EMAIL)
				
			Else
			
				cTo := "SEM E-MAIL NOS CADASTROS"
			
			EndIf 
            
			cNomeEmp	:= SubStr(Upper(SuperGetMV("AL_SUBJECT", ,"" , MAILTO->FILIAL)),5)
            cFilE2		:= MAILTO->E2_FILIAL 
            cChave		:= AllTrim(MAILTO->E2_FORNECE) + " - " + AllTrim(MAILTO->E2_LOJA)
			cBody   	:= MontaBody()
			cFiles 		:= MontaXML()
			
			U_EMAILTO(cServer,cAccount,cPass,cFrom,cTo,cCc,cBcc,cSubject,cBody,cFiles,lText,lAuto, lNotific, lEnvPad,cFilE2,cCorpo, cChave)

		EndDo
		
		fClose(nHandle)// Fechei o arquivo CSV 
		
		FTPDisconnect()

		If FTPConnect(cFTPserv,nFTPport,cFTPUser,cFTPPass) .And. lCsv

			FtpSetType(1)
			EtUpLoad(cArCSV, @_aUpResul,cServer,cAccount,cPass)
		
		ElseIf lCsv
		
			x_csvenv(cServer,cAccount,cPass)
	
		Endif				
	
	Else
	
		Conout("J_GRVMAI (U_J_GRVMAI): " + Dtos(Date()) + " - " + Time() + " - " + "Não tem dados para ser enviado")
	
	Endif

	If Select("MAILTO") > 0
		DbSelectArea("MAILTO")
		MAILTO->(DbCloseArea())
	EndIf
	

	ConOut("J_GRVMAI (U_J_GRVMAI): " + Dtos(Date()) + " - " + Time() + " - FINALIZANDO JOB DE GRAVAÇÃO DE E-MAIL DE TITULOS PAGOS ALATUR.")
    
	RpcClearEnv()

Return()

Static Function MontaXML()

	Local oExcel 		:= FWMSEXCEL():NEW()
	Local cNameTable	:= "PLANILHA"
	Local cNameSheet	:= "RELAÇÃO DE TÍTULOS PAGOS " + SubStr(Upper(SuperGetMV("AL_SUBJECT", ,"" , MAILTO->FILIAL)),5)
	Local _cCodFor 		:= MAILTO->FILIAL + MAILTO->E2_FORNECE + MAILTO->E2_LOJA
	Local cComp			:= ""
	Local lXfatfor		:= .F.
	Local cArq			:= ""
	Local _ni			:= 1
	Local _uValor 		:= ""     
	Local cRet			:= ""
	
	//INICIA MONTAGEM DO EXCEL
	oExcel:AddworkSheet(cNameTable)
	oExcel:AddTable (cNameTable,cNameSheet)	
	
	//MONTAGEM DAS COLUNAS
	oExcel:AddColumn(cNameTable,cNameSheet,"EMISSAO",1,1)
	oExcel:AddColumn(cNameTable,cNameSheet,"NUMERO DA NOTA",1,1)

	If !Empty(MAILTO->E2_XFATFOR)
		oExcel:AddColumn(cNameTable,cNameSheet,"FATURA LOCALIZA",1,1)
		lXfatfor:= .T.
	EndIf
	
	oExcel:AddColumn(cNameTable,cNameSheet,"PARCELA",1,1)
	oExcel:AddColumn(cNameTable,cNameSheet,"CNPJ FORNECEDOR",1,1)
	oExcel:AddColumn(cNameTable,cNameSheet,"NOME DO FORNECEDOR",1,1)
	oExcel:AddColumn(cNameTable,cNameSheet,"DATA DA BAIXA",1,1)
	oExcel:AddColumn(cNameTable,cNameSheet,"VALOR TITULO",2,3)
	oExcel:AddColumn(cNameTable,cNameSheet,"DATA VENCIMENTO",1,1)
	oExcel:AddColumn(cNameTable,cNameSheet,"VENCIMENTO REAL",1,1)
	oExcel:AddColumn(cNameTable,cNameSheet,"TIPO DE PAGAMENTO",1,1)
	oExcel:AddColumn(cNameTable,cNameSheet,"HISTÓRICO",1,1)
	oExcel:AddColumn(cNameTable,cNameSheet,"TIPO MOVIMENTO",1,1)
	
	cComp:= SubStr(Dtos(MAILTO->E2_BAIXA),7,2) + "/" + SubStr(Dtos(MAILTO->E2_BAIXA),5,2) + "/" + SubStr(Dtos(MAILTO->E2_BAIXA),1,4)
	
	While MAILTO->(!Eof()) .and. _cCodFor == MAILTO->FILIAL + MAILTO->E2_FORNECE + MAILTO->E2_LOJA

		If lXfatfor
			oExcel:AddRow(cNameTable,cNameSheet,{	SubStr(Dtos(MAILTO->E2_EMISSAO),7,2) + "/" + SubStr(Dtos(MAILTO->E2_EMISSAO),5,2) + "/" + SubStr(Dtos(MAILTO->E2_EMISSAO),1,4)   ,;
													MAILTO->E2_NUM,;
													MAILTO->E2_XFATFOR,;
													MAILTO->E2_PARCELA,;
													IIF( Len(AllTrim(MAILTO->A2_CGC)) = 14, SubStr(MAILTO->A2_CGC,1,2) + "." + SubStr(MAILTO->A2_CGC,3,3) + "." + SubStr(MAILTO->A2_CGC,6,3) + "/" + SubStr(MAILTO->A2_CGC,9,4) + "-" + SubStr(MAILTO->A2_CGC,13,2), SubStr(MAILTO->A2_CGC,1,3) + "." + SubStr(MAILTO->A2_CGC,4,3) + "." + SubStr(MAILTO->A2_CGC,7,3) + "-" + SubStr(MAILTO->A2_CGC,10,2)  ) ,;
													MAILTO->A2_NOME,;
													SubStr(Dtos(MAILTO->E2_BAIXA),7,2) + "/" + SubStr(Dtos(MAILTO->E2_BAIXA),5,2) + "/" + SubStr(Dtos(MAILTO->E2_BAIXA),1,4),;
													MAILTO->E5_VALOR,;
													MAILTO->E2_VENCTO,;
													MAILTO->E2_VENCREA,;
													IIF( !Empty(MAILTO->E2_CODBAR) .Or. !Empty(MAILTO->E2_LINDIG),"PAGAMENTO VIA BOLETO", "PAGAMENTO VIA DEPOSITO"),;
													MAILTO->E5_HISTOR,;
													MAILTO->E5_TIPODOC } )			
 		Else       
			oExcel:AddRow(cNameTable,cNameSheet,{	SubStr(Dtos(MAILTO->E2_EMISSAO),7,2) + "/" + SubStr(Dtos(MAILTO->E2_EMISSAO),5,2) + "/" + SubStr(Dtos(MAILTO->E2_EMISSAO),1,4)   ,;
													MAILTO->E2_NUM,;		
													MAILTO->E2_PARCELA,;
													IIF( Len(AllTrim(MAILTO->A2_CGC)) = 14, SubStr(MAILTO->A2_CGC,1,2) + "." + SubStr(MAILTO->A2_CGC,3,3) + "." + SubStr(MAILTO->A2_CGC,6,3) + "/" + SubStr(MAILTO->A2_CGC,9,4) + "-" + SubStr(MAILTO->A2_CGC,13,2), SubStr(MAILTO->A2_CGC,1,3) + "." + SubStr(MAILTO->A2_CGC,4,3) + "." + SubStr(MAILTO->A2_CGC,7,3) + "-" + SubStr(MAILTO->A2_CGC,10,2)  ) ,;
													MAILTO->A2_NOME,;
													SubStr(Dtos(MAILTO->E2_BAIXA),7,2) + "/" + SubStr(Dtos(MAILTO->E2_BAIXA),5,2) + "/" + SubStr(Dtos(MAILTO->E2_BAIXA),1,4),;
													MAILTO->E5_VALOR,;
													MAILTO->E2_VENCTO,;
													MAILTO->E2_VENCREA,;
													IIF( !Empty(MAILTO->E2_CODBAR) .Or. !Empty(MAILTO->E2_LINDIG),"PAGAMENTO VIA BOLETO", "PAGAMENTO VIA DEPOSITO"),;
													MAILTO->E5_HISTOR,;
													MAILTO->E5_TIPODOC } )			
		EndIf

		for _ni := 1 to len(aHeader)
		
			_uValor := ""
			
			if aHeader[_ni,3] == "D" // Trata campos data
				_uValor := dtoc(&("MAILTO->" + aHeader[_ni,2]))
			elseif aHeader[_ni,3] == "N" // Trata campos numericos
				_uValor := transform((&("MAILTO->" + aHeader[_ni,2])),"@E 999999999.99")
			elseif aHeader[_ni,3] == "C" // Trata campos caracter
				If AllTrim(aHeader[_ni,2]) == "A2_CGC"
					_uValor := IIF( Len(AllTrim(MAILTO->A2_CGC)) = 14, SubStr(MAILTO->A2_CGC,1,2) + "." + SubStr(MAILTO->A2_CGC,3,3) + "." + SubStr(MAILTO->A2_CGC,6,3) + "/" + SubStr(MAILTO->A2_CGC,9,4) + "-" + SubStr(MAILTO->A2_CGC,13,2), SubStr(MAILTO->A2_CGC,1,3) + "." + SubStr(MAILTO->A2_CGC,4,3) + "." + SubStr(MAILTO->A2_CGC,7,3) + "-" + SubStr(MAILTO->A2_CGC,10,2)  )
				Else
					_uValor := &("MAILTO->" + aHeader[_ni,2])
				EndIf
			endif
			
			if _ni = (len(aHeader))
				fWrite(nHandle, _uValor )				
			Else	
				fWrite(nHandle, _uValor + ";" )
			endif
			
		next _ni
		
		fWrite(nHandle, CRLF )
		
		MAILTO->(DbSkip())

	EndDo
    
	cArq:= SuperGetMV("AL_ARQEMP", , SubStr(_cCodFor,1,2),SubStr(_cCodFor,1,2)) + "_" + AllTrim(SubStr(_cCodFor,3,9)) + "_" + SubStr(_cCodFor,12,4) + "_" + SubStr(Dtos(dDatabase),7,2) + "-" + SubStr(Dtos(dDatabase),5,2) + "-" + SubStr(Dtos(dDatabase),1,4) + "_" + SubStr(Time(),1,2) + "_" + SubStr(Time(),4,2) + "_" + SubStr(Time(),7,2) + ".xml" 
	cSubject:= SuperGetMV("AL_SUBJECT", ,"CaP " + SubStr(_cCodFor,1,2) , SubStr(_cCodFor,1,2)) + " - Composicao de Pagamentos - " + cComp

	oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArq)
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cPath + cArq)
	oExcelApp:SetVisible(.F.)
	oExcelApp:WorkBooks:Close(cPath + cArq)

	fclose(cPath + cArq)

	If File ("\CAP_TMP\XML\" + cArq)
		cRet:= "\CAP_TMP\XML\" + cArq
	Else
	    cRet:=""
	EndIf  
	
return(cRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaBody    ºAutor  ³Ambrosini        º Data ³  29/08/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel por montar o corpo do e-mail             º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MontaBody()

	Local cDiasVen	:= AllTrim(Str(SuperGetMV("AL_DIASVEN", , "2"))) //Parametro de quantidade de dias dos titulos vencidos (ex.D-1, D-2....)//ambrosini
    Local cFrase	:= AllTrim(SuperGetMV("AL_FIMMAIL", , "")) //Frase editavel para incluir no fim do e-mail

	Local cBody		:= ""			//Texto da Mensagem

	cBody    := '<html>'
	cBody    += '<head>'
	cBody    += '  <meta content="text/html; charset=ISO-8859-1 http-equiv="content-type">'
	cBody    += '  <title>Titulos PAGOS ALATUR</title>'
	cBody    += '  <meta content="ALATUR" name="author">'
	cBody    += '</head>'
	cBody    += '<body style="color: rgb(0, 0, 0); background-color: rgb(168, 168, 168); alink="#000099" link="#000099" vlink="#990099">'
	cBody    += 	'<div style="text-align: left;">'
	cBody    += 		'<br> Prezado Fornecedor, <br>'
	cBody    += 		'<br> Segue anexo, em arquivo Excel (xml), a rela&ccedil;&atilde;o de T&Iacute;TULOS PAGOS &agrave; sua empresa.<br>'
	cBody    += 		'<br> Os t&iacute;tulos relacionados na planilha referem-se a pagamentos j&aacute; efetuados e em D-' + cDiasVen + ', ou seja, o cr&eacute;dito na conta banc&aacute;ria aconteceu um dia &uacute;til antes da data de envio deste e-mail. <br>'
	cBody    += 		'<br> Estornos por eventuais inconsist&ecirc;ncias em boletos ou dados banc&aacute;rios poder&atilde;o ocorrer em at&eacute; 3 (tr&ecirc;s) dias. Caso ocorra uma destas situa&ccedil;&otilde;es o estorno ser&aacute; informado e posteriormente regularizado. <br>'
	cBody    += 		'<br> *** Esta &eacute; mais uma a&ccedil;&atilde;o da ' + cNomeEmp + '  que visa ajudar os nossos fornecedores a identificar e baixar rapidamente os t&iacute;tulos pagos por n&oacute;s ganhando efici&ecirc;ncia neste processo *** <br>'
	cBody    += 		'<br>' + cFrase + '<br>'
	cBody    += 		'<br><br>'
	cBody    += 		'<br> Grupo Alatur JTB'	
	cBody    += 		'<br> Departamento de Contas a Pagar <br>'
	cBody    += 		'<br><br>'
	cBody    += 		'<br>Esta mensagem pode conter informa&ccedil;&otilde;es confidenciais e/ou privilegiadas, se voc&ecirc; n&atilde;o for o seu destinat&aacute;rio, favor comunicar imediatamente ao remetente e destruir todas as informa&ccedil;&otilde;es e suas c&oacute;pias. <br>'
	cBody    += 		'This message may contain information which is confidential and/or privileged. If you are not the intended recipient, please advise the sender immediately and destroy it and all copies. <br>'
	cBody    += 	'</div>'
	cBody    += '</body>'
	cBody    += '</html>'
	
	cCorpo    := 		'Prezado Fornecedor, ' + CRLF + CRLF
	cCorpo    += 		'Segue anexo, em arquivo Excel (xml), a relação de TÍTULOS PAGOS à sua empresa.' + CRLF + CRLF
	cCorpo    += 		'Os tí;tulos relacionados na planilha referem-se a pagamentos já efetuados e em D-' + cDiasVen + ', ou seja, o crédito na conta bancária aconteceu um dia útil antes da data de envio deste e-mail.' + CRLF + CRLF
	cCorpo    += 		'Estornos por eventuais inconsistências em boletos ou dados bancários poderão ocorrer em até 3 (três) dias. Caso ocorra uma destas situações o estorno será informado e posteriormente regularizado.' + CRLF + CRLF
	cCorpo    += 		'*** Esta é mais uma ação da ' + cNomeEmp + '  que visa ajudar os nossos fornecedores a identificar e baixar rapidamente os títulos pagos por nós ganhando eficiência neste processo ***' + CRLF + CRLF
	cCorpo    += 		cFrase + CRLF
	cCorpo    += 		CRLF + CRLF
	cCorpo    += 		'Grupo Alatur JTB' + CRLF
	cCorpo    += 		'Departamento de Contas a Pagar' + CRLF
	cCorpo    += 		CRLF + CRLF
	cCorpo    += 		'Esta mensagem pode conter informações confidenciais e/ou privilegiadas, se você não for o seu destinatário, favor comunicar imediatamente ao remetente e destruir todas as informações e suas cópias.' + CRLF
	cCorpo    += 		'This message may contain information which is confidential and/or privileged. If you are not the intended recipient, please advise the sender immediately and destroy it and all copies.' + CRLF

Return(cBody)

Static Function EtUpLoad(_cArq, _aUpResul,cServer,cAccount,cPass)

	Local _j		:= 0
	Local _cNomeArq	:= ""
	Local _lUpa		:= .F.
	Local _lTam		:= 0
	Local _nPos		:= 0
	
	// OBS Verificar se a pasta imagens\temp existe, caso contrario criar com MKDIR
	For _j := Len(_cArq) to 1 Step -1
		If Substr(_cArq,_j,1) == "\"
			_cNomeArq := Substr(_cArq,_j+1,Len(_cArq))
			Exit
		EndIf
	Next _j
	
	                                 
	// Upload da imagem para o FTP
	
	_lUpa := FTPUpload("\CAP_TMP\XML\" + Alltrim(_cNomeArq), Alltrim(_cNomeArq) ) 
	
	If _lUpa
	
		ConOut("J_GRVMAI (U_J_GRVMAI): " + Dtos(Date()) + " - " + Time() + " - " + _cNomeArq + " enviado com sucesso para o FTP !")
	
		If File(_cArq)
			
			//Arquivo Salvo Localmente - Excluir
			
			Ferase(_cArq)
			
		EndIf
		
		If File ("\CAP_TMP\XML\" + Alltrim(_cNomeArq))
		
			Ferase("\CAP_TMP\XML\" + Alltrim(_cNomeArq))
		
		EndIf
		
	Else
		Conout("J_GRVMAI (U_J_GRVMAI): " + Dtos(Date()) + " - " + Time() + " - Não foi possivel enviar o arquivo " + _cNomeArq + " para o FTP")
		x_csvenv(cServer,cAccount,cPass)	
	EndIf

Return()

Static Function x_csvenv(cServer,cAccount,cPass)

	Local _cBody		:= ""
	Local _cSubject      := "Alatur JTB - Arquivo CSV consolidado - " + SubStr(dtos(dAuxDat),7,2) + "/" + SubStr(dtos(dAuxDat),5,2) + "/" + SubStr(dtos(dAuxDat),1,4)
	Local cCorpo
	
	//Programar para enviar e-mail se falhar o FTP
	Conout("J_GRVMAI (U_J_GRVMAI): " + Dtos(Date()) + " - " + Time() + " - Falha na conexao com o FTP - Será enviado e-mail!")

	_cBody    := '<html>'
	_cBody    += '<head>'
	_cBody    += '  <meta content="text/html; charset=ISO-8859-1 http-equiv="content-type">'
	_cBody    += '  <title>Titulos PAGOS ALATUR</title>'
	_cBody    += '  <meta content="ALATUR" name="author">'
	_cBody    += '</head>'
	_cBody    += '<body style="color: rgb(0, 0, 0); background-color: rgb(168, 168, 168); alink="#000099" link="#000099" vlink="#990099">'
	_cBody    += 	'<div style="text-align: left;">'
	_cBody    += 		'<br> Prezados(as), <br>'
	_cBody    += 		'<br> Em anexo arquivo .CSV contendo todos os pagamentos consolidados ref. ao dia ' + SubStr(dtos(dAuxDat),7,2) + "/" + SubStr(dtos(dAuxDat),5,2) + "/" + SubStr(dtos(dAuxDat),1,4) + ' <br>'
	_cBody    += 		'<br> Este e-mail &eacute; uma conting&ecirc;ncia e quer alertar que por algum motivo o arquivo .csv n&atilde;o pode ser salvo no FTP da SBK.<br>'
	_cBody    += 		'<br> Por favor, verifique se as credencias de acesso s&atilde;o as mesmas informadas ao TI da AJ e qualquer problema entre em contato para ajuste.<br>'
	_cBody    += 		'<br> Obrigado, <br>'
	_cBody    += 		'<br> <br>'
	_cBody    += 		'<br>Esta mensagem pode conter informa&ccedil;&otilde;es confidenciais e/ou privilegiadas, se voc&ecirc; n&atilde;o for o seu destinat&aacute;rio, favor comunicar imediatamente ao remetente e destruir todas as informa&ccedil;&otilde;es e suas c&oacute;pias. <br>'
	_cBody    += 		'This message may contain information which is confidential and/or privileged. If you are not the intended recipient, please advise the sender immediately and destroy it and all copies. <br>'
	_cBody    += 	'</div>'
	_cBody    += '</body>'
	_cBody    += '</html>'
	                                         
	
	cCorpo    := 		'Prezados(as), ' + CRLF + CRLF
	cCorpo    += 		'Em anexo arquivo .CSV contendo todos os pagamentos consolidados ref. ao dia ' + SubStr(dtos(dAuxDat),7,2) + "/" + SubStr(dtos(dAuxDat),5,2) + "/" + SubStr(dtos(dAuxDat),1,4) + CRLF + CRLF
	cCorpo    += 		'Este e-mail é uma contingência e quer alertar que por algum motivo o arquivo .csv não pode ser salvo no FTP da SBK.' + CRLF + CRLF
	cCorpo    += 		'Por favor, verifique se as credencias de acesso são as mesmas informadas ao TI da AJ e qualquer problema entre em contato para ajuste.' + CRLF + CRLF
	cCorpo    += 		'Obrigado, ' + CRLF
	cCorpo    += 		CRLF + CRLF
	cCorpo    += 		'Esta mensagem pode conter informações confidenciais e/ou privilegiadas, se você não for o seu destinatário, favor comunicar imediatamente ao remetente e destruir todas as informações e suas cópias.' + CRLF
	cCorpo    += 		'This message may contain information which is confidential and/or privileged. If you are not the intended recipient, please advise the sender immediately and destroy it and all copies.' + CRLF
	
	U_EMAILTO(cServer,cAccount,cPass,cAccount,cMailCsv,"","",_cSubject,_cBody,cArCSV,.T.,.T., .T., .F.,xFilial("SE2"), cCorpo, "SBK")
	
Return

User Function EMAILTO(cServer,cAccount,cPass,cFrom,cTo,cCc,cBcc,cSubject,cBody,cFiles,lText,lAuto, lNotific, lEnvPad, cFilE2, cCorpo, cChave)

	Default lAuto		:= .T.
	Default lNotific	:= .T.
	Default lEnvPad		:= .F.
	
	// Substituido os parametros de Envio Recebidos pela Rotina, caso o parametro lEnvPad esteja Falso ou nao tenha sido enviado
	If !(lEnvPad)
		cServer		:= SuperGetMv("MV_RELSERV"	, NIL	, "smtp.office365.com:587")
		cAccount 	:= SuperGetMv("MV_RELACNT"	, NIL	, "erpp@alatur.com")
		cPass		:= SuperGetMv("MV_RELPSW" 	, NIL	, "456!@vbnm")
		cFrom		:= SuperGetMv("MV_RELFROM"	, NIL	, "erpp@alatur.com")
	EndIf
	
	IF Empty(cServer) .Or. Empty(cAccount) .Or. Empty(cPass) .Or. Empty(cFrom) //.Or. Empty(cTo)
		Return()
	Endif
	
	DbSelectArea("SZM")
	
	RecLock("SZM",.T.)
	
	SZM->ZM_FILIAL	:=	cFilE2
	SZM->ZM_SERVER	:=	cServer
	SZM->ZM_ACCOUNT	:=	cAccount
	SZM->ZM_PASS	:=	cPass
	SZM->ZM_FROM	:=	cFrom
	SZM->ZM_TO		:=	ClearMail(cTo)
	SZM->ZM_CC		:=	ClearMail(cCc)
	SZM->ZM_BCC		:=	ClearMail(cBcc)
	SZM->ZM_SUBJECT	:=	cSubject
	SZM->ZM_ATTACH	:=	cFiles
	SZM->ZM_AUTO	:=	lAuto
	SZM->ZM_EMISSAO	:=	Date()
	SZM->ZM_ENVIADO	:=	.F.
	SZM->ZM_NOTIFIC	:=	lNotific
	SZM->ZM_BODY	:= cBody
	SZM->ZM_CORPO	:= cCorpo
	SZM->ZM_HRGRV	:= Time()
	SZM->ZM_CHAVE	:= cChave

	SZM->(MsUnlock())
	//SZM->(DbCloseArea())
	
Return()

/*
	Limpa o endereco passado
*/
Static Function ClearMail(_cEmail)
                                                                        

	Default _cEmail	:=	""

	If !Empty(_cEmail)

		_cEmail	:=	Alltrim(_cEmail)

		While .T. //Remove todos os ; q	ue possuir no fim da string

			If Substring(_cEmail, Len(_cEmail), 1) == ";"
				_cEmail	:=	Substring(_cEmail, 1, Len(_cEmail) - 1)
			Else
				Exit
			Endif
				
		EndDo

	Endif
	
Return _cEmail