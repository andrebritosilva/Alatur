#include 'protheus.ch'
#include 'parmtype.ch'
#DEFINE DEFAULT_FTP 21
#DEFINE PATH "\"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVARTIT02  บAutor  ณAMBROSINI           บDATA  ณ  28/08/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPrograma executado via JOB responsavel por enviar os e-mailsบฑฑ
ฑฑบ          ณpara os dos fornecedores ALATUR                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function VARTIT02()

	Local _cQuery		:= ""
	Local cPerg    		:= PADR("VARTIT0002",10) // Grupo de Perguntas.       
	Local cArCSV		:= ""
		
	Private aHeader 	:= {}
	Private nHandle		
	Private cPath  		:= AllTrim( GetTempPath())

	ValidP1(cPerg)
	
	If !Pergunte(cPerg,.t.)
		Return()
	EndIf
	
	//CRIACAO DAS COLUNAS DO CSV
	
	If MV_PAR05 <> 1
	
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
		aAdd(aHeader,{"His๓rico"	 				,"E5_HISTOR"	,"C",40,0})
		aAdd(aHeader,{"Tipo Movimento"	 			,"E5_TIPODOC"	,"C",02,0})		
		aAdd(aHeader,{"Banco"			 			,"E5_BANCO"		,"C",03,0})		
		aAdd(aHeader,{"Agencia"	 					,"E5_AGENCIA"	,"C",05,0})		
		aAdd(aHeader,{"Conta"	 					,"E5_CONTA"		,"C",10,0})		
		aAdd(aHeader,{"Cheque"	 					,"E5_NUMCHEQ"	,"C",15,0})		
	
	EndIf
	
	//MONTA QUERY DE E-MAIL QUE ESTรO ESPERANDO PARA SER ENVIADOS

	//QUERY OBTENDO DADOS
	_cQuery := " SELECT SUBSTRING(E2_FILIAL,1,2) AS FILIAL, E2_FILIAL, E2_FORNECE, E2_LOJA, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_TIPO, E2_EMISSAO, E2_VALLIQ, E2_VALOR, E2_VENCTO, E2_VENCREA, E2_BAIXA, E2_XFATFOR, E2_CODBAR, E2_LINDIG, A2_NOME, A2_EMAIL, A2_CGC ,G4V_EMAIL, SE2.R_E_C_N_O_ AS RECNO, E5_HISTOR, E5_TIPODOC, E5_VALOR, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ " + CRLF
	_cQuery += " FROM " + RetSqlName("SE2") + " SE2 " + CRLF
	_cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON (E2_FORNECE = SA2.A2_COD AND E2_LOJA = SA2.A2_LOJA) AND SA2.D_E_L_E_T_ = ' ' " 
	_cQuery += " LEFT OUTER JOIN " + RetSqlName("G4V") + " G4V ON (E2_FORNECE = G4V_FORNEC AND E2_LOJA = G4V_LOJA) AND G4V.D_E_L_E_T_ = ' ' " 

	_cQuery += " LEFT OUTER JOIN " + RetSqlName("SE5") + " SE5 ON (E2_FILIAL = SE5.E5_FILIAL AND E2_FORNECE = SE5.E5_CLIFOR AND E2_LOJA = SE5.E5_LOJA AND E2_NUM = SE5.E5_NUMERO AND E2_PREFIXO = SE5.E5_PREFIXO AND E2_PARCELA = SE5.E5_PARCELA) AND SE5.D_E_L_E_T_ = ' ' " 
	_cQuery += " WHERE " + CRLF
	_cQuery += " SE2.E2_BAIXA BETWEEN  '" + Dtos(MV_PAR01) + "' AND '" +  DTOS(MV_PAR02) + "' "	 + CRLF 
	_cQuery += " AND SE2.E2_FORNECE >=  '" + MV_PAR03 + "' " + CRLF
	_cQuery += " AND SE2.E2_FORNECE <=  '" + MV_PAR04 + "' " + CRLF
		
	_cQuery += " AND SE2.E2_TIPO =  'FTF' " + CRLF	
	_cQuery += " AND SE2.D_E_L_E_T_ <> '*' " + CRLF
	_cQuery += " ORDER BY SUBSTRING(SE2.E2_FILIAL,1,2),SE2.E2_FORNECE,SE2.E2_LOJA " + CRLF

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"MAILTO",.F.,.T.)

	TCSetField("MAILTO","E2_BAIXA"		,"D",8,0)
	TCSetField("MAILTO","E2_EMISSAO"	,"D",8,0)
	TCSetField("MAILTO","E2_VENCTO"		,"D",8,0)
	TCSetField("MAILTO","E2_VENCREA"	,"D",8,0)

	MemoWrite("ENVMAIL.SQL",_cQuery) //grava na system arquivo de query.
	
	MAILTO->(DbGoTop())
    
	If MV_PAR05 <> 1
	
		Processa( {|| CSVCAB(@cArCSV)},"Processando CSV Colunas", "Aguarde")
	
	EndIf
	
	Processa( {|| XMLCSV(cArCSV)},IIF(MV_PAR05 = 1,"Processando XML", IIF(MV_PAR05 = 2,"Processando CSV","Processando XML e CSV")  ), "Aguarde")

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaXML  บAutor  ณMarcelo - Ethosx    บ Data ณ  17/09/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MontaXML()

	Local oExcel 		:= FWMSEXCEL():NEW()
	Local cNameTable	:= "PLANILHA"
	Local cNameSheet	:= "RELAวรO DE TอTULOS PAGOS " + SubStr(Upper(SuperGetMV("AL_SUBJECT", ,"" , MAILTO->FILIAL)),5)
	Local _cCodFor 		:= MAILTO->FILIAL + MAILTO->E2_FORNECE + MAILTO->E2_LOJA
	Local cComp			:= ""
	Local lXfatfor		:= .F.
	Local cArq			:= ""
	Local _ni			:= 1
	Local _uValor 		:= ""     
	
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
	oExcel:AddColumn(cNameTable,cNameSheet,"HISTำRICO",1,1)
	oExcel:AddColumn(cNameTable,cNameSheet,"TIPO MOVIMENTO",1,1)
	
	cComp:= SubStr(Dtos(MAILTO->E2_BAIXA),7,2) + "/" + SubStr(Dtos(MAILTO->E2_BAIXA),5,2) + "/" + SubStr(Dtos(MAILTO->E2_BAIXA),1,4)
	
	While MAILTO->(!Eof()) .and. _cCodFor == MAILTO->FILIAL + MAILTO->E2_FORNECE + MAILTO->E2_LOJA

		If MV_PAR05 <> 2
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

	    EndIf    
		
		If MV_PAR05 <> 1//CSV
		
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
		
		EndIf
			
		MAILTO->(DbSkip())

	EndDo
    
	If MV_PAR05 <> 2
		cArq:= SuperGetMV("AL_ARQEMP", , SubStr(_cCodFor,1,2),SubStr(_cCodFor,1,2)) + "_" + SubStr(_cCodFor,3,9) + "_" + SubStr(_cCodFor,12,4) + "_" + SubStr(Dtos(dDatabase),7,2) + "-" + SubStr(Dtos(dDatabase),5,2) + "-" + SubStr(Dtos(dDatabase),1,4) + "_" + SubStr(Time(),1,2) + "_" + SubStr(Time(),4,2) + "_" + SubStr(Time(),7,2) + ".xml"
		
		oExcel:Activate()
		oExcel:GetXMLFile(cPath + cArq)
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cPath + cArq)
		oExcelApp:SetVisible(.T.)
		
	EndIf
	
return()   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCSVCAB    บAutor  ณMarcelo - Ethosx    บ Data ณ  17/09/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CSVCAB(cArCSV)

	Local cArCSV	:= ""
	Local _ni		:= 1
                         
	ProcRegua(Len(aHeader))
	
	nHandle := MsfCreate(cPath + "CONSOLIDADO_CAP_GRUPOAJ_" +  SubStr(dtos(MV_PAR01),7,2) + "-" + SubStr(dtos(MV_PAR01),5,2) + "-" + SubStr(dtos(MV_PAR01),1,4) + "_" + SubStr(Time(),1,2) + "_" + SubStr(Time(),4,2) + "_" + SubStr(Time(),7,2) + ".CSV",0)
	
	cArCSV:= cPath + "CONSOLIDADO_CAP_GRUPOAJ_" +  SubStr(dtos(MV_PAR01),7,2) + "-" + SubStr(dtos(MV_PAR01),5,2) + "-" + SubStr(dtos(MV_PAR01),1,4) + "_" + SubStr(Time(),1,2) + "_" + SubStr(Time(),4,2) + "_" + SubStr(Time(),7,2) + ".CSV"
	
	If nHandle == -1
	   Alert("Falha ao criar arquivo - erro " + str(ferror()))
   	   Return
	EndIf
	
	//Montagem do cabe็alho do arquivo CSV
	For _ni := 1 to len(aHeader)

		IncProc("Processando Arquivo CSV - Criac็ใo de Colunas"  )

		if _ni = (len(aHeader))
			fWrite(nHandle, aHeader[_ni,1] )
		Else
			fWrite(nHandle, aHeader[_ni,1] + ";" )
		endif
	
	Next _ni

	fWrite(nHandle, CRLF )

Return()   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXMLCSV    บAutor  ณMarcelo - Ethosx    บ Data ณ  17/09/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processo de geracao do XML e CSV                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function XMLCSV(cArCSV)


	If MAILTO->(!Eof())
	
		DbSelectArea("MAILTO")
		
		Procregua(Reccount())
		
		While MAILTO->(!Eof())

			IncProc()
				
			MontaXML()
						
		EndDo
        
		//Sleep(2000)
		fClose(nHandle)// Fechei o arquivo CSV
		ShellExecute("Open",cArCSV,"","",1)
		
	Else
	
		Alert("Nใo Existem Dados com esses parโmetros")
	
	Endif

	MAILTO->(DbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณValidP1   ณ Autor ณ Marcelo - Ethosx      ณ Data ณ 05.09.19  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Parametros da rotina.                			      	   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidP1(cPerg)

Local i := 0
Local j := 0

dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}              
aAdd(aRegs,{cPerg,"01","Data Baixa de ?                     "	,"","","mv_ch1" ,"D", 8,0,0,"G",""														,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""		,"","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data Baixa ate ?                    "	,"","","mv_ch2" ,"D", 8,0,0,"G","NaoVazio()"											,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""		,"","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Fornecedor de ?                     "	,"","","mv_ch3" ,"C", 9,0,0,"G",""														,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2"	,"","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Fornecedor ate ?                    "	,"","","mv_ch4" ,"C", 9,0,0,"G",""														,"mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA2"	,"","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Gera็ใo ?     		                 "	,"","","mv_ch5" ,"N", 1,0,0,"C",""														,"mv_par05","Somente XML","Somente XML","Somente XML","","","Somente CSV","Somente CSV","Somente CSV","","","Ambos","Ambos","Ambos","","","","","","","","","","","","","","","","","","","",""} )

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
		dbCommit()
	Endif
Next
                          
Return(.T.)