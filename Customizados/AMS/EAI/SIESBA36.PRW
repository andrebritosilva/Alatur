#INCLUDE "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SIESBA36 � Autor �    � Data �  29/08/12   				  ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Integracoes (SZZ)    	                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CNI                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function SIESBA36
Private cCadastro := "Cadastro de Integracoes"
Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
{"Visualizar","AxVisual",0,2} ,;
{"Incluir","AxInclui",0,3} ,;
{"Alterar","AxAltera",0,4} ,;
{"Excluir","AxDeleta",0,5} }

Private cString := "SZZ"

dbSelectArea("SZZ")
dbSetOrder(1)

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return