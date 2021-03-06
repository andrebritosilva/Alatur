#include "PROTHEUS.CH"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GRVTURSF2	 �Autor  �Totvs     � Data �  11/10/16            ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava mensagem da NFS/RPS campo F2_MEMNOTA.                ���
���          � 									                          ���
�������������������������������������������������������������������������͹��
���Uso       � P12 - Alatur                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function GRVTURSF2(cPrefixo,cNumFat,cClient,cLojaCli)

Local _aGetArea := GetArea()
Local _aAreaG85	:= G85->(GetArea())
Local _aAreaG48	:= G48->(GetArea())
Local _aAreaG3P	:= G3P->(GetArea())
Local _aAreaG8E	:= G8E->(GetArea())
Local _aAreaSA1	:= SA1->(GetArea())
Local _aAreaSF2	:= SF2->(GetArea())
Local _aAreaG6L	:= G6L->(GetArea())
Local cMensagem := ''
Local _cQuery1  := '' //Query para buscar os Passageiros
Local _cAlias1  := GetNextAlias()	//Fun��o GetNextAlias() pega proximo Alias disponivel
Local _cQuery2  := '' //Query para Selecionar as Notas do Turimos para a mesma fatura e cliente
Local _cAlias2  := GetNextAlias()	//Fun��o GetNextAlias() pega proximo Alias disponivel
Local _cQuery3  := '' //Query para Selecionar as Notas do Turimos para a mesma fatura e cliente
Local _cAlias3  := GetNextAlias()	//Fun��o GetNextAlias() pega proximo Alias disponivel
Local _cNome    := '' //Nomes de Passageiro, Hospede, Motorista
Local _cDtIni   := '' //Data in do passageiro, hospede, motorista
Local _cDtFim   := '' //Data out do passageiro, hospede, motorista
Local _cAglphm  := '' //Aglutina passageiro, hospede, motorista
Local _cEstFor  := '' //Indica se Fornecedor/cliente � nacional ou internacional
Local _cTipFor  := '' //Indica se Fornecedor/cliente � nacional ou internacional
Local _cNomEve  := '' //Nome do Evento
Local _cNumID   := '' //Numero do Registro de Venda
Local _cDtApuI  := '' //Data inicio da Apura��o
Local _cDtApuF  := '' //Data fim da Apura��o
Local _cPreApu  := GetMV('MV_PFXAPU')
Local _cPreFat  := GetMV('MV_PFXFAT')         
Local _cTrib    := '' //Valor Aproxima dos Tributos (ISS/INSS/CSLL/COFINS//PIS/IRRF) - Somados
Local _cObs     := '' //Buscar observa��o do campo G48_MSGOBS
Local cQrySA1	:= GetNextAlias()

//Ponto de entrada s� deve ser chamado pelas rotinas de Faturamento Turismo Vendas e Apura��o
If ISINCALLSTACK("TURA044V") .OR. ISINCALLSTACK("TURA044A")
	
	_cObs := ALLTRIM(G84->G84_MSGOBS)
	//Seleciona Nota pela Fatura de Venda e Apura��o
	//Query para buscar o nome dos Passageiros, Hospedes e Motoristas;
	_cQuery2 := "SELECT G8E_FILIAL, G8E_PREFIX, G8E_NUMFAT, G8E_CLIENT, G8E_LOJA, G8E_TIPO, G8E_SERIE, G8E_NUMNF, G8E_FILREF FROM " + RetsqlName("G8E")
	_cQuery2 += " WHERE G8E_FILIAL = '"+xFilial("G84")+ "'"
	_cQuery2 += " AND G8E_PREFIX = '"+cPrefixo+"'"
	_cQuery2 += " AND G8E_NUMFAT = '"+cNumFat+"'"
	_cQuery2 += " AND G8E_CLIENT = '"+cClient+"'"
	_cQuery2 += " AND G8E_LOJA = '"+cLojaCli+"'"
	_cQuery2 += " AND G8E_TIPO = '2'"
	_cQuery2 += " AND D_E_L_E_T_ <> '*'"
	_cQuery2 += " AND R_E_C_N_O_ > 0"
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery2),_cAlias2,.T.,.T.)
	
	DbSelectArea(_cAlias2)
	(_cAlias2)->(DbGotop())
	
	If (_cAlias2)->(!EOF())
		_cQuery3 := "SELECT G85_FILIAL, G85_PREFIX, G85_NUMFAT, G85_FILREF, G85_REGVEN, G85_CODAPU, G85_SEGNEG, G85_CLASS, G85_GRPPRD FROM " + RetsqlName("G85")
		_cQuery3 += " WHERE G85_FILIAL = '"+xFilial("G84")+ "'"
		_cQuery3 += " AND G85_PREFIX = '"+cPrefixo+"'"
		_cQuery3 += " AND G85_NUMFAT = '"+cNumFat+"'"
		_cQuery3 += " AND G85_TIPO = '3'"
		_cQuery3 += " AND D_E_L_E_T_ <> '*'"
		_cQuery3 += " AND R_E_C_N_O_ > 0"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery3),_cAlias3,.T.,.T.)

		DbSelectArea(_cAlias3)
		(_cAlias3)->(DbGotop())
		
		If (_cAlias3)->(!EOF())
			
			If Empty((_cAlias3)->(G85_REGVEN))
				DbSelectArea("G48")
				DBORDERNICKNAME('FILAPUR')
				If MsSeek((_cAlias3)->(G85_FILREF + G85_CODAPU),.T.)
					_cNumID := G48->G48_NUMID
				EndIf
			Else
				DbSelectArea("G3P")
				DbSetOrder(1)
				
				If Empty(_cNumID)
					If MsSeek((_cAlias3)->(G85_FILREF + G85_REGVEN)+'2',.T.) //2 = Segmento Evento
						_cNomEve := ALLTRIM(G3P->G3P_NOMEUN)
					EndIf
				Else
					If MsSeek((_cAlias3)->(G85_FILREF)+_cNumID+'2',.T.) //2 = Segmento Evento
						_cNomEve := ALLTRIM(G3P->G3P_NOMEUN)
					EndIf
				EndIf
				
			EndIf
			
			//Seleciona Raz�o Social do Cliente que � um Fornecedor;
			//Este ponto s� funicona para o Cliente Alatur, pois, o c�digo e loja de Fornecedor � igual ao de Cliente;
/*/			DbSelectArea("SA1")
			DbSetOrder(1)
			If MsSeek(xFilial("SA1")+cClient+cLojaCli,.T.)
				_cFornec := Alltrim(SA1->A1_EST)  //EX = INTERNACIONAL
				_cTipFor := Alltrim(SA1->A1_TIPO) //X = INTERNACIONAL
			EndIf
/*/
			BeginSQL Alias cQrySA1
				SELECT A1_EST, A1_TIPO
				FROM %Table:SA1% SA1 (NOLOCK)
				WHERE SA1.A1_FILIAL	=	%xFilial:SA1%
				AND SA1.A1_COD		=	%Exp:cClient%
				AND SA1.A1_LOJA		=	%Exp:cLojaCli%
				AND SA1.%NotDel%
			EndSql
			_cFornec := Alltrim((cQrySA1)->A1_EST)  //EX = INTERNACIONAL
			_cTipFor := Alltrim((cQrySA1)->A1_TIPO) //X = INTERNACIONAL
			(cQrySA1)->(dbCloseArea())
			//Query para buscar o nome dos Passageiros, Hospedes e Motoristas;
			DbSelectArea(_cAlias3)
			While (_cAlias3)->(!EOF()) .AND. !Empty((_cAlias3)->(G85_REGVEN)) 
				If ALLTRIM((_cAlias3)->(G85_GRPPRD)) = 'AE' //A�reo
					_cQuery1 := "SELECT DISTINCT G3T_FILIAL, G3T_NUMID, G3T_NOMPAX, G3T_DTSAID, G3T_DTCHEG FROM " + RetsqlName("G3T")
					_cQuery1 += " WHERE G3T_FILIAL = '"+(_cAlias3)->(G85_FILREF)+ "'"
					If Empty(_cNumID)
						_cQuery1 += " AND G3T_NUMID = '"+(_cAlias3)->(G85_REGVEN)+"'"
					Else
						_cQuery1 += " AND G3T_NUMID = '"+_cNumID+"'"
					EndIf
					_cQuery1 += " AND D_E_L_E_T_ <> '*'"
					_cQuery1 += " AND R_E_C_N_O_ > 0"
				
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery1),_cAlias1,.T.,.T.)
				
					DbSelectArea(_cAlias1)
					(_cAlias1)->(DbGotop())
				
					While (_cAlias1)->(!EOF()) .AND. (_cAlias1)->G3T_FILIAL == (_cAlias3)->(G85_FILREF) .AND. (_cAlias1)->G3T_NUMID == IIF(Empty(_cNumID),(_cAlias3)->(G85_REGVEN),_cNumID)
						If !_cNome $ Alltrim((_cAlias1)->G3T_NOMPAX)
							_cNome  := ALLTRIM((_cAlias1)->G3T_NOMPAX) + ' '
							_cDtIni := DTOC(STOD((_cAlias1)->G3T_DTSAID))
							_cDtFim := DTOC(STOD((_cAlias1)->G3T_DTCHEG))
							_cAglphm += _cNome + ' ' + _cDtIni + ' a ' + _cDtFim + ' '
						EndIf
						(_cAlias1)->(DbSkip())
						//(_cAlias1)->(DbCloseArea())
					EndDo
					(_cAlias1)->(DbCloseArea())
				ElseIf ALLTRIM((_cAlias3)->(G85_GRPPRD)) = 'HO' //Hotel
					_cQuery1 := "SELECT DISTINCT G3U_FILIAL, G3U_NUMID, G3U_NOMPAX, G3U_DTINI, G3U_DTFIM FROM " + RetsqlName("G3U")
					_cQuery1 += " WHERE G3U_FILIAL = '"+(_cAlias3)->(G85_FILREF)+ "'"
					If Empty(_cNumID)
						_cQuery1 += " AND G3U_NUMID = '"+(_cAlias3)->(G85_REGVEN)+"'"
					Else
						_cQuery1 += " AND G3U_NUMID = '"+_cNumID+"'"
					EndIf
					_cQuery1 += " AND D_E_L_E_T_ <> '*'"
					_cQuery1 += " AND R_E_C_N_O_ > 0"
				
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery1),_cAlias1,.T.,.T.)
				
					DbSelectArea(_cAlias1)
					(_cAlias1)->(DbGotop())
				    
					While (_cAlias1)->(!EOF()) .AND. (_cAlias1)->G3U_FILIAL == (_cAlias3)->(G85_FILREF) .AND. (_cAlias1)->G3U_NUMID == IIF(Empty(_cNumID),(_cAlias3)->(G85_REGVEN),_cNumID)
						If !_cNome $ Alltrim((_cAlias1)->G3U_NOMPAX)
							_cNome  := ALLTRIM((_cAlias1)->G3U_NOMPAX) + ' '
							_cDtIni := DTOC(STOD((_cAlias1)->G3U_DTINI))
							_cDtFim := DTOC(STOD((_cAlias1)->G3U_DTFIM)) 
							_cAglphm += _cNome + ' ' + _cDtIni + ' a ' + _cDtFim + ' '
						EndIf
						(_cAlias1)->(DbSkip())
						//(_cAlias1)->(DbCloseArea())
					EndDo
					(_cAlias1)->(DbCloseArea())			
				ElseIf ALLTRIM((_cAlias3)->(G85_GRPPRD)) = 'CA' //Carro
					_cQuery1 := "SELECT DISTINCT G3V_FILIAL, G3V_NUMID, G3V_NOMPAX, G3V_DTINI, G3V_DTFIM FROM " + RetsqlName("G3V")
					_cQuery1 += " WHERE G3V_FILIAL = '"+(_cAlias3)->(G85_FILREF)+ "'"
					If Empty(_cNumID)
						_cQuery1 += " AND G3V_NUMID = '"+(_cAlias3)->(G85_REGVEN)+"'"
					Else
						_cQuery1 += " AND G3V_NUMID = '"+_cNumID+"'"
					EndIf
					_cQuery1 += " AND D_E_L_E_T_ <> '*'"
					_cQuery1 += " AND R_E_C_N_O_ > 0"
				
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery1),_cAlias1,.T.,.T.)
				
					DbSelectArea(_cAlias1)
					(_cAlias1)->(DbGotop())
				    
					While (_cAlias1)->(!EOF()) .AND. (_cAlias1)->G3V_FILIAL == (_cAlias3)->(G85_FILREF) .AND. (_cAlias1)->G3V_NUMID == IIF(Empty(_cNumID),(_cAlias3)->(G85_REGVEN),_cNumID)
						If !_cNome $ Alltrim((_cAlias1)->G3V_NOMPAX)
							_cNome  := ALLTRIM((_cAlias1)->G3V_NOMPAX) + ' '
							_cDtIni := DTOC(STOD((_cAlias1)->G3V_DTINI))
							_cDtFim := DTOC(STOD((_cAlias1)->G3V_DTFIM)) 
							_cAglphm += _cNome + ' ' + _cDtIni + ' a ' + _cDtFim + ' '
						EndIf
						(_cAlias1)->(DbSkip())
						//(_cAlias1)->(DbCloseArea())
					EndDo 
					(_cAlias1)->(DbCloseArea())
			 	EndIf
				(_cAlias3)->(DbSkip())
			EndDo
			
			(_cAlias3)->(DbGotop())
			
			//Inicio das Regra RONALDO:
			//FEE Corporativo- cobrado por apura��o
			If ALLTRIM((_cAlias3)->(G85_PREFIX)) = ALLTRIM(_cPreApu) .AND. ALLTRIM((_cAlias3)->(G85_SEGNEG)) $ '1/3' .AND. SUBSTR((_cAlias3)->(G85_CLASS),1,1) = 'C'
				cMensagem := 'Remuneracao pela intermediacao FT: '+ ALLTRIM(G84->G84_NUMFAT) + IIF(Empty((_cAlias3)->(G85_CODAPU)),'',' Apuracao: ' + ALLTRIM((_cAlias3)->(G85_CODAPU))) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
				//FEE Corporativo - cobrado em fatura
			ElseIf ALLTRIM((_cAlias3)->(G85_PREFIX)) = ALLTRIM(_cPreFat) .AND. ALLTRIM((_cAlias3)->(G85_SEGNEG)) $ '1/3'
				cMensagem := 'Remuneracao pela intermediacao FT: '+ ALLTRIM(G84->G84_NUMFAT) + ' ' + IIF(!Empty(_cAglphm),Alltrim(_cAglphm),'') + IIF(Empty(G85->G85_REGVEN),'',' Registro de Venda: ' + ALLTRIM((_cAlias3)->(G85_REGVEN))) //+ ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
				//FEE Eventos - cobrado por apura��o
			ElseIf ALLTRIM((_cAlias3)->(G85_PREFIX)) = ALLTRIM(_cPreApu) .AND. ALLTRIM((_cAlias3)->(G85_SEGNEG)) = '2' .AND. SUBSTR((_cAlias3)->(G85_CLASS),1,1) = 'C'
				cMensagem := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Remuneracao pela intermediacao de eventos FT:' + ALLTRIM(G84->G84_NUMFAT) + IIF(Empty((_cAlias3)->(G85_CODAPU)),'',' Apuracao: ' + ALLTRIM((_cAlias3)->(G85_CODAPU))) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
				//FEE Eventos - cobrado em fatura
			ElseIf ALLTRIM((_cAlias3)->(G85_PREFIX)) = ALLTRIM(_cPreFat) .AND. ALLTRIM((_cAlias3)->(G85_SEGNEG)) = '2'
				If _cTipFor = 'X' .OR. _cFornec = 'EX'
					cMensagem := 'Remuneracao pela intermediacao de eventos FT:' + ALLTRIM(G84->G84_NUMFAT) + ' ' + IIF(!Empty(_cNomEve),Alltrim(_cNomEve),'') + IIF(Empty(G85->G85_REGVEN),'',' Registro de Venda: ' + ALLTRIM((_cAlias3)->(G85_REGVEN))) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
				Else
					cMensagem := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Remuneracao pela intermediacao de eventos FT:' + ALLTRIM(G84->G84_NUMFAT) + ' ' + IIF(!Empty(_cNomEve),Alltrim(_cNomEve),'') + IIF(Empty(G85->G85_REGVEN),'',' Registro de Venda: ' + ALLTRIM((_cAlias3)->(G85_REGVEN))) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
				EndIf
				//Comiss�o Corporativa por apura��o + Comiss�o Corporativa Faturada
			ElseIf ALLTRIM((_cAlias3)->(G85_SEGNEG)) $ '1/3' .AND. SUBSTR((_cAlias3)->(G85_CLASS),1,1) = 'F'
				If ALLTRIM((_cAlias3)->(G85_GRPPRD)) = 'AE'
					If !Empty((_cAlias3)->(G85_CODAPU))
						cMensagem := 'Comissao pela intermediacao de reservas FT: '+ ALLTRIM(G84->G84_NUMFAT) + ' Apuracao: ' + ALLTRIM((_cAlias3)->(G85_CODAPU)) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
					Else
						cMensagem := 'Comissao pela intermediacao de reservas FT: '+ ALLTRIM(G84->G84_NUMFAT) + ' Registro de Venda: ' + ALLTRIM((_cAlias3)->(G85_REGVEN)) + IIF(!Empty(_cAglphm),Alltrim(_cAglphm)+' ','') + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
					EndIf
				Else
					If !Empty((_cAlias3)->(G85_CODAPU))                                                           //' Apura��o: ' + ALLTRIM((_cAlias3)->(G85_CODAPU))
						If _cTipFor = 'X' .OR. _cFornec = 'EX'
							cMensagem := 'Comissao pela intermediacao de reservas FT: '+ ALLTRIM(G84->G84_NUMFAT) + ' Apuracao: ' + ALLTRIM((_cAlias3)->(G85_CODAPU)) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
						Else
							cMensagem := 'SUJEITO A RETENCAO DE 1,5% IR - Comissao pela intermediacao de reservas FT: '+ ALLTRIM(G84->G84_NUMFAT) + ' Apuracao: ' + ALLTRIM((_cAlias3)->(G85_CODAPU)) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
						EndIf
					Else
						If _cTipFor = 'X' .OR. _cFornec = 'EX'
							cMensagem := 'Comissao pela intermediacao de reservas FT: '+ ALLTRIM(G84->G84_NUMFAT) + ' Registro de Venda: ' + ALLTRIM((_cAlias3)->(G85_REGVEN)) + IIF(!Empty(_cAglphm),' ' + Alltrim(_cAglphm),'') + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
						Else
							cMensagem := 'SUJEITO A RETENCAO DE 1,5% IR - Comissao pela intermediacao de reservas FT: '+ ALLTRIM(G84->G84_NUMFAT) + ' Registro de Venda: ' + ALLTRIM((_cAlias3)->(G85_REGVEN)) + IIF(!Empty(_cAglphm),' ' + Alltrim(_cAglphm),'') + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
						EndIf
					EndIf
				EndIf
				//Comiss�o Eventos por apura��o + Comiss�o Eventos Fatura
			ElseIf ALLTRIM((_cAlias3)->(G85_SEGNEG)) = '2' .AND. SUBSTR((_cAlias3)->(G85_CLASS),1,1) = 'F'
				If _cTipFor = 'X' .OR. _cFornec = 'EX'
					cMensagem := 'Comissao pela intermedicao de reservas de eventos FT: '+ ALLTRIM(G84->G84_NUMFAT) + IIF(!Empty(_cNomEve),' ' + Alltrim(_cNomEve),'') + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
				Else
					cMensagem := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Comissao pela intermediacao de reservas de eventos FT: '+ ALLTRIM(G84->G84_NUMFAT) + IIF(!Empty(_cNomEve),' ' + Alltrim(_cNomEve),'') + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
				EndIf
				//Meta / Comiss�o de AE
			ElseIf SUBSTR((_cAlias3)->(G85_CLASS),1,1) = 'M'
				DbSelectArea("G6L")
				DbSetOrder(1)
				If MsSeek(xFilial("G6L")+(_cAlias3)->(G85_CODAPU),.T.)
					_cDtApuI := DTOC(G6L->G6L_DTINI)
					_cDtApuF := DTOC(G6L->G6L_DTFIM)
				EndIf
				cMensagem := 'Incentivo variavel de vendas nacional/internacional ' + IIF(Empty((_cAlias3)->(G85_CODAPU)),' FT: ' + ALLTRIM(G84->G84_NUMFAT),' Apuracao: ' + ALLTRIM((_cAlias3)->(G85_CODAPU))) + IIF(!Empty(_cDtApuI) .AND. !Empty(_cDtApuF),' Ref. periodo de ' + ALLTRIM(_cDtApuI) + ' ate ' + ALLTRIM(_cDtApuF),'') //+ ALLTRIM(CVALTOCHAR(MONTH(G84->G84_EMISS))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G84->G84_EMISS)))
			EndIf
			
			//Grava mensagem personalizada Alatur para transmiss�o das notas fiscais de servi�os
			DbSelectArea("SF2")
			DbSetOrder(1)
			
			While (_cAlias2)->(!EOF())
				If MsSeek((_cAlias2)->(G8E_FILREF+G8E_NUMNF+G8E_SERIE+G8E_CLIENT+G8E_LOJA),.T.)
					
					//Informar valores dos tributos
					If SF2->(F2_VALISS+F2_VALINSS+F2_VALCSLL+F2_VALCOFI+F2_VALPIS+F2_VALIRRF) > 0
						_cTrib := 'Vlr Aprox Trib: R$ '+ALLTRIM(STR(SF2->(F2_VALISS+F2_VALINSS+F2_VALCSLL+F2_VALCOFI+F2_VALPIS+F2_VALIRRF)))+' '
					EndIf   
					
					//Mensagens Nota Fiscal de Sa�da: Tributos, Observa��o (Campo Memo) e Outras conforme regras acima....
					cMensagem := _cTrib + IIF(Len(_cObs)>0,_cObs+' ','') + cMensagem
					cMensagem := cMensagem + IIF(!Empty(cMensagem) .AND. LEN(cMensagem) < 194,' OBS: Cancelamento da NF somente dentro do mes de competencia','') 
					cMensagem := STRTRAN(cMensagem, '|','') //Tira acentua��o: FwNoAccent(cMensagem)
					RecLock("SF2",.F.)
						SF2->F2_MENNOTA := ALLTRIM(cMensagem) 
					SF2->(MsUnlock())
				
				EndIf
				(_cAlias2)->(DbSkip())
			EndDo
		EndIf
		(_cAlias3)->(DbCloseArea())
	EndIf                         
	(_cAlias2)->(DbCloseArea())
EndIf

//Retorna area para posi��o da rotina padr�o as tabelas abaixo:
RestArea(_aAreaG85)
RestArea(_aAreaG48)
RestArea(_aAreaG3P)
RestArea(_aAreaG8E)
RestArea(_aAreaSA1)
RestArea(_aAreaSF2)
RestArea(_aAreaG6L)
RestArea(_aGetArea)

Return()