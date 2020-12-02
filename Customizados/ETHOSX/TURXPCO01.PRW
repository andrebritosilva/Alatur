#Include "Protheus.ch"
#Include "RwMake.ch"

User Function TURXPCO01()

Local cAlias  := "SZ2"
Local cTitulo := "Tipo de Despesa"

SetKey(VK_F12, {|| U_xImpSZ2()})

AxCadastro(cAlias, cTitulo, "U_xDelOk()", "U_xCOK()")

Return .T.

User Function xDelOk()  

    Local lRet := MsgBox("Tem certeza que deseja excluir o registro selecionado?", "Confirmação", "YESNO")

Return lRet

User Function xCOK()    

Local lInclui := .F.
Local lRet    := .T.

lInclui := MsgYesNo("Deseja importar as despesas?" ,"Importação")

If lInclui
    lRet := U_xImpSZ2()
Else
    MsgAlert("Registro incluso!") 
EndIf

Return lRet

User Function xImpSZ2()

Local aRet			:= {}
Local aArea         := GetArea()
Local aCfg			:= {}
Local cCampos		:= ""
Local lContinua		:= .T.
Local oModImp    	:= Nil

Private oProcess

SaveInter()

If ParamBox({	{6,"Selecione Arquivo",PadR("",150),"",,"", 90 ,.T.,"Importação de Despesas","",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;
        "Importar Despesas para tabela SZ2",@aRet)

    oProcess:= MsNewProcess():New( {|lEnd| xSz2CSV( lEnd, oProcess, aRet[1] )} )
    oProcess:Activate()

EndIf

RestInter()

RestArea(aArea)

Return .T.


Static Function xSz2CSV(lEnd, oProcess, cArq)
	
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


    oProcess:IncRegua1("Lendo despesas do arquivo .csv: " + cValToChar(nNumCob))

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

DbselectArea("SZ2")
DbSetOrder(1)

Begin Transaction
    
    nInclu := Len(aDados)
    
    For i := 1 to Len(aDados)


        oProcess:IncRegua2("Incluindo a conta: " + aDados[i][2] + " C. Custo: " + aDados[i][3])
        
        cConta      := aDados[i][2] 
        cCusto      := aDados[i][3]
        cDespesa    := aDados[i][4] 
       
        If SZ2->(DBSeek( aDados[i][1] + aDados[i][2] +  aDados[i][3] ))
            
            nInclu --
            
            AADD(aRvs, { cConta, cCusto, cDespesa })
            
        Else
            
            RecLock( "SZ2", .T. )
            
            SZ2->Z2_FILIAL     := ""
            SZ2->Z2_CONTA      := Alltrim(cConta)
            SZ2->Z2_CCUSTO     := Alltrim(cCusto)
            SZ2->Z2_DESPESA    := Alltrim(cDespesa)

            MsUnLock()
            
        EndIf
    
    Next
            
End Transaction

U_xSZ2Msg(Len(aDados), nInclu, aRvs)

RestArea(aArea)

Return


User Function xSZ2Msg(nDados, nInclu, aRvs)

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

cMsg  := "Total de registros processados: " + Alltrim(Str(nDados)) + CRLF
cMsg  += "Total de registros inclusos na tabela SZ2: " + Alltrim(Str(nInclu))

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
    cTexto += "Conta: " + aRvs[nX][2] + CRLF
    cTexto += "Centro de Custo: " + aRvs[nX][3] + CRLF
    cTexto += "Despesa: " + aRvs[nX][4] + CRLF
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
@ 127, 004 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (xSalSz2(cMsg, cTitulo, Alltrim(Str(nDados)),cTexto)) OF oDlgMens PIXEL
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

Static Function xSalSz2(cMsg, cTitulo, cQtdDados, cTxt)

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