#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M030INC   �Autor  �Microsiga           � Data �  19/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � PE apos inclusao de clientes.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � P11 - SISTEMA INDUSTRIA                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M030Inc()
Local _lOk := ParamIXB == 0

IF _lOk // confirmou         
	IF  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/  
		SZZ->(dbSetOrder(1))
		IF SZZ->(dbSeek(XFilial("SZZ")+"MATA030")).And. (SZZ->ZZ_TPINT <>  '2') //Se existe a integracao e se ha a op��o de envio.
			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA01() } )
		ENDIF	
	ENDIF
ENDIF

Return()
