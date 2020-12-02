#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LP596HIST()
Contabilização do Historico da Compensação Contas a Receber aberta pela G4C-Item Financeiro
@author Ronaldo Bicudo
@since 30/06/2017
@version 12.1.006
@return cRet
/*/
//-------------------------------------------------------------------

User Function LP596HIST(cOpc)
         
Local cRet := ''        

If cOpc = '1' //Titulo de PA         
	If ALLTRIM(SE5->E5_TIPO) = 'RA'
		cRet := ALLTRIM(SE5->E5_NUMERO)
	ElseIf ALLTRIM(SE1->E1_TIPO) = 'RA'
		cRet := ALLTRIM(SE1->E1_NUM)
	ElseIf SUBSTR(SE5->E5_DOCUMEN,14,2) = 'RA'
		cRet := SUBSTR(SE5->E5_DOCUMEN,4,9)
	Else
		cRet := ALLTRIM(SE5->E5_NUMERO) 
	EndIf	
ElseIf cOpc = '2' //Numero Fatura
	If ALLTRIM(SE5->E5_PREFIXO)='APU'
		cRet := ALLTRIM(SE5->E5_NUMERO)
	ElseIf ALLTRIM(SE1->E1_PREFIXO)='APU'
		cRet := ALLTRIM(SE1->E1_NUM)
	ElseIf SUBSTR(SE5->E5_DOCUMEN,1,3) = 'APU'
		cRet := SUBSTR(SE5->E5_DOCUMEN,4,9)
	Else
		cRet := ALLTRIM(SE5->E5_NUMERO) 
	EndIf            
EndIF           

Return (cRet)