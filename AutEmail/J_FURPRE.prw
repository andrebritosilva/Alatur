#include "fivewin.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TURR012.CH'
#INCLUDE 'TURR013.CH'

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥J_FURPRE  ∫Autor  ≥MARCELO - ETHOSX    ∫DATA  ≥  12/12/19   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥Programa para receber dados do e-mail e grava-los em uma    ∫±±
±±∫          ≥tabela para que posteriormente sejam enviados por um JOB.   ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function J_FURPRE()

	Local _cQuery		:= ""

	Local _ni			:= 0
	Local nDias			:= 0
	Local nDiaPrev		:= 0
	Local cFilE1		:= ""

	Local cServer		:= ""
	Local cAccount		:= ""
	Local cPass			:= ""
	Local cFrom			:= ""
	Local cTo			:= ""
	Local cCc			:= ""
	Local cBcc			:= ""
	Local cBody			:= ""
	Local lText			:= .T.
	
	Local _aUpResul		:= {}
	Local lAuto			:= .T.
	Local lNotific		:= .T.
	Local lEnvPad		:= .F.
	
	Private cPathRps	:= ""
	
	Private dAuxDat		:= Ctod("  /  /    ")
	Private dAuxPre		:= Ctod("  /  /    ")
	Private cSubject	:= ""
	Private cPath  		:= ""
	Private cFiles		:= ""
	Private aSenha		:= {}
	
	Private cNomeEmp	:= ""	
	Private cCorpo		:= ""
	Private cChave		:= ""
	Private cNomCli		:= ""
	Private cTipoCli	:= ""
	
	Private aListad1	:={}
	Private aListadm	:={}
	Private aListad7	:={}
	Private cArqPDF		:=""

	Private cFTPserv	:= ""
	Private cFTPUser	:= ""
	Private cFTPPass	:= ""
	Private nFTPport	:= 0
	
	RPCClearEnv()//LIMPA O AMBIENTE
	RPCSetType(3)//DEFINE O AMBIENTE N√O CONSOME LICEN«A
	RPCSetEnv('01','01SP0001',/*cUser*/,/*pass*/,'FIN',,/*aTabelas*/)//PREPARA O AMBIENTE
    
	MakeDir("\CAR_TMP\")
	MakeDir("\CAR_TMP\FUR\")
		
	cPath  		:= "\CAR_TMP\FUR\"
	
	ConOut("J_FURPRE (U_J_FURPRE): " + Dtos(Date()) + " - " + Time() + " - Iniciando Job GravaÁ„o dos E-Mails Furo e Preventivo para Envio")
	
	nDias			:= SuperGetMV("AL_DIAFURO"	, 		, 1)
	nDiaPrev		:= SuperGetMV("AL_DIAPREV"	, 		, 7)
	cAccount		:= SuperGetMv("MV_RELACNT"	, NIL	, "erpp@alatur.com") //erpp@alatur.com //SuperGetMV("AL_CONTEMA", , "marcelo.franca@ethosx.com.br") //Parametro de conta de envio de email para fornecedores 	//ambrosini
	cPass			:= SuperGetMv("MV_RELPSW" 	, NIL	, "456!@vbnm") //456!@vb nm//SuperGetMV("AL_PASSEMA", , "ethosx@2017") //Parametro de senha de email para envio a fornecedores	//ambrosini
	cServer			:= SuperGetMv("MV_RELSERV"	, NIL	, "smtp.office365.com:587") //smtp.office365.com:587
	cFrom			:= SuperGetMv("MV_RELFROM"	, NIL	, "erpp@alatur.com") //erpp@alatur.com	
	cPathRps		:= SuperGetMv("AL_DIRRPS"	, NIL	, "\data\RPS\") //erpp@alatur.com	
	
	//MONTA QUERY DE E-MAIL QUE EST√O ESPERANDO PARA SER ENVIADOS
    
	If Select("FURO") > 0
		DbSelectArea("FURO")
		FURO->(DbCloseArea())
	EndIf

	//QUERY OBTENDO DADOS
	_cQuery := " SELECT SUBSTRING(E1_FILIAL,1,2) AS FILIAL, E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_NUM, E1_PREFIXO, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_VALLIQ, E1_VALOR, E1_VENCTO, E1_VENCREA, E1_XDTPROR ,E1_SALDO, E1_XCOBRA, E1_VENCORI, A1_NOME, A1_EMAIL, A1_CGC , A1_XCLIFOR, A1_XSENDER ,SE1.R_E_C_N_O_ AS RECNO " + CRLF
	_cQuery += " FROM " + RetSqlName("SE1") + " SE1 " + CRLF
	_cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON (E1_CLIENTE = SA1.A1_COD AND E1_LOJA = SA1.A1_LOJA) AND SA1.D_E_L_E_T_ = ' ' " 
	_cQuery += " WHERE " + CRLF
    
    dAuxDat:= dDatabase 
    
	For _ni:= 1 to nDias
	                                 
		dAuxDat:= DataValida(dAuxDat-1,.F.)
	
	Next                                                         

	_cQuery += " E1_VENCREA <=  '" + dtos(dAuxDat) + "' " + CRLF
 	_cQuery += " AND E1_XCOBRA <> 'N' "  + CRLF
 	//_cQuery += " AND E1_CLIENTE = '00529828' "  + CRLF
 	//_cQuery += " AND E1_LOJA = '0001' "  + CRLF
 	
 	_cQuery += " AND E1_SALDO > 0 "  + CRLF
 	_cQuery += " AND E1_PREFIXO IN ('FAT','APU') "  + CRLF
 	_cQuery += " AND E1_TIPO = 'FTC' "  + CRLF
 
	_cQuery += " AND SE1.D_E_L_E_T_ <> '*' " + CRLF
	
	_cQuery += " ORDER BY SUBSTRING(SE1.E1_FILIAL,1,2),SE1.E1_CLIENTE,SE1.E1_LOJA, SE1.E1_VENCREA " + CRLF

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"FURO",.F.,.T.)

	TCSetField("FURO","E1_VENCREA","D",8,0)
	TCSetField("FURO","E1_EMISSAO","D",8,0)	
	TCSetField("FURO","E1_VENCTO","D",8,0)	
	TCSetField("FURO","E1_XDTPROR","D",8,0)	
	TCSetField("FURO","E1_VENCORI","D",8,0)	

	MemoWrite("FUROMAIL.SQL",_cQuery) //grava na system arquivo de query.
	
	FURO->(DbGoTop())

	//Criacao do PREVENTIVO
	
	If Select("PREVE") > 0
		DbSelectArea("PREVE")
		PREVE->(DbCloseArea())
	EndIf

	//QUERY OBTENDO DADOS
	_cQuery := " SELECT SUBSTRING(E1_FILIAL,1,2) AS FILIAL, E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_NUM, E1_PREFIXO, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_VALLIQ, E1_VALOR, E1_VENCTO, E1_VENCREA, E1_XDTPROR, E1_SALDO, E1_XCOBRA, E1_VENCORI, A1_NOME, A1_EMAIL, A1_CGC , A1_XCLIFOR, A1_XSENDER, SE1.R_E_C_N_O_ AS RECNO " + CRLF
	_cQuery += " FROM " + RetSqlName("SE1") + " SE1 " + CRLF
	_cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON (E1_CLIENTE = SA1.A1_COD AND E1_LOJA = SA1.A1_LOJA) AND SA1.D_E_L_E_T_ = ' ' " 
	_cQuery += " WHERE " + CRLF
    
    dAuxPre:= dDatabase
    
	For _ni:= 1 to nDiaPrev
	
		dAuxPre:= DataValida(dAuxPre+1,.T.)
	
	Next

	_cQuery += " E1_VENCREA >=  '" + dtos(dAuxPre) + "' " + CRLF
 	_cQuery += " AND (A1_XMAILPR = 'S' OR A1_XMAILPR = '' ) "  + CRLF
 	_cQuery += " AND E1_SALDO > 0 "  + CRLF
 	_cQuery += " AND E1_PREFIXO IN ('FAT','APU') "  + CRLF
 	_cQuery += " AND E1_TIPO = 'FTC' "  + CRLF
 
	_cQuery += " AND SE1.D_E_L_E_T_ <> '*' " + CRLF
	
	_cQuery += " ORDER BY SUBSTRING(SE1.E1_FILIAL,1,2),SE1.E1_CLIENTE,SE1.E1_LOJA, SE1.E1_VENCREA " + CRLF

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"PREVE",.F.,.T.)

	TCSetField("PREVE","E1_VENCREA"	,"D",8,0)
	TCSetField("PREVE","E1_EMISSAO"	,"D",8,0)	
	TCSetField("PREVE","E1_VENCTO"	,"D",8,0)	
	TCSetField("PREVE","E1_XDTPROR"	,"D",8,0)
	TCSetField("PREVE","E1_VENCORI"	,"D",8,0)	

	MemoWrite("PREVEMAIL.SQL",_cQuery) //grava na system arquivo de query.
	
	PREVE->(DbGoTop())

	If PREVE->(!Eof())
		
		DbSelectArea("PREVE") 
		
		While PREVE->(!Eof())
		
			If !Empty(PREVE->A1_EMAIL)
			
				cTo := AllTrim(PREVE->A1_EMAIL)
				
			Else
			
				cTo := "SEM E-MAIL NOS CADASTROS"
			
			EndIf 

			cAccount		:= AllTrim(PREVE->A1_XSENDER)
			
			If cAccount $ SuperGetMv("AL_ENVMA01" 	, NIL	, "")
				
				aSenha:= SEPARA(SuperGetMv("AL_ENVMA01" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA02" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA02" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA03" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA03" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA04" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA04" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA05" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA05" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA06" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA06" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA07" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA07" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA08" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA08" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA09" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA09" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA10" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA10" 	, NIL	, ""),";",.T.)

			EndIf

			cPass		:= ""//AllTrim(aSenha[2])
			cFrom		:= PREVE->A1_XSENDER
			cNomeEmp	:= AllTrim(SubStr(Upper(SuperGetMV("AL_SUBJECT", ,PREVE->FILIAL , PREVE->FILIAL)),5))
			cSubject	:= "Preventivo " + cNomeEmp + " - Faturas a Vencer - " + PREVE->A1_NOME
            cFilE1		:= PREVE->E1_FILIAL 
            cChave		:= AllTrim(PREVE->E1_CLIENTE) + " - " + AllTrim(PREVE->E1_LOJA) + " - CLIENTE " + PREVE->A1_NOME
			cNomCli		:= PREVE->A1_NOME
			cTipoCli	:= PREVE->A1_XCLIFOR
			Listad7()
			cBody   	:= MontaPrev()    
			
			EMAILPA(cServer,cAccount,cPass,cFrom,cTo,cCc,cBcc,cSubject,cBody,SubStr(cFiles,1,Len(cFiles)-1),lText,lAuto, lNotific, lEnvPad,cFilE1,cCorpo, cChave)

		EndDo
		
	Else
	
		Conout("J_FURPRE (U_J_FURPRE): " + Dtos(Date()) + " - " + Time() + " - " + "N„o tem dados PREVENTIVO para ser enviado")
	
	Endif
	
	If FURO->(!Eof())
		
		DbSelectArea("FURO") 
		
		While FURO->(!Eof())
		
			iF !Empty(FURO->A1_EMAIL)
			
				cTo := AllTrim(FURO->A1_EMAIL)
				
			Else
			
				cTo := "SEM E-MAIL NOS CADASTROS"
			
			EndIf 
            
			cAccount		:= AllTrim(FURO->A1_XSENDER)

			If cAccount $ SuperGetMv("AL_ENVMA01" 	, NIL	, "")
				
				aSenha:= SEPARA(SuperGetMv("AL_ENVMA01" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA02" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA02" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA03" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA03" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA04" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA04" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA05" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA05" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA06" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA06" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA07" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA07" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA08" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA08" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA09" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA09" 	, NIL	, ""),";",.T.)

			ElseIf cAccount $ SuperGetMv("AL_ENVMA10" 	, NIL	, "")

				aSenha:= SEPARA(SuperGetMv("AL_ENVMA10" 	, NIL	, ""),";",.T.)

			EndIf

			cPass		:= ""//AllTrim(aSenha[2])
			cFrom		:= FURO->A1_XSENDER
			cNomeEmp	:= AllTrim(SubStr(Upper(SuperGetMV("AL_SUBJECT", ,FURO->FILIAL , FURO->FILIAL)),5))
			cSubject	:= "RegularizaÁ„o de Pagamentos Em Atraso - " + cNomeEmp + " - " + FURO->A1_NOME
            cFilE1		:= FURO->E1_FILIAL 
            cChave		:= AllTrim(FURO->E1_CLIENTE) + " - " + AllTrim(FURO->E1_LOJA) + " - CLIENTE " + FURO->A1_NOME
            cNomCli		:= FURO->A1_NOME
            cTipoCli	:= FURO->A1_XCLIFOR
			Listad1()
			
			If Len(aListad1) > 0
				
				cBody   	:= MontaBody()
				EMAILPA(cServer,cAccount,cPass,cFrom,cTo,cCc,cBcc,cSubject,cBody,SubStr(cFiles,1,Len(cFiles)-1),lText,lAuto, lNotific, .T.,cFilE1,cCorpo, cChave)
				
			EndIf

		EndDo
		
	Else
	
		Conout("J_FURPRE (U_J_FURPRE): " + Dtos(Date()) + " - " + Time() + " - " + "N„o tem dados FURO para ser enviado")
	
	Endif

	If Select("FURO") > 0
		DbSelectArea("FURO")
		FURO->(DbCloseArea())
	EndIf
	
    
	If Select("PREVE") > 0
		DbSelectArea("PREVE")
		PREVE->(DbCloseArea())
	EndIf
    
	ConOut("J_FURPRE (U_J_FURPRE): " + Dtos(Date()) + " - " + Time() + " - FINALIZANDO JOB DE GRAVA«√O DE E-MAIL DE FUROS E PREVENTIVO.")

	RpcClearEnv()

Return()


Static Function MontaXML()

	Local cRet			:= ""         
	Local aRetDir		:= {}
	
       
	If FURO->A1_XCLIFOR == "C"
		
		TURFAT(FURO->E1_FILIAL,FURO->E1_CLIENTE,FURO->E1_LOJA,FURO->E1_PREFIXO,FURO->E1_NUM,"2",.F.,.T.,cPath,.T.)
		cRet:= cpath + StrTran(cArqPDF,".PD_",".PDF") + ";"
			
	ElseIf FURO->A1_XCLIFOR == "F"
		        
		aRetDir := Directory(cPathRps + FURO->E1_NUM + "\" + FURO->E1_FILIAL + "\*.PDF")
		
		If Len(aRetDir) > 0
			
			cRet:= cPathRps + FURO->E1_NUM + "\" + FURO->E1_FILIAL + "\" + AllTrim(aRetDir[1][1]) + ";"
							
		EndIf
			
	EndIf
	
Return(cRet)	 			


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
	Local cDiasVen	:= AllTrim(Str(SuperGetMV("AL_DIAFURO", , "2")))
    //Local cFrase	:= AllTrim(SuperGetMV("AL_FIMMAIL", , "")) //Frase editavel para incluir no fim do e-mail

	Local cBody		:= ""			//Texto da Mensagem
	Local _i		:= 1

	cBody    := '<html>'
	cBody    += '<head>'
	cBody    += '  <meta content="text/html; charset=ISO-8859-1 http-equiv="content-type">'
	cBody    += '  <title>Titulos Receber ALATUR</title>'
	cBody    += '  <meta content="ALATUR" name="author">'
	cBody    += '</head>'
	cBody    += '<body style="color: rgb(0, 0, 0); background-color: rgb(168, 168, 168); alink="#000099" link="#000099" vlink="#990099">'
	cBody    += 	'<div style="text-align: left;">'

	If cTipoCli == "C"

		cBody    += 		'Prezado Cliente, ' + AllTrim(cNomCli) + '. <br>' 
		cCorpo   := 		'Prezado Cliente, ' + AllTrim(cNomCli) + '.' +  CRLF

	Else

		cBody    += 		'Prezado Fornecedor, ' + AllTrim(cNomCli) + '. <br>' 
		cCorpo   := 		'Prezado Fornecedor, ' + AllTrim(cNomCli) + '.' +  CRLF

	EndIf
    
	If Len(aListad1) > 0

		cBody    += 		'<br> Segue para conhecimento e provid&ecirc;ncias de pagamento a rela&ccedil;&atilde;o de faturas vencidas em D-' + CdIASvEN + '. <br>'
		cCorpo   += 		CRLF + 'Segue para conhecimento e providÍncias de pagamento a relaÁ„o de faturas vencidas em D-' + CdIASvEN + '.'  + CRLF

		cBody    += 		'Por gentileza responder a este e-mail informando a data de pagamento em at&eacute; dois dias &uacute;teis para regulariza&ccedil;&atilde;o do vencimento em nosso sistema. <br>'
		cCorpo   += 		'Por gentileza responder a este e-mail informando a data de pagamento em atÈ dois dias ˙teis para regularizaÁ„o do vencimento em nosso sistema.'  + CRLF

		If cTipoCli == "C"

			cBody    += 		'Caso o(s) t&iacute;tulo(s) tenha(m) sido liquidado(s), favor nos encaminhar o(s) comprovante(s) de pagamento para a(s) devida(s) baixa(s). <br> <br>'
			cCorpo   += 		'Caso o(s) tÌtulo(s) tenha(m) sido liquidado(s), favor nos encaminhar o(s) comprovante(s) de pagamento para a(s) devida(s) baixa(s).'  + CRLF + CRLF  
			
		Else

			cBody    += 		'Caso o(s) t&iacute;tulo(s) tenha(m) sido liquidado(s), favor nos encaminhar o(s) comprovante(s) de pagamento e a composi&ccedil;&atilde;o de cada comprovante para a(s) devida(s) baixa(s). <br> <br>'
			cCorpo   += 		'Caso o(s) tÌtulo(s) tenha(m) sido liquidado(s), favor nos encaminhar o(s) comprovante(s) de pagamento e a composiÁ„o de cada comprovante para a(s) devida(s) baixa(s).'  + CRLF + CRLF  
		
		EndIf
			
		cBody    += '     <table style="width: 728px; height: 244px; text-align: left; margin-left: auto; margin-right: auto;" border="0" cellpadding="0" cellspacing="0">'
		cBody    += '        <tbody>'
		cBody    += '          <tr bgcolor="#ffffff">'
		cBody    += '            <td class="formulario2"><table width="100%" border="1" cellspacing="1" cellpadding="1">'
		cBody    += ' 		      <tr>'
		cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Rela&ccedil;&atilde;o de Faturas</span></th>'
		cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Valor</span></th>'
		cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Vencimento Original</span></th>'
		cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Vencimento Prorrogado</span></th>'
		cBody    += '             </tr>'
		
		For _i := 1 to Len(aListad1)
			
			cBody += '	 	  <tr>'
		
			cCorpo   += 	AllTrim(aListad1[_i,1]) + " - " + AllTrim(aListad1[_i,2]) + " - " + AllTrim(aListad1[_i,3]) + " - " + AllTrim(aListad1[_i,4]) + CRLF 
		
			cBody += '			<td width="25%"><div align="center">' 	+ aListad1[_i,1] + '</div></td>' //Relacao de Faturas
			cBody += '			<td width="25%"><div align="center">' 	+ aListad1[_i,2] + '</div></td>' //Valor
			cBody += '		 	<td width="25%"><div align="center">' 	+ aListad1[_i,3] + '</div></td>' //Vencimento Original
			cBody += '		 	<td width="25%"><div align="center">'  	+ aListad1[_i,4] + '</div></td>' //Vencimento Prorrogado
			cBody += '	   	 </tr>'
		
		Next
		
		cBody    += '          </table></td>'
		cBody    += '          </tr>'
		cBody    += '        </tbody>'
		cBody    += '      </table>'
		
		If Len(aListadm) > 0
	
			cBody    += 		'<br> Aproveitamos o ensejo para informar que al&eacute;m das faturas supracitadas vencidas em D-' + CdIASvEN + ', constam em nossos controles a rela&ccedil;&atilde;o abaixo de faturas pendentes de pagamento. <br> <br>'
			cCorpo   += 		CRLF + 'Aproveitamos o ensejo para informar que alÈm das faturas supracitadas vencidas em D-' + CdIASvEN + ', constam em nossos controles a relaÁ„o abaixo de faturas pendentes de pagamento.' + CRLF + CRLF
	
			cBody    += '     <table style="width: 728px; height: 244px; text-align: left; margin-left: auto; margin-right: auto;" border="0" cellpadding="0" cellspacing="0">'
			cBody    += '        <tbody>'
			cBody    += '          <tr bgcolor="#ffffff">'
			cBody    += '            <td class="formulario2"><table width="100%" border="1" cellspacing="1" cellpadding="1">'
			cBody    += ' 		      <tr>'
			cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Rela&ccedil;&atilde;o de Faturas</span></th>'
			cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Valor</span></th>'
			cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Vencimento Original</span></th>'
			cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Vencimento Prorrogado</span></th>'
			
			For _i := 1 to Len(aListadm)
				
				cBody += '	 	  <tr>'
			
				cCorpo   += 	AllTrim(aListadm[_i,1]) + " - " + AllTrim(aListadm[_i,2]) + " - " + AllTrim(aListadm[_i,3]) + " - " + AllTrim(aListadm[_i,4]) + CRLF
			
				cBody += '			<td width="25%"><div align="center">' 	+ aListadm[_i,1] + '</div></td>' //Relacao de Faturas
				cBody += '			<td width="25%"><div align="center">' 	+ aListadm[_i,2] + '</div></td>' //Valor
				cBody += '		 	<td width="25%"><div align="center">' 	+ aListadm[_i,3] + '</div></td>' //Vencimento Original
				cBody += '		 	<td width="25%"><div align="center">' 	+ aListadm[_i,4] + '</div></td>' //Vencimento Prorrogado
								
				cBody += '	   	 </tr>'
			
			Next  
			
			cBody    += '          </table></td>'
			cBody    += '          </tr>'
			cBody    += '        </tbody>'
			cBody    += '      </table>'  
	
			If cTipoCli == "C"
	        
				cBody    += 		'<br> Para evitarmos a aplica&ccedil;&atilde;o da Pol&iacute;tica de Faturamento da AJ MOBI, no que tange bloqueio de faturamento, solicitamos a quita&ccedil;&atilde;o imediata das faturas em aberto. <br>'
				cCorpo    += 		CRLF + 'Para evitarmos a aplicaÁ„o da Politica de Faturamento da AJ MOBI, no que tange bloqueio de faturamento, solicitamos a quitaÁ„o imediata das faturas em aberto.' + CRLF
				
			Else
			     
				cBody    += 		'<br> Para evitarmos a&ccedil;&otilde;es de protesto ou bloqueio de vendas solicitamos a quita&ccedil;&atilde;o imediata das faturas em aberto. <br>'
				cCorpo    += 		CRLF + 'Para evitarmos aÁıes de protesto ou bloqueio de vendas solicitamos a quitaÁ„o imediata das faturas em aberto.' + CRLF
			
			EndIf
		
		EndIf		
		
	EndIf

	//cBody    += 		'<br> Qualquer d&uacute;vida, permanecemos ‡ disposi&ccedil;&atilde;o. <br>'
	//cCorpo   += 		CRLF + 'Qualquer d˙vida, permanecemos ‡ disposiÁ„o.' + CRLF
	
	cCorpo   += 		CRLF + 'Esta mensagem pode conter informaÁıes confidenciais e/ou privilegiadas, se vocÍ n„o for o seu destinat·rio, favor comunicar imediatamente ao remetente e destruir todas as informaÁıes e suas cÛpias.' + CRLF
	cCorpo   += 		'This message may contain information which is confidential and/or privileged. If you are not the intended recipient, please advise the sender immediately and destroy it and all copies.' + CRLF
	cBody    += 		'<br>Esta mensagem pode conter informa&ccedil;&otilde;es confidenciais e/ou privilegiadas, se voc&ecirc; n&atilde;o for o seu destinat&aacute;rio, favor comunicar imediatamente ao remetente e destruir todas as informa&ccedil;&otilde;es e suas c&oacute;pias. <br>'
	cBody    += 		'This message may contain information which is confidential and/or privileged. If you are not the intended recipient, please advise the sender immediately and destroy it and all copies. <br>'
	
	cBody    += '      <span style="font-family: Arial Narrow;"></span><span=""></span></td>'
	cBody    += '</div>'
	cBody    += '</body>'
	cBody    += '</html>'
	
Return(cBody)


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MontaPrev ∫Autor  ≥Ambrosini        ∫ Data ≥  29/08/19   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao responsavel por montar o corpo do e-mail             ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

Static Function MontaPrev()

	Local cBody		:= ""			//Texto da Mensagem
	Local cDiasVen	:= AllTrim(Str(SuperGetMV("AL_DIAPREV"	, 		, 7)))
	Local _i		:= 1

	cBody    := '<html>'
	cBody    += '<head>'
	cBody    += '  <meta content="text/html; charset=ISO-8859-1 http-equiv="content-type">'
	cBody    += '  <title>Titulos PAGOS ALATUR</title>'
	cBody    += '  <meta content="ALATUR" name="author">'
	cBody    += '</head>'
	cBody    += '<body style="color: rgb(0, 0, 0); background-color: rgb(168, 168, 168); alink="#000099" link="#000099" vlink="#990099">'
	cBody    += 	'<div style="text-align: left;">'
	
	If cTipoCli == "C"

		cBody    += 		'Prezado Cliente, <br>'   
		cCorpo   := 		'Prezado Cliente, ' +  CRLF
	
	Else

		cBody    += 		'Prezado Fornecedor, <br>' 
		cCorpo   := 		'Prezado Fornecedor, ' +  CRLF
	
	EndIf
	
	
	If Len(aListad7) > 0

		cBody    += 		'<br> Segue para conhecimento rela&ccedil;&atilde;o de faturas &agrave; vencer nos pr&oacute;ximos ' + AllTrim(cDiasVen) + ' dias, favor responder a este e-mail com a confirma&ccedil;&atilde;o de recebimento das mesmas, garantindo a efetiva&ccedil;&atilde;o do pagamento no vencimento mencionado abaixo. <br> <br>'
		cCorpo   += 		CRLF + 'Segue para conhecimento relac„o de faturas ‡ vencer nos prÛximos ' + AllTrim(cDiasVen) + ' dias, favor responder a este e-mail com a confirmaÁ„o de recebimento das mesmas, garantindo a efetivaÁ„o do pagamento no vencimento mencionado abaixo.' + CRLF  + CRLF

		cBody    += '     <table style="width: 728px; height: 244px; text-align: left; margin-left: auto; margin-right: auto;" border="0" cellpadding="0" cellspacing="0">'
		cBody    += '        <tbody>'
		cBody    += '          <tr bgcolor="#ffffff">'
		cBody    += '            <td class="formulario2"><table width="100%" border="1" cellspacing="1" cellpadding="1">'
		cBody    += ' 		      <tr>'
		cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Rela&ccedil;&atilde;o de Faturas</span></th>'
		cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Valor</span></th>'
		cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Vencimento Original</span></th>'
		cBody    += '             <th width="25%" bgcolor="#999999" scope="col"><span class="style4">Vencimento Prorrogado</span></th>'
		cBody    += '             </tr>'
		
		For _i := 1 to Len(aListad7)
			
			cBody += '	 	  <tr>'
		
			cCorpo   += 	AllTrim(aListad7[_i,1]) + ' - ' + AllTrim(aListad7[_i,2]) + ' - ' + AllTrim(aListad7[_i,3]) + ' - ' + AllTrim(aListad7[_i,4]) + CRLF
		
			cBody += '			<td width="25%"><div align="center">' 	+ aListad7[_i,1] + '</div></td>' //Fatura
			cBody += '			<td width="25%"><div align="center">' 	+ aListad7[_i,2] + '</div></td>' //Valor
			cBody += '		 	<td width="25%"><div align="center">' 	+ aListad7[_i,3] + '</div></td>' //Vencimento Original
			cBody += '		 	<td width="25%"><div align="center">' 	+ aListad7[_i,4] + '</div></td>' //Vencimento Prorrogado
			cBody += '	   	 </tr>'
		
		Next
		
		cBody    += '          </table></td>'
		cBody    += '          </tr>'
		cBody    += '        </tbody>'
		cBody    += '      </table>'
		
	EndIf

	cCorpo   += 		CRLF + 'Ficamos ‡ disposiÁ„o para qualquer informaÁ„o adicional.' + CRLF
	cBody    += 		'<br>Ficamos &agrave; disposi&ccedil;&atilde; para qualquer informa&ccedil;&atilde;o adicional. <br>'
	
	cCorpo   += 		CRLF + 'Esta mensagem pode conter informaÁıes confidenciais e/ou privilegiadas, se vocÍ n„o for o seu destinat·rio, favor comunicar imediatamente ao remetente e destruir todas as informaÁıes e suas cÛpias.' + CRLF
	cCorpo   += 		'This message may contain information which is confidential and/or privileged. If you are not the intended recipient, please advise the sender immediately and destroy it and all copies.' + CRLF
	cBody    += 		'<br>Esta mensagem pode conter informa&ccedil;&otilde;es confidenciais e/ou privilegiadas, se voc&ecirc; n&atilde;o for o seu destinat&aacute;rio, favor comunicar imediatamente ao remetente e destruir todas as informa&ccedil;&otilde;es e suas c&oacute;pias. <br>'
	cBody    += 		'This message may contain information which is confidential and/or privileged. If you are not the intended recipient, please advise the sender immediately and destroy it and all copies. <br>'
	
	cBody    += '      <span style="font-family: Arial Narrow;"></span><span=""></span></td>'
	cBody    += '</div>'
	cBody    += '</body>'
	cBody    += '</html>'                  
	                                          
Return(cBody)


Static Function EMAILPA(cServer,cAccount,cPass,cFrom,cTo,cCc,cBcc,cSubject,cBody,cFiles,lText,lAuto, lNotific, lEnvPad, cFilE1, cCorpo, cChave)

	Default lAuto		:= .T.
	Default lNotific	:= .T.
	Default lEnvPad		:= .F.     
	
	/*IF Empty(cServer) .Or. Empty(cAccount) .Or. Empty(cPass) .Or. Empty(cFrom) //.Or. Empty(cTo)
		ConOut("J_FURPRE (U_J_FURPRE): " + Dtos(Date()) + " - " + Time() + " - SEM INFORMA«√O PARA ENVIO DE E-MAIL - CSERVER - CACCOUNT - CPASS - CFROM.")
		Return()
	Endif*/
	
	DbSelectArea("SZM")
	
	RecLock("SZM",.T.)
	
	SZM->ZM_FILIAL	:=	cFilE1
	SZM->ZM_SERVER	:=	cServer
	SZM->ZM_ACCOUNT	:=	cAccount
	SZM->ZM_PASS	:=	cPass
	SZM->ZM_FROM	:=	cFrom
	SZM->ZM_TO		:=	ClearMail(cTo)
	SZM->ZM_CC		:=	ClearMail(cCc)
	SZM->ZM_BCC		:=	"CAR"
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

Static Function Listad1() 

Local _cCodCli 		:= FURO->FILIAL + FURO->E1_CLIENTE + FURO->E1_LOJA

aListad1:= {}
aListadm:= {}
cFiles:= ""        
nAnexo:= 0

While FURO->(!Eof()) .and. _cCodCli == FURO->FILIAL + FURO->E1_CLIENTE + FURO->E1_LOJA .And. nAnexo <= 2

	If Dtos(FURO->E1_VENCREA) == dtos(dAuxDat) 
	
		//AADD(aListad1,{FURO->E1_FILIAL, FURO->E1_PREFIXO, FURO->E1_NUM,Transform(FURO->E1_SALDO,"@E 999,999,999.99") })
		AADD(aListad1,{FURO->E1_NUM, Transform(FURO->E1_SALDO,"@E 999,999,999.99"), SubStr(Dtos(FURO->E1_VENCORI),7,2) + "/" + SubStr(Dtos(FURO->E1_VENCORI),5,2) + "/" + SubStr(Dtos(FURO->E1_VENCORI),1,4) ,SubStr(Dtos(FURO->E1_XDTPROR),7,2) + "/" + SubStr(Dtos(FURO->E1_XDTPROR),5,2) + "/" + SubStr(Dtos(FURO->E1_XDTPROR),1,4) } )
		cFiles	:= cFiles + MontaXML()
		nAnexo:= nAnexo + 1
		
	Else
		
		AADD(aListadm,{FURO->E1_NUM, Transform(FURO->E1_SALDO,"@E 999,999,999.99"), SubStr(Dtos(FURO->E1_VENCORI),7,2) + "/" + SubStr(Dtos(FURO->E1_VENCORI),5,2) + "/" + SubStr(Dtos(FURO->E1_VENCORI),1,4)  ,SubStr(Dtos(FURO->E1_XDTPROR),7,2) + "/" + SubStr(Dtos(FURO->E1_XDTPROR),5,2) + "/" + SubStr(Dtos(FURO->E1_XDTPROR),1,4) } )
	
	Endif
	
	FURO->(DbSkip())

End

Return

Static Function Listad7()

Local _cCodCli 		:= PREVE->FILIAL + PREVE->E1_CLIENTE + PREVE->E1_LOJA

aListad7:= {}
cFiles:= ""

While PREVE->(!Eof()) .and. _cCodCli == PREVE->FILIAL + PREVE->E1_CLIENTE + PREVE->E1_LOJA

	AADD(aListad7,{PREVE->E1_NUM	,Transform(PREVE->E1_SALDO,"@E 999,999,999.99")	, SubStr(Dtos(PREVE->E1_VENCORI),7,2) + "/" + SubStr(Dtos(PREVE->E1_VENCORI),5,2) + "/" + SubStr(Dtos(PREVE->E1_VENCORI),1,4), SubStr(Dtos(PREVE->E1_XDTPROR),7,2) + "/" + SubStr(Dtos(PREVE->E1_XDTPROR),5,2) + "/" + SubStr(Dtos(PREVE->E1_XDTPROR),1,4)})
	PREVE->(DbSkip())

End

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURR012
FunÁ„o para impress„o de Fatura
@author    Cleyton
@version   1.00
@since     01/05/2016
/*/
//------------------------------------------------------------------------------------------

Static Function TURFAT(cxFilial,cCliPDF,cLojaPDF,cPrefixo,cFatura,cTipoImp,lViewPDF,lAuto,cDirPDF,lReimp)

Local lTURR12BL  := ExistBlock("TURRELFT")

Default cCliPDF   := ""
Default cLojaPDF  := ""
Default cPrefixo  := ""
Default cFatura   := "" 
Default lViewPDF  := .F.
Default cDirPDF   := ""
Default lAuto     := .F.
Default cTipoImp  := "2"
Default lReimp    := .T.	// .T. - fatura est· sendo reimpressa via menu / .F. - fatura est· sendo impressa pela geraÁ„o de fatura

If lTURR12BL
	ExecBlock("TURRELFT",.f.,.f.,{cCliPDF,cLojaPDF,cPrefixo,cFatura,lViewPDF,@cDirPDF,lAuto,cTipoImp})
Else
	TURRFTPRT(cxFilial,cCliPDF,cLojaPDF,cPrefixo,cFatura,lViewPDF,@cDirPDF,lAuto,cTipoImp,lReimp) 
EndIf																							  

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURRFTPRT
FunÁ„o para impress„o de Fatura
@author    Cleyton
@version   1.00
@since     01/05/2016
/*/
//------------------------------------------------------------------------------------------
Static Function TURRFTPRT(cxFilial,cCliPDF,cLojaPDF,cPrefixo,cFatura,lViewPDF,cDirPDF,lAuto,cTipoImp,lReimp)

Local oPrint
Local cPerg        := "TURR012"
Local cAliasQry    := GetNextAlias()
Local cArqREL      := ""
Local cDirSave     := ""
Local cFileNme     := ""
Local cFilePrt     := ""
Local cPathPDF     := ""
Local cPathPrt     := ""
Local cPrinter     := "PDF"
Local cFilFat      := ""
Local nQtdCopy     := 1
Local nDevice      := IMP_PDF
Local nPagina      := 0
Local lDisabeSetup := .T.
Local lAdjToLegacy := .T.
Local nLin         := 0159
Local lFirst       := .T.
Local lTURR12IT    := ExistBlock("TURFATIT")
Local cWhere       := ""
Local cTempDir     := ""//cDirPDF//GetTempPath()
Local cTpFat       := ""
Local cCaminho     := ""

Default cCliPDF    := ""
Default cLojaPDF   := ""
Default cPrefixo   := ""
Default cFatura    := "" 
Default lViewPDF   := .F. 
Default cDirPDF    := ""
Default cTipoImp   := "2" //1=aglutinado;2=separado 

Pergunte(cPerg,.F.)

mv_par01 := cCliPDF
mv_par03 := cCliPDF
	
mv_par02 := cLojaPDF
mv_par04 := cLojaPDF

mv_par05 := cPrefixo
mv_par07 := cPrefixo
	
mv_par06 := cFatura
mv_par08 := cFatura

cWhere		:= '%'+ cWhere +'%'

//Garante a existencia da fatura antes de iniciar a impress„o/geraÁ„o...
BeginSql Alias cAliasQry
	
	SELECT	G84_FILIAL,
			G84_PREFIX,
			G84_NUMFAT,
			G84_CLIENT,
			G84_LOJA,
			G84_TPFAT,
			G84_TOTAL
	FROM %Table:G84% G84
	WHERE	G84_FILIAL =  %Exp:cxFilial%  AND
			G84_CLIENT >= %Exp:MV_PAR01% AND
			G84_LOJA   >= %Exp:MV_PAR02% AND
			G84_CLIENT <= %Exp:MV_PAR03% AND
			G84_LOJA   <= %Exp:MV_PAR04% AND
			G84_PREFIX >= %Exp:MV_PAR05% AND
			G84_PREFIX <= %Exp:MV_PAR07% AND
			G84_NUMFAT >= %Exp:MV_PAR06% AND
			G84_NUMFAT <= %Exp:MV_PAR08% AND
			%Exp:cWhere%
			G84.%NotDel%
	
EndSql

If (cAliasQry)->(EOF()) .and. (cAliasQry)->(BOF())
	ConOut("J_FURPRE (U_J_FURPRE): " + Dtos(Date()) + " - " + Time() + " - " + STR0007 + MV_PAR01 + " - " + MV_PAR02 + " " + MV_PAR03 + " - " + MV_PAR04 + " " + MV_PAR05 + " - " + MV_PAR06, STR0004)	
	Return nil
Endif

(cAliasQry)->(dbGoTop())  

While (cAliasQry)->(!Eof())
	
	If (cAliasQry)->G84_TPFAT != "1" .Or. ((cAliasQry)->G84_TPFAT == "1" .And. (cAliasQry)->G84_TOTAL > 0) 
		cFilFat  := (cAliasQry)->G84_FILIAL
		cCliPDF  := (cAliasQry)->G84_CLIENT
		cLojaPDF := (cAliasQry)->G84_LOJA
		cPrefixo := (cAliasQry)->G84_PREFIX
		cFatura  := (cAliasQry)->G84_NUMFAT
	
		cDirSave := cDirPDF
	
		If cTipoImp == "2" //Separado por cliente+fatura
		
			cArqPDF := Alltrim(cCliPDF) + Alltrim(cLojaPDF)			//cÛd. cliente
			cArqPDF += "_" + alltrim(cPrefixo) + Alltrim(cFatura)	//nro da fatura 
			cArqPDF += "_" + DtoS(dDataBase) + StrTran(Time(),":","") + ".PD_"  //data e hora da geraÁ„o do arquivo	
			
		EndIf
	
		If lFirst 
	
			lFirst := .F.
			oPrint:= FWMsPrinter():New(cArqPDF,IMP_PDF,lAdjToLegacy,cDirSave,lDisabeSetup,,,,,,.F.,lViewPDF,nQtdCopy)
			oPrint:SetResolution(72)
			oPrint:SetPortrait() 
			oPrint:SetPaperSize(DMPAPER_A4)

		EndIf
		
		nPagina++
		
		If lTURR12IT
			oPrint := ExecBlock("TURFATIT",.f.,.f.,{oPrint,cCliPDF,cLojaPDF,cPrefixo,cFatura,nPagina})
		Else
			TURFAT13(@oPrint,@nLin,cCliPDF,cLojaPDF,cPrefixo,cFatura,nPagina,lReimp,cxFilial)
		EndIf
	
		cFilePrt := cDirSave+cArqPDF
		
		If cTipoImp == "2" //Separado por cliente+fatura
	
			FERASE(StrTran(Upper(cFilePrt),".PD_",".PDF"))
			File2Printer( cFilePrt, "PDF" )
			oPrint:CPATHPDF  := cDirSave
			oPrint:Preview()
			nLin      := 0159
			lFirst := .T.
			nPagina := 0
		EndIf
		
		If TR012ChkImp((cAliasQry)->G84_TPFAT)///MV_PAR18 == 2 //Sim
			ShellExecute( "Print", StrTran(Upper(cArqPDF),".PD_",".PDF"), " ", cDirSave, 0 ) 
		EndIf
		
		cTpFat := (cAliasQry)->G84_TPFAT
	EndIf	
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

If ValType(oPrint) == "O"
	
	FreeObj(oPrint)

EndIf

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TR012ChkImp
FunÁ„o para checar se dever· imprimir diretamente na porta da impressora
@author    Fernando Radu Muscalu
@version   1.00
@since     09/11/2016
/*/
//------------------------------------------------------------------------------------------

Static Function TR012ChkImp(cTipoFat)

Local lAuto	:= .f.

Do Case
Case ( cTipoFat == "1" .And. FWIsInCallStack("TURA044V") )	//Faturamento de venda
	lAuto := mv_par18 == 2
Case ( cTipoFat == "2" .And. FWIsInCallStack("TURA044A") )	//Faturamento de apuraÁ„o
	lAuto := .f. //em implementaÁ„o (mv_par14 == 2)
Case ( cTipoFat == "3" .And. FWIsInCallStack("TURA044B") )	//Faturamento de breakage
	lAuto := .f. //em implementaÁ„o (mv_par14 == 2)
Case ( cTipoFat == "4" .And. FWIsInCallStack("TURA044C") )	//Faturamento de credito
	lAuto := .f. //em implementaÁ„o (mv_par16 == 2)
End Case

Return(lAuto)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURR13DET
FunÁ„o para impress„o de Fatura
@author    Cleyton
@version   1.00
@since     01/05/2016
/*/
//------------------------------------------------------------------------------------------
Static Function TURFAT13(oPrint,nLin,cCliPDF,cLojaPDF,cPrefixo,cFatura,nPagina,lReimp,cFilFat)

Local oFont11    := TFontEx():New(oPrint, "Courier", 11, 11, .T., .T., .F.)
Local oFont11N   := TFontEx():New(oPrint, "Arial"  , 11, 11, .T., .T., .F.)
Local oFont14    := TFontEx():New(oPrint, "Courier", 14, 14, .T., .T., .F.)
Local oFont16N   := TFontEx():New(oPrint, "Arial"  , 16, 16, .T., .T., .F.)
Local cAliasEad  := GetNextAlias()
Local cAliasTot  := GetNextAlias()
Local cAliasG8E  := GetNextAlias()
Local cAliasNFS  := ""
Local aTpAgru    := {STR0004,STR0005,STR0006,STR0007}  //"Entidades Adicionais","Solicitantes","Grupo de Produto","Padrao do Cliente"
Local aTitFina   := {}
Local aTitFisc   := {}
Local aTot		 := {}
Local aObs		 := {}
Local aAux		 := {}
Local aAreaSM0	 := {}
Local aTotais    := {0,0,0,0,0,0}
Local cDscEntTot := ""
Local cComple    := ""
Local cTpVen     := ""
Local cCodEad    := ""
Local cEnvio     := ""
Local cEntTot    := ""
Local cCodBar    := ""
Local cG85NumRV  := ""
Local cTotAnt	 := ""
Local cCampo     := ""
Local cOrder	 := ""
Local cObs		 := ""
Local cObsAux    := ""
Local cPefixo    := ""
Local cFilAux    := ""
Local lFirst	 := .T.
Local lTotaliza  := .T.
Local lObsOk     := .F.
Local nTotEad    := 0
Local nX 		 := 0
Local nLenTot    := 0
Local nCount	 := 0
Local nPosIni	 := 1
Local nIndexPre  := 0
Local nTotal	 := 0
Local nI		 := 0
Local nLinIni	 := 0
Local nPgBreak   := oPrint:nPageHeight*0.90 //2300
Local cConinu    := Space(TamSx3("G4C_CONINU")[1])
Local aEmail     := {}
Local nE         := 1
Local nSomaMail  := 0
Local lExistFunc := Findfunction('U_FTBLCFIN')
Local cTpApur	 := '1'
Local cExpG6LG85 := TurExpFil('G6L','G6L','G85','G85')

Private oFont12  := TFontEx():New(oPrint,"Courier",12, 12,.T.,.T.,.F.)
nPagina := 0

G3G->(dbSetOrder(1)) //G3G_FILIAL + G3G_CLIENT + G3G_LOJA + G3G_TIPO + G3G_ITEM
G3Q->(dbSetOrder(1)) //G3Q_FILIAL + G3Q_NUMID + G3Q_IDITEM + G3Q_NUMSEQ + G3Q_CONORI
G3R->(dbSetOrder(1)) //G3R_FILIAL + G3R_NUMID + G3R_IDITEM + G3R_NUMSEQ + G3R_CONORI
G3S->(dbSetOrder(1)) //G3S_FILIAL + G3S_NUMID + G3S_IDITEM + G3S_NUMSEQ + G3S_CODPAX + G3S_CONORI
G3T->(dbSetOrder(1)) //G3T_FILIAL + G3T_NUMID + G3T_IDITEM + G3T_NUMSEQ + G3T_CODPAX + G3T_ID + G3T_CONORI
G3U->(dbSetOrder(1)) //G3U_FILIAL + G3U_NUMID + G3U_IDITEM + G3U_NUMSEQ + G3U_CODPAX + G3U_ID + G3U_CONORI
G3V->(dbSetOrder(1)) //G3V_FILIAL + G3V_NUMID + G3V_IDITEM + G3V_NUMSEQ + G3V_CODPAX + G3V_ID + G3V_CONORI
G3W->(dbSetOrder(1)) //G3W_FILIAL + G3W_NUMID + G3W_IDITEM + G3W_NUMSEQ + G3W_CODPAX + G3W_ID + G3W_CONORI
G3X->(dbSetOrder(1)) //G3X_FILIAL + G3X_NUMID + G3X_IDITEM + G3X_NUMSEQ + G3X_CODPAX + G3X_ID + G3X_CONORI
G3Y->(dbSetOrder(1)) //G3Y_FILIAL + G3Y_NUMID + G3Y_IDITEM + G3Y_NUMSEQ + G3Y_CODPAX + G3Y_ID + G3Y_CONORI
G3Z->(dbSetOrder(1)) //G3Z_FILIAL + G3Z_NUMID + G3Z_IDITEM + G3Z_NUMSEQ + G3Z_CODPAX + G3Z_ID + G3Z_CONORI
G40->(dbSetOrder(1)) //G40_FILIAL + G40_IDITEM + G40_NUMID + G40_NUMSEQ + G40_CODPAX + G40_ID + G40_CONORI
G41->(dbSetOrder(1)) //G41_FILIAL + G41_IDITEM + G41_NUMID + G41_NUMSEQ + G41_CODPAX + G41_ID + G41_CONORI
G42->(dbSetOrder(1)) //G42_FILIAL + G42_NUMID + G42_IDITEM + G42_NUMSEQ + G42_CODPAX + G42_ID + G42_CONORI
G43->(dbSetOrder(1)) //G43_FILIAL + G43_NUMID + G43_IDITEM + G43_NUMSEQ + G43_CODPAX + G43_ID + G43_CONORI
G4L->(dbSetORder(1)) //G4L_FILIAL + G4L_CODIGO
G4M->(dbSetORder(1)) //G4M_FILIAL + G4M_CODIGO
G84->(dbSetOrder(1)) //G84_FILIAL + G84_PREFIX + G84_NUMFAT + G84_CLIENT + G84_LOJA
G8E->(dbSetOrder(1)) //G8E_FILIAL + G8E_SEQUEN + G8E_PREFIX + G8E_NUMFAT + G8E_TIPO + G8E_SERIE + G8E_NUMNF + G8E_IDDOC
SA1->(dbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
SA2->(dbSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
SF2->(dbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
SU5->(dbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
SBM->(dbSetOrder(1)) //BM_FILIAL + BM_GRUPO
G3E->(dbSetOrder(1)) //G3E_FILIAL + G3E_CODIGO
G4E->(dbSetOrder(1)) 

SA1->(dbSeek(xFilial("SA1")+cCliPDF+cLojaPDF))

G84->(dbGoTop())
If G84->(dbSeek(cFilFat+cPrefixo+cFatura))
	
	G4L->(dbSeek(xFilial("G4L")+G84->G84_CMPCLI))
	G4M->(dbSeek(xFilial("G4M")+G4L->G4L_CODIGO))
	
	aEmail  := StrtoKarr(Posicione("G4P",1,xFilial("G4P")+G4L->G4L_CODIGO,"G4P_EMAIL"),";")

	cComple := G84->G84_CMPCLI
	cTpVen  := G84->G84_TPFAT
	
	nLin := TU13CAB(@oPrint,@nPagina,lReimp)

	If Len(aEmail)> 1
		nSomaMail := 45 * Len(aEmail)
	Endif 
	//------------------------------------------------------------------------------------------
	// INFORMA«‘ES DO CLIENTE
	//------------------------------------------------------------------------------------------
	oPrint:Box( nLin, 0060, nLin+460+nSomaMail, 2284 )
	
	
	nLin+=25
	
	//Cliente
	oPrint:Say( nLin+=40, 0080, OEMTOANSI(STR0008)+":"		        			 				,oFont11N:oFont)  //"Nome"
	oPrint:Say( nLin	, 0344, OEMTOANSI(SUBSTR(SA1->A1_NOME,1,44))	        			 					,oFont12:oFont  )
	oPrint:Say( nLin	, 1132, OEMTOANSI(STR0009)+":"		        			 				,oFont11N:oFont)  //"CÛdigo"
	oPrint:Say( nLin	, 1396, OEMTOANSI(AllTrim(cCliPDF)+"-"+AllTrim(cLojaPDF))					,oFont12:oFont  )
	oPrint:Say( nLin+=45, 0080, OEMTOANSI(STR0010)+":"											,oFont11N:oFont)  //"EndereÁo"
	oPrint:Say( nLin	, 0344, OEMTOANSI(SUBSTR(SA1->A1_END,1,44))											,oFont12:oFont  )
	oPrint:Say( nLin	, 1132, OEMTOANSI(STR0011)+":"											,oFont11N:oFont)  //"CEP"
	oPrint:Say( nLin	, 1396, OEMTOANSI(TransForm(SA1->A1_CEP, PesqPict("SA1", "A1_CEP")))	,oFont12:oFont  )
	oPrint:Say( nLin+=45, 0080, OEMTOANSI(STR0012)+":"											,oFont11N:oFont)  //"Complemento"
	oPrint:Say( nLin	, 0344, OEMTOANSI(SA1->A1_COMPLEM)										,oFont12:oFont  )
	oPrint:Say( nLin	, 1132, OEMTOANSI(STR0013)+":"											,oFont11N:oFont)  //"Bairro"
	oPrint:Say( nLin	, 1396, OEMTOANSI(SA1->A1_BAIRRO)										,oFont12:oFont  )
	oPrint:Say( nLin+=45, 0080, OEMTOANSI(STR0014)+":"		        		 					,oFont11N:oFont)  //"Cidade-UF"
	oPrint:Say( nLin	, 0344, OEMTOANSI(AllTrim(SA1->A1_MUN)+"-"+SA1->A1_EST)					,oFont12:oFont  )
	oPrint:Say( nLin	, 1132, OEMTOANSI(STR0015)+":"		        			 				,oFont11N:oFont)  //"Fone"
	oPrint:Say( nLin	, 1396, OEMTOANSI("("+ AllTrim(SA1->A1_DDD) +") " + ALLTRIM(TRANSFORM(SA1->A1_TEL,PesqPict('SA1','A1_TEL'))))    	,oFont12:oFont  )
	oPrint:Say( nLin+=45, 0080, OEMTOANSI(STR0016)+":"											,oFont11N:oFont)  //"CPF/CNPJ"
	oPrint:Say( nLin	, 0344, OEMTOANSI(TransForm(AllTrim(SA1->A1_CGC),PesqPict("SA1", "A1_CGC"))),oFont12:oFont  )
	oPrint:Say( nLin	, 1132, OEMTOANSI(STR0082)+":"								,oFont11N:oFont)  //"Inscr. Estadual"
	oPrint:Say( nLin	, 1396, OEMTOANSI(SA1->A1_INSCR) 										,oFont12:oFont  )
	oPrint:Line(nLin+=50, 0060, nLin, 2286,, )
	//CobranÁa
	oPrint:Say( nLin+=50, 0080, OEMTOANSI(STR0010)+":"										 	,oFont11N:oFont)  //"EndereÁo"
	oPrint:Say( nLin	, 0344, SubStr(Posicione("G4P",1,xFilial("G4P")+G4L->G4L_CODIGO,"G4P_ENDER"),1,44)	,oFont12:oFont  )
	oPrint:Say( nLin	, 1132, OEMTOANSI(STR0011)+":"		        			 				,oFont11N:oFont)  //"CEP"
	oPrint:Say( nLin	, 1396, TransForm(Posicione("G4P",1,xFilial("G4P")+G4L->G4L_CODIGO,"G4P_CEP"), PesqPict("SA1", "A1_CEP"))		,oFont12:oFont  )
	oPrint:Say( nLin+=45, 0080, OEMTOANSI(STR0012)+":"		        	 						,oFont11N:oFont)  //"Complemento"
	oPrint:Say( nLin	, 0344, Posicione("G4P",1,xFilial("G4P")+G4L->G4L_CODIGO,"G4P_COMPL")	,oFont12:oFont  )
	oPrint:Say( nLin	, 1132, OEMTOANSI(STR0013)+":"		        			 				,oFont11N:oFont)  //"Bairro"
	oPrint:Say( nLin	, 1396, Posicione("G4P",1,xFilial("G4P")+G4L->G4L_CODIGO,"G4P_BAIRRO")	,oFont12:oFont  )
	oPrint:Say( nLin+=45, 0080, OEMTOANSI(STR0014)+":"											,oFont11N:oFont)  //"Cidade-UF"
	oPrint:Say( nLin	, 0344, AllTrim(Posicione('G5S', 1, XFilial('G5S')+Posicione("G4P",1,xFilial("G4P")+G4L->G4L_CODIGO,"G4P_MUNIC"), 'G5S_CIDADE'))+"-"+;
							Posicione("G4P",1,xFilial("G4P")+G4L->G4L_CODIGO,"G4P_UF")			,oFont12:oFont  )
	oPrint:Say( nLin	, 1132, OEMTOANSI(STR0020)+":"											,oFont11N:oFont)  //"Email"

	For nE := 1 to Len(aEmail)
		oPrint:Say( nLin	, 1396, aEmail[nE]	,oFont12:oFont  )
		nLin+=45
	Next 
	
	nLin+=5
	
	BeginSQL Alias cAliasG8E
	
		SELECT
			G8E.G8E_FILREF
			,G8E.G8E_TIPOTI
			,G8E.G8E_PFXTIT
			,G8E.G8E_NUMTIT
			,G8E.G8E_PARCEL
			,G8E.G8E_SEQUEN
			,SE1.E1_VALOR
			,SE1.E1_SALDO
			,SE1.E1_VENCREA
			,SE1.E1_PORCJUR
			,(SE1.E1_VALJUR+SE1.E1_ACRESC) ENCARGOS
		FROM
			%Table:G8E% G8E
		INNER JOIN
			%Table:SE1% SE1
		ON
			SE1.E1_FILIAL = G8E.G8E_FILIAL
			AND SE1.E1_PREFIXO = G8E.G8E_PFXTIT
			AND SE1.E1_NUM = G8E.G8E_NUMTIT
			AND SE1.E1_PARCELA = G8E.G8E_PARCEL
			AND SE1.E1_TIPO = G8E.G8E_TIPOTI
			AND SE1.E1_SALDO > 0
			AND SE1.%NotDel% 			
		WHERE	
				G8E.G8E_FILIAL = %Exp:cFilFat%
				AND G8E.G8E_PREFIX = %Exp:cPrefixo%
			AND	G8E.G8E_NUMFAT = %Exp:cFatura%
				AND G8E.G8E_TIPO <> '2'
			AND	G8E.%NotDel%
		ORDER BY 
			G8E.G8E_SEQUEN DESC
	
	EndSQL
	
	(cAliasG8E)->(dbGoTop())
	
	While (cAliasG8E)->(!Eof())
	
		aAdd(aAux, 	(cAliasG8E)->G8E_FILREF)
		aAdd(aAux,	(cAliasG8E)->G8E_PFXTIT )
		aAdd(aAux,	(cAliasG8E)->G8E_NUMTIT )
		aAdd(aAux,	(cAliasG8E)->G8E_PARCEL )
		aAdd(aAux,	(cAliasG8E)->G8E_TIPOTI )
		aAdd(aAux,	Iif( Alltrim((cAliasG8E)->G8E_TIPOTI) == "NCC",(cAliasG8E)->E1_SALDO*(-1),(cAliasG8E)->E1_SALDO)	)
		aAdd(aAux,	SToD((cAliasG8E)->E1_VENCREA)	)
		aAdd(aAux,	(cAliasG8E)->E1_PORCJUR )
		aAdd(aAux,	(cAliasG8E)->ENCARGOS  )
		
		aAdd(aTitFina,aClone(aAux))
		aAux := {}
			
		(cAliasG8E)->(DbSkip())
		
	EndDo
	
	(cAliasG8E)->(dbCloseArea())
	
	//------------------------------------------------------------------------------------------
	// INFORMA«‘ES DO FINANCEIRO
	//------------------------------------------------------------------------------------------
	If lExistFunc
		
		nLinIni := nLin
		
		//PONTO DE ENTRADA PARA ALTERAR INFORMA«’ES DO BLOCO DO FINANCEIRO	
		nLin := U_FTBLCFIN(oPrint, aTitFina, nLin)
		
		If ValType(nLin) != "N"
			nLin := nLinIni 
		EndIf
			
	ELSE
		If !Empty(aTitFina)
			
			If ( aScan(aTitFina,{|x| !(Empty(x[3]))}) > 0)
				aSort(aTitFina,,,{|x,y| x[3] < y[3]})
			Endif
			
			nLinIni := nLin
			
				oPrint:Box( nLin, 0060, nLin+75, 2284,, ) 
				nLin+=25
		
				oPrint:Say( nLin+=35, 0080, OEMTOANSI(STR0021)	,oFont11N:oFont)  //"Prefixo"
				oPrint:Say( nLin	, 0400, OEMTOANSI(STR0022)	,oFont11N:oFont)  //"Num. Titulo"
				oPrint:Say( nLin	, 0720, OEMTOANSI(STR0023)	,oFont11N:oFont)  //"Parcela"
				oPrint:Say( nLin	, 0900, OEMTOANSI(STR0024)	,oFont11N:oFont)  //"Valor"
				oPrint:Say( nLin	, 1200, OEMTOANSI(STR0025)	,oFont11N:oFont)  //"Vencimento"
				oPrint:Say( nLin	, 1620, OEMTOANSI(STR0026)	,oFont11N:oFont)  //"Juros(%)"
				oPrint:Say( nLin	, 1950, OEMTOANSI(STR0027)	,oFont11N:oFont)  //"Tx.Perman."
			
				nLin+=15
		
			For nI := 1 to Len(aTitFina)
		
					oPrint:Line(nLin, 0060, nLin+45, 0060,, )
					oPrint:Line(nLin, 2286, nLin+45, 2286,, )
					nLin+=45
			
					oPrint:Say( nLin 	, 0080, OEMTOANSI(aTitFina[nI,2]) 									,oFont12:oFont  )
					oPrint:Say( nLin	, 0400, OEMTOANSI(aTitFina[nI,3]) 									,oFont12:oFont  )
					oPrint:Say( nLin	, 0720, OEMTOANSI(aTitFina[nI,4]) 									,oFont12:oFont  )
					oPrint:Say( nLin	, 0850, Transform(aTitFina[nI,6],"@E 9,999,999.99")	,oFont12:oFont,,,,1  )
					oPrint:Say( nLin	, 1200, OEMTOANSI(Dtoc(aTitFina[nI,7]))							,oFont12:oFont  )
					oPrint:Say( nLin	, 1550, Transform(aTitFina[nI,8],"@E 9,999,999.99") 			,oFont12:oFont,,,,1  )
					oPrint:Say( nLin	, 1900, Transform(aTitFina[nI,9],"@E 9,999,999.99") 			,oFont12:oFont,,,,1  )
			
					If nI == Len(aTitFina)		
						oPrint:Line(nLin, 0060, nLin+25, 0060,, )
						oPrint:Line(nLin, 2286, nLin+25, 2286,, )
						nLin+=25		
						oPrint:Line(nLin, 0060, nLin, 2286,, )
						nLin+=25
					EndIf
		
				
				Next nI
		
		EndIf
	EndIf
	
	//------------------------------------------------------------------------------------------
	// NOTA FISCAL
	//------------------------------------------------------------------------------------------

	If cTpVen == '2' //ApuraÁıes

		cAliasNFS	:= GetNextAlias()
		
		BeginSQL Alias cAliasNFS
		
			SELECT
				G8E.G8E_FILREF
  				,G8E.G8E_NUMNF
  				,G8E.G8E_SERIE
				,G8E.G8E_SEQUEN
				,SF2.F2_EMISSAO
				,SF2.F2_VALMERC
				,SF2.F2_VALIRRF
				,SF2.F2_VALINSS
				,SF2.F2_VALISS
				,SF2.F2_VALICM
				,SF2.F2_VALIPI
				,SF2.F2_VALCSLL
				,SF2.F2_VALPIS
				,SF2.F2_VALCOFI 
				,SF2.F2_VALFAT
			FROM
				%Table:G8E% G8E
			INNER JOIN
				%Table:SF2% SF2
			ON
				SF2.F2_FILIAL = G8E.G8E_FILREF AND
				SF2.F2_SERIE = G8E.G8E_SERIE AND
				SF2.F2_DOC = G8E.G8E_NUMNF AND
				SF2.F2_CLIENTE = G8E.G8E_CLIENT AND
				SF2.F2_LOJA = G8E.G8E_LOJA AND
				SF2.%NotDel% 			
			WHERE	
				G8E.G8E_FILIAL = %Exp:cFilFat% AND
				G8E.G8E_PREFIX = %Exp:cPrefixo% AND
				G8E.G8E_NUMFAT = %Exp:cFatura% AND
				G8E.G8E_TIPO = '2' AND
				G8E.%NotDel%
			ORDER BY 
				G8E.G8E_SEQUEN DESC
		
		EndSQL
		
		(cAliasNFS)->(dbGoTop())
		
		While (cAliasNFS)->(!Eof())
		
			aAdd(aTitFisc,{	(cAliasNFS)->G8E_SERIE  ,; 
								(cAliasNFS)->G8E_NUMNF  ,; 
								SToD((cAliasNFS)->F2_EMISSAO) ,; 
								(cAliasNFS)->F2_VALMERC ,;
								(cAliasNFS)->F2_VALIRRF +;
								(cAliasNFS)->F2_VALINSS +;
								(cAliasNFS)->F2_VALISS  +;
								(cAliasNFS)->F2_VALICM  +;
								(cAliasNFS)->F2_VALIPI  +;
								(cAliasNFS)->F2_VALCSLL +;
								(cAliasNFS)->F2_VALPIS  +;
								(cAliasNFS)->F2_VALCOFI ,; 
								(cAliasNFS)->F2_VALFAT  })
				
			(cAliasNFS)->(DbSkip())
			
		EndDo
		
		(cAliasNFS)->(dbCloseArea())
		
		If !Empty(aTitFisc)
					
			oPrint:Box( nLin, 0060, nLin+75, 2284,, ) 
			nLin+=25
			
			oPrint:Say( nLin+=35, 0080, OEMTOANSI(STR0028)	,oFont11N:oFont ) //"SÈrie"
			oPrint:Say( nLin, 0400, OEMTOANSI(STR0094)		,oFont11N:oFont ) //"RPS"
			oPrint:Say( nLin, 0850, OEMTOANSI(STR0029)	,oFont11N:oFont ) //"Emiss„o"
			oPrint:Say( nLin, 1200, OEMTOANSI(STR0030)	,oFont11N:oFont ) //"Valor ServiÁo"
			oPrint:Say( nLin, 1620, OEMTOANSI(STR0031)	,oFont11N:oFont ) //"Impostos"
			oPrint:Say( nLin, 1950, OEMTOANSI(STR0032)	,oFont11N:oFont ) //"Total da NF"
			nLin+=15
			
			For nx := 1 To Len(aTitFisc)
							
				oPrint:Line(nLin, 0060, nLin+45, 0060,, )
				oPrint:Line(nLin, 2286, nLin+45, 2286,, )
				nLin+=45
				
				oPrint:Say( nLin, 0080, OEMTOANSI(aTitFisc[nx,1]) 				,oFont12:oFont  ) 
				oPrint:Say( nLin, 0400, OEMTOANSI(aTitFisc[nx,2]) 				,oFont12:oFont  ) 
				oPrint:Say( nLin, 0850, OEMTOANSI(DToC(aTitFisc[nx,3])) 		,oFont12:oFont  ) 
				oPrint:Say( nLin, 1200, Transform(aTitFisc[nx,4],"@E 9,999,999.99") 	,oFont12:oFont,,,,1  ) 
				oPrint:Say( nLin, 1550, Transform(aTitFisc[nx,5],"@E 9,999,999.99") 	,oFont12:oFont,,,,1  ) 
				oPrint:Say( nLin, 1900, Transform(aTitFisc[nx,6],"@E 9,999,999.99") 	,oFont12:oFont,,,,1  ) 
				
			
				If nX == Len(aTitFisc)		
					oPrint:Line(nLin, 0060, nLin+25, 0060,, )
					oPrint:Line(nLin, 2286, nLin+25, 2286,, )
					nLin+=25		
					oPrint:Line(nLin, 0060, nLin, 2286,, )
					nLin+=25
				EndIf
			
			Next
		EndIf
	EndIf

	//------------------------------------------------------------------------------------------
	// ENTIDADE TOTALIZADORA
	//------------------------------------------------------------------------------------------
	nTotEad := 0

	//Seleciona o Totalizador cadastrado para o cliente da fatura
	BeginSQL Alias cAliasEad

		SELECT	G67.G67_BASE
				, G67.G67_CODEAD
		FROM	%Table:G67% G67
		WHERE	G67.%NotDel%
		AND		G67_FILIAL = %xFilial:G67%
		AND		G67_CODIGO = %Exp:cComple%
		AND		G67_TIPO   = %Exp:cTpVen%
		AND		G67_TPAGRU = '2'

	EndSQL

	(cAliasEad)->(dbGoTop())

	If (cAliasEad)->(!Eof()) .And. !Empty((cAliasEad)->G67_BASE)
		Do Case
			Case (cAliasEad)->G67_BASE == "1" //1=Entidades Adicionais

				cDscEntTot := AllTrim((Posicione("G3E",1,xFilial("G3E")+(cAliasEad)->G67_CODEAD,"G3E_DESCR")))+": "

			Case (cAliasEad)->G67_BASE == "2" //2=Solicitantes

				cDscEntTot := STR0085 //"Solicitante: "
				cCampo := "SOLIC"

			Case (cAliasEad)->G67_BASE == "3" //3=Grupo de Produto

				cDscEntTot := STR0086 //"Grupo de Produto: "
				cCampo := "GRUPO"

			Case (cAliasEad)->G67_BASE == "4" //4=Filial de Venda

				cDscEntTot := STR0087 //"Filial de Venda: "
				cCampo := "FILREF"

		EndCase
	Else
		lTotaliza := .F.
	EndIf

	If lTotaliza .And.	(cAliasEad)->G67_BASE $ "2|3|4"
		cOrder   += " ORDER BY " + cCampo
	EndIf

	cOrder := '%'+cOrder+'%'

	If G84->G84_TPFAT == '4'
		BeginSql Alias cAliasTot
			SELECT FILREF+REGVEN+ITVEND ITEM
			 		, FILREF
			 		, REGVEN
			 		, ITVEND
			 		, GRUPO
			 		, SOLIC
			 		, MOEDA
			 		, CAMBIO
			 		, TPENT
			 		, ITENT
			 		, SUM(TARIFA) TARIFA
			 		, SUM(TAXA) TAXA
			 		, SUM(TAXAADM) TAXAADM
			 		, SUM(VALOR) TOTAL
			 		, SUM(MULTA) MULTA
			 		, SUM(REPASSE) REPASSE
			FROM (
				SELECT G85.G85_IDIF IDIF
						, G85.G85_FILREF FILREF
						, G85.G85_REGVEN REGVEN
						, G85.G85_ITVEND ITVEND
						, G85.G85_TPENT  TPENT
						, G85.G85_ITENT  ITENT
						, G4C.G4C_MOEDA MOEDA
						, (CASE WHEN (G4C_OPERAC = '2' AND G4C_PAGREC = '2') OR (G4C_OPERAC <> '2' AND G4C_PAGREC = '1') THEN G4C.G4C_TARIFA ELSE G4C.G4C_TARIFA*-1 END) TARIFA
						, (CASE WHEN (G4C_OPERAC = '2' AND G4C_PAGREC = '2') OR (G4C_OPERAC <> '2' AND G4C_PAGREC = '1') THEN G4C.G4C_TXORIG + G4C.G4C_EXTRA ELSE (G4C.G4C_TXORIG + G4C.G4C_EXTRA)*-1  END) TAXA
          				, G4C.G4C_TXCAMB CAMBIO
          				, G4C.G4C_TAXADU TAXAADM
						, (CASE WHEN (G4C_OPERAC = '2' AND G4C_PAGREC = '2') OR (G4C_OPERAC <> '2' AND G4C_PAGREC = '1') THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) VALOR
						, G85.G85_GRPPRD GRUPO
						, G85.G85_SOLIC SOLIC
						, (CASE WHEN (G4C_OPERAC = '2' AND G4C_PAGREC = '2') OR (G4C_OPERAC <> '2' AND G4C_PAGREC = '1') THEN (G4C.G4C_TXRORI + G4C.G4C_EXTRA)*-1 ELSE (G4C.G4C_TXRORI + G4C.G4C_EXTRA) END)MULTA
						, 0 REPASSE
				 FROM %Table:G85% G85
				 INNER JOIN %Table:G4C% G4C
				 ON G4C.G4C_FILREF = G85.G85_FILREF
				 AND G4C.G4C_IDIF = G85.G85_IDIF
				 AND G4C.G4C_NUMID = G85.G85_REGVEN
				 AND G4C.G4C_IDITEM = G85.G85_ITVEND
				 AND G4C.G4C_NUMSEQ = G85.G85_SEQIV
				 AND G4C.G4C_CONINU = %Exp:cConinu%
				 AND G4C.%NotDel%
				 WHERE G85.G85_FILIAL = %Exp:cFilFat%
				 AND G85.G85_PREFIX = %Exp:cPrefixo%
				 AND G85.G85_NUMFAT = %Exp:cFatura%
				 AND G85.G85_ITPRIN = ' '
				 AND G85.G85_CLASS <> 'V01'
				 AND G85.%NotDel%

				 UNION

				 SELECT G85.G85_IDIF IDIF
				 		 , G85.G85_FILREF FILREF
						 , G85.G85_REGVEN REGVEN
						 , G85.G85_ITVEND ITVEND
 						 , G85.G85_TPENT  TPENT
						 , G85.G85_ITENT  ITENT
						 , G4C.G4C_MOEDA MOEDA
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END)  TARIFA
						 , 0 TAXA
						 , G4C.G4C_TXCAMB CAMBIO
						 , 0 TAXAADM
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) VALOR
						 , G85.G85_GRPPRD GRUPO
						 , G85.G85_SOLIC SOLIC
						 , 0 MULTA
						 , 0 REPASSE
				 FROM %Table:G85% G85
				 INNER JOIN %Table:G4C% G4C
				 ON G4C.G4C_FILREF = G85.G85_FILREF
				 AND G4C.G4C_IDIF = G85.G85_IDIF
				 AND G4C.G4C_NUMID = G85.G85_REGVEN
				 AND G4C.G4C_IDITEM = G85.G85_ITVEND
				 AND G4C.G4C_NUMSEQ = G85.G85_SEQIV
				 AND G4C.G4C_CONINU = %Exp:cConinu%
				 AND G4C.%NotDel%
				 WHERE G85.G85_FILIAL = %Exp:cFilFat%
				 AND G85.G85_PREFIX = %Exp:cPrefixo%
				 AND G85.G85_NUMFAT = %Exp:cFatura%
				 AND G85.G85_ITPRIN <> ' '
				 AND G85.G85_CLASS IN ('C08','C09')
				 AND G85.%NotDel%

				 UNION

				 SELECT G85.G85_IDIF IDIF
				 		 , G85.G85_FILREF FILREF
						 , G85.G85_REGVEN REGVEN
						 , G85.G85_ITVEND ITVEND
						 , G85.G85_TPENT  TPENT
						 , G85.G85_ITENT  ITENT
						 , G4C.G4C_MOEDA MOEDA
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) TARIFA
						 , 0 TAXA
						 , G4C.G4C_TXCAMB CAMBIO
						 , 0 TAXAADM
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) VALOR
						 , G85.G85_GRPPRD GRUPO
						 , G85.G85_SOLIC SOLIC
						 , 0 MULTA
						 , 0 REPASSE
				 FROM %Table:G85% G85
				 INNER JOIN %Table:G4C% G4C
				 ON G4C.G4C_FILREF = G85.G85_FILREF
				 AND G4C.G4C_IDIF = G85.G85_IDIF
				 AND G4C.G4C_NUMID = G85.G85_REGVEN
				 AND G4C.G4C_IDITEM = G85.G85_ITVEND
				 AND G4C.G4C_NUMSEQ = G85.G85_SEQIV
				 AND G4C.G4C_CONINU = %Exp:cConinu%
				 AND G4C.%NotDel%
				 WHERE G85.G85_FILIAL = %Exp:cFilFat%
				 AND G85.G85_PREFIX = %Exp:cPrefixo%
				 AND G85.G85_NUMFAT = %Exp:cFatura%
				 AND G85.G85_ITPRIN = ' '
				 AND G85.G85_CLASS = 'V01'
				 AND G85.%NotDel%

				 UNION

				 SELECT G85.G85_IDIF IDIF
				 		 , G85.G85_FILREF FILREF
						 , G85.G85_REGVEN REGVEN
						 , G85.G85_ITVEND ITVEND
						 , G85.G85_TPENT  TPENT
						 , G85.G85_ITENT  ITENT
						 , G4C.G4C_MOEDA MOEDA
						 , 0 TARIFA
						 , 0 TAXA
						 , G4C.G4C_TXCAMB CAMBIO
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) TAXAADM
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) VALOR
						 , G85.G85_GRPPRD GRUPO
						 , G85.G85_SOLIC SOLIC
						 , 0 MULTA
						 , 0 REPASSE
				 FROM %Table:G85% G85
				 INNER JOIN %Table:G4C% G4C
				 ON G4C.G4C_FILREF = G85.G85_FILREF
				 AND G4C.G4C_IDIF = G85.G85_IDIF
				 AND G4C.G4C_NUMID = G85.G85_REGVEN
				 AND G4C.G4C_IDITEM = G85.G85_ITVEND
				 AND G4C.G4C_NUMSEQ = G85.G85_SEQIV
				 AND G4C.G4C_CONINU = %Exp:cConinu%
				 AND G4C.%NotDel%
				 WHERE G85.G85_FILIAL = %Exp:cFilFat%
				 AND G85.G85_PREFIX = %Exp:cPrefixo%
				 AND G85.G85_NUMFAT = %Exp:cFatura%
				 AND G85.G85_ITPRIN <> ' '
				 AND G85.G85_CLASS NOT IN('C09','C08','V01')
				 AND G85.%NotDel%
				 
			 	UNION

				 SELECT G85.G85_IDIF IDIF
				 		 , G85.G85_FILREF FILREF
						 , G85.G85_REGVEN REGVEN
						 , G85.G85_ITVEND ITVEND
						 , G85.G85_TPENT  TPENT
						 , G85.G85_ITENT  ITENT
						 , G4C.G4C_MOEDA MOEDA
						 , 0 TARIFA
						 , 0 TAXA
						 , G4C.G4C_TXCAMB CAMBIO
						 , 0 TAXAADM
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR *-1 ELSE G4C.G4C_VALOR END) VALOR
						 , G85.G85_GRPPRD GRUPO
						 , G85.G85_SOLIC SOLIC
						 , 0 MULTA
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) REPASSE
				 FROM %Table:G85% G85
				 INNER JOIN %Table:G4C% G4C
				 ON G4C.G4C_FILREF = G85.G85_FILREF
				 AND G4C.G4C_IDIF = G85.G85_IDIF
				 AND G4C.G4C_NUMID = G85.G85_REGVEN
				 AND G4C.G4C_IDITEM = G85.G85_ITVEND
				 AND G4C.G4C_NUMSEQ = G85.G85_SEQIV
				 AND G4C.G4C_CONINU = %Exp:cConinu%
				 AND G4C.%NotDel%
				 WHERE G85.G85_FILIAL = %Exp:cFilFat%
				 AND G85.G85_PREFIX = %Exp:cPrefixo%
				 AND G85.G85_NUMFAT = %Exp:cFatura%
				 AND G85.G85_CLASS = 'C07' 
				 AND G85.%NotDel%				 
				 ) TMP
			GROUP BY FILREF, REGVEN, ITVEND, GRUPO, SOLIC, MOEDA, CAMBIO, TPENT, ITENT

			%Exp:cOrder%

		EndSql


	ElseIf G84->G84_TPFAT <> '2'

		BeginSql Alias cAliasTot
			SELECT FILREF+REGVEN+ITVEND ITEM
			 		, FILREF
			 		, REGVEN
			 		, ITVEND
			 		, GRUPO
			 		, SOLIC
			 		, MOEDA
			 		, CAMBIO
			 		, TPENT
			 		, ITENT
			 		, SUM(TARIFA) TARIFA
			 		, SUM(TAXA) TAXA
			 		, SUM(TAXAADM) TAXAADM
			 		, SUM(VALOR) TOTAL
			FROM (
				SELECT G85.G85_IDIF IDIF
						, G85.G85_FILREF FILREF
						, G85.G85_REGVEN REGVEN
						, G85.G85_ITVEND ITVEND
						, G85.G85_TPENT  TPENT
					    , G85.G85_ITENT  ITENT
						, G4C.G4C_MOEDA MOEDA
						, (CASE WHEN (G4C_OPERAC = '2' AND G4C_PAGREC = '1') OR (G4C_OPERAC <> '2' AND G4C_PAGREC = '2') THEN G4C.G4C_TARIFA ELSE G4C.G4C_TARIFA*-1 END) TARIFA
						, (CASE WHEN (G4C_OPERAC = '2' AND G4C_PAGREC = '1') OR (G4C_OPERAC <> '2' AND G4C_PAGREC = '2') THEN G4C.G4C_TAXA + G4C.G4C_EXTRA ELSE (G4C.G4C_TAXA + G4C.G4C_EXTRA)*-1 END )TAXA
						, G4C.G4C_TXCAMB CAMBIO
						, G4C.G4C_TAXADU TAXAADM
						, (CASE WHEN (G4C_OPERAC = '2' AND G4C_PAGREC = '1') OR (G4C_OPERAC <> '2' AND G4C_PAGREC = '2') THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) VALOR
						, G85.G85_GRPPRD GRUPO
						, G85.G85_SOLIC SOLIC
				 FROM %Table:G85% G85
				 INNER JOIN %Table:G4C% G4C
				 ON G4C.G4C_FILREF = G85.G85_FILREF
				 AND G4C.G4C_IDIF = G85.G85_IDIF
				 AND G4C.G4C_NUMID = G85.G85_REGVEN
				 AND G4C.G4C_IDITEM = G85.G85_ITVEND
				 AND G4C.G4C_NUMSEQ = G85.G85_SEQIV
				 AND G4C.G4C_CONINU = %Exp:cConinu%
				 AND G4C.%NotDel%
				 WHERE G85.G85_FILIAL = %Exp:cFilFat%
				 AND G85.G85_PREFIX = %Exp:cPrefixo%
				 AND G85.G85_NUMFAT = %Exp:cFatura%
				 AND G85.G85_ITPRIN = ' '
				 AND G85.G85_CLASS <> 'V01'
				 AND G85.%NotDel%

				 UNION

				 SELECT G85.G85_IDIF IDIF
				 		 , G85.G85_FILREF FILREF
						 , G85.G85_REGVEN REGVEN
						 , G85.G85_ITVEND ITVEND
						 , G85.G85_TPENT  TPENT
						 , G85.G85_ITENT  ITENT
						 , G4C.G4C_MOEDA MOEDA
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) TARIFA
						 , 0 TAXA
						 , G4C.G4C_TXCAMB CAMBIO
						 , 0 TAXAADM
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) VALOR
						 , G85.G85_GRPPRD GRUPO
						 , G85.G85_SOLIC SOLIC
				 FROM %Table:G85% G85
				 INNER JOIN %Table:G4C% G4C
				 ON G4C.G4C_FILREF = G85.G85_FILREF
				 AND G4C.G4C_IDIF = G85.G85_IDIF
				 AND G4C.G4C_NUMID = G85.G85_REGVEN
				 AND G4C.G4C_IDITEM = G85.G85_ITVEND
				 AND G4C.G4C_NUMSEQ = G85.G85_SEQIV
				 AND G4C.G4C_CONINU = %Exp:cConinu%
				 AND G4C.%NotDel%
				 WHERE G85.G85_FILIAL = %Exp:cFilFat%
				 AND G85.G85_PREFIX = %Exp:cPrefixo%
				 AND G85.G85_NUMFAT = %Exp:cFatura%
				 AND G85.G85_ITPRIN <> ' '
				 AND G85.G85_CLASS IN ('C08','C09')
				 AND G85.%NotDel%

				 UNION

				 SELECT G85.G85_IDIF IDIF
				 		 , G85.G85_FILREF FILREF
						 , G85.G85_REGVEN REGVEN
						 , G85.G85_ITVEND ITVEND
						 , G85.G85_TPENT  TPENT
						 , G85.G85_ITENT  ITENT
						 , G4C.G4C_MOEDA MOEDA
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) TARIFA
						 , 0 TAXA
						 , G4C.G4C_TXCAMB CAMBIO
						 , 0 TAXAADM
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) VALOR
						 , G85.G85_GRPPRD GRUPO
						 , G85.G85_SOLIC SOLIC
				 FROM %Table:G85% G85
				 INNER JOIN %Table:G4C% G4C
				 ON G4C.G4C_FILREF = G85.G85_FILREF
				 AND G4C.G4C_IDIF = G85.G85_IDIF
				 AND G4C.G4C_NUMID = G85.G85_REGVEN
				 AND G4C.G4C_IDITEM = G85.G85_ITVEND
				 AND G4C.G4C_NUMSEQ = G85.G85_SEQIV
				 AND G4C.G4C_CONINU = %Exp:cConinu%
				 AND G4C.%NotDel%
				 WHERE G85.G85_FILIAL = %Exp:cFilFat%
				 AND G85.G85_PREFIX = %Exp:cPrefixo%
				 AND G85.G85_NUMFAT = %Exp:cFatura%
				 AND G85.G85_ITPRIN = ' '
				 AND G85.G85_CLASS = 'V01'
				 AND G85.%NotDel%

				 UNION

				 SELECT G85.G85_IDIF IDIF
				 		 , G85.G85_FILREF FILREF
						 , G85.G85_REGVEN REGVEN
						 , G85.G85_ITVEND ITVEND
						 , G85.G85_TPENT  TPENT
						 , G85.G85_ITENT  ITENT
						 , G4C.G4C_MOEDA MOEDA
						 , 0 TARIFA
						 , 0 TAXA
						 , G4C.G4C_TXCAMB CAMBIO
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) TAXAADM
						 , (CASE WHEN G4C.G4C_PAGREC = '2' THEN G4C.G4C_VALOR ELSE G4C.G4C_VALOR*-1 END) VALOR
						 , G85.G85_GRPPRD GRUPO
						 , G85.G85_SOLIC SOLIC
				 FROM %Table:G85% G85
				 INNER JOIN %Table:G4C% G4C
				 ON G4C.G4C_FILREF = G85.G85_FILREF
				 AND G4C.G4C_IDIF = G85.G85_IDIF
				 AND G4C.G4C_NUMID = G85.G85_REGVEN
				 AND G4C.G4C_IDITEM = G85.G85_ITVEND
				 AND G4C.G4C_NUMSEQ = G85.G85_SEQIV
				 AND G4C.G4C_CONINU = %Exp:cConinu%
				 AND G4C.%NotDel%
				 WHERE G85.G85_FILIAL = %Exp:cFilFat%
				 AND G85.G85_PREFIX = %Exp:cPrefixo%
				 AND G85.G85_NUMFAT = %Exp:cFatura%
				 AND G85.G85_ITPRIN <> ' '
				 AND G85.G85_CLASS NOT IN('C09','C08','V01')
				 AND G85.%NotDel%
				 ) TMP
			GROUP BY FILREF, REGVEN, ITVEND, GRUPO, SOLIC, MOEDA, CAMBIO, TPENT, ITENT

			%Exp:cOrder%    

		EndSql


	Else

		BeginSql Alias cAliasTot
			SELECT G6L_TPAPUR 
			FROM %Table:G6L% G6L
			JOIN %Table:G85% G85 ON %Exp:cExpG6LG85%
									G85.G85_CODAPU = G6L.G6L_CODAPU
			WHERE G85.G85_FILIAL = %Exp:cFilFat%  AND 
			      G85.G85_PREFIX = %Exp:cPrefixo% AND
                  G85.G85_NUMFAT = %Exp:cFatura%  AND
                  G85.%NotDel% AND 
                  G6L.%NotDel%
		EndSql
		
		If (cAliasTot)->(!Eof())
			cTpApur := (cAliasTot)->G6L_TPAPUR
			(cAliasTot)->(dbCloseArea())
	
			If cTpApur == '1' 
				BeginSql Alias cAliasTot
					SELECT G85.G85_FILREF+G85.G85_CODAPU ITEM,
						   G85.G85_FILREF FILREF,
						   G85.G85_CODAPU APURACAO,
						   G85.G85_TPENT TPENT,
						   G85.G85_ITENT ITENT,
						   SUM((CASE WHEN G85.G85_PAGREC = '2' 
								  THEN G85.G85_VALOR
								  ELSE G85.G85_VALOR * -1
								END)) TOTAL
					FROM %Table:G85% G85
					INNER JOIN %Table:G81% G81 ON G81.G81_FILREF = G85.G85_FILREF AND 		
												  G81.G81_IDIFA  = G85.G85_IDIFA  AND 		
												  G81.%NotDel%
					WHERE G85.G85_FILIAL = %Exp:cFilFat%  AND 
						  G85.G85_PREFIX = %Exp:cPrefixo% AND
						  G85.G85_NUMFAT = %Exp:cFatura%  AND
						  G85.%NotDel%
					GROUP BY G85.G85_FILREF+G85.G85_CODAPU,
							 G85.G85_FILREF, 
							 G85.G85_CODAPU, 
							 G85.G85_TPENT, 
							 G85.G85_ITENT
				EndSql
			Else
				BeginSql Alias cAliasTot
					SELECT		G85.G85_FILREF+G85.G85_CODAPU+G85.G85_IDIFA ITEM,
								G85.G85_FILREF FILREF,
								G85.G85_CODAPU APURACAO,
								G85.G85_IDIFA IDIFA,
								G85.G85_CODPRD PRODUTO,
								(CASE
									WHEN G85.G85_PAGREC = '2' 
									THEN G85.G85_VALOR
									ELSE G85.G85_VALOR*-1
								END) TOTAL,
								G85.G85_TPENT TPENT,
								G85.G85_ITENT ITENT,
								G85.G85_ITEM ITEMF
					FROM 		%Table:G85% G85
					INNER JOIN 	%Table:G81% G81
					ON 			G81.G81_FILREF 	= G85.G85_FILREF
					AND 		G81.G81_IDIFA 	= G85.G85_IDIFA
					AND 		G81.%NotDel%
					WHERE 		G85.%NotDel%
					AND 		G85.G85_FILIAL	= %Exp:cFilFat%
					AND 		G85.G85_PREFIX 	= %Exp:cPrefixo%
					AND 		G85.G85_NUMFAT 	= %Exp:cFatura%
				EndSql
			EndIf
		EndIf
	EndIf
	
	(cAliasTot)->(dbGoTop())

	//Guarda em um array os itens da fatura
	While (cAliasTot)->(!Eof())
	
		If ( (cAliasTot)->(FieldPos("REPASSE")) > 0 )
			nTotal := TR013CalcSub((cAliasTot)->TOTAL,(cAliasTot)->REPASSE)
		Else
			nTotal := (cAliasTot)->TOTAL
		EndIf	
		
		If lTotaliza
			aAdd(aTot,{	If(	(cAliasEad)->G67_BASE <> "1",	(cAliasTot)->&(cCampo),;
							If(G84->G84_TPFAT <> '2',	DescEnt((cAliasTot)->ITEM,'01',(cAliasEad)->G67_CODEAD),;
							If((cAliasTot)->TPENT == (cAliasEad)->G67_CODEAD,(cAliasTot)->ITENT,""))),;
							(cAliasTot)->ITEM,;
						If(G84->G84_TPFAT <> '2',(cAliasTot)->CAMBIO,0),;
						If(G84->G84_TPFAT <> '2',(cAliasTot)->TARIFA,0),; //Tarifa Cliente
						If(G84->G84_TPFAT <> '2',(cAliasTot)->TAXA,0),;
						If(G84->G84_TPFAT <> '2',(cAliasTot)->TAXAADM,0),;
						nTotal,;
						If(G84->G84_TPFAT == '2',(cAliasTot)->TPENT,""),;
						If(G84->G84_TPFAT == '2',(cAliasTot)->ITENT,""),;
						If(G84->G84_TPFAT == '4',(cAliasTot)->MULTA,0),;
						If(G84->G84_TPFAT == '4',(cAliasTot)->REPASSE,0)})
		Else
			aAdd(aTot,{	"",;
						(cAliasTot)->ITEM,;
						If(G84->G84_TPFAT <> '2',(cAliasTot)->CAMBIO,0),;
						If(G84->G84_TPFAT <> '2',(cAliasTot)->TARIFA,0),; //Tarifa Cliente
						If(G84->G84_TPFAT <> '2',(cAliasTot)->TAXA,0),;
						If(G84->G84_TPFAT <> '2',(cAliasTot)->TAXAADM,0),;
						nTotal,;
						If(G84->G84_TPFAT == '2',(cAliasTot)->TPENT,""),;
						If(G84->G84_TPFAT == '2',(cAliasTot)->ITENT,""),;
						If(G84->G84_TPFAT == '4',(cAliasTot)->MULTA,0),;
						If(G84->G84_TPFAT == '4',(cAliasTot)->REPASSE,0)})
		EndIf
		(cAliasTot)->(dbSkip())
	EndDo

	(cAliasTot)->(dbCloseArea())

	If (cAliasEad)->G67_BASE == "1" //Entidade Adicional
		aTot := aSort(aTot,,,{ | x,y | y[1] > x[1] })
	EndIf

	For nX := 1 To Len(aTot)
		If lTotaliza //Se houver totalizador cadastrado
			If cTotAnt <> aTot[nX][1] .Or. lFirst

				cTotAnt := aTot[nX][1]
				lFirst	:= .F.
				//Identifica a descriÁ„o dos totalizadores
				Do Case
					Case (cAliasEad)->G67_BASE == "1" //1=Entidades Adicionais
						If !Empty(aTot[nX][1])
							If 	G3G->(dbSeek(xFilial("G3G")+cCliPDF+cLojaPDF+(cAliasEad)->G67_CODEAD+aTot[nX][1]))
								cEntTot := AllTrim(G3G->G3G_ITEM) + " - " + AllTrim(G3G->G3G_DESCR)
							EndIf
						Else
							cEntTot := ""
						EndIf

					Case (cAliasEad)->G67_BASE == "2" //2=Solicitantes

						If SU5->(dbSeek(xFilial("SU5")+aTot[nX][1]))
							cEntTot := AllTrim(SU5->U5_CODCONT) + " - " + AllTrim(SU5->U5_CONTAT)
						EndIf

					Case (cAliasEad)->G67_BASE == "3" //3=Grupo de Produto

						If SBM->(dbSeek(xFilial("SBM")+aTot[nX][1]))
							cEntTot := AllTrim(SBM->BM_GRUPO) + " - " + AllTrim(SBM->BM_DESC)
						EndIf

					Case (cAliasEad)->G67_BASE == "4" //4=Filial de Venda

						aAreaSM0 := SM0->(GetArea())
						If SM0->(dbSeek(cEmpAnt + aTot[nX][1]))//aaui
							cEntTot := AllTrim(SM0->M0_CODFIL) + " - " + AllTrim(SM0->M0_NOMECOM)
						EndIf
						RestArea(aAreaSM0)
				EndCase

				//------------------------------------------------------------------------------------------
				// ENTIDADE TOTALIZADORA
				//------------------------------------------------------------------------------------------
				If nLin+75 > nPgBreak

					oPrint:EndPage()

					nLin := TU13CAB(@oPrint,@nPagina,lReimp)

				EndIf

				oPrint:Box( nLin, 0060, nLin+75, 2284,, )
				nLin+=35

				oPrint:Say( nLin, 0080, SubStr(OEMTOANSI(cDscEntTot) +" - "+ OEMTOANSI(cEntTot),1,86)	,oFont12:oFont,, )
				
				If Len(OEMTOANSI(cDscEntTot) +" - "+ OEMTOANSI(cEntTot)) > 86	
					oPrint:Line(nLin, 0060, nLin+20, 0060,, )
					oPrint:Line(nLin, 2284, nLin+20, 2284,, )
					nLin+=20
					oPrint:Say( nLin, 0080,SubStr(OEMTOANSI(cDscEntTot) +" - "+ OEMTOANSI(cEntTot),87) 	,oFont12:oFont  )
				EndIf
				
				nLin+=50
			EndIf
		Else
			nLin+=25
		EndIf

		If G84->G84_TPFAT <> '2'
			G85->(dbSetOrder(2)) //G85_FILIAL + G85_PREFIX + G85_NUMFAT + G85_FILREF + G85_REGVEN + G85_ITVEND + G85_SEQIV
		Else
			G85->(dbSetOrder(3)) //G85_FILIAL + G85_PREFIX + G85_NUMFAT + G85_FILREF + G85_CODAPU + G85_IDIFA
		EndIf
		If G85->(dbSeek(cFilFat+cPrefixo+cFatura+aTot[nX][2]))

			If G84->G84_TPFAT <> '2'
				G3Q->(dbSeek(xFilial("G3Q",G85->G85_FILREF)+G85->G85_REGVEN+G85->G85_ITVEND+G85->G85_SEQIV))
				G3R->(dbSeek(xFilial("G3R",G85->G85_FILREF)+G85->G85_REGVEN+G85->G85_ITVEND+G85->G85_SEQIV))
				SA1->(dbSeek(xFilial("SA1",G85->G85_FILREF)+G3Q->G3Q_CLIENT+G3Q->G3Q_LOJA))
				SA2->(dbSeek(xFilial("SA2",G85->G85_FILREF)+G3R->G3R_FORNEC+G3R->G3R_LOJA))
				SBM->(dbSeek(xFilial("SBM",G85->G85_FILREF)+G85->G85_GRPPRD))
			Else
				G81->(dbSeek(xFilial("G81",G85->G85_FILREF)+G85->G85_IDIFA))
				SA1->(dbSeek(xFilial("SA1",G85->G85_FILREF)+G81->G81_CLIENT+G81->G81_LOJA))
			EndIf

			SB1->(dbSeek(xFilial("SB1",G85->G85_FILREF)+G85->G85_CODPRD))

			//------------------------------------------------------------------------------------------
			// ITEM DE VENDA
			//------------------------------------------------------------------------------------------

			If aTot[nX][7] <> 0
				nLin := TURR13SEG(@oPrint,@nPagina,nLin,cDscEntTot,cEntTot,aTot[nX],cTpApur)
				nTotEad += aTot[nX][7]
				aTotais[1] += aTot[nX][4] //Tarifa Cliente
				aTotais[2] += aTot[nX][5] //Taxas
				aTotais[3] += aTot[nX][6] //Taxa Adm
				aTotais[4] += (aTot[nX][7] ) //Total
				aTotais[5] += aTot[nX][10] //Multas
				aTotais[6] += aTot[nX][11] //Abatim.
			EndIf
		EndIf

		If lTotaliza
			If Len(aTot) == nX .Or. aTot[nX][1] <> aTot[nX+1][1]
				//------------------------------------------------------------------------------------------
				// TOTAL ENTIDADE
				//------------------------------------------------------------------------------------------
				If nLin+100 > nPgBreak

					oPrint:EndPage()
					nLin := TU13CAB(@oPrint,@nPagina,lReimp)

				EndIf

				oPrint:Box( nLin, 0060, nLin+100, 2284,, )
				nLin+=25
				
				oPrint:Say( nLin+=35, 0344, OEMTOANSI(STR0033)  					,oFont11N:oFont)  //Total
				
				oPrint:Say( nLin	, 0450, SubStr(OEMTOANSI(cDscEntTot) +" - "+ OEMTOANSI(cEntTot),1,86)	,oFont12:oFont,, )
				
				If Len(OEMTOANSI(cDscEntTot) +" - "+ OEMTOANSI(cEntTot)) > 86	
					oPrint:Line(nLin, 0060, nLin+20, 0060,, )
					oPrint:Line(nLin, 2284, nLin+20, 2284,, )
					nLin+=20
					oPrint:Say( nLin, 0450,SubStr(OEMTOANSI(cDscEntTot) +" - "+ OEMTOANSI(cEntTot),87) 	,oFont12:oFont  )
				EndIf
				
				
				oPrint:Say( nLin	, 2020, Transform(nTotEad,"@E 9,999,999.99") 	,oFont12:oFont,, )
				nTotEad := 0
				nLin+=65
			EndIf
		EndIf

	Next nX

	(cAliasEad)->(dbCloseArea())

	//------------------------------------------------------------------------------------------
	// TOTAL DA FATURA
	//------------------------------------------------------------------------------------------
	If nLin+145 > nPgBreak

		oPrint:EndPage()
		nLin := TU13CAB(@oPrint,@nPagina,lReimp)

	EndIf

	oPrint:Box( nLin, 0060, nLin+145, 2284,, )
	nLin+=25

	nLin+=35
	
	If G84->G84_TPFAT == '4'
		oPrint:Say( nLin	,  800, OEMTOANSI(STR0034) 	 ,oFont11N:oFont)  //Tar.Nac.
		oPrint:Say( nLin	, 1100, OEMTOANSI(STR0035) 	 ,oFont11N:oFont)  //Taxas
		oPrint:Say( nLin	, 1370, OEMTOANSI(STR0036)   ,oFont11N:oFont)  //Taxa Adm.
		oPrint:Say( nLin	, 1670, OEMTOANSI(STR0091) 	 ,oFont11N:oFont)  //"Multa"
		oPrint:Say( nLin	, 1870, OEMTOANSI(STR0092) 	 ,oFont11N:oFont)  //"Repasse"
		oPrint:Say( nLin	, 2120, OEMTOANSI(STR0033)  ,oFont11N:oFont)  //Total
	ElseIf G84->G84_TPFAT <> '2'
		oPrint:Say( nLin	, 1100, OEMTOANSI(STR0034) 	,oFont11N:oFont)  //Tar.Nac.
		oPrint:Say( nLin	, 1400, OEMTOANSI(STR0035) 	,oFont11N:oFont)  //Taxas
		oPrint:Say( nLin	, 1670, OEMTOANSI(STR0036)  ,oFont11N:oFont)  //Taxa Adm.
		oPrint:Say( nLin	, 2120, OEMTOANSI(STR0033)  ,oFont11N:oFont)  //Total
	EndIf
	

	oPrint:Say( nLin+=45, 0400, OEMTOANSI(STR0037)+":"  			  ,oFont11N:oFont,, )
	If G84->G84_TPFAT == '4'
		oPrint:Say( nLin,  730, Transform(aTotais[1],"@E 9,999,999.99") ,oFont12:oFont,, )
		oPrint:Say( nLin, 1000, Transform(aTotais[2],"@E 9,999,999.99") ,oFont12:oFont,, )
		oPrint:Say( nLin, 1320, Transform(aTotais[3],"@E 9,999,999.99") ,oFont12:oFont,, )
		oPrint:Say( nLin, 1560, Transform(aTotais[5],"@E 9,999,999.99") ,oFont12:oFont,, )
		oPrint:Say( nLin, 1790, Transform(aTotais[6],"@E 9,999,999.99") ,oFont12:oFont,, )
		oPrint:Say( nLin, 2050, Transform(aTotais[4],"@E 9,999,999.99") ,oFont12:oFont,, )
	ElseIf G84->G84_TPFAT <> '2'
		oPrint:Say( nLin, 1000, Transform(aTotais[1],"@E 9,999,999.99") ,oFont12:oFont,, )
		oPrint:Say( nLin, 1320, Transform(aTotais[2],"@E 9,999,999.99") ,oFont12:oFont,, )
		oPrint:Say( nLin, 1600, Transform(aTotais[3],"@E 9,999,999.99") ,oFont12:oFont,, )
		oPrint:Say( nLin, 2050, Transform(aTotais[4],"@E 9,999,999.99") ,oFont12:oFont,, )
	Else
		oPrint:Say( nLin, 2050, Transform(aTotais[4],"@E 9,999,999.99") ,oFont12:oFont,, )
	EndIf

	nLin+=35

	//------------------------------------------------------------------------------------------
	// IMPRESSAO
	//------------------------------------------------------------------------------------------
	If nLin+100 > nPgBreak

		oPrint:EndPage()
		nLin := TU13CAB(@oPrint,@nPagina,lReimp)

	EndIf

	oPrint:Box( nLin, 0060, nLin+100, 2284,, )
	nLin+=25

	oPrint:Say( nLin+=35, 0080, OEMTOANSI(STR0038)+":" 	 	,oFont11N:oFont) 
	oPrint:Say( nLin	, 0359, DtoC(dDataBase)		 		,oFont12:oFont,, )
	oPrint:Say( nLin	, 1132, OEMTOANSI(STR0039)+":" 	 	,oFont11N:oFont) 
	oPrint:Say( nLin	, 1411, SubStr(cUsuario,7,15)		,oFont12:oFont,, )

	nLin+=50

	If nLin > 2700

		oPrint:EndPage()

		nLin := TU13CAB(@oPrint,@nPagina,lReimp)

	EndIf
	//------------------------------------------------------------------------------------------
	// CODIGO DE BARRAS
	//------------------------------------------------------------------------------------------
	cCodBar := StrTran(G84->(G84_PREFIX+G84_NUMFAT)," ","*")

	For nIndexPre:= 1 TO TAMSX3('G84_PREFIX')[1]
		cPefixo +=  PADL(ASC(SUBSTRING(G84->G84_PREFIX,nIndexPre,1)),3,'0')
	Next nIndexPre
	
	For nIndexPre:= 1 TO TAMSX3('G84_FILIAL')[1]
		cFilAux += PADL(ASC(SUBSTRING(G84->G84_FILIAL,nIndexPre,1)),3,'0')
	Next nIndexPre
	
	If nLin+167 > nPgBreak

		oPrint:EndPage()
		nLin := TU13CAB(@oPrint,@nPagina,lReimp)

	EndIf

	oPrint:Box( nLin, 0060, nLin+167, 2284,, )
	nLin+=98

	oPrint:Code128c(nLin+53,0224,cFilAux+cPefixo+G84->G84_NUMFAT,45) 
	 
	oPrint:Say(nLin,1512,cCodBar,oFont16N:oFont,,)

	nLin+= 79

	//------------------------------------------------------------------------------------------
	// OBSERVA«√O
	//------------------------------------------------------------------------------------------
	cObs := AllTrim(G84->G84_MSGOBS)
	aObs := TurBreakLine(cObs,oPrint,oFont12:oFont,oPrint:nPageWidth-50 ) //2224 È o tamanho em pixels da largura do box

	If !Empty(aObs)

		If nLin+145 > nPgBreak //?? VER AQUI PARA A QUEBRA DA PAGINA QUE ESTA DEIXANDO UM ESPA«O GRANDE - RADU

			oPrint:EndPage()
			nLin := TU13CAB(@oPrint,@nPagina,lReimp)

		EndIf

		oPrint:Line(nLin, 0060, nLin	, 2286,, )
		oPrint:Line(nLin, 0060, nLin+70	, 0060,, )
		oPrint:Line(nLin, 2286, nLin+70	, 2286,, )
		nLin+=25

		oPrint:Say( nLin+35, 0080, OEMTOANSI(STR0040) 	,oFont11N:oFont) 
		nLin+=45

		For nX := 1 To Len(aObs)

			If nLin+70 > nPgBreak
				oPrint:Line(nLin, 0060, nLin	, 2286,, )
				oPrint:EndPage()
				nLin := TU13CAB(@oPrint,@nPagina,lReimp)
				nLin+=25
				oPrint:Line(nLin, 0060, nLin, 2286,, )
			EndIf

			oPrint:Line(nLin, 0060, nLin+45, 0060,, )
			oPrint:Line(nLin, 2286, nLin+45, 2286,, )
			nLin+=45

			If ( At(chr(13) + chr(10),aObs[nX]) > 0 )
				oPrint:Say( nLin, 0080, "" 			,oFont12:oFont)
			Else
				oPrint:Say( nLin, 0080, aObs[nX] 	,oFont12:oFont)
			EndIf

		Next nX
		oPrint:Line(nLin, 0060, nLin+25	, 0060,, )
		oPrint:Line(nLin, 2286, nLin+25	, 2286,, )
		nLin+=25
		oPrint:Line(nLin, 0060, nLin	, 2286,, )
	EndIf

Else
	ConOut("J_FURPRE (U_J_FURPRE): " + Dtos(Date()) + " - " + Time() + " - " + STR0096 + xFilial("G84") + " # " + cFilAnt + " - " + cPrefixo + " - " + cFatura + " - " + cCliPDF + " - " + cLojaPDF + " - " + STR0102 + G84->(DBFilter()) + " - ", STR0097)               // "Fatura n„o encontrada! "     "Falha na impress„o da Fatura."		"FILTRO: "
EndIf

oPrint:EndPage()

Return(oPrint)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TU13CAB
FunÁ„o para impress„o de Fatura
@author    Cleyton
@version   1.00
@since     01/05/2016
/*/
//------------------------------------------------------------------------------------------
Static Function TU13CAB(oPrint,nPagina,lReimp)

Local oFont11N   := TFontEx():New(oPrint,"Arial",11, 11,.T.,.T.,.F.)
Local oFont12    := TFontEx():New(oPrint,"Courier",12, 12,.T.,.T.,.F.)
Local oFont14    := TFontEx():New(oPrint,"Arial",14, 14,.F.,.T.,.F.)
Local oFont14N    := TFontEx():New(oPrint,"Arial",14, 14,.T.,.T.,.F.)
Local oFont16N   := TFontEx():New(oPrint,"Arial",16, 16,.T.,.T.,.F.)

Local nLin       := 0
Local cEndCob	 := ""
Local cCidCob	 := ""
Local aAreaSM0	:= {}

Default lReimp := .F.

nPagina++

oPrint:StartPage()

If nPagina > 1
	//------------------------------------------------------------------------------------------
	// CABE«ALHO OUTRAS PAGINAS
	//------------------------------------------------------------------------------------------
	oPrint:Box( 0100 ,0060 ,0200 ,2284 )
	
	oPrint:Say( 0160, 0080, OEMTOANSI(STR0045)+":"		        									,oFont11N:oFont)  //"P·gina"
	oPrint:Say( 0160, 0344, OEMTOANSI(AllTrim(Str(nPagina)))   										,oFont12:oFont  )
	oPrint:Say( 0160, 0730, OEMTOANSI(STR0046)+":"		        									,oFont11N:oFont)  //"Pref. - Fatura"
	oPrint:Say( 0160, 0994, OEMTOANSI(AllTrim(G84->(G84_PREFIX))+" - "+AllTrim(G84->(G84_NUMFAT)))	,oFont12:oFont  )
	oPrint:Say( 0160, 1318, OEMTOANSI(STR0053)+":"		        									,oFont11N:oFont)  //"Filial"
	aAreaSM0 := SM0->(GetArea())
	If SM0->(dbSeek(cEmpAnt + G84->G84_FILIAL))
		oPrint:Say( 0160, 1482, OEMTOANSI(G84->G84_FILIAL) +" - "+	AllTrim(SM0->M0_NOMECOM)		,oFont12:oFont  )
	EndIf
	RestArea(aAreaSM0)

	nLin := 0225

Else
	//------------------------------------------------------------------------------------------
	// INFORMA«‘ES DA EMPRESA
	//------------------------------------------------------------------------------------------
	oPrint:Box( 		0100, 0060, 0470, 2284 )
	
	SM0->(dbSeek(cEmpAnt + G84->G84_FILIAL))  	
		
	cEndCob := AllTrim(SM0->M0_ENDCOB) + If(!Empty(SM0->M0_COMPCOB)," - " + AllTrim(SM0->M0_COMPCOB), "") + " - " + AllTrim(SM0->M0_BAIRCOB)
	cCidCob := AllTrim(SM0->M0_CIDCOB) + " - " + AllTrim(SM0->M0_ESTCOB)  + " - " + OEMTOANSI(STR0051) + " - " + STR0011+": " + TransForm(SM0->M0_CEPCOB, PesqPict("SA1", "A1_CEP"))

	oPrint:Say( 0159, (1142-(Int(oPrint:GetTextWidth(AllTrim(SM0->M0_NOMECOM),oFont16N:oFont)/3))), SM0->M0_NOMECOM		,oFont16N:oFont)
	oPrint:Say( 0213, (1142-(Int(oPrint:GetTextWidth(AllTrim(cEndCob),oFont14:oFont)/3))), AllTrim(cEndCob)		,oFont14:oFont) // EndereÁo
	oPrint:Say( 0266, (1142-(Int(oPrint:GetTextWidth(AllTrim(cCidCob),oFont14:oFont)/3))), AllTrim(cCidCob)		,oFont14:oFont)	// Cidade
	oPrint:Say( 0319, 0468, OEMTOANSI(STR0083)+":"																,oFont14N:oFont)  //"Fone"
	oPrint:Say( 0319, 0703, TransForm(SM0->M0_TEL, "@R (99) 9999-9999" )											,oFont14:oFont  )
	oPrint:Say( 0373, 0468, OEMTOANSI(STR0041)+":" 																,oFont14N:oFont)  //"HomePage"
	oPrint:Say( 0373, 0703, AllTrim(GetMV("MV_TURSITE"))														,oFont14:oFont  )
	oPrint:Say( 0319, 1256, OEMTOANSI(STR0020)+":"																,oFont14N:oFont)  //"E-mail"
	oPrint:Say( 0319, 1445, AllTrim(GetMV("MV_TURMAIL"))														,oFont14:oFont  )
	oPrint:Say( 0426, 0468, OEMTOANSI(STR0042)+":" 																,oFont14N:oFont)  //"CNPJ"
	oPrint:Say( 0426, 0703, TransForm(SM0->M0_CGC, "@R 99.999.999/9999-99" )									,oFont14:oFont 	)
	oPrint:Say( 0373, 1256, OEMTOANSI(STR0084+":")																,oFont14N:oFont)  //"Embratur"
	oPrint:Say( 0373, 1445, AllTrim(GetMV("MV_TUREMBT"))														,oFont14:oFont  )
	oPrint:Say( 0426, 1256, OEMTOANSI(STR0044)+":" 																,oFont14N:oFont)  //"IATA"
	oPrint:Say( 0426, 1445, AllTrim(Posicione("G3M",1,xFilial("G3M")+G4M->G4M_CODPOS,"G3M_NIATA" ))				,oFont14:oFont 	)

	//------------------------------------------------------------------------------------------
	// INFORMA«‘ES DA FATURA
	//------------------------------------------------------------------------------------------
	oPrint:Box( 		0480 ,0060 ,0640 ,2284 )
	//---------------------------------------------------------------------------------------------------------------------------------------
	oPrint:Say( 0545, 0080, OEMTOANSI(STR0045)+":"		        									,oFont11N:oFont)  //"P·gina"
	oPrint:Say( 0545, 0344, OEMTOANSI(AllTrim(Str(nPagina)))   										,oFont12:oFont  )
	//---------------------------------------------------------------------------------------------------------------------------------------
	oPrint:Say( 0545, 0420, OEMTOANSI(STR0046)+":"		        									,oFont11N:oFont)  //"Pref. - Fatura"
	oPrint:Say( 0545, 0684, OEMTOANSI(AllTrim(G84->(G84_PREFIX))+" - "+AllTrim(G84->(G84_NUMFAT)))	,oFont12:oFont  )
	oPrint:Say( 0590, 0420, OEMTOANSI(STR0049)+":"													,oFont11N:oFont)  //"Data Emiss„o"
	oPrint:Say( 0590, 0684, DTOC(G84->G84_EMISS) 	        											,oFont12:oFont  )
	//---------------------------------------------------------------------------------------------------------------------------------------
	oPrint:Say( 0545, 1020, OEMTOANSI(STR0053)+":"		        									,oFont11N:oFont)  //"Filial"
	aAreaSM0 := SM0->(GetArea())
	If SM0->(dbSeek(cEmpAnt + G84->G84_FILIAL))
		oPrint:Say( 0545, 1250, OEMTOANSI(G84->G84_FILIAL) +" - "+	AllTrim(SM0->M0_NOMECOM)		,oFont12:oFont  )
	EndIf
	RestArea(aAreaSM0)
	oPrint:Say( 0590, 1020, OEMTOANSI(STR0050)+":"		        									,oFont11N:oFont)  //"Moeda"
	oPrint:Say( 0590, 1250, AllTrim(Posicione("G5T",1,xFilial("G5T")+G84->G84_MOEDA,"G5T_SIMBOL" )),oFont12:oFont  )
	
	//---------------------------------------------------------------------------------------------------------------------------------------
	If G84->G84_TOTAL < 0
		oPrint:Say( 0545, 1700, OEMTOANSI(STR0047)													,oFont11N:oFont  ) //"(FATURA DE CREDITO)"
	EndIf


	nLin := 0665
EndIf

Return(nLin)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURR13SEG
FunÁ„o para impress„o de Fatura
@author    Cleyton
@version   1.00
@since     01/05/2016
/*/
//------------------------------------------------------------------------------------------
Static Function TURR13SEG(oPrint,nPagina,nLin,cDscAgru,cQuebra,aTot,cTpApur)

Local aArea		 	:= (GetArea())
Local aAreaSA2   	:= SA2->(GetArea())
Local aAreaG3S   	:= G3S->(GetArea())
Local oFont11    	:= TFontEx():New(oPrint, "Courier", 11, 11, .T., .T., .F.)
Local oFont11N   	:= TFontEx():New(oPrint, "Arial"  , 11, 11, .T., .T., .F.)
Local oFont12    	:= TFontEx():New(oPrint, "Courier", 12, 12, .T., .T., .F.)
Local cAliasEntA 	:= ""
Local nTamG4BTit	:= TamSx3("G4B_TITUL")[1]
Local cConinu   	:= Space(TamSx3("G4C_CONINU")[1])
Local cDatas        := ""
Local lQuebraData   := .T.
Local aTpProd       := TURGetComb('G3U_TPPROD', 1)
Local aCatBus       := TURGetComb('G3W_CATBUS', 1)
Local nLinPula      := 0
Local nPgBreak		:= oPrint:nPageHeight*0.90
Local lTURR013PRT	:= ExistBlock("TURR013PRT")
Local aObsG43       := {}
Local nG43l         := 1
Local cAliasAux     := ""
Local cAliasAer		:= ''
Local lSegAereo		:= .F.
Local cTrechos		:= ''
Local lServProp     := G3Q->G3Q_OPERAC == "4"

If lTURR013PRT	
	ExecBlock("TURR013PRT",.f.,.f.,{oPrint,nLin})
EndIf

If nLin+120 > nPgBreak
	oPrint:EndPage()
	nLin := TU13CAB(@oPrint,@nPagina)
EndIf

oPrint:Box( nLin, 0060, nLin+170, 2284,, )

nLin+=35

oPrint:Say( nLin, 0080, OEMTOANSI(STR0053), oFont11N:oFont)  //"Filial"

If G84->G84_TPFAT <> '2'
	oPrint:Say( nLin, 0230, OEMTOANSI(STR0054), oFont11N:oFont)  //"RV"
	oPrint:Say( nLin, 0430, OEMTOANSI(STR0055), oFont11N:oFont)  //"IV"
	oPrint:Say( nLin, 0550, OEMTOANSI(STR0029), oFont11N:oFont)  //"Emiss„o"
	oPrint:Say( nLin, 0750, OEMTOANSI(STR0057), oFont11N:oFont)  //"Produto"
Else // ApuraÁ„o
	oPrint:Say( nLin, 0250, OEMTOANSI(STR0088), oFont11N:oFont)  //"ApuraÁ„o"
	oPrint:Say( nLin, 0630, OEMTOANSI(STR0029), oFont11N:oFont)  //"Emiss„o"
	If cTpApur == '1'
		oPrint:Say( nLin, 0860, OEMTOANSI(STR0075), oFont11N:oFont)  //"DescriÁ„o"
	Else
		oPrint:Say( nLin, 0860, OEMTOANSI(STR0057), oFont11N:oFont)  //"Produto"
	EndIf
EndIf

If G84->G84_TPFAT == '4'
	oPrint:Say( nLin, 1140, OEMTOANSI(STR0058), oFont11N:oFont)  //"Tarifa"
	oPrint:Say( nLin, 1300, OEMTOANSI(STR0059), oFont11N:oFont)  //"Tx.Cambio"
	oPrint:Say( nLin, 1530, OEMTOANSI(STR0060), oFont11N:oFont)  //"Tar.Nac."
	oPrint:Say( nLin, 1750, OEMTOANSI(STR0035), oFont11N:oFont)  //"Taxas"
	oPrint:Say( nLin, 1890, OEMTOANSI(STR0036), oFont11N:oFont)  //"Taxa Adm."
	oPrint:Say( nLin, 2150, OEMTOANSI(STR0091), oFont11N:oFont)  //"Multa"
Else
	If G84->G84_TPFAT <> '2'
		oPrint:Say( nLin, 1140, OEMTOANSI(STR0058), oFont11N:oFont)  //"Tarifa"
		oPrint:Say( nLin, 1300, OEMTOANSI(STR0059), oFont11N:oFont)  //"Tx.Cambio"
		oPrint:Say( nLin, 1530, OEMTOANSI(STR0060), oFont11N:oFont)  //"Tar.Nac."
		oPrint:Say( nLin, 1750, OEMTOANSI(STR0035), oFont11N:oFont)  //"Taxas"
		oPrint:Say( nLin, 1890, OEMTOANSI(STR0036), oFont11N:oFont)  //"Taxa Adm."
	Else
		oPrint:Say( nLin, 1450, OEMTOANSI(STR0100), oFont11N:oFont)  //"PerÌodo Inicial"
		oPrint:Say( nLin, 1700, OEMTOANSI(STR0101), oFont11N:oFont)  //"PerÌodo Final"
	EndIf
		
	oPrint:Say( nLin, 2150, OEMTOANSI(STR0033), oFont11N:oFont)  //Total
	
EndIf

nLin+=60

oPrint:Say( nLin, 0080, OEMTOANSI(G85->G85_FILREF)	  , oFont11:oFont )
If G84->G84_TPFAT <> '2'
	oPrint:Say( nLin, 0220, OEMTOANSI(G85->G85_REGVEN), oFont11:oFont )
	oPrint:Say( nLin, 0430, OEMTOANSI(G85->G85_ITVEND), oFont11:oFont )
	oPrint:Say( nLin, 0550, DtoC(G85->G85_EMISSA)	  , oFont11:oFont )
Else
	oPrint:Say( nLin, 0250, OEMTOANSI(G85->G85_CODAPU), oFont11:oFont )
	oPrint:Say( nLin, 0630, DtoC(G85->G85_EMISSA)	  , oFont11:oFont )
EndIf

If G84->G84_TPFAT == '4'
	oPrint:Say( nLin, 0750, OEMTOANSI(SBM->BM_GRUPO)				 	 , oFont11:oFont )
	oPrint:Say( nLin, 1020, Transform(aTot[4]/aTot[3], "@E 9,999,999.99"), oFont11:oFont ) //Tarifa Base = Tarifa Cliente / Taxa Cambio
	oPrint:Say( nLin, 1250, Transform(aTot[3]		 , "@E 9,999,999.99"), oFont11:oFont ) //Tx.Cambio
	oPrint:Say( nLin, 1460, Transform(aTot[4]		 , "@E 9,999,999.99"), oFont11:oFont ) //Tarifa Cliente
	oPrint:Say( nLin, 1650, Transform(aTot[5]		 , "@E 9,999,999.99"), oFont11:oFont ) //Taxas
	oPrint:Say( nLin, 1840, Transform(aTot[6]		 , "@E 9,999,999.99"), oFont11:oFont ) //Taxa Adm
	oPrint:Say( nLin, 2050, Transform(aTot[10]		 , "@E 9,999,999.99"), oFont11:oFont ) //Multa

	nLin+=45
	oPrint:Say( nLin, 0080, OEMTOANSI(STR0093) + ":"		    , oFont11N:oFont )	//"Prod."
	oPrint:Say( nLin, 0250, OEMTOANSI(SBM->BM_DESC)		        , oFont11:oFont  )	//DescriÁ„o do Grupo de Produtos
	oPrint:Say( nLin, 1820, OEMTOANSI(STR0033)			        , oFont11N:oFont ) 	//Total
	oPrint:Say( nLin, 2050, Transform(aTot[7],"@E 9,999,999.99"), oFont11:oFont  ) 	//Total

Else

	If G84->G84_TPFAT <> '2'
		oPrint:Say( nLin, 0750, OEMTOANSI(SBM->BM_GRUPO)                     , oFont11:oFont )
		oPrint:Say( nLin, 1020, Transform(aTot[4]/aTot[3], "@E 9,999,999.99"), oFont11:oFont ) //Tarifa Base = Tarifa Cliente / Taxa Cambio
		oPrint:Say( nLin, 1250, Transform(aTot[3]		 , "@E 9,999,999.99"), oFont11:oFont ) //Tx.Cambio
		oPrint:Say( nLin, 1460, Transform(aTot[4]		 , "@E 9,999,999.99"), oFont11:oFont ) //Tarifa Cliente
		oPrint:Say( nLin, 1650, Transform(aTot[5]		 , "@E 9,999,999.99"), oFont11:oFont ) //Taxas
		oPrint:Say( nLin, 1840, Transform(aTot[6]		 , "@E 9,999,999.99"), oFont11:oFont ) //Taxa Adm
		oPrint:Say( nLin, 2050, Transform(aTot[7]		 , "@E 9,999,999.99"), oFont11:oFont ) //Total
	Else
		DbSelectArea("G6L")
		G6L->(DbSetOrder(1))	// G6L_FILIAL+G6L_CODAPU
		G6L->(DbSeek(G81->G81_FILIAL + G81->G81_CODAPU))
		
		If cTpApur == '1'	
			oPrint:Say( nLin, 0860, IIF(aTot[7] > 0, STR0098, STR0099) + IIF(G81->G81_SEGNEG == "1", Upper(STR0001), IIF(G81->G81_SEGNEG == "2", Upper(STR0002), Upper(STR0003))), oFont11:oFont )		// "FEE "	// "REPASSE "	// "CORPORATIVO"	// "EVENTO"		// "LAZER"    
			oPrint:Say( nLin, 1450, OEMTOANSI(DtoC(G6L->G6L_DTINI)), oFont11:oFont)
			oPrint:Say( nLin, 1700, OEMTOANSI(DtoC(G6L->G6L_DTFIM)), oFont11:oFont)
			oPrint:Say( nLin, 2050, Transform(aTot[7], "@E 9,999,999.99"), oFont11:oFont ) //Total
		Else
			oPrint:Say( nLin, 0860, OEMTOANSI(G85->G85_CODPRD), oFont11:oFont )
			oPrint:Say( nLin, 1450, OEMTOANSI(DtoC(G6L->G6L_DTINI)), oFont11:oFont)
			oPrint:Say( nLin, 1700, OEMTOANSI(DtoC(G6L->G6L_DTFIM)), oFont11:oFont)
			oPrint:Say( nLin, 2050, Transform(aTot[7], "@E 9,999,999.99"), oFont11:oFont ) //Total
	
			nLin += 45
	
			oPrint:Say( nLin, 0080, OEMTOANSI(STR0075 + " " + STR0093) + ":", oFont11N:oFont ) //"Prod."
			oPrint:Say( nLin, 0320, OEMTOANSI(Posicione("SB1", 1, xFilial("SB1") + G85->G85_CODPRD, "B1_DESC")), oFont11:oFont )
		EndIf
		G6L->(DbCloseArea())
	EndIf
EndIf

nLin+=25

If G84->G84_TPFAT <> '2'
	SA2->(dbSeek(xFilial("SA2",G85->G85_FILREF)+G3R->(G3R_FORNEC+G3R_LOJA)))

	DbSelectArea("G3S")
	G3S->(DbSetOrder(1)) //G3S_FILIAL + G3S_NUMID + G3S_IDITEM + G3S_NUMSEQ + G3S_CODPAX + G3S_CONORI

	If G3S->(DbSeek(xFilial("G3S",G85->G85_FILREF)+G85->G85_REGVEN+G85->G85_ITVEND+G85->G85_SEQIV))

		While G3S->(!Eof()) .And. (G85->G85_REGVEN + G85->G85_ITVEND + G85->G85_SEQIV) == (G3S->G3S_NUMID + G3S->G3S_IDITEM + G3S->G3S_NUMSEQ)
			If Empty(G3S->G3S_CONINU)
				
				//------------------------------------------------------------------------------------------
				// INFORMA«‘ES DO REEMBOLSO
				//------------------------------------------------------------------------------------------
				If G3Q->G3Q_OPERAC = '2'
					cAliasAux := TR13DdsSeg('R', xFilial("G4E", G85->G85_FILREF), G85->G85_REGVEN, G85->G85_ITVEND, G85->G85_SEQIV)
					If (cAliasAux)->(!EOF())
						If nLin+295 > nPgBreak
							oPrint:EndPage()
							nLin := TU13CAB(@oPrint,@nPagina)
						EndIf

						oPrint:Box( nLin, 0060, nLin+295, 2284,, )
						oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0057) + ":", oFont11N:oFont)  //"Produto"
						oPrint:Say( nLin	, 0600, SBM->BM_DESC			, oFont12:oFont )					
						oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0061) + ":", oFont11N:oFont)  //"PAX"
						oPrint:Say( nLin	, 0600, AllTrim(G3S->G3S_NOME)	, oFont12:oFont )
						oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0062) + ":", oFont11N:oFont)  //"Bilhete/Doc"
						oPrint:Say( nLin	, 0600, AllTrim(G3Q->G3Q_DOC) + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), "") + IIF(G3Q->G3Q_TPSEG == "1", " - " + R013Trecho(G3Q->G3Q_DOCORI), ""), oFont12:oFont)
						oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0095) + ":", oFont11N:oFont)  //"Data prev - Data Cred" //FALTA STRING FIXA
						oPrint:Say( nLin	, 0600, DtoC(SToD((cAliasAux)->G4E_DTPREV)) + " ñ " + DtoC(SToD((cAliasAux)->G4E_DTCRED)), oFont12:oFont)
						oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont)  //"Solicitante"
						oPrint:Say( nLin	, 0600, G3Q->G3Q_NOMESO			, oFont12:oFont )
						oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0065) + ":", oFont11N:oFont)  //"Emissor"
						oPrint:Say( nLin	, 0600, IIF( !lServProp, G3R->G3R_NOMREP, "")			, oFont12:oFont )
					EndIf
					(cAliasAux)->(DbCloseArea())
				Else
					cAliasAux := TR13DdsSeg(G3Q->G3Q_TPSEG, xFilial("G4E", G85->G85_FILREF), G85->G85_REGVEN, G85->G85_ITVEND, G85->G85_SEQIV)
					If (cAliasAux)->(!EOF())				
						Do Case 
							//------------------------------------------------------------------------------------------
							// INFORMA«‘ES DO AEREO
							//------------------------------------------------------------------------------------------
							Case G3Q->G3Q_TPSEG = '1'
								If nLin+295 > nPgBreak
									oPrint:EndPage()
									nLin := TU13CAB(@oPrint,@nPagina)
								EndIf
								cAliasAer	:= GetNextAlias()
								
								lSegAereo:= .F.
								If ItensArer(cAliasAer, xFilial("G3T",G85->G85_FILREF), G85->G85_REGVEN, G85->G85_ITVEND, G85->G85_SEQIV, G3S->G3S_CODPAX, @cDatas, @cTrechos)
									lSegAereo:= .T.
			 						oPrint:Box( nLin, 0060, nLin+320, 2284,, )				
														
									If nLin+320 > nPgBreak
										oPrint:EndPage()
										nLin := TU13CAB(@oPrint,@nPagina)
										
										oPrint:Line(nLin, 		0060, nLin+350, 0060,, )
										oPrint:Line(nLin, 		2286, nLin+350, 2286,, )
										oPrint:Line(nLin+350,	0060, nLin+350, 2286,, )												
									EndIf
									oPrint:Say( nLin+=50	, 0344, OEMTOANSI(STR0057) + ":", oFont11N:oFont)  //"Produto"
									oPrint:Say( nLin		, 0600, SBM->BM_DESC			, oFont12:oFont )
									oPrint:Say( nLin+=40	, 0344, OEMTOANSI(STR0061) + ":", oFont11N:oFont)  //"PAX"
									oPrint:Say( nLin		, 0600, AllTrim(G3S->G3S_NOME)  , oFont12:oFont )
									oPrint:Say( nLin+=45	, 0344, OEMTOANSI(STR0062) + ":", oFont11N:oFont)  //"Bilhete/Doc"
									oPrint:Say( nLin		, 0600, AllTrim(G3Q->G3Q_DOC) + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), "") + " ñ " + cTrechos, oFont12:oFont)															
									oPrint:Say( nLin+=45	, 0344, OEMTOANSI(STR0063) + ":",oFont11N:oFont )  //"Data In-Out"
									oPrint:Say( nLin		, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
									
									oPrint:Say( nLin+=45	, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont)  //"Solicitante"
									oPrint:Say( nLin		, 0600, G3Q->G3Q_NOMESO         , oFont12:oFont )
									oPrint:Say( nLin+=45	, 0344, OEMTOANSI(STR0065) + ":", oFont11N:oFont)  //"Emissor"
									oPrint:Say( nLin		, 0600, IIF( !lServProp, G3R->G3R_NOMREP, "")         , oFont12:oFont )								
																	
								EndIf				
							
							//------------------------------------------------------------------------------------------
							// INFORMA«‘ES DO HOTEL
							//------------------------------------------------------------------------------------------
							Case G3Q->G3Q_TPSEG = '2'
								If nLin+420 > nPgBreak
									oPrint:EndPage()
									nLin := TU13CAB(@oPrint,@nPagina)
								EndIf
			
								cDatas   := TR13DtInOut(G85->G85_PREFIX, G85->G85_NUMFAT, G85->G85_REGVEN, G85->G85_ITVEND, "%G3U_DTINI%", "%G3U_DTFIM%")
								nLinPula := (Round((Len(cDatas) / 99), 0) - 1) * 25
								oPrint:Box( nLin, 0060, nLin+420 + IIF(nLinPula > 0, nLinPula, 0), 2284,, )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0057) + ":", oFont11N:oFont)  //"Produto"//FAZER A STRING
								oPrint:Say( nLin	, 0600, SBM->BM_DESC			, oFont12:oFont )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0061) + ":", oFont11N:oFont)  //""PAX""
								oPrint:Say( nLin	, 0600, AllTrim(G3S->G3S_NOME)  , oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0068) + ":", oFont11N:oFont)  //"Voucher"
								oPrint:Say( nLin	, 0600, AllTrim(G3Q->G3Q_DOC) + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), "") + " ñ " + AllTrim((cAliasAux)->G3U_CIDHOT), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0063) + ":", oFont11N:oFont)  //"Data In-Out"
								oPrint:Say( nLin	, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
								
								While lQuebraData
									If Len(cDatas) > 99
										nLin += 25
										cDatas := AllTrim(SubStr(cDatas, 100))
										oPrint:Say( nLin, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
									Else
										lQuebraData := .F.	
									EndIf
								EndDo
								lQuebraData := .T.
			
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0069) + ":", oFont11N:oFont)  //"Di·rias"
								oPrint:Say( nLin	, 0600, AllTrim(Transform((cAliasAux)->G3U_QTDDIA, PesqPict("G3U", "G3U_QTDDIA"))), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0070) + ":", oFont11N:oFont)  //"Tipo Prod."
								oPrint:Say( nLin	, 0600, G3Q->G3Q_PROD + " ñ " + AllTrim(SB1->B1_DESC) + " (" + aTpProd[Val((cAliasAux)->G3U_TPPROD)] + ") ", oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0071) + ":", oFont11N:oFont)  //"Quantidade"
								oPrint:Say( nLin	, 0600, AllTrim(Transform((cAliasAux)->G3U_QTDPRD, PesqPict("G3U", "G3U_QTDPRD"))), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont)  //"Solicitante"
								oPrint:Say( nLin	, 0600, G3Q->G3Q_NOMESO			, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0065) + ":", oFont11N:oFont)  //"Emissor"
								oPrint:Say( nLin	, 0600, IIF( !lServProp, G3R->G3R_NOMREP, "") 		, oFont12:oFont )
	
							//------------------------------------------------------------------------------------------
							// INFORMA«‘ES DO CARRO
							//------------------------------------------------------------------------------------------
							Case G3Q->G3Q_TPSEG = '3'
								If nLin+375 > nPgBreak
									oPrint:EndPage()
									nLin := TU13CAB(@oPrint,@nPagina)
								EndIf
			
								cDatas   := TR13DtInOut(G85->G85_PREFIX, G85->G85_NUMFAT, G85->G85_REGVEN, G85->G85_ITVEND, "%G3V_DTINI%", "%G3V_DTFIM%")
								nLinPula := (Round((Len(cDatas) / 99), 0) - 1) * 25
								oPrint:Box( nLin, 0060, nLin+375 + IIF(nLinPula > 0, nLinPula, 0), 2284,, )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0057) + ":", oFont11N:oFont)  //"Produto"
								oPrint:Say( nLin	, 0600, SBM->BM_DESC			, oFont12:oFont )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0061) + ":", oFont11N:oFont)  //"PAX"
								oPrint:Say( nLin    , 0600, AllTrim(G3S->G3S_NOME)  , oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0068) + ":", oFont11N:oFont)  //"Voucher"
								oPrint:Say( nLin    , 0600, AllTrim(G3Q->G3Q_DOC) + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), "") + " ñ " + AllTrim((cAliasAux)->G3V_CIDRET), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0063) + ":", oFont11N:oFont)  //"Data In-Out"
								oPrint:Say( nLin	, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
								
								While lQuebraData
									If Len(cDatas) > 99
										nLin += 25
										cDatas := AllTrim(SubStr(cDatas, 100))
										oPrint:Say( nLin, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
									Else
										lQuebraData := .F.	
									EndIf
								EndDo
								lQuebraData := .T.
			
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0069) + ":", oFont11N:oFont)  //"Di·rias"
								oPrint:Say( nLin    , 0600, AllTrim(Transform((cAliasAux)->G3V_QTDDIA, PesqPict("G3V", "G3V_QTDDIA"))), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0071) + ":", oFont11N:oFont)  //"Quantidade"
								oPrint:Say( nLin    , 0600, AllTrim(Transform((cAliasAux)->G3V_QTDPRD, PesqPict("G3V", "G3V_QTDPRD"))), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont)  //"Solicitante"
								oPrint:Say( nLin    , 0600, G3Q->G3Q_NOMESO			, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0065) + ":", oFont11N:oFont)  //"Emissor"
								oPrint:Say( nLin    , 0600, IIF( !lServProp, G3R->G3R_NOMREP, "") 		, oFont12:oFont )
	
							//------------------------------------------------------------------------------------------
							// INFORMA«‘ES DO RODOVIARIO
							//------------------------------------------------------------------------------------------
							Case G3Q->G3Q_TPSEG = '4'
								If nLin+375 > nPgBreak
									oPrint:EndPage()
									nLin := TU13CAB(@oPrint,@nPagina)
								EndIf
			
								cDatas   := TR13DtInOut(G85->G85_PREFIX, G85->G85_NUMFAT, G85->G85_REGVEN, G85->G85_ITVEND, "%G3W_DTINI%", "%G3W_DTFIM%")
								nLinPula := (Round((Len(cDatas) / 99), 0) - 1) * 25
								oPrint:Box( nLin, 0060, nLin+375 + IIF(nLinPula > 0, nLinPula, 0), 2284,, )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0057) + ":"      , oFont11N:oFont)  //"Produto"
								oPrint:Say( nLin	, 0600, SBM->BM_DESC			      , oFont12:oFont )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0061) + ":"      , oFont11N:oFont)  //"PAX"
								oPrint:Say( nLin    , 0600, AllTrim(G3S->G3S_NOME)        , oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0068) + ":"      , oFont11N:oFont)  //"Voucher"
								oPrint:Say( nLin    , 0600, AllTrim(G3Q->G3Q_DOC) + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), ""), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0072) + ":"      , oFont11N:oFont)  //"Itiner·rio"
								oPrint:Say( nLin    , 0600, AllTrim(Posicione("G5S", 1, xFilial("G5S") + (cAliasAux)->G3W_CIDEMB, "G5S_CIDADE")) + " / " + AllTrim(Posicione("G5S", 1, xFilial("G5S") + (cAliasAux)->G3W_CIDDES, "G5S_CIDADE")), oFont12:oFont) 
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0073) + ":"      , oFont11N:oFont)  //"Categoria"
								oPrint:Say( nLin    , 0600, aCatBus[Val((cAliasAux)->G3W_CATBUS)], oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0063) + ":"      , oFont11N:oFont)  //"Data In-Out"
								oPrint:Say( nLin	, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont )
								
								While lQuebraData
									If Len(cDatas) > 99
										nLin += 25
										cDatas := AllTrim(SubStr(cDatas, 100))
										oPrint:Say( nLin, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
									Else
										lQuebraData := .F.	
									EndIf
								EndDo
								lQuebraData := .T.
			
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont)  //"Solicitante"
								oPrint:Say( nLin    , 0600, G3Q->G3Q_NOMESO			, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0065) + ":", oFont11N:oFont)  //"Emissor"
								oPrint:Say( nLin    , 0600, IIF( !lServProp, G3R->G3R_NOMREP, "") 		, oFont12:oFont )
	
							//------------------------------------------------------------------------------------------
							// INFORMA«‘ES DO TREM
							//------------------------------------------------------------------------------------------
							Case G3Q->G3Q_TPSEG = '6'
								If nLin+375 > nPgBreak
									oPrint:EndPage()
									nLin := TU13CAB(@oPrint,@nPagina)
								EndIf
			
								cDatas   := TR13DtInOut(G85->G85_PREFIX, G85->G85_NUMFAT, G85->G85_REGVEN, G85->G85_ITVEND, "%G3X_DTINI%", "%G3X_DTFIM%")
								nLinPula := (Round((Len(cDatas) / 99), 0) - 1) * 25
								oPrint:Box( nLin, 0060, nLin+375 + IIF(nLinPula > 0, nLinPula, 0), 2284,, )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0057) + ":", oFont11N:oFont)  //"Produto"
								oPrint:Say( nLin	, 0600, SBM->BM_DESC			, oFont12:oFont )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0061) + ":", oFont11N:oFont)  //"PAX"
								oPrint:Say( nLin    , 0600, AllTrim(G3S->G3S_NOME)	, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0068) + ":", oFont11N:oFont)  //"Voucher"
								oPrint:Say( nLin    , 0600, AllTrim(G3Q->G3Q_DOC) + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), ""), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0072) + ":", oFont11N:oFont)  //"Itiner·rio"
								oPrint:Say( nLin    , 0600, AllTrim((cAliasAux)->G3X_CIDEMB) + " / " + AllTrim((cAliasAux)->G3X_CIDDES), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0073) + ":", oFont11N:oFont)  //"Categoria"
								oPrint:Say( nLin    , 0600, AllTrim((cAliasAux)->G3X_CTTREM), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0063) + ":", oFont11N:oFont)  //"Data In-Out"
								oPrint:Say( nLin	, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
								
								While lQuebraData
									If Len(cDatas) > 99
										nLin += 25
										cDatas := AllTrim(SubStr(cDatas, 100))
										oPrint:Say( nLin, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
									Else
										lQuebraData := .F.	
									EndIf
								EndDo
								lQuebraData := .T.
			
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont)  //"Solicitante"
								oPrint:Say( nLin    , 0600, G3Q->G3Q_NOMESO			, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0065) + ":", oFont11N:oFont)  //"Emissor"
								oPrint:Say( nLin    , 0600, IIF( !lServProp, G3R->G3R_NOMREP, "") 		, oFont12:oFont )
	
							//------------------------------------------------------------------------------------------
							// INFORMA«‘ES DO CRUZEIRO
							//------------------------------------------------------------------------------------------
							Case G3Q->G3Q_TPSEG = '5'
								If nLin+420 > nPgBreak
									oPrint:EndPage()
									nLin := TU13CAB(@oPrint,@nPagina)
								EndIf
			
								G3Y->(DbGoTo((cAliasAux)->R_E_C_N_O_))
								cDatas   := TR13DtInOut(G85->G85_PREFIX, G85->G85_NUMFAT, G85->G85_REGVEN, G85->G85_ITVEND, "%G3Y_DTINI%", "%G3Y_DTFIM%")
								nLinPula := (Round((Len(cDatas) / 99), 0) - 1) * 25
								oPrint:Box( nLin, 0060, nLin+420 + IIF(nLinPula > 0, nLinPula, 0), 2284,, )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0057) + ":", oFont11N:oFont)  //"Produto"
								oPrint:Say( nLin	, 0600, SBM->BM_DESC			, oFont12:oFont )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0061) + ":", oFont11N:oFont)  //"PAX"
								oPrint:Say( nLin    , 0600, AllTrim(G3S->G3S_NOME)  , oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0068) + ":", oFont11N:oFont)  //"Voucher"
								oPrint:Say( nLin    , 0600, AllTrim(G3Q->G3Q_DOC) + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), ""), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0074) + ":", oFont11N:oFont)  //"Navio"
								oPrint:Say( nLin    , 0600, (cAliasAux)->G3Y_NOMNAV , oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0075) + ":", oFont11N:oFont)  //"DescriÁ„o"
								oPrint:Say( nLin    , 0600, SubStr(G3Y->G3Y_DESNAV, 01, 50), oFont12:oFont)
								oPrint:Say( nLin+=45, 0600, SubStr(G3Y->G3Y_DESNAV, 51, 50), oFont12:oFont) 			//ContinuaÁ„o DescriÁ„o
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0063) + ":", oFont11N:oFont)  //"Data In-Out"
								oPrint:Say( nLin	, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
								
								While lQuebraData
									If Len(cDatas) > 99
										nLin += 25
										cDatas := AllTrim(SubStr(cDatas, 100))
										oPrint:Say( nLin, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
									Else
										lQuebraData := .F.	
									EndIf
								EndDo
								lQuebraData := .T.
			
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont)  //"Solicitante"
								oPrint:Say( nLin    , 0600, G3Q->G3Q_NOMESO			, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0065) + ":", oFont11N:oFont)  //"Emissor"
								oPrint:Say( nLin    , 0600, IIF( !lServProp, G3R->G3R_NOMREP, "") 		, oFont12:oFont )
	
							//------------------------------------------------------------------------------------------
							// INFORMA«‘ES DO PACOTE
							//------------------------------------------------------------------------------------------
							Case G3Q->G3Q_TPSEG = 'A'
								If nLin+375 > nPgBreak
									oPrint:EndPage()
									nLin := TU13CAB(@oPrint,@nPagina)
								EndIf
			
								G3Z->(DbGoTo((cAliasAux)->R_E_C_N_O_))
								cDatas   := TR13DtInOut(G85->G85_PREFIX, G85->G85_NUMFAT, G85->G85_REGVEN, G85->G85_ITVEND, "%G3Z_DTINI%", "%G3Z_DTFIM%")
								nLinPula := (Round((Len(cDatas) / 99), 0) - 1) * 25
								oPrint:Box( nLin, 0060, nLin+375 + IIF(nLinPula > 0, nLinPula, 0), 2284,, )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0057) + ":", oFont11N:oFont)  //"Produto"
								oPrint:Say( nLin	, 0600, SBM->BM_DESC			, oFont12:oFont )	
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0061) + ":", oFont11N:oFont)  //""PAX""
								oPrint:Say( nLin    , 0600, AllTrim(G3S->G3S_NOME)	, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0068) + ":", oFont11N:oFont)  //"Voucher"
								oPrint:Say( nLin    , 0600, AllTrim(G3Q->G3Q_DOC) + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), ""), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0075) + ":", oFont11N:oFont)  //"DescriÁ„o"
								oPrint:Say( nLin    , 0600, SubStr(G3Z->G3Z_DESPAC, 01, 50),oFont12:oFont)
								oPrint:Say( nLin+=45, 0600, SubStr(G3Z->G3Z_DESPAC, 51, 50),oFont12:oFont)			//ContinuaÁ„o DescriÁ„o
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0063) + ":", oFont11N:oFont)  //"Data In-Out"
								oPrint:Say( nLin	, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
								
								While lQuebraData
									If Len(cDatas) > 99
										nLin += 25
										cDatas := AllTrim(SubStr(cDatas, 100))
										oPrint:Say( nLin, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
									Else
										lQuebraData := .F.	
									EndIf
								EndDo
								lQuebraData := .T.
			
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont)  //"Solicitante"
								oPrint:Say( nLin    , 0600, G3Q->G3Q_NOMESO			, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0065) + ":", oFont11N:oFont)  //"Emissor"
								oPrint:Say( nLin    , 0600, IIF( !lServProp, G3R->G3R_NOMREP, "") 		, oFont12:oFont )
	
							//------------------------------------------------------------------------------------------
							// INFORMA«‘ES DO TOUR
							//------------------------------------------------------------------------------------------
							Case G3Q->G3Q_TPSEG = '9'
								If nLin+330 > nPgBreak
									oPrint:EndPage()
									nLin := TU13CAB(@oPrint,@nPagina)
								EndIf
			
								cDatas   := TR13DtInOut(G85->G85_PREFIX, G85->G85_NUMFAT, G85->G85_REGVEN, G85->G85_ITVEND, "%G40_DTINI%", "%G40_DTFIM%")
								nLinPula := (Round((Len(cDatas) / 99), 0) - 1) * 25
								oPrint:Box( nLin, 0060, nLin+330 + IIF(nLinPula > 0, nLinPula, 0), 2284,, )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0057) + ":", oFont11N:oFont)  //"Produto"
								oPrint:Say( nLin	, 0600, SBM->BM_DESC			, oFont12:oFont )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0061) + ":", oFont11N:oFont)  //"PAX"
								oPrint:Say( nLin    , 0600, AllTrim(G3S->G3S_NOME)	, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0068) + ":", oFont11N:oFont)  //"Voucher"
								oPrint:Say( nLin    , 0600, AllTrim(G3Q->G3Q_DOC) + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), ""), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0076) + ":", oFont11N:oFont)  //"Nome Tour"
								oPrint:Say( nLin    , 0600, (cAliasAux)->G40_NMTOUR	, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0063) + ":", oFont11N:oFont)  //"Data In-Out"
								oPrint:Say( nLin	, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
								
								While lQuebraData
									If Len(cDatas) > 99
										nLin += 25
										cDatas := AllTrim(SubStr(cDatas, 100))
										oPrint:Say( nLin, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
									Else
										lQuebraData := .F.	
									EndIf
								EndDo
								lQuebraData := .T.
			
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont)  //"Solicitante"
								oPrint:Say( nLin    , 0600, G3Q->G3Q_NOMESO			, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0065)+":"	, oFont11N:oFont)  //"Emissor"
								oPrint:Say( nLin    , 0600, IIF( !lServProp, G3R->G3R_NOMREP, "") 		, oFont12:oFont )
	
							//------------------------------------------------------------------------------------------
							// INFORMA«‘ES DO SEGURO
							//------------------------------------------------------------------------------------------
							Case G3Q->G3Q_TPSEG = '8'
								If nLin+375 > nPgBreak
									oPrint:EndPage()
									nLin := TU13CAB(@oPrint,@nPagina)
								EndIf
			
								cDatas   := TR13DtInOut(G85->G85_PREFIX, G85->G85_NUMFAT, G85->G85_REGVEN, G85->G85_ITVEND, "%G41_DTINI%", "%G41_DTFIM%")
								nLinPula := (Round((Len(cDatas) / 99), 0) - 1) * 25
								oPrint:Box( nLin, 0060, nLin+375 + IIF(nLinPula > 0, nLinPula, 0), 2284,, )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0057) + ":", oFont11N:oFont)  //"Produto"
								oPrint:Say( nLin	, 0600, SBM->BM_DESC			, oFont12:oFont )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0061) + ":", oFont11N:oFont)  //"PAX"
								oPrint:Say( nLin    , 0600, AllTrim(G3S->G3S_NOME)	, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0068) + ":", oFont11N:oFont)  //"Voucher"
								oPrint:Say( nLin    , 0600, AllTrim(G3Q->G3Q_DOC) + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), ""), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0077) + ":", oFont11N:oFont)  //"Nome Plano"
								oPrint:Say( nLin    , 0600, (cAliasAux)->G41_PLSEGU	, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0078) + ":", oFont11N:oFont)  //"Apolice"
								oPrint:Say( nLin    , 0600, (cAliasAux)->G41_NUMAPO	, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0063) + ":", oFont11N:oFont)  //"Data In-Out"
								oPrint:Say( nLin	, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
								
								While lQuebraData
									If Len(cDatas) > 99
										nLin += 25
										cDatas := AllTrim(SubStr(cDatas, 100))
										oPrint:Say( nLin, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
									Else
										lQuebraData := .F.	
									EndIf
								EndDo
								lQuebraData := .T.
			
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont)  //"Solicitante"
								oPrint:Say( nLin    , 0600, G3Q->G3Q_NOMESO			, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0065) + ":", oFont11N:oFont)  //"Emissor"
								oPrint:Say( nLin    , 0600, IIF( !lServProp, G3R->G3R_NOMREP, "") 		, oFont12:oFont )
	
							//------------------------------------------------------------------------------------------
							// INFORMA«‘ES DO VISTO
							//------------------------------------------------------------------------------------------
							Case G3Q->G3Q_TPSEG = '7'
								If nLin+330 > nPgBreak
									oPrint:EndPage()
									nLin := TU13CAB(@oPrint,@nPagina)
								EndIf
			
								oPrint:Box( nLin, 0060, nLin+330, 2284,, )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0057) + ":", oFont11N:oFont)  //"Produto"
								oPrint:Say( nLin	, 0600, SBM->BM_DESC			, oFont12:oFont )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0061) + ":", oFont11N:oFont)  //"PAX"
								oPrint:Say( nLin    , 0600, AllTrim(G3S->G3S_NOME)	, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0068) + ":", oFont11N:oFont) //"Voucher"
								oPrint:Say( nLin    , 0600, AllTrim(G3Q->G3Q_DOC) + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), ""), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0081) + ":", oFont11N:oFont) //"Tipo Visto"
								oPrint:Say( nLin    , 0600, AllTrim( (Posicione("G4F",1,xFilial("G4F")+(cAliasAux)->G42_TPVIST, "G4F_DESCR")) )	, oFont12:oFont )								
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0080) + ":", oFont11N:oFont) //"PaÌs"
								oPrint:Say( nLin    , 0600, AllTrim( (Posicione("SYA",1,xFilial("SYA")+(cAliasAux)->G42_PAIS, "YA_DESCR")) )	, oFont12:oFont )
								 
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont) //"Solicitante"
								oPrint:Say( nLin    , 0600, G3Q->G3Q_NOMESO			, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0065) + ":", oFont11N:oFont) //"Emissor"
								oPrint:Say( nLin    , 0600, IIF( !lServProp, G3R->G3R_NOMREP, "") 		, oFont12:oFont )
	
							//------------------------------------------------------------------------------------------
							// INFORMA«‘ES DO OUTROS
							//------------------------------------------------------------------------------------------
							Case G3Q->G3Q_TPSEG = 'B'
								If nLin+375 > nPgBreak
									oPrint:EndPage()
									nLin := TU13CAB(@oPrint,@nPagina)
								EndIf
			
								G43->(DbGoTo((cAliasAux)->R_E_C_N_O_))
								cDatas   := TR13DtInOut(G85->G85_PREFIX, G85->G85_NUMFAT, G85->G85_REGVEN, G85->G85_ITVEND, "%G43_DTINI%", "%G43_DTFIM%")
								nLinPula := (Round((Len(cDatas) / 99), 0) - 1) * 25
								oPrint:Box( nLin, 0060, nLin+375 + IIF(nLinPula > 0, nLinPula, 0), 2284,, )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0057) + ":", oFont11N:oFont)  //"Produto"
								oPrint:Say( nLin	, 0600, SBM->BM_DESC			, oFont12:oFont )
								oPrint:Say( nLin+=40, 0344, OEMTOANSI(STR0061) + ":", oFont11N:oFont)  //"PAX"
								oPrint:Say( nLin    , 0600, AllTrim(G3S->G3S_NOME)	, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0068) + ":", oFont11N:oFont)  //"Voucher"
								oPrint:Say( nLin    , 0600, AllTrim(G3Q->G3Q_DOC)  + IIF( !lServProp, " ñ " + AllTrim(SA2->A2_NREDUZ), ""), oFont12:oFont)
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0075) + ":", oFont11N:oFont)  //"DescriÁ„o"
								oPrint:Say( nLin    , 0600, AllTrim(G3Q->G3Q_PROD) + " ñ " + AllTrim(SB1->B1_DESC)  , oFont12:oFont)
								
								aObsG43 := CabeMemo(G43->G43_DSSERV, 7060, "oFont12:oFont", oPrint)
								If Len(aObsG43) > 0
									nLin+=45
									For nG43l := 1 to Len(aObsG43)
										oPrint:Say( nLin, 0600, aObsG43[nG43l],oFont12:oFont,, )//ContinuaÁ„o DescriÁ„o
										nLin+=45
									Next
								Endif
			
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0063) + ":", oFont11N:oFont)  //"Data In-Out"
								oPrint:Say( nLin	, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
								
								While lQuebraData
									If Len(cDatas) > 99
										nLin += 25
										cDatas := AllTrim(SubStr(cDatas, 100))
										oPrint:Say( nLin, 0600, AllTrim(SubStr(cDatas, 1, 99)), oFont12:oFont)
									Else
										lQuebraData := .F.	
									EndIf
								EndDo
								lQuebraData := .T.
			
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0064) + ":", oFont11N:oFont)  //"Solicitante"
								oPrint:Say( nLin    , 0600, G3Q->G3Q_NOMESO			, oFont12:oFont )
								oPrint:Say( nLin+=45, 0344, OEMTOANSI(STR0065) + ":", oFont11N:oFont)  //"Emissor"
								oPrint:Say( nLin    , 0600, IIF( !lServProp, G3R->G3R_NOMREP, "") 		, oFont12:oFont )
						EndCase
					EndIf
					(cAliasAux)->(DbCloseArea())
				EndIf
				
				nLin+=25
				
				cAliasEntA := GetNextAlias()
				BeginSQL Alias cAliasEntA

					SELECT		G4B.G4B_TITUL
								,G4B.G4B_ITEM
								,G4B.G4B_DESENT
					FROM		%Table:G4B% G4B
					INNER JOIN 	%Table:G3F% G3F
					ON 			G3F.G3F_CODCLI 	= G4B.G4B_CLIENT
					AND 		G3F.G3F_LOJA 	= G4B.G4B_LOJA
					AND			G3F.G3F_TIPO 	= G4B.G4B_TPENT
					AND			G3F.%NotDel%
					WHERE		G4B.G4B_FILIAL 	= %Exp:G3S->G3S_FILIAL%
					AND			G4B.G4B_NUMID 	= %Exp:G3S->G3S_NUMID%
					AND			G4B.G4B_IDITEM 	= %Exp:G3S->G3S_IDITEM%
					AND			G4B.G4B_NUMSEQ 	= %Exp:G3S->G3S_NUMSEQ%
					AND			G4B.G4B_CODPAX 	= %Exp:G3S->G3S_CODPAX%
					AND			G3F.G3F_IMPFAT 	= '1'
					AND			G4B.G4B_CONINU 	= %Exp:cConinu%
					AND			G4B.%NotDel%

				EndSQL

				(cAliasEntA)->(dbGoTop())

				If (cAliasEntA)->(!Eof())
					If G3Q->G3Q_TPSEG <> '1' .OR. (G3Q->G3Q_TPSEG = '1' .AND. lSegAereo)
						While (cAliasEntA)->(!Eof())
	
							If nLin+45 > nPgBreak
								oPrint:Line(nLin, 0060, nLin, 2286,, )
								oPrint:EndPage()
								nLin := TU13CAB(@oPrint,@nPagina)
								nLin+=25
								oPrint:Line(nLin, 0060, nLin, 2286,, )
							EndIf
	
							oPrint:Line(nLin, 0060, nLin+45, 0060,, )
							oPrint:Line(nLin, 2286, nLin+45, 2286,, )
							nLin+=45
							
							//Para fonte Courrier 12. Cabe 86 caracter de Item e DescriÁ„o da entidade
							oPrint:Say( nLin, 0080, Replicate(" ",nTamG4BTit-Len(AllTrim((cAliasEntA)->G4B_TITUL)))+AllTrim((cAliasEntA)->G4B_TITUL)+":",oFont12:oFont  )
							oPrint:Say( nLin, 0810, SubStr(AllTrim((cAliasEntA)->G4B_ITEM)+" - "+ AllTrim((cAliasEntA)->G4B_DESENT),1,86) 	,oFont12:oFont  )
							
							If Len(AllTrim((cAliasEntA)->G4B_ITEM)+" - "+ AllTrim((cAliasEntA)->G4B_DESENT)) > 86	
								oPrint:Line(nLin, 0060, nLin+20, 0060,, )
								oPrint:Line(nLin, 2286, nLin+20, 2286,, )
								nLin+=20
								oPrint:Say( nLin, 0810, SubStr(AllTrim((cAliasEntA)->G4B_ITEM)+" - "+ AllTrim((cAliasEntA)->G4B_DESENT),87) 	,oFont12:oFont  )
							EndIf
	
	
							(cAliasEntA)->(DbSkip())
						EndDo
						oPrint:Line(nLin, 0060, nLin+25, 0060,, )
						oPrint:Line(nLin, 2286, nLin+25, 2286,, )
						nLin+=25
						oPrint:Line(nLin, 0060, nLin, 2286,, )
					EndIf
				EndIf

				(cAliasEntA)->(dbCloseArea())

			EndIf
			G3S->(DbSkip())
		EndDo
	EndIf
ElseIf !Empty(aTot[8]) .And. !Empty(aTot[9]) //Se for fatura de apuraÁ„o imprime somente uma entidade adicional
	If nLin+70 > nPgBreak

		oPrint:EndPage()
		nLin := TU13CAB(@oPrint,@nPagina)

	EndIf

	oPrint:Box( nLin, 0060, nLin+70, 2284 )
	nLin+=45

	oPrint:Say( nLin, 0324, AllTrim(Posicione("G3E",1,xFilial("G3E")+aTot[8],"G3E_DESCR"))+":" 	,oFont11N:oFont  )
	oPrint:Say( nLin, 1112, AllTrim(aTot[9])+" - "+ AllTrim(Posicione("G3G",1,xFilial("G3G")+G81->G81_CLIENT+G81->G81_LOJA+aTot[8]+aTot[9],"G3G_DESCR")) ,oFont12:oFont  )
	nLin+=25

EndIf

RestArea(aAreaG3S)
RestArea(aAreaSA2)
nLin+=25

Return(nLin)


Static Function R013Trecho(cDocOrigem)
Local cTrecho := ''
Local cAliasG3Q := GetNextAlias()

	BeginSQL Alias cAliasG3Q

		SELECT     G3Q.G3Q_DOC, G3Q.G3Q_DOCORI,G3T.G3T_TERORI,G3T.G3T_TERDST
		FROM         %Table:G3T% G3T INNER JOIN %Table:G3Q% G3Q ON 
			G3T.G3T_FILIAL = G3Q.G3Q_FILIAL 
			AND G3T.G3T_NUMID = G3Q.G3Q_NUMID 
			AND G3T.G3T_IDITEM = G3Q.G3Q_IDITEM 
			AND G3T.G3T_NUMSEQ = G3Q.G3Q_NUMSEQ
		WHERE
			G3Q.G3Q_FILIAL 	= %xFilial:G3Q% AND
			G3Q.%NotDel% AND
			G3Q.G3Q_DOC = %Exp:cDocOrigem%
	EndSQL
	 
	(cAliasG3Q)->(dbGoTop())

	If (cAliasG3Q)->(!Eof())
		cTrecho := (cAliasG3Q)->G3T_TERORI +" - "+(cAliasG3Q)->G3T_TERDST
	EndIf

	(cAliasG3Q)->(dbCloseArea())


Return cTrecho

//-------------------------------------------------------------------
/*/{Protheus.doc} TR013CalcSub() 
FunÁ„o para efetuar o c·lculo de subtraÁ„o do repasse do total da 
fatura, levando em consideraÁ„o os valores negativos

@author Fernando Radu Muscalu
@since†14/10/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function TR013CalcSub(nTotalFat,nRepasse)

Local nTotalPos		:= 0
Local nRepassePos	:= 0
Local nTotal		:= 0
		
If ( nTotalFat < 0 )
	nTotalPos := ( nTotalFat * (-1) )
Else
	nTotalPos := nTotalFat	
EndIf 	

If ( nRepasse < 0 )
	nRepassePos := ( nRepasse * (-1) )
Else
	nRepassePos := nRepasse	 
EndIf

If ( nTotalPos > nRepassePos )
	
	If ( nTotalFat < 0 .And. nRepasse > 0 )
		nTotal := nTotalPos - nRepassePos
		nTotal *= -1
	ElseIf ( nTotalFat < 0 .And. nRepasse < 0 )
		nTotal := nTotalPos + nRepassePos	
	 	nTotal *= -1
	Else
	 	nTotal := nTotalPos - nRepassePos
	Endif
	 	
ElseIf ( nRepassePos > nTotalPos )

	If ( nRepasse < 0 .And. nTotalFat > 0 )
		nTotal := nRepassePos - nTotalPos
		nTotal *= -1
	ElseIf ( nRepasse < 0 .And. nTotalFat < 0 )
		nTotal := nRepassePos + nTotalPos
		nTotal *= -1
	Else	
		nTotal := nRepassePos + nTotalPos
	Endif
		 
EndIf

Return(nTotal)		


//-------------------------------------------------------------------
/*/{Protheus.doc} DescEnt() 
FunÁ„o para consulta de Entidade Adicional utilizada
@author Totvs
@since†17/02/2017
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function DescEnt(cFilIdItem,cSeq,cCodEAD)
Local cAliasG4B	:= GetNextAlias()
Local cFilialG4B	:= SUBSTR(cFilIdItem,1,TAMSX3('G4B_FILIAL')[1])
Local cID 			:= SUBSTR(cFilIdItem,TAMSX3('G4B_FILIAL')[1]+1,TAMSX3('G4B_NUMID')[1])
Local cItem		:= SUBSTR(cFilIdItem,TAMSX3('G4B_FILIAL')[1]+TAMSX3('G4B_NUMID')[1]+1,TAMSX3('G4B_IDITEM')[1])
Local cRet			:= ''
Local cConinu   	:= Space(TamSx3("G4C_CONINU")[1])

BeginSQL Alias cAliasG4B

	SELECT
		G4B_ITEM
	FROM
		%Table:G4B% G4B
	WHERE	
			G4B.G4B_FILIAL = %Exp:cFilialG4B%
			AND G4B.G4B_NUMID = %Exp:cID%
			AND G4B.G4B_IDITEM = %Exp:cItem%
			AND G4B.G4B_NUMSEQ = %Exp:cSeq%
			AND G4B.G4B_TPENT = %Exp:cCodEAD%
			AND G4B.G4B_CONINU = %Exp:cConinu%
		AND	G4B.%NotDel%

EndSQL

(cAliasG4B)->(dbGoTop())

If (cAliasG4B)->(!Eof())
	cRet := (cAliasG4B)->G4B_ITEM
EndIf

(cAliasG4B)->(dbCloseArea())


Return cRet

Static Function CabeMemo(cOriObs, nTamPixels, cFont, oPrint) 

	Local aRetObs      := {}
	Local cOBS         := Upper(cOriObs)
	Local nTamObs      := Len(cOBS)
	Local nPosObs      := 0
	Local cLinObs      := ""
	Local cCR          := Chr(13)
	Local cLF          := Chr(10)
	Local nQtdArray    := Ceiling(nTamObs/95)
	Local nArray       := 1
	DEFAULT nTamPixels := 7060
	DEFAULT cFont      := "oFont12"

	For nArray := 1 to nQtdArray

		For nPosObs := 1 To nTamObs

			If Len(aRetObs) == 5		
				Exit
			EndIf

			cAtuCar := SubStr(cOBS, nPosObs, 1)
	
			If cAtuCar == cCR .or. cAtuCar == cLF
				If SubStr(cOBS, nPosObs + 1, 1) == cLF
					nPosObs += 1
					cAtuCar := SubStr(cOBS, nPosObs, 1)
				EndIf

				If !Empty(AllTrim(cLinObs))			
					AAdd(aRetObs, StrTran(StrTran(AllTrim(cLinObs), cCR, "" ), cLF,"" ))				
					cLinObs := ""				
				EndIf
			EndIf

			If cAtuCar <> cCR .and. cAtuCar <> cLF .and. cAtuCar <> cCR + cLF
				cLinObs += cAtuCar
			EndIf

			If oPrint:GetTextWidth(AllTrim(cLinObs), &(cFont) ) > nTamPixels
				If !Empty(AllTrim(cLinObs))
					AAdd(aRetObs, SubStr(AllTrim(cLinObs), 1, Len(AllTrim(cLinObs))-1))
					If nPosObs > 0
						nPosObs -= 1
					EndIf
					cLinObs := ""
				EndIf
			EndIf

		Next

		If cLinObs <> "" 
			AAdd(aRetObs, SubStr(AllTrim(cLinObs), 1, Len(AllTrim(cLinObs))))
			Exit
		Endif 

	Next
Return(aRetObs)

//-------------------------------------------------------------------
/*/{Protheus.doc} TR13DtInOut() 
FunÁ„o para retornar as datas de IN/OUT dos IVs faturados
@author Totvs
@since†17/02/2017
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function TR13DtInOut(cPrefix, cNumFat, cNumId, cIdItem, cDataIni, cDataFim)

Local aArea   := GetArea()
Local cAlias  := GetNextAlias()
Local cDatas  := ""
Local cConinu := Space(TamSx3("G4C_CONINU")[1])

BeginSQL Alias cAlias
	COLUMN INICIAL AS DATE
	COLUMN FINAL   AS DATE

	SELECT DISTINCT %Exp:cDataIni% INICIAL, %Exp:cDataFim% FINAL
	FROM %Table:G85% G85
	INNER JOIN %Table:G3Q% G3Q ON G3Q_FILIAL = G85_FILREF AND
								  G3Q_NUMID  = G85_REGVEN AND
								  G3Q_IDITEM = G85_ITVEND AND
								  G3Q_NUMSEQ = G85_SEQIV  AND
								  G3Q.%NotDel%
	LEFT JOIN %Table:G3T% G3T ON  G3T_FILIAL = G3Q_FILIAL AND
							      G3T_NUMID  = G3Q_NUMID  AND
							      G3T_IDITEM = G3Q_IDITEM AND
							      G3T_NUMSEQ = G3Q_NUMSEQ AND
								  G3T_CONINU = G3Q_CONINU AND
							      G3T.%NotDel%
	LEFT JOIN %Table:G3U% G3U ON  G3U_FILIAL = G3Q_FILIAL AND
							      G3U_NUMID  = G3Q_NUMID  AND
							      G3U_IDITEM = G3Q_IDITEM AND
							      G3U_NUMSEQ = G3Q_NUMSEQ AND
								  G3U_CONINU = G3Q_CONINU AND
							      G3U.%NotDel%
	LEFT JOIN %Table:G3V% G3V ON  G3V_FILIAL = G3Q_FILIAL AND
							      G3V_NUMID  = G3Q_NUMID  AND
							      G3V_IDITEM = G3Q_IDITEM AND
							      G3V_NUMSEQ = G3Q_NUMSEQ AND
								  G3V_CONINU = G3Q_CONINU AND
							      G3V.%NotDel%
	LEFT JOIN %Table:G3W% G3W ON  G3W_FILIAL = G3Q_FILIAL AND
							      G3W_NUMID  = G3Q_NUMID  AND
							      G3W_IDITEM = G3Q_IDITEM AND
							      G3W_NUMSEQ = G3Q_NUMSEQ AND
								  G3W_CONINU = G3Q_CONINU AND
							      G3W.%NotDel%
	LEFT JOIN %Table:G3X% G3X ON  G3X_FILIAL = G3Q_FILIAL AND
							      G3X_NUMID  = G3Q_NUMID  AND
							      G3X_IDITEM = G3Q_IDITEM AND
							      G3X_NUMSEQ = G3Q_NUMSEQ AND
								  G3X_CONINU = G3Q_CONINU AND
							      G3X.%NotDel%
	LEFT JOIN %Table:G3Y% G3Y ON  G3Y_FILIAL = G3Q_FILIAL AND
							      G3Y_NUMID  = G3Q_NUMID  AND
							      G3Y_IDITEM = G3Q_IDITEM AND
							      G3Y_NUMSEQ = G3Q_NUMSEQ AND
								  G3Y_CONINU = G3Q_CONINU AND
							      G3Y.%NotDel%
	LEFT JOIN %Table:G3Z% G3Z ON  G3Z_FILIAL = G3Q_FILIAL AND
							      G3Z_NUMID  = G3Q_NUMID  AND
							      G3Z_IDITEM = G3Q_IDITEM AND
							      G3Z_NUMSEQ = G3Q_NUMSEQ AND
								  G3Z_CONINU = G3Q_CONINU AND
							      G3Z.%NotDel%
	LEFT JOIN %Table:G40% G40 ON  G40_FILIAL = G3Q_FILIAL AND
							      G40_NUMID  = G3Q_NUMID  AND
							      G40_IDITEM = G3Q_IDITEM AND
							      G40_NUMSEQ = G3Q_NUMSEQ AND
								  G40_CONINU = G3Q_CONINU AND
							      G40.%NotDel%
	LEFT JOIN %Table:G41% G41 ON  G41_FILIAL = G3Q_FILIAL AND
							      G41_NUMID  = G3Q_NUMID  AND
							      G41_IDITEM = G3Q_IDITEM AND
							      G41_NUMSEQ = G3Q_NUMSEQ AND
								  G41_CONINU = G3Q_CONINU AND
							      G41.%NotDel%
	LEFT JOIN %Table:G43% G43 ON  G43_FILIAL = G3Q_FILIAL AND
							      G43_NUMID  = G3Q_NUMID  AND
							      G43_IDITEM = G3Q_IDITEM AND
							      G43_NUMSEQ = G3Q_NUMSEQ AND
								  G43_CONINU = G3Q_CONINU AND
							      G43.%NotDel%
	WHERE G85_FILIAL = %xFilial:G85% AND
	      G85_PREFIX = %Exp:cPrefix% AND
	      G85_NUMFAT = %Exp:cNumFat% AND
	      G85_REGVEN = %Exp:cNumId%  AND
	      G85_ITVEND = %Exp:cIdItem% AND
		  G3Q_CONINU = %Exp:cConinu% AND
	      G3Q_STATUS < '3' AND 
	      G3Q_ACERTO = '2' AND
	      G85.%NotDel% 
							 
EndSQL

While (cAlias)->(!EOF())
	cDatas += DtoC((cAlias)->INICIAL) + " - " + DtoC((cAlias)->FINAL) 
	(cAlias)->(DbSkip())
	If (cAlias)->(!EOF())
		cDatas += ", "
	EndIf
EndDo
(cAlias)->(DbCloseArea())

RestArea(aArea)

Return cDatas

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TR13DdsSeg

FunÁ„o que retorna Alias com dados do segmento a ser impresso

@sample 	TR13DdsSeg()
@param		cTpSeg  - String - cÛdigo do segmento
			cFilRv  - String - filial do RV 
			cNumID  - String - cÛdigo do RV
			cIdItem - String - cÛdigo do IV
			cNumSeq - String - cÛdigo sequencia do IV
@author 	Thiago Tavares
@since 		15/12/2017
@version 	12.1.17
/*/
//+----------------------------------------------------------------------------------------
Static Function TR13DdsSeg(cTpSeg, cFilRV, cNumID, cIdItem, cNumSeq)

Local cAliasQry := GetNextAlias() 
Local cQuery    := ''
Local aTabSeg   := {{'1', 'G3T'}, {'2', 'G3U'}, {'3', 'G3V'}, {'4', 'G3W'}, {'5', 'G3Y'}, {'6', 'G3X'}, {'7', 'G42'}, {'8', 'G41'}, {'9', 'G40'}, {'A', 'G3Z'}, {'B', 'G43'}, {'R', 'G4E'}}
Local nPos      := 0
Local cConinu   := Space(TamSx3("G4C_CONINU")[1])

If (nPos := aScan(aTabSeg, {|x| x[1] == cTpSeg}))
	cQuery := I18N("SELECT * FROM " + RetSQLName(aTabSeg[nPos][2]) + " WHERE #1_FILIAL = '" + cFilRV + "' AND #1_NUMID = '" + cNumID + "' AND #1_IDITEM = '" + cIdItem + "' AND #1_NUMSEQ = '" + cNumSeq + "' AND #1_CONINU = '" + cConinu + "' AND D_E_L_E_T_ <> '*'", {aTabSeg[nPos][2]})
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TCGenQry(, , cQuery), cAliasQry, .F., .T.)
	DbSelectArea(cAliasQry)
EndIf

Return cAliasQry



/*/{Protheus.doc} ItensArer
(long_description)
@type function
@author osmar.junior
@since 31/01/2018
@version 1.0
@param cFilialAux, character, (DescriÁ„o do par‚metro)
@param cREGVEN, character, (DescriÁ„o do par‚metro)
@param cITVEND, character, (DescriÁ„o do par‚metro)
@param cSEQIV, character, (DescriÁ„o do par‚metro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ItensArer( cAliasAer, cFilialAux, cREGVEN, cITVEND, cSEQIV,cPax, cDatas, cTrechos)
Local lRet := .F.
Local cDataFim := ''

	cDatas := ''
	cTrechos := ''
	
	BeginSql Alias cAliasAer
		column G3T_DTSAID as Date
		column G3T_DTCHEG as Date
		
		SELECT G3T_DTSAID,G3T_DTCHEG,G3T_TERORI,G3T_TERDST
		 FROM %Table:G3T%
		WHERE 
		G3T_FILIAL = %Exp:cFilialAux% AND
		G3T_NUMID  = %Exp:cREGVEN% AND
		G3T_IDITEM = %Exp:cITVEND% AND   
		G3T_NUMSEQ = %Exp:cSEQIV% AND        
		G3T_CODPAX = %Exp:cPax% AND 
		G3T_CONINU = '' AND
		%notDel%
		ORDER BY G3T_FILIAL,G3T_NUMID,G3T_IDITEM,G3T_NUMSEQ,G3T_ID
	EndSql
		
	If (cAliasAer)->( !EOF() )
		lRet 	:= .T.
		cDatas 	:= 	DtoC((cAliasAer)->G3T_DTSAID)
		While (cAliasAer)->(!Eof())	
			cTrechos += AllTrim((cAliasAer)->G3T_TERORI) + "/" + AllTrim((cAliasAer)->G3T_TERDST)+ ' | '
			cDataFim := DtoC((cAliasAer)->G3T_DTCHEG)
			(cAliasAer)->(DbSkip()) 
		EndDo
		cDatas 		+= " - " + cDataFim	
        cTrechos 	:= SUBSTR(cTrechos, 1, RAT("|", cTrechos)-1)
					
	EndIf
	
	(cAliasAer)->( dbCloseArea() )	


Return lRet