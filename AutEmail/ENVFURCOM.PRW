#INCLUDE "TOTVS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE 'PARMTYPE.CH'

/*================================================================================================
{Protheus.doc} ENVFURCOM
Enviar e-mail para Fornecedores com Comissões em Atraso a mais de 365 dias
@Project FURO 365 DIAS
@Author  Mário Augusto Cavenaghi
@Since   16/01/2020
@Type    User Function
@Return  Nil
@Version P12.1.17
@History
================================================================================================*/

User Function ENVFURCOM()

	Local cServer  := SuperGetMV("MV_RELSERV",, "smtp.office365.com:587")
	Local cAccount := SuperGetMV("MV_RELACNT",, "erpp@alatur.com")
	Local cPass    := SuperGetMV("MV_RELPSW" ,, "456!@vbnm")
	Local cFrom    := SuperGetMV("MV_RELFROM",, "erpp@alatur.com")
	Local cMailTo  := ""	//	e-MAIL do Fornecedor
	Local cMailCc  := SuperGetMV("AL_CRECFOR",, "contasareceber.fornecedores@alaturjtb.com")	//	Criar
	Local cMailBcc := ""
	Local cMailUsr := ""
	Local cSubject := "Fatura(s) vencida(s) há mais de 365 dias - Inadimplência = AJ Mobi " + Iif(cEmpAnt = "01", "(Alatur JTB)", "(BSP)")
	Local cPerg    := "ENVFURCOM"
	Local cQuery := ""
	Local cDtFuro := ""
	Local cFornec := ""
	Local cCheckIN := ""
	Local cCheckOUT := ""
	Local cApu := ""
	Local cTab := ""
	Local cBody := ""
	Local cAnexo := ""
	Local nServico := 0
	Local nLenTit := 0
	Local nItem := 0
	Local oServer := TMailManager():New()
	Local oMessage := TMailMessage():New()
	Local aTitulos := {}
	Local aMail := {}
	Local aAnexo := {}
	Local aServico := { ;
		{"1", "G3T", "G3T_DTCHEG", "G3T_DTSAID"},;
		{"2", "G3U", "G3U_DTINI" , "G3U_DTFIM" },;
		{"3", "G3V", "G3V_DTINI" , "G3V_DTFIM" },;
		{"4", "G3W", "G3W_DTINI" , "G3W_DTFIM" },;
		{"5", "G3Y", "G3Y_DTINI" , "G3Y_DTFIM" },;
		{"6", "G3X", "G3X_DTINI" , "G3X_DTFIM" },;		//{"7", "G42", ""          , ""          },;
		{"8", "G41", "G41_DTINI" , "G41_DTFIM" },;
		{"9", "G40", "G40_DTINI" , "G40_DTFIM" },;
		{"A", "G3Z", "G3Z_DTINI" , "G3Z_DTFIM" },;
		{"B", "G43", "G43_DTINI" , "G43_DTFIM" } }

	AJUSTA_SX1(cPerg)	//	Cria os Parâmetros
	If Pergunte(cPerg)
		cDtFuro  := DtoS(dDataBase - MV_PAR05)		//	Dias de atraso
		cMailBcc := Alltrim(MV_PAR09)
		cMailUsr := Iif(MV_PAR08 > 1, Alltrim(UsrRetMail(RetCodUsr())), "")	//	Usuário logado
		If Empty(cMailUsr)
			cMailUsr := cMailBcc
		ElseIf !Empty(cMailBcc) .And. Upper(cMailBcc) <> Upper(cMailUsr)
			cMailUsr += ";" + cMailBcc
		Endif

		//MONTA QUERY DE E-MAIL QUE ESTÃO ESPERANDO PARA SER ENVIADOS
		cQuery += "SELECT DISTINCT " + CRLF
		cQuery += "       XX_APU      = E1_FILIAL + '.' + E1_PREFIXO + '.' + E1_NUM, " + CRLF
		cQuery += "       F2_NFELETR  , " + CRLF
		cQuery += "       E1_VENCREA  , " + CRLF
		cQuery += "       E1_SALDO    , " + CRLF
		cQuery += "       G3S_NOME    , " + CRLF
		cQuery += "       XX_VOUCHER  = E1_FILIAL + '.' + G3R_NUMID  + '.' + G3R_IDITEM + '.' + G3R_NUMSEQ, " + CRLF
		cQuery += "       G3R_IDCONF  , " + CRLF
		cQuery += "       G3R_TPSEG   , " + CRLF
		cQuery += "       G3R_VLCOMI  , " + CRLF
		cQuery += "       XX_CHAVE    = G48_FILIAL + G48_NUMID + G48_IDITEM + G48_NUMSEQ, " + CRLF
		cQuery += "       E1_CLIENTE, E1_LOJA, E1_FILIAL, E1_PREFIXO, E1_NUM, G4V_EMAIL, G4S_EMAIL " + CRLF

		cQuery += "  FROM      SE1010 SE1 " + CRLF
		cQuery += " INNER JOIN SA1010 SA1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND A1_XCLIFOR = 'F' AND SA1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " INNER JOIN SA2010 SA2 ON A2_CLIENTE = A1_COD AND  A2_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "  LEFT JOIN G4V010 G4V ON G4V_FORNEC = A2_COD AND G4V_LOJA = A2_LOJA AND G4V.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "  LEFT JOIN G4S010 G4S ON G4S_FORNEC = G4V_FORNEC AND G4S_LOJA = G4V_LOJA AND G4S.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " INNER JOIN G8E010 G8E ON G8E_FILREF =  E1_FILIAL AND G8E_PREFIX  =  E1_PREFIXO AND G8E_NUMFAT = E1_NUM AND G8E_SERIE  = 'NF' AND G8E_CLIENT = E1_CLIENTE AND G8E_LOJA = E1_LOJA AND G8E.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " INNER JOIN SF2010 SF2 ON F2_FILIAL = G8E_FILREF  AND  F2_CLIENTE = G8E_CLIENT  AND  F2_LOJA       = G8E_LOJA   AND  F2_DOC    = G8E_NUMNF  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " INNER JOIN G85010 G85 ON G85_FILIAL = G8E_FILIAL  AND G85_NUMFAT  = G8E_NUMFAT AND G85_PREFIX = 'APU' AND G85.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " INNER JOIN G81010 G81 ON G81_FILREF = G85_FILREF  AND G81_IDIFA = G85_IDIFA   AND G81.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " INNER JOIN G48010 G48 ON G48_FILIAL = G81_FILREF  AND G48_CODAPU = G81_CODAPU AND G48_CLASS  = 'F01' AND G48_CONINU = ' ' AND G48.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " INNER JOIN G3R010 G3R ON G3R_FILIAL = G48_FILIAL  AND G3R_NUMID   = G48_NUMID   AND G3R_IDITEM     = G48_IDITEM AND G3R_NUMSEQ = G48_NUMSEQ AND G3R_CONINU = G48_CONINU AND G3R.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " INNER JOIN G3S010 G3S ON G3S_FILIAL = G48_FILIAL  AND G3S_NUMID   = G48_NUMID   AND G3S_IDITEM     = G48_IDITEM AND G3S_NUMSEQ = G48_NUMSEQ AND G3S_CONINU = G48_CONINU AND G3S.D_E_L_E_T_ = ' ' " + CRLF

		cQuery += " WHERE E1_CLIENTE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "' " + CRLF
		cQuery += "   AND E1_LOJA    BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "' " + CRLF
		cQuery += "   AND E1_PREFIXO = 'APU' " + CRLF
		cQuery += "   AND E1_VENCREA < '" + cDtFuro + "' " + CRLF
		cQuery += "   AND E1_SALDO   > 0 " + CRLF
		cQuery += "   AND E1_ORIGEM  LIKE 'TURA%' " + CRLF
		cQuery += "   AND SE1.D_E_L_E_T_ = ' ' " + CRLF

		cQuery += " ORDER BY E1_CLIENTE, E1_LOJA, E1_FILIAL " + CRLF

		DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "MAILTO", .F., .T.)
		TCSetField("MAILTO", "E1_VENCREA", "D", 8, 0)
		MemoWrite("C:\ENVFURCOM.SQL", cQuery) //grava na system arquivo de query.

		If MAILTO->(!Eof())	//Conecta apenas no primeiro envio
			ConOut("ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - Conectando ao SMTP")
			oServer:SetUseTLS(.T.)
			oServer:Init('', SubStr(AllTrim(cServer), 1, Len(AllTrim(cServer)) - 4), Alltrim(cAccount), Alltrim(cPass), 0, Val(Right(AllTrim(cServer), 3)))
			oServer:SetSmtpTimeOut(120)
			nErro := oServer:SmtpConnect()
			If nErro <> 0
				ConOut( "ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - ERROR:" + oServer:GetErrorString(nErro))
				oServer:SMTPDisconnect()
				RpcClearEnv()
				Return .F.
			Endif
			nErro := oServer:SmtpAuth( Alltrim(cAccount), Alltrim(cPass))
			If nErro <> 0
				ConOut( "ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - ERROR:" + oServer:GetErrorString(nErro))
				oServer:SMTPDisconnect()
				RpcClearEnv()
				Return .F.
			Endif
			SA1->(dbSetOrder(1))
			While !MAILTO->(Eof())
				If cFornec <> MAILTO->(E1_CLIENTE + E1_LOJA)
					cFornec  := MAILTO->(E1_CLIENTE + E1_LOJA)
					aTitulos := {}
					nLenTit  := 0
					cApu     := ""
					If MV_PAR08 <> 2
						aMail := StrTokArr(Alltrim(MAILTO->G4V_EMAIL), ";")	//	E-mail de Cobrança
						For nItem := 1 To Len(aMail)
							If !("ALATUR" $ Upper(aMail[nItem]))	//	Desconsidera e-mail interno
								cMailTo += Iif(!Empty(cMailTo), ";", "") + aMail[nItem]
							Endif
						Next
						If Empty(cMailTo)
							aMail := StrTokArr(Alltrim(MAILTO->G4S_EMAIL), ";")	//	Email Dep. Res.
							For nItem := 1 To Len(aMail)
								If !("ALATUR" $ Upper(aMail[nItem]))	//	Desconsidera e-mail interno
									cMailTo += Iif(!Empty(cMailTo), ";", "") + aMail[nItem]
								Endif
							Next
						Endif
					Endif
					If     MV_PAR08 == 2
						cMailTo := cMailUsr
						cMailCc := ""
					ElseIf MV_PAR08 == 3
						cMailCc += ";" + cMailUsr
					Endif

					// Verifica se e um e-mail valido. Caso nao seja, nem tenta enviar
					If VLD_MAIL(Alltrim(cMailTo + ";" + cMailCc), .T., .T.)
						SA1->(dbSeek(xFilial() + cFornec))
						aAnexo := {}
						While cFornec == MAILTO->(E1_CLIENTE + E1_LOJA)
							nServico := aScan(aServico, {|x| x[1] == MAILTO->G3R_TPSEG})
							If nServico > 0
								cTab := aServico[nServico, 2]	//	Tabela correspondente ao Serviço
								(cTab)->(dbSetOrder(1))
								(cTab)->(dbSeek(MAILTO->XX_CHAVE))
								cCheckIN  := DtoC(&(cTab + "->" + aServico[nServico, 3]))
								cCheckOUT := DtoC(&(cTab + "->" + aServico[nServico, 4]))
							Else
								cCheckIN  := " "
								cCheckOUT := " "
							Endif
							If cApu <> MAILTO->XX_APU
								If !Empty(cApu)
									aAdd(aTitulos, Array(Len(aTitulos[1])))	//	Adiciona uma linha para separar os Títulos
									nLenTit++
									aFill(aTitulos[nLenTit], "  ")
									aTitulos[nLenTit, 1] := "."
								Endif
								cAnexo := FTP_PDF()
								If !Empty(cAnexo)
									aAdd(aAnexo, cAnexo)	//	Retorna o PDF da Danfe
								Endif
								cApu := MAILTO->XX_APU
								MAILTO->(aAdd(aTitulos, { ;
									Alltrim(XX_APU),;
									F2_NFELETR,;
									DtoC(E1_VENCREA),;
									Alltrim(Transform(E1_SALDO, "@E 999,999.99")),;
									G3S_NOME,;
									XX_VOUCHER,;
									G3R_IDCONF,;
									cCheckIN,;
									cCheckOUT,;
									Alltrim(Transform(G3R_VLCOMI, "@E 999,999.99"));
								}))
							Else
								MAILTO->(aAdd(aTitulos, { ;
									" ",;
									" ",;
									" ",;
									" ",;
									G3S_NOME,;
									XX_VOUCHER,;
									G3R_IDCONF,;
									cCheckIN,;
									cCheckOUT,;
									Alltrim(Transform(G3R_VLCOMI, "@E 999,999.99"));
								}))
							Endif
							nLenTit++
							MAILTO->(dbSkip())
						Enddo
						cBody := ADD_ITENS(aTitulos)
						MemoWrite("C:\ENVFURCOM.HTML", cBody) //grava na system arquivo do email

						oMessage:Clear()
						oMessage:cFrom    := Alltrim(cFrom)
						oMessage:cTo      := Alltrim(cMailTo)
						oMessage:cCc      := Alltrim(cMailCc)
						oMessage:cSubject := Alltrim(cSubject)
						oMessage:cBody    := cBody
						If !Empty(aAnexo)
							For nItem := 1 To Len(aAnexo)
								cAnexo := aAnexo[nItem]
								If File(cAnexo)//VERIFICA SE O ARQUIVO EXISTE NA ORIGEM
									If oMessage:AttachFile(Alltrim(cAnexo)) < 0
										Conout( "ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - Erro ao ANEXAR o arquivo: " + cAnexo)
									Else
										//ADICIONA UMA TAG INFORMANDO QUE É UM ATTACH E O NOME DO ARQUIVO
										oMessage:AddAtthTag( 'Content-Disposition: attachment; filename="' + cAnexo + '"')
									EndIf
								EndIF
							Next
						EndIf

						nErro := oMessage:Send(oServer)

						//TRATA O ENVIO DO EMAIL, CASO SEJA BEM SUCEDIDO FAZEMOS AS DEVIDAS TRATATIVAS
						If nErro <> 0
							ConOut("ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - Tentativa de enviar e-mail para " + Alltrim(SA1->A1_NOME))
							ConOut("ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - Erro no envio: " + oServer:GetErrorString(nErro))
							ConOut("ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - Mandando reconectar servidor para corrigir problema apos erro no envio de e-mail")
							oServer:SMTPDisconnect()	//	Desconecta para evitar erro no envio do próximo email
						Else
							ConOut("ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - e-mail para " + Alltrim(SA1->A1_NOME) + " - Enviado")
						Endif
					Else
						ConOut("ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - A T E N Ç Ã O - E-mail não pode ser enviado " + Alltrim(cMailTo))
					Endif

					If !Empty(aAnexo) // se enviou e-mail, matamos o anexo
						For nItem := 1 To Len(aAnexo)
							cAnexo := aAnexo[nItem]
							Ferase(cAnexo)
						Next
					Endif
				Endif
				MAILTO->(DbSkip())
			Enddo
		Endif
		MAILTO->(DbCloseArea())
	Endif

Return()


//=================================================================================================
// Valida se o e-mail passado e valido, permitidno validar diversos e-mails separados por ';'.
// A funcao de validacao de cada e-mail e a isEmail (Padrao TOTVS)
Static Function VLD_MAIL(cEmails, lMultiple, lShowError)

	Local lRet := .F.
	Local aEmails := {}
	Local nValid := 0
	Local nAT := 0

	Default cEmails := ""
	Default lShowError := .F.
	Default lMultiple := .F.

	If !Empty(cEmails)
		cEmails := Alltrim(StrTran(cEmails, ";;", ";"))
		//cEmails := Iif(Right(cEmails, 1) == ";", Left(cEmails, Len(cEmails) - 1), cEmails)	//	Remove ";" do Final
		If(lMultiple) //Caso existam, valida varios e-mails separados por ';'
			aEmails := StrTokArr(Rtrim(cEmails), ";")
		Else
			aAdd(aEmails, Rtrim(cEmails))
		Endif
		If Len(aEmails) = 1
			lMultiple := .F.
		Endif

		//Verifica se TODOS os e-mails informados sao validos
		For nAT := 1 To Len(aEmails)
			If !Empty(aEmails[nAT]) .And. IsEmail(aEmails[nAT])
				nValid++
			Endif
		Next

		//Somente permite continuar caso TODOS os e-mails informados sejam validos
		If nValid == Len(aEmails)
			lRet := .T.
		Else
			If lShowError
				If lMultiple
					ConOut("ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - O(s) E-mail(s) informado(s) é(são) inválido(s)! Verifique...")
				Else
					ConOut("ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - O E-mail informado é inválido! Verifique...")
				Endif
				lRet := .F.
			Endif
		Endif
	Else
		lRet := .T.
	Endif

Return lRet


//=================================================================================================
// Funcao responsável por enviar e-mail informando os que estao bloqueados na fila
Static Function ADD_ITENS(aTitulos)

	Local cDtDesc  := DtoC(MV_PAR07)
	Local cBody    := MONTA_HTML() //Texto da Mensagem
	Local cItens   := ""
	Local nTit     := 0

	For nTit := 1 To Len(aTitulos)
		cItens += '         <tr cellspacing="0" cellpadding="0" bgcolor="' + Iif(nTit % 2 == 0, '#D3D3D3', '#FFFFFF') + '">' + CRLF
		cItens += '          <td align="left"  ><font size="2px"> ' + aTitulos[nTit,  1] + ' </font></td>' + CRLF	//	APU
		cItens += '          <td align="left"  ><font size="2px"> ' + aTitulos[nTit,  2] + ' </font></td>' + CRLF	//	NFe
		cItens += '          <td align="Center"><font size="2px"> ' + aTitulos[nTit,  3] + ' </font></td>' + CRLF	//	Vencimento
		cItens += '          <td align="right" ><font size="2px"> ' + aTitulos[nTit,  4] + ' </font></td>' + CRLF	//	Valor
		cItens += '          <td nowrap align="left"  ><font size="2px"> ' + aTitulos[nTit, 5] + ' </font></td>' + CRLF	//	Nome do Hospede
		cItens += '          <td align="left"  ><font size="2px"> ' + aTitulos[nTit,  6] + ' </font></td>' + CRLF	//	Voucher
		cItens += '          <td align="left"  ><font size="2px"> ' + aTitulos[nTit,  7] + ' </font></td>' + CRLF	//	Confirmação
		cItens += '          <td align="Center"><font size="2px"> ' + aTitulos[nTit,  8] + ' </font></td>' + CRLF	//	Check IN
		cItens += '          <td align="Center"><font size="2px"> ' + aTitulos[nTit,  9] + ' </font></td>' + CRLF	//	Check OUT
		cItens += '          <td align="right" ><font size="2px"> ' + aTitulos[nTit, 10] + ' </font></td>' + CRLF	//	Valor do Serviço
		cItens += '         </tr>' + CRLF
	Next
	cBody := StrTran(cBody, '#FORNECEDOR#'    , '"' + Alltrim(SA1->A1_NOME) + '"')
	cBody := StrTran(cBody, '#DATADESCONTO#'  , cDtDesc)
	cBody := StrTran(cBody, '#ITENS_DE_VENDA#', cItens)

Return(cBody)


//=================================================================================================
// Layout da Mensagem
Static Function MONTA_HTML

	Local cBody := ""

	cBody += '<html>' + CRLF
	cBody += ' <meta http-equiv="Content-Type" content="text/html;charset=UTF-8">' + CRLF
	cBody += ' <head>' + CRLF
	cBody += '  <style type="text/css">' + CRLF
	cBody += '   td { font-family:verdana; font-size:12px}'
	cBody += '   p  { font-family:verdana;}'
	cBody += '  </style>' + CRLF
	cBody += ' </head>' + CRLF
	cBody += ' <body>' + CRLF
	cBody += '  <table style="border:2px; border-style: ridge; " width="100%">' + CRLF
	cBody += '   <!-- CABECALHO -->' + CRLF
	cBody += '   <tr>' + CRLF
	cBody += '    <td>' + CRLF
	cBody += '     <table>' + CRLF
	cBody += '      <tr><td colspan="2">&nbsp;</td></tr>' + CRLF
	cBody += '      <tr align="left">' + CRLF
	cBody += '       <td width="20%" align="left" valign="top"><img src="logo_cliente_01.png"></td>' + CRLF
	cBody += '     </table>' + CRLF
	cBody += '    </td>' + CRLF
	cBody += '   </tr>' + CRLF
	cBody += '  </table>' + CRLF
	cBody += '  <table>' + CRLF
	cBody += '   <!-- CORPO -->' + CRLF
	cBody += '   <tr>' + CRLF
	cBody += '    <td width="100%">' + CRLF
	cBody += '     <table>' + CRLF
	cBody += '      <tr><td>&nbsp;</td></tr>' + CRLF
	cBody += '      <!-- TEXTO 1 -->' + CRLF
	cBody += '      <tr>' + CRLF
	cBody += '       <td>' + CRLF
	cBody += '        <table>' + CRLF
	cBody += '         <tr><td><b>A/C: Departamento de Cobran&ccedil;a</b></td></tr>' + CRLF
	cBody += '         <tr><td>&nbsp;</td></tr>' + CRLF
	cBody += '         <tr><td>Prezado Fornecedor #FORNECEDOR#, </td></tr>' + CRLF
	cBody += '         <tr><td>Servimo-nos da presente para informá-lo que constam em nosso banco de dados registros de débitos de comissões devidas pelo vosso estabelecimento conforme NF (s) em anexo e reserva (s) abaixo.</td></tr>' + CRLF
	cBody += '         <tr><td>Caso o pagamento tenha sido efetuado, pedimos a vossa gentileza de nos informar enviando o comprovante e a composição das reservas para que realizemos as devidas baixas. Neste caso, nos desculpamos antecipadamente pela inconveniência desta mensagem.</td></tr>' + CRLF
	If MV_PAR06 > 0
		cBody += '         <tr><td>Na hipótese de V.Sa. não ter efetuado o pagamento, informamos que poderemos lhe conceder um desconto de até '
		cBody += Alltrim(Str(MV_PAR06)) + '% do débito caso a quitação se dê até #DATADESCONTO#.</td></tr>' + CRLF
	Endif
	cBody += '        </table>' + CRLF
	cBody += '        <tr><td>&nbsp;</td></tr>' + CRLF
	cBody += '        <tr><td align="left"><font size="4"><b>Dados para depósito</b></font></td></tr>' + CRLF
	If     cEmpAnt = "01"
		//	ALATUR
		cBody += '        <table>' + CRLF
		cBody += '         <tr><td align="center"><font size="4"><b>Alatur JTB Viagens e Turismo LTDA</b></font></td></tr>' + CRLF
		cBody += '         <tr><td><b>CNPJ: 15.279.665/0001-53</b> </td></tr>' + CRLF
		cBody += '         <tr><td><b>Banco: SANTANDER</b> </td></tr>' + CRLF
		cBody += '         <tr><td><b>Ag&ecirc;ncia: 0319</b> </td></tr>' + CRLF
		cBody += '         <tr><td><b>Conta: 13-008248 - 9</b> </td></tr>' + CRLF
		cBody += '        <table>' + CRLF
	Elseif cEmpAnt = "03"
		//	BSP
		cBody += '        <table>' + CRLF
		cBody += '         <tr><td align="center"><font size="4"><b>BSP Assoc. Viagens e Turismo Ltda</b></font></td></tr>' + CRLF
		cBody += '         <tr><td><b>CNPJ: 15.279.665/0001-53</b> </td></tr>' + CRLF
		cBody += '         <tr><td><b>Banco: Itaú</b> </td></tr>' + CRLF
		cBody += '         <tr><td><b>Ag&ecirc;ncia: 0445-1</b> </td></tr>' + CRLF
		cBody += '         <tr><td><b>Conta: 78895–3</b> </td></tr>' + CRLF
		cBody += '        <table>' + CRLF
	Endif
	cBody += '       </td>' + CRLF
	cBody += '      </tr>' + CRLF
	cBody += '      <!-- ITENS DE VENDA -->' + CRLF
	cBody += '      <tr>' + CRLF
	cBody += '       <td width="100%">' + CRLF
	cBody += '        <table width="100%" style="border:2px; border-style: solid; ">' + CRLF
	cBody += '         <tr bgcolor="#076881">' + CRLF
	cBody += '          <td width="15%" align="center"><font color="#FFFFFF" size="2px">APU             </font></td>' + CRLF
	cBody += '          <td width="10%" align="center"><font color="#FFFFFF" size="2px">NF              </font></td>' + CRLF
	cBody += '          <td width="10%" align="center"><font color="#FFFFFF" size="2px">Vencimento      </font></td>' + CRLF
	cBody += '          <td width="10%" align="center"><font color="#FFFFFF" size="2px">Valor           </font></td>' + CRLF
	cBody += '          <td width="10%" align="center"><font color="#FFFFFF" size="2px">Hospede         </font></td>' + CRLF
	cBody += '          <td width="10%" align="center"><font color="#FFFFFF" size="2px">Voucher         </font></td>' + CRLF
	cBody += '          <td width="10%" align="center"><font color="#FFFFFF" size="2px">Confirma&ccedil;&atilde;o  </font></td>' + CRLF
	cBody += '          <td width="08%" align="center"><font color="#FFFFFF" size="2px">Check IN        </font></td>' + CRLF
	cBody += '          <td width="08%" align="center"><font color="#FFFFFF" size="2px">Check OUT       </font></td>' + CRLF
	cBody += '          <td width="10%" align="center"><font color="#FFFFFF" size="2px">Valor Confirmado</font></td>' + CRLF
	cBody += '         </tr>' + CRLF
	cBody += '         #ITENS_DE_VENDA#
	cBody += '        </table>' + CRLF
	cBody += '       </td>' + CRLF
	cBody += '      </tr>' + CRLF
	cBody += '      <!-- TEXTO 2 -->' + CRLF
	cBody += '      <tr>' + CRLF
	cBody += '       <td>' + CRLF
	cBody += '        <table>' + CRLF
	cBody += '         <tr><td>Sem mais e no aguardo das vossas providências.</td></tr>' + CRLF
	cBody += '        </table>' + CRLF
	cBody += '       </td>' + CRLF
	cBody += '      </tr>' + CRLF
	cBody += '     </table>' + CRLF
	cBody += '    </td>' + CRLF
	cBody += '   </tr>' + CRLF
	cBody += '  </table>' + CRLF
	cBody += ' </body>' + CRLF
	cBody += '</html>' + CRLF

Return(cBody)


//=================================================================================================
// Baixa do FTP A cópia da Danfe
Static Function FTP_PDF()

	Local cFTPserv := SuperGetMV("AL_FTPFEND" ,, "187.94.58.20")	//	"ftpdtc.totvs.com.br" tem que ser IP
	Local nFTPport := SuperGetMV("AL_FTPFPOR" ,, 21)
	Local cFTPUser := SuperGetMV("AL_FTPFUSER",, "qbsnct_p12_r6_rps")
	Local cFTPPass := SuperGetMV("AL_FTPFSENH",, "tC5PdCSICh")
	Local cDirPDF  := GetEnv("TEMP")
	Local cAnexo   := Alltrim(MAILTO->F2_NFELETR) + ".pdf"
	Local cPathFTP := cFTPserv + "/" + cFTPUser + "/" + Alltrim(MAILTO->E1_NUM) + "/" + Alltrim(MAILTO->E1_FILIAL)
	Local oFtp     := tFtpClient():New()

	If oFtp:FtpConnect(cFTPserv, nFTPport, cFTPUser, cFTPPass) == 0
		If oFtp:ReceiveFile(cPathFTP + "/" + cAnexo, cDirPDF + "\" + cAnexo)
			ConOut("ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - " + cAnexo + " copiado com sucesso para o FTP !")
			cAnexo := cDirPDF + "\" + cAnexo
		Else
			Conout("ENVFURCOM: " + Dtos(Date()) + " - " + Time() + " - Não foi possivel copiar o arquivo: " + cAnexo + " do FTP: " + cPathFTP)
			cAnexo := ""
		EndIf
	Else
		cAnexo := ""
	Endif
	oFtp:Close()

Return(cAnexo)


//=================================================================================================
// Cria Parametros do filtro
Static Function AJUSTA_SX1(cPerg)

	Local aPerg := {}
	Local nLin := nCol := 0

	// Cabeçalho do SX1
	aAdd(aPerg, {"X1_ORDEM", "X1_PERGUNT"        , "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO"     , "X1_GSC", "X1_F3", "X1_VAR01", "X1_DEF01"    , "X1_DEF02", "X1_DEF03"})

	// Itens
	aAdd(aPerg, {"01"      , "Fornecedor De"     , "MV_CH1"    , "C"      , Len(SA1->A1_COD) , "G"     , "SA1"  , "MV_PAR01", ""            , ""        ,           })
	aAdd(aPerg, {"02"      , "Loja De"           , "MV_CH2"    , "C"      , Len(SA1->A1_LOJA), "G"     , ""     , "MV_PAR02", ""            , ""        ,           })
	aAdd(aPerg, {"03"      , "Fornecedor Até"    , "MV_CH3"    , "C"      , Len(SA1->A1_COD) , "G"     , "SA1"  , "MV_PAR03", "ZZZZZZZZ"    , ""        ,           })
	aAdd(aPerg, {"04"      , "Loja Até"          , "MV_CH4"    , "C"      , Len(SA1->A1_LOJA), "G"     , ""     , "MV_PAR04", "ZZZZ"        , ""        ,           })
	aAdd(aPerg, {"05"      , "Dias de Atraso"    , "MV_CH5"    , "N"      ,                 3, "G"     , ""     , "MV_PAR05", "365"         , ""        ,           })
	aAdd(aPerg, {"06"      , "% do Desconto"     , "MV_CH6"    , "N"      ,                 2, "G"     , ""     , "MV_PAR06", "40"          , ""        ,           })
	aAdd(aPerg, {"07"      , "Desconto Até"      , "MV_CH7"    , "D"      ,                 8, "G"     , ""     , "MV_PAR07", "dDataBase+30", ""        ,           })
	aAdd(aPerg, {"08"      , "Enviar para quem"  , "MV_CH8"    , "N"      ,                 1, "C"     , ""     , "MV_PAR08", "Fornecedor"  , "Operador", "Ambos"   })
	aAdd(aPerg, {"09"      , "Incluir Cópia para", "MV_CH9"    , "C"      ,                60, "G"     , ""     , "MV_PAR09", ""            , ""        ,           })

	// Cria Perguntas
	cPerg := PadR(cPerg, Len(SX1->X1_GRUPO))
	SX1->(dbSetOrder(1))
	For nLin := 2 To Len(aPerg)
		If !SX1->(dbSeek(cPerg + aPerg[nLin, 1]))
			SX1->(Reclock("SX1", .T.))
			SX1->X1_GRUPO := cPerg
			For nCol := 1 To Len(aPerg[1])
				SX1->(FieldPut(FieldPos(aPerg[1, nCol]), aPerg[nLin, nCol]))
			Next
			SX1->(MsUnlock())
		Endif
	Next

Return
