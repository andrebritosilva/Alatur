#Include "PROTHEUS.CH"
#Include "FWBROWSE.CH"
#Include "RPTDEF.CH"
#Include "TOPCONN.CH"
#Include "TBICONN.CH"

// #########################################################################################
// Projeto: 11.90
// Modulo : Financeiro
// Fonte  : FINX999.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 30/08/13 | Marcos Berto	    | Impressao de Boleto
// #########################################################################################
User Function FINX99()

Local cMark := GetMark()
Local cAliasQry := ""  
Local cAliasQry2 := ""  
Local oPrint
Local oMainWnd

//Atualiza o grupo de perguntas do rdmake
SX1FINX999()

//Exibe o grupo de perguntas
If Pergunte("FINX999",.T.)
	
	//Monta a tabela temporária com os dados parametrizados
	cAliasQry2 := _Tmp()
	
	If !(cAliasQry2)->(Bof()) .Or. !(cAliasQry2)->(Eof())
		FINX999Sel(cAliasQry2,cMark)
		
		(cAliasQry2)->(dbGoTop())
		
		//Define a tela onde será impressa a visualização
		DEFINE DIALOG oMainWnd TITLE "Boleto" FROM 0,0 TO 800,600 PIXEL
		
		oPrint := FWMsPrinter():New("bol_" + DToS(dDataBase), IMP_PDF, .T., "\system", .F./*lDisabeSetup*/, .T., , , , , .F., .T., )
		oPrint:SetPortrait()
		
		While !(cAliasQry2)->(Eof())
			If (cAliasQry2)->E1_OK == cMark
				_cQuery := "UPDATE " +RetSqlName("SE1")
				_cQuery += " SET E1_PORTADO= '"+MV_PAR17+"' "
				_cQuery += " , E1_AGEDEP  = '"+MV_PAR18+"' "
				_cQuery += " , E1_CONTA  = '"+MV_PAR19+"' "
				_cQuery += " where E1_FILIAL = '"+XFILIAL("SE1")+"' "
				_cQuery += " AND E1_PREFIXO   = '"+ALLTRIM((cAliasQry2)->E1_PREFIXO) +"' "
				_cQuery += " AND E1_NUM  = '"+ALLTRIM((cAliasQry2)->E1_NUM)+"' "
				_cQuery += " AND E1_PARCELA  = '"+ALLTRIM((cAliasQry2)->E1_PARCELA)+"' "
				_cQuery += " AND E1_CLIENTE  = '"+ALLTRIM((cAliasQry2)->A1_COD)+"' "
				_cQuery += " AND  E1_LOJA = '"+ALLTRIM((cAliasQry2)->A1_LOJA)+"' "
				_cQuery += " AND E1_PORTADO= '' "
				_cQuery += " AND E1_AGEDEP  = '' "
				_cQuery += " AND E1_CONTA  = '' "		
				_cQuery += " AND  D_E_L_E_T_ = '' "
				_cQuery += " AND E1_SALDO >	0 "
				TcSqlExec(_cQuery) 
				
				cAliasQry := _Tmp2(cAliasQry2)
				U_FINX999Imp(oPrint,cAliasQry)   
				(cAliasQry)->(dbCloseArea())
			EndIf
			(cAliasQry2)->(dbSkip())
		EndDo
		
		oPrint:Preview()
	Else
		MsgAlert("Não há títulos disponíveis para a emissão do(s) boleto(s)."+CRLF+"Verifique os parâmetros informados e emita novamente a boleto.", "Atenção")
		(cAliasQry2)->(dbCloseArea())
		RETURN
	EndIf
	
	(cAliasQry2)->(dbCloseArea())
	
EndIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999Imp

Monta e Imprime o Boleto

@author    TOTVS
@version   11.90
@since     06/09/13

//------------------------------------------------------------------------------------------
/*/
USER Function FINX999Imp(oPrint,cAliasQry,_cMenBol)

Local aDados	:= {}
Local cBanco	:= ""
Local cImagem	:= ""
Local cNumBco	:= ""
Local cCart		:= ""
Local cMsgLn1	:= ""
Local cMsgLn2	:= ""
Local cMsgLn3	:= ""
Local cMsgLn4	:= ""
Local cMsgLn5	:= ""
Local cPictNN	:= ""
Local nVlrAbat	:= 0
Local nI		:= 0
Local cCodEmp   := ""
Local nTotPCC   := 0 
//Incluido Ronaldo Bicudo - 24/04/2017
Local nPercMul	:= SUPERGETMV("MV_LJMULTA", .T. , 5 )   //GetMv("MV_LJMULTA") //valor percentual em multa
Local nPercMJ	:= SUPERGETMV("MV_LJJUROS" , .T. , 0.03 )//GetMv("MV_LJUROS") //valor percentual em juros/mora
Local nJuros	:= 0
Local nMulta	:= 0
Local nTotJM	:= 0 //Valor total de juros/mora + multa
Local nDias		:= 0 //Quantidade de dias para calculo de Juros/Mora
Local aPropImg	:= {330,110}
//Fim
Local cTempSA1	:= GetNextAlias()

BeginSql Alias cTempSA1
	SELECT E1_FILIAL,E1_PORTADO,E1_AGEDEP,E1_CONTA
	FROM %Table:SE1% SE1 (NOLOCK)
	WHERE SE1.E1_FILIAL	= %xFilial:SE1%
   	AND SE1.E1_PREFIXO	= %Exp:(cAliasQry)->E1_PREFIXO%
   	AND SE1.E1_NUM		= %Exp:(cAliasQry)->E1_NUM%
   	AND SE1.E1_PARCELA	= %Exp:(cAliasQry)->E1_PARCELA%
   	AND SE1.E1_TIPO		= %Exp:(cAliasQry)->E1_TIPO%
	AND SE1.%NotDel%
EndSql

//DbSelectArea("SE1")
//DbSetOrder(1)
//DbSeek(xFilial("SE1")+(cAliasQry)->E1_PREFIXO+(cAliasQry)->E1_NUM+(cAliasQry)->E1_PARCELA+(cAliasQry)->E1_TIPO)
DbSelectArea("SEE")
DbSetOrder(1)
//SEE->(DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)+MV_PAR20))
SEE->(DbSeek(xFilial("SEE")+(cTempSA1)->(E1_PORTADO+E1_AGEDEP+E1_CONTA)+MV_PAR20))

cCodEmp   :=  SEE->EE_CODEMP

(cTempSA1)->(dbCloseArea())

DEFAULT cAliasQry := ""

cBanco := (cAliasQry)->A6_COD

cImagem := "\data\logos\"

//Incluido Ronaldo Bicudo / Totvs - 09/05/2017
//If Alltrim(cAliasQry)->E1_XCOBJM <> '2' //Não cobra Multa e nem Juros/Mora
	If (cAliasQry)->E1_XMULTA > 0 
		nPercMul := (cAliasQry)->E1_XMULTA
	ElseIf (cAliasQry)->A1_XMULTA > 0 
		nPercMul := (cAliasQry)->A1_XMULTA
	EndIf
//EndIf
//FIM

Do Case
	Case cBanco == "237"
		
		cImagem 	+= "bradesco.bmp"
		cNumBco 	:= "237-2"
		cCart		:= SEE->EE_CODCART //"09"
		cMsgLn1		:= ALLTRIM(SEE->EE_FORMEN1) //"Pagável preferencialmente nas agências do Banco Bradesco e Bradesco Expresso" 								//Alterar conforme necessidade do cliente
		cMsgLn2		:= ALLTRIM(SEE->EE_FORMEN2)																		//Alterar conforme necessidade do cliente
		cMsgLn3		:= ALLTRIM(SEE->EE_FOREXT1) //"Juros: após vencto. cobrar R$ 0,41 ao dia."
		cMsgLn4 	:= ALLTRIM(SEE->EE_FOREXT2)
		cMsgLn5 	:= IIf(!Empty(_cMenBol),_cMenBol,'')//Exibe mensagem no boleto: "Sujeito a Retenção de PCC" 
		aPropImg	:= {290,120}
		cPictNN   	:= "XX/XXXXXXXXXXX-X"
		
	Case cBanco == "341"
		
		cImagem 	+= "itau.bmp"
		cNumBco 	:= "341-7"
		cCart		:= "109"
		cMsgLn1		:= ALLTRIM(SEE->EE_FORMEN1) //"Pagável preferencialmente nas agências do Banco Bradesco e Bradesco Expresso" 								//Alterar conforme necessidade do cliente
		cMsgLn2		:= ALLTRIM(SEE->EE_FORMEN2)																		//Alterar conforme necessidade do cliente
		//cMsgLn3		:= ALLTRIM(SEE->EE_FOREXT1) //"Juros: após vencto. cobrar R$ 0,41 ao dia."
		//cMsgLn4 	:= ALLTRIM(SEE->EE_FOREXT2)
		cMsgLn3    	:= "***Apos o vencimento cobrar multa de "+ CVALTOCHAR(nPercMul) +"%" 
		cMsgLn4    	:= " e mora de "+ CVALTOCHAR(nPercMJ) +"% ao dia."
		cMsgLn5 	:= IIf(!Empty(_cMenBol),_cMenBol,'')//Exibe mensagem no boleto: "Sujeito a Retenção de PCC" 
		/*
		cMsgLn1 	:= "ATÉ O VENCIMENTO, PREFERENCIALMENTE NO ITAÚ,"
		cMsgLn2 	:= "APÓS O VENCIMENTO, SOMENTE NO ITAÚ"
		cMsgLn3		:= "Após vencimento, cobrar juros de R$ 0,41 por dia" 					//Alterar conforme necessidade do cliente
		//	cMsgLn4	:= "QUALQUER DÚVIDA SOBRE ESTE BOLETO, CONTATE O BENEFICIÁRIO."		//Alterar conforme necessidade do cliente
		*/
		aPropImg	:= {380,110}
		cPictNN	:= "XXX/XXXXXXXX-X"
		
	Case cBanco == "422"
		
		//cImagem 	+= "safra.bmp"
		cImagem 	:= "Banco Safra S.A."
		cNumBco 	:= "422-7"
		cCart		:= "02" 																	//Alterar conforme necessidade do cliente
		cMsgLn1		:= "PAGÁVEL PREFERENCIALMENTE NO BANCO SAFRA ATÉ O VENCIMENTO"
		cMsgLn2		:= "APÓS VENCIMENTO PAGUE SOMENTE NO SAFRA"
		
		cMsgLn6    	:= "***Apos o vencimento cobrar multa de "+ CVALTOCHAR(nPercMul) +"%" 
		cMsgLn7    	:= " e mora de R$ " + TRANSFORM ( ((SE1->E1_VALOR*nPercMJ)/30) , "@E 99,999.999" ) +" ao dia."
		cMsgLn8     := "Todas as informacoes desse bloquete sao de responsabilidade do Beneficiario"
		
		cMsgLn3    	:= "ESTE BOLETO REPRESENTA DUPLICATA CEDIDA FIDUCIARIAMENTE AO BANCO SAFRA S/A, FICANDO" 
		cMsgLn4    	:= "VEDADO O PAGAMENTO DE QUALQUER OUTRA FORMA QUE NAO ATRAVES DO PRESENTE BOLETO."
		
		cMsgLn5 	:= IIf(!Empty(_cMenBol),_cMenBol,'')//Exibe mensagem no boleto: "Sujeito a Retenção de PCC" 
		aPropImg	:= {270,120}
		cPictNN	:= "XXXXXXXXX"
		
	Case cBanco == "707"
		cImagem 	+= "bradesco.bmp"
		cNumBco 	:= "237-2"
		/*
		cImagem 	+= "daycoval.bmp"
		cNumBco 	:= "707-2"
		*/
		cCart		:= "19"
		cMsgLn1		:= "PAGÁVEL PREFERENCIALMENTE EM QUALQUER AGÊNCIA BRADESCO"
		//	cMsgLn2	:= "APÓS VENCIMENTO PAGUE SOMENTE NO DAYCOVAL"
		cMsgLn3	:= "Juros: após vencto. cobrar R$ 0,15 ao dia" 	     						//Alterar conforme necessidade do cliente
		cMsgLn4	:= ""																		//Alterar conforme necessidade do cliente
		cMsgLn5 	:= IIf(!Empty(_cMenBol),_cMenBol,'')//Exibe mensagem no boleto: "Sujeito a Retenção de PCC" 
		aPropImg	:= {300,120}
		cPictNN	:= "XXXXXXXXXXXXXX-XX"
		
	Case cBanco == "033"
		cImagem 	+= "santander.bmp"
		cNumBco 	:= "033-7"//VG - 2017.08.29 - Alteração de "033" para "033-7"
		cCart		:= SEE->EE_CODCART 			  // "102"
		cMsgLn1		:= ALLTRIM(SEE->EE_FORMEN1)   // "Até o vencimento pagável em qualquer agência" 				//Alterar conforme necessidade do cliente
		cMsgLn2	    := ALLTRIM(SEE->EE_FORMEN2)   // "APÓS VENCIMENTO PAGUE SOMENTE NO SANTANDER"				//Alterar conforme necessidade do cliente																	//Alterar conforme necessidade do cliente
		//cMsgLn3	:= ALLTRIM(SEE->EE_FOREXT1)   // "Não dispensar mora de 0,20% por dia de atraso"              //Pegar do SEE
		//cMsgLn4	:= ALLTRIM(SEE->EE_FOREXT2)
		cMsgLn3    	:= "***Apos o vencimento cobrar multa de "+ CVALTOCHAR(nPercMul) +"%" 
		cMsgLn4    	:= " e mora de "+ CVALTOCHAR(nPercMJ) +"% ao dia."
		cMsgLn5 	:= IIf(!Empty(_cMenBol),_cMenBol,'')//Exibe mensagem no boleto: "Sujeito a Retenção de PCC" 
		aPropImg	:= {330,110}
		cPictNN		:= "XXXXXXXXXXXXX"
		
	Case cBanco == "745"
		
		cImagem 	+= "citi.bmp"
		cNumBco 	:= "745-9"
		cCart		:= "09"
		cMsgLn1		:= "PAGAR PREFERENCIALMENTE NO BANCO CITI ATÉ O VENCIMENTO)" 			//Alterar conforme necessidade do cliente
		cMsgLn2		:= "APÓS VENCIMENTO PAGUE SOMENTE NO CITI"
		cMsgLn3    	:= "DE RESPONSABILIDADE DO BENEFICIÁRIO"
		cMsgLn4		:= ""																	//Alterar conforme necessidade do cliente
		cMsgLn5 	:= IIf(!Empty(_cMenBol),_cMenBol,'')//Exibe mensagem no boleto: "Sujeito a Retenção de PCC" 
		aPropImg	:= {320,110}
		cPictNN		:= "XXXXXXXXXXX-X"
		
EndCase

nVlrAbat := SomaAbat((cAliasQry)->E1_PREFIXO,(cAliasQry)->E1_NUM,(cAliasQry)->E1_PARCELA,"R",1,dDataBase,(cAliasQry)->A1_COD,(cAliasQry)->A1_LOJA)

nTotPCC := (cAliasQry)->E1_PIS + (cAliasQry)->E1_COFINS + (cAliasQry)->E1_CSLL                   //Soma PCC

//Verifica quantidade de dias que foi prorrogado o recebimento do titulo do cliente
If Alltrim((cAliasQry)->E1_XCOBJM) <> '2' //Não cobra Multa e nem Juros/Mora
	If !Empty((cAliasQry)->E1_XDTPROR) 
		nDias  := Abs((cAliasQry)->E1_VENCREA - (cAliasQry)->E1_XDTPROR)
		//Incluido Ronaldo Bicudo / Totvs - 05/05/2017
		If (cAliasQry)->E1_XMULTA > 0 
			nMulta := ROUND((cAliasQry)->E1_SALDO * ((cAliasQry)->E1_XMULTA/100),2)
		ElseIF (cAliasQry)->A1_XMULTA > 0 
			nMulta := ROUND((cAliasQry)->E1_SALDO * ((cAliasQry)->A1_XMULTA/100),2)
		Else
			nMulta := ROUND((cAliasQry)->E1_SALDO * (nPercMul/100),2)
		EndIf
		//FIM
		nPercMj := (nPercMJ/100) * nDias
		nJuros := Round((cAliasQry)->E1_SALDO * nPercMJ,2)
		//Round( aReceb[i][__VALOR] * (nPerJur /100),2) //PADRÃO
		nTotJM := nJuros + nMulta //Valor total de multa e mora/juros ao dia
	EndIf
EndIf
//Fim

aAdd(aDados,cNumBco)																			 //1 - Numero do Banco
aAdd(aDados,AllTrim((cAliasQry)->A6_AGENCIA))												     //2 - Agencia
aAdd(aDados,AllTrim(SEE->EE_CONTA) + "-" + AllTrim(SEE->EE_DVCTA))
//aAdd(aDados,AllTrim(SEE->EE_CODEMP))								      						 //3 - Conta  ---- 6330126
aAdd(aDados,cImagem)																			 //4 - Imagem
aAdd(aDados,AllTrim(SM0->M0_NOMECOM))														     //5 - Beneficiario
aAdd(aDados,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"))								         //6 - CNPJ Benef.
aAdd(aDados,AllTrim((cAliasQry)->A1_NOME))												         //7 - Pagador
If (cAliasQry)->A1_PESSOA == "J"
	aAdd(aDados,Transform((cAliasQry)->A1_CGC,"@R 99.999.999/9999-99"))				             //8 - CNPJ Pagador
Else
	aAdd(aDados,Transform((cAliasQry)->A1_CGC,"@R 999.999.999-99")) 					         //8 - CPF Pagador
EndIf
aAdd(aDados,ALLTRIM((cAliasQry)->A1_END))														 //9 - End. Cob.
aAdd(aDados,ALLTRIM((cAliasQry)->A1_BAIRRO))													 //10- Bairro Cob.
aAdd(aDados,AllTrim((cAliasQry)->A1_MUN))												         //11- Munic. Cob.
aAdd(aDados,AllTrim((cAliasQry)->A1_EST))														 //12- Estado Cob.
aAdd(aDados,Transform((cAliasQry)->A1_CEP,PesqPict("SA1","A1_CEP")))					         //13- CEP Cob.
aAdd(aDados,Transform(FINX999NN(cAliasQry),"@R "+cPictNN))								         //14- Nosso Numero
aAdd(aDados,FINX999LDg(cAliasQry)) 															     //15- Linha Digitavel
aAdd(aDados,DtoC((cAliasQry)->E1_VENCREA)) 													     //16- Vencimento
aAdd(aDados,DtoC((cAliasQry)->E1_EMISSAO))												         //17- Emissao
aAdd(aDados,DtoC(dDataBase))																     //18- Processamento
aAdd(aDados,Transform((cAliasQry)->E1_SALDO - nVlrAbat,PesqPict("SE1","E1_SALDO")))	             //19- Valor
aAdd(aDados,cMsgLn1)																			 //20- Local Pgto. Ln1
aAdd(aDados,cMsgLn2)																			 //21- Local Pgto. Ln2
aAdd(aDados,Iif(cBanco == "399","","R$"))													     //22- Especie
aAdd(aDados,cCart)																			     //23- Carteira
aAdd(aDados,Iif(cBanco == "399","","N"))													     //24- Aceite
//aAdd(aDados,Iif(cBanco == "237" .AND. !SEE->EE_XCIP=="","DM",(cAliasQry)->E1_TIPO))			 //25- Tipo Doc.
aAdd(aDados,Iif(cBanco $ "237|422" .AND. !SEE->EE_XCIP=="","DM",(cAliasQry)->E1_TIPO))			 //25- Tipo Doc.
aAdd(aDados,_NCB(cAliasQry))															   		 //26- Cod. Barras
aAdd(aDados,cMsgLn3)																			 //27- Instru. Ln1
aAdd(aDados,cMsgLn4)																			 //28- Instru. Ln2
aAdd(aDados,AllTrim((cAliasQry)->E1_NUM+(cAliasQry)->E1_PARCELA))								 //29 - Número Documento
aAdd(aDados,AllTrim(SEE->EE_XCIP))														         //30 - CIP
aAdd(aDados,cMsgLn5)																			 //31- Observação PCC
//Adiconado Ronaldo Bicudo - 20/04/2017
//Solicitado a retirada dos impostos 16/04/19  (5632646)
aAdd(aDados,"") //"IRRF Retido...... " + Transform((cAliasQry)->E1_IRRF,PesqPict("SE1","E1_IRRF"))) 	//32 - Valor de IRRF													         
aAdd(aDados,"") //"PCC Retido......  " + Transform(nTotPCC,PesqPict("SE1","E1_PIS")))	 			 	//33 - Valor de PIS + COFINS + CSLL													         
aAdd(aDados,"") //"ISS Retido......  " + Transform((cAliasQry)->E1_ISS,PesqPict("SE1","E1_ISS")))	 	//34 - Valor de ISS													         
//Adicionado Ronaldo Bicudo - 24/04/2017
aAdd(aDados,AllTrim(SM0->M0_ENDCOB))			
											     //35 - Endereço
If !Empty((cAliasQry)->E1_XDTPROR) .or. Alltrim((cAliasQry)->E1_XCOBJM) <> '2'
	aAdd(aDados,Transform(nTotJM,PesqPict("SE1","E1_SALDO")))							        //36 - Valor Mora/Juros
EndIf
If !Empty((cAliasQry)->E1_XDTPROR)
	aAdd(aDados,Transform(((cAliasQry)->E1_SALDO - nVlrAbat)+ nTotJM,PesqPict("SE1","E1_SALDO")))   //37 - Valor Total
EndIf

If cBanco == '422
	aAdd(aDados,cMsgLn6) //38- Instru. Ln1
	aAdd(aDados,cMsgLn7) //39- Instru. Ln2
	aAdd(aDados,cMsgLn8) //40- Instru. Ln2
End If

//Fim

//oPrint:StartPage()

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)

oFont8 		:= TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11c 	:= TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  	:= TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  	:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  	:= TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  	:= TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n 	:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  	:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n 	:= TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n 	:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  	:= TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página

/******************/
/* PRIMEIRA PARTE */
/******************/

oPrint:Line (0150,500,0070, 500)
oPrint:Line (0150,710,0070, 710)

If cBanco <> '422'
	oPrint:SayBitmap(40,100,cImagem,aPropImg[1],aPropImg[2])	//IMAGEM
Else
	oPrint:Say  (0084,100,cImagem,oFont14 )						//(OU) NOME DO BANCO
End If

oPrint:Say  (0115,525,aDados[1],oFont21)

oPrint:Say  (0084,1900,"Comprovante de Entrega",oFont10)
oPrint:Line (0150,100,0150,2300)

oPrint:Say  (0150,100 ,"Beneficiário",oFont8)
oPrint:Say  (0200,100 ,aDados[5],oFont10)

oPrint:Say  (0150,1060,"Agência/Código do Beneficiário",oFont8)
oPrint:Say  (0200,1060,aDados[2]+"/"+aDados[3],oFont10)

oPrint:Say  (0150,1510,"Nro.Documento",oFont8)
oPrint:Say  (0200,1510,aDados[29],oFont10)

oPrint:Say  (0250,100 ,"Pagador",oFont8)
oPrint:Say  (0300,100 ,aDados[7],oFont10)

oPrint:Say  (0250,1060,"Vencimento",oFont8)
oPrint:Say  (0300,1060,aDados[16],oFont10)

oPrint:Say  (0250,1510,"Valor do Documento",oFont8)
oPrint:Say  (0300,1550,aDados[19],oFont10)

oPrint:Say  (0400,0100,"Recebi(emos) o boleto/título",oFont10)
oPrint:Say  (0450,0100,"com as características acima.",oFont10)
oPrint:Say  (0350,1060,"Data",oFont8)
oPrint:Say  (0350,1410,"Assinatura",oFont8)
oPrint:Say  (0450,1060,"Data",oFont8)
oPrint:Say  (0450,1410,"Entregador",oFont8)

oPrint:Line (0250, 100,0250,1900 )
oPrint:Line (0350, 100,0350,1900 )
oPrint:Line (0450,1050,0450,1900 )
oPrint:Line (0550, 100,0550,2300 )

oPrint:Line (0550,1050,0150,1050 )
oPrint:Line (0550,1400,0350,1400 )
oPrint:Line (0350,1500,0150,1500 )
oPrint:Line (0550,1900,0150,1900 )

oPrint:Say  (0165,1910,"(  )Mudou-se",oFont8)
oPrint:Say  (0205,1910,"(  )Ausente",oFont8)
oPrint:Say  (0245,1910,"(  )Não existe nº indicado",oFont8)
oPrint:Say  (0285,1910,"(  )Recusado",oFont8)
oPrint:Say  (0325,1910,"(  )Não procurado",oFont8)
oPrint:Say  (0365,1910,"(  )Endereço insuficiente",oFont8)
oPrint:Say  (0405,1910,"(  )Desconhecido",oFont8)
oPrint:Say  (0445,1910,"(  )Falecido",oFont8)
oPrint:Say  (0485,1910,"(  )Outros(anotar no verso)",oFont8)


/*****************/
/* SEGUNDA PARTE */
/*****************/

//Pontilhado separador
For nI := 100 to 2300 step 50
	oPrint:Line(0580, nI,0580, nI+30)
Next nI

oPrint:Line (0710,100,0710,2300)
oPrint:Line (0710,500,0630, 500)
oPrint:Line (0710,710,0630, 710)

If cBanco <> '422'
	oPrint:SayBitmap(590,100,cImagem,aPropImg[1],aPropImg[2])		//IMAGEM
Else
	oPrint:Say  (0644,100,cImagem,oFont14)					//(OU) NOME DO BANCO
End If

oPrint:Say  (0675,525,aDados[1],oFont21 )

oPrint:Say  (0600,1900,"Recibo do Pagador",oFont10)

oPrint:Say  (0678,755,aDados[15],oFont15n)

oPrint:Line (0810,100,0810,2300 )
oPrint:Line (0910,100,0910,2300 )
oPrint:Line (0980,100,0980,2300 )
oPrint:Line (1050,100,1050,2300 )

oPrint:Line (0910,500,1050,500)
oPrint:Line (0980,750,1050,750)
oPrint:Line (0910,1000,1050,1000)
oPrint:Line (0910,1300,0980,1300)
oPrint:Line (0910,1480,1050,1480)

oPrint:Say  (0710,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (0725,400 ,aDados[20],oFont10)
oPrint:Say  (0765,400 ,aDados[21],oFont10)

oPrint:Say  (0710,1810,"Vencimento",oFont8)
//nCol := 1810+(374-(Len(aDados[16])*22))
//oPrint:Say  (0750,1825,aDados[16],oFont11c)
oPrint:Say  (0750,1940,aDados[16],oFont11c)

oPrint:Say  (0810,100 ,"Beneficiário",oFont8)
//oPrint:Say  (0850,100 ,aDados[5]+" - CNPJ: "+aDados[6],oFont10)
oPrint:Say  (0850,100   ,aDados[5]+" - CNPJ: "+aDados[6]+" - End.: "+aDados[35],oFont10)

oPrint:Say  (0810,1810,"Agência/Código do Beneficiário",oFont8)
//nCol := 1810+(374-(Len(aDados[2]+aDados[3])+1)*22)
//oPrint:Say  (0850,1825,aDados[2]+"/"+aDados[3],oFont11c)
oPrint:Say  (0850,1940,aDados[2]+"/"+aDados[3],oFont11c)

oPrint:Say  (0910,100 ,"Data do Documento",oFont8)
oPrint:Say  (0940,100, aDados[17],oFont10)

oPrint:Say  (0910,505 ,"Nro.Documento",oFont8)
oPrint:Say  (0940,605 ,aDados[29],oFont10)

oPrint:Say  (0910,1005,"Espécie Doc.",oFont8)
oPrint:Say  (0940,1050,aDados[25],oFont10)

oPrint:Say  (0910,1305,"Aceite",oFont8)
oPrint:Say  (0940,1400,aDados[24],oFont10)

oPrint:Say  (0910,1485,"Data do Processamento",oFont8)
oPrint:Say  (0940,1550,aDados[18],oFont10)

oPrint:Say  (0910,1810,"Nosso Número",oFont8)
//nCol := 1880+(374-(Len(aDados[14])*22))
//oPrint:Say  (0940,1825,aDados[14],oFont11c)
oPrint:Say  (0940,1940,aDados[14],oFont11c)

oPrint:Say  (0980,100 ,"Uso do Banco",oFont8)
If (!Empty(aDados[30]))
	oPrint:Line (0980,355,1050,355)
	oPrint:Say  (0980,360 ,"CIP",oFont8)
	oPrint:Say  (1010,410 , aDados[30],oFont10)
Endif

oPrint:Say  (0980,505 ,"Carteira",oFont8)
oPrint:Say  (1010,555 ,aDados[23],oFont10)

oPrint:Say  (0980,755 ,"Espécie",oFont8)
oPrint:Say  (1010,805 ,aDados[22],oFont10)

oPrint:Say  (0980,1005,"Quantidade",oFont8)
oPrint:Say  (0980,1485,"Valor",oFont8)

oPrint:Say  (0980,1810,"Valor do Documento",oFont8)
//nCol := 1810+(374-(len(aDados[19])*22))
oPrint:Say  (1010,1830,aDados[19],oFont11c, , , , , 1)

oPrint:Say  (1050,100 ,"Instruções",oFont8)

If cBanco <> '422'
	oPrint:Say  (1150,100,aDados[27]+" "+aDados[28],oFont10)
Else
	oPrint:Say  (1150,100,aDados[27],oFont10)
	oPrint:Say  (1200,100,aDados[28],oFont10)
	oPrint:Say  (1250,100,aDados[37],oFont10)
	oPrint:Say  (1300,100,aDados[38],oFont10)
	oPrint:Say  (1340,100,aDados[39],oFont8)
End If

oPrint:Say  (1200,100,aDados[31],oFont10) //Incluido Ronaldo Bicudo - Totvs / 18/10/2016
//Adiconado Ronaldo Bicudo - 20/04/2017
If (cAliasQry)->E1_IRRF > 0
	oPrint:Say  (1230,100,aDados[32],oFont10)
EndIF
IF nTotPCC > 0
	oPrint:Say  (1260,100,aDados[33],oFont10)
EndIf
If (cAliasQry)->E1_ISS > 0
	oPrint:Say  (1290,100,aDados[34],oFont10)
EndIF
//Fim
oPrint:Say  (1050,1810,"(-)Desconto/Abatimento"	,oFont8)
oPrint:Say  (1120,1810,"(-)Outras Deduções"			,oFont8)
oPrint:Say  (1190,1810,"(+)Mora/Multa"				,oFont8)
//Adicionado Ronaldo Bicudo - 24/04/2017
If !Empty((cAliasQry)->E1_XDTPROR) .and. Alltrim((cAliasQry)->E1_XCOBJM) <> '2'
	oPrint:Say  (1220,1830,aDados[36],oFont11c, , , , , 1)
EndIf                                 
//Fim
oPrint:Say  (1260,1810,"(+)Outros Acréscimos"		,oFont8)
oPrint:Say  (1330,1810,"(=)Valor Cobrado"			,oFont8)

// Carlos Eduardo Saturnino - Comentado em 27/10/2017 por 
// Solicitação da Sra. Lilian - Financeiro
/*<Inicio>----------------------------------------------------

If !Empty((cAliasQry)->E1_XDTPROR)
	oPrint:Say  (1360,1830,aDados[37],oFont11c, , , , , 1)
Else
	oPrint:Say  (1360,1830,aDados[19],oFont11c, , , , , 1)
EndIf

<Fim>-------------------------------------------------------*/
oPrint:Say  (1400,100 ,"Pagador",oFont8)
oPrint:Say  (1430,400 ,aDados[7]+" - "+aDados[8],oFont10)
oPrint:Say  (1483,400 ,aDados[9],oFont10)
oPrint:Say  (1536,400 ,aDados[13],oFont10)
oPrint:Say  (1536,800 ,aDados[10],oFont10)
oPrint:Say  (1536,1300,aDados[11]+"-"+aDados[12],oFont10)

oPrint:Say  (1605,100 ,"Sacador/Avalista",oFont8)
oPrint:Say  (1645,1500,"Autenticação Mecânica",oFont8)

oPrint:Line (0710,1800,1400,1800 )
oPrint:Line (1120,1800,1120,2300 )
oPrint:Line (1190,1800,1190,2300 )
oPrint:Line (1260,1800,1260,2300 )
oPrint:Line (1330,1800,1330,2300 )
oPrint:Line (1400,100 ,1400,2300 )
oPrint:Line (1640,100 ,1640,2300 )                        

/******************/
/* TERCEIRA PARTE */
/******************/

For nI := 100 to 2300 step 50
	oPrint:Line(1880, nI, 1880, nI+30)
Next nI

If cBanco <> '422'
	oPrint:SayBitmap(1890,100,cImagem,aPropImg[1],aPropImg[2])	//IMAGEM
Else
	oPrint:Say (1934,100,cImagem,oFont14 )						//(OU) NOME DO BANCO
End If
oPrint:Line (2000,100,2000,2300)
oPrint:Line (2000,500,1920, 500)
oPrint:Line (2000,710,1920, 710)

oPrint:Say  (1965,525,aDados[1],oFont21 )
oPrint:Say  (1968,755,aDados[15],oFont15n)

oPrint:Line (2100,100,2100,2300 )
oPrint:Line (2200,100,2200,2300 )
oPrint:Line (2270,100,2270,2300 )
oPrint:Line (2340,100,2340,2300 )

oPrint:Line (2200,500 ,2340,500 )
oPrint:Line (2270,750 ,2340,750 )
oPrint:Line (2200,1000,2340,1000)
oPrint:Line (2200,1300,2270,1300)
oPrint:Line (2200,1480,2340,1480)

oPrint:Say  (2000,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (2015,400 ,aDados[20],oFont10)
oPrint:Say  (2055,400 ,aDados[21],oFont10)

oPrint:Say  (2000,1810,"Vencimento",oFont8)
//nCol	 	 := 1810+(374-(Len(aDados[16])*22))
//oPrint:Say  (2040,1825,aDados[16],oFont11c)
oPrint:Say  (2040,1940,aDados[16],oFont11c)

oPrint:Say  (2100,100 ,"Beneficiário",oFont8)
oPrint:Say  (2140,100 ,aDados[5]+" - CNPJ: "+aDados[6]+" - End.: "+aDados[35],oFont10)

If cBanco <> '422'
	oPrint:Say  (2100,1810,"Agência/Código Cedente",oFont8)
Else
	oPrint:Say  (2100,1810,"Agência/Código Beneficiário",oFont8)
EndIf
//nCol 	 := 1810+(374-((Len(aDados[2]+aDados[3])+1)*22))
//oPrint:Say  (2140,1825,aDados[2]+"/"+aDados[3] ,oFont11c)
oPrint:Say  (2140,1940,aDados[2]+"/"+aDados[3] ,oFont11c)

oPrint:Say  (2200,100,"Data do Documento",oFont8)
oPrint:Say (2230,100,aDados[17],oFont10)

oPrint:Say  (2200,505,"Nro.Documento",oFont8)
oPrint:Say  (2230,605,aDados[29],oFont10)

oPrint:Say  (2200,1005,"Espécie Doc.",oFont8)
oPrint:Say  (2230,1050,aDados[25],oFont10)

oPrint:Say  (2200,1305,"Aceite",oFont8)
oPrint:Say  (2230,1400,aDados[24],oFont10)

oPrint:Say  (2200,1485,"Data do Processamento",oFont8)
oPrint:Say  (2230,1550,aDados[18],oFont10)

oPrint:Say  (2200,1810,"Nosso Número",oFont8)
//nCol 	 := 1880+(374-(Len(aDados[14])*22))
//oPrint:Say  (2230,1825,aDados[14],oFont11c)
oPrint:Say  (2230,1940,aDados[14],oFont11c)

oPrint:Say  (2270,100 ,"Uso do Banco",oFont8)

If (!Empty(aDados[30]))
	oPrint:Line (2270,355 ,2340,355 )
	oPrint:Say  (2270,360 ,"CIP",oFont8)
	oPrint:Say  (2300,410 , aDados[30],oFont10)
Endif

oPrint:Say  (2270,505 ,"Carteira",oFont8)
oPrint:Say  (2300,555 ,aDados[23],oFont10)

oPrint:Say  (2270,755 ,"Espécie",oFont8)
oPrint:Say  (2300,805 ,aDados[22],oFont10)

oPrint:Say  (2270,1005,"Quantidade",oFont8)
oPrint:Say  (2270,1485,"Valor",oFont8)

oPrint:Say  (2270,1810,"Valor do Documento",oFont8)
//nCol 	 := 1810+(374-(Len(aDados[19])*22))
oPrint:Say  (2300,1830,aDados[19],oFont11c, , , , , 1)

oPrint:Say  (2340,100,"Instruções",oFont8)

//oPrint:Say  (2440,100,aDados[27]+" "+aDados[28],oFont10)
If cBanco <> '422'
	oPrint:Say  (2440,100,aDados[27]+" "+aDados[28],oFont10)
Else
	oPrint:Say  (2440,100,aDados[27],oFont10)
	oPrint:Say  (2470,100,aDados[28],oFont10)
	oPrint:Say  (2500,100,aDados[37],oFont10)
	oPrint:Say  (2530,100,aDados[38],oFont10)
	oPrint:Say  (2560,100,aDados[39],oFont8)
EndIf

oPrint:Say  (2470,100,aDados[31],oFont10) //Incluido Ronaldo Bicudo - Totvs / 18/10/2016
//Adiconado Ronaldo Bicudo - 20/04/2017
If (cAliasQry)->E1_IRRF > 0
	oPrint:Say  (2500,100,aDados[32],oFont10)
EndIF
IF nTotPCC > 0
	oPrint:Say  (2530,100,aDados[33],oFont10)
EndIf
If (cAliasQry)->E1_ISS > 0
	oPrint:Say  (2560,100,aDados[34],oFont10)
EndIF
//Fim
oPrint:Say  (2340,1810,"(-)Desconto/Abatimento"	,oFont8)
oPrint:Say  (2410,1810,"(-)Outras Deduções"		,oFont8)
oPrint:Say  (2480,1810,"(+)Mora/Multa"			,oFont8)
//Adicionado Ronaldo Bicudo - 24/04/2017
If !Empty((cAliasQry)->E1_XDTPROR) .and. Alltrim((cAliasQry)->E1_XCOBJM) <> '2'
	oPrint:Say  (2510,1830,aDados[36],oFont11c, , , , , 1)
EndIf                                 
//Fim
oPrint:Say  (2550,1810,"(+)Outros Acréscimos"		,oFont8)
oPrint:Say  (2620,1810,"(=)Valor Cobrado"			,oFont8)

// Carlos Eduardo Saturnino - Comentado em 27/10/2017 por 
// Solicitação da Sra. Lilian - Financeiro
/*<Inicio>----------------------------------------------------

If !Empty((cAliasQry)->E1_XDTPROR)
	oPrint:Say  (2650,1830,aDados[37],oFont11c, , , , , 1) 
Else
	oPrint:Say  (2650,1830,aDados[19],oFont11c, , , , , 1) 
EndIf                                 

<Fim>-------------------------------------------------------*/

//nCol 	 := 1810+(374-(Len(aDados[19])*22))
//oPrint:Say  (2654,1950,aDados[19],oFont11c, , , , , 1)

oPrint:Say  (2690,100 ,"Pagador",oFont8)
oPrint:Say  (2700,400 ,aDados[7]+" - "+aDados[8],oFont10)
oPrint:Say  (2753,400 ,aDados[9],oFont10)
oPrint:Say  (2806,400 ,aDados[13],oFont10)
oPrint:Say  (2806,600,aDados[10],oFont10)
oPrint:Say  (2806,1200,aDados[11]+"-"+aDados[12],oFont10)

oPrint:Say  (2878,100 ,"Sacador/Avalista",oFont8)
oPrint:Say  (2878,1500,"Autenticação Mecânica - Ficha de Compensação" ,oFont8)

oPrint:Line (2000,1800,2690,1800)
oPrint:Line (2410,1800,2410,2300)
oPrint:Line (2480,1800,2480,2300)
oPrint:Line (2550,1800,2550,2300)
oPrint:Line (2620,1800,2620,2300)
oPrint:Line (2690,100 ,2690,2300)

oPrint:Line (2850,100,2850,2300)

//MSBAR("INT25",25.5,1,aDados[26],oPrint,.F.,Nil,Nil,0.025,1.5,Nil,Nil,"A",.F.)
//              MSBAR3( cTypeBar nRow nCol cCode oPr    lCheck Color lHort  nWidth nHeigth lBanner cFont cMode lPrint nPFWidth nPFHeigth ] )
//FWMsPrinter():FWMsBar(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz, nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
oPrint:FWMsBar("INT25", 68.0, 3, aDados[26], oPrint, .F., Nil, Nil, 0.025, 1.25, Nil, Nil, "A", .F.)         //Alterado Rafael 22/09/16

oPrint:EndPage()

aDados := Nil

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999Sel

Monta a tela de seleção de títulos.

@author    TOTVS
@version   11.90
@since     30/08/13

//------------------------------------------------------------------------------------------
/*/
Static Function FINX999Sel(cAliasTmp,cMark)

Local oDlg
Local oBrowse
Local oColumn

DEFAULT cAliasTmp	:= ""
DEFAULT cMark		:= ""

If !Empty(cAliasTmp)
	DEFINE MSDIALOG oDlg TITLE "Seleção de Títulos" FROM 0,0 TO 600,800 PIXEL

	dbSelectArea(cAliasTmp)
	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS cAliasTmp NO REPORT OF oDlg

	ADD MARKCOLUMN oColumn DATA { || If((cAliasTmp)->E1_OK == cMark,'LBOK','LBNO') } DOUBLECLICK { || FINX999Mrk(cAliasTmp,cMark) } HEADERCLICK { |oBrowse| _FINX999IMk(cAliasTmp,cMark), oBrowse:Refresh() } OF oBrowse

	ADD COLUMN oColumn DATA { || (cAliasTmp)->E1_PREFIXO   											} TITLE RetTitle("E1_PREFIXO"		)  	OF oBrowse
	ADD COLUMN oColumn DATA { || (cAliasTmp)->E1_NUM   												} TITLE RetTitle("E1_NUM"			)  	OF oBrowse
	ADD COLUMN oColumn DATA { || (cAliasTmp)->E1_PARCELA   											} TITLE RetTitle("E1_PARCELA"		)  	OF oBrowse
	ADD COLUMN oColumn DATA { || (cAliasTmp)->E1_NUMBOR   											} TITLE RetTitle("E1_NUMBOR"		)  	OF oBrowse
	ADD COLUMN oColumn DATA { || (cAliasTmp)->E1_EMISSAO   											} TITLE RetTitle("E1_EMISSAO"		)  	OF oBrowse
	//If Empty((cAliasTmp)->E1_XDTPROR) 
		ADD COLUMN oColumn DATA { || (cAliasTmp)->E1_VENCREA   											} TITLE RetTitle("E1_VENCREA"	)  	OF oBrowse
	//Else
	//	ADD COLUMN oColumn DATA { || (cAliasTmp)->E1_XDTPROR   											} TITLE RetTitle("E1_XDTPROR"	)  	OF oBrowse
	//EndIf
	ADD COLUMN oColumn DATA { || Transform((cAliasTmp)->E1_SALDO, "@E 9,999,999,999,999.99")  	} TITLE RetTitle("E1_SALDO"				)  	OF oBrowse
	ADD COLUMN oColumn DATA { || (cAliasTmp)->A1_COD 													} TITLE RetTitle("E1_CLIENTE"	)  	OF oBrowse
	ADD COLUMN oColumn DATA { || (cAliasTmp)->A1_LOJA   												} TITLE RetTitle("E1_LOJA"		) 	OF oBrowse
	ADD COLUMN oColumn DATA { || (cAliasTmp)->A1_NOME   												} TITLE RetTitle("A1_NOME"		) 	OF oBrowse

	ACTIVATE FWBROWSE oBrowse

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,)
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999Mrk

Atualiza a marcação dos títulos para a geração do boleto

@author    TOTVS
@version   11.90
@since     02/09/13

//------------------------------------------------------------------------------------------
/*/
Static Function FINX999Mrk(cAliasTmp,cMark)

DEFAULT cAliasTmp	:= ""
DEFAULT cMark		:= ""

If (cAliasTmp)->E1_OK == cMark
	RecLock(cAliasTmp,.F.)
	(cAliasTmp)->E1_OK := ""
	(cAliasTmp)->(MsUnlock())
Else
	RecLock(cAliasTmp,.F.)
	(cAliasTmp)->E1_OK := cMark
	(cAliasTmp)->(MsUnlock())
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999IMk

Inverte a marcação dos títulos para a geração do boleto

@author    TOTVS
@version   11.90
@since     02/09/13

//------------------------------------------------------------------------------------------
/*/
Static Function _FINX999IMk(cAliasTmp,cMark)

Local aAreaTmp := {}

DEFAULT cAliasTmp := ""
DEFAULT cMark:= ""

dbSelectArea(cAliasTmp)
aAreaTmp := (cAliasTmp)->(GetArea())
(cAliasTmp)->(dbGoTop())

While !(cAliasTmp)->(Eof())
	FINX999Mrk(cAliasTmp,cMark)
	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(RestArea(aAreaTmp))

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999VIB

Valida o código do banco informado na pergunta "Portador" da pergunta FINX999

@author    TOTVS
@version   11.90
@since     30/08/13

@return lRet - Banco válido ou não

//------------------------------------------------------------------------------------------
/*/
User Function _VIB()

Local lRet		:= .T.
Local cPortador	:= MV_PAR17
Local aBanco	:= {}

aAdd(aBanco,"745")
aAdd(aBanco,"237")
aAdd(aBanco,"422")
aAdd(aBanco,"707")
aAdd(aBanco,"341")
aAdd(aBanco,"033")

/*
BANCOS VALIDOS
-----------------------------------
745 - Banco Citi
237 - Banco Bradesco
422 - Banco Safra
707 - Daycoval
341 - Itau
033 - Santander
-----------------------------------
*/

If aScan(aBanco,{ |cBanco| Alltrim(cBanco) == Alltrim(cPortador)  }) <= 0
	lRet := .F.
	MsgAlert("O banco informado não é válido para a impressão deste modelo de boleto.")
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999TMP

Criação do arquivo temporário Clientes X Títulos X Banco

@author    TOTVS
@version   11.90
@since     30/08/13

@return cAliasTrb - Alias do Arquivo temporário

//------------------------------------------------------------------------------------------
/*/
Static Function _Tmp()

Local aStruct		:= {}
Local cAliasQry		:= GetNextAlias()
Local cAliasTrb		:= GetNextAlias()
Local cCampo    	:= ""
Local cNotIn		:= '%' + FormatIn(MVABATIM,"/") + "%"
Local nX			:= 0
Local xConteudo		:= ""

BeginSQL Alias cAliasQry
	SELECT	SE1.E1_PREFIXO,	SE1.E1_NUM,		SE1.E1_PARCELA,	SE1.E1_TIPO,
	SE1.E1_EMISSAO,	SE1.E1_VENCREA,	SE1.E1_NUMBOR,	SE1.E1_SALDO, SE1.E1_XMULTA, SE1.E1_XCOBJM,
	SE1.E1_VENCTO, SE1.E1_XDTPROR,SE1.E1_OK, SE1.E1_IRRF, SE1.E1_ISS, SE1.E1_PIS, SE1.E1_COFINS, SE1.E1_CSLL,
//	SA6.A6_COD,		SA6.A6_AGENCIA,	SA6.A6_NUMCON,	SA6.A6_NOME,
//	SA6.A6_DVCTA,
	SA1.A1_COD,		SA1.A1_NOME,		SA1.A1_LOJA, 		SA1.A1_END,
	SA1.A1_ENDCOB,	SA1.A1_BAIRRO,	SA1.A1_BAIRROC,	SA1.A1_MUN,
	SA1.A1_MUNC,		SA1.A1_EST,		SA1.A1_ESTC,		SA1.A1_CEP,
	SA1.A1_CEPC,		SA1.A1_CGC,		SA1.A1_PESSOA, SA1.A1_XMULTA 
	FROM	%Table:SE1% SE1
//	INNER JOIN %Table:SA6% SA6 ON
//	SA6.A6_FILIAL			= %XFilial:SA6%
//	AND SA6.A6_COD			= SE1.E1_PORTADO
//	AND SA6.A6_AGENCIA	= SE1.E1_AGEDEP
//	AND SA6.A6_NUMCON		= SE1.E1_CONTA
//	AND SA6.%NotDel%
	INNER JOIN %Table:SA1% SA1 ON
	SA1.A1_FILIAL			= %XFilial:SA1%
	AND SA1.A1_COD			= SE1.E1_CLIENTE
	AND SA1.A1_LOJA		= SE1.E1_LOJA
	AND SA1.A1_EST <> 'EX'
	AND SA1.%NotDel%
	WHERE	SE1.E1_FILIAL			=	%XFilial:SE1%
	AND SE1.E1_PREFIXO	BETWEEN	%Exp:MV_PAR01% AND %Exp:MV_PAR02%
	AND SE1.E1_NUM		BETWEEN	%Exp:MV_PAR03% AND %Exp:MV_PAR04%
	AND SE1.E1_PARCELA	BETWEEN	%Exp:MV_PAR05% AND %Exp:MV_PAR06%
	AND SE1.E1_TIPO		NOT IN		%Exp:cNotIn%
	AND SE1.E1_CLIENTE	BETWEEN	%Exp:MV_PAR07% AND %Exp:MV_PAR08%
	AND SE1.E1_LOJA		BETWEEN	%Exp:MV_PAR09% AND %Exp:MV_PAR10%
	AND SE1.E1_EMISSAO	BETWEEN	%Exp:MV_PAR11% AND %Exp:MV_PAR12%
	AND SE1.E1_VENCREA	BETWEEN	%Exp:MV_PAR13% AND %Exp:MV_PAR14%
	AND SE1.E1_NUMBOR	BETWEEN	%Exp:MV_PAR15% AND %Exp:MV_PAR16%
	AND (SE1.E1_PORTADO	=			%Exp:MV_PAR17% OR SE1.E1_PORTADO='')
   	AND SE1.E1_SITUACA	=			%Exp:MV_PAR21%
	AND SE1.E1_SALDO		>			0
//	AND SE1.E1_PORTADO	<>			' '
	AND SE1.%NotDel%
	ORDER BY %Order:SE1%
EndSQL

aAdd(aStruct,{"E1_PREFIXO"	,"C", TamSX3("E1_PREFIXO")[1]	, TamSX3("E1_PREFIXO")[2]}	)
aAdd(aStruct,{"E1_NUM"		,"C", TamSX3("E1_NUM")[1]		, TamSX3("E1_NUM")[2]}		)
aAdd(aStruct,{"E1_PARCELA"	,"C", TamSX3("E1_PARCELA")[1]	, TamSX3("E1_PARCELA")[2]}	)
aAdd(aStruct,{"E1_TIPO"		,"C", TamSX3("E1_TIPO")[1]		, TamSX3("E1_TIPO")[2]}		)
aAdd(aStruct,{"E1_EMISSAO"	,"D", TamSX3("E1_EMISSAO")[1]	, TamSX3("E1_EMISSAO")[2]}	)
aAdd(aStruct,{"E1_NUMBOR"	,"C", TamSX3("E1_NUMBOR")[1]	, TamSX3("E1_NUMBOR")[2]}	)
aAdd(aStruct,{"E1_OK"		,"C", TamSX3("E1_OK")[1]		, TamSX3("E1_OK")[2]}		)
aAdd(aStruct,{"E1_SALDO"	,"N", TamSX3("E1_SALDO")[1]		, TamSX3("E1_SALDO")[2]}	)
aAdd(aStruct,{"E1_VENCREA"	,"D", TamSX3("E1_VENCREA")[1]	, TamSX3("E1_VENCREA")[2]}	)
aAdd(aStruct,{"E1_VENCTO"	,"D", TamSX3("E1_VENCTO")[1]	, TamSX3("E1_VENCTO")[2]}	)
//Incluido Ronaldo Bicudo / 20/04/2017 - Alterado 15/05/2017
aAdd(aStruct,{"E1_XDTPROR"	,"D", TamSX3("E1_XDTPROR")[1]	, TamSX3("E1_XDTPROR")[2]}	)
aAdd(aStruct,{"E1_IRRF"		,"N", TamSX3("E1_IRRF")[1]		, TamSX3("E1_IRRF")[2]}		)
aAdd(aStruct,{"E1_ISS"		,"N", TamSX3("E1_ISS")[1]		, TamSX3("E1_ISS")[2]}		)
aAdd(aStruct,{"E1_PIS"		,"N", TamSX3("E1_PIS")[1]		, TamSX3("E1_PIS")[2]}		)
aAdd(aStruct,{"E1_COFINS"	,"N", TamSX3("E1_COFINS")[1]	, TamSX3("E1_COFINS")[2]}	)
aAdd(aStruct,{"E1_CSLL"		,"N", TamSX3("E1_CSLL")[1]		, TamSX3("E1_CSLL")[2]}		)
aAdd(aStruct,{"E1_XMULTA"	,"N", TamSX3("E1_XMULTA")[1]	, TamSX3("E1_XMULTA")[2]}	)
aAdd(aStruct,{"E1_XCOBJM"	,"C", TamSX3("E1_XCOBJM")[1]	, TamSX3("E1_XCOBJM")[2]}	)
//FIM
aAdd(aStruct,{"A1_COD"		,"C", TamSX3("A1_COD")[1]		, TamSX3("A1_COD")[2]}		)
aAdd(aStruct,{"A1_BAIRRO"	,"C", TamSX3("A1_BAIRRO")[1]	, TamSX3("A1_BAIRRO")[2]}	)
aAdd(aStruct,{"A1_BAIRROC"	,"C", TamSX3("A1_BAIRROC")[1]	, TamSX3("A1_BAIRROC")[2]}	)
aAdd(aStruct,{"A1_CEP"		,"C", TamSX3("A1_CEP")[1]		, TamSX3("A1_CEP")[2]}		)
aAdd(aStruct,{"A1_CEPC"		,"C", TamSX3("A1_CEPC")[1]		, TamSX3("A1_CEPC")[2]}		)
aAdd(aStruct,{"A1_CGC"		,"C", TamSX3("A1_CGC")[1]		, TamSX3("A1_CGC")[2]}		)
aAdd(aStruct,{"A1_LOJA"		,"C", TamSX3("A1_LOJA ")[1]		, TamSX3("A1_LOJA ")[2]}	)
aAdd(aStruct,{"A1_NOME"		,"C", TamSX3("A1_NOME")[1]		, TamSX3("A1_NOME")[2]}		)
aAdd(aStruct,{"A1_END"		,"C", TamSX3("A1_END")[1]		, TamSX3("A1_END")[2]}		)
aAdd(aStruct,{"A1_ENDCOB"	,"C", TamSX3("A1_ENDCOB")[1]	, TamSX3("A1_ENDCOB")[2]}	)
aAdd(aStruct,{"A1_EST"		,"C", TamSX3("A1_EST")[1]		, TamSX3("A1_EST")[2]}		)
aAdd(aStruct,{"A1_ESTC"		,"C", TamSX3("A1_ESTC")[1]		, TamSX3("A1_ESTC")[2]}		)
aAdd(aStruct,{"A1_MUN"		,"C", TamSX3("A1_MUN")[1]		, TamSX3("A1_MUN")[2]}		)
aAdd(aStruct,{"A1_MUNC"		,"C", TamSX3("A1_MUNC")[1]		, TamSX3("A1_MUNC")[2]}		)
aAdd(aStruct,{"A1_PESSOA"	,"C", TamSX3("A1_PESSOA")[1]	, TamSX3("A1_PESSOA")[2]}	)
//Incluido Ronaldo Bicudo / Totvs -  05/05/2017
aAdd(aStruct,{"A1_XMULTA"	,"N", TamSX3("A1_XMULTA")[1]	, TamSX3("A1_XMULTA")[2]}	)    
//FIM
//aAdd(aStruct,{"A6_COD"		,"C", TamSX3("A6_COD")[1]		, TamSX3("A6_COD")[2]}		)
//aAdd(aStruct,{"A6_AGENCIA"	,"C", TamSX3("A6_AGENCIA")[1]	, TamSX3("A6_AGENCIA")[2]}	)
//aAdd(aStruct,{"A6_NUMCON"	,"C", TamSX3("A6_NUMCON")[1]		, TamSX3("A6_NUMCON")[2]}	)
//aAdd(aStruct,{"A6_NOME"		,"C", TamSX3("A6_NOME")[1]		, TamSX3("A6_NOME")[2]}		)
//aAdd(aStruct,{"A6_DVCTA"		,"C", TamSX3("A6_DVCTA")[1]		, TamSX3("A6_DVCTA")[2]}		)

//Cria o arquivo temporário
cAliasTrb := CriaTrab(aStruct,.T.)
DbUseArea(.T.,__Localdrive, cAliasTrb,cAliasTrb)
IndRegua(cAliasTrb,cAliasTrb,"E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")

dbSelectArea(cAliasQry)
While !(cAliasQry)->(Eof())
	
	RecLock(cAliasTrb,.T.)
	
	For nX := 1 to Len(aStruct)
		cCampo := aStruct[nX][1]
		
		If aStruct[nX][2] == "D"
			xConteudo := StoD((cAliasQry)->&cCampo)
		Else
			xConteudo := 	(cAliasQry)->&cCampo
		EndIf
		
		(cAliasTrb)->&cCampo := xConteudo
	Next nX
	
	(cAliasTrb)->(MsUnlock())
	(cAliasQry)->(dbSkip())
	
EndDo

(cAliasQry)->(dbCloseArea())

Return(cAliasTrb)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999NN

Geração valor do "Nosso Numero"

@author    TOTVS
@version   11.90
@since     03/09/13

@param cBanco		- Cod. do Banco
@param	cAliasTmp	- Alias da tabela temporária

@return cRet 		- Cod. do Nosso Número

//------------------------------------------------------------------------------------------
/*/
Static Function FINX999NN(cAliasTmp,lDV)

Local cBanco	:= ""
Local cAux		:= ""
Local cNum		:= ""
Local cPrefixo	:= ""
Local cParcela	:= ""
Local cTipo		:= ""
Local cNossoNum	:= ""
Local cDV		:= ""
Local cRet		:= ""
Local aArea		:= getArea()
Local aAreaSEE	:= SEE->(getArea())
Local aAreaSE1	:= SE1->(getArea())
Local cAtual	:= ""
Local cCodCart	:= ""
Local cAgencia	:= ""
Local cConta	:= ""
Local nI		:= 0
Local nSoma		:= 0
Local nMult		:= 2
Local nResto	:= 0
Local nDig		:= 0
Local cChave	:= ""
Local cTempSE1	:= GetNextAlias()

DEFAULT cAliasTmp	:= ""
DEFAULT lDV		 	:= .T.

cBanco := (cAliasTmp)->A6_COD

BeginSql Alias cTempSE1
	SELECT E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_PORTADO,E1_AGEDEP,E1_CONTA,E1_NUMBCO,R_E_C_N_O_ SE1REC
	FROM %Table:SE1% SE1 (NOLOCK)
	WHERE SE1.E1_FILIAL	= %xFilial:SE1%
   	AND SE1.E1_PREFIXO	= %Exp:(cAliasTmp)->E1_PREFIXO%
   	AND SE1.E1_NUM		= %Exp:(cAliasTmp)->E1_NUM%
   	AND SE1.E1_PARCELA	= %Exp:(cAliasTmp)->E1_PARCELA%
   	AND SE1.E1_TIPO		= %Exp:(cAliasTmp)->E1_TIPO%
	AND SE1.%NotDel%
EndSql

Do Case 

	Case cBanco $ "237|745" //Bradesco|Citi
		cRet := ""
		
//		DbSelectArea("SE1")
//		SE1->(DbSetOrder(1))
//		If (SE1->(DbSeek(xFilial("SE1") + (cAliasTmp)->E1_PREFIXO + (cAliasTmp)->E1_NUM + (cAliasTmp)->E1_PARCELA + (cAliasTmp)->E1_TIPO)))
		dbSelectArea(cAliasTmp)
//		dbSelectArea(cAliasQry)
		If !Eof()
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
//			If (SEE->(DbSeek(xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + mv_par20)))
			If (SEE->(DbSeek(xFilial("SEE") + (cTempSE1)->E1_PORTADO + (cTempSE1)->E1_AGEDEP + (cTempSE1)->E1_CONTA + mv_par20)))
				cAtual := AllTrim(Iif(Empty((cTempSE1)->E1_NUMBCO), SUBSTR(SEE->EE_FAXATU,1,11), SUBSTR((cTempSE1)->E1_NUMBCO,3,11)))
				cCodCart := AllTrim(SEE->EE_CODCART)
				cAgencia := AllTrim(SEE->EE_AGENCIA)
				cConta := AllTrim(SEE->EE_CONTA)

				cChave := cCodCart + cAtual

				For nI := Len(cChave) To 1 Step -1
					nSoma += Val(SubStr(cChave, nI, 1)) * nMult

					If (nMult == 7)
						nMult := 2
					Else
						nMult++
					Endif
				Next nI

				nResto := Mod(nSoma, 11)
				If nResto = 0
					nDig := 0 
				Else
					nDig := 11 - nResto
				EndIf

				cRet := cCodCart + cAtual + Iif(nDig = 10, "P", cValToChar(nDig))

//				If (Empty((cAliasQry)->E1_NUMBCO))
				If (Empty((cAliasTmp)->E1_NUMBCO))
					cQryG85 := "UPDATE " + RetSqlName("SE1")
					cQryG85 += " SET E1_NUMBCO = '"+ cRet +"'"
					cQryG85 += " WHERE E1_FILIAL	= '"+ xFilial("SE1")+ "' "
					cQryG85 += " AND E1_PREFIXO		= '"+ AllTrim((cAliasTmp)->E1_PREFIXO) +"' "
					cQryG85 += " AND E1_NUM			= '"+ AllTrim((cAliasTmp)->E1_NUM)+"' "
					cQryG85 += " AND E1_PARCELA		= '"+ AllTrim((cAliasTmp)->E1_PARCELA)+"' "
					cQryG85 += " AND E1_CLIENTE		= '"+ AllTrim((cAliasTmp)->A1_COD)+"' "
					cQryG85 += " AND E1_LOJA		= '"+ AllTrim((cAliasTmp)->A1_LOJA)+"' "
					cQryG85 += " AND D_E_L_E_T_		= '' "

					nStatus := TCSQLEXEC(cQryG85)

/*/					DbSelectArea("SE1")
					
					RecLock("SE1", .F.)
					//SE1->E1_NUMBCO := SEE->EE_FAXATU  
					SE1->E1_NUMBCO := cRet  					
					SE1->(MsUnlock())
/*/					
					DbSelectArea("SEE")

					RecLock("SEE", .F.)
					SEE->EE_FAXATU := StrZero((Val(SEE->EE_FAXATU) + 1), Len(AllTrim(SEE->EE_FAXATU)))
					SEE->(MsUnlock())
				Endif
			Endif
		Endif

	Case cBanco $ "422" //Safra
		cRet := ""

//		DbSelectArea("SE1")
//		SE1->(DbSetOrder(1))
//		If (SE1->(DbSeek(xFilial("SE1") + (cAliasTmp)->E1_PREFIXO + (cAliasTmp)->E1_NUM + (cAliasTmp)->E1_PARCELA + (cAliasTmp)->E1_TIPO)))
		dbSelectArea(cAliasTmp)
//		dbSelectArea(cAliasQry)
		If !Eof()
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
//			If (SEE->(DbSeek(xFilial("SEE") + (cAliasQry)->E1_PORTADO + (cAliasQry)->E1_AGEDEP + (cAliasQry)->E1_CONTA + mv_par20)))
			If (SEE->(DbSeek(xFilial("SEE") + (cAliasTmp)->E1_PORTADO + (cAliasTmp)->E1_AGEDEP + (cAliasTmp)->E1_CONTA + mv_par20)))
				//cAtual := AllTrim(Iif(Empty(SE1->E1_NUMBCO), SUBSTR(SEE->EE_FAXATU,1,9), SUBSTR(SE1->E1_NUMBCO,1,9))) WILSON 08/01
//				cAtual := AllTrim(Iif(Empty((cAliasQry)->E1_NUMBCO), STRZERO(VAL(SEE->EE_FAXATU),9), STRZERO(VAL((cAliasQry)->E1_NUMBCO),9) ))
				cAtual := AllTrim(Iif(Empty((cAliasTmp)->E1_NUMBCO), STRZERO(VAL(SEE->EE_FAXATU),9), STRZERO(VAL((cAliasTmp)->E1_NUMBCO),9) ))
				cCodCart := AllTrim(SEE->EE_CODCART)
				//cAgencia := AllTrim(SEE->EE_AGENCIA) wilson 08/01
				cAgencia := strzero(val(SEE->EE_AGENCIA),4)
				//cConta := AllTrim(SEE->EE_CONTA) wilson 08/01
				cConta := strzero(val(SEE->EE_CONTA),6)

				//cChave := cCodCart + cAtual
				//cChave := cAtual + "2" WILSON 08/01
				cChave := cAtual				

				For nI := Len(cChave) To 1 Step -1
					nSoma += Val(SubStr(cChave, nI, 1)) * nMult

					If (nMult == 7)
						nMult := 2
					Else
						nMult++
					Endif
				Next nI

				nResto := Mod(nSoma, 11)
				nDig := 11 - nResto

				//cRet := cCodCart + cAtual + Iif(nDig > 9, "0", cValToChar(nDig))
				//cRet := cAtual + Iif(nDig > 9, "0", cValToChar(nDig))                                                                

				cRet := cAtual //+ Iif(nDig > 9, "0", cValToChar(nDig))
				If (Empty(SE1->E1_NUMBCO))

					cQryG85 := "UPDATE " + RetSqlName("SE1")
					cQryG85 += " SET E1_NUMBCO = '"+ cRet +"'"
					cQryG85 += " WHERE E1_FILIAL	= '"+ xFilial("SE1")+ "' "
					cQryG85 += " AND E1_PREFIXO		= '"+ AllTrim((cAliasTmp)->E1_PREFIXO) +"' "
					cQryG85 += " AND E1_NUM			= '"+ AllTrim((cAliasTmp)->E1_NUM)+"' "
					cQryG85 += " AND E1_PARCELA		= '"+ AllTrim((cAliasTmp)->E1_PARCELA)+"' "
					cQryG85 += " AND E1_CLIENTE		= '"+ AllTrim((cAliasTmp)->A1_COD)+"' "
					cQryG85 += " AND E1_LOJA		= '"+ AllTrim((cAliasTmp)->A1_LOJA)+"' "
					cQryG85 += " AND D_E_L_E_T_		= '' "

					nStatus := TCSQLEXEC(cQryG85)
/*/					DbSelectArea("SE1")
					
					RecLock("SE1", .F.)
					//SE1->E1_NUMBCO := SEE->EE_FAXATU  
					SE1->E1_NUMBCO := cRet
					SE1->(MsUnlock())
/*/					
					DbSelectArea("SEE")

					RecLock("SEE", .F.)
					SEE->EE_FAXATU := StrZero((Val(SEE->EE_FAXATU) + 1), Len(AllTrim(SEE->EE_FAXATU)))
					SEE->(MsUnlock())
				Endif
			Endif
		Endif

		/*
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek(xFilial("SE1")+(cAliasTmp)->E1_PREFIXO+(cAliasTmp)->E1_NUM+(cAliasTmp)->E1_PARCELA+(cAliasTmp)->E1_TIPO)
		
		cNossoNum	:= NNItau((cAliasTmp)->E1_PREFIXO, (cAliasTmp)->E1_NUM, (cAliasTmp)->E1_PARCELA, (cAliasTmp)->E1_TIPO)
		
		cAux	:= ALLTRIM(SEE->EE_CODCART) //"09" //Número carteira Fornecido pelo Banco
		cNum	:= cAux+STRZERO(VAL(cNossoNum),11)
		cDV		:= aFINX999M11(cNum,2,cBanco)
		cRet	:= cNum+cDV
		
		RECLOCK("SE1",.F.)
		SE1->E1_NUMBCO := cRet
		MsUnlock()
		*/

	Case cBanco == "341" //Itaú
		cRet := ""

//		DbSelectArea("SE1")
//		SE1->(DbSetOrder(1))
//		If (SE1->(DbSeek(xFilial("SE1") + (cAliasTmp)->E1_PREFIXO + (cAliasTmp)->E1_NUM + (cAliasTmp)->E1_PARCELA + (cAliasTmp)->E1_TIPO)))
		dbSelectArea(cAliasTmp)
//		dbSelectArea(cAliasQry)
		If !Eof()
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
			If (SEE->(DbSeek(xFilial("SEE") + (cTempSE1)->E1_PORTADO + (cTempSE1)->E1_AGEDEP + (cTempSE1)->E1_CONTA + mv_par20)))
				cAtual := AllTrim(Iif(Empty((cTempSE1)->E1_NUMBCO), ALLTRIM(SEE->EE_FAXATU), SUBSTR((cTempSE1)->E1_NUMBCO,1,8)))
				cCodCart := AllTrim(SEE->EE_CODCART)
				cAgencia := AllTrim(SEE->EE_AGENCIA)
				cConta := AllTrim(SEE->EE_CONTA)

				cChave := cAgencia + cConta + cCodCart + cAtual

				For nI := Len(cChave) To 1 Step -1
					nSoma += Iif(Val(SubStr(cChave, nI, 1)) * nMult > 9, Val(SubStr(cValToChar(Val(SubStr(cChave, nI, 1)) * nMult), 1, 1)) + Val(SubStr(cValToChar(Val(SubStr(cChave, nI, 1)) * nMult), 2, 1)), Val(SubStr(cChave, nI, 1)) * nMult)

					If (nMult == 1)
						nMult := 2
					Else
						nMult--
					Endif
				Next nI

				If (nSoma > 10)
					nResto := Mod(nSoma, 10)
				Endif

				nDig := 10 - nResto

				If (nDig > 9)
					nDig := 0
				Endif

				//cRet := cCodCart + cAtual + cValToChar(nDig)
				cRet := cCodCart + cAtual + cValToChar(nDig)

				If (Empty(SE1->E1_NUMBCO))
					cQryG85 := "UPDATE " + RetSqlName("SE1")
					cQryG85 += " SET E1_NUMBCO = '"+ SUBSTR(cRet,4,9) +"'"
					cQryG85 += " WHERE E1_FILIAL	= '"+ xFilial("SE1")+ "' "
					cQryG85 += " AND E1_PREFIXO		= '"+ AllTrim((cAliasTmp)->E1_PREFIXO) +"' "
					cQryG85 += " AND E1_NUM			= '"+ AllTrim((cAliasTmp)->E1_NUM)+"' "
					cQryG85 += " AND E1_PARCELA		= '"+ AllTrim((cAliasTmp)->E1_PARCELA)+"' "
					cQryG85 += " AND E1_CLIENTE		= '"+ AllTrim((cAliasTmp)->A1_COD)+"' "
					cQryG85 += " AND E1_LOJA		= '"+ AllTrim((cAliasTmp)->A1_LOJA)+"' "
					cQryG85 += " AND D_E_L_E_T_		= '' "

					nStatus := TCSQLEXEC(cQryG85)
/*/					DbSelectArea("SE1")
					RecLock("SE1", .F.)
					//SE1->E1_NUMBCO := SEE->EE_FAXATU
					SE1->E1_NUMBCO := SUBSTR(cRet,4,9)
					SE1->(MsUnlock())
/*/					
					DbSelectArea("SEE")

					RecLock("SEE", .F.)
					SEE->EE_FAXATU := StrZero((Val(SEE->EE_FAXATU) + 1), Len(AllTrim(SEE->EE_FAXATU)))
					SEE->(MsUnlock())
				Endif
			Endif
		Endif

	Case cBanco == "707" //Banco Daycoval
		cRet := ""
//		DbSelectArea("SE1")
//		SE1->(DbSetOrder(1))
//		If (SE1->(DbSeek(xFilial("SE1") + (cAliasTmp)->E1_PREFIXO + (cAliasTmp)->E1_NUM + (cAliasTmp)->E1_PARCELA + (cAliasTmp)->E1_TIPO)))
		dbSelectArea(cAliasTmp)
//		dbSelectArea(cAliasQry)
		If !Eof()
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
			If (SEE->(DbSeek(xFilial("SEE") + (cTempSE1)->E1_PORTADO + (cTempSE1)->E1_AGEDEP + (cTempSE1)->E1_CONTA + mv_par20)))
				cAtual := AllTrim(Iif(Empty((cTempSE1)->E1_NUMBCO), ALLTRIM(SEE->EE_FAXATU), ALLTRIM((cTempSE1)->E1_NUMBCO)))
				//cNossoNum	:= NNItau((cAliasTmp)->E1_PREFIXO, (cAliasTmp)->E1_NUM, (cAliasTmp)->E1_PARCELA, (cAliasTmp)->E1_TIPO)
				//cNum 		:= NNItau (cPrefixo, cNum, cParcela, cTipo)
				cAux	:= "19" //Número carteira Fornecido pelo Banco
				cNum	:= AllTrim(cAtual)
				cDV		:= _M10("19"+cNum)

				cRet	:= cAux+cNum+cDV

				If (Empty(SE1->E1_NUMBCO))
					cQryG85 := "UPDATE " + RetSqlName("SE1")
					cQryG85 += " SET E1_NUMBCO = '"+ cNum+cDV +"'"
					cQryG85 += " WHERE E1_FILIAL	= '"+ xFilial("SE1")+ "' "
					cQryG85 += " AND E1_PREFIXO		= '"+ AllTrim((cAliasTmp)->E1_PREFIXO) +"' "
					cQryG85 += " AND E1_NUM			= '"+ AllTrim((cAliasTmp)->E1_NUM)+"' "
					cQryG85 += " AND E1_PARCELA		= '"+ AllTrim((cAliasTmp)->E1_PARCELA)+"' "
					cQryG85 += " AND E1_CLIENTE		= '"+ AllTrim((cAliasTmp)->A1_COD)+"' "
					cQryG85 += " AND E1_LOJA		= '"+ AllTrim((cAliasTmp)->A1_LOJA)+"' "
					cQryG85 += " AND D_E_L_E_T_		= '' "

					nStatus := TCSQLEXEC(cQryG85)

/*/			  		DbSelectArea("SE1")
			
					RecLock("SE1", .F.)
					//SE1->E1_NUMBCO := SEE->EE_FAXATU
					SE1->E1_NUMBCO := cNum+cDV
					SE1->(MsUnlock())
/*/			
					DbSelectArea("SEE")

					RecLock("SEE", .F.)
					SEE->EE_FAXATU := StrZero((Val(SEE->EE_FAXATU) + 1), Len(AllTrim(SEE->EE_FAXATU)))
					SEE->(MsUnlock())
				Endif
			Endif
		Endif

	Case cBanco == "033" //Santander

		cRet := ""

//		DbSelectArea("SE1")
//		SE1->(DbSetOrder(1))
//		If (SE1->(DbSeek(xFilial("SE1") + (cAliasTmp)->E1_PREFIXO + (cAliasTmp)->E1_NUM + (cAliasTmp)->E1_PARCELA + (cAliasTmp)->E1_TIPO)))
		dbSelectArea(cAliasTmp)
//		dbSelectArea(cAliasQry)
		If !Eof()
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
			If (SEE->(DbSeek(xFilial("SEE") + (cTempSE1)->E1_PORTADO + (cTempSE1)->E1_AGEDEP + (cTempSE1)->E1_CONTA + mv_par20)))
				cAtual := AllTrim(Iif(Empty((cTempSE1)->E1_NUMBCO), SEE->EE_FAXATU, SUBSTR((cTempSE1)->E1_NUMBCO,1,12)))
				cCodCart := AllTrim(SEE->EE_CODCART)
				cAgencia := AllTrim(SEE->EE_AGENCIA)
				cConta := AllTrim(SEE->EE_CONTA)

				If Len(cAtual) < 13
					cChave := cAtual

					For nI := Len(cChave) To 1 Step -1
						nSoma += Val(SubStr(cChave, nI, 1)) * nMult

						If (nMult == 9)
							nMult := 2
						Else
							nMult++
						Endif
					Next nI

					nResto := Mod(nSoma, 11)

					//Incluido Ronaldo Bicudo - Totvs / 27/06/2017
					If nResto >= 10
						nDig = '1'
					ElseIf nResto = 1 .or. nResto = 0
						nDig = '0'
					Else
						nDig := 11 - nResto
					EndIf 

					//cRet := cAtual + Iif(nDig = 10, "1", Iif(nDig == 1 .Or. nDig == 0, "0", cValToChar(nDig)))
					cRet := cAtual + cValToChar(nDig)
				Else
					cRet := cAtual
				EndIf
				//FIM
				//wilson 10/11/2017

				cRet := StrZero(val(cRet),13)

				If (Empty(SE1->E1_NUMBCO))

					cQryG85 := "UPDATE " + RetSqlName("SE1")
					cQryG85 += " SET E1_NUMBCO = '"+ cRet +"'"
					cQryG85 += " , E1_IDCNAB   = '"+ SUBSTR(SEE->EE_FAXATU,3,10) + "'"
					cQryG85 += " WHERE E1_FILIAL	= '"+ xFilial("SE1")+ "' "
					cQryG85 += " AND E1_PREFIXO		= '"+ AllTrim((cAliasTmp)->E1_PREFIXO) +"' "
					cQryG85 += " AND E1_NUM			= '"+ AllTrim((cAliasTmp)->E1_NUM)+"' "
					cQryG85 += " AND E1_PARCELA		= '"+ AllTrim((cAliasTmp)->E1_PARCELA)+"' "
					cQryG85 += " AND E1_CLIENTE		= '"+ AllTrim((cAliasTmp)->A1_COD)+"' "
					cQryG85 += " AND E1_LOJA		= '"+ AllTrim((cAliasTmp)->A1_LOJA)+"' "
					cQryG85 += " AND D_E_L_E_T_		= '' "

					nStatus := TCSQLEXEC(cQryG85)

/*/					DbSelectArea("SE1")
					RecLock("SE1", .F.)
					//SE1->E1_NUMBCO := SEE->EE_FAXATU 
					SE1->E1_NUMBCO := cRet
					SE1->E1_IDCNAB := SUBSTR(SEE->EE_FAXATU,3,10)
					SE1->(MsUnlock())
/*/					
					DbSelectArea("SEE")

					RecLock("SEE", .F.)
					SEE->EE_FAXATU := StrZero((Val(SEE->EE_FAXATU) + 1), Len(AllTrim(SEE->EE_FAXATU)))
					SEE->(MsUnlock())
				Endif
			Endif
		Endif

EndCase

Return cRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999CpL

Geração valor do "Campo Livre" para alguns bancos

@author    TOTVS
@version   11.90
@since     04/09/13

@param	cAliasTmp	- Alias da tabela temporária

@return cRet 		- Cod. do Campo Livre

//------------------------------------------------------------------------------------------
/*/
Static Function FINX999CpL(cAliasTmp)

Local cBanco 	:= ""
Local cRet 	:= ""

DEFAULT cAliasTmp := ""

cBanco := (cAliasTmp)->A6_COD

Do Case
	Case cBanco == "237" //Bradesco
		cRet := ""
		cRet += PadL((cAliasTmp)->A6_AGENCIA,4,"0") 	    //Agencia
		//cRet += "22" 										//Carteira
		//cRet += ALLTRIM(SEE->EE_CODCART) 					//Carteira
		cRet += FINX999NN(cAliasTmp)						//Nosso Numero
		cRet += PadL((cAliasTmp)->A6_NUMCON,7,"0") 	        //Conta
		cRet += "0"										    //Constante Zero
	Case cBanco == "422" //Banco Safra
		cRet := ""
		cRet += PadL((cAliasTmp)->A6_AGENCIA,4,"0") 	//Agencia
		cRet += "22" 										//Carteira
		cRet += FINX999NN(cAliasTmp)						//Nosso Numero
		cRet += PadL((cAliasTmp)->A6_NUMCON,7,"0") 	//Conta
		cRet += "0"										//Constante Zero
	Case cBanco == "707" //Daycoval
		cRet := ""
		cRet += PadL((cAliasTmp)->A6_AGENCIA,4,"0") 	//Agencia
		cRet += "22" 										//Carteira
		cRet += FINX999NN(cAliasTmp)						//Nosso Numero
		cRet += PadL((cAliasTmp)->A6_NUMCON,7,"0") 	//Conta
		cRet += "0"
	Case cBanco == "745" //Banco Citi
		cRet := ""
		cRet += PadL((cAliasTmp)->A6_AGENCIA,4,"0") 	//Agencia
		cRet += "22" 										//Carteira
		cRet += FINX999NN(cAliasTmp)						//Nosso Numero
		cRet += PadL((cAliasTmp)->A6_NUMCON,7,"0") 	//Conta
		cRet += "0"										//Constante Zero
EndCase

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999M10

Cálculo do módulo 10

-----------------------------------------------------------------------------------
|	Cálculo:																		|
|																					|
|	1) 	Multiplica-se cada algarismo (nFator) pela sequencia de						|
|			multiplicadores (nMult) 2 e 1, da direita para a esquerda.				|
|			Ex.: 	0	1	2	3	4	5											|
|					|	|	|	|	|	|											|
|					X	X	X	X	X	X											|
|					|	|	|	|	|	|											|
|					1	2	1	2	1	2 <--										|
|					-------------------												|
|					0	1	2	6	8	10											|
|																					|
|	2) 	Nos resultados em que o valor form maior que 9, soma-se os 					|
|		dígitos:																	|
|																					|
|		Ex.:	0	1	2	6	8	10												|
|				--------------------												|
|				0	1	2	6	8	1												|
|																					|
|	3) Soma-se os valores para obter N (nSoma)										|
|																					|
|		Ex.:	0 + 1 + 2 + 6 + 8 + 1 = 18											|
|																					|
|	4) O Resto da divisão de N por 10 é subtraído de 10 para obter o DV.			|
|																					|
|			Ex.: 	18/10 	= 1 (resta 8)											|
|					10 - 8	= 2														|
|																					|
|					DV = 2															|
|																					|
-----------------------------------------------------------------------------------

@author    TOTVS
@version   11.90
@since     30/08/13

@param 		cBase	- Cadeia de algarismos base

@return	cRet 	- Dígito Verificador

//------------------------------------------------------------------------------------------
/*/
Static Function _M10(cData)
Local L,D,P := 0
Local B     := .F.

L := Len(cData)  //TAMANHO DE BYTES DO CARACTER
B := .T.
D := 0     //DIGITO VERIFICADOR
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P >= 10
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End

Return(Str(D,1))

/*
Local cAux		:= ""
Local cRet		:= ""
Local nX		:= 0
Local nMult		:= 0
Local nFator	:= 0
Local nSoma		:= 0
Local nResult	:= 0

DEFAULT cBase 	:= ""

nMult 	:= 2 //o multiplicador base inicia com 2

For nX := Len(cBase) to 1 step -1
//Algarismo
nFator := Val(SubStr(cBase,nX,1))

//Multiplicador
If nMult > 1
nMult-- //(1)
Else
nMult++ //(2)
EndIf

//Resultado da Multiplicação
cAux  := StrZero(nFator * nMult,2)
nSoma += (Val(Left(cAux,1)) + Val(Right(cAux,1)))

Next nX

//Modulo 10
nResult := Mod(nSoma,10)

If nResult == 10 		//Resultado 10 --> DV = 0
nResult := 0
ElseIf nResult > 0 	//Resultado > 0 --> DV = 10 - Mod(10)
nResult := 10 - nResult
EndIf

cRet := Str(nResult,1)

Return cRet
*/

Static Function Ana(cBase)

Local cAux		:= ""
Local cRet		:= ""
Local nX		:= 0
Local nMult		:= 0
Local nFator	:= 0
Local nSoma		:= 0
Local nResult	:= 0

DEFAULT cBase 	:= ""

nMult 	:= 1 //o multiplicador base inicia com 2

For nX := Len(cBase) to 1 step -1
	//Algarismo
	nFator := Val(SubStr(cBase,nX,1))
	
	//Multiplicador
	If nMult > 1
		nMult-- //(1)
	Else
		nMult++ //(2)
	EndIf
	
	//Resultado da Multiplicação
	
	cAux  := StrZero(nFator * nMult,2)
	If val(cAux) >= 10
		
		cAux := substr(cAux,1,1)
	EndIf
	nSoma += (Val(Left(cAux,1)) + Val(Right(cAux,1)))
	
Next nX

//Modulo 10
nResult := Mod(nSoma,10)

If nResult == 10 		//Resultado 10 --> DV = 0
	nResult := 0
ElseIf nResult > 0 	//Resultado > 0 --> DV = 10 - Mod(10)
	nResult := 10 - nResult
EndIf

cRet := Str(nResult,1)

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999M11

Cálculo do módulo 11

-----------------------------------------------------------------------------------
|	Cálculo:																		|
|																					|
|	1) 	Multiplica-se cada algarismo (nFator) pela sequencia de						|
|		multiplicadores (nMult) 9 a 2, por exemplo, da direita para a esquerda.		|
|			Ex.: 	0	1	2	3	4	5											|
|					|	|	|	|	|	|											|
|					X	X	X	X	X	X											|
|					|	|	|	|	|	|											|
|					4	5	6	7	8	9 <--										|
|					----------------------											|
|					0	5	12	21	32	45											|
|																					|
|	2) 	Nos resultados em que o valor form maior que 9, soma-se os 					|
|		dígitos:																	|
|																					|
|		Ex.:	0	5	12	21	32	45												|
|				----------------------												|
|				0	5	3	3	5	9												|
|																					|
|	3) Soma-se os valores para obter N (nSoma)										|
|																					|
|		Ex.:	0 + 5 + 3 + 3 + 5 + 9 = 25											|
|																					|
|	4) 	Para o calculo do Dígito Verificador, cada banco possui uma regra a partir	|
|		do resto da divisão do fator N por 11.										|
|																					|
-----------------------------------------------------------------------------------

@author    TOTVS
@version   11.90
@since     30/08/13

@param 		cBase	- Cadeia de algarismos base
@param 		nOper	- Operação 1 (Codigo de Barras) e 2 (Nosso Numero e outros)
@param 		cBanco	- Cod. Banco

@return	cRet 	- Dígito Verificador

//------------------------------------------------------------------------------------------
/*/
Static Function aFINX999M11(cBase,nOper,cBanco)

Local cRet	:= ""
Local aNumAux := Array(Len(cBase),3) //array com o conteudo do cNum para ser multiplicado
Local aLisMult:= {9,8,7,6,5,4,3,2} //Array/Lista de Multiplicadores
Local nResto
Local nX 		:= 0
Local nSoma   	:= 0
Local nResult 	:= 0
Local nPos		:= 0

DEFAULT cBase	:= ""
DEFAULT cBanco	:= ""
DEFAULT nOper 	:= 0

//nOper = 	1 (Codigo de Barras)
//			2 (Nosso Numero e outros)

//Multiplicadores
If cBanco == "237"
	aLisMult:= {7,6,5,4,3,2} //Bradesco utiliza base 7
Else
	aLisMult:= {9,8,7,6,5,4,3,2} //Outros Bancos utilizam base 9
EndIf

nPos := Len(aLisMult)

For nX := Len(cBase) to 1 step -1
	
	//Algarismo
	aNumAux[nX,1] := Val(SubStr(cBase,nX,1))
	
	//Multiplicador
	aNumAux[nX,2] := aLisMult[nPos]
	nPos--
	If nPos == 0
		nPos := Len(aLisMult)
	EndIf
	
	//Fator N
	aNumAux[nX,3] := aNumAux[nX,2] * aNumAux[nX,1]
	nSoma += aNumAux[nX,3]
Next

nResto := Mod(nSoma,11)

If nOper == 1
	
	nResult := 11 - nResto
	
	Do Case
		Case cBanco == "745" //Banco Citi
			
			If nResult == 0 .Or. nResult == 10 .Or. nResult == 11
				nResult := 1
			EndIf
			
		Case cBanco == "237" //Bradesco
			
			If nResult == 0 .Or. nResult == 1 .Or. nResult > 9
				nResult := 1
			EndIf
			
		Case cBanco == "422" //Banco Safra
			
			If nResult == 0 .Or. nResult == 1 .Or. nResult > 9
				nResult := 1
			EndIf
			
		Case cBanco == "707" //Daycoval
			
			If nResult == 0 .Or. nResult == 1 .Or. nResult > 9
				nResult := 1
			EndIf
			
		Case cBanco == "341" //Itaú
			
			If nResult == 0 .Or. nResult == 0 .Or. nResult == 10 .Or. nResult == 11
				nResult := 1
			EndIf
			
		Case cBanco == "033" //Santander
			
			If nResult == 0 .Or. nResult == 10 .Or. nResult == 11
				nResult := 1
			EndIf
			
	EndCase
	
	cRet := Str(nResult,1)
	
ElseIf nOper == 2 //Nosso numero e outros
	
	Do Case
		
		Case cBanco == "745" //Banco Citi
			
			If nResto < 10
				nResult := nResto
				cRet := Str(nResult,1)
			ElseIf nResto == 10
				cRet := "X"
			EndIf
			
		Case cBanco == "237" //Bradesco
			
			If nResto == 0
				nResult := 0
			ElseIf nResto == 1
				cRet := "P"
			Else
				nResult := 11 - nResto
				cRet := Str(nResult,1)
			EndIf
			
		Case cBanco == "422" //Banco Safra
			
			If nResto == 0
				nResult := 0
			ElseIf nResto == 1
				cRet := "P"
			Else
				nResult := 11 - nResto
				cRet := Str(nResult,1)
			EndIf
			
		Case cBanco == "707" //Daycoval
			
			If nResto == 0
				nResult := 0
			ElseIf nResto == 1
				cRet := "P"
			Else
				nResult := 11 - nResto
				cRet := Str(nResult,1)
			EndIf
			
		Case cBanco == "033" //Santander
			
			If nResto == 10
				nResult := 1
			ElseIf nResto == 0 .Or. nResto == 1
				nResult := 0
			Else
				nResult := 11 - nResto
			EndIf
			
			cRet := Str(nResult,1)
			
	EndCase
	
EndIf

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999NCB

Geração o cálculo do código de barras

@author    TOTVS
@version   11.90
@since     04/09/13

@param	cAliasTmp	- Alias da tabela temporária

@return cRet 		- Código de Barras

//------------------------------------------------------------------------------------------
/*/
Static Function _NCB(cAliasTmp)

Local cBlk1	:= ""
Local cBlk2	:= ""
Local cDV		:= ""
Local cCB 		:= ""
Local cBanco	:= ""
Local cAuxKey	:= ""
Local cCpoAux	:= ""
Local nVlrAbat	:= ""
Local aArea 	:= getArea()
Local aAreaSEE 	:= SEE->(getArea())
Local cSubConta := MV_PAR20
Local cCodbar :=""
Local nSoma := 0
Local nMult := 2
//Incluido Ronaldo Bicudo - 26/04/2017
Local nPercMul := SUPERGETMV("MV_LJMULTA", .T. , 5 )   //GetMv("MV_LJMULTA") //valor percentual em multa
Local nPercMJ  := SUPERGETMV("MV_LJUROS" , .T. , 0.03 )//GetMv("MV_LJUROS") //valor percentual em juros/mora
Local nJuros   := 0
Local nMulta   := 0
Local nTotJM   := 0 //Valor total de juros/mora + multa
Local nDias    := 0 //Quantidade de dias para calculo de Juros/Mora
Local nI		:=0
//Fim

DEFAULT cAliasTmp := ""

DbSelectArea("SEE")
DbSetOrder(1)
DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)+cSubConta)

cBanco 		:= (cAliasTmp)->A6_COD
nVlrAbat 	:= SomaAbat((cAliasTmp)->E1_PREFIXO,(cAliasTmp)->E1_NUM,(cAliasTmp)->E1_PARCELA,"R",1,dDataBase,(cAliasTmp)->A1_COD,(cAliasTmp)->A1_LOJA)

//Incluido Ronaldo Bicudo - 26/04/2017
If 	Alltrim((cAliasTmp)->E1_XCOBJM) <> '2'
	If !Empty((cAliasTmp)->E1_XDTPROR) 
		nDias  := Abs((cAliasTmp)->E1_VENCREA - (cAliasTmp)->E1_XDTPROR)
		//Incluido Ronaldo Bicudo / Totvs - 05/05/2017
		If (cAliasTmp)->E1_XMULTA > 0 
			nMulta := Round((cAliasTmp)->E1_SALDO * ((cAliasTmp)->E1_XMULTA/100),2)
		ElseIf (cAliasTmp)->A1_XMULTA > 0 
			nMulta := Round((cAliasTmp)->E1_SALDO * ((cAliasTmp)->A1_XMULTA/100),2)
		Else
			nMulta := Round((cAliasTmp)->E1_SALDO * (nPercMul/100),2)
		EndIf
		//FIM
		nPercMj := (nPercMJ/100) * nDias
		nJuros := Round((cAliasTmp)->E1_SALDO * nPercMJ,2)
		nTotJM := nJuros + nMulta //Valor total de multa e mora/juros ao dia
	EndIf
EndIf
//Fim

Do Case
 
	Case cBanco $ "745|237|707" //CitiBank/Bradesco
		
		/*		cCpoAux := FINX999CpL(cAliasTmp)
		
		//Bloco 1
		cBlk1 := ""
		cBlk1 += cBanco 														//Banco
		cBlk1 += "9"															//Moeda
		
		//Bloco 2
		cBlk2 := ""
		cBlk2 += StrZero((cAliasTmp)->E1_VENCTO-CtoD("07/10/97"),4) 	//Vencimento
		cBlk2 += StrZero(((cAliasTmp)->E1_SALDO - nVlrAbat)*100,10)		//Valor
		cBlk2 += cCpoAux														//Campo Livre
		*/
		 		
		nSoma := 0
		nMult := 2
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		If (SE1->(DbSeek(xFilial("SE1") + (cAliasTmp)->E1_PREFIXO + (cAliasTmp)->E1_NUM + (cAliasTmp)->E1_PARCELA + (cAliasTmp)->E1_TIPO)))
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
			If (SEE->(DbSeek(xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + mv_par20)))
				cAtual := AllTrim(Iif(Empty(SE1->E1_NUMBCO), SUBSTR(SEE->EE_FAXATU,1,11), SUBSTR(SE1->E1_NUMBCO,3,11)))
				cCodCart := AllTrim(SEE->EE_CODCART)
				cAgencia := AllTrim(SEE->EE_AGENCIA)
				cConta := AllTrim(SEE->EE_CONTA)

				cChave := cCodCart + cAtual

				For nI:= Len(cChave) To 1 Step -1
					nSoma += Val(SubStr(cChave, nI, 1)) * nMult

					If (nMult == 7)
						nMult := 2
					Else
						nMult++
					Endif
				Next nI

				nResto := Mod(nSoma, 11)
				nDig := 11 - nResto

				cNossoNum := cCodCart + cAtual + Iif(nDig > 9, "0", cValToChar(nDig))

				//cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100), 10) + ;
				//cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((IIF(Empty(SE1->E1_XDTPROR),SE1->E1_VENCREA,SE1->E1_XDTPROR) - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				AllTrim(SEE->EE_AGENCIA) + AllTrim(SEE->EE_CODCART) + cAtual + StrZero(Val(AllTrim(SEE->EE_CONTA)), 7) + "0")

				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100), 10) + ;
				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((IIF(Empty(SE1->E1_XDTPROR),SE1->E1_VENCREA,SE1->E1_XDTPROR) - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				AllTrim(SEE->EE_AGENCIA) + AllTrim(SEE->EE_CODCART) + cAtual + StrZero(Val(AllTrim(SEE->EE_CONTA)), 7) + "0"
			ENDIF
		ENDIF

	Case cBanco $ "422" //Safra

		/*		cCpoAux := FINX999CpL(cAliasTmp)
		
		//Bloco 1
		cBlk1 := ""
		cBlk1 += cBanco 														//Banco
		cBlk1 += "9"															//Moeda
		
		//Bloco 2
		cBlk2 := ""
		cBlk2 += StrZero((cAliasTmp)->E1_VENCTO-CtoD("07/10/97"),4) 	//Vencimento
		cBlk2 += StrZero(((cAliasTmp)->E1_SALDO - nVlrAbat)*100,10)		//Valor
		cBlk2 += cCpoAux														//Campo Livre
		*/
		nSoma := 0
		nMult := 2
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		If (SE1->(DbSeek(xFilial("SE1") + (cAliasTmp)->E1_PREFIXO + (cAliasTmp)->E1_NUM + (cAliasTmp)->E1_PARCELA + (cAliasTmp)->E1_TIPO)))
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
			If (SEE->(DbSeek(xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + mv_par20)))
				//cAtual := AllTrim(Iif(Empty(SE1->E1_NUMBCO), SUBSTR(SEE->EE_FAXATU,1,11), SUBSTR(SE1->E1_NUMBCO,1,11)))
				cAtual := AllTrim(Iif(Empty(SE1->E1_NUMBCO), STRZERO(VAL(SEE->EE_FAXATU),9), STRZERO(VAL(SE1->E1_NUMBCO),9) ))
				cCodCart := AllTrim(SEE->EE_CODCART)
				cAgencia := AllTrim(SEE->EE_AGENCIA)
				cConta := AllTrim(SEE->EE_CONTA)
				
				//cChave := cCodCart + cAtual
				cChave := cAtual
				
				For nI := Len(cChave) To 1 Step -1
					nSoma += Val(SubStr(cChave, nI, 1)) * nMult
					
					If (nMult == 7)
						nMult := 2
					Else
						nMult++
					Endif
				Next nI           

				nResto := Mod(nSoma, 11)
				nDig := 11 - nResto

				//cNossoNum := cCodCart + cAtual + Iif(nDig > 9, "0", cValToChar(nDig))
				cNossoNum := cAtual +"-"+ Iif(nDig > 9, "0", cValToChar(nDig))

				//cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100) , 10) + ;
				//cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((IIF(Empty(SE1->E1_XDTPROR),SE1->E1_VENCREA,SE1->E1_XDTPROR) - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100) , 10) + ;
				//cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100) , 10) + ;
				//"7" + StrZero(Val(AllTrim(SEE->EE_AGENCIA)),5)+ StrZero(Val(AllTrim(SEE->EE_CONTA)),9)+ cAtual + "2")
				cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100) , 10) + ;
				"7" + StrZero(Val(AllTrim(SEE->EE_AGENCIA)),5) + StrZero(Val(AllTrim(SEE->EE_CONTA)),8)+AllTrim(SEE->EE_DVCTA) + cAtual + "2")

				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100), 10) + ;
				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((IIF(Empty(SE1->E1_XDTPROR),SE1->E1_VENCREA,SE1->E1_XDTPROR) - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				//"7" + StrZero(Val(AllTrim(SEE->EE_AGENCIA)),5) + StrZero(Val(AllTrim(SEE->EE_CONTA)),9)+ cAtual + "2"
				cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + ;
				StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				"7" + StrZero(Val(AllTrim(SEE->EE_AGENCIA)),5) + StrZero(Val(AllTrim(SEE->EE_CONTA)),8)+AllTrim(SEE->EE_DVCTA) + cAtual + "2"				

			ENDIF
		ENDIF
		
		/*	Case cBanco == "707" //Daycoval
		
		cCpoAux := FINX999NN(cAliasTmp,.F.) //N. Numero sem DV
		
		//Bloco 1
		cBlk1 := ""
		cBlk1 += cBanco 																			//Banco
		cBlk1 += "9"																				//Moeda
		
		//Bloco 2
		cBlk2 := ""
		cBlk2 += StrZero((cAliasTmp)->E1_VENCTO-CtoD("07/10/97"),4) 						//Vencimento
		cBlk2 += StrZero(((cAliasTmp)->E1_SALDO - nVlrAbat)*100,10)							//Valor
		cBlk2 += PadR(AllTrim((cAliasTmp)->A6_NUMCON),7)										//Conta
		cBlk2 += cCpoAux 																			//N. Numero sem DV
		AuxKey := "01/01/"+Str(Year((cAliasTmp)->E1_VENCTO))
		cBlk2 += StrZero((l)->E1_VENCTO-CtoD(cAuxKey),3) 	 						//Vencimento em formato Juliano															//Fixo 000
		cBlk2 += SubStr(AllTrim(Str(Year((cAliasTmp)->E1_VENCTO))),4,1)						//Ultimo digito do ano (comp. Jul.)
		cBlk2 += "2"																				//Cod. Produto forn. pelo banco
		*/
	Case cBanco == "341" //Itaú
		
		cCpoAux := FINX999NN(cAliasTmp)
		
		cAuxKey := ""
		cAuxKey += Alltrim((cAliasTmp)->A6_AGENCIA)	//Agencia
		cAuxKey += Alltrim((cAliasTmp)->A6_NUMCON)	//Conta
		//cAuxKey += "109"					//Carteira forn. pelo banco
		cAuxKey += Alltrim(SEE->EE_CODCART)
		//cAuxKey += cCpoAux					//Nosso Numero
		cAuxKey += Alltrim(SE1->E1_NUMBCO)		
		
		//Bloco 1
		cBlk1 := ""
		cBlk1 += cBanco 																//Banco
		cBlk1 += "9"																	//Moeda
		
		//Bloco 2
		cBlk2 := ""
		//cBlk2 += StrZero((cAliasTmp)->E1_VENCREA-CtoD("07/10/97"),4) 			//Vencimento
		//cBlk2 += StrZero(IIF(Empty((cAliasTmp)->E1_XDTPROR),(cAliasTmp)->E1_VENCREA,(cAliasTmp)->E1_XDTPROR)-CtoD("07/10/97"),4) //Vencimento
		cBlk2 += StrZero((cAliasTmp)->E1_VENCREA-CtoD("07/10/97"),4) 			//Vencimento
		cBlk2 += StrZero((((cAliasTmp)->E1_SALDO - nVlrAbat)+ nTotJM)*100,10)				//Valor
		cBlk2 += SEE->EE_CODCART												//Carteira forn. pelo banco
		cBlk2 += SUBSTRING(cCpoAux,4,9)											//Nosso Numero - DIGITO JÁ ESTA NESTÁ VARIAVEL COMENTADO LINHA ABAIXO
		//cBlk2 += _M10(cAuxKey)													//DV
		cBlk2 += PadR(AllTrim((cAliasTmp)->A6_AGENCIA),4)						//Agencia
		cBlk2 += PadR(AllTrim((cAliasTmp)->A6_NUMCON),5)						//Conta
		//cBlk2 += _M10((cAliasTmp)->A6_AGENCIA+(cAliasTmp)->A6_NUMCON) 	    //DV
		cBlk2 += PadR(AllTrim((cAliasTmp)->A6_DVCTA),1)
		cBlk2 += "000"															//Fixo 000
		
	Case cBanco == "033" //Santander
		cCpoAux := FINX999NN(cAliasTmp)
		
		//Bloco 1
		cBlk1 := ""
		cBlk1 += cBanco 														//Banco
		cBlk1 += "9"															//Moeda
		
		//Bloco 2
		cBlk2 := ""
		//cBlk2 += StrZero((cAliasTmp)->E1_VENCREA-CtoD("07/10/97"),4) 			//Vencimento
		//cBlk2 += StrZero(IIF(Empty((cAliasTmp)->E1_XDTPROR),(cAliasTmp)->E1_VENCREA,(cAliasTmp)->E1_XDTPROR)-CtoD("07/10/97"),4) 			//Vencimento
		cBlk2 += StrZero((cAliasTmp)->E1_VENCREA-CtoD("07/10/97"),4) 			//Vencimento
		cBlk2 += StrZero((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM)*100,10)				//Valor
		cBlk2 += "9"															//Fixo 9
		cBlk2 += PadR(SEE->EE_CODEMP,7)										//Numero Convenio
		cBlk2 += cCpoAux 														//N. Numero
		cBlk2 += "0"															//IOS Seguradoras (7 a 9 ou 0)
		cBlk2 += SEE->EE_CODCART											//Carteira forn. pelo banco
EndCase

IF cBanco $ "237|422|745|707"
	
	cCB := cCodbar
	
else
	//Digito Verificado Mod. 11
	
	cDV := aFINX999M11(cBlk1+cBlk2,1,cBanco)
	//Cod. Barras
		cCB := cBlk1+cDV+cBlk2
endif
RestArea (aAreaSEE)
RestArea (aArea)

Return cCB

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999LDg

Geração da linha digitavel do boleto

@author    TOTVS
@version   11.90
@since     04/09/13

@param	cAliasTmp	- Alias da tabela temporária

@return cRet 		- String da Linha Digitável

//------------------------------------------------------------------------------------------
/*/
Static Function FINX999LDg(cAliasTmp)

Local cAuxKey	:= ""
Local cBanco  	:= ""
Local cCpoAux	:= ""
Local cCampo1 	:= ""
Local cCampo2 	:= ""
Local cCampo3 	:= ""
Local cCampo4 	:= ""
Local cCampo5 	:= ""
Local cCodBar	:= ""
Local cRet		:= ""
Local nVlrAbat	:= 0
Local aArea 	:= getArea()
Local aAreaSEE 	:= SEE->(getArea())
Local cSubConta := MV_PAR20
Local cAuxCp1   := ""
Local cAuxCp2	:= ""
Local cAuxCp3   := ""
Local nMult := 0
//Incluido Ronaldo Bicudo - 26/04/2017
Local nPercMul := SUPERGETMV("MV_LJMULTA", .T. , 5 )   //GetMv("MV_LJMULTA") //valor percentual em multa
Local nPercMJ  := SUPERGETMV("MV_LJUROS" , .T. , 0.03 )//GetMv("MV_LJUROS") //valor percentual em juros/mora
Local nJuros   := 0
Local nMulta   := 0
Local nTotJM   := 0 //Valor total de juros/mora + multa
Local nDias    := 0 //Quantidade de dias para calculo de Juros/Mora
Local nI		 := 0
//Fim

cBanco 	:= (cAliasTmp)->A6_COD
cCodBar := _NCB(cAliasTmp)

//Incluido Ronaldo Bicudo - 26/04/2017
If Alltrim((cAliasTmp)->E1_XCOBJM) <> '2' 
	If !Empty((cAliasTmp)->E1_XDTPROR) 
		nDias  := Abs((cAliasTmp)->E1_VENCREA - (cAliasTmp)->E1_XDTPROR)
		//Incluido Ronaldo Bicudo / Totvs - 05/05/2017
		If (cAliasTmp)->E1_XMULTA > 0 
			nMulta := Round((cAliasTmp)->E1_SALDO * ((cAliasTmp)->E1_XMULTA/100),2)
		ElseIf (cAliasTmp)->A1_XMULTA > 0 
			nMulta := Round((cAliasTmp)->E1_SALDO * ((cAliasTmp)->A1_XMULTA/100),2)
		Else
			nMulta := Round((cAliasTmp)->E1_SALDO * (nPercMul/100),2)
		EndIf
		//FIM
		nPercMj := (nPercMJ/100) * nDias
		nJuros := Round((cAliasTmp)->E1_SALDO * nPercMJ,2)
		nTotJM := nJuros + nMulta //Valor total de multa e mora/juros ao dia
	EndIf
EndIf
//Fim  cAliasTmp

DbSelectArea("SEE")
DbSetOrder(1)
DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)+cSubConta)

Do Case
	/* Case cBanco == "745" //Banco Citi
	cCpoAux := cCodBar
	//Campo 1
	cCampo1 += cBanco									//Banco
	cCampo1 += "9"										//Moeda
	cCampo1 += SubStr(cCpoAux,20,5)					//Cod. Barra 20-24
	cCampo1 += FINX999M10(cCampo1)					//DV
	//Campo 2
	cCampo2 += SubStr(cCpoAux,25,10)				//Cod. Barra 25-34
	cCampo2 += FINX999M10(cCampo2)					//DV
	//Campo 3
	cCampo3 += SubStr(cCpoAux,35,10)				//Cod. Barra 35-44
	cCampo3 += FINX999M10(cCampo3)					//DV */
	
	Case cBanco $ "237|745|707" //Bradesco|Citi|Daycoval
		nSoma := 0
		nMult := 2
		
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		If (SE1->(DbSeek(xFilial("SE1") + (cAliasTmp)->E1_PREFIXO + (cAliasTmp)->E1_NUM + (cAliasTmp)->E1_PARCELA + (cAliasTmp)->E1_TIPO)))
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
			If (SEE->(DbSeek(xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + mv_par20)))
				cAtual := AllTrim(Iif(Empty(SE1->E1_NUMBCO), SUBSTR(SEE->EE_FAXATU,1,11), SUBSTR(SE1->E1_NUMBCO,3,11)))
				cCodCart := AllTrim(SEE->EE_CODCART)
				cAgencia := AllTrim(SEE->EE_AGENCIA)
				cConta := AllTrim(SEE->EE_CONTA)
				
				cChave := cCodCart + cAtual
				
				For nI := Len(cChave) To 1 Step -1
					nSoma += Val(SubStr(cChave, nI, 1)) * nMult
					
					If (nMult == 7)
						nMult := 2
					Else
						nMult++
					Endif
				Next nI
				
				nResto := Mod(nSoma, 11)
				nDig := 11 - nResto
				
				cNossoNum := cCodCart + cAtual + Iif(nDig > 9, "0", cValToChar(nDig))
				
				//cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100), 10) + ;
				//cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((IIF(Empty(SE1->E1_XDTPROR),SE1->E1_VENCREA,SE1->E1_XDTPROR) - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				AllTrim(SEE->EE_AGENCIA) + AllTrim(SEE->EE_CODCART) + cAtual + StrZero(Val(AllTrim(SEE->EE_CONTA)), 7) + "0")
				
				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100), 10) + ;
				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((IIF(Empty(SE1->E1_XDTPROR),SE1->E1_VENCREA,SE1->E1_XDTPROR) - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				AllTrim(SEE->EE_AGENCIA) + AllTrim(SEE->EE_CODCART) + cAtual + StrZero(Val(AllTrim(SEE->EE_CONTA)), 7) + "0"
				
				cDig1 := GER01DLD(SEE->EE_CODIGO, SubStr(cCodBar, 1, 4) + SubStr(cCodBar, 20, 5))
				cDig2 := GER01DLD(SEE->EE_CODIGO, SubStr(cCodBar, 25, 10))
				cDig3 := GER01DLD(SEE->EE_CODIGO, SubStr(cCodBar, 35, 10))
				
				cCampo1 := SubStr(cCodBar, 1, 4) + SubStr(cCodBar, 20, 1) + SubStr(cCodBar, 21, 4) + cDig1
				cCampo2 := SubStr(cCodBar, 25, 5) + SubStr(cCodBar, 30, 5) + cDig2
				cCampo3 := SubStr(cCodBar, 35, 5) + SubStr(cCodBar, 40, 5) + cDig3
				cCampo4 := SubStr(cCodBar, 5, 1) + SubStr(cCodBar, 6, 4) + StrZero(Val(SubStr(cCodBar, 10, 10)), 10)
				
			Endif
		Endif

	Case cBanco $ "422" //Safra
		nSoma := 0
		nMult := 2
		
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		If (SE1->(DbSeek(xFilial("SE1") + (cAliasTmp)->E1_PREFIXO + (cAliasTmp)->E1_NUM + (cAliasTmp)->E1_PARCELA + (cAliasTmp)->E1_TIPO)))
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
			If (SEE->(DbSeek(xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + mv_par20)))
				//cAtual := AllTrim(Iif(Empty(SE1->E1_NUMBCO), SUBSTR(SEE->EE_FAXATU,1,11), SUBSTR(SE1->E1_NUMBCO,1,11)))
				cAtual := AllTrim(Iif(Empty(SE1->E1_NUMBCO), STRZERO(VAL(SEE->EE_FAXATU),9), STRZERO(VAL(SE1->E1_NUMBCO),9) ))
				cCodCart := AllTrim(SEE->EE_CODCART)
				cAgencia := AllTrim(SEE->EE_AGENCIA)
				cConta := AllTrim(SEE->EE_CONTA)
				
				//cChave := cCodCart + cAtual
				cChave := cAtual				
				
				For nI := Len(cChave) To 1 Step -1
					nSoma += Val(SubStr(cChave, nI, 1)) * nMult
					
					If (nMult == 7)
						nMult := 2
					Else
						nMult++
					Endif
				Next nI
				
				nResto := Mod(nSoma, 11)
				nDig := 11 - nResto
				
				cNossoNum := cCodCart + cAtual + Iif(nDig > 9, "0", cValToChar(nDig))
				
                //cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100) , 10) + ;
                //cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((IIF(Empty(SE1->E1_XDTPROR),SE1->E1_VENCREA,SE1->E1_XDTPROR) - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100) , 10) + ;
                cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100) , 10) + ;
				"7" + StrZero(Val(AllTrim(SEE->EE_AGENCIA)),5) + StrZero(Val(AllTrim(SEE->EE_CONTA)),8)+AllTrim(SEE->EE_DVCTA) + cAtual + "2")
				
				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100), 10) + ;
				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((IIF(Empty(SE1->E1_XDTPROR),SE1->E1_VENCREA,SE1->E1_XDTPROR) - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				
				cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + ;
				StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				"7" + StrZero(Val(AllTrim(SEE->EE_AGENCIA)),5) + StrZero(Val(AllTrim(SEE->EE_CONTA)),8)+AllTrim(SEE->EE_DVCTA) + cAtual  + "2"				
				//MSGALERT(cCodBar)
                //42294744900000031007011000020042960000001912
				cDig1 := GER01DLD(SEE->EE_CODIGO, SubStr(cCodBar, 1, 4) + SubStr(cCodBar, 20, 5))
				cDig2 := GER01DLD(SEE->EE_CODIGO, SubStr(cCodBar, 25, 10))
				cDig3 := GER01DLD(SEE->EE_CODIGO, SubStr(cCodBar, 35, 10))
				//cDig4 := GER01DLDX(SEE->EE_CODIGO, SubStr(cCodBar, 1, 46))
				                                 	
				cCampo1 := SubStr(cCodBar, 1, 4) + SubStr(cCodBar, 20, 1) + SubStr(cCodBar, 21, 4) + cDig1
				cCampo2 := SubStr(cCodBar, 25, 5) + SubStr(cCodBar, 30, 5) + cDig2
				cCampo3 := SubStr(cCodBar, 35, 5) + SubStr(cCodBar, 40, 5) + cDig3 
				cCampo4 := SubStr(cCodBar, 5, 1) + SubStr(cCodBar, 6, 4) + StrZero(Val(SubStr(cCodBar, 10, 10)), 10)
				
			Endif
		Endif

		/*
		cCpoAux := FINX999CpL(cAliasTmp)
		
		//Campo 1
		cCampo1 += cBanco									//Banco
		cCampo1 += "9"										//Moeda
		cCampo1 += SubStr(cCpoAux,1,5)					//Campo Livre 1-5
		cCampo1 += "1"                                  //primeiro digito da carteira
		cCampo1 += _M10(cCampo1)					//DV
		
		//Campo 2
		cCampo2 += "9"                                  //segundo digito da carteira
		cCampo2 += SubStr(cCpoAux,2,10)				 	//Campo Livre 6-15
		cCampo2 += _M10(cCampo2)					//DV
		
		//Campo 3
		cCampo3 += SubStr(cCpoAux,12,2)				 //Campo Livre 16-25
		cCampo3 += "0"
		cCampo3 += PadL(SubStr((cAliasTmp)->A6_NUMCON,1,5),5,"0")
		cCampo3 += _M10(cCampo3)					//DV
		*/
	Case cBanco == "341" //Itaú
		
//		nSoma := 0
//		nMult := 2
		
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		If (SE1->(DbSeek(xFilial("SE1") + (cAliasTmp)->E1_PREFIXO + (cAliasTmp)->E1_NUM + (cAliasTmp)->E1_PARCELA + (cAliasTmp)->E1_TIPO)))
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
			If (SEE->(DbSeek(xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA+ mv_par20)))
			/*
				cAtual := AllTrim(Iif(Empty(SE1->E1_NUMBCO), SEE->EE_FAXATU, SE1->E1_NUMBCO))
				cCodCart := AllTrim(SEE->EE_CODCART)
				cAgencia := AllTrim(SEE->EE_AGENCIA)
				cConta := AllTrim(SEE->EE_CONTA)
				
				cChave := cAgencia + cConta + cCodCart + cAtual
				
				For nI := Len(cChave) To 1 Step -1
					nSoma += Iif(Val(SubStr(cChave, nI, 1)) * nMult > 9, Val(SubStr(cValToChar(Val(SubStr(cChave, nI, 1)) * nMult), 1, 1)) + Val(SubStr(cValToChar(Val(SubStr(cChave, nI, 1)) * nMult), 2, 1)), Val(SubStr(cChave, nI, 1)) * nMult)
					
					If (nMult == 1)
						nMult := 2
					Else
						nMult--
					Endif
				Next nI
				
				If (nSoma > 10)
					nResto := Mod(nSoma, 10)
				Endif
				
				nDig := 10 - nResto
				
				If (nDig > 9)
					nDig := 0
				Endif
				
				cNossoNum := cCodCart + cAtual
				
				cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCTO - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100), 10) + ;
				SubStr(cNossoNum, 1, 3) + SubStr(cNossoNum, 4, 8) + cValToChar(nDig) + AllTrim(SEE->EE_AGENCIA) + Right(AllTrim(SEE->EE_CONTA), 5) + AllTrim(SEE->EE_DVCTA) + Replicate("0", 3))
				
				cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCTO - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100), 10) + ;
				SubStr(cNossoNum, 1, 3) + SubStr(cNossoNum, 4, 8) + cValToChar(nDig) + AllTrim(SEE->EE_AGENCIA) + Left(AllTrim(SEE->EE_CONTA), 5) + AllTrim(SEE->EE_DVCTA) + Replicate("0", 3) //mexer
				*/
				cCodBar:= _NCB(cAliasTmp)
				
				cDig1 := GER01DLD(SEE->EE_CODIGO, SubStr(cCodBar, 1, 4) + SubStr(cCodBar, 20, 5))
				cDig2 := GER01DLD(SEE->EE_CODIGO, SubStr(cCodBar, 25, 10))
				cDig3 := GER01DLD(SEE->EE_CODIGO, SubStr(cCodBar, 35, 10))
				
				cCampo1 := SubStr(cCodBar, 1, 4) + SubStr(cCodBar, 20, 1) + SubStr(cCodBar, 21, 4) + cDig1
				cCampo2 := SubStr(cCodBar, 25, 5) + SubStr(cCodBar, 30, 5) + cDig2
				cCampo3 := SubStr(cCodBar, 35, 5) + SubStr(cCodBar, 40, 5) + cDig3
				cCampo4 := SubStr(cCodBar, 5, 1) + SubStr(cCodBar, 6, 4) + StrZero(Val(SubStr(cCodBar, 10, 10)), 10)
				
			Endif
		Endif
		
	Case cBanco == "033" //Santander
		nSoma := 0
		nMult := 2
		
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		If (SE1->(DbSeek(xFilial("SE1") + (cAliasTmp)->E1_PREFIXO + (cAliasTmp)->E1_NUM + (cAliasTmp)->E1_PARCELA + (cAliasTmp)->E1_TIPO)))
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
			If (SEE->(DbSeek(xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + mv_par20)))
				cAtual := AllTrim(Iif(Empty(SE1->E1_NUMBCO), SEE->EE_FAXATU, SE1->E1_NUMBCO))
				cCodCart := AllTrim(SEE->EE_CODCART)
				cAgencia := AllTrim(SEE->EE_AGENCIA)
				cConta := AllTrim(SEE->EE_CONTA)
				
				If Len(cAtual) < 13
					cChave := cAtual
				
					For nI := Len(cChave) To 1 Step -1
						nSoma += Val(SubStr(cChave, nI, 1)) * nMult
					
						If (nMult == 9)
							nMult := 2
						Else
							nMult++
						Endif
					Next nI
					
					nResto := Mod(nSoma, 11)
				    
					If nResto >= 10
						nDig = '1'
					ElseIf nResto = 1 .or. nResto = 0
						nDig = '0'
					Else
						nDig := 11 - nResto
					EndIf 
					cNossoNum := cAtual + cValToChar(nDig)
				Else
					cNossoNum := cAtual 
				EndIf		
				//cRet := cAtual + Iif(nDig = 10, "1", Iif(nDig == 1 .Or. nDig == 0, "0", cValToChar(nDig)))
				cNossoNum := StrZero(Val(cNossoNum),13)
				//FIM
				//nDig := 11 - nResto
				//cNossoNum := cAtual + Iif(nDig > 9, "1", Iif(nDig == 0 .Or. nDig == 1, "0", cValToChar(nDig)))
				
				//cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100), 10) + ;
				//cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((IIF(Empty(SE1->E1_XDTPROR),SE1->E1_VENCREA,SE1->E1_XDTPROR) - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				
				//---Wilson 10/11/2017-----------------------------------------------------------------------------------------
				//cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007"))));
				// + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				//"9" + AllTrim(SEE->EE_CODEMP) + cNossoNum + "0101")
				
				cDVGeral := GER01DVC(SEE->EE_CODIGO, SEE->EE_CODIGO + "9" + cValToChar(((SE1->E1_VENCREA - SToD("19971007"))));
				 + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				"9" + AllTrim(SEE->EE_CODEMP) + cNossoNum + "0101")
				
				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				//"9" + AllTrim(SEE->EE_CODEMP) + cNossoNum + "0101"
				
				cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				"9" + AllTrim(SEE->EE_CODEMP) + cNossoNum + "0101"
				//----------------------------------------------------------------------------------------------------------------
				
				
				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100), 10) + ;
				//cCodBar := SEE->EE_CODIGO + "9" + cDVGeral + cValToChar(((IIF(Empty(SE1->E1_XDTPROR),SE1->E1_VENCREA,SE1->E1_XDTPROR) - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10) + ;
				
				
				//03399.63308 12600 000470 94702.010102 3 73360000003800 - ERRADO
				//03399.63308 12600.000470 79470.201017 3 73360000003800 - CORRETO
				//03392733600000038009633012600000047947020101
				//03399.63308  12600.000041  79470.201017  2  73360000003800
				//033 9 3 7336 0000003800 9 6330126 0000047947020 1 010
				//03393733600000038009633012600000047947020101
				//0000004794702 NOSSO NUMERO
				//6330126     COD EMP
				
				//wilson 10/11/17
				//cDig1 := GER01DLD(SEE->EE_CODIGO, SubStr(cCodBar, 1, 4) + "9" + Left(AllTrim(SEE->EE_CODEMP), 4))
				//cDig2 := GER01DLD(SEE->EE_CODIGO, Right(AllTrim(SEE->EE_CODEMP), 3) + Left(cNossoNum, 7))
				//cDig3 := GER01DLD(SEE->EE_CODIGO, Right(cNossoNum, 6) + "0101")
				
				//cCampo1 := SubStr(cCodBar, 1, 4) + "9" + Left(AllTrim(SEE->EE_CODEMP), 4) + cDig1//SubStr(cCodBar, 1, 4) + SubStr(cCodBar, 20, 1) + SubStr(cCodBar, 21, 4) + cDig1
				//cCampo2 := Right(AllTrim(SEE->EE_CODEMP), 3) + Left(cNossoNum, 7) + cDig2//SubStr(cCodBar, 25, 5) + SubStr(cCodBar, 30, 5) + cDig2
				//cCampo3 := Right(cNossoNum, 6) + "0101" + cDig3
				
				cDig1 := GER01DLD(SEE->EE_CODIGO, SubStr(cCodBar, 1, 4) + "9" + Left(AllTrim(SEE->EE_CODEMP), 4))
				cDig2 := GER01DLD(SEE->EE_CODIGO, Right(AllTrim(SEE->EE_CODEMP), 3) + Left(cNossoNum, 7))
				cDig3 := GER01DLD(SEE->EE_CODIGO, Right(cNossoNum, 6) + "0101")
				
				cCampo1 := SubStr(cCodBar, 1, 4) + "9" + Left(AllTrim(SEE->EE_CODEMP), 4) + cDig1//SubStr(cCodBar, 1, 4) + SubStr(cCodBar, 20, 1) + SubStr(cCodBar, 21, 4) + cDig1
				cCampo2 := Right(AllTrim(SEE->EE_CODEMP), 3) + Left(cNossoNum, 7) + cDig2//SubStr(cCodBar, 25, 5) + SubStr(cCodBar, 30, 5) + cDig2
				cCampo3 := Right(cNossoNum, 6) + "0101" + cDig3
				

				
				//SubStr(cCodBar, 35, 5) + SubStr(cCodBar, 40, 5) + cDig3
				
				
				//cCampo4 := cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero((SE1->E1_VALOR * 100), 10)//SubStr(cCodBar, 5, 1) + SubStr(cCodBar, 6, 4) + StrZero(Val(SubStr(cCodBar, 10, 10)), 10)
				//cCampo4 := cDVGeral + cValToChar(((IIF(Empty(SE1->E1_XDTPROR),SE1->E1_VENCREA,SE1->E1_XDTPROR) - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10)//SubStr(cCodBar, 5, 1) + SubStr(cCodBar, 6, 4) + StrZero(Val(SubStr(cCodBar, 10, 10)), 10)
				cCampo4 := cDVGeral + cValToChar(((SE1->E1_VENCREA - SToD("19971007")))) + StrZero(((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM) * 100), 10)//SubStr(cCodBar, 5, 1) + SubStr(cCodBar, 6, 4) + StrZero(Val(SubStr(cCodBar, 10, 10)), 10)
			Endif
		Endif
		/*
		cCpoAux := FINX999NN(cAliasTmp)
		cAuxCp1 := "9"+"9"+PadL(SubStr(AllTrim(SEE->EE_CODEMP),1,4),4,"0")
		cAuxCp2 := _M10(PadL(SubStr(AllTrim(SEE->EE_CODEMP),5,3),3,"0")+PadR(SubStr(AllTrim(cCpoAux),1,7),7,"0"))
		cAuxCp3 := _M10((PadR(SubStr(AllTrim(cCpoAux),8,6),6,"0")+"0"+SEE->EE_CODCART))
		
		
		//Campo 1
		cCampo1 += cBanco														//Banco
		cCampo1 += "9"															//Moeda
		cCampo1 += "9"															//Valor Fixo = 9
		cCampo1 += PadL(SubStr(AllTrim(SEE->EE_CODEMP),1,4),4,"0")				//Convenio 1-4
		cCampo1 += aFINX999M11(cAuxCp1,2,"033")                   //DV
		
		//Campo 2
		cCampo2 += PadL(SubStr(AllTrim("6330126"),5,3),3,"0")   				//Conta 5-7
		//cCampo2 += SubStr(cCpoAux,1,7)											//N.Numero 1-7
		cCampo2 += PadR(SubStr(AllTrim(cCpoAux),1,7),7,"0")
		cCampo2 += Ana(cCampo2)									//DV
		
		//Campo 3
		cCampo3 += PadR(SubStr(AllTrim(cCpoAux),8,6),6,"0")						//N.Numero 8-13
		cCampo3 += "0" 															//IOS
		cCampo3 += SEE->EE_CODCART												//Mod. da Carteira for. pelo banco
		cCampo3 += _M10(cCampo3)			  			                        //DV
		*/
EndCase

//Campo 1
cCampo1 := Transform(cCampo1,"@R 99999.99999")

//Campo 2
cCampo2 := Transform(cCampo2,"@R 99999.999999")

//Campo 3
cCampo3 := Transform(cCampo3,"@R 99999.999999")

//Campo 4
cCampo4 := SubStr(cCodBar,5,1)

//Campo 5

nVlrAbat := SomaAbat((cAliasTmp)->E1_PREFIXO,(cAliasTmp)->E1_NUM,(cAliasTmp)->E1_PARCELA,"R",1,dDataBase,(cAliasTmp)->A1_COD,(cAliasTmp)->A1_LOJA)

//cCampo5 += StrZero((cAliasTmp)->E1_VENCREA-CtoD("07/10/97"),4)
//cCampo5 += StrZero(IIF(Empty((cAliasTmp)->E1_XDTPROR),(cAliasTmp)->E1_VENCREA,(cAliasTmp)->E1_XDTPROR)-CtoD("07/10/97"),4)
cCampo5 += StrZero((cAliasTmp)->E1_VENCREA-CtoD("07/10/97"),4)
cCampo5 += StrZero((((cAliasTmp)->E1_SALDO - nVlrAbat) + nTotJM)*100,10)

cRet := cCampo1 + "  " + cCampo2 + "  " + cCampo3 + "  " + cCampo4 + "  " + cCampo5

RestArea (aAreaSEE)
RestArea (aArea)

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999SX1

Validação e criação das perguntas do relatório

@author    TOTVS
@version   11.90
@since     30/08/13

//------------------------------------------------------------------------------------------
/*/

Static Function SX1FINX999()

Local cPerg 		:= "FINX999"
Local nTamGrp001	:= TamSXG("001")[1]
Local nTamGrp002	:= TamSXG("002")[1]
Local nTamGrp007	:= TamSXG("007")[1]
Local nTamGrp011	:= TamSXG("011")[1]
Local nTamGrp018	:= TamSXG("018")[1]
Local aHelpPor		:= {}
Local aHelpEng		:= {}
Local aHelpSpa		:= {}

aHelpPor := {"Intervalo inicial dos prefixos a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo inicial dos prefixos a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo inicial dos prefixos a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//			cGrupo	cOrdem	cPergunt				cPerSpa				cPerEng				cVar		cTipo	nTamanho	nDecimal	nPreselcGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"01"	,"Do prefixo"			,"Do prefixo"			,"Do prefixo"			,"MV_CH1"	,"C"	,3			,0			,0		,"G"	,""								,""			,""		,"N"	,"MV_PAR01"	,""		,""			,""			,""							,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo final dos prefixos a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo final dos prefixos a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo final dos prefixos a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//			cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"02"	,"Até o prefixo"		,"Até o prefixo"		,"Até o prefixo"		,"MV_CH2"	,"C"	,3			,0			,0		,"G"	,""								,""			,""		,"N"	,"MV_PAR02"	,""		,""			,""			,"ZZZ"						,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo inicial dos números a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo inicial dos números a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo inicial dos números a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"03"	,"Do número"			,"Do número"			,"Do número"			,"MV_CH3"	,"C"	,nTamGrp018	,0			,0		,"G"	,""								,""			,"018"	,"N"	,"MV_PAR03"	,""		,""			,""			,""							,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo final dos números a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo final dos números a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo final dos números a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"04"	,"Até o número"			,"Até o número"			,"Até o número"			,"MV_CH4"	,"C"	,nTamGrp018	,0			,0		,"G"	,""								,""			,"018"	,"N"	,"MV_PAR04"	,""		,""			,""			,Replicate("Z",nTamGrp018)	,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo inicial das parcelas a serem"	,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo inicial das parcelas a serem"	,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo inicial das parcelas a serem"	,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"05"	,"Da parcela"			,"Da parcela"			,"Da parcela"			,"MV_CH5"	,"C"	,nTamGrp011	,0			,0		,"G"	,""								,""			,"011"	,"N"	,"MV_PAR05"	,""		,""			,""			,""							,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo final das parcelas a serem"		,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo final das parcelas a serem"		,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo final das parcelas a serem"		,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"06"	,"Até a parcela"		,"Até a parcela"		,"Até a parcela"		,"MV_CH6"	,"C"	,nTamGrp011	,0			,0		,"G"	,""								,""			,"011"	,"N"	,"MV_PAR06"	,""		,""			,""			,Replicate("Z",nTamGrp011)	,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo inicial dos clientes a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo inicial dos clientes a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo inicial dos clientes a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"07"	,"Do cliente"			,"Do cliente"			,"Do cliente"			,"MV_CH7"	,"C"	,nTamGrp001	,0			,0		,"G"	,""								,"SA1CLI"	,"001"	,"N"	,"MV_PAR07"	,""		,""			,""			,""							,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo final dos clientes a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo final dos clientes a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo final dos clientes a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"08"	,"Até o cliente"		,"Até o cliente"		,"Até o cliente"		,"MV_CH8"	,"C"	,nTamGrp001	,0			,0		,"G"	,""								,"SA1CLI"	,"001"	,"N"	,"MV_PAR08"	,""		,""			,""			,Replicate("Z",nTamGrp001)	,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo inicial das lojas a serem"		,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo inicial das lojas a serem"		,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo inicial das lojas a serem"		,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"09"	,"Da loja"				,"Da loja"				,"Da loja"				,"MV_CH9"	,"C"	,nTamGrp002	,0			,0		,"G"	,""								,"SA1LJ"	,"002"	,"N"	,"MV_PAR09"	,""		,""			,""			,""							,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo final das lojas a serem"			,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo final das lojas a serem"			,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo final das lojas a serem"			,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"10"	,"Até a loja"			,"Até a loja"			,"Até a loja"			,"MV_CHA"	,"C"	,nTamGrp002	,0			,0		,"G"	,""								,"SA1LJ"	,"002"	,"N"	,"MV_PAR10"	,""		,""			,""			,Replicate("Z",nTamGrp002)	,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo inicial das emissões a serem"	,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo inicial das emissões a serem"	,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo inicial das emissões a serem"	,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"11"	,"Da emissão"			,"Da emissão"			,"Da emissão"			,"MV_CHB"	,"D"	,8			,0			,0		,"G"	,""								,""			,""		,"N"	,"MV_PAR11"	,""		,""			,""			,"01/01/2013"				,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo final das emissões a serem"		,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo final das emissões a serem"		,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo final das emissões a serem"		,"consideradas na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"12"	,"Até a emissão"		,"Até a emissão"		,"Até a emissão"		,"MV_CHC"	,"D"	,8			,0			,0		,"G"	,""								,""			,""		,"N"	,"MV_PAR12"	,""		,""			,""			,"31/12/2013"				,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo inicial dos vencimentos a"		,"serem considerados na seleção dos"		,"títulos a receber para a emissão dos"		,"boletos."}
aHelpEng := {"Intervalo inicial dos vencimentos a"		,"serem considerados na seleção dos"		,"títulos a receber para a emissão dos"		,"boletos."}
aHelpSpa := {"Intervalo inicial dos vencimentos a"		,"serem considerados na seleção dos"		,"títulos a receber para a emissão dos"		,"boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"13"	,"Do vencimento"		,"Do vencimento"		,"Do vencimento"		,"MV_CHD"	,"D"	,8			,0			,0		,"G"	,""								,""			,""		,"N"	,"MV_PAR13"	,""		,""			,""			,"01/01/2013"				,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo final dos vencimentos a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo final dos vencimentos a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo final dos vencimentos a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"14"	,"Até o vencimento"		,"Até o vencimento"		,"Até o vencimento"		,"MV_CHE"	,"D"	,8			,0			,0		,"G"	,""								,""			,""		,"N"	,"MV_PAR14"	,""		,""			,""			,"31/12/2013"				,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo inicial dos borderôs a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo inicial dos borderôs a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo inicial dos borderôs a serem"	,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"15"	,"Do borderô"			,"Do borderô"			,"Do borderô"			,"MV_CHF"	,"C"	,6			,0			,0		,"G"	,""								,""			,""		,"N"	,"MV_PAR15"	,""		,""			,""			,""							,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Intervalo final dos borderôs a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpEng := {"Intervalo final dos borderôs a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
aHelpSpa := {"Intervalo final dos borderôs a serem"		,"considerados na seleção dos títulos a"	,"receber para a emissão dos boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"16"	,"Até o borderô"		,"Até o borderô"		,"Até o borderô"		,"MV_CHG"	,"C"	,6			,0			,0		,"G"	,""								,""			,""		,"N"	,"MV_PAR16"	,""		,""			,""			,"ZZZZZZ"					,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Portador a ser considerado na seleção"		,"dos títulos a receber para a emissão dos"	,"boletos. Códigos válidos:"				,"001 - Banco do Brasil"					,"237 - Banco Bradesco"						,"104 - Caixa Econômica Federal"					,"399 - HSBC"		,"341 - Itaú"			,"033 - Banco Santander"}
aHelpEng := {"Portador a ser considerado na seleção"		,"dos títulos a receber para a emissão dos"	,"boletos. Códigos válidos:"				,"001 - Banco do Brasil"					,"237 - Banco Bradesco"						,"104 - Caixa Econômica Federal"					,"399 - HSBC"		,"341 - Itaú"			,"033 - Banco Santander"}
aHelpSpa := {"Portador a ser considerado na seleção"		,"dos títulos a receber para a emissão dos"	,"boletos. Códigos válidos:"				,"001 - Banco do Brasil"					,"237 - Banco Bradesco"						,"104 - Caixa Econômica Federal"					,"399 - HSBC"		,"341 - Itaú"			,"033 - Banco Santander"}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"17"	,"Portador"				,"Portador"				,"Portador"				,"MV_CHH"	,"C"	,nTamGrp007	,0			,0		,"G"	,"Vazio() .Or. U__VIB()"	,"SA6"		,"007"	,"N"	,"MV_PAR17"	,""		,""			,""			,""							,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)
PUTSX1(cPerg	,"18"	,"Agencia ?"			, "Agencia ?"			, "Agencia ?"			,"mv_CHI","C",TAMSX3("A6_AGENCIA")[1],0,0,"G",""	,""	 ,"","N"	,"mv_PAR18",""		,""			,""			,""			,""		,""		,"","","" ,"","","","","","","","","","","","","","","",""  )
PUTSX1(cPerg	,"19"	,"Conta   ?"			, "Conta   ?" 			, "Conta   ?"			,"mv_CHJ","C",TAMSX3("A6_NUMCON")[1] ,0,0,"G",""	,""	 ,"","N"	,"mv_PAR19",""		,""			,""			,""			,""		,""		,"","","" ,"","","","","","","","","","","","","","","",""  )
aHelpPor := {"Código de Parametrização do Banco. "	,"Ex.: 001"	}
aHelpEng := {"Código de Parametrização do Banco. "	,"Ex.: 001"	}
aHelpSpa := {"Código de Parametrização do Banco. "	,"Ex.: 001" }
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"20"	,"Parâmetro Banco"	,"Parâmetro Banco"	,"Parâmetro Banco"	,"MV_CHI"	,"C"	,3			,0			,0		,"G"	,""								,		,""		,"N"	,"MV_PAR20"	,""		,""			,""			,""							,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

aHelpPor := {"Situação a ser considerada na seleção"		,"dos títulos a receber para a emissão dos"	,"boletos."}
aHelpEng := {"Situação a ser considerada na seleção"		,"dos títulos a receber para a emissão dos"	,"boletos."}
aHelpSpa := {"Situação a ser considerada na seleção"		,"dos títulos a receber para a emissão dos"	,"boletos."}
//		cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PutSx1(	cPerg	,"21"	,"Situação do título"	,"Situação do título"	,"Situação do título"	,"MV_CHJ"	,"C"	,1			,0			,0		,"G"	,""								,"07"		,""		,"N"	,"MV_PAR21"	,""		,""			,""			,""							,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,aHelpPor	,aHelpEng	,aHelpSpa	,		)

ASize(aHelpPor,0)
ASize(aHelpEng,0)
ASize(aHelpSpa,0)

aHelpPor := Nil
aHelpEng := Nil
aHelpSpa := Nil

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NNItau    ºAutor  ³Favio Senger        º Data ³  19/12/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo do Nosso Numero para o CNAB do Itau                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fazendas Finencio                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NNItau
Local aArea := getArea()
Local aAreaSEE := SEE->(getArea())
Local aAreaSE1 := SE1->(getArea())
Local cSubConta := MV_PAR20
Local cNossoNum := ""

DbSelectArea("SEE")
DbSetOrder(1)
If DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)+cSubConta)
	
	If Empty(SE1->E1_NUMBCO) //SE FOR GERADO A PRIMEIRA VEZ
		cNossoNum := StrZero(Val(SEE->EE_FAXATU)+1,TAMSX3("EE_FAXATU")[1])
		RecLock("SEE",.F.)
		SEE->EE_FAXATU := cNossoNum
		MsUnlock()
	Else
		IF SE1->E1_PORTADO == "237"
			cNossoNum := SE1->E1_NUMBCO
		ELSE
			cNossoNum := SUBSTR(SE1->E1_NUMBCO,1,12)
		ENDIF
	EndIf
ELSE
	MsgStop("Nao achou o banco")
ENDIF


Return (cNossoNum)

Static Function GER01DLD(cBanco, cChave)

Local cRet := ""
Local nI := 0
Local nSoma := 0
Local nMult := 2
Local nResto := 0
Local nDig := 0

cChave := AllTrim(cChave)

For nI := Len(cChave) To 1 Step -1
	nSoma += Iif(Val(SubStr(cChave, nI, 1)) * nMult > 9, Val(SubStr(cValToChar(Val(SubStr(cChave, nI, 1)) * nMult), 1, 1)) + Val(SubStr(cValToChar(Val(SubStr(cChave, nI, 1)) * nMult), 2, 1)), Val(SubStr(cChave, nI, 1)) * nMult)
	
	If (nMult == 1)
		nMult := 2
	Else
		nMult--
	Endif
Next nI

If (nSoma > 10)
	nResto := Mod(nSoma, 10)
Endif

If (cBanco == "237" .and. nSoma < 10)
	nResto := nSoma
Endif

nDig := 10 - nResto

If (cBanco == "422" .and. nSoma < 10 )
	nDig := 10 - nSoma
Endif


If ((cBanco == "033" .OR. cBanco == "237" .OR. cBanco =="422") .And. nDig >= 10)
	//nDig := Val(Left(cValToChar(nDig), 1)) + Val(Right(cValToChar(nDig), 1)) - Lelis - 08/12/2016 
    //Elseif (nDig == 10) - Lelis - 08/12/2016
	nDig := 0
Endif

cRet := cValToChar(nDig)
Return(cRet)

Static Function GER01DVC(cBanco, cChave)

Local cRet := ""
Local nI := 0
Local nSoma := 0
Local nMult := 2
Local nResto := 0
Local nDig := 0

cChave := AllTrim(cChave)

For nI := Len(cChave) To 1 Step -1
	nSoma += Val(SubStr(cChave, nI, 1)) * nMult
	
	If (nMult == 9)
		nMult := 2
	Else
		nMult++
	Endif
Next nI

nResto := Mod(nSoma, 11)
nDig := 11 - nResto

If (((nDig > 9) .Or. (nDig <= 1)) .And. (cBanco == "033" .or. cBanco == "422" ))
	nDig := 1
Elseif ((nDig > 9) .And. (cBanco <> "237"))
	nDig := 0
Elseif (nDig > 9) .And. (cBanco == "237")
	nDig := 1
Endif

cRet := cValToChar(nDig)

Return(cRet)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINX999TMP

Criação do arquivo temporário Clientes X Títulos X Banco

@author    TOTVS
@version   11.90
@since     30/08/13

@return cAliasTrb - Alias do Arquivo temporário

//------------------------------------------------------------------------------------------
/*/
Static Function _Tmp2(cAliasQ)

Local aStruct		:= {}
Local cAliasQry	:= GetNextAlias()
Local cAliasTrb	:= GetNextAlias()
Local cCampo    	:= ""
Local cNotIn		:= '%' + FormatIn(MVABATIM,"/") + "%"
Local nX			:= 0
Local xConteudo	:= ""

BeginSQL Alias cAliasQry
	SELECT	SE1.E1_PREFIXO,	SE1.E1_NUM,		SE1.E1_PARCELA,	SE1.E1_TIPO,
	SE1.E1_EMISSAO,	SE1.E1_VENCREA,	SE1.E1_NUMBOR,	SE1.E1_SALDO, SE1.E1_XCOBJM,
	SE1.E1_VENCTO, SE1.E1_XDTPROR, SE1.E1_OK, SE1.E1_IRRF, SE1.E1_ISS, SE1.E1_PIS, SE1.E1_COFINS, SE1.E1_CSLL,
	SA6.A6_COD,		SA6.A6_AGENCIA,	SA6.A6_NUMCON,	SA6.A6_NOME, SE1.E1_XMULTA,
	SA6.A6_DVCTA,
	SA1.A1_COD,		SA1.A1_NOME,		SA1.A1_LOJA, 		SA1.A1_END,
	SA1.A1_ENDCOB,	SA1.A1_BAIRRO,	SA1.A1_BAIRROC,	SA1.A1_MUN, 
	SA1.A1_MUNC,		SA1.A1_EST,		SA1.A1_ESTC,		SA1.A1_CEP,
	SA1.A1_CEPC,		SA1.A1_CGC,		SA1.A1_PESSOA, SA1.A1_XMULTA 
	FROM	%Table:SE1% SE1
	INNER JOIN %Table:SA6% SA6 ON
	SA6.A6_FILIAL			= %XFilial:SA6%
	AND SA6.A6_COD			= SE1.E1_PORTADO
	AND SA6.A6_AGENCIA	= SE1.E1_AGEDEP
	AND SA6.A6_NUMCON		= SE1.E1_CONTA
	AND SA6.%NotDel%
	INNER JOIN %Table:SA1% SA1 ON
	SA1.A1_FILIAL			= %XFilial:SA1%
	AND SA1.A1_COD			= SE1.E1_CLIENTE
	AND SA1.A1_LOJA		= SE1.E1_LOJA
	AND SA1.A1_EST <> 'EX'
	AND SA1.%NotDel%
	WHERE	SE1.E1_FILIAL			=	%XFilial:SE1%
	AND SE1.E1_PREFIXO	= %Exp:(cAliasQ)->E1_PREFIXO%
	AND SE1.E1_NUM	    = %Exp:(cAliasQ)->E1_NUM%
	AND SE1.E1_PARCELA	= %Exp:(cAliasQ)->E1_PARCELA%
	AND SE1.E1_TIPO		= %Exp:(cAliasQ)->E1_TIPO%
	AND SE1.E1_CLIENTE	= %Exp:(cAliasQ)->A1_COD%
	AND SE1.E1_LOJA		= %Exp:(cAliasQ)->A1_LOJA%
	AND SE1.E1_EMISSAO	= %Exp:(cAliasQ)->E1_EMISSAO%
	AND SE1.E1_VENCREA	= %Exp:(cAliasQ)->E1_VENCREA%
//	AND SE1.E1_NUMBOR		BETWEEN	%Exp:MV_PAR15% AND %Exp:MV_PAR16%
	AND SE1.E1_PORTADO	= %Exp:MV_PAR17%
	AND SE1.E1_SITUACA	= %Exp:MV_PAR21%
	AND SE1.E1_SALDO		>			0
	AND SE1.E1_PORTADO	<>			' '
	AND SE1.%NotDel%
	ORDER BY %Order:SE1%
EndSQL

aAdd(aStruct,{"E1_PREFIXO"	,"C", TamSX3("E1_PREFIXO")[1]	, TamSX3("E1_PREFIXO")[2]}	)
aAdd(aStruct,{"E1_NUM"		,"C", TamSX3("E1_NUM")[1]		, TamSX3("E1_NUM")[2]}		)
aAdd(aStruct,{"E1_PARCELA"	,"C", TamSX3("E1_PARCELA")[1]	, TamSX3("E1_PARCELA")[2]}	)
aAdd(aStruct,{"E1_TIPO"		,"C", TamSX3("E1_TIPO")[1]		, TamSX3("E1_TIPO")[2]}		)
aAdd(aStruct,{"E1_EMISSAO"	,"D", TamSX3("E1_EMISSAO")[1]	, TamSX3("E1_EMISSAO")[2]}	)
aAdd(aStruct,{"E1_NUMBOR"	,"C", TamSX3("E1_NUMBOR")[1]	, TamSX3("E1_NUMBOR")[2]}	)
aAdd(aStruct,{"E1_OK"		,"C", TamSX3("E1_OK")[1]		, TamSX3("E1_OK")[2]}		)
aAdd(aStruct,{"E1_SALDO"	,"N", TamSX3("E1_SALDO")[1]		, TamSX3("E1_SALDO")[2]}	)
aAdd(aStruct,{"E1_VENCREA"	,"D", TamSX3("E1_VENCREA")[1]	, TamSX3("E1_VENCREA")[2]}	)
aAdd(aStruct,{"E1_VENCTO"	,"D", TamSX3("E1_VENCTO")[1]	, TamSX3("E1_VENCTO")[2]}	)
//Incluido Ronaldo Bicudo - 20/04/2017 - Alterado 15/05/2017
aAdd(aStruct,{"E1_XDTPROR"	,"D", TamSX3("E1_XDTPROR")[1]	, TamSX3("E1_XDTPROR")[2]}	)
aAdd(aStruct,{"E1_IRRF"		,"N", TamSX3("E1_IRRF")[1]		, TamSX3("E1_IRRF")[2]}		)
aAdd(aStruct,{"E1_ISS"		,"N", TamSX3("E1_ISS")[1]		, TamSX3("E1_ISS")[2]}		)
aAdd(aStruct,{"E1_PIS"		,"N", TamSX3("E1_PIS")[1]		, TamSX3("E1_PIS")[2]}		)
aAdd(aStruct,{"E1_COFINS"	,"N", TamSX3("E1_COFINS")[1]	, TamSX3("E1_COFINS")[2]}	)
aAdd(aStruct,{"E1_CSLL"		,"N", TamSX3("E1_CSLL")[1]		, TamSX3("E1_CSLL")[2]}		)
aAdd(aStruct,{"E1_XMULTA"	,"N", TamSX3("E1_XMULTA")[1]	, TamSX3("E1_XMULTA")[2]}	) 
aAdd(aStruct,{"E1_XCOBJM"	,"C", TamSX3("E1_XCOBJM")[1]	, TamSX3("E1_XCOBJM")[2]}	)
//FIM
aAdd(aStruct,{"A1_COD"		,"C", TamSX3("A1_COD")[1]		, TamSX3("A1_COD")[2]}		)
aAdd(aStruct,{"A1_BAIRRO"	,"C", TamSX3("A1_BAIRRO")[1]	, TamSX3("A1_BAIRRO")[2]}	)
aAdd(aStruct,{"A1_BAIRROC"	,"C", TamSX3("A1_BAIRROC")[1]	, TamSX3("A1_BAIRROC")[2]}	)
aAdd(aStruct,{"A1_CEP"		,"C", TamSX3("A1_CEP")[1]		, TamSX3("A1_CEP")[2]}		)
aAdd(aStruct,{"A1_CEPC"		,"C", TamSX3("A1_CEPC")[1]		, TamSX3("A1_CEPC")[2]}		)
aAdd(aStruct,{"A1_CGC"		,"C", TamSX3("A1_CGC")[1]		, TamSX3("A1_CGC")[2]}		)
aAdd(aStruct,{"A1_LOJA"		,"C", TamSX3("A1_LOJA ")[1]		, TamSX3("A1_LOJA ")[2]}	)
aAdd(aStruct,{"A1_NOME"		,"C", TamSX3("A1_NOME")[1]		, TamSX3("A1_NOME")[2]}		)
aAdd(aStruct,{"A1_END"		,"C", TamSX3("A1_END")[1]		, TamSX3("A1_END")[2]}		)
aAdd(aStruct,{"A1_ENDCOB"	,"C", TamSX3("A1_ENDCOB")[1]	, TamSX3("A1_ENDCOB")[2]}	)
aAdd(aStruct,{"A1_EST"		,"C", TamSX3("A1_EST")[1]		, TamSX3("A1_EST")[2]}		)
aAdd(aStruct,{"A1_ESTC"		,"C", TamSX3("A1_ESTC")[1]		, TamSX3("A1_ESTC")[2]}		)
aAdd(aStruct,{"A1_MUN"		,"C", TamSX3("A1_MUN")[1]		, TamSX3("A1_MUN")[2]}		)
aAdd(aStruct,{"A1_MUNC"		,"C", TamSX3("A1_MUNC")[1]		, TamSX3("A1_MUNC")[2]}		)
aAdd(aStruct,{"A1_PESSOA"	,"C", TamSX3("A1_PESSOA")[1]	, TamSX3("A1_PESSOA")[2]}	)
//Incluido Ronaldo Bicudo - 05/05/2017
aAdd(aStruct,{"A1_XMULTA"	,"N", TamSX3("A1_XMULTA")[1]	, TamSX3("A1_XMULTA")[2]}	)
//fim
aAdd(aStruct,{"A6_COD"		,"C", TamSX3("A6_COD")[1]		, TamSX3("A6_COD")[2]}		)
aAdd(aStruct,{"A6_AGENCIA"	,"C", TamSX3("A6_AGENCIA")[1]	, TamSX3("A6_AGENCIA")[2]}	)
aAdd(aStruct,{"A6_NUMCON"	,"C", TamSX3("A6_NUMCON")[1]	, TamSX3("A6_NUMCON")[2]}	)
aAdd(aStruct,{"A6_NOME"		,"C", TamSX3("A6_NOME")[1]		, TamSX3("A6_NOME")[2]}		)
aAdd(aStruct,{"A6_DVCTA"	,"C", TamSX3("A6_DVCTA")[1]		, TamSX3("A6_DVCTA")[2]}	)

//Cria o arquivo temporário
cAliasTrb := CriaTrab(aStruct,.T.)
DbUseArea(.T.,__Localdrive, cAliasTrb,cAliasTrb)
IndRegua(cAliasTrb,cAliasTrb,"E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")

dbSelectArea(cAliasQry)
While !(cAliasQry)->(Eof())
	
	RecLock(cAliasTrb,.T.)
	
	For nX := 1 to Len(aStruct)
		cCampo := aStruct[nX][1]
		
		If aStruct[nX][2] == "D"
			xConteudo := StoD((cAliasQry)->&cCampo)
		Else
			xConteudo := 	(cAliasQry)->&cCampo
		EndIf
		
		(cAliasTrb)->&cCampo := xConteudo
	Next nX
	
	(cAliasTrb)->(MsUnlock())
	(cAliasQry)->(dbSkip())
	
EndDo

(cAliasQry)->(dbCloseArea())

Return(cAliasTrb)


User Function xMulta()

Local cRet  := ''
Local cData := SE1->E1_VENCREA+1

cRet := GravaData(cData+1,.F.)	 + ;
iif(len(cValToChar(GETMV("MV_LJMULTA")*100)) == 4,cValToChar(GETMV("MV_LJMULTA")*100),'0'+cValToChar(GETMV("MV_LJMULTA")*100))+'000'

Return cRet