#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE 'PROTHEUS.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURR013PRT
Função para impressão de Fatura campo especcifico da Conciliaçao Terrestre
@author    Totvs
@version   1.00
@since     31/01/2017
/*/
//------------------------------------------------------------------------------------------

User Function TURR013PRT()

Local _cID       := ''
Local _cAliasG4C := GetNextAlias()
Local _cAliasG8C := GetArea("G8C")
Local _oPrint    := PARAMIXB[1]
Local _nLin      := PARAMIXB[2]
Local _oFont11   := TFontEx():New(_oPrint,"Courier",11, 11,.T.,.T.,.F.)
Local _oFont11N  := TFontEx():New(_oPrint,"Arial",11, 11,.T.,.T.,.F.)

BeginSQL Alias _cAliasG4C
	
	SELECT G4C_FILIAL, G4C_CONORI, G4C_NUMFAT, G4C_PREFIX
	FROM %Table:G4C% G4C
	WHERE
	G4C_FILIAL = %Exp: G85->G85_FILREF%
	AND G4C_PREFIX = %Exp:G85->G85_PREFIX%
	AND G4C_NUMFAT = %Exp:G85->G85_NUMFAT%
	AND G4C_NUMID = %Exp:G85->G85_REGVEN%
	AND G4C_IDITEM = %Exp:G85->G85_ITVEND%
	AND G4C_NUMSEQ = %Exp:G85->G85_SEQIV%
	AND G4C_CONINU = '' 
	AND G4C_CONORI <> ''
	AND G4C.%NotDel%                     
	
EndSQL

(_cAliasG4C)->(dbGoTop())

DbSelectArea("G8C")
DbSetOrder(1)
If G8C->(MsSeek((_cAliasG4C)->(G4C_FILIAL+G4C_CONORI)))
	_cID := G8C->G8C_XEDOC
EndIf

If _cID <> ''
	_oPrint:Say( _nLin-0025, 0080, "ID.: "       ,_oFont11N:oFont ) //"ID."
	_oPrint:Say( _nLin-0025, 0180, OEMTOANSI(_cID),_oFont11:oFont ) //Conteudo do Campo
EndIF

(_cAliasG4C)->(DbCloseArea())   
RestArea(_cAliasG8C)    

Return nil