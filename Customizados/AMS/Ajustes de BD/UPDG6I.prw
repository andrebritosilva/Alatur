#Include "Totvs.ch"

Function RunUpdG6I()

If MsgYesNo("Deseja atualizar filial (G6I_FILDR)?") 
	FWMsgRun(,{|| updG6I()},  , "Aguarde... atualizando filial da G6I..." ) 
EndIf

Return


Static Function updG6I()
	cSts := ""
	
	
	cSts := "UPDATE " + RetSqlName( 'G6I' )
	cSts += 	" SET G6I_FILDR = ( "
	cSts += 		" SELECT G3R_MSFIL " 
	cSts += 			" FROM " + RetSqlName( 'G3R' ) + " G3R "
	cSts += 			" WHERE G3R_CONCIL = G6I_CONCIL "
	cSts += 				" AND G3R_FILCON = G6I_FILIAL "
	cSts += 				" AND G3R_NUMID = G6I_NUMID "
	cSts += 				" AND G3R_IDITEM = G6I_IDITEM "
	cSts += 				" AND G3R_NUMSEQ = G6I_NUMSEQ "
	cSts += 				" AND G3R.D_E_L_E_T_ = ' ' "
	cSts += 				" 				) "
	cSts += 	" WHERE G6I_NUMID <> ' ' "	
	cSts += 		" AND G6I_IDITEM	<> ' ' "
	cSts += 		" AND G6I_NUMSEQ <> ' ' "
	cSts += 		" AND D_E_L_E_T_ = ' ' "
	
	If TCSQLExec( cSts ) >= 0
		MsgInfo( 'Executado com sucesso' )
	Else
		MsgAlert( 'Erro na execução' )	
	EndIf
Return