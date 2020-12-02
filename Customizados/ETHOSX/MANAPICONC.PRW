#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "TURA042.ch"
#Include "TbIconn.ch"

Static cAdmErro		:= " Procure o administrador."

User Function ManApiConc(oJson)
	Local __cFilAnt	:= ""	//variavel para backup da filial corrente se necessário
	Local oModG8C 	:= Nil	//Cabeçalho Conc. Fatura Terrestre
	Local oModG3R	:= Nil 	//Documento de reserva
	Local oModG46	:= Nil 	//Taxas	
	Local oModG47	:= Nil 	//Extras
	Local oModG48A := Nil 	//Acordos de Cliente 
	Local oModG48B := Nil 	//Acordos de Cliente 
	Local oModG3U	:= Nil  //2 - Hotel(G3U)
	Local oModG44	:= Nil  //TarIfas*/
	Local lContinua	:= .t.
	Local nX
	Local nLoop,nLoop2
	Local aRet		:= {}
	Local bTura042
	Local oModel	:= nil
	Local cFilJson	:= ''
	Local cFile01 	:= ''
	Local cFile02 	:= ''
	Local aFile		:= {}
	Local cFatura	:= ''
	Local cRV		:= ''
	Local cErro		:= ''
	Local cRetorno	:= ''
	Local nTamG3R	:= 0

	
	cFilJson	:= oJson:NUMERO_FILIAL
	
	//verIfica se existe empresa aberta
	If Type('cFilAnt')=='U'
		RpcSetType( 3 )
		If !(RpcSetEnv( '01' , cFilJson ))
			lContinua	:= .F.
			cRetorno	:= '{"status":"erro","msghelp":"Não foi possível abrir a empresa.'+cAdmErro+'"}'
		EndIf
	EndIf
	//necessário para que gere a fatura corretamente do fina290
	nModulo := 89
	//tratamento para mudança de filial, caso necessário
	If !(cFilAnt == cFilJson)
		__cFilAnt 	:= cFilAnt
		cFilAnt 	:= cFilJson
	EndIf	
	

	If lContinua
		oModel	:= FwLoadModel( "TURA042A" )
		TRDChaceNew()

		oModel:SetOperation(MODEL_OPERATION_INSERT)
		
		oModel:Activate()
		//variaveis publicas
		CriarVarPub()
		
		oModG8C  	:= oModel:GetModel("G8C_MASTER")
		oModG3R  	:= oModel:GetModel("G3R_ITENS" )
		oModG46  	:= oModel:GetModel("G46_ITENS" )
		oModG47 	:= oModel:GetModel("G47_ITENS" )
		oModG48A 	:= oModel:GetModel("G48A_ITENS")
		oModG48B 	:= oModel:GetModel("G48B_ITENS")
		oModG3U  	:= oModel:GetModel("G3U_ITENS" )
		oModG44  	:= oModel:GetModel("G44_ITENS" )
		oModSrc  	:= oModel:GetModel("TMP_SEARCH")
		
		For nX := 1 To Len(oJson:Object)
			cRV		:= oJson:Object[nX][6]:RV
			If lContinua 
				lContinua := CountRv(cRV)
				If lContinua
					oModSrc:SetValue("SRC_NUMID",cRV)				
					cErro := ''					
					//SIMULA O F5 DA ROTINA PADRÃO
 					bTura042 := {||StaticCall(TURA042,TA042SrcG3R)}
					Eval(bTura042)

					cErro := GetLasHelp()
					If 'Documento de Reserva foi encontrado na conciliação' $ cErro  
						Return '{"status":"erro","msghelp":"'+cErro+'"}'	
					ElseIf 'Documento de Reserva com Fornecedor de Reporte diferente' $ cErro  
						Return '{"status":"erro","msghelp":"'+cErro+'"}'	
					ElseIf  ' Documento de Reserva já selecionado nesta conciliação' $ cErro  
						Return '{"status":"erro","msghelp":"'+cErro+'"}'
					ElseIf 'TA042VLDDR     '  $ cErro  		
						Return '{"status":"erro","msghelp":"'+cErro+'"}'
					EndIf
				
					//trata o periodo
					dDataIni 	:= SToD(oJson:Object[nX][7]:CHECK_IN)
					dDataFim	:= SToD(oJson:Object[nX][8]:CHECK_OUT)
					
					If Empty(oModG3U:GetValue("G3U_DTINI")) .OR. Empty(oModG3U:GetValue("G3U_DTFIM")) 
						oModG3U:SetValue("G3U_DTINI",dDataIni)
						oModG3U:SetValue("G3U_DTFIM",dDataFim)
					EndIf
					
					If Empty(oModG3U:GetValue("G3U_CIDHOT"))
						DBSelectArea("SA2")
						SA2->(dbSetOrder(1))
						If SA2->(dbSeek(xFilial("SA2")+oModG8C:GetValue("G8C_FORNEC")))
							oModG3U:SetValue("G3U_CIDHOT", AllTrim(SA2->A2_MUN))
							oModG3U:SetValue("G3U_HRINI", "00:00")
							oModG3U:SetValue("G3U_HRFIM", "00:00")		
						EndIf	
					EndIf	
					If !(oModG3U:GetValue("G3U_DTINI") == dDataIni) .or. !(oModG3U:GetValue("G3U_DTFIM")==dDataFim) 
						 
						oModG3U:SetValue("XXX_DTINI" ,oModG3U:GetValue("G3U_DTINI")) 
						oModG3U:SetValue("XXX_DTFIM" ,oModG3U:GetValue("G3U_DTFIM")) 
						oModG3U:SetValue("G3U_DTINI",dDataIni)
						oModG3U:SetValue("G3U_DTFIM",dDataFim)
						
						oModG3U:SetValue("G3U_HRINI", "00:00")
						oModG3U:SetValue("G3U_HRFIM", "00:00")						

						SetAltSeg(.t.)						
						TA042AtuDR(.T.)
						nTamG3R := oModel:GetModel("G3R_ITENS" ):LENGTH()
						While nTamG3R >= 1
							oModel:GetModel("G3R_ITENS" ):GOLINE(nTamG3R)
							If oModel:GetModel("G3R_ITENS"):GetValue("G3R_STATUS",nTamG3R) == '1'								
								nTamG3R := 0
							EndIf
							nTamG3R--
						EndDo
					EndIf
					
					//tarifas
					If  (oJson:Object[nX][10]:TARIFA_BASE > 0 )						
						oModG44:SetValue("G44_TARBAS",oJson:Object[nX][10]:TARIFA_BASE)
						SetAltTarIfa(.t.)
					EndIf
					
					//taxas
					lAdiciona	:= .F.
					For nLoop2 := 1 To oModG46:LENGTH()
						oModG46:GOLINE(nLoop2)
						If !(oModG46:GetValue("G46_VLBASE") == oJson:Object[nX][9]:VALOR_BASE_TAXA) .OR. oModG46:ISDELETED()
							If  (oModG46:GetValue("G46_VLBASE") == 0)
								oModG46:SetValue("G46_EMISS",dDataIni) 
								oModG46:SetValue("G46_VLBASE",oJson:Object[nX][9]:VALOR_BASE_TAXA)	
								SetAltTaxas(.t.)
								lAdiciona := .F.
							Else
								oModG46:SetValue("G46_VLBASE",0)							
								lAdiciona	:= .T.
							EndIf	
						Else
							lAdiciona := .F.
						EndIf	
					Next
										
					If  (oJson:Object[nX][9]:VALOR_BASE_TAXA > 0)												
						if lAdiciona
							nLinha	:= oModG46:AddLine()
							oModG46:GOLINE(nLinha)							
							oModG46:SetValue("G46_EMISS",dDataIni) 
							oModG46:SetValue("G46_VLBASE",oJson:Object[nX][9]:VALOR_BASE_TAXA)	
							SetAltTaxas(.t.)
						EndIf	
					EndIf	
					
					//extras
					If oJson:Object[nX][5]:EXTRA > 0						
						If oModG47:isDeleted() 
							nLinha	:= oModG47:AddLine()
							oModG47:GOLINE(nLinha)
						EndIf	
							
						oModG47:SetValue("G47_EMISS",dDataIni) 
						If Empty(oJson:Object[nX][4]:DESCRICAO_EXTRAS)
							oModG47:SetValue("G47_EXTRA","Restaurante")
						Else
							oModG47:SetValue("G47_EXTRA",DecodeUtf8(oJson:Object[nX][4]:DESCRICAO_EXTRAS))
						EndIf					
						oModG47:SetValue("G47_QUANT",1) 
						oModG47:SetValue("G47_VLUNIT",oJson:Object[nX][5]:EXTRA) 
						SetAltExtras(.t.)
						EndIf

					//acordos
					For nLoop2 := 1 To oModG48B:LENGTH()
						If !Empty(oModG48B:GetValue("G48_CODACD"))								
							oModG48B:GOLINE(nLoop2)
							If oJson:Object[nX][3]:ACORDO == 0
								oModG48B:LoadValue("G48_STATUS","3")
								oModG48B:SetValue(  "G48_RECCON", .F. )
								oModG48B:SetValue("G48_TPACD",'2') 
							EndIf							
						EndIf	
					Next
										
					If  (oJson:Object[nX][3]:ACORDO > 0)
						If !Empty(oModG48B:GetValue("G48_CODACD"))								
							oModG48B:LoadValue("G48_STATUS","3")							
							oModG48B:SetValue( "G48_RECCON", .F. )												
							nlinha := oModG48B:AddLine()
							oModG48B:GOLINE(nlinha)
						EndIf
						oModG48B:SetValue("G48_CODACD","000183")
						oModG48B:SetValue("G48_CODREC","04")
						oModG48B:SetValue("G48_STATUS", "1" )
						oModG48B:SetValue("G48_TPACD",'1') 
						oModG48B:SetValue("G48_RECCON", .T. )
							
						oModG48B:SetValue("G48_VLACD",oJson:Object[nX][3]:ACORDO)
																	
						SetAplAcordFin(.t.)	
					EndIf
					
					if Empty(oModG46:GetValue("G46_MOEDA"))
						oModG46:SetValue("G46_MOEDA","01")
					EndIf

					if Empty(oModG46:GetValue("G46_TXCAMB"))
						oModG46:SetValue("G46_TXCAMB",1) 
					EndIf
					
					if Empty(oModG47:GetValue("G47_MOEDA"))
						oModG47:SetValue("G47_MOEDA","01") 
					EndIf
					
					if Empty(oModG47:GetValue("G47_TXCAMB"))
						oModG47:SetValue("G47_TXCAMB",1) 
					EndIf
										
					TA042AtuDR(.T.)
				Else
					lContinua	:= .F.
					cRetorno	:= '{"status":"erro","msghelp":"Existe mais de UM ou NÃO existe registro para o RV: '+cRV+'."}'					
				EndIf
			EndIf	
		Next
		
		If lContinua 
			If !Empty(oModG8C:GetValue("G8C_FORNEC"))
				//grava as informações
				oModG8C:SetValue("G8C_XEDOC" ,xFilial("G8C"))			
				oModG8C:SetValue("G8C_FATURA",oJson:NUMERO_FATURA)		
				oModG8C:SetValue("G8C_SERIE",'FF')				
				oModG8C:SetValue("G8C_EMISSA",SToD(oJson:DATA_EMISSAO))
				oModG8C:SetValue("G8C_VENCIM",SToD(oJson:DATA_VENCIMENTO))
				If !(oModG8C:GetValue("G8C_VLRFAT") == oJson:VALOR_BOLETO)
					Return '{"status":"erro","msghelp":"Erro no calculo da fatura: '+oJson:NUMERO_FATURA+'."}'	
				EndIf	
				oModG8C:SetValue("G8C_OBSERV","Número da Fatura: "+oJson:NUMERO_FATURA)
				oModG8C:SetValue("G8C_XEDOC" ,oJson:Object[1][2]:ID_DOCUMENTO_SUP)	
				oModG8C:SetValue("G8C_TIPO","1")
				//variaveis publicas
				CriarVarPub()

				lContinua  := TA042ATOK(oModel)
				If	lContinua .AND. VlFat(oJson:NUMERO_FATURA)
					If lContinua
						//variaveis publicas
						CriarVarPub()
						lContinua := FwFormCommit(oModel)
						If lContinua
							If File('\spool\'+"demfinagen-ter.pdf")
								fErase('\spool\'+"demfinagen-ter.pdf")
								fErase('\spool\'+"demfincli-ter.pdf")
							EndIf 		
							//variaveis publicas
							CriarVarPub()
							TA042AEfet()		
						EndIf						 	
					EndIf
				EndIf	
			EndIf
		EndIf	
		If !lContinua .or. Empty(cRetorno)
			cHelp := GetLasHelp()
			If cHelp == ''
				cRetorno	:= '{"status":"erro","msghelp":"Não foi possível gerar a conciliação.","last_rv":"'+cRV+'"}'
			Else
				cRetorno	:='{"status":"erro","msghelp":"'+cHelp+'","last_rv":"'+cRV+'"}'
			EndIf					
		EndIf
	Else	
		lContinua	:= .F.
		cRetorno	:= '{"status":"erro","msghelp":"Não foi possível abrir o ambiente."}'
	EndIf

	If lContinua	
		cFile01 := ""
		cFile02 := ""
		If File('\spool\'+"demfinagen-ter.pdf")
			//Conecta e envia para o FTP
			cFatura	:= oJson:NUMERO_FATURA
			aRet := startjob("u_SendFTP",getenvserver(),.T.,cFatura)
			
			lContinua	:= aRet[1]
			cRetorno	:= aRet[2]
			If lContinua
				
				cRetorno	:= '{"status":"ok",'+; 
								'"conciliacao":"'+oModG8C:GetValue("G8C_CONCIL")+'",'+; 
								'"file1":"'+cFatura+"_agencia.pdf"+'",'+;
								'"file2":"'+cFatura+"_cliente.pdf"+'"}'
			EndIf
		Else
			lContinua 	:= .F.
			cRetorno	:= '{"status":"erro","msghelp":"Não foi possível gerar a efetivação"}'
		EndIf
	Endif
	//restaura a filial
	If !empty(__cFilAnt) .and. !(cFilAnt == __cFilAnt)
		cFilAnt	:= __cFilAnt
	EndIf	
	
Return cRetorno


User Function SendFTP(cFatura)
	Local cIPFtp		:= ''
	Local cPorta		:= ''
	Local cUser			:= ''
	Local cPass			:= ''
	Local cPath			:= '\spool\'
	Local lContinua		:= .T.
	Local cRetorno		:= '{"status":"ok","msghelp":"ok!."}'
	Local cDirServ		:= "\sbk_ftp"
	Local nCont			:= 0
	Local nLoop			:= 0
	Local cNewArquivo	:= ''
	Local oFTPHandle 	:= NIL
	Local oFile
	Local aFile := {"demfinagen-ter.pdf","demfincli-ter.pdf"}
	
    
    RpcSetType( 3 )
	RpcSetEnv( '01' , "01SP0005" )

    cIPFtp		:= GETMV("FS_FTPIP",.T.,"ftp.sbkbpo.com.br")
	cPorta		:= GETMV("FS_FTPPORT",.T.,21)
	cUser		:= GETMV("FS_FTPUSER",.T.,"alaturjtb2")
	cPass		:= GETMV("FS_FTPASS",.T.,"Sbk@190807#")
	

	Makedir(cDirServ)		
	
	oFTPHandle := tFtpClient():New()	
		
	nRet := oFTPHandle:FTPConnect(cIPFtp, cPorta ,cUser, cPass)
		
	If (nRet != 0)
		lContinua 	:= .F.
		cRetorno	:= '{"status":"erro","msghelp":"Não foi possível se conectar!!."}'
	EndIf
		
	If lContinua
	    For nLoop := 1 To Len(aFile)			
			cArquivo 	:= aFile[nLoop]
			cOnLyFile	:= IIf(nLoop == 1, cFatura+"_agencia.pdf",cFatura+"_cliente.pdf")
			cNewArquivo	:= cDirServ+'\'+IIf(nLoop == 1, cFatura+"_agencia.pdf",cFatura+"_cliente.pdf")
			If !(__CopyFile(cPath+cArquivo,cNewArquivo))
				lContinua 	:= .F.
				cRetorno	:= '{"status":"erro","msghelp":"Não foi possível enviar o arquivo para o servidor."}'
				Loop
			EndIf
						
			If oFTPHandle:SendFile(cNewArquivo,cOnLyFile) == 0					
				If File(cNewArquivo)
				    fErase(cNewArquivo)
			    EndIf
            Else
                lContinua 	:= .F.
			    cRetorno	:= '{"status":"erro","msghelp":"Não foi possível enviar o arquivo para o FTP!!."}'
			EndIf        				
		Next						
	EndIf

    oFTPHandle:Close()
Return {lContinua,cRetorno}

Static Function CountRv(cReserva)
	Local lRet   	:= .T.
	Local cWhere 	:= ""
	Local cQuery 	:= ""
	Local cAliasG3R := GetNextAlias()
	Local aArea     := GetArea()
	Local oModel    := FwModelActive()
	Local nTotReg   := 0

	If !Empty(cReserva)
		cWhere += " G3R_NUMID = '"  + StrTran(StrTran(cReserva, '"', ''), "'", "")  + "' AND "
	EndIf
	
	cQuery := "SELECT "
	cQuery += "		'  ' AS G3R_MARK, "
	cQuery += "		G3R_FILIAL, "
	cQuery += "		G3R_NUMID, "
	cQuery += "		G3R_IDITEM, "
	cQuery += "		G3R_NUMSEQ, "
	cQuery += "		(CASE "
	cQuery += "			WHEN G3Q_OPERAC = '1' THEN '" + STR0042 + "' "		// "Emissão" 
	cQuery += "			WHEN G3Q_OPERAC = '2' THEN '" + STR0055 + "' "		// "Reembolso"		
	cQuery += "			WHEN G3Q_OPERAC = '3' THEN '" + STR0043 + "' "		// "Reemissão" 
	cQuery += "		END) G3Q_OPERAC, "
	cQuery += "		(CASE "
	cQuery += "			WHEN G3Q_TPDOC = '1' THEN '" + STR0044 + "' "		// "Voucher" 
	cQuery += "			WHEN G3Q_TPDOC = '4' THEN '" + STR0054 + "' "		// "Doc. Adicional" 
	cQuery += "		END) G3Q_TPDOC, "
	cQuery += "		G3Q_DOC, "
	cQuery += "		G3Q_EMISS, "
	cQuery += "		G3R_FORNEC, "
	cQuery += "		G3R_LOJA, "
	cQuery += "		A2_NOME, "
	cQuery += "		G3R_ACERTO, " 
	cQuery += "		G3R_TARIfA, "
	cQuery += "		G3R_TAXA, "
	cQuery += "		G3R_EXTRAS, "
	cQuery += "		G3R_VLCOMI, "
	cQuery += "		G3R_TAXADU, "
	cQuery += "		G3R_VLINCE, "
	cQuery += "		G3R_FORREP, "
	cQuery += "		G3R_LOJREP, "
	cQuery += "		G3R_NOMREP, "
	cQuery += "		G3R_TXFORN, "
	cQuery += "		G3R_TOTREC, "
	cQuery += "		G3Q_POSTO, "
	cQuery += "		G3M_DESCR, "
	cQuery += "		G3Q_CLIENT, "
	cQuery += "		G3Q_LOJA, "
	cQuery += "		A1_NOME, "
	cQuery += "		G3Q_FORMPG, " 
	cQuery += "		G3Q_DESCFP, "
	cQuery += "		G3Q_ORDER, "
	cQuery += "		G3Q_ITOS, "
	cQuery += "		G3R_LOCGDS, "
	cQuery += "		G3R_CONCIL, "
	cQuery += "		G3R_STATUS, "
	cQuery += "		G3R_SEQNSH, "
	cQuery += "		G3R_SEQPRC, "
	cQuery += "		G3R_MOEDA, "
	cQuery += "		G3R_MSFIL "
	cQuery += "	FROM " + RetSQLName("G3R") + " G3R "
	cQuery += "	INNER JOIN " + RetSQLName("G3Q") + " G3Q ON G3Q_FILIAL = G3R_FILIAL AND "
	cQuery += "	                                     G3Q_NUMID  = G3R_NUMID  AND "
	cQuery += "	                                     G3Q_IDITEM = G3R_IDITEM AND "
	cQuery += "	                                     G3Q_NUMSEQ = G3R_NUMSEQ AND "
	cQuery += "	                                     G3Q_CONINU = ''         AND "
	cQuery += "	                                     G3Q.D_E_L_E_T_ = '' "
	cQuery += "	INNER JOIN " + RetSQLName("G3M") + " G3M ON G3M_FILIAL = G3Q_FILPST AND "
	cQuery += "	                                     G3M_CODIGO = G3Q_POSTO  AND " 
	cQuery += "	                                     G3M.D_E_L_E_T_ = '' "
	cQuery += "	INNER JOIN " + RetSQLName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial('SA1') + "' AND "
	cQuery += "	                              A1_COD    = G3Q_CLIENT    AND "
	cQuery += "	                              A1_LOJA   = G3Q_LOJA      AND "
	cQuery += "	                              SA1.D_E_L_E_T_ = '' "
	cQuery += "	INNER JOIN " + RetSQLName("SA2") + " SA2 ON A2_FILIAL = '" + xFilial('SA2') + "' AND "
	cQuery += "	                              A2_COD    = G3R_FORNEC    AND "
	cQuery += "	                              A2_LOJA   = G3R_LOJA      AND "
	cQuery += "	                              SA2.D_E_L_E_T_ = '' "

	If !Empty(xFilial('G8C')) .Or. !Empty(xFilial('SA1'))
		cQuery += "	WHERE G3R_FILIAL = '" + xFilial('G3R') + "' AND "
	Else
		cQuery += "	WHERE "
	EndIf
	
	If FwIsInCallStack('TURA042A')
		cQuery += "	      G3Q_OPERAC IN ('1', '3') AND "		// 1=Emissão e 3=Reemissão
	ElseIf FwIsInCallStack('TURA042R')
		cQuery += "	      G3Q_OPERAC = '2' AND "				// 2=Reembolso
	EndIf
	
	cQuery += "	      G3Q_TPDOC  IN ('1', '4') AND "			// 1=Voucher e 4=Doc Adicional
	cQuery += "		 (G3R_ACERTO = '2' OR (G3R_ACERTO = '1' AND G3R_CONALT = '')) AND "		// mostra acerto manual
	cQuery += "		  G3R_TPSEG <> '1' AND "
	cQuery += "		  G3R_CONINU = ''  AND " + cWhere
	cQuery += "		  G3R.D_E_L_E_T_ = '' "
	
	cQuery    := ChangeQuery(cQuery)
	cAliasG3R := GetNextAlias()
	DBUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), cAliasG3R, .F., .T.)
	DBSelectArea(cAliasG3R)
		
	Count To nTotReg
	
	(cAliasG3R)->(DbGoTop())

	If (cAliasG3R)->(EOF())	
		Help( , , "TA042SrcG3R", , STR0045, 1, 0)		// "Documento de Reserva não encontrado."
	EndIf
		
	If !nTotReg == 1
		lRet := .F.
	EndIf	

Return lRet

Static Function GetLasHelp()
	Local aError 	:=  FWGetUltHlp()
	Local cReturn	:= ''

	If Len(aError) > 0
		cReturn	:= AllTrim(aError[1])
	EndIf	
	If Len(aError) > 1
		cReturn	+=	Space(5)+Alltrim(aError[2,1])
	EndIf	
	If Len(aError) > 3
		cReturn	+= Space(5)+AllTrim(aError[3,1])
	EndIf
Return cReturn	

Static Function VlFat(cFatura)
	Local aArea		:= GetArea()
	Local aAreaG8C	:= G8C->( GetArea() )
	Local lRet 		:= .T.
	Local oModel    := FwModelActive()

	If !FwIsInCallStack('TA042FillG3R') .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
		G8C->( dbSetOrder(2) )
		If G8C->( dbSeek(xFilial("G8C") + FWFldGet("G8C_FORNEC") + FWFldGet("G8C_LOJA") + cFatura))
			lRet := .F.
			Help(,,"TA042VLFAT",,"Fatura já cadastrada para este fornecedor.",1,0)		 
		EndIf
	EndIf
	
	RestArea(aAreaG8C)
	RestArea(aArea)
Return lRet

Static Function CriarVarPub()
	//variaveis publicas inicializadas
	__cUserId	:= '001568'
	cId 		:= '001568'
	cUserName 	:= 'WS.CONC'
	cUsrName	:= 'WS.CONC'
REturn nil