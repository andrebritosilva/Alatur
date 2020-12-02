/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � LPT62CCRED�Autor  �Edelcio Cano        � Data � 14/01/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � Captura Historico - Captura Conta D�BITO Processo RA       ���
���          � Tipo FAT/CDT, qdo Compensa��o partir do T�tulo             ���
���          *                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ALATUR                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function LPT62CDEB()

Local _aAreaAt	:= GetArea()  

Local _cDeb     := "" 
Local _cPref 	:= Substr(SE5->E5_DOCUMEN,1,3)	
Local _cNum		:= Substr(SE5->E5_DOCUMEN,4,9)
Local _cPar		:= Substr(SE5->E5_DOCUMEN,13,1)
Local _cTipo	:= Substr(SE5->E5_DOCUMEN,14,3)
Local _cNaturez := ""

DbSelectArea("SE1")
DbSetOrder(1)

If DbSeek(xFilial("SE1") + _cPref + _cNum + _cPar + _cTipo)
	_cNaturez := SE1->E1_NATUREZ
Else
	_cNaturez := ""
EndIf

DbSelectArea("SED")
DbSetOrder(1)

If DbSeek(xFilial("SED") + _cNaturez)
	_cDeb := SED->ED_CONTA
Else
	_cDeb := ""
EndIf

/*_cNaturez := POSICIONE("SE1",1,XFILIAL("SE1")+_cPref+_cNum+_cPar+_cTipo,"E1_NATUREZ")

_cDeb    := POSICIONE("SED",1,XFILIAL("SED")+_cNaturez,"ED_CONTA")*/

RestArea(_aAreaAt)

Return(_cDeb)