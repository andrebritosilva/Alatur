#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"
#include "TOTVS.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LpT97     ºAutor  ³TOTVS..             º Data ³  06/2017    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Regras de LP pata T97.                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºParametros³                                                            º±±
1- Indica o tipo:
   D=Debito
   C=Credito
   V=Valor
   H=Historico
2- Forma de pagamento:
	1=Cartão do Cliente
	2=Cartão da Agencia
	3=Faturado                    
3- Grupo de produto
4- Classe
5- Motivo da Baixa	
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function LpT97(cTp,cFPag,cGrp,cClass,cMotBx)

//Chamada da função LP T97
//DEBITO	- u_LpT97("D",U_LpTur02('1'),ALLTRIM((cAliasQ1)->G3Q_GRPPRD),ALLTRIM((cAliasQ1)->G85_CLASS),ALLTRIM(SE5->E5_MOTBX))
//CREDITO	- u_LpT97("C",U_LpTur02('1'),ALLTRIM((cAliasQ1)->G3Q_GRPPRD),ALLTRIM((cAliasQ1)->G85_CLASS),ALLTRIM(SE5->E5_MOTBX))
//HISTOR	- u_LpT97("H",U_LpTur02('1'),ALLTRIM((cAliasQ1)->G3Q_GRPPRD),ALLTRIM((cAliasQ1)->G85_CLASS),ALLTRIM(SE5->E5_MOTBX))
//VALOR		- u_LpT97("V",U_LpTur02('1'),ALLTRIM((cAliasQ1)->G3Q_GRPPRD),ALLTRIM((cAliasQ1)->G85_CLASS),ALLTRIM(SE5->E5_MOTBX))

//Chamada da função para estorno LP T94
//DEBITO	- u_LpT97("C",U_LpTur02('1'),ALLTRIM((cAliasQ1)->G3Q_GRPPRD),ALLTRIM((cAliasQ1)->G85_CLASS),ALLTRIM(SE5->E5_MOTBX))                                                                                     
//CREDITO	- u_LpT97("D",U_LpTur02('1'),ALLTRIM((cAliasQ1)->G3Q_GRPPRD),ALLTRIM((cAliasQ1)->G85_CLASS),ALLTRIM(SE5->E5_MOTBX))                                                                                     
//HISTOR	- "Canc "+u_LpT97("H",U_LpTur02('1'),ALLTRIM((cAliasQ1)->G3Q_GRPPRD),ALLTRIM((cAliasQ1)->G85_CLASS),ALLTRIM(SE5->E5_MOTBX))                                                                                     
//VALOR		- u_LpT97("V",U_LpTur02('1'),ALLTRIM((cAliasQ1)->G3Q_GRPPRD),ALLTRIM((cAliasQ1)->G85_CLASS),ALLTRIM(SE5->E5_MOTBX))                                                                                     

//LPs traduzidas

//020 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                     
//021 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                     
//022 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                     
//023 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                     
//024 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                     
//025 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                     
//026 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                     

//027 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                     
//028 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                     
//029 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                                     
//030 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                                     
//031 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                                     
//032 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                                     
//033 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                                     
     
//034 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                     
//035 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                     
//036 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                                     
//037 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                                     
//038 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                                     
//039 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                                     
//040 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                                     

//041 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                     
//042 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                     
//043 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                     
//044 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                     
//045 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                     
//046 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                     
//047 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                     

//048 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                     
//049 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                     
//050 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                                     
//051 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                                     
//052 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                                     
//053 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                                     
//054 - IIF(U_LpTur02('1')=="1".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                                     

//055 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                     
//056 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                     
//057 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                     
//058 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                     
//059 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                     
//060 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                     
//061 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                     

//062 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                     
//063 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                     
//064 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                                     
//065 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                                     
//066 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                                     
//067 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                                     
//068 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                                     
     
//069 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                     
//070 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                     
//071 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                                     
//072 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                                     
//073 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                                     
//074 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                                     
//075 - IIF(U_LpTur02('1')=="2".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                                     

//076 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                    
//077 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                    
//078 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                    
//079 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                    
//080 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                    
//081 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                    
//082 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                    

//083 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                    
//084 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                    
//085 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)
//086 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                                    
//087 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                                    
//088 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                                    
//089 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C07".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                                    
        
//090 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                    
//091 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                    
//092 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                                    
//093 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                                    
//094 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                                    
//095 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                                    
//096 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                                    

//097 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"F01".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                    
//098 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"F01".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                    
//099 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"F01".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                                    
//100 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"F01".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                                    
//101 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"F01".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                                    
//102 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"F01".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                                    
//103 - IIF(U_LpTur02('1')=="3".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"F01".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                                    
     
//104 - IIF(U_LpTur02('1')=="1".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                    
//105 - IIF(U_LpTur02('1')=="1".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                    
//106 - IIF(U_LpTur02('1')=="1".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                    
//107 - IIF(U_LpTur02('1')=="1".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                    
//108 - IIF(U_LpTur02('1')=="1".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                    
//109 - IIF(U_LpTur02('1')=="1".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                    
//110 - IIF(U_LpTur02('1')=="1".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                    

//111 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                    
//112 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                    
//113 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                    
//114 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                    
//115 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                    
//116 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                    
//117 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                    

//118 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                    
//119 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                    
//120 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                                    
//121 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                                    
//122 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                                    
//123 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                                    
//124 - IIF(U_LpTur02('1')=="2".AND.!ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                                    
     
//125 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                     
//126 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                     
//127 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                     
//128 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                     
//129 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                     
//130 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                     
//131 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                     

//132 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                     
//133 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                     
//134 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                                     
//135 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                                     
//136 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                                     
//137 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                                     
//138 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"C09".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                                     
     
//139 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMR".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                    
//140 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMR".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                    
//141 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMR".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                                    

//142 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMRH/VRH".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                               
//143 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMRH/VRH".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                               
//144 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMRH/VRH".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                               
//145 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMRH/VRH".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                               

//146 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                              
//147 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                              
//148 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                              
//149 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                              
//150 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                              
//151 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                              
//152 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                              

//153 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$" ".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"362",nVlrApu,0)                                                                                                      
//154 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$" ".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"365",nVlrApu,0)                                                                                                      
//155 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$" ".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"367",nVlrApu,0)                                                                                                      
//156 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$" ".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"375",nVlrApu,0)                                                                                                      
//157 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$" ".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"376",nVlrApu,0)                                                                                                      
//158 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$" ".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"377",nVlrApu,0)                                                                                                      
//159 - IIF(U_LpTur02('1')=="3".AND.ALLTRIM((cAliasQ1)->G3Q_GRPPRD)$" ".AND.ALLTRIM((cAliasQ1)->G85_CLASS)$"V01".AND.ALLTRIM(SE5->E5_MOTBX)$"363",nVlrApu,0)                                                                                                      

If !cMotBx $ "362/365/367/375/376/377/363"

	If cTp $ "D/C/H"
		cRet := ""
	Else
		cRet := 0
	EndIF
	
	Return(cRet)	
	
EndIf

If cFPag == '3'
	If cGrp $ "AE"
		If cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                               
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                               
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                  
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3 FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4 FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5 FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                                
				EndIf
			EndIf
		ElseIf cClass$"C07"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NCO IDENTIFICADO TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3 TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4 TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5 TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                            
				EndIf
			EndIf
		ElseIf cClass$"C09"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                            
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                            
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11204003'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NCO IDENTIFICADO MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                               
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3 MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                      
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4 MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                      
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5 MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                      
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                             
				EndIf
			EndIf
		EndIf     
	ElseIf !cGrp $ "AE/VI/VMRH/VRH/VMTE/VMAE/VINC/FTJ"
		If cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO  FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                          
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO  FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                          
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO  FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3  FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4  FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5  FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA  FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                           
				EndIf
			EndIf
		ElseIf cClass$"C07"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO  TAXA DU TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                      
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO  TAXA DU TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                      
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO  TAXA DU TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3  TAXA DU TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4  TAXA DU TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5  TAXA DU TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA  TAXA DU TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                       
				EndIf
			EndIf
		ElseIf cClass$"C09"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO  MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                       
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO  MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                       
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11204003'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NCO IDENTIFICADO  MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3  MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4  MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5  MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA  MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                        
				EndIf
			EndIf
		ElseIf cClass$"F01"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO  COMISSAO TERRESTRE FATURADO NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO  COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11204003'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NCO IDENTIFICADO  COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                        
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3  COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                               
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4  COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                               
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5  COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                               
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA  COMISSAO TERRESTRE FATURADO NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                     
				EndIf
			EndIf
		EndIf
	ElseIf cGrp $ "VI"
		If cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO  FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                            
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO  FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                            
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NCO IDENTIFICADO  FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                               
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3  FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                      
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4  FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                      
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5  FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                      
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA  FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                             
				EndIf
			EndIf
		ElseIf cClass$"C09"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO  MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO  MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11204003'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NCO IDENTIFICADO  MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                            
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3  MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                   
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4  MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                   
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5  MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                   
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA  MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                          
				EndIf
			EndIf
		EndIf
	ElseIf cGrp $ "VMR"
		If cClass$"V01"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO CONF RV VERBA DE RH NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                              
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO CONF RV VERBA DE RH NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                              
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11204003'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO CONF RV VERBA DE RH NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                 
				EndIf
			EndIf
		EndIf
	ElseIf cGrp $ "VMRH/VRH"
		If cClass$"V01"
			If SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3 CONF RV VERBA DE RH NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                        
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4 CONF RV VERBA DE RH NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                        
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5 CONF RV VERBA DE RH NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                        
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA CONF RV VERBA DE RH NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                               
				EndIf
			EndIf
		EndIf
	ElseIf cGrp $ "VMTE/VMAE"
		If cClass$"V01"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO CONF RV VERBA DE MARKETING NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                       
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO CONF RV VERBA DE MARKETING NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                       
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11204003'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO CONF RV VERBA DE MARKETING NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3 CONF RV VERBA DE MARKETING NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4 CONF RV VERBA DE MARKETING NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5 CONF RV VERBA DE MARKETING NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA CONF RV VERBA DE MARKETING NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                        
				EndIf
			EndIf
		EndIf
	ElseIf cGrp $ " "
		If cClass$"V01"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO CONF RV VERBA DE INCENTIVO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                       
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO CONF RV VERBA DE INCENTIVO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                       
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11204003'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO CONF RV VERBA DE INCENTIVO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3 CONF RV VERBA DE INCENTIVO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4 CONF RV VERBA DE INCENTIVO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5 CONF RV VERBA DE INCENTIVO NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA CONF RV VERBA DE INCENTIVO NR."+ALLTRIM(ALLTRIM((cAliasQ1)->G48_NUMID))+" FAT "+ALLTRIM((cAliasQ2)->G4C_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                          
				EndIf
			EndIf
		EndIf
	EndIf      
ElseIf cFPag == '1'	
	If cGrp $ "AE"
		If cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                            
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3 FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                   
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4 FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                   
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5 FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                   
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ1)->G85_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                          
				EndIf
			EndIf
		ElseIf cClass$"C07"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO TAXA DU AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO TAXA DU AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO TAXA DU AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                        
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3 TAXA DU AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                               
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4 TAXA DU AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                               
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5 TAXA DU AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                               
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA TAXA DU AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                      
				EndIf
			EndIf
		EndIf     
	ElseIf !cGrp $ "AE/VI/VMRH/VRH/VMTE/VMAE/VINC/FTJ"
		If cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO  FEE TERRESTRE CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO  FEE TERRESTRE CARTAO CLIENTE NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                   
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO  FEE TERRESTRE CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3  FEE TERRESTRE CARTAO CLIENTE NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                             
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4  FEE TERRESTRE CARTAO CLIENTE NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                             
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5  FEE TERRESTRE CARTAO CLIENTE NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                             
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA  FEE TERRESTRE CARTAO CLIENTE NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                    
				EndIf
			EndIf
		EndIf
	EndIf    
ElseIf cFPag == '2'
	If cGrp $ "AE"
		If cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                            
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3 FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                   
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4 FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                   
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5 FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                   
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                          
				EndIf
			EndIf
		ElseIf cClass$"C07"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO TAXA DU CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO TAXA DU CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO TAXA DU CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3 TAXA DU CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4 TAXA DU CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5 TAXA DU CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '21101025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA TAXA DU CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                            
				EndIf
			EndIf
		ElseIf cClass$"C09"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO  MARKUP CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO  MARKUP CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11204003'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NAO IDENTIFICADO MARKUP CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                               
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3  MARKUP CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4  MARKUP CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5  MARKUP CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA  MARKUP CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                             
				EndIf
			EndIf
		EndIf
	ElseIf !cGrp $ "AE/VI/VMRH/VRH/VMTE/VMAE/VINC/FTJ"
		If cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO  FEE TERRESTRE CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO  FEE TERRESTRE CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NCO IDENTIFICADO  FEE TERRESTRE CARTAO CLIENTE NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                      
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3  FEE TERRESTRE CARTAO CLIENTE NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                             
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4  FEE TERRESTRE CARTAO CLIENTE NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                             
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5  FEE TERRESTRE CARTAO CLIENTE NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                             
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201040'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA  FEE TERRESTRE CARTAO CLIENTE NR. "+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                    
				EndIf
			EndIf
		ElseIf cClass$"C09"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR AUTORIZACAO DA DIRECAO  MARKUP TERRESTRE CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR COMPENSACAO  MARKUP TERRESTRE CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11204003'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA DE TITULOS POR CREDITO NCO IDENTIFICADO  MARKUP TERRESTRE CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                    
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 3  MARKUP TERRESTRE CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 4  MARKUP TERRESTRE CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA ALATUR OPER CC 5  MARKUP TERRESTRE CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BAIXA POR MOEDA  MARKUP TERRESTRE CARTAO CLIENTE NR."+ALLTRIM((cAliasQ1)->G48_NUMID)+" FAT "+(cAliasQ2)->G4C_NUMFAT+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                  
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return(cRet)