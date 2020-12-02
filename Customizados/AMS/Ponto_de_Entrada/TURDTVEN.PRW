#include 'protheus.ch'
#include 'parmtype.ch'

user function TurDtVen(cAliasAux) 
Local dtVenc :=	IIF( Empty( (cAliasAux)->E1_XDTPROR ), SToD((cAliasAux)->E1_VENCTO), SToD((cAliasAux)->E1_VENCREA) ) 
	
return dtVenc