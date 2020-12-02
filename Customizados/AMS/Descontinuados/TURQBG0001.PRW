#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURQBG0001

Função para deletar conciliações de Metas
@author Serviços
@since 02/02/17
@version P12

@return	Nil
/*/
//--------------------------------------------------------------------------------------------------------------------

User Function TURQBG0001()
Local aAreaBkp	:= GetArea()
	
	Processa( {|| lRet := SetDelG6J() },"Aguarde...","Deletando Concilia��es...")

RestArea(aAreaBkp)
Return


Static Function SetDelG6J()

Local cTmpAlias	:= GetNextAlias()
Local oModel	:=	nil

BeginSql Alias cTmpAlias
	Select 
		R_E_C_N_O_ as Recno
	FROM 
		%Table:G6J% G6J
	WHERE
		G6J.G6J_TIPO = '3' AND
		G6J.%NotDel%
EndSql

oModel := FwLoadModel( "TURA039M" )
oModel:SetOperation( MODEL_OPERATION_DELETE )

ProcRegua((cTmpAlias)->(ScopeCount()))
(cTmpAlias)->(DbGoTop())
While (cTmpAlias)->(!Eof())
	IncProc("Deletando registro...")
	G6J->(DbGoTo((cTmpAlias)->Recno))
	lRet := .F.
	If oModel:Activate()
		lRet := oModel:VldData()
		oModel:CommitData()	
		oModel:DeActivate()
	Endif
	If !lRet
		JurShowErro( oModel:GetErrorMessage())
	Endif
	(cTmpAlias)->(DBSKIP())
EndDo
oModel:Destroy()	
	
(cTmpAlias)->(dbCloseArea())

Return

