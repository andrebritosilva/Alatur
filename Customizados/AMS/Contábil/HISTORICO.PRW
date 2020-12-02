#Include "Protheus.ch"

User function Hist()

Local _cQuery 	:= ''
Local cMsg	 	:= '' 
Local _cAliasZ1	:= GetNextAlias()

BeginSQL Alias _cAliasZ1
   		SELECT G3R_NOMREP
   		FROM %table:G4C% G4C 
   		INNER JOIN %table:G3R% G3R ON
   		G4C_FILIAL = G3R.G3R_FILIAL
   		AND	G4C_NUMID = G3R.G3R_NUMID 
   		AND G4C_NUMSEQ = G3R.G3R_NUMSEQ
   		AND G4C.%NotDel%
		WHERE G3R_FILIAL = %Exp:G4C->G4C_FILIAL%
   		AND G3R_NUMID = %Exp:G4C->G4C_NUMID%
   		AND G3R_NUMSEQ = %Exp:G4C->G4C_NUMSEQ%
   		AND G3R.%NotDel%
   	EndSQL
 
cMsg:= (_cAliasZ1)->G3R_NOMREP

(_cAliasZ1)->(dbCloseArea()) 

Return(cMsg)