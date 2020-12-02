#Include "Totvs.ch"

Function UPDG9J()

Local cAliasG9J := GetNextAlias()

BeginSql Alias cAliasG9J 

	SELECT G9I_CODIGO, G9J_ITEM, G84_FILIAL 
 	FROM G84010 G84 
 	INNER JOIN G9I010 G9I ON G9I_CLIENT = G84_CLIENT AND G9I_LOJA = G84_LOJA AND G9I.D_E_L_E_T_ = ''
 	INNER JOIN G9J010 G9J ON G9J_CODIGO = G9I_CODIGO AND G9J.D_E_L_E_T_ = ''
 	WHERE G84_PREFIX = G9J_PREFIX AND 
		  G84_NUMFAT = G9J_FATURA AND 
	  	  G84.D_E_L_E_T_ = ' '

EndSql

If (cAliasG9J)->(!Eof())
	DbSelectArea('G9J')
	G9J->(DbSetOrder(1))	// G9J_FILIAL+G9J_CODIGO+G9J_ITEM
	While (cAliasG9J)->(!Eof())
		If G9J->(DbSeek(xFilial('G9J') + (cAliasG9J)->G9I_CODIGO + (cAliasG9J)->G9J_ITEM))
			RecLock('G9J', .F.)
			G9J->G9J_FILFAT := (cAliasG9J)->G84_FILIAL
			G9J->(MsUnLock())
		EndIf		
		(cAliasG9J)->(DbSkip())
	EndDo
	G9J->(DbCloseArea())
	MsgInfo( 'Processo finalizado.' )
EndIf

(cAliasG9J)->(DbCloseArea())

Return