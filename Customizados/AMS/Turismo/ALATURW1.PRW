#include "Protheus.ch"                 
#include "topconn.ch"      
#include "TBICONN.CH"


// #########################################################################################
// Projeto: 12.001.06
// Modulo : Turismo
// Fonte  : ALATURW1.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 04/10/16 | Totvs	            | Atualiza Naturezas G4C e G9K
// #########################################################################################

User Function ALATURW1()

Local _cQuery := ""
//Local _cEol   := Chr(13) + Chr(10)

PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01SP0005'

//Atualiza G4C        
//_cQuery := "Begin "
//_cQuery += _cEol
//1-Quando tiver somente a venda para o cliente aéreo
_cQuery := "UPDATE G4C010 "
_cQuery += "SET G4C_NATUR = '100100' "
_cQuery += "WHERE G4C_CLIFOR = '1' "
_cQuery += "AND G4C_GRPPRD = 'AE' "
_cQuery += "AND G4C_CLASS = '' "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol    
  
TCSQLEXEC(_cQuery)
_cQuery := ''

//2-Quando tiver receita de fornecedores aéreo
_cQuery := "UPDATE G4C010 "
_cQuery += "SET G4C_NATUR = '200100' "
_cQuery += "WHERE G4C_CLIFOR = '2' "
_cQuery += "AND G4C_GRPPRD = 'AE' "
_cQuery += "AND G4C_CLASS = '' "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol                 
                      
TCSQLEXEC(_cQuery)
_cQuery := ''

//3-Qualquer acordo de cliente
_cQuery := "UPDATE G4C010 "
_cQuery += "SET G4C_NATUR = '100120' "
_cQuery += "WHERE G4C_CLIFOR = '1' "
_cQuery += "AND G4C_CLASS <> '' "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol

TCSQLEXEC(_cQuery)
_cQuery := ''

//4-Quando tiver somente a venda para o cliente terrestre
_cQuery := "UPDATE G4C010 "
_cQuery += "SET G4C_NATUR = '100200' "
_cQuery += "WHERE G4C_CLIFOR = '1' "
_cQuery += "AND G4C_GRPPRD <> 'AE' "
_cQuery += "AND G4C_CLASS = '' "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol             

TCSQLEXEC(_cQuery)
_cQuery := ''

//5-Quando tiver receita de fornecedores terrestre
_cQuery := "UPDATE G4C010 "
_cQuery += "SET G4C_NATUR = '200110' "
_cQuery += "WHERE G4C_CLIFOR = '2' "
_cQuery += "AND G4C_GRPPRD <> 'AE' "
_cQuery += "AND G4C_CLASS = '' "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol                 

TCSQLEXEC(_cQuery)
_cQuery := ''

//6-Qualquer receita de acordo de fornecedores comissão e incentivo (aéreo e terrestre) = 100101	
_cQuery := "UPDATE G4C010 "
_cQuery += "SET G4C_NATUR = '100101' "
_cQuery += "WHERE G4C_CLIFOR = '2' "
_cQuery += "AND (G4C_CLASS = 'F01' OR G4C_CLASS = 'F02') "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol                 
//_cQuery += "end"

TCSQLEXEC(_cQuery)
_cQuery := ''

//Atualiza G9K
//_cQuery := "Begin "
//_cQuery += _cEol
//1-Apuração de Clientes
_cQuery := "UPDATE G9K010 "
_cQuery += "SET G9K_NATURE = '100120' "
_cQuery += "WHERE G9K_CLIFOR = '1' "
_cQuery += "AND G9K_MODO = '2' "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol
  
TCSQLEXEC(_cQuery)
_cQuery := ''

//2-Apuração de Fornecedores
_cQuery := "UPDATE G9K010 "
_cQuery += "SET G9K_NATURE = '100101' "
_cQuery += "WHERE G9K_CLIFOR = '2' "
_cQuery += "AND G9K_MODO = '2' "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol                 

TCSQLEXEC(_cQuery)
_cQuery := ''

//3-Vendas Cliente Aereo
_cQuery := "UPDATE G9K010 "
_cQuery += "SET G9K_NATURE = '100100' " 
_cQuery += "FROM G9K010 G9K "
_cQuery += "JOIN G4C010 G4C " 
_cQuery += "ON(G4C_NUMID = G9K_NUMID AND G4C_GRPPRD = 'AE' AND G4C.D_E_L_E_T_ <> '*') "
_cQuery += "WHERE G9K_CLIFOR = '1' "
_cQuery += "AND G9K_MODO <> '2' "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol           
  
TCSQLEXEC(_cQuery)
_cQuery := ''
                    
//4-Vendas Cliente Terrestre
_cQuery := "UPDATE G9K010 "
_cQuery += "SET G9K_NATURE = '100200' " 
_cQuery += "FROM G9K010 G9K "
_cQuery += "JOIN G4C010 G4C " 
_cQuery += "ON(G4C_NUMID = G9K_NUMID AND G4C_GRPPRD <> 'AE' AND G4C.D_E_L_E_T_ <> '*') "
_cQuery += "WHERE G9K_CLIFOR = '1' "
_cQuery += "AND G9K_MODO <> '2' "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol           
  
TCSQLEXEC(_cQuery)
_cQuery := ''

//5-Vendas Fornecedores Aereo
_cQuery := "UPDATE G9K010 "
_cQuery += "SET G9K_NATURE = '200100' " 
_cQuery += "FROM G9K010 G9K "
_cQuery += "JOIN G4C010 G4C " 
_cQuery += "ON(G4C_NUMID = G9K_NUMID AND G4C_GRPPRD = 'AE' AND G4C.D_E_L_E_T_ <> '*') "
_cQuery += "WHERE G9K_CLIFOR = '2' "
_cQuery += "AND G9K_MODO <> '2' "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol           
  
TCSQLEXEC(_cQuery)
_cQuery := ''
    
//6-Vendas Fornecedores Terrestre
_cQuery := "UPDATE G9K010 "
_cQuery += "SET G9K_NATURE = '200110' " 
_cQuery += "FROM G9K010 G9K "
_cQuery += "JOIN G4C010 G4C " 
_cQuery += "ON(G4C_NUMID = G9K_NUMID AND G4C_GRPPRD <> 'AE' AND G4C.D_E_L_E_T_ <> '*') "
_cQuery += "WHERE G9K_CLIFOR = '2' "
_cQuery += "AND G9K_MODO <> '2' "
_cQuery += "AND D_E_L_E_T_ <> '*'; "
//_cQuery += _cEol           
//_cQuery += "end"

TCSQLEXEC(_cQuery)

RESET ENVIRONMENT	 
aParam  := aSize(aParam,0) 
_cQuery := ''
  
//AVISO( "Atenção...", "Finalizado!", {"Ok"} )

Return()