#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"
#Include "RPTDEF.CH"
#Include "TBICONN.CH"

// #########################################################################################
// Modulo : SIGATUR
// Fonte  : PONTO DE ENTRADA TURBOLFA.PRW
// #########################################################################################

User Function TURBOLFA()

	Local cClient		:= PARAMIXB[1]
	Local cLojaCli		:= PARAMIXB[2]
	Local cPrefixo		:= PARAMIXB[3]
	Local cNumTit		:= PARAMIXB[4]
	Local _cCamArq		:= PARAMIXB[5] + "\" + TRXSTRTRAN(cClient) + TRXSTRTRAN(cLojaCli) + "\fta" + FwFldGet("G8G_FATADI") +"\bol\"
	Local _cSegMent		:= FwFldGet("G8G_SEGMEN")
	Local _cImpAut		:= 0
	Local _cNomArq		:= Alltrim(cClient) + Alltrim(cLojaCli) + "_bol" + alltrim(cPrefixo) + Alltrim(cNumTit) + "_" + DtoS(dDataBase) + StrTran(Time(),":","")
	Local _cMenBol		:= ''
	Local cBanco		:= PARAMIXB[6]
	Local cAgencia		:= PARAMIXB[7]
	Local cConta		:= PARAMIXB[8]
	Local cPBanco		:= PARAMIXB[9]
	
	PRIVATE MV_PAR20

	If Empty(_cImpAut)
		_cImpAut := 1
	EndIf

	If _cSegMent = '2'
		_cMenBol := 'Sujeito a Retenção de PCC'
	EndIf

	_cQuery := "UPDATE " +RetSqlName("SE1")
	_cQuery += " SET E1_PORTADO= '"+cBanco+"' "
	_cQuery += " , E1_AGEDEP  = '"+cAgencia+"' "
	_cQuery += " , E1_CONTA  = '"+cConta+"' "
	_cQuery += " where E1_FILIAL = '"+XFILIAL("SE1")+"' "
	_cQuery += " AND E1_PREFIXO   = '"+ALLTRIM(PARAMIXB[3])+"' "
	_cQuery += " AND E1_NUM  = '"+ALLTRIM(PARAMIXB[4])+"' "
	_cQuery += " AND E1_CLIENTE  = '"+ALLTRIM(PARAMIXB[1])+"' "
	_cQuery += " AND E1_LOJA = '"+ALLTRIM(PARAMIXB[2])+"' "
	_cQuery += " AND E1_TIPO NOT IN " + FormatIn(MVABATIM,"|")
	_cQuery += " AND D_E_L_E_T_ = '' "
	_cQuery += " AND E1_SALDO >	0 "
	TcSqlExec(_cQuery)
	
	cAliasQry := _Query()

	If !(cAliasQry)->(Bof()) .Or. !(cAliasQry)->(Eof())
		
		(cAliasQry)->(dbGoTop())
		FWMAKEDIR(_cCamArq)
		oPrint:=FwMSPrinter():New(_cNomArq,IMP_PDF,.T.,,.T.,.T.,,,,,.F.,.F.,)
		oPrint:cPathPDF := _cCamArq
		oPrint:SetPortrait()
		oPrint:SetPaperSize(9) // 9 = A4
		
		While !(cAliasQry)->(Eof())
			MV_PAR20:=cPBanco

			U_FINX999Imp(oPrint,cAliasQry,_cMenBol)
			
			(cAliasQry)->(dbSkip())
		EndDo
		
		oPrint:Preview()
		
		If _cImpAut = 2 //1-Não imprime boleto automatico / 2-Imprime boleto automatico
			//Função que imprimi direto na impressora.
			ShellExecute( "Print", _cNomArq+".PDF", " ", _cCamArq, 0 )
		EndIf
		
		FreeObj(oPrint)
		oPrint := Nil
	Else

		MsgAlert("Não há títulos disponíveis para a emissão do(s) boleto(s)."+CRLF+"Verifique os parâmetros informados e emita novamente o boleto.")
	
	EndIf

	(cAliasQry)->(dbSkip())
	
Return
	
// #########################################################################################
// Modulo : SIGATUR
// Fonte  : FUNÇÃO QUE M0NTA QUERY COM OS DADOS A SEREM ENVIADOS A ROTINA QUE GERA O BOLETO
// #########################################################################################
Static Function _Query()
	
	Local aStruct		:= {}
	Local cAliasQry	:= GetNextAlias()
	Local cAliasTrb	:= GetNextAlias()
	Local cCampo    := ""
	Local cNotIn	:= '%' + FormatIn(MVABATIM,"/") + "%"
	Local nX		:= 0
	Local xConteudo	:= ""
	
	BeginSQL Alias cAliasQry
		SELECT			SE1.E1_PREFIXO,	SE1.E1_NUM,		SE1.E1_PARCELA,	SE1.E1_TIPO,
		SE1.E1_EMISSAO,	SE1.E1_VENCREA,	SE1.E1_XDTPROR, SE1.E1_NUMBOR,	SE1.E1_SALDO,	SE1.E1_XMULTA,
		SE1.E1_VENCTO,	SE1.E1_OK, 		SE1.E1_IRRF,	SE1.E1_ISS,		SE1.E1_PIS,		SE1.E1_COFINS, SE1.E1_CSLL, SE1.E1_XCOBJM,
		SA6.A6_COD,		SA6.A6_AGENCIA,	SA6.A6_NUMCON,	SA6.A6_NOME,	SA6.A6_DVCTA,
		SA1.A1_COD,		SA1.A1_NOME,	SA1.A1_LOJA,	SA1.A1_END,
		SA1.A1_ENDCOB,	SA1.A1_BAIRRO,	SA1.A1_BAIRROC,	SA1.A1_MUN,
		SA1.A1_MUNC,	SA1.A1_EST,		SA1.A1_ESTC,	SA1.A1_CEP,
		SA1.A1_CEPC,	SA1.A1_CGC,		SA1.A1_PESSOA,	SA1.A1_XMULTA
		FROM	%Table:SE1% SE1
		INNER JOIN %Table:SA6% SA6 ON
		SA6.A6_FILIAL		= %XFilial:SA6%
		AND SA6.A6_COD			= SE1.E1_PORTADO
		AND SA6.A6_AGENCIA	= SE1.E1_AGEDEP
		AND SA6.A6_NUMCON	= SE1.E1_CONTA
		AND SA6.%NotDel%
		INNER JOIN %Table:SA1% SA1 ON
		SA1.A1_FILIAL		= %XFilial:SA1%
		AND SA1.A1_COD		= SE1.E1_CLIENTE
		AND SA1.A1_LOJA		= SE1.E1_LOJA
		AND SA1.A1_EST 		<> 'EX'
		AND SA1.%NotDel%
		WHERE	SE1.E1_FILIAL	=		%XFilial:SE1%
		AND SE1.E1_PREFIXO		=		%Exp:PARAMIXB[3]%
		AND SE1.E1_NUM			=		%Exp:PARAMIXB[4]%
		AND SE1.E1_TIPO			NOT IN	%Exp:cNotIn%
		AND SE1.E1_CLIENTE		=		%Exp:PARAMIXB[1]%
		AND SE1.E1_LOJA			=		%Exp:PARAMIXB[2]%
		AND SE1.E1_SALDO		>		0
		AND SE1.%NotDel%
		ORDER BY %Order:SE1%
	EndSQL
	
	aAdd(aStruct,{"E1_PREFIXO"	,"C", TamSX3("E1_PREFIXO")[1]	, TamSX3("E1_PREFIXO")[2]}	)
	aAdd(aStruct,{"E1_NUM"		,"C", TamSX3("E1_NUM")[1]		, TamSX3("E1_NUM")[2]}		)
	aAdd(aStruct,{"E1_PARCELA"	,"C", TamSX3("E1_PARCELA")[1]	, TamSX3("E1_PARCELA")[2]}	)
	aAdd(aStruct,{"E1_TIPO"		,"C", TamSX3("E1_TIPO")[1]		, TamSX3("E1_TIPO")[2]}		)
	aAdd(aStruct,{"E1_EMISSAO"	,"D", TamSX3("E1_EMISSAO")[1]	, TamSX3("E1_EMISSAO")[2]}	)
	aAdd(aStruct,{"E1_NUMBOR"	,"C", TamSX3("E1_NUMBOR")[1]	, TamSX3("E1_NUMBOR")[2]}	)
	aAdd(aStruct,{"E1_OK"		,"C", TamSX3("E1_OK")[1]		, TamSX3("E1_OK")[2]}		)
	aAdd(aStruct,{"E1_SALDO"	,"N", TamSX3("E1_SALDO")[1]		, TamSX3("E1_SALDO")[2]}	)
	aAdd(aStruct,{"E1_VENCREA"	,"D", TamSX3("E1_VENCREA")[1]	, TamSX3("E1_VENCREA")[2]}	)
	aAdd(aStruct,{"E1_VENCTO"	,"D", TamSX3("E1_VENCTO")[1]	, TamSX3("E1_VENCTO")[2]}	)
	aAdd(aStruct,{"E1_XDTPROR"	,"D", TamSX3("E1_XDTPROR")[1]	, TamSX3("E1_XDTPROR")[2]}	)
	aAdd(aStruct,{"E1_IRRF"		,"N", TamSX3("E1_IRRF")[1]		, TamSX3("E1_IRRF")[2]}		)
	aAdd(aStruct,{"E1_ISS"		,"N", TamSX3("E1_ISS")[1]		, TamSX3("E1_ISS")[2]}		)
	aAdd(aStruct,{"E1_PIS"		,"N", TamSX3("E1_PIS")[1]		, TamSX3("E1_PIS")[2]}		)
	aAdd(aStruct,{"E1_COFINS"	,"N", TamSX3("E1_COFINS")[1]	, TamSX3("E1_COFINS")[2]}	)
	aAdd(aStruct,{"E1_CSLL"		,"N", TamSX3("E1_CSLL")[1]		, TamSX3("E1_CSLL")[2]}		)
	aAdd(aStruct,{"E1_XMULTA"	,"N", TamSX3("E1_XMULTA")[1]	, TamSX3("E1_XMULTA")[2]}	)
	aAdd(aStruct,{"E1_XCOBJM"	,"C", TamSX3("E1_XCOBJM")[1]	, TamSX3("E1_XCOBJM")[2]}	)
	aAdd(aStruct,{"A1_COD"		,"C", TamSX3("A1_COD")[1]		, TamSX3("A1_COD")[2]}		)
	aAdd(aStruct,{"A1_BAIRRO"	,"C", TamSX3("A1_BAIRRO")[1]	, TamSX3("A1_BAIRRO")[2]}	)
	aAdd(aStruct,{"A1_BAIRROC"	,"C", TamSX3("A1_BAIRROC")[1]	, TamSX3("A1_BAIRROC")[2]}	)
	aAdd(aStruct,{"A1_CEP"		,"C", TamSX3("A1_CEP")[1]		, TamSX3("A1_CEP")[2]}		)
	aAdd(aStruct,{"A1_CEPC"		,"C", TamSX3("A1_CEPC")[1]		, TamSX3("A1_CEPC")[2]}		)
	aAdd(aStruct,{"A1_CGC"		,"C", TamSX3("A1_CGC")[1]		, TamSX3("A1_CGC")[2]}		)
	aAdd(aStruct,{"A1_LOJA"		,"C", TamSX3("A1_LOJA ")[1]		, TamSX3("A1_LOJA ")[2]}	)
	aAdd(aStruct,{"A1_NOME"		,"C", TamSX3("A1_NOME")[1]		, TamSX3("A1_NOME")[2]}		)
	aAdd(aStruct,{"A1_END"		,"C", TamSX3("A1_END")[1]		, TamSX3("A1_END")[2]}		)
	aAdd(aStruct,{"A1_ENDCOB"	,"C", TamSX3("A1_ENDCOB")[1]	, TamSX3("A1_ENDCOB")[2]}	)
	aAdd(aStruct,{"A1_EST"		,"C", TamSX3("A1_EST")[1]		, TamSX3("A1_EST")[2]}		)
	aAdd(aStruct,{"A1_ESTC"		,"C", TamSX3("A1_ESTC")[1]		, TamSX3("A1_ESTC")[2]}		)
	aAdd(aStruct,{"A1_MUN"		,"C", TamSX3("A1_MUN")[1]		, TamSX3("A1_MUN")[2]}		)
	aAdd(aStruct,{"A1_MUNC"		,"C", TamSX3("A1_MUNC")[1]		, TamSX3("A1_MUNC")[2]}		)
	aAdd(aStruct,{"A1_PESSOA"	,"C", TamSX3("A1_PESSOA")[1]	, TamSX3("A1_PESSOA")[2]}	)
	aAdd(aStruct,{"A1_XMULTA"	,"N", TamSX3("A1_XMULTA")[1]	, TamSX3("A1_XMULTA")[2]}	)
	aAdd(aStruct,{"A6_COD"		,"C", TamSX3("A6_COD")[1]		, TamSX3("A6_COD")[2]}		)
	aAdd(aStruct,{"A6_AGENCIA"	,"C", TamSX3("A6_AGENCIA")[1]	, TamSX3("A6_AGENCIA")[2]}	)
	aAdd(aStruct,{"A6_NUMCON"	,"C", TamSX3("A6_NUMCON")[1]	, TamSX3("A6_NUMCON")[2]}	)
	aAdd(aStruct,{"A6_NOME"		,"C", TamSX3("A6_NOME")[1]		, TamSX3("A6_NOME")[2]}		)
	aAdd(aStruct,{"A6_DVCTA"	,"C", TamSX3("A6_DVCTA")[1]		, TamSX3("A6_DVCTA")[2]}	)
	
	//Cria o arquivo temporário
	cAliasTrb := CriaTrab(aStruct,.T.)
	DbUseArea(.T.,__Localdrive, cAliasTrb,cAliasTrb)
	IndRegua(cAliasTrb,cAliasTrb,"E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")
	
	dbSelectArea(cAliasQry)
	While !(cAliasQry)->(Eof())
		
		RecLock(cAliasTrb,.T.)
		
		For nX := 1 to Len(aStruct)
			cCampo := aStruct[nX][1]
			
			If aStruct[nX][2] == "D"
				xConteudo := StoD((cAliasQry)->&cCampo)
			Else
				xConteudo := (cAliasQry)->&cCampo
			EndIf
			
			(cAliasTrb)->&cCampo := xConteudo
		Next nX
		
		(cAliasTrb)->(MsUnlock())
		(cAliasQry)->(dbSkip())
		
	EndDo
	
	(cAliasQry)->(dbCloseArea())
	
Return(cAliasTrb)