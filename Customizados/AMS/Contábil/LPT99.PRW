
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LpT99     ºAutor  ³TOTVS..             º Data ³  06/2017    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Regras de LP pata T99.                                      º±±
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

User Function LpT99(cTp,cFPag,cGrp,cClass,cMotBx)

//Chamada da função
//u_LpT99("V",U_LpTur02(),ALLTRIM((cAliasQ2)->G85_GRPPRD),(cAliasQ2)->G85_CLASS,SE5->E5_MOTBX)

//LPs traduzidas
//033 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                          
//034 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                          
//035 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                          
//036 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                          
//037 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                          
//038 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                          
//039 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                          

//040 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                  
//041 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                  
//042 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                  
//043 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                  
//044 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                  
//045 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                  
//046 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                  

//047 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                  
//048 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                  
//049 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                  
//050 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                  
//051 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                  
//052 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                  
//053 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                  

//054 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                  
//055 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                  
//056 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                  
//057 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                  
//058 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                  
//059 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                  
//060 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                  

//061 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                  
//062 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                  
//063 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                  
//064 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                  
//065 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                  
//066 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                  
//067 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                  

///////////////////////////////

//068 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                  
//069 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                  
//070 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                  
//071 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                  
//072 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                  
//073 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                  
//074 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                  

//075 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                  
//076 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                  
//077 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                  
//078 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                  
//079 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                  
//080 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                  
//081 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                         

//082 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                  
//083 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                  
//084 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                  
//085 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                  
//086 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                  
//087 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                  
//088 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                  

//////////////////////////

//089 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                           
//090 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                          
//091 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                          
//092 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                          
//093 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                          
//094 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                          
//095 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                          

//096 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                  
//097 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                  
//098 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                  
//099 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                  
//100 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                  
//101 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                  
//102 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                  

//103 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                  
//104 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                  
//105 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                  
//106 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                  
//107 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                  
//108 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                  
//109 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C07".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                  

//110 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                  
//111 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                  
//112 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                  
//113 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                  
//114 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                  
//115 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                  
//116 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                  

//117 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                  
//118 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                  
//119 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                  
//120 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                  
//121 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                  
//122 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                  
//123 - IIF(U_LpTur02()=="2".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                  

//O bloco abaixo do 124 a 130 foi traduzido no fonte PLT99 igual ao 131 a 137 que esta no LPT992
//124 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                         
//125 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                         
//126 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                         
//127 - IIF(U_LpTur02()=="3".AND.!ALLTRIM(G85->G85_GRPPRD)$"AE".AND.EMPTY(G85->G85_CLASS).AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                                       
//128 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                         
//129 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                         
//130 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                         

//131 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                         
//132 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                         
//133 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                         
//134 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                         
//135 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                         
//136 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                         
//137 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                         
        
//138 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                 
//139 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                 
//140 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                 
//141 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                 
//142 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                 
//143 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                 
//144 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                 

//145 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                 
//146 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                 
//147 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.!EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                               
//148 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                 
//149 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                 
//150 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                 
//151 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                 

//152 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                 
//153 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                 
//154 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                 
//155 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                 
//156 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                 
//157 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                 
//158 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                 
        
//159 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"F01".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                 
//160 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"F01".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                 
//161 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"F01".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                 
//162 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"F01".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                 
//163 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"F01".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                 
//164 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"F01".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                 
//165 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"F01".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                 

//O bloco abaixo do 166 a 171 foi traduzido no fonte PLT99 igual ao 68 a 74 que esta no LPT992
//166 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                  
//167 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                   
//168 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                  
//169 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                  
//170 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                  
//171 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                  
//172 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                  

//173 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                         
//174 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                         
//175 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                         
//176 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                         
//177 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                         
//178 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                         
//179 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                         

//O bloco abaixo do 180 a 186 foi traduzido no fonte PLT99 igual ao 173 a 179 que esta no LPT992
//180 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                         
//181 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                         
//182 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                         
//183 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                         
//184 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                         
//185 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                         
//186 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                         

//187 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                 
//187 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                 
//189 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                 
//190 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                 
//191 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                 
//192 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                 
//193 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                 

//194 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                 
//195 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                 
//196 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                 
//197 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                 
//198 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                 
//199 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                 
//200 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                 
        
//201 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                 
//202 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                 
//203 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                 
//204 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                 
//205 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                 
//206 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                 
//207 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                 

//208 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                          
//209 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                          
//210 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                          
//211 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                          
//212 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                          
//213 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                          
//214 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                          

//215 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                  
//216 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                  
//217 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                  
//218 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                  
//219 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                  
//220 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                  
//221 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                  

//222 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                  
//223 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                  
//224 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                  
//225 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                  
//226 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                  
//227 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                  
//228 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C06".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                  

//229 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                  
//230 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                  
//231 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                  
//232 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                  
//233 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                  
//234 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                  
//235 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VI".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C09".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                  

//236 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMRH/VRH".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                            
//237 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMRH/VRH".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                            
//238 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMRH/VRH".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                            
//239 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMRH/VRH".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                            
//240 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMRH/VRH".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                            
//241 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMRH/VRH".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                            
//242 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMRH/VRH".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                            

//243 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                           
//244 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                           
//245 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                           
//246 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                           
//247 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                           
//248 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                           
//249 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VMTE/VMAE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                           

//250 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VINC".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                
//251 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VINC".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                
//252 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VINC".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                
//253 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VINC".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                
//254 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VINC".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                
//255 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VINC".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                
//256 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"VINC".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                

//257 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"FTJ".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                 
//258 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"FTJ".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                 
//259 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"FTJ".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                 
//260 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"FTJ".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                 
//261 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"FTJ".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                 
//262 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"FTJ".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                 
//263 - IIF(U_LpTur02()=="3".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"FTJ".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"V01".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                 

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
		If Empty(cClass)
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201010'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201010'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := '11204003'
				ElseIf cTp == 'C'
					cRet := '11201010'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT. CONF RV DE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                   
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201010'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                        
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201010'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                        
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201010'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                        
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201010'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                          
				EndIf
			EndIf
		ElseIf cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201011'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201011'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201011' - Invertido dia 06/11/2017
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201011'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT. CONF RV DE FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                               
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201011'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201011'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201011'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201011'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE FEE AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                                                     
				EndIf
			EndIf
		ElseIf cClass$"C07"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201012'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                            
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201012'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE TAXA DU AEREO FATURADO NR. "+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201012' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201012'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT. CONF RV DE TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201012'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201012'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201012'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201012'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE TAXA DU AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                  
				EndIf
			EndIf
		ElseIf cClass$"C06"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201013'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE TX DESCASAMENTO AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                    
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201013'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE TX DESCASAMENTO AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                    
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201013' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201013'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT. CONF RV DE TX DESCASAMENTO AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                   
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201013'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE TX DESCASAMENTO AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                        
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201013'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE TX DESCASAMENTO AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                        
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201013'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE TX DESCASAMENTO AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                        
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201013'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE TX DESCASAMENTO AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
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
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201014' - Invertido em 06/11/17
					cRet := '11204003'
				ElseIf cTp == 'C'
					//cRet := '11204003'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT. CONF RV DE MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                            
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201014'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE MARKUP AEREO FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                   
				EndIf
			EndIf
		EndIf     
	ElseIf !cGrp $ "AE/VI/VMRH/VRH/VMTE/VMAE/VINC/FTJ"
		If Empty(cClass)
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201041'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201041'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := '11204003'
				ElseIf cTp == 'C'
					cRet := '11201041'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201041'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201041'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201041'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201041'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                      
				EndIf
			EndIf
		ElseIf cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201042'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                            
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201042'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                            
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201042' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201042'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                            
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201042'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201042'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201042'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201042'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE FEE TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                  
				EndIf
			EndIf
		ElseIf cClass$"C06"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201043'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE DESCASAMENTO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                   
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201043'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE DESCASAMENTO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                   
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201043' invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201043'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE DESCASAMENTO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                   
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201043'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE DESCASAMENTO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201043'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE DESCASAMENTO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201043'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE DESCASAMENTO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201043'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE DESCASAMENTO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
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
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201044' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201044'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE MARKUP TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                               
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
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201046' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 COMISSAO CONF RV DE COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                  
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201046'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE COMISSAO TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			EndIf
		EndIf
	ElseIf cGrp $ "VI"
		If Empty(cClass)
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201057'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                  
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201057'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                  
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201057' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201057'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                  
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201057'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                      
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201057'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                      
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201057'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                      
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201057'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                        
				EndIf
			EndIf
		ElseIf cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201058'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201058'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201058'  - Invertido em 06/11/17
					cRet := '11204003'   
				ElseIf cTp == 'C'
					//cRet := '11204003'   
					cRet := '11201058'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201058'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                  
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201058'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                  
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201058'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                  
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201058'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE FEE EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			EndIf
		ElseIf cClass$"C06"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201059'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE DESCASAMENTO EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                      
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201059'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE DESCASAMENTO EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                     
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201059' -  Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201059'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE DESCASAMENTO EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                     
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201059'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE DESCASAMENTO EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201059'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE DESCASAMENTO EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201059'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE DESCASAMENTO EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201059'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE DESCASAMENTO EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
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
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201060' - Invertido em 06/11/17
					cRet := '11204003'
				ElseIf cTp == 'C'
					//cRet := '11204003'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                               
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                               
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                               
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201060'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE MARKUP EMISSAO DE VISTO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                 
				EndIf
			EndIf
		EndIf
	ElseIf cGrp $ "VMRH/VRH" 
		If cClass$"V01"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE VERBA DE RH NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                       
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE VERBA DE RH NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                       
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201036' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE VERBA DE RH NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                       
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE VERBA DE RH NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE VERBA DE RH NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE VERBA DE RH NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                           
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201036'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE VERBA DE RH NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                             
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
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE VERBA DE MARKETING NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE VERBA DE MARKETING NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201034' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE VERBA DE MARKETING NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE VERBA DE MARKETING NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE VERBA DE MARKETING NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE VERBA DE MARKETING NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                    
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201034'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE VERBA DE MARKETING NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                      
				EndIf
			EndIf
		EndIf
	ElseIf cGrp $ "VINC" 
		If cClass$"V01"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE INCENTIVO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE INCENTIVO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201033' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE INCENTIVO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                         
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE INCENTIVO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                             
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE INCENTIVO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                             
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE INCENTIVO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                             
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201033'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE INCENTIVO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                               
				EndIf
			EndIf
		EndIf
	ElseIf cGrp $ "FTJ" 
		If cClass$"V01"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201039'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE JUROS  NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                            
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201039'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE JUROS  NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                            
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201039' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201039'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE JUROS  NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201039'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 FAT. JUROS CONF RV DE JUROS  NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201039'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 FAT. JUROS CONF RV DE JUROS  NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201039'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 FAT. JUROS CONF RV DE JUROS  NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                     
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201039'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA FAT. JUROS CONF RV DE JUROS  NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                       
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
					cRet := '11201018'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201018'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201018' - Invertido em 06/11/17
					cRet := '11204003'
				ElseIf cTp == 'C'
					//cRet := '11204003'
					cRet := '11201018'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT. CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201018'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201018'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201018'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201018'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			EndIf
		ElseIf cClass$"C07"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201019'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE TX ALATUR AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                    
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201019'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE TX ALATUR AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                    
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201019' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201019'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT. CONF RV DE TX ALATUR AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                   
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201019'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE TX ALATUR AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                        
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201019'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE TX ALATUR AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                        
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201019'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE TX ALATUR AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                        
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201019'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE TX ALATUR AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			EndIf
		ElseIf cClass$"C06"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201020'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE TX DESCASAMENTO AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)              
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201020'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE TX DESCASAMENTO AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)              
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201020' - Invertido em 06/11/17
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201020'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT. CONF RV DE TX DESCASAMENTO AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)             
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201020'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE TX DESCASAMENTO AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                  
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201020'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE TX DESCASAMENTO AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                  
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201020'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE TX DESCASAMENTO AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                  
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201020'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE TX DESCASAMENTO AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                    
				EndIf
			EndIf
		EndIf
	EndIf      
ElseIf cFPag == '2'
	If cGrp $ "AE"
		If Empty(cClass)
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201023'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO  CONF RV DE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201023'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					cRet := '11204003'
				ElseIf cTp == 'C'
					cRet := '11201023'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT. CONF RV DE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201023'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3  AEREO CONF RV DE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201023'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4  AEREO CONF RV DE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201023'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5  AEREO CONF RV DE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201023'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA  CONF RV DE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                   
				EndIf
			EndIf
		ElseIf cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201024'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE FEE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201024'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE FEE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201024' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201024'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT. CONF RV DE FEE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201024'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE FEE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201024'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE FEE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201024'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE FEE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201024'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE FEE AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			EndIf
		ElseIf cClass$"C07"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE TAXA DU AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                      
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE TAXA DU AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                      
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201025' -  Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT. CONF RV DE TAXA DU AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                     
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE TAXA DU AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE TAXA DU AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE TAXA DU AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201025'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE TAXA DU AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                            
				EndIf
			EndIf
		ElseIf cClass$"C06"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201026'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE TX DESCASAMENTO AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)              
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201026'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR  CONF RV DE TX DESCASAMENTO AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)             
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201026' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201026'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE TX DESCASAMENTO AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)              
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201026'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE TX DESCASAMENTO AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                  
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201026'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE TX DESCASAMENTO AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                  
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201026'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE TX DESCASAMENTO AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                  
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201026'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE TX DESCASAMENTO AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                    
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
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE MARKUP AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE MARKUP AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201027' -  invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE MARKUP AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE MARKUP AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE MARKUP AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE MARKUP AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201027'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE MARKUP AEREO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			EndIf
		EndIf
	ElseIf !cGrp $ "AE"
		If Empty(cClass)
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201054'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201054'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201054' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201054'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201054'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201054'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201054'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201054'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			EndIf
		ElseIf cClass$"C01/C02/C03/C04/C05"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201051'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE FEE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                      
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201051'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE FEE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                      
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201051' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201051'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE FEE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                      
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201051'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE FEE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201051'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE FEE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201051'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE FEE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201051'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE FEE TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                            
				EndIf
			EndIf
		ElseIf cClass$"C06"
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201052'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE DESCASAMENTO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201052'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE DESCASAMENTO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201052' - invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201052'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE DESCASAMENTO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201052'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE DESCASAMENTO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201052'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE DESCASAMENTO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201052'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE DESCASAMENTO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                           
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201052'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE DESCASAMENTO CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
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
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE MARKUP CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE MARKUP CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201053' - invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE MARKUP CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE MARKUP CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE MARKUP CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE MARKUP CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                 
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201053'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE MARKUP CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                   
				EndIf
			EndIf
	    EndIf
	EndIf
EndIf

Return(cRet)