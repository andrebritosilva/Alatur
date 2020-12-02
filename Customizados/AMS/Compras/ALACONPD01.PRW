#include "protheus.ch"
#include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ALACONPD01  ºAutor  ³J. Augusto C. Molla Data ³  22/06/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para ser utilizada na consulta padrão de cod. de    º±±
±±ºDesc.     ³ municipio em cadastros de clientes e fornecedores.         º±±
±±º          ³ Quando UF=EX olha para tabelas G5S no cadastro de cidades  º±±
±±º          ³ do Turismo, quando difente olha para tabela padrão CC2     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Alatur                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User function ALACONPD01(_ConsultaA, _RetornoA,  _ConsultaB, _RetornoB)

//local cRetorno := ''
Static cRetorno := ''

If ISINCALLSTACK("MATA020")
	If M->A2_EST <> "EX"
		cRetorno := ConPad1(,,,_ConsultaA,_RetornoA,,.F.)
	Else
		cRetorno := ConPad1(,,,_ConsultaB,_RetornoB,,.F.)
	Endif
Endif

If ISINCALLSTACK("MATA030")
	If M->A1_EST <> "EX"
		cRetorno := ConPad1(,,,_ConsultaA,_RetornoA,,.F.)
	Else
		cRetorno := ConPad1(,,,_ConsultaB,_RetornoB,,.F.)
	Endif
Endif

Return cRetorno

user function AlaGetRet() 

	If ISINCALLSTACK("MATA020")
		If M->A2_EST <> "EX"
			cRetorno := CC2->CC2_CODMUN
		Else
			cRetorno := G5S->G5S_CODIGO
		Endif
	Endif

return cRetorno		// colocar no sxb no lugar do cretorno