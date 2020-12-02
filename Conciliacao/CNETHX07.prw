#Include 'Protheus.ch'
/*/{Protheus.doc} CNETHX07
Rotina para gerar as ORDENS DE PAGAMENTO do CNAB ONLINE
@type function
@author Fernando Carvalho
@since 30/10/2018
@version 1.0
/*/
User Function CNETHX07()
	Local oDlg			:= nil
	Local oSize			:= nil
	Local oFontArial18	:= TFont():New('arial',,-18,.T.)
	Local a1stRow		:= {}
	Local a1stRow		:= {}
	Local a2ndRow		:= {}
	Local aColuna		:= {}
	Local aButtons 		:= {}
	Local aSE1			:= {}
	Local nLinha		:= 0
	Local nValorTot		:= 0
	Local nQtdFat		:= 0
	Local nOpc			:= 0
	Local lInverte		:= .f.
	Local cPerg     	:= "CNETHX07"
	Local lExiste		:= .F. //VERIFICA SE EXISTE PELO MENOS UM MARCADO

	//valida se o CNAB online está aplicado nesta empresa
	dbSelectArea("SX2")
	dbSetOrder(1)
	If !dbSeek("PZ8")
		MsgInfo("Esta empresa não contempla o CNAB ONLINE.")
		return
	Endif

	/*If !ExistOrder(.t.)
	Return
	endIf		
	*/
	AjustaSX1(cPerg)

	if ! Pergunte(cPerg, .T.)
		Return nil
	endif
	Private aRetValSal	:= U_CNETHX10(MV_PAR03)
	Private cNumOrder	:= GetSxeNum("PZ8",'PZ8_ORDEM')
	Private cSaldoCnab	:= aRetValSal[1]
	Private nSaldoCnab	:= aRetValSal[2]
	Private nValorMark	:= 0
	Private aCampos 	:=	{}

	dbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbSeek("SE1"))

	//CAMPOS OBRIGATORIOS
	Aadd(aCampos,{"E1_OK" 		,"",""})
	Aadd(aCampos,{"E1_FILIAL"	,"",""})

	While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "SE1")
		If (SX3->X3_BROWSE = 'S') .AND.  (X3USO(SX3->X3_USADO)).And. (cNivel >= SX3->X3_NIVEL).AND. (!(SX3->X3_TIPO == "M"))
			Aadd(aCampos,{SX3->X3_CAMPO,"",SX3->X3_TITULO,SX3->X3_PICTURE})
		Endif

		SX3->(DbSkip())

	EndDo

	GeraDados()
	dbSelectArea("TRB")
	TRB->(DbGotop())
	//Faz o calculo automatico de dimensoes de objetos
	oSize := FwDefSize():New(.T.)

	oSize:lLateral	:= .F.
	oSize:lProp		:= .T. // Proporcional

	oSize:AddObject( "1STROW" ,  100, 10, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "2NDROW" ,  100, 90, .T., .T. ) // Totalmente dimensionavel

	oSize:aMargins	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

	oSize:Process() // Dispara os calculos

	a1stRow := {	oSize:GetDimension("1STROW","LININI"),;
	oSize:GetDimension("1STROW","COLINI"),;
	oSize:GetDimension("1STROW","LINEND"),;
	oSize:GetDimension("1STROW","COLEND")}

	a2ndRow := {	oSize:GetDimension("2NDROW","LININI"),;
	oSize:GetDimension("2NDROW","COLINI"),;
	oSize:GetDimension("2NDROW","LINEND"),;
	oSize:GetDimension("2NDROW","COLEND")}

	DEFINE MSDIALOG oDlg TITLE 'titulo' From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
	oDlg:lMaximized := .T.
	//------------------------------------------------------------------------------------------------------------------------
	//Painel 1 - Informações
	//------------------------------------------------------------------------------------------------------------------------
	nLinha		:= 10//a1stRow[1] + 3
	nSize 		:= 150
	aColuna		:={a1stRow[2],,,}
	aColuna[2]	:=aColuna[1]+nSize+100
	aColuna[3]	:=aColuna[2]+150
	aColuna[4]	:=aColuna[3]+nSize+5
	//@nLinha,aColuna[1] Say "Saldo anterior (CNAB)" + " (" + "Bancario" + ")"SIZE nSize,10 PIXEL Of oDlg
	oSay1 := TSay():New(nLinha,aColuna[1],{||"Nº Ordem solicitação"},oDlg,,oFontArial18,,,,.T.,,,nSize,100,,,,,,)
	oSay2 := TSay():New(nLinha,aColuna[2],{||"Saldo do CNAB"},oDlg,,oFontArial18,,,,.T.,,,nSize,100,,,,,,)
	oSay3 := TSay():New(nLinha,aColuna[3],{||"Valor atual"},oDlg,,oFontArial18,,,,.T.,,,nSize,100,,,,,,)


	nLinha += 9
	oSay4 	:= TSay():New(nLinha,aColuna[1],{||cNumOrder},oDlg,,oFontArial18,,,,.T.,CLR_RED,,nSize,100,,,,,,)
	oValGer := TSay():New(nLinha,aColuna[2],{||cSaldoCnab},oDlg,,oFontArial18,,,,.T.,CLR_RED,,nSize,100,,,,,,)
	oValAtu := TSay():New(nLinha,aColuna[3],{||"R$ " + AllTrim(Transform( nValorMark, "@E 99,999,999.99"))},oDlg,,oFontArial18,,,,.T.,CLR_RED,,nSize,100,,,,,,)
	nLinha += 18

	//Botões da tela
	oTButton1 := TButton():New( nLinha, aColuna[1], "Gera Ordem",oDlg,{|| nOpc := 1, oDlg:End()}, 40,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	//------------------------------------------------------------------------------------------------------------------------
	//Painel 2 - MsSelect
	//------------------------------------------------------------------------------------------------------------------------

	PRIVATE cMarca	 	:= GetMark()
	oMark := MsSelect():New("TRB","E1_OK","",aCampos,@lInverte,@cMarca,{a2ndRow[1],a2ndRow[2],a2ndRow[3],a2ndRow[4]})
	oMark:oBrowse:lColDrag := .T.
	oMark:bMark := {| | FaCnabDisp(cMarca,lInverte,oValAtu)}
	oMark:oBrowse:bAllMark := { || FaCnabInverte(cMarca,oValAtu)}

	ACTIVATE MSDIALOG oDlg  CENTERED
	//valida se já existe ordem, caso exista não deixa criar uma nova
	//retirado pois não ha necessidade de validar isso
	/*If !ExistOrder()
	Return
	Endif*/
	If nOpc == 1
		DbSelectArea("TRB")
		TRB->(DbGoTop())
		DbSelectArea("SE1")
		SE1->(dbSetOrder(2))

		lExiste := .f.



		While TRB->(!Eof())
			If TRB->E1_OK == cMarca
				If SE1->(DbSeek(TRB->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
					aAdd(aSE1,{SE1->E1_XIDCNON,TRB->E1_VALOR})
					nValorTot += SE1->((E1_VALOR + E1_ACRESC) -(E1_IRRF+E1_CSLL+E1_COFINS+E1_PIS+E1_DECRESC))  
					nQtdFat ++
					lExiste := .t.					
				Endif
			Endif
			TRB->(dbSkip())
		EndDo

		If lExiste			
			//ENVIA A ORDEM PARA O CNAB ONLINE
			If U_CNETHX08(cNumOrder,aSE1,MV_PAR03,,nValorTot,nQtdFat,nSaldoCnab)
				ConfirmSX8()
				TRB->(dbGoTop())
				While TRB->(!Eof())
					If TRB->E1_OK == cMarca
						If SE1->(DbSeek(TRB->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
							If RecLock("SE1",.F.)
								SE1->E1_XORDEM := cNumOrder
								SE1->E1_XCOSTAT:= '6'
								SE1->(MsUnlock())							
							Endif
						Endif
					Endif
					TRB->(dbSkip())
				EndDo
				MsgAlert("Foi gerada a Ordem de Pagamento: "+cNumOrder+".")
			Else


				RollbackSx8()
				MsgAlert("Não foi possível realizar a Ordem de Pagamento.")
			Endif
		Else
			RollbackSx8()
			MsgAlert("Nenhum título foi escolhido e por isso não será gerado nenhuma Ordem.")
		Endif

	Else
		RollBackSx8()
	Endif
Return

Static Function FaCnabDisp(cMarca,lInverte,oValAtu)
	Local nValBkp	:= nValorMark

	If IsMark("E1_OK",cMarca,lInverte)
		nValorMark += TRB->E1_VALOR
		If nValorMark > nSaldoCnab //ultrapassou o valor permitido e voltar o valor anterior
			nValorMark	:= nValBkp
			MsgAlert("Ultrapassa o valor de Saldo.")
			RecLock("TRB",.F.)
			TRB->E1_OK := ''
			TRB->(MsUnlock())
		Endif
	Else
		nValorMark -= TRB->E1_VALOR
	Endif

	oValAtu:Refresh()

Return

Static Function FaCnabInverte(cMarca,oValAtu)
	Local nReg 		:= TRB->(Recno())
	Local nValBkp	:= nValorMark
	Local lUltrapassa := .F.

	DbSelectArea("TRB")
	DbGoTop()

	While TRB->(!Eof())

		nValBkp	:= nValorMark

		If TRB->E1_OK == cMarca
			nValorMark -= TRB->E1_VALOR
			RecLock("TRB",.F.)
			TRB->E1_OK := ''
			TRB->(MsUnlock())
		Else
			nValorMark += TRB->E1_VALOR
			If nValorMark > nSaldoCnab //ultrapassou o valor permitido e voltar o valor anterior
				nValorMark	:= nValBkp
				lUltrapassa := .T.
			Else
				RecLock("TRB",.F.)
				TRB->E1_OK := cMarca
				TRB->(MsUnlock())
			Endif
		Endif
		TRB->(dbskip())
	EndDo
	DbSelectArea("TRB")
	TRB->(DbGoTo(nReg))

	If lUltrapassa
		MsgInfo("Alguns títulos não foram marcados pois ultrapassa o valor de saldo.")
	Endif
	oValAtu:Refresh()
Return(NIL)

Static Function GERADADOS()
	Local cQuery 		:= ''
	Local cAliasTitulo	:= ''
	Local lEthosx		:= .F.
	Local aTemp 		:=	{}
	Local cCamposQry	:= ""
	Local nLoop			:= 0


	dbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbSeek("SE1"))

	//CAMPOS OBRIGATORIOS
	Aadd(aTemp,{"E1_OK" 		,"C",02})
	Aadd(aTemp,{"E1_FILIAL"		,"C",TamSx3("E1_FILIAL")[1]})
	While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "SE1")
		If (SX3->X3_BROWSE = 'S') .AND.  (X3USO(SX3->X3_USADO)).And. (cNivel >= SX3->X3_NIVEL) .AND. (!(SX3->X3_TIPO == "M"))
			Aadd(aTemp,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			cCamposQry += SX3->X3_CAMPO + ","
		Endif

		SX3->(DbSkip())

	EndDo

	cCamposQry := SubStr(cCamposQry,1,Len(cCamposQry)-1)

	cArqTmp := CriaTrab(aTemp)

	If Select("TRB")<>0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf
	dbUseArea( .T.,, cArqTmp, "TRB", .F., .F. )

	cAliasTitulo	:= GetNextAlias()

	cCamposQry := StrTran(cCamposQry,"E1_VALOR","((E1_VALOR + E1_ACRESC) -(E1_IRRF+E1_CSLL+E1_COFINS+E1_PIS+E1_DECRESC)) E1_VALOR")

	cQuery += " SELECT E1_FILIAL,"
	cQuery += cCamposQry
	cQuery += " FROM " + RETSQLNAME("SE1")+ " SE1"
	cQuery += " WHERE D_E_L_E_T_ = ''"
	cQuery += " AND E1_XCOSTAT = '3'  "
	cQuery += " AND E1_XORDEM = ''"
	cQuery += " AND E1_CLIENTE BETWEEN  '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
	cQuery += " AND E1_PREFIXO = '"+MV_PAR03+"'"
	cQuery += " AND E1_NUM BETWEEN  '"+MV_PAR04+"' AND '"+MV_PAR05+"'"
	cQuery += " AND E1_EMISSAO BETWEEN  '" + Dtos(MV_PAR06)+"' AND '"+ Dtos(MV_PAR07)+"'"
	cQuery += " ORDER BY E1_NUM"

	cQuery	:= ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), (cAliasTitulo), .F., .T. )

	(cAliasTitulo)->(dbGoTop())

	While (cAliasTitulo)->(! EOF())

		Reclock("TRB",.T.)
		For nLoop := 1 To Len(aTemp)
			If !(AllTrim(aTemp[nLoop, 1]) == 'E1_OK')
				If aTemp[nLoop, 2] == 'D'
					TRB->&(aTemp[nLoop, 1]) := Stod((cAliasTitulo)->&(aTemp[nLoop, 1]))
				Else
					TRB->&(aTemp[nLoop, 1]) := (cAliasTitulo)->&(aTemp[nLoop, 1])
				Endif
			Endif
		Next
		(cAliasTitulo)->(dbSkip())

	Enddo
	(cAliasTitulo)->(dbCloseArea())
Return

Static Function AjustaSX1(cPerg)

	u_xPutSx1(cPerg	,"01","Cliente de" 	,'','',"MV_C01"	,"C",TAMSX3("E1_CLIENTE")[1] 	,0,,"G"	,""	,"SA1"	,"","","mv_par01","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg	,"02","Cliente ate"	,'','',"MV_C02"	,"C",TAMSX3("E1_CLIENTE")[1]	,0,,"G"	,""	,"SA1"	,"","","mv_par02","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg	,"03","Prefixo" 	,'','',"MV_C03"	,"C",TAMSX3("E1_PREFIXO")[1]	,0,,"G"	,""	,""		,"","","mv_par03","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg	,"04","Numero de" 	,'','',"MV_C04" ,"C",TAMSX3("E1_NUM")[1]		,0,,"G"	,""	,""		,"","","mv_par04","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg	,"05","Numero ate"	,'','',"MV_C05" ,"C",TAMSX3("E1_NUM")[1]		,0,,"G"	,""	,""		,"","","mv_par05","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg	,"06","Emissao de" 	,'','',"MV_C06" ,"D",TAMSX3("E1_EMISSAO")[1]	,0,,"G"	,""	,""		,"","","mv_par06","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg	,"07","Emissao ate"	,'','',"MV_C07" ,"D",TAMSX3("E1_EMISSAO")[1]	,0,,"G"	,""	,""		,"","","mv_par07","","","","","","","","","","","","","","","","")
return

Static Function ExistOrder(lQuestion)
	Local lRet		:= .t.
	Local lEthosx	:= .F.
	Local cQuery	:= ""
	Default lQuestion := .F.

	cAlias := GetNextAlias()

	dbselectArea("PZ8")

	If FieldPos("PZ8_EMPFAT") > 0
		lEthosx := .t.
	Endif

	cQuery	+= " SELECT PZ8_ORDEM, PZ8_VALOR, PZ8_SALDO, PZ8_QTDFAT, PZ8_STATUS, PZ8_DATA"
	cQuery	+= " FROM "+ RETSQLNAME("PZ8")+" PZ8"
	cQuery	+= " WHERE PZ8.D_E_L_E_T_ = ''"
	If lEthosx
		cQuery	+= " AND PZ8_EMPFAT = '"+MV_PAR03+"'"
	Endif
	cQuery	+= " AND PZ8_STATUS IN ('1','2')"

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T. )
	(cAlias)->(dbGoTop())

	While !(cAlias)->(Eof())
		If lQuestion
			Return MsgYesNo("Atenção, já existe uma ordem em aberto e não é possível criar uma nova enquanto não ser finalizada."+ CRLF+;
			"Deseja Prosseguir.")
		Else
			MsgInfo("Atenção, já existe uma ordem em aberto."+ CRLF+;
			"Aguardar a fnalização da Ordem para que possa criar uma nova.")
		Endif			
		lRet	:= .F.
		exit
	endDo
Return lRet