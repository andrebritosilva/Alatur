#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "FWBROWSE.CH"
#Include "RPTDEF.CH"
#Include "TBICONN.CH"

// #########################################################################################
// Projeto: 11.90
// Modulo : SIGATUR
// Fonte  : PONTO DE ENTRADA TURBOLFT.PRW
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 20/09/16 | Rafael Melo	    | Ponto de entrada para chamar impressão de boleto
// #########################################################################################
User Function TURBOLFT()

local _aArea		:= GetArea()
LOCAL _cQuery		:= ""
local cBanco		:= ""
local cAgencia		:= ""
local cConta		:= ""
//local cPBanco		:= ""
Local _cSegMent		:= ''
Local aComplemento	:={}
LOCAL mpar01,mpar02,mpar03,mpar04
Local _cImpAut		:= 0
Local aAreaG4P		:= G4P->(GetArea())
Local aAreaG85		:= G85->(GetArea())
Local aAreaG84		:= G84->(GetArea())
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSE1		:= SE1->(GetArea())
Local aAreaSEE		:= SEE->(GetArea())
Local _cCamArq		:= SUBSTR(PARAMIXB[5],1,LEN(PARAMIXB[5])-4)+"BOL\"
Local _cNomArq		:= "bol_" + DToS(dDataBase)
Local cAliasG85		:= GetNextAlias()
Local cAliasSA1		:= GetNextAlias()
Local cCodCli		:= ''
Local cLojCli		:= ''

PRIVATE cPrefixo	:= PARAMIXB[3]
PRIVATE cNumFat		:= PARAMIXB[4]
PRIVATE cClient		:= PARAMIXB[1]
PRIVATE cLojaCli	:= PARAMIXB[2]
PRIVATE MV_PAR20
PRIVATE _cMenBol	:= ''

//Personalização para gravação da tabela SF2 para transmissão da Nota Fiscal de Saída!!!
//U_GRVTURSF2(cPrefixo,cNumFat,cClient,cLojaCli)  

Pergunte("TURA44V", .F.)

_cImpAut := MV_PAR18

If Empty(_cImpAut)
	_cImpAut := 1
EndIf

/*/
//Inicio da ALteração Ronaldo Bicudo / Totvs - 11/10/2016
DbSelectArea("G85")
DbSetOrder(1)
If G85->(MsSeek(xFilial("G85")+cPrefixo+cNumFat,.T.))
	If G85->G85_SEGNEG == '1'
		aComplemento := TURAX01(PARAMIXB[1], PARAMIXB[2] , .F. , "" ,dDataBase, .T., .F., .F., "")
	ELSEIF 	G85->G85_SEGNEG == '2'
		aComplemento := TURAX01(PARAMIXB[1], PARAMIXB[2] , .F. , "" ,dDataBase, .F., .T., .F., "")
	ELSEIF 	G85->G85_SEGNEG == '3'
		aComplemento := TURAX01(PARAMIXB[1], PARAMIXB[2] , .F. , "" ,dDataBase, .F., .F., .T., "")
	ENDIF
	_cSegMent := ALLTRIM(G85->G85_SEGNEG)
EndIf
/*/
BeginSQL Alias cAliasG85
	SELECT G85_SEGNEG
	FROM %Table:G85% G85 (NOLOCK)
	WHERE G85.G85_FILIAL	=	%xFilial:G85%
	AND G85.G85_PREFIX		=	%Exp:cPrefixo%
	AND G85.G85_NUMFAT		=	%Exp:cNumFat%
	AND G85.%NotDel%
EndSql

If (cAliasG85)->G85_SEGNEG == '1'
	aComplemento := TURAX01(PARAMIXB[1], PARAMIXB[2] , .F. , "" ,dDataBase, .T., .F., .F., "")
ELSEIF 	(cAliasG85)->G85_SEGNEG == '2'
	aComplemento := TURAX01(PARAMIXB[1], PARAMIXB[2] , .F. , "" ,dDataBase, .F., .T., .F., "")
ELSEIF 	(cAliasG85)->G85_SEGNEG == '3'
	aComplemento := TURAX01(PARAMIXB[1], PARAMIXB[2] , .F. , "" ,dDataBase, .F., .F., .T., "")
ENDIF

_cSegMent := ALLTRIM((cAliasG85)->G85_SEGNEG)

(cAliasG85)->(dbCloseArea())

If _cSegMent = '2'
	_cMenBol := 'Sujeito a Retenção de PCC'
EndIf

If EMPTY(aComplemento)
	RestArea(_aArea)
	RestArea(aAreaG4P)
	RestArea(aAreaG85)
	RestArea(aAreaG84)
	RestArea(aAreaSA1)
	RestArea(aAreaSE1)
	RestArea(aAreaSEE)
	//Personalização para gravação da tabela SF2 para transmissão da Nota Fiscal de Saída!!!
	//U_GRVTURSF2(cPrefixo,cNumFat,cClient,cLojaCli)
	RETURN()
Else //Comentado parte do fonte, porque tem complemento de clientes que estão com a tabela G4P vazia.E Alatur diz não querer este tipo de validação no processo.
	//Voltado Else para tratativa do campo abaixo, conforme alinahmento com Octavio (TI - Alatur) - 01/08/2017.
	DBSELECTAREA("G4P")
	DBSETORDER(1)
	If DBSEEK(XFILIAL("G4P")+aComplemento[1,1])    //Adicionado 'IF' Ronaldo Bicudo -  01/08/2017
		If G4P_ENVBOL <> '1'
			RestArea(_aArea)
			RestArea(aAreaG4P)
			RestArea(aAreaG85)
			RestArea(aAreaG84)
			RestArea(aAreaSA1)
			RestArea(aAreaSE1)
			RestArea(aAreaSEE)
			//Personalização para gravação da tabela SF2 para transmissão da Nota Fiscal de Saída!!!
			//U_GRVTURSF2(cPrefixo,cNumFat,cClient,cLojaCli)
			RETURN()
		EndIF
	EndIf
EndIf
//Fim da Alteração por Ronaldo Bicudo / Totvs - 11/10/2016

cCodCli := SUBSTR(PARAMIXB[1],1,TamSx3("A1_COD")[1])
cLojCli := PARAMIXB[2]

//DBSELECTAREA("SA1")
//DBSETORDER(1)
//DBSEEK(XFILIAL("SA1")+SUBSTR(PARAMIXB[1],1,TamSx3("A1_COD")[1])+PARAMIXB[2])

BeginSQL Alias cAliasSA1
	SELECT A1_BCO1, A1_XAGEN, A1_XCONTAC, A1_XPBANC
	FROM %Table:SA1% SA1 (NOLOCK)
	WHERE SA1.A1_FILIAL	=	%xFilial:SA1%
	AND SA1.A1_COD		=	%Exp:cCodCli%
	AND SA1.A1_LOJA		=	%Exp:cLojCli%
	AND SA1.%NotDel%
EndSql

If EMPTY((cAliasSA1)->A1_BCO1) .OR. EMPTY((cAliasSA1)->A1_XAGEN) .OR. EMPTY((cAliasSA1)->A1_XCONTAC) .or. EMPTY((cAliasSA1)->A1_XPBANC)
	mpar01:=MV_PAR01
	mpar02:=MV_PAR02
	mpar03:=MV_PAR03
	mpar04:=MV_PAR04
	SX1FINBOL()
	If Pergunte(PADR("_xBOL",10),.T.)
		cBanco	:= ALLTRIM(mv_par01)
		cAgencia:= ALLTRIM(mv_par02)
		cConta	:= ALLTRIM(mv_par03)
		cPBanco := ALLTRIM(MV_PAR04)
	else
		RestArea(_aArea)
		RETURN()
	endif
else
	cBanco	:= ALLTRIM((cAliasSA1)->A1_BCO1)
	cAgencia:= ALLTRIM((cAliasSA1)->A1_XAGEN)
	cConta	:= ALLTRIM((cAliasSA1)->A1_XCONTAC)
	cPBanco := ALLTRIM((cAliasSA1)->A1_XPBANC)
endif

(cAliasSA1)->(dbCloseArea())

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
	//	oPrint:=FWMsPrinter():New("bol_" + DToS(dDataBase),IMP_PDF, .T., "\system", .F./*lDisabeSetup*/, .T.,,,,,.F., .T., )
	oPrint:=FwMSPrinter():New(_cNomArq,IMP_PDF,.T.,,.T.,.T.,,,,,.F.,.F.,)
	MAKEDIR(SUBSTR(PARAMIXB[5],1,LEN(PARAMIXB[5])-4)+"BOL\")
	oPrint:cPathPDF := SUBSTR(PARAMIXB[5],1,LEN(PARAMIXB[5])-4)+"BOL\"
	oPrint:SetPortrait()
	//	oPrint:SetSize(215,297)
	//	oPrint:SetPaperSize(0,285,210) // 9 = A4
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
	
Else
	MsgAlert("Não há títulos disponíveis para a emissão do(s) boleto(s)."+CRLF+"Verifique os parâmetros informados e emita novamente a boleto.")
	
	(cAliasQry)->(dbSkip())
	RestArea(_aArea)
	RestArea(aAreaG4P)
	RestArea(aAreaG85)
	RestArea(aAreaG84)
	RestArea(aAreaSA1)
	RestArea(aAreaSE1)
	RestArea(aAreaSEE)
	
	MV_PAR01:=mpar01
	MV_PAR02:=mpar02
	MV_PAR03:=mpar03
	MV_PAR04:=mpar04
	
	//Personalização para gravação da tabela SF2 para transmissão da Nota Fiscal de Saída!!!
	//U_GRVTURSF2(cPrefixo,cNumFat,cClient,cLojaCli)
	
	return
	
EndIf

(cAliasQry)->(dbSkip())
RestArea(_aArea)
RestArea(aAreaG4P)
RestArea(aAreaG85)
RestArea(aAreaG84)
RestArea(aAreaSA1)
RestArea(aAreaSE1)
RestArea(aAreaSEE)

MV_PAR01:=mpar01
MV_PAR02:=mpar02
MV_PAR03:=mpar03
MV_PAR04:=mpar04

FreeObj(oPrint)
oPrint := Nil

//Personalização para gravação da tabela SF2 para transmissão da Nota Fiscal de Saída!!!
//U_GRVTURSF2(cPrefixo,cNumFat,cClient,cLojaCli)

return

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
//	SA6.A6_FILIAL			= %XFilial:SA6%
//	AND 
	SA6.A6_COD			= SE1.E1_PORTADO
	AND SA6.A6_AGENCIA	= SE1.E1_AGEDEP
	AND SA6.A6_NUMCON	= SE1.E1_CONTA
	AND SA6.%NotDel%
	INNER JOIN %Table:SA1% SA1 ON
	SA1.A1_FILIAL		= %XFilial:SA1%
	AND SA1.A1_COD		= SE1.E1_CLIENTE
	AND SA1.A1_LOJA		= SE1.E1_LOJA
	AND SA1.A1_EST 		<> 'EX'
	AND SA1.%NotDel%
	WHERE	SE1.E1_FILIAL	=	%XFilial:SE1%
	AND SE1.E1_PREFIXO		=	%Exp:PARAMIXB[3]%
	AND SE1.E1_NUM			=	%Exp:PARAMIXB[4]%
	//	AND SE1.E1_PARCELA	BETWEEN	%Exp:MV_PAR05% AND %Exp:MV_PAR06%
	AND SE1.E1_TIPO			NOT IN		%Exp:cNotIn%
	AND SE1.E1_CLIENTE		=	%Exp:PARAMIXB[1]%
	AND SE1.E1_LOJA			=	%Exp:PARAMIXB[2]%
	//	AND SE1.E1_EMISSAO	BETWEEN	%Exp:MV_PAR11% AND %Exp:MV_PAR12%
	//	AND SE1.E1_VENCREA	BETWEEN	%Exp:MV_PAR13% AND %Exp:MV_PAR14%
	//	AND SE1.E1_NUMBOR		BETWEEN	%Exp:MV_PAR15% AND %Exp:MV_PAR16%
	//	AND SE1.E1_PORTADO	=			%Exp:MV_PAR17%
	//	AND SE1.E1_SITUACA	=			%Exp:MV_PAR19%
	AND SE1.E1_SALDO		>			0
	//	AND SE1.E1_PORTADO	<>			' '
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
//Incluido Ronaldo Bicudo / 20/04/2017 - Alterado 15/05/2017
aAdd(aStruct,{"E1_XDTPROR"	,"D", TamSX3("E1_XDTPROR")[1]	, TamSX3("E1_XDTPROR")[2]}	)
aAdd(aStruct,{"E1_IRRF"		,"N", TamSX3("E1_IRRF")[1]		, TamSX3("E1_IRRF")[2]}		)
aAdd(aStruct,{"E1_ISS"		,"N", TamSX3("E1_ISS")[1]		, TamSX3("E1_ISS")[2]}		)
aAdd(aStruct,{"E1_PIS"		,"N", TamSX3("E1_PIS")[1]		, TamSX3("E1_PIS")[2]}		)
aAdd(aStruct,{"E1_COFINS"	,"N", TamSX3("E1_COFINS")[1]	, TamSX3("E1_COFINS")[2]}	)
aAdd(aStruct,{"E1_CSLL"		,"N", TamSX3("E1_CSLL")[1]		, TamSX3("E1_CSLL")[2]}		)
aAdd(aStruct,{"E1_XMULTA"	,"N", TamSX3("E1_XMULTA")[1]	, TamSX3("E1_XMULTA")[2]}	)
aAdd(aStruct,{"E1_XCOBJM"	,"C", TamSX3("E1_XCOBJM")[1]	, TamSX3("E1_XCOBJM")[2]}	)
//FIM
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
//Incluido Ronaldo Bicudo / Totvs 05/05/2017
aAdd(aStruct,{"A1_XMULTA"	,"N", TamSX3("A1_XMULTA")[1]	, TamSX3("A1_XMULTA")[2]}	)
//FIM
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

RETURN

********************************************************************************************************************
Static Function SX1FINBOL()

Private aRegs :={}, i

_xBOL := PADR("_xBOL",10)

//	   cGrupo	cOrdem	cPergunt				cPerSpa					cPerEng					cVar		cTipo	nTamanho	nDecimal	nPresel	cGSC	cValid							cF3			cGrpSxg	cPyme	cVar01		cDef01	cDefSpa1	cDefEng1	cCnt01						cDef02	cDefSpa2	cDefEng2	cDef03	cDefSpa3	cDefEng3	cDef04	cDefSpa4	cDefEng4	cDef05	cDefSpa5	cDefEng5	aHelpPor	aHelpEng	aHelpSpa	cHelp
PUTSX1(_xBOL	,"01"	,"Banco   ?"			, "Banco   ?"			, "Banco   ?"			,"mv_ch1","C",TAMSX3("A6_COD")[1]	 ,0,0,"G","","SA6","","N"	,"MV_PAR01",""		,""			,""			,""			,""		,""		,"","","" ,"","","","","","","","","","","","","","",""  )
PUTSX1(_xBOL	,"02"	,"Agencia ?"			, "Agencia ?"			, "Agencia ?"			,"mv_ch2","C",TAMSX3("A6_AGENCIA")[1],0,0,"G",""	,""	 ,"","N"	,"MV_PAR02",""		,""			,""			,""			,""		,""		,"","","" ,"","","","","","","","","","","","","","","",""  )
PUTSX1(_xBOL	,"03"	,"Conta   ?"			, "Conta   ?" 			, "Conta   ?"			,"mv_ch3","C",TAMSX3("A6_NUMCON")[1] ,0,0,"G",""	,""	 ,"","N"	,"MV_PAR03",""		,""			,""			,""			,""		,""		,"","","" ,"","","","","","","","","","","","","","","",""  )
PutSx1(_xBol	,"04"	,"Parâmetro Banco"		, "Parâmetro Banco"		,"Parâmetro Banco"		,"MV_CH4","C",3			,0			,0		,"G"	,""								,		,""		,"N"	,"MV_PAR18"	,""		,""			,""			,""							,""		,""			,""			,""		,""			,""			,""		,""			,""			,""		,""			,""			,""	,""	,""	,""		)

Return