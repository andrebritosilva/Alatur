#include 'protheus.ch'
#include 'parmtype.ch'

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥J_TITPAG  ∫Autor  ≥MARCELO - ETHOSX    ∫DATA  ≥  28/08/19   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥Programa executado via JOB responsavel por enviar os e-mails∫±±
±±∫          ≥para os dos fornecedores ALATUR                             ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function J_TITPAG()

	Local _cQuery		:= ""
	Local cEmail		:= "" //"marcelo.franca@ethosx.com"
	Local cPass			:= ""
	Local _cBody		:= ""
	
	Local ExcTenta		:= {}
	Local cErrorMsg		:= ""
	Local nContErro		:=	0
	Local nContDesp		:=	0
	Local _ni			:= 0
	Local nDias			:= 0
	Local cServer		:= ""
	Local cFrom			:= ""
	Local cFTPserv		:= ""
	Local cFTPUser		:= ""
	Local cFTPPass		:= ""
	Local nFTPport		:= 0
	Local _lVaiTo		:= .T.
	Local _aUpResul		:= {}
	Local lCsv			:= .T.

	Private dAuxDat		:= Ctod("  /  /    ")
	Private cAssunto	:= ""
	Private aHeader 	:= {}
	Private nHandle		
	Private cPath  		:= ""
	Private cCont		:= ""
	Private _lJoinha	:= .T.
	Private cMailCsv	:= ""
	Private cArCSV		:= ""
	Private nContSuc	:=	0
	Private _lConnect	:= .T.
	Private lOk			:= .F.
	Private oServer
	Private oMessage
	Private cNomeEmp	:= ""

		
	RPCClearEnv()//LIMPA O AMBIENTE
	RPCSetType(3)//DEFINE O AMBIENTE N√O CONSOME LICEN«A
	RPCSetEnv('01','01SP0001',/*cUser*/,/*pass*/,'FIN',,/*aTabelas*/)//PREPARA O AMBIENTE
    
	MakeDir("\CAP_TMP\")
	
	cPath  		:= "\CAP_TMP\"
	
	ConOut("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - Iniciando Job Titulos Pagos Alatur")
	
	nDias			:= SuperGetMV("AL_DIASVEN"	, 		, 3) //Parametro de quantidade de dias dos titulos vencidos (ex.D-1, D-2....)//ambrosini
	cCont			:= SuperGetMv("MV_RELACNT"	, NIL	, "erpp@alatur.com") //erpp@alatur.com //SuperGetMV("AL_CONTEMA", , "marcelo.franca@ethosx.com.br") //Parametro de conta de envio de email para fornecedores 	//ambrosini
	cPass			:= SuperGetMv("MV_RELPSW" 	, NIL	, "456!@vbnm") //456!@vb nm//SuperGetMV("AL_PASSEMA", , "ethosx@2017") //Parametro de senha de email para envio a fornecedores	//ambrosini
	cServer			:= SuperGetMv("MV_RELSERV"	, NIL	, "smtp.office365.com:587") //smtp.office365.com:587
	cFrom			:= SuperGetMv("MV_RELFROM"	, NIL	, "erpp@alatur.com") //erpp@alatur.com	
	cMailCsv		:= SuperGetMv("AL_MAILCSV"	, NIL	, "alaturjtb@sbkbs.com.br") //erpp@alatur.com	

	cFTPserv		:= SuperGetMv("AL_FTPEND"	, NIL	, "ftp.sbkbpo.com.br" )
	nFTPport		:= SuperGetMv("AL_FTPPOR"	, NIL	, 21 )
	cFTPUser		:= SuperGetMv("AL_FTPUSER"	, NIL	, "alaturjtb3" )
	cFTPPass		:= SuperGetMv("AL_FTPSENH"	, NIL	, "@Sbk4l4t7r" )
	
	oServer 		:= TMailManager():New()
	oMessage 		:= TMailMessage():New()
	
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
	aAdd(aHeader,{"HisÛrico"	 				,"E5_HISTOR"	,"C",40,0})
	aAdd(aHeader,{"Tipo Movimento"	 			,"E5_TIPODOC"	,"C",02,0})		
	aAdd(aHeader,{"Banco"			 			,"E5_BANCO"		,"C",03,0})		
	aAdd(aHeader,{"Agencia"	 					,"E5_AGENCIA"	,"C",05,0})		
	aAdd(aHeader,{"Conta"	 					,"E5_CONTA"		,"C",10,0})		
	aAdd(aHeader,{"Cheque"	 					,"E5_NUMCHEQ"	,"C",15,0})		

	//MONTA QUERY DE E-MAIL QUE EST√O ESPERANDO PARA SER ENVIADOS
    
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

		   conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - Falha ao criar arquivo CSV - erro " )
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
			ConOut("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - Arquivo CSV criado inicialmente ")
			lCsv:= .T.
		
		EndIf
		
		DbSelectArea("MAILTO")
		
		While MAILTO->(!Eof()) .And. lCsv
		
			IF !Empty(MAILTO->G4V_EMAIL)
				cEmail := AllTrim(MAILTO->G4V_EMAIL)
			ElseiF !Empty(MAILTO->A2_EMAIL)
				cEmail := AllTrim(MAILTO->A2_EMAIL)
			EndIf 
            
			If !Empty(cEmail)
	             
				Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - E-Mail cadastrado no fornecedor = " + cEmail)
	
				If _lConnect
	
					Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - Conectando ao SMTP")
	
					oServer:SetUseTLS( .T. )
					oServer:Init('', SubStr(AllTrim(cServer),1,Len(cServer)-4) , Alltrim(cCont) , Alltrim(cPass) , 0 , Val(SubStr(AllTrim(cServer),Len(cServer)-3))     )
					oServer:SetSmtpTimeOut( 120 )
	
					nErro := oServer:SmtpConnect()
	
					If nErro <> 0
						Conout( "J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + "ERROR:" + oServer:GetErrorString( nErro ) )
						oServer:SMTPDisconnect()
						RpcClearEnv() 
						Return .F.
					Endif
	                
					nErro := oServer:SmtpAuth( Alltrim(cCont) , Alltrim(cPass))
	
					If nErro <> 0
						Conout( "J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + "ERROR:" + oServer:GetErrorString( nErro ) )
						oServer:SMTPDisconnect()
						RpcClearEnv() 
						Return .F.
					Endif
	
						//Conecta apenas no primeiro envio
						_lConnect	:=	.F.
				EndIf
				
				cNomeEmp	:= SubStr(Upper(SuperGetMV("AL_SUBJECT", ,"" , MAILTO->FILIAL)),5)
				_cBody   	:= MontaBody()
				_cAttach 	:= MontaXML()
				
				//================================================================
				// Verifica se e um e-mail valido. Caso nao seja, nem tenta enviar
				//================================================================

				If isMail(Alltrim(cEmail), .T., .F.) .And. isMail(Alltrim(cEmail), .T., .F.) 		
					oMessage:Clear()
					oMessage:cFrom                  := Alltrim(cCont)
					oMessage:cTo                    := Alltrim(cEmail)
					//oMessage:cCc                    := Alltrim(MAILTO->ZV_CC)
					oMessage:cSubject               := Alltrim(cAssunto)
					oMessage:cBody                  := _cBody
	
					//ADICIONA UM ATTACH
					If !Empty((_cAttach))  
						//VERIFICA SE O ARQUIVO EXISTE NA ORIGEM
						If File(_cAttach)
							If oMessage:AttachFile(Alltrim(_cAttach)) < 0
								Conout( "J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + "Erro ao ANEXAR o arquivo " + _cAttach + ".")
								RpcClearEnv() 
								Return .F.
							Else
								//ADICIONA UMA TAG INFORMANDO QUE … UM ATTACH E O NOME DO ARQUIVO 
								oMessage:AddAtthTag( 'Content-Disposition: attachment; filename="' + Alltrim(SubStr(_cAttach,10)) + '"')
							EndIf
						EndIF
					EndIf
					
					//Evitando o limite de envio maximo de emails por minuto imposto pelo Office365
					Sleep(3000)
						
					nErro := oMessage:Send( oServer ) //enviando email ambrosini
	
					//TRATA O ENVIO DO EMAIL, CASO SEJA BEM SUCEDIDO FAZEMOS AS DEVIDAS TRATATIVAS
					if nErro <> 0
						Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - Mandando reconectar servidor para corrigir problema apos erro no envio de e-mail")
						oServer:SMTPDisconnect()
						_lConnect	:=	.T.
					Else
						nContSuc++
						conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - " + cValToChar(MAILTO->RECNO) + " - Ultimo R_E_C_N_O_ enviado")
	
						If !Ferase(_cAttach) <> -1
							Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - " + "Erro Nao Exclui o Arquivo XML no Servidor " )
						EndIf
									
						lOk := .T.
					EndIf	
				Else
					nContDesp++
					//IncNumT(MAILTO->RECNO) //Incrementa o ZV_NRTENTA para que o registro deixe de ser enviado apos 50 tentativas
					Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - " + " - A T E N « √ O -  E-mail n„o pode ser enviado " +  Alltrim(cEMail))
				Endif

			Else

				ConOut("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - E-Mail em branco - Fornecedor = " + MAILTO->E2_FORNECE + " - " + MAILTO->E2_LOJA)
				MAILTO->(DbSkip())
				Loop

			EndIf
	
			lOk 		:= .F.
			cErrorMsg 	:= ""        
			//Evitando o limite de envio maximo de emails por minuto imposto pelo Office365
	
		EndDo
		
		fClose(nHandle)// Fechei o arquivo CSV 
		
		FTPDisconnect()

		If FTPConnect(cFTPserv,nFTPport,cFTPUser,cFTPPass) .And. lCsv

			//If !FTPDirChange(cPathFTPImg)
			
				//Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - Nao foi possivel localizar o diretorio: " + cPathFTPImg)
				//_lJoinha := .F.
			
			//Else
		
			// Definindo tipo de transferencia do FTP para Binario (Imagens)
			FtpSetType(1)
			EtUpLoad(cArCSV, @_aUpResul)
			
			//EndIf
			
		ElseIf lCsv
		
			x_csvenv()
	
		Endif				
	
	Else
	
		Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - " + "N„o tem dados para ser enviado")
	
	Endif

	If Select("MAILTO") > 0
		DbSelectArea("MAILTO")
		MAILTO->(DbCloseArea())
	EndIf
	
	Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - DESCONECTANDO DO SMTP")
	oServer:SMTPDisconnect()

	ConOut("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - FINALIZANDO JOB DE ENVIO DE E-MAIL DE TITULOS PAGOS ALATUR.")
	ConOut("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - ENVIADOS COM SUCESSO: " + cValToChar(nContSuc) + " - DESPREZADOS POR ENDERECO INVALIDO: " + cValToChar(nContDesp))
    
	RpcClearEnv()


Return()

Static Function MontaXML()

	Local oExcel 		:= FWMSEXCEL():NEW()
	Local cNameTable	:= "PLANILHA"
	Local cNameSheet	:= "RELA«√O DE TÕTULOS PAGOS " + SubStr(Upper(SuperGetMV("AL_SUBJECT", ,"" , MAILTO->FILIAL)),5)
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
	oExcel:AddColumn(cNameTable,cNameSheet,"HIST”RICO",1,1)
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
    
	cArq:= SuperGetMV("AL_ARQEMP", , SubStr(_cCodFor,1,2),SubStr(_cCodFor,1,2)) + "_" + SubStr(_cCodFor,3,9) + "_" + SubStr(_cCodFor,12,4) + "_" + SubStr(Dtos(dDatabase),7,2) + "-" + SubStr(Dtos(dDatabase),5,2) + "-" + SubStr(Dtos(dDatabase),1,4) + "_" + SubStr(Time(),1,2) + "_" + SubStr(Time(),4,2) + "_" + SubStr(Time(),7,2) + ".xml" 
	cAssunto:= SuperGetMV("AL_SUBJECT", ,"CaP " + SubStr(_cCodFor,1,2) , SubStr(_cCodFor,1,2)) + " - Composicao de Pagamentos - " + cComp

	oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArq)
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cPath + cArq)
	oExcelApp:SetVisible(.F.)
	oExcelApp:WorkBooks:Close(cPath + cArq)

	fclose(cPath + cArq)

	If File ("\CAP_TMP\" + cArq)
		cRet:= "\CAP_TMP\" + cArq
	Else
	    cRet:=""
	EndIf  
	
return(cRet)

/*
Funcao: isMailET
Autor: Leandro Boni
Data: 29/08/2016
Descricao: Valida se o e-mail passado e valido, permitidno validar diversos e-mails separados por ';'.
A funcao de validacao de cada e-mail e a isEmail (Padrao TOTVS)

_cEmails - String contendo o e-mail a ser validado ou os e-mails a serem validados (Separados por ';')
_lMultiple - Indica se a validacao sera apenas para UM E-MAIL ou para MULTIPLOS E-MAILS (Default: .F.)
_lShowError - Indica se deve exibir Alert em caso de erro ou apenas retornar boolean (Default: .F.)
*/

Static Function isMail(_cEmails, _lMultiple, _lShowError)

	Local _lRet		:=	.F.
	Local _aEmails	:=	{}
	Local _nValid	:=	0
	Local _nAT		:=	0

	Default _cEmails		:=	""
	Default _lShowError		:=	.F.
	Default _lMultiple		:=	.F.

	If !Empty(_cEmails)
		If(_lMultiple) //Caso existam, valida varios e-mails separados por ';'
			_aEmails	:=	StrTokArr(Rtrim(_cEmails), ";")
		Else
			Aadd(_aEmails, Rtrim(_cEmails))
		Endif

		//Verifica se TODOS os e-mails informados sao validos
		For _nAT := 1 To Len(_aEmails)
			If !Empty(_aEmails[_nAT]) .And. IsEmail(_aEmails[_nAT])
				_nValid	:=	_nValid + 1
			Endif
		Next

		//Somente permite continuar caso TODOS os e-mails informados sejam validos
		If _nValid == Len(_aEmails)
			_lRet	:=	.T.

			If Substring(Rtrim(_cEmails), Len(Rtrim(_cEmails)), 1) == ";"
				If _lShowError
					Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - O ˙ltimo caracter N√O deve ser um ';'")
				Endif

				_lRet	:=	.F.				
			Endif
		Else
			If _lShowError
				If _lMultiple
					Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - O(s) E-mail(s) informado(s) È(s„o) inv·lido(s)! Verifique...")
				Else
					Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - O E-mail informado È inv·lido! Verifique...")
				Endif

				_lRet	:=	.F.
			Endif
		Endif
	Else
		_lRet	:=	.T.
	Endif

Return _lRet


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MontaBody    ∫Autor  ≥Ambrosini        ∫ Data ≥  29/08/19   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao responsavel por montar o corpo do e-mail             ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

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

Return(cBody)


Static Function EtUpLoad(_cArq, _aUpResul)

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

_lUpa := FTPUpload("\CAP_TMP\" + Alltrim(_cNomeArq), Alltrim(_cNomeArq) ) 

If _lUpa

	ConOut("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - " + _cNomeArq + " enviado com sucesso para o FTP !")

	If File(_cArq)
		
		//Arquivo Salvo Localmente - Excluir
		
		Ferase(_cArq)
		
	EndIf
	
	If File ("\CAP_TMP\" + Alltrim(_cNomeArq))
	
		Ferase("\CAP_TMP\" + Alltrim(_cNomeArq))
	
	EndIf
	
Else
	Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - N„o foi possivel enviar o arquivo " + _cNomeArq + " para o FTP")
	x_csvenv()	
EndIf

Return()

Static Function x_csvenv()

	Local _cBody		:= ""
	Local nErro			:= 0
	
	//Programar para enviar e-mail se falhar o FTP
	Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - Falha na conexao com o FTP - Ser· enviado e-mail!")
	_lJoinha := .F.
				
	oMessage:Clear()
	oMessage:cFrom                  := Alltrim(cCont)
	oMessage:cTo                    := Alltrim(cMailCsv)
	//oMessage:cCc                    := Alltrim(MAILTO->ZV_CC)
	oMessage:cSubject               := "Alatur JTB - Arquivo CSV consolidado - " + SubStr(dtos(dAuxDat),7,2) + "/" + SubStr(dtos(dAuxDat),5,2) + "/" + SubStr(dtos(dAuxDat),1,4)
				
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
			
	oMessage:cBody                  := _cBody
		
	//ADICIONA UM ATTACH
	//If !Empty("\CAP_TMP\" + StrTran(cArCSV,cPath,""))  
	If !Empty(cArCSV)  
		//VERIFICA SE O ARQUIVO EXISTE NA ORIGEM
		If File(cArCSV)
			//If oMessage:AttachFile(Alltrim("\CAP_TMP\" + StrTran(cArCSV,cPath,""))) < 0
			If oMessage:AttachFile(Alltrim(cArCSV)) < 0
				Conout( "J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + "Erro ao ANEXAR o arquivo CSV  .")
				RpcClearEnv() 
				Return .F.
			Else
				//ADICIONA UMA TAG INFORMANDO QUE … UM ATTACH E O NOME DO ARQUIVO
				oMessage:AddAtthTag( 'Content-Disposition: attachment; filename="' + StrTran(cArCSV,cPath,"") + '"')
			EndIf
		EndIF
	EndIf
							
	nErro := oMessage:Send( oServer ) //enviando email ambrosini
		
	//TRATA O ENVIO DO EMAIL, CASO SEJA BEM SUCEDIDO FAZEMOS AS DEVIDAS TRATATIVAS
	if nErro <> 0
		Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - Mandando reconectar servidor para corrigir problema apos erro no envio de e-mail")
		oServer:SMTPDisconnect()
		_lConnect	:=	.T.
	Else
		nContSuc++
		conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - " + cValToChar(MAILTO->RECNO) + " - Ultimo R_E_C_N_O_ enviado")
		
		//If !Ferase("\" + StrTran(cArCSV,cPath,"")) <> -1
		If !Ferase(cArCSV) <> -1
			//Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - " + "Erro Nao Exclui o Arquivo no Servidor = " + STr(Ferase("\" + StrTran(cArCSV,cPath,""))))
			Conout("J_TITPAG (U_J_TITPAG): " + Dtos(Date()) + " - " + Time() + " - " + "Erro Nao Exclui o Arquivo no Servidor " )
		EndIf
										
		lOk := .T.
	EndIf
	
Return