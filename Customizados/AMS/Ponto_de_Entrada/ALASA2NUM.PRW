#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณALASA2NUM   บAutor  ณMolla          บ Data ณ  21/01/15      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna sequenacia para o codigo de fornecedor com         บฑฑ
ฑฑบ          ณ A2_TIPO='X'                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP 11.8 - Alatur                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function ALASA2NUM()      
Local cArea :=GetArea()
Local cAliasQuery := CriaTrab(,.F.)
Local cRetCod := nil       
Local ntamSX3 := TAMSX3("A2_COD")[1]

                 

	cquery := 	"SELECT " 
	cquery +=	"CASE WHEN MAX(A2_COD)  IS NULL  THEN 'EX" + REPLICATE('0',ntamSX3-2)+"'"
	cquery +=	"ELSE "
	cquery +=	"'EX'+replicate('0',"+ str(ntamSX3-2) +" -LEN(MAX(SUBSTRING(A2_COD,3,"+str(ntamSX3-2)+")+1)))+cast(MAX(SUBSTRING(A2_COD,3,"+str(ntamSX3-2)+")+1) as varchar("+str(ntamSX3)+"))"
	cquery +=	"END as CODIGO"   
	cquery +=	"FROM " + RetSqlName("SA2") + " WHERE A2_TIPO='X' AND D_E_L_E_T_<>'*' AND SUBSTRING(A2_COD,1,2)= 'EX'"
	cquery +=	" and A2_COD <='EX"+  REPLICATE('9',ntamSX3-2)+"'"
                   

                                             
      
	cQuery := ChangeQuery(cquery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQuery,.F.,.T.) 
	cRetCod := (cAliasQuery)->CODIGO

(cAliasQuery)->(dbCloseArea())      

RestArea(cArea)
return (cRetCod)
