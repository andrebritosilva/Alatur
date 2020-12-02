#INCLUDE 'TOTVS.CH'  
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'REPORT.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE 'ALAR001.CH'

Static aColFixas := {{'01', '1'}, ;		// 01-Centro de Custo
					 {'80', '2'}, ;		// 80-Email do Solicitante 
					 {'03', '3'}, ;	 	// 03-Matricula 
					 {'02', '4'}}		// 02-Autorização

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ALAR001

Relatório Customizado de Receita para envio aos clientes da Agência (RDMAKE)

@sample 	ALAR001()
@param 		
@author    Thiago Tavares
@since		19/09/2016
@version	P12.1.13
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function ALAR001()

Local aArea 	  := GetArea()
Local cAliasG6L   := GetNextAlias()
Local oReport     := Nil
Local dDataDe     := CToD('  /  /  ')
Local dDataAte    := CToD('  /  /  ')
Local cGrupoDe    := ''
Local cGrupoAte   := '' 
Local cCliDe      := ''
Local cCliAte     := ''
Local cGrpProdDe  := ''
Local cGrpProdAte := ''
Local cNome       := ''
Local cCampo      := ''
Local cAGTCod     := ''
Local cLogGeracao := ''
Local cArqXls     := ''
Local cCliCod     := ''
Local cLoja       := ''
Local cDirFile    := GetMv('MV_DIRAPUR', , 'C:\TOTVS\')
Local cDirLog     := ''
Local cInnerJoin  := '% '
Local cWhere      := '% '   	
Local nTipo       := 0
Local nStatus     := 0
Local nX          := 0
Local nHandle     := 0
Local lCorp       := .F.
Local lEventos    := .F.
Local lLazer      := .F.
Local lQuebra     := .F.
Local aRelatorios := {} // 1-Código Grupo Cliente / 2-Código Cliente / 3-Loja Cliente / 4-Nome Cliente / 5-Nome arquivo XLS

If Pergunte('ALAR001', .T., .F.)
	nTipo       := MV_PAR01
	dDataDe     := MV_PAR02
	dDataAte    := MV_PAR03
	cGrupoDe    := MV_PAR04
	cGrupoAte   := IIF(!Empty(MV_PAR05), MV_PAR05, Replicate('Z', TamSX3('AGT_CODIGO')[1]))
	cCliDe      := MV_PAR06
	cCliAte     := IIF(!Empty(MV_PAR07), MV_PAR07, Replicate('Z', TamSX3('A1_COD')[1]))
	cGrpProdDe  := MV_PAR08
	cGrpProdAte := MV_PAR09
	nStatus     := MV_PAR10
	lCorp       := MV_PAR11 == 1
	lEventos    := MV_PAR12 == 1
	lLazer      := MV_PAR13 == 1
	lQuebra     := MV_PAR14 == 1
	cDirFile    := IIF(!Empty(Alltrim(MV_PAR15)), Alltrim(MV_PAR15), GetMv('MV_DIRAPUR', , 'C:\TOTVS\'))

	If !lCorp .And. !lEventos .And. !lLazer
		Help( , ,'ALAR001', , STR0040, 1, 0)		// "Para gerar o relatório é obrigatório selecionar pelo menos um Segmento de Negócio."  
	ElseIf AllTrim(Upper(cDirFile)) == 'C:' .Or. AllTrim(Upper(cDirFile)) == 'C:\'
		Help( , ,'ALAR001', , STR0001, 1, 0)			// "Não é possível gravar o(s) Relatório(s) no diretório informado."  
	Else 
		MakeDir(cDirFile)
		MakeDir((cDirLog  := cDirFile + 'Log'))
		MakeDir((cDirFile := cDirFile + IIF(nTipo == 1, STR0004, STR0005)))		// "Clientes" 		"Grupo Clientes"
		If SubStr(cDirFile, Len(cDirFile), 1) != '\'
			cDirFile += '\'
		EndIf 		   
		
		If nTipo == 1	// CLIENTE
			cCampo := '% G6L_CLIENT, G6L_LOJA %'
			cWhere += "AND G6L_CLIENT BETWEEN '" + cCliDe + "' AND '" + cCliAte + "' "
		Else				// GRUPO DE CLIENTE
			cCampo := '% AGT_CODIGO, G6L_CLIENT, G6L_LOJA %'
			cInnerJoin += "INNER JOIN " + RetSqlName('AGU') + " AGU ON AGU_CODCLI = G6L_CLIENT AND AGU_LOJCLI = G6L_LOJA AND AGU.D_E_L_E_T_ = '' " 
			cInnerJoin += "INNER JOIN " + RetSqlName('AGT') + " AGT ON AGT_CODIGO = AGU_CODIGO AND AGT.D_E_L_E_T_ = '' " 
			cWhere     += "AND AGT_CODIGO BETWEEN '" + cGrupoDe + "' AND '" + cGrupoAte + "' "
		EndIf
		
		cInnerJoin += ' %' 
		cWhere     += ' %'     
		
		BeginSQL Alias cAliasG6L
			SELECT DISTINCT %Exp:cCampo% 
			FROM %Table:G6L% G6L
			%Exp:cInnerJoin%
			WHERE G6L_FILIAL = %xFilial:G6L% 
				%Exp:cWhere% 
				AND G6L_DTGERA BETWEEN %Exp:dDataDe% AND %Exp:dDataAte%
				AND G6L_TPAPUR = '1' //Buscar apenas apurações de clientes.
				AND G6L.%notDel%
			ORDER BY %Exp:cCampo% 
		EndSQL

		If (cAliasG6L)->(!Eof())
			While (cAliasG6L)->(!Eof())
				If nTipo == 1
					cCliCod := (cAliasG6L)->G6L_CLIENT
					cLoja   := IIF(lQuebra, (cAliasG6L)->G6L_LOJA, '')

					If lQuebra 
						cNome   := '(' + AllTrim((cAliasG6L)->G6L_CLIENT) + '_' + AllTrim((cAliasG6L)->G6L_LOJA) + ') ' + AllTrim(Posicione('SA1', 1, xFilial('SA1') + (cAliasG6L)->G6L_CLIENT + (cAliasG6L)->G6L_LOJA, 'A1_NREDUZ'))
					Else
						cNome   := '(' + AllTrim((cAliasG6L)->G6L_CLIENT) + ') ' + AllTrim(Posicione('SA1', 1, xFilial('SA1') + (cAliasG6L)->G6L_CLIENT, 'A1_NREDUZ'))
					EndIf
					
					cArqXls := cDirFile + STR0006 + AllTrim((cAliasG6L)->G6L_CLIENT) + IIF(lQuebra, '_' + AllTrim((cAliasG6L)->G6L_LOJA), '') + '_' + FwTimeStamp() + '.xls'			// "RELATORIO_RECEITA_CLIENTE_"
					(cAliasG6L)->(DbSkip())
					
					aAdd(aRelatorios, {cAGTCod, cCliCod, cLoja, cNome, cArqXls})

					If !lQuebra
						While (cAliasG6L)->(!Eof()) .And. (cAliasG6L)->G6L_CLIENT == cCliCod
							(cAliasG6L)->(DbSkip())
						EndDo
					EndIf
				Else
					cAGTCod := (cAliasG6L)->AGT_CODIGO
					cCliCod := (cAliasG6L)->G6L_CLIENT
					cLoja   := IIF(lQuebra, (cAliasG6L)->G6L_LOJA, '')
					cNome   := '(' + AllTrim((cAliasG6L)->AGT_CODIGO) + ') ' + AllTrim(Posicione('AGT', 1, xFilial('AGT') + (cAliasG6L)->AGT_CODIGO, 'AGT_DESCRI'))
					cArqXls := cDirFile + STR0007 + AllTrim(cAGTCod) + '_' + AllTrim((cAliasG6L)->G6L_CLIENT) + IIF(lQuebra, '_' + AllTrim((cAliasG6L)->G6L_LOJA), '') + '_' + FwTimeStamp() + '.xls'			// "RELATORIO_RECEITA_GRUPO_CLIENTE_"
					(cAliasG6L)->(DbSkip())

					aAdd(aRelatorios, {cAGTCod, cCliCod, cLoja, cNome, cArqXls})

					If !lQuebra
						While (cAliasG6L)->(!Eof()) .And. (cAliasG6L)->AGT_CODIGO == cAGTCod .And. (cAliasG6L)->G6L_CLIENT == cCliCod
							(cAliasG6L)->(DbSkip())
						EndDo
					EndIf
				EndIf
			EndDo
			(cAliasG6L)->(DbCloseArea())

			// gerando os relatorios
			For nX := 1 To Len(aRelatorios)
				MsgRun(STR0066, STR0002, {|| oReport := ReportDef(nTipo, aRelatorios[nX][1], aRelatorios[nX][2], aRelatorios[nX][3], dDataDe, dDataAte, cGrpProdDe, cGrpProdAte, nStatus, lCorp, lEventos, lLazer, lQuebra)}) 		// "Gerando relatórios..."		"Aguarde"		
				oReport:SetPreview(.F.)
				oReport:SetDevice(4)
				oReport:cFile := aRelatorios[nX][5]
				oReport:Print(.F.)
				cLogGeracao += I18N(STR0008, {IIF(nTipo == 1, Upper(STR0004), Upper(STR0005)), aRelatorios[nX][4]}) + Chr(13) + Chr(10)		// "Relatório gerado - #1: #2"		"Cliente"		"Grupo Clientes"
			Next nX

			// gravando o arquivo com o log do processamento
			nHandle := FCreate(cArqLog := cDirLog + '\' + If(nTipo == 1, STR0006, STR0007) + FwTimeStamp() + '.log')		// "RELATORIO_RECEITA_CLIENTE_"		"RELATORIO_RECEITA_GRUPO_CLIENTE_"
			FSeek(nHandle, 0, FS_END)         
			FWrite(nHandle, cLogGeracao, Len(cLogGeracao)) 
			FClose(nHandle)
			If FwAlertYesNo(I18N(STR0065, {Alltrim(cDirFile), Chr(13) + Chr(10)}), STR0064) // "Processo finalizado com sucesso. Verifique se o(s) Relatório(s) foi(ram) gerado(s) no diretório #1. #2 Deseja ver o LOG de gereção?" 		"Atenção"
				ShellExecute('Open', cArqLog, '', GetTempPath(), 1)
			EndIf                   
		Else
			Help( , , "ALAR001", , STR0009, 1, 0)			// "Não há Relatório(s) a ser(em) gerado(s) para os parâmetros informados."		
		EndIf
	EndIf 
EndIf

RestArea(aArea)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Processamento do relatorio de Apuração de Receita de Cliente

@sample 	ReportDef(nTipo, cAGTCod, cCliCod, cLoja, dDataDe, dDataAte, cGrpProdDe, cGrpProdAte, nStatus, lCorp, lEventos, lLazer, lQuebra)
@param 		nTipo - Numérico - determina se o relatório será gerado por Cliente ou Grupo Cliente
			cAGTCod - String - código do grupo do cliente
			cCliCod - String - código do cliente
			cLoja - String - loja do cliente, será informado quando a quebra por loja for selecionada
			dDataDe - String - data inicial da geração da apuração
			dDataAte - String - data final da geração da apuração  
			cGrpProdDe - String - código inicial do Grupo de Produto
			cGrpProdAte - String - código final do Grupo de Produto
			cStatus - Numérico - indica o status da apuração que será considerado no relatório
			lCorp - Lógico - indica se é para gerar o relatório para o segmento de negócio Corporativo     
			lEvento - Lógico - indica se é para gerar o relatório para o segmento de negócio Evento     
			lLazer - Lógico - indica se é para gerar o relatório para o segmento de negócio Lazer
			lQuebra - Lógico - indica se haverá quebra por cliente/loja     
@author    Thiago Tavares
@since		23/09/2016
@version	P12.1.13
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ReportDef(nTipo, cAGTCod, cCliCod, cLoja, dDataDe, dDataAte, cGrpProdDe, cGrpProdAte, nStatus, lCorp, lEventos, lLazer, lQuebra)

Local oReport     := Nil
Local oSecCabeca  := Nil		// 1 
Local oSecTrans   := Nil		// 2
Local oSecTranLin := Nil		// 2.1
Local cTitle      := STR0010		// "Relatório de Receita de Cliente"
Local cHelp       := STR0011		// "Gera Relatório de Receita de Cliente"
Local cTabelas    := IIF(nTipo == 1, 'SA1, G6L, G6M, G6O, G3P, ADK, G3Q, CTT, G3R, SA2, G4S, G3S, G3T, G3U, G3V, G3W, G3X, G3Y, G3Z, G40, G41, G43, G44, G46, G48, G4B, G4D', ; 
					  				 'AGT, G6L, SA1, G6M, G6O, G3P, ADK, G3Q, CTT, G3R, SA2, G4S, G3S, G3T, G3U, G3V, G3W, G3X, G3Y, G3Z, G40, G41, G43, G44, G46, G48, G4B, G4D')

oReport := TReport():New('ALAR001', cTitle, , {|oReport| ReportPrint(oReport, nTipo, cAGTCod, cCliCod, cLoja, dDataDe, dDataAte, cGrpProdDe, cGrpProdAte, nStatus, lCorp, lEventos, lLazer, lQuebra)}, cHelp, .T./*lLandscape*/, /*uTotalText*/, /*lTotalInLine*/, /*cPageTText*/, /*lPageTInLine*/, /*lTPageBreak*/, /*nColSpace*/)
oReport:HideHeader()
oReport:SetTotalInLine(.F.)

oSecCabeca  := TRSection():New(oReport, IIF(nTipo == 1, Upper(STR0012), Upper(STR0013)), {IIF(nTipo == 1, 'SA1', 'AGT')})		// "DADOS DO CLIENTE"		"DADOS DO GRUPO DE CLIENTES"		
oSecTrans   := TRSection():New(oReport, STR0014, {cTabelas})		// "VENDAS DO PERÍODO"	
oSecTranLin := TRSection():New(oSecTrans, '', {cTabelas})

Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Regra de impressao e geracao do relatorio

@sample 	ReportPrint(oReport, nTipo, cAGTCod, cCliCod, dDataDe, dDataAte, cGrpProdDe, cGrpProdAte, nStatus, lCorp, lEventos, lLazer, lQuebra)
@param 		oReport - Objeto - TREPORT do relatorio
			nTipo - Numérico - determina se o relatório será gerado por Cliente ou Grupo Cliente
			cAGTCod - String - código do grupo do cliente
			cCliCod - String - código do cliente
			cLoja - String - loja do cliente, será informado quando a quebra por loja for selecionada
			dDataDe - String - data inicial da geração da apuração
			dDataAte - String - data final da geração da apuração  
			cGrpProdDe - String - código inicial do Grupo de Produto
			cGrpProdAte - String - código final do Grupo de Produto
			cStatus - Numérico - indica o status da apuração que será considerado no relatório
			lCorp - Lógico - indica se é para gerar o relatório para o segmento de negócio Corporativo     
			lEvento - Lógico - indica se é para gerar o relatório para o segmento de negócio Evento     
			lLazer - Lógico - indica se é para gerar o relatório para o segmento de negócio Lazer
			lQuebra - Lógico - indica se haverá quebra por cliente/loja     
@author    Thiago Tavares
@since		23/09/2016
@version	P12.1.13
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport, nTipo, cAGTCod, cCliCod, cLoja, dDataDe, dDataAte, cGrpProdDe, cGrpProdAte, nStatus, lCorp, lEventos, lLazer, lQuebra)

Local aArea      := GetArea()
Local oSecCabeca := oReport:Section(1)
Local cNome      := ''

TRCell():New(oSecCabeca, 'DTGERA', '', Upper(STR0014))	
TRCell():New(oSecCabeca, 'NOME'  , '', IIF(nTipo == 1, Upper(STR0004), Upper(STR0005)) + ": ")		// "CLIENTE"		"GRUPO DE CLIENTES" 

//oSecCabeca:BeginQuery()
//oSecCabeca:EndQuery()

If nTipo == 1
	cNome := AllTrim(Posicione('SA1', 1, xFilial('SA1') + cCliCod + cLoja, 'A1_NREDUZ'))
Else		
	cNome := AllTrim(Posicione('AGT', 1, xFilial('AGT') + cAGTCod, 'AGT_DESCRI'))
EndIf 	

oSecCabeca:Cell('DTGERA'):SetValue(TURCAST(dDataDe, 'C') + ' - ' + TURCAST(dDataAte, 'C'))      
oSecCabeca:Cell('NOME'  ):SetValue(cNome) 
oSecCabeca:PrintLine() 

If nTipo == 1
	cNome := '(' + AllTrim(cCliCod) + IIF(lQuebra, '_' + AllTrim(cLoja), '') + ') ' + cNome
Else		
	cNome := '(' + AllTrim(cAGTCod) + ') ' + cNome
EndIf 	

// TRANSACIONAIS
FwMsgRun( , {|oSelf| AR001ATrans(oReport, cCliCod, cLoja, dDataDe, dDataAte, cGrpProdDe, cGrpProdAte, nStatus, lCorp, lEventos, lLazer, lQuebra, oSelf, nTipo, cNome)}, '', I18N(STR0003, {IIF(nTipo == 1, STR0004, STR0005), cNome, '0%'}))	// "Gerando relatórios..."

RestArea(aArea)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AR001ATrans

Função responsável por imprimir a seção destinada aos acordos TRANSACIONAIS

@sample 	AR001Trans(oReport, cCliCod, cLoja, dDataDe, dDataAte, cGrpProdDe, cGrpProdAte, nStatus, lCorp, lEventos, lLazer, lQuebra)
@param 		oReport - Objeto - TREPORT do relatorio
			cCliCod - String - código do cliente
			cLoja - String - loja do cliente, será informado quando a quebra por loja for selecionada
			dDataDe - String - data inicial da geração da apuração
			dDataAte - String - data final da geração da apuração  
			cGrpProdDe - String - código inicial do Grupo de Produto
			cGrpProdAte - String - código final do Grupo de Produto
			nStatus - Numérico - indica o status da apuração que será considerado no relatório
			lCorp - Lógico - indica se é para gerar o relatório para o segmento de negócio Corporativo     
			lEvento - Lógico - indica se é para gerar o relatório para o segmento de negócio Evento     
			lLazer - Lógico - indica se é para gerar o relatório para o segmento de negócio Lazer
			lQuebra - Lógico - indica se haverá quebra por cliente/loja     
			oMsgRun - Objeto do tipo FwMsgRun que será utillziado para atualizar a mensagem na tela 
			nTipo - Determina qual mensagem será mostrada 
			cNome - Nome do Cliente ou Grupo de Cliente que será mostrada
@author    	Thiago Tavares
@since		23/09/2016
@version	P12.1.13
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AR001ATrans(oReport, cCliCod, cLoja, dDataDe, dDataAte, cGrpProdDe, cGrpProdAte, nStatus, lCorp, lEventos, lLazer, lQuebra, oMsgRun, nTipo, cNome)

Local aArea       := GetArea()
Local cAliasG6L   := GetNextAlias()
Local oSecTrans   := oReport:Section(2)				
Local oSecTranLin := oReport:Section(2):Section(1)	
Local cWhere      := '% '
Local cSegmento   := ' ('
Local cEntAdc     := '2'
Local cEntidade1  := I18N(STR0039, {'1'})		// "Ent. Adicional #1"
Local cEntidade2  := I18N(STR0039, {'2'})		// "Ent. Adicional #1"
Local cG4BItens1  := ''
Local cG4BItens2  := ''
Local cColExtras  := '% '
Local aColunas    := {}
Local aColExtras  := {}
Local nX          := 0
Local nCount      := 0
Local nPercAtu    := 0	
Local nTotReg     := 0
Local lAtuMsg	  := ValType(oMsgRun) == 'O'
Local xConteudo   := Nil
Local oBreak      := Nil

Private aEntidades := AR001AENT(cCliCod, cLoja, lCorp, lEventos, lLazer)		// Array 1-Código Ent Adicional / 2-Descrição / 3-Ordem das colunas 

// criando as colunas extras das entidades adicionais
For nX := 1 To Len(aEntidades)
	If aScan(aColFixas, {|x| x[1] == aEntidades[nX][1]}) == 0
		If Empty(cEntidade1) .Or. Empty(cEntidade2)
			If Empty(cEntidade1)
				cG4BItens1 := aEntidades[nX][1]
				cEntidade1 := aEntidades[nX][2]
			Else
				cG4BItens2 := aEntidades[nX][1]
				cEntidade2 := aEntidades[nX][2]
			EndIf
		Else
			cEntADc := Soma1(cEntADc)
			aAdd(aColExtras, {'G4B_ITENS' + cEntAdc, 'G4B', aEntidades[nX][2], TamSx3('G4B_DESENT')[3], TamSx3('G4B_DESENT')[1], TamSx3('G4B_DESENT')[2]})
			cColExtras += ", (SELECT TOP 1 G4B_DESENT " + ;
							"FROM " + RetSqlName('G4B') + " G4B " + ; 
							"WHERE G4B_FILIAL = G3S_FILIAL AND " + ;
							      "G4B_NUMID  = G3S_NUMID  AND " + ; 
							      "G4B_IDITEM = G3S_IDITEM AND " + ; 
							      "G4B_NUMSEQ = G3S_NUMSEQ AND " + ; 
							      "G4B_CODPAX = G3S_CODPAX AND " + ; 
							      "G4B_TPENT  = '" + aEntidades[nX][1] + "' AND " + ; 
							      "G4B.D_E_L_E_T_ = ' ') G4B_ITENS" + cEntAdc
		EndIf
	EndIf
Next nX 

cColExtras += ' %'
aAdd(aColExtras, {'A1_COD' , 'SA1', '', TamSx3('A1_COD' )[3], TamSx3('A1_COD' )[1], TamSx3('A1_COD' )[2]})	
aAdd(aColExtras, {'A1_LOJA', 'SA1', '', TamSx3('A1_LOJA')[3], TamSx3('A1_LOJA')[1], TamSx3('A1_LOJA')[2]})	

If lCorp;    cSegmento += "G6M_SEGNEG = '1' "; EndIf
If lEventos; cSegmento += IIF(cSegmento == ' (', "G6M_SEGNEG = '2' ", "OR G6M_SEGNEG = '2' "); EndIf
If lLazer;   cSegmento += IIF(cSegmento == ' (', "G6M_SEGNEG = '3' ", "OR G6M_SEGNEG = '3' "); EndIf

cSegmento += ') '

If lQuebra 
	cWhere += " AND G6L_CLIENT = '" + cCliCod + "' AND G6L_LOJA = '" + cLoja + "' "
Else
	cWhere += " AND G6L_CLIENT = '" + cCliCod + "' " 
EndIf

cWhere += IIF(AllTrim(Str(nStatus)) $ '1|2', " AND G6L_STATUS = '" + AllTrim(Str(nStatus)) + "' AND ", ' AND ') + cSegmento + ' %'

// colunas da seção
aAdd(aColunas, {'A1_NREDUZ' , 'SA1', STR0015})									// "Nome Cliente"	
aAdd(aColunas, {'G3S_NOME'  , 'G3S', STR0016})									// "Passageiro"
aAdd(aColunas, {'G3Q_GRPPRD', 'G3Q', STR0017})									// "Cód. Produto"		
aAdd(aColunas, {'G3P_DESTIN', 'G3P', STR0018})									// "Tipo Transação"		
aAdd(aColunas, {'G3Q_DESTIN', 'G3Q', STR0019})									// "Destino"	
aAdd(aColunas, {'A2_NOME'   , 'SA2', STR0020})									// "Nome Fornecedor"	
aAdd(aColunas, {'G3Q_DOC'   , 'G3Q', STR0021})									// "Documento"	
aAdd(aColunas, {'SEGMENTOS' , 'G3Q', STR0022})									// "Rota/Cidade"	
aAdd(aColunas, {'CLASSDIAS' , 'G3Q', STR0023})									// "Classes/Diárias"	
aAdd(aColunas, {'G3Q_EMISS' , 'G3Q', STR0024})									// "Data Emissão"	
aAdd(aColunas, {'DTINI'     , 'G3Q', STR0025})									// "Emb./In"	
aAdd(aColunas, {'DTFIM'     , 'G3Q', STR0026})									// "Des./Out"	
aAdd(aColunas, {'G44_APLICA', 'G44', STR0027})									// "Tarifa Aplicada"	
aAdd(aColunas, {'G46_VLTAXA', 'G46', STR0028})									// "Taxas"	
aAdd(aColunas, {'G4B_ITEM'  , 'G4B', STR0029})									// "C.Custo Fatura"	
aAdd(aColunas, {'G4B_NOMESO', 'G4B', STR0030})									// "Solicitante"	
aAdd(aColunas, {'G3R_VLCOMI', 'G3R', STR0031})									// "Comissão Recebida"	
aAdd(aColunas, {'G3R_TAXADU', 'G3R', STR0032})									// "Taxa DU"	
aAdd(aColunas, {'G3Q_REPASS', 'G3Q', STR0033})									// "Devolução Líq."		
aAdd(aColunas, {'G3Q_TXTRAN', 'G3Q', STR0034})									// "Taxa Transação"
aAdd(aColunas, {'G3R_IDCONF', 'G3R', STR0035})									// "Autorização"	
aAdd(aColunas, {'G3Q_TPEMIS', 'G3Q', STR0036})									// "Status"	
aAdd(aColunas, {'G3Q_NUMDOC', 'G3Q', STR0037})									// "Registro de Venda"	
aAdd(aColunas, {'G4B_MATRIC', 'G4B', STR0038})									// "Matrícula"
aAdd(aColunas, {'G4B_ITENS1', 'G4B', cEntidade1})								
aAdd(aColunas, {'G4B_ITENS2', 'G4B', cEntidade2})								
aAdd(aColunas, {'A1_CGC'    , 'SA1', STR0041})									// "Filial/Suc."	
aAdd(aColunas, {'G4S_ABIATA', 'G4S', STR0042})									// "Sigla Cia."
aAdd(aColunas, {'G4B_DSCCCT', 'G4B', STR0043})									// "Desc. C.Custo"
aAdd(aColunas, {'G4D_CARTAO', 'G4D', STR0044})									// "Bandeira/Cartão"
aAdd(aColunas, {'ADK_NOME'  , 'ADK', STR0045})									// "Unidade de Negócio"
aAdd(aColunas, {'A1_NOME'   , 'SA1', STR0046})									// "Razão Social Cliente"
aAdd(aColunas, {'G44_VLRDIA', 'G44', STR0047})									// "Valor Diária"
aAdd(aColunas, {'EMBARQUE'  , 'G3Q', STR0048})									// "Origem"
aAdd(aColunas, {'DESEMBARQ' , 'G3Q', STR0049})									// "Destino"
aAdd(aColunas, {'G44_TXCAMB', 'G44', STR0050})									// "Câmbio"
aAdd(aColunas, {'G44_TARBAS', 'G44', STR0051})									// "Tarifa Base"
aAdd(aColunas, {'G44_CHEIA' , 'G44', STR0052})									// "Tarifa Cheia"
aAdd(aColunas, {'G44_MENOR' , 'G44', STR0053})									// "Menor Tarifa"
aAdd(aColunas, {'G44_PUBLIC', 'G44', STR0054})									// "Tarifa Publicada"
aAdd(aColunas, {'G3T_PERNAS', 'G3T', STR0055})									// "Pernas"
aAdd(aColunas, {'G3R_VLINCE', 'G3R', STR0056})									// "Incentivo Recebido"
aAdd(aColunas, {'G3Q_AREA'  , 'G3Q', STR0057})									// "Área"
aAdd(aColunas, {'G3R_LOCGDS', 'G3R', STR0058})									// "Loc. GDS"
aAdd(aColunas, {'G3Q_TPDOC' , 'G3Q', STR0059})									// "Tipo Documento"
aAdd(aColunas, {'G3Q_KMS'   , 'G3Q', STR0060})									// "Kms Voados"
aAdd(aColunas, {'G3Q_MILHAS', 'G3Q', STR0061})									// "Milhas Voadas"
aAdd(aColunas, {'G3Q_OPERAC', 'G3Q', STR0062})									// "Tipo Operação"
aAdd(aColunas, {'G5T_SIMBOL', 'G44', STR0063})									// "Moeda Forn."

// criando as colunas fixas
For nX := 1 To Len(aColunas)
	TRCell():New(oSecTranLin, aColunas[nX][1], aColunas[nX][2], aColunas[nX][3])
Next nX

// criando as colunas extras 
For nX := 1 To Len(aColExtras)
	TRCell():New(oSecTranLin, aColExtras[nX][1], aColExtras[nX][2], aColExtras[nX][3])
	If aColExtras[nX][2] == "G4B"
		aAdd(aColunas, {aColExtras[nX][1], aColExtras[nX][2], aColExtras[nX][3]})
	EndIf	
Next nX

oSecTranLin:Cell('A1_COD'):Hide()
oSecTranLin:Cell('A1_LOJA'):Hide()
oBreak := TRBreak():New(oSecTranLin, {|| oSecTranLin:Cell('A1_COD'):uPrint }, '', .F.)
TRFunction():New(oSecTranLin:Cell('G44_APLICA'), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)	
TRFunction():New(oSecTranLin:Cell('G46_VLTAXA'), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)
TRFunction():New(oSecTranLin:Cell('G3R_VLCOMI'), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)
TRFunction():New(oSecTranLin:Cell('G3R_TAXADU'), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)
TRFunction():New(oSecTranLin:Cell('G3Q_REPASS'), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)
TRFunction():New(oSecTranLin:Cell('G3Q_TXTRAN'), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)
TRFunction():New(oSecTranLin:Cell('G44_VLRDIA'), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)
TRFunction():New(oSecTranLin:Cell('G44_TARBAS'), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)
TRFunction():New(oSecTranLin:Cell('G44_CHEIA' ), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)
TRFunction():New(oSecTranLin:Cell('G44_MENOR' ), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)
TRFunction():New(oSecTranLin:Cell('G44_PUBLIC'), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)
TRFunction():New(oSecTranLin:Cell('G3R_VLINCE'), , 'SUM', oBreak, , , , .F., .F., .F., oSecTranLin)

oSecTrans:BeginQuery()
	BeginSQL Alias cAliasG6L
		Column G6L_DTGERA as Date
		Column G3Q_EMISS as Date
		Column DTINI as Date
		Column DTFIM as Date
		
		%noParser%
		
		SELECT DISTINCT * 
		FROM 
			(SELECT 
				A1_COD,
				A1_LOJA,
				A1_NREDUZ,
				G3S_NOME,
				G3Q_GRPPRD,
				CASE
					WHEN G3P_DESTIN = '1' THEN 'NAC'
					WHEN G3P_DESTIN = '2' THEN 'INT'
					WHEN G3P_DESTIN = '3' THEN 'AMB'
				END G3P_DESTIN,
				CASE
					WHEN G3Q_DESTIN = '1' THEN 'N'
					WHEN G3Q_DESTIN = '2' THEN 'I'
				END G3Q_DESTIN,
				A2_NOME, 
				G3Q_DOC,
				'U_SEGMENTOS("' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '")' SEGMENTOS,    // 01-Centro de Custo 
				CASE
					WHEN G3Q_TPSEG = '1' THEN 'U_RETCOLS("CLASSDIAS", "' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '", "' + G3S_CODPAX + '", "' + G3Q_GRPPRD + '")' 
					WHEN G3Q_TPSEG = '2' THEN 
						(SELECT LTRIM(STR(SUM(G3U_QTDDIA)))
					 	 FROM %Table:G3U% G3U
					 	 WHERE G3U_FILIAL = G3S_FILIAL AND 
			                   G3U_NUMID  = G3S_NUMID  AND 
			                   G3U_IDITEM = G3S_IDITEM AND 
			                   G3U_NUMSEQ = G3S_NUMSEQ AND 
			                   G3U_CODPAX = G3S_CODPAX AND 
		  	                   G3U_CONINU = '' AND
			                   G3U.%NotDel%)
					WHEN G3Q_TPSEG = '3' THEN 
						(SELECT LTRIM(STR(SUM(G3V_QTDDIA))) 
						 FROM %Table:G3V% G3V
						 WHERE G3V_FILIAL = G3S_FILIAL AND 
			                   G3V_NUMID  = G3S_NUMID  AND 
			                   G3V_IDITEM = G3S_IDITEM AND 
			                   G3V_NUMSEQ = G3S_NUMSEQ AND 
			                   G3V_CODPAX = G3S_CODPAX AND 
		  	                   G3V_CONINU = '' AND
			                   G3V.%NotDel%)
					WHEN G3Q_TPSEG = '4' THEN 
						(SELECT LTRIM(STR(SUM(DATEDIFF(dd, Convert(DateTime, G3W_DTINI, 103), Convert(DateTime, G3W_DTFIM, 103))))) 
						 FROM %Table:G3W% G3W
						 WHERE G3W_FILIAL = G3S_FILIAL AND 
			                   G3W_NUMID  = G3S_NUMID  AND 
			                   G3W_IDITEM = G3S_IDITEM AND 
			                   G3W_NUMSEQ = G3S_NUMSEQ AND 
			                   G3W_CODPAX = G3S_CODPAX AND 
		  	                   G3W_CONINU = '' AND
			                   G3W.%NotDel%)
					WHEN G3Q_TPSEG = '5' THEN 
						(SELECT LTRIM(STR(SUM(DATEDIFF(dd, Convert(DateTime, G3Y_DTINI, 103), Convert(DateTime, G3Y_DTFIM, 103))))) 
						 FROM %Table:G3Y% G3Y
						 WHERE G3Y_FILIAL = G3S_FILIAL AND 
			                   G3Y_NUMID  = G3S_NUMID  AND 
			                   G3Y_IDITEM = G3S_IDITEM AND 
			                   G3Y_NUMSEQ = G3S_NUMSEQ AND 
			                   G3Y_CODPAX = G3S_CODPAX AND 
		  	                   G3Y_CONINU = '' AND
			                   G3Y.%NotDel%)
					WHEN G3Q_TPSEG = '6' THEN 
						(SELECT LTRIM(STR(SUM(DATEDIFF(dd, Convert(DateTime, G3X_DTINI, 103), Convert(DateTime, G3X_DTFIM, 103))))) 
						 FROM %Table:G3X% G3X
						 WHERE G3X_FILIAL = G3S_FILIAL AND 
			                   G3X_NUMID  = G3S_NUMID  AND 
			                   G3X_IDITEM = G3S_IDITEM AND 
			                   G3X_NUMSEQ = G3S_NUMSEQ AND 
			                   G3X_CODPAX = G3S_CODPAX AND 
		  	                   G3X_CONINU = '' AND
			                   G3X.%NotDel%)
					WHEN G3Q_TPSEG = '7' THEN '1'
					WHEN G3Q_TPSEG = '8' THEN 
						(SELECT LTRIM(STR(SUM(DATEDIFF(dd, Convert(DateTime, G41_DTINI, 103), Convert(DateTime, G41_DTFIM, 103))))) 
					 	 FROM %Table:G41% G41
					 	 WHERE G41_FILIAL = G3S_FILIAL AND 
			               	   G41_NUMID  = G3S_NUMID  AND 
			                   G41_IDITEM = G3S_IDITEM AND 
			                   G41_NUMSEQ = G3S_NUMSEQ AND 
			                   G41_CODPAX = G3S_CODPAX AND 
		  	                   G41_CONINU = '' AND
			                   G41.%NotDel%)
					WHEN G3Q_TPSEG = '9' THEN 
						(SELECT LTRIM(STR(SUM(DATEDIFF(dd, Convert(DateTime, G40_DTINI, 103), Convert(DateTime, G40_DTFIM, 103))))) 
					 	 FROM %Table:G40% G40
					 	 WHERE G40_FILIAL = G3S_FILIAL AND 
			               	   G40_NUMID  = G3S_NUMID  AND 
			                   G40_IDITEM = G3S_IDITEM AND 
			                   G40_NUMSEQ = G3S_NUMSEQ AND 
			                   G40_CODPAX = G3S_CODPAX AND 
		  	                   G40_CONINU = '' AND
			                   G40.%NotDel%)
					WHEN G3Q_TPSEG = 'A' THEN 
						(SELECT LTRIM(STR(SUM(DATEDIFF(dd, Convert(DateTime, G3Z_DTINI, 103), Convert(DateTime, G3Z_DTFIM, 103))))) 
						 FROM %Table:G3Z% G3Z
						 WHERE G3Z_FILIAL = G3S_FILIAL AND 
			                   G3Z_NUMID  = G3S_NUMID  AND 
			                   G3Z_IDITEM = G3S_IDITEM AND 
			                   G3Z_NUMSEQ = G3S_NUMSEQ AND 
			                   G3Z_CODPAX = G3S_CODPAX AND 
		  	                   G3Z_CONINU = '' AND
			                   G3Z.%NotDel%)
					WHEN G3Q_TPSEG = 'B' THEN 
						(SELECT LTRIM(STR(SUM(G43_QTDDIA))) 
						 FROM %Table:G43% G43
						 WHERE G43_FILIAL = G3S_FILIAL AND 
			                   G43_NUMID  = G3S_NUMID  AND 
			                   G43_IDITEM = G3S_IDITEM AND 
			                   G43_NUMSEQ = G3S_NUMSEQ AND 
			                   G43_CODPAX = G3S_CODPAX AND 
		  	                   G43_CONINU = '' AND
			                   G43.%NotDel%)
				END CLASSDIAS,
				G3Q_EMISS,
				COALESCE(G3T_DTSAID, G3U_DTINI, G3V_DTINI, G3W_DTINI, G3X_DTINI, G3Y_DTINI, G3Z_DTINI, G40_DTINI, G41_DTINI, G43_DTINI) DTINI,
				COALESCE(G3T_DTCHEG, G3U_DTFIM, G3V_DTFIM, G3W_DTFIM, G3X_DTFIM, G3Y_DTFIM, G3Z_DTFIM, G40_DTFIM, G41_DTFIM, G43_DTFIM) DTFIM,
				G44_APLICA,
				(SELECT SUM(G46_VLTAXA) 
				 FROM %Table:G46% G46
				 WHERE G46_FILIAL = G3Q_FILIAL AND
				       G46_NUMID  = G3Q_NUMID  AND
					   G46_IDITEM = G3Q_IDITEM AND
					   G46_NUMSEQ = G3Q_NUMSEQ AND
					   G46_CONINU = '' AND
					   G46.%NotDel%) G46_VLTAXA,
				'U_RETG4B("' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '", "G4B_ITEM", "' + %Exp:aColFixas[1][1]% + '")' G4B_ITEM,    // 01-Centro de Custo 
				CASE 
					WHEN G3Q_NOMESO <> '' THEN G3Q_NOMESO ELSE 'U_RETG4B("' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '", "G4B_DESENT", "' + %Exp:aColFixas[2][1]% + '")'    // 80-Email do Solicitante
				END G4B_NOMESO,
				G3R_VLCOMI,
				G3R_TAXADU,
				G3Q_REPASS,
				(SELECT SUM(G48_VLACD)
				 FROM %Table:G48% G48A
				 WHERE G48_FILIAL = G3Q_FILIAL AND 
				       G48_NUMID  = G3Q_NUMID  AND 
				       G48_IDITEM = G3Q_IDITEM AND 
				       G48_NUMSEQ = G3Q_NUMSEQ AND 
				       G48_CODAPU = G6L_CODAPU AND 
				       G48_CLASS IN ('C01', 'C05', 'C06', 'C10', 'C12') AND 
				       G48_CONINU = '' AND 
				       G48A.%NotDel%) G3Q_TXTRAN,  
				CASE 
					WHEN G3R_IDCONF <> '' THEN G3R_IDCONF ELSE 'U_RETG4B("' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '", "G4B_DESENT", "' + %Exp:aColFixas[4][1]% + '")'    // 02-Autorização
				END G3R_IDCONF,
				(SELECT G5O_DESCR 
				 FROM %Table:G5O% G5O 
				 WHERE G5O_FILIAL = %xFilial:G5O% AND G5O_CODIGO = G3Q_TPEMIS AND G5O.%NotDel%) G3Q_TPEMIS,
				(G3Q_NUMID + '.' + G3Q_IDITEM + '.' + G3Q_NUMSEQ) G3Q_NUMDOC,
				'U_RETG4B("' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '", "G4B_DESENT", "' + %Exp:aColFixas[2][1]% + '")' G4B_MATRIC,    // 03-Matricula 
				'U_RETG4B("' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '", "G4B_DESENT", "' + %Exp:cG4BItens1% + '")' G4B_ITENS1,    
				'U_RETG4B("' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '", "G4B_DESENT", "' + %Exp:cG4BItens2% + '")' G4B_ITENS2,
				A1_CGC, 
				G4S_ABIATA,
				'U_RETG4B("' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '", "G4B_DESENT", "' + %Exp:aColFixas[1][1]% + '")' G4B_DSCCCT,    
				'U_RETG4D("' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '")' G4D_CARTAO,
				('') ADK_NOME,
				A1_NOME,
				G44_VLRDIA,
				COALESCE(G3T_TERORI, G3U_CIDHOT, G3V_CIDRET, G3W_CIDEMB, G3X_CIDEMB, G3Y_CIDEMB, G3Z_CIDEMB, G40_CIDEMB, G43_CIDEMB) EMBARQUE,
				COALESCE((SELECT TOP 1 G3T_TERDST
						  FROM %Table:G3T%
						  WHERE G3T_FILIAL = G3S_FILIAL AND 
						        G3T_NUMID  = G3S_NUMID  AND 
						        G3T_IDITEM = G3S_IDITEM AND 
						        G3T_NUMSEQ = G3S_NUMSEQ AND 
						        G3T_CODPAX = G3S_CODPAX AND 
								G3T_CONINU = '' AND
								G3T.%notDel% AND
						        G3T_ID = '01'), G3U_CIDHOT, G3V_CIDDEV, G3W_CIDDES, G3X_CIDDES, G3Y_CIDPRI, G3Z_CIDPRI, G40_CIDPRI, G43_CIDDES) DESEMBARQ,
				G44_TXCAMB,
				G44_TARBAS,
				G44_CHEIA,
				G44_MENOR,
				G44_PUBLIC,
				(SELECT COUNT(G3T_CODPAX)
				 FROM %Table:G3T% G3T
				 WHERE G3T_FILIAL = G3S_FILIAL AND
				       G3T_NUMID  = G3S_NUMID  AND
					   G3T_IDITEM = G3S_IDITEM AND
					   G3T_NUMSEQ = G3S_NUMSEQ AND
					   G3T_CODPAX = G3S_CODPAX AND
					   G3T_CONINU = '' AND
					   G3T.%NotDel%) G3T_PERNAS,
				G3R_VLINCE,
				'U_RETCOLS("AREA", "' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '", "' + G3S_CODPAX + '", "' + G3Q_GRPPRD + '")' G3Q_AREA,
				G3R_LOCGDS,
				CASE
					WHEN G3Q_TPDOC = '1' THEN 'VOUCHER'
					WHEN G3Q_TPDOC = '2' THEN 'BILHETE'
					WHEN G3Q_TPDOC = '3' THEN 'LOCALIZADOR'
					WHEN G3Q_TPDOC = '4' THEN 'DOC. ADICIONAL'
					WHEN G3Q_TPDOC = '5' THEN 'ADM'
					WHEN G3Q_TPDOC = '6' THEN 'ACM'
					WHEN G3Q_TPDOC = '7' THEN 'EMD'
					WHEN G3Q_TPDOC = '8' THEN 'MCO'
				END G3Q_TPDOC,
				CASE
					WHEN G3Q_TPSEG = '1' THEN 'U_RETSZA("' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '", "ZA_KMS")' ELSE '0'
				END G3Q_KMS,
				CASE
					WHEN G3Q_TPSEG = '1' THEN 'U_RETSZA("' + G3Q_FILIAL + '", "' + G3Q_NUMID + '", "' + G3Q_IDITEM + '", "' + G3Q_NUMSEQ + '", "ZA_MILHAS")' ELSE '0' 
				END G3Q_MILHAS,
				CASE
					WHEN G3Q_OPERAC = '1' THEN 'EMISSÃO'
					WHEN G3Q_OPERAC = '2' THEN 'REEMBOLSO'
					WHEN G3Q_OPERAC = '3' THEN 'REEMISSÃO'
					WHEN G3Q_OPERAC = '4' THEN 'SERVIÇO PRÓPRIO'
				END G3Q_OPERAC,
				(SELECT G5T_SIMBOL
				 FROM %Table:G5T% G5T
				 WHERE G5T_FILIAL = %xFilial:G5T% AND 
				       G5T_CODIGO = G44_MOEDFO AND
					   G5T.%NotDel%) G5T_SIMBOL
				%Exp:cColExtras%
			FROM %Table:G6L% G6L
			INNER JOIN %Table:G6M% G6M ON G6M_FILIAL = G6L_FILIAL AND 
			                              G6M_CODAPU = G6L_CODAPU AND 
			                              G6M.%NotDel%
			INNER JOIN %Table:G6O% G6O ON G6O_FILIAL = G6M_FILIAL AND 
			                              G6O_CODAPU = G6M_CODAPU AND 
			                              G6O_TIPOAC = G6M_TIPOAC AND
			                              G6O_SEGNEG = G6M_SEGNEG AND 
			                              G6O.%NotDel%
			INNER JOIN %Table:G48% G48 ON G48_FILAPU = G6O_FILIAL AND 
			                              G48_SEGNEG = G6O_SEGNEG AND 
			                              G48_CLASS  = G6M_TIPOAC AND 
			                              G48_CODACD = G6O_CODACD AND 
			                              G48_CODREC = G6O_CODREV AND 
			                              G48_CODAPU = G6O_CODAPU AND 
			                              G48_CLIFOR = '1' AND 
			                              G48_OK     = 'T' AND 
			                              G48_CONINU = ''  AND 
			                              G48.%NotDel%
			INNER JOIN %Table:G3Q% G3Q ON G3Q_FILIAL = G48_FILIAL AND 
			                              G3Q_NUMID  = G48_NUMID  AND 
			                              G3Q_IDITEM = G48_IDITEM AND 
			                              G3Q_NUMSEQ = G48_NUMSEQ AND
					                      G3Q_CONINU = '' AND
			                              G3Q.%NotDel%			
			INNER JOIN %Table:G3P% G3P ON G3P_FILIAL = G3Q_FILIAL AND 
			                              G3P_NUMID  = G3Q_NUMID  AND 
			                              G3P_SEGNEG = G6M_SEGNEG AND 
			                              G3P_CLIENT = G6L_CLIENT AND
					                      G3P_LOJA   = G6L_LOJA   AND 
			                              G3P.%NotDel%			
			INNER JOIN %Table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1% AND 
			                              A1_COD    = G3Q_CLIENT    AND 
			                              A1_LOJA   = G3Q_LOJA      AND
			                              SA1.%NotDel%
			INNER JOIN %Table:G3R% G3R ON G3R_FILIAL = G3Q_FILIAL AND 
			                              G3R_NUMID  = G3Q_NUMID  AND 
			                              G3R_IDITEM = G3Q_IDITEM AND 
			                              G3R_NUMSEQ = G3Q_NUMSEQ AND
					                      G3R_CONINU = '' AND
			                              G3R.%NotDel%			
			INNER JOIN %Table:SA2% SA2 ON A2_FILIAL = %xFilial:SA2% AND 
			                              A2_COD    = G3R_FORNEC    AND 
			                              A2_LOJA   = G3R_LOJA      AND
			                              SA2.%NotDel%
			LEFT JOIN %Table:G44% G44 ON G44_FILIAL = G3Q_FILIAL AND
					                     G44_NUMID  = G3Q_NUMID  AND
					                     G44_IDITEM = G3Q_IDITEM AND
					                     G44_NUMSEQ = G3Q_NUMSEQ AND
					                     G44_CONINU = '' AND
					                     G44.%NotDel%
		  	LEFT JOIN %Table:G4S% G4S ON G4S_FILIAL = %xFilial:G4S% AND 
		  	                             G4S_FORNEC = G3R_FORNEC    AND 
		  	                             G4S_LOJA   = G3R_LOJA      AND 
		  	                             G4S.%NotDel%
		  	LEFT JOIN %Table:G3S% G3S ON G3S_FILIAL = G3Q_FILIAL AND 
		  	                             G3S_NUMID  = G3Q_NUMID  AND 
		  	                             G3S_IDITEM = G3Q_IDITEM AND 
		  	                             G3S_NUMSEQ = G3Q_NUMSEQ AND
		  	                             G3S_CONINU = '' AND
										 G3S_CODPAX = '00001' AND
		  	                             G3S.%NotDel%
		  	LEFT JOIN %Table:G3T% G3T ON G3T_FILIAL = G3S_FILIAL AND 
		  	                             G3T_NUMID  = G3S_NUMID  AND 
		  	                             G3T_IDITEM = G3S_IDITEM AND 
		  	                             G3T_NUMSEQ = G3S_NUMSEQ AND
		  	                             G3T_CODPAX = G3S_CODPAX AND
		  	                             G3T_CONINU = '' AND
		  	                             G3T_ID = '01' AND 
		  	                             G3T.%NotDel%
		  	LEFT JOIN %Table:G3U% G3U ON G3U_FILIAL = G3S_FILIAL AND 
		  	                             G3U_NUMID  = G3S_NUMID  AND 
		  	                             G3U_IDITEM = G3S_IDITEM AND 
		  	                             G3U_NUMSEQ = G3S_NUMSEQ AND
		  	                             G3U_CODPAX = G3S_CODPAX AND 
		  	                             G3U_CONINU = '' AND
		  	                             G3U_ID = '01' AND 
		  	                             G3U.%NotDel%
			LEFT JOIN %Table:G3V% G3V ON G3V_FILIAL = G3S_FILIAL AND 
			                             G3V_NUMID  = G3S_NUMID  AND 
			                             G3V_IDITEM = G3S_IDITEM AND 
			                             G3V_NUMSEQ = G3S_NUMSEQ AND
			                             G3V_CODPAX = G3S_CODPAX AND 
			                             G3V_CONINU = '' AND 
		  	                             G3V_ID = '01' AND 
			                             G3V.%NotDel%
			LEFT JOIN %Table:G3W% G3W ON G3W_FILIAL = G3S_FILIAL AND 
			                             G3W_NUMID  = G3S_NUMID  AND 
			                             G3W_IDITEM = G3S_IDITEM AND 
			                             G3W_NUMSEQ = G3S_NUMSEQ AND 
			                             G3W_CODPAX = G3S_CODPAX AND
		  	                             G3W_ID = '01' AND 
			                             G3W_CONINU = '' AND
			                             G3W.%NotDel% 
			LEFT JOIN %Table:G3X% G3X ON G3X_FILIAL = G3S_FILIAL AND 
			                             G3X_NUMID  = G3S_NUMID  AND 
			                             G3X_IDITEM = G3S_IDITEM AND 
			                             G3X_NUMSEQ = G3S_NUMSEQ AND
			                             G3X_CODPAX = G3S_CODPAX AND
			                             G3X_CONINU = '' AND 
		  	                             G3X_ID = '01' AND 
			                             G3X.%NotDel% 
			LEFT JOIN %Table:G3Y% G3Y ON G3Y_FILIAL = G3S_FILIAL AND 
			                             G3Y_NUMID  = G3S_NUMID  AND 
			                             G3Y_IDITEM = G3S_IDITEM AND 
			                             G3Y_NUMSEQ = G3S_NUMSEQ AND 
			                             G3Y_CODPAX = G3S_CODPAX AND
			                             G3Y_CONINU = '' AND 
		  	                             G3Y_ID = '01' AND 
			                             G3Y.%NotDel%
			LEFT JOIN %Table:G3Z% G3Z ON G3Z_FILIAL = G3S_FILIAL AND 
			                             G3Z_NUMID  = G3S_NUMID  AND 
			                             G3Z_IDITEM = G3S_IDITEM AND 
			                             G3Z_NUMSEQ = G3S_NUMSEQ AND
			                             G3Z_CODPAX = G3S_CODPAX AND 
			                             G3Z_CONINU = '' AND
		  	                             G3Z_ID = '01' AND 
			                             G3Z.%NotDel% 
			LEFT JOIN %Table:G40% G40 ON G40_FILIAL = G3S_FILIAL AND 
			                             G40_NUMID  = G3S_NUMID  AND 
			                             G40_IDITEM = G3S_IDITEM AND 
			                             G40_NUMSEQ = G3S_NUMSEQ AND
			                             G40_CODPAX = G3S_CODPAX AND 
			                             G40_CONINU = '' AND
		  	                             G40_ID = '01' AND 
			                             G40.%NotDel% 
			LEFT JOIN %Table:G41% G41 ON G41_FILIAL = G3S_FILIAL AND 
										 G41_NUMID  = G3S_NUMID  AND 
										 G41_IDITEM = G3S_IDITEM AND 
										 G41_NUMSEQ = G3S_NUMSEQ AND
										 G41_CODPAX = G3S_CODPAX AND 
										 G41_CONINU = '' AND
		  	                             G41_ID = '01' AND 
			                             G41.%NotDel% 
			LEFT JOIN %Table:G43% G43 ON G43_FILIAL = G3S_FILIAL AND 
			                             G43_NUMID  = G3S_NUMID  AND 
			                             G43_IDITEM = G3S_IDITEM AND 
			                             G43_NUMSEQ = G3S_NUMSEQ AND
			                             G43_CODPAX = G3S_CODPAX AND 
			                             G43_CONINU = '' AND
		  	                             G43_ID = '01' AND 
			                             G43.%NotDel% 
			WHERE
				G6L_FILIAL = %xFilial:G6L%
				AND G6L_TPAPUR = '1'
				AND G6L_DTGERA BETWEEN %Exp:dDataDe% AND %Exp:dDataAte%
				AND G6M_TIPOAC IN ('C01', 'C04', 'C05', 'C06', 'C07', 'C10', 'C12')
				AND G3Q_GRPPRD BETWEEN %Exp:cGrpProdDe% AND %Exp:cGrpProdAte% 
				AND G6L.%NotDel%
				%Exp:cWhere%) TMP
		ORDER BY A1_COD, A1_LOJA, G3Q_GRPPRD, G3Q_DESTIN, G3Q_NUMDOC
	EndSQL
oSecTrans:EndQuery()

If (cAliasG6L)->(!Eof())
	nTotReg := (cAliasG6L)->(ScopeCount())
	(cAliasG6L)->(DbGoTop())
	oSecTrans:Init()
	oSecTranLin:Init()
	While (cAliasG6L)->(!Eof())
		For nX := 1 To Len(aColunas)
			xConteudo := ''
			If ValType((cAliasG6L)->&(aColunas[nX][1])) == 'C'
				If (nPos := At(')', (cAliasG6L)->&(aColunas[nX][1]))) > 0
					xConteudo := SubStr((cAliasG6L)->&(aColunas[nX][1]), 1, nPos)
					If (FindFunction(xConteudo))
						xConteudo := AllTrim(&(xConteudo))
					Endif
				Else
					If (aColunas[nX][1] == 'EMBARQUE' .Or. aColunas[nX][1] == 'DESEMBARQ') .And. Posicione('SBM', 1, xFilial('SBM') + (cAliasG6L)->G3Q_GRPPRD, 'BM_TPSEGP') == '1'
						xConteudo := AllTrim(Posicione('G5S', 1, xFilial('G5S') + AllTrim(Posicione('G3B', 2, xFilial('G3B') + AllTrim((cAliasG6L)->&(aColunas[nX][1])), 'G3B_CODMUN')), 'G5S_CIDADE'))
					Else					
						xConteudo := AllTrim((cAliasG6L)->&(aColunas[nX][1]))
					EndIf
				Endif
			Else
				xConteudo := (cAliasG6L)->&(aColunas[nX][1])
			Endif

			oSecTranLin:Cell(aColunas[nX][1]):SetValue(xConteudo)
		Next nX
		oSecTranLin:PrintLine()
		(cAliasG6L)->(DbSkip()) 
		nCount++
		If lAtuMsg 
			ALARAtuMsg(oMsgRun, @nPercAtu, nCount, nTotReg, nTipo, cNome)
		EndIf			
	EndDo
	oSecTranLin:Finish()
	oSecTrans:Finish()
EndIf

(cAliasG6L)->(DbCloseArea())
RestArea(aArea)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AR001AENT

Função que irá retorna informações para as colunas ROTA/CIDADE e CLASSES/DIÁRIAS

@sample 	AR001AENT(cCliCod, cLoja, lCorp, lEventos, lLazer)
@param 		cCliCod - String - código do cliente
			cLoja - String - loja do cliente, será informado quando a quebra por loja for selecionada
			lCorp - Lógico - indica se é para gerar o relatório para o segmento de negócio Corporativo     
			lEvento - Lógico - indica se é para gerar o relatório para o segmento de negócio Evento     
			lLazer - Lógico - indica se é para gerar o relatório para o segmento de negócio Lazer
@author    	Thiago Tavares
@since		24/09/2016
@version	P12.1.13
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AR001AENT(cCliCod, cLoja, lCorp, lEventos, lLazer)

Local aArea      := GetArea()
Local cAliasAux  := GetNextAlias()
Local aEntidades := {}
Local cColuna    := ''
Local cExtras    := '4'
Local nPos       := 0

BeginSQL Alias cAliasAux
	SELECT G3F_LOJA, G3F_TIPO, G3E_DESCR, G3F_COMPAR  
  	FROM %Table:G3F% G3F
  	INNER JOIN %Table:G3E% G3E ON G3E_FILIAL = G3F_FILIAL AND
  									  G3E_CODIGO = G3F_TIPO   AND
  									  G3E.%Notdel%
  	WHERE G3F_FILIAL = %xFilial:G3F% AND
  	      G3F_CODCLI = %Exp:cCliCod% AND
	      G3F.%NotDel%
	ORDER BY G3F_TIPO 
EndSQL

While (cAliasAux)->(!Eof())
	If Empty(cLoja) .Or. (cAliasAux)->G3F_LOJA == cLoja .Or. (cAliasAux)->G3F_COMPAR == '1'
		If aScan(aEntidades, {|x| x[1] == (cAliasAux)->G3F_TIPO}) == 0
			If (nPos := aScan(aColFixas, {|x| x[1] == (cAliasAux)->G3F_TIPO})) > 0   
				cColuna := aColFixas[nPos][2] 
			Else
				cColuna := cExtras := Soma1(cExtras)
			EndIf
			 
			aAdd(aEntidades, {(cAliasAux)->G3F_TIPO, AllTrim((cAliasAux)->G3E_DESCR), cColuna})
		EndIf
	EndIf
	(cAliasAux)->(DbSkip())
EndDo

(cAliasAux)->(DbCloseArea())
RestArea(aArea)

Return aEntidades

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RETCOLS

Função que irá retorna informações para as colunas ROTA/CIDADE e CLASSES/DIÁRIAS

@sample 	RETCOLS(cCampo, cFilRV, cNumID, cIdItem, cNumSeq, cCodPax, cGrpProd)
@param 		cCampo - String - Nome do campo referente a coluna do relatório
			cFilRV - String - Código da Filial do Registro de Venda
			cNumID - String - Código do Registro de Venda
			cIdItem - String - Código do Item de Venda
			cNumSeq - String - Código da sequencia do Item de Venda
			cCodPax - String - Código do passageiro
			cGrpProd - Código do Grupo de Produto
@author    	Thiago Tavares
@since		24/09/2016
@version	P12.1.13
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function RETCOLS(cCampo, cFilRV, cNumID, cIdItem, cNumSeq, cCodPax, cGrpProd)

Local aArea      := GetArea()
Local cAliasAux  := GetNextAlias()
Local nPos       := 0
Local nLinha     := 1
Local cTpSeg     := Posicione('SBM', 1, xFilial('SBM') + cGrpProd, 'BM_TPSEGP')
Local cCodZV     := ''
Local cRet       := ''
Local cDestino   := ''
Local cTpBilhete := ''	// 1-Só Ida / 2-Ida e Volta
Local aAeroporto := {}
Local aSegmentos := {{'1', '% G3T_TERORI, G3T_TERDST %', '% G3T_CLASRV %'}, ;		// AEREO
					 {'2', '% G3R_FORNEC, G3R_LOJA   %', '% SUM(G3U_QTDDIA) QTDDIA %'}, ;		// HOTEL
					 {'3', '% G3V_CIDDEV COD_CIDADE  %', '% SUM(G3V_QTDDIA) QTDDIA %'}, ;		// CARRO
					 {'4', '% G3W_CIDDES COD_CIDADE  %', '% SUM(DATEDIFF(dd, Convert(DateTime, G3W_DTINI, 103), Convert(DateTime, G3W_DTFIM, 103))) QTDDIA %'}, ;		// RODOVIÁRIO		
					 {'5', '% G3Y_CIDPRI COD_CIDADE  %', '% SUM(DATEDIFF(dd, Convert(DateTime, G3Y_DTINI, 103), Convert(DateTime, G3Y_DTFIM, 103))) QTDDIA %'}, ;		// CRUZEIRO
					 {'6', '% G3X_CIDDES COD_CIDADE  %', '% SUM(DATEDIFF(dd, Convert(DateTime, G3X_DTINI, 103), Convert(DateTime, G3X_DTFIM, 103))) QTDDIA %'}, ;		// TREM
					 {'7', '% G3R_FORNEC, G3R_LOJA   %', '% SUM(1) QTDDIA %'}, ;		// VISTO
					 {'8', '% G3R_FORNEC, G3R_LOJA   %', '% SUM(DATEDIFF(dd, Convert(DateTime, G41_DTINI, 103), Convert(DateTime, G41_DTFIM, 103))) QTDDIA %'}, ;		// SEGURO
					 {'9', '% G40_CIDPRI COD_CIDADE  %', '% SUM(DATEDIFF(dd, Convert(DateTime, G40_DTINI, 103), Convert(DateTime, G40_DTFIM, 103))) QTDDIA %'}, ;		// TOUR
					 {'A', '% G3Z_CIDPRI COD_CIDADE  %', '% SUM(DATEDIFF(dd, Convert(DateTime, G3Z_DTINI, 103), Convert(DateTime, G3Z_DTFIM, 103))) QTDDIA %'}, ;		// PACOTE
					 {'B', '% G43_CIDDES COD_CIDADE  %', '% SUM(G43_QTDDIA) QTDDIA %'}}			// OUTROS

// SEGMENTO AEREO 
If cTpSeg == '1'
	BeginSQL Alias cAliasAux
		SELECT G3Q_DESTIN, %Exp:IIF(cCampo == 'SEGMENTOS' .Or. cCampo == 'AREA', aSegmentos[1][2], aSegmentos[1][3])%
	  	FROM %Table:G3S% G3S
		INNER JOIN %Table:G3Q% G3Q ON G3Q_FILIAL = G3S_FILIAL AND 
		                              G3Q_NUMID  = G3S_NUMID  AND 
		                              G3Q_IDITEM = G3S_IDITEM AND 
		                              G3Q_NUMSEQ = G3S_NUMSEQ AND 
		                              G3Q_CONINU = ''         AND
		                              G3Q.%NotDel% 
		LEFT JOIN %Table:G3T% G3T ON G3T_FILIAL = G3S_FILIAL AND 
		                             G3T_NUMID  = G3S_NUMID  AND 
		                             G3T_IDITEM = G3S_IDITEM AND 
		                             G3T_NUMSEQ = G3S_NUMSEQ AND 
		                             G3T_CODPAX = G3S_CODPAX AND 
	  	                             G3T_CONINU = ''         AND
		                             G3T.%NotDel% 
	  	WHERE G3S_FILIAL = %Exp:cFilRV%  AND
		      G3S_NUMID  = %Exp:cNumID%  AND 
		      G3S_IDITEM = %Exp:cIdItem% AND 
		      G3S_NUMSEQ = %Exp:cNumSeq% AND 
		      G3S_CODPAX = %Exp:cCodPax% AND 
		      G3S_CONINU = ''            AND
		      G3S.%NotDel%
	EndSQL
	
	Do Case 
		Case cCampo == 'SEGMENTOS'
			While (cAliasAux)->(!Eof())
				If nLinha == 1
					cRet += AllTrim(Posicione('G5S', 1, xFilial('G5S') + AllTrim(Posicione('G3B', 2, xFilial('G3B') + (cAliasAux)->G3T_TERORI, 'G3B_CODMUN')), 'G5S_IATA')) + '(' + AllTrim((cAliasAux)->G3T_TERORI) + ')/'
					cRet += AllTrim(Posicione('G5S', 1, xFilial('G5S') + AllTrim(Posicione('G3B', 2, xFilial('G3B') + (cAliasAux)->G3T_TERDST, 'G3B_CODMUN')), 'G5S_IATA')) + '(' + AllTrim((cAliasAux)->G3T_TERDST) + ')'  
				Else
					cRet += '/' + AllTrim(Posicione('G5S', 1, xFilial('G5S') + AllTrim(Posicione('G3B', 2, xFilial('G3B') + (cAliasAux)->G3T_TERDST, 'G3B_CODMUN')), 'G5S_IATA')) + '(' + AllTrim((cAliasAux)->G3T_TERDST) + ')'  
				EndIf
				nLinha++
				(cAliasAux)->(DbSkip())
			EndDo

		Case cCampo == "CLASSDIAS"
			While (cAliasAux)->(!Eof())
				cRet += AllTrim((cAliasAux)->G3T_CLASRV)
				(cAliasAux)->(DbSkip())
				If (cAliasAux)->(!Eof())
					cRet += '/' 
				EndIf
			EndDo

		Case cCampo == "AREA"
			// guardando a quantidade de segmentos
			nSegmentos := (cAliasAux)->(ScopeCount())
			(cAliasAux)->(DbGoTop())

			// preenchendo o array com os aeroportos dos segmentos
			While (cAliasAux)->(!Eof())
				cPaisOri  := AllTrim(Posicione('G3B', 2, xFilial('G3B') + (cAliasAux)->G3T_TERORI, 'G3B_PAIS'))
				cPaisDst  := AllTrim(Posicione('G3B', 2, xFilial('G3B') + (cAliasAux)->G3T_TERDST, 'G3B_PAIS'))
				
				aAdd(aAeroporto, {(cAliasAux)->G3T_TERORI, cPaisOri, (cAliasAux)->G3T_TERDST, cPaisDst})

				(cAliasAux)->(DbSkip())
			EndDo

			// determinando se o bilhete é 1-SÓ IDA ou 2-IDA E VOLTA
			// Se o bilhete tem 1 segmento é considerado 1-SÓ IDA
			// Se o bilhete tem mais de 4 segmentos, é considerado 2-IDA E VOLTA

			// Se o bilhete tem de 2 até 4 segmentos, para definir se é 1-SÓ IDA ou 2-IDA E VOLTA precisa passar pela análise abaixo.
			// Como definir se é 1-SÓ IDA:
			//	- Se o bilhete é nacional e o aeroporto de partida do 1o. segmento é DIFERENTE do aeroporto de chegada do último segmento. Ex.: Seg.1: GRU/REC, Seg.2: REC/SDU, aqui ele partiu de Guarulhos e foi para o Rio.
			//	- Se o bilhete é internacional e o país do aeroporto de partida do primeiro segmento é DIFERENTE ao país do aeroporto de chegada do último segmento. Ex.: Seg.1 GRU/CWB, Seg.2: CWB/BUE, aqui ele partiu de Guarulhos (Brasil) e terminou em para Buenos Aires (Argentina).

			// Como definir se é 2-IDA E VOLTA:
			//	- Se o bilhete é nacional e o aeroporto de partida do 1o. segmento é IGUAL do aeroporto de chegada do último segmento. Ex.: Seg.1: GRU/REC, Seg.2: REC/GRU, aqui ele partiu de Guarulhos e voltou para Guarulhos.
			// - Se o bilhete é internacional e o país do aeroporto de partida do primeiro segmento é IGUAL ao país do aeroporto de destino do último segmento. Ex.: Seg.1 GRU/MIA, Seg.2: MIA/SDU, aqui ele partiu de Guarulhos (Brasil) e terminou no Rio de Janeiro (Brasil).
			Do Case			
				Case nSegmentos = 1
					cTpBilhete := '1'

				Case nSegmentos > 4 		
					cTpBilhete := '2'

				Case nSegmentos >= 2 .And. nSegmentos <= 4
					If cDestino == '1'			// NACIONAL (valida os aeroportos - aAeroporto[?][1] e aAeroporto[?][3])
						If aAeroporto[1][1] != aAeroporto[Len(aAeroporto)][3]
							cTpBilhete := '1' 
						ElseIf aAeroporto[1][1] == aAeroporto[Len(aAeroporto)][3]
							cTpBilhete := '2'
						EndIf
					ElseIf cDestino == '2'		// INTERNACIONAL (valida os países - aAeroporto[?][2] e aAeroporto[?][4])
						If aAeroporto[1][2] != aAeroporto[Len(aAeroporto)][4]
							cTpBilhete := '1'
						ElseIf aAeroporto[1][2] == aAeroporto[Len(aAeroporto)][4]
							cTpBilhete := '2'
						EndIf
					EndIf
			EndCase
			
			// retornando a valor do campo AREA
			// Viagens 1-SÓ IDA
			//	- Sempre será o país da cidade do aeroporto de destino do último segmento
			
			// Viagens 2-IDA E VOLTA
			// Se tem 2 Segmentos:
			//	- é o país da cidade do aeroporto de destino do 1o. segmento

			// Se tem 3 ou 4 segmentos:
			//	- é o país da cidade do aeroporto de destino do 2o. segmento

			// Se tem 5 ou 6 segmentos
			//	- é o país da cidade do aeroporto de destino do 3o. segmento

			// Se tem 7 ou 8 segmentos
			//	- é o país da cidade do aeroporto de destino do 3o. segmento

			// Se tem 9 ou 10 segmentos
			//	- é o país da cidade do aeroporto de destino do 4o. segmento

			// Se tem mais de segmentos
			//	- é o país da cidade do aeroporto de destino do 5o. segmento

			If cTpBilhete == '1' 	// SÓ IDA
				cCodZV := Posicione('SYA', 1, xFilial('SYA') + aAeroporto[Len(aAeroporto)][4], 'YA_XCONT')
			Else						// IDA e VOLTA
				Do Case
					Case nSegmentos == 2
						cCodZV := Posicione('SYA', 1, xFilial('SYA') + aAeroporto[1][3], 'YA_XCONT')
						
					Case nSegmentos == 3 .Or. nSegmentos == 4
						cCodZV := Posicione('SYA', 1, xFilial('SYA') + aAeroporto[2][3], 'YA_XCONT')
						
					Case nSegmentos == 5 .Or. nSegmentos == 6 .Or. nSegmentos == 7 .Or. nSegmentos == 8
						cCodZV := Posicione('SYA', 1, xFilial('SYA') + aAeroporto[3][3], 'YA_XCONT')
						
					Case nSegmentos == 9 .Or. nSegmentos == 10
						cCodZV := Posicione('SYA', 1, xFilial('SYA') + aAeroporto[4][3], 'YA_XCONT')
						
					Case nSegmentos > 10
						cCodZV := Posicione('SYA', 1, xFilial('SYA') + aAeroporto[5][3], 'YA_XCONT')
				EndCase
			EndIf
			
			cRet := AllTrim(Posicione('SX5', 1, xFilial('SX5') + "ZV" + cCodZV, 'X5_DESCRI'))
	EndCase

// DEMAIS SEGMENTOS 	 
ElseIf cTpSeg != '1' .And. (nPos := aScan(aSegmentos, {|x| x[1] == cTpSeg})) > 0
	BeginSQL Alias cAliasAux
		SELECT %Exp:IIF(cCampo == 'SEGMENTOS' .Or. cCampo == 'AREA', aSegmentos[nPos][2], aSegmentos[nPos][3])%
	  	FROM %Table:G3R% G3R
	  	INNER JOIN %Table:G3S% G3S ON G3S_FILIAL = G3R_FILIAL AND 
	  	                              G3S_NUMID  = G3R_NUMID  AND 
	  	                              G3S_IDITEM = G3R_IDITEM AND 
	  	                              G3S_NUMSEQ = G3R_NUMSEQ AND 
	  	                              G3S_CONINU = ''         AND
	  	                              G3S.%NotDel%
	  	LEFT JOIN %Table:G3U% G3U ON G3U_FILIAL = G3S_FILIAL AND 
	  	                             G3U_NUMID  = G3S_NUMID  AND 
	  	                             G3U_IDITEM = G3S_IDITEM AND 
	  	                             G3U_NUMSEQ = G3S_NUMSEQ AND 
	  	                             G3U_CODPAX = G3S_CODPAX AND 
	  	                             G3U_CONINU = ''         AND
	  	                             G3U.%NotDel%
		LEFT JOIN %Table:G3V% G3V ON G3V_FILIAL = G3S_FILIAL AND 
		                             G3V_NUMID  = G3S_NUMID  AND 
		                             G3V_IDITEM = G3S_IDITEM AND 
		                             G3V_NUMSEQ = G3S_NUMSEQ AND 
		                             G3V_CODPAX = G3S_CODPAX AND 
	  	                             G3V_CONINU = ''         AND 
		                             G3V.%NotDel%
		LEFT JOIN %Table:G3W% G3W ON G3W_FILIAL = G3S_FILIAL AND 
		                             G3W_NUMID  = G3S_NUMID  AND 
		                             G3W_IDITEM = G3S_IDITEM AND 
		                             G3W_NUMSEQ = G3S_NUMSEQ AND 
		                             G3W_CODPAX = G3S_CODPAX AND 
	  	                             G3W_CONINU = ''         AND
		                             G3W.%NotDel% 
		LEFT JOIN %Table:G3X% G3X ON G3X_FILIAL = G3S_FILIAL AND 
		                             G3X_NUMID  = G3S_NUMID  AND 
		                             G3X_IDITEM = G3S_IDITEM AND 
		                             G3X_NUMSEQ = G3S_NUMSEQ AND
		                             G3X_CODPAX = G3S_CODPAX AND 
	  	                             G3X_CONINU = ''         AND 
		                             G3X.%NotDel% 
		LEFT JOIN %Table:G3Y% G3Y ON G3Y_FILIAL = G3S_FILIAL AND 
		                             G3Y_NUMID  = G3S_NUMID  AND 
		                             G3Y_IDITEM = G3S_IDITEM AND 
		                             G3Y_NUMSEQ = G3S_NUMSEQ AND 
		                             G3Y_CODPAX = G3S_CODPAX AND 
	  	                             G3Y_CONINU = ''         AND 
		                             G3Y.%NotDel%
		LEFT JOIN %Table:G3Z% G3Z ON G3Z_FILIAL = G3S_FILIAL AND 
		                             G3Z_NUMID  = G3S_NUMID  AND 
		                             G3Z_IDITEM = G3S_IDITEM AND 
		                             G3Z_NUMSEQ = G3S_NUMSEQ AND 
		                             G3Z_CODPAX = G3S_CODPAX AND 
	  	                             G3Z_CONINU = ''         AND
		                             G3Z.%NotDel% 
		LEFT JOIN %Table:G40% G40 ON G40_FILIAL = G3S_FILIAL AND 
		                             G40_NUMID  = G3S_NUMID  AND 
		                             G40_IDITEM = G3S_IDITEM AND 
		                             G40_NUMSEQ = G3S_NUMSEQ AND 
		                             G40_CODPAX = G3S_CODPAX AND 
	  	                             G40_CONINU = ''         AND
		                             G40.%NotDel% 
		LEFT JOIN %Table:G41% G41 ON G41_FILIAL = G3S_FILIAL AND 
									 G41_NUMID  = G3S_NUMID  AND 
									 G41_IDITEM = G3S_IDITEM AND 
									 G41_NUMSEQ = G3S_NUMSEQ AND 
									 G41_CODPAX = G3S_CODPAX AND 
	  	                             G41_CONINU = ''         AND
		                             G41.%NotDel% 
		LEFT JOIN %Table:G42% G42 ON G42_FILIAL = G3S_FILIAL AND 
									 G42_NUMID  = G3S_NUMID  AND 
									 G42_IDITEM = G3S_IDITEM AND 
									 G42_NUMSEQ = G3S_NUMSEQ AND 
									 G42_CODPAX = G3S_CODPAX AND 
	  	                             G42_CONINU = ''         AND
		                             G42.%NotDel% 
		LEFT JOIN %Table:G43% G43 ON G43_FILIAL = G3S_FILIAL AND 
		                             G43_NUMID  = G3S_NUMID  AND 
		                             G43_IDITEM = G3S_IDITEM AND 
		                             G43_NUMSEQ = G3S_NUMSEQ AND 
		                             G43_CODPAX = G3S_CODPAX AND 
	  	                             G43_CONINU = ''         AND
		                             G43.%NotDel% 
	  	WHERE G3R_FILIAL = %Exp:cFilRV%  AND
		      G3R_NUMID  = %Exp:cNumID%  AND 
		      G3R_IDITEM = %Exp:cIdItem% AND 
		      G3R_NUMSEQ = %Exp:cNumSeq% AND 
		      G3R_CONINU = ''            AND
		      G3S_CODPAX = %Exp:cCodPax% AND 
		      G3R.%NotDel%
	EndSQL
	
	If (cAliasAux)->(!Eof())
		Do Case
			Case cCampo == 'SEGMENTOS'
				If cTpSeg $ '2|7|8'
					cRet := Posicione('CC2', 3, xFilial('CC2') + Posicione('SA2', 1, xFilial('SA2') + (cAliasAux)->G3R_FORNEC + (cAliasAux)->G3R_LOJA, 'A2_COD_MUN'), 'CC2_MUN') 
				Else
					cRet := Posicione('G3B', 2, xFilial('G3B') + (cAliasAux)->COD_CIDADE, 'G3B_DESCR')
				EndIf

			Case cCampo == "CLASSDIAS"
				cRet := AllTrim(Str((cAliasAux)->QTDDIA)) 

			Case cCampo == "AREA"
				Do Case
					Case cTpSeg $ '2|7'
						cCodZV := Posicione('SYA', 1, xFilial('SYA') + Posicione('SA2', 1, xFilial('SA2') + (cAliasAux)->G3R_FORNEC + (cAliasAux)->G3R_LOJA, 'A2_PAIS'), 'YA_XCONT') 
				
					Case cTpSeg == '8'
						cCodZV := ''
				
					Otherwise
						cCodZV := Posicione('SYA', 1, xFilial('SYA') + Posicione('G5S', 1, xFilial('G5S') + (cAliasAux)->COD_CIDADE, 'G5S_PAIS'), 'YA_XCONT') 
				EndCase
				
				If !Empty(cCodZV)
					cRet := Posicione('SX5', 1, xFilial('SX5') + "ZV" + cCodZV, 'X5_DESCRI')
				EndIf

		EndCase
	EndIf
EndIf 

(cAliasAux)->(DbCloseArea())
RestArea(aArea)

Return cRet 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RETG4D

Função que irá retornar informações para a coluna BANDEIRA/CARTAO 

@sample 	RETG4D(cFilRV, cNumID, cIdItem, cNumSeq)
@param 		cFilRV  - String - Código da Filial do Registro de Venda
			cNumID  - String - Código do Registro de Venda
			cIdItem - String - Código do Item de Venda
			cNumSeq - String - Código da sequencia do Item de Venda
@author    Thiago Tavares
@since		26/09/2016
@version	P12.1.13
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function RETG4D(cFilRV, cNumID, cIdItem, cNumSeq)

Local aArea      := GetArea()
Local cAliasAux  := GetNextAlias()
Local nPos       := 0
Local cRet       := ''
Local cSigla     := ''

BeginSQL Alias cAliasAux
	SELECT G4D_CODBAN, G4D_NUMCAR
  	FROM %Table:G4D% G4D
  	WHERE G4D_FILIAL = %Exp:cFilRV%  AND
	      G4D_NUMID  = %Exp:cNumID%  AND 
	      G4D_IDITEM = %Exp:cIdItem% AND 
	      G4D_NUMSEQ = %Exp:cNumSeq% AND 
	      G4D_CONINU = ''            AND
	      G4D.%NotDel%
EndSQL

While (cAliasAux)->(!Eof())
	cRet += IIF(!Empty((cSigla := AllTrim(Posicione('G6K', 1, xFilial('G6K') + '000006' + (cAliasAux)->G4D_CODBAN, 'G6K_CDPARA')))), cSigla, (cAliasAux)->G4D_CODBAN) + '-' + (cAliasAux)->G4D_NUMCAR 
	(cAliasAux)->(DbSkip())
	If (cAliasAux)->(!Eof())
		cRet += '/' 
	EndIf
EndDo 

(cAliasAux)->(DbCloseArea())
RestArea(aArea)

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RETG4B

Função que irá retornar informações para as colunas de Entidades Adicionais

@sample 	RETG4B(cFilRV, cNumID, cIdItem, cNumSeq)
@param 		cFilRV  - String - Código da Filial do Registro de Venda
			cNumID  - String - Código do Registro de Venda
			cIdItem - String - Código do Item de Venda
			cNumSeq - String - Código da sequencia do Item de Venda
@author    	Thiago Tavares
@since		24/07/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function RETG4B(cFilRV, cNumID, cIdItem, cNumSeq, cCampo, cTpEnt)

Local aArea      := GetArea()
Local cAliasAux  := GetNextAlias()
Local cRet       := ''
Local cExpCampo  := '%' + cCampo + '%'

BeginSQL Alias cAliasAux
	SELECT TOP 1 %Exp:cExpCampo%
	FROM %Table:G4B% G4B
	WHERE G4B_FILIAL = %Exp:cFilRV% AND 
	      G4B_NUMID  = %Exp:cNumId% AND 
		  G4B_IDITEM = %Exp:cIdItem% AND 
		  G4B_NUMSEQ = %Exp:cNumSeq% AND 
		  G4B_CODPAX = '00001' AND 
		  G4B_TPENT  = %Exp:cTpEnt% AND		 
		  G4B.%NotDel%
EndSQL

If (cAliasAux)->(!Eof())
	cRet := (cAliasAux)->&(cCampo)
EndIf 

(cAliasAux)->(DbCloseArea())
RestArea(aArea)

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RETSZA

Função que irá retornar a distância entre aeroportos

@sample 	RETSZA(cFilRV, cNumID, cIdItem, cNumSeq)
@param 		cFilRV  - String - Código da Filial do Registro de Venda
			cNumID  - String - Código do Registro de Venda
			cIdItem - String - Código do Item de Venda
			cNumSeq - String - Código da sequencia do Item de Venda
@author    	Thiago Tavares
@since		24/07/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function RETSZA(cFilRV, cNumID, cIdItem, cNumSeq, cCampo)

Local aArea      := GetArea()
Local cAliasAux  := GetNextAlias()
Local nRet       := 0
Local cExpCampo  := '%' + cCampo + '%'

BeginSQL Alias cAliasAux
	SELECT SUM(%Exp:cExpCampo%) AS DISTANCIA
	FROM %Table:G3T% G3T
	INNER JOIN %Table:SZA% SZA ON ZA_FILIAL = %xFilial:SZA% AND 
	                              ZA_TERORI = G3T_TERORI AND 
	                              ZA_TERDES = G3T_TERDST AND 
	                              SZA.%NotDel% 
	 WHERE G3T_FILIAL = %Exp:cFilRV%  AND 
		   G3T_NUMID  = %Exp:cNumID%  AND 
		   G3T_IDITEM = %Exp:cIdItem% AND 
		   G3T_NUMSEQ = %Exp:cNumSeq% AND 
		   G3T_CODPAX = '00001' AND 
	  	   G3T_CONINU = '' AND
		   G3T.%NotDel%
EndSQL

If (cAliasAux)->(!Eof())
	nRet := (cAliasAux)->(DISTANCIA)
EndIf 

(cAliasAux)->(DbCloseArea())
RestArea(aArea)

Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AR001PERGT

Função utilizada para preenchimento automatico dos Pergunte

@sample 	AR001PERGT()
@param 		
@author    Thiago Tavares
@since		22/09/2016
@version	P12.1.13
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function AR001APERGT()

Local aArea := GetArea()
Local lRet  := .T.

Do Case
	Case Upper(Alltrim(ReadVar())) == 'MV_PAR03'		// APURACAO ATE
		If !Empty(MV_PAR03) .And. MV_PAR03 < MV_PAR02
			Help( , , "ALAR001", , "Datas divergentes.", 1, 0)					
			lRet := .F. 
		EndIf

	Case Upper(Alltrim(ReadVar())) == 'MV_PAR04'		// GRUPO CLIENTE DE
		If !Empty(MV_PAR04) .And. Alltrim(Upper(MV_PAR04)) <> Replicate("Z", TamSx3("AGT_CODIGO")[1])
			If (lRet := ExistCpo('AGT', MV_PAR04))
				MV_PAR05 := MV_PAR04
			EndIf
		ElseIf Empty(MV_PAR04)
			MV_PAR05 := Replicate("Z", TamSx3("AGT_CODIGO")[1])
		EndIf
			
	Case Upper(Alltrim(ReadVar())) == 'MV_PAR05'		// GRUPO CLIENTE ATE
		If !Empty(MV_PAR05) .And. Alltrim(Upper(MV_PAR05)) <> Replicate("Z", TamSx3("AGT_CODIGO")[1])
			lRet := ExistCpo('AGT', MV_PAR04)
		EndIf

	Case Upper(Alltrim(ReadVar())) == 'MV_PAR06'		// CLIENTE DE
		If !Empty(MV_PAR06) .And. Alltrim(Upper(MV_PAR06)) <> Replicate("Z", TamSx3("A1_COD")[1])
			MV_PAR07 := MV_PAR06
		ElseIf Empty(MV_PAR06)
			MV_PAR07 := Replicate("Z", TamSx3("A1_COD")[1])
		EndIf
			
	Case Upper(Alltrim(ReadVar())) == 'MV_PAR07'		// CLIENTE ATE
		If !Empty(MV_PAR07) .And. Alltrim(Upper(MV_PAR07)) <> Replicate("Z", TamSx3("A1_COD")[1])
			lRet := ExistCpo('SA1', MV_PAR07)
		EndIf

	Case Upper(Alltrim(ReadVar())) == 'MV_PAR08'		// GRUPO PRODUTO DE
		If !Empty(MV_PAR08) .And. Alltrim(Upper(MV_PAR08)) <> Replicate("Z", TamSx3("BM_GRUPO")[1])
			MV_PAR09 := MV_PAR08
		ElseIf Empty(MV_PAR08)
			MV_PAR09 := Replicate("Z", TamSx3("BM_GRUPO")[1])
		EndIf

	Case Upper(Alltrim(ReadVar())) == 'MV_PAR09'		// GRUPO PRODUTO ATE
		If !Empty(MV_PAR09) .And. Alltrim(Upper(MV_PAR09)) <> Replicate("Z", TamSx3("BM_GRUPO")[1])
			lRet := ExistCpo('SB1', MV_PAR09)
		EndIf
End Case

RestArea(aArea)

Return lRet

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} ALARAtuMsg

Função para atualização da mensagem de processamento informando o percentual já processado

@type 		function
@author 	Anderson Toledo
@since 		14/09/2016
/*/
//+----------------------------------------------------------------------------------------
Static Function ALARAtuMsg(oMessage, nPercAtu, nItemAtu, nTotal, nTipo, cNome)

Local nPerc := Int((nItemAtu * 100) / nTotal)

//Default	cMsg := ""

If nPerc > nPercAtu
	oMessage:SetText(I18N(STR0003, {IIF(nTipo == 1, STR0004, STR0005), cNome, cValToChar(nPerc) + '%'}))
	ProcessMessages()
	
	//Atualiza o próximo % de atualização da mensagem, sempre de 5% em 5%
	nPercAtu := nPerc + 5 
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SEGMENTOS

Função utilizada para retornar as informações do produto 

@sample 	SEGMENTOS()
@param 		
@author     Thiago Tavares
@since		05/10/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function SEGMENTOS(cFilRV, cNumID, cIdItem, cNumSeq)

Local aArea     := GetArea()
Local cAliasAux := GetNextAlias()
Local cRet      := ''

BeginSQL Alias cAliasAux
	SELECT
		G3Q_TPSEG,
		G3S_CODPAX,
		G3Q_GRPPRD,
		CASE
			WHEN G3Q_TPSEG = '2' OR G3Q_TPSEG = '7' OR G3Q_TPSEG = '8' THEN
				(SELECT RTRIM(CC2_MUN)
				 FROM %Table:SA2% SA2
	             INNER JOIN %Table:CC2% CC2 ON CC2_FILIAL = %xFilial:CC2% AND CC2_CODMUN = A2_COD_MUN AND CC2_EST = A2_EST AND CC2.%NotDel%
				 WHERE A2_FILIAL = %xFilial:SA2% AND A2_COD = G3R_FORNEC AND A2_LOJA = G3R_LOJA AND SA2.%NotDel%)
			ELSE
				(SELECT RTRIM(G5S_CIDADE)
	 			 FROM %Table:G5S% G5S
	 			 WHERE G5S_FILIAL = %xFilial:G5S% AND 
	 			       G5S.D_E_L_E_T_ = ' ' AND 
	 			       G5S_CODIGO = (CASE  
									    WHEN G3Q_TPSEG = '3' THEN G3V_CIDDEV
										WHEN G3Q_TPSEG = '4' THEN G3W_CIDDES
										WHEN G3Q_TPSEG = '5' THEN G3Y_CIDPRI
										WHEN G3Q_TPSEG = '6' THEN G3X_CIDDES
										WHEN G3Q_TPSEG = '9' THEN G40_CIDPRI
										WHEN G3Q_TPSEG = 'A' THEN G3Z_CIDPRI
										WHEN G3Q_TPSEG = 'B' THEN G43_CIDDES
									 END)) 
		END SEGMENTOS
	FROM %Table:G3Q% G3Q
	INNER JOIN %Table:G3R% G3R ON G3R_FILIAL = G3Q_FILIAL AND 
	                              G3R_NUMID  = G3Q_NUMID  AND 
	                              G3R_IDITEM = G3Q_IDITEM AND 
	                              G3R_NUMSEQ = G3Q_NUMSEQ AND 
	                              G3R_CONINU = ''         AND
	                              G3R.%NotDel%
  	INNER JOIN %Table:G3S% G3S ON G3S_FILIAL = G3R_FILIAL AND 
  	                              G3S_NUMID  = G3R_NUMID  AND 
  	                              G3S_IDITEM = G3R_IDITEM AND 
  	                              G3S_NUMSEQ = G3R_NUMSEQ AND 
  	                              G3S_CONINU = ''         AND
  	                              G3S.%NotDel%
	LEFT JOIN %Table:G3U% G3U ON  G3U_FILIAL = G3S_FILIAL AND 
	                              G3U_NUMID  = G3S_NUMID  AND 
	                              G3U_IDITEM = G3S_IDITEM AND 
	                              G3U_NUMSEQ = G3S_NUMSEQ AND 
	                              G3U_CODPAX = G3S_CODPAX AND 
	                              G3U_CONINU = ''         AND
	                              G3U.%NotDel%
	LEFT JOIN %Table:G3V% G3V ON  G3V_FILIAL = G3S_FILIAL AND 
	                              G3V_NUMID  = G3S_NUMID  AND 
	                              G3V_IDITEM = G3S_IDITEM AND 
	                              G3V_NUMSEQ = G3S_NUMSEQ AND 
	                              G3V_CODPAX = G3S_CODPAX AND 
	                              G3V_CONINU = ''         AND 
	                              G3V.%NotDel%
	LEFT JOIN %Table:G3W% G3W ON  G3W_FILIAL = G3S_FILIAL AND 
	                              G3W_NUMID  = G3S_NUMID  AND 
	                              G3W_IDITEM = G3S_IDITEM AND 
	                              G3W_NUMSEQ = G3S_NUMSEQ AND 
	                              G3W_CODPAX = G3S_CODPAX AND 
	                              G3W_CONINU = ''         AND
	                              G3W.%NotDel% 
	LEFT JOIN %Table:G3X% G3X ON  G3X_FILIAL = G3S_FILIAL AND 
	                              G3X_NUMID  = G3S_NUMID  AND 
	                              G3X_IDITEM = G3S_IDITEM AND 
	                              G3X_NUMSEQ = G3S_NUMSEQ AND
	                              G3X_CODPAX = G3S_CODPAX AND 
	                              G3X_CONINU = ''         AND 
	                              G3X.%NotDel% 
	LEFT JOIN %Table:G3Y% G3Y ON  G3Y_FILIAL = G3S_FILIAL AND 
	                              G3Y_NUMID  = G3S_NUMID  AND 
	                              G3Y_IDITEM = G3S_IDITEM AND 
	                              G3Y_NUMSEQ = G3S_NUMSEQ AND 
	                              G3Y_CODPAX = G3S_CODPAX AND 
	                              G3Y_CONINU = ''         AND 
	                              G3Y.%NotDel%
	LEFT JOIN %Table:G3Z% G3Z ON  G3Z_FILIAL = G3S_FILIAL AND 
	                              G3Z_NUMID  = G3S_NUMID  AND 
	                              G3Z_IDITEM = G3S_IDITEM AND 
	                              G3Z_NUMSEQ = G3S_NUMSEQ AND 
	                              G3Z_CODPAX = G3S_CODPAX AND 
 	                              G3Z_CONINU = ''         AND
	                              G3Z.%NotDel% 
	LEFT JOIN %Table:G40% G40 ON  G40_FILIAL = G3S_FILIAL AND 
	                              G40_NUMID  = G3S_NUMID  AND 
	                              G40_IDITEM = G3S_IDITEM AND 
	                              G40_NUMSEQ = G3S_NUMSEQ AND 
	                              G40_CODPAX = G3S_CODPAX AND 
  	                              G40_CONINU = ''         AND
	                              G40.%NotDel% 
	LEFT JOIN %Table:G41% G41 ON  G41_FILIAL = G3S_FILIAL AND 
								  G41_NUMID  = G3S_NUMID  AND 
								  G41_IDITEM = G3S_IDITEM AND 
								  G41_NUMSEQ = G3S_NUMSEQ AND 
								  G41_CODPAX = G3S_CODPAX AND 
  	                              G41_CONINU = ''         AND
	                              G41.%NotDel% 
	LEFT JOIN %Table:G42% G42 ON  G42_FILIAL = G3S_FILIAL AND 
								  G42_NUMID  = G3S_NUMID  AND 
								  G42_IDITEM = G3S_IDITEM AND 
								  G42_NUMSEQ = G3S_NUMSEQ AND 
								  G42_CODPAX = G3S_CODPAX AND 
  	                              G42_CONINU = ''         AND
	                              G42.%NotDel% 
	LEFT JOIN %Table:G43% G43 ON  G43_FILIAL = G3S_FILIAL AND 
	                              G43_NUMID  = G3S_NUMID  AND 
	                              G43_IDITEM = G3S_IDITEM AND 
	                              G43_NUMSEQ = G3S_NUMSEQ AND 
	                              G43_CODPAX = G3S_CODPAX AND 
  	                              G43_CONINU = ''         AND
	                              G43.%NotDel% 
  	WHERE G3Q_FILIAL = %Exp:cFilRV%  AND
	      G3Q_NUMID  = %Exp:cNumID%  AND 
	      G3Q_IDITEM = %Exp:cIdItem% AND 
	      G3Q_NUMSEQ = %Exp:cNumSeq% AND 
	      G3Q_CONINU = ''            AND
	      G3Q.%NotDel%
EndSQL

If (cAliasAux)->(!Eof())
	If (cAliasAux)->G3Q_TPSEG == '1'
		cRet := U_RETCOLS("SEGMENTOS", cFilRV, cNumID, cIdItem, cNumSeq, (cAliasAux)->G3S_CODPAX, (cAliasAux)->G3Q_GRPPRD)
	Else
		cRet := (cAliasAux)->SEGMENTOS
	EndIf
EndIf


(cAliasAux)->(DbCloseArea())
RestArea(aArea)

Return cRet 		