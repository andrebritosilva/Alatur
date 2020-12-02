#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH

//--------------------------------------------------
	/*/{Protheus.doc} TURXFORN
	 Rotina de Acordos de Fornecedor
	
	@author André Brito
	@since 11/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

User Function TURXFORN()

	Local aRet			:= {}
	Local aArea         := GetArea()
	Local aCfg			:= {}
	Local cCampos		:= ""
	Local lContinua		:= .T.
	Local oModImp    	:= Nil

	Private oProcess

	SaveInter()

	If ParamBox({	{6,"Selecione Arquivo",PadR("",150),"",,"", 90 ,.T.,"Importação Base Net","",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;
			"Importar Cobrança Comissão NET",@aRet)

		oProcess:= MsNewProcess():New( {|lEnd| xTurImpCSV( lEnd, oProcess, aRet[1] )} )
		oProcess:Activate()

	EndIf

	RestInter()

	RestArea(aArea)

Return .T.

//--------------------------------------------------
	/*/{Protheus.doc} xTurImpCSV
	Importa registros da planilha para a tabela SB1
	
	@author André Brito
	@since 02/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------

Static Function xTurImpCSV(lEnd, oProcess, cArq)
	
	Local aArea       := GetArea()
	Local aCab        := {}
	Local aCampos     := {}
	Local aDados      := {}
	Local aProds      := {}
	Local lPrim       := .T.
	Local lMsErroAuto := .F.
	Local cLinha      := ""
	Local oModel      := Nil
	Local nAtual      := 0
	Local nTotal      := 0
	Local nTot2       := 0
	Local nNumCob     := 0
	Local i           := 0
	Local x           := 0
	Local cNumId      := ""
	Local cCodFor     := ""
	Local cLoja       := ""
	Local cProd       := ""
	Local cVerFil     := ""
	Local cCodRv      := ""
	Local nInclu      := 0
	Local aRvs        := {}

	Private aErro     := {}
	Private HrIn      := Time()    
	Private HrFin
	Private aErros    := {}
 
	If !File(cArq)
		MsgStop("O arquivo "  + cArq + " não foi encontrado. A importação será abortada!","ATENCAO")
		Return
	EndIf
 
	FT_FUSE(cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()

	nTot2 := FT_FLASTREC()
	oProcess:SetRegua1(nTot2)

	While !FT_FEOF()
	

		oProcess:IncRegua1("Lendo cobranças do arquivo .csv: " + cValToChar(nNumCob))

		nNumCob := nNumCob + 1

		cLinha := FT_FREADLN()
 
		If lPrim
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf
 
		FT_FSKIP()
	EndDo

	nTotal := Len(aDados)

	Count To nTotal
	oProcess:SetRegua2(nTotal)
	
	DbselectArea("SZ1")
	DbSetOrder(1)//Z1_FILIAL+Z1_NUMID+Z1_CODFOR+Z1_LOJA+Z1_PRODUTO

	Begin Transaction
		
		nInclu := Len(aDados)
		
		For i := 1 to Len(aDados)
			
				If Len(aDados[i]) == 5
				
					oProcess:IncRegua2("Incluindo a cobrança: " + aDados[i][1])
					
					cNumId      := Padr( SubStr( aDados[i][1], 10, 9 ), TAMSX3("Z1_NUMID")[1] )
					cCodFor     := aDados[i][2]//Padr( aDados[i][2], TAMSX3("Z1_CODFOR")[1] )
					//cCodFor     := StrZero( Val(cCodFor), TAMSX3("G3R_FORNEC")[1])
					cLoja       := aDados[i][3]//Padr( aDados[i][3], TAMSX3("G3R_LOJA")[1] )
					cProd       := aDados[i][4]//Padr( aDados[i][4], TAMSX3("G3R_LOJA")[1] )
					cVerFil     := Padr( SubStr( aDados[i][1], 1, 8 ), TAMSX3("Z1_FILIAL")[1] )
					cCodRv      := SubStr( aDados[i][1], 10, 11 )//aDados[i][1]
					
					If SZ1->(DBSeek( cVerFil + STRTRAN(cCodRv, "-", "") +  Padr(cCodFor, TAMSX3("Z1_CODFOR")[1]) + cLoja + cProd ))
						
						nInclu --
						
						AADD(aRvs, { cVerFil, aDados[i][1], STRTRAN(cCodRv, "-", ""), cCodFor, aDados[i][3], aDados[i][4], aDados[i][5] })
						
					Else
						
						RecLock( "SZ1", .T. )
						
						SZ1->Z1_FILIAL  := cVerFil
						SZ1->Z1_RV      := aDados[i][1]
						SZ1->Z1_CODFOR  := cCodFor
						SZ1->Z1_LOJA    := aDados[i][3]
						SZ1->Z1_PRODUTO := aDados[i][4]
						SZ1->Z1_MOTINT  := aDados[i][5]
						SZ1->Z1_NUMID   := STRTRAN(cCodRv, "-", "")
						SZ1->Z1_STATUS  := "1"
						SZ1->Z1_DATA    := dDataBase
							
						MsUnLock()
						
					EndIf
				Else
				
					AADD(aErros, {i})
					
				EndIf
			Next
		
	End Transaction
	
	HrFin := Time()
	
	U_xAlaMsg(Len(aDados), nInclu, aRvs, HrIn, HrFin, i)

	RestArea(aArea)

Return

//--------------------------------------------------
	/*/{Protheus.doc} xAlaMsg
	 Tela de Log para usuário
	
	@author André Brito
	@since 11/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------
 
User Function xAlaMsg(nDados, nInclu, aRvs, HrIn, HrFin, i)

	Local lRetMens             := .F.
	Local oDlgMens
	Local oBtnOk, cTxtConf     := ""
	Local oBtnCnc, cTxtCancel  := ""
	Local oBtnSlv
	Local oFntTxt              := TFont():New("Verdana",,-011,,.F.,,,,,.F.,.F.)
	Local oMsg
	Local nIni                 := 1
	Local nFim                 := 50
	Local cMsg                 := ""
	Local cTitulo              := "Registros importados"
	Local cQuebra              := CRLF + CRLF
	Local nTipo                := 1 // 1=Ok; 2= Confirmar e Cancelar
	Local lEdit                := .F.
    Local nX                   := 0
    Local cTime                :=  ElapTime( HrIn, HrFin)
    Local j   
    
    cMsg  := "Total de registros processados: " + Alltrim(Str(nDados)) + " em " + cTime +  CRLF
    cMsg  += "Total de registros inclusos na tabela SZ1: " + Alltrim(Str(nInclu)) +  CRLF
    For j:= 1 to Len(aErros)
    	cMsg  += "Linha com inconsistência: " + Alltrim(Str(aErros[j][1])) +  CRLF
    Next
    
	cTexto := "Função   - " + FunName()       + CRLF
	cTexto += "Usuário  - " + cUserName       + CRLF
	cTexto += "Data     - " + dToC(dDataBase) + CRLF
	cTexto += "Hora     - " + Time()          + CRLF
	cTexto += "Mensagem - " + cTitulo + cQuebra  + cMsg + " " + cQuebra
	cTexto += CRLF

	If nInclu != nDados
		cTexto += "Registros não inclusos:" + CRLF + CRLF
	EndIf

	For nX := 1 To Len(aRvs)
		cTexto += "Filial: " + aRvs[nX][1] + CRLF
		cTexto += "RV: " + aRvs[nX][2] + CRLF
		cTexto += "ID: " + aRvs[nX][3] + CRLF
		cTexto += "Fornecedor: " + aRvs[nX][4] + CRLF
		cTexto += "Loja: " + aRvs[nX][5] + CRLF
		cTexto += "Produto: " + aRvs[nX][6] + CRLF
		cTexto += "Mot. Int.: " + aRvs[nX][7] + CRLF + CRLF
	Next
    
    //Definindo os textos dos botões
	If(nTipo == 1)
		cTxtConf:='Ok'
	Else
		cTxtConf:='Confirmar'
		cTxtCancel:='Cancelar'
	EndIf
 
    //Criando a janela centralizada com os botões
	DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL
        //Get com o Log
	@ 002, 004 GET oMsg VAR cTexto OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
	If !lEdit
		oMsg:lReadOnly := .T.
	EndIf
         
        //Se for Tipo 1, cria somente o botão OK
	If (nTipo==1)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
         
        //Senão, cria os botões OK e Cancelar
	ElseIf(nTipo==2)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
		@ 137, 144 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
	EndIf
         
        //Botão de Salvar em Txt
	@ 127, 004 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (xSalvaArq(cMsg, cTitulo, Alltrim(Str(nDados)),cTexto,i)) OF oDlgMens PIXEL
	ACTIVATE MSDIALOG oDlgMens CENTERED
 
Return lRetMens

//--------------------------------------------------
	/*/{Protheus.doc} xAlaMsg
	 Tela de Log para usuário
	
	@author André Brito
	@since 11/12/2019
	@version P12.1.17
	 
	@return 
	/*/
//--------------------------------------------------
 
Static Function xSalvaArq(cMsg, cTitulo, cQtdDados, cTxt, i)

	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""
     
    //Pegando o caminho do arquivo
	cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
 
    //Se o nome não estiver em branco    
	If !Empty(cFileNom)
        //Teste de existência do diretório
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		EndIf
         
        //Montando a mensagem
		/*cTexto := "Função   - "+ FunName()       + CRLF
		cTexto += "Usuário  - "+ cUserName       + CRLF
		cTexto += "Data     - "+ dToC(dDataBase) + CRLF
		cTexto += "Hora     - "+ Time()          + CRLF
		cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + " " + cQuebra*/

		cTexto := cTxt
         
        //Testando se o arquivo já existe
		If File(cFileNom)
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		EndIf
         
		If lOk
			MemoWrite(cFileNom, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
		EndIf
	EndIf
Return