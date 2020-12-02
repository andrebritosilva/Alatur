#INCLUDE "Protheus.ch"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ALAR066

Fonte utilizado para retornar o corpo do e-mail do envio eletrônico de faturas

@sample 	ALAR066()
@param 		 
@return		cBody - String com o corpo do e-mail em html
@author    	Thiago Tavares
@since		22/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
User Function ALAR066()

cBody :=	'<html>'+;
				'<head>'+;
					'<style type="text/css">'+;
						'td { font-family:verdana; font-size:12px}'+;
						'p  { font-family:verdana; font-size:12px}'+;
					'</style>'+;
				'</head>'+;
				'<body>'+;
					'<p>Prezado(a),</p>' + ; 
					'<p>Segue em anexo o(s) documento(s) referente ao faturamento de nosso contrato.</p>' + ;
					'<p>Cordialmente,<br>' + ;
					'<table cellpadding="2" width="100%">'+;
						'<tr>'+;
							'<td colspan="12" align="center" bgcolor="#08364D">'+;
							'<span style="color:white;font-size:12px;"><b>' + FWFilialName() + '<b></span>' + ;	
							'</td>'+;
						'</tr>'+;
					'</table>'+;
					'<p>Está é uma mensagem automática, favor não respondê-la.</p>' + ;		
					'<p>Em caso de dúvidas, favor entrar em contato pelo e-mail <a href="mailto:saf.alatur@grupotx.com.br">mailto:saf.alatur@grupotx.com.br</a> ou pelo telefone: +55(11)2392-0405.</p>' + ;
				'</body>'+;
			'</html>' 

Return cBody
