#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATA730.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FatA730   ºAutor  ³Vendas CRM          º Data ³  03/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grupos Societarios em MVC.								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFAT                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FatA730
Local oBrowse	:= Nil 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o Browse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AGT')
oBrowse:SetDescription(STR0001)//'Grupos Societarios'
oBrowse:Activate()

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ModelDef  ºAutor  ³Vendas CRM          º Data ³  03/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define o modelo de dados do grupos societarios.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FatA730                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()

Local oModel
Local oStruAGT 		:= FWFormStruct(1,'AGT',/*bAvalCampo*/,/*lViewUsado*/)
Local oStruAGU 		:= FWFormStruct(1,'AGU',/*bAvalCampo*/,/*lViewUsado*/)

oModel := MPFormModel():New('FATA730',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('AGTMASTER',/*cOwner*/,oStruAGT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'AGUDETAIL','AGTMASTER',oStruAGU,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/) 
oModel:SetRelation( 'AGUDETAIL',{{'AGU_FILIAL','xFilial("AGU")'},{'AGU_CODIGO','AGT_CODIGO'}} ,'AGU_FILIAL+AGU_CODIGO')
oModel:GetModel('AGUDETAIL'):SetUniqueLine({'AGU_CODCLI','AGU_LOJCLI'})
oModel:SetDescription(STR0001)

Return(oModel)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ViewDef   ºAutor  ³Vendas CRM          º Data ³  03/02/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define a interface para cadastro do grupo societario.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FatA730                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('FATA730')
Local oStruAGT := FWFormStruct(2,'AGT')
Local oStruAGU := FWFormStruct(2,'AGU')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_AGT', oStruAGT, 'AGTMASTER' )
oView:AddGrid( 'VIEW_AGU', oStruAGU, 'AGUDETAIL' )
oView:CreateHorizontalBox('SUPERIOR', 10 )
oView:CreateHorizontalBox('INFERIOR', 90 )
oView:SetOwnerView( 'VIEW_AGT','SUPERIOR' )
oView:SetOwnerView( 'VIEW_AGU','INFERIOR' )

Return(oView)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef   ³ Autor ³ Vendas CRM            ³ Data ³ 03/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de definicao do aRotina.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRotina   retorna a array com lista de aRotina              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FatA730                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FATA730'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FATA730'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FATA730'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FATA730'	OPERATION 5	ACCESS 0

Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ft730VdCli
Validacao dos campos AGU_CODCLI / AGU_LOJCLI.
@sample 	Ft730Cli(cCodCli,cLoja)
@param		ExpC1	Codigo do cliente
			ExpC2	Loja do cliente
@return   	ExpL	True - Válido, False - Inválido
@author	    Squad CRM
@since		13/02/2019
@version	12.1.17
/*/
//------------------------------------------------------------------------------ 
Function Ft730VdCli(cCodCli, cLoja)

Local lRetorno  := .T.
Default cCodCli := ""
Default cLoja   := ""

If !Empty( cCodCli ) .And. Empty( cLoja )
	SA1->(DbSetOrder(1))
	If SA1->(!DbSeek(xFilial("SA1")+cCodCli))
        Help(NIL, NIL, "Ft730VdCli", NIL, STR0007 , 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0008 }) // "Cliente inválido." ## "Verificar o código informado."
		lRetorno := .F.
	EndIf
Else
    lRetorno := Vazio() .OR. ExistCpo("SA1", cCodCli + cLoja)
EndIf	

Return(lRetorno)

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local aRet := {}
	aRet:= FATI730( cXml, nTypeTrans, cTypeMessage )

Return aRet