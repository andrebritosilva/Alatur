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
// 16/01/17 | FABIO	        | RESULTADO PARA VALOR DO LP 530
// #########################################################################################

user function _LP530(_NLP530)
_NLP530:=SE5->E5_VALOR+SE5->E5_VRETPIS+SE5->E5_VRETCOF+SE5->E5_VRETCSL+SE5->E5_VLDESCO-SE5->E5_VLMULTA-SE5->E5_VLCORRE-SE5->E5_VLJUROS


return(_NLP530)
