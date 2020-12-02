#INCLUDE "PROTHEUS.CH"


User Function ALASA1NUM()      
Local cArea :=GetArea()
Local cAliasQuery := CriaTrab(,.F.)
Local cRetCod := nil
Local ntamSX3 := TAMSX3("A1_COD")[1]

	cquery := 	"SELECT " 
	cquery +=	"CASE WHEN MAX(A1_COD)  IS NULL  THEN 'EX" + REPLICATE('0',ntamSX3-2)+"'"
	cquery +=	"ELSE "
	cquery +=	"'EX'+replicate('0', "+ str(ntamSX3-2) + "-LEN(MAX(SUBSTRING(A1_COD,3,"+str(ntamSX3-2)+")+1)))+cast(MAX(SUBSTRING(A1_COD,3,"+str(ntamSX3-2)+")+1) as varchar("+str(ntamSX3)+"))"
	cquery +=	"END as CODIGO"   
	cquery +=	"FROM " + RetSqlName("SA1") + " WHERE A1_TIPO='X' AND D_E_L_E_T_<>'*' AND SUBSTRING(A1_COD,1,2)= 'EX'"
	cquery +=	" and A1_COD <='EX" + REPLICATE('9',ntamSX3-2)+"'"
                   

                                             
      
	cQuery := ChangeQuery(cquery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQuery,.F.,.T.) 
	cRetCod := (cAliasQuery)->CODIGO

(cAliasQuery)->(dbCloseArea())      

RestArea(cArea)
return (cRetCod)
