#Include "Totvs.ch"

Function GERFTF(cFilFTF, cConFTF)
//Criei essa função para caso queiram melhorar, da pra criar uma tela pedindo filial e conciliação. Do jeito que está, precisa ser passado nos parametros
FIXFTF(cFilFTF, cConFTF)

Return

/* Passos do procedimento manual
- Abrir o Sistema via APSDU, e abrir a tabela G3R

- Executar filtro com a expressão:
G3R_CONCIL='número da conciliação' .AND. G3R_FILIAL='filial'

- Anotar todos os números de RV que aparecerem.

- Abrir a tabela G4C

- Executar filtro com a expressão:
G4C_NUMID $ 'numero RV1|numero RV2|numero RV3|...' .AND. G4C_FILIAL='filial' .AND. G4C_CLIFOR='1' .AND. G4C_CONINU=' '
Exemplo:
G4C_NUMID $ '1806306611|1806306611|' .AND. G4C_FILIAL='03SP0001' .AND. G4C_CLIFOR='1' .AND. G4C_CONINU=' '

- Guardar todas as datas da G4C_DTLIB

- Alterar o campo G4C_STATUS para 1

- Executar o Sistema normalmente e mandar fazer a desefetivação e efetivação da conciliação, e verificar se o título FTF foi gerado.

- No APSDU voltar na tabela G4C e voltar a data da G4C_DTLIB para a anterior
*/
Static Function FIXFTF(cFilFTF, cConFTF)
Local aArea    := GetArea()
Local cRvs     := ''
Local cFilter  := ''
Local aG4C     := {} //Array com recno, dtlib e status da G4C no formato {{RECNO, DTLIB, STATUS},{RECNO, DTLIB, STATUS}, ...}
Local nX       := 1
Local lHelp    := HelpInDark(.F.) //Habilita mostrar os helps, para que seja possível saber se houve algo durante efetivação ou desefetivação 

//abrir a tabela G3R
DbSelectArea("G3R")
DbSetOrder(2) //G3R_FILIAL+G3R_CONCIL+G3R_IDITEM

//Ao inves de filtrar, como temos um indice de FILIAL+CONCIL, vamos usar essa ordem em um laço
DbSeek(cFilFTF+cConFTF)
While G3R_CONCIL == cConFTF
	//Pegamos todos os RVs envolvidos nessa conciliação para montar o filtro da G4C
	cRvs += G3R_NUMID + "|"
	DbSkip()
EndDo

//Abrimos a G4C e aplicamos o filtro
DbSelectArea("G4C")
cFilter := "G4C_NUMID $ '" + cRvs + "' .AND. G4C_FILIAL = '" + cFilFTF + "' .AND. G4C_CLIFOR='1' .AND. G4C_CONINU=' '"
DbSetFilter(&("{|| " + cFilter + " }"),cFilter)
DbGoTop()
//Pegamos cada um dos registros e guardamos as datas de liberação para recupera-las depois.
While !EOF()
	aAdd(aG4C, {RECNO(), G4C_DTLIB, G4C_STATUS})

	//Aqui alteramos o status para que seja possivel desefetivar a conciliação
	RecLock("G4C", .F.)
	G4C_STATUS := '1'
	MsUnlock()

	DbSkip()
EndDo

//Selecionamos a conciliação e fazemos a desefetivação e efetivação
DbSelectArea("G8C")
DbSetOrder(1)
If DbSeek(cFilFTF+cConFTF)
	If TuraEfetiv('2','1') //Desfaz efetivação
		TuraEfetiv('1','1') //Refaz efetivação
	EndIf
EndIf

//Voltamos para a G4C e recuperamos as datas de liberação anteriores
For nX := 1 to Len(aG4C)

	G4C->( DbGoTo(aG4C[nX,1]) )
	RecLock("G4C", .F.)
	G4C->G4C_DTLIB := aG4C[nX,2]
	G4C_STATUS := aG4C[nX,3]
	G4C->(MsUnlock())

Next nX

HelpInDark(lHelp) //Volta o Help pro estado natural. Faço isso pois não sei de onde o usuário está executando essa função
RestArea(aArea)

Return