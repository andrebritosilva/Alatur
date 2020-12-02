#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function FINM010()

    Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local oObj       := ''
    Local cIdPonto   := ''
    Local cIdModel   := ''
    Local cOrigem    := AllTrim(SE1->E1_ORIGEM)
    Local cAliasG8G  := "G8G"
    Local cPrefTitRA := "FTA"
    Local aFina040   := {}
    Local cFilMemo	 := ""
    Local aAreaBkp   := GetArea()

    Private lMsErroAuto := .F.

    If aParam <> NIL
        oObj       := aParam[1]
        cIdPonto   := aParam[2]
        cIdModel   := aParam[3]
       
        If cIdPonto == 'MODELCOMMITTTS' .AND. cOrigem == "TURA047" .AND. oObj:nOperation == 3 //3 - Baixa do titulo
    
            DbSelectArea(cAliasG8G)
            G8G->(DbSetOrder(3))//G8G_FILREF+G8G_FAENUM+G8G_FAPREF+G8G_FAEPAR
            
            If G8G->(DbSeek(SE1->E1_FILIAL + SE1->E1_NUM + SE1->E1_PREFIXO + SE1->E1_PARCELA))
            
                If FK5->FK5_VALOR >= SE1->E1_SALDO
            
                    cNumTitRA := GetSXENum("SE1", "E1_NUM",cPrefTitRA,1)
                    ConfirmSX8()
                    
                    cFilMemo:= cFilAnt
                    cFilAnt := G8G->G8G_FILREF
                    
                    AAdd(aFina040, {'E1_FILIAL'     ,G8G->G8G_FILREF                    ,NIL})
                    AAdd(aFina040, {'E1_NUM'        ,cNumTitRA             			    ,NIL})
                    AAdd(aFina040, {'E1_PARCELA'    ,SE1->E1_PARCELA           		    ,NIL})
                    AAdd(aFina040, {'E1_PREFIXO'    ,cPrefTitRA               		    ,NIL})
                    AAdd(aFina040, {'E1_NATUREZ'    ,SE1->E1_NATUREZ                    ,NIL})
                    AAdd(aFina040, {'E1_TIPO'       ,'RA'                  		        ,NIL})
                    AAdd(aFina040, {'E1_CLIENTE'    ,SE1->E1_CLIENTE         		    ,NIL})
                    AAdd(aFina040, {'E1_LOJA'       ,SE1->E1_LOJA              		    ,NIL})
                    AAdd(aFina040, {'E1_VALOR'      ,SE1->E1_VALOR            		    ,NIL})
                    AAdd(aFina040, {'E1_MOEDA'      ,SE1->E1_MOEDA                	    ,NIL})
                    AAdd(aFina040, {'E1_TXMOEDA'    ,RecMoeda(dDatabase, SE1->E1_MOEDA)	,NIL})
                    AAdd(aFina040, {'E1_EMISSAO'    ,dDataBase                    	    ,NIL})
                    AAdd(aFina040, {'E1_VENCTO'     ,dDataBase                    	    ,NIL})
                    AAdd(aFina040, {'E1_VENCREA'    ,DataValida(dDataBase, .T.)   	    ,NIL})
                    AAdd(aFina040, {'E1_VENCORI'    ,DataValida(ddatabase, .T.)   	    ,NIL})
                    AAdd(aFina040, {'E1_XCOBJM'     ,'2'                    	  	    ,NIL})
                    AAdd(aFina040, {'E1_STATUS'     ,'A'                    	  	    ,NIL})
                    AAdd(aFina040, {'CBCOAUTO'      ,SE1->E1_PORTADOR              	    ,NIL})
                    AAdd(aFina040, {'CAGEAUTO'      ,SE1->E1_AGEDEP                	    ,NIL})
                    AAdd(aFina040, {'CCTAAUTO'      ,SE1->E1_CONTA               	    ,NIL})
            
                    MSExecAuto({|x, y| FINA040(x, y)}, aFina040, 3)

                    If !lMsErroAuto
                            
                        RecLock("G8G",.F.)
                        G8G->G8G_RA     := cNumTitRA
                        G8G->G8G_RAPREF := cPrefTitRA
                        G8G->G8G_RAPARC := SE1->E1_PARCELA
                        G8G->(MsUnLock())
                
                    Else

                        MostraErro()
                        lRet:= .F.

                    Endif
                    
                    cFilAnt:= cFilMemo

                EndIf

            Else
                
                xRet := .F. 
                Help(,,"PE_FINM0101",," Não foi possivel gerar titulo de RA para a Fatura " + cNumTitRA,1,0)      

            EndIf

            DbCloseArea()

        ElseIf cIdPonto == 'MODELPRE' .AND. cOrigem == "TURA047" .AND. oObj:nOperation == 4 //4 - Cancelamento da Baixa
                
            DbSelectArea(cAliasG8G)
            G8G->(DbSetOrder(3))//G8G_FILREF+G8G_FAENUM+G8G_FAPREF+G8G_FAEPAR
                
            If G8G->(DbSeek(SE1->E1_FILIAL + SE1->E1_NUM + SE1->E1_PREFIXO + SE1->E1_PARCELA))
                    
                SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
                If SE1->(DbSeek(xFilial("SE1") + G8G->G8G_CLIENT + G8G->G8G_LOJA + G8G->G8G_RAPREF + G8G->G8G_RA + G8G->G8G_RAPARC + "RA"))

                    If SE1->E1_SALDO <> SE1->E1_VALOR

                        Help(,,"PE_FINM0102",," Não é possivel cancelar esta baixa, pois existe movimentação no RA " + G8G->G8G_RA,1,0)
                        xRet := .F.

                    Else
                                
                        AAdd(aFina040, {'E1_FILIAL'     ,G8G->G8G_FILREF   ,NIL})
                        AAdd(aFina040, {'E1_NUM'        ,G8G->G8G_RA       ,NIL})
                        AAdd(aFina040, {'E1_PARCELA'    ,G8G->G8G_RAPARC   ,NIL})
                        AAdd(aFina040, {'E1_PREFIXO'    ,G8G->G8G_RAPREF   ,NIL})
                        AAdd(aFina040, {'E1_NATUREZ'    ,SE1->E1_NATUREZ   ,NIL})
                        AAdd(aFina040, {'E1_TIPO'       ,'RA'              ,NIL})
                        AAdd(aFina040, {'E1_CLIENTE'    ,G8G->G8G_CLIENT   ,NIL})
                        AAdd(aFina040, {'E1_LOJA'       ,G8G->G8G_LOJA     ,NIL})
                        AAdd(aFina040, {'E1_VALOR'      ,G8G->G8G_VALOR    ,NIL})
                        AAdd(aFina040, {'E1_EMISSAO'    ,SE1->E1_EMISSAO   ,NIL})
                        AAdd(aFina040, {'E1_VENCTO'     ,SE1->E1_VENCTO    ,NIL})
                        AAdd(aFina040, {'E1_VENCREA'    ,SE1->E1_VENCREA   ,NIL})
                        
                        MSExecAuto({|x, y| FINA040(x, y)}, aFina040, 5)

                        If !lMsErroAuto
                            
                            RecLock("G8G",.F.)
                            G8G->G8G_RA     := " "
                            G8G->G8G_RAPREF := " "
                            G8G->G8G_RAPARC := " "
                            G8G->(MsUnLock())
                
                        Else

                            MostraErro()
                            lRet:= .F.    

                        EndIf

                    EndIf
                
                Else
                    
                    Help(,,"PE_FINM0103",," Titulo RA não encontrado. " + G8G->G8G_RA,1,0)
                   
                EndIf    

            EndIf

            DbCloseArea()

        EndIf
    
    EndIf
    
    RestArea(aAreaBkp)

Return xRet