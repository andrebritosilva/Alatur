#Include "Protheus.ch"
#Include "RwMake.ch"

User Function PCOA5307()
 
Local lInclui   := ParamIXB[1] //Indica se passou pelas valida��es padr�es.
Local aDadosPE  := ParamIXB[2] //Dados or�ament�rios considerando o registro que se pretende incluir.
Local nDet      := ParamIxb[3] // Retorno da vari�vel, considerar a a��o efetuada pelo usu�rio na pergunta de libera��o de conting�ncia.
 
If nDet == 2 // Indica que o usu�rio selecionou a op��o Solicitar libera��o.
    lInclui := MsgYesNo("Na avalia��o do Protheus, o registro " + If(lInclui,"ser�","n�o ser�") + " incluso. Voc� deseja incluir?" ,"Ponto de Entrada - PCOA5307")
EndIF
 
Return lInclui