
User Function MTI030NOM() 
Local aNome := aClone(Paramixb[1]) 
Local cNome := Paramixb[2] 
Local aArea := getarea()
Local cCodBasen := Nil
Local cPaisNome := Nil


 if  Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerOrVendor:Text") <> "U"
        cValInt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerOrVendor:Text
		aAdd(aNome, {"A1_XCLIFOR", rtrim(cValInt), Nil}) 
  EndIf

  if  Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerLegal:Text") <> "U"
        cValInt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerLegal:Text
		aAdd(aNome, {"A1_PESSOA", rtrim(cValInt), Nil}) 
  EndIf

 if  Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_xCustomerType:Text") <> "U"
        cValInt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_xCustomerType:Text
		
		If Alltrim(cValInt) =="X"
		
			If (npos := aScan(aNome,{|X| x[1] = "A1_TIPO"}) ) >0
 				aNome[npos][2] := "X"
			Endif
		Endif
	EndIf	    

	

 if  Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_CountryCode:Text") <> "U"
        cValInt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_CountryCode:Text
        aAdd(aNome, {"A1_PAIS", rtrim(cValInt), Nil}) 
 		
 		dbSelectArea("SYA")
		dbsetorder(1)
		dbGoTop()
		
		if SYA->(msseek(xFilial("SYA")+rtrim(cValInt),.F.)) 
			cPaisNome := rtrim(SYA->YA_DESCR)
			
			dbSelectArea("CCH")
			dbsetorder(2)
			
			dbGoTop()
			if CCH->(msseek(xFilial("CCH")+cPaisNome,.F.)) 
				cCodBasen := Alltrim(CCH->CCH_CODIGO)
				aAdd(aNome, {"A1_CODPAIS", cCodBasen, Nil}) 
	
			endif	
			dbclosearea("CCH")
	
		endif
			dbclosearea("SYA")
 
 Endif
RestArea(aArea) 
	
aRet := aClone(aNome)
Return aRet
