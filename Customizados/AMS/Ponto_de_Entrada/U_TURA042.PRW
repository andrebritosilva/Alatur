#include "PROTHEUS.CH"
#include "topconn.ch"
#Include 'FWMVCDef.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TURA042	 ºAutor  ³Totvs     º Data ³  27/10/16            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava mensagem da NFS/RPS campo F2_MEMNOTA.                º±±
±±º          ³ 									                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12 - Alatur                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TURA042()

Local _aParam   := PARAMIXB
//Local _oObj     := ''
Local _cIdPonto := ''
Local _cIdModel := ''
//Local oStruG8C 	:= nil
Local _aGetArea := GetArea()
Local _aAreaSA1	:= SA1->(GetArea())
Local _aAreaSA2	:= SA2->(GetArea())
Local _aAreaSF2	:= SF2->(GetArea())
Local cAliasG8Y	:= GetNextAlias()
Local cAliasG3R	:= ''
Local _xRet     := .T.
Local oModel	:= nil
Local _cMsg     := ''
Local _cTrib    := ''
Local _cFornec  := ''
Local _cTipFor  := ''
Local _cCodCli  := ''
Local _cLojCli  := ''

If _aParam <> NIL
	
	//_oObj       := _aParam[1]
	_cIdPonto   := _aParam[2]
	_cIdModel   := _aParam[3]
	oModel := _aParam[1]	
				
	If _cIdPonto == 'MODELCOMMITNTTS' .And. FwIsInCallStack( 'TA042AEFET' )
		
		BeginSql Alias cAliasG8Y
			SELECT G8Y_FILIAL, G8Y_FATURA, G8Y_DOC, G8Y_SERIE, G8Y_TPFAT, G8Y_FORNEC, G8Y_LOJA, G8Y_CONCIL
			FROM %Table:G8Y% G8Y
			WHERE G8Y_TPFAT <> '1' //1 = Aéreo / 2 = Terrestre
			AND G8Y_CONCIL = %Exp:oModel:GetValue( 'G8C_MASTER', 'G8C_CONCIL' )% 
			AND G8Y_TPDOC  = '4' //4 = Nota de Sáida
			AND G8Y_FILIAL = %xFilial:G8C%
			AND G8Y.%notDel%
		EndSql
		
		DbSelectArea("SA1")
		DbSetOrder(1)
		
		DbSelectArea("SF2")
		DbSetOrder(1)
		
		DbSelectArea("SA2")
		DbSetOrder(1)
				
		While (cAliasG8Y)->(!EOF())
			
			cAliasG3R := GetNextAlias()
			
			//Query para trazes o Tipo de Segmento
			BeginSql Alias cAliasG3R
				SELECT G3R_FILIAL, G3R_NUMID, G3R_TPSEG, G3P_SEGNEG
				FROM %Table:G3R% G3R
				INNER JOIN %Table:G3P% G3P ON
				G3P_FILIAL = G3R_FILIAL AND
				G3P_NUMID = G3R_NUMID AND
				G3P.%notDel%
				WHERE G3R_FILIAL = %Exp:(cAliasG8Y)->G8Y_FILIAL%
				AND G3R_CONCIL = %Exp:(cAliasG8Y)->G8Y_CONCIL%
				AND G3R.%notDel%
			EndSql
			
			//Verificar Nacionalidade do Fornecedor/Cliente
			If SA1->(MsSeek(xFilial("SA1")+(cAliasG8Y)->G8Y_FORNEC+(cAliasG8Y)->G8Y_LOJA,.T.))
				_cFornec := Alltrim(SA1->A1_EST)  //EX = INTERNACIONAL
				_cTipFor := Alltrim(SA1->A1_TIPO) //X = INTERNACIONAL
			EndIf
			
			//Seleciona a Aérea da query da tabela G3R
			DbSelectArea(cAliasG3R)
			(cAliasG3R)->( DbGoTop() )
			
			//Fatura Fornecedor pela Conciliação Terrestre
			If ALLTRIM((cAliasG3R)->G3P_SEGNEG) $ '1/3'
				If _cTipFor = 'X' .OR. _cFornec = 'EX'
					_cMsg := 'Comissao pela intermediacao de reservas FT: '+ ALLTRIM((cAliasG8Y)->G8Y_CONCIL) + ' Fatura Fornec.: ' + ALLTRIM(G8C->G8C_FATURA) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G8C->G8C_DTCONC))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G8C->G8C_DTCONC)))
				Else
					_cMsg := 'SUJEITO A RETENCAO DE 1,5% IR - Comissao pela intermediacao de reservas FT: ' + ALLTRIM((cAliasG8Y)->G8Y_CONCIL) + ' Fatura Fornec.: ' + ALLTRIM(G8C->G8C_FATURA) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G8C->G8C_DTCONC))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G8C->G8C_DTCONC)))
				EndIf
			ElseIf  ALLTRIM(%Exp:(cAliasG3R)->(G3P_SEGNEG)%) == '2'
				If _cTipFor = 'X' .OR. _cFornec = 'EX'
					_cMsg := 'Comissao pela intermediacao de reservas de eventos FT: ' + ALLTRIM((cAliasG8Y)->G8Y_CONCIL) + ' Fatura Fornec.: ' + ALLTRIM(G8C->G8C_FATURA) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G8C->G8C_DTCONC))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G8C->G8C_DTCONC)))
				Else
					_cMsg := 'SUJEITO A RETENCAO DO PCC 4,65% MAIS 1,5% DE IR - Comissao pela intermediacao de reservas de eventos FT: '+ ALLTRIM((cAliasG8Y)->G8Y_CONCIL) + ' Fatura Fornec.: ' + ALLTRIM(G8C->G8C_FATURA) + ' Ref. ' + ALLTRIM(CVALTOCHAR(MONTH(G8C->G8C_DTCONC))) + '/' + ALLTRIM(CVALTOCHAR(YEAR(G8C->G8C_DTCONC)))
				EndIf
			EndIf
			 
			//Busca Codigo e loja do Cliente(SF2) na tabela de Fornecedores (SA2)
			If SA2->(MsSeek(xFilial("SA2")+(cAliasG8Y)->G8Y_FORNEC+(cAliasG8Y)->G8Y_LOJA,.T.))
				_cCodCli := SA2->A2_CLIENTE
				_cLojCli := SA2->A2_LOJCLI
			EndIf
			
			//Grava mensagem personalizada Alatur para transmissão das notas fiscais de serviços
			If SF2->(MsSeek((cAliasG8Y)->G8Y_FILIAL+(cAliasG8Y)->G8Y_DOC+(cAliasG8Y)->G8Y_SERIE+_cCodCli+_cLojCli,.T.))
				
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
			
			(cAliasG8Y)->(dbSkip())
			
		EndDo
		
		(cAliasG8Y)->( dbCloseArea() )
		
	
	ElseIf _cIdPonto == 'MODELPOS' //Chamada na validação total do modelo.
                            
    	If FwIsInCallStack( "TURA042A" ) .and. (oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4) //oModel:GetOperation() == MODEL_OPERATION_DELETE
			If Empty(oModel:GetValue( 'G8C_MASTER', 'G8C_XEDOC' ))   //If !Empty(oModel:GetValue('G8C_MASTER','G8C_XEDOC'))
				oModel:SetErrorMessage('G8C_MASTER', 'G8C_XEDOC' , '' , '' , "Erro", 'Campo ID em Branco', 'Informe campo ID') 
				_xRet := .F. 				
				//MSGINFO('Preencher campo ID !!!','Aviso')
			EndIf
		EndIf 
		
	EndIf
	
EndIf

RestArea(_aAreaSF2)
RestArea(_aAreaSA1)
RestArea(_aAreaSA2)
RestArea(_aGetArea)

Return(_xRet)