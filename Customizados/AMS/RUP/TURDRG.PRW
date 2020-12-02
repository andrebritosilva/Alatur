#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} TURDRG
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  11/07/2016
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function TURDRG( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
	TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf
	
	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()
			
			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "TURDRG" )
				Else
					MsgStop( "Atualização não Realizada.", "TURDRG" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Concluída." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf
			
		Else
			MsgStop( "Atualização não Realizada.", "TURDRG" )
			
		EndIf
		
	Else
		MsgStop( "Atualização não Realizada.", "TURDRG" )
		
	EndIf
	
EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  11/07/2016
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )
	
	dbSelectArea( "SM0" )
	dbGoTop()
	
	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
			.AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End
	
	SM0->( dbCloseArea() )
	
	If lOpen
		
		For nI := 1 To Len( aRecnoSM0 )
			
			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf
			
			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )
			
			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )
			
			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.
			
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )
			
			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			
			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf
			
			oProcess:SetRegua1( 8 )
			
			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()
			
			//------------------------------------
			// Atualiza o dicionário SX9
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de relacionamentos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX9()
			
			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()
			
			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )
			
			// Alteração física dos arquivos
			__SetX31Mode( .F. )
			
			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf
			
			For nX := 1 To Len( aArqUpd )
				
				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf
				
				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf
				
				X31UpdTable( aArqUpd[nX] )
				
				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf
				
				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf
				
			Next nX
			
			//------------------------------------
			// Atualiza o dicionário SX7
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7()
			
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )
			
			RpcClearEnv()
			
		Next nI
		
		If !lAuto
			
			cTexto := LeLog()
			
			Define Font oFont Name "Mono AS" Size 5, 12
			
			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel
			
			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont
			
			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel
			
			Activate MsDialog oDlg Center
			
		EndIf
		
	EndIf
	
Else
	
	lRet := .F.
	
EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  11/07/2016
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
{ "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
{ "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
{ "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
{ "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
{ "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
{ "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )

//
// --- ATENÇÃO ---
// Coloque .F. na 2a. posição de cada elemento do array, para os dados do SX3
// que não serão atualizados quando o campo já existir.
//

//
// Campos Tabela AC8
//
aAdd( aSX3, { ;
	{ 'AC8'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'AC8_EMAIL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'E-mail'																, .T. }, ; //X3_TITULO
	{ 'E-mail'																, .T. }, ; //X3_TITSPA
	{ 'E-mail'																, .T. }, ; //X3_TITENG
	{ 'E-mail do Contato'													, .T. }, ; //X3_DESCRIC
	{ 'E-mail del contacto'													, .T. }, ; //X3_DESCSPA
	{ 'Contact E-mail'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI, IIF(FINDFUNCTION("CRMA060RET"),CRMA060RET(AC8->AC8_CODCON,"U5_EMAIL"),""),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela AGU
//
aAdd( aSX3, { ;
	{ 'AGU'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'AGU_NOMCLI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome'																, .T. }, ; //X3_TITULO
	{ 'Nombre'																, .T. }, ; //X3_TITSPA
	{ 'Name'																, .T. }, ; //X3_TITENG
	{ 'Nome do Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Nombre del Cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Customer Name'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI,POSICIONE("SA1",1,XFILIAL("SA1")+AGU->AGU_CODCLI+AGU->AGU_LOJCLI,"A1_NOME"),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME


//
// Campos Tabela G3A
//
aAdd( aSX3, { ;
{ 'G3A'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G3A_XOBSER'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 150																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Observacao'															, .T. }, ; //X3_TITULO
{ 'Observacao'															, .T. }, ; //X3_TITSPA
{ 'Observacao'															, .T. }, ; //X3_TITENG
{ 'Observacao'															, .T. }, ; //X3_DESCRIC
{ 'Observacao'															, .T. }, ; //X3_DESCSPA
{ 'Observacao'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3B
//
aAdd( aSX3, { ;
{ 'G3B'																	, .T. }, ; //X3_ARQUIVO
{ '10'																	, .T. }, ; //X3_ORDEM
{ 'G3B_CODMUN'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód. Mun.'															, .T. }, ; //X3_TITULO
{ 'Cod. Mun.'															, .T. }, ; //X3_TITSPA
{ 'Code City'															, .T. }, ; //X3_TITENG
{ 'Código Munícipio'													, .T. }, ; //X3_DESCRIC
{ 'Codigo del municipio'												, .T. }, ; //X3_DESCSPA
{ 'City Code'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ "Vazio() .or. ExistCpo('G5S',FwFldGet('G3B_CODMUN'))"					, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5S'																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ ''																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME


aAdd( aSX3, { ;
{ 'G3B'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G3B_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log Dw'																, .T. }, ; //X3_TITULO
{ 'Log Dw'																, .T. }, ; //X3_TITSPA
{ 'Log Dw'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3B'																	, .T. }, ; //X3_ARQUIVO
{ '14'																	, .T. }, ; //X3_ORDEM
{ 'G3B_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3C
//
aAdd( aSX3, { ;
{ 'G3C'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G3C_CODIGO'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 6																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Código'																, .T. }, ; //X3_TITULO
{ 'Codigo'																, .T. }, ; //X3_TITSPA
{ 'Code'																, .T. }, ; //X3_TITENG
{ 'Código Classe de Serviço'											, .T. }, ; //X3_DESCRIC
{ 'Codigo clase de servicio'											, .T. }, ; //X3_DESCSPA
{ 'Code Service Class'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'ExistChav("G3C",FWFldGet("G3C_CODFOR")+FWFldGet("G3C_LJFOR")+FWFldGet("G3C_CODIGO"),2)', .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ "GETSXENUM('G3C','G3C_CODIGO')"										, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ 'INCLUI'																, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3C'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G3C_XIDEAI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 60																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Identif. EAI'														, .T. }, ; //X3_TITULO
{ 'Identif. EAI'														, .T. }, ; //X3_TITSPA
{ 'Identif. EAI'														, .T. }, ; //X3_TITENG
{ 'Identificador de EAI'												, .T. }, ; //X3_DESCRIC
{ 'Identificador de EAI'												, .T. }, ; //X3_DESCSPA
{ 'Identificador de EAI'												, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3C'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G3C_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3C'																	, .T. }, ; //X3_ARQUIVO
{ '10'																	, .T. }, ; //X3_ORDEM
{ 'G3C_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3F
//
aAdd( aSX3, { ;
	{ 'G3F'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'G3F_CLIENT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Razao Social'														, .T. }, ; //X3_TITULO
	{ 'Razon socia'															, .T. }, ; //X3_TITSPA
	{ 'Company Name'														, .T. }, ; //X3_TITENG
	{ 'Razão Social Cliente'												, .T. }, ; //X3_DESCRIC
	{ 'Razon social cliente'												, .T. }, ; //X3_DESCSPA
	{ 'Customer Company Name'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI,Posicione("SA1", 1, xFilial("SA1")+FWFldGet("G3F_CODCLI")+FWFldGet("G3F_LOJA"), "A1_NOME"),"")', .T. }, ; //X3_RELACAO
	{ 'G3E'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'Posicione("SA1", 1, xFilial("SA1")+G3F->G3F_CODCLI+G3F->G3F_LOJA, "A1_NOME")', .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ '001'																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3H
//
aAdd( aSX3, { ;
{ 'G3H'																	, .T. }, ; //X3_ARQUIVO
{ '11'																	, .T. }, ; //X3_ORDEM
{ 'G3H_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3H'																	, .T. }, ; //X3_ARQUIVO
{ '12'																	, .T. }, ; //X3_ORDEM
{ 'G3H_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3I
//
aAdd( aSX3, { ;
	{ 'G3I'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'G3I_DESCPO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Descrição'															, .T. }, ; //X3_TITULO
	{ 'Descripcion'															, .T. }, ; //X3_TITSPA
	{ 'Description'															, .T. }, ; //X3_TITENG
	{ 'Nome do Posto.'														, .T. }, ; //X3_DESCRIC
	{ 'Nombre del puesto.'													, .T. }, ; //X3_DESCSPA
	{ 'Position Name'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI,POSICIONE("G3M",1,G3I->G3I_FILPST+G3I->G3I_POSTO,"G3M_DESCR"),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'IIF(!INCLUI,POSICIONE("G3M",1,G3I->G3I_FILPST+G3I->G3I_POSTO,"G3M_DESCR"),"")', .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3J
//
aAdd( aSX3, { ;
{ 'G3J'																	, .T. }, ; //X3_ARQUIVO
{ '31'																	, .T. }, ; //X3_ORDEM
{ 'G3J_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3J'																	, .T. }, ; //X3_ARQUIVO
{ '32'																	, .T. }, ; //X3_ORDEM
{ 'G3J_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3M
//

aAdd( aSX3, { ;
{ 'G3M'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G3M_CODMUN'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód. Mun.'															, .T. }, ; //X3_TITULO
{ 'Cod. Mun.'															, .T. }, ; //X3_TITSPA
{ 'City Code'															, .T. }, ; //X3_TITENG
{ 'Código do Municipio'													, .T. }, ; //X3_DESCRIC
{ 'Codigo del municipio'												, .T. }, ; //X3_DESCSPA
{ 'City Code'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ "Vazio() .or. ExistCpo('G5S',FwFldGet('G3M_CODMUN'))"					, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5S'																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ 'FwFldGet("G3M_EST") <> " "'											, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME


aAdd( aSX3, { ;
{ 'G3M'																	, .T. }, ; //X3_ARQUIVO
{ '06'																	, .T. }, ; //X3_ORDEM
{ 'G3M_XBAIRR'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 30																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Bairro'																, .T. }, ; //X3_TITULO
{ 'Bairro'																, .T. }, ; //X3_TITSPA
{ 'Bairro'																, .T. }, ; //X3_TITENG
{ 'Bairro'																, .T. }, ; //X3_DESCRIC
{ 'Bairro'																, .T. }, ; //X3_DESCSPA
{ 'Bairro'																, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3M'																	, .T. }, ; //X3_ARQUIVO
{ '23'																	, .T. }, ; //X3_ORDEM
{ 'G3M_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3M'																	, .T. }, ; //X3_ARQUIVO
{ '24'																	, .T. }, ; //X3_ORDEM
{ 'G3M_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3N
//
aAdd( aSX3, { ;
{ 'G3N'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G3N_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3N'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G3N_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3P
//
aAdd( aSX3, { ;
	{ 'G3P'																	, .T. }, ; //X3_ARQUIVO
	{ '09'																	, .T. }, ; //X3_ORDEM
	{ 'G3P_RAZAO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Razão Social'														, .T. }, ; //X3_TITULO
	{ 'Razón Social'														, .T. }, ; //X3_TITSPA
	{ 'Company Name'														, .T. }, ; //X3_TITENG
	{ 'Razão Social do Cliente'												, .T. }, ; //X3_DESCRIC
	{ 'Razón social del cliente'											, .T. }, ; //X3_DESCSPA
	{ 'Customer Company Name'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'POSICIONE("SA1",1,XFILIAL("SA1")+G3P->G3P_CLIENT+G3P->G3P_LOJA,"A1_NOME")', .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3P'																	, .T. }, ; //X3_ARQUIVO
{ '27'																	, .T. }, ; //X3_ORDEM
{ 'G3P_XCIDAD'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 20																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cid. Evento'															, .T. }, ; //X3_TITULO
{ 'Cid. Evento'															, .T. }, ; //X3_TITSPA
{ 'Cid. Evento'															, .T. }, ; //X3_TITENG
{ 'Cidade Evento'														, .T. }, ; //X3_DESCRIC
{ 'Cidade Evento'														, .T. }, ; //X3_DESCSPA
{ 'Cidade Evendo'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5S'																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ 'ISINCALLSTACK("TURA034B")'											, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3P'																	, .T. }, ; //X3_ARQUIVO
{ '29'																	, .T. }, ; //X3_ORDEM
{ 'G3P_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3P'																	, .T. }, ; //X3_ARQUIVO
{ '30'																	, .T. }, ; //X3_ORDEM
{ 'G3P_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME



//
// Campos Tabela G3Q
//
aAdd( aSX3, { ;
	{ 'G3Q'																	, .T. }, ; //X3_ARQUIVO
	{ '17'																	, .T. }, ; //X3_ORDEM
	{ 'G3Q_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Cliente'														, .T. }, ; //X3_TITULO
	{ 'Nombre Clien'														, .T. }, ; //X3_TITSPA
	{ 'Custmr Name'															, .T. }, ; //X3_TITENG
	{ 'Nome do Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Nombre del cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Customer Name'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3Q'																	, .T. }, ; //X3_ARQUIVO
{ '19'																	, .T. }, ; //X3_ORDEM
{ 'G3Q_PROD'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 15																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Produto'																, .T. }, ; //X3_TITULO
{ 'Producto'															, .T. }, ; //X3_TITSPA
{ 'Product'																, .T. }, ; //X3_TITENG
{ 'Código do Produto'													, .T. }, ; //X3_DESCRIC
{ 'Código del producto'													, .T. }, ; //X3_DESCSPA
{ 'Product Code'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Tura34VldIV("G3Q_PROD")'												, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'SB1TUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '030'																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3Q'																	, .T. }, ; //X3_ARQUIVO
{ '20'																	, .T. }, ; //X3_ORDEM
{ 'G3Q_DESPRD'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 60																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Desc. Prod.'															, .T. }, ; //X3_TITULO
{ 'Desc. Prod.'															, .T. }, ; //X3_TITSPA
{ 'Prod Descr'															, .T. }, ; //X3_TITENG
{ 'Descrição do Produto'												, .T. }, ; //X3_DESCRIC
{ 'Descrip. del producto'												, .T. }, ; //X3_DESCSPA
{ 'Product Description'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ 'Posicione("SB1",1,xFilial("SB1")+G3Q->G3Q_PROD,"SB1->B1_DESC")'		, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(158) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

/*aAdd( aSX3, { ;
{ 'G3Q'																	, .T. }, ; //X3_ARQUIVO
{ '52'																	, .T. }, ; //X3_ORDEM
{ 'G3Q_SOLIC'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 6																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Solicitante'															, .T. }, ; //X3_TITULO
{ 'Solicitante'															, .T. }, ; //X3_TITSPA
{ 'Requester'															, .T. }, ; //X3_TITENG
{ 'Solicitante'															, .T. }, ; //X3_DESCRIC
{ 'Solicitante'															, .T. }, ; //X3_DESCSPA
{ 'Requester'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("SU5")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'SU5TUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME
*/
aAdd( aSX3, { ;
{ 'G3Q'																	, .T. }, ; //X3_ARQUIVO
{ '72'																	, .T. }, ; //X3_ORDEM
{ 'G3Q_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3Q'																	, .T. }, ; //X3_ARQUIVO
{ '73'																	, .T. }, ; //X3_ORDEM
{ 'G3Q_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3R
//
/*aAdd( aSX3, { ;
{ 'G3R'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G3R_FORNEC'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 9																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Forn. Prod.'															, .T. }, ; //X3_TITULO
{ 'Prov. Prod.'															, .T. }, ; //X3_TITSPA
{ 'ProdSupplier'														, .T. }, ; //X3_TITENG
{ 'Código do Fornecedor'												, .T. }, ; //X3_DESCRIC
{ 'Código del proveedor'												, .T. }, ; //X3_DESCSPA
{ 'Supplier Code'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("SA2",M->G3R_FORNEC)'										, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G4TTUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '001'																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME
*/

aAdd( aSX3, { ;
	{ 'G3R'																	, .T. }, ; //X3_ARQUIVO
	{ '15'																	, .T. }, ; //X3_ORDEM
	{ 'G3R_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Fornec.'														, .T. }, ; //X3_TITULO
	{ 'Nomb Prov.'															, .T. }, ; //X3_TITSPA
	{ 'Supplier Nam'														, .T. }, ; //X3_TITENG
	{ 'Nome do Fornecedor'													, .T. }, ; //X3_DESCRIC
	{ 'Nombre del proveedor'												, .T. }, ; //X3_DESCSPA
	{ 'Supplier Name'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI,ALLTRIM(POSICIONE("SA2",1,XFILIAL("SA2")+G3R->G3R_FORNEC+G3R->G3R_LOJA,"A2_NOME")),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(147) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G3R'																	, .T. }, ; //X3_ARQUIVO
	{ '18'																	, .T. }, ; //X3_ORDEM
	{ 'G3R_NOMREP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Reporte'														, .T. }, ; //X3_TITULO
	{ 'Nom Informe'															, .T. }, ; //X3_TITSPA
	{ 'Report Name'															, .T. }, ; //X3_TITENG
	{ 'Nome Fornecedor Reporte'												, .T. }, ; //X3_DESCRIC
	{ 'Nombre Proveedor Informe'											, .T. }, ; //X3_DESCSPA
	{ 'Report Supplier Name'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI,ALLTRIM(POSICIONE("SA2",1,XFILIAL("SA2")+G3R->G3R_FORREP+G3R->G3R_LOJREP,"A2_NOME")),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3R'																	, .T. }, ; //X3_ARQUIVO
{ '20'																	, .T. }, ; //X3_ORDEM
{ 'G3R_DESPRD'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 60																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Desc Produto'														, .T. }, ; //X3_TITULO
{ 'Desc Product'														, .T. }, ; //X3_TITSPA
{ 'Product Desc'														, .T. }, ; //X3_TITENG
{ 'Descrição do Produto'												, .T. }, ; //X3_DESCRIC
{ 'Descripción del producto'											, .T. }, ; //X3_DESCSPA
{ 'Product Description'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ 'IIF(!INCLUI,ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+G3R->G3R_PROD,"B1_DESC")),"")', .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'V'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3R'																	, .T. }, ; //X3_ARQUIVO
{ '25'																	, .T. }, ; //X3_ORDEM
{ 'G3R_POSTOR'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 6																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Posto'																, .T. }, ; //X3_TITULO
{ 'Puesto'																, .T. }, ; //X3_TITSPA
{ 'Station'																, .T. }, ; //X3_TITENG
{ 'Código Posto Atendimento'											, .T. }, ; //X3_DESCRIC
{ 'Cód. Puesto de atención'												, .T. }, ; //X3_DESCSPA
{ 'Service Station Code'												, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G3M'																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3R'																	, .T. }, ; //X3_ARQUIVO
{ '71'																	, .T. }, ; //X3_ORDEM
{ 'G3R_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3R'																	, .T. }, ; //X3_ARQUIVO
{ '72'																	, .T. }, ; //X3_ORDEM
{ 'G3R_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3S
//
/*aAdd( aSX3, { ;
	{ 'G3S'																	, .T. }, ; //X3_ARQUIVO
	{ '17'																	, .T. }, ; //X3_ORDEM
	{ 'G3S_EMAIL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'E-mail'																, .T. }, ; //X3_TITULO
	{ 'E-mail'																, .T. }, ; //X3_TITSPA
	{ 'E-mail'																, .T. }, ; //X3_TITENG
	{ 'E-mail do Passageiro'												, .T. }, ; //X3_DESCRIC
	{ 'E-mail del pasajero'													, .T. }, ; //X3_DESCSPA
	{ 'Passenger E-mail'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'IsEmail(AllTrim(M->G3S_EMAIL))'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'FwFldGet(' + SIMPLES + 'G3R_DETPAX' + SIMPLES + ') == ' + DUPLAS  + '1' + DUPLAS  + '', .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME
*/

aAdd( aSX3, { ;
{ 'G3S'																	, .T. }, ; //X3_ARQUIVO
{ '24'																	, .T. }, ; //X3_ORDEM
{ 'G3S_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3S'																	, .T. }, ; //X3_ARQUIVO
{ '25'																	, .T. }, ; //X3_ORDEM
{ 'G3S_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3T
//
aAdd( aSX3, { ;
	{ 'G3T'																	, .T. }, ; //X3_ARQUIVO
	{ '13'																	, .T. }, ; //X3_ORDEM
	{ 'G3T_NOMFOR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Cia.'															, .T. }, ; //X3_TITULO
	{ 'Nomb Cía.'															, .T. }, ; //X3_TITSPA
	{ 'Company Name'														, .T. }, ; //X3_TITENG
	{ 'Nome do Fornecedor'													, .T. }, ; //X3_DESCRIC
	{ 'Nombre del proveedor'												, .T. }, ; //X3_DESCSPA
	{ 'Supplier Name'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3T'																	, .T. }, ; //X3_ARQUIVO
{ '31'																	, .T. }, ; //X3_ORDEM
{ 'G3T_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3T'																	, .T. }, ; //X3_ARQUIVO
{ '32'																	, .T. }, ; //X3_ORDEM
{ 'G3T_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3U
//
aAdd( aSX3, { ;
{ 'G3U'																	, .T. }, ; //X3_ARQUIVO
{ '27'																	, .T. }, ; //X3_ORDEM
{ 'G3U_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3U'																	, .T. }, ; //X3_ARQUIVO
{ '28'																	, .T. }, ; //X3_ORDEM
{ 'G3U_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3V
//
aAdd( aSX3, { ;
{ 'G3V'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G3V_CIDRET'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cidade Ret.'															, .T. }, ; //X3_TITULO
{ 'Ciudad Ret.'															, .T. }, ; //X3_TITSPA
{ 'Removal City'														, .T. }, ; //X3_TITENG
{ 'Cidade Retirada'														, .T. }, ; //X3_DESCRIC
{ 'Ciudad retirada'														, .T. }, ; //X3_DESCSPA
{ 'Removal City'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3V'																	, .T. }, ; //X3_ARQUIVO
{ '11'																	, .T. }, ; //X3_ORDEM
{ 'G3V_CIDDEV'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cidade Dev.'															, .T. }, ; //X3_TITULO
{ 'Ciudad Dev.'															, .T. }, ; //X3_TITSPA
{ 'Ret City'															, .T. }, ; //X3_TITENG
{ 'Cidade da Devolução'													, .T. }, ; //X3_DESCRIC
{ 'Ciudad de la devolución'												, .T. }, ; //X3_DESCSPA
{ 'Return City'															, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3V'																	, .T. }, ; //X3_ARQUIVO
{ '30'																	, .T. }, ; //X3_ORDEM
{ 'G3V_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3V'																	, .T. }, ; //X3_ARQUIVO
{ '31'																	, .T. }, ; //X3_ORDEM
{ 'G3V_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3W
//
aAdd( aSX3, { ;
{ 'G3W'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G3W_CIDEMB'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cid. Embarq.'														, .T. }, ; //X3_TITULO
{ 'Ciu. Embarq.'														, .T. }, ; //X3_TITSPA
{ 'Board City'															, .T. }, ; //X3_TITENG
{ 'Cidade de Embarque'													, .T. }, ; //X3_DESCRIC
{ 'Ciudad de embarque'													, .T. }, ; //X3_DESCSPA
{ 'Boarding City'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3W'																	, .T. }, ; //X3_ARQUIVO
{ '14'																	, .T. }, ; //X3_ORDEM
{ 'G3W_CIDDES'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cid. Desemb.'														, .T. }, ; //X3_TITULO
{ 'Ciu. Desemb.'														, .T. }, ; //X3_TITSPA
{ 'Land City'															, .T. }, ; //X3_TITENG
{ 'Cidade Desembarque'													, .T. }, ; //X3_DESCRIC
{ 'Ciudad desembarque'													, .T. }, ; //X3_DESCSPA
{ 'Landing City'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3W'																	, .T. }, ; //X3_ARQUIVO
{ '23'																	, .T. }, ; //X3_ORDEM
{ 'G3W_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3W'																	, .T. }, ; //X3_ARQUIVO
{ '24'																	, .T. }, ; //X3_ORDEM
{ 'G3W_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3X
//
aAdd( aSX3, { ;
{ 'G3X'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G3X_CIDEMB'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cidade Emb.'															, .T. }, ; //X3_TITULO
{ 'Ciudad Emb.'															, .T. }, ; //X3_TITSPA
{ 'Ship City'															, .T. }, ; //X3_TITENG
{ 'Cidade Embarque'														, .T. }, ; //X3_DESCRIC
{ 'Ciudad embarque'														, .T. }, ; //X3_DESCSPA
{ 'Landing City'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3X'																	, .T. }, ; //X3_ARQUIVO
{ '14'																	, .T. }, ; //X3_ORDEM
{ 'G3X_CIDDES'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cidade Des.'															, .T. }, ; //X3_TITULO
{ 'Ciudad Des.'															, .T. }, ; //X3_TITSPA
{ 'Land City'															, .T. }, ; //X3_TITENG
{ 'Cidade de Desembarque'												, .T. }, ; //X3_DESCRIC
{ 'Ciudad del desembarque'												, .T. }, ; //X3_DESCSPA
{ 'Landing City'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3X'																	, .T. }, ; //X3_ARQUIVO
{ '22'																	, .T. }, ; //X3_ORDEM
{ 'G3X_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3X'																	, .T. }, ; //X3_ARQUIVO
{ '23'																	, .T. }, ; //X3_ORDEM
{ 'G3X_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3Y
//
aAdd( aSX3, { ;
{ 'G3Y'																	, .T. }, ; //X3_ARQUIVO
{ '12'																	, .T. }, ; //X3_ORDEM
{ 'G3Y_CIDPRI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cid. Princ.'															, .T. }, ; //X3_TITULO
{ 'Ciu. Princ.'															, .T. }, ; //X3_TITSPA
{ 'Main City'															, .T. }, ; //X3_TITENG
{ 'Cidade Principal'													, .T. }, ; //X3_DESCRIC
{ 'Ciudad principal'													, .T. }, ; //X3_DESCSPA
{ 'Main City'															, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3Y'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G3Y_CIDEMB'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cid. Embarq.'														, .T. }, ; //X3_TITULO
{ 'Ciu. Embarq.'														, .T. }, ; //X3_TITSPA
{ 'Board City'															, .T. }, ; //X3_TITENG
{ 'Cidade de Embarque'													, .T. }, ; //X3_DESCRIC
{ 'Ciudad de embarque'													, .T. }, ; //X3_DESCSPA
{ 'Boarding City'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3Y'																	, .T. }, ; //X3_ARQUIVO
{ '24'																	, .T. }, ; //X3_ORDEM
{ 'G3Y_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3Y'																	, .T. }, ; //X3_ARQUIVO
{ '25'																	, .T. }, ; //X3_ORDEM
{ 'G3Y_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G3Z
//
aAdd( aSX3, { ;
{ 'G3Z'																	, .T. }, ; //X3_ARQUIVO
{ '10'																	, .T. }, ; //X3_ORDEM
{ 'G3Z_CIDPRI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cid. Princ.'															, .T. }, ; //X3_TITULO
{ 'Ciu. Princ.'															, .T. }, ; //X3_TITSPA
{ 'Main City'															, .T. }, ; //X3_TITENG
{ 'Cidade Principal'													, .T. }, ; //X3_DESCRIC
{ 'Ciudad principal'													, .T. }, ; //X3_DESCSPA
{ 'Main City'															, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3Z'																	, .T. }, ; //X3_ARQUIVO
{ '11'																	, .T. }, ; //X3_ORDEM
{ 'G3Z_CIDEMB'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cid. Embarq.'														, .T. }, ; //X3_TITULO
{ 'Ciu. Embarq.'														, .T. }, ; //X3_TITSPA
{ 'Board City'															, .T. }, ; //X3_TITENG
{ 'Cidade de Embarque'													, .T. }, ; //X3_DESCRIC
{ 'Ciudad del embarque'													, .T. }, ; //X3_DESCSPA
{ 'Boarding City'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3Z'																	, .T. }, ; //X3_ARQUIVO
{ '21'																	, .T. }, ; //X3_ORDEM
{ 'G3Z_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G3Z'																	, .T. }, ; //X3_ARQUIVO
{ '22'																	, .T. }, ; //X3_ORDEM
{ 'G3Z_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G40
//
aAdd( aSX3, { ;
{ 'G40'																	, .T. }, ; //X3_ARQUIVO
{ '11'																	, .T. }, ; //X3_ORDEM
{ 'G40_CIDPRI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cid. Princ.'															, .T. }, ; //X3_TITULO
{ 'Ciu. Princ.'															, .T. }, ; //X3_TITSPA
{ 'Main City'															, .T. }, ; //X3_TITENG
{ 'Cidade Principal'													, .T. }, ; //X3_DESCRIC
{ 'Ciudad principal'													, .T. }, ; //X3_DESCSPA
{ 'Main City'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G40'																	, .T. }, ; //X3_ARQUIVO
{ '12'																	, .T. }, ; //X3_ORDEM
{ 'G40_CIDEMB'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cid. Embarq.'														, .T. }, ; //X3_TITULO
{ 'Ciu. Embarq.'														, .T. }, ; //X3_TITSPA
{ 'Board City'															, .T. }, ; //X3_TITENG
{ 'Cidade Embarque'														, .T. }, ; //X3_DESCRIC
{ 'Ciudad de embarque'													, .T. }, ; //X3_DESCSPA
{ 'Boarding City'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G40'																	, .T. }, ; //X3_ARQUIVO
{ '23'																	, .T. }, ; //X3_ORDEM
{ 'G40_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G40'																	, .T. }, ; //X3_ARQUIVO
{ '25'																	, .T. }, ; //X3_ORDEM
{ 'G40_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G41
//
aAdd( aSX3, { ;
{ 'G41'																	, .T. }, ; //X3_ARQUIVO
{ '20'																	, .T. }, ; //X3_ORDEM
{ 'G41_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G41'																	, .T. }, ; //X3_ARQUIVO
{ '21'																	, .T. }, ; //X3_ORDEM
{ 'G41_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G42
//
aAdd( aSX3, { ;
{ 'G42'																	, .T. }, ; //X3_ARQUIVO
{ '14'																	, .T. }, ; //X3_ORDEM
{ 'G42_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G42'																	, .T. }, ; //X3_ARQUIVO
{ '15'																	, .T. }, ; //X3_ORDEM
{ 'G42_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G43
//
aAdd( aSX3, { ;
{ 'G43'																	, .T. }, ; //X3_ARQUIVO
{ '11'																	, .T. }, ; //X3_ORDEM
{ 'G43_CIDDES'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cidade Dest.'														, .T. }, ; //X3_TITULO
{ 'Ciudad Dest.'														, .T. }, ; //X3_TITSPA
{ 'Dest City'															, .T. }, ; //X3_TITENG
{ 'Cidade destino'														, .T. }, ; //X3_DESCRIC
{ 'Ciudad de destino'													, .T. }, ; //X3_DESCSPA
{ 'Destination City'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G43'																	, .T. }, ; //X3_ARQUIVO
{ '17'																	, .T. }, ; //X3_ORDEM
{ 'G43_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G43'																	, .T. }, ; //X3_ARQUIVO
{ '18'																	, .T. }, ; //X3_ORDEM
{ 'G43_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G43'																	, .T. }, ; //X3_ARQUIVO
{ '10'																	, .T. }, ; //X3_ORDEM
{ 'G43_CIDEMB'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cidade Emb.'															, .T. }, ; //X3_TITULO
{ 'Ciudad Emb.'															, .T. }, ; //X3_TITSPA
{ 'Board City'															, .T. }, ; //X3_TITENG
{ 'Cidade Embarque'														, .T. }, ; //X3_DESCRIC
{ 'Ciudad de embarque'													, .T. }, ; //X3_DESCSPA
{ 'Boarding City'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G5S")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5STUR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME


//
// Campos Tabela G44
//
aAdd( aSX3, { ;
{ 'G44'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G44_BASTAR'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 12																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Base Tarifa'															, .T. }, ; //X3_TITULO
{ 'Base Tarifa'															, .T. }, ; //X3_TITSPA
{ 'Fee Basis'															, .T. }, ; //X3_TITENG
{ 'Código Base Tarifária'												, .T. }, ; //X3_DESCRIC
{ 'Código base tarifaria'												, .T. }, ; //X3_DESCSPA
{ 'Fee Base Code'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G44'																	, .T. }, ; //X3_ARQUIVO
{ '23'																	, .T. }, ; //X3_ORDEM
{ 'G44_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G44'																	, .T. }, ; //X3_ARQUIVO
{ '24'																	, .T. }, ; //X3_ORDEM
{ 'G44_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G46
//
aAdd( aSX3, { ;
{ 'G46'																	, .T. }, ; //X3_ARQUIVO
{ '18'																	, .T. }, ; //X3_ORDEM
{ 'G46_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G46'																	, .T. }, ; //X3_ARQUIVO
{ '19'																	, .T. }, ; //X3_ORDEM
{ 'G46_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G47
//
aAdd( aSX3, { ;
{ 'G47'																	, .T. }, ; //X3_ARQUIVO
{ '19'																	, .T. }, ; //X3_ORDEM
{ 'G47_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G47'																	, .T. }, ; //X3_ARQUIVO
{ '20'																	, .T. }, ; //X3_ORDEM
{ 'G47_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G48
//
aAdd( aSX3, { ;
	{ 'G48'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'G48_DESCR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 60																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Descrição'															, .T. }, ; //X3_TITULO
	{ 'Descripción'															, .T. }, ; //X3_TITSPA
	{ 'Description'															, .T. }, ; //X3_TITENG
	{ 'Descrição Acordo'													, .T. }, ; //X3_DESCRIC
	{ 'Descripción acuerdo'													, .T. }, ; //X3_DESCSPA
	{ 'Description'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G48'																	, .T. }, ; //X3_ARQUIVO
{ '46'																	, .T. }, ; //X3_ORDEM
{ 'G48_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G48'																	, .T. }, ; //X3_ARQUIVO
{ '47'																	, .T. }, ; //X3_ORDEM
{ 'G48_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G49
//
aAdd( aSX3, { ;
{ 'G49'																	, .T. }, ; //X3_ARQUIVO
{ '15'																	, .T. }, ; //X3_ORDEM
{ 'G49_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G49'																	, .T. }, ; //X3_ARQUIVO
{ '16'																	, .T. }, ; //X3_ORDEM
{ 'G49_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4A
//
aAdd( aSX3, { ;
{ 'G4A'																	, .T. }, ; //X3_ARQUIVO
{ '14'																	, .T. }, ; //X3_ORDEM
{ 'G4A_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4A'																	, .T. }, ; //X3_ARQUIVO
{ '15'																	, .T. }, ; //X3_ORDEM
{ 'G4A_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4B
//
aAdd( aSX3, { ;
{ 'G4B'																	, .T. }, ; //X3_ARQUIVO
{ '12'																	, .T. }, ; //X3_ORDEM
{ 'G4B_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4B'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G4B_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4C
//
aAdd( aSX3, { ;
{ 'G4C'																	, .T. }, ; //X3_ARQUIVO
{ '50'																	, .T. }, ; //X3_ORDEM
{ 'G4C_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4C'																	, .T. }, ; //X3_ARQUIVO
{ '51'																	, .T. }, ; //X3_ORDEM
{ 'G4C_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4D
//
aAdd( aSX3, { ;
{ 'G4D'																	, .T. }, ; //X3_ARQUIVO
{ '16'																	, .T. }, ; //X3_ORDEM
{ 'G4D_NSU'																, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 12																	, .T. }, ; //X3_TAMANHO
{ 0																	, .T. }, ; //X3_DECIMAL
{ 'Apr. Cartao'																	, .T. }, ; //X3_TITULO
{ 'Apr. Cartao'																	, .T. }, ; //X3_TITSPA
{ 'SSN'																	, .T. }, ; //X3_TITENG
{ 'Número Sequencial Único'												, .T. }, ; //X3_DESCRIC
{ 'Número secuencial único'												, .T. }, ; //X3_DESCSPA
{ 'Single Sequence Number'												, .T. }, ; //X3_DESCENG
{ '@999999999999'														, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4D'																	, .T. }, ; //X3_ARQUIVO
{ '21'																	, .T. }, ; //X3_ORDEM
{ 'G4D_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4D'																	, .T. }, ; //X3_ARQUIVO
{ '22'																	, .T. }, ; //X3_ORDEM
{ 'G4D_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4E
//
aAdd( aSX3, { ;
{ 'G4E'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G4E_DTSOLI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 6																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Chave Regis'															, .T. }, ; //X3_TITULO
{ 'Doc. Solic.'															, .T. }, ; //X3_TITSPA
{ 'Req Doc'																, .T. }, ; //X3_TITENG
{ 'Chave Registro Intranet'												, .T. }, ; //X3_DESCRIC
{ 'Doc. Solic.'															, .T. }, ; //X3_DESCSPA
{ 'Req. Doc.'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4E'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G4E_TPREE'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Tipo Solic.'															, .T. }, ; //X3_TITULO
{ 'Tipo Reemb.'															, .T. }, ; //X3_TITSPA
{ 'Reimb Tp'															, .T. }, ; //X3_TITENG
{ 'Tipo Solicitacao'													, .T. }, ; //X3_DESCRIC
{ 'Tipo reembolso'														, .T. }, ; //X3_DESCSPA
{ 'Reimburse Type'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ ''																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Voluntário;2=Involuntário'											, .T. }, ; //X3_CBOX
{ '1=Voluntario;2=Involuntario'											, .T. }, ; //X3_CBOXSPA
{ '1=Volunteering;2=Involuntary'										, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4E'																	, .F. }, ; //X3_ARQUIVO
{ '09'																	, .F. }, ; //X3_ORDEM
{ 'G4E_DESTFN'															, .F. }, ; //X3_CAMPO
{ 'C'																	, .F. }, ; //X3_TIPO
{ 1																		, .F. }, ; //X3_TAMANHO
{ 0																		, .F. }, ; //X3_DECIMAL
{ 'Destino Fin.'														, .F. }, ; //X3_TITULO
{ 'Destino Fin.'														, .F. }, ; //X3_TITSPA
{ 'Fin Target'															, .F. }, ; //X3_TITENG
{ 'Destino Financeiro'													, .F. }, ; //X3_DESCRIC
{ 'Destino financiero'													, .F. }, ; //X3_DESCSPA
{ 'Financials Destination'												, .F. }, ; //X3_DESCENG
{ '@!'																	, .F. }, ; //X3_PICTURE
{ ''																	, .F. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .F. }, ; //X3_USADO
{ '"2"'																	, .F. }, ; //X3_RELACAO
{ ''																	, .F. }, ; //X3_F3
{ 1																		, .F. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .F. }, ; //X3_RESERV
{ ''																	, .F. }, ; //X3_CHECK
{ ''																	, .F. }, ; //X3_TRIGGER
{ ''																	, .F. }, ; //X3_PROPRI
{ ''																	, .F. }, ; //X3_BROWSE
{ 'A'																	, .F. }, ; //X3_VISUAL
{ 'R'																	, .F. }, ; //X3_CONTEXT
{ ''																	, .F. }, ; //X3_OBRIGAT
{ ''																	, .F. }, ; //X3_VLDUSER
{ '1=Cliente;2=Agencia'													, .F. }, ; //X3_CBOX
{ '1=Cliente;2=Agencia'													, .F. }, ; //X3_CBOXSPA
{ '1=Cust;2=Agency'														, .F. }, ; //X3_CBOXENG
{ ''																	, .F. }, ; //X3_PICTVAR
{ ''																	, .F. }, ; //X3_WHEN
{ ''																	, .F. }, ; //X3_INIBRW
{ ''																	, .F. }, ; //X3_GRPSXG
{ ''																	, .F. }, ; //X3_FOLDER
{ ''																	, .F. }, ; //X3_CONDSQL
{ ''																	, .F. }, ; //X3_CHKSQL
{ 'N'																	, .F. }, ; //X3_IDXSRV
{ ''																	, .F. }, ; //X3_ORTOGRA
{ ''																	, .F. }, ; //X3_TELA
{ '2'																	, .F. }, ; //X3_POSLGT
{ 'N'																	, .F. }, ; //X3_IDXFLD
{ ''																	, .F. }, ; //X3_AGRUP
{ 'N'																	, .F. }, ; //X3_MODAL
{ 'N'																	, .F. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4E'																	, .T. }, ; //X3_ARQUIVO
{ '32'																	, .T. }, ; //X3_ORDEM
{ 'G4E_XENVCO'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Envia Compan'														, .T. }, ; //X3_TITULO
{ 'Envia Compan'														, .T. }, ; //X3_TITSPA
{ 'Envia Compan'														, .T. }, ; //X3_TITENG
{ 'Envia Companhia'														, .T. }, ; //X3_DESCRIC
{ 'Envia Companhia'														, .T. }, ; //X3_DESCSPA
{ 'Envia Companhia'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Aprovado;2=Reprovado'												, .T. }, ; //X3_CBOX
{ '1=Aprovado;2=Reprovado'												, .T. }, ; //X3_CBOXSPA
{ '1=Aprovado;2=Reprovado'												, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4E'																	, .T. }, ; //X3_ARQUIVO
{ '30'																	, .T. }, ; //X3_ORDEM
{ 'G4E_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4E'																	, .T. }, ; //X3_ARQUIVO
{ '31'																	, .T. }, ; //X3_ORDEM
{ 'G4E_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4E'																	, .T. }, ; //X3_ARQUIVO
{ '32'																	, .T. }, ; //X3_ORDEM
{ 'G4E_LIMREE'															, .T. }, ; //X3_CAMPO
{ 'D'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Limit. Reemb'														, .T. }, ; //X3_TITULO
{ 'Límit. Reemb'														, .T. }, ; //X3_TITSPA
{ 'Refund DueDt'														, .T. }, ; //X3_TITENG
{ 'Dt Limite do reembolso'												, .T. }, ; //X3_DESCRIC
{ 'Fch Límite del reembolso'											, .T. }, ; //X3_DESCSPA
{ 'Refund Due Date'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(198) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ ''																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME


//
// Campos Tabela G4F
//
aAdd( aSX3, { ;
{ 'G4F'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'G4F_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4F'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G4F_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4G
//
aAdd( aSX3, { ;
{ 'G4G'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G4G_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4G'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G4G_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4H
//
aAdd( aSX3, { ;
{ 'G4H'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G4H_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4H'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G4H_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4I
//
aAdd( aSX3, { ;
{ 'G4I'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'G4I_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log  DW'																, .T. }, ; //X3_TITULO
{ 'Log  DW'																, .T. }, ; //X3_TITSPA
{ 'Log  DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4I'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G4I_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4J
//
aAdd( aSX3, { ;
{ 'G4J'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'G4J_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4J'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G4J_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4L
//
aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '01'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_FILIAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Filial'																, .T. }, ; //X3_TITULO
	{ 'Sucursal'															, .T. }, ; //X3_TITSPA
	{ 'Branch'																, .T. }, ; //X3_TITENG
	{ 'Filial'																, .T. }, ; //X3_DESCRIC
	{ 'Sucursal'															, .T. }, ; //X3_DESCSPA
	{ 'Branch'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '033'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '02'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_CODIGO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Código'																, .T. }, ; //X3_TITULO
	{ 'Código'																, .T. }, ; //X3_TITSPA
	{ 'Code'																, .T. }, ; //X3_TITENG
	{ 'Código Complem Cliente'												, .T. }, ; //X3_DESCRIC
	{ 'Código Complem Cliente'												, .T. }, ; //X3_DESCSPA
	{ 'Cust Compl Code'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistChav("G4L",M->G4L_CODIGO) .Or. Vazio()'							, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(176)					, .T. }, ; //X3_USADO
	{ "GETSXENUM('G4L','G4L_CODIGO')"										, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(151) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'INCLUI'																, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_CLIENT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cód. Cliente'														, .T. }, ; //X3_TITULO
	{ 'Cód. Cliente'														, .T. }, ; //X3_TITSPA
	{ 'Cust Code'															, .T. }, ; //X3_TITENG
	{ 'Cód. Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Cód. Cliente'														, .T. }, ; //X3_DESCSPA
	{ 'Customer Code'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("SA1",M->G4L_CLIENT)'							, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA1G4L'																, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'INCLUI'																, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '001'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_LOJA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Loja'																, .T. }, ; //X3_TITULO
	{ 'Tienda'																, .T. }, ; //X3_TITSPA
	{ 'Store'																, .T. }, ; //X3_TITENG
	{ 'Loja do Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Tienda de cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Customer Store'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("SA1",M->G4L_CLIENT+M->G4L_LOJA)'				, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'INCLUI'																, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '002'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_XNOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Cliente'														, .T. }, ; //X3_TITULO
	{ 'Nome Cliente'														, .T. }, ; //X3_TITSPA
	{ 'Nome Cliente'														, .T. }, ; //X3_TITENG
	{ 'Nome Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Nome Cliente'														, .T. }, ; //X3_DESCSPA
	{ 'Nome Cliente'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_XMUN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 60																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Municipio'															, .T. }, ; //X3_TITULO
	{ 'Municipio'															, .T. }, ; //X3_TITSPA
	{ 'Municipio'															, .T. }, ; //X3_TITENG
	{ 'Municipio'															, .T. }, ; //X3_DESCRIC
	{ 'Municipio'															, .T. }, ; //X3_DESCSPA
	{ 'Municipio'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '07'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Cliente'														, .T. }, ; //X3_TITULO
	{ 'Nomb Cliente'														, .T. }, ; //X3_TITSPA
	{ 'Customer Nam'														, .T. }, ; //X3_TITENG
	{ 'Nome do Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Nombre del cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Customer Name'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IF(!INCLUI,POSICIONE("SA1",1,XFILIAL("SA1")+G4L->G4L_CLIENT+G4L->G4L_LOJA,"A1_NOME"),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ "POSICIONE('SA1', 1, XFILIAL('SA1')+G4L->G4L_CLIENT+G4L->G4L_LOJA,'A1_NOME')", .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '08'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_CORP'															, .T. }, ; //X3_CAMPO
	{ 'L'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Corporativo'															, .T. }, ; //X3_TITULO
	{ 'Corporativo'															, .T. }, ; //X3_TITSPA
	{ 'Corporative'															, .T. }, ; //X3_TITENG
	{ 'Compl. Corporativo'													, .T. }, ; //X3_DESCRIC
	{ 'Compl. Corporativo'													, .T. }, ; //X3_DESCSPA
	{ 'Corporative Compl'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '09'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_EVENTO'															, .T. }, ; //X3_CAMPO
	{ 'L'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Evento'																, .T. }, ; //X3_TITULO
	{ 'Evento'																, .T. }, ; //X3_TITSPA
	{ 'Event'																, .T. }, ; //X3_TITENG
	{ 'Compl. Eventos'														, .T. }, ; //X3_DESCRIC
	{ 'Compl. Eventos'														, .T. }, ; //X3_DESCSPA
	{ 'Events Compl'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_LAZER'															, .T. }, ; //X3_CAMPO
	{ 'L'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Lazer'																, .T. }, ; //X3_TITULO
	{ 'Ocio'																, .T. }, ; //X3_TITSPA
	{ 'Leisure'																, .T. }, ; //X3_TITENG
	{ 'Compl. Lazer'														, .T. }, ; //X3_DESCRIC
	{ 'Compl. Ocio'															, .T. }, ; //X3_DESCSPA
	{ 'Leisure Compl'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '11'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_MSBLQL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Bloqueado?'															, .T. }, ; //X3_TITULO
	{ 'Bloqueado?'															, .T. }, ; //X3_TITSPA
	{ 'Bloqueado?'															, .T. }, ; //X3_TITENG
	{ 'Registro bloqueado'													, .T. }, ; //X3_DESCRIC
	{ 'Registro bloqueado'													, .T. }, ; //X3_DESCSPA
	{ 'Registro bloqueado'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "'2'"																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'L'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
	{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
	{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '12'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_COMPAR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Compartilha'															, .T. }, ; //X3_TITULO
	{ 'Compartido'															, .T. }, ; //X3_TITSPA
	{ 'Share'																, .T. }, ; //X3_TITENG
	{ 'Compartilhado entre Lojas'											, .T. }, ; //X3_DESCRIC
	{ 'Compartido entre tiendas'											, .T. }, ; //X3_DESCSPA
	{ 'Shared among Stores'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"2"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
	{ '1=Sí;2=No'															, .T. }, ; //X3_CBOXSPA
	{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '13'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_XDWLOG'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 50																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt Alteracao'														, .T. }, ; //X3_TITULO
	{ 'Dt Alteracao'														, .T. }, ; //X3_TITSPA
	{ 'Dt Alteracao'														, .T. }, ; //X3_TITENG
	{ ''																	, .T. }, ; //X3_DESCRIC
	{ ''																	, .T. }, ; //X3_DESCSPA
	{ ''																	, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4L'																	, .T. }, ; //X3_ARQUIVO
	{ '14'																	, .T. }, ; //X3_ORDEM
	{ 'G4L_XENVBI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Enviado BI'															, .T. }, ; //X3_TITULO
	{ 'Enviado BI'															, .T. }, ; //X3_TITSPA
	{ 'Enviado BI'															, .T. }, ; //X3_TITENG
	{ ''																	, .T. }, ; //X3_DESCRIC
	{ ''																	, .T. }, ; //X3_DESCSPA
	{ ''																	, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME


//
// Campos Tabela G4K
//
aAdd( aSX3, { ;
{ 'G4K'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'G4K_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4K'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G4K_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4M
//
aAdd( aSX3, { ;
	{ 'G4M'																	, .T. }, ; //X3_ARQUIVO
	{ '12'																	, .T. }, ; //X3_ORDEM
	{ 'G4M_NOMPOS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Desc. Posto'															, .T. }, ; //X3_TITULO
	{ 'Desc. Puesto'														, .T. }, ; //X3_TITSPA
	{ 'Station Desc'														, .T. }, ; //X3_TITENG
	{ 'Desc Posto Atendimento'												, .T. }, ; //X3_DESCRIC
	{ 'Desc. puesto de atención'											, .T. }, ; //X3_DESCSPA
	{ 'Service Station Descr'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI,POSICIONE("G3M",1,G4M->G4M_FILPOS+G4M_CODPOS,"G3M_DESCR"),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'IIF(!INCLUI,POSICIONE("G3M",1,G4M->G4M_FILPOS+G4M_CODPOS,"G3M_DESCR"),"")', .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4P
//
aAdd( aSX3, { ;
	{ 'G4P'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'G4P_ENDER'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'End de Cobr'															, .T. }, ; //X3_TITULO
	{ 'Direc cobro'															, .T. }, ; //X3_TITSPA
	{ 'Collect Addr'														, .T. }, ; //X3_TITENG
	{ 'Endereço de Cobrança'												, .T. }, ; //X3_DESCRIC
	{ 'Dirección de cobro'													, .T. }, ; //X3_DESCSPA
	{ 'Collection Address'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4P'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'G4P_BAIRRO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 50																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Bairro Cobr'															, .T. }, ; //X3_TITULO
	{ 'Barrio cobro'														, .T. }, ; //X3_TITSPA
	{ 'Collect Dist'														, .T. }, ; //X3_TITENG
	{ 'Bairro de Cobrança'													, .T. }, ; //X3_DESCRIC
	{ 'Barrio de cobro'														, .T. }, ; //X3_DESCSPA
	{ 'Collection District'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4P'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G4P_MUNIC'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód. Mun.'															, .T. }, ; //X3_TITULO
{ 'Cód. Mun.'															, .T. }, ; //X3_TITSPA
{ 'City Code'															, .T. }, ; //X3_TITENG
{ 'Munic. endereço cobrança'											, .T. }, ; //X3_DESCRIC
{ 'Mun. direccion cobro'												, .T. }, ; //X3_DESCSPA
{ 'Collection Address City'												, .T. }, ; //X3_DESCENG
{ '@9'																	, .T. }, ; //X3_PICTURE
{ "Vazio() .or. ExistCpo('G5S',FwFldGet('G4P_MUNIC'))"					, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5S1'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

/*aAdd( aSX3, { ;
{ 'G4P'																	, .T. }, ; //X3_ARQUIVO
{ '12'																	, .T. }, ; //X3_ORDEM
{ 'G4P_EMAIL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'E-mail'																, .T. }, ; //X3_TITULO
{ 'E-mail venta'														, .T. }, ; //X3_TITSPA
{ 'Sale E-mail'															, .T. }, ; //X3_TITENG
{ 'E-mail de Cobrança'													, .T. }, ; //X3_DESCRIC
{ 'E-mail de venta'														, .T. }, ; //X3_DESCSPA
{ 'Sale E-mail'															, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME
*/
aAdd( aSX3, { ;
	{ 'G4P'																	, .T. }, ; //X3_ARQUIVO
	{ '16'																	, .T. }, ; //X3_ORDEM
	{ 'G4P_EMAILV'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 250																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'E-mail Envio'														, .T. }, ; //X3_TITULO
	{ 'E-mail envío'														, .T. }, ; //X3_TITSPA
	{ 'Send. E-mail'														, .T. }, ; //X3_TITENG
	{ 'E-mail de Envio'														, .T. }, ; //X3_DESCRIC
	{ 'E-mail de envío'														, .T. }, ; //X3_DESCSPA
	{ 'Sending E-mail'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4R
//
aAdd( aSX3, { ;
	{ 'G4R'																	, .T. }, ; //X3_ARQUIVO
	{ '01'																	, .T. }, ; //X3_ORDEM
	{ 'G4R_FILIAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Filial'																, .T. }, ; //X3_TITULO
	{ 'Sucursal'															, .T. }, ; //X3_TITSPA
	{ 'Branch'																, .T. }, ; //X3_TITENG
	{ 'Filial do Sistema'													, .T. }, ; //X3_DESCRIC
	{ 'Sucursal del sistema'												, .T. }, ; //X3_DESCSPA
	{ 'System Branch'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '033'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4R'																	, .T. }, ; //X3_ARQUIVO
	{ '02'																	, .T. }, ; //X3_ORDEM
	{ 'G4R_FORNEC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cód. Fornec.'														, .T. }, ; //X3_TITULO
	{ 'Cód. Proveed'														, .T. }, ; //X3_TITSPA
	{ 'Supplier Cod'														, .T. }, ; //X3_TITENG
	{ 'Código do Fornecedor'												, .T. }, ; //X3_DESCRIC
	{ 'Código del proveedor'												, .T. }, ; //X3_DESCSPA
	{ 'Supplier Code'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("SA2",M->G4R_FORNEC)'							, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA2G4R'																, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'INCLUI'																, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '001'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4R'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'G4R_LOJA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Loja'																, .T. }, ; //X3_TITULO
	{ 'Tienda'																, .T. }, ; //X3_TITSPA
	{ 'Store'																, .T. }, ; //X3_TITENG
	{ 'Loja do Fornecedor'													, .T. }, ; //X3_DESCRIC
	{ 'Tienda del proveedor'												, .T. }, ; //X3_DESCSPA
	{ 'Supplier Store'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Vazio() .Or. ( ExistCpo('SA2',M->G4R_FORNEC+M->G4R_LOJA) .And. ExistChav('G4R', FWFLDGET('G4R_FORNEC')+FWFLDGET('G4R_LOJA')))", .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'INCLUI'																, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '002'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4R'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'G4R_XNOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Fornec'															, .T. }, ; //X3_TITULO
	{ 'Nome Fornec'															, .T. }, ; //X3_TITSPA
	{ 'Nome Fornec'															, .T. }, ; //X3_TITENG
	{ 'Nome do Fornecedor'													, .T. }, ; //X3_DESCRIC
	{ 'Nome do Fornecedor'													, .T. }, ; //X3_DESCSPA
	{ 'Nome do Fornecedor'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4R'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'G4R_XMUN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 60																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Municipio'															, .T. }, ; //X3_TITULO
	{ 'Municipio'															, .T. }, ; //X3_TITSPA
	{ 'Municipio'															, .T. }, ; //X3_TITENG
	{ 'Municipio'															, .T. }, ; //X3_DESCRIC
	{ 'Municipio'															, .T. }, ; //X3_DESCSPA
	{ 'Municipio'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4R'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'G4R_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Fornecedor'															, .T. }, ; //X3_TITULO
	{ 'Proveedor'															, .T. }, ; //X3_TITSPA
	{ 'Supplier'															, .T. }, ; //X3_TITENG
	{ 'Nome do Fornecedor'													, .T. }, ; //X3_DESCRIC
	{ 'Nombre del proveedor'												, .T. }, ; //X3_DESCSPA
	{ 'Supplier Name'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IF(!INCLUI,POSICIONE("SA2",1,XFILIAL("SA2")+G4R->G4R_FORNEC+G4R->G4R_LOJA,"A2_NOME"),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'POSICIONE("SA2", 1, XFILIAL("SA2")+G4R->G4R_FORNEC+G4R->G4R_LOJA,"A2_NOME")', .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4R'																	, .T. }, ; //X3_ARQUIVO
	{ '07'																	, .T. }, ; //X3_ORDEM
	{ 'G4R_MSBLQL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Bloqueado?'															, .T. }, ; //X3_TITULO
	{ 'Bloqueado?'															, .T. }, ; //X3_TITSPA
	{ 'Bloqueado?'															, .T. }, ; //X3_TITENG
	{ 'Registro bloqueado'													, .T. }, ; //X3_DESCRIC
	{ 'Registro bloqueado'													, .T. }, ; //X3_DESCSPA
	{ 'Registro bloqueado'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "'2'"																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'L'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
	{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
	{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4S
//
aAdd( aSX3, { ;
{ 'G4S'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'G4S_TIPO'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Tipo Fornec.'														, .T. }, ; //X3_TITULO
{ 'Tipo Proveed'														, .T. }, ; //X3_TITSPA
{ 'Supplier Tp'															, .T. }, ; //X3_TITENG
{ 'Tipo de Fornecedor'													, .T. }, ; //X3_DESCRIC
{ 'Tipo de proveedor'													, .T. }, ; //X3_DESCSPA
{ 'Supplier Type'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ "Pertence('123456789ABCDEFG')"										, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Cia Aerea;2=HO;3=LC;4=CZ;5=RO;6=EVE;7=OS;8=BSP;9=Recep;A=Feiras;B=Inst Fin;C=Opr Tur;D=Cia Fer;E=Cia Seg;F=Desp;G=Ag Vi', .T. }, ; //X3_CBOX
{ '1=Cia Aerea;2=HO;3=LC;4=CZ;5=RO;6=EVE;7=OS;8=BSP;9=Recep;A=Feiras;B=Inst Fin;C=Opr Tur;D=Cia Fer;E=Cia Seg;F=Desp;G=Ag Vi', .T. }, ; //X3_CBOXSPA
{ '1=Cia Aerea;2=HO;3=LC;4=CZ;5=RO;6=EVE;7=OS;8=BSP;9=Recep;A=Feiras;B=Inst Fin;C=Opr Tur;D=Cia Fer;E=Cia Seg;F=Desp;G=Ag Vi', .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4S'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G4S_FONE'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 12																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Fone D. Res.'														, .T. }, ; //X3_TITULO
{ 'Telf. D. Res'														, .T. }, ; //X3_TITSPA
{ 'Res D Phone'															, .T. }, ; //X3_TITENG
{ 'Fone Dep. Res.'														, .T. }, ; //X3_DESCRIC
{ 'Telf. Dep. Res.'														, .T. }, ; //X3_DESCSPA
{ 'Res Dep Phone'														, .T. }, ; //X3_DESCENG
{ '@R (99)9999-9999'													, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4S'																	, .T. }, ; //X3_ARQUIVO
{ '10'																	, .T. }, ; //X3_ORDEM
{ 'G4S_FAX'																, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 12																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Fax D. Res'															, .T. }, ; //X3_TITULO
{ 'Fax D. Res'															, .T. }, ; //X3_TITSPA
{ 'Res D Fax'															, .T. }, ; //X3_TITENG
{ 'Fax Dep. Res.'														, .T. }, ; //X3_DESCRIC
{ 'Fax Dep. Res.'														, .T. }, ; //X3_DESCSPA
{ 'Res Dep Fax'															, .T. }, ; //X3_DESCENG
{ '@R (99)9999-9999'													, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4S'																	, .T. }, ; //X3_ARQUIVO
{ '11'																	, .T. }, ; //X3_ORDEM
{ 'G4S_EMAIL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Email D. Res'														, .T. }, ; //X3_TITULO
{ 'Email D. Res'														, .T. }, ; //X3_TITSPA
{ 'Res D Email'															, .T. }, ; //X3_TITENG
{ 'Email Dep. Res.'														, .T. }, ; //X3_DESCRIC
{ 'Email Dep. Res.'														, .T. }, ; //X3_DESCSPA
{ 'Res Dep Email'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4S'																	, .T. }, ; //X3_ARQUIVO
{ '12'																	, .T. }, ; //X3_ORDEM
{ 'G4S_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4S'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G4S_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G4V
//
aAdd( aSX3, { ;
	{ 'G4V'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'G4V_ENDER'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'End de Cobr'															, .T. }, ; //X3_TITULO
	{ 'Direc. cobro'														, .T. }, ; //X3_TITSPA
	{ 'Coll Address'														, .T. }, ; //X3_TITENG
	{ 'Endereço de Cobrança'												, .T. }, ; //X3_DESCRIC
	{ 'Dirección de cobro'													, .T. }, ; //X3_DESCSPA
	{ 'Collection Address'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G4V'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'G4V_BAIRRO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 50																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Bairro Cobr'															, .T. }, ; //X3_TITULO
	{ 'Barrio Cobro'														, .T. }, ; //X3_TITSPA
	{ 'Coll Distr'															, .T. }, ; //X3_TITENG
	{ 'Bairro de Cobrança'													, .T. }, ; //X3_DESCRIC
	{ 'Bairro de cobro'														, .T. }, ; //X3_DESCSPA
	{ 'Collection District'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4V'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G4V_MUNIC'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód. Mun.'															, .T. }, ; //X3_TITULO
{ 'Cód. Mun.'															, .T. }, ; //X3_TITSPA
{ 'City Code'															, .T. }, ; //X3_TITENG
{ 'Munic. endereço cobrança'											, .T. }, ; //X3_DESCRIC
{ 'Mun. direccion de cobro'												, .T. }, ; //X3_DESCSPA
{ 'Collection address city'												, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ "Vazio() .or. ExistCpo('G5S',FwFldGet('G4V_MUNIC'))"					, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5S1'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

/*--Retirado em 04/04/2017-Octavio
aAdd( aSX3, { ;
{ 'G4V'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G4V_EMAIL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'E-mail'																, .T. }, ; //X3_TITULO
{ 'E-mail'																, .T. }, ; //X3_TITSPA
{ 'E-mail'																, .T. }, ; //X3_TITENG
{ 'E-mail de Cobrança'													, .T. }, ; //X3_DESCRIC
{ 'E-mail de cobro'														, .T. }, ; //X3_DESCSPA
{ 'Collection E-mail'													, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME
*/
//
// Campos Tabela G4W
//
aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '01'																	, .T. }, ; //X3_ORDEM
{ 'G4W_FILIAL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Filial'																, .T. }, ; //X3_TITULO
{ 'Sucursal'															, .T. }, ; //X3_TITSPA
{ 'Branch'																, .T. }, ; //X3_TITENG
{ 'Filial Sistema'														, .T. }, ; //X3_DESCRIC
{ 'Sucursal Sistema'													, .T. }, ; //X3_DESCSPA
{ 'Branch of System'													, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '033'																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '02'																	, .T. }, ; //X3_ORDEM
{ 'G4W_DESCRI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Descrição'															, .T. }, ; //X3_TITULO
{ 'Descripción'															, .T. }, ; //X3_TITSPA
{ 'Description'															, .T. }, ; //X3_TITENG
{ 'Descrição do Acordo'													, .T. }, ; //X3_DESCRIC
{ 'Descripción del acuerdo'												, .T. }, ; //X3_DESCSPA
{ 'Agreement Description'												, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Tur20VldRev()'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '03'																	, .T. }, ; //X3_ORDEM
{ 'G4W_CODACO'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 6																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Código'																, .T. }, ; //X3_TITULO
{ 'Código'																, .T. }, ; //X3_TITSPA
{ 'Code'																, .T. }, ; //X3_TITENG
{ 'Código do Acordo'													, .T. }, ; //X3_DESCRIC
{ 'Código del acuerdo'													, .T. }, ; //X3_DESCSPA
{ 'Agreem Code'															, .T. }, ; //X3_DESCENG
{ '@'																	, .T. }, ; //X3_PICTURE
{ 'NaoVasio() .AND. ExistChav("G4W")'									, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ 'GETSXENUM("G4W","G4W_CODACO")'										, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'G4W_CODREV'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 2																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód. Revisão'														, .T. }, ; //X3_TITULO
{ 'Cód. Revisió'														, .T. }, ; //X3_TITSPA
{ 'Review Code'															, .T. }, ; //X3_TITENG
{ 'Código da Revisão'													, .T. }, ; //X3_DESCRIC
{ 'Código de la revisión'												, .T. }, ; //X3_DESCSPA
{ 'Review Code'															, .T. }, ; //X3_DESCENG
{ '@'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"00"'																, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G4W_TPVAL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Tp. Valor'															, .T. }, ; //X3_TITULO
{ 'Tp. Valor'															, .T. }, ; //X3_TITSPA
{ 'Value Type'															, .T. }, ; //X3_TITENG
{ 'Tipo de Valor'														, .T. }, ; //X3_DESCRIC
{ 'Tipo de valor'														, .T. }, ; //X3_DESCSPA
{ 'Value Type'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("12")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Porcentagem;2=Valor Fixo'											, .T. }, ; //X3_CBOX
{ '1=Porcentaje;2=Valor Fijo'											, .T. }, ; //X3_CBOXSPA
{ '1=Percentage;2=Fixed Value'											, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '06'																	, .T. }, ; //X3_ORDEM
{ 'G4W_VALOR'															, .T. }, ; //X3_CAMPO
{ 'N'																	, .T. }, ; //X3_TIPO
{ 14																	, .T. }, ; //X3_TAMANHO
{ 2																		, .T. }, ; //X3_DECIMAL
{ 'Valor'																, .T. }, ; //X3_TITULO
{ 'Valor'																, .T. }, ; //X3_TITSPA
{ 'Value'																, .T. }, ; //X3_TITENG
{ 'Valor'																, .T. }, ; //X3_DESCRIC
{ 'Valor'																, .T. }, ; //X3_DESCSPA
{ 'Value'																, .T. }, ; //X3_DESCENG
{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
{ 'Positivo()'															, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '07'																	, .T. }, ; //X3_ORDEM
{ 'G4W_BASCAL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 2																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Base Calc.'															, .T. }, ; //X3_TITULO
{ 'Base Calc.'															, .T. }, ; //X3_TITSPA
{ 'Calc. Basis'															, .T. }, ; //X3_TITENG
{ 'Base de Cálculo'														, .T. }, ; //X3_DESCRIC
{ 'Base de cálculo'														, .T. }, ; //X3_DESCSPA
{ 'Calculation Base'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'TUR20BasCalc()'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'X4'																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ "IIF(M->G4W_TPVAL<>'2',.T.,.F.)"										, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G4W_NIVEL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 2																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Nível'																, .T. }, ; //X3_TITULO
{ 'Nivel'																, .T. }, ; //X3_TITSPA
{ 'Level'																, .T. }, ; //X3_TITENG
{ 'Nível'																, .T. }, ; //X3_DESCRIC
{ 'Nivel'																, .T. }, ; //X3_DESCSPA
{ 'Level'																, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '00=Nivel 0;01=Nivel 1;02=Nivel 2;03=Nivel 3;04=Nivel 4;05=Nivel 5;06=Nivel 6;07=Nivel 7;08=Nivel 8;09=Nivel 9', .T. }, ; //X3_CBOX
{ '00=Nivel 0;01=Nivel 1;02=Nivel 2;03=Nivel 3;04=Nivel 4;05=Nivel 5;06=Nivel 6;07=Nivel 7;08=Nivel 8;09=Nivel 9', .T. }, ; //X3_CBOXSPA
{ '00=Level 0;01=Level 1;02=Level 2;03=Level 3;04=Level 4;05=Level 5;06=Level 6;07=Level 7;08=Level 8;09=Level 9', .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G4W_MSBLQL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Bloqueado'															, .T. }, ; //X3_TITULO
{ 'Bloqueado'															, .T. }, ; //X3_TITSPA
{ 'Blocked'																, .T. }, ; //X3_TITENG
{ 'Registro bloqueado'													, .T. }, ; //X3_DESCRIC
{ 'Registro bloqueado'													, .T. }, ; //X3_DESCSPA
{ 'Record Blocked'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ "'2'"																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
{ '1=Yes.2=No'															, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '10'																	, .T. }, ; //X3_ORDEM
{ 'G4W_DTALT'															, .T. }, ; //X3_CAMPO
{ 'D'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Dt. Altera'															, .T. }, ; //X3_TITULO
{ 'Fch Modifica'														, .T. }, ; //X3_TITSPA
{ 'Edit Date'															, .T. }, ; //X3_TITENG
{ 'Data/Hora de Alteração'												, .T. }, ; //X3_DESCRIC
{ 'Fch/Hora de modificación'											, .T. }, ; //X3_DESCSPA
{ 'Date/Time of Edit'													, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '11'																	, .T. }, ; //X3_ORDEM
{ 'G4W_USERAL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 25																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'User Altera'															, .T. }, ; //X3_TITULO
{ 'User Modific'														, .T. }, ; //X3_TITSPA
{ 'Editing User'														, .T. }, ; //X3_TITENG
{ 'Usuário da Alteração'												, .T. }, ; //X3_DESCRIC
{ 'Usuario de modificación'												, .T. }, ; //X3_DESCSPA
{ 'Editing User'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '12'																	, .T. }, ; //X3_ORDEM
{ 'G4W_ESTREE'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Est. Reemb.'															, .T. }, ; //X3_TITULO
{ 'Ext. Reemb.'															, .T. }, ; //X3_TITSPA
{ 'Reimb Rev'															, .T. }, ; //X3_TITENG
{ 'Estorno no Reembolso ?'												, .T. }, ; //X3_DESCRIC
{ '¿Extorno Reembolso?'													, .T. }, ; //X3_DESCSPA
{ 'Reimburse Reversal?'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("12")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"2"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(230) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
{ '1=Sí;2=No'															, .T. }, ; //X3_CBOXSPA
{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G4W_CLASSI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 3																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Classific.'															, .T. }, ; //X3_TITULO
{ 'Clasific.'															, .T. }, ; //X3_TITSPA
{ 'Classifictn.'														, .T. }, ; //X3_TITENG
{ 'Classificação do Acordo'												, .T. }, ; //X3_DESCRIC
{ 'Clasificación del acuerdo'											, .T. }, ; //X3_DESCSPA
{ 'Agreement Classification'											, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Vazio() .OR. (ExistCpo("G8B",FWFldGet("G4W_CLASSI"))  .And. SubStr(FWFldGet("G4W_CLASSI"),1,1) == "F") .And. Tur20VldRev()', .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G8BFOR'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

/*aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '14'																	, .T. }, ; //X3_ORDEM
{ 'G4W_TPACO'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Tp. Acordo'															, .T. }, ; //X3_TITULO
{ 'Tp. Acuerdo'															, .T. }, ; //X3_TITSPA
{ 'AgreemtType'															, .T. }, ; //X3_TITENG
{ 'Tipo de Acordo'														, .T. }, ; //X3_DESCRIC
{ 'Tipo de acuerdo'														, .T. }, ; //X3_DESCSPA
{ 'Agreement Type'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ 'IF(!INCLUI,Posicione("G8B",1, xFilial("G8B")+FwFldGet("G4W_CLASSI"),"G8B_TIPO"),"")', .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'V'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Receita;2=Abatimento de Receita;3=Demonstrativo'					, .T. }, ; //X3_CBOX
{ '1=Ingreso;2=Descuento de ingreso;3=Estado de resultado'				, .T. }, ; //X3_CBOXSPA
{ '1=Revenue;2=Revenue Deduction;3=Statement'							, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ 'Tur20InBrw(Posicione("G8B",1, xFilial("G8B")+G4W->G4W_CLASSI,"G8B_TIPO"))', .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME
*/

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '15'																	, .T. }, ; //X3_ORDEM
{ 'G4W_DESCLA'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 30																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Descr. Clas.'														, .T. }, ; //X3_TITULO
{ 'Descr. Clas.'														, .T. }, ; //X3_TITSPA
{ 'Class Descr'															, .T. }, ; //X3_TITENG
{ 'Descrição Classificação'												, .T. }, ; //X3_DESCRIC
{ 'Descripción clasificación'											, .T. }, ; //X3_DESCSPA
{ 'Classification Descriptio'											, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ 'IF(!INCLUI,Posicione("G8B",1, xFilial("G8B")+G4W->G4W_CLASSI,"G8B_DESCRI"),"")', .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'V'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ 'Posicione("G8B",1, xFilial("G8B")+G4W->G4W_CLASSI,"G8B_DESCRI")'		, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '16'																	, .T. }, ; //X3_ORDEM
{ 'G4W_TPENT'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Aplicar Ao'															, .T. }, ; //X3_TITULO
{ 'Aplicar Al'															, .T. }, ; //X3_TITSPA
{ 'Apply To'															, .T. }, ; //X3_TITENG
{ 'Aplicar Ao'															, .T. }, ; //X3_DESCRIC
{ 'Aplicar Al'															, .T. }, ; //X3_DESCSPA
{ 'Apply To'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'TUR20Aplic() .And. Tur20VldRev()'									, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Fornecedor;2=Reporte;3=Não se Aplica'								, .T. }, ; //X3_CBOX
{ '1=Proveedor;2=Informe;3=No se aplica'								, .T. }, ; //X3_CBOXSPA
{ '1=Supplier;2=Report;3=Non Applicable'								, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '17'																	, .T. }, ; //X3_ORDEM
{ 'G4W_FORAPL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Forma Aplic.'														, .T. }, ; //X3_TITULO
{ 'Forma Aplic.'														, .T. }, ; //X3_TITSPA
{ 'Applic.Metho'														, .T. }, ; //X3_TITENG
{ 'Forma de Aplicação'													, .T. }, ; //X3_DESCRIC
{ 'Forma de aplicación'													, .T. }, ; //X3_DESCSPA
{ 'Application Method'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence(" 12")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ '€'																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Manual;2=Automática'												, .T. }, ; //X3_CBOX
{ '1=Manual;2=Automática'												, .T. }, ; //X3_CBOXSPA
{ '1=Manual;2=Automatic'												, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '18'																	, .T. }, ; //X3_ORDEM
{ 'G4W_VIGINI'															, .T. }, ; //X3_CAMPO
{ 'D'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Vigência De'															, .T. }, ; //X3_TITULO
{ 'De Vigencia'															, .T. }, ; //X3_TITSPA
{ 'ValidityFrom'														, .T. }, ; //X3_TITENG
{ 'Vigência De'															, .T. }, ; //X3_DESCRIC
{ 'De Vigencia'															, .T. }, ; //X3_DESCSPA
{ 'Validity From'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'Tur20VldRev()'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '19'																	, .T. }, ; //X3_ORDEM
{ 'G4W_VIGFIM'															, .T. }, ; //X3_CAMPO
{ 'D'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Vigência Até'														, .T. }, ; //X3_TITULO
{ 'A Vigencia'															, .T. }, ; //X3_TITSPA
{ 'Validity To'															, .T. }, ; //X3_TITENG
{ 'Vigência Até'														, .T. }, ; //X3_DESCRIC
{ 'A Vigencia'															, .T. }, ; //X3_DESCSPA
{ 'Validity to'															, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '20'																	, .T. }, ; //X3_ORDEM
{ 'G4W_OBSERV'															, .T. }, ; //X3_CAMPO
{ 'M'																	, .T. }, ; //X3_TIPO
{ 10																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Observação'															, .T. }, ; //X3_TITULO
{ 'Observación'															, .T. }, ; //X3_TITSPA
{ 'Note'																, .T. }, ; //X3_TITENG
{ 'Observação'															, .T. }, ; //X3_DESCRIC
{ 'Observación'															, .T. }, ; //X3_DESCSPA
{ 'Note'																, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ 'Tur20VldRev()'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G4W'																	, .T. }, ; //X3_ARQUIVO
{ '21'																	, .T. }, ; //X3_ORDEM
{ 'G4W_DESCFT'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Na Fatura'															, .T. }, ; //X3_TITULO
{ 'En la Factur'														, .T. }, ; //X3_TITSPA
{ 'In Invoice'															, .T. }, ; //X3_TITENG
{ 'Na Fatura'															, .T. }, ; //X3_DESCRIC
{ 'En la Factura'														, .T. }, ; //X3_DESCSPA
{ 'In the Invoice'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence(" 12") .And. Tur20VldRev()'									, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"1"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ '€'																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
{ '1=Yes.2=No'															, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G5M
//
aAdd( aSX3, { ;
{ 'G5M'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G5M_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5M'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G5M_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G5N
//
aAdd( aSX3, { ;
	{ 'G5N'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'G5N_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome'																, .T. }, ; //X3_TITULO
	{ 'Nombre'																, .T. }, ; //X3_TITSPA
	{ 'Name'																, .T. }, ; //X3_TITENG
	{ 'Nome Fornecedor'														, .T. }, ; //X3_DESCRIC
	{ 'Nombre proveedor'													, .T. }, ; //X3_DESCSPA
	{ 'Supplier Name'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "IF(!INCLUI,POSICIONE('SA2',1,XFILIAL('SA2')+G5N->G5N_FORNEC,'A2_NOME'),'')", .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ "POSICIONE('SA2',1,XFILIAL('SA2')+G5N->G5N_FORNEC+G5N->G5N_LOJA,'A2_NOME')", .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5N'																	, .T. }, ; //X3_ARQUIVO
{ '07'																	, .T. }, ; //X3_ORDEM
{ 'G5N_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5N'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G5N_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G5O
//
aAdd( aSX3, { ;
{ 'G5O'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'G5O_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5O'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G5O_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G5S
//       
aAdd( aSX3, { ;
{	'G5S'																	, .T. }, ; //X3_ARQUIVO
{	'02'																	, .T. }, ; //X3_ORDEM
{	'G5S_CODIGO'															, .T. }, ; //X3_CAMPO
{	'C'																		, .T. }, ; //X3_TIPO
{	5																		, .T. }, ; //X3_TAMANHO
{	0																		, .T. }, ; //X3_DECIMAL
{	'Cód. Cidade'															, .T. }, ; //X3_TITULO
{	'Cód. Ciudad'															, .T. }, ; //X3_TITSPA
{	'City Code'																, .T. }, ; //X3_TITENG
{	'Código da Cidade'														, .T. }, ; //X3_DESCRIC
{	'Código de la ciudad'													, .T. }, ; //X3_DESCSPA
{	'City Code'																, .T. }, ; //X3_DESCENG
{	''																		, .T. }, ; //X3_PICTURE
{	''																		, .T. }, ; //X3_VALID
{	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{	'GETSXENUM("G5S","G5S_CODIGO")'											, .T. }, ; //X3_RELACAO
{	''																		, .T. }, ; //X3_F3
{	1																		, .T. }, ; //X3_NIVEL
{	Chr(132) + Chr(128)														, .T. }, ; //X3_RESERV
{	''																		, .T. }, ; //X3_CHECK
{	''																		, .T. }, ; //X3_TRIGGER
{	''																		, .T. }, ; //X3_PROPRI
{	'S'																		, .T. }, ; //X3_BROWSE
{	'V'																		, .T. }, ; //X3_VISUAL
{	'R'																		, .T. }, ; //X3_CONTEXT
{	''																		, .T. }, ; //X3_OBRIGAT
{	''																		, .T. }, ; //X3_VLDUSER
{	''																		, .T. }, ; //X3_CBOX
{	''																		, .T. }, ; //X3_CBOXSPA
{	''																		, .T. }, ; //X3_CBOXENG
{	''																		, .T. }, ; //X3_PICTVAR
{	''																		, .T. }, ; //X3_WHEN
{	''																		, .T. }, ; //X3_INIBRW
{	''																		, .T. }, ; //X3_GRPSXG
{	''																		, .T. }, ; //X3_FOLDER
{	''																		, .T. }, ; //X3_CONDSQL
{	''																		, .T. }, ; //X3_CHKSQL
{	'S'																		, .T. }, ; //X3_IDXSRV
{	''																		, .T. }, ; //X3_ORTOGRA
{	''																		, .T. }, ; //X3_TELA
{	'1'																		, .T. }, ; //X3_POSLGT
{	'N'																		, .T. }, ; //X3_IDXFLD
{	''																		, .T. }, ; //X3_AGRUP
{	'S'																		, .T. }, ; //X3_MODAL
{	'S'																		, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5S'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G5S_XNIATA'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 10																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'N° IATA'																, .T. }, ; //X3_TITULO
{ 'N° IATA'																, .T. }, ; //X3_TITSPA
{ 'N° IATA'																, .T. }, ; //X3_TITENG
{ 'N° IATA'																, .T. }, ; //X3_DESCRIC
{ 'N° IATA'																, .T. }, ; //X3_DESCSPA
{ 'N° IATA'																, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5S'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G5S_XAIATA'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 10																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Abrev. IATA'															, .T. }, ; //X3_TITULO
{ 'Abrev. IATA'															, .T. }, ; //X3_TITSPA
{ 'Abrev. IATA'															, .T. }, ; //X3_TITENG
{ 'Abrev. IATA'															, .T. }, ; //X3_DESCRIC
{ 'Abrev. IATA'															, .T. }, ; //X3_DESCSPA
{ 'Abrev. IATA'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5S'																	, .T. }, ; //X3_ARQUIVO
{ '11'																	, .T. }, ; //X3_ORDEM
{ 'G5S_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5S'																	, .T. }, ; //X3_ARQUIVO
{ '12'																	, .T. }, ; //X3_ORDEM
{ 'G5S_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G5V
//
aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '01'																	, .T. }, ; //X3_ORDEM
{ 'G5V_FILIAL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Filial'																, .T. }, ; //X3_TITULO
{ 'Sucursal'															, .T. }, ; //X3_TITSPA
{ 'Branch'																, .T. }, ; //X3_TITENG
{ 'Filial'																, .T. }, ; //X3_DESCRIC
{ 'Sucursal'															, .T. }, ; //X3_DESCSPA
{ 'Branch'																, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '033'																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '02'																	, .T. }, ; //X3_ORDEM
{ 'G5V_CODACO'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 6																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód. Acordo'															, .T. }, ; //X3_TITULO
{ 'Cód. Acuerdo'														, .T. }, ; //X3_TITSPA
{ 'Agreem Code'															, .T. }, ; //X3_TITENG
{ 'Código Acordo'														, .T. }, ; //X3_DESCRIC
{ 'Código acuerdo'														, .T. }, ; //X3_DESCSPA
{ 'Agreement Code'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'NaoVazio() .AND. ExistChav("G5V")'									, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ 'GETSXENUM("G5V","G5V_CODACO")'										, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '03'																	, .T. }, ; //X3_ORDEM
{ 'G5V_CODREV'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 2																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód. Revisão'														, .T. }, ; //X3_TITULO
{ 'Cód. Revis.'															, .T. }, ; //X3_TITSPA
{ 'Review Code'															, .T. }, ; //X3_TITENG
{ 'Código da Revisão'													, .T. }, ; //X3_DESCRIC
{ 'Código de la revisión'												, .T. }, ; //X3_DESCSPA
{ 'Revision Code'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"00"'																, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'G5V_DESCRI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Desc. Acordo'														, .T. }, ; //X3_TITULO
{ 'Desc. Acuerd'														, .T. }, ; //X3_TITSPA
{ 'AgreemtDescr'														, .T. }, ; //X3_TITENG
{ 'Descrição do Acordo'													, .T. }, ; //X3_DESCRIC
{ 'Descripción del acuerdo'												, .T. }, ; //X3_DESCSPA
{ 'Agreement Description'												, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ 'INCLUI'																, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G5V_TPFEE'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 3																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Tipo Fee'															, .T. }, ; //X3_TITULO
{ ''																	, .T. }, ; //X3_TITSPA
{ 'Fee Type'															, .T. }, ; //X3_TITENG
{ 'Tipo Fee'															, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ 'Fee Type'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ 'C01=Transaction;C02=Flat;C03=Management;C04=Success;C05=Combo-Transaction;C06=Taxa;C07=Repasse;C08=Desconto;C09=Markup', .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ 'C01=Transaction;C02=Flat;C03=Management;C04=Success;C05=Combo-Transaction;C06=Rate;C07=Transfer;C08=Discount;C09=Markup', .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '06'																	, .T. }, ; //X3_ORDEM
{ 'G5V_TPACO'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Tipo Acordo'															, .T. }, ; //X3_TITULO
{ 'Tipo acuerdo'														, .T. }, ; //X3_TITSPA
{ 'Agreem Tp'															, .T. }, ; //X3_TITENG
{ 'Tipo de Acordo'														, .T. }, ; //X3_DESCRIC
{ 'Tipo de acuerdo'														, .T. }, ; //X3_DESCSPA
{ 'Agreement Type'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("123")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Receita;2=Abatimento de Receita;3=Demonstrativo'					, .T. }, ; //X3_CBOX
{ '1=Ingreso;2=Descuento de ingreso;3=Informe'							, .T. }, ; //X3_CBOXSPA
{ '1=Revenue;2=Deduction of Revenue;3=Statement'						, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '07'																	, .T. }, ; //X3_ORDEM
{ 'G5V_FORAPL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Forma Aplic.'														, .T. }, ; //X3_TITULO
{ 'Forma Aplic.'														, .T. }, ; //X3_TITSPA
{ 'Appl Method'															, .T. }, ; //X3_TITENG
{ 'Forma de Aplicação'													, .T. }, ; //X3_DESCRIC
{ 'Forma de aplicación'													, .T. }, ; //X3_DESCSPA
{ 'Application Method'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("12")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Manual;2=Automática'												, .T. }, ; //X3_CBOX
{ '1=Manual;2=Automática'												, .T. }, ; //X3_CBOXSPA
{ '1=Manual;2=Automatic'												, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G5V_BASCAL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 2																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Base Cálc.'															, .T. }, ; //X3_TITULO
{ 'Base Cálc.'															, .T. }, ; //X3_TITSPA
{ 'Calc Base'															, .T. }, ; //X3_TITENG
{ 'Base de Cálculo'														, .T. }, ; //X3_DESCRIC
{ 'Base de cálculo'														, .T. }, ; //X3_DESCSPA
{ 'Calculation Basis'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("SX5","X5"+M->G5V_BASCAL) .And. Tur33BasCalc()'				, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'X5'																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G5V_VALOR'															, .T. }, ; //X3_CAMPO
{ 'N'																	, .T. }, ; //X3_TIPO
{ 14																	, .T. }, ; //X3_TAMANHO
{ 2																		, .T. }, ; //X3_DECIMAL
{ 'Valor'																, .T. }, ; //X3_TITULO
{ 'Valor'																, .T. }, ; //X3_TITSPA
{ 'Value'																, .T. }, ; //X3_TITENG
{ 'Valor'																, .T. }, ; //X3_DESCRIC
{ 'Valor'																, .T. }, ; //X3_DESCSPA
{ 'Value'																, .T. }, ; //X3_DESCENG
{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
{ 'Positivo()'															, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '10'																	, .T. }, ; //X3_ORDEM
{ 'G5V_FTSERV'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Na Fatura'															, .T. }, ; //X3_TITULO
{ 'En factura'															, .T. }, ; //X3_TITSPA
{ 'Invoice'																, .T. }, ; //X3_TITENG
{ 'Fatura com Serviço'													, .T. }, ; //X3_DESCRIC
{ 'Factura con servicio'												, .T. }, ; //X3_DESCSPA
{ 'Invoice with Service'												, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("12")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"2"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
{ '1=Yes.2=No'															, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '11'																	, .T. }, ; //X3_ORDEM
{ 'G5V_VIGINI'															, .T. }, ; //X3_CAMPO
{ 'D'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Vigência de'															, .T. }, ; //X3_TITULO
{ 'De vigencia'															, .T. }, ; //X3_TITSPA
{ 'Validity fro'														, .T. }, ; //X3_TITENG
{ 'Vigência de:'														, .T. }, ; //X3_DESCRIC
{ 'De vigencia:'														, .T. }, ; //X3_DESCSPA
{ 'Validity from:'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '12'																	, .T. }, ; //X3_ORDEM
{ 'G5V_VIGFIM'															, .T. }, ; //X3_CAMPO
{ 'D'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Vigência até'														, .T. }, ; //X3_TITULO
{ 'A vigencia'															, .T. }, ; //X3_TITSPA
{ 'Validity to'															, .T. }, ; //X3_TITENG
{ 'Vigência até:'														, .T. }, ; //X3_DESCRIC
{ 'A vigencia:'															, .T. }, ; //X3_DESCSPA
{ 'Validity to:'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G5V_OBSERV'															, .T. }, ; //X3_CAMPO
{ 'M'																	, .T. }, ; //X3_TIPO
{ 10																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Observação'															, .T. }, ; //X3_TITULO
{ 'Observación'															, .T. }, ; //X3_TITSPA
{ 'Note'																, .T. }, ; //X3_TITENG
{ 'Observação'															, .T. }, ; //X3_DESCRIC
{ 'Observación'															, .T. }, ; //X3_DESCSPA
{ 'Note'																, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '14'																	, .T. }, ; //X3_ORDEM
{ 'G5V_MSBLQL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Bloqueado'															, .T. }, ; //X3_TITULO
{ 'Bloqueado'															, .T. }, ; //X3_TITSPA
{ 'Blocked'																, .T. }, ; //X3_TITENG
{ 'Registro Bloqueado'													, .T. }, ; //X3_DESCRIC
{ 'Registro Bloqueado'													, .T. }, ; //X3_DESCSPA
{ 'Record Blocked'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"2"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
{ '1=Yes.2=No'															, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '15'																	, .T. }, ; //X3_ORDEM
{ 'G5V_CORP'															, .T. }, ; //X3_CAMPO
{ 'L'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Corporativo'															, .T. }, ; //X3_TITULO
{ 'Corporativo'															, .T. }, ; //X3_TITSPA
{ 'Corporate'															, .T. }, ; //X3_TITENG
{ 'Corporativo'															, .T. }, ; //X3_DESCRIC
{ 'Corporativo'															, .T. }, ; //X3_DESCSPA
{ 'Corporate'															, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '16'																	, .T. }, ; //X3_ORDEM
{ 'G5V_EVENTO'															, .T. }, ; //X3_CAMPO
{ 'L'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Evento'																, .T. }, ; //X3_TITULO
{ 'Evento'																, .T. }, ; //X3_TITSPA
{ 'Event'																, .T. }, ; //X3_TITENG
{ 'Evento'																, .T. }, ; //X3_DESCRIC
{ 'Evento'																, .T. }, ; //X3_DESCSPA
{ 'Event'																, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '17'																	, .T. }, ; //X3_ORDEM
{ 'G5V_LAZER'															, .T. }, ; //X3_CAMPO
{ 'L'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Lazer'																, .T. }, ; //X3_TITULO
{ 'Diversión'															, .T. }, ; //X3_TITSPA
{ 'Leisure'																, .T. }, ; //X3_TITENG
{ 'Lazer'																, .T. }, ; //X3_DESCRIC
{ 'Diversión'															, .T. }, ; //X3_DESCSPA
{ 'Leisure'																, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '18'																	, .T. }, ; //X3_ORDEM
{ 'G5V_PASSAG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Por Passag.'															, .T. }, ; //X3_TITULO
{ 'Por Pasajero'														, .T. }, ; //X3_TITSPA
{ 'By Passenger'														, .T. }, ; //X3_TITENG
{ 'Por Passageiro'														, .T. }, ; //X3_DESCRIC
{ 'Por pasajero'														, .T. }, ; //X3_DESCSPA
{ 'By Passenger'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("12")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
{ '1=Yes.2=No'															, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ 'INCLUI'																, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '19'																	, .T. }, ; //X3_ORDEM
{ 'G5V_DTALT'															, .T. }, ; //X3_CAMPO
{ 'D'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Dt. Alter.'															, .T. }, ; //X3_TITULO
{ 'Fch.Modif.'															, .T. }, ; //X3_TITSPA
{ 'Change Dt'															, .T. }, ; //X3_TITENG
{ 'Data / Hora  da Alteração'											, .T. }, ; //X3_DESCRIC
{ 'Fecha / Hora modificación'											, .T. }, ; //X3_DESCSPA
{ 'Change Time/Date'													, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '20'																	, .T. }, ; //X3_ORDEM
{ 'G5V_USERAL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 25																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'User Altera'															, .T. }, ; //X3_TITULO
{ 'Usua.Modif.'															, .T. }, ; //X3_TITSPA
{ 'Editing User'														, .T. }, ; //X3_TITENG
{ 'Usuáio da Alteração'													, .T. }, ; //X3_DESCRIC
{ 'Usuario de modificación'												, .T. }, ; //X3_DESCSPA
{ 'Editing User'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '21'																	, .T. }, ; //X3_ORDEM
{ 'G5V_ESTREE'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Est. Reemb.'															, .T. }, ; //X3_TITULO
{ 'Ext. Reemb.'															, .T. }, ; //X3_TITSPA
{ 'Reimb Rev'															, .T. }, ; //X3_TITENG
{ 'Estorno no Reembolso ?'												, .T. }, ; //X3_DESCRIC
{ '¿Extorno en reembolso?'												, .T. }, ; //X3_DESCSPA
{ 'Reimburse Reversal?'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("12")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"2"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(198) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
{ '1=Sí;2=No'															, .T. }, ; //X3_CBOXSPA
{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '22'																	, .T. }, ; //X3_ORDEM
{ 'G5V_BASAPU'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Base Apur.'															, .T. }, ; //X3_TITULO
{ 'Base Cálc.'															, .T. }, ; //X3_TITSPA
{ 'Calc Base'															, .T. }, ; //X3_TITENG
{ 'Base Apuração'														, .T. }, ; //X3_DESCRIC
{ 'Base cálculo'														, .T. }, ; //X3_DESCSPA
{ 'Calculation Basis'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("12345")'													, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"1"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Volume;2=Quantidade;3=Custo;4=O.S.;5=R.V.'							, .T. }, ; //X3_CBOX
{ '1=Volumen;2=Cantidad;3=Costo;4=O.S.;5=R.V.'							, .T. }, ; //X3_CBOXSPA
{ '1=Volume;2=Quantity;3=Cost;4=S.O.;5=R.V.'							, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ 'INCLUI'																, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '23'																	, .T. }, ; //X3_ORDEM
{ 'G5V_TPVAL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Tipo Valor'															, .T. }, ; //X3_TITULO
{ 'Tipo valor'															, .T. }, ; //X3_TITSPA
{ 'Value Type'															, .T. }, ; //X3_TITENG
{ 'Tipo de Valor'														, .T. }, ; //X3_DESCRIC
{ 'Tipo de valor'														, .T. }, ; //X3_DESCSPA
{ 'Value Type'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("12")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"1"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Porcentagem;2=Valor Fixo'											, .T. }, ; //X3_CBOX
{ '1=Porcentaje;2=Valor fijo'											, .T. }, ; //X3_CBOXSPA
{ '1=Percentage;2=Fixed Value'											, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '24'																	, .T. }, ; //X3_ORDEM
{ 'G5V_ACOORI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 6																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Acord. Orig.'														, .T. }, ; //X3_TITULO
{ 'Acue. Orig'															, .T. }, ; //X3_TITSPA
{ 'Origin Agree'														, .T. }, ; //X3_TITENG
{ 'Acordo Origem'														, .T. }, ; //X3_DESCRIC
{ 'Acuerdo origen'														, .T. }, ; //X3_DESCSPA
{ 'Origin Agreement'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("G4W",M->G5V_ACOORI)'										, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G4WAC2'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ 'INCLUI'																, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G5V'																	, .T. }, ; //X3_ARQUIVO
{ '25'																	, .T. }, ; //X3_ORDEM
{ 'G5V_NIVEL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 2																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Nivel'																, .T. }, ; //X3_TITULO
{ 'Nivel'																, .T. }, ; //X3_TITSPA
{ 'Level'																, .T. }, ; //X3_TITENG
{ 'Nivel'																, .T. }, ; //X3_DESCRIC
{ 'Nivel'																, .T. }, ; //X3_DESCSPA
{ 'Level'																, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(246) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ ''																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '00=Nivel 0;01=Nivel 1;02=Nivel 2;03=Nivel 3;04=Nivel 4;05=Nivel 5;06=Nivel 6;07=Nivel 7;08=Nivel 8;09=Nivel 9', .T. }, ; //X3_CBOX
{ '00=Nivel 0;01=Nivel 1;02=Nivel 2;03=Nivel 3;04=Nivel 4;05=Nivel 5;06=Nivel 6;07=Nivel 7;08=Nivel 8;09=Nivel 9', .T. }, ; //X3_CBOXSPA
{ '00=Level 0;01=Level 1;02=Level 2;03=Level 3;04=Level 4;05=Level 5;06=Level 6;07=Level 7;08=Level 8;09=Level 9', .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G64
//
aAdd( aSX3, { ;
{ 'G64'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G64_DESCR'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 100																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Descrição'															, .T. }, ; //X3_TITULO
{ 'Descripción'															, .T. }, ; //X3_TITSPA
{ 'Description'															, .T. }, ; //X3_TITENG
{ 'Descrição'															, .T. }, ; //X3_DESCRIC
{ 'Descripción'															, .T. }, ; //X3_DESCSPA
{ 'Description'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(151) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G6A
//
aAdd( aSX3, { ;
{ 'G6A'																	, .T. }, ; //X3_ARQUIVO
{ '06'																	, .T. }, ; //X3_ORDEM
{ 'G6A_DSCPRD'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 60																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Descr. Prod.'														, .T. }, ; //X3_TITULO
{ 'Descr. Prod.'														, .T. }, ; //X3_TITSPA
{ 'Prod.Descrip'														, .T. }, ; //X3_TITENG
{ 'Descrição do Produto'												, .T. }, ; //X3_DESCRIC
{ 'Descripción del producto'											, .T. }, ; //X3_DESCSPA
{ 'Product Description'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ 'IIF(!INCLUI, Posicione("SB1",1,xFilial("SB1")+FwFldGet("G6A_CODPRD"),"B1_DESC"),"")', .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'V'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ 'Posicione("SB1",1,xFilial("SB1")+G6A->G6A_CODPRD,"B1_DESC")'			, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ '001'																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G6D
//
aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '01'																	, .T. }, ; //X3_ORDEM
{ 'G6D_FILIAL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Filial'																, .T. }, ; //X3_TITULO
{ 'Sucursal'															, .T. }, ; //X3_TITSPA
{ 'Branch'																, .T. }, ; //X3_TITENG
{ 'Filial do Sistema'													, .T. }, ; //X3_DESCRIC
{ 'Sucursal del sistema'												, .T. }, ; //X3_DESCSPA
{ 'System Branch'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(152)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ ''																	, .T. }, ; //X3_BROWSE
{ ''																	, .T. }, ; //X3_VISUAL
{ ''																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '033'																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '02'																	, .T. }, ; //X3_ORDEM
{ 'G6D_CODACO'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 6																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Código'																, .T. }, ; //X3_TITULO
{ 'Código'																, .T. }, ; //X3_TITSPA
{ 'Code'																, .T. }, ; //X3_TITENG
{ 'Codigo do Acordo Metas'												, .T. }, ; //X3_DESCRIC
{ 'Código Acuerdo Metas'												, .T. }, ; //X3_DESCSPA
{ 'Goal Agreement Code'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'NaoVazio() .AND. ExistChav("G6D")'									, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(184)					, .T. }, ; //X3_USADO
{ 'GETSXENUM("G6D","G6D_CODACO")'										, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(151) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '03'																	, .T. }, ; //X3_ORDEM
{ 'G6D_CODREV'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 2																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód. Revisão'														, .T. }, ; //X3_TITULO
{ 'Cód. Revisió'														, .T. }, ; //X3_TITSPA
{ 'Review Code'															, .T. }, ; //X3_TITENG
{ 'Codigo da Revisao'													, .T. }, ; //X3_DESCRIC
{ 'Codigo de la revisión'												, .T. }, ; //X3_DESCSPA
{ 'Review Code'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(184)					, .T. }, ; //X3_USADO
{ '"00"'																, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'G6D_DESCRI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Descrição'															, .T. }, ; //X3_TITULO
{ 'Descripción'															, .T. }, ; //X3_TITSPA
{ 'Description'															, .T. }, ; //X3_TITENG
{ 'Descricao do Acordo Meta'											, .T. }, ; //X3_DESCRIC
{ 'Descripción Acuerdo Meta'											, .T. }, ; //X3_DESCSPA
{ 'Goal Aggreement Descripti'											, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(151) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G6D_CODFOR'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 9																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Fornecedor'															, .T. }, ; //X3_TITULO
{ 'Proveedor'															, .T. }, ; //X3_TITSPA
{ 'Supplier'															, .T. }, ; //X3_TITENG
{ 'Codigo do Fornecedor'												, .T. }, ; //X3_DESCRIC
{ 'Código del proveedor'												, .T. }, ; //X3_DESCSPA
{ 'Supplier Code'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Vazio().Or.(ExistCpo("SA2",FwFldGet("G6D_CODFOR")).And.TA037FornVld())'	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'SA2A'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ 'INCLUI .And. ! IsInCallStack( "TA037REV" )'							, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '001'																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '06'																	, .T. }, ; //X3_ORDEM
{ 'G6D_LOJA'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 4																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Loja Fornec.'														, .T. }, ; //X3_TITULO
{ 'Tda Proveed.'														, .T. }, ; //X3_TITSPA
{ 'Supplier Sto'														, .T. }, ; //X3_TITENG
{ 'Loja Fornecedor'														, .T. }, ; //X3_DESCRIC
{ 'Tienda del proveedor'												, .T. }, ; //X3_DESCSPA
{ 'Supplier Store'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Vazio().Or.(ExistCpo("SA2",FwFldGet("G6D_CODFOR")+FwFldGet("G6D_LOJA")).And.TA037FornVld())', .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ 'INCLUI .And. ! IsInCallStack( "TA037REV" )'							, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '002'																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '07'																	, .T. }, ; //X3_ORDEM
{ 'G6D_NOME'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 100																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Nome Fornec.'														, .T. }, ; //X3_TITULO
{ 'Nomb Proveed'														, .T. }, ; //X3_TITSPA
{ 'Supplier Nam'														, .T. }, ; //X3_TITENG
{ 'Nome Fornecedor'														, .T. }, ; //X3_DESCRIC
{ 'Nombre del proveedor'												, .T. }, ; //X3_DESCSPA
{ 'Supplier Name'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ 'IF(!INCLUI,POSICIONE("SA2",1,XFILIAL("SA2")+G6D->G6D_CODFOR+G6D->G6D_LOJA,"A2_NOME"),"")', .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(214) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'V'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ 'POSICIONE("SA2",1,XFILIAL("SA2")+G6D->G6D_CODFOR+G6D->G6D_LOJA,"A2_NOME")', .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G6D_BASEAP'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Base Apur.'															, .T. }, ; //X3_TITULO
{ 'Base Cálc.'															, .T. }, ; //X3_TITSPA
{ 'Calc Base'															, .T. }, ; //X3_TITENG
{ 'Base Apuracao'														, .T. }, ; //X3_DESCRIC
{ 'Base cálculo'														, .T. }, ; //X3_DESCSPA
{ 'Calculation Base'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("1234")'													, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"1"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Volume Vendas;2=Transação;3=Market Share;4=Crescimento'			, .T. }, ; //X3_CBOX
{ '1=Volumen Ventas;2=Transacción;3=Market Share;4=Crescimiento'		, .T. }, ; //X3_CBOXSPA
{ '1=Sales Volume;2=Transaction;3=Market Share;4=Growth'				, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'G6D_TPVLR'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Tp. Valor'															, .T. }, ; //X3_TITULO
{ 'Tp. Valor'															, .T. }, ; //X3_TITSPA
{ 'Value Tp'															, .T. }, ; //X3_TITENG
{ 'Tipo de Valor'														, .T. }, ; //X3_DESCRIC
{ 'Tipo de valor'														, .T. }, ; //X3_DESCSPA
{ 'Value Type'															, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("12")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"1"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Porcentagem;2=Valor Fixo'											, .T. }, ; //X3_CBOX
{ '1=Porcentaje;2=Valor fijo'											, .T. }, ; //X3_CBOXSPA
{ '1=Percentage;2=Fixed Value'											, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '10'																	, .T. }, ; //X3_ORDEM
{ 'G6D_REEMBO'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Abate Reemb.'														, .T. }, ; //X3_TITULO
{ 'Desc Reemb.'															, .T. }, ; //X3_TITSPA
{ 'Reimb Ded'															, .T. }, ; //X3_TITENG
{ 'Abate Reembolso'														, .T. }, ; //X3_DESCRIC
{ 'Descuenta reembolso'													, .T. }, ; //X3_DESCSPA
{ 'Reimburse Deduction'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("12")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"1"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '11'																	, .T. }, ; //X3_ORDEM
{ 'G6D_VIGINI'															, .T. }, ; //X3_CAMPO
{ 'D'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Vigência De'															, .T. }, ; //X3_TITULO
{ 'De Vigencia'															, .T. }, ; //X3_TITSPA
{ 'ValidityFrom'														, .T. }, ; //X3_TITENG
{ 'Vigência De'															, .T. }, ; //X3_DESCRIC
{ 'De Vigencia'															, .T. }, ; //X3_DESCSPA
{ 'Validity From'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ "FwFldGet('G6D_VIGINI')==cToD('').Or.FwFldGet('G6D_VIGFIM')==cToD('').Or.FwFldGet('G6D_VIGINI')<=FwFldGet('G6D_VIGFIM')", .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ ''																	, .T. }, ; //X3_BROWSE
{ ''																	, .T. }, ; //X3_VISUAL
{ ''																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '12'																	, .T. }, ; //X3_ORDEM
{ 'G6D_VIGFIM'															, .T. }, ; //X3_CAMPO
{ 'D'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Vigência Até'														, .T. }, ; //X3_TITULO
{ 'A Vigencia'															, .T. }, ; //X3_TITSPA
{ 'Validity To'															, .T. }, ; //X3_TITENG
{ 'Vigência Ate'														, .T. }, ; //X3_DESCRIC
{ 'A Vigencia'															, .T. }, ; //X3_DESCSPA
{ 'Validity To'															, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ "FwFldGet('G6D_VIGINI')==cToD('').Or.FwFldGet('G6D_VIGFIM')==cToD('').Or.FwFldGet('G6D_VIGINI')<=FwFldGet('G6D_VIGFIM')", .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G6D_FAIXA'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 2																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Faixa'																, .T. }, ; //X3_TITULO
{ 'Rango'																, .T. }, ; //X3_TITSPA
{ 'Range'																, .T. }, ; //X3_TITENG
{ 'Faixa da Meta'														, .T. }, ; //X3_DESCRIC
{ 'Rango de la meta'													, .T. }, ; //X3_DESCSPA
{ 'Goal Range'															, .T. }, ; //X3_DESCENG
{ '99'																	, .T. }, ; //X3_PICTURE
{ 'Vazio().Or.TA037VldFx()'												, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"01"'																, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(135) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '14'																	, .T. }, ; //X3_ORDEM
{ 'G6D_PERIOD'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Período'																, .T. }, ; //X3_TITULO
{ 'Período'																, .T. }, ; //X3_TITSPA
{ 'Period'																, .T. }, ; //X3_TITENG
{ 'Periodo base apuracao'												, .T. }, ; //X3_DESCRIC
{ 'Peródo base cálculo'													, .T. }, ; //X3_DESCSPA
{ 'Calculation base period'												, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("1234")'													, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Mensal;2=Trimestral;3=Semestral;4=Anual'							, .T. }, ; //X3_CBOX
{ '1=Mensual;2=Trimestral;3=Semestral;4=Anual'							, .T. }, ; //X3_CBOXSPA
{ '1=Monthly;2=Quarterly;3=Semestral;4=Annual'							, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ 'M->G6D_BASEAP == "4"'												, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '15'																	, .T. }, ; //X3_ORDEM
{ 'G6D_AEREO'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Forn. Aéreo'															, .T. }, ; //X3_TITULO
{ 'Prov. Aéreo'															, .T. }, ; //X3_TITSPA
{ 'Air Supplier'														, .T. }, ; //X3_TITENG
{ 'Fornecedor Aéreo'													, .T. }, ; //X3_DESCRIC
{ 'Proveedor aéreo'														, .T. }, ; //X3_DESCSPA
{ 'Air Supplier'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence("12")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"2"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '16'																	, .T. }, ; //X3_ORDEM
{ 'G6D_OBSERV'															, .T. }, ; //X3_CAMPO
{ 'M'																	, .T. }, ; //X3_TIPO
{ 10																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Observação'															, .T. }, ; //X3_TITULO
{ 'Observación'															, .T. }, ; //X3_TITSPA
{ 'Note'																, .T. }, ; //X3_TITENG
{ 'Observação'															, .T. }, ; //X3_DESCRIC
{ 'Observación'															, .T. }, ; //X3_DESCSPA
{ 'Note'																, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '17'																	, .T. }, ; //X3_ORDEM
{ 'G6D_MSBLQL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Bloqueado?'															, .T. }, ; //X3_TITULO
{ '¿Bloqueado?'															, .T. }, ; //X3_TITSPA
{ 'Blocked?'															, .T. }, ; //X3_TITENG
{ 'Registro bloqueado'													, .T. }, ; //X3_DESCRIC
{ 'Registro bloqueado'													, .T. }, ; //X3_DESCSPA
{ 'Blocked Record'														, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"2"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '18'																	, .T. }, ; //X3_ORDEM
{ 'G6D_DTALT'															, .T. }, ; //X3_CAMPO
{ 'D'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Dt. Alter.'															, .T. }, ; //X3_TITULO
{ 'Fch. Modif.'															, .T. }, ; //X3_TITSPA
{ 'Change Dt'															, .T. }, ; //X3_TITENG
{ 'Data da alteracao'													, .T. }, ; //X3_DESCRIC
{ 'Fecha de la modificación'											, .T. }, ; //X3_DESCSPA
{ 'Change Date'															, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ 'Date()'																, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '19'																	, .T. }, ; //X3_ORDEM
{ 'G6D_STATUS'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Bloqueado'															, .T. }, ; //X3_TITULO
{ 'Bloqueado'															, .T. }, ; //X3_TITSPA
{ 'Blocked'																, .T. }, ; //X3_TITENG
{ 'Bloqueado para alteração.'											, .T. }, ; //X3_DESCRIC
{ 'Bloqueado p modificación'											, .T. }, ; //X3_DESCSPA
{ 'Blocked for change.'													, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
{ '"2"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ ''																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G6D'																	, .T. }, ; //X3_ARQUIVO
{ '20'																	, .T. }, ; //X3_ORDEM
{ 'G6D_CLASS'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 3																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Classif.'															, .T. }, ; //X3_TITULO
{ 'Clasif.'																, .T. }, ; //X3_TITSPA
{ 'Classif.'															, .T. }, ; //X3_TITENG
{ 'Classificação tipo acordo'											, .T. }, ; //X3_DESCRIC
{ 'Clasificación tpo acuerdo'											, .T. }, ; //X3_DESCSPA
{ 'Agreement Type Classifica'											, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"M0" + FWFLDGET( "G6D_BASEAP" )'										, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'N'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G6F
//
aAdd( aSX3, { ;
	{ 'G6F'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'G6F_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Fornec.'														, .T. }, ; //X3_TITULO
	{ 'Nomb Prov.'															, .T. }, ; //X3_TITSPA
	{ 'Supp Name'															, .T. }, ; //X3_TITENG
	{ 'Nome Fornecedor'														, .T. }, ; //X3_DESCRIC
	{ 'Nombre de proveedor'													, .T. }, ; //X3_DESCSPA
	{ 'Supplier Name'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IF(!INCLUI,POSICIONE("SA2",1,XFILIAL("SA2")+G6F->G6F_CODFOR+G6F->G6F_LOJA,"A2_NOME"),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'POSICIONE("SA2",1,XFILIAL("SA2")+G6F->G6F_CODFOR+G6F->G6F_LOJA,"A2_NOME")', .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G6I
//
aAdd( aSX3, { ;
	{ 'G6I'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'G6I_LOCALI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Localizador'															, .T. }, ; //X3_TITULO
	{ 'Localizador'															, .T. }, ; //X3_TITSPA
	{ 'Locator'																, .T. }, ; //X3_TITENG
	{ 'Localizador'															, .T. }, ; //X3_DESCRIC
	{ 'Localizador'															, .T. }, ; //X3_DESCSPA
	{ 'Locator'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(148) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G6I'																	, .T. }, ; //X3_ARQUIVO
	{ '27'																	, .T. }, ; //X3_ORDEM
	{ 'G6I_SITUAC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Situacao'															, .T. }, ; //X3_TITULO
	{ 'Situación'															, .T. }, ; //X3_TITSPA
	{ 'Status'																, .T. }, ; //X3_TITENG
	{ 'Situacao'															, .T. }, ; //X3_DESCRIC
	{ 'Situación'															, .T. }, ; //X3_DESCSPA
	{ 'Status'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("12345")'													, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Nao Associado;2=Associado;3=Aprovado;4=Pend. Aval. Automatica;5=Pend. Aval. Natureza', .T. }, ; //X3_CBOX
	{ '1=Nao Associado;2=Associado;3=Aprovado;4=Pend. Aval. Automatica;5=Pend. Aval. Natureza', .T. }, ; //X3_CBOXSPA
	{ '1=Nao Associado;2=Associado;3=Aprovado;4=Pend. Aval. Automatica;5=Pend. Aval. Natureza', .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G6I'																	, .T. }, ; //X3_ARQUIVO
	{ '32'																	, .T. }, ; //X3_ORDEM
	{ 'G6I_TPFOP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Pagmto'															, .T. }, ; //X3_TITULO
	{ 'Tipo de pago'														, .T. }, ; //X3_TITSPA
	{ 'Pay Type'															, .T. }, ; //X3_TITENG
	{ 'Tipo de Forma de Pagament'											, .T. }, ; //X3_DESCRIC
	{ 'Tipo de forma de pago'												, .T. }, ; //X3_DESCSPA
	{ 'Payment Term Type'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'vazio() .or. pertence("012")'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"0"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(215) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '0=Desconhecida;1=Intermediação;2=Cartão'								, .T. }, ; //X3_CBOX
	{ '0=Desconocida;1=Intermediación;2=Tarjeta'							, .T. }, ; //X3_CBOXSPA
	{ '0=Unknown;1=Intermediation;2=Card'									, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G6H
//
aAdd( aSX3, { ;
	{ 'G6H'																	, .T. }, ; //X3_ARQUIVO
	{ '20'																	, .T. }, ; //X3_ORDEM
	{ 'G6H_SERIE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Série'																, .T. }, ; //X3_TITULO
	{ 'Serie'																, .T. }, ; //X3_TITSPA
	{ 'Series'																, .T. }, ; //X3_TITENG
	{ 'Série da Nota'														, .T. }, ; //X3_DESCRIC
	{ 'Serie de la factura'													, .T. }, ; //X3_DESCSPA
	{ 'Invoice Series'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"FAP"'																, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G6L
//
aAdd( aSX3, { ;
	{ 'G6L'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'G6L_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome'																, .T. }, ; //X3_TITULO
	{ 'Nombre'																, .T. }, ; //X3_TITSPA
	{ 'Name'																, .T. }, ; //X3_TITENG
	{ 'Nome do cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Nombre del cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Customer Name'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'POSICIONE("SA1", 1, XFILIAL("SA1")+G6L->G6L_CLIENT+G6L->G6L_LOJA, "A1_NOME")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'POSICIONE("SA1", 1, XFILIAL("SA1")+G6L->G6L_CLIENT+G6L->G6L_LOJA, "A1_NOME")', .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'G6L'																	, .T. }, ; //X3_ARQUIVO
	{ '17'																	, .T. }, ; //X3_ORDEM
	{ 'G6L_NOMFOR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Fornec.'														, .T. }, ; //X3_TITULO
	{ 'Nomb Proveed'														, .T. }, ; //X3_TITSPA
	{ 'Supp Name'															, .T. }, ; //X3_TITENG
	{ 'Nome do Fornecedor'													, .T. }, ; //X3_DESCRIC
	{ 'Nombre del proveedor'												, .T. }, ; //X3_DESCSPA
	{ 'Supplier Name'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'Iif(!Inclui,POSICIONE("SA2", 1, XFILIAL("SA2")+G6L->G6L_FORNEC+G6L->G6L_LJFORN, "A2_NOME"), "" )', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'POSICIONE("SA2", 1, XFILIAL("SA2")+G6L->G6L_FORNEC+G6L->G6L_LJFORN, "A2_NOME")', .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G84
//
aAdd( aSX3, { ;
	{ 'G84'																	, .T. }, ; //X3_ARQUIVO
	{ '18'																	, .T. }, ; //X3_ORDEM
	{ 'G84_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome'																, .T. }, ; //X3_TITULO
	{ 'Nombre'																, .T. }, ; //X3_TITSPA
	{ 'Name'																, .T. }, ; //X3_TITENG
	{ 'Nome do Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Nombre del cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Customer Name'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI,POSICIONE("SA1",1,XFILIAL("SA1")+G84->G84_CLIENT+G84->G84_LOJA,"A1_NOME"),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ "POSICIONE('SA1', 1, XFILIAL('SA1')+G84->G84_CLIENT+G84->G84_LOJA,'A1_NOME')", .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G85
//
aAdd( aSX3, { ;
	{ 'G85'																	, .T. }, ; //X3_ARQUIVO
	{ '31'																	, .T. }, ; //X3_ORDEM
	{ 'G85_ITDESC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 60																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Desc. Item'															, .T. }, ; //X3_TITULO
	{ 'Desc. Ítem'															, .T. }, ; //X3_TITSPA
	{ 'Item Desc'															, .T. }, ; //X3_TITENG
	{ 'Descrição do Item'													, .T. }, ; //X3_DESCRIC
	{ 'Descripción del ítem'												, .T. }, ; //X3_DESCSPA
	{ 'Item Description'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI,TA45ITENT(),"")'											, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'TA45ITENT()'															, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G8C
//
aAdd( aSX3, { ;
	{ 'G8C'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'G8C_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Razão Social'														, .T. }, ; //X3_TITULO
	{ 'Razón social'														, .T. }, ; //X3_TITSPA
	{ 'Comp Name'															, .T. }, ; //X3_TITENG
	{ 'Razão Social'														, .T. }, ; //X3_DESCRIC
	{ 'Razón social'														, .T. }, ; //X3_DESCSPA
	{ 'Company Name'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI,POSICIONE("SA2",1,XFILIAL("SA2")+G8C->G8C_FORNEC+G8C->G8C_LOJA,"A2_NOME"),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'POSICIONE("SA2",1,XFILIAL("SA2")+G8C->G8C_FORNEC+G8C->G8C_LOJA,"A2_NOME")', .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G8C'																	, .T. }, ; //X3_ARQUIVO
{ '07'																	, .T. }, ; //X3_ORDEM
{ 'G8C_FATURA'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 9																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Fatura'																, .T. }, ; //X3_TITULO
{ 'Factura'																, .T. }, ; //X3_TITSPA
{ 'Invoice'																, .T. }, ; //X3_TITENG
{ 'Fatura do Fornecedor'												, .T. }, ; //X3_DESCRIC
{ 'Factura del proveedor'												, .T. }, ; //X3_DESCSPA
{ 'Supplier Invoice'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'TA042VlFat()'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(197) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ "FwFldGet('G8C_EXTADT') <> '1'"										, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '018'																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G8C'																	, .T. }, ; //X3_ARQUIVO
{ '10'																	, .T. }, ; //X3_ORDEM
{ 'G8C_VLRFAT'															, .T. }, ; //X3_CAMPO
{ 'N'																	, .T. }, ; //X3_TIPO
{ 16																	, .T. }, ; //X3_TAMANHO
{ 2																		, .T. }, ; //X3_DECIMAL
{ 'Valor'																, .T. }, ; //X3_TITULO
{ 'Valor'																, .T. }, ; //X3_TITSPA
{ 'Valor'																, .T. }, ; //X3_TITENG
{ 'Valor'																, .T. }, ; //X3_DESCRIC
{ 'Valor'																, .T. }, ; //X3_DESCSPA
{ 'Valor'																, .T. }, ; //X3_DESCENG
{ '@E 9,999,999,999,999.99'												, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(197) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ "FwFldGet('G8C_EXTADT') <> '1'"										, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G8C'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'G8C_SERIE'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 3																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Série/Prefix'														, .T. }, ; //X3_TITULO
{ 'Serie/Prefij'														, .T. }, ; //X3_TITSPA
{ 'Series/Pref'															, .T. }, ; //X3_TITENG
{ 'Série/Prefixo'														, .T. }, ; //X3_DESCRIC
{ 'Serie/Prefijo'														, .T. }, ; //X3_DESCSPA
{ 'Series/Prefix'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ 'IIF(ISINCALLSTACK("TURA042A"),"FF","REE")'                           , .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(196) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '095'																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '2'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G8C'																	, .T. }, ; //X3_ARQUIVO
{ '22'																	, .T. }, ; //X3_ORDEM
{ 'G8C_XEDOC'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 20																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'ID'																	, .T. }, ; //X3_TITULO
{ 'ID'																	, .T. }, ; //X3_TITSPA
{ 'ID'																	, .T. }, ; //X3_TITENG
{ 'ID'																	, .T. }, ; //X3_DESCRIC
{ 'ID'																	, .T. }, ; //X3_DESCSPA
{ 'ID'																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G8G
//
aAdd( aSX3, { ;
	{ 'G8G'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'G8G_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome'																, .T. }, ; //X3_TITULO
	{ 'Nombre'																, .T. }, ; //X3_TITSPA
	{ 'Name'																, .T. }, ; //X3_TITENG
	{ 'Nome do Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Nombre de cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Customer Name'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI,POSICIONE("SA1",1,XFILIAL("SA1")+G8G->(G8G_CLIENT+G8G_LOJA),"A1_NOME"),SPACE(TamSX3("G8G_NOME")[1]))', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'Posicione("SA1",1,xFilial("SA1")+G8G->(G8G_CLIENT+G8G_LOJA),"A1_NOME")'	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G8L
//
aAdd( aSX3, { ;
{ 'G8L'																	, .T. }, ; //X3_ARQUIVO
{ '07'																	, .T. }, ; //X3_ORDEM
{ 'G8L_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G8L'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'G8L_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G8M
//
aAdd( aSX3, { ;
{ 'G8M'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G8M_CIDINI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód.Cid.Emb.'														, .T. }, ; //X3_TITULO
{ 'Cód.Ciu.Emb.'														, .T. }, ; //X3_TITSPA
{ 'Ship City Cd'														, .T. }, ; //X3_TITENG
{ 'Código Cidade Embarque'												, .T. }, ; //X3_DESCRIC
{ 'Código Ciudad Embarque'												, .T. }, ; //X3_DESCSPA
{ 'Shipment City Code'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Vazio() .Or. ExistCpo("G5S",FWFldGet("G8M_CIDINI"))'					, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5S'																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G8M'																	, .T. }, ; //X3_ARQUIVO
{ '07'																	, .T. }, ; //X3_ORDEM
{ 'G8M_CIDFIM'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód.Cid.Des.'														, .T. }, ; //X3_TITULO
{ 'Cód.Ciu.Des.'														, .T. }, ; //X3_TITSPA
{ 'Land City Cd'														, .T. }, ; //X3_TITENG
{ 'Código Cidade Desembarque'											, .T. }, ; //X3_DESCRIC
{ 'Código Ciudad Desembarque'											, .T. }, ; //X3_DESCSPA
{ 'Landing City Code'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Vazio() .Or. ExistCpo("G5S",FWFldGet("G8M_CIDFIM"))'					, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5S'																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G8N
//
aAdd( aSX3, { ;
{ 'G8N'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'G8N_CIDTRC'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód.Cidade'															, .T. }, ; //X3_TITULO
{ 'Cód.Ciudad'															, .T. }, ; //X3_TITSPA
{ 'City Code'															, .T. }, ; //X3_TITENG
{ 'Código Cidade do Trecho'												, .T. }, ; //X3_DESCRIC
{ 'Código ciudad del trrecho'											, .T. }, ; //X3_DESCSPA
{ 'Part City Code'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Vazio() .Or. ExistCpo("G5S",FWFldGet("G8N_CIDTRC"))'					, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'G5S'																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G8O
//
aAdd( aSX3, { ;
{ 'G8O'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G8O_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G8O'																	, .T. }, ; //X3_ARQUIVO
{ '06'																	, .T. }, ; //X3_ORDEM
{ 'G8O_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G8P
//
aAdd( aSX3, { ;
{ 'G8P'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G8P_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G8P'																	, .T. }, ; //X3_ARQUIVO
{ '06'																	, .T. }, ; //X3_ORDEM
{ 'G8P_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G8Q
//
aAdd( aSX3, { ;
{ 'G8Q'																	, .T. }, ; //X3_ARQUIVO
{ '05'																	, .T. }, ; //X3_ORDEM
{ 'G8Q_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'G8Q'																	, .T. }, ; //X3_ARQUIVO
{ '06'																	, .T. }, ; //X3_ORDEM
{ 'G8Q_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela G8X
//
aAdd( aSX3, { ;
	{ 'G8X'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'G8X_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome'																, .T. }, ; //X3_TITULO
	{ 'Nombre'																, .T. }, ; //X3_TITSPA
	{ 'Name'																, .T. }, ; //X3_TITENG
	{ 'Nome do Fornecedor'													, .T. }, ; //X3_DESCRIC
	{ 'Nombre del proveedor'												, .T. }, ; //X3_DESCSPA
	{ 'Supplier Name'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI,POSICIONE("SA2",1,XFILIAL("SA2")+G8X->G8X_FORNEC+G8X->G8X_LOJA,"A2_NOME"),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'POSICIONE("SA2",1,XFILIAL("SA2")+G8X->G8X_FORNEC+G8X->G8X_LOJA,"A2_NOME")', .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G90
//
aAdd( aSX3, { ;
{ 'G90'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'G90_NCARD'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 32																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Núm. Cartão'															, .T. }, ; //X3_TITULO
{ 'Nº Tarjeta'															, .T. }, ; //X3_TITSPA
{ 'Card no.'															, .T. }, ; //X3_TITENG
{ 'Número Cartão Turismo'												, .T. }, ; //X3_DESCRIC
{ 'Nº Tarjeta turismo'													, .T. }, ; //X3_DESCSPA
{ 'Tourism Card Number'													, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G9I
//
aAdd( aSX3, { ;
	{ 'G9I'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'G9I_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cliente'																, .T. }, ; //X3_TITULO
	{ 'Cliente'																, .T. }, ; //X3_TITSPA
	{ 'Customer'															, .T. }, ; //X3_TITENG
	{ 'Nome do Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Nombre del cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Customer Name'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+G9I->G9I_CLIENT+G9I->G9I_LOJA,"SA1->A1_NOME") ,"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'Posicione("SA1",1,xFilial("SA1")+G9I->G9I_CLIENT+G9I->G9I_LOJA,"SA1->A1_NOME")', .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela GA9
//
aAdd( aSX3, { ;
	{ 'GA9'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'GA9_NOME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Razao Social'														, .T. }, ; //X3_TITULO
	{ 'Razon Social'														, .T. }, ; //X3_TITSPA
	{ 'Razao Social'														, .T. }, ; //X3_TITENG
	{ 'Razao Social'														, .T. }, ; //X3_DESCRIC
	{ 'Razon Social'														, .T. }, ; //X3_DESCSPA
	{ 'Razao Social'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'NaoVazio()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(147) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

//
// Campos Tabela GC7
//
aAdd( aSX3, { ;
{ 'GC7'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'GC7_XLOGO'															, .T. }, ; //X3_CAMPO
{ 'N'																	, .T. }, ; //X3_TIPO
{ 2																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Coordenada X'														, .T. }, ; //X3_TITULO
{ 'Coordenada X'														, .T. }, ; //X3_TITSPA
{ 'X coordinate'														, .T. }, ; //X3_TITENG
{ 'Eixo x'																, .T. }, ; //X3_DESCRIC
{ 'Eje x'																, .T. }, ; //X3_DESCSPA
{ 'X axis'																, .T. }, ; //X3_DESCENG
{ '99'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela GI2
//
aAdd( aSX3, { ;
{ 'GI2'																	, .T. }, ; //X3_ARQUIVO
{ '20'																	, .T. }, ; //X3_ORDEM
{ 'GI2_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log DW'																, .T. }, ; //X3_TITULO
{ 'Log DW'																, .T. }, ; //X3_TITSPA
{ 'Log DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'GI2'																	, .T. }, ; //X3_ARQUIVO
{ '21'																	, .T. }, ; //X3_ORDEM
{ 'GI2_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela GI3
//
aAdd( aSX3, { ;
{ 'GI3'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'GI3_XDWLOG'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 50																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Log  DW'																, .T. }, ; //X3_TITULO
{ 'Log  DW'																, .T. }, ; //X3_TITSPA
{ 'Log  DW'																, .T. }, ; //X3_TITENG
{ ''																	, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'GI3'																	, .T. }, ; //X3_ARQUIVO
{ '14'																	, .T. }, ; //X3_ORDEM
{ 'GI3_XENVBI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Enviado p BI'														, .T. }, ; //X3_TITULO
{ 'BI publicado'														, .T. }, ; //X3_TITSPA
{ 'Posted BI'															, .T. }, ; //X3_TITENG
{ 'Enviado para Stg DW'													, .T. }, ; //X3_DESCRIC
{ ''																	, .T. }, ; //X3_DESCSPA
{ ''																	, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'V'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela SA1
// 
aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ '08'																	, .T. }, ; //X3_ORDEM
	{ 'A1_NOME'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome'																, .T. }, ; //X3_TITULO
	{ 'Nombre'																, .T. }, ; //X3_TITSPA
	{ 'Name'																, .T. }, ; //X3_TITENG
	{ 'Nome do cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Nombre del cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Client Name'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(147) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'texto()'																, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
{ '04'																	, .T. }, ; //X3_ORDEM
{ 'A1_PESSOA'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Fisica/Jurid'														, .T. }, ; //X3_TITULO
{ 'Fisic/Jurid.'														, .T. }, ; //X3_TITSPA
{ 'Natur./Legal'														, .T. }, ; //X3_TITENG
{ 'Pessoa Fisica/Juridica'												, .T. }, ; //X3_DESCRIC
{ 'Persona Fisica/Juridica'												, .T. }, ; //X3_DESCSPA
{ 'Nat. Person/Legal Entity'											, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Pertence(" FJ")'														, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ '€'																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ 'F=Fisica;J=Juridica'													, .T. }, ; //X3_CBOX
{ 'F=Fisica;J=Juridica'													, .T. }, ; //X3_CBOXSPA
{ 'F=Natural;J=Legal'													, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ 'X3COMBO("A1_PESSOA",RETPESSOA(SA1->A1_CGC))'							, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ '1'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ '07'																	, .T. }, ; //X3_ORDEM
	{ 'A1_NREDUZ'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 50																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'N Fantasia'															, .T. }, ; //X3_TITULO
	{ 'Nom Fantasia'														, .T. }, ; //X3_TITSPA
	{ 'Trade Name'															, .T. }, ; //X3_TITENG
	{ 'Nome Reduzido do cliente'											, .T. }, ; //X3_DESCRIC
	{ 'Nom. Reducido del Cliente'											, .T. }, ; //X3_DESCSPA
	{ 'Customer Short Name'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(147) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ '09'																	, .T. }, ; //X3_ORDEM
	{ 'A1_END'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Endereco'															, .T. }, ; //X3_TITULO
	{ 'Direccion'															, .T. }, ; //X3_TITSPA
	{ 'Address'																, .T. }, ; //X3_TITENG
	{ 'Endereco do cliente'													, .T. }, ; //X3_DESCRIC
	{ 'Direccion do cliente'												, .T. }, ; //X3_DESCSPA
	{ 'Customer´s address'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(147) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

/*aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'A1_COMPLEM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Complemento'															, .T. }, ; //X3_TITULO
	{ 'Complemento'															, .T. }, ; //X3_TITSPA
	{ 'Complement'															, .T. }, ; //X3_TITENG
	{ 'Complemento do endereço'												, .T. }, ; //X3_DESCRIC
	{ 'Complemento de la direcc.'											, .T. }, ; //X3_DESCSPA
	{ 'Address complement'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME
*/
aAdd( aSX3, { ;
{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
{ '13'																	, .T. }, ; //X3_ORDEM
{ 'A1_COD_MUN'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cd.Municipio'														, .T. }, ; //X3_TITULO
{ 'Cd.Municipio'														, .T. }, ; //X3_TITSPA
{ 'City Code'															, .T. }, ; //X3_TITENG
{ 'Código do Municipio'													, .T. }, ; //X3_DESCRIC
{ 'Codigo del Municipio'												, .T. }, ; //X3_DESCSPA
{ 'City Code'															, .T. }, ; //X3_DESCENG
{ '@99999'																, .T. }, ; //X3_PICTURE
{ 'IIF(M->A1_EST<>"EX",ExistCpo("CC2",M->A1_EST+M->A1_COD_MUN),ExistCpo("G5S",M->A1_COD_MUN))', .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'CIDSA1'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ '€'																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ '1'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ '15'																	, .T. }, ; //X3_ORDEM
	{ 'A1_BAIRRO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 50																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Bairro'																, .T. }, ; //X3_TITULO
	{ 'Barrio'																, .T. }, ; //X3_TITSPA
	{ 'District'															, .T. }, ; //X3_TITENG
	{ 'Bairro do cliente'													, .T. }, ; //X3_DESCRIC
	{ 'Barrio del cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Customer District'													, .T. }, ; //X3_DESCENG
	{ '@S15'																, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ '26'																	, .T. }, ; //X3_ORDEM
	{ 'A1_ENDCOB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'End.Cobranca'														, .T. }, ; //X3_TITULO
	{ 'Dir.Cobranza'														, .T. }, ; //X3_TITSPA
	{ 'Collec.Addr.'														, .T. }, ; //X3_TITENG
	{ 'End.de cobr. do cliente'												, .T. }, ; //X3_DESCRIC
	{ 'Dir. de cobr. del cliente'											, .T. }, ; //X3_DESCSPA
	{ 'Custm.Collec.Address'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(255) + Chr(255) + Chr(236) + Chr(128) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(131) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'Vazio().Or.texto()'													, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '2'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
{ 'P8'																	, .T. }, ; //X3_ORDEM
{ 'A1_XCOMTUR'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Com. Turismo'														, .T. }, ; //X3_TITULO
{ 'Com. Turismo'														, .T. }, ; //X3_TITSPA
{ 'Com. Turismo'														, .T. }, ; //X3_TITENG
{ 'Comissao Turismo'													, .T. }, ; //X3_DESCRIC
{ 'Comissao Turismo'													, .T. }, ; //X3_DESCSPA
{ 'Comissao Turismo'													, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ '"N"'																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ 'pertence("S,N")'														, .T. }, ; //X3_VLDUSER
{ 'S=SIM;N=NAO'															, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ 'Q2'																	, .T. }, ; //X3_ORDEM
	{ 'A1_XAGEN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nro Agencia'															, .T. }, ; //X3_TITULO
	{ 'Nro Agencia'															, .T. }, ; //X3_TITSPA
	{ 'Nro Agencia'															, .T. }, ; //X3_TITENG
	{ 'Agencia do banco'													, .T. }, ; //X3_DESCRIC
	{ 'Agencia do banco'													, .T. }, ; //X3_DESCSPA
	{ 'Agencia do banco'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'NaoVazio() .and. A070ALFANUM(M->A1_XAGEN) .AND. ExistChav("SA6",M->A1_BCO1+M->A1_XAGEN+M->A1_XCONTAC)', .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ 'Q3'																	, .T. }, ; //X3_ORDEM
	{ 'A1_XCONTAC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nro Conta'															, .T. }, ; //X3_TITULO
	{ 'Nro Conta'															, .T. }, ; //X3_TITSPA
	{ 'Nro Conta'															, .T. }, ; //X3_TITENG
	{ 'Conta Corrente no Banco'												, .T. }, ; //X3_DESCRIC
	{ 'Conta Corrente no Banco'												, .T. }, ; //X3_DESCSPA
	{ 'Conta Corrente no Banco'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'A070ALFANUM(M->A1_XCONTAC) .AND. ExistChav("SA6",M->A1_BANCO1+M->A1_XAGEN+M->A1_XCONTAC)', .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ 'Q4'																	, .T. }, ; //X3_ORDEM
	{ 'A1_XPBANC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Param Banco'															, .T. }, ; //X3_TITULO
	{ 'Param Banco'															, .T. }, ; //X3_TITSPA
	{ 'Param Banco'															, .T. }, ; //X3_TITENG
	{ 'Parametro Banco'														, .T. }, ; //X3_DESCRIC
	{ 'Parametro Banco'														, .T. }, ; //X3_DESCSPA
	{ 'Parametro Banco'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ 'Q9'																	, .T. }, ; //X3_ORDEM
	{ 'A1_XMULTA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Perc Multa %'														, .T. }, ; //X3_TITULO
	{ 'Perc Multa %'														, .T. }, ; //X3_TITSPA
	{ 'Perc Multa %'														, .T. }, ; //X3_TITENG
	{ 'Percentual de Multa'													, .T. }, ; //X3_DESCRIC
	{ 'Percentual de Multa'													, .T. }, ; //X3_DESCSPA
	{ 'Percentual de Multa'													, .T. }, ; //X3_DESCENG
	{ '@E 9.99'																, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '2'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela SA2
//
aAdd( aSX3, { ;
	{ 'SA2'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'A2_NOME'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Razao Social'														, .T. }, ; //X3_TITULO
	{ 'Razon Social'														, .T. }, ; //X3_TITSPA
	{ 'Company Name'														, .T. }, ; //X3_TITENG
	{ 'Nome ou Razao Social'												, .T. }, ; //X3_DESCRIC
	{ 'Nombre o razon social'												, .T. }, ; //X3_DESCSPA
	{ 'Name or Company Name'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(147) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'texto()'																, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA2'																	, .T. }, ; //X3_ARQUIVO
	{ '07'																	, .T. }, ; //X3_ORDEM
	{ 'A2_NREDUZ'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 50																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'N Fantasia'															, .T. }, ; //X3_TITULO
	{ 'Nom Fantasia'														, .T. }, ; //X3_TITSPA
	{ 'Trade Name'															, .T. }, ; //X3_TITENG
	{ 'Nome de Fantasia'													, .T. }, ; //X3_DESCRIC
	{ 'Nombre Fantasia'														, .T. }, ; //X3_DESCSPA
	{ 'Trade Name'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(147) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'texto()'																, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'SA2'																	, .T. }, ; //X3_ARQUIVO
{ '08'																	, .T. }, ; //X3_ORDEM
{ 'A2_CLIENTE'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 9																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cód. Cliente'														, .T. }, ; //X3_TITULO
{ 'Cód. Cliente'														, .T. }, ; //X3_TITSPA
{ 'Custome Cd'															, .T. }, ; //X3_TITENG
{ 'Código Cliente'														, .T. }, ; //X3_DESCRIC
{ 'Código Cliente'														, .T. }, ; //X3_DESCSPA
{ 'Customer Code'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("SA1", M->A2_CLIENTE )'										, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'SA1'																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ '€'																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '001'																	, .T. }, ; //X3_GRPSXG
{ '1'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'SA2'																	, .T. }, ; //X3_ARQUIVO
{ '09'																	, .T. }, ; //X3_ORDEM
{ 'A2_LOJCLI'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 4																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Loja Cliente'														, .T. }, ; //X3_TITULO
{ 'Tda cliente'															, .T. }, ; //X3_TITSPA
{ 'Cust Store'															, .T. }, ; //X3_TITENG
{ 'Loja Cliente'														, .T. }, ; //X3_DESCRIC
{ 'Tienda cliente'														, .T. }, ; //X3_DESCSPA
{ 'Customer Store'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'ExistCpo("SA1", M->A2_CLIENTE + M->A2_LOJCLI )'						, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ '€'																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '002'																	, .T. }, ; //X3_GRPSXG
{ '1'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA2'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'A2_END'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Endereco'															, .T. }, ; //X3_TITULO
	{ 'Direccion'															, .T. }, ; //X3_TITSPA
	{ 'Address'																, .T. }, ; //X3_TITENG
	{ 'Endereco do Fornecedor'												, .T. }, ; //X3_DESCRIC
	{ 'Direccion del Proveedor'												, .T. }, ; //X3_DESCSPA
	{ 'Supplier Address'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(147) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'texto()'																, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

/*aAdd( aSX3, { ;
	{ 'SA2'																	, .T. }, ; //X3_ARQUIVO
	{ '12'																	, .T. }, ; //X3_ORDEM
	{ 'A2_COMPLEM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Complemento'															, .T. }, ; //X3_TITULO
	{ 'Complemento'															, .T. }, ; //X3_TITSPA
	{ 'Complement'															, .T. }, ; //X3_TITENG
	{ 'Complemento do endereço'												, .T. }, ; //X3_DESCRIC
	{ 'Complemento de la direcc.'											, .T. }, ; //X3_DESCSPA
	{ 'Address complement'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME
*/
aAdd( aSX3, { ;
	{ 'SA2'																	, .T. }, ; //X3_ARQUIVO
	{ '14'																	, .T. }, ; //X3_ORDEM
	{ 'A2_BAIRRO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 50																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Bairro'																, .T. }, ; //X3_TITULO
	{ 'Barrio'																, .T. }, ; //X3_TITSPA
	{ 'District'															, .T. }, ; //X3_TITENG
	{ 'Bairro do Fornecedor'												, .T. }, ; //X3_DESCRIC
	{ 'Barrio del Proveedor'												, .T. }, ; //X3_DESCSPA
	{ 'Supplier district'													, .T. }, ; //X3_DESCENG
	{ '@!S15'																, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
	{ 'vazio().or.texto()'													, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'SA2'																	, .T. }, ; //X3_ARQUIVO
{ '17'																	, .T. }, ; //X3_ORDEM
{ 'A2_COD_MUN'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 5																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cod. Municip'														, .T. }, ; //X3_TITULO
{ 'Cod. Municip'														, .T. }, ; //X3_TITSPA
{ 'City Code'															, .T. }, ; //X3_TITENG
{ 'Codigo do Municipio'													, .T. }, ; //X3_DESCRIC
{ 'Codigo del Municipio'												, .T. }, ; //X3_DESCSPA
{ 'City Code'															, .T. }, ; //X3_DESCENG
{ '@99999'																, .T. }, ; //X3_PICTURE
{ 'IIF(M->A2_EST<>"EX",ExistCpo("CC2",M->A2_EST+M->A2_COD_MUN),ExistCpo("G5S",M->A2_COD_MUN))', .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'CIDSA2'																, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ '€'																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ '1'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela SA3
//
aAdd( aSX3, { ;
{ 'SA3'																	, .T. }, ; //X3_ARQUIVO
{ '07'																	, .T. }, ; //X3_ORDEM
{ 'A3_MUN'																, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 25																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Municipio'															, .T. }, ; //X3_TITULO
{ 'Municipio'															, .T. }, ; //X3_TITSPA
{ 'City'																, .T. }, ; //X3_TITENG
{ 'Municipio do Vendedor'												, .T. }, ; //X3_DESCRIC
{ 'Municipio del Vendedor'												, .T. }, ; //X3_DESCSPA
{ 'Sales Rep. City'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ 'vazio().or.texto()'													, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ '1'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'S'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'S'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME
    
//
// Campos Tabela SA6
//

aAdd( aSX3, { ;
	{ 'SA6'																	, .F. }, ; //X3_ARQUIVO
	{ '23'																	, .F. }, ; //X3_ORDEM
	{ 'A6_CONTA'															, .F. }, ; //X3_CAMPO
	{ 'C'																	, .F. }, ; //X3_TIPO
	{ 20																	, .F. }, ; //X3_TAMANHO
	{ 0																		, .F. }, ; //X3_DECIMAL
	{ 'Cta.Corrente'														, .F. }, ; //X3_TITULO
	{ 'Cta.Corrente'														, .F. }, ; //X3_TITSPA
	{ 'Cta.Corrente'														, .F. }, ; //X3_TITENG
	{ 'Conta Contabil do Banco'												, .F. }, ; //X3_DESCRIC
	{ 'Cta.Contable del Banco'												, .F. }, ; //X3_DESCSPA
	{ 'Bank Ledger Account'													, .F. }, ; //X3_DESCENG
	{ '@!'																	, .F. }, ; //X3_PICTURE
	{ 'vazio() .or. Ctb105Cta()'											, .F. }, ; //X3_VALID
	{ Chr(255) + Chr(255) + Chr(236) + Chr(128) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(132) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(131) + Chr(128)					, .F. }, ; //X3_USADO
	{ ''																	, .F. }, ; //X3_RELACAO
	{ 'CT1'																	, .F. }, ; //X3_F3
	{ 1																		, .F. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .F. }, ; //X3_RESERV
	{ ''																	, .F. }, ; //X3_CHECK
	{ ''																	, .F. }, ; //X3_TRIGGER
	{ ''																	, .F. }, ; //X3_PROPRI
	{ 'N'																	, .F. }, ; //X3_BROWSE
	{ 'A'																	, .F. }, ; //X3_VISUAL
	{ 'R'																	, .F. }, ; //X3_CONTEXT
	{ ''																	, .F. }, ; //X3_OBRIGAT
	{ ''																	, .F. }, ; //X3_VLDUSER
	{ ''																	, .F. }, ; //X3_CBOX
	{ ''																	, .F. }, ; //X3_CBOXSPA
	{ ''																	, .F. }, ; //X3_CBOXENG
	{ ''																	, .F. }, ; //X3_PICTVAR
	{ ''																	, .F. }, ; //X3_WHEN
	{ ''																	, .F. }, ; //X3_INIBRW
	{ '003'																	, .F. }, ; //X3_GRPSXG
	{ ''																	, .F. }, ; //X3_FOLDER
	{ ''																	, .F. }, ; //X3_CONDSQL
	{ ''																	, .F. }, ; //X3_CHKSQL
	{ 'N'																	, .F. }, ; //X3_IDXSRV
	{ 'N'																	, .F. }, ; //X3_ORTOGRA
	{ ''																	, .F. }, ; //X3_TELA
	{ '1'																	, .F. }, ; //X3_POSLGT
	{ 'N'																	, .F. }, ; //X3_IDXFLD
	{ ''																	, .F. }, ; //X3_AGRUP
	{ 'N'																	, .F. }, ; //X3_MODAL
	{ 'S'																	, .F. }} ) //X3_PYME


aAdd( aSX3, { ;
	{ 'SA6'																	, .F. }, ; //X3_ARQUIVO
	{ '24'																	, .F. }, ; //X3_ORDEM
	{ 'A6_XCONTA'															, .F. }, ; //X3_CAMPO
	{ 'C'																	, .F. }, ; //X3_TIPO
	{ 20																	, .F. }, ; //X3_TAMANHO
	{ 0																		, .F. }, ; //X3_DECIMAL
	{ 'Cta Aplicac'															, .F. }, ; //X3_TITULO
	{ 'Cta Aplicac'															, .F. }, ; //X3_TITSPA
	{ 'Cta Aplicac'															, .F. }, ; //X3_TITENG
	{ 'Cta contabil de aplicacao'											, .F. }, ; //X3_DESCRIC
	{ 'Cta contabil de aplicacao'											, .F. }, ; //X3_DESCSPA
	{ 'Cta contabil de aplicacao'											, .F. }, ; //X3_DESCENG
	{ '@!'																	, .F. }, ; //X3_PICTURE
	{ ''																	, .F. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .F. }, ; //X3_USADO
	{ ''																	, .F. }, ; //X3_RELACAO
	{ 'CT1'																	, .F. }, ; //X3_F3
	{ 0																		, .F. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .F. }, ; //X3_RESERV
	{ ''																	, .F. }, ; //X3_CHECK
	{ ''																	, .F. }, ; //X3_TRIGGER
	{ 'U'																	, .F. }, ; //X3_PROPRI
	{ 'N'																	, .F. }, ; //X3_BROWSE
	{ 'A'																	, .F. }, ; //X3_VISUAL
	{ 'R'																	, .F. }, ; //X3_CONTEXT
	{ ''																	, .F. }, ; //X3_OBRIGAT
	{ ''																	, .F. }, ; //X3_VLDUSER
	{ ''																	, .F. }, ; //X3_CBOX
	{ ''																	, .F. }, ; //X3_CBOXSPA
	{ ''																	, .F. }, ; //X3_CBOXENG
	{ ''																	, .F. }, ; //X3_PICTVAR
	{ ''																	, .F. }, ; //X3_WHEN
	{ ''																	, .F. }, ; //X3_INIBRW
	{ ''																	, .F. }, ; //X3_GRPSXG
	{ ''																	, .F. }, ; //X3_FOLDER
	{ ''																	, .F. }, ; //X3_CONDSQL
	{ ''																	, .F. }, ; //X3_CHKSQL
	{ ''																	, .F. }, ; //X3_IDXSRV
	{ 'N'																	, .F. }, ; //X3_ORTOGRA
	{ ''																	, .F. }, ; //X3_TELA
	{ '2'																	, .F. }, ; //X3_POSLGT
	{ 'N'																	, .F. }, ; //X3_IDXFLD
	{ ''																	, .F. }, ; //X3_AGRUP
	{ ''																	, .F. }, ; //X3_MODAL
	{ ''																	, .F. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA6'																	, .F. }, ; //X3_ARQUIVO
	{ '25'																	, .F. }, ; //X3_ORDEM
	{ 'A6_XCONTA2'															, .F. }, ; //X3_CAMPO
	{ 'C'																	, .F. }, ; //X3_TIPO
	{ 20																	, .F. }, ; //X3_TAMANHO
	{ 0																		, .F. }, ; //X3_DECIMAL
	{ 'Cta Empresti'														, .F. }, ; //X3_TITULO
	{ 'Cta Empresti'														, .F. }, ; //X3_TITSPA
	{ 'Cta Empresti'														, .F. }, ; //X3_TITENG
	{ 'Conta contabil emprestimo'											, .F. }, ; //X3_DESCRIC
	{ 'Conta contabil emprestimo'											, .F. }, ; //X3_DESCSPA
	{ 'Conta contabil emprestimo'											, .F. }, ; //X3_DESCENG
	{ '@!'																	, .F. }, ; //X3_PICTURE
	{ ''																	, .F. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .F. }, ; //X3_USADO
	{ ''																	, .F. }, ; //X3_RELACAO
	{ 'CT1'																	, .F. }, ; //X3_F3
	{ 0																		, .F. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .F. }, ; //X3_RESERV
	{ ''																	, .F. }, ; //X3_CHECK
	{ ''																	, .F. }, ; //X3_TRIGGER
	{ 'U'																	, .F. }, ; //X3_PROPRI
	{ 'N'																	, .F. }, ; //X3_BROWSE
	{ 'A'																	, .F. }, ; //X3_VISUAL
	{ 'R'																	, .F. }, ; //X3_CONTEXT
	{ ''																	, .F. }, ; //X3_OBRIGAT
	{ ''																	, .F. }, ; //X3_VLDUSER
	{ ''																	, .F. }, ; //X3_CBOX
	{ ''																	, .F. }, ; //X3_CBOXSPA
	{ ''																	, .F. }, ; //X3_CBOXENG
	{ ''																	, .F. }, ; //X3_PICTVAR
	{ ''																	, .F. }, ; //X3_WHEN
	{ ''																	, .F. }, ; //X3_INIBRW
	{ ''																	, .F. }, ; //X3_GRPSXG
	{ ''																	, .F. }, ; //X3_FOLDER
	{ ''																	, .F. }, ; //X3_CONDSQL
	{ ''																	, .F. }, ; //X3_CHKSQL
	{ ''																	, .F. }, ; //X3_IDXSRV
	{ 'N'																	, .F. }, ; //X3_ORTOGRA
	{ ''																	, .F. }, ; //X3_TELA
	{ '2'																	, .F. }, ; //X3_POSLGT
	{ 'N'																	, .F. }, ; //X3_IDXFLD
	{ ''																	, .F. }, ; //X3_AGRUP
	{ ''																	, .F. }, ; //X3_MODAL
	{ ''																	, .F. }} ) //X3_PYME

//
// Campos Tabela SE1
//
aAdd( aSX3, { ;
	{ 'SE1'																	, .T. }, ; //X3_ARQUIVO
	{ '15'																	, .T. }, ; //X3_ORDEM
	{ 'E1_XDTPROR'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt. Prorroga'														, .T. }, ; //X3_TITULO
	{ 'Dt. Prorroga'														, .T. }, ; //X3_TITSPA
	{ 'Dt. Prorroga'														, .T. }, ; //X3_TITENG
	{ 'Data de Prorrogacao'													, .T. }, ; //X3_DESCRIC
	{ 'Data de Prorrogacao'													, .T. }, ; //X3_DESCSPA
	{ 'Data de Prorrogacao'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SE1'																	, .T. }, ; //X3_ARQUIVO
	{ 'Q5'																	, .T. }, ; //X3_ORDEM
	{ 'E1_XMULTA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Perc Multa'															, .T. }, ; //X3_TITULO
	{ 'Perc Multa'															, .T. }, ; //X3_TITSPA
	{ 'Perc Multa'															, .T. }, ; //X3_TITENG
	{ 'Percentual de Multa'													, .T. }, ; //X3_DESCRIC
	{ 'Percentual de Multa'													, .T. }, ; //X3_DESCSPA
	{ 'Percentual de Multa'													, .T. }, ; //X3_DESCENG
	{ '@E 9.99'																, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '3'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SE1'																	, .T. }, ; //X3_ARQUIVO
	{ 'Q6'																	, .T. }, ; //X3_ORDEM
	{ 'E1_XCOBJM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cob JurosMul'														, .T. }, ; //X3_TITULO
	{ 'Cob JurosMul'														, .T. }, ; //X3_TITSPA
	{ 'Cob JurosMul'														, .T. }, ; //X3_TITENG
	{ 'Cobra Juros e Multa?'												, .T. }, ; //X3_DESCRIC
	{ 'Cobra Juros e Multa?'												, .T. }, ; //X3_DESCSPA
	{ 'Cobra Juros e Multa?'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Sim;2=Nao'															, .T. }, ; //X3_CBOX
	{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
	{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME
 
//
// Campos Tabela SE2
//
aAdd( aSX3, { ;
	{ 'SE2'																	, .T. }, ; //X3_ARQUIVO
	{ 'M5'																	, .T. }, ; //X3_ORDEM
	{ 'E2_XFCTADV'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'DV Ag. Conta'														, .T. }, ; //X3_TITULO
	{ 'DV Ag. Conta'														, .T. }, ; //X3_TITSPA
	{ 'DV Ag. Conta'														, .T. }, ; //X3_TITENG
	{ 'Digito da Agencia e Conta'											, .T. }, ; //X3_DESCRIC
	{ 'Digito da Agencia e Conta'											, .T. }, ; //X3_DESCSPA
	{ 'Digito da Agencia e Conta'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '4'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela SEE
//                  
aAdd( aSX3, { ;
	{ 'SEE'																	, .T. }, ; //X3_ARQUIVO
	{ '21'																	, .T. }, ; //X3_ORDEM
	{ 'EE_CODEMP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod Empresa'															, .T. }, ; //X3_TITULO
	{ 'Cod Empresa'															, .T. }, ; //X3_TITSPA
	{ 'Comp. Code'															, .T. }, ; //X3_TITENG
	{ 'Codigo empresa no Banco'												, .T. }, ; //X3_DESCRIC
	{ 'Codigo empresa en Banco'												, .T. }, ; //X3_DESCSPA
	{ 'Company Code in Bank'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'SEE'																	, .T. }, ; //X3_ARQUIVO
{ '65'																	, .T. }, ; //X3_ORDEM
{ 'EE_XJURDIA'															, .T. }, ; //X3_CAMPO
{ 'N'																	, .T. }, ; //X3_TIPO
{ 14																	, .T. }, ; //X3_TAMANHO
{ 2																		, .T. }, ; //X3_DECIMAL
{ 'Taxa Perman.'														, .T. }, ; //X3_TITULO
{ 'Taxa Perman.'														, .T. }, ; //X3_TITSPA
{ 'Taxa Perman.'														, .T. }, ; //X3_TITENG
{ 'Taxa Permanencia Diaria'												, .T. }, ; //X3_DESCRIC
{ 'Taxa Permanencia Diaria'												, .T. }, ; //X3_DESCSPA
{ 'Taxa Permanencia Diaria'												, .T. }, ; //X3_DESCENG
{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 0																		, .T. }, ; //X3_NIVEL
{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ 'U'																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ ''																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ ''																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ ''																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ ''																	, .T. }, ; //X3_MODAL
{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela SU5
//
aAdd( aSX3, { ;
{ 'SU5'																	, .T. }, ; //X3_ARQUIVO
{ '19'																	, .T. }, ; //X3_ORDEM
{ 'U5_EMAIL'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 100																	, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'E-mail'																, .T. }, ; //X3_TITULO
{ 'E-mail'																, .T. }, ; //X3_TITSPA
{ 'E-mail'																, .T. }, ; //X3_TITENG
{ 'e-mail'																, .T. }, ; //X3_DESCRIC
{ 'e-mail'																, .T. }, ; //X3_DESCSPA
{ 'e-mail'																, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'VAZIO() .OR. EXISTCHAV("SU5",M->U5_EMAIL,9)'							, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ '€'																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ '1'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'SU5'																	, .T. }, ; //X3_ARQUIVO
{ '23'																	, .T. }, ; //X3_ORDEM
{ 'U5_SEXO'																, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 1																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Sexo'																, .T. }, ; //X3_TITULO
{ 'Sexo'																, .T. }, ; //X3_TITSPA
{ 'Gender'																, .T. }, ; //X3_TITENG
{ 'Sexo (Masculino/Feminino)'											, .T. }, ; //X3_DESCRIC
{ 'Sexo (Masculino/Femenino)'											, .T. }, ; //X3_DESCSPA
{ 'Gender (Male/Female)'												, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'vazio() .OR. Pertence("12")'											, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'N'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ '1=Masculino;2=Feminino;'												, .T. }, ; //X3_CBOX
{ '1=Masculino;2=Femenino;'												, .T. }, ; //X3_CBOXSPA
{ '1=Male;2=Female;'													, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ '2'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'SU5'																	, .T. }, ; //X3_ARQUIVO
{ '24'																	, .T. }, ; //X3_ORDEM
{ 'U5_NIVER'															, .T. }, ; //X3_CAMPO
{ 'D'																	, .T. }, ; //X3_TIPO
{ 8																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Data de Nasc'														, .T. }, ; //X3_TITULO
{ 'Fcha. Nac.'															, .T. }, ; //X3_TITSPA
{ 'Birthday'															, .T. }, ; //X3_TITENG
{ 'Data de Nascimento'													, .T. }, ; //X3_DESCRIC
{ 'Fcha de Nacimiento'													, .T. }, ; //X3_DESCSPA
{ 'Birthday'															, .T. }, ; //X3_DESCENG
{ ''																	, .T. }, ; //X3_PICTURE
{ ''																	, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ '2'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'SU5'																	, .T. }, ; //X3_ARQUIVO
{ '63'																	, .T. }, ; //X3_ORDEM
{ 'U5_PAIS'																, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 3																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'País'																, .T. }, ; //X3_TITULO
{ 'Pais'																, .T. }, ; //X3_TITSPA
{ 'Country'																, .T. }, ; //X3_TITENG
{ 'Código do país'														, .T. }, ; //X3_DESCRIC
{ 'Codigo del pais'														, .T. }, ; //X3_DESCSPA
{ 'Country code'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'Vazio() .or. ExistCpo("SYA",M->U5_PAIS)'								, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'SYA'																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(158) + Chr(128)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ ''																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ '€'																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ ''																	, .T. }, ; //X3_GRPSXG
{ '1'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ 'N'																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'SU5'																	, .T. }, ; //X3_ARQUIVO
{ '67'																	, .T. }, ; //X3_ORDEM
{ 'U5_XCOD'																, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 9																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Cliente'																, .T. }, ; //X3_TITULO
{ 'Cliente'																, .T. }, ; //X3_TITSPA
{ 'Customer'															, .T. }, ; //X3_TITENG
{ 'Codigo do Cliente'													, .T. }, ; //X3_DESCRIC
{ 'Codigo del Cliente'													, .T. }, ; //X3_DESCSPA
{ 'Customer´s Code'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'existcpo("SA1",M->U5_XCOD,,,,.F.)'									, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ 'SA1'																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(65)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '001'																	, .T. }, ; //X3_GRPSXG
{ '1'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
{ 'SU5'																	, .T. }, ; //X3_ARQUIVO
{ '68'																	, .T. }, ; //X3_ORDEM
{ 'U5_XLOJA'															, .T. }, ; //X3_CAMPO
{ 'C'																	, .T. }, ; //X3_TIPO
{ 4																		, .T. }, ; //X3_TAMANHO
{ 0																		, .T. }, ; //X3_DECIMAL
{ 'Loja'																, .T. }, ; //X3_TITULO
{ 'Tienda'																, .T. }, ; //X3_TITSPA
{ 'Unit'																, .T. }, ; //X3_TITENG
{ 'Loja do Cliente'														, .T. }, ; //X3_DESCRIC
{ 'Tienda del Cliente'													, .T. }, ; //X3_DESCSPA
{ 'Customer Unit'														, .T. }, ; //X3_DESCENG
{ '@!'																	, .T. }, ; //X3_PICTURE
{ 'existcpo("SA1",M->U5_XCOD+M->U5_XLOJA)'								, .T. }, ; //X3_VALID
{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
{ ''																	, .T. }, ; //X3_RELACAO
{ ''																	, .T. }, ; //X3_F3
{ 1																		, .T. }, ; //X3_NIVEL
{ Chr(134) + Chr(65)													, .T. }, ; //X3_RESERV
{ ''																	, .T. }, ; //X3_CHECK
{ 'S'																	, .T. }, ; //X3_TRIGGER
{ ''																	, .T. }, ; //X3_PROPRI
{ 'S'																	, .T. }, ; //X3_BROWSE
{ 'A'																	, .T. }, ; //X3_VISUAL
{ 'R'																	, .T. }, ; //X3_CONTEXT
{ ''																	, .T. }, ; //X3_OBRIGAT
{ ''																	, .T. }, ; //X3_VLDUSER
{ ''																	, .T. }, ; //X3_CBOX
{ ''																	, .T. }, ; //X3_CBOXSPA
{ ''																	, .T. }, ; //X3_CBOXENG
{ ''																	, .T. }, ; //X3_PICTVAR
{ ''																	, .T. }, ; //X3_WHEN
{ ''																	, .T. }, ; //X3_INIBRW
{ '002'																	, .T. }, ; //X3_GRPSXG
{ '1'																	, .T. }, ; //X3_FOLDER
{ ''																	, .T. }, ; //X3_CONDSQL
{ ''																	, .T. }, ; //X3_CHKSQL
{ 'N'																	, .T. }, ; //X3_IDXSRV
{ ''																	, .T. }, ; //X3_ORTOGRA
{ ''																	, .T. }, ; //X3_TELA
{ '1'																	, .T. }, ; //X3_POSLGT
{ 'N'																	, .T. }, ; //X3_IDXFLD
{ ''																	, .T. }, ; //X3_AGRUP
{ 'N'																	, .T. }, ; //X3_MODAL
{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela SUS
//
aAdd( aSX3, { ;
	{ 'SUS'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'US_NOME'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Razao Social'														, .T. }, ; //X3_TITULO
	{ 'Razon Social'														, .T. }, ; //X3_TITSPA
	{ 'Com. name'															, .T. }, ; //X3_TITENG
	{ 'Razao Social do Prospect'											, .T. }, ; //X3_DESCRIC
	{ 'Razon Social del Prospect'											, .T. }, ; //X3_DESCSPA
	{ "Prosp. company's name"												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(151) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ '001'																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela G66
//
aAdd( aSX3, { ;
	{ 'G66'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'G66_QTDDIA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Qtde. Dias'															, .T. }, ; //X3_TITULO
	{ 'Cant. Días'															, .T. }, ; //X3_TITSPA
	{ 'Days Qty'															, .T. }, ; //X3_TITENG
	{ 'Qtde dias de intervalo'												, .T. }, ; //X3_DESCRIC
	{ 'Cant. días de intervalo'												, .T. }, ; //X3_DESCSPA
	{ 'Qty days interval'													, .T. }, ; //X3_DESCENG
	{ '@E 999'																, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(151) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq][1]+x[nPosOrd][1]+x[nPosCpo][1] < y[nPosArq][1]+y[nPosOrd][1]+y[nPosCpo][1] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )
	
	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG][1] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG][1] ) )
			If aSX3[nI][nPosTam][1] <> SXG->XG_SIZE
				aSX3[nI][nPosTam][1] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf
	
	SX3->( dbSetOrder( 2 ) )
	
	If !( aSX3[nI][nPosArq][1] $ cAlias )
		cAlias += aSX3[nI][nPosArq][1] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq][1] )
	EndIf
	
	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo][1], nTamSeek ) ) )
		
		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq][1] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq][1]
			
			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )
			
			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf
			
			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf
		
		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )
		
		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )
				
			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] ) )
				
			EndIf
		Next nJ
		
		dbCommit()
		MsUnLock()
		
		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo][1] )
		
	Else
		
		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG][1]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam][1] <> SXG->XG_SIZE
					aSX3[nI][nPosTam][1] := SXG->XG_SIZE
					AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " NÃO atualizado e foi mantido em [" + ;
					AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF + ;
					"   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF )
				EndIf
			EndIf
		EndIf
		
		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )
			
			//
			// Se o campo estiver diferente da estrutura
			//
			If aSX3[nI][nJ][2]
				cX3Campo := AllTrim( aEstrut[nJ][1] )
				cX3Dado  := SX3->( FieldGet( aEstrut[nJ][2] ) )
				
				If  aEstrut[nJ][2] > 0 .AND. ;
					PadR( StrTran( AllToChar( cX3Dado ), " ", "" ), 250 ) <> ;
					PadR( StrTran( AllToChar( aSX3[nI][nJ][1] ), " ", "" ), 250 ) .AND. ;
					(!cX3Campo == "X3_ORDEM" .OR. cX3Campo == "X3_TAMANHO" .OR. cX3Campo == "X3_DECIMAL" .OR. ;
					cX3Campo == "X3_TITULO" .OR. cX3Campo == "X3_PICTURE" .OR. cX3Campo == "X3_F3" .OR. ;
					cX3Campo == "X3_VISUAL" .OR. cX3Campo == "X3_FOLDER")
					
					cMsg := "O campo " + aSX3[nI][nPosCpo][1] + " está com o " + cX3Campo + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( cX3Dado ) ) + "]" + CRLF + ;
					"que será substituído pelo NOVO conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSX3[nI][nJ][1] ) ) + "]" + CRLF + ;
					"Deseja substituir ? "
					
					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SX3" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )
						
						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SX3 e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf
						
						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX3 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf
						
					EndIf
					
					If nOpcA == 1
						AutoGrLog( "Alterado campo " + aSX3[nI][nPosCpo][1] + CRLF + ;
						"   " + PadR( cX3Campo, 10 ) + " de [" + AllToChar( cX3Dado ) + "]" + CRLF + ;
						"            para [" + AllToChar( aSX3[nI][nJ][1] )           + "]" + CRLF )
						
						RecLock( "SX3", .F. )
						FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] )
						MsUnLock()
					EndIf
					
				EndIf
				
			EndIf
			
		Next
		
	EndIf
	
	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )
	
Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX9
Função de processamento da gravação do SX9 - Relacionamento

@author TOTVS Protheus
@since  22/07/2016
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX9()
Local aEstrut   := {}
Local aSX9      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX9->X9_DOM )

AutoGrLog( "Ínicio da Atualização" + " SX9" + CRLF )

aEstrut := { "X9_DOM"    , "X9_IDENT"  , "X9_CDOM"   , "X9_EXPDOM" , "X9_EXPCDOM", "X9_PROPRI" , "X9_LIGDOM" , ;
"X9_LIGCDOM", "X9_CONDSQL", "X9_USEFIL" , "X9_VINFIL" , "X9_CHVFOR" , "X9_ENABLE" }


//
// Domínio G8N
//
aAdd( aSX9, { ;
'G8N'																	, ; //X9_DOM
'001'																	, ; //X9_IDENT
'G3W'																	, ; //X9_CDOM
'G8N_CODLIN+G8N_CODIGO'													, ; //X9_EXPDOM
'G3W_LINHA+G3W_TRECHO'													, ; //X9_EXPCDOM
'S'																		, ; //X9_PROPRI
'1'																		, ; //X9_LIGDOM
'N'																		, ; //X9_LIGCDOM
''																		, ; //X9_CONDSQL
''																		, ; //X9_USEFIL
''																		, ; //X9_VINFIL
''																		, ; //X9_CHVFOR
'S'																		} ) //X9_ENABLE

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX9 ) )

dbSelectArea( "SX9" )
dbSetOrder( 2 )

For nI := 1 To Len( aSX9 )
	
	//	If !SX9->( dbSeek( PadR( aSX9[nI][3], nTamSeek ) + PadR( aSX9[nI][1], nTamSeek ) ) )
	If SX9->( dbSeek( PadR( aSX9[nI][3], nTamSeek ) + PadR( aSX9[nI][1], nTamSeek ) ) )
		
		If !( aSX9[nI][1]+aSX9[nI][3] $ cAlias )
			cAlias += aSX9[nI][1]+aSX9[nI][3] + "/"
		EndIf
		
		RecLock( "SX9", .F. )
		For nJ := 1 To Len( aSX9[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX9[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
		
		AutoGrLog( "Foi incluído o relacionamento " + aSX9[nI][1] + "/" + aSX9[nI][3] )
		
		oProcess:IncRegua2( "Atualizando Arquivos (SX9)..." )
		
	EndIf
	
Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX9" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  11/07/2016
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
"DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela G3H
//
aAdd( aSIX, { ;
'G3H'																	, ; //INDICE
'5'																		, ; //ORDEM
'G3H_FILIAL+G3H_NOMEAG'													, ; //CHAVE
'Nome'																	, ; //DESCRICAO
'Nombre'																, ; //DESCSPA
'Name'																	, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'NOMEG3H'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

//
// Tabela G48
//
aAdd( aSIX, { ;
'G48'																	, ; //INDICE
'6'																		, ; //ORDEM
'G48_FILIAL+G48_CODAPU'													, ; //CHAVE
'Apuracao'																, ; //DESCRICAO
'Calculo'																, ; //DESCSPA
'Calculation'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'FILAPUR'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

//
// Tabela G4L
//
aAdd( aSIX, { ;
	'G4L'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'G4L_FILIAL+G4L_CODIGO'													, ; //CHAVE
	'Código'																, ; //DESCRICAO
	'Código'																, ; //DESCSPA
	'Code'																	, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'G4L'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'G4L_FILIAL+G4L_CLIENT+G4L_LOJA'										, ; //CHAVE
	'Cód. Cliente + Loja'													, ; //DESCRICAO
	'Cód. Cliente + Tienda'													, ; //DESCSPA
	'Cust Code + Store'														, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'G4L'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'G4L_FILIAL+G4L_XNOME'													, ; //CHAVE
	'Nome Cliente'															, ; //DESCRICAO
	'Nome Cliente'															, ; //DESCSPA
	'Nome Cliente'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'G4LNOME'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'G4L'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'G4L_FILIAL+G4L_XMUN'													, ; //CHAVE
	'Municipio'																, ; //DESCRICAO
	'Municipio'																, ; //DESCSPA
	'Municipio'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'G4LMUNIC'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela G4R
//
aAdd( aSIX, { ;
	'G4R'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'G4R_FILIAL+G4R_FORNEC+G4R_LOJA'										, ; //CHAVE
	'Cód. Fornec. + Loja'													, ; //DESCRICAO
	'Cód. Proveed + Tienda'													, ; //DESCSPA
	'Supplier Cod + Store'													, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'G4R'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'G4R_FILIAL+G4R_XNOME'													, ; //CHAVE
	'Nome Fornec'															, ; //DESCRICAO
	'Nome Fornec'															, ; //DESCSPA
	'Nome Fornec'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'G4RNOME'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'G4R'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'G4R_FILIAL+G4R_XMUN'													, ; //CHAVE
	'Municipio'																, ; //DESCRICAO
	'Municipio'																, ; //DESCSPA
	'Municipio'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'G4RMUNIC'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela G4W
//
aAdd( aSIX, { ;
'G4W'																	, ; //INDICE
'2'																		, ; //ORDEM
'G4W_FILIAL+G4W_DESCRI'													, ; //CHAVE
'Descrição'																, ; //DESCRICAO
'Descripción'															, ; //DESCSPA
'Description'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'DESCRIG4W'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'G4W'																	, ; //INDICE
'3'																		, ; //ORDEM
'G4W_FILIAL+G4W_VALOR'													, ; //CHAVE
'Valor'																	, ; //DESCRICAO
'Valor'																	, ; //DESCSPA
'Value'																	, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'VALORG4W'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'G4W'																	, ; //INDICE
'4'																		, ; //ORDEM
'G4W_FILIAL+G4W_VIGINI'													, ; //CHAVE
'Vigência De'															, ; //DESCRICAO
'De Vigencia'															, ; //DESCSPA
'ValidityFrom'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'DTINIG4W'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'G4W'																	, ; //INDICE
'5'																		, ; //ORDEM
'G4W_FILIAL+G4W_VIGFIM'													, ; //CHAVE
'Vigência Até'															, ; //DESCRICAO
'A Vigencia'															, ; //DESCSPA
'Validity To'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'DTFIMG4W'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

//
// Tabela G5V
//
aAdd( aSIX, { ;
'G5V'																	, ; //INDICE
'3'																		, ; //ORDEM
'G5V_FILIAL+G5V_DESCRI'													, ; //CHAVE
'Desc. Acordo'															, ; //DESCRICAO
'Desc. Acuerd'															, ; //DESCSPA
'AgreemtDescr'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'DESCRIG5V'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'G5V'																	, ; //INDICE
'4'																		, ; //ORDEM
'G5V_FILIAL+G5V_VALOR'													, ; //CHAVE
'Valor'																	, ; //DESCRICAO
'Valor'																	, ; //DESCSPA
'Value'																	, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'VALORG5V'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'G5V'																	, ; //INDICE
'5'																		, ; //ORDEM
'G5V_VIGINI'															, ; //CHAVE
'Vigência de'															, ; //DESCRICAO
'De vigencia'															, ; //DESCSPA
'Validity fro'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'DTINIG5V'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'G5V'																	, ; //INDICE
'6'																		, ; //ORDEM
'G5V_VIGFIM'															, ; //CHAVE
'Vigência até'															, ; //DESCRICAO
'A vigencia'															, ; //DESCSPA
'Validity to'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'DTFIMG5V'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

//
// Tabela G6D
//
aAdd( aSIX, { ;
'G6D'																	, ; //INDICE
'4'																		, ; //ORDEM
'G6D_FILIAL+G6D_DESCRI'													, ; //CHAVE
'Descrição'																, ; //DESCRICAO
'Descripción'															, ; //DESCSPA
'Description'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'DESCRIG6D'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'G6D'																	, ; //INDICE
'5'																		, ; //ORDEM
'G6D_FILIAL+G6D_VIGINI'													, ; //CHAVE
'Vigência De'															, ; //DESCRICAO
'De Vigencia'															, ; //DESCSPA
'ValidityFrom'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'DTINIG6D'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'G6D'																	, ; //INDICE
'6'																		, ; //ORDEM
'G6D_FILIAL+G6D_VIGFIM'													, ; //CHAVE
'Vigência Até'															, ; //DESCRICAO
'A Vigencia'															, ; //DESCSPA
'Validity To'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'DTFIMG6D'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

//
// Tabela SA1
//
aAdd( aSIX, { ;
'SA1'																	, ; //INDICE
'D'																		, ; //ORDEM
'A1_FILIAL+A1_MUN'														, ; //CHAVE
'Municipio'																, ; //DESCRICAO
'Municipio'																, ; //DESCSPA
'Municipality'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'MUNCCLI'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

//
// Tabela SA2
//
aAdd( aSIX, { ;
'SA2'																	, ; //INDICE
'A'																		, ; //ORDEM
'A2_FILIAL+A2_XSABRE'													, ; //CHAVE
'Codigo Sabre'															, ; //DESCRICAO
'Codigo Sabre'															, ; //DESCSPA
'Codigo Sabre'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'XSABRE'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'SA2'																	, ; //INDICE
'B'																		, ; //ORDEM
'A2_FILIAL+A2_NREDUZ'													, ; //CHAVE
'N Fantasia'															, ; //DESCRICAO
'Nom Fantasia'															, ; //DESCSPA
'Trade Name'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'NOMEFOR'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'SA2'																	, ; //INDICE
'C'																		, ; //ORDEM
'A2_FILIAL+A2_MUN'														, ; //CHAVE
'Municipio'																, ; //DESCRICAO
'Municipio'																, ; //DESCSPA
'City'																	, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'MUNICFOR'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ
//
// Tabela AGT
//
aAdd( aSIX, { ;
'AGT'																	, ; //INDICE
'2'																		, ; //ORDEM
'AGT_FILIAL+AGT_DESCRI'													, ; //CHAVE
'Descrição'																, ; //DESCRICAO
'Descripción'															, ; //DESCSPA
'Description'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
'DESCRIAGT'																, ; //NICKNAME
'S'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )
	
	lAlt    := .F.
	lDelInd := .F.
	
	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
			StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf
	
	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()
	
	dbCommit()
	
	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf
	
	oProcess:IncRegua2( "Atualizando índices..." )
	
Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtu3
Função de processamento da gravação do SX7 - Gatilhos

@author TOTVS Protheus
@since  11/07/2016
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
Local aEstrut   := {}
Local aAreaSX3  := SX3->( GetArea() )
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
"X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo A1_EST
//
aAdd( aSX7, { ;
'A1_EST'		   														, ; //X7_CAMPO
'002'																	, ; //X7_SEQUENC
'IF(ALLTRIM(M->A1_EST)<>"EX","105","")'									, ; //X7_REGRA
'A1_PAIS'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'N'																		, ; //X7_SEEK
''																		, ; //X7_ALIAS
0																		, ; //X7_ORDEM
''																		, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
''																		} ) //X7_CONDIC

//
// Campo A1_EST
//
aAdd( aSX7, { ;
'A1_EST'		   														, ; //X7_CAMPO
'002'																	, ; //X7_SEQUENC
'IF(ALLTRIM(M->A1_EST)<>"EX","01058","")'								, ; //X7_REGRA
'A1_CODPAIS'															, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'N'																		, ; //X7_SEEK
''																		, ; //X7_ALIAS
0																		, ; //X7_ORDEM
''																		, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
''																		} ) //X7_CONDIC

//
// Campo A1_COD_MUN
//
aAdd( aSX7, { ;
'A1_COD_MUN'															, ; //X7_CAMPO
'001'																	, ; //X7_SEQUENC
'CC2->CC2_MUN' 															, ; //X7_REGRA
'A1_MUN'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'S'																		, ; //X7_SEEK
'CC2'																	, ; //X7_ALIAS
1																		, ; //X7_ORDEM
"xFilial('CC2')+M->A1_EST+M->A1_COD_MUN"								, ; //X7_CHAVE
'S'																		, ; //X7_PROPRI
'M->A1_EST<>"EX"'														} ) //X7_CONDIC

//
// Campo A1_COD_MUN
//
aAdd( aSX7, { ;
'A1_COD_MUN'															, ; //X7_CAMPO
'003'																	, ; //X7_SEQUENC
'G5S->G5S_CIDADE'														, ; //X7_REGRA
'A1_MUN'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'N'																		, ; //X7_SEEK
''																		, ; //X7_ALIAS
0																		, ; //X7_ORDEM
''																		, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
'M->A1_EST="EX"'														} ) //X7_CONDIC


//
// Campo A2_EST
//
aAdd( aSX7, { ;
'A2_EST'		   														, ; //X7_CAMPO
'003'																	, ; //X7_SEQUENC
'IF(ALLTRIM(M->A2_EST)<>"EX","105","")'									, ; //X7_REGRA
'A2_PAIS'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'N'																		, ; //X7_SEEK
''																		, ; //X7_ALIAS
0																		, ; //X7_ORDEM
''																		, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
''																		} ) //X7_CONDIC

//
// Campo A2_EST
//
aAdd( aSX7, { ;
'A2_EST'		   														, ; //X7_CAMPO
'004'																	, ; //X7_SEQUENC
'IF(ALLTRIM(M->A2_EST)<>"EX","01058","")'								, ; //X7_REGRA
'A2_CODPAIS'															, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'N'																		, ; //X7_SEEK
''																		, ; //X7_ALIAS
0																		, ; //X7_ORDEM
''																		, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
''																		} ) //X7_CONDIC

//
// Campo A2_COD_MUN
//
aAdd( aSX7, { ;
'A2_COD_MUN'															, ; //X7_CAMPO
'001'																	, ; //X7_SEQUENC
'CC2->CC2_MUN'															, ; //X7_REGRA
'A2_MUN'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'S'																		, ; //X7_SEEK
'CC2'																	, ; //X7_ALIAS
1																		, ; //X7_ORDEM
"xFilial('CC2')+M->A2_EST+M->A2_COD_MUN"								, ; //X7_CHAVE
'S'																		, ; //X7_PROPRI
'M->A2_EST<>"EX"'														} ) //X7_CONDIC

//
// Campo A2_COD_MUN
//
aAdd( aSX7, { ;
'A2_COD_MUN'															, ; //X7_CAMPO
'002'																	, ; //X7_SEQUENC
'G5S->G5S_CIDADE'														, ; //X7_REGRA
'A2_MUN'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'N'																		, ; //X7_SEEK
''																		, ; //X7_ALIAS
0																		, ; //X7_ORDEM
''																		, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
'M->A2_EST="EX"'														} ) //X7_CONDIC


//
// Campo G4L_LOJA
//
aAdd( aSX7, { ;
'G4L_LOJA'																, ; //X7_CAMPO
'002'																	, ; //X7_SEQUENC
'SA1->A1_NOME' 															, ; //X7_REGRA
'G4L_XNOME'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'S'																		, ; //X7_SEEK
'SA1'																	, ; //X7_ALIAS
1																		, ; //X7_ORDEM
"xFilial('SA1')+FWFldGet('G4L_CLIENT')+FWFldGet('G4L_LOJA')"			, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
'G4L_LOJA'																, ; //X7_CAMPO
'003'																	, ; //X7_SEQUENC
'SA1->A1_MUN' 															, ; //X7_REGRA
'G4L_XMUN'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'S'																		, ; //X7_SEEK
'SA1'																	, ; //X7_ALIAS
1																		, ; //X7_ORDEM
"xFilial('SA1')+FWFldGet('G4L_CLIENT')+FWFldGet('G4L_LOJA')"			, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
''																		} ) //X7_CONDIC

//
// Campo G4P_UF
//
aAdd( aSX7, { ;
'G4P_UF'		   														, ; //X7_CAMPO
'004'																	, ; //X7_SEQUENC
'IF(ALLTRIM(M->G4P_UF)<>"EX","105","")'									, ; //X7_REGRA
'G4P_PAIS'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'N'																		, ; //X7_SEEK
''																		, ; //X7_ALIAS
0																		, ; //X7_ORDEM
''																		, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
''																		} ) //X7_CONDIC

//
// Campo G4R_LOJA
//
aAdd( aSX7, { ;
'G4R_LOJA'																, ; //X7_CAMPO
'002'																	, ; //X7_SEQUENC
'SA2->A2_NOME' 															, ; //X7_REGRA
'G4R_XNOME'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'S'																		, ; //X7_SEEK
'SA2'																	, ; //X7_ALIAS
1																		, ; //X7_ORDEM
"xFilial('SA2')+FWFldGet('G4R_FORNEC')+FWFldGet('G4R_LOJA')"			, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
'G4R_LOJA'																, ; //X7_CAMPO
'003'																	, ; //X7_SEQUENC
'SA2->A2_MUN' 															, ; //X7_REGRA
'G4R_XMUN'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'S'																		, ; //X7_SEEK
'SA2'																	, ; //X7_ALIAS
1																		, ; //X7_ORDEM
"xFilial('SA2')+FWFldGet('G4R_FORNEC')+FWFldGet('G4R_LOJA')"			, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
''																		} ) //X7_CONDIC

//
// Campo G4V_UF
//
aAdd( aSX7, { ;
'G4V_UF'		   														, ; //X7_CAMPO
'005'																	, ; //X7_SEQUENC
'IF(ALLTRIM(M->G4V_UF)<>"EX","105","")'									, ; //X7_REGRA
'G4V_PAIS'																, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'N'																		, ; //X7_SEEK
''																		, ; //X7_ALIAS
0																		, ; //X7_ORDEM
''																		, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
''																		} ) //X7_CONDIC

//
// Campo G8C_FATURA
//
aAdd( aSX7, { ;
'G8C_FATURA'															, ; //X7_CAMPO
'001'																	, ; //X7_SEQUENC
"FwFldGet('G8C_FATURA')"												, ; //X7_REGRA
'G8C_NUMDOC'															, ; //X7_CDOMIN
'P'																		, ; //X7_TIPO
'N'																		, ; //X7_SEEK
''																		, ; //X7_ALIAS
0																		, ; //X7_ORDEM
''																		, ; //X7_CHAVE
'U'																		, ; //X7_PROPRI
''																		} ) //X7_CONDIC

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )
	
	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )
		
		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )
		EndIf
		
		RecLock( "SX7", .T. )
	Else
		
		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			AutoGrLog( "Foi alterado o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )
		EndIf
		
		RecLock( "SX7", .F. )
	EndIf
	
	For nJ := 1 To Len( aSX7[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
		EndIf
	Next nJ
	
	dbCommit()
	MsUnLock()
	
	If SX3->( dbSeek( SX7->X7_CAMPO ) )
		RecLock( "SX3", .F. )
		SX3->X3_TRIGGER := "S"
		MsUnLock()
	EndIf
	
	oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )
	
Next nI

RestArea( aAreaSX3 )

AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )
	
	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf
	
	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), oDlg:End()  ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  11/07/2016
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
	
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf
	
	Sleep( 500 )
	
Next nLoop

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  11/07/2016
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()
	
	cAux := FT_FREADLN()
	
	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf
	
	FT_FSKIP()
End

FT_FUSE()

Return cRet
/////////////////////////////////////////////////////////////////////////////