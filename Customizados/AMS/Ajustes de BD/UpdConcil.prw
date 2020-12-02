User Function UpdConcil()
	Local oModel := nil
	Local lRet 	 := .F.

	If MyOpenSM0(.T.)
		RpcSetType( 3 )
		RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )
		
		BEGIN TRANSACTION		
			lRet := AjusConcil( '1' )
			If lRet 
				lRet := AjusConcil('2' )
			EndIf

			If !lRet 
				DisarmTransaction()
			EndIf
			
		END TRANSACTION
	
		If lRet
			MsgInfo("Processo finalizado com sucesso.")
		Else
			MsgAlert("Erro ao processar, alterações estornadas.")
		EndIf
		
		RpcClearEnv()
		
	EndIf	
	
Return


Static Function AjusConcil( cTipo )
	Local aDependency	:= {}	
	Local cAliasTMP	:= GetNextAlias()
	Local lRet		:= .T.
	Local nX		:= 0
	Local oModel	:= ''
	Local cModel	:= IIF( cTipo == '1', 'TURA042A', 'TURA042R' )
	Local cNewConc	:= ''

	BeginSql Alias cAliasTMP
		SELECT	G8C_FILIAL, 
				G8C_CONCIL 
				FROM %Table:G8C% G8C
			WHERE G8C_TIPO = %Exp:cTipo%
				AND G8C.%notDel%
			ORDER BY G8C_FILIAL, G8C_CONCIL
	EndSql

	G8C->( dbSetOrder( 1 ) )
	If (cAliasTMP)->( !EOF() )
		oModel := FwLoadModel( cModel )
		
		GetDependency( oModel, 'G8C_MASTER', aDependency )
	
		G8C->( dbSetOrder(1) )
		While (cAliasTMP)->( !EOF() ) .And. lRet

			If G8C->( dbSeek( (cAliasTMP)->G8C_FILIAL + (cAliasTMP)->G8C_CONCIL ) )
			
				cNewConc := GetNewNum()
				
				RecLock( 'G8C', .F. )
					G8C->G8C_XOLDNU := G8C->G8C_CONCIL
					G8C->G8C_CONCIL := cNewConc
					G8C->G8C_XOLDFI	:= G8C->G8C_FILIAL
				G8C->( MsUnlock() )
			
				For nX := 1 to len( aDependency )
					
					If lRet .And. ( aDependency[nX] )->( FieldPos( aDependency[nX] + '_CONINU' ) ) > 0
						lRet := UpdTable( '_CONINU', aDependency[nX], (cAliasTMP)->G8C_FILIAL, (cAliasTMP)->G8C_CONCIL, cNewConc  )
					EndIf	
		
					If lRet .And. ( aDependency[nX] )->( FieldPos( aDependency[nX] + '_CONORI' ) ) > 0
						lRet := UpdTable( '_CONORI', aDependency[nX], (cAliasTMP)->G8C_FILIAL, (cAliasTMP)->G8C_CONCIL, cNewConc  )
					EndIf	
					
				Next
			
				If lRet
					lRet := UpdG3R( (cAliasTMP)->G8C_FILIAL, (cAliasTMP)->G8C_CONCIL, cNewConc )
				EndIf
				
			
				If lRet
					lRet := UpdG8Y( (cAliasTMP)->G8C_FILIAL, cTipo, (cAliasTMP)->G8C_CONCIL, cNewConc )
				EndIf
			
			EndIf
			(cAliasTMP)->( dbSkip() )
		EndDo
		
		(cAliasTMP)->( dbCloseArea() )
				
		If lRet
			lRet := UpdG8C( cTipo )
		EndIf
	
	EndIf
	
	
	
Return lRet

Static Function GetDependency( oModel, cId, aDep )
	Local aAux 		:= {}
	Local nX		:= 0
	Local oMdlAux	:= nil
	
	aAux := oModel:GetDependency( cId )
	
	For nX := 1 to len(aAux)
		cTable := oModel:GetModel( aAux[nX][2] ):GetStruct():GetTable()[1]
		
		If AliasInDic( cTable )
			If aScan( aDep, {|x| x == cTable} ) == 0
				aAdd( aDep, cTable )
			EndIf	
			GetDependency( oModel, aAux[nX][2], aDep )
		EndIf	
	Next
	
Return

Static Function GetNewNum()
	Local cNewNum 	:= GetMV( 'AL_NUMCON' )

	//TODO tratamento para verificar se a conciliação já existe na base de dados

	PutMV( 'AL_NUMCON', Soma1(cNewNum) )
	
Return cNewNum

Static Function UpdTable( cField, cTable, cFil, cConcil, cNewConc  )
	Local cSts := ''

	cSts := "UPDATE " + RetSqlName(cTable) 
	cSts += 	" SET " + cTable + cField +" = '" + cNewConc +"' "
	cSts += 	" WHERE " + cTable + "_FILIAL = '" + cFil + "' "
	cSts += 		" AND " + cTable + cField +" = '"+ cConcil +"' "
	
Return TCSQLExec( cSts ) >= 0	

Static Function UpdG8Y( cFil, cTpCon, cConcil, cNewConcil ) 
	cSts := " UPDATE " + RetSqlName('G8Y') + " "
	cSts += 	" SET G8Y_FILIAL = ' ', "
	cSts +=			" G8Y_CONCIL = '" + cNewConcil + "'"
	cSts += 	" WHERE G8Y_FILIAL = '" + cFil + "'"
	cSts += 		" AND G8Y_CONCIL = '" + cConcil + "'" 
	cSts += 		" AND G8Y_TPFAT = '" + cTpCon + "'"
	cSts += 		" AND D_E_L_E_T_ = ' ' "

Return TCSQLExec( cSts ) >= 0

Static Function UpdG3R( cFil, cConcil, cNewConcil )
	Local cSts := ' '
	
	cSts := "UPDATE " + RetSqlName('G3R')
	cSts += 	" SET G3R_CONCIL = '" + cNewConcil + "', "
	cSts += 	" G3R_FILCON = ' ' "
	cSts += 	" WHERE G3R_TPSEG <> '1' "
	cSts += 		" AND G3R_FILCON = '" + cFil + "'"	
	cSts += 		" AND G3R_CONCIL = '" + cConcil + "'"
	cSts += 		" AND D_E_L_E_T_ = ' ' "

Return TCSQLExec( cSts ) >= 0

Static Function UpdG8C( cTipo )
	Local cSts := ' '
	
	cSts := "UPDATE " + RetSqlName('G8C')
	cSts += 	" SET G8C_FILIAL = ' ' "
	cSts += 	" WHERE G8C_TIPO = '" + cTipo + "' "
	cSts += 		" AND D_E_L_E_T_ = ' ' "

Return TCSQLExec( cSts ) >= 0


Static Function MyOpenSM0(lShared)

	Local lOpen := .F.
	Local nLoop := 0
	
	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
	
		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
	
		Sleep( 500 )
	
	Next nLoop
	
	If !lOpen
		MsgStop( "Não foi possível a abertura da tabela " + ;
		IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
	EndIf

Return lOpen
