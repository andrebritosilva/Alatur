#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FILEIO.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ALAA001()

Cadastro das distâncias entre aeroportos (CUSTOMIZADO)

@sample 	ALAA001()
@return                             
@author  	Thiago Tavares
@since   	10/10/2016
@version  	P12
/*/
//------------------------------------------------------------------------------------------
User Function ALAA001()

Local oBrowse	:= FWMBrowse():New()

Processa({|| U_ALAA001LOAD()}, "Aguarde... Realizando a carga de dados do cadastro.", "Essa operação poderá demorar alguns minutos.") 

oBrowse:SetAlias('SZA')
oBrowse:SetDescription("Cadastro de Distância entre Aeroportos")
oBrowse:SetMenudef('ALAA001')
oBrowse:Activate()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Função que define o modelo de dados do cadastro 

@sample 	ALAA001()
@return  	oModel                       
@author  	Thiago Tavares
@since   	10/10/2016
@version  	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := Nil
Local oStruSZA := FWFormStruct(1, 'SZA', /*bAvalCampo*/, /*lViewUsado*/)

oModel:= MPFormModel():New('ALAA001X', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/)
oModel:AddFields('SZAMASTER', /*cOwner*/, oStruSZA, /*Criptog()/, /*bPosValidacao*/, /*bCarga*/)
oModel:SetPrimaryKey({})
oModel:SetDescription("Cadastro de Distância entre Aeroportos")

Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

Função que define a visualização do cadastro 

@sample 	ALAA001()
@return   	oView                       
@author  	Thiago Tavares
@since   	10/10/2016
@version  	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView    := Nil
Local oModel   := FWLoadModel('ALAA001')
Local oStruSZA := FWFormStruct(2, 'SZA')

oView:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SZA', oStruSZA, 'SZAMASTER')
oView:CreateHorizontalBox('TELA', 100)
oView:SetOwnerView('VIEW_SZA', 'TELA')

Return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Função que define os itens do menu do cadastro 

@sample 	ALAA001()
@return  	aRotina                       
@author  	Thiago Tavares
@since   	10/10/2016
@version  	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar" 	ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"	ACTION 'VIEWDEF.ALAA001'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE "Incluir" 	ACTION 'VIEWDEF.ALAA001'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE "Alterar"	 	ACTION 'VIEWDEF.ALAA001'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE "Excluir"		ACTION 'VIEWDEF.ALAA001'	OPERATION 5	ACCESS 0

Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Função que realiza a carga de dados para o cadastro de acordo com arquivo CSV enviada pela SABRE

@sample 	ALAA001()
@return  	
@author  	Thiago Tavares
@since   	10/10/2016
@version  	P12
/*/
//------------------------------------------------------------------------------------------
User Function ALAA001LOAD()

Local aArea   := GetArea()
Local cArqCSV := GetSrvProfString('RootPath', '') + '\data\milhas.csv'
Local oModel  := Nil
Local oStruct := Nil
Local nHandle := 0
Local nLinha  := 1
Local aLinha  := {}

DbSelectArea('SZA')
SZA->(DbSetOrder(1))		// ZA_FILIAL+ZA_TERORI+ZA_TERDES
If SZA->(Eof())
	If File(cArqCSV, , .F.) 
		nHandle := FT_FUse(cArqCSV)
		FT_FGoTop()
		While !FT_FEOF()
			If nLinha > 1
				oModel := FwLoadModel('ALAA001')
				oModel:SetOperation(MODEL_OPERATION_INSERT)
	
				oStruct := oModel:GetModel('SZAMASTER'):GetStruct()
				oStruct:SetProperty('ZA_TERORI', MODEL_FIELD_VALID, {|| .T.})
				oStruct:SetProperty('ZA_TERDES', MODEL_FIELD_VALID, {|| .T.})
	
				aLinha  := StrToKArr(Upper(AllTrim(FT_FReadLn())), ";")
				SZA->(DbSetOrder(1))		// ZA_FILIAL+ZA_TERORI+ZA_TERDES
				If !SZA->(DbSeek(xFilial('SZA') + aLinha[1] + aLinha[2]))
					If oModel:Activate()
						oModel:GetModel('SZAMASTER'):SetValue('ZA_FILIAL', xFilial('SZA'))
						oModel:GetModel('SZAMASTER'):SetValue('ZA_TERORI', aLinha[1])
						oModel:GetModel('SZAMASTER'):SetValue('ZA_TERDES', aLinha[2])
						oModel:GetModel('SZAMASTER'):SetValue('ZA_KMS'   , Val(aLinha[3]))
						oModel:GetModel('SZAMASTER'):SetValue('ZA_MILHAS', Val(aLinha[4]))
						If oModel:VldData() 
							oModel:CommitData()
						Endif
					EndIf
				Endif
				SZA->(DbCloseArea())
				oModel:Deactivate()
				oModel:Destroy()
			EndIf
			nLinha++
			FT_FSkip()
		EndDo
		FT_FUse()
	EndIf
EndIf
SZA->(DbCloseArea())

RestArea(aArea)

Return 