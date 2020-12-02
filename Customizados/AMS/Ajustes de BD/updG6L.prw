#Include "Totvs.ch"

Function RunUpdG6L()

If MsgYesNo("Deseja atualizar o Destino das apurações (G6L_DESTIN)?") 
	FWMsgRun(,{|| updG6L()},  , "Aguarde... atualizando destino das apurações de fornecedor..." ) 
EndIf

Return


Static Function updG6L()

	Local cQuery    := ""
	
	cQuery := "UPDATE " + RetSqlName("G6L")
	cQuery += "	  SET G6L_DESTIN = (SELECT CASE "
	cQuery += "								 WHEN COUNT(G4C_DESTIN) > 1 THEN '3' "
	cQuery += "							     WHEN COUNT(G4C_DESTIN) = 1 THEN G4C_DESTIN " 
	cQuery += "							   END "
	cQuery += "					    FROM " + RetSqlName("G48")+ " G48 " 
	cQuery += "						INNER JOIN " + RetSqlName("G4C")+ " G4C ON G4C_FILIAL = G48_FILIAL AND "
	cQuery += "								                                   G4C_NUMID  = G48_NUMID  AND "
	cQuery += "														           G4C_IDITEM = G48_IDITEM AND "
	cQuery += "														           G4C_NUMSEQ = G48_NUMSEQ AND "
	cQuery += "														           G4C_APLICA = G48_APLICA AND "
	cQuery += "														           G4C_CODAPU = G48_CODAPU " 
	cQuery += "						WHERE G48_CODAPU = G6L_CODAPU AND "
	cQuery += "									       RTRIM(G48_CODAPU) <> '' AND "
	cQuery += "									       RTRIM(G4C_DESTIN) <> '' AND "  
	cQuery += "									       G4C_CLIFOR = '2' AND "
	cQuery += "									       G4C.D_E_L_E_T_ = '' "
	cQuery += "						GROUP BY G4C_CODAPU, G4C_DESTIN) " 
	cQuery += "WHERE G6L_TPAPUR = '3' AND "
	cQuery += "      G6L_CODAPU IN (SELECT G4C_CODAPU " 
	cQuery += "					    FROM " + RetSqlName("G48")+ " G48 "
	cQuery += "					    INNER JOIN " + RetSqlName("G4C")+ " G4C ON G4C_FILIAL = G48_FILIAL AND " 
	cQuery += "					                             G4C_NUMID  = G48_NUMID  AND "
	cQuery += "											     G4C_IDITEM = G48_IDITEM AND "
	cQuery += "											     G4C_NUMSEQ = G48_NUMSEQ AND "
	cQuery += "											     G4C_APLICA = G48_APLICA AND "
	cQuery += "											     G4C_CODAPU = G48_CODAPU "
	cQuery += "					    WHERE G48_CODAPU = G6L_CODAPU AND " 
	cQuery += "					          RTRIM(G48_CODAPU) <> '' AND "
	cQuery += "						      RTRIM(G4C_DESTIN) <> '' AND "
	cQuery += "						      G4C_CLIFOR = '2' AND "
	cQuery += "						      G4C.D_E_L_E_T_ = '' "
	cQuery += "                    GROUP BY G4C_CODAPU) "
		
	If TCSQLExec(cQuery) >= 0
		MsgInfo('Executado com sucesso.')
	Else
		MsgAlert('Erro na execução.')	
	EndIf

Return .T.