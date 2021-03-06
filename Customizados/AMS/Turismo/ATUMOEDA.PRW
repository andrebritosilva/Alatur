#include "PROTHEUS.CH"
#include "topconn.ch"
                     
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtuMoeda   �Autor  �Totvs     � Data �  21/09/16            ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca Moeda pelo codigo informado pela Alatur do arquivo   ���
���          � txt que � carregado pelo Mille                             ���
�������������������������������������������������������������������������͹��
���Uso       � P12 - Alatur    x                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AtuMoeda(_cxA)
           
Local aAreaAtu	:= GetArea()
Local cMoeda	:= ''
Local _cQuery	:= ''
     
_cQuery := " SELECT G5T_CODIGO FROM "+ RetsqlName("G5T")
_cQuery += " WHERE G5T_FILIAL = '"+xFilial("G9L")+ "'"
_cQuery += " AND G5T_SIMBOL = '"+_cxA+ "'" 
_cQuery += " AND G5T_MSBLQL = '2'" 
_cQuery += " AND D_E_L_E_T_ <> '*'"

TcQuery ChangeQuery(_cQuery) New Alias "G5TCOD"

DbSelectArea("G5TCOD")
G5TCOD->(DbGotop())

cMoeda := G5TCOD->G5T_CODIGO

G5TCOD->(DbCloseArea())

/*DbSelectArea("G5T")
DbGoTop()
DbSetOrder(4)
If MsSeek(xFilial("G9L")+_cxA)

	cMoeda := G5T->G5T_CODIGO
	
EndIf

G5T->(DbCloseArea())
*/
RestArea(aAreaAtu)

Return(cMoeda)