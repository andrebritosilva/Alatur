#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ViewDef
View estendida do Tura034 com o filtro ja ativo na abertura da view 
@type function
@author Anderson Toledo
@since 12/05/2017
@version 1.0
/*/
User Function TURXVIEW(cFilSeek, cNumId)

Local oModel    := MPFormModel():New( "TURA067", /*bPreValidacao*/, /*bPosVandreandalidacao*/,/*bcommit*/, {|oModel| FWFormCancel(oModel),  TA067Destroy() } )
Local aDadosUsr	:= {}
Local lMarcado 	:= .F.
Local cBkpFil	:= ""
Local oMdlAnt  	:= oModel
Local nOpt      := 3

DbSelectArea("G3P")
DbSetOrder(1)
If G3P->(dbSeek(PadR(cFilSeek,TamSx3("G3P_FILIAL")[1])+cNumId))
	
	cBkpFil := cFilAnt 
	cFilAnt := cFilSeek
		
	T34Segmento( Val( G3P->G3P_SEGNEG ) )
	TURA34HierAces(__cUserId,@aDadosUsr)
	
	If Empty(aDadosUsr[1])
		Help(,,"Tura34SemAcesso",,"'Seu codigo de usuario nao esta relacionado com um vendedor ou agente. Nao sera possivel acessar essa rotina.'",1,0) 
	Else

		T34DadosUsr( aDadosUsr )
		
		FWExecView(Iif(nOpt==2,"Visualizar","Alterar"),'TURA034',Iif(nOpt==2,MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE),,{|| .T. }) //"VISUALIZAR"#"ALTERAR"
		
		T34Segmento( 0 )
		T34DadosUsr( {"","","",""} )

	EndIf
		
	cFilAnt := cBkpFil
		
Else
    MsgInfo("RV não encontrado na base de dados","RV não encontrado")
EndIf

Return .T.