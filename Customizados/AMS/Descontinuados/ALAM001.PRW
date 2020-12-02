#include "totvs.ch"
#include "protheus.ch"
#Include "FWMVCDef.ch"
#Include "FILEIO.CH"


Static aMsg := {}
User Function ALAM001()
Local n1	:= 1
Local aPerg	:= {}
Local aArea	:= GetArea()
Private	aRet	:= {}


aAdd( aPerg ,{	6					,;// [1] : 6 - File
				"Arquivo: "			,;// [2] : Descrição
				Space(80)				,;// [3] : String contendo o inicializador do campo
				"@"						,;// [4] : String contendo a Picture do campo
				"!Empty(MV_PAR01).AND. FILE(MV_PAR01)"					,;// [5] : String contendo a validação
				".F."					,;// [6] : String contendo a validação When
				80						,;// [7] : Tamanho do MsGet
				.T.						,;// [8] : Flag .T./.F. Parâmetro Obrigatório ?
				"Arquivo CSV|*.csv|Arquivo TXT|*.txt"	;// [9] : Texto contendo os tipos de arquivo Ex.: "Arquivos .CSV |*.CSV"
			};
	)	
	
	
	If ParamBox(aPerg ,"Selecione o Arquivo",@aRet)      
		Processa( {|| AtuAcord(aRet) },"Aguarde...","Preparando dados para atualizacao do R.V")
	EndIf
	
	If Len(aMsg) > 0 
		AutoGRLog("")
		MostraErro("x")
		For n1 :=  1 to Len(aMsg)
			AutoGRLog(aMsg[n1])
		Next
		MostraErro()
		aSize(aMsg,0)
		aMsg := nil
	Endif
	
RestArea(aArea)	
Return .T.

Static Function AtuAcord()
Local lFirstLine	:= .T.
Local aCabec		:= {}
Local aDados		:= {}
Local cArq			:= MV_PAR01
Local lOk			:= .T.
Local nPosFil		:= 0
Local nPosRV		:= 0
Local nPosIV		:= 0
Local nPosSeq		:= 0
Local nPosCobCli	:= 0
Local nPosCancDU	:= 0
Local nI			:= 0
Local lInDark 		:= HelpInDark( .T. )
Local oModel	:= FwLoadModel("TURA034")
Local cBlind  := __cInternet
aMsg := {}
If Empty(cArq) .Or. !File(cArq)
	Help(,,"Arquivo",,I18N( "O arquivo #1 nao foi encontrado. A importacao sera abortada!",{cArq}),1,0) 
	Return(.F.)
EndIf

FT_FUse(cArq)
nTotLine := FT_FLastRec()
ProcRegua(nTotLine)
FT_FGOTOP()

cLinha := FT_FReadLn()
aCabec := Separa(cLinha,";",.T.)	

For	nI := 1 To Len(aCabec)	
	Do Case
		Case aCabec[nI] == "[FILIAL]"
			nPosFil		:= nI
		Case aCabec[nI] == "[RV]"
			nPosRV		:= nI
		Case aCabec[nI] == "[IV]"
			nPosIV		:= nI
		Case aCabec[nI] == "[SEQ]"
			nPosSeq		:= nI
		Case aCabec[nI] == "[COBRA CLIENTE?]"
			nPosCobCli	:= nI
		Case aCabec[nI] == "[CANCELA DU FORNECEDOR?]"
			nPosCancDU	:= nI
	EndCase
Next

If (nPosFil == 0 ) .or. (nPosRV == 0 ) .or.  (nPosIV == 0 ) .or. (nPosSeq == 0 ) .or. (nPosCobCli == 0 ) .or. (nPosCancDU == 0 )
	Help(,,"Arquivo",,I18N( "O arquivo #1 nao e valido. A importacao sera abortada!",{cArq}),1,0)
	Return .F. 
Endif
FT_FSkip()

While !FT_FEOF()
	
	IncProc("Lendo arquivo...") //"Lendo arquivo CSV..."
	HelpInDark( .T. )
	__cInternet := "AUTOMATICO"
	cLinha := FT_FReadLn()
	If !Empty(cLinha)
		aDados := Separa(cLinha,";",.T.)
		SetAcord(oModel,aDados[nPosFil],aDados[nPosRV],aDados[nPosIV],aDados[nPosSeq],aDados[nPosCobCli],aDados[nPosCancDU])
	Endif
	FT_FSkip()
EndDo
__cInternet := cBlind
oModel:Destroy()
HelpInDark( lInDark )//Restaura o estado anterior

Return

Static Function SetAcord(oModel,cFil,cRV,cIV,cSeq,cCobCli,cCancDU)
Local lCobraCli	:= cCobCli == 'SIM'
Local lCancDU		:= cCancDU == 'SIM'
Local oModelG48A	:=NIL
Local oModelG48B	:=NIL
Local cCodAco		:= '001579'
Local nX			:= 0
Local cErroRV		:= "Filial: #1 RV: #2 "
Local cErroIV		:= "IV: #3 SEQ: #4 "  
Local cFilBkp		:= cFilAnt
Local aStatus		:= {}
Local aStsErro		:= {}
Local lRet			:= .T.
cFil	:= PadR(cFil,TamSx3("G3P_FILIAL")[1])
cRv		:= PadR(cRv ,TamSx3("G3Q_NUMID" )[1])
cIV		:= PadR(cIV ,TamSx3("G3Q_IDITEM")[1])
cSeq	:= PadR(cSeq,TamSx3("G3Q_NUMSEQ")[1])

cFilAnt := cFil

oModel:SetOperation( MODEL_OPERATION_UPDATE  )

G3P->(DBSETORDER(1))
G3Q->(DBSETORDER(1))

If G3P->(DbSeek(cFil+cRv))
	If G3Q->(DbSeek(cFil+cRv+cIV+cSeq))
		oModel:GetModel( 'G3Q_ITENS' ):SetLoadFilter( { { 'G3Q_IDITEM', "'"+cIV+"'"}, { 'G3Q_NUMSEQ', "'"+cSeq+"'" }} )
		oModel:Activate()
		
		oModelG48A	:= oModel:GetModel('G48A_ITENS')
		oModelG48B	:= oModel:GetModel('G48B_ITENS')
		
		If lCobraCli
			If !oModelG48A:SeekLine( { { 'G48_CODACD', cCodAco } } )
				If !oModelG48A:CanInsertLine()
					oModelG48A:SetNoInsertLine(.F.)
				Endif
				If oModelG48A:IsEmpty() .or. (oModelG48A:Length() < oModelG48A:AddLine()) 
					If oModelG48B:SeekLine({{"G48_CLASS","F04"}})
						If (lRet := oModelG48A:SetValue('G48_CODACD' ,cCodAco ) .and. oModelG48A:SetValue('G48_VLACD' ,oModelG48B:GetValue('G48_VLACD') ) )
							aAdd(aStatus, "Foi incluido o Acordo "+cCodAco+" com sucesso")	
						Endif
					Else
						aAdd(aStsErro,"Nao foi possivel incluir o acordo "+cCodAco+" pois nao havia acordo de DU para buscar o Valor")   
					Endif	
					
				Else
					aAdd(aStsErro,"Nao foi possivel incluir o acordo "+cCodAco)   
				Endif
			Endif
		Else
			If oModelG48A:SeekLine( { { 'G48_CODACD', cCodAco } } ) 
				If oModelG48A:GetValue('G48_STATUS') <> "4"
					If lRet := oModelG48A:LoadValue('G48_STATUS' , "3")
						aAdd(aStatus, "Acordo "+cCodAco +" cancelado com sucesso")	
					Endif
				Else
					aAdd(aStsErro,"Nao foi possivel cancelar o acordo "+cCodAco+" pois o mesmo se encontra Finalizado") 
				Endif
			Endif
		Endif
		
		If lRet .and. lCancDU
			For nX	:= 1 to oModelG48B:Length()
				If oModelG48B:GetValue('G48_CLASS',nX) == "F04"
					oModelG48B:GoLine(nX)
					If lRet := oModelG48B:LoadValue('G48_STATUS' , "3")
						aAdd(aStatus, "O Acordo "+cCodAco+" foi cancelado com sucesso")	
					Endif
				Endif
			Next
		Endif
		If lRet .And. oModel:VldData() 
			oModel:CommitData()
			TmSetMsg(cFil,cRv,cIv,cSeq,aStatus)
		Else
			lRet := .F.
			 TMErro(oModel,cFil,cRv,cIv,cSeq,aStsErro)
		EndIf
		
		oModel:DeActivate()
	Else
		aAdd(aMsg,I18N( cErroRV+cErroIV +"nao foi encontrado",{cFil,cRv,cIv,cSeq}) )   
	Endif
Else
	aAdd(aMsg, I18N( cErroRV+"nao foi encontrado",{cFil,cRv})   )
Endif


cFilAnt := cFilBkp
Return

Static Function TMErro(oModel,cFil,cRv,cIv,cSeq,aStsErro)
Local cErro	:= ""
Local cMsgErro	:= ""
Local aErro	:= {} 
Local aArea	:= GetArea()
Local n1		:= 0
Default lLock	:= .T.

aErro	:= oModel:GetErrorMessage()
If !Empty(_NoTags(Alltrim(aErro[4])))
	SX3->(DBSETORDER(2))
	If SX3->(DBSEEK(Padr(aErro[4],10)))
		cMsgErro += AllTrim(X3TITULO()) +'('+_NoTags(Alltrim(aErro[4]))+')' +chr(13)+chr(10)
	Endif
Endif                                       
If !Empty(_NoTags(Alltrim(aErro[5])) ) .or. !Empty(_NoTags(Alltrim(aErro[6])) )
	cMsgErro += _NoTags(Alltrim(aErro[5])+'-'+AllTrim(aErro[6])) +chr(13)+chr(10)
Endif
If !Empty(_NoTags(Alltrim(aErro[8])))
	cMsgErro += 'Referencia:'+_NoTags(Alltrim(aErro[8]))+ chr(13)+chr(10)
Endif
If !Empty(Alltrim(strtran(oModel:GetErrorMessage()[7], chr(13)+chr(10), '')))
	cMsgErro += 'Solucao - '+_NoTags(AllTrim(aErro[7]))+chr(13)+chr(10)
Endif

For n1 := 1 To Len(aStsErro)
	cMsgErro += aStsErro[n1] +CHR(13)+CHR(10)
Next          
If !Empty(cMsgErro)
	cErro += "Foi retornado o seguinte erro: "+cMsgErro
Endif
cErro := I18N("Falha ao aplicar regra no Registro: #1| #2| #3| #4 ",{cFil,cRv,cIv,cSeq}) + chr(13) + chr(10) + cErro

aSize(aErro,0)
aErro:=nil
RestArea(aArea)
aAdd(aMsg, cErro)
Return 

Static Function TmSetMsg(cFil,cRv,cIv,cSeq,aStatus)
Local cMsg			:= ""
Local n1			:= 0
Default cRv		:= G3P->G3P_NUMID
Default aItens	:= {}
Default cMsgRet	:= "" 
cMsg := I18N("Registro: #1| #2| #3| #4 aplicado com sucesso",{cFil,cRv,cIv,cSeq}) + chr(13) + chr(10)
If Len(aStatus) > 0
	cMsg += "Foram realizados os seguintes procedimentos: " + chr(13) + chr(10)
	For n1 :=  1 to len(aStatus)
		cMsg += aStatus[n1] +CHR(13)+CHR(10)
	Next
Endif	
aAdd(aMsg, cMsg)

Return nil