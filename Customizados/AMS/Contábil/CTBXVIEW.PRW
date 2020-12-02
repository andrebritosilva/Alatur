#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP011_MVC
Exemplo de montagem da modelo e interface para um tabela em MVC

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function CTBXVIEW()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CT2')
oBrowse:SetDescription('Conciliação Contábil')
oBrowse:AddLegend( "CT2_XCTBFL != ' '", "GREEN", "Não Conciliado"      )
oBrowse:AddLegend( "CT2_XIDCRE != ' '" ,"BLUE"  , "Interprete" )
//oBrowse:SetFilterDefault( "ZA0_TIPO=='1'" )
//oBrowse:SetFilterDefault( "Empty(ZA0_DTAFAL)" )
//oBrowse:DisableDetails()
//oBrowse:SetCacheView( .F. )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.COMP011_MVC' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.COMP011_MVC' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.COMP011_MVC' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.COMP011_MVC' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.COMP011_MVC' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.COMP011_MVC' OPERATION 9 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCT2 := FWFormStruct( 1, 'CT2', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Remove campos da estrutura
//oStruZA0:RemoveField( 'ZA0_QTDMUS' )

//Campos Memo Virtuais SYP
//FWMemoVirtual( oStruZA1, {{'ZA0_CDSYP1','ZA0_MMSYP1'},{'ZA0_CDSYP2','ZA0_MMSYP2'}}  )

// Altero propriedades dos campos da estrutura, no caso colocando cada campo no seu grupo
//
// SetProperty( <Campo>, <Propriedade>, <Valor> )
//
// Propriedades existentes para View (lembre-se de incluir o FWMVCDEF.CH):
//
//	MODEL_FIELD_TITULO
//	MODEL_FIELD_TOOLTIP
//	MODEL_FIELD_IDFIELD
//	MODEL_FIELD_TIPO
//	MODEL_FIELD_TAMANHO
//	MODEL_FIELD_DECIMAL
//	MODEL_FIELD_VALID
//	MODEL_FIELD_WHEN
//	MODEL_FIELD_VALUES
//	MODEL_FIELD_OBRIGAT
//	MODEL_FIELD_INIT
//	MODEL_FIELD_KEY
//	MODEL_FIELD_NOUPD
//	MODEL_FIELD_VIRTUAL
//
//oStruZA0:SetProperty( '*'         , MODEL_FIELD_NOUPD, .T. )

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('CTBXVIEW', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('COMP011MODEL', /*bPreValidacao*/, { |oMdl| COMP011POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CT2MASTER', /*cOwner*/, oStruCT2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Lançamentos a serem conciliados' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CT2MASTER' ):SetDescription( 'Lançamentos Contábeis' )

// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'CTBXVIEW' )
// Cria a estrutura a ser usada na View
Local oStruCT2 := FWFormStruct( 2, 'CT2' )
//Local oStruZA0 := FWFormStruct( 2, 'ZA0', { |cCampo| COMP11STRU(cCampo) } )
Local oView
Local cCampos := {}

oStruCT2:AddField( ;                      // Ord. Tipo Desc.
AllTrim( 'Sel.' )           , ;      // [01]  C   Titulo do campo
AllTrim( 'Sel. Campo' )     , ;      // [02]  C   ToolTip do campo
'CT2_XMARK'                     , ;      // [03]  C   Id do Field
'L'                              , ;      // [04]  C   Tipo do campo
1                                , ;      // [05]  N   Tamanho do campo
0                                , ;      // [06]  N   Decimal do campo
FwBuildFeature( STRUCT_FEATURE_VALID,"xVldCon()"),;    // [07]  B   Code-bl
NIL                              , ;      // [08]  B   Code-block de valida
Nil                , ;      // [09]  A   Lista de valores permitido do campo
.T.                              , ;      // [10]  L   Indica se o campo tem preenchimento 
Nil      , ;      // [11]  B   Code-block de inicializacao do campo
NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma
.T.                              )        // [14]  L   Indica se o campo 


// Crio os Agrupamentos de Campos
// AddGroup( cID, cTitulo, cIDFolder, nType )   nType => ( 1=Janela; 2=Separador )
//oStruZA0:AddGroup( 'GRUPO01', 'Alguns Dados', '', 1 )
//oStruZA0:AddGroup( 'GRUPO02', 'Outros Dados', '', 2 )

// Altero propriedades dos campos da estrutura, no caso colocando cada campo no seu grupo
//
// SetProperty( <Campo>, <Propriedade>, <Valor> )
//
// Propriedades existentes para View (lembre-se de incluir o FWMVCDEF.CH):
//			MVC_VIEW_IDFIELD
//			MVC_VIEW_ORDEM
//			MVC_VIEW_TITULO
//			MVC_VIEW_DESCR
//			MVC_VIEW_HELP
//			MVC_VIEW_PICT
//			MVC_VIEW_PVAR
//			MVC_VIEW_LOOKUP
//			MVC_VIEW_CANCHANGE
//			MVC_VIEW_FOLDER_NUMBER
//			MVC_VIEW_GROUP_NUMBER
//			MVC_VIEW_COMBOBOX
//			MVC_VIEW_MAXTAMCMB
//			MVC_VIEW_INIBROW
//			MVC_VIEW_VIRTUAL
//			MVC_VIEW_PICTVAR
//
//oStruZA0:SetProperty( '*'         , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
//oStruZA0:SetProperty( 'ZA0_QTDMUS', MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
//oStruZA0:SetProperty( 'ZA0_TIPO'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CT2', oStruCT2, 'CT2MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CT2', 'TELA' )

//oView:SetViewAction( 'BUTTONOK'    , { |o| Help(,,'HELP',,'Ação de Confirmar ' + o:ClassName(),1,0) } )
//oView:SetViewAction( 'BUTTONCANCEL', { |o| Help(,,'HELP',,'Ação de Cancelar '  + o:ClassName(),1,0) } )
Return oView


//-------------------------------------------------------------------
Static Function COMPMAN( oModel )
Local nOperation := oModel:GetOperation()
Local lRet       := .T.

If nOperation == MODEL_OPERATION_UPDATE
	If Empty( oModel:GetValue( 'CT2MASTER', 'CT2_XNUMDO' ) )
		Help( ,, 'HELP',, 'Informe a data', 1, 0)
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
Static Function COMPMANACT( oModel )  // Passa o model sem dados
Local aArea      := GetArea()
Local cQuery     := ''
Local cTmp       := ''
Local lRet       := .T.
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_DELETE .AND. lRet

	cTmp    := GetNextAlias()

	cQuery  := ""
	cQuery  += "SELECT * FROM " + RetSqlName( 'CT2' ) + " CT2 "
	cQuery  += " WHERE CT2.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )

	lRet := (cTmp)->( EOF() )

	(cTmp)->( dbCloseArea() )

	If !lRet
		Help( ,, 'HELP',, 'Este Autor/interprete nao pode ser excluido.', 1, 0)
	EndIf

EndIf

RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
Static Function COMPMANSTR( cCampo )
Local lRet := .T.

/*If cCampo == 'ZA0_QTDMUS'
	lRet := .F.
EndIf*/

Return lRet
