#Include "Protheus.ch"
#Include "RwMake.ch"

User Function PCOA5307()
 
Local lInclui   := ParamIXB[1] //Indica se passou pelas validações padrões.
Local aDadosPE  := ParamIXB[2] //Dados orçamentários considerando o registro que se pretende incluir.
Local nDet      := ParamIxb[3] // Retorno da variável, considerar a ação efetuada pelo usuário na pergunta de liberação de contingência.
 
If nDet == 2 // Indica que o usuário selecionou a opção Solicitar liberação.
    lInclui := MsgYesNo("Na avaliação do Protheus, o registro " + If(lInclui,"será","não será") + " incluso. Você deseja incluir?" ,"Ponto de Entrada - PCOA5307")
EndIF
 
Return lInclui