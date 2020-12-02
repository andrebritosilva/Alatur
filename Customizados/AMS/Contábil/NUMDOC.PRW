#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"

// #########################################################################################
// Projeto: 12.6
// Modulo : SIGATUR
// Fonte  : Tratativa lp
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 01/03/17 | Totvs	    | Tratativa Lançamento Padrão SIGATUR
// #########################################################################################

User function NumDoc()
Local cRet:='' 
cRet := SE5->E5_NUMERO
M->CT2_XNUMDO:= SE5->E5_NUMERO
return(M->CT2_XNUMDO)
