#include "CRMA060.CH"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA060

Amarracao entidades x Contatos contruido em mvc
o cadastro de CONTATOS pode ser associado a qualquer entidade.(Clientes, Fornecedor).


@sample  		CRMA060()

@param		    ExpC1 -> Entidade                                            
           		ExpN1 -> Registro                                            
           		ExpN2 -> Opcao ( Somente Visualizar, Alterar e Excluir ) 
           		Expl4 -> Exclui a amarração da entidade x contato sem mostrar a interface? (Exclusao Direta)                                               
 
 
@return		Nenhum

@author		Victor Bitencourt
@since			21/10/2013
@version		11.90                
/*/
//------------------------------------------------------------------------------
Function CRMA060( cAlias, nReg, nOperation, lExcNotView )

Local aArea 			:= GetArea()
Local cNomEnt    		:= ""
Local cEntidade  		:= ""
Local cCodEnt    		:= ""
Local cUnico     		:= "" 
Local cNome				:= ""
Local cLog				:= ""
Local nScan      		:= 0
Local oExecView			:= Nil 
Local lAchou 			:= .F. 
Local oModel			:= Nil

Default cAlias  		:= Alias()
Default nReg	  		:= (cAlias)->(RecNo()) 
Default nOperation		:= 1
Default lExcNotView		:= .F.

Private INCLUI := .T.  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona a entidade                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cEntidade := cAlias
dbSelectArea( cEntidade )
MsGoto( nReg )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informa a chave de relacionamento de cada entidade e o campo descricao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEntidade := MsRelation()
nScan := AScan( aEntidade, { |x| x[1] == cEntidade } )

If Empty( nScan ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza a chave unica pelo SX2                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	SX2->( dbSetOrder( 1 ) ) 
	If SX2->( dbSeek( cEntidade ) )  
	
		If !Empty( SX2->X2_UNICO )       
		   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Macro executa a chave unica                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			cUnico   := SX2->X2_UNICO 
			cCodEnt  := &cUnico 
			cCodDesc := Substr( AllTrim( cCodEnt ), Len( SA1->A1_FILIAL ) + 1 )  
			lAchou   := .T. 
				 
		EndIf 					
	
	EndIf 	   

Else 
	aChave   := aEntidade[ nScan, 2 ]
	cCodEnt  := MaBuildKey( cEntidade, aChave ) 
	cCodDesc := AllTrim( cCodEnt ) + "-" + Capital( Eval( aEntidade[ nScan, 3 ] ) )    
	lAchou := .T. 
EndIf 

  
If lAchou  

	Do Case
		Case cAlias == "SA1" //Clientes
			cNome := SA1->A1_NOME
		Case cAlias == "SUS"// Prospects
			cNome := SUS->US_NOME 
		Case cAlias == "ACH"// Suspects
			cNome := ACH->ACH_RAZAO 
		Case cAlias == "AC3" // Concorrentes
			cNome := AC3->AC3_NOME
		Case cAlias == "AC4" // Parceiros
			cNome := AC4->AC4_NOME 
		Case cAlias == "SA4" // Transportadoras
			cNome := SA4->A4_NOME 
		Case cAlias == "SA2" // Fornecedores
			cNome := SA2->A2_NOME
		Case cAlias == "SU2" // Concorrentes
			cNome := SU2->U2_CONCOR			
	EndCase
	
	SX2->(DbSetOrder(1)) //X2_CHAVE  
	If SX2->(DbSeek(cEntidade))
		cNomEnt  := AllTrim(X2Nome())+" - "+cCodDesc
	EndIf	
	
	oModel := FWLoadModel("CRMA060")
	oModel:SetOperation(nOperation)
	oModel:GetModel("AC8MASTER"):bLoad := {|| {xFilial("AC8"),xFilial( cEntidade ),cEntidade,cCodEnt,cNomEnt}}
	oModel:Activate() 
	    
	If !lExcNotView
	
		oView := FWLoadView("CRMA060")
	  	oView:SetModel(oModel)
	  	oView:SetOperation(nOperation) 
	  			  	
	  	oExecView := FWViewExec():New()
		oExecView:SetTitle(STR0001)
		oExecView:SetView(oView)
		oExecView:SetModal(.F.)
		oExecView:SetCloseOnOK({|| .T. })
		oExecView:SetOperation(nOperation)
		oExecView:OpenView(.T.)
		
	Else
		If oModel:VldData()
			oModel:CommitData()
		Else
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[6])        	
			Help( ,,"CRM60VLDPOS",,cLog, 1, 0 ) 
		EndIf
	EndIf

	oModel:DeActivate()

Else
	MsgStop(STR0010)//"Nao existe chave de relacionamento definida para o alias.
EndIf 

RestArea(aArea)
 
Return Nil


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Cria o objeto comtendo a estrutura , relacionamentos das tabelas envolvidas 

@sample		ModelDef()

@param		Nenhum

@return		ExpO - o objeto do modelo de dados

@author		Victor Bitencourt
@since		21/10/2013
@version	11.80                
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel 		:= Nil
Local cCpoAC8Cab	:= "AC8_FILIAL|AC8_FILENT|AC8_ENTIDA|AC8_CODENT|"
Local bAvCpoCab		:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoAC8Cab}
Local oStructMST 	:= FWFormStruct(1,"AC8",bAvCpoCab)
Local oStructAC8 	:= FWFormStruct(1,"AC8")

oStructMST:AddField(	AllTrim(STR0003)				,; 	// [01] C Titulo do campo 
						AllTrim(STR0004)				,; 	// [02] C ToolTip do campo //"Tipo de Entidade"
						"AC8_ENTNOM" 					,; 	// [03] C identificador (ID) do Field
						"C" 							,; 	// [04] C Tipo do campo
						30 								,; 	// [05] N Tamanho do campo
						0 								,; 	// [06] N Decimal do campo
						Nil 							,; 	// [07] B Code-block de validação do campo
						Nil								,; 	// [08] B Code-block de validação When do campo
						Nil					 			,; 	// [09] A Lista de valores permitido do campo
						Nil 							,; 	// [10] L Indica se o campo tem preenchimento obrigatório
						Nil		 			   			,;  // [11] B Code-block de inicializacao do campo
						Nil 							,; 	// [12] L Indica se trata de um campo chave
						Nil				 				,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
						Nil )
						
oStructAC8:SetProperty("AC8_FILENT",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD, "CRMA060IFil()" ))						

oModel := MPFormModel():New("CRMA060",/*bPreValidacao*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)	
oModel:SetDescription(STR0002)//"Relacionamento ENTIDADE X CONTATO"

oModel:AddFields("AC8MASTER",/*cOwner*/,oStructMST,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/) 
oModel:AddGrid("AC8CONTDET","AC8MASTER",oStructAC8,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey({"AC8_FILIAL","AC8_FILENT","AC8_ENTIDA","AC8_CODENT"})

oModel:GetModel("AC8CONTDET"):SetOptional( .T. )

oModel:GetModel("AC8CONTDET"):SetUniqueLine({"AC8_CODCON"})

oModel:SetRelation("AC8CONTDET",{ {"AC8_FILIAL","AC8_FILIAL"},;
                                  {"AC8_FILENT","AC8_FILENT"},;
                                  {"AC8_ENTIDA","AC8_ENTIDA"},;
                                  {"AC8_CODENT","AC8_CODENT"}; 
                                },AC8->( IndexKey(1)))
 
Return(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

monta o objeto que irá permitir a visualização da interfece grafica,
com base no Model

@sample		ViewDef()

@param		Nenhum

@return	    ExpO - bojeto de visualizacao da interface grafica.

@author		Victor Bitencourt
@since		23/10/2013
@version	11.80                
/*/
//------------------------------------------------------------------------------

Static Function ViewDef()

Local oView 		:= Nil
Local oModel		:= FwLoadModel("CRMA060")
Local cCpoAC8Cab	:= "AC8_FILIAL|AC8_FILENT|AC8_ENTIDA|AC8_CODENT|"
Local bAvCpoCab		:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoAC8Cab}
Local oStructMST 	:= FWFormStruct(2,"AC8",bAvCpoCab)
Local oStructAC8 	:= FWFormStruct(2,"AC8")

// Alterando a propriedade dos campos, para nçao ser editaveis
oStructMST:SetProperty("AC8_CODENT",MVC_VIEW_CANCHANGE,.F.)
oStructMST:SetProperty("AC8_ENTIDA" , MVC_VIEW_CANCHANGE, .F. )

oStructMST:AddField(	"AC8_ENTNOM" 			,;	// [01] C Nome do Campo
						"05" 					,; 	// [02] C Ordem
						STR0003					,; 	// [03] C Titulo do campo//"Entidade"
						STR0004					,; 	// [04] C Descrição do campo//"Tipo de Entidade"
						{} 	   					,; 	// [05] A Array com Help
						"C" 					,; 	// [06] C Tipo do campo
						"@!" 					,; 	// [07] C Picture
						Nil 					,; 	// [08] B Bloco de Picture Var
						Nil 					,; 	// [09] C Consulta F3
						.F. 					,;	// [10] L Indica se o campo é evitável
						Nil 					,; 	// [11] C Pasta do campo
						Nil 					,;	// [12] C Agrupamento do campo
						Nil 					,; 	// [13] A Lista de valores permitido do campo (Combo)
						Nil 					,;	// [14] N Tamanho Maximo da maior opção do combo
						Nil 					,;	// [15] C Inicializador de Browse
						Nil 					,;	// [16] L Indica se o campo é virtual
						Nil ) 

oStructMST:RemoveField("AC8_FILENT")
oStructAC8:RemoveField("AC8_FILIAL")
oStructAC8:RemoveField("AC8_FILENT")
oStructAC8:RemoveField("AC8_ENTIDA")
oStructAC8:RemoveField("AC8_CODENT")

oView := FWFormView():New()
oView:SetModel(oModel)
 
oView:AddField("VIEW_MST",oStructMST,"AC8MASTER")
oView:AddGrid("VIEW_AC8",oStructAC8, "AC8CONTDET")

oView:CreateHorizontalBox("VIEW_TOP",20)
oView:SetOwnerView("VIEW_MST","VIEW_TOP")

oView:CreateHorizontalBox("VIEW_DET",80)
oView:SetOwnerView("VIEW_AC8","VIEW_DET")

Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA060RET

CRMA040RET(cCodCont,cCampo) para posicionar uma unica vez na tabela de Contatos(SU5),
Retornando a informação do campo, passado como parâmetro. 

@sample		CRMA060RET()

@param		ExpC1 = Codigo do contato a ser relacionado
            ExpC2 = Nome do campo que dever ser retornado o valor 

@return		Retorna o valor do campo requisitado referente ao codigo enviado.

@author		Victor Bitencourt
@since		21/10/2013
@version	11.90                
/*/
//------------------------------------------------------------------------------
Function CRMA060RET(cCodCont,cCampo) 

Local cRet       := ""
Local oView      := Nil
Local oMdlGrid   := Nil 

Default cCodCont := ""
Default cCampo   := ""

oView := FwViewActive()
If !Empty(oView)
	If (oView:IsActive())
		cCodCont := ""
	EndIf
EndIf

If Alias() == "SU5" .AND. SU5->U5_CODCONT == cCodCont
	cRet := SU5->&(cCampo)
Else

	If !Empty(cCodCont)

		DbSelectArea("SU5") 
		DbSetOrder(1) //xFlial("SU5")+U5_CODCONT
		
		If DbSeek(xFilial("SU5")+cCodCont)
			cRet := SU5->&(cCampo) 
		EndIf	
	EndIf

EndIf

Return(cRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA060VAL

CRMA060VAL() faz a validacao da
Retornando a informação do campo, passado como parâmetro. 

@sample		CRMA060VAL()

@param		ExpC1 = Codigo do contato.

@return		Retorna o valor do campo "UM_DESC" da Tabela "SUM" referente ao codigo posicionado.

@author		Victor Bitencourt
@since		21/10/2013
@version	11.90                
/*/
//------------------------------------------------------------------------------

Function CRMA060VAL(cCodCon)

Local cRet := ""

If(!INCLUI) .AND. FindFunction("CRMA060RET")
	cRet := POSICIONE("SUM",1,XFILIAL("SUM")+CRMA060RET(cCodCon,"U5_FUNCAO"),"UM_DESC")      
Else
   	cRet :=""
EndIf	

Return(cRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA060IFil

Devido ao model ser um modelo 2, captura a filial do cabeçalho

@param		Nenhum
@return		cFilEnt, caracter, Filial do cabeçalho 

@author		Jonatas Martins
@since		17/10/2015
@version	12.1.7              
/*/
//------------------------------------------------------------------------------
Function CRMA060IFil()

Local oModel	:= FwModelActive()
Local oMdlCabec	:= oModel:GetModel("AC8MASTER")
Local cFilEnt 	:= oMdlCabec:GetValue("AC8_FILENT")

Return ( cFilEnt )




//------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Mensagem Única	

@sample		IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransaction, lJSon ) 

@param		xEnt 
@param		nTypeTrans 
@param		cTypeMessage
@param		cVersion
@param		cTransaction
@param		lJSon

@return		aRet 

@author		Totvs Cascavel
@since		11/09/2018
@version	12
/*/
//------------------------------------------------------------------------------
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransaction, lJSon ) 

Local aRet 		:= {}
Default lJSon 	:= .F.

If lJSon .And. FindFunction("CRMI060O")
	aRet := CRMI060O( xEnt, nTypeTrans, cTypeMessage)
Else
	aRet := CRMI060( xEnt, nTypeTrans, cTypeMessage)
Endif

Return aRet