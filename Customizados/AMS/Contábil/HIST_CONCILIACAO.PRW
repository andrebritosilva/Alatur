#Include "Protheus.ch"

//Traz o nome do cliente para as conciliações.

User function HistConcil()

Local _cQuery 	:= ''
Local cMsg	 	:= '' 
Local _cAliasZ2	:= GetNextAlias()

BeginSQL Alias _cAliasZ2
   		SELECT G3P_RAZAO
   		FROM %table:G4C% G4C 
   		INNER JOIN %table:G3P% G3P ON
   		G4C_FILIAL = G3P.G3P_FILIAL
   		AND	G4C_NUMID = G3P.G3P_NUMID 
   		AND G4C.%NotDel%
		WHERE G3P_FILIAL = %Exp:G4C->G4C_FILIAL%
   		AND G3P_NUMID = %Exp:G4C->G4C_NUMID%
   		AND G3P.%NotDel%
   	EndSQL
 
cMsg:= (_cAliasZ2)->G3P_RAZAO

(_cAliasZ2)->(dbCloseArea()) 

Return(cMsg)