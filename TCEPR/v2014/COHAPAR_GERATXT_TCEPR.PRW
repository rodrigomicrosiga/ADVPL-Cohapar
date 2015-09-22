/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualização 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Contabilidade 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_GERATXT_TCEPR.PRW								 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Programa para geração de Arquivos Texto				 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/09/2014												 !
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
! Programa 	! TXTTCEPR	! Autor !Gilson Lima 		 ! Data ! 18/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Tela de Processamento											 !
!			! Gera o(s) arquivo(s) TXT baseado nos parâmetros Informados	 !
+----------------------------------------------------------------------------*/
User Function TXTTCEPR()

	Local aRet		:= {}
	Local aParambox	:= {}
	Local dData		:= DATE()
	Local aQuadrim	:= {"1o. Quadrimestre - Jan a Abr","2o. Quadrimestre - Mai a Ago","3o. Quadrimestre - Set a Dez"}
	Local nAnosExib	:= 5
	Local aAno		:= {}

	Local cAlert 	:= "Arquivos Gerados:" + CHR(10) + CHR(10)

	Private cTitJan	:= "Geração de Aquivos TXT"

	Private cNmDir		:= "C:\Temp\" // Caminho para salvar os arquivos
	Private aQuaDelib	:= {}
	Private cIdPessoa	:= "14834" // idPessoa COHAPAR
	Private aMensOK		:= {}
	Private nQuadr		:= 0
	
	Private cDtIni, cDtFim, dDtIni, dDtFim, cAno, cTpMov
	
	// Determina os Anos a serem apresentados
	AADD(aAno,cValToChar(Year(dData)))
	For nI := 1 To nAnosExib
		AADD(aAno,cValToChar(Year(dData) - nI))
	Next nI
	
	// Diretório para Salvar os Arquivos
	
	AADD(aParambox,{2,"Selecione o Quadrimestre: ",1,aQuadrim,100,"",.T.})
	AADD(aParambox,{2,"Selecione o Ano: ",1,aAno,30,"",.T.})
	// Cadastros
	AADD(aParambox,{5,"PessoaSEICED.txt",.T.,150,"",.F.})
	AADD(aParambox,{5,"QuadroDeliberativoExecutivo.txt",.T.,150,"",.F.})
	AADD(aParambox,{5,"BaixaQuadroDeliberativoExecutivo.txt",.T.,150,"",.F.})
	// Módulo Contábil
	AADD(aParambox,{5,"PlanoContabilEstatal.txt",.T.,150,"",.F.})
	AADD(aParambox,{5,"PlanoContabilEstatalXPlanoContabilReferencialEstatais.txt",.T.,150,"",.F.})
	AADD(aParambox,{5,"SaldoContabilExercicioAnteriorEstatais.txt",.T.,150,"",.F.})
	AADD(aParambox,{5,"MovimentoContabilMensalEstatais.txt",.T.,150,"",.F.})
	// Módulo Tesouraria
	AADD(aParambox,{5,"ContaBancaria.txt",.T.,150,"",.F.})
	AADD(aParambox,{5,"DesativacaoContaBancaria.txt",.T.,150,"",.F.})
	AADD(aParambox,{5,"ReversaoDesativacaoContaBancaria.txt",.T.,150,"",.F.})
	AADD(aParambox,{5,"SaldoMensalExtratoBancario.txt",.T.,150,"",.F.})

	If ParamBox(aParambox,"Geração de Arquivos .txt",@aRet)
			
		// Cria variáveis Private com o resultado da Parambox
		
		//Determina Ano
		If ValType(aRet[2]) == "N"
			If aRet[2] == 1
				cAno := cValToChar(Year(dData))
			EndIf
		Else
			cAno := aRet[2]
		EndIf
		
		// Determina Datas
		If ValType(aRet[1]) == "N"
			If aRet[1] == 1
				dDtIni := StoD(cAno+"0101")
				dDtFim := StoD(cAno+"0430")
			EndIf
		Else
			Do Case
				Case aRet[1] == aQuadrim[1]
					dDtIni := StoD(cAno+"0101")
					dDtFim := StoD(cAno+"0430")
					nQuadr := 1
				Case aRet[1] == aQuadrim[2]
					dDtIni := StoD(cAno+"0501")
					dDtFim := StoD(cAno+"0831")
					nQuadr := 2	
				Case aRet[1] == aQuadrim[3]
					dDtIni := StoD(cAno+"0901")
					dDtFim := StoD(cAno+"1231")
					nQuadr := 3
			EndCase
		EndIf
		

		// Cria arquivos conforme seleção na pergunta
			
		If aRet[3] == .T.
			Processa({||PeSEICED()}, "PessoaSEICED.txt") // Pessoas Não Jurisdionadas do TCE
		EndIf
	
		If aRet[4] == .T.
			Processa({||QuaDelib()}, "QuadroDeliberativoExecutivo.txt") // Composição do Quadro Deliberativo e Executivo das Estatais
		EndIf
	
		If aRet[5] == .T.
			Processa({||BxQuaDelib()}, "BaixaQuadroDeliberativoExecutivo.txt") // Baixa na Composição do Quadro Deliberativo e Executivo das Estatais
		EndIf
	
		If aRet[6] == .T.
			Processa({||PlContabil()}, "PlanoContabilEstatal.txt") // Plano Contábil Estatal
		EndIf
	
		If aRet[7] == .T.
			Processa({||PlContabR()}, "PlanoContabilEstatalXPlanoContabilReferencialEstatais.txt") // Plano Contábil Referencial Estatal
		EndIf
	
		If aRet[8] == .T.
			Processa({||SalAntCTB()}, "SaldoContabilExercicioAnteriorEstatais.txt") // Saldo Contabil Exercicio Anterior Estatais
		EndIf
	
		If aRet[9] == .T.		
			Processa({||SalCtaCTB()}, "MovimentoContabilMensalEstatais.txt") // Movimento Contábil Mensal Estatais
		EndIf
	
		If aRet[10] == .T.
			Processa({||ContaBanc()}, "ContaBancaria.txt") // Contas Bancárias
		EndIf
	
		If aRet[11] == .T.
			Processa({||DesCtaBanc()}, "DesativacaoContaBancaria.txt") // Desativação de Contas Bancárias
		EndIf
	
		If aRet[12] == .T.
			Processa({||RDsCtaBanc()}, "ReversaoDesativacaoContaBancaria.txt") // Reversão da Desativação de Contas Bancárias
		EndIf
	
		If aRet[13] == .T.
			Processa({||SalCtaBanc()}, "SaldoMensalExtratoBancario.txt") // Saldo Mensal de Contas Bancárias
		EndIf
		
		For nX := 1 To Len(aMensOK)
			cAlert += aMensOK[nX][1] + chr(10)
		Next nX
		
		If Len(aMensOK) > 0
			MsgInfo(cAlert,"Geração de TXTs")
		EndIf
			
	EndIf

				
Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! QuaDelib	! Autor !Gilson Lima 		 ! Data ! 18/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Quadro Deliberativo					 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function PeSEICED()

	// Gera o arquivo texto
	Local cNmArq	:= "PessoaSEICED.txt"
	Local cArqTxt 	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf

	/***
	 * Notações
	 * 
	 * X - Qualquer caractere alfanumérico
	 * 9 - Apenas Numérico e de preenchimento obrigatório
	 * Z - Somente número ou posição em branco
	 *
	 * Tabela PessoaSEICED
	 *
	 * Esta tabela visa inserir no sistema SEI-CED os credores, participantes vencedores de licitações, contribuintes,
	 * membros do quadro deliberativo e executivo das Estatais e outras pessoas informadas nas diversas tabelas do sistema.
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome					Obrigatorio	Protheus
	 * Tipo de Documento	2		Numérico	Z(1)9		idTipoDocumentoPessoa	Sim			CVB->CVB_CPF|CVB->CVB_CGC
	 * Número do Documento	15		Caractere	X(15)		nrDocumento				Sim			CVB->CVB_CPF|CVB->CVB_CGC
	 * Nome da Pessoa		100		Caractere	X(100)		nmPessoa				Sim			CVB->CVB_NOME
	 * Endereço da Pessoa	250		Caractere	X(250)		dsEndereco				Sim			CVB->CVB_END + CVB->CVB_COMPL + CVB->CVB_BAIRRO + CC2->CC2_MUN + CC2->CC2_EST - Manual
	 * Código do CEP		8		Numérico	99999999	cdCEP					Sim			CVB->CVB_CEP 
	 */
	
	dbSelectArea("CVB")

	CVB->(dbGoTop())
	While CVB->(!EOF())
		nRegistros ++
		CVB->(dbSkip())
	EndDo

	ProcRegua(nRegistros)	// Número de registros a Processar
	
	CVB->(dbGoTop())
	While CVB->(!EOF())
		
		IncProc() // Incrementa a régua
		nLinhas++
		
		IIf(allTrim(CVB->CVB_CGC) != "",cLin := "1|",cLin := "2|")
		IIf(allTrim(CVB->CVB_CGC) != "",cLin += allTrim(Substr(CVB->CVB_CGC,1,15))  + "|",cLin += allTrim(Substr(CVB->CVB_CPF,1,15))  + "|")
		cLin += allTrim(Substr(CVB->CVB_NOME,1,100)) + "|"
		cLin += Substr(ValEndereco(CVB->CVB_END,CVB->CVB_COMPL,CVB->CVB_BAIRRO,CVB->CVB_UF,CVB->CVB_CODMUN),1,250) + "|"
		cLin += allTrim(Substr(CVB->CVB_CEP,1,8)) + "|"
		
		If nLinhas < nRegistros
			cLin += CRLF
		EndIf
		
		// Gravação do arquivo. Testa por erros durante a gravação
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
				Exit
			EndIf
		EndIf
		
		CVB->(dbSkip())	
	EndDo

	// Fecha o arquivo texto
	fClose(nHdl)
	
	AADD(aMensOK,{cNmArq})

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! QuaDelib	! Autor !Gilson Lima 		 ! Data ! 18/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Quadro Deliberativo					 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function QuaDelib()
	
	// Gera o arquivo texto
	Local cNmArq	:= "QuadroDeliberativoExecutivo.txt"
	Local cArqTxt := cNmDir+cNmArq
	Local nHdl	:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0	
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf
	
	/***
	 * Notações
	 * 
	 * X - Qualquer caractere alfanumérico
	 * 9 - Apenas Numérico e de preenchimento obrigatório
	 * Z - Somente número ou posição em branco
	 *
	 * Tabela QuadroDeliberativoExecutivo
	 *
	 * Captar a composição do quadro deliberativo e executivo das Estatais
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Cód. da Operação		7		Numérico	Z(6)9		nrOperacao					Sim			Sequencial Automatico
	 * Num. Doc. Componente	15		Caractere	X(15)		nrCPFComponente				Sim			CVB->CVB_CPF
	 * Nat. Função Quadro	2		Numérico	Z(1)9		idTipoNaturezaQuadroEstatal	Sim			CVB->CVB_ZNTDEL
	 * Função Quadro Est.	2		Numérico	Z(1)9		idTipoFuncaoQuadroEstatal	Sim			CVB->CVB_ZTPDEL
	 * Dt. Início Mandato	10		Data		AAAA-MM-DD	dtInicio					Sim			CVB->CVB_DTINI
	 * Dt. Prev. Fim Mandato10		Data		AAAA-MM-DD	dtFim						Sim			CVB->CVB_ZPRFIM (Previsão termino do mandato)
	 */
		 
	dbSelectArea("CVB")

	CVB->(dbGoTop())
	While CVB->(!EOF()) .And. CVB->CVB_DTINI <= dDtFim // Início do mandato Menor ou Igual data Final
		nRegistros ++
		CVB->(dbSkip())
	EndDo

	ProcRegua(nRegistros)	// Número de registros a Processar
	
	CVB->(dbGoTop())
	While CVB->(!EOF()) .And. CVB->CVB_DTINI <= dDtFim // Início do mandato Menor ou Igual data Final
		
		IncProc() // Incrementa a régua
		
		nLinhas++
		nCont++
		
		// Cria array para utilização de comparação na Baixa do Quadro Deliberativo
		AADD(aQuaDelib,{cVAlToChar(nCont),allTrim(Substr(CVB->CVB_CPF,1,15))})
		
		cLin := cIdPessoa  + "|"
		cLin += cValToChar(nCont)  + "|"
		cLin += allTrim(Substr(CVB->CVB_CPF,1,15)) + "|"
		cLin += allTrim(Substr(CVB->CVB_ZNTDEL,1,2)) + "|"
		cLin += allTrim(Substr(CVB->CVB_ZTPDEL,1,2)) + "|"
		cLin += ValidaData(DtoS(CVB->CVB_DTINI)) + "|" // Alterar data
		cLin += ValidaData(DtoS(CVB->CVB_ZPRFIM)) + "|" // Alterar data

		If nLinhas < nRegistros
			cLin += CRLF
		EndIf
		
		// Gravação do arquivo. Testa por erros durante a gravação
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
				Exit
			EndIf
		EndIf
		
		CVB->(dbSkip())	
	EndDo

	// Fecha o arquivo texto
	fClose(nHdl)
	
	AADD(aMensOK,{cNmArq})
	
Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! BxQuaDelib! Autor !Gilson Lima 		 ! Data ! 18/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Quadro Deliberativo					 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function BxQuaDelib()
	
	// Gera o arquivo texto
	Local cNmArq	:= "BaixaQuadroDeliberativoExecutivo.txt"
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0	
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf
	
	/***
	 * Notações
	 * 
	 * X - Qualquer caractere alfanumérico
	 * 9 - Apenas Numérico e de preenchimento obrigatório
	 * Z - Somente número ou posição em branco
	 *
	 * Tabela BaixaQuadroDeliberativoExecutivo
	 *
	 * Captar a baixa dos componentes do quadro deliberativo e executivo
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Cód. da Operação		7		Numérico	Z(6)9		nrOperacao					Sim			Sequencial do Quadro Deliberativo (aQdoDelib[n][1])
	 * Dt. Baixa			10		Data		AAAA-MM-DD	dtBAixa						Sim			CVB->CVB_DTFIM
	 * Tipo de Baixa		2		Numérico	Z(1)9		idTipoBaixaQuadroDelibExec	Sim			CVB->CVB_ZMOTBX
	 * Desc. Motivo Baixa	250		Caractere	X(250)		dsMotivo					Sim			CVB->CVB_ZDSCBX
	 */
	 
	dbSelectArea("CVB")

	CVB->(dbGoTop())
	While CVB->(!EOF()) .And. CVB->CVB_DTFIM <= dDtFim // Fim do mandato Anterior ou Igual data Final
		IF DtoC(CVB->CVB_DTFIM) != "  /  /    "		
			nRegistros ++
		EndIf
		CVB->(dbSkip())
	EndDo

	ProcRegua(nRegistros)	// Número de registros a Processar
	
	CVB->(dbGoTop())
	While CVB->(!EOF()) .And. CVB->CVB_DTFIM <= dDtFim // Fim do mandato Anterior ou Igual data Final
		
		IF DtoC(CVB->CVB_DTFIM) != "  /  /    "
			
			IncProc() // Incrementa a régua
			
			nLinhas++
			nCont++
			
			cLin := cIdPessoa  + "|"
			
			For nI := 1 To Len(aQuaDelib)
				If aQuaDelib[nI][2] == allTrim(Substr(CVB->CVB_CPF,1,15))
					cLin += cValToChar(aQuaDelib[nI][1])  + "|"
				EndIf
			Next nI
			cLin += ValidaData(DtoS(CVB->CVB_DTFIM)) + "|" // Alterar data
			cLin += allTrim(CVB->CVB_ZMOTBX) + "|"
			
			If CVB->CVB_ZMOTBX == "99"
				cLin += allTrim(Substr(CVB->CVB_ZDSCBX,1,250)) + "|"
			Else
				cLin += "|"	
			EndIf
	
			If nLinhas < nRegistros
				cLin += CRLF
			EndIf
			
			// Gravação do arquivo. Testa por erros durante a gravação
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
					Exit
				EndIf
			EndIf
		EndIf
		
		CVB->(dbSkip())	
	EndDo

	// Fecha o arquivo texto
	fClose(nHdl)

	AADD(aMensOK,{cNmArq})
	
Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! PlContabil! Autor !Gilson Lima 		 ! Data ! 19/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Plano Contábil Estatal					 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function PlContabil()
	
	// Gera o arquivo texto
	Local cNmArq	:= "PlanoContabilEstatal.txt"
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0	
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf
	
	/***
	 * Notações
	 * 
	 * X - Qualquer caractere alfanumérico
	 * 9 - Apenas Numérico e de preenchimento obrigatório
	 * Z - Somente número ou posição em branco
	 *
	 * Tabela PlanoContabilEstatal
	 *
	 * Captar o plano de contas contábil utilizado pelas Empresas Estatais
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Cód. Contábil		50		Caractere	X(50)		cdContaContabil				Sim			CT1->CT1_CONTA
	 * Ano Aplicação		4		Numérico	9999		nrAnoAplicacao				Sim			Parâmetro: cAno
	 * Título				250		Caractere	X(250)		dsConta						Sim			CT1->CT1_DESC01
	 * Natureza Saldo		1		Caractere	X			tpNaturezaSaldo				Sim			CT1->CT1_NORMAL (1 = Débito | 2 = Crédito)
	 * Escrituração			1		Caractere	X			tpEscrituracao				Sim			CT1->CT1_CLASSE (1 = Ñ Escriturável | 2 = Escriturável)
	 */
	
	cQuery := 'SELECT CT1.CT1_CONTA, CT1.CT1_DESC01, CT1.CT1_NORMAL, CT1.CT1_CLASSE'
	cQuery += " FROM " + RetSqlName("CT1") + " CT1"
	cQuery += " WHERE CT1.D_E_L_E_T_ <> '*'"
	cQuery += " AND CT1.CT1_ZDTTCE <= '" + DtoS(dDtFim) + "'"
	If nQuadr <> 1 .And. nQuadr <> 0
		cQuery += " AND CT1.CT1_ZDTTCE >= '" + DtoS(dDtIni) + "'"
	EndIf
	cQuery += " ORDER BY CT1.CT1_CONTA"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
		nRegistros ++
		TRB->(dbSkip())	
	EndDo

	ProcRegua(nRegistros)	// Número de registros a Processar
		 
	TRB->(dbGoTop())
	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		
		nLinhas++
		nCont++
		
		cLin := cIdPessoa  + "|"
		cLin += Alltrim(Substr(TRB->CT1_CONTA,1,50)) + "|"
		cLin += cAno + "|"
		cLin += Alltrim(Substr(TRB->CT1_DESC01,1,250)) + "|"
		IIF (TRB->CT1_NORMAL == "1",cLin += "D" + "|",cLin += "C" + "|") // D = Débito | C = Crédito | X = Mista
		IIF (TRB->CT1_CLASSE == "1",cLin += "N" + "|",cLin += "S" + "|") // N = Não Escriturável | S = Escriturável
		
		If nLinhas < nRegistros
			cLin += CRLF
		EndIf
		
		// Gravação do arquivo. Testa por erros durante a gravação
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
				Exit
			EndIf
		EndIf
		
		TRB->(dbSkip())	
	EndDo
	
	TRB->(dbCloseArea())

	// Fecha o arquivo texto
	fClose(nHdl)
	
	AADD(aMensOK,{cNmArq})

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	!PlContabR	! Autor !Gilson Lima 		 ! Data ! 19/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Plano Contábil Referencial Estatal		 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function PlContabR()
	
	// Gera o arquivo texto
	Local cNmArq	:= "PlanoContabilEstatalXPlanoContabilReferencialEstatais.txt"
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0	
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf
	
	/***
	 * Notações
	 * 
	 * X - Qualquer caractere alfanumérico
	 * 9 - Apenas Numérico e de preenchimento obrigatório
	 * Z - Somente número ou posição em branco
	 *
	 * Tabela PlanoContabilEstatalXPlanoContabilReferencialEstatais
	 *
	 * Captar o plano de contas contábil utilizado pelas Empresas Estatais
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Cód. Contábil		50		Caractere	X(50)		cdContaContabil				Sim			CT1->CT1_CONTA
	 * Classe				1		Caractere	9			cdClasse					Sim			CT1->CT1_ZCTATC[1] (Dividido pelos .)
	 * Grupo				1		Caractere	9			cdGrupo						Sim			CT1->CT1_ZCTATC[2] (Dividido pelos .)
	 * SubGrupo				1		Caractere	9			cdSubGrupo					Sim			CT1->CT1_ZCTATC[3] (Dividido pelos .)
	 * Titulo				1		Caractere	9			cdTitulo					Sim			CT1->CT1_ZCTATC[4] (Dividido pelos .)
	 * SubTitulo			1		Caractere	9			cdSubTitulo					Sim			CT1->CT1_ZCTATC[5] (Dividido pelos .)
	 * Item					2		Caractere	99			cdItem						Sim			CT1->CT1_ZCTATC[6] (Dividido pelos .)
	 * SubItem				2		Caractere	99			cdSubItem					Sim			CT1->CT1_ZCTATC[7] (Dividido pelos .)
	 * Ano Aplicação		4		Numérico	9999		nrAnoAplicacao				Sim			Parâmetro: cAno
	 */

	cQuery := "SELECT CT1.CT1_CONTA, CT1.CT1_ZCTATC"
	cQuery += " FROM " + RetSqlName("CT1") + " CT1"
	cQuery += " WHERE CT1.D_E_L_E_T_ <> '*'"
	cQuery += " AND CT1.CT1_CLASSE = '2'"
	cQuery += " AND CT1.CT1_ZDTTCE <= '" + DtoS(dDtFim) + "'"
	If nQuadr <> 1 .And. nQuadr <> 0
		cQuery += " AND CT1.CT1_ZDTTCE >= '" + DtoS(dDtIni) + "'"
	EndIf
	cQuery += " ORDER BY CT1.CT1_CONTA"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
		If Alltrim(TRB->CT1_ZCTATC) != ""
			nRegistros ++
		EndIf
		TRB->(dbSkip())	
	EndDo

	ProcRegua(nRegistros)	// Número de registros a Processar
		 
	TRB->(dbGoTop())
	While TRB->(!EOF())
		
		If Alltrim(TRB->CT1_ZCTATC) != "" // Possuir informação na conta referencial
		
			IncProc() // Incrementa a régua
			
			nLinhas++
			nCont++
			
			cLin := cIdPessoa  + "|"
			cLin += Alltrim(Substr(TRB->CT1_CONTA,1,50)) + "|"
			cLin += Substr(TRB->CT1_ZCTATC,1,1) + "|"
			cLin += Substr(TRB->CT1_ZCTATC,3,1) + "|"
			cLin += Substr(TRB->CT1_ZCTATC,5,1) + "|"
			cLin += Substr(TRB->CT1_ZCTATC,7,1) + "|"
			cLin += Substr(TRB->CT1_ZCTATC,9,1) + "|"
			cLin += Substr(TRB->CT1_ZCTATC,11,2) + "|"
			cLin += Substr(TRB->CT1_ZCTATC,14,2) + "|"
			cLin += cAno + "|"
			
			If nLinhas < nRegistros
				cLin += CRLF
			EndIf
			
			// Gravação do arquivo. Testa por erros durante a gravação
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
					Exit
				EndIf
			EndIf
		EndIf
		
		TRB->(dbSkip())	
	EndDo
	
	TRB->(dbCloseArea())

	// Fecha o arquivo texto
	fClose(nHdl)
	
	AADD(aMensOK,{cNmArq})

Return Nil


/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! SalAntCTB	! Autor !Gilson Lima 		 ! Data ! 08/01/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT de Saldos Contábil Exercício Anterior		 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function SalAntCTB()

	// Gera o arquivo texto
	Local cNmArq	:= "SaldoContabilExercicioAnteriorEstatais.txt"
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0
	Local cQuery1	:= ""
	Local cQuery2	:= ""
	Local aContas   := {}
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf
	
	/***
	 * Notações
	 * 
	 * X - Qualquer caractere alfanumérico
	 * 9 - Apenas Numérico e de preenchimento obrigatório
	 * Z - Somente número ou posição em branco
	 *
	 * Tabela SaldoContabilExercicioAnteriorEstatais
	 *
	 * Captar o saldo do exercício anterior por conta contábil das Estatais
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Cód. Contábil Emp	50		Caractere	X(46)4		cdContaContabil				Sim			CT7->CT7_CONTA
	 * Ano de Implantação	4		Numérico	9999		nrAnoImplantacao			Sim			(NUM. ANO Quadrimestre - 1) - Memória base quadrimestre
	 * Natureza do Saldo	1		Caractere	X			tpNaturezaSaldo				Sim			"D" / "C"
	 * Saldo Exercício Ant.	16,2	Numérico	Z(13)9.99	VlSaldoExercicioAnterior	Sim			
	 *
	 * Filtro: Ano anterior ao do Quadrimestre
	 */
	 
	cQuery1 := "SELECT DISTINCT CT7.CT7_CONTA"
	cQuery1 += " FROM " + RetSqlName("CT7") + " CT7"
	cQuery1 += " WHERE CT7.CT7_DATA < '" + cAno + "0101'"
	cQuery1 += " AND CT7.CT7_CONTA LIKE '1%' OR CT7.CT7_CONTA LIKE '2%'"
	//cQuery1 += " AND CT7.CT7_DATA >= '" + cValtoChar(Val(cAno) - 1) + "0101'"
	cQuery1 += " ORDER BY CT7.CT7_CONTA" 
	
	cQuery1 := changeQuery(cQuery1) 
	
	dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery1),"CT7Tmp1", .f., .t.)

	While CT7Tmp1->(!EOF())

		
		cQuery2 := "SELECT TOP 1 (CT7.CT7_ATUDEB - CT7.CT7_ATUCRD) CT7_SALDO"
		cQuery2 += " FROM " + RetSqlName("CT7") + " CT7"
		cQuery2 += " WHERE CT7.CT7_CONTA = '" + CT7Tmp1->CT7_CONTA + "'"
		cQuery2 += " AND CT7.CT7_DATA < '" + cAno + "0101'"
		cQuery2 += " ORDER BY CT7.CT7_DATA DESC"
		
		cQuery2 := changeQuery(cQuery2) 
		
		dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery2),"CT7Tmp2", .f., .t.)
	
		While CT7Tmp2->(!EOF())
			
			If CT7Tmp2->CT7_SALDO <> 0
				nRegistros++
				
				aAdd(aContas,{CT7Tmp1->CT7_CONTA, CT7Tmp2->CT7_SALDO})
			EndIf
			
			CT7Tmp2->(dbSkip())
		End
		
		CT7Tmp2->(dbCloseArea())
		
		CT7Tmp1->(dbSkip())
	EndDo
	
	CT7Tmp1->(dbCloseArea())

	ProcRegua(nRegistros)	// Número de registros a Processar

	For nV := 1 To Len(aContas)

		IncProc() // Incrementa a régua

		nLinhas++
		nCont++
				
		cLin := cIdPessoa  + "|"
		cLin += AllTrim(aContas[nV][1]) + "|"
		cLin += cValToChar(Val(cAno)-1) + "|"
		cLin += IIF(aContas[nV][2] >= 0, "D", "C") + "|"
		
		If (aContas[nV][2] < 0)
			aContas[nV][2] := aContas[nV][2] * -1
		EndIf
		
		cLin += StrTran(LTrim(Transform(aContas[nV][2], "@E 999999999999.99")),",",".") + "|"
		
		If nLinhas < nRegistros
			cLin += CRLF
		EndIf
		
		// Gravação do arquivo. Testa por erros durante a gravação
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
				Exit
			EndIf
		EndIf
	
	Next nV	
	
	// Fecha o arquivo texto
	fClose(nHdl)	
	
	AADD(aMensOK,{cNmArq})

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! SalCtaCTB	! Autor !Gilson Lima 		 ! Data ! 08/01/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT de Saldos Mensais de Contas Contábeis 		 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function SalCtaCTB()
	
	// Gera o arquivo texto
	Local cNmArq	:= "MovimentoContabilMensalEstatais.txt"
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0
	Local cQuery	:= ""
	
	Local aArea		:= {}
	
	Local aDatas	:= ValDtSal()
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf
	
	/***
	 * Notações
	 * 
	 * X - Qualquer caractere alfanumérico
	 * 9 - Apenas Numérico e de preenchimento obrigatório
	 * Z - Somente número ou posição em branco
	 *
	 * Tabela MovimentoContabilMensalEstatais
	 *
	 * Captar movimento de débitos e créditos mensais por conta contábil das Estatais
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Cód. Contábil Emp	50		Caractere	X(46)4		idContaContabil				Sim			CT7->CT7_CONTA
	 * Ano da Operacao		4		Numérico	9999		nrAnoAplicacao				Sim			NUM. ANO - Memória base quadrimestre
	 * Mês da Operacao		2		Numérico	Z(1)9		nrMes						Sim			NUM. MÊS - Memória base quadrimestre
	 * Tipo Mov. Contábil	1		Numérico	9			idTipoMovimentoContabil		Sim			Manual: [1] - Movimento Normal / 2 - Encerramento do Exercício
	 * Valor do Débito		16,2	Numérico	Z(13)9.99	vlDebito					Sim			SUM(CT7_DEBITO)
	 * Valor do Saldo		16,2	Numérico	Z(13)9.99	vlCredito					Sim			SUM(CT7_CREDIT)
	 *
	 * Filtro: Entre datas do mês referente ao quadrimestre
	 */
	For nY := 1 to Len(aDatas)
		
		nRegistros := 0
		nLinhas	   := 0
		nCont	   := 0
		
		// Movimento Normal		
		cQuery := "SELECT CT7.CT7_CONTA, SUM(CT7.CT7_DEBITO) CT7_TDEBIT, SUM(CT7.CT7_CREDIT) CT7_TCREDI "
		cQuery += "FROM " + RetSqlName("CT7") + " AS CT7 "
		cQuery += "WHERE CT7.CT7_DATA BETWEEN '" + cValToChar(aDatas[nY][2])+StrZero(aDatas[nY][1],2)+"01" + "' AND '" + cValToChar(aDatas[nY][3]) + "' "
		cQuery += "AND CT7.CT7_LP <> 'Z' "
		cQuery += "GROUP BY CT7.CT7_CONTA"
		
		cQuery := changeQuery(cQuery) 
		
		dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),"CT7Tmp", .f., .t.)
	
		While CT7Tmp->(!EOF())
			nRegistros++
			CT7Tmp->(dbSkip())
		EndDo

		ProcRegua(nRegistros)	// Número de registros a Processar
		
		CT7Tmp->(dbGoTop())
		While CT7Tmp->(!EOF())

			IncProc() // Incrementa a régua
			
			nLinhas++
			nCont++
					
			cLin := cIdPessoa  + "|"
			cLin += AllTrim(CT7Tmp->CT7_CONTA) + "|"
			cLin += cValToChar(aDatas[nY][2]) + "|"
			cLin += cValToChar(aDatas[nY][1]) + "|"
			cLin += "1" + "|"
			cLin += StrTran(LTrim(Transform(CT7Tmp->CT7_TDEBIT, "@E 999999999999.99")),",",".") + "|"
			cLin += StrTran(LTrim(Transform(CT7Tmp->CT7_TCREDI, "@E 999999999999.99")),",",".") + "|"
			
			If nLinhas < nRegistros
				cLin += CRLF
			ElseIf nY < 4 // Valida se está no último mês do quadrimestre
				cLin += CRLF
			EndIf
			
			// Gravação do arquivo. Testa por erros durante a gravação
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
					Exit
				EndIf
			EndIf

			CT7Tmp->(dbSkip())

		EndDo

		DbCloseArea("CT7Tmp")
		
		/******************************************/

		// Encerramento do Exercício
				
		nRegistros := 0
		nLinhas	   := 0
		nCont	   := 0

		cQuery := "SELECT CT7.CT7_CONTA, SUM(CT7.CT7_DEBITO) CT7_TDEBIT, SUM(CT7.CT7_CREDIT) CT7_TCREDI "
		cQuery += "FROM " + RetSqlName("CT7") + " AS CT7 "
		cQuery += "WHERE CT7.CT7_DATA BETWEEN '" + cValToChar(aDatas[nY][2])+StrZero(aDatas[nY][1],2)+"01" + "' AND '" + cValToChar(aDatas[nY][3]) + "' "
		cQuery += "AND CT7.CT7_LP = 'Z' "
		cQuery += "GROUP BY CT7.CT7_CONTA"
		
		cQuery := changeQuery(cQuery) 
		
		dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),"CT7Tmp", .f., .t.)
	
		While CT7Tmp->(!EOF())
			nRegistros++
			CT7Tmp->(dbSkip())
		EndDo

		ProcRegua(nRegistros)	// Número de registros a Processar
		
		CT7Tmp->(dbGoTop())
		While CT7Tmp->(!EOF())

			IncProc() // Incrementa a régua
			
			nLinhas++
			nCont++
			
			If nLinhas == 1		
				cLin := CRLF + cIdPessoa  + "|"
			Else
				cLin := cIdPessoa  + "|"
			EndIf
			cLin += AllTrim(CT7Tmp->CT7_CONTA) + "|"
			cLin += cValToChar(aDatas[nY][2]) + "|"
			cLin += cValToChar(aDatas[nY][1]) + "|"
			cLin += "2" + "|"
			cLin += StrTran(LTrim(Transform(CT7Tmp->CT7_TDEBIT, "@E 999999999999.99")),",",".") + "|"
			cLin += StrTran(LTrim(Transform(CT7Tmp->CT7_TCREDI, "@E 999999999999.99")),",",".") + "|"
			
			If nLinhas < nRegistros
				cLin += CRLF
			ElseIf nY < 4 // Valida se está no último mês do quadrimestre
				cLin += CRLF
			EndIf
			
			// Gravação do arquivo. Testa por erros durante a gravação
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
					Exit
				EndIf
			EndIf

			CT7Tmp->(dbSkip())

		EndDo

		DbCloseArea("CT7Tmp")			
	
	Next nY
	
	// Fecha o arquivo texto
	fClose(nHdl)	
	
	AADD(aMensOK,{cNmArq})

Return Nil


/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! ContaBanc	! Autor !Gilson Lima 		 ! Data ! 19/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Contas Bancárias						 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function ContaBanc()
	
	// Gera o arquivo texto
	Local cNmArq	:= "ContaBancaria.txt"
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0	
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf
	
	/***
	 * Notações
	 * 
	 * X - Qualquer caractere alfanumérico
	 * 9 - Apenas Numérico e de preenchimento obrigatório
	 * Z - Somente número ou posição em branco
	 *
	 * Tabela ContaBancaria
	 *
	 * Captar o cadastro básico das contas bancárias, visando a verificação do
	 * fluxo financeiro por fontes de recursos.
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Identif. PJ TCE Vinc.7		Numérico	Z(6)9		idPessoaEntidade			Sim			Manual: 14834
	 * Cód. Ident. Conta	10		Numérico	Z(9)9		idConta						Sim			SA6->A6_ZIDTCE
	 * Cód. Banco			4		Numérico	Z(3)9		idBanco						Sim			SA6->A6_COD
	 * Cód. Agência			7		Caractere	X(7)		cdAgencia					Sim			SA6->A6_AGENCIA
	 * Num. Conta			14		Caractere	X(14)		cdConta						Sim			SA6->A6_NUMCON
	 * Cód. Fonte			5		Caractere	Z(2)999		cdFonte						Sim			NÃO APLICADO
	 * Sigla da UF			2		Caractere	X(2)		sgUF						Sim			SA6->A6_EST
	 * Descr. Conta			80		Caractere	X(80)		dsConta						Sim			SA6->A6_NOME
	 * Tipo de Vínculo		2		Numérico	Z(1)9		idTipoContaBancaria			Sim			SA6->A6_ZVINTCE
	 * Data de Abertura Cta	10		Data		AAAA-MM-DD	dtAbertura					Sim			SA6->A6_ZDTABER
	 *
	 * Filtro: SA6->A6_ZCTAEMP == "S"
	 */

	cQuery := 'SELECT SA6.A6_ZIDTCE, SA6.A6_COD, SA6.A6_AGENCIA, SA6.A6_NUMCON, SA6.A6_EST, SA6.A6_NOME, SA6.A6_ZVINTCE, SA6.A6_ZDTABER'
	cQuery += " FROM " + RetSqlName("SA6") + " SA6"
	cQuery += " WHERE SA6.D_E_L_E_T_ <> '*'"
	cQuery += " AND SA6.A6_ZCTAEMP = 'S'"
	cQuery += " AND SA6.A6_ZDTABER <= '" + DtoS(dDtFim) + "'"
	If nQuadr <> 1 .And. nQuadr <> 0
		cQuery += " AND SA6.A6_ZDTABER >= '" + DtoS(dDtIni) + "'"
	EndIf
	cQuery += " ORDER BY SA6.A6_ZIDTCE"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
		nRegistros ++
		TRB->(dbSkip())	
	EndDo

	ProcRegua(nRegistros)	// Número de registros a Processar
		 
	TRB->(dbGoTop())
	While TRB->(!EOF())
		
		IncProc() // Incrementa a régua
		
		nLinhas++
		nCont++
		
		cLin := cIdPessoa  + "|"
		cLin += cIdPessoa  + "|"
		cLin += cValToChar(Val(TRB->A6_ZIDTCE)) + "|" // Retira os zeros da esquerda
		
		// De -> Para criado para atender contas anteriores criadas com informação diferente do
		// cód. Febraban no campo Cód. Banco. Pois esse ítem é validado no envio ao TCE baseado
		// na tabela Febraban
		
		Do Case
			Case Alltrim(TRB->A6_COD)== "A01"
				cLin += "1" + "|"
				cLin += Alltrim(Substr(TRB->A6_AGENCIA,1,7)) + "|"
				cLin += "A" + Alltrim(Substr(TRB->A6_NUMCON,1,13)) + "|"
				
			Case Alltrim(TRB->A6_COD)== "A10"
				cLin += "104" + "|"
				cLin += Alltrim(Substr(TRB->A6_AGENCIA,1,7)) + "|"
				cLin += "A" + Alltrim(Substr(TRB->A6_NUMCON,1,13)) + "|"
			Case Alltrim(TRB->A6_COD)== "A15"
				cLin += "151" + "|"
				cLin += Alltrim(Substr(TRB->A6_AGENCIA,1,7)) + "|"
				cLin += "A" + Alltrim(Substr(TRB->A6_NUMCON,1,13)) + "|"
			Case Alltrim(TRB->A6_COD)== "A23"
				cLin += "237" + "|"
				cLin += Alltrim(Substr(TRB->A6_AGENCIA,1,7)) + "|"
				cLin += "A" + Alltrim(Substr(TRB->A6_NUMCON,1,13)) + "|"
			Case Alltrim(TRB->A6_COD)== "A34"
				cLin += "341" + "|"
				cLin += Alltrim(Substr(TRB->A6_AGENCIA,1,7)) + "|"
				cLin += "A" + Alltrim(Substr(TRB->A6_NUMCON,1,13)) + "|"
			Case Alltrim(TRB->A6_COD)== "A38"
				cLin += "38" + "|"
				cLin += Alltrim(Substr(TRB->A6_AGENCIA,1,7)) + "|"
				cLin += "A" + Alltrim(Substr(TRB->A6_NUMCON,1,13)) + "|"
			Case Alltrim(TRB->A6_COD)== "A42"
				cLin += "1" + "|"
				cLin += Alltrim(Substr(TRB->A6_AGENCIA,1,7)) + "|"
				cLin += "A" + Alltrim(Substr(TRB->A6_NUMCON,1,13)) + "|"
			Case Alltrim(TRB->A6_COD)== "P01"
				cLin += "1" + "|"
				cLin += Alltrim(Substr(TRB->A6_AGENCIA,1,7)) + "|"
				cLin += "P" + Alltrim(Substr(TRB->A6_NUMCON,1,13)) + "|"
			Case Alltrim(TRB->A6_COD)== "P10"
				cLin += "104" + "|"
				cLin += Alltrim(Substr(TRB->A6_AGENCIA,1,7)) + "|"
				cLin += "P" + Alltrim(Substr(TRB->A6_NUMCON,1,13)) + "|"
			Case Alltrim(TRB->A6_COD)== "P42"
				cLin += "1" + "|"
				cLin += Alltrim(Substr(TRB->A6_AGENCIA,1,7)) + "|"
				cLin += "P" + Alltrim(Substr(TRB->A6_NUMCON,1,13)) + "|"
			Otherwise
				cLin += cValToChar(Val(TRB->A6_COD)) + "|" // Retira os zeros da esquerda		
				cLin += Alltrim(Substr(TRB->A6_AGENCIA,1,7)) + "|"
				cLin += Alltrim(Substr(TRB->A6_NUMCON,1,14)) + "|"
		EndCase
		
		cLin += "|"
		cLin += Alltrim(Substr(TRB->A6_EST,1,2)) + "|"
		cLin += Alltrim(Substr(TRB->A6_NOME,1,80)) + "|"
		cLin += Alltrim(TRB->A6_ZVINTCE) + "|"
		cLin += ValidaData(TRB->A6_ZDTABER) + "|" // Alterar data
		
		If nLinhas < nRegistros
			cLin += CRLF
		EndIf
		
		// Gravação do arquivo. Testa por erros durante a gravação
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
				Exit
			EndIf
		EndIf
	
		TRB->(dbSkip())	
	EndDo

	// Fecha o arquivo texto
	fClose(nHdl)
	
	AADD(aMensOK,{cNmArq})

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! DesCtaBanc! Autor !Gilson Lima 		 ! Data ! 19/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Desativação de Contas Bancárias		 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function DesCtaBanc()
	
	// Gera o arquivo texto
	Local cNmArq	:= "DesativacaoContaBancaria.txt"
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0	
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf
	
	/***
	 * Notações
	 * 
	 * X - Qualquer caractere alfanumérico
	 * 9 - Apenas Numérico e de preenchimento obrigatório
	 * Z - Somente número ou posição em branco
	 *
	 * Tabela DesativacaoContaBancaria
	 *
	 * Captar dados das contas bancárias desativadas junto a instituição bancária
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Identif. PJ TCE Vinc.7		Numérico	Z(6)9		idPessoaEntidade			Sim			Manual: 14834
	 * Cód. Ident. Conta	10		Numérico	Z(9)9		idConta						Sim			SA6->A6_ZIDTCE
	 * Data de Desativacao	10		Data		AAAA-MM-DD	dtDesativacao				Sim			SA6->A6_DTBLOQ
	 *
	 * Filtro: SA6->A6_BLOCKED == "1" .And. SA6->A6_DTBLOQ <= dDtFim - Bloqueados com data de bloqueio menor ou igual quadrimestre de trabalho
	 */
	 
	cQuery := 'SELECT SA6.A6_ZIDTCE, SA6.A6_DTBLOQ'
	cQuery += " FROM " + RetSqlName("SA6") + " SA6"
	cQuery += " WHERE SA6.D_E_L_E_T_ <> '*'"
	cQuery += " AND SA6.A6_DTBLOQ <= '" + DtoS(dDtFim) + "'"
	cQuery += " AND SA6.A6_BLOCKED = '1'"
	cQuery += " AND SA6.A6_ZCTAEMP = 'S'"
	If nQuadr <> 1 .And. nQuadr <> 0
		cQuery += " AND SA6.A6_DTBLOQ >= '" + DtoS(dDtIni) + "'"
	EndIf
	cQuery += " ORDER BY SA6.A6_ZIDTCE"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
		nRegistros ++
		TRB->(dbSkip())	
	EndDo

	ProcRegua(nRegistros)	// Número de registros a Processar
		 
	TRB->(dbGoTop())
	While TRB->(!EOF())

		IncProc() // Incrementa a régua
		
		nLinhas++
		nCont++
		
		cLin := cIdPessoa  + "|"
		cLin += cIdPessoa  + "|"
		cLin += cValToChar(Val(TRB->A6_ZIDTCE)) + "|" // Retira os zeros da esquerda
		cLin += ValidaData(TRB->A6_DTBLOQ) + "|" // Alterar data
		
		If nLinhas < nRegistros
			cLin += CRLF
		EndIf
		
		// Gravação do arquivo. Testa por erros durante a gravação
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
				Exit
			EndIf
		EndIf
		
		TRB->(dbSkip())	
	EndDo

	// Fecha o arquivo texto
	fClose(nHdl)
	
	AADD(aMensOK,{cNmArq})

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! RDsCtaBanc! Autor !Gilson Lima 		 ! Data ! 22/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Reversão da Desativação de Contas 		 !
! 			! Bancárias														 !
+----------------------------------------------------------------------------*/
Static Function RDsCtaBanc()
	
	// Gera o arquivo texto
	Local cNmArq	:= "ReversaoDesativacaoContaBancaria.txt"
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0	
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf
	
	/***
	 * Notações
	 * 
	 * X - Qualquer caractere alfanumérico
	 * 9 - Apenas Numérico e de preenchimento obrigatório
	 * Z - Somente número ou posição em branco
	 *
	 * Tabela DesativacaoContaBancaria
	 *
	 * Captar dados das contas bancárias desativadas junto a instituição bancária
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Identif. PJ TCE Vinc.7		Numérico	Z(6)9		idPessoaEntidade			Sim			Manual: 14834
	 * Cód. Ident. Conta	10		Numérico	Z(9)9		idConta						Sim			SA6->A6_ZIDTCE
	 * Data de Desativacao	10		Data		AAAA-MM-DD	dtDesativacao				Sim			SA6->A6_DTBLOQ
	 * Dt Rev Desativacao	10		Data		AAAA-MM-DD	dtReversao					Sim			SA6->A6_ZDTREV
	 * Mot Rev Desativacao	250		Caractere	X(250)		dsMotivo					Sim			SA6->A6_ZMTREV
	 *
	 * Filtro: SA6->A6_BLOCKED == "1" .And. SA6->A6_DTBLOQ <= dDtFim - Bloqueados com data de bloqueio menor ou igual quadrimestre de trabalho
	 */

	cQuery := 'SELECT SA6.A6_ZIDTCE, SA6.A6_DTBLOQ, SA6.A6_ZDTREV, SA6.A6_ZMTREV'
	cQuery += " FROM " + RetSqlName("SA6") + " SA6"
	cQuery += " WHERE SA6.D_E_L_E_T_ <> '*'"
	cQuery += " AND SA6.A6_ZDTREV <= '" + DtoS(dDtFim) + "'"
	cQuery += " AND SA6.A6_ZDTREV <> '      '"
	cQuery += " AND SA6.A6_ZCTAEMP = 'S'"
	If nQuadr <> 1 .And. nQuadr <> 0
		cQuery += " AND SA6.A6_ZDTREV >= '" + DtoS(dDtIni) + "'"
	EndIf
	cQuery += " ORDER BY SA6.A6_ZIDTCE"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
		nRegistros ++
		TRB->(dbSkip())	
	EndDo

	ProcRegua(nRegistros)	// Número de registros a Processar
		 
	TRB->(dbGoTop())
	While TRB->(!EOF())

		IncProc() // Incrementa a régua
		
		nLinhas++
		nCont++
		
		cLin := cIdPessoa  + "|"
		cLin += cIdPessoa  + "|"
		cLin += cValToChar(Val(TRB->A6_ZIDTCE)) + "|" // Retira os zeros da esquerda
		cLin += ValidaData(DtoS(TRB->A6_DTBLOQ)) + "|" // Alterar data
		cLin += ValidaData(DtoS(TRB->A6_ZDTREV)) + "|" // Alterar data
		cLin += Alltrim(Substr(TRB->A6_ZMTREV,1,250)) + "|"
		
		If nLinhas < nRegistros
			cLin += CRLF
		EndIf
		
		// Gravação do arquivo. Testa por erros durante a gravação
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
				Exit
			EndIf
		EndIf
		
		TRB->(dbSkip())	
	EndDo

	// Fecha o arquivo texto
	fClose(nHdl)
	
	AADD(aMensOK,{cNmArq})

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! SalCtaBanc! Autor !Gilson Lima 		 ! Data ! 22/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT de Saldos Mensais de Contas Bancárias 		 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function SalCtaBanc()
	
	// Gera o arquivo texto
	Local cNmArq	:= "SaldoMensalExtratoBancario.txt"
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0
	Local lContaOk	:= .T.
	//Local cChave	:= ""
	//Local cChave2	:= ""
	Local cQuery	:= ""
	
	Local nNrMeses	:= 0
	Local nMesIni	:= 0
	Local nMesBloq	:= 0
	Local nMeses	:= 0
	Local lProcessa := .T.
	
	Local aArea		:= {}
	
	Local aDatas	:= ValDtSal()
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf
	
	/***
	 * Notações
	 * 
	 * X - Qualquer caractere alfanumérico
	 * 9 - Apenas Numérico e de preenchimento obrigatório
	 * Z - Somente número ou posição em branco
	 *
	 * Tabela DesativacaoContaBancaria
	 *
	 * Captar dados das contas bancárias desativadas junto a instituição bancária
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Identif. PJ TCE Vinc.7		Numérico	Z(6)9		idPessoaEntidade			Sim			Manual: 14834
	 * Cód. Ident. Conta	10		Numérico	Z(9)9		idConta						Sim			SA6->A6_ZIDTCE
	 * Tipo de Saldo		1		Numérico	9			idTipoSaldo					Sim			SA6->A6_ZTSLTCE
	 * Mês Base Saldo		2		Numérico	Z(1)9		nrMes						Sim			NUM. MÊS - Memória base quadrimestre
	 * Ano Base Saldo		3		Numérico	9999		nrAno						Sim			NUM. ANO - Memória base quadrimestre
	 * Natureza do Saldo	1		Caractere	X			tpNaturezaSaldo				Sim			D/C
	 * Valor do Saldo		16,2	Numérico	Z(13)9.99	vlSaldo						Sim			SE8->E8_SALATUA
	 *
	 * Filtro: SE8->E8_DTSALAT = Último Dia do Mês
	 */
	 
	dbSelectArea("SA6")

	SA6->(dbGoTop())
	While SA6->(!EOF())
	
		nMesesPl	:= 0
			
		If SA6->A6_ZCTAEMP == "S" .And. SA6->A6_ZDTABER <= dDtFim // Conta da Empresa, abertura inferior ao quadrimestre de trabalho
			If AllTrim(SA6->A6_BLOCKED) == "1"
				If SA6->A6_DTBLOQ >= dDtIni .And. SA6->A6_DTBLOQ <= dDtFim
					nMesIni := MONTH(dDtIni)
					nMesBloq:= MONTH(SA6->A6_DTBLOQ)
					nMeses  := nMesBloq - nMesIni
					
					For nZ := 1 To nMeses+1
						nRegistros ++		
					Next nZ
				EndIf
			Else
				nRegistros += 4
			EndIf
			
			If SA6->A6_ZDTABER > dDtIni
				nMesIni	:= MONTH(dDtIni)
				nMesAber:= MONTH(SA6->A6_ZDTABER)
				If nMesIni != nMesAber
					nMesesPl	:= nMesAber - nMesIni
					//nRegistros 	-= nMesesPl
				EndIf
			EndIf
		EndIf
		SA6->(dbSkip())
	EndDo

	ProcRegua(nRegistros)	// Número de registros a Processar
	
	SA6->(dbGoTop())
	While SA6->(!EOF())
	
		lProcessa	:= .T.
		nNrMeses	:= 0
		nMesesPl	:= 0
		
		IF SA6->A6_ZCTAEMP == "S" .And. SA6->A6_ZDTABER <= dDtFim // Conta da Empresa e abertura inferior ao quadrimestre de trabalho
		
			If AllTrim(SA6->A6_BLOCKED) == "1"
				If SA6->A6_DTBLOQ >= dDtIni .And. SA6->A6_DTBLOQ <= dDtFim
					nMesIni := MONTH(dDtIni)
					nMesBloq:= MONTH(SA6->A6_DTBLOQ)
					nMeses  := nMesBloq - nMesIni
			
					For nZ := 1 To nMeses+1
						nNrMeses ++		
					Next nZ
				Else
					lProcessa := .F.
				EndIf
			Else
				nNrMeses := 4
			EndIf
		Else
			lProcessa := .F.
		EndIf

		If lProcessa == .T.
			For nY := 1+nMesesPl To nNrMeses
			
				cQuery := "SELECT SE8.E8_BANCO, SE8.E8_AGENCIA, SE8.E8_CONTA, SE8.E8_DTSALAT, SE8.E8_SALATUA "
				cQuery += "FROM " + RetSqlName("SE8") + " AS SE8 "
				cQuery += "WHERE SE8.E8_BANCO = '" + SA6->A6_COD + "' AND SE8.E8_AGENCIA = '" + SA6->A6_AGENCIA + "' AND SE8.E8_CONTA = '" + SA6->A6_NUMCON + "' AND SE8.E8_DTSALAT <= '" + aDatas[nY][3] + "' AND SE8.D_E_L_E_T_ = '' "
				cQuery += "ORDER BY SE8.E8_DTSALAT DESC"
				
				cQuery := changeQuery(cQuery) 
				
				dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),"SE8Tmp", .f., .t.)
		   
					If SE8Tmp->(!Eof())
						lContaOk := .T.
					Else
						lContaOk := .F.
					EndIf
					
					IncProc() // Incrementa a régua
					
					nLinhas++
					nCont++
					
					cLin := cIdPessoa  + "|"
					cLin += cIdPessoa  + "|"
					cLin += cValToChar(Val(SA6->A6_ZIDTCE)) + "|" // Retira os zeros da esquerda
					cLin += SA6->A6_ZTSLTCE + "|"
					cLin += cValToChar(aDatas[nY][1]) + "|"
					cLin += cValToChar(aDatas[nY][2]) + "|"
					
					If lContaOk == .T.
						IF SE8tmp->E8_SALATUA >= 0 // Seguindo padrão contábil, no financeiro é crédito e no Contábil é débito
						
							cLin += "D" + "|"
							cLin += StrTran(LTrim(Transform(SE8tmp->E8_SALATUA, "@E 999999999999.99")),",",".") + "|"
							
						Else
							cLin += "C" + "|"
							cLin += StrTran(LTrim(Transform(SE8tmp->E8_SALATUA * -1,"@E 999999999999.99")),",",".") + "|"
							
						EndIf
					Else
						cLin += "D" + "|"
						cLin += "0.00" + "|"
					EndIf
					
					If nLinhas < nRegistros
						cLin += CRLF
					EndIf
					
				dbCloseArea()

				// Gravação do arquivo. Testa por erros durante a gravação
				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
						Exit
					EndIf
				EndIf
			Next nY
		EndIF
		
		SA6->(dbSkip())	
	EndDo

	// Fecha o arquivo texto
	fClose(nHdl)
	
	AADD(aMensOK,{cNmArq})

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	!ValEndereco! Autor !Gilson Lima 		 ! Data ! 17/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Valida Endereço + Municipio + UF retornando o endereço completo!
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function ValEndereco(cEnd,cCompl,cBairro,cEst,cCodMun)

	Local aArea 	:= GetArea()
	Local cEndereco := ""
	Local cChave	:= ""
	
	cChave := xFilial("CC2")+cEst+Substr(cCodMun,-1,5)
	
	dbSelectArea("CC2")
	CC2->(dbSetOrder(1))	// CC2_FILIAL+CC2_EST+CC2_CODMUN
	CC2->(dbSeek(cChave))
	
	cEndereco := AllTrim(cEnd)+" - "+AllTrim(cCompl)+" - "+AllTrim(cBairro)
	
	While CC2->(!EOF()) .And. CC2->(CC2_FILIAL+CC2_EST+CC2_CODMUN) == cChave
		cEndereco += " - "+AllTrim(CC2->CC2_MUN)+" - "+AllTrim(CC2->CC2_EST)
		CC2->(dbSkip())
	EndDo
	
	RestArea(aArea)
	
Return(cEndereco)

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! ValidaData! Autor !Gilson Lima 		 ! Data ! 18/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Retorna data passada como string para o formato AAAA-MM-DD	 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function ValidaData(cData)
	
	Local cNData := ""
	
	If allTrim(cData) != ""
		cNData := Substr(cData,1,4) + "-" + Substr(cData,5,2) + "-" + Substr(cData,7,2)
	Else
		cNData := ""
	EndIf
	
Return(allTrim(cNData))

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! SA6Aut	! Autor !Gilson Lima 		 ! Data ! 19/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Função para popular campo customizado SA6->A6_ZIDTCE para que	 !
! 			! a numeração automática fique correta.							 !
+----------------------------------------------------------------------------*/
Static Function ValDtSal()
	
	Local aDatas 	:= {}
	Local nAno		:= Year(dDtIni)
	Local nMesAt	:= Month(dDtIni)
	
	AADD(aDatas,{nMesAt,nAno,""})
	
	For nI := 1 To 3
		nMesAt ++
		AADD(aDatas,{nMesAt,nAno,""})
	Next nI
	
	For nX := 1 To Len(aDatas)
		Do Case
			Case aDatas[nX][1] == 1
				aDatas[nX][3] := cValToChar(aDatas[nX][2])+"0131"
			Case aDatas[nX][1] == 2
				If IsBissexto(cValToChar(aDatas[nX][2])) // Verifica se o ano é Bissexto
					aDatas[nX][3] := cValToChar(aDatas[nX][2])+"0229"
				Else
					aDatas[nX][3] := cValToChar(aDatas[nX][2])+"0228"
				EndIf
			Case aDatas[nX][1] == 3
				aDatas[nX][3] := cValToChar(aDatas[nX][2])+"0331"
			Case aDatas[nX][1] == 4
				aDatas[nX][3] := cValToChar(aDatas[nX][2])+"0430"
			Case aDatas[nX][1] == 5
				aDatas[nX][3] := cValToChar(aDatas[nX][2])+"0531"
			Case aDatas[nX][1] == 6
				aDatas[nX][3] := cValToChar(aDatas[nX][2])+"0630"
			Case aDatas[nX][1] == 7
				aDatas[nX][3] := cValToChar(aDatas[nX][2])+"0731"
			Case aDatas[nX][1] == 8
				aDatas[nX][3] := cValToChar(aDatas[nX][2])+"0831"
			Case aDatas[nX][1] == 9
				aDatas[nX][3] := cValToChar(aDatas[nX][2])+"0930"
			Case aDatas[nX][1] == 10
				aDatas[nX][3] := cValToChar(aDatas[nX][2])+"1031"
			Case aDatas[nX][1] == 11
				aDatas[nX][3] := cValToChar(aDatas[nX][2])+"1130"
			Case aDatas[nX][1] == 12
				aDatas[nX][3] := cValToChar(aDatas[nX][2])+"1231"
		EndCase
	Next nX
	
Return(aDatas)

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! IsBissexto! Autor !Gilson Lima 		 ! Data ! 22/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Função para retornar se o ano é bissexto ou não				 !
! 			! 							 									 !
+----------------------------------------------------------------------------*/
Static Function IsBissexto(cAno)

	Local cFinal	:= SubStr(cAno,3,2)
	Local nResult	:= 0
	Local lRet		:= .F.
	
	If cFinal == "00"
		nResult := Val(cAno) % 400
	Else
		nResult := Val(cAno) % 4
	EndIf
	
	If nResult == 0
		lRet := .T.
	EndIf

Return(lRet)
/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! SA6Aut	! Autor !Gilson Lima 		 ! Data ! 19/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Função para popular campo customizado SA6->A6_ZIDTCE para que	 !
! 			! a numeração automática fique correta.							 !
+----------------------------------------------------------------------------*/
User Function SA6Aut()
	
	Local nI := 0
	
	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	
	While SA6->(!EOF())
		nI++
		RecLock("SA6",.F.)
			SA6->A6_ZIDTCE := StrZero(nI,10)
		SA6->(MsUnlock())
		SA6->(dbSkip())
	EndDo
	
	Alert("Atualização da numeração OK")

Return