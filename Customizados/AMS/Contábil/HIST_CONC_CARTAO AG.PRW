#Include "Protheus.ch"

//Traz o nome do cliente para as conciliações de cartão.

User function Histcart()

Local _cQuery 	:= ''
Local cMsg	 	:= '' 
Local _cAliasZ5	:= GetNextAlias()

BeginSQL Alias _cAliasZ5
   		SELECT G3R_NOMREP
   		FROM %table:G4C% G4C 
   		INNER JOIN %table:G3RP% G3R ON
   		G4C_FILIAL = G3R.G3R_FILIAL
   		AND	G4C_NUMID = G3R.G3R_NUMID 
   		AND G4C.%NotDel%
		WHERE G3R_FILIAL = %Exp:G4C->G4C_FILIAL%
   		AND G3R_NUMID = %Exp:G4C->G4C_NUMID%
   		AND G3R.%NotDel%
   	EndSQL   
   	
 
cMsg:= (_cAliasZ5)->G3R_NOMREP

(_cAliasZ5)->(dbCloseArea()) 

Return(cMsg)