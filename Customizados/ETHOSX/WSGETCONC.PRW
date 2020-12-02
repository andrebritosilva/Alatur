#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "RestFul.ch"
#Include "FwMvcDef.ch"
#Include "TbIconn.ch"

WSRESTFUL WsPostConc DESCRIPTION "Conciliação"
 
    WSMETHOD POST DESCRIPTION "Carrega dados para Conciliação" WSSYNTAX "/Api/WsPostConc/"
    
END WSRESTFUL

WSMETHOD POST WSSERVICE WsPostConc  
    Local aRet      := {}
    Local lRet      := .T.
    Local cBody     := Self:GetContent()
    Local oJson
    Local cError    := ""
    Local cReturn   := ""

    if FwJsonDeserialize(cBody, @oJson)
        cReturn    := U_ManApiConc(@oJson)
        
        Self:SetResponse(EncodeUtf8(cReturn))
       
    Else
        Self:SetResponse('{"status":"erro","msghelp":"JSON incorreto, por favor, avalie o arquivo de envio."}')
    Endif

Return lRet