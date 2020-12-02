/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LpT992    ºAutor  ³TOTVS..             º Data ³  06/2017    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Regras de LP pata T99.Mesmo conceito utilizado no fonte     º±±
±±º          ³LpT99, porem para sequencias que estavam repitidas, com     º±±
±±º          ³contas diferentes.                                          º±±
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

User Function LpT992(cTp,cFPag,cGrp,cClass,cMotBx)

//Chamada da função
//u_LpT992("V",U_LpTur02(),ALLTRIM((cAliasQ2)->G85_GRPPRD),(cAliasQ2)->G85_CLASS,SE5->E5_MOTBX)

//LPs traduzidas

//O bloco abaixo do 166 a 171 foi traduzido no fonte PLT992 igual ao 68 a 74 que esta no LPT99
//166 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                  
//167 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                   
//168 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                  
//169 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                  
//170 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                  
//171 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                  
//172 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                  

//Do 068 ao 074 esta no fonte LPT99
//068 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                  
//069 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                  
//070 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                  
//071 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                  
//072 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                  
//073 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                  
//074 - IIF(U_LpTur02()=="1".AND.ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.ALLTRIM((cAliasQ2)->G85_CLASS)$"C01/C02/C03/C04/C05".AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                  


//O bloco abaixo do 124 a 130 foi traduzido no fonte PLT992 igual ao 131 a 137 que esta no LPT99
//124 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                         
//125 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                         
//126 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                         
//127 - IIF(U_LpTur02()=="3".AND.!ALLTRIM(G85->G85_GRPPRD)$"AE".AND.EMPTY(G85->G85_CLASS).AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                                       
//128 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                         
//129 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                         
//130 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                         

//Do 131 ao 137 esta no fonte LPT99
//131 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                         
//132 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                         
//133 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                         
//134 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                         
//135 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                         
//136 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                         
//137 - IIF(U_LpTur02()=="3".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                         
        
//O bloco abaixo do 180 a 186 foi traduzido no fonte PLT992 igual ao 173 a 179 que esta no LPT99
//180 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                         
//181 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                         
//182 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                         
//183 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                         
//184 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                         
//185 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                         
//186 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                         

//Do 173 ao 179 esta no fonte LPT99
//173 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"362",nVlrRV,0)                                                                                                                         
//174 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"365",nVlrRV,0)                                                                                                                         
//175 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"367",nVlrRV,0)                                                                                                                         
//176 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"375",nVlrRV,0)                                                                                                                         
//177 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"376",nVlrRV,0)                                                                                                                         
//178 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"377",nVlrRV,0)                                                                                                                         
//179 - IIF(U_LpTur02()=="2".AND.!ALLTRIM((cAliasQ2)->G85_GRPPRD)$"AE".AND.EMPTY((cAliasQ2)->G85_CLASS).AND.SE5->E5_MOTBX$"363",nVlrRV,0)                                                                                                                         


If !cMotBx $ "362/365/367/375/376/377/363"

	If cTp $ "D/C/H"
		cRet := ""
	Else
		cRet := 0
	EndIF
	
	Return(cRet)	
	
EndIf

If cFPag == '3'
	If !cGrp $ "AE/VI/VMRH/VRH/VMTE/VMAE/VINC/FTJ"
		If Empty(cClass)
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201045'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE EXTRAS TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201045'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE EXTRAS TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201045' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201045'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE EXTRAS TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201045'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE EXTRAS TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201045'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE EXTRAS TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201045'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE EXTRAS TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                             
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201045'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE EXTRAS TERRESTRE FATURADO NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                               
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
					cRet := '11201048'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF AUTOR DIRET CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201048'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201048' - Invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201048'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                          
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201048'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201048'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201048'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                              
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201048'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE FEE AEREO CARTAO CLIENTE NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                                
				EndIf
			EndIf
		EndIf
	EndIf      
ElseIf cFPag == '2'
	If !cGrp $ "AE"
		If Empty(cClass)
			If SE5->E5_MOTBX$"362"
				If cTp == 'D'
					cRet := '51401007'
				ElseIf cTp == 'C'
					cRet := '11201050'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX AUT DA DIRECAO CONF RV DE EXTRAS TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                   
				EndIf
			ElseIf SE5->E5_MOTBX$"365"
				If cTp == 'D'
					cRet := '21401001'
				ElseIf cTp == 'C'
					cRet := '11201050'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX POR COMPENS-CR CONF RV DE EXTRAS TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                   
				EndIf
			ElseIf SE5->E5_MOTBX$"367"
				If cTp == 'D'
					//cRet := '11201050' - invertido em 06/11/17  
					cRet := '11204003'  
				ElseIf cTp == 'C'
					//cRet := '11204003'  
					cRet := '11201050'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX CRED NAO IDENT CONF RV DE EXTRAS TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                   
				EndIf
			ElseIf SE5->E5_MOTBX$"375"
				If cTp == 'D'
					cRet := '41102009'
				ElseIf cTp == 'C'
					cRet := '11201050'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 3 CONF RV DE EXTRAS TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"376"
				If cTp == 'D'
					cRet := '51202009'
				ElseIf cTp == 'C'
					cRet := '11201050'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 4 CONF RV DE EXTRAS TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"377"
				If cTp == 'D'
					cRet := '51102009'
				ElseIf cTp == 'C'
					cRet := '11201050'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX OPER. CC 5 CONF RV DE EXTRAS TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                       
				EndIf
			ElseIf SE5->E5_MOTBX$"363"
				If cTp == 'D'
					cRet := SA6->A6_CONTA
				ElseIf cTp == 'C'
					cRet := '11201050'
				ElseIf cTp == 'V'
					cRet := nVlrRv
				ElseIf cTp == 'H'
					cRet := "VLR REF BX EM MOEDA CONF RV DE EXTRAS TERRESTRE CARTAO AGENCIA NR."+ALLTRIM((cAliasQ2)->G85_REGVEN)+" FAT "+ALLTRIM((cAliasQ2)->G85_NUMFAT)+" CLIENTE -"+ALLTRIM(SA1->A1_NOME)                         
				EndIf
			EndIf
	    EndIf
	EndIf
EndIf

Return(cRet)