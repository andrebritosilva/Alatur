#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TAFA519.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA519

Rotina para chamada de menu.
Executa a view para montagem da tela, sem utilização de Browse.

@author TOTVS
@since 29/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TAFA519()
Local lContinua := .T.

//-----------------------------
// Valida se a filial é matriz
//-----------------------------
DBSelectArea("C1E")
C1E->( DBSetOrder(3) ) //C1E_FILIAL+C1E_FILTAF+C1E_ATIVO
If C1E->( MSSeek( xFilial("C1E") + PadR( SM0->M0_CODFIL, TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )
	If !C1E->C1E_MATRIZ
		lContinua := .F.
		Help(" ",1,"TAFA519",,STR0001,1,0,,,,,,{STR0002 }) //"Acesso não autorizado para a filial."###"Só é possivel acessar a rotina na filial marcada como Matriz no Cadastro de Complemento de Empresa."
	EndIf
EndIf

//----------------------------------------------------------------------------------------------
// Valida se o dia está entre 01 e 07, para alertar o usuário da indisponibilidade pelo governo
//----------------------------------------------------------------------------------------------
If lContinua .And. Day(dDataBase) >= 1 .And. Day(dDataBase) <= 7
	lContinua := MsgYesNo(STR0003) //"A consulta está indisponivel entre os dias 1 a 7 de cada mês. Deseja continuar?"
EndIf

//----------------------------
// Apresenta a tela da rotina
//----------------------------
If lContinua
	//         cTitulo ,cPrograma ,nOperation             ,oDlg ,bCloseOnOK ,bOk ,nPercReducao ,aEnableButtons ,bCancel ,cOperatId ,cToolBar ,oModelAct
	FWExecView(STR0004 ,"TAFA519" ,MODEL_OPERATION_INSERT ,     ,           ,    ,             ,               ,        ,          ,         ,         ) //'Consulta Recibo'
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface grafica da consulta de recibo no eSocial BX

@return Objeto, Objeto da interface da rotina de consulta de recibo do eSocial BX

@author TOTVS
@since 29/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FWLoadModel("TAFA519")
Local oStruPar	:= TAFStruct(2,"PARAMETROS")
Local oStruReg	:= TAFStruct(2,"REGISTROS")
Local oStruCont	:= TAFStruct(2,"CONTADORES")

//------------------------
// Define o model da view
//------------------------
oView:SetModel( oModel )

//---------------------------------------------------
// Adiciona na view a estrutura do painel PARAMETROS
//---------------------------------------------------
oView:AddField('VIEW_PAR', oStruPar, 'PARAMETROS')

//--------------------------------------------------
// Adicao de outros objetos para inclusão de botões
//--------------------------------------------------
//                   cViewID    ,bActivate                     ,bDeActivate ,bRefresh
oView:AddOtherObject("VIEW_BOT" ,{|oPanel| TAFA519Bot(oPanel)} ,            ,        )

//---------------------------------------------------
// Adiciona na view a estrutura do painel REGISTROS
//---------------------------------------------------
oView:AddGrid('VIEW_REG', oStruReg, 'REGISTROS')

//---------------------------------------------------
// Adiciona na view a estrutura do painel CONTADORES
//---------------------------------------------------
oView:AddField('VIEW_CON', oStruCont, 'CONTADORES')

//-----------------------------------
// Exibe a opcao de pesquisa no grid
//-----------------------------------
oView:SetViewProperty("VIEW_REG", "GRIDSEEK", {.T.})

//---------------------------------
// Exibe a opcao de filtro no grid
//---------------------------------
 oView:SetViewProperty("VIEW_REG", "GRIDFILTER", {.T.}) 

//---------------------------------------------------------
// Cria "box" horizontal para receber os elementos da view
//---------------------------------------------------------
oView:CreateHorizontalBox('BOX_1',23)
oView:CreateHorizontalBox('BOX_2',10)
oView:CreateHorizontalBox('BOX_3',55)
oView:CreateHorizontalBox('BOX_4',12)

//--------------------------------------------------
// Relaciona o ID da View com o "box" para exibicao
//--------------------------------------------------
oView:SetOwnerView('VIEW_PAR','BOX_1')
oView:SetOwnerView('VIEW_BOT','BOX_2')
oView:SetOwnerView('VIEW_REG','BOX_3')
oView:SetOwnerView('VIEW_CON',"BOX_4")

//--------------------------
// Exibe o titulo do painel
//--------------------------
oView:EnableTitleView('VIEW_PAR')
oView:EnableTitleView('VIEW_REG')
oView:EnableTitleView('VIEW_CON')

//-------------------------------------
// Bloqueia a inclusão de novas linhas
//-------------------------------------
oView:SetNoInsertLine('VIEW_REG')

//---------------------------------------
// Bloqueia a exclusão de linhas do grid
//---------------------------------------
oView:SetNoDeleteLine('VIEW_REG')

//---------------------------------------------------------------------------------------------------------
// Não apresenta o botao "Salvar e Criar Novo" quando utilizada a opção de inclusão MODEL_OPERATION_INSERT
//---------------------------------------------------------------------------------------------------------
oView:SetCloseOnOK({ || .T. })

//-----------------------------------------
// Adiciona botoes no grupo "Outras Acoes"
//-----------------------------------------
//                  cTitle  ,cResource ,bBloco                                  ,cToolTip ,nShortCut ,aOptions
oView:AddUserButton(STR0005 ,""        ,{|| TAFVisLog() }                       ,         ,          ,        ) //"Log eSocial BX" 
oView:AddUserButton(STR0006 ,""        ,{|| If(TAFA519PVl(),TAFPreCons(),Nil) } ,         ,          ,        ) //"Consulta Base TAF" 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Regra de negócio da rotina de consulta de recibo no eSocial BX

@return Objeto, Objeto da regra de negócio da rotina de consulta de recibo do eSocial BX

@author TOTVS
@since 29/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= Nil
Local oStruPar	:= TAFStruct(1,"PARAMETROS")
Local oStruReg	:= TAFStruct(1,"REGISTROS")
Local oStruCont	:= TAFStruct(1,"CONTADORES")

//----------------------------------
// Cria o objeto do Modelo de Dados
//----------------------------------
//                         cID       ,bPre ,bPost ,bCommit                       ,bCancel
oModel:= MPFormModel():New("TAFA519" ,     ,      ,{|oModel| TAFA519Grv(oModel)} ,       )

//-----------------------------------------------------------------------------------
// Adiciona ao modelo a estrutura dos PARAMETROS como formulário de edição por campo
//-----------------------------------------------------------------------------------
//               cId          ,cOwner ,oModelStruct ,bPre ,bPost ,bLoad
oModel:AddFields("PARAMETROS" ,       ,oStruPar     ,     ,      ,     )

//----------------------------------------------------------------------------------
// Adiciona ao modelo a estrutura dos REGISTROS como formulário de edição por linha
//----------------------------------------------------------------------------------
//             cId         ,cOwner       ,oModelStruct ,bLinePre ,bLinePost ,bPre ,bLinePost ,bLoad 
oModel:AddGrid('REGISTROS' ,'PARAMETROS' ,oStruReg     ,         ,          ,     ,          ,     )

//-----------------------------------------------------------------------------------
// Adiciona ao modelo a estrutura dos CONTADORES como formulário de edição por campo
//-----------------------------------------------------------------------------------
//               cId          ,cOwner       ,oModelStruct ,bPre ,bPost ,bLoad
oModel:AddFields("CONTADORES" ,'PARAMETROS' ,oStruCont    ,     ,      ,     )

//-----------------------------------------
// Adiciona a descricao do Modelo de Dados
//-----------------------------------------
oModel:SetDescription("eSocial BX")

//-------------------------------------------------------
// Adiciona a descricao dos submodelos de dados
//-------------------------------------------------------
oModel:GetModel("PARAMETROS"):SetDescription(STR0007) //"Parâmetros"
oModel:GetModel("REGISTROS"):SetDescription(STR0008) //"Registros"
oModel:GetModel("CONTADORES"):SetDescription(STR0009) //"Contadores"

//----------------------------------------------------------------
// Devido o modelo não ter base em dicionário, não há Primary Key
//----------------------------------------------------------------
oModel:SetPrimaryKey({})

Return oModel

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA519Bot

Inclusão dos botoes no Submodelo da View VIEW_BOT

@param  Objeto, oPanel, Painel onde será incluso os botões.

@author TOTVS
@since 05/09/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Function TAFA519Bot(oPanel)
Local oBtn1 := Nil
Local oBtn2	:= Nil

//                      nRow ,nCol ,cCaption ,oWnd   ,bAction            ,nWidth ,nHeight ,uParam8 ,oFont ,uParam10 ,lPixel ,uParam12 ,uParam13 ,uParam14 ,bWhen ,uParam16 ,uParam17
oBtn1 := TButton():New( 005  ,003  ,STR0010  ,oPanel ,{|| TAFLoadReg() } ,50     ,12      ,        ,      ,         ,.T.    ,         ,         ,         ,      ,         ,        ) //"Consultar Governo"
oBtn2 := TButton():New( 005  ,060  ,STR0011  ,oPanel ,{|| TAFVisReg() }  ,50     ,12      ,        ,      ,         ,.T.    ,         ,         ,         ,      ,         ,        ) //"Visualizar Registro"

Return()

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFLoadReg

Carga do Submodelo REGISTROS

@author TOTVS
@since 05/09/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Static Function TAFLoadReg()
Local oModel		:= FWModelActive()
Local oView			:= FWViewActive()
Local oModPar		:= oModel:GetModel('PARAMETROS')
Local oGridReg		:= oModel:GetModel('REGISTROS')
Local oModCont		:= oModel:GetModel('CONTADORES')
Local cTPEvento		:= oModPar:GetValue("TPEVENTO")
Local cEvento		:= ""
Local aRetTSS		:= {}
Local nRetTSS		:= 0
Local cAliasQry		:= GetNextAlias()
Local cQry			:= ""
Local cInID			:= ""
Local cRecibo		:= ""
Local nPosRec		:= 0
Local nPosEvt		:= 0
Local cAlias 		:= ""
Local dDataIni		:= SToD("")
Local cHoraIni		:= ""
Local cLockBy		:= "TAFA519"
Local cCPFTrab		:= ""
Local nX			:= 0
Local lContinua		:= .T.
Local nTamDesc		:= oGridReg:GetStruct():GetProperty('DESCRIC',MODEL_FIELD_TAMANHO)

//----------------------------------------------------
// Valida se os campos obrigatórios foram preenchidos
//----------------------------------------------------
If lContinua
	lContinua := TAFA519PVl()
EndIf

//--------------------------------------------------------------------------------------------
// Tratamento para a consulta não ocorrer de forma paralela, conforme determinação do Governo
//--------------------------------------------------------------------------------------------
//            cName   ,lEmpresa ,lFilial
If lContinua .And. !LockByName(cLockBy ,.T.      ,.F.    )
	lContinua := .F.
	Help(" ",1,"TAFLoadReg",,STR0012,1,0,,,,,,{STR0013}) //"Uma consulta já está em processamento."###"Aguarde o término do processamento da outra estação."
EndIf

If lContinua

	If cTPEvento == '1'
		cEvento := 'S-1000'
		cAlias := 'C1E'

	ElseIf cTPEvento == '2'
		cEvento	:= oModPar:GetValue("EVENTO")
	EndIf

	//--------------------------------------------
	// Chama o TSS passando os dados do parãmetro
	//--------------------------------------------
	MsgRun(STR0014, STR0010, {|| aRetTSS := TSSeSocBX() }) //"Aguarde, realizando consulta no sistema do Governo..."###"Consulta Governo"

	//------------------------------------------------------
	// Finalizada a consulta no governo, a trava é removida
	//------------------------------------------------------
	//           cName   ,lEmpresa ,lFilial
	UnLockByName(cLockBy ,.T.      ,.F.    )

	If !Empty(aRetTSS)

		//---------------------------------------------
		// Grava a tabela de LOG da consulta realizada 
		//---------------------------------------------
		RecLock("V2N",.T.)
		V2N->V2N_FILIAL	:= XFilial("V2N")
		V2N->V2N_ID		:= TAFGeraID()
		V2N->V2N_DATA	:= dDataBase
		V2N->V2N_HORA	:= StrTran(Time(),":","")
		V2N->V2N_TIPOEV	:= cTPEvento
		V2N->V2N_EVENTO	:= cEvento
		V2N->V2N_CODUSR	:= RetCodUsr()
		V2N->V2N_CODRET	:= aRetTSS[1]
		V2N->V2N_DSCRET	:= aRetTSS[2]
		V2N->(MSUnlock())

		//----------------------------------------------------------------------------------------------
		// Se o governo retornar código diferente do sucesso, apresenta o ocorrido e interrompe a carga
		//----------------------------------------------------------------------------------------------
		If aRetTSS[1] != '201'
			lContinua := .F.
			Help(" ",1,"TAFLoadReg",,STR0015 + aRetTSS[1] + "-" + aRetTSS[2] ,1,0,,,,,,{STR0016}) //"Erro no retorno do Governo. Código: "###"Entre em contato com o suporte técnico."
		EndIf

		If lContinua
			//----------------------------------------------------------------
			// Atualiza o campo "Consultas Disponiveis" (painel "Contadores")
			//----------------------------------------------------------------
			oModCont:SetValue("CONSDISP",TAFConsDis())

			//----------------------------------------------------------------
			// Atualiza o campo "Registros Processados" (painel "Contadores")
			//----------------------------------------------------------------
			oModCont:SetValue("REGAPRE",oModCont:GetValue("REGAPRE") + Len(aRetTSS[5]))

			//----------------------------------------------------------------
			// Atualiza o campo "Registros Processados" (painel "Contadores")
			//----------------------------------------------------------------
			oModCont:SetValue("REGDIS",Val(aRetTSS[3]))

			If oView <> Nil
				oView:Refresh("CONTADORES")
			EndIf

			//---------------------------------------------------------------------------------------------------------------------------------------------
			// Atualiza a data inicial do SubModelo Parametros com a ultima data, quando os registros retornados superarem o total localizado pelo governo
			//---------------------------------------------------------------------------------------------------------------------------------------------
			If Val(aRetTSS[3]) > Len(aRetTSS[5])

				dDataIni := SToD(StrTran(SubStr(aRetTSS[4],1,10),'-',''))
				cHoraIni := StrTran(SubStr(aRetTSS[4],12,Len(aRetTSS[4])),':','')

				oModPar:SetValue("DATADE",dDataIni)
				oModPar:SetValue("HORADE",cHoraIni)

				If oView <> Nil

					Aviso("Atenção",;
							STR0017 +CRLF+; //'O governo localizou mais registros do que a quantidade maxima retornada por consulta.'
							STR0018 +CRLF+CRLF+; //'Para visualiza-los, clique novamente no botão "Consultar Governo".'
							STR0019,; //'Obs: Os campos "Data De" e "Hora De" foram automaticamente ajustados para a busca dos próximos registros.'
							{STR0020},; //"Fechar"
							2)

					oView:Refresh("PARAMETROS")

				EndIf

			EndIf

			//-------------------------------------------------------------------
			// Trata os IDs retornados pelo governo para consulta na base do TAF
			//-------------------------------------------------------------------
			For nRetTSS := 1 To Len(aRetTSS[5])

				If nRetTSS > 1
					cInID += ','
				EndIf

				cInID += "'" + aRetTSS[5][nRetTSS][1] + "'"

			Next nRetTSS

			//----------------------------------------
			// Monta query para preenchimento da grid
			//----------------------------------------
			cQry := TAFA519Qry(cInID)

			MPSysOpenQuery(cQry, cAliasQry)

			If (cAliasQry)->(EOF())
				lContinua := .F.
				Help(" ",1,"TAFLoadReg",,STR0021 ,1,0,,,,,,{STR0022}) //"Os registros retornados pelo governo já possuem número de recibo no TAF."###"Confira os parâmetros informados."
			EndIf

			If lContinua
				//-----------------------------------------------------
				// Permite a inclusao de linhas no Submodelo REGISTROS
				//-----------------------------------------------------
				oGridReg:SetNoInsertLine(.F.)

				//-------------------------------------------------------
				// Alimenta a tabela temporária com os dados dos eventos
				//-------------------------------------------------------
				While (cAliasQry)->(!EOF())

					//--------------------------
					// Obtem o numero do recibo
					//--------------------------
					nPosRec := AScan(aRetTSS[5], {|x| x[1] == (cAliasQry)->XMLID })
					cRecibo := aRetTSS[5][nPosRec][2]

					nLine := oGridReg:AddLine()

					oGridReg:GoLine(nLine)

					oGridReg:SetValue("OK"		,.T.					,.T.)
					oGridReg:SetValue("FILIAL"	,(cAliasQry)->FILIAL	,.T.)
					oGridReg:SetValue("EVENTO"	,(cAliasQry)->EVENTO	,.T.)
					oGridReg:SetValue("ID"		,(cAliasQry)->ID		,.T.)
					oGridReg:SetValue("PROTUL"	,cRecibo				,.T.)
					oGridReg:SetValue("DESCRIC"	,SubStr((cAliasQry)->DESCRIC,1,nTamDesc),.T.)
					oGridReg:SetValue("ALIAS"	,(cAliasQry)->ALIAS		,.T.)
					oGridReg:SetValue("RECNO"	,(cAliasQry)->RECNO		,.T.)

				(cAliasQry)->(DBSkip())
				EndDo

				oGridReg:SetNoInsertLine(.T.)
				oGridReg:SetLine(1)

				If oView <> Nil
					oView:Refresh("REGISTROS")
				EndIf

			EndIf

			(cAliasQry)->(DBCloseArea())

		EndIf

	EndIf

EndIf

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFSXBETab

Monta a consulta especifica para seleção do evento

@return Lógico, Indica se o usário clicou no OK ou Cancelar na tela da consulta

@author TOTVS
@since 05/09/2018
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Function TAFSXBETab()
Local oDlg			:= Nil
Local aCampos		:= {}
Local aSeek			:= {}
Local aEvtEsocial	:= {"S-1005","S-1010","S-1020","S-1030","S-1035","S-1040","S-1050","S-1060","S-1070","S-1080"}
Local nEvento		:= 0
Local cDscEvento	:= ""
Local lRet			:= .T.
Local cAliasTmp		:= GetNextAlias()
Local oBrowse		:= Nil
Local oTabEvtSel	:= Nil
Local oModel		:= FWModelActivate()

VAR_IXB := FWFldGet("EVENTO")

//-------------------------------------------
// Estrutura dos campos da tabela temporaria
//-------------------------------------------
AAdd(aCampos,{"EVENTO","C",006,0})
AAdd(aCampos,{"DESCRI","C",220,0})

//------------------------------
// Criação da tabela temporaria
//------------------------------
oTabEvtSel := FwTemporaryTable():New(cAliasTmp)
oTabEvtSel:SetFields(aCampos)
oTabEvtSel:AddIndex("1",{"EVENTO"})
oTabEvtSel:AddIndex("2",{"DESCRI"})
oTabEvtSel:Create()

//-------------------------------------------------------
// Alimenta a tabela temporária com os dados dos eventos
//-------------------------------------------------------
For nEvento := 1 To Len(aEvtEsocial)

	//---------------------------------
	// Obtem a descrição na tabela C8E
	//---------------------------------
	cDscEvento := GetAdvFVal("C8E","C8E_DESCRI",XFilial("C8E")+aEvtEsocial[nEvento],2,"") //C8E_FILIAL+C8E_CODIGO+DTOS(C8E_VALIDA)

	If RecLock(cAliasTmp,.T.)
		(cAliasTmp)->EVENTO	:= aEvtEsocial[nEvento]	//Código do evento
		(cAliasTmp)->DESCRI	:= cDscEvento			//Descrição do evento
		(cAliasTmp)->(MsUnLock())
	EndIf

Next nEvento

//-----------------------------------------------------------
// Montagem de janela para apresentar a mark no estilo popup
//-----------------------------------------------------------
DEFINE MSDIALOG oDlg TITLE "Eventos" From 0,0 To 600,800 OF oMainWnd PIXEL

//-------------------------------
// Define as pesquisas do browse
//-------------------------------
          //Título da pesquisa ,LookUp   ,Tipo de dados ,Tamanho ,Decimal ,Título do campo ,Máscara
AAdd(aSeek,{STR0023           ,{{STR0023 ,"C"           ,006     ,0       ,"Evento"        ,"@!"}} } ) //"Evento"
AAdd(aSeek,{STR0024           ,{{STR0024 ,"C"           ,220     ,0       ,"Descrição"     ,"@!"}} } ) //"Descrição"

//----------------------------------------------
// Instancia o objeto com a classe FWMBrowse
//----------------------------------------------
oBrowse := FWmBrowse():New()

//-----------------------------------
// Indica o alias que será utilizado
//-----------------------------------
oBrowse:SetAlias(cAliasTmp)

//------------------
// Titulo da Janela
//------------------
oBrowse:SetDescription("Seleção de Evento")

//-------------------------------------------------------------------------------------------------------------
// Ignorar a variavel private aRotina na construção da markbrowse, pois haverá somente um Confirmar e Cancelar
//-------------------------------------------------------------------------------------------------------------
oBrowse:SetIgnoreARotina(.T.)

//---------------------------
// Adiciona botoes na janela
//---------------------------
//                cTitle      ,xAction                                                                                                   ,uParam1 ,nOption
oBrowse:AddButton("Confirmar" ,{|| lRet := .T. , FwFldPut("EVENTO", (cAliasTmp)->EVENTO) ,VAR_IXB := (cAliasTmp)->EVENTO ,CloseBrowse()} ,        ,1      )
oBrowse:AddButton("Cancelar"  ,{|| lRet := .F. ,CloseBrowse()}                                                                           ,        ,1      )

//-----------------------------
// Define as colunas do Browse
//-----------------------------
//                   cTitulo     ,bData       ,cTipo ,cPicture ,nAlign ,nSize ,nDecimal ,lEdit ,bValid  ,lImage ,bDoubleClick ,cEditVar ,bHeaderClick ,lDel ,lDetail
oBrowse:SetColumns({{"Evento"    ,{|| EVENTO} ,"C"   ,"@!"     ,1      ,006   ,0        ,.F.   ,{||.T.} ,.F.    ,{||.T.}      ,NIL      ,{||.T.}      ,.F.  ,.F.    }})
oBrowse:SetColumns({{"Descrição" ,{|| DESCRI} ,"C"   ,"@!"     ,1      ,220   ,0        ,.F.   ,{||.T.} ,.F.    ,{||.T.}      ,NIL      ,{||.T.}      ,.F.  ,.F.    }})

//------------------------------------------------------------------
// Define a tela de apresentacao da mark, para nao ocupar toda tela
//------------------------------------------------------------------
oBrowse:SetOwner(oDlg)

//--------------------------------------------------
// Desabilita a apresentação dos detalhes no Browse
//--------------------------------------------------
oBrowse:DisableDetails()

//--------------------------------
// Remove o botão Imprimir Browse
//--------------------------------
oBrowse:DisableReport()

//---------------------------------------------------------------
// Remove o botão Filtro, pois não funciona em tabela temporaria
//---------------------------------------------------------------
oBrowse:DisableFilter()

//-----------------------------------------------
// Indica que o Browse utiliza tabela temporária
//-----------------------------------------------
oBrowse:SetTemporary(.T.)

//-----------------------------------------------
// Acao do duplo clique na linha do registro
//-----------------------------------------------
oBrowse:SetDoubleClick({|| lRet := .T., VAR_IXB := (cAliasTmp)->EVENTO, FwFldPut("EVENTO", (cAliasTmp)->EVENTO), CloseBrowse()})

//----------------------------------------------------------
// Habilita a utilização da pesquisa de registros no Browse
//----------------------------------------------------------
oBrowse:SetSeek(.T.,aSeek)

//--------------
// Ativa a tela
//--------------
oBrowse:Activate()

ACTIVATE MSDIALOg oDlg CENTERED

oTabEvtSel:Delete()

aSize(aEvtEsocial,0)
aEvtEsocial := Nil

Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFSXBChv

Funcao para montagem dinamica de consulta padrao conforme o evento definido no
campo "Evento" e obtencao da chave do evento de tabela conforme determinado pelo
Governo.

@return Lógico, Indica se o usário clicou no OK ou Cancelar na tela da consulta 

@author TOTVS
@since 01/11/2018
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Function TAFSXBChv()
Local oModel	:= FWModelActivate()
Local cEvento	:= oModel:GetValue("PARAMETROS","EVENTO")
Local lRet		:= .T.
Local cAlias	:= ""
Local cRetorno	:= ""

//------------------------------------------------------
// Tabela de Estabelecimentos
// tpInsc=1;nrInsc=11223344556677...
// C92_TPINSC - C92_NRINSC
//------------------------------------------------------
If cEvento == "S-1005"
	cAlias		:= "C92"
	cRetorno	:= '"tpInsc=" + C92->C92_TPINSC + ";" + "nrInsc=" + AllTrim(C92->C92_NRINSC)'

//------------------------------------------------------
// Rubricas
// codRubr=1;ideTabRubr=1
// C8R_CODRUB C8R_IDTBRU
//------------------------------------------------------
ElseIf cEvento == "S-1010"
	cAlias		:= "C8R"
	cRetorno	:= '"codRubr=" + AllTrim(C8R->C8R_CODRUB) + ";" + "ideTabRubr=" + AllTrim(C8R->C8R_IDTBRU)'

//------------------------------------------------------
// Tabela de Lotações
// codLotacao=001
// C99_CODIGO
//------------------------------------------------------
ElseIf cEvento == "S-1020"
	cAlias		:= "C99"
	cRetorno	:= '"codLotacao=" + AllTrim(C99->C99_CODIGO)'

//------------------------------------------------------
// Cargos
// codCargo=001
// C8V_CODIGO
//------------------------------------------------------
ElseIf cEvento == "S-1030"
	cAlias		:= "C8V"
	cRetorno	:= '"codCargo=" + AllTrim(C8V->C8V_CODIGO)'

//------------------------------------------------------
// Tabela de Carreiras Públicas
// CodCarreira=001
// T5K_CODIGO
//------------------------------------------------------
ElseIf cEvento == "S-1035"
	cAlias		:= "T5K"
	cRetorno	:= '"CodCarreira=" + AllTrim(T5K->T5K_CODIGO)'

//------------------------------------------------------
// Funções
// codFuncao=001
// C8X_CODIGO
//------------------------------------------------------
ElseIf cEvento == "S-1040"
	cAlias		:= "C8X"
	cRetorno	:= '"codFuncao=" + AllTrim(C8X->C8X_CODIGO)'

//------------------------------------------------------
// Horários/Turnos de Trabalho
// codHorContrat=001
// C90_CODIGO
//------------------------------------------------------
ElseIf cEvento == "S-1050"
	cAlias		:= "C90"
	cRetorno	:= '"codHorContrat=" + AllTrim(C90->C90_CODIGO)'

//------------------------------------------------------
// Ambientes de Trabalho
// codAmb=001
// T04_CODIGO
//------------------------------------------------------
ElseIf cEvento == "S-1060"
	cAlias		:= "T04"
	cRetorno	:= '"codAmb=" + AllTrim(T04->T04_CODIGO)'

//------------------------------------------------------
// Processos Referenciados
// tpProc=1;nrProc=12345678...
// C1G_TPPROC C1G_NUMPRO
//------------------------------------------------------
ElseIf cEvento == "S-1070"
	cAlias		:= "C1G"
	cRetorno	:= '"tpProc=" + C1G->C1G_TPPROC + ";" + "nrProc=" + AllTrim(C1G->C1G_NUMPRO)'

//------------------------------------------------------
// Operadores Portuários
// cnpjOpPortuario=111222333...
// C8W_CNPJOP
//------------------------------------------------------
ElseIf cEvento == "S-1080"
	cAlias		:= "C8W"
	cRetorno	:= '"cnpjOpPortuario=" + AllTrim(C8W->C8W_CNPJOP)'

EndIf

//-------------------------------------
// Apresenta a tela de consulta padrão
//-------------------------------------
If !Empty(cAlias)

	//              uPar1,uPar2,uPar3,cAlias ,cCampoRet,uPar6,lOnlyView,cVar,uPar9,uContent
	lRet := ConPad1(     ,     ,     ,cAlias ,         ,     ,.T.      ,    ,     ,        )

	//-------------------------------------------------
	// Alimenta variavel utilizada como retorno no SXB
	//-------------------------------------------------
	VAR_IXB := &(cRetorno)

EndIf

Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA519Grv

Grava o número do recibo obtido do governo

@param objeto, oModel, Modelo de dados rotina

@return Lógico, Indica se a gravação ocorreu com sucesso

@author TOTVS
@since 01/11/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Function TAFA519Grv(oModel)
Local lRet			:= .T.
Local oModReg		:= oModel:GetModel("REGISTROS")
Local cEvento		:= oModel:GetValue("PARAMETROS","EVENTO")
Local nRegistros	:= 0
Local aEvtEsocial	:= TAFRotinas(,,.T.,2)
Local nPosEvt		:= 0
Local cAlias		:= ""

For nRegistros := 1 To oModReg:Length()

	If oModReg:GetValue("OK")

		cAlias := oModReg:GetValue("ALIAS")

		(cAlias)->(DBGoTo(oModReg:GetValue("RECNO")))

		RecLock(cAlias,.F.)
			(cAlias)->(&(cAlias +"_PROTUL")) := oModReg:GetValue("PROTUL")
		(cAlias)->(MsUnlock())

	EndIf

Next nRegistros

aSize(aEvtEsocial,0)
aEvtEsocial := Nil

Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFVisReg

Apresenta os detalhes do registro do painel REGISTROS

@author TOTVS
@since 01/11/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Static Function TAFVisReg()
Local oModel		:= FWModelActivate()
Local oModReg		:= oModel:GetModel("REGISTROS")
Local nRecno		:= oModReg:GetValue("RECNO")
Local cAlias		:= oModReg:GetValue("ALIAS")
Local lContinua		:= .T.

Private cCadastro := "Visualizar" //Variavel necessária pela rotina AXVisual

//--------------------------------------
// Valida se há dados no grid REGISTROS
//--------------------------------------
If oModReg:Length() == 0 .Or. Empty(oModReg:GetValue("OPER"))
	lContinua := .F.
	Help(" ",1,"TAFVisReg",,STR0025,1,0,,,,,,{STR0026 }) //'Não há dados no painel "Registros" para exibição.'###'Preencha os campos do painel "Parâmetros" e clique no botão "Consultar Governo".'
EndIf

//--------------------------------------------
// Apresenta os dados do registro posicionado
//--------------------------------------------
If lContinua

	(cAlias)->(DBGoTo(nRecno))

	//       cAlias ,nReg   ,nOpc ,aAcho ,nColMens ,cMensagem ,cFunc ,aButtons ,lMaximized
	AXVisual(cAlias ,nRecno ,2    ,      ,         ,          ,      ,         ,          )

EndIf

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFConsDis

Retornar a quantidade de consultas disponiveis. 
O governo limita em 10 consultas por dia

@return numerico, quantidade de consultas disponiveis

@author TOTVS
@since 01/11/2018
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Static Function TAFConsDis()
Local nRet := 10
Local nQtd := 0

DBSelectArea("V2N")
V2N->(DBSetOrder(1)) //V2N_FILIAL+V2N_DATA+V2N_HORA

If V2N->(DBSeek(XFilial("V2N")+DToS(dDataBase)))

	While V2N->(!EOF()) .And. V2N->(V2N_FILIAL+DToS(V2N_DATA)) == XFilial("V2N")+DToS(dDataBase) 
		nQtd++
	V2N->(DBSkip())
	EndDo

EndIf

nRet -= nQtd

Return nRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TSSeSocBX
Consome o servico de consulta do TSS

@author TOTVS
@since 01/11/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Static Function TSSeSocBX()
Local aRet			:= {}
Local aRegs			:= {}
Local oSocial		:= Nil
Local cUrl			:= AllTrim(TafGetUrlTSS())
Local cAmbte		:= SuperGetMv('MV_TAFAMBE',.F.,"2")
Local cIdEnt		:= TAFRIdEnt()
Local cUserTk		:= "TOTVS"
Local cTpCons		:= ""
Local cXML			:= ""
Local ctpInsc		:= "" //1 – CNPJ|2 – CPF 
Local cnrInsc		:= ""
Local oModel		:= FWModelActivate()
Local cTpEvento		:= oModel:GetValue("PARAMETROS","TPEVENTO")
Local cEvento		:= oModel:GetValue("PARAMETROS","EVENTO")
Local cDtTimeDe		:= Transform( DToS(oModel:GetValue("PARAMETROS","DATADE"))  + oModel:GetValue("PARAMETROS","HORADE")  ,"@R 9999-99-99T99:99:99")
Local cDtTimeAte	:= Transform( DToS(oModel:GetValue("PARAMETROS","DATAATE")) + oModel:GetValue("PARAMETROS","HORAATE") ,"@R 9999-99-99T99:99:99")
Local cPerApu		:= oModel:GetValue("PARAMETROS","PERAPU")
Local cCPF			:= oModel:GetValue("PARAMETROS","CPFTRABA")
Local cChvEvento	:= oModel:GetValue("PARAMETROS","CHVEVENTO")
Local lRetWS		:= .T.
Local lEmpregad		:= .F.
Local lTabela		:= .F.
Local lTrabalhad	:= .F.
Local cError		:= ""
Local cWarning		:= ""
Local cCodRet		:= ""
Local cDscRet		:= ""
Local cDtHrRet		:= ""
Local cQtdRet		:= ""
Local nX			:= 0
Local cXMLRet		:= ""
Local lContinua		:= .T.

Private oXml		:= Nil //Declarado como private para funcionamento da função Type()

If !("TSSWSSOCIAL.APW" $ Upper(cUrl))
	cUrl += "TSSWSSOCIAL.apw"
EndIf

If cTpEvento == "1"
	lEmpregad	:= .T.
	cTpCons		:= 'EMPREGADOR'
	cEvento		:= 'S-1000'
	cPerApu		:= SubStr(cPerApu,3,4) + "-" + SubStr(cPerApu,1,2)

ElseIf cTpEvento == "2"
	lTabela		:= .T.
	cTpCons		:= 'TABELA'

ElseIf cTpEvento == "3"
	lTrabalhad	:= .T.
	cTpCons		:= 'TRABALHADOR'

EndIf

//----------------------------------------------------------
// Obtem o tipo de inscrição do empregador
// Caso o emissor for Produtor Rural, deve verificar o CPF
//----------------------------------------------------------
cnrInsc := Posicione("C1E",3,xFilial("C1E")+PadR( SM0->M0_CODFIL, TamSX3( "C1E_FILTAF" )[1] )+"1","C1E_NRCPF")

If Empty(cnrInsc)
	cnrInsc		:= SM0->M0_CGC
	ctpInsc	:= "1" //CNPJ
Else
	ctpInsc	:= "2" //CPF
Endif

//--------------------------------
// Montagem do XML para consulta
//--------------------------------
cXML := '<?xml version="1.0" encoding="utf-8"?>'

If lEmpregad
	cXML += '<eSocial xmlns="http://www.esocial.gov.br/schema/consulta/identificadores-eventos/empregador/v1_0_0">'
ElseIf lTabela
	cXML += '<eSocial xmlns="http://www.esocial.gov.br/schema/consulta/identificadores-eventos/tabela/v1_0_0">'
ElseIf lTrabalhad
	cXML += '<eSocial xmlns="http://www.esocial.gov.br/schema/consulta/identificadores-eventos/trabalhador/v1_0_0">'
EndIf

cXML += 	'<consultaIdentificadoresEvts>'
cXML += 		'<ideEmpregador>'
cXML += 			'<tpInsc>' + ctpInsc + '</tpInsc>'
cXML += 			'<nrInsc>' + cnrInsc + '</nrInsc>'
cXML += 		'</ideEmpregador>'

//-------------------
// EVENTO EMPREGADOR
//-------------------
If lEmpregad
	cXML += 	'<consultaEvtsEmpregador>'
	cXML += 		'<tpEvt>' + cEvento + '</tpEvt>'
	cXML += 		'<perApur>' + cPerApu + '</perApur>'
	cXML += 	'</consultaEvtsEmpregador>'

//-------------------
// EVENTO TABELA
//-------------------
ElseIf lTabela
	cXML += 	'<consultaEvtsTabela>'
	cXML += 		'<tpEvt>' + cEvento + '</tpEvt>'
	cXML += 		'<chEvt>' + cChvEvento + '</chEvt>'
	cXML += 		'<dtIni>' + cDtTimeDe + '</dtIni>'
	cXML += 		'<dtFim>' + cDtTimeAte + '</dtFim>'
	cXML += 	'</consultaEvtsTabela>'

//--------------------
// EVENTO TRABALHADOR
//--------------------
ElseIf lTrabalhad
   	cXML += 	'<consultaEvtsTrabalhador>'
   	cXML += 		'<cpfTrab>' + cCPF + '</cpfTrab>'
   	cXML += 		'<dtIni>' + cDtTimeDe + '</dtIni>'
   	cXML += 		'<dtFim>' + cDtTimeAte + '</dtFim>'
   	cXML += 	'</consultaEvtsTrabalhador>'

EndIf

cXML += 	'</consultaIdentificadoresEvts>'
cXML += '</eSocial>'

oSocial := WSTSSWSSOCIAL():New()

oSocial:_Url := cUrl

oSocial:oWSENTCONSIDENT:cAMBIENTE		:= cAmbte
oSocial:oWSENTCONSIDENT:cID_ENT			:= cIdEnt
oSocial:oWSENTCONSIDENT:cUSERTOKEN		:= cUserTk
oSocial:oWSENTCONSIDENT:cTIPOCONSULTA	:= cTpCons
oSocial:oWSENTCONSIDENT:cXML			:= cXML

lRetWS := oSocial:ConsultaIdentificadores()

If ValType(lRetWS) != "L"
	lContinua := .F.
	Help(" ",1,"TSSeSocBX",,STR0027,1,0,,,,,,{STR0028}) //"Erro no retorno do governo."###"Entre em contato com o suporte técnico para avaliação."
EndIf

If ValType(oSocial:oWSCONSULTAIDENTIFICADORESRESULT:lRESULT) == "U"
	lContinua := .F.
	Help(" ",1,"TSSeSocBX",,STR0027,1,0,,,,,,{STR0028}) //"Erro no retorno do governo."###"Entre em contato com o suporte técnico para avaliação."
EndIf

If !oSocial:oWSCONSULTAIDENTIFICADORESRESULT:lRESULT
	lContinua := .F.
	Help(" ",1,"TSSeSocBX",,STR0027,1,0,,,,,,{STR0028}) //"Erro no retorno do governo."###"Entre em contato com o suporte técnico para avaliação."
EndIf


If lContinua
	//------------------------------------------------------------------------
	// Ponto de entrada para o Tester conseguir simular o retorno do governo,
	// devido indisponibilidade e limitação de quantidade de consultas
	//------------------------------------------------------------------------
	If ExistBlock("TAFXML")
		cXMLRet := ExecBlock("TAFXML",.f.,.f.)
	Else
		cXMLRet := oSocial:oWSCONSULTAIDENTIFICADORESRESULT:cXMLRESULT
	EndIf

	oXml := XmlParser(cXMLRet , "_", @cError, @cWarning )

	If oXml == Nil .Or. !Empty(cError) .Or. !Empty(cWarning)
		lContinua := .F.
		Help(" ",1,"TSSeSocBX",,STR0029,1,0,,,,,,{STR0028}) //"Erro na mensagem recebida pela consulta."###"Entre em contato com o suporte técnico para avaliação."
	EndIf

	If lContinua
		//-----------------------------------------------------------------------
		// Trata para o objeto apresentar somente o trecho da estrutura em comum
		//-----------------------------------------------------------------------
		If lEmpregad
			oXml := oXml:_ConsultarIdentificadoresEventosEmpregadorResponse:_ConsultarIdentificadoresEventosEmpregadorResult:_ESOCIAL:_RETORNOCONSULTAIDENTIFICADORESEVTS

		ElseIf lTabela
			oXml := oXml:_CONSULTARIDENTIFICADORESEVENTOSTABELARESPONSE:_CONSULTARIDENTIFICADORESEVENTOSTABELARESULT:_ESOCIAL:_RETORNOCONSULTAIDENTIFICADORESEVTS

		ElseIf lTrabalhad
			oXml := oXml:_ConsultarIdentificadoresEventosTrabalhadorResponse:_ConsultarIdentificadoresEventosTrabalhadorResult:_ESOCIAL:_RETORNOCONSULTAIDENTIFICADORESEVTS

		EndIf

		//--------------------------------------------
		// Código de resposta do processo de consulta
		//--------------------------------------------
		If Type("oXml:_STATUS:_CDRESPOSTA:TEXT") <> "U"
			cCodRet := oXml:_STATUS:_CDRESPOSTA:TEXT
		EndIf

		//------------------------------------------------
		// Descrição correspondente ao código de resposta
		//------------------------------------------------
		If Type("oXml:_STATUS:_DESCRESPOSTA:TEXT") <> "U"
			cDscRet := oXml:_STATUS:_DESCRESPOSTA:TEXT
		EndIf

		//--------------------------------------------------------------------
		// Quantidade de eventos encontrados de acordo com o filtro informado
		//--------------------------------------------------------------------
		If Type("oXml:_RETORNOIDENTIFICADORESEVTS:_QTDETOTEVTSCONSULTA:TEXT") <> "U"
			cQtdRet := oXml:_RETORNOIDENTIFICADORESEVTS:_QTDETOTEVTSCONSULTA:TEXT
		EndIf

		//-----------------------------------------------------------------------------------------------------------------------------------
		// Data/hora do último evento retornado. Este valor deve ser utilizado na tag dtIni do filtro da próxima pesquisa no caso em que o
		// valor retornado na tag qtdeTotEvtsConsulta for maior que 50, para ter acesso aos próximos eventos que atendam ao filtro informado
		//-----------------------------------------------------------------------------------------------------------------------------------
		If Type("oXml:_RETORNOIDENTIFICADORESEVTS:_DHULTIMOEVTRETORNADO:TEXT") <> "U"
			cDtHrRet := oXml:_RETORNOIDENTIFICADORESEVTS:_DHULTIMOEVTRETORNADO:TEXT
		EndIf

		//-------------------------------------------------------------------------------------------------
		// Os registros retornados na consulta (governo retorna os 50 primeiros que atendam os parametros)
		//-------------------------------------------------------------------------------------------------
		If Type("oXml:_RETORNOIDENTIFICADORESEVTS:_IDENTIFICADORESEVTS:_IDENTIFICADOREVT") == "A"
			For nX := 1 To Len(oXml:_RETORNOIDENTIFICADORESEVTS:_IDENTIFICADORESEVTS:_IDENTIFICADOREVT)
				Aadd(aRegs,{;
				oXml:_RETORNOIDENTIFICADORESEVTS:_IDENTIFICADORESEVTS:_IDENTIFICADOREVT[nX]:_id:TEXT ,;
				oXml:_RETORNOIDENTIFICADORESEVTS:_IDENTIFICADORESEVTS:_IDENTIFICADOREVT[nX]:_nrRec:TEXT}) //ID / Recibo
			Next nX
		EndIf

		//---------------------------
		// Alimenta array de retorno
		//---------------------------
		Aadd(aRet, cCodRet	)
		Aadd(aRet, cDscRet	)
		Aadd(aRet, cQtdRet	)
		Aadd(aRet, cDtHrRet	)
		Aadd(aRet, aRegs	)

	EndIf

EndIf

Return aRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFStruct

Monta a estrutura dos campos do Model ou View, devido a rotina nao ter base no
dicionario padrao

@param   Numerico, nTipo, Tipo da estrutura que será montada. 1=Model;2=View.
@param   Caracter, cID, Identificador do SubModelo.

@return  Objeto, Estrutura de campo (Model ou View) do submodelo desejado.

@author TOTVS
@since 01/11/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Static Function TAFStruct(nTipo,cID)
Local oStruct := Nil

//----------------------------------------------------------------------------
// Instancia o objeto conforme a estrutura de campos desejada (Model ou View)
//----------------------------------------------------------------------------
If nTipo == 1
	oStruct := FWFormModelStruct():New()
ElseIf nTipo == 2
	oStruct := FWFormViewStruct():New()
EndIf

//----------------------------
// Adiciona campos e gatilhos
//----------------------------
If cID == "PARAMETROS"

	If nTipo == 1
		//               cTitulo ,cTooltip ,cIdField    ,cTipo ,nTamanho ,nDecimal ,bValid                                                        ,bWhen                                             ,aValues           ,lObrigat ,bInit ,lKey ,lNoUpd ,lVirtual ,cValid
		oStruct:AddField(STR0030 ,STR0030  ,"TPEVENTO"  ,"C"   ,01       ,0        ,{ || .T. }                                                    ,                                                  ,{" ","1","2","3"} ,.T.      ,      ,     ,       ,         ,      ) //"Tipo do Evento"
		oStruct:AddField(STR0023 ,STR0023  ,"EVENTO"    ,"C"   ,06       ,0        ,FWBuildFeature(STRUCT_FEATURE_VALID,'TAFValPar("EVENTO")'   ) ,{|oModPar| oModPar:GetValue("TPEVENTO") == "2" }  ,                  ,.F.      ,      ,     ,       ,         ,      ) //"Evento"
		oStruct:AddField(STR0031 ,STR0031  ,"DATADE"    ,"D"   ,08       ,0        ,FWBuildFeature(STRUCT_FEATURE_VALID,'TAFValPar("DATADE")'   ) ,{|oModPar| oModPar:GetValue("TPEVENTO") $ "2|3" } ,                  ,.F.      ,      ,     ,       ,         ,      ) //"Data De"
		oStruct:AddField(STR0032 ,STR0032  ,"DATAATE"   ,"D"   ,08       ,0        ,FWBuildFeature(STRUCT_FEATURE_VALID,'TAFValPar("DATAATE")'  ) ,{|oModPar| oModPar:GetValue("TPEVENTO") $ "2|3" } ,                  ,.F.      ,      ,     ,       ,         ,      ) //"Data Até"
		oStruct:AddField(STR0033 ,STR0033  ,"HORADE"    ,"C"   ,06       ,0        ,FWBuildFeature(STRUCT_FEATURE_VALID,'TAFValPar("HORADE")'   ) ,{|oModPar| oModPar:GetValue("TPEVENTO") $ "2|3" } ,                  ,.F.      ,      ,     ,       ,         ,      ) //"Hora De"
		oStruct:AddField(STR0034 ,STR0034  ,"HORAATE"   ,"C"   ,06       ,0        ,FWBuildFeature(STRUCT_FEATURE_VALID,'TAFValPar("HORAATE")'  ) ,{|oModPar| oModPar:GetValue("TPEVENTO") $ "2|3" } ,                  ,.F.      ,      ,     ,       ,         ,      ) //"Hora Até"
		oStruct:AddField(STR0035 ,STR0035  ,"PERAPU"    ,"C"   ,06       ,0        ,FWBuildFeature(STRUCT_FEATURE_VALID,'TAFValPar("PERAPU")'   ) ,{|oModPar| oModPar:GetValue("TPEVENTO") == "1" }  ,                  ,.F.      ,      ,     ,       ,         ,      ) //"Mês-Ano"
		oStruct:AddField(STR0036 ,STR0036  ,"CPFTRABA"  ,"C"   ,11       ,0        ,FWBuildFeature(STRUCT_FEATURE_VALID,'TAFValPar("CPFTRABA")' ) ,{|oModPar| oModPar:GetValue("TPEVENTO") == "3" }  ,                  ,.F.      ,      ,     ,       ,         ,      ) //"CPF do Trabalhador"
		oStruct:AddField(STR0037 ,STR0037  ,"CHVEVENTO" ,"C"   ,50       ,0        ,{ || .T. }                                                    ,{|oModPar| oModPar:GetValue("TPEVENTO") == "2" }  ,                  ,.F.      ,      ,     ,       ,         ,      ) //"Chave do Evento"

		//                 cIdField   ,cTargetIdField ,bPre                                                  ,bSetValue
		oStruct:AddTrigger('TPEVENTO' ,'EVENTO'       ,{|| .T. }                                             ,{|| "" } )
		oStruct:AddTrigger('TPEVENTO' ,'DATADE'       ,{|| .T. }                                             ,{|| STOD("") } )
		oStruct:AddTrigger('TPEVENTO' ,'DATAATE'      ,{|| .T. }                                             ,{|| STOD("") } )
		oStruct:AddTrigger('TPEVENTO' ,'HORADE'       ,{|| .T. }                                             ,{|oModPar| If(oModPar:GetValue("TPEVENTO") $ "2|3","000000","") } )
		oStruct:AddTrigger('TPEVENTO' ,'HORAATE'      ,{|| .T. }                                             ,{|oModPar| If(oModPar:GetValue("TPEVENTO") $ "2|3","235959","") } )
		oStruct:AddTrigger('TPEVENTO' ,'PERAPU'       ,{|| .T. }                                             ,{|oModPar| If(oModPar:GetValue("TPEVENTO") == "1",STRTran(SubStr(DToC(dDataBase),4,7),"/",""),"") } )
		oStruct:AddTrigger('TPEVENTO' ,'CPFTRABA'     ,{|| .T. }                                             ,{|| "" } )
		oStruct:AddTrigger('TPEVENTO' ,'CHVEVENTO'    ,{|| .T. }                                             ,{|| "" } )
		oStruct:AddTrigger('DATAATE'  ,'HORAATE'      ,{|oModPar| oModPar:GetValue("DATAATE") == dDataBase } ,{|| "" } )
		oStruct:AddTrigger('EVENTO'   ,'CHVEVENTO'    ,{|| .T. }                                             ,{|| "" } )

	ElseIf nTipo == 2
		//               cIdField    ,cOrdem ,cTitulo ,cDescric ,aHelp ,cType (Combo/Get/Check) ,cPicture            ,bPictVar ,cLookUp  ,lCanChange ,cFolder , cGroup ,aComboValues                  ,nMaxLenCombo ,cIniBrow ,lVirtual ,cPictVar ,lInsertLine ,nWidth
		oStruct:AddField('TPEVENTO'  ,'01'   ,STR0030 ,STR0030  ,      ,'C'                     ,"@!"                ,         ,''       ,           ,        ,        ,{" ",STR0038,STR0039,STR0040} ,             ,         ,         ,         ,            ,       ) //'Tipo do Evento'###"1=Empregador"###"2=Tabela"###"3=Trabalhador"
		oStruct:AddField('EVENTO'    ,'02'   ,STR0023 ,STR0023  ,      ,'G'                     ,"@!"                ,         ,'TAFETB' ,           ,        ,        ,                              ,             ,         ,         ,         ,            ,       ) //'Evento'
		oStruct:AddField('DATADE'    ,'03'   ,STR0031 ,STR0031  ,      ,'G'                     ,"@!"                ,         ,''       ,           ,        ,        ,                              ,             ,         ,         ,         ,            ,       ) //'Data De'
		oStruct:AddField('DATAATE'   ,'04'   ,STR0032 ,STR0032  ,      ,'G'                     ,"@!"                ,         ,''       ,           ,        ,        ,                              ,             ,         ,         ,         ,            ,       ) //'Data Até'
		oStruct:AddField('HORADE'    ,'05'   ,STR0033 ,STR0033  ,      ,'G'                     ,"@R 99:99:99"       ,         ,''       ,           ,        ,        ,                              ,             ,         ,         ,         ,            ,       ) //'Hora De'
		oStruct:AddField('HORAATE'   ,'06'   ,STR0034 ,STR0034  ,      ,'G'                     ,"@R 99:99:99"       ,         ,''       ,           ,        ,        ,                              ,             ,         ,         ,         ,            ,       ) //'Hora Até'
		oStruct:AddField('PERAPU'    ,'07'   ,STR0035 ,STR0035  ,      ,'G'                     ,"@R 99-9999"        ,         ,''       ,           ,        ,        ,                              ,             ,         ,         ,         ,            ,       ) //'Mês-Ano'
		oStruct:AddField('CPFTRABA'  ,'08'   ,STR0036 ,STR0036  ,      ,'G'                     ,"@R 999.999.999-99" ,         ,'C9VE'   ,           ,        ,        ,                              ,             ,         ,         ,         ,            ,       ) //'CPF do Trabalhador'
		oStruct:AddField('CHVEVENTO' ,'09'   ,STR0037 ,STR0037  ,      ,'G'                     ,"@!"                ,         ,'TAFCHV' ,           ,        ,        ,                              ,             ,         ,         ,         ,            ,       ) //'Chave do Evento'

	EndIf

ElseIf cID == "REGISTROS"

	If nTipo == 1
		//               cTitulo    ,cTooltip   ,cIdField  ,cTipo ,nTamanho       ,nDecimal ,bValid     ,bWhen ,aValues ,lObrigat ,bInit ,lKey ,lNoUpd ,lVirtual ,cValid
		oStruct:AddField(""         ,""         ,"OK"      ,"L"   ,01             ,0        ,{ || .T. } ,      ,        ,.F.      ,      ,     ,       ,         ,      )
		oStruct:AddField(STR0041    ,STR0041    ,"FILIAL"  ,"C"   ,FWSizeFilial() ,0        ,{ || .T. } ,      ,        ,.F.      ,      ,     ,       ,         ,      ) //"Filial"
		oStruct:AddField(STR0023   	,STR0023   	,"EVENTO"  ,"C"   ,06             ,0        ,{ || .T. } ,      ,        ,.F.      ,      ,     ,       ,         ,      ) //"Evento"
		oStruct:AddField("ID"       ,"ID"       ,"ID"      ,"C"   ,36             ,0        ,{ || .T. } ,      ,        ,.F.      ,      ,     ,       ,         ,      )
		oStruct:AddField(STR0042    ,STR0042    ,"PROTUL"  ,"C"   ,44             ,0        ,{ || .T. } ,      ,        ,.F.      ,      ,     ,       ,         ,      ) //"Recibo"
		oStruct:AddField("Descricao","Descricao","DESCRIC" ,"C"   ,100            ,0        ,{ || .T. } ,      ,        ,.F.      ,      ,     ,       ,         ,      )
		oStruct:AddField("Alias"    ,"Alias"    ,"ALIAS"   ,"C"   ,03             ,0        ,{ || .T. } ,      ,        ,.F.      ,      ,     ,       ,         ,      )
		oStruct:AddField("Recno"    ,"Recno"    ,"RECNO"   ,"N"   ,04             ,0        ,{ || .T. } ,      ,        ,.F.      ,      ,     ,       ,         ,      )

	ElseIf nTipo == 2
		//               cIdField  ,cOrdem ,cTitulo    ,cDescric   ,aHelp ,cType (Combo/Get/Check) ,cPicture ,bPictVar ,cLookUp ,lCanChange ,cFolder , cGroup ,aComboValues      ,nMaxLenCombo ,cIniBrow ,lVirtual ,cPictVar ,lInsertLine ,nWidth
		oStruct:AddField('OK'      ,'01'   ,''         ,''         ,      ,'Check'                 ,""       ,         ,''      ,           ,        ,        ,                  ,             ,         ,         ,         ,            ,       )
		oStruct:AddField('FILIAL'  ,'02'   ,STR0041    ,STR0041    ,      ,'G'                     ,"@!"     ,         ,''      ,           ,        ,        ,                  ,             ,         ,         ,         ,            ,       ) //'Filial'
		oStruct:AddField('EVENTO'  ,'03'   ,STR0023    ,STR0023    ,      ,'G'                     ,"@!"     ,         ,''      ,           ,        ,        ,                  ,             ,         ,         ,         ,            ,       ) //'Evento'
		oStruct:AddField('ID'      ,'04'   ,'ID'       ,'ID'       ,      ,'G'                     ,"@!"     ,         ,''      ,           ,        ,        ,                  ,             ,         ,         ,         ,            ,       )
		oStruct:AddField('PROTUL'  ,'05'   ,STR0042    ,STR0042    ,      ,'G'                     ,"@!"     ,         ,''      ,           ,        ,        ,                  ,             ,         ,         ,         ,            ,       ) //'Recibo'
		oStruct:AddField('DESCRIC' ,'06'   ,'Descrição','Descrição',      ,'G'                     ,""       ,         ,''      ,           ,        ,        ,                  ,             ,         ,         ,         ,            ,       )

	EndIf

ElseIf cID == "CONTADORES"

	If nTipo == 1
		//               cTitulo ,cTooltip ,cIdField   ,cTipo ,nTamanho ,nDecimal ,bValid ,bWhen ,aValues ,lObrigat ,bInit             ,lKey ,lNoUpd ,lVirtual ,cValid
		oStruct:AddField(STR0046 ,STR0046  ,"CONSDISP" ,"N"   ,2        ,0        ,       ,      ,        ,.F.      ,{|| TAFConsDis()} ,     ,       ,         ,      ) //"Consultas Restantes"
		oStruct:AddField(STR0047 ,STR0047  ,"REGAPRE"  ,"N"   ,9        ,0        ,       ,      ,        ,.F.      ,                  ,     ,       ,         ,      ) //"Registros Processados"
		oStruct:AddField(STR0048 ,STR0048  ,"REGDIS"   ,"N"   ,9        ,0        ,       ,      ,        ,.F.      ,                  ,     ,       ,         ,      ) //"Registros Disponiveis"

	ElseIf nTipo == 2
		//               cIdField   ,cOrdem ,cTitulo ,cDescric ,aHelp ,cType (Combo/Get/Check) ,cPicture ,bPictVar ,cLookUp  ,lCanChange ,cFolder , cGroup ,aComboValues ,nMaxLenCombo ,cIniBrow ,lVirtual ,cPictVar ,lInsertLine ,nWidth
		oStruct:AddField('CONSDISP' ,'01'   ,STR0046 ,STR0046  ,      ,'G'                     ,"@!"     ,         ,''       ,.F.        ,        ,        ,             ,             ,         ,         ,         ,            ,       ) //'Consultas Restantes'
		oStruct:AddField('REGAPRE'  ,'02'   ,STR0047 ,STR0047  ,      ,'G'                     ,"@!"     ,         ,''       ,.F.        ,        ,        ,             ,             ,         ,         ,         ,            ,       ) //'Registros Processados'
		oStruct:AddField('REGDIS'   ,'03'   ,STR0048 ,STR0048  ,      ,'G'                     ,"@!"     ,         ,''       ,.F.        ,        ,        ,             ,             ,         ,         ,         ,            ,       ) //'Registros Disponiveis'

	EndIf

EndIf

Return oStruct

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFValPar

Funcao com as validacoes dos campos do submodelo PARAMETROS

@param   Caracter, cCpoPar, Identificador do campo do SubModelo PARAMETROS.

@return  Lógico, Indica se o valor digitado no campo é válido.

@author TOTVS
@since 01/11/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Function TAFValPar(cCpoPar)
Local lRet			:= .T.
Local oModel		:= FWModelActivate()
Local xConteudo		:= oModel:GetValue("PARAMETROS",cCpoPar)
Local cMes			:= ""
Local cAno			:= ""
Local cQry			:= ""

If !Empty(xConteudo)

	If cCpoPar == "EVENTO"
		If !(xConteudo $ "S-1005|S-1010|S-1020|S-1030|S-1035|S-1040|S-1050|S-1060|S-1070|S-1080")
			lRet := .F.
			Help(" ",1,"REGNOIS")
		EndIf

	ElseIf cCpoPar == "DATADE"

		If !Empty(oModel:GetValue("PARAMETROS","DATAATE"))

			If xConteudo > oModel:GetValue("PARAMETROS","DATAATE") 
				lRet := .F.
				Help(" ",1,"TAFValPar",,STR0049,1,0,,,,,,{STR0050}) //"Data inválida."###"A data inicial não pode ser posterior a data final."
			EndIf

			If ABS(xConteudo - oModel:GetValue("PARAMETROS","DATAATE")) > 31 
				lRet := .F.
				Help(" ",1,"TAFValPar",,STR0049,1,0,,,,,,{STR0051}) //"Data inválida."###"O periodo para pesquisa não pode ser maior que 31 dias."
			EndIf

		EndIf

	ElseIf cCpoPar == "DATAATE"

		If !Empty(oModel:GetValue("PARAMETROS","DATADE"))

			If xConteudo < oModel:GetValue("PARAMETROS","DATADE") 
				lRet := .F.
				Help(" ",1,"TAFValPar",,STR0049,1,0,,,,,,{STR0052}) //"Data inválida."###"A data final deve ser posterior a data inicial."

			ElseIf ABS(xConteudo - oModel:GetValue("PARAMETROS","DATADE")) > 31 
				lRet := .F.
				Help(" ",1,"TAFValPar",,STR0049,1,0,,,,,,{STR0051}) //"Data inválida."###"O periodo para pesquisa não pode ser maior que 31 dias."

			ElseIf xConteudo > dDataBase 
				lRet := .F.
				Help(" ",1,"TAFValPar",,STR0049,1,0,,,,,,{STR0082}) //"Data inválida."###"A data final não pode ser superior a data atual."

			EndIf

		EndIf

	ElseIf cCpoPar == "HORADE"

		If	!Empty(oModel:GetValue("PARAMETROS","HORAATE")) .And.;
			!Empty(oModel:GetValue("PARAMETROS","DATADE")) .And.;
			!Empty(oModel:GetValue("PARAMETROS","DATAATE")) .And.;
			oModel:GetValue("PARAMETROS","DATADE") == oModel:GetValue("PARAMETROS","DATAATE") .And.;
			xConteudo > oModel:GetValue("PARAMETROS","HORAATE")

			lRet := .F.
			Help(" ",1,"TAFValPar",,STR0053,1,0,,,,,,{STR0054}) //"Hora inválida."###"A hora inicial deve ser anterior ou igual a hora final, quando pesquisado somente um dia."

		ElseIf !StrHora(xConteudo) 
			lRet := .F.
			Help(" ",1,"TAFValPar",,STR0053,1,0,,,,,,{STR0055}) //"Hora inválida."###"Confira o horário preenchido no campo Hora De."

		ElseIf !Empty(xConteudo) .And. Len(AllTrim(xConteudo)) != 6
			lRet := .F.
			Help(" ",1,"TAFValPar",,STR0053,1,0,,,,,,{STR0084}) //"Hora inválida."###"Preencha o horário no formato HH:MM:SS."

		EndIf

	ElseIf cCpoPar == "HORAATE"

		If	!Empty(oModel:GetValue("PARAMETROS","HORADE")) .And.;
			!Empty(oModel:GetValue("PARAMETROS","DATADE")) .And.;
			!Empty(oModel:GetValue("PARAMETROS","DATAATE")) .And.;
			oModel:GetValue("PARAMETROS","DATADE") == oModel:GetValue("PARAMETROS","DATAATE") .And.;
			xConteudo < oModel:GetValue("PARAMETROS","HORADE")

			lRet := .F.
			Help(" ",1,"TAFValPar",,STR0053,1,0,,,,,,{STR0056}) //"Hora inválida."###"A hora final deve ser posterior ou igual a hora inicial, quando pesquisado somente um dia."

		ElseIf !StrHora(xConteudo)
			lRet := .F.
			Help(" ",1,"TAFValPar",,STR0053,1,0,,,,,,{STR0057 }) //"Hora inválida."###"Confira o horário preenchido no campo Hora Até."

		ElseIf oModel:GetValue("PARAMETROS","DATAATE") == dDataBase .And. Val(xConteudo) > ( Val(StrTran(Time(),":","")) - 10000 )
			lRet := .F.
			Help(" ",1,"TAFValPar",,STR0053,1,0,,,,,,{STR0083}) //"Hora inválida."###"A consulta deverá ser realizada com data limite até uma hora a menos que a data atual."

		ElseIf !Empty(xConteudo) .And. Len(AllTrim(xConteudo)) != 6
			lRet := .F.
			Help(" ",1,"TAFValPar",,STR0053,1,0,,,,,,{STR0084}) //"Hora inválida."###"Preencha o horário no formato HH:MM:SS."

		EndIf

	ElseIf cCpoPar == "PERAPU"

		cMes := AllTrim(Substr( xConteudo, 1, 2))
		cAno := AllTrim(Substr( xConteudo, 3, 4))

		dData := CToD( "01/" + cMes + "/" + cAno )

		If Len(cMes) < 2 .Or. cMes < "01" .Or. cMes > "12"
			lRet := .F.
			Help(" ",1,"TAFValPar",,STR0058,1,0,,,,,,{STR0059}) //"Mês não preenchido ou inválido."###'Confira o preenchimento do mês no campo "Mês-Ano".'
		ElseIf Len(cAno) < 4 .Or. cAno < "1900"
			lRet := .F.
			Help(" ",1,"TAFValPar",,STR0060,1,0,,,,,,{STR0061}) //"Ano não preenchido ou inválido."###'Confira o preenchimento do ano no campo "Mês-Ano".'
		ElseIf Empty(dData) .Or. dData < CToD( "01/01/1900" )
			lRet := .F.
			Help(" ",1,"TAFValPar",,STR0062,1,0,,,,,,{STR0063}) //"Periodo inválido."###'Verifique a data informada no campo "Mês-Ano".'
		EndIf

	ElseIf cCpoPar == "CPFTRABA"

		cAliasQry := GetNextAlias()

		cQry := " SELECT C9V_CPF FROM " + RetSqlName("C9V") + " C9V "
		cQry += " WHERE "
		cQry += " C9V_CPF = '" + xConteudo + "' " 
		cQry += " AND D_E_L_E_T_ = ' ' "

		cQry := ChangeQuery(cQry)

		MPSysOpenQuery(cQry, cAliasQry)

		If (cAliasQry)->(EOF())
			lRet := .F.
			Help(" ",1,"REGNOIS")
		EndIf

		(cAliasQry)->(DBCloseArea())

	EndIf

EndIf

Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFVisLog

Apresenta o LOG das consultas realizadas.

@author TOTVS
@since 01/11/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Static Function TAFVisLog()
Local oBrw := FWmBrowse():New()

oBrw:SetDescription(STR0005) //"Log eSocial BX"

oBrw:SetAlias('V2N')

oBrw:AddButton(STR0020 ,{|| CloseBrowse()}) //"Fechar"

oBrw:Activate()

Return Nil

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFPreCons

Faz uma pré consulta nas tabelas do TAF/TSS apresentando a data e hora dos eventos
transmitidos que não há código do recibo.

@author TOTVS
@since 01/11/2018
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Static Function TAFPreCons()
Local oModel		:= FWModelActivate()
Local cTipoEvt		:= oModel:GetValue("PARAMETROS","TPEVENTO")
Local cEvento		:= oModel:GetValue("PARAMETROS","EVENTO")
Local dDataDe		:= oModel:GetValue("PARAMETROS","DATADE")
Local dDataAte		:= oModel:GetValue("PARAMETROS","DATAATE")
Local cHoraDe		:= oModel:GetValue("PARAMETROS","HORADE")
Local cHoraAte		:= oModel:GetValue("PARAMETROS","HORAATE")
Local cCPFTrab		:= oModel:GetValue("PARAMETROS","CPFTRABA")
Local cPerApu		:= oModel:GetValue("PARAMETROS","PERAPU")
Local cQry			:= ""
Local cAliasTmp		:= GetNextAlias()
Local cAliasQry		:= ""
Local cID			:= ""
Local nQtdPorLote	:= 50
Local nPosEvt		:= 0
Local aEvtEsocial	:= TAFRotinas(,,.T.,2)
Local cAlias 		:= ""
Local oBrw			:= Nil
Local nX			:= 0
Local nItemLote		:= 0
Local aCampos		:= {}
Local aStru			:= {}
Local aColumns		:= {}
Local aXmls			:= {}
Local cAlsEvt		:= ""
Local cURL			:= AllTrim(TafGetUrlTSS())
Local cAmbiente		:= SuperGetMv('MV_TAFAMBE',.F.,"2")
Local cIdEnt		:= TAFRIdEnt()
Local cUserTk		:= "TOTVS"
Local dDataRet		:= SToD("")
Local cHoraRet		:= ""
Local nY			:= 0
Local oSocial		:= Nil
Local nReg			:= 0
Local aXMLAux		:= {}
Local lGrava		:= .T.

If !("TSSWSSOCIAL.APW" $ Upper(cUrl))
	cUrl += "TSSWSSOCIAL.apw"
EndIf

//-------------------------------------------
// Estrutura dos campos da tabela temporaria
//-------------------------------------------
AAdd(aCampos,{"EVENTO" ,"C" ,006            ,0})
AAdd(aCampos,{"DTTRAN" ,"D" ,008            ,0})
AAdd(aCampos,{"HRTRAN" ,"C" ,006            ,0})
AAdd(aCampos,{"ID"     ,"C" ,100            ,0})

//------------------------------
// Criação da tabela temporaria
//------------------------------
oTabEvtSel := FwTemporaryTable():New(cAliasTmp)

oTabEvtSel:SetFields(aCampos)

oTabEvtSel:AddIndex("1",{"EVENTO"})
oTabEvtSel:AddIndex("2",{"DTTRAN"})
oTabEvtSel:AddIndex("3",{"HRTRAN"})
oTabEvtSel:AddIndex("4",{"ID"})

oTabEvtSel:Create()

//----------------------------------------------------------------------------
// Query para obter os registros do TAF transmitidos mas sem número de recibo
//----------------------------------------------------------------------------
cQry := TAFA519Qry()

cAliasQry := MPSysOpenQuery(cQry)

//--------------------------------------------------------------
// Se houver, consulta o TSS para alimentar a tabela temporaria
//--------------------------------------------------------------
While (cAliasQry)->(!EOF())

	cID := AllTrim ( StrTran( ( cAliasQry )->EVENTO , "-" , "" ) ) + AllTrim( ( cAliasQry )->ID ) + AllTrim( ( cAliasQry )->VERSAO )

	Aadd( aXmls , { "" , cId , ( cAliasQry )->RECNO , AllTrim( ( cAliasQry )->EVENTO ) , cAlsEvt, ( cAliasQry )->FILIAL,(cAliasQry )->ID } )

(cAliasQry)->(DBSkip())
EndDo

For nReg := 1 To Len(aXmls)

	Aadd(aXMLAux,AClone(aXmls[nReg]))

	//------------------------------------------------------------------------------------------------
	// Realiza a consulta no TSS se alcançou a quantidade máxima por consulta ou se acabaram os dados
	//------------------------------------------------------------------------------------------------
	If nReg % nQtdPorLote == 0 .Or. nReg == Len(aXmls)

		//------------------------------------------------------------------------------
		// Consulta o TSS para incluir na tabela temporaria os registros não integrados
		//------------------------------------------------------------------------------
		oSocial	:= WSTSSWSSOCIAL():New()

		oSocial:_Url := cURL

		oSocial:oWSENTCONSDADOS:cAMBIENTE	:= cAmbiente
		oSocial:oWSENTCONSDADOS:cID_ENT		:= cIdEnt
		oSocial:oWSENTCONSDADOS:cUSERTOKEN	:= cUserTk

		oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS := WsClassNew("TSSWSSOCIAL_ARRAYOFENTCONSDOC")
		oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC :={}

		For nItemLote := 1 To Len(aXMLAux)

			aAdd(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC,WsClassNew("TSSWSSOCIAL_ENTCONSDOC"))
			Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):CCODIGO			:= aXMLAux[nItemLote][4]
			Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):CID				:= aXMLAux[nItemLote][2]
			Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):lRETORNAXML		:= .T.
			Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):lHISTPROC		:= .F.

		Next nItemLote

		//---------------------------
		// Executa a consulta no TSS
		//---------------------------
		lRet := oSocial:consultarDocumentos()

		If ValType(lRet) == "L"

			If lRet

				aRetorno := oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS:oWSSAIDACONSDOC

				//---------------------------------------------------------------------------
				// Grava na tabale temporaria somente os registros que atendem os parametros
				//---------------------------------------------------------------------------
				For nY := 1 To Len(aRetorno)

					If aRetorno[nY]:LSUCESSO

						dDataRet := aRetorno[nY]:DDTENTRADA
						cHoraRet := StrTran(aRetorno[nY]:CHRENTRADA,':','')

						//------------
						// Empregador
						//------------
						If cTipoEvt == "1"

							If	Str(Year(dDataRet),4) != SubStr(cPerApu,3,4) .Or.;
								StrZero(Month(dDataRet),2) != SubStr(cPerApu,1,2)

								Loop

							EndIf

						//----------------------
						// Tabela | Trabalhador
						//----------------------
						ElseIf cTipoEvt $ "2|3"

							If	dDataDe > dDataRet .Or. dDataAte < dDataRet .Or.;
								cHoraDe > cHoraRet .Or. cHoraAte < cHoraRet

								Loop

							EndIf

						EndIf

						If lGrava
							//---------------------------
							// Grava a tabela temporaria
							//---------------------------
							Reclock(cAliasTmp,.T.)
							(cAliasTmp)->EVENTO	:= AllTrim(aRetorno[nY]:CCODIGO)
							(cAliasTmp)->DTTRAN	:= dDataRet
							(cAliasTmp)->HRTRAN	:= cHoraRet
							(cAliasTmp)->ID		:= AllTrim(aRetorno[nY]:CID)
							(cAliasTmp)->(MSUnlock())

						EndIf

					EndIf

				Next nY

			EndIf

		EndIf

		//------------------------------------------
		// Limpa a variavel para novo processamento
		//------------------------------------------
		FreeObj(oSocial)
		oSocial := Nil

		ASize(aXMLAux,0)
		aXMLAux := {}

	EndIf

Next nReg

//           cDesc   ,cCampo   ,cTipo ,nTam ,nDec ,cPicture
aStru := {	{STR0023 ,"EVENTO" ,"C"   ,6    ,0    ,"@!"         },; //"Evento"
			{STR0064 ,"DTTRAN" ,"D"   ,8    ,0    ,""           },; //"Data"
			{STR0065 ,"HRTRAN" ,"C"   ,6    ,0    ,"@R 99:99:99"},; //"Hora" 
			{"ID"    ,"ID"     ,"C"   ,100  ,0    ,""           }}

For nX := 1 To Len(aStru)
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(aStru[nX][1])
	aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][2]+"}") )
	aColumns[Len(aColumns)]:SetSize(aStru[nX][4])
	aColumns[Len(aColumns)]:SetDecimal(aStru[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aStru[nX][6])
Next nX

oBrowse:= FWMBrowse():New()

oBrowse:SetDescription("Pré-Consulta: Registros sem Recibo")
oBrowse:SetDataTable(.T.)
oBrowse:SetAlias(cAliasTmp)
oBrowse:SetColumns(aColumns)
oBrowse:SetIgnoreARotina(.T.)
oBrowse:AddButton("Fechar" ,{|| CloseBrowse()})
oBrowse:DisableDetails()

oBrowse:Activate()

//----------------------------
// Deleta a tabela temporaria
//----------------------------
oTabEvtSel:Delete()

(cAliasQry)->(DBCloseArea())

aSize( aXmls, 0 )
aXmls := Nil

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA519Qry

Query para alimentação do painel REGISTROS e para a pré-consulta da base TAF (Outras ações -> Pré-consulta TAF)

@author TOTVS
@since 01/11/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Static Function TAFA519Qry(cInID)
Local oModel		:= FWModelActive()
Local cTPEvento		:= oModel:GetValue("PARAMETROS","TPEVENTO")
Local cCPFTrab		:= ""
Local aEvtEsocial	:= TAFRotinas(,,.T.,2)
Local aEventos		:= {}
Local cChvFunc		:= " ,'Nome: ' || RTRIM(C9V.C9V_NOME) || ' | CPF: ' || RTRIM(C9V.C9V_CPF) || ' | NIS: ' || RTRIM(C9V.C9V_NIS) DESCRIC "
Local nX			:= 0
Local nPosEvt		:= 0
Local cAlias		:= ""
Local cQry			:= ""

Default cInID		:= ""

If cTPEvento == "1"
	aEventos := {"S-1000"}

ElseIf cTPEvento == "2"
	aEventos := {oModel:GetValue("PARAMETROS","EVENTO")}

ElseIf  cTPEvento == "3"
	aEventos := {"S-1200","S-1207","S-1210","S-2190","S-2200","S-2205","S-2206","S-2210","S-2220","S-2230","S-2240","S-2241","S-2250","S-2260","S-2298","S-2299","S-2306","S-2400","S-3000"}

	cCPFTrab := oModel:GetValue("PARAMETROS","CPFTRABA")

EndIf

For nX := 1 To Len(aEventos)

	nPosEvt	:= AScan(aEvtEsocial,{|x| x[4] == aEventos[nX] })

	cAlias	:= aEvtEsocial[nPosEvt][3]

	//-----------------------------------------------------------------
	// Caso seja feita query com mais de uma tabela, une os resultados
	//-----------------------------------------------------------------
	If nX > 1 
		cQry += " UNION ALL "
	EndIf

	cQry += " SELECT "
	cQry += 	"'" + cAlias + "' ALIAS "
	cQry += 	"," + cAlias + "_FILIAL FILIAL "
	cQry += 	",'" + aEventos[nX] +"' EVENTO "
	cQry += 	"," + cAlias + "_ID ID "
	cQry += 	"," + cAlias + "_VERSAO VERSAO "	
	cQry += 	"," + cAlias + "_PROTUL PROTUL "
	cQry += 	"," + cAlias + "_XMLID XMLID "
	cQry += 	", " + cAlias + ".R_E_C_N_O_ RECNO "

	If aEventos[nX] $ "S-1200|S-1207|S-1210|S-2190|S-2200|S-2205|S-2206|S-2210|S-2220|S-2230|S-2240|S-2241|S-2250|S-2260|S-2298|S-2299|S-2306|S-2400|S-3000"
		cQry +=	cChvFunc

	ElseIf aEventos[nX] == "S-1000"
		cQry +=	" , 'Filial TAF: ' || RTRIM(C1E.C1E_FILTAF) || ' | Razão Social: ' || RTRIM(C1E.C1E_NOME) DESCRIC "

	ElseIf aEventos[nX] == "S-1005"
		cQry +=	" , 'Nr.Insc.Est.: ' || RTRIM(C92.C92_NRINSC) DESCRIC "

	ElseIf aEventos[nX] == "S-1010"
		cQry +=	" , 'Cod.Rubrica: ' || RTRIM(C8R.C8R_CODRUB) || ' | Desc.Rubrica: ' || RTRIM(C8R.C8R_DESRUB) DESCRIC "

	ElseIf aEventos[nX] == "S-1020"
		cQry +=	", 'Cod.Lotação: ' || RTRIM(C99.C99_CODIGO) || ' | Desc.Lotação: ' || RTRIM(C99.C99_DESCRI) DESCRIC "

	ElseIf aEventos[nX] == "S-1030"
		cQry +=	", 'Cód Cargo: ' || RTRIM(C8V.C8V_CODIGO) || ' | Nome Cargo: ' || RTRIM(C8V.C8V_DESCRI) DESCRIC "

	ElseIf aEventos[nX] == "S-1035"
		cQry +=	", 'Evento: ' || RTRIM(T5K.T5K_EVENTO) || ' | Descrição: ' || RTRIM(T5K.T5K_DESCRI) DESCRIC "

	ElseIf aEventos[nX] == "S-1040"
		cQry +=	", 'Cód Função: ' || RTRIM(C8X.C8X_CODIGO) || ' | Descr Função: ' || RTRIM(C8X.C8X_DESCRI) DESCRIC "

	ElseIf aEventos[nX] == "S-1050"
		cQry +=	", 'Cód Turno: ' || RTRIM(C90.C90_CODIGO) || ' | Descr Turno: ' || RTRIM(C90.C90_DESCRI) DESCRIC "

	ElseIf aEventos[nX] == "S-1060"
		cQry +=	", 'Cód Amb Trab: ' || RTRIM(T04.T04_CODIGO) DESCRIC "

	ElseIf aEventos[nX] == "S-1070"
		cQry +=	", 'Num.Proc.: ' || RTRIM(C1G.C1G_NUMPRO) || ' | Descrição: ' || RTRIM(C1G.C1G_DESCRI) DESCRIC "

	ElseIf aEventos[nX] == "S-1080"
		cQry +=	", 'CNPJ Op.Port: ' || RTRIM(C8W.C8W_CNPJOP) DESCRIC "

	ElseIf aEventos[nX] == "S-1250"
		cQry +=	", 'Nr Inscrição: ' || RTRIM(CMR.CMR_INSCES) DESCRIC "

	ElseIf aEventos[nX] == "S-1260"
		cQry +=	", 'Nr Ins Rural: ' || RTRIM(T1M.T1M_NRINSC) DESCRIC "

	ElseIf aEventos[nX] == "S-1270"
		cQry +=	", 'ID: ' || RTRIM(T2A.T2A_ID) DESCRIC "

	ElseIf aEventos[nX] == "S-1280"
		cQry +=	", 'ID: ' || RTRIM(T3V.T3V_ID) DESCRIC "

	ElseIf aEventos[nX] == "S-1295"
		cQry +=	", 'Id. Resp.: ' || RTRIM(T72.T72_IDRESP) DESCRIC "

	ElseIf aEventos[nX] == "S-1298"
		cQry +=	", 'ID: ' || RTRIM(T1S.T1S_ID) DESCRIC "

	ElseIf aEventos[nX] == "S-1299"
		cQry +=	", 'ID: ' || RTRIM(CUO.CUO_ID) DESCRIC "

	ElseIf aEventos[nX] == "S-1300"
		cQry +=	", 'ID: ' || RTRIM(T3Z.T3Z_ID) DESCRIC "

	Else
		cQry +=	" ,'Não identificada' DESCRIC "

	EndIf

	cQry += " FROM "
	cQry += 	RetSqlName(cAlias) + " " + cAlias

	//-------------------------------------------------------------------------------------------------------
	// Caso seja consulta relacionada a trabalhador, faz Inner com a C9V para obter os dados do funcionário
	//-------------------------------------------------------------------------------------------------------
	If cTPEvento == "3" .And. cAlias != "C9V" 

		cQry += " INNER JOIN " + RetSqlName("C9V") + " C9V ON "

		If aEventos[nX] $ "S-1200|S-2210|S-2250|S-2260|S-3000"
			cQry += " C9V_ID = " + cAlias + "_TRABAL "

		ElseIf aEventos[nX] $ "S-1207|S-2190|S-2205|S-2206|S-2400|S-2306"
			cQry += " C9V_CPF = " + cAlias + "_CPF "

		ElseIf aEventos[nX] == "S-1210"
			cQry += " C9V_ID = T3P_BENEFI "

		ElseIf aEventos[nX] $ "S-2220|S-2230|S-2240|S-2298|S-2299"
			cQry += " C9V_ID = " + cAlias + "_FUNC "

		ElseIf aEventos[nX] == "S-2241"
			cQry += " C9V_ID = T3B_IDTRAB "

		EndIf

		cQry += " AND C9V.D_E_L_E_T_ = ' ' "

	EndIf

	cQry += " WHERE "

	cQry += " " + cAlias + "_PROTUL = ' ' "

	cQry += " AND " + cAlias + "_STATUS = '4' "

	If !Empty(cInID)
		cQry += " AND " + cAlias + "_XMLID IN(" + cInID + ") "
	EndIf

	If cTPEvento == "3"
		cQry += " AND C9V.C9V_CPF = '" + cCPFTrab + "' "
	EndIf

	cQry += " AND " + cAlias + ".D_E_L_E_T_ = ' ' "

Next nX

cQry := ChangeQuery(cQry)

aSize(aEvtEsocial,0)
aEvtEsocial := Nil

Return cQry

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA519Dsc

Retorna o campo de descricao conforme evento

@Author		TOTVS
@Since		28/11/2018
@Version	12.1.17
/*/
//---------------------------------------------------------------------
Static Function TAFA519Chv(cLayout,nTipo)
Local cQry		:= ""
Local cChvFunc	:= " ,'Nome: ' || RTRIM(C9V.C9V_NOME) || ' | CPF: ' || RTRIM(C9V.C9V_CPF) || ' | NIS: ' || RTRIM(C9V.C9V_NIS) CHVNEGOC "

If cLayout == "S-1000"
	If nTipo == 1
		cQry :=	" , 'Filial TAF: ' || RTRIM(C1E.C1E_FILTAF) || ' | Razão Social: ' || RTRIM(C1E.C1E_NOME) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1005"
	If nTipo == 1
		cQry :=	" , 'Nr.Insc.Est.: ' || RTRIM(C92.C92_NRINSC) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1010"
	If nTipo == 1
		cQry :=	" , 'Cod.Rubrica: ' || RTRIM(C8R.C8R_CODRUB) || ' | Desc.Rubrica: ' || RTRIM(C8R.C8R_DESRUB) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1020"
	If nTipo == 1
		cQry :=	", 'Cod.Lotação: ' || RTRIM(C99.C99_CODIGO) || ' | Desc.Lotação: ' || RTRIM(C99.C99_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1030"
	If nTipo == 1
		cQry :=	", 'Cód Cargo: ' || RTRIM(C8V.C8V_CODIGO) || ' | Nome Cargo: ' || RTRIM(C8V.C8V_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1035"
	If nTipo == 1
		cQry :=	", 'Evento: ' || RTRIM(T5K.T5K_EVENTO) || ' | Descrição: ' || RTRIM(T5K.T5K_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1040"
	If nTipo == 1
		cQry :=	", 'Cód Função: ' || RTRIM(C8X.C8X_CODIGO) || ' | Descr Função: ' || RTRIM(C8X.C8X_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1050"
	If nTipo == 1
		cQry :=	", 'Cód Turno: ' || RTRIM(C90.C90_CODIGO) || ' | Descr Turno: ' || RTRIM(C90.C90_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1060"
	If nTipo == 1
		cQry :=	", 'Cód Amb Trab: ' || RTRIM(T04.T04_CODIGO) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1070"
	If nTipo == 1
		cQry :=	", 'Num.Proc.: ' || RTRIM(C1G.C1G_NUMPRO) || ' | Descrição: ' || RTRIM(C1G.C1G_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1080"
	If nTipo == 1
		cQry :=	", 'CNPJ Op.Port: ' || RTRIM(C8W.C8W_CNPJOP) CHVNEGOC "
	EndIf

ElseIf cLayout $ "S-1200|S-1202"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = C91_TRABAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-1207"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T62_CPF "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-1210"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = T3P_BENEFI "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-1250"
	If nTipo == 1
		cQry :=	", 'Nr Inscrição: ' || RTRIM(CMR.CMR_INSCES) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1260"
	If nTipo == 1
		cQry :=	", 'Nr Ins Rural: ' || RTRIM(T1M.T1M_NRINSC) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1270"
	If nTipo == 1
		cQry :=	", 'ID: ' || RTRIM(T2A.T2A_ID) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1280"
	If nTipo == 1
		cQry :=	", 'ID: ' || RTRIM(T3V.T3V_ID) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1295"
	If nTipo == 1
		cQry :=	", 'Id. Resp.: ' || RTRIM(T72.T72_IDRESP) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1298"
	If nTipo == 1
		cQry :=	", 'ID: ' || RTRIM(T1S.T1S_ID) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1299"
	If nTipo == 1
		cQry :=	", 'ID: ' || RTRIM(CUO.CUO_ID) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1300"
	If nTipo == 1
		cQry :=	", 'ID: ' || RTRIM(T3Z.T3Z_ID) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-2190"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T3A_CPF "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2200"
	If nTipo == 1
		cQry :=	cChvFunc
	EndIf

ElseIf cLayout == "S-2205"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T1U_CPF "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2206"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T1V_CPF "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2210"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CM0_TRABAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2220"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = C8B_FUNC "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2230"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CM6_FUNC "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2240"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CM9_FUNC "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2241"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = T3B_IDTRAB "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2250"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CM8_TRABAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2260"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = T87_TRABAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2298"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CMF_FUNC "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2299"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CMD_FUNC "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2300"
	If nTipo == 1
		cQry :=	cChvFunc
	EndIf

ElseIf cLayout == "S-2306"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T0F_CPF "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2399"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = T92_TRABAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2400"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T5T_CPF "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-3000"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CMJ_TRABAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

Else
	If nTipo == 1
		cQry :=	" ,'Não identificada' CHVNEGOC "
	EndIf

EndIf

Return cQry

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA519PVl

Pré-validação se os campos necessários do painel "Parâmetros" estão
preenchidos. As validações são conforme documento do governo.

@Author		TOTVS
@Since		30/11/2018
@Version	12.1.17
/*/
//---------------------------------------------------------------------
Static Function TAFA519PVl()
Local lRet		:= .T.
Local oModel	:= FWModelActivate() 
Local cTpEvento	:= oModel:GetValue("PARAMETROS","TPEVENTO")

If Empty(cTpEvento)
	lRet := .F.
	Help(" ",1,"TAFA519PVl",,STR0066,1,0,,,,,,{STR0067}) //"Tipo do evento não informado."###'Preencha no painel "Parâmetros", o campo "Tipo do Evento".'
EndIf

//------------
// Empregador
//------------
If lRet .And. cTpEvento == "1"

	If Empty(oModel:GetValue("PARAMETROS","PERAPU"))
		lRet := .F.
		Help(" ",1,"TAFA519PVl",,STR0068,1,0,,,,,,{STR0069}) //"Mês e ano não informados."###'Preencha no painel "Parâmetros", o campo "Mês-Ano".'
	EndIf

EndIf

//--------
// Tabela
//--------
If lRet .And. cTpEvento == "2"

	If Empty(oModel:GetValue("PARAMETROS","EVENTO"))
		lRet := .F.
		Help(" ",1,"TAFA519PVl",,STR0070,1,0,,,,,,{STR0071}) //"Evento não informado."###'Preencha no painel "Parâmetros", o campo "Evento".'
	EndIf

	If lRet .And. !Empty(oModel:GetValue("PARAMETROS","HORAATE")) .And. Empty(oModel:GetValue("PARAMETROS","HORADE"))
		lRet := .F.
		Help(" ",1,"TAFA519PVl",,STR0076,1,0,,,,,,{STR0077}) //"Hora inicial não informada."###'Preencha no painel "Parâmetros", o campo "Hora De".'
	EndIf

	If lRet .And. !Empty(oModel:GetValue("PARAMETROS","HORADE")) .And. Empty(oModel:GetValue("PARAMETROS","HORAATE"))
		lRet := .F.
		Help(" ",1,"TAFA519PVl",,STR0078,1,0,,,,,,{STR0079}) //"Hora final não informada."###'Preencha no painel "Parâmetros", o campo "Hora Até".'
	EndIf


EndIf

//-------------
// Trabalhador
//-------------
If lRet .And. cTpEvento == "3"

	If lRet .And. Empty(oModel:GetValue("PARAMETROS","DATADE"))
		lRet := .F.
		Help(" ",1,"TAFA519PVl",,STR0072,1,0,,,,,,{STR0073}) //"Data inicial não informada."###'Preencha no painel "Parâmetros", o campo "Data De".'
	EndIf

	If lRet .And. Empty(oModel:GetValue("PARAMETROS","DATAATE"))
		lRet := .F.
		Help(" ",1,"TAFA519PVl",,STR0074,1,0,,,,,,{STR0075}) //"Data final não informada."###'Preencha no painel "Parâmetros", o campo "Data Até".'
	EndIf

	If lRet .And. Empty(oModel:GetValue("PARAMETROS","HORADE"))
		lRet := .F.
		Help(" ",1,"TAFA519PVl",,STR0076,1,0,,,,,,{STR0077}) //"Hora inicial não informada."###'Preencha no painel "Parâmetros", o campo "Hora De".'
	EndIf

	If lRet .And. Empty(oModel:GetValue("PARAMETROS","HORAATE"))
		lRet := .F.
		Help(" ",1,"TAFA519PVl",,STR0078,1,0,,,,,,{STR0079}) //"Hora final não informada."###'Preencha no painel "Parâmetros", o campo "Hora Até".'
	EndIf

	If lRet .And. Empty(oModel:GetValue("PARAMETROS","CPFTRABA"))
		lRet := .F.
		Help(" ",1,"TAFA519PVl",,STR0080,1,0,,,,,,{STR0081}) //"CPF do trabalhador não informado."###'Preencha no painel "Parâmetros", o campo "CPF do Trabalhador".'
	EndIf

EndIf

Return lRet