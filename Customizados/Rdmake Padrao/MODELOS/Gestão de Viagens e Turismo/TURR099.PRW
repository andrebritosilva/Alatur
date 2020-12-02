#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "MSOLE.CH" 


/*/{Protheus.doc} TURR099
(long_description)
@type function
@author osmar.junior
@since 06/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function TURR099()

If Pergunte("TURR099",.t.)
	TURETIQQRY()
EndIf

Return()


/*/{Protheus.doc} TURETIQQRY
(long_description)
@type function
@author osmar.junior
@since 06/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function TURETIQQRY()
Local cAliasRp := GetNextAlias()
Local cAliasQtd := GetNextAlias()
Local oWord 	:= Nil
Local nVar		:= 0
Local nQtd		:= 0


	BeginSql alias cAliasQtd
			
		SELECT Count(*) Quantidade		
		FROM %table:G9I% G9I, %table:SA1% SA1			
		WHERE 	G9I_FILIAL = %xfilial:G9I% AND G9I.%notDel% AND
				A1_FILIAL  = %xfilial:SA1% AND SA1.%notDel% AND
				G9I_CLIENT = A1_COD    AND
				G9I_LOJA   = A1_LOJA   AND 
				G9I_CODIGO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
				G9I_CLIENT BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR05% AND
				G9I_LOJA   BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR06% 	          
		
			
	EndSql

	If (cAliasQtd)->(!Eof())
		nQtd :=(cAliasQtd)->Quantidade
	EndIf

	
	BeginSql alias cAliasRp
			
		SELECT G9I_FILIAL, G9I_CODIGO, G9I_EMISS, G9I_CLIENT, G9I_LOJA ,    
				A1_FILIAL , A1_COD    , A1_LOJA  , A1_NOME   , A1_END   , 
				A1_BAIRRO , A1_EST, A1_MUN, A1_CEP, A1_CONTATO			
		FROM %table:G9I% G9I, %table:SA1% SA1			
		WHERE 	G9I_FILIAL = %xfilial:G9I% AND G9I.%notDel% AND
				A1_FILIAL  = %xfilial:SA1% AND SA1.%notDel% AND
				G9I_CLIENT = A1_COD    AND
				G9I_LOJA   = A1_LOJA   AND 
				G9I_CODIGO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
				G9I_CLIENT BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR05% AND
				G9I_LOJA   BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR06% 	            
		ORDER BY G9I_FILIAL, G9I_CODIGO
			
	EndSql
	
	If (cAliasRp)->(!Eof())
	
		While (cAliasRp)->(!Eof())
			nVar++
			ImpEtiquet(nVar,oWord,cAliasRp,nQtd)		 
			(cAliasRp)->(dbSkip())
		EndDo
		
		FechaWord(oWord)
		
	Else
		Alert('Sem protocolos a serem impressos.')
	
	EndIF


Return()


/*/{Protheus.doc} ImpEtiquet
(long_description)
@type function
@author osmar.junior
@since 07/12/2016
@version 1.0
@param nVar, numérico, (Descrição do parâmetro)
@param oWord, objeto, (Descrição do parâmetro)
@param cAliasRp, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function ImpEtiquet(nVar,oWord,cAliasRp,nQtd)
Local cDirDoc := 'C:\TOTVS\EtiquetaProt2.dot'
Local cCodigo	:=  (cAliasRp)->G9I_CODIGO
Local cNome	:= (cAliasRp)->(/*A1_COD+"/"+A1_LOJA+"-"+*/allTrim(A1_NOME))
Local cEnder	:= (cAliasRp)->(AllTrim(A1_END))
Local cBairro	:= (cAliasRp)->(AllTrim(A1_BAIRRO))
Local cMunic	:= (cAliasRp)->(AllTrim(A1_MUN))
Local cEstado	:= (cAliasRp)->(AllTrim(A1_EST))+ " - "
Local cCEP		:= (cAliasRp)->(AllTrim(A1_CEP))
Local cSep		:= "|"
Local cAC		:= ''

	If nVar == 1
		oWord := OLE_CreateLink()
		BeginMsOle()
		OLE_SetPropertie( oWord, oleWdVisible, .T.) //indica que o word deve estar visivel
		OLE_NewFile(oWord, cDirDoc ) 
		OLE_SetDocumentVar(oWord,"nTotalEtiquetas",nQtd)
		OLE_ExecuteMacro(oWord,"Etiqueta")
	EndIf
	
	If (cAliasRp)->(!Eof())
		
		//OLE_SetDocumentVar(oWord,"G9I_CODIGO_"+AllTrim(STR(nVar)),		cCodigo)  
		OLE_SetDocumentVar(oWord,"A1_COD_"+AllTrim(STR(nVar)),			cNome) 
		OLE_SetDocumentVar(oWord,"A1_END_"+AllTrim(STR(nVar)),			cEnder) 
		OLE_SetDocumentVar(oWord,"A1_BAIRRO_"+AllTrim(STR(nVar)),		cBairro) 
		OLE_SetDocumentVar(oWord,"A1_MUN_"+AllTrim(STR(nVar)),			cMunic + " - ") 
		OLE_SetDocumentVar(oWord,"A1_EST_"+AllTrim(STR(nVar)),			cEstado)
		OLE_SetDocumentVar(oWord,"A1_CEP_"+AllTrim(STR(nVar)),			cCEP)
		OLE_SetDocumentVar(oWord,"AC_"+AllTrim(STR(nVar)),				"A/C "+ContatoAC(cAliasRp)) 
	EndIf

Return



/*/{Protheus.doc} FechaWord
(long_description)
@type function
@author osmar.junior
@since 08/12/2016
@version 1.0
@param oWord, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function FechaWord(oWord)

	OLE_UpdateFields(oWord) 				
	EndMsOle()
	  
	If MsgYesNo("Fecha o Word?")
		OLE_CloseFile( oWord )
		OLE_CloseLink( oWord )
	Endif

Return

/*/{Protheus.doc} ContatoAC
(long_description)
@type function
@author osmar.junior
@since 04/01/2017
@version 1.0
@param cAliasRp, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function ContatoAC(cAliasRp)
Local cRet			:= ''
Local cCodigo		:=  (cAliasRp)->G9I_CODIGO
Local cAliasFat 	:= GetNextAlias()
Local cCodAux		:= ''
Local lSolic		:= .F.
Local lEntid		:= .F.

	BeginSql alias cAliasFat			

	SELECT DISTINCT G9J_CODIGO,G84_CLIENT,G84_LOJA,G85_TPENT,G85_ITENT,G85_SOLIC,G86_PREFIX,G86_NUMFAT,G86_TPAGRU,G86_CODEAD
	FROM %table:G9J% G9J INNER JOIN %table:G84% G84 ON 
	G9J.G9J_FATURA=G84.G84_NUMFAT AND 
	G9J.G9J_PREFIX=G84.G84_PREFIX 
	INNER JOIN %table:G85% G85 ON
	G9J_PREFIX = G85_PREFIX AND
	G9J_FATURA = G85_NUMFAT
	LEFT JOIN %table:G86% G86 ON 
	G85_NUMFAT = G86_NUMFAT AND
	G85_PREFIX = G86_PREFIX
	WHERE 	
	G84.%notDel% AND
	G85.%notDel% AND	
	G9J.%notDel% AND
	G9J_CODIGO = %Exp:cCodigo%
	ORDER BY G86_TPAGRU DESC 

	EndSql

	While (cAliasFat)->(!Eof())
		If ((cAliasFat)->G86_TPAGRU == '2' .AND. !Empty( (cAliasFat)->G85_SOLIC )) //Solicitante
			cCodAux := (cAliasFat)->G85_SOLIC
			cRet := AllTrim(Posicione("SU5",1,xFilial("SU5")+cCodAux,"U5_CONTAT"))
			lSolic		:= .T.
		ElseIf !lSolic
			cCodAux := PADR((cAliasFat)->G84_CLIENT + (cAliasFat)->G84_LOJA,TAMSX3('AC8_CODENT')[1])
			cCodAux := Posicione("AC8",2,xFilial("AC8")+'SA1'+xFilial("AC8")+cCodAux,"AC8_CODCON")
			cRet := 	AllTrim(Posicione("SU5",1,xFilial("SU5")+cCodAux,"U5_CONTAT"))			
		EndIf
		
		(cAliasFat)->(dbSkip())
	EndDo

Return cRet