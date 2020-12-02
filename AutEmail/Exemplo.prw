#include "protheus.ch"  
User Function Exxemplo ()
  
  files := {"C:\Users\andre\OneDrive\Documentos\Contas\Carro\Multas2015.pdf","C:\Users\andre\OneDrive\Documentos\Contas\Carro\FoxAbril.pdf"}
  
  nret := FZip("C:\boletos\imagens.zip",files)
  if nret!=0
    conout("Não foi possível criar o arquivo zip")
  else
    conout("Arquivo zip criado com sucesso")
  endif
  
  /*nret := FZip("\testing\imgs.zip",files,"\testing\","123456")
  if nret!=0
    conout("Não foi possível criar o arquivo zip")
  else
    conout("Arquivo zip criado com sucesso")
  endif*/
  
Return