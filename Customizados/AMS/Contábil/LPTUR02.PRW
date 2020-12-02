#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"
#include "TOTVS.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LpTur02   ºAutor  ³TOTVS..             º Data ³  12/2016    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna G4D_PROPRI, baseado no SE5 posicionado.             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function LpTur02(cOpc)

Local aAliasAtu := GetArea()
Local aAliasG3Q := G3Q->(GetArea())
Local aAliasSE5 := SE5->(GetArea())
Local cRet		:= '3' //Caso não encontre nada no resultado da select vai retornar 3
//Local cAli		:= "TRG85"
Local cAliTRG85	:= GetNextAlias()
Local cE5Filial := ""
Local cE5Prefixo:= ""
Local cE5Numero := ""
Local cDelG4D	:= "%G4D.D_E_L_E_T_ <> '*'%"
Local cDelG4C	:= "%G4C.D_E_L_E_T_ <> '*'%"
Local cDelG90	:= "%G90.D_E_L_E_T_ <> '*'%"
Local cDelG6I	:= "%G6I.D_E_L_E_T_ <> '*'%"
Local cDelG8Y	:= "%G8Y.D_E_L_E_T_ <> '*'%"
Local cDelG8C	:= "%G8C.D_E_L_E_T_ <> '*'%"
Local cDelG85	:= "%G85.D_E_L_E_T_ <> '*'%"

//Default lxLP520 := .f.

If Type('lxLP520') = 'U'
	lxLP520 := .f.
EndIf

If Type('cAliasQ2') = 'U'
	cAliasQ2 := ''
EndIf

//Se o registro posicionado for PA, preciso procurar o titulo desse adiantamento
If Alltrim(SE5->E5_TIPO) == 'PA' .AND. Alltrim(SE5->E5_TIPODOC) == 'BA'
	dbSelectArea("SE5")
	dbSetOrder(7)//Filial+Prefixo+Numero+Parcela+Tipo+Fornecedor+Loja
	dbSeek(xFilial("SE5")+Alltrim(SE5->E5_DOCUMEN))
	If !Found()
		Return 0
	EndIf
EndIf

cE5Filial := SE5->E5_FILIAL
cE5Prefixo:= SE5->E5_PREFIXO
cE5Numero := SE5->E5_NUMERO
cRecPag   := SE5->E5_RECPAG

//Tratamento abaixo no caso de mais de uma FOP por RV
If lxLP520 .and. !Empty(cAliasQ2) //Essa variavel é criada LP_520_TUR_BX.prw
	lxOk := .t.
	c85FilRef 	:= (cAliasQ2)->G85_FILREF
	c85RegVen	:= (cAliasQ2)->G85_REGVEN
	c85ItRv 	:= (cAliasQ2)->G85_ITVEND
	c85SeqRv	:= (cAliasQ2)->G85_SEQIV
EndIf

If Select((cAliTRG85)) > 0
	DbSelectArea((cAliTRG85))
	dbCloseArea()
EndIf

If cOpc = '2' // 2 = Rotinas de Faturas de Apuração
	BeginSQL Alias cAliTRG85
		SELECT G4D_PROPRI
		FROM %table:G4C% G4C (NOLOCK)
		INNER JOIN %table:G4D% G4D (NOLOCK) ON
		G4D_FILIAL = G4C.G4C_FILIAL
		AND	G4D_NUMID = G4C.G4C_NUMID
		//		AND G4D.%NotDel%
		AND %Exp:cDelG4D%
		WHERE G4C_FILREF = %Exp:G85->G85_FILIAL%
		AND G4C_CODAPU = %Exp:G85->G85_CODAPU%
		//		AND G4C.%NotDel%
		AND %Exp:cDelG4C%
	EndSQL
	
	If Select((cAliTRG85)) > 0
		
		DbSelectArea((cAliTRG85))
		
		If ALLTRIM((cAliTRG85)->G4D_PROPRI) == "1" //Cartão do Cliente
			cRet := "1"
		ElseIf ALLTRIM((cAliTRG85)->G4D_PROPRI) == "2" //Cartão da Agencia
			cRet := "2"
		Else
			G3Q->(DbSetOrder(1))
			IF G85->G85_PREFIX == 'APU' //Apuração de Clientes
				G3Q->(DbSetOrder(1))
				IF G3Q->(DbSeek(xFilial("G3Q")+(_cAliasG4C)->(G4C_NUMID+G4C_IDITEM+G4C_NUMSEQ),.F.)) .AND. G3Q->G3Q_FORMPG == "000011"
					cRet := "1"
				ELSE
					cRet := "3"
				ENDIF
			ELSE
				cRet := "3"
			ENDIF
		ENDIF
		(cAliTRG85)->(dbCloseArea())
	ENDIF
	
Else     //1 = Rotina do Financeiro Baixas Receber e Pagar
	If ALLTRIM(SE5->E5_PREFIXO) == 'FTC'
		BeginSQL Alias cAliTRG85
			SELECT G4D_PROPRI
			FROM %table:G90% G90 (NOLOCK)
			INNER JOIN %table:G4C% G4C (NOLOCK) ON
			G4C_CARTUR = G90.G90_CODIGO
			AND G4C_FATCAR = G90.G90_NUMFAT
			AND G4C_PAGREC = '1'
			//			AND G4C.%NotDel%
			AND %Exp:cDelG4C%
			INNER JOIN %table:G4D% G4D (NOLOCK) ON
			G4D_FILIAL = G4C.G4C_FILIAL
			AND G4D_NUMID = G4C.G4C_NUMID
			//			AND G4D.%NotDel%
			AND %Exp:cDelG4D%
			WHERE G90_FILIAL = %Exp:xFilial("G90")%
			AND G90_PREFIX = %Exp:cE5Prefixo%
			AND G90_NUMTIT = %Exp:cE5Numero%
			//			AND G90.%NotDel%
			AND %Exp:cDelG90%
		EndSQL
	ElseIf ALLTRIM(SE5->E5_PREFIXO) == 'APU'
		BeginSQL Alias cAliTRG85
			SELECT G4D_PROPRI
			FROM %table:G4C% G4C (NOLOCK)
			INNER JOIN %table:G4D% G4D (NOLOCK) ON
			G4D_FILIAL = G4C.G4C_FILIAL
			AND	G4D_NUMID = G4C.G4C_NUMID
			//			AND G4D.%NotDel%
			AND %Exp:cDelG4D%
			WHERE G4C_FILREF = %Exp:cE5Filial%
			AND G4C_CODAPU = %Exp:cE5Numero%
			//			AND G4C.%NotDel%
			AND %Exp:cDelG4C%
		EndSQL
	ElseIf ALLTRIM(SE5->E5_PREFIXO) == 'FAP'
		BeginSQL Alias cAliTRG85
			SELECT G4D_PROPRI
			FROM %table:G8Y% G8Y (NOLOCK)
			INNER JOIN %table:G6I% G6I (NOLOCK) ON
			G6I_FILIAL = %Exp:xFilial("G6I")%
			AND G6I_FATURA = G8Y.G8Y_FATURA
			//			AND G6I.%NotDel%
			AND %Exp:cDelG6I%
			INNER JOIN %table:G4D% G4D (NOLOCK) ON
			G4D_FILIAL = G8Y.G8Y_FILREF
			AND G4D_NUMID = G6I.G6I_NUMID
			//			AND G4D.%NotDel%
			AND %Exp:cDelG4D%
			WHERE G8Y_FILREF = %Exp:cE5Filial%
			AND G8Y_PREFIX = %Exp:cE5Prefixo%
			AND G8Y_NUM = %Exp:cE5Numero%
			//			AND G8Y.%NotDel%
			AND %Exp:cDelG8Y%
		EndSQL
	ElseIf ALLTRIM(SE5->E5_PREFIXO) == 'FTI'
		BeginSQL Alias cAliTRG85
			SELECT G4D_NUMID, G4D_PROPRI
			FROM %table:G8C% G8C (NOLOCK)
			INNER JOIN %table:G4C% G4C (NOLOCK) ON
			G4C_FILIAL = G8C_FILEFE
			AND G4C_CONINU = G8C_CONCIL
			AND G4C_CLIFOR = '2'
			//			AND G4C.%NotDel%
			AND %Exp:cDelG4C%
			INNER JOIN %table:G4D% G4D (NOLOCK) ON
			G4D_FILIAL = G4C_FILIAL
			AND G4D_NUMID = G4C_NUMID
			//			AND G4D.%NotDel%
			AND %Exp:cDelG4D%
			WHERE G8C_FILIAL = %Exp:cE5Filial%
			AND G8C_FATURA = %Exp:cE5Numero%
			AND G8C_SERIE = %Exp:cE5Prefixo%
			//			AND G8C.%NotDel%
			AND %Exp:cDelG8C%
		EndSQL
	Else
		If lxLP520 .and. !Empty(cAliasQ2) //Essa variavel é criada LP_520_TUR_BX.prw
			//Essa query é para ratamento abaixo no caso de mais de uma FOP por RV
			BeginSQL Alias cAliTRG85
				SELECT G4D_PROPRI
				FROM %table:G4D% G4D  (NOLOCK)
				WHERE G4D_FILIAL = %Exp:c85FilRef%
				AND G4D_NUMID = %Exp:c85RegVen%
				AND G4D_IDITEM = %Exp:c85ItRv%
				AND G4D_NUMSEQ = %Exp:c85SeqRv%
				//				AND G4D.%NotDel%
				AND %Exp:cDelG4D%
			EndSQL
		Else
			BeginSQL Alias cAliTRG85
				SELECT G4D_PROPRI
				FROM %table:G85% G85 (NOLOCK)
				INNER JOIN %table:G4D% G4D  (NOLOCK) ON
				G4D_FILIAL = %Exp:cE5Filial%
				AND G4D_NUMID = G85_REGVEN
				//				AND G4D.%NotDel%
				AND %Exp:cDelG4D%
				WHERE G85_FILREF = %Exp:cE5Filial%
				AND G85_PREFIX = %Exp:cE5Prefixo%
				AND G85_NUMFAT = %Exp:cE5Numero%
				//				AND G85.%NotDel%
				AND %Exp:cDelG85%
			EndSQL
		EndIf
	EndIf
	
	If Select((cAliTRG85)) > 0
		
		DbSelectArea((cAliTRG85))
		
		If ALLTRIM((cAliTRG85)->G4D_PROPRI) == "1" //Cartão do Cliente
			cRet := "1"
		Elseif ALLTRIM((cAliTRG85)->G4D_PROPRI) == "2" //Cartão da Agencia
			cRet := "2"
		Else
			G3Q->(DbSetOrder(1))
			//IF __cTurProcess == "R" - Foi comentado em 06/11/17 pois estava dando erro de variavel não existe em __cTurProcess
			IF cRecPag == "R"
				IF SE5->E5_PREFIXO == 'APU' //Apuração de Clientes
					G3Q->(DbSetOrder(1))
					//IF G3Q->(DbSeek(xFilial("G3Q")+(cAliasQ2)->(G4C_NUMID+G4C_IDITEM+G4C_NUMSEQ+G4C_CONINU),.F.)) .AND. G3Q->G3Q_FORMPG == "000011"
					IF G3Q->(DbSeek(xFilial("G3Q")+G4C->(G4C_NUMID+G4C_IDITEM+G4C_NUMSEQ+G4C_CONINU),.F.)) .AND. G3Q->G3Q_FORMPG == "000011"
						cRet := "1"
					ELSE
						cRet := "3"
					ENDIF
				ELSE
					//G4C->(DbSetOrder(1))
					//IF G4C->( DbSeek(xFilial("G4C")+(iif(SE5->E5_PREFIXO=='JUR',cAliasQ1,cAliasQ2))->G85_REGVEN,.F.) )
					G3Q->(DbSetOrder(1))
					IF G3Q->(DbSeek(xFilial("G3Q")+G4C->(G4C_NUMID+G4C_IDITEM+G4C_NUMSEQ+G4C_CONINU),.F.)).AND. G3Q->G3Q_FORMPG == "000011"
						cRet := "1"
					ELSE
						cRet := "3"
					ENDIF
				ENDIF
			ELSEIF cRecPag == "P" //__cTurProcess == "P"
				IF G3Q->(DbSeek(xFilial("G3Q")+G4C->(G4C_NUMID+G4C_IDITEM+G4C_NUMSEQ+G4C_CONINU),.F.)).AND. G3Q->G3Q_FORMPG == "000011"
					cRet := "1"
				ELSE
					cRet := "3"
				ENDIF
			ENDIF
		ENDIF
//		(cAliTRG85)->(dbCloseArea())
	ENDIF
EndIf

If Select((cAliTRG85)) > 0
	DbSelectArea((cAliTRG85))
	dbCloseArea()
EndIf

RestArea(aAliasG3Q)
RestArea(aAliasSE5)
RestArea(aAliasAtu)

Return(cRet)