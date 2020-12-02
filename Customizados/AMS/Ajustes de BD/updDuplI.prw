#Include "Totvs.ch"


//Ajusta a chave única da tabela G4C
Function RunChvG4C()

Local lRet := .T.


If MsgYesNo("Deseja ajustar a chave única da tabela G4C?") 
	
	DBUseArea(.F., 'TOPCONN', RetSqlName("G4C"),"G4C" , .F., .T.)
	
	If Alias() == "G4C"
	
		G4C->(DbCloseArea())
	
		FWMsgRun(,{|| UpdG4C(@lRet)},  , "Aguarde... atualizando IF duplicados..." ) 	
		If lRet 
			FWMsgRun(,{|| BkpG4C(@lRet)},  , "Aguarde... realizando backup da tabela G4C..." ) 
		EndIf
		If lRet
			FWMsgRun(,{|| DrpG4C(@lRet)},  , "Aguarde... recriando tabela G4C com nova chave..." ) 
		EndIf
		If lRet
			FWMsgRun(,{|| LoadG4C(@lRet)},  , "Aguarde... carregando tabela G4C..." ) 
		EndIf
		
		If lRet
			Alert('Ajuste Finalizado com sucesso')
		Else
			Alert('Houve problemas no processo, avalie a restauração da tabela G4C.')
		EndIf

	Else
		Alert('Não foi possivel abrir G4C em modo exclusivo.')
	EndIf

		
EndIf
	

Return

/*/{Protheus.doc} updDuplI
(long_description)
@type function
@author osmar.junior
@since 18/08/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function UpdG4C(lRet)

Local cAliasQry 	:= GetNextAlias()
Local cChave		:= ""
Local nRecno		:= 0
Local cIdIfNew	:= ""
Local cFilbkp		:= cFilAnt

BeginSql Alias cAliasQry

	SELECT G4CA.G4C_FILIAL,G4CA.G4C_NUMID,G4CA.G4C_IDITEM,G4CA.G4C_NUMSEQ,G4CA.G4C_APLICA,G4CA.G4C_IDIF,G4CA.G4C_IFPRIN,G4CA.G4C_CONORI,G4CA.R_E_C_N_O_ G4CRECNO FROM (
	SELECT G4C_FILIAL, G4C_IDIF, G4C_CONORI, COUNT(*) COUNT FROM %table:G4C% G4C
	WHERE G4C.%notDel%
	GROUP BY G4C_FILIAL, G4C_IDIF, G4C_CONORI HAVING COUNT(*) > 1) TMP
	INNER JOIN %table:G4C% G4CA ON
	G4CA.G4C_FILIAL = TMP.G4C_FILIAL AND
	G4CA.G4C_IDIF = TMP.G4C_IDIF AND
	G4CA.%notDel%
	ORDER BY G4C_FILIAL,G4C_IDIF,G4C_CONORI,G4C_NUMID,G4C_IDITEM,G4C_NUMSEQ,G4C_APLICA
		
EndSql
	
While (cAliasQry)->(!EOF())
	
	If cChave <> (cAliasQry)->(G4C_FILIAL+G4C_IDIF+G4C_CONORI)
		
		//Neste caso é primeiro registro, não precisa atualizar  
		cChave := (cAliasQry)->(G4C_FILIAL+G4C_IDIF+G4C_CONORI)
		nRecno := (cAliasQry)->(G4CRECNO)
	
	ElseIf cChave == (cAliasQry)->(G4C_FILIAL+G4C_IDIF+G4C_CONORI) .And. nRecno <> (cAliasQry)->(G4CRECNO) 
		
		cFilAnt := (cAliasQry)->(G4C_FILIAL)
		
		cIdIfNew		:= 	TurGetNum("G4C","G4C_IDIF")
		ConfirmSX8()
		
		lRet := AjustBase(	(cAliasQry)->(G4C_FILIAL),;
					(cAliasQry)->(G4C_NUMID),;
					(cAliasQry)->(G4C_IDITEM),;
					(cAliasQry)->(G4C_NUMSEQ),;
					(cAliasQry)->(G4C_IDIF),;
					(cAliasQry)->(G4C_APLICA),;
					(cAliasQry)->(G4CRECNO),;
					cIdIfNew,;
					(cAliasQry)->(G4C_CONORI))
		
	EndIf
	
	If !lRet
		Exit
	EndIf
	
	
	(cAliasQry)->(DbSkip())
EndDo


(cAliasQry)->( DbCloseArea() )

cFilAnt := cFilbkp

Return lRet


/*/{Protheus.doc} AjustBase
(long_description)
@type function
@author osmar.junior
@since 21/08/2017
@version 1.0
@param cAliasQry, character, (Descrição do parâmetro)
@param RecnoG4C, ${param_type}, (Descrição do parâmetro)
@param cIdIfNew, character, (Descrição do parâmetro)
@param nG85RECNO, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static FuncTion AjustBase(cFilG4C,cNumId,cIdItem,cNumSeq,cIDIFAtu,cAplica,nRecnoG4C,cIdIfNew,cConori )

Local lRet 	:= .T.
Local cQuery	:= ""
	
//Atualiza o próprio Item			
cQuery := " UPDATE " +RetSQLName("G4C")+ " SET G4C_IDIF = '"+ cIdIfNew +"' WHERE  R_E_C_N_O_ = " + AllTrim(STR(nRecnoG4C)) +";"

//Atualiza os Filhos dele
cQuery += " UPDATE " +RetSQLName("G4C")+ " SET G4C_IFPRIN = '"+ cIdIfNew +"' WHERE " 
cQuery += " G4C_FILIAL = '" + cFilG4C + "' AND "
cQuery += " G4C_NUMID = '" + cNumId + "' AND "
cQuery += " G4C_IDITEM = '" + cIdItem + "' AND "
cQuery += " G4C_NUMSEQ = '" + cNumSeq + "' AND "
cQuery += " G4C_CONORI = '" + cConori + "' AND "
cQuery += " G4C_IFPRIN = '" + cIDIFAtu + "'"+";"

//Atualiza a G85 dele
cQuery += " UPDATE " +RetSQLName("G85")+ " SET G85_IDIF = '"+ cIdIfNew +"' WHERE " 
cQuery += " G85_FILREF = '" + cFilG4C + "' AND "
cQuery += " G85_IDIF = '" + cIDIFAtu + "' AND"
cQuery += " G85_REGVEN = '" + cNumId + "' AND "
cQuery += " G85_ITVEND = '" + cIdItem + "' AND "
cQuery += " G85_SEQIV = '" + cNumSeq + "' "


lRet := TCSQLExec(cQuery) >= 0
					

If !lRet 
	Alert("Ajuste duplicidade " + TCSQLError())
EndIf

Return lRet



//Backup da tabela G4C
Static Function BkpG4C(lRet)

Local cAliasVld	:= GetNextAlias()
Local cAliasQry 	:= GetNextAlias()
Local nG4C			:= 1
Local nBKP			:= 2

BeginSql Alias cAliasVld
	SELECT G4C_IDIF IDIF,G4C_FILIAL FILIAL,SUM(1) CT FROM %table:G4C% G4C WHERE G4C.%notDel% GROUP BY G4C_IDIF,G4C_FILIAL HAVING SUM(1) > 1
EndSql

If (cAliasVld)->(Eof())

	lRet := TCSqlExec("SELECT * INTO G4C_BKP_CHV FROM "+RetSqlName("G4C")) >= 0
	 
	If lRet 
		
		BeginSql Alias cAliasQry
			SELECT 'G4C' Tabela, COUNT(*) QTD FROM %table:G4C%
			UNION
			SELECT 'BKP' Tabela, COUNT(*) QTD FROM G4C_BKP_CHV		
		EndSql
		
		(cAliasQry)->(DbGoTop())
		nG4C := (cAliasQry)->(QTD)
		
		(cAliasQry)->(DbSkip())
		nBKP := (cAliasQry)->(QTD)
		
		If nG4C <> nBKP
			lRet := .F.
			Alert("Backup incompleto")
		EndIf
		
	Else
		 Alert("BACKUP " + TCSQLError())
	EndIf
Else
	Alert("Há registros com IF duplicado")
	lRet := .F.
Endif

Return lRet



//Drop da tabela G4C
Static Function DrpG4C(lRet)

lRet := TCSqlExec("DROP TABLE "+RetSqlName("G4C")) >= 0
   
If lRet

	If SX2->(DbSeek("G4C"))
		RecLock("SX2",.F.)
			SX2->X2_UNICO := "G4C_FILIAL+G4C_IDIF+G4C_CONORI"
		SX2->(MsUnLock())
		
		lRet := ChkFile("G4C")
		
		If !lRet
			Alert("ChkFile() Não foi possível recriar a tabela G4C") 
		EndIf
			
	Else
		lRet := .F.
		Alert("SX2->(DbSeek) Não foi possível encontrar a SX2") 
	EndIf

Else

	Alert("DROP TABLE " + TCSQLError())

EndIf

Return lRet 
	



//Load da tabela G4C
Static Function LoadG4C(lRet)

Local cAliasQry 	:= GetNextAlias()
Local nG4C			:= 1
Local nBKP			:= 2
Local cInsert		:= ""

cInsert := "INSERT INTO "+RetSqlName("G4C")+ " ("
cInsert += "G4C_FILIAL,"
cInsert += "G4C_NUMID,"
cInsert += "G4C_IDITEM,"
cInsert += "G4C_NUMSEQ,"
cInsert += "G4C_APLICA,"
cInsert += "G4C_IDIF,"
cInsert += "G4C_CLIFOR,"
cInsert += "G4C_NUMACD,"
cInsert += "G4C_CLASS,"
cInsert += "G4C_CODIGO,"
cInsert += "G4C_LOJA,"
cInsert += "G4C_SEGNEG,"
cInsert += "G4C_EMISS,"
cInsert += "G4C_TIPO,"
cInsert += "G4C_PAGREC,"
cInsert += "G4C_GRPPRD,"
cInsert += "G4C_DESTIN,"
cInsert += "G4C_CONDPG,"
cInsert += "G4C_NATUR,"
cInsert += "G4C_TPFOP,"
cInsert += "G4C_MOEDA,"
cInsert += "G4C_VALOR,"
cInsert += "G4C_VENCIM,"
cInsert += "G4C_ENTAD,"
cInsert += "G4C_ITRAT,"
cInsert += "G4C_STATUS,"
cInsert += "G4C_IFPRIN,"
cInsert += "G4C_OBS,"
cInsert += "G4C_CODPRO,"
cInsert += "G4C_CONORI,"
cInsert += "G4C_CONINU,"
cInsert += "G4C_OPERAC,"
cInsert += "G4C_DOC,"
cInsert += "G4C_ASSOCI,"
cInsert += "G4C_CARTUR,"
cInsert += "G4C_TARIFA,"
cInsert += "G4C_TAXA,"
cInsert += "G4C_EXTRA,"
cInsert += "G4C_FATCAR,"
cInsert += "G4C_LA,"
cInsert += "G4C_CODAPU,"
cInsert += "G4C_TPCONC,"
cInsert += "G4C_DTLIB,"
cInsert += "G4C_ACERTO,"
cInsert += "G4C_SOLIC,"
cInsert += "G4C_FILFAT,"
cInsert += "G4C_NUMFAT,"
cInsert += "G4C_PREFIX,"
cInsert += "G4C_TXCAMB,"
cInsert += "G4C_LC,"
cInsert += "G4C_FILREF,"
cInsert += "G4C_TXORIG,"
cInsert += "G4C_TXRORI,"
cInsert += "G4C_LACONC,"
cInsert += "G4C_DTINC,"
cInsert += "G4C_TAXADU,"
cInsert += "G4C_ESTORN,"
cInsert += "D_E_L_E_T_,"
cInsert += "R_E_C_N_O_,"
cInsert += "R_E_C_D_E_L_,"
cInsert += "G4C_XDWLOG,"
cInsert += "G4C_XENVBI " 
cInsert += ") " 
cInsert += "SELECT "
cInsert += "G4C_FILIAL,"
cInsert += "G4C_NUMID,"
cInsert += "G4C_IDITEM,"
cInsert += "G4C_NUMSEQ,"
cInsert += "G4C_APLICA,"
cInsert += "G4C_IDIF,"
cInsert += "G4C_CLIFOR,"
cInsert += "G4C_NUMACD,"
cInsert += "G4C_CLASS,"
cInsert += "G4C_CODIGO,"
cInsert += "G4C_LOJA,"
cInsert += "G4C_SEGNEG,"
cInsert += "G4C_EMISS,"
cInsert += "G4C_TIPO,"
cInsert += "G4C_PAGREC,"
cInsert += "G4C_GRPPRD,"
cInsert += "G4C_DESTIN,"
cInsert += "G4C_CONDPG,"
cInsert += "G4C_NATUR,"
cInsert += "G4C_TPFOP,"
cInsert += "G4C_MOEDA,"
cInsert += "G4C_VALOR,"
cInsert += "G4C_VENCIM,"
cInsert += "G4C_ENTAD,"
cInsert += "G4C_ITRAT,"
cInsert += "G4C_STATUS,"
cInsert += "G4C_IFPRIN,"
cInsert += "G4C_OBS,"
cInsert += "G4C_CODPRO,"
cInsert += "G4C_CONORI,"
cInsert += "G4C_CONINU,"
cInsert += "G4C_OPERAC,"
cInsert += "G4C_DOC,"
cInsert += "G4C_ASSOCI,"
cInsert += "G4C_CARTUR,"
cInsert += "G4C_TARIFA,"
cInsert += "G4C_TAXA,"
cInsert += "G4C_EXTRA,"
cInsert += "G4C_FATCAR,"
cInsert += "G4C_LA,"
cInsert += "G4C_CODAPU,"
cInsert += "G4C_TPCONC,"
cInsert += "G4C_DTLIB,"
cInsert += "G4C_ACERTO,"
cInsert += "G4C_SOLIC,"
cInsert += "G4C_FILFAT,"
cInsert += "G4C_NUMFAT,"
cInsert += "G4C_PREFIX,"
cInsert += "G4C_TXCAMB,"
cInsert += "G4C_LC,"
cInsert += "G4C_FILREF,"
cInsert += "G4C_TXORIG,"
cInsert += "G4C_TXRORI,"
cInsert += "G4C_LACONC,"
cInsert += "G4C_DTINC,"
cInsert += "G4C_TAXADU,"
cInsert += "G4C_ESTORN,"
cInsert += "D_E_L_E_T_,"
cInsert += "R_E_C_N_O_,"
cInsert += "R_E_C_D_E_L_,"
cInsert += "G4C_XDWLOG,"
cInsert += "G4C_XENVBI" 
cInsert += " FROM G4C_BKP_CHV"

lRet := TCSqlExec(cInsert) >= 0
 
If lRet 
	
	BeginSql Alias cAliasQry
		SELECT 'G4C' Tabela, COUNT(*) QTD FROM %table:G4C%
		UNION
		SELECT 'BKP' Tabela, COUNT(*) QTD FROM G4C_BKP_CHV		
	EndSql
	
	(cAliasQry)->(DbGoTop())
	nG4C := (cAliasQry)->(QTD)
	
	(cAliasQry)->(DbSkip())
	nBKP := (cAliasQry)->(QTD)
	
	If nG4C <> nBKP
		lRet := .F.
		Alert("Carga da G4C incompleto")
	EndIf
	
Else
	 Alert("LOAD G4C " + TCSQLError())
EndIf

Return lRet
