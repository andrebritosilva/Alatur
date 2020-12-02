#Include 'Protheus.ch'

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TUR20AJU

Função para ajuste do campo G4W_TPACO com referência ao campo G8B_TIPO

@sample 	TUR20AJU()
@param 		 
@return		
@author    	Thiago Tavares
@since		02/12/2016
@version	P12.1.14
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function TUR20AJU()

Local aArea := GetArea()

If MsgYesNo('Deseja ajustar o tipo de acordo?', 'Ajuste') 
	DbSelectArea("G4W")
	G4W->(DbSetOrder(1))	// G4W_FILIAL+G4W_CODACO+G4W_CODREV+G4W_MSBLQL
	While G4W->(!Eof())
		If Empty(G4W->G4W_TPACO)
			RecLock('G4W', .F.)
			G4W->G4W_TPACO     := POSICIONE("G8B",1, XFILIAL("G8B")+G4W->G4W_CLASSI,"G8B_TIPO")
			G4W->(MsUnLock())
		EndIf	
		G4W->(DbSkip())
	EndDo
	Alert('Ajustes Efetuados.')		
EndIf
G4W->(DbCloseArea())

RestArea(aArea)
	
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TUR20F04

Função para desabilitar a classificação do acordo F04 - Taxa DU e 
desabilitar os acordos cadastrados com essa classificação

@sample 	TUR20F04()
@param 		 
@return		
@author    	Thiago Tavares
@since		31/05/2017
@version	P12.1.14
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function TUR20F04()

Local aArea := GetArea()

If MsgYesNo('Deseja desabilitar a classificação de acordo F04 - Taxa DU e os acordos cadastrados?', 'Desabilitar') 

	// desabilitando os acordos F04
	G4W->(DbCloseArea())
	DbSelectArea("G4W")
	G4W->(DbSetOrder(1))	// G4W_FILIAL+G4W_CODACO+G4W_CODREV+G4W_MSBLQL
	While G4W->(!Eof())
		If G4W->G4W_CLASSI $ 'F04|F05'
			RecLock('G4W', .F.)
			G4W->G4W_MSBLQL := '1'
			G4W->(MsUnLock())
		EndIf	
		G4W->(DbSkip())
	EndDo
	G4W->(DbCloseArea())
	
	// desabilitando a classificação
	DbSelectArea("G8B")
	G8B->(DbSetOrder(1))		// G8B_FILIAL+G8B_CODIGO
	While G8B->(!Eof()) 
		If G8B->G8B_CODIGO $ 'F04|F05'
			RecLock('G8B', .F.)
			G8B->(DbDelete())
			G8B->(MsUnLock())
		EndIf
		G8B->(DbSkip())
	EndDo

	Alert('Classificação e acordos desabilitados com sucesso.')		
EndIf

RestArea(aArea)

Return
