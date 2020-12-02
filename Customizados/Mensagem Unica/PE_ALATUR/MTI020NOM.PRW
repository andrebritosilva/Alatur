
User Function MTI020NOM() 

	Local aNome     := aClone(Paramixb[1]) 
	Local cNome     := Paramixb[2] 
	local aArea     := getarea()
	local cCodBasen := nil
	local cPaisNome := nil
	Local nPos		:= 0
	Local nPosCod   := 0
	Local nPosLoj	:= 0
	Local cCodigo   := ''

	If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_CountryCode:Text") <> "U"
		cValInt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_CountryCode:Text
		aAdd(aNome, {"A2_PAIS", (cValInt), Nil}) 
			
		DbSelectArea("SYA")
		SYA->(DbSetOrder(1))
		SYA->(DbGoTop())
		If SYA->(MsSeek(xFilial("SYA") + RTrim(cValInt),.F.)) 
			cPaisNome := RTrim(SYA->YA_DESCR)
				
			DbSelectArea("CCH")
			CCH->(DbSetorder(2))
			CCH->(DbGoTop())
			If CCH->(MsSeek(xFilial("CCH")+cPaisNome,.F.)) 
				cCodBasen := AllTrim((CCH->CCH_CODIGO))
				aAdd(aNome, {"A2_CODPAIS", cCodBasen, '.T.'}) 
			EndIf	
			CCH->(DbSetorder(1))
			CCH->(DbCloseArea())
		EndIf
		SYA->(DbCloseArea())	
	EndIf
	RestArea(aArea)		

	// Recuperando o código do municipio
	If aScan(aNome, {|x| AllTrim(x[1]) == "A2_COD_MUN"}) == 0 .And. Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityCode:Text)
		aAdd(aNome, {"A2_COD_MUN", Right(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityCode:Text, 5), Nil})
	EndIf

	//Validando se inclusão
	If nOpcx == 3
		// Preenchendo o A2_COD 
		If (nPosCod := aScan(aNome, {|x| AllTrim(x[1]) == "A2_COD"})) > 0
			If ExistBlock("ALASA2NUM") 
				If ValType((cCodigo := ExecBlock("ALASA2NUM", .F., .F. ))) == "C"
					aNome[nPosCod][2] := AllTrim(cCodigo)
				EndIf
			EndIf
		EndIf
		
		//Preenchendo o A2_LOJA
		If (nPosLoj := aScan(aNome, {|x| AllTrim(x[1]) == "A2_LOJA"})) > 0
			aNome[nPosLoj][2] := "00EX" 
		EndIf
	EndIf

	If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerOrVendor:Text") <> "U"
		cValInt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerOrVendor:Text
		aAdd(aNome, {"A2_XFORCLI", RTrim(cValInt), Nil}) 
	EndIf

	If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text") <> "U"
		cValInt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text
		aAdd(aNome, {"A2_CLIENTE", (cValInt), Nil}) 
	EndIf

	If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerUnit:Text") <> "U"
		cValInt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerUnit:Text
		aAdd(aNome, {"A2_LOJCLI", (cValInt), Nil}) 
	EndIf

Return aClone(aNome)