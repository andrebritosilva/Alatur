#include "PROTHEUS.CH"
#include "topconn.ch"
#include "FwMvcDef.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA461	 ºAutor  ³Totvs     º Data ³  11/10/16            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava mensagem da NFS/RPS campo F2_MEMNOTA.                º±±
±±º          ³ 									                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12 - Alatur - TURA045A                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SF2460I()
Local lGerNF    := ISINCALLSTACK('TA45GerNFS') //Gera Nota de Saída Faturamento de Vendas - Apuração
local lGerNFConc:= ISINCALLSTACK('TA042EfNFS') //Gera Nota de Saída Efetivação de Conciliação Aérea - Terrestre


If lGerNF .AND. ( ISINCALLSTACK("TURA044V") .OR. ISINCALLSTACK("TURA044A") ) // Fatura de vendas / apuração
	TurNfFat()
ElseIf lGerNFConc .AND. ISINCALLSTACK("TA039EFET") // Efetivação de conciliação aérea
	NFConcAer()
Elseif lGerNFConc .AND. ISINCALLSTACK("TA042AEFET") // Efetivação de conciliação terrestre
	NFConcTe()
Endif

Return	

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TurNfFat
Ponto de entrada para F2_MENNOT  Nota Fiscal de Saida - Fatura de vendas / Apuração

@author Odair Faria
@since 09/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------------------
Static Function TurNfFat()
Local _aGetArea := GetArea()
Local _aAreaG84 := G84->(GetArea())
Local _aAreaG85	:= G85->(GetArea())
Local _aAreaG48	:= G48->(GetArea())
Local _aAreaG3P	:= G3P->(GetArea())
Local _aAreaG8E	:= G8E->(GetArea())
Local _aAreaSA1	:= SA1->(GetArea())
Local _aAreaSF2	:= SF2->(GetArea())
Local _aAreaG6L	:= G6L->(GetArea())
Local cMensagem := ''
Local _cQuery1  := '' //Query para buscar os Passageiros
Local _cAlias1  := GetNextAlias()	//Função GetNextAlias() pega proximo Alias disponivel
Local _cNome    := '' //Nomes de Passageiro, Hospede, Motorista
Local _cDtIni   := '' //Data in do passageiro, hospede, motorista
Local _cDtFim   := '' //Data out do passageiro, hospede, motorista
Local _cAglphm  := '' //Aglutina passageiro, hospede, motorista
Local _cTipFor  := '' //Indica se Fornecedor/cliente é nacional ou internacional
Local _cNomEve  := '' //Nome do Evento
Local _cObsFat  := '' //Obsevação do Registro de Venda
Local _cNumID   := '' //Numero do Registro de Venda
Local _cDtApuI  := '' //Data inicio da Apuração
Local _cDtApuF  := '' //Data fim da Apuração
Local _cPreApu  := GetMV('MV_PFXAPU')
Local _cPreFat  := GetMV('MV_PFXFAT')         
Local _cTrib    := '' //Valor Aproxima dos Tributos (ISS/INSS/CSLL/COFINS//PIS/IRRF) - Somados
Local _cObs     := '' //Buscar observação do campo G48_MSGOBS
Local cQrySA1	:= GetNextAlias()
Local lGerNF    := ISINCALLSTACK('TA45GerNFS') //Gera Nota de Saída Faturamento de Vendas - Apuração
local lGerNFConc:= ISINCALLSTACK('TA042EfNFS') //Gera Nota de Saída Efetivação de Conciliação Aérea - Terrestre
Local cFilLog   := cFilAnt 
Local nLine     := 0   
Local aSaveLines := FWSaveRows()

oModelG84 := oModelAux045A:GetModel( 'G84_MASTER' )
oModelG85 := oModelAux045A:GetModel( 'G85_DETAIL' )

_cPrefixo := oModelG84:GetValue( 'G84_PREFIX' )
_cCliente := oModelG84:GetValue( 'G84_CLIENT' )
_cLojaCli := oModelG84:GetValue( 'G84_LOJA'   )

For nLine := 1 to oModelG85:Length()
	oModelG85:GoLine( nLine )
	If (oModelG85:GetValue("G85_TIPO") == '3' .AND. oModelG85:GetValue("G85_FILREF") == cFilLog)
		_cObs     := Alltrim(oModelG84:GetValue( 'G84_MSGOBS' ))

		//If Empty(oModelG85:GetValue( 'G85_REGVEN' ))
		If Empty (oModelG85:GetValue("G85_REGVEN"))
			DbSelectArea("G48")
			DBORDERNICKNAME('FILAPUR')
			If G48->(DbSeek(oModelG85:GetValue("G85_FILREF")+oModelG85:GetValue("G85_CODAPU")))
				_cNumID := G48->G48_NUMID
			EndIf
		Else
			DbSelectArea("G3P")
			DbSetOrder(1)	// G3P_FILIAL+G3P_NUMID+G3P_SEGNEG
			If Empty(_cNumID)
				//If MsSeek((_cAlias3)->(G85_FILREF + G85_REGVEN)+'2',.T.) //2 = Segmento Evento
				If DbSeek(oModelG85:GetValue("G85_FILREF") + oModelG85:GetValue("G85_REGVEN") + '2')
					_cNomEve := ALLTRIM(G3P->G3P_NOMEUN)
					_cObsFat := StrTran(G3P->G3P_OBS, CRLF, ' ') 
				EndIf
			Else
				//If MsSeek(oModelG85:GetValue( 'G85_FILREF' )+_cNumID+'2',.T.) //2 = Segmento Evento
				If DbSeek(oModelG85:GetValue("G85_FILREF") + _cNumID + '2')
					_cNomEve := ALLTRIM(G3P->G3P_NOMEUN)
					_cObsFat := StrTran(G3P->G3P_OBS, CRLF, ' ') 
				EndIf
			EndIf
		EndIf

		//Seleciona Razão Social do Cliente que é um Fornecedor;
		//Este ponto só funicona para o Cliente Alatur, pois, o código e loja de Fornecedor é igual ao de Cliente;
		BeginSQL Alias cQrySA1
			SELECT A1_EST, A1_TIPO
			FROM %Table:SA1% SA1 (NOLOCK)
			WHERE SA1.A1_FILIAL	=	%xFilial:SA1%
			AND SA1.A1_COD		=	%Exp:_cCliente%
			AND SA1.A1_LOJA		=	%Exp:_cLojaCli%
			AND SA1.%NotDel%
		EndSql
		_cFornec := Alltrim((cQrySA1)->A1_EST)  //EX = INTERNACIONAL
		_cTipFor := Alltrim((cQrySA1)->A1_TIPO) //X = INTERNACIONAL
		(cQrySA1)->(dbCloseArea())
		//Query para buscar o nome dos Passageiros, Hospedes e Motoristas;
		IF !Empty(oModelG85:GetValue( 'G85_REGVEN' ))  
			If ALLTRIM(oModelG85:GetValue( 'G85_GRPPRD' )) = 'AE' //Aéreo
				_cQuery1 := "SELECT DISTINCT G3T_FILIAL, G3T_NUMID, G3T_NOMPAX, G3T_DTSAID, G3T_DTCHEG FROM " + RetsqlName("G3T")
				_cQuery1 += " WHERE G3T_FILIAL = '"+oModelG85:GetValue( 'G85_FILREF' )+ "'"
				If Empty(_cNumID)
					_cQuery1 += " AND G3T_NUMID = '"+oModelG85:GetValue( 'G85_REGVEN' )+"'"
				Else
					_cQuery1 += " AND G3T_NUMID = '"+_cNumID+"'"
				EndIf
				_cQuery1 += " AND D_E_L_E_T_ <> '*'"
				_cQuery1 += " AND R_E_C_N_O_ > 0"

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery1),_cAlias1,.T.,.T.)

				DbSelectArea(_cAlias1)
				(_cAlias1)->(DbGotop())

				While (_cAlias1)->(!EOF()) .AND. (_cAlias1)->G3T_FILIAL == oModelG85:GetValue( 'G85_FILREF' ) .AND. (_cAlias1)->G3T_NUMID == IIF(Empty(_cNumID),oModelG85:GetValue( 'G85_REGVEN' ),_cNumID)
					If !_cNome $ Alltrim((_cAlias1)->G3T_NOMPAX)
						_cNome  := ALLTRIM((_cAlias1)->G3T_NOMPAX) + ' '
						_cDtIni := DTOC(STOD((_cAlias1)->G3T_DTSAID))
						_cDtFim := DTOC(STOD((_cAlias1)->G3T_DTCHEG))
						_cAglphm += _cNome + ' ' + _cDtIni + ' a ' + _cDtFim + ' '
					EndIf
					(_cAlias1)->(DbSkip())
				EndDo

				(_cAlias1)->(DbCloseArea())

			ElseIf ALLTRIM(oModelG85:GetValue( 'G85_GRPPRD' )) = 'HO' //Hotel
				_cQuery1 := "SELECT DISTINCT G3U_FILIAL, G3U_NUMID, G3U_NOMPAX, G3U_DTINI, G3U_DTFIM FROM " + RetsqlName("G3U")
				_cQuery1 += " WHERE G3U_FILIAL = '"+oModelG85:GetValue( 'G85_FILREF' )+ "'"
				If Empty(_cNumID)
					_cQuery1 += " AND G3U_NUMID = '"+oModelG85:GetValue( 'G85_REGVEN' )+"'"
				Else
					_cQuery1 += " AND G3U_NUMID = '"+_cNumID+"'"
				EndIf
				_cQuery1 += " AND D_E_L_E_T_ <> '*'"
				_cQuery1 += " AND R_E_C_N_O_ > 0"

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery1),_cAlias1,.T.,.T.)
				DbSelectArea(_cAlias1)
				(_cAlias1)->(DbGotop())

				While (_cAlias1)->(!EOF()) .AND. (_cAlias1)->G3U_FILIAL == oModelG85:GetValue( 'G85_FILREF' ) .AND. (_cAlias1)->G3U_NUMID == IIF(Empty(_cNumID),oModelG85:GetValue( 'G85_REGVEN' ),_cNumID)
					If !_cNome $ Alltrim((_cAlias1)->G3U_NOMPAX)
						_cNome  := ALLTRIM((_cAlias1)->G3U_NOMPAX) + ' '
						_cDtIni := DTOC(STOD((_cAlias1)->G3U_DTINI))
						_cDtFim := DTOC(STOD((_cAlias1)->G3U_DTFIM)) 
						_cAglphm += _cNome + ' ' + _cDtIni + ' a ' + _cDtFim + ' '
					EndIf
					(_cAlias1)->(DbSkip())
				EndDo
				(_cAlias1)->(DbCloseArea())	
						
			ElseIf ALLTRIM(oModelG85:GetValue( 'G85_GRPPRD' )) = 'CA' //Carro
				_cQuery1 := "SELECT DISTINCT G3V_FILIAL, G3V_NUMID, G3V_NOMPAX, G3V_DTINI, G3V_DTFIM FROM " + RetsqlName("G3V")
				_cQuery1 += " WHERE G3V_FILIAL = '"+oModelG85:GetValue( 'G85_FILREF' )+ "'"
				If Empty(_cNumID)
					_cQuery1 += " AND G3V_NUMID = '"+oModelG85:GetValue( 'G85_REGVEN' )+"'"
				Else
					_cQuery1 += " AND G3V_NUMID = '"+_cNumID+"'"
				EndIf
				_cQuery1 += " AND D_E_L_E_T_ <> '*'"
				_cQuery1 += " AND R_E_C_N_O_ > 0"

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery1),_cAlias1,.T.,.T.)

				DbSelectArea(_cAlias1)
				(_cAlias1)->(DbGotop())

				While (_cAlias1)->(!EOF()) .AND. (_cAlias1)->G3V_FILIAL == oModelG85:GetValue( 'G85_FILREF' ) .AND. (_cAlias1)->G3V_NUMID == IIF(Empty(_cNumID),oModelG85:GetValue( 'G85_REGVEN' ),_cNumID)
					If !_cNome $ Alltrim((_cAlias1)->G3V_NOMPAX)
						_cNome  := ALLTRIM((_cAlias1)->G3V_NOMPAX) + ' '
						_cDtIni := DTOC(STOD((_cAlias1)->G3V_DTINI))
						_cDtFim := DTOC(STOD((_cAlias1)->G3V_DTFIM)) 
						_cAglphm += _cNome + ' ' + _cDtIni + ' a ' + _cDtFim + ' '
					EndIf
					(_cAlias1)->(DbSkip())
				EndDo 
				(_cAlias1)->(DbCloseArea())
			Endif
		Endif

		//Inicio das Regra RONALDO:
		//FEE Corporativo- cobrado por apuração
		If ALLTRIM(_cPrefixo) = ALLTRIM(_cPreApu) .AND. ALLTRIM(oModelG85:GetValue('G85_SEGNEG')) $ '1/3' .AND. SUBSTR(oModelG85:GetValue('G85_CLASS'),1,1) = 'C'
			cMensagem := 'Remuneracao pela intermediacao FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + IIF(Empty(oModelG85:GetValue('G85_CODAPU')),'',' Apuracao: ' + ALLTRIM(oModelG85:GetValue('G85_CODAPU'))) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))

		//FEE Corporativo - cobrado em fatura
		ElseIf ALLTRIM(_cPrefixo) = ALLTRIM(_cPreFat) .AND. ALLTRIM(oModelG85:GetValue('G85_SEGNEG')) $ '1/3'
			cMensagem := 'Remuneracao pela intermediacao FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' ' + IIF(!Empty(_cAglphm),Alltrim(_cAglphm),'') + IIF(Empty(oModelG85:GetValue( 'G85_REGVEN' )),'',' Registro de Venda: ' + ALLTRIM(oModelG85:GetValue('G85_REGVEN'))) //+ ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))

		//FEE Eventos - cobrado por apuração
		ElseIf ALLTRIM(_cPrefixo) = ALLTRIM(_cPreApu) .AND. ALLTRIM(oModelG85:GetValue('G85_SEGNEG')) = '2' .AND. SUBSTR(oModelG85:GetValue('G85_CLASS'),1,1) = 'C'
//			cMensagem := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Remuneracao pela intermediacao de eventos FT:' + ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + IIF(Empty(oModelG85:GetValue('G85_CODAPU')),'',' Apuracao: ' + ALLTRIM(oModelG85:GetValue('G85_CODAPU'))) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
			cMensagem := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Remuneracao pela intermediacao de eventos FT:' + ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' ' + _cObsFat

		//FEE Eventos - cobrado em fatura
		ElseIf ALLTRIM(_cPrefixo) = ALLTRIM(_cPreFat) .AND. ALLTRIM(oModelG85:GetValue('G85_SEGNEG')) = '2'
			If _cTipFor = 'X' .OR. _cFornec = 'EX'
//				cMensagem := 'Remuneracao pela intermediacao de eventos FT:' + ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' ' + IIF(!Empty(_cNomEve),Alltrim(_cNomEve),'') + IIF(Empty(oModelG85:GetValue( 'G85_REGVEN' )),'',' Registro de Venda: ' + ALLTRIM(oModelG85:GetValue( 'G85_REGVEN' ))) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
				cMensagem := 'Remuneracao pela intermediacao de eventos FT:' + ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' ' + IIF(!Empty(_cNomEve),Alltrim(_cNomEve),'') + ' ' + _cObsFat
			Else
//				cMensagem := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Remuneracao pela intermediacao de eventos FT:' + ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' ' + IIF(!Empty(_cNomEve),Alltrim(_cNomEve),'') + IIF(Empty(oModelG85:GetValue( 'G85_REGVEN' )),'',' Registro de Venda: ' + ALLTRIM(oModelG85:GetValue( 'G85_REGVEN' ))) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
				cMensagem := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Remuneracao pela intermediacao de eventos FT:' + ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' ' + _cObsFat 
			EndIf

		//Comissão Corporativa por apuração + Comissão Corporativa Faturada
		ElseIf ALLTRIM(oModelG85:GetValue('G85_SEGNEG')) $ '1/3' .AND. SUBSTR(oModelG85:GetValue('G85_CLASS'),1,1) = 'F'
			If ALLTRIM(oModelG85:GetValue('G85_GRPPRD')) = 'AE'
				If !Empty(oModelG85:GetValue('G85_CODAPU'))
					cMensagem := 'Comissao pela intermediacao de reservas FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' Apuracao: ' + ALLTRIM(oModelG85:GetValue('G85_CODAPU')) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
				Else
					cMensagem := 'Comissao pela intermediacao de reservas FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' Registro de Venda: ' + ALLTRIM(oModelG85:GetValue( 'G85_REGVEN' )) + IIF(!Empty(_cAglphm),Alltrim(_cAglphm)+' ','') + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
				EndIf
			Else
				If !Empty(oModelG85:GetValue('G85_CODAPU'))                                                           //' Apuração: ' + ALLTRIM(oModelG85:GetValue('G85_CODAPU'))
					If _cTipFor = 'X' .OR. _cFornec = 'EX'
						cMensagem := 'Comissao pela intermediacao de reservas FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' Apuracao: ' + ALLTRIM(oModelG85:GetValue('G85_CODAPU')) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
					Else
						cMensagem := 'SUJEITO A RETENCAO DE 1,5% IR - Comissao pela intermediacao de reservas FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' Apuracao: ' + ALLTRIM(oModelG85:GetValue('G85_CODAPU')) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
					EndIf
				Else
					If _cTipFor = 'X' .OR. _cFornec = 'EX'
						cMensagem := 'Comissao pela intermediacao de reservas FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' Registro de Venda: ' + ALLTRIM(oModelG85:GetValue( 'G85_REGVEN' )) + IIF(!Empty(_cAglphm),' ' + Alltrim(_cAglphm),'') + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
					Else
						cMensagem := 'SUJEITO A RETENCAO DE 1,5% IR - Comissao pela intermediacao de reservas FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' Registro de Venda: ' + ALLTRIM(oModelG85:GetValue( 'G85_REGVEN' )) + IIF(!Empty(_cAglphm),' ' + Alltrim(_cAglphm),'') + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
					EndIf
				EndIf
			EndIf

		//Comissão Eventos por apuração + Comissão Eventos Fatura
		ElseIf ALLTRIM(oModelG85:GetValue('G85_SEGNEG')) = '2' .AND. SUBSTR(oModelG85:GetValue('G85_CLASS'),1,1) = 'F'
			If _cTipFor = 'X' .OR. _cFornec = 'EX'
//				cMensagem := 'Comissao pela intermedicao de reservas de eventos FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + IIF(!Empty(_cNomEve),' ' + Alltrim(_cNomEve),'') + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
				cMensagem := 'Comissao pela intermedicao de reservas de eventos FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + IIF(!Empty(_cNomEve),' ' + Alltrim(_cNomEve),'') + ' ' + _cObsFat
			Else
//				cMensagem := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Comissao pela intermediacao de reservas de eventos FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + IIF(!Empty(_cNomEve),' ' + Alltrim(_cNomEve),'') + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
				cMensagem := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Comissao pela intermediacao de reservas de eventos FT: '+ ALLTRIM(oModelG84:GetValue('G84_NUMFAT')) + ' ' + _cObsFat
			EndIf

		//Meta / Comissão de AE
		ElseIf SUBSTR(oModelG85:GetValue( 'G85_CLASS' ), 1,1) = 'M'
			DbSelectArea("G6L")
			G6L->(DbSetOrder(1))
			If G6L->(DbSeek(xFilial("G6L")+oModelG85:GetValue( 'G85_CODAPU' )))
				_cDtApuI := DTOC(G6L->G6L_DTINI)
				_cDtApuF := DTOC(G6L->G6L_DTFIM)
			EndIf
			//cMensagem := 'Incentivo variavel de vendas nacional/internacional ' + IIF(Empty(oModelG85:GetValue('G85_CODAPU')),' FT: ' + ALLTRIM(oModelG84:GetValue('G84_NUMFAT')),' Apuracao: ' + ALLTRIM(oModelG85:GetValue('G85_CODAPU'))) + IIF(!Empty(_cDtApuI) .AND. !Empty(_cDtApuF),' Ref. periodo de ' + ALLTRIM(_cDtApuI) + ' ate ' + ALLTRIM(_cDtApuF),'') //+ ALLTRIM(CVALTOCHAR(MONTH(oModelG84:GetValue('G84_EMISS')))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(oModelG84:GetValue('G84_EMISS'))))
			cMensagem := G6L->G6L_OBSFAT + ' FT: ' + oModelG84:GetValue('G84_NUMFAT')
		EndIf

		//Grava mensagem personalizada Alatur para transmissão das notas fiscais de serviços
		DbSelectArea("SF2")
		SF2->(DbSetOrder(1))

		If SF2->(DbSeek(oModelG85:GetValue( 'G85_FILREF' )+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
			//Informar valores dos tributos
			If SF2->(F2_VALISS+F2_VALINSS+F2_VALCSLL+F2_VALCOFI+F2_VALPIS+F2_VALIRRF) > 0
				_cTrib := 'Vlr Aprox Trib: R$ '+ALLTRIM(STR(SF2->(F2_VALISS+F2_VALINSS+F2_VALCSLL+F2_VALCOFI+F2_VALPIS+F2_VALIRRF)))+' '
			EndIf   

			//Mensagens Nota Fiscal de Saída: Tributos, Observação (Campo Memo) e Outras conforme regras acima....
			cMensagem := _cTrib + IIF(Len(_cObs)>0,_cObs+' ','') + cMensagem
			cMensagem := cMensagem + IIF(!Empty(cMensagem) .AND. LEN(cMensagem) < 194,' OBS: Cancelamento da NF somente dentro do mes de competencia','') 
			cMensagem := STRTRAN(cMensagem, '|','') //Tira acentuação: FwNoAccent(cMensagem)
			RecLock("SF2",.F.)
			SF2->F2_MENNOTA := SubStr(ALLTRIM(cMensagem), 1, TamSX3("F2_MENNOTA")[1]) 
			SF2->(MsUnlock())

		EndIf
	EndIF
Next

//Retorna area para posição da rotina padrão as tabelas abaixo:
RestArea(_aAreaG84)
RestArea(_aAreaG85)
RestArea(_aAreaG48)
RestArea(_aAreaG3P)
RestArea(_aAreaG8E)
RestArea(_aAreaSA1)
RestArea(_aAreaSF2)
RestArea(_aAreaG6L)
RestArea(_aGetArea)

FwRestRows( aSaveLines )

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} NFConcAer
Ponto de entrada para F2_MENNOT  Nota Fiscal de Saida - Conciliação Aérea

@author Odair Faria
@since 09/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------------------
Static Function NFConcAer()
Local _aGetArea  := GetArea()
Local _aAreaSA1	 := SA1->(GetArea())
Local _aAreaSA2	 := SA2->(GetArea())
Local _aAreaSF2	 := SF2->(GetArea())
Local cAliasG3R	 := ''
Local _cMsg      := ''
Local _cTrib     := ''
Local _cFornec   := ''
Local _cTipFor   := ''
Local _cCodCli   := ''
Local _cLojCli   := ''
Local _cFatura   := ''
Local nLine      := 0
Local oModel	 := Nil
Local oModelG6H  := Nil
Local aSaveLines := FWSaveRows()

If ISINCALLSTACK('TA042EfNFS')
	oModelG6H := oModel:GetModel("G6H_MASTER")

	For nLine := 1 to oModelG6H:Length()
		oModelG6H:GoLine( nLine )

		_cFatura := oModelG6H:GetValue('G6H_FATURA')

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))

		DbSelectArea("SF2")
		SF2->(DbSetOrder(1))

		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))


		cAliasG3R := GetNextAlias()

		//Query para trazes o Tipo de Segmento
		BeginSql Alias cAliasG3R
			SELECT G3R_FILIAL, G3R_NUMID, G3R_TPSEG, G3P_SEGNEG
			FROM %Table:G3R% G3R
			INNER JOIN %Table:G3P% G3P ON
			G3P_FILIAL = G3R_FILIAL AND
			G3P_NUMID = G3R_NUMID AND
			G3P.%notDel%
			WHERE G3R_FILIAL = %Exp:G6H->G6H_FILIAL%
			AND G3R_FATURA = %Exp:oModelG6H:GetValue('G6H_FATURA')% 
			AND G3R.%notDel%
		EndSql

		//Verificar Nacionalidade do Fornecedor/Cliente
		If SA1->(DbSeek(xFilial("SA1")+G6H->G6H_FORNEC+G6H->G6H_LOJA))
			_cFornec := Alltrim(SA1->A1_EST)  //EX = INTERNACIONAL
			_cTipFor := Alltrim(SA1->A1_TIPO) //X = INTERNACIONAL
		EndIf

		//Seleciona a Aérea da query da tabela G3R
		DbSelectArea(cAliasG3R)
		(cAliasG3R)->( DbGoTop() )

		//Fatura Fornecedor pela Conciliação Aérea			
		If ALLTRIM((cAliasG3R)->G3P_SEGNEG) $ '1/3'
			_cMsg := 'Comissao pela intermediacao de reservas FT: '+ _cFatura + ' Fatura Fornec.: ' + ALLTRIM(G6H->G6H_FATFOR) + ' Ref. ' + ALLTRIM(G6H->G6H_MES) + '/' + ALLTRIM(G6H->G6H_ANO)
		ElseIf  ALLTRIM((cAliasG3R)->(G3P_SEGNEG)) == '2'
			If _cTipFor = 'X' .OR. _cFornec = 'EX'
				_cMsg := 'Comissao pela intermediacao de reservas de eventos FT: '+ _cFatura + ' Fatura Fornec.: ' + ALLTRIM(G6H->G6H_FATFOR) + ' Ref. ' + ALLTRIM(G6H->G6H_MES) + '/' + ALLTRIM(G6H->G6H_ANO)
			Else
				_cMsg := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Comissao pela intermediacao de reservas de eventos FT: '+ _cFatura + ' Fatura Fornec.: ' + ALLTRIM(G6H->G6H_FATFOR) + ' Ref. ' + ALLTRIM(G6H->G6H_MES) + '/' + ALLTRIM(G6H->G6H_ANO)
			EndIf
		EndIf

		If SA2->(DbSeek(xFilial("SA2")+ G6H->G6H_FORNEC+G6H->G6H_LOJA))
			_cCodCli := SA2->A2_CLIENTE
			_cLojCli := SA2->A2_LOJCLI
		EndIf

		//Grava mensagem personalizada Alatur para transmissão das notas fiscais de serviços
		If SF2->(DbSeek(G6H->G6H_FORNEC+G6H->G6H_LOJA+_cCodCli+_cLojCli))

			//Informar valores dos tributos
			If SF2->(F2_VALISS+F2_VALINSS+F2_VALCSLL+F2_VALCOFI+F2_VALPIS+F2_VALIRRF) > 0
				_cTrib := 'Vlr Aprox Trib: R$ '+ALLTRIM(STR(SF2->(F2_VALISS+F2_VALINSS+F2_VALCSLL+F2_VALCOFI+F2_VALPIS+F2_VALIRRF)))+' '
			EndIf   

			//Mensagens Nota Fiscal de Saída: Tributos, Observação (Campo Memo) e Outras conforme regras acima....
			_cMsg := _cTrib + _cMsg
			_cMsg := _cMsg + IIF(!Empty(_cMsg) .AND. LEN(_cMsg) < 194,' OBS: Cancelamento da NF somente dentro do mes de competencia','')
			RecLock("SF2",.F.)
			SF2->F2_MENNOTA := ALLTRIM(_cMsg)
			SF2->(MsUnlock())
		EndIf

		(cAliasG3R)->( dbCloseArea() )

	Next

RestArea(_aAreaSF2)
RestArea(_aAreaSA1)
RestArea(_aAreaSA2)
RestArea(_aGetArea)

FwRestRows( aSaveLines )
Endif


Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} NFConcTe
Ponto de entrada para F2_MENNOT  Nota Fiscal de Saida - Conciliação Terrestre

@author Odair Faria
@since 09/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------------------
Static Function NFConcTe()
Local oModel     := Nil
Local oModelG3R  := Nil
Local _aGetArea  := GetArea()
Local _aAreaSA1	 := SA1->(GetArea())
Local _aAreaSA2	 := SA2->(GetArea())
Local _aAreaSF2	 := SF2->(GetArea())
Local cAliasG3R	 := ''
Local _xRet      := .T.
Local _cMsg      := ''
Local _cTrib     := ''
Local _cFornec   := ''
Local _cTipFor   := ''
Local _cCodCli   := ''
Local _cLojCli   := ''
Local nLine      := 0
Local aSaveLines := FWSaveRows()

If ISINCALLSTACK('TA042EfNFS')
	oModel := oModelAux42I
	oModelG3R := oModel:GetModel('G3R_ITENS')

	For nLine := 1 to oModelG3R:Length()
		oModelG3R:GoLine( nLine )

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))

		DbSelectArea("SF2")
		SF2->(DbSetOrder(1))

		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))

		cAliasG3R := GetNextAlias()
		//Query para trazes o Tipo de Segmento
		BeginSql Alias cAliasG3R
			SELECT G3R_FILIAL, G3R_NUMID, G3R_TPSEG, G3P_SEGNEG, G3R_CONCIL
			FROM %Table:G3R% G3R
			INNER JOIN %Table:G3P% G3P ON
			G3P_FILIAL = G3R_FILIAL AND
			G3P_NUMID = G3R_NUMID AND
			G3P.%notDel%
			WHERE G3R_FILIAL = %xFilial:G8C%
			AND G3R_CONCIL = %Exp:G8C->G8C_CONCIL%
			AND G3R.%notDel%
		EndSql

		//Verificar Nacionalidade do Fornecedor/Cliente
		If SA1->(DbSeek(xFilial("SA1")+G8C->G8C_FORNEC+G8C->G8C_LOJA))
			_cFornec := Alltrim(SA1->A1_EST)  //EX = INTERNACIONAL
			_cTipFor := Alltrim(SA1->A1_TIPO) //X = INTERNACIONAL
		EndIf

		//Seleciona a Aérea da query da tabela G3R
		DbSelectArea(cAliasG3R)
		(cAliasG3R)->( DbGoTop() )

		//Fatura Fornecedor pela Conciliação Terrestre
		If ALLTRIM((cAliasG3R)->G3P_SEGNEG) $ '1/3'
			If _cTipFor = 'X' .OR. _cFornec = 'EX'
				_cMsg := 'Comissao pela intermediacao de reservas FT: '+ ALLTRIM((cAliasG3R)->G3R_CONCIL) + ' Fatura Fornec.: ' + ALLTRIM(G8C->G8C_FATURA) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G8C->G8C_DTCONC))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G8C->G8C_DTCONC)))
			Else
				_cMsg := 'SUJEITO A RETENCAO DE 1,5% IR - Comissao pela intermediacao de reservas FT: ' + ALLTRIM((cAliasG3R)->G3R_CONCIL) + ' Fatura Fornec.: ' + ALLTRIM(G8C->G8C_FATURA) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G8C->G8C_DTCONC))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G8C->G8C_DTCONC)))
			EndIf
		ElseIf  ALLTRIM(%Exp:(cAliasG3R)->(G3P_SEGNEG)%) == '2'
			If _cTipFor = 'X' .OR. _cFornec = 'EX'
				_cMsg := 'Comissao pela intermediacao de reservas de eventos FT: ' + ALLTRIM((cAliasG3R)->G3R_CONCIL) + ' Fatura Fornec.: ' + ALLTRIM(G8C->G8C_FATURA) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G8C->G8C_DTCONC))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G8C->G8C_DTCONC)))
			Else
				_cMsg := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Comissao pela intermediacao de reservas de eventos FT: '+ ALLTRIM((cAliasG3R)->G3R_CONCIL) + ' Fatura Fornec.: ' + ALLTRIM(G8C->G8C_FATURA) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G8C->G8C_DTCONC))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G8C->G8C_DTCONC)))
			EndIf
		EndIf

		//Busca Codigo e loja do Cliente(SF2) na tabela de Fornecedores (SA2)
		If SA2->(DbSeek(xFilial("SA2")+G8C->G8C_FORNEC+G8C->G8C_LOJA))
			_cCodCli := SA2->A2_CLIENTE
			_cLojCli := SA2->A2_LOJCLI
		EndIf

		//Grava mensagem personalizada Alatur para transmissão das notas fiscais de serviços
		If SF2->(DbSeek(xFilial('G8C')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

			//Informar valores dos tributos
			If SF2->(F2_VALISS+F2_VALINSS+F2_VALCSLL+F2_VALCOFI+F2_VALPIS+F2_VALIRRF) > 0
				_cTrib := 'Vlr Aprox Trib: R$ '+ALLTRIM(STR(SF2->(F2_VALISS+F2_VALINSS+F2_VALCSLL+F2_VALCOFI+F2_VALPIS+F2_VALIRRF)))+' '
			EndIf   

			//Mensagens Nota Fiscal de Saída: Tributos, Observação (Campo Memo) e Outras conforme regras acima....
			_cMsg := _cTrib + _cMsg
			_cMsg := _cMsg + IIF(!Empty(_cMsg) .AND. LEN(_cMsg) < 194,' OBS: Cancelamento da NF somente dentro do mes de competencia','')
			RecLock("SF2",.F.)
			SF2->F2_MENNOTA := ALLTRIM(_cMsg)
			SF2->(MsUnlock())
		EndIf

		(cAliasG3R)->( dbCloseArea() )

	Next

RestArea(_aAreaSF2)
RestArea(_aAreaSA1)
RestArea(_aAreaSA2)
RestArea(_aGetArea)


FwRestRows( aSaveLines )
Endif

Return
