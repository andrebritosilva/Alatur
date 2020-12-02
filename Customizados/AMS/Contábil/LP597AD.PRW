#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"

// #########################################################################################
// Projeto: 11.90
// Modulo : SIGATUR
// Fonte  : Tratativa lp
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 20/06/17 | Totvs| Tratativa Lançamento Padrão Descontos e Multa/Juros COmpensação a Pagar
// #########################################################################################

User Function LP597AD(nOpc)

Local nRet 	   := 0
Local _cFilial := SE5->E5_FILIAL
Local _cChave  := SE5->E5_DOCUMEN
Local aArea    := GetArea()
Local aAreaSe2 := SE2->(GetArea())
Local aAreaSe5 := SE5->(GetArea())
Local cAlias   := GetNextAlias()

If nOpc = '1' //Decrescimo
	If SE5->E5_VLDECRE = 0
		If !Empty(_cChave)
			
			BeginSQL Alias cAlias
				SELECT E5_PREFIXO, E5_NUMERO, E5_CLIFOR, E5_LOJA, E5_VLDECRE
				FROM %table:SE5% SE5
				WHERE E5_FILIAL = %Exp:_cFilial%
				AND E5_PREFIXO 	= %Exp:SUBSTR(_cChave,1,3)%
				AND E5_NUMERO 	= %Exp:SUBSTR(_cChave,4,9)%
				AND E5_PARCELA 	= %Exp:SUBSTR(_cChave,13,1)%
				AND E5_TIPO 	= %Exp:SUBSTR(_cChave,14,3)%
				AND E5_CLIFOR 	= %Exp:SUBSTR(_cChave,17,9)%
				AND E5_LOJA   	= %Exp:SUBSTR(_cChave,26,4)%
				AND E5_TIPODOC  <> 'ES'
				AND SE5.%NotDel%
				Order By E5_SEQ DESC
			EndSQL
			
			nRet := (cAlias)->E5_VLDECRE
			
		EndIf
	Else
		nRet := SE5->E5_VLDECRE
	EndIf
ElseIF nOpc = '2' //Acrescimo
	If SE5->E5_VLACRES = 0
		If !Empty(_cChave)
			
			BeginSQL Alias cAlias
				SELECT E5_PREFIXO, E5_NUMERO, E5_CLIFOR, E5_LOJA, E5_VLACRES
				FROM %table:SE5% SE5
				WHERE E5_FILIAL = %Exp:_cFilial%
				AND E5_PREFIXO 	= %Exp:SUBSTR(_cChave,1,3)%
				AND E5_NUMERO 	= %Exp:SUBSTR(_cChave,4,9)%
				AND E5_PARCELA 	= %Exp:SUBSTR(_cChave,13,1)%
				AND E5_TIPO 	= %Exp:SUBSTR(_cChave,14,3)%
				AND E5_CLIFOR 	= %Exp:SUBSTR(_cChave,17,9)%
				AND E5_LOJA   	= %Exp:SUBSTR(_cChave,26,4)%
				AND E5_TIPODOC  <> 'ES'
				AND SE5.%NotDel%
				Order By E5_SEQ DESC
			EndSQL
			
			nRet := (cAlias)->E5_VLACRES
			
		EndIf
	Else
		nRet := SE5->E5_VLACRES
	EndIf
EndIF                        

If Select((cAlias)) > 0
	(cAlias)->(DbCloseArea())
EndIf

RestArea(aAreaSe5)
RestArea(aAreaSe2)
RestArea(aArea)

Return(nRet)