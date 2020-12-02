#Include 'Protheus.ch'
#Include 'RwMake.ch'

User Function PCO530xHTM()
/*
Local nPosProduto  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
Local nPosData     := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_DATPRF"})
Local nPosCusto    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CC"})
Local nPosClasse   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CLVL"})
Local nPosValUnit  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})
Local nPosQuanti   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_QUANT"})
Local nPosValTot   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_TOTAL"})
Local cAuxHtm      := ""
Local cCont        := ALI->ALI_CDCNTG
Local cProduto     := Alltrim(aCols[n][nPosProduto])
Local cDataCom     := Alltrim(Dtos(aCols[n][nPosData]))
Local cSol         := Alltrim(ALI->ALI_NOMSOL)
Local cPcoFil      := ALI->ALI_FILIAL
Local cDtSol       := DTOC(ALI->ALI_DTSOLI)
Local cEmail       := ALI->ALI_USER
Local cCusto       := Alltrim(aCols[n][nPosCusto])
Local cClasse      := Alltrim(aCols[n][nPosClasse])
Local cValUnit     := Alltrim(Str(aCols[n][nPosValUnit]))
Local cQuant       := Alltrim(Str(aCols[n][nPosQuanti]))
Local cValTot      := Alltrim(Str(aCols[n][nPosValTot]))
Local cAliUser     := Alltrim(ALI->ALI_USER)
Local cValOrc      := Alltrim(Str(aRec[3]))
Local cValRe       := Alltrim(Str(aRec[2]))
Local cConta       := aRec[4]

//cAuxHtm := '<a href="http://http://187.94.58.102:9098/U_GerCont.apw?cparam=1&cloop=2">Clique Aqui</a>'
//cAuxHtm := '<a href="http://localhost:8085/U_xGerCont.apw?cparam=1&cCont=' + cCont + '&cProd=' + cProduto + '&cDataCom=' + cDataCom + '&cCusto=' + cCusto +'&cClasse=' +cClasse +'&cSol=' +cSol +'&cPcoFil='+ cPcoFil + '&cAliUser=' + cAliUser + '&cValTot=' + cValTot + '&cUserId=' + __cUserId + '&cValOrc=' + cValOrc + '&cValRe=' + cValRe + '&cConta=' + cConta + '&cEmail=' + cEmail + '&cEmpAnt=' + cEmpAnt +'&cFilAnt=' + cFilAnt +'">Clique aqui para aprovar sua contigência</a>'
cAuxHtm := '<a href="http://187.94.63.204:14010/wf/U_xGerCont.apw?cparam=1&cCont=' + cCont + '&cProd=' + cProduto + '&cDataCom=' + cDataCom + '&cCusto=' + cCusto +'&cClasse=' +cClasse +'&cSol=' +cSol +'&cPcoFil='+ cPcoFil + '&cAliUser=' + cAliUser + '&cValTot=' + cValTot + '&cUserId=' + __cUserId + '&cValOrc=' + cValOrc + '&cValRe=' + cValRe + '&cConta=' + cConta + '&cEmail=' + cEmail + '&cEmpAnt=' + cEmpAnt +'&cFilAnt=' + cFilAnt +'">Clique aqui para aprovar sua contigência</a>'
*/
Return cAuxHtm    