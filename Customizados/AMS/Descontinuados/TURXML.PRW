#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'


User Function TsXmlNFS()

	FWMsgRun(,{|| TurXml()},  , "Aguarde... gerando XML da NF posicionada..." ) 

Return


Function TurXml()

	U_nfseXMLEnv( "1", SF2->F2_EMISSAO, SF2->F2_SERIE , SF2->F2_DOC, SF2->F2_CLIENTE, SF2->F2_LOJA,'')
	
Return 