#include "rwmake.ch"  

User Function Pagano() 
                       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PAGANO    �Autor  �Osmil Squarcine     � Data �  31/3/05    ���
�������������������������������������������������������������������������͹��
���Desc.     � SELECIONAR O ANO DO NOSSO NUMERO DO NUMERO CNAB QUANDO NAO ���
���          �  NAO TIVER TEM QUE SER COLOCADO "00"                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_RETANO,")

////  PROGRAMA PARA SELECIONAR O ANO DO NOSSO NUMERO DO NUMERO CNAB QUANDO NAO
////  NAO TIVER TEM QUE SER COLOCADO "00"


IF SUBS(SE2->E2_CODBAR,01,3) != "237"
   _RETANO := "000"
Else
   _RETANO := "0" + SUBS(SE2->E2_CODBAR,26,2)
EndIf


Return(_RETANO)
