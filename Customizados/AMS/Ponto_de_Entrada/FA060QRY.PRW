#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RWMAKE.CH"

/*- -------------------------------------------------------------------------------
{Protheus.doc} 	FA060QRY
TODO 			CONDIÇÃO SQL PARA FILTRO DE TITULOS NO BORDERÔ DO CONTAS A RECEBER
@author 		Carlos Eduardo Saturnino - Bell Consulting
@since 			26/09/2017
@version 		1.0
@return $		{return}, ${return_description}
@type 			user function
----------------------------------------------------------------------------------*/
User Function FA060QRY()
	
Local _cFilt := " "
Local cAgencia 	:= ParamIxb[1]
Local cConta 	:= ParamIxb[2]


IF MsgYesNo("Deseja visualizar apenas títulos que possuam boleto emitido ? ") 
	_cFilt := " E1_NUMBCO <> '' "
	//Fev/2018 - Tratamento inclui para filtrar os titulos conforme parametros bancarios do bordero.
	_cFilt += " AND	E1_AGEDEP = '" + cAgencia + " ' "
	_cFilt += " AND	E1_CONTA = '" + cConta + " ' "	
Else
	//Return(Nil)
	//Fev/2018 - Tratamento inclui para filtrar os titulos conforme parametros bancarios do bordero.
	_cFilt += " E1_AGEDEP = '" + cAgencia + " ' "	
	_cFilt += " AND	E1_CONTA = '" + cConta + " ' "	
Endif
    

Return(_cFilt)