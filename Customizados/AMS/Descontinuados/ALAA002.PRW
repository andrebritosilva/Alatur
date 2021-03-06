#INCLUDE "Protheus.ch"


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ALAA002


@sample 	ALAA002()
@param 		cModelo -
			cCampo - 
@return	
@author    jacomo Lisa
@since		30/01/2017
@version	P12.1.14
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function ALAA002()
Local lRet		:=  .T.
Local aArea		:= GetArea()
Local cCodCont	:= POSICIONE("SU5",9,xFilial('SU5')+M->U5_EMAIL,"U5_CODCONT")
Local cMsg			:= ""
Local cIntId		:= ""

If !Empty(cCodCont) .and. cCodCont <> M->U5_CODCONT  
	DbSelectArea('XXF')
	cIntId := TURXMakeId(cCodCont, 'SU5')
	cMsg	+= "O e-mail informado j� foi utilizado em outro registro"+Chr(13)+Chr(10)
	cMSg	+= "C�digo Protheus: "+cCodCont+Chr(13)+Chr(10)
	cMSg	+= "C�digo Interno: "+ cIntId+Chr(13)+Chr(10)
	cMsg	+= "C�digo Alatur: "+CFGA070EXT('PROTHEUS', 'SU5', 'U5_CODCONT', cIntId)+Chr(13)+Chr(10)
	
	Help("",1, "EMAIL JA GRAVADO", , cMsg, 1, )
	lRet := .F.
Endif
RestArea(aArea)
Return lRet