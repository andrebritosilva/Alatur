#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"

// Função que limpa as 
Function LimpaIFs()

Local cAliasQry := GetNextAlias()
Local oModel	:= "" 
Local cRv		:= ""
Local cFil		:= ""
Local cFilBkp	:= cFilAnt
Local lRet		:= .T.
Local aItens	:= {}
Local nTotReg	:= 0
Local lInDark 	:= HelpInDark( .F. )
Local cConInu   := SPACE(TAMSX3('G3Q_CONINU')[1])
Local cConOri   := SPACE(TAMSX3('G3Q_CONINU')[1])
Local lLock		:= 0

BeginSql Alias cAliasQry

	SELECT G4C_FILIAL, G4C_NUMID, G4C_IDITEM, G4C_NUMSEQ, G4C_APLICA, G4C_CLIFOR, COUNT(G4C_IDIF)
	FROM %Table:G4C% G4C
	WHERE G4C_APLICA <> '' AND G4C_CONINU = %Exp:cConInu% AND G4C_CONORI = %Exp:cConOri% AND G4C.%notdel%
	GROUP BY G4C_FILIAL, G4C_NUMID, G4C_IDITEM, G4C_NUMSEQ, G4C_APLICA, G4C_CLIFOR
	HAVING COUNT(G4C_IDIF) > 1

EndSql

If (cAliasQry)->(EOF()) .and. (cAliasQry)->(BOF())
	FwAlertError("Não há registros a serem processados", "Aviso")
	(cAliasQry)->(dbCloseArea())
	Return nil
EndIf

Count to nTotReg
ProcRegua(nTotReg)
(cAliasQry)->(dbGoTop())

cMsgRet	:= ""

If Empty(cRv)
	G3P->(DbSeek((cAliasQry)->G4C_FILIAL + (cAliasQry)->G4C_NUMID))
	cFil	:= (cAliasQry)->G4C_FILIAL
	cRv		:= (cAliasQry)->G4C_NUMID
	
	cFilAnt := TurRetFil('G3P', cFil)

	If lLock := SoftLock('G3P') .And. !Empty(cFilAnt)
		T034SetStc({{"lHierarquia", .F.}, {"nSegmento", Val(G3P->G3P_SEGNEG)}})
		oModel := FwLoadModel("TURA034")
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		oModelG3Q := oModel:GetModel('G3Q_ITENS')
	Else
		cFilAnt := cFilBkp	
	EndIf
EndIf

nInc := 0

While (cAliasQry)->(!Eof())
	nInc++

	aAdd(aItens,{(cAliasQry)->G4C_IDITEM, (cAliasQry)->G4C_NUMSEQ})

	If lLock
		If oModelG3Q:SeekLine({{"G3Q_IDITEM", (cAliasQry)->G4C_IDITEM}, {"G3Q_NUMSEQ", (cAliasQry)->G4C_NUMSEQ}})
			oModelG3Q:ForceValue("G3Q_ATUIF" , (cAliasQry)->G4C_CLIFOR)
			oModelG3Q:ForceValue("G3Q_ATUIFA", (cAliasQry)->G4C_CLIFOR)
		EndIf

		oModel:lModify := .T.
		IncProc(cValToChar(nInc) + "/" + cValToChar(nTotReg) + "| " + "Processando R.V " + RTrim((cAliasQry)->G4C_NUMID) + " Item " + RTrim((cAliasQry)->G4C_IDITEM) + " Seq " + RTrim((cAliasQry)->G4C_NUMSEQ))  
	EndIf

	(cAliasQry)->(DbSkip())
	If (cAliasQry)->(Eof()) .OR. cFil + cRv <> (cAliasQry)->G4C_FILIAL + (cAliasQry)->G4C_NUMID
		If lLock
			HelpInDark( .T. )
			cBlind  := __cInternet
			__cInternet := "AUTOMATICO"
			Tur34ItFin(oModel, oMdlG3Q:GetValue("G3Q_ATUIF"), .T., oMdlG3Q:GetValue("G3Q_ATUIFA"), , .T.)
		EndIf

		If !lLock .OR.( lLock .AND. oModel:HasErrorMessage() .or. !oModel:VldData() .or. !oModel:CommitData())  
			lRet := .F.
			Alert("Registro: " + Rtrim(cRV)+ " --> Falha ao aplicar acordo")
		Else
			TmSetMsg(cFil,cRv,aItens)
		EndIf
	
		aItens	:= {}
		
		If lLock
			MsUnlock()
			oModel:DeActivate()
			oModel:Destroy()
			__cInternet := cBlind
		EndIf
		If (cAliasQry)->(!Eof())
			G3P->(DbSeek((cAliasQry)->G4C_FILIAL + (cAliasQry)->G4C_NUMID))
			cFil := (cAliasQry)->G4C_FILIAL
			cRv	 := (cAliasQry)->G4C_NUMID 
			
			cFilAnt := TurRetFil('G3P',cFil)
			
			If lLock := SoftLock('G3P') .And. !Empty(cFilAnt)
				T034SetStc({{"lHierarquia",.F.}, {"nSegmento", Val(G3P->G3P_SEGNEG)}, {"lBlind", .T.}})
				oModel := FwLoadModel("TURA034")
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				oModel:Activate()
				oModelG3Q := oModel:GetModel('G3Q_ITENS')	
			Else
				cFilAnt := cFilBkp
			EndIf
		EndIf
	EndIf
EndDo

HelpInDark( .F. )

(cAliasQry)->(dbCloseArea())

If lRet
	FwAlertSuccess("Aplicação de Acordo realizada com sucesso", "Sucesso")
Else
	FwAlertWarning("Houve erro na aplicação de acordo", "Atenção")
EndIf

AutoGRLog("")
MostraErro("x")
AutoGRLog(cMsgRet)
MostraErro()
HelpInDark( lInDark )//Restaura o estado anterior

cFilAnt := cFilBkp

Return .T.

/*/{Protheus.doc} TURM034
Aplicação automatica mostra erro
@author Jacomo Lisa
@since 07/10/2016
@version 1.0
/*/

Static Function TM034Erro(oModel,cFil,cRV,aItens,lLock)
Local cErro	  := ""
Local aErro	  := {} 
Local aArea	  := GetArea()
Local n1	  := 0
Default lLock := .T.

If !Empty(cFil)
	cFil := "Filial: " + Rtrim(cFil) + " "
EndIf 

cErro := cFil + "Registro: " + Rtrim(cRV)+ " --> Falha ao aplicar acordo" + chr(13)+ chr(10) 
cErro += "Foi retornado o seguinte erro: "

If !lLock
	cErro += "Registro bloqueado com outro usuário" + chr(13)+ chr(10)
Else	
	aErro := oModel:GetErrorMessage()
	If !Empty(_NoTags(Alltrim(aErro[4])))
		SX3->(DBSETORDER(2))
		If SX3->(DBSEEK(Padr(aErro[4],10)))
			cErro += AllTrim(X3TITULO()) + '(' + _NoTags(Alltrim(aErro[4])) + ')' + chr(13) + chr(10)
		EndIf
	EndIf

	cErro += _NoTags(Alltrim(aErro[5]) + '-' + AllTrim(aErro[6])) + chr(13) + chr(10)

	If !Empty(_NoTags(Alltrim(aErro[8])))
		cErro += " Referencia: " + _NoTags(Alltrim(aErro[8])) + chr(13) + chr(10)
	EndIf
	If !Empty(Alltrim(strtran(oModel:GetErrorMessage()[7], chr(13)+chr(10), '')))
		cErro += " Solução - " + _NoTags(AllTrim(aErro[7])) + chr(13) + chr(10)
	EndIf
EndIf

For n1 := 1 to Len(aItens) 
	cErro += " Item: " + Rtrim(aItens[n1][1]) + " Sequência: " + Rtrim(aItens[n1][2]) + chr(13) + chr(10) 
Next

TURXNIL(aErro)
RestArea(aArea)

Return 

/*/{Protheus.doc} TURM034
Aplicação automatica de acordos mostra msg de sucesso

@author Jacomo Lisa
@since 07/10/2016
@version 1.0
/*/
Static Function TmSetMsg(cFil, cRV, aItens)
Local cMsg		:= ""
Local n1		:= 0

Default cRv		:= G3P->G3P_NUMID
Default aItens	:= {}
Default cMsgRet	:= ""

If !Empty(cFil)
	cFil := "Filial: " + Rtrim(cFil) + " "
EndIf 

cMsg += "Registro: " + Rtrim(cRv) + " --> Aplicado com sucesso" + chr(13) + chr(10)

For n1 := 1 to Len(aItens) 
	cMsg += " Item: " + Rtrim(aItens[n1][1]) + " Sequencia: " + Rtrim(aItens[n1][2]) + chr(13) + chr(10) 
Next

cMsgRet += cMsg

Return nil