#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'TURI034LOC.CH'

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Função padrão que deve existir para cadastro do adapter

@sample	TURI034LOC(cXml, cTypeTrans, cTypeMessage)
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transação
				0 - para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				1 - para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				20 - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				21 - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				22 - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				23 - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return	aRet - lREt - Variável lógica, indicando se o processamento foi executado com sucesso (.T.) ou não (.F.) 
			   cXMLRet - String com o XML de retorno
			   cMsgUnica - String com o nome da Mensagem Unica
@author 	Jacomo Lisa
@since		05/04/2016
@version 	P12
/*/
//-----------------------------------------------------------------------------------------
STATIC FUNCTION IntegDef(cXml, nTypeTrans, cTypeMessage) 

Local aRet := {}
aRet:= TURI034LOC(cXml, nTypeTrans, cTypeMessage)

Return aRet

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} TURI034LOC

Função de integração de localizador de Item de Venda (RV)
Mensagem única do tipo Request - 

@sample	TURI034LOC(cXml, cTypeTrans, cTypeMessage)
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transação
				0 - para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				1 - para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				20 - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				21 - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				22 - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				23 - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return	lRet - Variável lógica, indicando se o processamento foi executado com sucesso (.T.) ou não (.F.) 
			cXMLRet - String com o XML de retorno
			cMsgUnica - String com o nome da Mensagem Unica
@author 	Jacomo Lisa
@since		05/04/2016
@version 	P12
/*/
//-----------------------------------------------------------------------------------------
Function TURI034LOC(cXml, nTypeTrans, cTypeMessage)

Local aArea     := GetArea()
Local lRet		:= .T.
Local cXMLRet	:= "" 
Local cXmlItem	:= ""
Local cMsgUnica	:= "SaleItemFinder" 
Local oXML		:= tXMLManager():New()
Local cBusiCont	:= '/TOTVSMessage/BusinessMessage/BusinessContent'
Local cMarca	:= ""
Local cDoc	    := ""
Local cSegNeg	:= ""
Local cExtProd	:= ""
Local cProd		:= ""
Local cExtCli   := ""
Local cCliente	:= ""
Local cCliLoja	:= ""
Local cExtPForn	:= ""
Local cPForne	:= ""
Local cPForLj	:= ""
Local cExtRForn	:= ""
Local cRForne	:= ""
Local cRForLj	:= ""
Local cTipoDoc  := ""
Local cOperac   := ""
Local cExtFop   := ""  
Local cFop      := ""
Local cExtCont  := ""
Local cContato  := ""	
Local nTarifa   := "" 
Local cDtEmiss  := ""
Local nX		:= 0
Local aMessages := {}

Do Case
	Case nTypeTrans == TRANS_RECEIVE .And. oXML:Parse(cXml)
		Do Case
			Case (cTypeMessage == EAI_MESSAGE_WHOIS)//whois 
				cXmlRet := '1.000'
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS) 
				cMsgUnica := AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessRequest/Operation'))
				cMarca	  := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
				cDoc      := PadR(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ProcessNumber')), TamSx3('G3Q_DOC')[1])
				cSegNeg	  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TradingProcess'))
				cExtProd  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ItemInternalId'))
				cExtCli	  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CustomerInternalId'))
				cExtPForn := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ProductVendorInternalId'))
				cExtRForn := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ReportVendorInternalId'))
				cTipoDoc  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DocumentType'))
				cOperac   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/OperationType'))
				cExtFop   := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/PaymentFormInternalId'))
				cFop      := PadR(Alltrim(TURXRetId(cMarca, "G3N", "G3N_CODIGO", cExtFop, Nil, 3)), TamSx3("G3Q_FORMPG")[1])				
				cExtCont  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ContactInternalId'))
				cContato  := PadR(Alltrim(TURXRetId(cMarca, "SU5", "U5_CODCONT", cExtCont, Nil, 3)), TamSx3("G3Q_SOLIC")[1])				
				cDtEmiss  := StrTran(StrTran(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/IssueDate')), "-", ""), "/", "")
				nTarifa   := Val(IIF(!Empty(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/BaseFareValue'))), AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/BaseFareValue')), '0'))

				// Recuperando os valores internos das entidades
				cProd := PadR(AllTrim(TURXRetId(cMarca, 'SB1', 'B1_COD', cExtProd, Nil, 3)), TamSx3('B1_COD')[1])
				If Empty(cProd) .Or. !SB1->(ExistCpo('SB1', cProd))
					aAdd(aMessages, {STR0004 + STR0001, 1, STR0004})	// "Produto"##" não encontrado ou não informado"
				EndIf
				
				cCliente := PadR(AllTrim(TURXRetId(cMarca, 'SA1', 'A1_COD', cExtCli, Nil, 3)), TamSx3('A1_COD' )[1])
				cCliLoja := PadR(AllTrim(TURXRetId(cMarca, 'SA1', 'A1_COD', cExtCli, Nil, 4)), TamSx3('A1_LOJA')[1])
				If !Empty(cCliente + cCliLoja) .AND. !SA1->(ExistCpo('SA1', cCliente + cCliLoja))
					aAdd(aMessages, {STR0008 + STR0001, 1, STR0008})	// "Cliente"##" não encontrado ou não informado"
				EndIf
				
				cPForne	:= PadR(AllTrim(TURXRetId(cMarca, 'SA2', 'A2_COD', cExtPForn, Nil, 3)), TamSx3('A2_COD'	)[1])
				cPForLj	:= PadR(AllTrim(TURXRetId(cMarca, 'SA2', 'A2_COD', cExtPForn, Nil, 4)), TamSx3('A2_LOJA')[1])
				If !Empty(cPForne + cPForLj) .AND. !SA2->(ExistCpo('SA2', cPForne + cPForLj))
					aAdd(aMessages, {STR0002 + STR0001, 1, STR0002})	// "Fornecedor do Produto"##" não encontrado ou não informado"
				EndIf
				
				cRForne	 := PadR(AllTrim(TURXRetId(cMarca, 'SA2', 'A2_COD', cExtRForn, Nil, 3)), TamSx3('A2_COD' )[1])
				cRForLj	 := PadR(AllTrim(TURXRetId(cMarca, 'SA2', 'A2_COD', cExtRForn, Nil, 4)), TamSx3('A2_LOJA')[1])
				If !Empty(cRForne + cRForLj) .AND. !SA2->(ExistCpo('SA2', cRForne + cRForLj))
					aAdd(aMessages, {STR0003 + STR0001, 1, STR0003})	// "Fornecedor de Reporte"##" não encontrado ou não informado"
				EndIf
				
				If Empty(cSegNeg)
					aAdd(aMessages, {STR0005 + STR0001, 1, STR0005})	// "Segmento"##" não encontrado ou não informado"
				EndIf

				If Empty(cDoc)
					aAdd(aMessages, {STR0006 + STR0001, 1, STR0006})	// "Documento"##" não encontrado ou não informado"
				EndIf

				If Len(aMessages) == 0
					lFound := Len(aDados := TI034Qry(cPForne, cPForLj, cRForne, cRForLj, cProd, cSegNeg, cDoc, cCliente, cCliLoja, cTipoDoc, cOperac, cFop, cContato, nTarifa, cDtEmiss)) > 0
					cXmlRet += '<Found>' + IIF(lFound, 'Yes', 'No') + '</Found>'
					If lFound
						For nX := 1 To Len(aDados)
							cXmlItem += '<SalesInformation>'
							cXmlItem +=		'<CustomerCode>' + aDados[nX, 1] + '</CustomerCode>'						// Cliente e Loja
							cXmlItem +=		'<CustomerInternalId>' + aDados[nX, 2] + '</CustomerInternalId>'			// InternalId do Cliente e Loja
							cXmlItem +=		'<SaleRegistryCode>' + aDados[nX, 3] + '</SaleRegistryCode>'				// Número do R.V.
							cXmlItem +=		'<SaleRegistryInternalId>' + aDados[nX, 4] + '</SaleRegistryInternalId>'	// InternalId do RV
							cXmlItem +=		'<SaleItemCode>' + aDados[nX, 5] + '</SaleItemCode>'						// Item de Venda + Sequencia
							cXmlItem +=		'<SaleItemInternalId>' + aDados[nX, 6] + '</SaleItemInternalId>'			// InternalID do IV

							If ExistBlock("T034LOCXML")
								cXmlPERet := ExecBlock("T034LOCXML", .F., .F., {cXMLRet, aDados, nX})
								If ValType(cXmlPERet) == "C"
									cXmlItem += cXmlPERet
								EndIf
							EndIf
							cXmlItem += '</SalesInformation>'
						Next
					EndIf
					If !Empty(cXmlItem)
						cXmlRet += '<ListOfSaleInformation>' + cXmlItem + '</ListOfSaleInformation>'
					EndIf
				EndIf
		EndCase
	OtherWise
		aAdd(aMessages, {STR0007, 1, 'parse'})	// 'A integração não foi bem sucedida.'
		lRet := .F.
EndCase

If Len(aMessages) > 0 
	lRet    := .F.
	cXmlRet	:= FWEAILOfMessages(aMessages) 
EndIf

RestArea(aArea)

Return {lRet, cXmlRet, cMsgUnica}

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} TI034Qry

Função que monta a query e retorna o RV consultado 

@sample		TI034Qry(cPForne, cPForLj, cRForne, cRForLj, cProd, cSegNeg, cDoc, cCliente, cCliLoja, cTipoDoc, cOperac, cFop, cContato, nTarifa, cDtEmiss)
@param		cPForne
			cPForLj
			cRForne
			cRForLj
			cProd
			cSegNeg
			cDoc
			cCliente
			cCliLoja
			cTipoDoc
			cOperac
			cFop
			cContato
			nTarifa
			cDtEmiss
@return		aRet - Caracter - Código do Cliente (Ex.: 26176436|0001)
				   Caracter - InternalId do Cliente (Ex.: 01||26176436|0001|C)
				   Caracter - Código do Registro de Venda (Ex.: 1815956661)
				   Caracter - Código do Item de Venda (Ex.: 0001|01)
				   Caracter - InternalID do Item de Venda (Ex.: 01|01SP0005|1815956661|0001|01)
				   Caracter - ExternalID do Item de Venda (Ex.: 2510|1943|194320|OBT_ARB|26176436|0001|VOUCHER|571115)
@author 	Jacomo Lisa
@since		05/04/2016
@version 	P12
/*/
//-----------------------------------------------------------------------------------------
Static Function TI034Qry(cPForne, cPForLj, cRForne, cRForLj, cProd, cSegNeg, cDoc, cCliente, cCliLoja, cTipoDoc, cOperac, cFop, cContato, nTarifa, cDtEmiss)

Local aArea		:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local aDados	:= {}
Local aRet		:= {}
Local cQry		:= ""
Local cCli		:= ""
Local cCliLj	:= ""
Local cRv		:= ""
Local cIv		:= ""
Local cIvSeq	:= ""

If !Empty(cPForne) .Or. !Empty(cPForLj)  
	cQry += " AND G3R.G3R_FORNEC = '" + cPForne + "' AND G3R.G3R_LOJA = '" + cPForLj + "' "
EndIf

If !Empty(cRForne) .Or. !Empty(cRForLj)  
	cQry += " AND G3R.G3R_FORREP = '" + cRForne + "' AND G3R.G3R_LOJREP = '" + cRForLj + "' "
EndIf

If !Empty(cCliente) .or. !Empty(cCliLoja)  
	cQry += " AND G3P.G3P_CLIENT = '" + cCliente + "' AND G3P.G3P_LOJA = '"+ cCliLoja + "' "
EndIf

If !Empty(cProd)  
	cQry += " AND G3R.G3R_PROD = '" + cProd + "' "
EndIf

If !Empty(cSegNeg)  
	cQry += " AND G3P.G3P_SEGNEG = '" + cSegNeg + "' "
EndIf

If !Empty(cDoc)  
	cQry += " AND G3Q.G3Q_DOC = '" + cDoc + "' "
EndIf

If !Empty(cTipoDoc)  
	cQry += " AND G3Q.G3Q_TPDOC = '" + cTipoDoc + "' "
EndIf

If !Empty(cOperac)  
	cQry += " AND G3Q.G3Q_OPERAC = '" + cOperac + "' "
EndIf

If !Empty(cFop)  
	cQry += " AND G3Q.G3Q_FORMPG = '" + cFop + "' "
EndIf

If !Empty(cContato)  
	cQry += " AND G3Q.G3Q_SOLIC = '" + cContato + "' "
EndIf

If nTarifa > 0  
	cQry += " AND G44.G44_TARBAS = " + cValToChar(nTarifa)
EndIf

If !Empty(cDtEmiss)  
	cQry += " AND G3Q.G3Q_EMISS = '" + cDtEmiss + "' "
EndIf

cQry := "%" + cQry + "%"

BeginSql Alias cAliasQry
	SELECT G3P_CLIENT, G3P_LOJA, G3P_NUMID, G3Q_IDITEM, G3Q_NUMSEQ, G3P_FILIAL 
	FROM %Table:G3P% G3P
	INNER JOIN %Table:G3Q% G3Q ON G3Q.G3Q_FILIAL = G3P.G3P_FILIAL AND G3Q.G3Q_NUMID = G3P.G3P_NUMID	AND G3Q.%NotDel%
	INNER JOIN %Table:G3R% G3R ON G3R.G3R_FILIAL = G3Q.G3Q_FILIAL AND G3R.G3R_NUMID	= G3Q.G3Q_NUMID	AND G3R.G3R_IDITEM = G3Q.G3Q_IDITEM	AND G3R.G3R_NUMSEQ = G3Q.G3Q_NUMSEQ	AND G3R.%NotDel%
	INNER JOIN %Table:G44% G44 ON G44.G44_FILIAL = G3Q.G3Q_FILIAL AND G44.G44_NUMID	= G3Q.G3Q_NUMID	AND G44.G44_IDITEM = G3Q.G3Q_IDITEM	AND G44.G44_NUMSEQ = G3Q.G3Q_NUMSEQ	AND G44.%NotDel%
	WHERE G3P.G3P_FILIAL = %xFilial:G3P% AND G3P.%NotDel% %Exp:cQry% 
	Order By G3Q_IDITEM, G3Q_NUMSEQ 
EndSql

If (cAliasQry)->(!EOF()) .and. (cAliasQry)->(!BOF())
	(cAliasQry)->(DbGoTop())
	Do While (cAliasQry)->(!EOF())
		cFil   := (cAliasQry)->G3P_FILIAL
		cCli   := (cAliasQry)->G3P_CLIENT
		cCliLj := (cAliasQry)->G3P_LOJA
		cRv	   := Alltrim((cAliasQry)->G3P_NUMID)
		cIv	   := Alltrim((cAliasQry)->G3Q_IDITEM)
		cIvSeq := Alltrim((cAliasQry)->G3Q_NUMSEQ)
		
		aDados := {}
		aAdd(aDados, Alltrim(cCli) + "|" + Alltrim(cCliLj))							// CustomerCode
		aAdd(aDados, IntCliExt(, , cCli, cCliLj)[2])								// CustomerInternalId
		aAdd(aDados, cRv)															// SaleRegistryCode
		aAdd(aDados, TurXMakeId(cRv, "G3P", , cFil))								// SaleRegistryInternalId
		aAdd(aDados, cIv + "|" + cIvSeq)											// SaleItemCode
		aAdd(aDados, TurXMakeId(cRv + "|" + cIv + "|" + cIvSeq, "G3Q", , cFil))		// SaleItemInternalId
		aAdd(aRet, aDados) 
		(cAliasQry)->(DbSkip())
	Enddo
EndIf
(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return aRet