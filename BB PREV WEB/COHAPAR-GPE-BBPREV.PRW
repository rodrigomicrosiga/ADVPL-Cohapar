/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualização 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Gestão de Pessoal										 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_GPE_BBPREV.PRW								 	 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Programa para geração de Arquivos Para o BB Previdência !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 09/01/2015												 !
+------------------+---------------------------------------------------------+
! ATUALIZACOES 	   															 !
+-------------------------------------------+-----------+-----------+--------+
! Descricao detalhada da atualizacao 		!Nome do    ! Analista  !Data da !
! 											!Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!  									 		! 		 	! 		 	!		 !
! 											! 		 	! 			! 		 !
+-------------------------------------------+-----------+-----------+--------+
*/
#include "Protheus.ch"

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! ARQBBPREV	! Autor !Gilson Lima 		 ! Data ! 09/01/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Tela de Processamento											 !
!			! Gera o(s) arquivo(s) TXT baseado nos parâmetros Informados	 !
+----------------------------------------------------------------------------*/
User Function ARQBBPREV()
	
	Local nItens	:= 0
	
	Private cFile	:= ""
	Private cPerg	:= "ARQBBPREV"
	Private aPergs	:= {}
	
	// Cria pergunta caso não exista
	SX1->(dbSeek(xFilial("SX1")+cPerg,.T.))
	If SX1->(!Found())

		AADD(aPergs,{"Dados Cadastrais?","","","mv_ch1","C",1,0,0,"C","","MV_PAR01","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","","","",""})
		AADD(aPergs,{"Tipo de Envio:","","","mv_ch2","C",1,0,0,"C","","MV_PAR02","Validação","","","","","Definitivo","","","","","","","","","","","","","","","","","","","","","","",""})
		AADD(aPergs,{"Informações Financeiras?","","","mv_ch3","C",1,0,0,"C","","MV_PAR03","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","","","",""})
		AADD(aPergs,{"Competência:","","","mv_ch4","C",7,0,0,"G","NAOVAZIO()","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","@E 99/9999"})
		AADD(aPergs,{"Local Arquivos:","","","mv_ch5","C",60,0,0,"G","NAOVAZIO()","MV_PAR05","","","","C:/TEMP","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
		AjustaSx1(cPerg,aPergs)
	EndIf
	
	// Carrega Perguntas
	Pergunte(cPerg,.T.)
	
	// Verifica se já existe arquivo definitivo gerado para essa competência
	// através da tabela de histórico SZG
	
	If MV_PAR02 == 2	// Arquivo Definitivo
			
		cQuery := "SELECT Count(SZG.ZG_MAT) ZG_ITENS"
		cQuery += " FROM " + RetSqlName("SZG") + " SZG"
		cQuery += " WHERE SZG.D_E_L_E_T_ <> '*'"
		cQuery += " AND SZG.ZG_COMPET = '" + Substr(MV_PAR04,4,4) + Substr(MV_PAR04,1,2) + "'"
		
		cQuery := changeQuery(cQuery) 
		
		dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),"TmpSZG", .f., .t.)
	
		While SZG->(!EOF())
			
			nItens := TmpSZG->ZG_ITENS
			
			SZG->(dbSkip())
		End	
		
		TmpSZG->(dbCloseArea())
		
		If nItens > 0
			If !MsgYesNo("Já foi gerado arquivo definitivo para a competência informada. Deseja Continuar?","Atenção")
				Return
			EndIF
		EndIf
	EndIf

	// Chama a função de importação
	If MsgYesNo("Confirma Geração de Arquivos?","Atenção")
		Processa({||BBPREV()},"BB PREV WEB","Gerando Arquivos...",.T.)
	EndIf	
Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! BBPREV	! Autor !Gilson Lima 		 ! Data ! 09/01/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Processamento													 !
!			! Roteia funções de geração de arquivos							 !
+----------------------------------------------------------------------------*/
Static Function BBPREV()

	Local cAlert := ''

	Private cCodPatroc	:= GetNewPar('MV_BBPRVCDP',  '10014')		// Código da Patrocinadora (Informado pelo BB)
	Private cCNPB		:= GetNewPar('MV_BBPRVCNPB', '2000007856')	// Código CNPB (Informado pelo BB)
	Private nContrProg	:= GetNewPar('MV_BBPRVCTPR', 84.16)			// Percentual Contribuição Programada (Informado Pelo BB)
	Private nContrRisc	:= GetNewPar('MV_BBPRVCTRC', 15.84)			// Percentual Contribuição Risco (Informado Pelo BB)
	Private cCodPlProg	:= GetNewPar('MV_BBPRVCPP',  '0109')		// Código Plano Programado
	Private cCodPlRisc	:= GetNewPar('MV_BBPRVCPR',  '0110')		// Código Plano Risco
	
	Private aCodPlano	:= {{cCodPlRisc,nContrRisc},{cCodPlProg,nContrProg}}// Código Plano = 0110 - Cohapar Risco | 0109 - Cohapar Programado
	
	Private aMensOK	    := {}
	
	// Referência baseada na competência informada
	Private cAnoRefer	:= Substr(MV_PAR04,4,4)
	Private cMesRefer	:= Substr(MV_PAR04,1,2)
	
	// Datas baseadas na competência informada
	Private dPriDiaMes	:= StoD(Substr(MV_PAR04,4,4) + Substr(MV_PAR04,1,2) + '01')	// Primeiro dia do Mês da competência informada
	Private dUltDiaMes	:= LastDay(dPriDiaMes,0)									// Último dia do Mês da competência informada
	
	// Executa Geração de arquivos de Informações Cadastrais, se MV_PAR01 = Sim
	If MV_PAR01 == 1
		Processa({||BBPREVCAD()},"BB PREV WEB","Gerando Dados Cadastrais...",.T.)
	EndIf

	// Executa Geração de arquivos de Informações Financeiras, se MV_PAR03 = Sim
	If MV_PAR03 == 1
		Processa({||BBPREVFIN()},"BB PREV WEB","Gerando Inf. Financeiras...",.T.)
	EndIf

	// Exibe mensagem com arquivos gerados com sucesso		
	If Len(aMensOK) > 0
		
		For nX := 1 To Len(aMensOK)
			cAlert += aMensOK[nX][1] + chr(10)
		Next nX

		MsgInfo(cAlert,"Geração de Arquivos OK")
	EndIf

Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! BBPREVCAD	! Autor !Gilson Lima 		 ! Data ! 09/01/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Processamento													 !
!			! Gera arquivo de Informações Cadastrais baseado nos parâmetros	 !
+----------------------------------------------------------------------------*/
Static Function BBPREVCAD()
	
	Local cArquivo 	 	:= ''	// Gera nome do arquivo para Informações Cadastrais
	Local cLinha 	 	:= ""
	Local nLinhas	 	:= 0
	Local nRegistros 	:= 0
	
	Local cTpAfast 		:= ''
	Local cDtIni 		:= ''
	Local cDtFim   		:= ''	
		
	Local cFooter	 	:= ''
	Local cHeader	 	:= ''
	Local nTotTipo2	 	:= 0
	Local nTotTipo3	 	:= 0
	Local nTotTipo4	 	:= 0
	Local nTotTipo5	 	:= 0
	Local nTotTipo6	 	:= 0
	
	Local aGravar	 	:= {}
	Local aGravarNovo	:= {}
	Local aGravarManut 	:= {}

	Local cGravar	 	:= ''
	
	Local aFunc		 	:= {} 	// Array para informações dos funcionários
	Local aFuncNovo	 	:= {} 	// Array para funcionarios novos
	Local aFuncManut 	:= {} 	// Array para funcionarios já existentes
		
	Local aPlanos	 	:= {} 	// Array para informações dos Planos Vinculados
	Local aPlanosNovo 	:= {} 	// Array para informações dos Planos Vinculados
	Local aPlanosManut 	:= {} 	// Array para informações dos Planos Vinculados
	
	Local aPercent	 	:= {} 	// Array para informações dos Percentuais de Contribuições Individuais
	Local aPercentNovo	:= {} 	// Array para informações dos Percentuais de Contribuições Individuais
	Local aPercentManut	:= {} 	// Array para informações dos Percentuais de Contribuições Individuais
	
	Local aDepend		:= {} 	// Array para informações dos dependentes
	Local aDepNovo		:= {} 	// Array para dependentes de Func Novos
	Local aDepManut  	:= {} 	// Array para dependentes de Func Manut

	Local aTempServ	 	:= {}	// Array para informações de tempo de serviço
	Local aTempServNovo	:= {} 	// Array para informações de tempo de serviço
	Local aTempServManut:= {} 	// Array para informações de tempo de serviço
	
	// Espaços reservados para os diferentes tipos de registros
	Local cReserv1	 := Replicate('0',588)	// Espaço reservado para Registros do Tipo 1
	Local cReserv2	 := Replicate('0',61)	// Espaço reservado para Registros do Tipo 2
	Local cReserv3	 := Replicate('0',568)	// Espaço reservado para Registros do Tipo 3
	Local cReserv4	 := Replicate('0',562)	// Espaço reservado para Registros do Tipo 4
	Local cReserv5	 := Replicate('0',517)	// Espaço reservado para Registros do Tipo 5
	Local cReserv6	 := Replicate('0',533)	// Espaço reservado para Registros do Tipo 6
	Local cReserv7	 := Replicate('0',569)	// Espaço reservado para Registros do Tipo 7
	 
	Local nHdl		 := 0		// Handler para gravação do arquivo
	
	// +----------------------------------------------------------------------------+
	// ! Obtenção de dados 														    !
	// +----------------------------------------------------------------------------+
	
	// Dados Cadastrais
	
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	SRA->(dbGoTop())
	
	While SRA->(!EOF())
	
		If AllTrim(DtoS(SRA->(RA_DTINPP))) <> '' ;		 // Executa apenas para funcionários que possuam data de Inscrição PP
			.And. SRA->(RA_DTINPP) < dUltDiaMes ;		 // Que a data de inscrição seja menor que último dia do mês da competência informada
			.And. (SRA->(RA_DTDLPP) > dPriDiaMes ;		 // E a data de desligamento seja maior que o primeiro dia do Mês da competência informada
			.Or. AllTrim(DtoS(SRA->(RA_DTDLPP))) == '' );// Ou data de desligamento seja vazia 
			.And. (AllTrim(DtoS(SRA->(RA_DEMISSA) )) == '' .Or. SRA->(RA_DEMISSA) >= dPriDiaMes) // Funcionários ativos ou que tenha sido demitido no mês de envio 	

			aFunc := Array(52)
			
			aFunc[1]	:= '2'											// Tipo de Registro		
			aFunc[2]	:= PadL(AllTrim(SRA->RA_MAT),9,'0')				// Matrícula do Participante
			aFunc[3]	:= PadR(AllTrim(SRA->RA_NOME),40,' ')			// Nome do Participante
			aFunc[4]	:= PadL(AllTrim(SRA->RA_CC),10,'0')				// Código da Lotação
			aFunc[5]	:= PadL(AllTrim(SRA->RA_CARGO),8,'0')			// Código do Cargo
			aFunc[6]	:= PadL(AllTrim(SRA->RA_CODFUNC),5,'0')			// Código da Função Exercida
			aFunc[7]	:= PadR(AllTrim(DtoS(SRA->RA_ADMISSA)),8,' ')	// Data de Admissão
			aFunc[8]	:= PadR(AllTrim(DtoS(SRA->RA_DEMISSA)),8,'0')	// Data de Demissão
			
			// Trata Motivo de Demissão
			If AllTrim(DtoS(SRA->RA_DEMISSA)) <> ''
				
				// Busca tipo de Rescisão
				cTpRes := Posicione("SRG",1,SRA->RA_FILIAL+SRA->RA_MAT,"RG_TIPORES")
				
				//Trata o Motivo de Demissão
				Do Case
					Case cTpRes == '14'
						aFunc[9]	:= '01'		// Aposentadoria
					Case cTpRes == '13'
						aFunc[9]	:= '02'		// Obito
					Case cTpRes $ '05_06_07_08_10_11_12_15_16_17'
						aFunc[9]	:= '03'		// Iniciativa da Patrocinadora
					Case cTpRes $ '01_02_03_04_09_18'
						aFunc[9]	:= '05'		// A Pedido
				EndCase					
			Else
				aFunc[9]	:= '  '				// Motivo de Demissão (Tratar - RA_SITFOLH -> RG_TIPORES)
			EndIf
			
			// Trata Situação na Empresa
			
			// Verifica Status e Datas de Afastamento
			
			cQuery := "SELECT TOP(1) SR8.R8_TIPO, SR8.R8_DATAINI, SR8.R8_DATAFIM"
			cQuery += " FROM " + RetSqlName("SR8")+ " SR8"
			cQuery += " WHERE SR8.D_E_L_E_T_ <> '*'"
			cQuery += " AND SR8.R8_FILIAL = '" + SRA->RA_FILIAL + "'"
			cQuery += " AND SR8.R8_MAT = '" + SRA->RA_MAT + "'"
			cQuery += " AND SR8.R8_TIPO <> 'F'"					// Diferente de Férias
			cQuery += " ORDER BY SR8.R8_DATAINI DESC"
			
			cQuery := changeQuery(cQuery) 
			
			dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),"TmpSR8", .f., .t.)
		
			While TmpSR8->(!EOF())
			
				cTpAfast := TmpSR8->R8_TIPO
				cDtIni	 := TmpSR8->R8_DATAINI
				cDtFim   := TmpSR8->R8_DATAFIM
				
				TmpSR8->(dbSkip())
			End
			
			TmpSR8->(dbCloseArea())
		
			If AllTrim(SRA->RA_SITFOLH) <> ''
				If (SRA->RA_SITFOLHA) == 'A'	// Afastado
					If AllTrim(cDtFim) == ''
						Do Case
							Case cTpAfast $ 'OP'
								aFunc[10]	:= '02'		// Licença Saúde
							Case cTpAfast $ 'RX'
								aFunc[10]	:= '06'		// Licença Sem Remuneração
							Case cTpAfast == 'Q'
								aFunc[10]	:= '07'		// Licença Maternidade
							Otherwise
								aFunc[10]	:= '00'		// Sem Informação
						EndCase
						
						aFunc[11]	:= PadR(AllTrim(cDtIni),8,'0')		// Data da Situação na Empresa
					Else
						aFunc[10]	:= '01'								// Ativo
						aFunc[11]	:= PadR(AllTrim(cDtIni),8,'0')		// Data da Situação na Empresa
					EndIf
				ElseIf (SRA->RA_SITFOLHA) == 'D'
					aFunc[10]	:= '05'								// Ativo
					aFunc[11]	:= PadR(AllTrim(DtoS(SRA->RA_DEMISSA)),8,'0')		// Data da Situação na Empresa
				Else
					aFunc[10]	:= '01'								// Ativo
					
					// Define a Data quando Ativo
					If AllTrim(cDtFim) <> ''
						aFunc[11] := PadR(AllTrim(DtoS(StoD(cDtFim) + 1)),8,'0')	// Data da Situação na Empresa
					Else
						aFunc[11]	:= PadR(AllTrim(DtoS(SRA->RA_ADMISSA)),8,'0')	// Data da Situação na Empresa
					EndIf
				EndIf
			Else
				aFunc[10]	:= '01'		// Ativo
				
				// Define a Data quando Ativo
				If AllTrim(cDtFim) <> ''
					aFunc[11] := PadR(AllTrim(DtoS(StoD(cDtFim) + 1)),8,'0')	// Data da Situação na Empresa
				Else
					aFunc[11] := PadR(AllTrim(DtoS(SRA->RA_ADMISSA)),8,'0')	// Data da Situação na Empresa
				EndIf			
			EndIf
		
			aFunc[12]	:= PadR(AllTrim(SRA->RA_SEXO),1,' ')			// Sexo
			
			// Trata Estado Civil
			Do Case
				Case SRA->RA_ESTCIVI == 'S'		// Estado Civil - Solteiro(a)
					aFunc[13]	:= '1'	
				Case SRA->RA_ESTCIVI == 'C'		// Estado Civil - Casado(a)
					aFunc[13]	:= '2'
				Case SRA->RA_ESTCIVI == 'V'		// Estado Civil - Viúvo(a)
					aFunc[13]	:= '3'
				Case SRA->RA_ESTCIVI == 'D'		// Estado Civil - Divorciado(a)
					aFunc[13]	:= '5'
				Case SRA->RA_ESTCIVI == 'M'		// Estado Civil - Companheiro(a)
					aFunc[13]	:= '6'
				Otherwise
					aFunc[13]	:= '7'			// Estado Civil - Outros
			EndCase

			// Trata Grau de Instrução
			Do Case
				Case SRA->RA_GRINRAI == '30'	// Grau de Instrução - 1º Grau Incompleto
					aFunc[14]	:= '1'
				Case SRA->RA_GRINRAI == '35'	// Grau de Instrução - 1º Grau Completo
					aFunc[14]	:= '2'
				Case SRA->RA_GRINRAI == '40'	// Grau de Instrução - 2º Grau Incompleto
					aFunc[14]	:= '3'
				Case SRA->RA_GRINRAI == '45'	// Grau de Instrução - 2º Grau Completo
					aFunc[14]	:= '4'
				Case SRA->RA_GRINRAI == '50'	// Grau de Instrução - 3º Grau Incompleto
					aFunc[14]	:= '5'
				Case SRA->RA_GRINRAI $ '55_85'	// Grau de Instrução - 3º Grau Completo
					aFunc[14]	:= '6'
				Case SRA->RA_GRINRAI == '65'	// Grau de Instrução - Mestrado
					aFunc[14]	:= '7'
				Case SRA->RA_GRINRAI == '75_95'	// Grau de Instrução - Doutorado
					aFunc[14]	:= '8'
				Otherwise
					aFunc[14]	:= '0'			// Grau de Instrução - Não informado
			EndCase

			aFunc[15]	:= PadR(AllTrim(SRA->RA_ENDEREC),40,' ')		// Endereço Residencial
			aFunc[16]	:= PadR(AllTrim(SRA->RA_NUMENDE),6,' ')			// Número do Endereço Residencial
			aFunc[17]	:= PadR(AllTrim(SRA->RA_COMPLEM),30,' ')		// Complemento do Endereço Residencial
			aFunc[18]	:= PadR(AllTrim(SRA->RA_BAIRRO),20,' ')			// Bairro do Endereço Residencial
			aFunc[19]	:= PadR(AllTrim(SRA->RA_MUNICIP),20,' ')		// Cidade do Endereço Residencial
			aFunc[20]	:= PadR(AllTrim(SRA->RA_ESTADO),2,' ')			// UF do Endereço Residencial
			aFunc[21]	:= PadR(AllTrim(SRA->RA_CEP),8,' ')				// CEP do Endereço Residencial
			aFunc[22]	:= PadL(AllTrim(SRA->RA_DDDFONE),3,'0')			// DDD do Telefone Residencial
			aFunc[23]	:= PadL(AllTrim(StrTran(SRA->RA_TELEFON,'-','')),17,'0')		// Telefone Residencial
			aFunc[24]	:= PadL(AllTrim('041'),3,'0')					// DDD Telefone Comercial
			aFunc[25]	:= PadL(AllTrim('33125700'),17,'0')				// Telefone Comercial
			aFunc[26]	:= PadL(AllTrim(SRA->RA_DDDCELU),3,'0')			// DDD Telefone Celular
			aFunc[27]	:= PadL(AllTrim(StrTran(SRA->RA_NUMCELU,'-','')),17,'0')		// Telefone Celular
			aFunc[28]	:= PadR(AllTrim(SRA->RA_MUNNASC),20,' ')		// Cidade de Nascimento
			aFunc[29]	:= PadR(AllTrim(SRA->RA_NATURAL),2,' ')			// UF de Nascimento
			aFunc[30]	:= PadR(AllTrim(SRA->RA_NACIONA),2,' ')			// Código da Nacionalidade
			aFunc[31]	:= PadR(AllTrim(DtoS(SRA->RA_NASC)),8,' ')		// Data de Nascimento
			aFunc[32]	:= PadL(AllTrim(SRA->RA_CIC),11,'0')			// Número do CPF
			aFunc[33]	:= PadR(AllTrim(SRA->RA_RG),12,' ')				// Número da Carteira de Identidade
			aFunc[34]	:= PadR(AllTrim(SRA->RA_RGORG),8,' ')			// Órgão de Emissão Carteira de Identidade
			aFunc[35]	:= PadR(AllTrim(SRA->RA_RGUF),2,' ')			// UF do Órgão de Emissão Carteira de Identidade
			If AllTrim(DtoS(SRA->))
			aFunc[36]	:= PadR(AllTrim(DtoS(SRA->RA_DTRGEXP)),8,'0')	// Data de Emissão Carteira de Identidade
			
			aFunc[37]	:= PadL(AllTrim('0'),1,'0')						// Forma de Recolhimento das Contribuições (0 = Desconto em Folha)
			aFunc[38]	:= PadR(AllTrim('001'),3,' ')					// Número do Banco (Sempre 001)
			aFunc[39]	:= PadR(AllTrim(''),5,' ')						// Código da Agência (Não Informado = Desconto em Folha)
			aFunc[40]	:= PadR(AllTrim(''),1,' ')						// Dígito Verificador da Agência (Não Informado = Desconto em Folha)
			aFunc[41]	:= PadL(AllTrim(''),11,'0')						// Conta Corrente (Não Informado = Desconto em Folha)
			aFunc[42]	:= PadR(AllTrim(''),1,' ')						// Dígito Verificador da Conta Corrente (Não Informado = Desconto em Folha)
			
			If AllTrim(SRA->RA_PAI) != ''
				aFunc[43]	:= PadR(AllTrim(SRA->RA_PAI),30,' ')			// Nome do Pai
			Else
				aFunc[43]	:= PadR('NÃO DECLARADO',30,' ')
			EndIf

			If AllTrim(SRA->RA_MAE) != ''
				aFunc[44]	:= PadR(AllTrim(SRA->RA_MAE),30,' ')			// Nome da Mãe
			Else
				aFunc[44]	:= PadR('NÃO DECLARADO',30,' ')
			EndIf

			aFunc[45]	:= PadR(AllTrim(SRA->RA_EMAIL),60,' ')			// Email
			
			aFunc[46]	:= PadR(AllTrim('I'),1,' ')						// Opção Pelo Regime de Tributação (Verificar)
			aFunc[47]	:= PadR(AllTrim('0'),1,'0')						// Opção de Investimento (Verificar)
			
			aFunc[48]	:= PadR(AllTrim('A'),1,' ')						// Situação na Admissão (Verificar)
			
			// Trata rendimentos mensais
			
			nVlRendim	:= RetRenda(SRA->RA_MAT)
			
/*			nVlRendim	:= POSICIONE("SRC",1,xFilial("SRC")+SRA->RA_MAT+'800',"RC_VALOR") // Busca Verba 800 usada para cálculo previdência
			If nVlRendim == 0
				nVlRendim := SRA->RA_SALARIO
			EndIf
*/			
			
			aFunc[49]	:= PadL(StrTran(LTrim(Transform(nVlRendim, "@E 999999999999.99")),",",""),11,'0')	// Valor dos Rendimentos Mensais
			
			aFunc[50]	:= PadL(StrTran(LTrim(Transform(0, "@E 999999999999.99")),",",""),11,'0')		// Valor do Patrimônio Bruto
			aFunc[51]	:= PadR(AllTrim('00000000'),8,' ')				// Data de Protocolo
			aFunc[52]	:= PadR(AllTrim('P'),1,' ')						// Indicador de Tipo de Funcionário (Verificar)
			
			cGeraArq := "P" // Define Tipo de Arquivo como Novo (P = Proposta) 

			// +----------------------------------------------------------------------------+
			// ! Verifica se o registro é manutenção, proposta ou não deve ser 			    !
			// ! incluído através da tabela SZG que contém o histórico de arquivos gerados  !
			// +----------------------------------------------------------------------------+			
			
			// Monta String com dados da SRA atual
			cDadosSRA := ''
			For nZ := 2 To Len(aFunc)
				If StrZero(nZ,2) $ '47_48'
					Loop
				EndIf 
				cDadosSRA += aFunc[nZ]
			Next nZ
			
			// Monta String com dados da Tabela SZG. Última Competência 
			cQuery := "SELECT TOP(1) SZG.ZG_MAT, SZG.ZG_NOME, SZG.ZG_LOTACAO, SZG.ZG_CARGO, SZG.ZG_FUNCAO, SZG.ZG_DTADMIS, SZG.ZG_DTDEMIS, SZG.ZG_MTDEMIS"
			cQuery += ", SZG.ZG_SITEMPR, SZG.ZG_DTSITEP, SZG.ZG_SEXO, SZG.ZG_ECIVIL, SZG.ZG_GRINSTR, SZG.ZG_ENDEREC, SZG.ZG_NRENDRE, SZG.ZG_COMPEND, SZG.ZG_BAIRRO"
			cQuery += ", SZG.ZG_CIDADE, SZG.ZG_UF, SZG.ZG_CEP, SZG.ZG_DDDRES, SZG.ZG_TELRES, SZG.ZG_DDDCOML, SZG.ZG_TELCOML, SZG.ZG_DDDCEL, SZG.ZG_TELCEL"
			cQuery += ", SZG.ZG_CIDNASC, SZG.ZG_UFNASC, SZG.ZG_CODNASC, SZG.ZG_DTNASC, SZG.ZG_CPF, SZG.ZG_RG, SZG.ZG_RGORG, SZG.ZG_RGORGUF, SZG.ZG_RGDTEMI"
			cQuery += ", SZG.ZG_FRMRECO, SZG.ZG_NRBANCO, SZG.ZG_CODAGEN, SZG.ZG_DVAGE, SZG.ZG_CTCORRE, SZG.ZG_DVCCORR, SZG.ZG_NMPAI, SZG.ZG_NMMAE, SZG.ZG_EMAIL"
			cQuery += ", SZG.ZG_OPCREGT, SZG.ZG_OPCINVE, SZG.ZG_SITADMI, SZG.ZG_VLINVME, SZG.ZG_VLPATRB, SZG.ZG_DTPROTO, SZG.ZG_TPFUNC"
			cQuery += " FROM " + RetSqlName("SZG") + " SZG"
			cQuery += " WHERE SZG.D_E_L_E_T_ <> '*'"
			cQuery += " AND SZG.ZG_COMPET < '" + cAnoRefer+cMesRefer + "'"
			cQuery += " AND SZG.ZG_MAT = '" + aFunc[2] + "'"
			cQuery += " ORDER BY SZG.ZG_COMPET DESC"
			
			cQuery := changeQuery(cQuery) 
			
			dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),"Tmp1", .f., .t.)
		
			While Tmp1->(!EOF())
				
				cDadosTmp := Tmp1->ZG_MAT + Tmp1->ZG_NOME + Tmp1->ZG_LOTACAO + Tmp1->ZG_CARGO + Tmp1->ZG_FUNCAO + Tmp1->ZG_DTADMIS + Tmp1->ZG_DTDEMIS + Tmp1->ZG_MTDEMIS
				cDadosTmp += Tmp1->ZG_SITEMPR + Tmp1->ZG_DTSITEP + Tmp1->ZG_SEXO + Tmp1->ZG_ECIVIL + Tmp1->ZG_GRINSTR + Tmp1->ZG_ENDEREC + Tmp1->ZG_NRENDRE + Tmp1->ZG_COMPEND + Tmp1->ZG_BAIRRO
				cDadosTmp += Tmp1->ZG_CIDADE + Tmp1->ZG_UF + Tmp1->ZG_CEP + Tmp1->ZG_DDDRES + Tmp1->ZG_TELRES + Tmp1->ZG_DDDCOML + Tmp1->ZG_TELCOML + Tmp1->ZG_DDDCEL + Tmp1->ZG_TELCEL
				cDadosTmp += Tmp1->ZG_CIDNASC + Tmp1->ZG_UFNASC + Tmp1->ZG_CODNASC + Tmp1->ZG_DTNASC + Tmp1->ZG_CPF + Tmp1->ZG_RG + Tmp1->ZG_RGORG + Tmp1->ZG_RGORGUF + Tmp1->ZG_RGDTEMI
				cDadosTmp += Tmp1->ZG_FRMRECO + Tmp1->ZG_NRBANCO + Tmp1->ZG_CODAGEN + Tmp1->ZG_DVAGE + Tmp1->ZG_CTCORRE + Tmp1->ZG_DVCCORR + Tmp1->ZG_NMPAI + Tmp1->ZG_NMMAE + Tmp1->ZG_EMAIL
				cDadosTmp += Tmp1->ZG_OPCREGT + Tmp1->ZG_VLINVME + Tmp1->ZG_VLPATRB + Tmp1->ZG_DTPROTO + Tmp1->ZG_TPFUNC
				
				// Verifica informações
				If cDadosSRA == cDadosTmp
					cGeraArq := "N" // Não Gera Arquivo
				Else
					cGeraArq := "M" // Gera arquivo de Manutenção
					
					// Alterações em caso de manutenção
					aFunc[47]	:= PadR(AllTrim('0'),1,'0')		// Opção de Investimento quando manutenção = ZERO
					aFunc[48]	:= PadR(AllTrim(' '),1,' ')		// Situação na Admissão quando manutenção = espaço
				EndIf		
	
				Tmp1->(dbSkip())
			End
			
			Tmp1->(dbCloseArea())	
			
			// +----------------------------------------------------------------------------+
			// ! Se for gerar o arquivo														!
			// +----------------------------------------------------------------------------+
		
			If cGeraArq <> 'N'

				// +----------------------------------------------------------------------------+
				// ! Busca Informações de Planos										    !
				// ! Registros Tipo 3															!
				// +----------------------------------------------------------------------------+
				
				For nG := 1 To Len(aCodPlano)
					aPlanos := Array(6)
					
					aPlanos[1]	:= '3'											// Tipo de Registro
					aPlanos[2]	:= PadL(AllTrim(SRA->RA_MAT),9,'0')				// Matrícula do Participante
					aPlanos[3]	:= PadR(AllTrim(aCodPlano[nG][1]),4,' ')		// Código do Plano
					
					// Trata data de Inscrição no Plano
					If cGeraArq == 'P' 		// Novo = P (Proposta)
						// OBS: Modificar comentário das duas linhas abaixo para habilitar a validaçao de proposta
						
						//aPlanos[4]	:= PadR(AllTrim('00000000'),8,'0')// Data de Inscrição no Plano
						aPlanos[4]	:= PadR(AllTrim(DtoS(SRA->RA_DTINPP)),8,' ')// Data de Inscrição no Plano
					ElseIf cGeraArq == 'M' 	// Manutenção = M
						aPlanos[4]	:= PadR(AllTrim(DtoS(SRA->RA_DTINPP)),8,' ')// Data de Inscrição no Plano
					EndIf
	
					// Trata situação do Plano
					If cGeraArq == 'P' 		// Novo = P (Proposta)			// Situação no Plano
						aPlanos[5]	:= '01'
					ElseIf cGeraArq == 'M' 	// Manutenção = M
						aPlanos[5]	:= '01'
					EndIf								
				
					// Trata data de Inscrição no Plano
					If cGeraArq == 'P' 		// Novo = P (Proposta)
						//aPlanos[6]	:= PadR(AllTrim('00000000'),8,'0')// Data de Situação no Plano
						aPlanos[6]	:= PadR(AllTrim(DtoS(SRA->RA_DTINPP)),8,' ')// Data de Situação no Plano
					ElseIf cGeraArq == 'M' 	// Manutenção = M
						aPlanos[6]	:= PadR(AllTrim(DtoS(SRA->RA_DTINPP)),8,' ')// Data de Situação no Plano
					EndIf
	
					// Verifica o tipo de Geração e insere as informações no array correspondente
					If cGeraArq == 'P' 		// Novo = P (Proposta)
						aAdd(aPlanosNovo,aPlanos)
					ElseIf cGeraArq == 'M' 	// Manutenção = M
						aAdd(aPlanosManut,aPlanos)
					EndIf
				Next Ng
				
				/*******************************************************************************************/				
				
				// +----------------------------------------------------------------------------+
				// ! Busca Informações de Contribuições Individuais										    !
				// ! Registros Tipo 4															!
				// +----------------------------------------------------------------------------+
				
				/**
				 NAO GERAR POR ORIENTACAO DA SRA. NATÁLIDA DO BB:
				 
				 No arquivo veio informaçoes do Registro Tipo 4 (Percentual Individual), mas como no Plano COHAPREV o participante não 
				 escolhe o percentual de contribuição a ser vertido (a contribuição é função do salário e da idade), esse tipo de registro 
				 não deve vir no arquivo.				
				
				aVerbas := {}
				
				nV530 := POSICIONE("SRC",1,xFilial("SRC")+SRA->RA_MAT+'530',"RC_VALOR") // Busca Verba 530 usada para cálculo previdência
				nV531 := POSICIONE("SRC",1,xFilial("SRC")+SRA->RA_MAT+'531',"RC_VALOR") // Busca Verba 531 usada para cálculo previdência
				nV532 := POSICIONE("SRC",1,xFilial("SRC")+SRA->RA_MAT+'532',"RC_VALOR") // Busca Verba 532 usada para cálculo previdência
				
				If nV530 > 0
					aAdd(aVerbas,{'530','01',nV530})
				EndIF
				 
				If nV531 > 0
					aAdd(aVerbas,{'531','03',nV531})
				EndIF

				If nV532 > 0
					aAdd(aVerbas,{'532','10',nV532})
				EndIF

				For nB := 1 To Len (aVerbas)
					aPercent := Array(8)
					
					aPercent[1]	:= '4'										// Tipo de Registro
					aPercent[2]	:= PadR(AllTrim(cAnoRefer),4,' ')			// Ano de Referência
					aPercent[3]	:= PadR(AllTrim(cMesRefer),2,' ')			// Mês de Referência
					aPercent[4]	:= PadL(AllTrim(SRA->RA_MAT),9,'0')			// Matrícula do Participante
					aPercent[5]	:= PadR(AllTrim(cCodPlano),4,' ')			// Código do Plano
					aPercent[6]	:= PadR(AllTrim(aVerbas[nB][2]),2,' ')		// Código da Contribuição
					aPercent[7]	:= PadL(StrTran(LTrim(Transform(aVerbas[nB][3], "@E 999999999999.99")),",",""),8,'0')	// Valor Contr. Participante
					aPercent[8]	:= PadL(StrTran(LTrim(Transform(aVerbas[nB][3], "@E 999999999999.99")),",",""),8,'0')	// Valor Contr. Patrocinadora
	
					// Verifica o tipo de Geração e insere as informações no array correspondente
					If cGeraArq == 'P' 		// Novo = P (Proposta)
						aAdd(aPercentNovo,aPercent)
					ElseIf cGeraArq == 'M' 	// Manutenção = M
						aAdd(aPercentManut,aPercent)
					EndIf
					
				Next nB
				
				*/
				
				/*******************************************************************************************/				
	
				// +----------------------------------------------------------------------------+
				// ! Busca Informações de Dependentes										    !
				// ! Registros Tipo 5															!
				// +----------------------------------------------------------------------------+

				/**
				 NAO GERAR POR ORIENTACAO DO SR. VALDNEY - COHAPAR
				 Pois segundo eles essas informações serão incluídas/alteradas diretamente no sistema da BB Previdência

				dbSelectArea("SRB")
				SRB->(dbSetOrder(1))
				SRB->(dbSeek(xFilial("SRB")+SRA->RA_MAT))
				
				While SRB->(!EOF()) .And. xFilial("SRB")+SRB->RB_MAT == xFilial("SRB")+SRA->RA_MAT
					
					aDepend := Array(8)
					
					aDepend[1]	:= '5'									// Tipo de Registro - 5 = Dependentes
					aDepend[2]	:= PadL(AllTrim(SRA->RA_MAT),9,'0')		// Matrícula do Participante
					aDepend[3]	:= PadR(AllTrim(SRB->RB_NOME),60,' ')	// Nome do Dependente

					// Trata Grau de Parentesco
					Do Case
						Case SRB->RB_GRAUPAR == 'C'						// Grau de Parentesco - Cônjuge
							aDepend[4]	:= '01'	
						Case SRB->RB_GRAUPAR == 'F'						// Grau de Parentesco - Filhos
							aDepend[4]	:= '08'	
						Case SRB->RB_GRAUPAR == 'E'						// Grau de Parentesco - Enteados
							aDepend[4]	:= '09'	
						Case SRB->RB_GRAUPAR == 'P'						// Grau de Parentesco - Pai / Mãe
							aDepend[4]	:= '20'	
						Otherwise
							aDepend[4]	:= '16'							// Grau de Parentesco - Indicado (Outros)
					EndCase
							
					aDepend[5]	:= PadR(AllTrim(SRB->RB_SEXO),1,' ')	// Sexo do Dependente
					aDepend[6]	:= PadR(AllTrim(DtoS(SRB->RB_DTNASC)),8,' ')	// Data de Nascimento do Dependente
					aDepend[7]	:= PadR(AllTrim('N'),1,' ')				// Inválido? (S/N)
					aDepend[8]	:= IIF(SRB->RB_TIPIR $ '123', 'S', 'N')	// Dependente para IRRF?
					
					// Verifica o tipo de Geração e insere as informações no array correspondente
					If cGeraArq == 'P' 		// Novo = P (Proposta)
						aAdd(aDepNovo,aDepend)
					ElseIf cGeraArq == 'M' 	// Manutenção = M
						aAdd(aDepManut,aDepend)
					EndIf									
							
					SRB->(dbSkip())
				End
				
				SRB->(dbCloseArea())

				/*******************************************************************************************/				
				
				*/
				
				// Verifica o tipo de Geração e insere as informações no array correspondente
				If cGeraArq == 'P' 		// Novo = P (Proposta)
					aAdd(aFuncNovo,aFunc)
				ElseIf cGeraArq == 'M' 	// Manutenção = M
					aAdd(aFuncManut,aFunc)
				EndIf
				
				/*******************************************************************************************/				
				
			EndIf
		EndIf
		
		SRA->(dbSkip())		
	End
	
	SRA->(dbCloseArea())

	// +----------------------------------------------------------------------------+
	// ! Processamento dos dados e Tratamento para gravação						    !
	// +----------------------------------------------------------------------------+	
	
	// +----------------------------------------------------------------------------+
	// ! Registros Tipo 2 - Dados Cadastrais							    !
	// +----------------------------------------------------------------------------+	
	
	// Novos

	If Len(aFuncNovo) > 0
		For nA := 1 To Len(aFuncNovo)

			cGravar := '2'		// Tipo de Registro
			
			// Acrescenta campos à linha de gravação
			For nB := 2 To Len(aFuncNovo[nA])
				cGravar += aFuncNovo[nA][nB]
			Next nB
			
			cGravar += cReserv2	// Acrescenta Campos Reservados (Caracter 0)
			
			// Adiciona no Array de registros a gravar
			aAdd(aGravarNovo,cGravar)
		Next nA
		
		// Se a geração for Definitiva
		// Grava tabela de Histórico
		If MV_PAR02 == 2
			GravaHist(aFuncNovo)
		EndIf
	EndIf

	// Registros Tipo 2 - Dados Cadastrais Manut
	If Len(aFuncManut) > 0
		For nA := 1 To Len(aFuncManut)

			cGravar := '2'		// Tipo de Registro
			
			// Acrescenta campos à linha de gravação
			For nB := 2 To Len(aFuncManut[nA])
				cGravar += aFuncManut[nA][nB]
			Next nB
			
			cGravar += cReserv2	// Acrescenta Campos Reservados (Caracter 0)
			
			// Adiciona no Array de registros a gravar
			aAdd(aGravarManut,cGravar)
		Next nA

		// Se a geração for Definitiva
		// Grava tabela de Histórico
		If MV_PAR02 == 2
			GravaHist(aFuncManut)
		EndIf
	EndIf
	
	// +----------------------------------------------------------------------------+
	// ! Registros Tipo 3 - Planos Vinculados									    !
	// +----------------------------------------------------------------------------+	
	
	// Novos
	If Len(aPlanosNovo) > 0
		For nA := 1 To Len(aPlanosNovo)

			cGravar := '3'		// Tipo de Registro
			
			// Acrescenta campos à linha de gravação
			For nB := 2 To Len(aPlanosNovo[nA])
				cGravar += aPlanosNovo[nA][nB]
			Next nB
			
			cGravar += cReserv3	// Acrescenta Campos Reservados (Caracter 0)
			
			// Adiciona no Array de registros a gravar
			aAdd(aGravarNovo,cGravar)
		
		Next nA
	EndIf

	// Registros Tipo 3 - Manutenção Planos Vinculados
	If Len(aPlanosManut) > 0
		For nA := 1 To Len(aPlanosManut)

			cGravar := '3'		// Tipo de Registro
			
			// Acrescenta campos à linha de gravação
			For nB := 2 To Len(aPlanosManut[nA])
				cGravar += aPlanosManut[nA][nB]
			Next nB
			
			cGravar += cReserv3	// Acrescenta Campos Reservados (Caracter 0)
			
			// Adiciona no Array de registros a gravar
			aAdd(aGravarManut,cGravar)
		
		Next nA
	EndIf
	
	// +----------------------------------------------------------------------------+
	// ! Registros Tipo 4 - Percentuais de Contribuições Individuais									    !
	// +----------------------------------------------------------------------------+	
	
	// Novos
	If Len(aPercentNovo) > 0
		For nA := 1 To Len(aPercentNovo)

			cGravar := '4'		// Tipo de Registro
			
			// Acrescenta campos à linha de gravação
			For nB := 2 To Len(aPercentNovo[nA])
				cGravar += aPercentNovo[nA][nB]
			Next nB
			
			cGravar += cReserv4	// Acrescenta Campos Reservados (Caracter 0)
			
			// Adiciona no Array de registros a gravar
			aAdd(aGravarNovo,cGravar)
		
		Next nA
	EndIf

	// Registros Tipo 4 - Manutenção
	If Len(aPercentManut) > 0
		For nA := 1 To Len(aPercentManut)

			cGravar := '4'		// Tipo de Registro
			
			// Acrescenta campos à linha de gravação
			For nB := 2 To Len(aPercentManut[nA])
				cGravar += aPercentManut[nA][nB]
			Next nB
			
			cGravar += cReserv4	// Acrescenta Campos Reservados (Caracter 0)
			
			// Adiciona no Array de registros a gravar
			aAdd(aGravarManut,cGravar)
		
		Next nA
	EndIf

	// +----------------------------------------------------------------------------+
	// ! Registros Tipo 5 - Dependentes											    !
	// +----------------------------------------------------------------------------+	
	
	// Novos
	If Len(aDepNovo) > 0
		For nA := 1 To Len(aDepNovo)

			cGravar := '5'		// Tipo de Registro

			// Acrescenta campos à linha de gravação
			For nB := 2 To Len(aDepNovo[nA])
				cGravar += aDepNovo[nA][nB]
			Next nB
			
			cGravar += cReserv5	// Acrescenta Campos Reservados (Caracter 0)
			
			// Adiciona no Array de registros a gravar
			aAdd(aGravarNovo,cGravar)
		Next nA
	EndIf

	// Registros Tipo 5 - Dependentes - Manut
	If Len(aDepManut) > 0
		For nA := 1 To Len(aDepManut)

			cGravar := '5'		// Tipo de Registro

			// Acrescenta campos à linha de gravação
			For nB := 2 To Len(aDepManut[nA])
				cGravar += aDepManut[nA][nB]
			Next nB
			
			cGravar += cReserv5	// Acrescenta Campos Reservados (Caracter 0)
			
			// Adiciona no Array de registros a gravar
			aAdd(aGravarManut,cGravar)
		Next nA
	EndIf

	// +----------------------------------------------------------------------------+
	// ! Registros Tipo 6 - Tempo de Serviço									    !
	// +----------------------------------------------------------------------------+	

	If Len(aTempServ) > 0
		For nA := 1 To Len(aTempServ)
		
		Next nA
	EndIf

	// +----------------------------------------------------------------------------+
	// ! GRAVAÇÃO DE ARQUIVO													    !
	// +----------------------------------------------------------------------------+	
	
	// Se houver registros Novos a gravar, executa a gravação
	If Len(aGravarNovo) > 0
	
		cArquivo 	 := NomeArq('P')		// Gera nome do arquivo para Informações Cadastrais
		nHdl		 := fCreate(cArquivo)	// Inicia gravação do arquivo
		
		// Caso não consiga criar arquivo, informa o erro e aborta o sistema
		If nHdl == -1
			MsgAlert("O arquivo de nome "+cArquivo+" não pode ser criado! Verifique os parâmetros.","Atenção!")
			Return
		EndIf
	
		ProcRegua(Len(aGravarNovo))	// Número de registros a Gravar

		// +----------------------------------------------------------------------------+
		// ! Grava Cabeçalho														    !
		// +----------------------------------------------------------------------------+
		 		
		cHeader := '1'			// Tipo de Registro - 1 = Cabeçalho
		cHeader += cCodPatroc	// Código da Patrocinadora
		cHeader += cAnoRefer	// Ano de Referência
		cHeader += cMesRefer	// Mes de Referência
		cHeader += cReserv1		// Campos Reservados (Preenchido com 0)
		cHeader += CRLF			// Adiciona quebra de linha
		
		// Gravação do arquivo
		fWrite(nHdl,cHeader,Len(cHeader))

		// +----------------------------------------------------------------------------+
		// ! Grava Registros no Arquivo												    !
		// +----------------------------------------------------------------------------+
		 
		For nY := 1 to Len(aGravarNovo)
		
			IncProc() // Incrementa a régua
			nLinhas++
			
			cLinha	:= aGravarNovo[nY]
			cLinha  += CRLF	// Adiciona quebra de linha
			
			// Gravação do arquivo. Testa por erros durante a gravação
			If fWrite(nHdl,cLinha,Len(cLinha)) != Len(cLinha)
				If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
					Exit
				EndIf
			EndIf
		Next nY

		// +----------------------------------------------------------------------------+
		// ! Grava Rodapé															    !
		// +----------------------------------------------------------------------------+		
		
		nTotTipo2	:= Len(aFuncNovo)
		nTotTipo3	:= Len(aPlanosNovo)
		nTotTipo4	:= Len(aPercentNovo)
		nTotTipo5	:= Len(aDepNovo)
		nTotTipo6	:= Len(aTempServNovo)
		
		cFooter 	:= '7'					// Registro Tipo 7 = Totalizadores
		
		If MV_PAR02 == 1
			//cFooter += 'VALIDACAO|'
		EndIf
		
		cFooter 	+= StrZero(nTotTipo2,6)	// Total Registros Tipo 2
		cFooter 	+= StrZero(nTotTipo3,6)	// Total Registros Tipo 3
		cFooter 	+= StrZero(nTotTipo4,6)	// Total Registros Tipo 4
		cFooter 	+= StrZero(nTotTipo5,6)	// Total Registros Tipo 5
		cFooter 	+= StrZero(nTotTipo6,6)	// Total Registros Tipo 6
		cFooter 	+= cReserv7				// Campos Reservados (Preenchido com 0)

		// Gravação do arquivo. 
		fWrite(nHdl,cFooter,Len(cFooter))
		
		// Fecha o arquivo texto
		fClose(nHdl)
		
		// Adiciona mensagem de arquivo gerado com sucesso
		AADD(aMensOK,{"Novos - Informações Cadastrais"})
	EndIf

	// Se houver manutenção de registros a gravar, executa a gravação
	If Len(aGravarManut) > 0
	
		cArquivo 	 := NomeArq('M')		// Gera nome do arquivo para Informações Cadastrais
		nHdl		 := fCreate(cArquivo)	// Inicia gravação do arquivo
		
		// Caso não consiga criar arquivo, informa o erro e aborta o sistema
		If nHdl == -1
			MsgAlert("O arquivo de nome "+cArquivo+" não pode ser criado! Verifique os parâmetros.","Atenção!")
			Return
		EndIf
	
		ProcRegua(Len(aGravarManut))	// Número de registros a Gravar

		// +----------------------------------------------------------------------------+
		// ! Grava Cabeçalho														    !
		// +----------------------------------------------------------------------------+
	 		
		cHeader := '1'			// Tipo de Registro - 1 = Cabeçalho
		cHeader += cCodPatroc	// Código da Patrocinadora
		cHeader += cAnoRefer	// Ano de Referência
		cHeader += cMesRefer	// Mes de Referência
		cHeader += cReserv1		// Campos Reservados (Preenchido com 0)
		cHeader += CRLF			// Adiciona quebra de linha
		
		// Gravação do arquivo
		fWrite(nHdl,cHeader,Len(cHeader))

		// +----------------------------------------------------------------------------+
		// ! Grava Registros no Arquivo												    !
		// +----------------------------------------------------------------------------+
		 
		For nY := 1 to Len(aGravarManut)
		
			IncProc() // Incrementa a régua
			nLinhas++
			
			cLinha	:= aGravarManut[nY]
			cLinha  += CRLF	// Adiciona quebra de linha
			
			// Gravação do arquivo. Testa por erros durante a gravação
			If fWrite(nHdl,cLinha,Len(cLinha)) != Len(cLinha)
				If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
					Exit
				EndIf
			EndIf
		Next nY

		// +----------------------------------------------------------------------------+
		// ! Grava Rodapé															    !
		// +----------------------------------------------------------------------------+		
		
		nTotTipo2	:= Len(aFuncManut)
		nTotTipo3	:= Len(aPlanosManut)
		nTotTipo4	:= Len(aPercentManut)
		nTotTipo5	:= Len(aDepManut)
		nTotTipo6	:= Len(aTempServManut)
		
		cFooter 	:= '7'					// Registro Tipo 7 = Totalizadores
		
		If MV_PAR02 == 1
			//cFooter += 'VALIDACAO|'
		EndIf	
			
		cFooter 	+= StrZero(nTotTipo2,6)	// Total Registros Tipo 2
		cFooter 	+= StrZero(nTotTipo3,6)	// Total Registros Tipo 3
		cFooter 	+= StrZero(nTotTipo4,6)	// Total Registros Tipo 4
		cFooter 	+= StrZero(nTotTipo5,6)	// Total Registros Tipo 5
		cFooter 	+= StrZero(nTotTipo6,6)	// Total Registros Tipo 6
		cFooter 	+= cReserv7				// Campos Reservados (Preenchido com 0)

		// Gravação do arquivo. 
		fWrite(nHdl,cFooter,Len(cFooter))
		
		// Fecha o arquivo texto
		fClose(nHdl)
		
		// Adiciona mensagem de arquivo gerado com sucesso
		AADD(aMensOK,{"Manutenção de Informações Cadastrais"})
	EndIf
	
Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! BBPREVFIN	! Autor !Gilson Lima 		 ! Data ! 09/01/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Processamento													 !
!			! Gera arquivo de Informações Cadastrais baseado nos parâmetros	 !
+----------------------------------------------------------------------------*/
Static Function BBPREVFIN()

	Local cArquivo 	 := NomeArq('R')		// Gera nome do arquivo para Informações Financeiras
	Local cLinha 	 := ""
	Local nLinhas	 := 0
	Local nRegistros := 0
	
	Local aGravar	 := {}
	
	Local nTotParticip := 0
	Local nTotPatrocin := 0	
	
	// Espaços reservados para os diferentes tipos de registros
	Local cReserv1	 := Replicate('0',88)	// Espaço reservado para Registros do Tipo 1
	Local cReserv2	 := Replicate('0',34)	// Espaço reservado para Registros do Tipo 2
	Local cReserv3	 := Replicate('0',65)	// Espaço reservado para Registros do Tipo 3
	
	Local nHdl		 := 0		// Handler para gravação do arquivo

	Local aValores		:= {}
	Local cVerbNor		:= '533_530_537_536'
	Local cVerbJoia		:= '534_531_538'
	Local cVerbEsp		:= '535_532'
	Local cVerbEmp		:= '539_542' 
	Local cVerbas		:= cVerbNor + "_" + cVerbJoia + "_" + cVerbEsp // + "_" + cVerbEmp // Verba de empréstimos, não considerar nesta rotina
	
	Local POSCTNOR := 1
	Local POSCTJOI := 2
	Local POSCTESP := 3
	Local POSPLRISC := 1
	Local POSPLPROG := 2

	// +----------------------------------------------------------------------------+
	// ! OBTENÇÃO DE DADOS														    !
	// +----------------------------------------------------------------------------+	

	dbSelectArea("SRC")
	SRC->(dbSetOrder(1))
	SRC->(dbGoTop())
	
	While SRC->(!EOF())
		
		If SRC->RC_PD $ cVerbas
		
			lValor := .F.
			If Len(aValores) > 0
				For nD := 1 To Len(aValores)
					If aValores[nD][1] == SRC->RC_MAT
						Do Case
							// Código da Contribuição NORMAL
							Case SRC->RC_PD $ cVerbNor
								aValores[nD][2][POSCTNOR] += SRC->RC_VALOR
							// Código da Contribuição JÓIA
							Case SRC->RC_PD $ cVerbJoia
								aValores[nD][2][POSCTJOI] += SRC->RC_VALOR
							// Código da Contribuição ESPORÁDICA
							Case SRC->RC_PD $ cVerbEsp
								aValores[nD][2][POSCTESP] += SRC->RC_VALOR
						EndCase
						lValor := .T.
					EndIf
				Next nD
			EndIf
			
			If !lValor
				
				aAdd(aValores,{SRC->RC_MAT,{0,0,0}})

				Do Case
					// Código da Contribuição NORMAL
					Case SRC->RC_PD $ cVerbNor
						aValores[Len(aValores)][2][POSCTNOR] += SRC->RC_VALOR
					// Código da Contribuição JÓIA
					Case SRC->RC_PD $ cVerbJoia
						aValores[Len(aValores)][2][POSCTJOI] += SRC->RC_VALOR
					// Código da Contribuição ESPORÁDICA
					Case SRC->RC_PD $ cVerbEsp
						aValores[Len(aValores)][2][POSCTESP] += SRC->RC_VALOR
				EndCase
			EndIf
		EndIf
		SRC->(dbSkip())
	End
	
	SRC->(dbCloseArea())
	
	
	For nZ := 1 To Len(aValores)
			
		// Busca Rendimento e Margem Consignável
		aVerbFin	:= RetVerbFin(aValores[nZ][1])

		nSalario	:= aVerbFin[1]			
		nMrgConsig 	:= aVerbFin[2]
		
		For nH := 1 To Len(aValores[nZ][2])
		
			For nG := 1 To Len(aCodPlano)
	
				cGravar 	:= ''
	
				aDadosGrv := Array(10)
				
				aDadosGrv[1]	:= '2'										// Tipo de Registro
				aDadosGrv[2]	:= PadL(AllTrim(aValores[nZ][1]),9,'0')		// Matrícula do Participante
				aDadosGrv[3]	:= PadR(AllTrim(cAnoRefer),4,' ')			// Ano de Referência
				aDadosGrv[4]	:= PadR(AllTrim(cMesRefer),2,' ')			// Mês de Referência
				aDadosGrv[5]	:= PadR(AllTrim(aCodPlano[nG][1]),4,' ')	// Código do Plano
				
				Do Case
					Case nH == POSCTNOR
						aDadosGrv[6]	:= PadR(AllTrim('01'),2,' ')		// Código da Contribuição NORMAL
					Case nH == POSCTJOI
						aDadosGrv[6]	:= PadR(AllTrim('03'),2,' ')		// Código da Contribuição JÓIA
					Case nH == POSCTESP
						aDadosGrv[6]	:= PadR(AllTrim('10'),2,' ')		// Código da Contribuição ESPORÁDICA
				EndCase
	
				aDadosGrv[7]	:= PadL(StrTran(LTrim(Transform(nSalario, "@E 999999999999.99")),",",""),11,'0')		// Salário
				
				aDadosGrv[8]	:= PadL(StrTran(LTrim(Transform(nMrgConsig, "@E 999999999999.99")),",",""),11,'0')		// Margem Consignável
	
				Do Case
					Case nH == POSCTNOR // Código da Contribuição NORMAL
						aDadosGrv[9]	:= PadL(StrTran(LTrim(Transform(aValores[nZ][2][nH] * (aCodPlano[nG][2] / 100), "@E 999999999999.99")),",",""),11,'0')	// Valor Contribuição Participante
						aDadosGrv[10]	:= PadL(StrTran(LTrim(Transform(aValores[nZ][2][nH] * (aCodPlano[nG][2] / 100), "@E 999999999999.99")),",",""),11,'0')	// Valor Contribuição Patrocinadora

					Case nH == POSCTJOI // Código da Contribuição JÓIA

						If nG == POSPLRISC // 1 = Plano Risco = 100%							
							aDadosGrv[9]	:= PadL(StrTran(LTrim(Transform(aValores[nZ][2][nH], "@E 999999999999.99")),",",""),11,'0')	// Valor Contribuição Participante
							aDadosGrv[10]	:= PadL(StrTran(LTrim(Transform(aValores[nZ][2][nH], "@E 999999999999.99")),",",""),11,'0')	// Valor Contribuição Patrocinadora
					
						Else
							Loop
						EndIf

					Case nH == POSCTESP // Código da Contribuição ESPORÁDICA
						If nG == POSPLPROG // 2 = Plano Programado = 100%							
							aDadosGrv[9]	:= PadL(StrTran(LTrim(Transform(aValores[nZ][2][nH], "@E 999999999999.99")),",",""),11,'0')	// Valor Contribuição Participante
							aDadosGrv[10]	:= PadL(StrTran(LTrim(Transform(0.00, "@E 999999999999.99")),",",""),11,'0')	// Valor Contribuição Patrocinadora
							
						Else
							Loop
						EndIf
				EndCase
				
				If aValores[nZ][2][nH] == 0
					Loop
				endIf

				//Adiciona valores aos totais
				nTotParticip += Val(aDadosGrv[9])/100	// Total Participantes
				nTotPatrocin += Val(aDadosGrv[10])/100	// Total Patrocinadora
								
				// Gera linha para gravação
				For nK := 2 To Len(aDadosGrv)
					cGravar += aDadosGrv[nK]
				Next nK
				
				// Acrescenta Registro para gravação
				aAdd(aGravar,cGravar)

/*				
				nTotParticip += aValores[nZ][2][nH]
				
				If nH <> POSCTESP	// Cohapar não paga valor em caso de esporádico
					nTotPatrocin += aValores[nZ][2][nH]
				EndIf
*/			
			
			Next nG
		
		Next nH			
		
	Next nZ
	
	
	// +----------------------------------------------------------------------------+
	// ! GRAVAÇÃO DE ARQUIVO													    !
	// +----------------------------------------------------------------------------+	
	
	// Se houver registros Novos a gravar, executa a gravação
	If Len(aGravar) > 0
	
		cArquivo 	 := NomeArq('R')		// Gera nome do arquivo para Informações Cadastrais
		nHdl		 := fCreate(cArquivo)	// Inicia gravação do arquivo
		
		// Caso não consiga criar arquivo, informa o erro e aborta o sistema
		If nHdl == -1
			MsgAlert("O arquivo de nome "+cArquivo+" não pode ser criado! Verifique os parâmetros.","Atenção!")
			Return
		EndIf
	
		ProcRegua(Len(aGravar))	// Número de registros a Gravar

		// +----------------------------------------------------------------------------+
		// ! Grava Cabeçalho														    !
		// +----------------------------------------------------------------------------+
		 		
		cHeader := '1'			// Tipo de Registro - 1 = Cabeçalho
		cHeader += cCodPatroc	// Código da Patrocinadora
		cHeader += cAnoRefer	// Ano de Referência
		cHeader += cMesRefer	// Mes de Referência
		cHeader += cReserv1		// Campos Reservados (Preenchido com 0)
		cHeader += CRLF			// Adiciona quebra de linha
		
		// Gravação do arquivo
		fWrite(nHdl,cHeader,Len(cHeader))

		// +----------------------------------------------------------------------------+
		// ! Grava Registros no Arquivo												    !
		// +----------------------------------------------------------------------------+
		 
		For nY := 1 to Len(aGravar)
		
			IncProc() // Incrementa a régua
			nLinhas++
			
			
			cLinha	:= '2'			// Tipo de Registro
			cLinha	+= aGravar[nY]	// Informações a gravar
			cLinha	+= cReserv2		// Campos Reservados (Preenchido com 0)
			cLinha  += CRLF			// Adiciona quebra de linha
			
			// Gravação do arquivo. Testa por erros durante a gravação
			If fWrite(nHdl,cLinha,Len(cLinha)) != Len(cLinha)
				If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
					Exit
				EndIf
			EndIf
		Next nY

		// +----------------------------------------------------------------------------+
		// ! Grava Rodapé															    !
		// +----------------------------------------------------------------------------+		
		
		nTotTipo2	:= Len(aGravar)
		
		cFooter 	:= '3'					// Registro Tipo 3 = Totalizadores
		
		If MV_PAR02 == 1
			//cFooter += 'VALIDACAO|'
		EndIf
		
		cFooter 	+= StrZero(nTotTipo2 + 1,6)		// Total Registros
		cFooter 	+= StrZero(nTotTipo2,6)			// Total Registros Tipo 2
		cFooter		+= PadL(StrTran(LTrim(Transform(nTotPatrocin, "@E 999999999999.99")),",",""),11,'0')	// Valor Total Contribuições da Patrocinadora
		cFooter		+= PadL(StrTran(LTrim(Transform(nTotParticip, "@E 999999999999.99")),",",""),11,'0')	// Valor Total Contribuições do Participante
		cFooter 	+= cReserv3						// Campos Reservados (Preenchido com 0)

		// Gravação do arquivo. 
		fWrite(nHdl,cFooter,Len(cFooter))
		
		// Fecha o arquivo texto
		fClose(nHdl)
		
		// Adiciona mensagem de arquivo gerado com sucesso
		AADD(aMensOK,{"Informações Financeiras"})
	EndIf	

Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! NOMEARQ	! Autor !Gilson Lima 		 ! Data ! 09/01/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Função Auxiliar												 !
!			! Define o nome do arquivo baseado no tipo	 					 !
!			! CAD = Informações cadastrais | FIN = Informações Financeiras	 !
+----------------------------------------------------------------------------*/
Static Function NomeArq(cTipo)

	Local cNomeArq		:= ''

	Private cArqExt		:= '.dat'					// Extensão do arquivo
	Private cArqDir		:= Lower(AllTrim(MV_PAR05)) // Diretório do Arquivo
	
	// Converte contra-barras para barras normais
	cArqDir				:= StrTran(cArqDir,'\','/')
	
	// Diretório do arquivo
	// Insere a '/' no final, caso não exista
	If Substr(cArqDir,Len(cArqDir),1) <> '/'
		cArqDir += '/'
	EndIf
	
	// Insere Localização do Arquivo
	cNomeArq := cArqDir
		
	// Define o prefixo
	
	If cTipo == 'P'		// Se for arquivo de Informação Cadastral
		cNomeArq += 'p'
	ElseIf cTipo == 'M' // Se for arquivo de Manutenção de Informação Cadastral
		cNomeArq += 'm'
	ElseIf cTipo == 'R'	// Se for arquivo de Informação Financeira
		cNomeArq += 'r'
	EndIf 
	
	cNomeArq += cCodPatroc				// Código da Patrocinadora
	cNomeArq +=	cCNPB					// Código CNPB
	cNomeArq +=	cAnoRefer + cMesRefer	// Data de Referência
	cNomeArq +=	cArqExt					// Extensão do Arquivo
	
Return cNomeArq

Static Function GravaHist(aFuncGrv)

	Local lDelCompet := .F. // Deleta ou não registros da competência atual

	// +----------------------------------------------------------------------------+
	// ! Verifica se existem o registros referente à competência atual			    !
	// +----------------------------------------------------------------------------+

	// Monta String com dados da Tabela SZG. Última Competência 
	cQuery := "SELECT Count(SZG.ZG_MAT) TOTREG"
	cQuery += " FROM " + RetSqlName("SZG") + " SZG"
	cQuery += " WHERE SZG.D_E_L_E_T_ <> '*'"
	cQuery += " AND SZG.ZG_COMPET = '" + cAnoRefer+cMesRefer + "'"
	
	cQuery := changeQuery(cQuery) 
	
	dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),"Tmp2", .f., .t.)

	While Tmp2->(!EOF())
		If Tmp2->TOTREG > 0
			lDelCompet := .T.
		EndIf
		Tmp2->(dbSkip())
	End
	
	Tmp2->(dbCloseArea())
	
	// Deleta registros para essa competência
	If lDelCompet
		
		dbSelectArea("SZG")
		SZG->(dbSetOrder(1))
		SZG->(dbSeek(xFilial("SZG")+cAnoRefer+cMesRefer))
		While SZG->(!EOF()) .And. SZG->(xFilial("SZG")+ZG_COMPET) == xFilial("SZG")+cAnoRefer+cMesRefer
		
			SZG->(RecLock("SZG",.F.))
			SZG->(DbDelete())
			SZG->(MsUnLock())

			SZG->(dbSkip())
		End
		
		SZG->(dbCloseArea())
	EndIf
	
	// +----------------------------------------------------------------------------+
	// ! Grava novos registros													    !
	// +----------------------------------------------------------------------------+	
	
	For nC := 1 To Len(aFuncGrv)
		dbSelectArea("SZG")
		
			SZG->(RecLock("SZG",.T.))
			
				SZG->ZG_FILIAL	:= xFilial("SZG")
				SZG->ZG_COMPET	:= cAnoRefer+cMesRefer
				SZG->ZG_MAT		:= aFuncGrv[nC][2]
				SZG->ZG_NOME	:= aFuncGrv[nC][3]
				SZG->ZG_LOTACAO	:= aFuncGrv[nC][4]
				SZG->ZG_CARGO	:= aFuncGrv[nC][5]
				SZG->ZG_FUNCAO	:= aFuncGrv[nC][6]
				SZG->ZG_DTADMIS	:= aFuncGrv[nC][7]
				SZG->ZG_DTDEMIS := aFuncGrv[nC][8]
				SZG->ZG_MTDEMIS	:= aFuncGrv[nC][9]
				SZG->ZG_SITEMPR := aFuncGrv[nC][10] 
				SZG->ZG_DTSITEP := aFuncGrv[nC][11] 
				SZG->ZG_SEXO 	:= aFuncGrv[nC][12] 
				SZG->ZG_ECIVIL 	:= aFuncGrv[nC][13] 
				SZG->ZG_GRINSTR := aFuncGrv[nC][14] 
				SZG->ZG_ENDEREC := aFuncGrv[nC][15] 
				SZG->ZG_NRENDRE := aFuncGrv[nC][16] 
				SZG->ZG_COMPEND := aFuncGrv[nC][17] 
				SZG->ZG_BAIRRO	:= aFuncGrv[nC][18] 
				SZG->ZG_CIDADE 	:= aFuncGrv[nC][19] 
				SZG->ZG_UF 		:= aFuncGrv[nC][20] 
				SZG->ZG_CEP 	:= aFuncGrv[nC][21] 
				SZG->ZG_DDDRES 	:= aFuncGrv[nC][22] 
				SZG->ZG_TELRES 	:= aFuncGrv[nC][23] 
				SZG->ZG_DDDCOML := aFuncGrv[nC][24] 
				SZG->ZG_TELCOML := aFuncGrv[nC][25] 
				SZG->ZG_DDDCEL 	:= aFuncGrv[nC][26] 
				SZG->ZG_TELCEL	:= aFuncGrv[nC][27] 
				SZG->ZG_CIDNASC := aFuncGrv[nC][28] 
				SZG->ZG_UFNASC 	:= aFuncGrv[nC][29] 
				SZG->ZG_CODNASC := aFuncGrv[nC][30] 
				SZG->ZG_DTNASC 	:= aFuncGrv[nC][31] 
				SZG->ZG_CPF 	:= aFuncGrv[nC][32] 
				SZG->ZG_RG 		:= aFuncGrv[nC][33] 
				SZG->ZG_RGORG 	:= aFuncGrv[nC][34] 
				SZG->ZG_RGORGUF := aFuncGrv[nC][35] 
				SZG->ZG_RGDTEMI	:= aFuncGrv[nC][36] 
				SZG->ZG_FRMRECO := aFuncGrv[nC][37] 
				SZG->ZG_NRBANCO := aFuncGrv[nC][38]
				SZG->ZG_CODAGEN := aFuncGrv[nC][39] 
				SZG->ZG_DVAGE 	:= aFuncGrv[nC][40] 
				SZG->ZG_CTCORRE := aFuncGrv[nC][41] 
				SZG->ZG_DVCCORR := aFuncGrv[nC][42] 
				SZG->ZG_NMPAI 	:= aFuncGrv[nC][43] 
				SZG->ZG_NMMAE 	:= aFuncGrv[nC][44] 
				SZG->ZG_EMAIL	:= aFuncGrv[nC][45] 
				SZG->ZG_OPCREGT := aFuncGrv[nC][46] 
				SZG->ZG_OPCINVE := aFuncGrv[nC][47] 
				SZG->ZG_SITADMI := aFuncGrv[nC][48] 
				SZG->ZG_VLINVME := aFuncGrv[nC][49] 
				SZG->ZG_VLPATRB := aFuncGrv[nC][50] 
				SZG->ZG_DTPROTO := aFuncGrv[nC][51] 
				SZG->ZG_TPFUNC	:= aFuncGrv[nC][52]
				SZG->ZG_DTGERAC := Date()
				SZG->ZG_HRGERAR := Time()
				SZG->ZG_USRGERA	:= __CUSERID+" | "+CUSERNAME 				
			
			SZG->(MsUnLock())
		SZG->(dbCloseArea())
	Next nC
Return

Static Function RetVerbFin(cMat)

	Local aArea		:= getArea()
	Local aVerbFin	:= {}

	// Busca Valor Salário - Verba 800 = Rendimento
	nSalario	:= Posicione("SRC",1,xFilial("SRC")+cMat+'800',"RC_VALOR")
	aAdd(aVerbFin,nSalario)
	
	// Busca Margem Consignável - 778
	nMrgConsig	:= Posicione("SRC",1,xFilial("SRC")+cMat+'778',"RC_VALOR")
	aAdd(aVerbFin,nMrgConsig)

	RestArea(aArea)
	
Return aVerbFin

Static Function RetRenda(cMat)

	Local aArea 	:= GetArea()
	Local cQuery 	:= ''
	Local nReg		:= 0
	Local aVerbas	:= {'102','101','103'}
	Local nRenda	:= 0
	
	// Verifica se possui registros na SRC, para buscar valores atualizados
	cQuery := "SELECT * FROM " + RetSqlName("SRC") + " SRC"
	cQuery += " WHERE SRC.RC_MAT = '" + cMat + "'"
	cQuery += " AND SRC.D_E_L_E_T_ <> '*'"
	cQuery += " AND (SRC.RC_PD = '101' OR SRC.RC_PD = '102' OR SRC.RC_PD = '103')"
	
	cQuery := changeQuery(cQuery) 
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Retorna o Nr. de Registros encontrados na SRC
	nReg := Contar("TRB","!EOF()")
	
	TRB->(dbCloseArea())
	
	// Busca nas tabelas todas as verbas do array aVerbas
	For nA := 1 To Len(aVerbas)	
	
		// Se houver registros na SRC, monta query baseada nela, caso contrário busca da SRD
		If nReg > 0				
				cQuery := "SELECT TOP(1) SRC.RC_VALOR as VALOR FROM " + RetSqlName("SRC") + " SRC"
				cQuery += " WHERE SRC.D_E_L_E_T_ <> '*'"
				cQuery += " AND SRC.RC_PD = '" + aVerbas[nA] + "'"
				cQuery += " AND SRC.RC_MAT = '" + cMat + "'"
		Else
				cQuery := "SELECT TOP(1) SRD.RD_VALOR as VALOR FROM " + RetSqlName("SRD") + " SRD"
				cQuery += " WHERE SRD.D_E_L_E_T_ <> '*'"
				cQuery += " AND SRD.RD_PD = '" + aVerbas[nA] + "'"
				cQuery += " AND SRD.RD_MAT = '" + cMat + "'"
		EndIF
		
		If Select('TMP') <> 0
			dbSelectArea('TMP')
			TMP->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TMP',.F.,.F.)
		
		// Retorna Nr. de Registros encontrados
		nRegTMP := Contar("TMP","!EOF()")
		
		// Se encontrou registros, adiciona seu valor à variável de retorno
		If nRegTMP > 0
			TMP->(dbGoTop())
			While TMP->(!EOF())
				nRenda += TMP->VALOR
				Exit
			End
		EndIf
		
		TMP->(dbCloseArea())
	
	Next nA	
	
	// Se não encontrou valor nas tabelas SRC ou SRD, retorna o valor de Salário na SRA
	/*If nRenda == 0
		nRenda := POSICIONE("SRA",1,xFilial("SRA")+cMat,"RA_SALARIO")
	EndIf*/
	
	RestArea(aArea)

Return (nRenda)