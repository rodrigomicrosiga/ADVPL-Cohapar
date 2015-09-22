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
!Nome 			   ! COHAPAR_GERATXT_TCEPRv2015.PRW							 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Programa para geração de Arquivos Texto				 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/04/2015												 !
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
! Programa 	! TCECADASTR! Autor !Gilson Lima 		 ! Data ! 17/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Tela de Processamento											 !
!			! Chamada da tela de seleção de arquivos do módulo				 !
+----------------------------------------------------------------------------*/
User Function TCECADASTR()

	Local nModulo := 1
	
	Processa({||TXTCEPR2(nModulo)},'Aguarde...', 'Geração de Arquivos')

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! TCECONTABI! Autor !Gilson Lima 		 ! Data ! 17/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Tela de Processamento											 !
!			! Chamada da tela de seleção de arquivos do módulo				 !
+----------------------------------------------------------------------------*/
User Function TCECONTABI()

	Local nModulo := 2
	
	Processa({||TXTCEPR2(nModulo)},'Aguarde...', 'Geração de Arquivos')

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! TCETESOURA! Autor !Gilson Lima 		 ! Data ! 17/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Tela de Processamento											 !
!			! Chamada da tela de seleção de arquivos do módulo				 !
+----------------------------------------------------------------------------*/
User Function TCETESOURA()

	Local nModulo := 3
	
	Processa({||TXTCEPR2(nModulo)},'Aguarde...', 'Geração de Arquivos')

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! TCELICITA ! Autor !Gilson Lima 		 ! Data ! 17/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Tela de Processamento											 !
!			! Chamada da tela de seleção de arquivos do módulo				 !
+----------------------------------------------------------------------------*/
User Function TCELICITA()

	Local nModulo := 4
	
	Processa({||TXTCEPR2(nModulo)},'Aguarde...', 'Geração de Arquivos')

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! TCECONTRAT! Autor !Gilson Lima 		 ! Data ! 17/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Tela de Processamento											 !
!			! Chamada da tela de seleção de arquivos do módulo				 !
+----------------------------------------------------------------------------*/
User Function TCECONTRAT()

	Local nModulo := 5
	
	Processa({||TXTCEPR2(nModulo)},'Aguarde...', 'Geração de Arquivos')

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! TCECONTRIN! Autor !Gilson Lima 		 ! Data ! 17/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Tela de Processamento											 !
!			! Chamada da tela de seleção de arquivos do módulo				 !
+----------------------------------------------------------------------------*/
User Function TCECONIN()

	Local nModulo := 6
	
	Processa({||TXTCEPR2(nModulo)},'Aguarde...', 'Geração de Arquivos')

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! TXTTCEPR2	! Autor !Gilson Lima 		 ! Data ! 18/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Tela de Processamento											 !
!			! Gera o(s) arquivo(s) TXT baseado nos parâmetros Informados	 !
+----------------------------------------------------------------------------*/
Static Function TXTCEPR2(nModulo)

	#DEFINE _OPC_cGETFILE ( GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	#DEFINE _POS_CADASTRAL  1
	#DEFINE _POS_CONTABIL   2
	#DEFINE _POS_TESOURARIA 3
	#DEFINE _POS_LICITACAO  4
	#DEFINE _POS_CONTRATO   5
	#DEFINE _POS_CONTRINT   6

	Local aRet			:= {}
	Local aParambox		:= {}
	Local dData			:= DATE()
	Local aQuadrim		:= {"1o. Quadrimestre - Jan a Abr","2o. Quadrimestre - Mai a Ago","3o. Quadrimestre - Set a Dez"}
	Local nAnosExib		:= 5
	Local aAno			:= {}

	Local cAlert 		:= "Arquivos Gerados:" + CHR(10) + CHR(10)

	Private cTitJan		:= "Geração de Aquivos TXT"
	
	Private aFuncoes	:= {{},{},{},{},{},{}} // Array para armazenar as Funções, Descrições e Arquivos
	Private aArquivos	:= {}

	Private cNmDir		:= '' // Caminho para salvar os arquivos
	
	Private aQuaDelib	:= {}
	Private cIdPessoa	:= GETNEWPAR("MV_TCEPRID",'99999') // idPessoa TCE/PR
	Private cEntOrig    := GETNEWPAR("MV_TCEENOR",'1') // Entidade Origem Licitação / Contrato
	Private cTpInstrCtr := '1' // Tipo de Instrumento Contratual - Sempre 1 = Contrato
	Private cDtIniPer   := '20150101' // Data início de assinatura de contratos para os arquivos
	Private aMensOK		:= {}
	Private nQuadr		:= 0
	
	Private cDtIni, cDtFim, dDtIni, dDtFim, cAno, cTpMov
	
	// Determina os Anos a serem apresentados
	AADD(aAno,cValToChar(Year(dData)))
	For nI := 1 To nAnosExib
		AADD(aAno,cValToChar(Year(dData) - nI))
	Next nI
	
	aAdd(aFuncoes[_POS_CADASTRAL]	,{'Cadastro'	,4	,{||PeSEICED(1)}	,'PessoaSEICED.txt'						,'Pessoas Não Jurisdicionadas do TCE'})
	aAdd(aFuncoes[_POS_CADASTRAL]	,{'Cadastro'	,4	,{||APSEICED(2)}	,'AtualizacaoPessoaSEICED.txt'			,'Atualização Pessoa SEICED'})
	aAdd(aFuncoes[_POS_CADASTRAL]	,{'Cadastro'	,4	,{||QuaDelib(3)}	,'QuadroDeliberativoExecutivo.txt'		,'Composição do Quadro Deliberativo e Executivo das Estatais'})
	aAdd(aFuncoes[_POS_CADASTRAL]	,{'Cadastro'	,4	,{||BxQuaDelib(4)}	,'BaixaQuadroDeliberativoExecutivo.txt' ,'Baixa na Composição do Quadro Deliberativo e Executivo das Estatais'})
	aAdd(aFuncoes[_POS_CADASTRAL]	,{'Cadastro'	,4	,{||ComCapSoc(5)}	,'ComposicaoCapitalSocial.txt'			,'Composição do Capital Social'})

	aAdd(aFuncoes[_POS_CONTABIL]	,{'Contabil'	,4	,{||PlContabil(1)}	,'PlanoContabilEstatal.txt'									,'Plano Contábil Estatal'})
	aAdd(aFuncoes[_POS_CONTABIL]	,{'Contabil'	,4	,{||PlContabR(2)}	,'PlanoContabilEstatalXPlanoContabilReferencialEstatais.txt','Plano Contábil Referencial Estatal'})
	aAdd(aFuncoes[_POS_CONTABIL]	,{'Contabil'	,4	,{||SalAntCTB(3)}	,'SaldoContabilExercicioAnteriorEstatais.txt'				,'Saldo Contabil Exercicio Anterior Estatais'})
	aAdd(aFuncoes[_POS_CONTABIL]	,{'Contabil'	,4	,{||SalCtaCTB(4)}	,'MovimentoContabilMensalEstatais.txt'						,'Movimento Contábil Mensal Estatais'})
	aAdd(aFuncoes[_POS_CONTABIL]	,{'Contabil'	,4	,{||Funcao(5)}		,'DemonstracaoMutacoesPatrimonioLiquido.txt'				,'Demonstração das Mutações do Patrimônio Líquido - DMPL'})
	aAdd(aFuncoes[_POS_CONTABIL]	,{'Contabil'	,4	,{||Funcao(6)}		,'DemonstracaoFluxoCaixa.txt'								,'Demonstração dos Fluxos de Caixa - DFC'})
	aAdd(aFuncoes[_POS_CONTABIL]	,{'Contabil'	,4	,{||GastoEst(7)}	,'GastoEstatal.txt'											,'Gastos das  Estatais'})
	aAdd(aFuncoes[_POS_CONTABIL]	,{'Contabil'	,4	,{||Funcao(8)}		,'EstornoGastoEstatal.txt'									,'Estorno dos Gastos das Estatais'})
	aAdd(aFuncoes[_POS_CONTABIL]	,{'Contabil'	,4	,{||DetGstEst(9)}	,'DetalheGastoEstatal.txt'									,'Detalhes dos Gastos das Estatais'})
	aAdd(aFuncoes[_POS_CONTABIL]	,{'Contabil'	,4	,{||Funcao(10)}		,'EstornoDetalheGastoEstatal.txt'							,'Estorno dos Detalhes dos Gastos das Estatais'})
	
	aAdd(aFuncoes[_POS_TESOURARIA]	,{'Tesouraria'	,4	,{||ContaBanc(1)}	,'ContaBancaria.txt'					,'Contas Bancárias'})
	aAdd(aFuncoes[_POS_TESOURARIA]	,{'Tesouraria'	,4	,{||DesCtaBanc(2)}	,'DesativacaoContaBancaria.txt'			,'Desativação de Contas Bancárias'})
	aAdd(aFuncoes[_POS_TESOURARIA]	,{'Tesouraria'	,4	,{||RDsCtaBanc(3)}	,'ReversaoDesativacaoContaBancaria.txt'	,'Reversão da Desativação de Contas Bancárias'})
	aAdd(aFuncoes[_POS_TESOURARIA]	,{'Tesouraria'	,4	,{||SalCtaBanc(4)}	,'SaldoMensalExtratoBancario.txt'		,'Saldo Mensal de Contas Bancárias'})
	
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||NrLicita(1)}	,'NumeroLicitacao.txt'						,'Números de Licitações'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||DadoLicita(2)}	,'DadosLicitacao.txt'						,'Atos Convocatórios das Licitações'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||MapaLicita(3)}	,'MapaLicitacao.txt'						,'Mapa dos Atos Convocatórios das Licitações e Referência de Preços'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(4)}	,'ParecerLicitacao.txt'						,'Pareceres dos Processos Licitatórios'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(5)}	,'PublicacaoEditalLicitacao.txt'			,'Publicação dos Instrumentos Convocatórios das Licitações'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(6)}	,'ConvidadoLicitacao.txt'					,'Cadastro dos Convidados para os Processos Licitatórios'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(7)}	,'SituacaoLicitacao.txt'					,'Situação dos Processos Licitatórios'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(8)}	,'ImpugnacaoLicitacao.txt'					,'Impugnação do Processo Licitatório'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(9)}	,'ResultadoImpugnacaoLicitacao.txt'			,'Resultado de Impugnação de Processos Licitatórios'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(10)}	,'Licitante.txt'							,'Cadastro dos Participantes em Licitações'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(11)}	,'PropostaLicitacao.txt'					,'Propostas dos Participantes dos Processos Licitatórios'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(12)}	,'ResultadoLicitante.txt'					,'Resultado dos Licitantes'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(13)}	,'VencedorLicitacao.txt'					,'Vencedores e Credenciados nos Processos Licitatórios'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(14)}	,'CancelamentoVencedorLicitacao.txt'		,'Cancelamento dos Vencedores e Credenciados dos Processos Licitatórios'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(15)}	,'ComponenteComissaoLicitacao.txt'			,'Componentes das Comissões de Licitações'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(16)}	,'BaixaComponenteComissaoLicitacao.txt'		,'Baixa dos Componentes das Comissões de Licitações'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(17)}	,'LicitacaoXComponenteComissaoLicitacao.txt','Vinculação Entre o Processo Licitatório e a Respectiva Comissão de Licitação'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(18)}	,'Certidao.txt'								,'Cadastro de Certidões'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(19)}	,'ComposicaoOrcamentoLicitacao.txt'			,'Composição do Orçamento dos Atos Convocatórios das Licitações'})
	aAdd(aFuncoes[_POS_LICITACAO]	,{'Licitação'	,4	,{||Funcao(20)}	,'GastoEstatalXLicitacao.txt'				,'Vinculação dos Gastos das Estatais com as Respectivas Licitações'})
	
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||ProcCompra(1)}	,'ProcessoCompra.txt'								,'Número do Processo de Compra'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||AtaRegis(2)}	,'AtaRegistroPreco.txt'								,'Ata de Registro de Preço'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||SitAta(3)}		,'SituacaoAtaRegistroPreco.txt'						,'Situação da Ata de Registro de Preços'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||Funcao(4)}	,'AditivoAtaRegistroPreco.txt'						,'Termos Aditivos de Ata de Registro de Preços'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||NumInstrCT(5)}	,'NumeroInstrumentoContratual.txt'					,'Número dos Instrumentos Contratuais'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||CadInstrCT(6)}	,'CadastroInstrumentoContratual.txt'				,'Dados dos Instrumentos Contratuais'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||ClaInstrCT(7)}	,'ClausulaNecessariaInstrumentoContratual.txt'		,'Cumprimento das Cláusulas Necessárias nos Instrumentos Contratuais'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||ParInstrCT(8)}	,'ParteContratada.txt'								,'Partes do Instrumento Contratual'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||AssInstrCt(9)}	,'AssinanteInstrumentoContratual.txt'				,'Assinantes dos Instrumentos Contratuais'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||ResInstrCt(10)}	,'ResponsavelInstrumentoContratual.txt'				,'Responsáveis pelos Instrumentos Contratuais'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||SitInstrCt(11)}	,'SituacaoInstrumentoContratual.txt'				,'Situação dos Instrumentos Contratuais'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||ContrVenc(12)}	,'ContratadoXVencedorLicitacao.txt'					,'Vinculação dos Instrumentos Contratuais com as Respectivas Licitações'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||ContrAta(13)}	,'ContratadoXAtaRegistroPreco.txt'					,'Vinculação dos Instrumentos Contratuais com a Respectiva Ata de Registro de Preço'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||PublContr(14)}	,'PublicacaoInstrumentoContratual.txt'				,'Publicação dos Instrumentos Contratuais e das Atas de Registro de Preços'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||Apostilam(15)}	,'Apostilamento.txt'								,'Apostilamento'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||NrAditivo(16)}	,'NumeroAditivoInstrumentoContratual.txt'			,'Cadastro do número dos aditivos dos instrumentos contratuais'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||Aditivo(17)}	,'AditivoInstrumentoContratual.txt'					,'Termos Aditivos dos Instrumentos Contratuais'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||AdtValor(18)}	,'AditivoValorInstrumentoContratual.txt'			,'Valores do Aditivo do Instrumento Contratual'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||AdtData(19)}	,'AditivoPrazoInstrumentoContratual.txt'			,'Aditivo de Prazo do Instrumento Contratual'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||AdtCessao(20)}	,'AditivoCessaoInstrumentoContratual.txt'			,'Aditivo de Cessão do Instrumento Contratual'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||AdtSubC(21)}	,'AditivoSubContratacao.txt'						,'Aditivo de SubContratação do Instrumento Contratual'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||AdtResc(22)}	,'AditivoRescisaoInstrumentoContratual.txt'			,'Aditivo de Rescisão do Instrumento Contratual'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||Funcao(23)}	,'AditivoRedimensionamentoInstrumentoContratual.txt','Aditivo de Redimensionamento do Instrumento Contratual'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||AdtOutros(24)}	,'OutroAditivoInstrumentoContratual.txt'			,'Outros Tipos de Aditivo do Instrumento Contratual'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||PublAdt(25)}	,'PublicacaoAditivoInstrumentoContratual.txt'		,'Publicação dos Extratos do Aditivo do Instrumento Contratual'})
	aAdd(aFuncoes[_POS_CONTRATO]	,{'Contrato'	,4	,{||ContrLic(26)}	,'InstrumentoContratualXLicitacao.txt'				,'Vinculação dos Contratos com as Respectivas Licitações'})

	aAdd(aFuncoes[_POS_CONTRINT]	,{'Ct. Interno'	,4	,{||Funcao(1)}	,'Achado.txt'									,'Achados do Controle Interno'})
	aAdd(aFuncoes[_POS_CONTRINT]	,{'Ct. Interno'	,4	,{||Funcao(2)}	,'Recomendacao.txt'								,'Recomendações do Controle Interno'})
	aAdd(aFuncoes[_POS_CONTRINT]	,{'Ct. Interno'	,4	,{||Funcao(3)}	,'RelatorioPrestacaoContaControleInterno.txt'	,'Relatório de Controle Interno Para a Prestação de Contas'})
	aAdd(aFuncoes[_POS_CONTRINT]	,{'Ct. Interno'	,4	,{||Funcao(4)}	,'RelatorioControladoriaGeral.txt'				,'Relatório da Controladoria Geral do Estado'})
	aAdd(aFuncoes[_POS_CONTRINT]	,{'Ct. Interno'	,4	,{||Funcao(5)}	,'TransparenciaAcessoInformacao.txt'			,'Transparência e Acesso a Informação'})
	aAdd(aFuncoes[_POS_CONTRINT]	,{'Ct. Interno'	,4	,{||Funcao(6)}	,'PedidoAcessoInformacao.txt'					,'Pedido de Aceso a Informação'})
	
	// Parâmetros
	AADD(aParambox,{2,"Selecione o Quadrimestre: ",1,aQuadrim,100,"",.T.})
	AADD(aParambox,{2,"Selecione o Ano: ",1,aAno,30,"",.T.})

	// Tabelas Cadastrais
	If nModulo == 1
		aArquivos := {}
		For nA := 1 To Len(aFuncoes[_POS_CADASTRAL])
			aAdd(aArquivos,aFuncoes[_POS_CADASTRAL][nA][4])
		Next nA
		
		aAdd(aParamBox,{9,"Tabelas Cadastrais:",100,9,.T.})
		aAdd(aParamBox,{3,"Gerar",1,{"Todos","Nenhum","Seleção"},100,"",.F.})
		aAdd(aParamBox,{2,"Selecione o Arquivo",1,aArquivos,100,"",.F.})

	EndIf

	// Módulo Contábil
	If nModulo == 2
		aArquivos := {}
		For nA := 1 To Len(aFuncoes[_POS_CONTABIL])
			aAdd(aArquivos,aFuncoes[_POS_CONTABIL][nA][4])
		Next nA
		
		aAdd(aParamBox,{9,"Módulo Contábil:",100,9,.T.})
		aAdd(aParamBox,{3,"Gerar",1,{"Todos","Nenhum","Seleção"},100,"",.F.})
		aAdd(aParamBox,{2,"Selecione o Arquivo",1,aArquivos,100,"",.F.})
	EndIf
	
	// Módulo Tesouraria
	If nModulo == 3
		aArquivos := {}
		For nA := 1 To Len(aFuncoes[_POS_TESOURARIA])
			aAdd(aArquivos,aFuncoes[_POS_TESOURARIA][nA][4])
		Next nA
		
		aAdd(aParamBox,{9,"Módulo Tesouraria:",100,9,.T.})
		aAdd(aParamBox,{3,"Gerar",1,{"Todos","Nenhum","Seleção"},100,"",.F.})
		aAdd(aParamBox,{2,"Selecione o Arquivo",1,aArquivos,100,"",.F.})
	EndIf
	
	// Módulo Licitação
	If nModulo == 4
		aArquivos := {}
		For nA := 1 To Len(aFuncoes[_POS_LICITACAO])
			aAdd(aArquivos,aFuncoes[_POS_LICITACAO][nA][4])
		Next nA
		
		aAdd(aParamBox,{9,"Módulo Licitação:",100,9,.T.})
		aAdd(aParamBox,{3,"Gerar",1,{"Todos","Nenhum","Seleção"},100,"",.F.})
		aAdd(aParamBox,{2,"Selecione o Arquivo",1,aArquivos,100,"",.F.})
	EndIf
	
	// Módulo Contratos
	If nModulo == 5
		aArquivos := {}
		For nA := 1 To Len(aFuncoes[_POS_CONTRATO])
			aAdd(aArquivos,aFuncoes[_POS_CONTRATO][nA][4])
		Next nA
		
		aAdd(aParamBox,{9,"Módulo Contratos:",100,9,.T.})
		aAdd(aParamBox,{3,"Gerar",1,{"Todos","Nenhum","Seleção"},100,"",.F.})
		aAdd(aParamBox,{2,"Selecione o Arquivo",1,aArquivos,100,"",.F.})
	EndIf
	
	// Módulo Controle Interno
	If nModulo == 6
		aArquivos := {}
		For nA := 1 To Len(aFuncoes[_POS_CONTRINT])
			aAdd(aArquivos,aFuncoes[_POS_CONTRINT][nA][4])
		Next nA
		
		aAdd(aParamBox,{9,"Módulo Controle Interno:",100,9,.T.})
		aAdd(aParamBox,{3,"Gerar",1,{"Todos","Nenhum","Seleção"},100,"",.F.})
		aAdd(aParamBox,{2,"Selecione o Arquivo",1,aArquivos,100,"",.F.})
	EndIf

	// Abre tela de Seleções
	If ParamBox(aParambox,"TCE/PR :: Geração de Arquivos .txt",@aRet)
	
		cNmDir := cGetFile( "Selecione o Diretorio | " , OemToAnsi( "Local para Salvar" ) , NIL , "" , .F. , _OPC_cGETFILE )
		
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

		// Executa funções conforme seleção na pergunta
		nA1 := nModulo
		If aRet[aFuncoes[nA1][1][2]] != 2 // Diferente de Nenhum
			If aRet[aFuncoes[nA1][1][2]] == 3 .And. ValType(aRet[aFuncoes[nA1][1][2] + 1]) == "N"
				Processa(aFuncoes[nA1][1][3], aFuncoes[nA1][1][4])
			Else
				For nB1 := 1 To Len(aFuncoes[nA1])
					If aRet[aFuncoes[nA1][1][2]] == 1 .Or. IIF(ValType(aRet[aFuncoes[nA1][1][2] + 1]) != "N", AllTrim(aRet[aFuncoes[nA1][1][2] + 1]) == AllTrim(aFuncoes[nA1][nB1][4]), .F.)
						Processa(aFuncoes[nA1][nB1][3], aFuncoes[nA1][nB1][4]) 
					EndIf						
				Next nB1
			EndIf
		EndIf

		// Trata Mensagem de Retorno de Execução do Arquivo
		For nX := 1 To Len(aMensOK)
			cAlert += aMensOK[nX][1] + chr(10)
		Next nX
		
		If Len(aMensOK) > 0
			MsgInfo(cAlert,"Geração de TXTs")
		EndIf
			
	EndIf

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! PeSEICED	! Autor !Gilson Lima 		 ! Data ! 18/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Quadro Deliberativo					 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function PeSEICED(nPos)

	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CADASTRAL][nPos][4]
	Local cArqTxt 	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local aSEICED	:= {}
	
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
	 * Tipo de Documento	2		Numérico	Z(1)9		idTipoDocumentoPessoa	Sim			SZI->ZI_TIPODOC
	 * Número do Documento	15		Caractere	X(15)		nrDocumento				Sim			SZI->ZI_NRDOC
	 * Nome da Pessoa		100		Caractere	X(100)		nmPessoa				Sim			SZI->ZI_NOME
	 * Endereço da Pessoa	250		Caractere	X(250)		dsEndereco				Sim			SZI->ZI_END + SZI->ZI_COMPL + SZI->ZI_BAIRRO + CC2->CC2_MUN + CC2->CC2_EST - Manual
	 * Código do CEP		8		Numérico	99999999	cdCEP					Sim			SZI->ZI_CEP 
	 */

	// Tabela PessoaSEICED - SZI
	cQuery := 'SELECT SZI.ZI_TIPODOC, SZI.ZI_NRDOC, SZI.ZI_NOME, SZI.ZI_END, SZI.ZI_COMPL, SZI.ZI_BAIRRO, SZI.ZI_UF, SZI.ZI_CODMUN, SZI.ZI_CEP'
	cQuery += " FROM " + RetSqlName("SZI") + " SZI"
	cQuery += " WHERE SZI.D_E_L_E_T_ <> '*'"
	cQuery += " AND SZI.ZI_ATIVO = 'S'"
	cQuery += " ORDER BY SZI.ZI_CODIGO"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc('Tab. PessoaSEICED') // Incrementa a régua
		
		// Retira caracteres especiais do Nr. Documento.
		cNrDoc := AllTrim(TRB->ZI_NRDOC)
		cNrDoc := StrTran(cNrDoc,'.','')
		cNrDoc := StrTran(cNrDoc,'-','')
		cNrDoc := StrTran(cNrDoc,'/','')
		
		lAddDados := .T.
		
		For nX := 1 To Len(aSEICED)
		
			If AllTrim(cNrDoc) == AllTrim(aSEICED[nX][2])
				lAddDados := .F.
			EndIF
		
		Next nX		
		
		If lAddDados
			aAdd(aSEICED,{;
				AllTrim(TRB->ZI_TIPODOC),;
				cNrDoc,;
				AllTrim(TRB->ZI_NOME),;
				AllTrim(Substr(ValEndereco(TRB->ZI_END,TRB->ZI_COMPL,TRB->ZI_BAIRRO,TRB->ZI_UF,TRB->ZI_CODMUN),1,250)),;
				AllTrim(TRB->ZI_CEP);
			})
		EndIf
		
		TRB->(dbSkip())	
	EndDo
	
	TRB->(dbCloseArea())
	

	// Tabela Fornecedores - SA2
	cQuery := "SELECT DISTINCT SA2.A2_TIPO, SA2.A2_CGC, SA2.A2_NOME, SA2.A2_END, SA2.A2_NR_END, SA2.A2_BAIRRO, SA2.A2_EST, SA2.A2_COD_MUN, SA2.A2_CEP"
	cQuery += " FROM " + RetSqlName("SA2") + " SA2"
	cQuery += " INNER JOIN " + RetSqlName("SE2") + " SE2"
	cQuery += "     ON SA2.A2_COD = SE2.E2_FORNECE"
	cQuery += "    AND SA2.A2_LOJA = SE2.E2_LOJA"
	cQuery += "    AND SE2.E2_PREFIXO <> 'ASS'"
	cQuery += "    AND (SE2.E2_PREFIXO+SE2.E2_TIPO <> 'FATIMP')"	
	cQuery += "    AND SE2.E2_VENCREA >= '" + DtoS(dDtIni) + "'"
	cQuery += "    AND SE2.E2_VENCREA <= '" + DtoS(dDtFim) + "'"
	cQuery += " WHERE SA2.D_E_L_E_T_ <> '*'"
	cQuery += " AND SA2.A2_MSBLQL <> '1'"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc('Tabela Fornecedores') // Incrementa a régua
		
		// Trata tipo de documento
		If AllTrim(TRB->A2_TIPO) == 'J'
			cTipoDoc := '1'
		Else
			cTipoDoc := '2'
		EndIf
		
		// Retira caracteres especiais do Nr. Documento.
		cNrDoc := AllTrim(TRB->A2_CGC)
		cNrDoc := StrTran(cNrDoc,'.','')
		cNrDoc := StrTran(cNrDoc,'-','')
		cNrDoc := StrTran(cNrDoc,'/','')
		
		lAddDados := .T.
		
		For nX := 1 To Len(aSEICED)
		
			If AllTrim(cNrDoc) == AllTrim(aSEICED[nX][2])
				lAddDados := .F.
			EndIF
		
		Next nX		
		
		If lAddDados
			aAdd(aSEICED,{;
				cTipoDoc,;
				cNrDoc,;
				AllTrim(Substr(TRB->A2_NOME,1,100)),;
				AllTrim(Substr(ValEndereco(AllTrim(TRB->A2_END)+', '+AllTrim(TRB->A2_NR_END),'',AllTrim(TRB->A2_BAIRRO),TRB->A2_EST,TRB->A2_COD_MUN),1,250)),;
				AllTrim(TRB->A2_CEP);
			})
		EndIf
		
		TRB->(dbSkip())	
	EndDo
	
	TRB->(dbCloseArea())
	
	ProcRegua(Len(aSEICED))
	
	// Gera Arquivo
	For nA = 1 To Len(aSEICED)
		
		IncProc('Gravando Arquivo') // Incrementa a régua
		
		nLinhas++
	
		cLin := aSEICED[nA][1] + "|"
		cLin += aSEICED[nA][2] + "|"
		cLin += aSEICED[nA][3] + "|"
		cLin += aSEICED[nA][4] + "|"
		cLin += aSEICED[nA][5] + "|"		
	
		If nLinhas < Len(aSEICED)
			cLin += CRLF
		EndIf
		
		// Gravação do arquivo. Testa por erros durante a gravação
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
				Exit
			EndIf
		EndIf
	
	Next nA

	// Fecha o arquivo texto
	fClose(nHdl)
	
	AADD(aMensOK,{cNmArq})

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! APSEICED	! Autor !Gilson Lima 		 ! Data ! 10/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT de Altearção da tabela PessoaSEICED		 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function APSEICED(nPos)

	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CADASTRAL][nPos][4]
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
	 * Tabela AtualizacaoPessoaSEICED
	 *
	 * Esta tabela visa inserir no sistema SEI-CED os credores, participantes vencedores de licitações, contribuintes,
	 * membros do quadro deliberativo e executivo das Estatais e outras pessoas informadas nas diversas tabelas do sistema.
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome					Obrigatorio	Protheus
	 * Tipo de Documento	2		Numérico	Z(1)9		idTipoDocumentoPessoa	Sim			SZI->ZI_TIPODOC
	 * Número do Documento	15		Caractere	X(15)		nrDocumento				Sim			SZI->ZI_NRDOC
	 * Nome da Pessoa		100		Caractere	X(100)		nmPessoa				Sim			SZI->ZI_NOME
	 * Endereço da Pessoa	250		Caractere	X(250)		dsEndereco				Sim			SZI->ZI_END + SZI->ZI_COMPL + SZI->ZI_BAIRRO + CC2->CC2_MUN + CC2->CC2_EST - Manual
	 * Código do CEP		8		Numérico	99999999	cdCEP					Sim			SZI->ZI_CEP 
	 */

	cQuery := 'SELECT SZI.ZI_TIPODOC, SZI.ZI_NRDOC, SZI.ZI_NOME, SZI.ZI_END, SZI.ZI_COMPL, SZI.ZI_BAIRRO, SZI.ZI_UF, SZI.ZI_CODMUN, SZI.ZI_CEP, SZI.ZI_DTALTER'
	cQuery += " FROM " + RetSqlName("SZI") + " SZI"
	cQuery += " WHERE SZI.D_E_L_E_T_ <> '*'"
	cQuery += " AND SZI.ZI_ATIVO = 'S'"
	cQuery += " AND SZI.ZI_DTALTER <= '" + DtoS(dDtFim) + "'" 	// Alteração efetuada dentro do quadrimestre
	cQuery += " AND SZI.ZI_DTALTER >= '" + DtoS(dDtIni) + "'"	// "
	cQuery += " ORDER BY SZI.ZI_CODIGO"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		cLin := AllTrim(TRB->ZI_TIPODOC) + "|"
		cLin += AllTrim(TRB->ZI_NRDOC) + "|"
		cLin += AllTrim(TRB->ZI_NOME) + "|"
		cLin += AllTrim(Substr(ValEndereco(TRB->ZI_END,TRB->ZI_COMPL,TRB->ZI_BAIRRO,TRB->ZI_UF,TRB->ZI_CODMUN),1,250)) + "|"
		cLin += AllTrim(TRB->ZI_CEP) + "|"
		cLin += ValidaData(TRB->ZI_DTALTER) + "|"
		
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
! Programa 	! QuaDelib	! Autor !Gilson Lima 		 ! Data ! 18/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Quadro Deliberativo					 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function QuaDelib(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CADASTRAL][nPos][4]
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
	 * Num. Doc. Componente	15		Caractere	X(15)		nrCPFComponente				Sim			SZJ->ZJ_NRDOC
	 * Nat. Função Quadro	2		Numérico	Z(1)9		idTipoNaturezaQuadroEstatal	Sim			SZJ->ZJ_CDNATUR
	 * Função Quadro Est.	2		Numérico	Z(1)9		idTipoFuncaoQuadroEstatal	Sim			SZJ->ZJ_CDTPFUN
	 * Dt. Início Mandato	10		Data		AAAA-MM-DD	dtInicio					Sim			SZJ->ZJ_DTINI
	 * Dt. Prev. Fim Mandato10		Data		AAAA-MM-DD	dtFim						Sim			SZJ->ZJ_DTPRFIM (Previsão termino do mandato)
	 */
		 
	cQuery := 'SELECT SZJ.ZJ_CODIGO, SZJ.ZJ_NRDOC, SZJ.ZJ_CDNATUR, SZJ.ZJ_CDTPFUN, SZJ.ZJ_DTINI, SZJ.ZJ_DTPRFIM, SZJ.ZJ_IDTCE'
	cQuery += " FROM " + RetSqlName("SZJ") + " SZJ"
	cQuery += " WHERE SZJ.D_E_L_E_T_ <> '*'"
	cQuery += " AND SZJ.ZJ_DTINI <= '" + DtoS(dDtFim) + "'" 	// Início do mandato Menor ou Igual data Final
	cQuery += " AND (SZJ.ZJ_DTFIM = '        ' OR SZJ.ZJ_DTFIM >= '" + DtoS(dDtIni) + "')"	// Fim maior que a data de início do período
	If nQuadr <> 1 .And. nQuadr <> 0
		cQuery += " AND SZJ.ZJ_DTALTER >= '" + DtoS(dDtIni) + "'"
		cQuery += " AND SZJ.ZJ_DTALTER <= '" + DtoS(dDtFim) + "'"
	Else
		cQuery += " AND SZJ.ZJ_DTINI >= '" + DtoS(dDtIni) + "'" 	// Início do mandato Maior ou Igual data Inicial
	EndIf
	cQuery += " ORDER BY SZJ.ZJ_CODIGO"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	nIdTCE := 0
	
	While TRB->(!EOF())
		
		IncProc() // Incrementa a régua
		
		nLinhas++
		nCont++
		
		lGrvID := .F.

		If AllTrim(TRB->ZJ_IDTCE) == ''
			If nIdTCE == 0
				nIdTCE := RetIDQuad()
				cIdTCE := cValToChar(nIdTCE)
			Else
				nIdTCE++
				cIdTCE := cValToChar(nIdTCE)
			EndIF
			lGrvID := .T.
		Else
			cIdTCE := cValToChar(Val(TRB->ZJ_IDTCE))
		EndIf
		
		cLin := cIdPessoa  + "|"
		cLin += cIdTCE  + "|"
		cLin += allTrim(Substr(TRB->ZJ_NRDOC,1,15)) + "|"
		cLin += allTrim(Substr(TRB->ZJ_CDNATUR,1,2)) + "|"
		cLin += allTrim(Substr(TRB->ZJ_CDTPFUN,1,2)) + "|"
		cLin += ValidaData(TRB->ZJ_DTINI) + "|" // Alterar data
		cLin += ValidaData(TRB->ZJ_DTPRFIM) + "|" // Alterar data

		If nLinhas < nRegistros
			cLin += CRLF
		EndIf
		
		// Gravação do arquivo. Testa por erros durante a gravação
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
				Exit
			EndIf
		EndIf
		
		If lGrvID
			aAreaTRB := GetArea()

			cChave := xFilial("SZJ")+TRB->ZJ_CODIGO
			
			dbSelectArea("SZJ")
			SZJ->(dbSetOrder(1))
			SZJ->(dbSeek(cChave))
			
			IF SZJ->(Found())
				RecLock("SZJ",.F.)
					SZJ->ZJ_IDTCE := PadL(cIdTCE,6,'0')
				MsUnLock()
			EndIF
			
			RestArea(aAreaTRB)
		EndIF
		
		TRB->(dbSkip())	
	EndDo
	
	TRB->(dbCloseArea())

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
Static Function BxQuaDelib(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CADASTRAL][nPos][4]
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
	 * Dt. Baixa			10		Data		AAAA-MM-DD	dtBAixa						Sim			SZJ->ZJ_DTFIM
	 * Tipo de Baixa		2		Numérico	Z(1)9		idTipoBaixaQuadroDelibExec	Sim			SZJ->ZJ_CDMOTBX
	 * Desc. Motivo Baixa	250		Caractere	X(250)		dsMotivo					Sim			SZJ->ZJ_DESCRBX
	 */
		 
	cQuery := 'SELECT SZJ.ZJ_CODIGO, SZJ.ZJ_DTFIM, SZJ.ZJ_NRDOC, SZJ.ZJ_CDMOTBX, SZJ.ZJ_DESCRBX, SZJ.ZJ_IDTCE'
	cQuery += " FROM " + RetSqlName("SZJ") + " SZJ"
	cQuery += " WHERE SZJ.D_E_L_E_T_ <> '*'"
	cQuery += " AND SZJ.ZJ_IDTCE <> '" + Space(6) + "'"
	cQuery += " AND SZJ.ZJ_DTINI <= '" + DtoS(dDtFim) + "'" 	// Início do mandato Menor ou Igual data Final
	cQuery += " AND SZJ.ZJ_DTFIM >= '" + DtoS(dDtIni) + "'"	// Fim maior que a data de início do período
	cQuery += " AND SZJ.ZJ_DTFIM <= '" + DtoS(dDtFim) + "'"	// Fim menor que a data de fim do período
	cQuery += " ORDER BY SZJ.ZJ_IDTCE, SZJ.ZJ_CODIGO"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
			
		IncProc() // Incrementa a régua
		
		nLinhas++
		nCont++
		
		cLin := cIdPessoa  + "|"
		cLin += cValToChar(Val(TRB->ZJ_IDTCE)) + "|"
		cLin += ValidaData(TRB->ZJ_DTFIM) + "|" // Alterar data
		cLin += allTrim(TRB->ZJ_CDMOTBX) + "|"
		
		If TRB->ZJ_CDMOTBX == "99"
			cLin += allTrim(Substr(TRB->ZJ_DESCRBX,1,250))
		EndIf
		
		cLin += "|"	

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
! Programa 	! COMCAPSOC	! Autor !Gilson Lima 		 ! Data ! 10/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT de Composição do Capital Social			 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function ComCapSoc(nPos)

	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CADASTRAL][nPos][4]
	Local cArqTxt 	:= cNmDir+cNmArq
	Local nHdl
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0

	// Executa apenas se for 3 Quadrimestre = Última remessa do ano 
	If nQuadr <> 3	
		Return
	EndIf
	
	nHdl := fCreate(cArqTxt)
		
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
	 * Tabela ComposicaoCapitalSocial
	 *
	 * Esta tabela visa captar a composição do Capital Social das Estatais,c ontendo os acionistas e tipos de ações.
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome					Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa				Sim			Manual: 14834
	 * Ano Aplicação		4		Numérico	9999		nrAnoAplicacao			Sim			Ano Selecionado
	 * Tipo de Documento	2		Numérico	Z(1)9		idTipoDocumentoPessoa	Sim			SZK.ZK_TIPODOC
	 * Número do Documento	15		Caractere	X(15)		nrDocumento				Sim			SZK.ZK_NRDOC
	 * Tipo de Ação			1		Numérico	9			idTipoAcaoCapital		Sim			SZK.ZK_TPACAO
	 * Nr Açoes				10		Numérico	Z(9)9		nrAcoes					Sim			SZK.ZK_NRACOES 
	 */

	cQuery := 'SELECT SZK.ZK_NRDOC, SZK.ZK_TIPODOC, SZK.ZK_TPACAO, SZK.ZK_NRACOES'
	cQuery += " FROM " + RetSqlName("SZK") + " SZK"
	cQuery += " WHERE SZK.D_E_L_E_T_ <> '*'"
	cQuery += " AND SZK.ZK_DTINI <= '" + cAno + "1231'" 	// Início dentro do Ano corrente
	cQuery += " AND (SZK.ZK_DTFIM = '        '"
	cQuery += " OR SZK.ZK_DTFIM >= '" + cAno + "0101')"	// Fim vazio ou dentro do Ano Corrente    "
	cQuery += " ORDER BY SZK.ZK_CODIGO"
		
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
		
		IncProc() // Incrementa a régua
		nLinhas++
		
		cLin := cIdPessoa  + "|"
		cLin += cAno + "|"
		cLin += AllTrim(TRB->ZK_TIPODOC) + "|"
		cLin += AllTrim(TRB->ZK_NRDOC) + "|"
		cLin += AllTrim(TRB->ZK_TPACAO) + "|"
		cLin += cValToChar(TRB->ZK_NRACOES) + "|"
		
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
! Programa 	! PlContabil! Autor !Gilson Lima 		 ! Data ! 19/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Plano Contábil Estatal					 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function PlContabil(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTABIL][nPos][4]
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
Static Function PlContabR(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTABIL][nPos][4]
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
Static Function SalAntCTB(nPos)

	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTABIL][nPos][4]
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
		//cLin += cValToChar(Val(cAno)-1) + "|"
		cLin += cAno + "|"
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
Static Function SalCtaCTB(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTABIL][nPos][4]
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
! Programa 	! GastoEst	! Autor !Gilson Lima 		 ! Data ! 18/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Gastos Estatal							 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function GastoEst(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTABIL][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0	
	
	Local NrGastoM	:= 0
	
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
	 * Tabela GastoEstatal
	 *
	 * Captar os gastos realizados pela Estatal, envolvendo todo sacrifício para aquisição de materiais, serviços, estoques,
	 * ativos permanente, pelo Regime de competência, independentemente da realização da despesa, apropriação em custos ou
	 * pagamento.
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Núm. de Contr. Gasto	9		Numérico	Z(8)9		nrGasto						Sim			SE2->E2_XNRGAS
	 * Ano do Gasto			4		Numérico	9999		nrAnoGasto					Sim			Ano(SE2->E2_EMISSAO)
	 * Data do Gasto		10		Data		AAAA-MM-DD	dtGasto						Sim			SE2->E2_EMISSAO
	 * Valor do Gasto		(16,2)	Numérico	Z(13)9.99	vlGasto						Sim			SE2->E2_VALOR
	 */

	cQuery := 'SELECT SE2.E2_FILIAL SE2.E2_XNRGAS, SE2.E2_EMISSAO, SE2.E2_VENCREA, SE2.E2_VALOR, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_FORNECE, SE2.E2_LOJA'
	cQuery += " FROM " + RetSqlName("SE2") + " SE2"
	cQuery += " WHERE SE2.D_E_L_E_T_ <> '*'"
	cQuery += " AND SE2.E2_PREFIXO <> 'ASS'" // Repasse Associação, não considerar como gasto
	cQuery += " AND (SE2.E2_PREFIXO+SE2.E2_TIPO <> 'FATIMP')"
	cQuery += " AND SE2.E2_VENCREA >= '" + DtoS(dDtIni) + "'"
	cQuery += " AND SE2.E2_VENCREA <= '" + DtoS(dDtFim) + "'"
	cQuery += " ORDER BY SE2.E2_VENCREA"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)

	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
		
		IncProc() // Incrementa a régua
		
		nLinhas++
		nCont++
		
		nrGasto := ''

		// Verifica o Nr. Sequencial do Gasto
		If AllTrim(TRB->E2_XNRGAS) == ''

			If nrGastoM == 0
				nrGasto  := RetNrGasto(1)	// Retorna Próximo número - 1 = Gasto, 2 = Detalhe
				NrGastoM := Val(nrGasto)
			Else
				nrGastoM++
				nrGasto  := cValToChar(nrGastoM)
			EndIF

			aAreaSE2 := GetArea()
			
			// Grava nr. retornado no banco de dados
			cChave := TRB->E2_FILIAL+TRB->E2_PREFIXO+TRB->E2_NUM+TRB->E2_PARCELA+TRB->E2_TIPO+TRB->E2_FORNECE+TRB->E2_LOJA
			
			dbSelectArea("SE2")
			SE2->(dbSetOrder(1))
			SE2->(dbSeek(cChave))
			
			If SE2->(Found())
				RecLock("SE2",.F.)
				
				SE2->E2_XNRGAS := nrGasto
				
				MsUnLock()
			EndIF
			
			SE2->(dbCloseArea())
			
			RestArea(aAreaSE2)
		Else
			nrGasto := AllTrim(TRB->E2_XNRGAS)
		EndIf
		
		cLin := cIdPessoa  + "|"
		cLin += nrGasto  + "|"
		cLin += Substr(TRB->E2_VENCREA,1,4) + "|"
		cLin += ValidaData(TRB->E2_VENCREA) + "|" // Alterar data
		cLin += StrTran(LTrim(Transform(TRB->E2_VALOR, "@E 999999999999.99")),",",".") + "|"
		
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
! Programa 	! EsGastoEst! Autor !Gilson Lima 		 ! Data ! 26/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Estornos de Gastos Estatal				 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function EsGastoEst(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTABIL][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0	
	
	Local NrGastoM	:= 0
	
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
	 * Tabela EstornoGastoEstatal
	 *
	 * Captar os estornos dos gastos realizados pela Estatal.
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Núm. do Estorno		9		Numérico	Z(8)9		nrEstorno					Sim			SE2->E2_XNREST
	 * Ano do Estorno		4		Numérico	9999		nrAnoEstorno				Sim			Ano(SE2->E2_MOVIMEN)
	 * Núm. de Contr. Gasto	9		Numérico	Z(8)9		nrGasto						Sim			SE2->E2_XNRGAS
	 * Ano do Gasto			4		Numérico	9999		nrAnoGasto					Sim			Ano(SE2->E2_EMISSAO)
	 * Data do Gasto		10		Data		AAAA-MM-DD	dtGasto						Sim			SE2->E2_EMISSAO
	 * Valor do Gasto		(16,2)	Numérico	Z(13)9.99	vlGasto						Sim			SE2->E2_VALOR
	 */

	cQuery := 'SELECT SE2.E2_FILIAL, SE2.E2_XNRGAS, SE2.E2_EMISSAO, SE2.E2_VENCREA, SE2.E2_VALOR, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_FORNECE, SE2.E2_LOJA'
	cQuery += " FROM " + RetSqlName("SE2") + " SE2"
	cQuery += " WHERE SE2.D_E_L_E_T_ <> '*'"
	cQuery += " AND SE2.E2_PREFIXO <> 'ASS'" // Repasse Associação, não considerar como gasto
	cQuery += " AND (SE2.E2_PREFIXO+SE2.E2_TIPO <> 'FATIMP')"
	cQuery += " AND SE2.E2_VENCREA >= '" + DtoS(dDtIni) + "'"
	cQuery += " AND SE2.E2_VENCREA <= '" + DtoS(dDtFim) + "'"
	cQuery += " ORDER BY SE2.E2_VENCREA"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)

	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
		
		IncProc() // Incrementa a régua
		
		nLinhas++
		nCont++
		
		nrGasto := ''

		// Verifica o Nr. Sequencial do Gasto
		If AllTrim(TRB->E2_XNRGAS) == ''

			If nrGastoM == 0
				nrGasto  := RetNrGasto(1)	// Retorna Próximo número - 1 = Gasto, 2 = Detalhe
				NrGastoM := Val(nrGasto)
			Else
				nrGastoM++
				nrGasto  := cValToChar(nrGastoM)
			EndIF

			aAreaSE2 := GetArea()
			
			// Grava nr. retornado no banco de dados
			cChave := TRB->E2_FILIAL+TRB->E2_PREFIXO+TRB->E2_NUM+TRB->E2_PARCELA+TRB->E2_TIPO+TRB->E2_FORNECE+TRB->E2_LOJA
			
			dbSelectArea("SE2")
			SE2->(dbSetOrder(1))
			SE2->(dbSeek(cChave))
			
			If SE2->(Found())
				RecLock("SE2",.F.)
				
				SE2->E2_XNRGAS := nrGasto
				
				MsUnLock()
			EndIF
			
			SE2->(dbCloseArea())
			
			RestArea(aAreaSE2)
		Else
			nrGasto := AllTrim(TRB->E2_XNRGAS)
		EndIf
		
		cLin := cIdPessoa  + "|"
		cLin += nrGasto  + "|"
		cLin += Substr(TRB->E2_VENCREA,1,4) + "|"
		cLin += ValidaData(TRB->E2_VENCREA) + "|" // Alterar data
		cLin += StrTran(LTrim(Transform(TRB->E2_VALOR, "@E 999999999999.99")),",",".") + "|"
		
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
! Programa 	! DetGstEst	! Autor !Gilson Lima 		 ! Data ! 18/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT  de Detalhes de Gastos Estatal				 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function DetGstEst(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTABIL][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nLinDet	:= 0
	Local nRegistros:= 0
	Local nCont		:= 0	
	
	Local NrGastoM	:= 0
	Local NrDetalheM:= 0
	Local aDadosDet := {}
	
	Local lGrvGasto	:= .F.
	Local lGrvDet	:= .F.
	Local lDetSD1	:= .F.
	
	Local cCPFOrdenador := GETNEWPAR("MV_TCEORD",'16096843972')
	
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
	 * Tabela DetalheGastoEstatal
	 *
	 * Captar o detalhamento dos gastos realizados pelas Estatais, envolvendo pricipalmente os documentos fiscais,
	 * ordenador, credor e o respectivo valor.
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Manual: 14834
	 * Núm. de Contr. Gasto 9		Numérico	Z(8)9		nrDetalhe					Sim			SE2->E2_NRDTTCE
	 * Ano Gasto			4		Numérico	9999		nrAnoDetalhe				Sim			Ano(SE2->E2_EMISSAO)
	 * Núm. de Contr. Gasto	9		Numérico	Z(8)9		nrGasto						Sim			SE2->E2_XNRGAS
	 * Ano do Gasto			4		Numérico	9999		nrAnoGasto					Sim			Ano(SE2->E2_EMISSAO)
	 * Data do Gasto		10		Data		AAAA-MM-DD	dtGasto						Sim			SE2->E2_EMISSAO
	 * Tipo de Gasto		2		Numérico	Z(1)9		idTipoGastoEstatal			Sim			SE2->E2_NATUREZ -> SED->ED_TPGAES
	 * Nr. Doc. Ordenador	15		Caractere	X(15)		nrCPFOrdenador				Sim			Parâmetro(MV_TCEORD)
	 * Cód. Doc. Fiscal		2		Numérico	Z(1)9		idTipoDocFiscal				Sim			SE2->E2_XCODTP
	 * Data Doc. Fiscal		10		Data		AAAA-MM-DD	dtDocFiscal					Sim			SE2->E2_EMISSAO
	 * Núm. Doc. Fiscal		50		Caractere	X(50)		nrDocFiscal					Sim			SE2->E2_NUM
	 * Tp. Série Doc. Fisc.	2		Numérico	Z(1)9		idTipoSerieDocFiscal		Sim			SE2->E2_PREFIXO (DE->PARA)
	 * Des.Série Doc. Fisc.	50		Caractere	X(50)		dsTipoSerie					Sim			"SP = Solicitação de Pagto"
	 * Tp. Doc. Credor		2		Numérico	Z(1)9		idTipoDocCredor				Sim			SE2->E2_FORNECE -> SA2->A2_TIPO (F = CPF, J = CNPJ)
	 * Nr. Doc. Credor		15		Caractere	X(15)		nrDocCredor					Sim			SA2->A2_CGC
	 * Tipo Grupo Item		3		Numérico	Z(2)9		idTipoGrupoItem				Sim			E2_NUM -> SF1 -> SD1 -> SB1 -> SBM			
	 * Tipo Classe Item		9		Numérico	Z(8)9		idTipoClasseItem			Sim			E2_NUM -> SF1 -> SD1 -> SB1 -> SBM
	 * Valor do Det.Gasto	(16,2)	Numérico	Z(13)9.99	vlGasto						Sim			SE2->E2_VALOR
	 */
 
	cQuery := "SELECT SE2.E2_FILIAL, SE2.E2_XNRGAS, SE2.E2_XCODTP, SE2.E2_EMISSAO, SE2.E2_VENCREA, SE2.E2_VALOR, SE2.E2_NRDTTCE,"
	cQuery += " SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_LOJA, SE2.E2_FORNECE,"
	cQuery += " SA2.A2_TIPO, SA2.A2_CGC,"
	cQuery += " SED.ED_TPGAES"
	cQuery += " FROM " + RetSqlName("SE2") + " SE2"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2"
	cQuery += "      ON SA2.A2_COD = SE2.E2_FORNECE"
	cQuery += "     AND SA2.A2_LOJA = SE2.E2_LOJA"
	cQuery += "     AND SA2.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("SED") + " SED"
	cQuery += "      ON SED.ED_CODIGO = SE2.E2_NATUREZ"
	cQuery += "     AND SED.D_E_L_E_T_ <>'*'"
	cQuery += " WHERE SE2.D_E_L_E_T_ <> '*'"
	cQuery += " AND SE2.E2_PREFIXO <> 'ASS'" // Repasse Associação, não considerar como gasto
	cQuery += " AND (SE2.E2_PREFIXO+SE2.E2_TIPO <> 'FATIMP')"
	cQuery += " AND SE2.E2_VENCREA >= '" + DtoS(dDtIni) + "'"
	cQuery += " AND SE2.E2_VENCREA <= '" + DtoS(dDtFim) + "'"
	cQuery += " ORDER BY SE2.E2_VENCREA"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)

	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
		
		IncProc() // Incrementa a régua
		
		nLinhas++
		nCont++
		aDadosDet := {}
		
		// Trata Série do Documento Fiscal
		cTpSerDFis := ''
		cDsSerDFis := ''
		
		Do Case
			Case AllTrim(TRB->E2_PREFIXO) == 'D-1' .Or. AllTrim(TRB->E2_PREFIXO) == 'D1' 
				cTpSerDFis := '1'		
			Case AllTrim(TRB->E2_PREFIXO) == 'M-1' .Or. AllTrim(TRB->E2_PREFIXO) == 'M1'
				cTpSerDFis := '2'		
			Case AllTrim(TRB->E2_PREFIXO) == 'A'
				cTpSerDFis := '3'		
			Case AllTrim(TRB->E2_PREFIXO) == 'A-1' .Or. AllTrim(TRB->E2_PREFIXO) == 'A1'
				cTpSerDFis := '4'		
			Case AllTrim(TRB->E2_PREFIXO) == 'A-2' .Or. AllTrim(TRB->E2_PREFIXO) == 'A2'
				cTpSerDFis := '5'		
			Case AllTrim(TRB->E2_PREFIXO) == 'B'
				cTpSerDFis := '6'		
			Case AllTrim(TRB->E2_PREFIXO) == 'B-1' .Or. AllTrim(TRB->E2_PREFIXO) == 'B1'
				cTpSerDFis := '7'		
			Case AllTrim(TRB->E2_PREFIXO) == 'B-2' .Or. AllTrim(TRB->E2_PREFIXO) == 'B2'
				cTpSerDFis := '8'		
			Case AllTrim(TRB->E2_PREFIXO) == 'M-7' .Or. AllTrim(TRB->E2_PREFIXO) == 'M7'
				cTpSerDFis := '9'		
			Case AllTrim(TRB->E2_PREFIXO) == 'M-8' .Or. AllTrim(TRB->E2_PREFIXO) == 'M8'
				cTpSerDFis := '10'		
			Case AllTrim(TRB->E2_PREFIXO) == '1'
				cTpSerDFis := '11'
			OtherWise
				cTpSerDFis := '99' // Outras Séries
				cDsSerDFis := 'Solicitacao de Pagamento'
		EndCase
		
		// Trata Tipo do Documento do Credor
		Do Case
			Case TRB->A2_TIPO == 'J'
				cTpDocCred := '1'
			Case TRB->A2_TIPO == 'F'
				cTpDocCred := '2'
			OtherWise
				cTpDocCred := '97' // Sem Documento
		EndCase

		// Número Gasto e Detalhe do Gasto
		nrGasto 	:= ''
		nrDetalhe 	:= ''		

		// Verifica o Nr. Sequencial do Gasto
		If AllTrim(TRB->E2_XNRGAS) == ''

			If nrGastoM == 0
				nrGasto  := RetNrGasto(1)	// Retorna Próximo número - 1 = Gasto, 2 = Detalhe
				NrGastoM := Val(nrGasto)
			Else
				nrGastoM++
				nrGasto  := cValToChar(nrGastoM)
			EndIF
			
			// Habilita gravação do NrGasto na SE2
			lGrvGasto := .T.

		Else
			nrGasto := AllTrim(TRB->E2_XNRGAS)
		EndIf
		
		// Trata ítens de NF
		cQuery2 := "SELECT SD1.D1_FILIAL, SD1.D1_TOTAL, SD1.D1_NRDTTCE, SD1.D1_COD, SD1.D1_ITEM,"
		cQuery2 += " SZN.ZN_CODCLAS, SZN.ZN_CODGRUP"
		cQuery2 += " FROM " + RetSqlName("SD1") + " SD1"
		cQuery2 += " LEFT JOIN " + RetSqlName("SB1") + " SB1"
		cQuery2 += "      ON SB1.B1_COD = SD1.D1_COD"
		cQuery2 += "     AND SB1.D_E_L_E_T_ <> '*'"
		cQuery2 += "     AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery2 += " LEFT JOIN " + RetSqlName("SBM") + " SBM"
		cQuery2 += "      ON SBM.BM_GRUPO = SB1.B1_GRUPO"
		cQuery2 += "     AND SBM.D_E_L_E_T_ <> '*'"
		cQuery2 += "     AND SBM.BM_FILIAL = '" + xFilial("SBM") + "'"
		cQuery2 += " LEFT JOIN " + RetSqlName("SZN") + " SZN"
		cQuery2 += "      ON SZN.ZN_CODCLAS = SBM.BM_CODGRCI"
		cQuery2 += "     AND SZN.D_E_L_E_T_ <> '*'"
		cQuery2 += "     AND SZN.ZN_FILIAL = '" + xFilial("SZN") + "'"
		cQuery2 += " WHERE SD1.D_E_L_E_T_ <> '*'"
		cQuery2 += " AND SD1.D1_FILIAL = '" + TRB->E2_FILIAL + "'"
		cQuery2 += " AND SD1.D1_DOC = '" + TRB->E2_NUM + "'"
		cQuery2 += " AND SD1.D1_LOJA = '" + TRB->E2_LOJA + "'"
		cQuery2 += " AND SD1.D1_FORNECE = '" + TRB->E2_FORNECE + "'"
		
		If Select('TRBSD1') <> 0
			dbSelectArea('TRBSD1')
			TRBSD1->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2),'TRBSD1',.F.,.F.)
	
		// Número de registros a Processar
		nRegSD1 := Contar("TRBSD1","!EOF()")
		
		lDetSD1 := .F.

		If nRegSD1 > 0
		
			lDetSD1 := .T.
					
			dbSelectArea('TRBSD1')
			TRBSD1->(dbGoTop())
		
			While TRBSD1->(!EOF())
			
				lGrvDetSD1 := .F.

				// Verifica o Nr. Sequencial do Detalhe do Gasto
				If AllTrim(TRBSD1->D1_NRDTTCE) == ''
				
					If nrDetalheM == 0
						
						nrDetalhe  := RetNrGasto(2)	// Retorna Próximo número - 1 = Gasto, 2 = Detalhe
						NrDetalheM := Val(nrDetalhe)
					Else
						nrDetalheM++
						nrDetalhe  := cValToChar(nrDetalheM)
					EndIF
					
					// Habilita gravação do NrDetalhe na SE2
					lGrvDetSD1 := .T.
		
				Else
					nrDetalhe := AllTrim(TRBSD1->D1_NRDTTCE)
				EndIf
				
				// Trata Classe e Grupo de Ítem
				
				If AllTrim(TRBSD1->ZN_CODGRUP) == ''
					cGrupoItem := '999' 	// Outros
				Else
					cGrupoItem := AllTrim(TRBSD1->ZN_CODGRUP)
				EndIf
				
				If AllTrim(TRBSD1->ZN_CODCLAS) == ''
					cClassItem := '99999'	// Outros
				Else
					cClassItem := AllTrim(TRBSD1->ZN_CODCLAS)
				EndIF
				
				aAdd(aDadosDet,{;
					nrDetalhe,;
					cGrupoItem,;
					cClassItem,;
					StrTran(LTrim(Transform(TRBSD1->D1_TOTAL, "@E 999999999999.99")),",",".");					
				})
				
				// Grava Detalhe
				If lGrvDetSD1
				
					// Grava nr. retornado no banco de dados
					cChave := TRBSD1->D1_FILIAL+TRB->E2_NUM+TRB->E2_PREFIXO+TRB->E2_FORNECE+TRB->E2_LOJA+TRBSD1->D1_COD+TRBSD1->D1_ITEM
					
					dbSelectArea("SD1")
					SD1->(dbSetOrder(1))
					SD1->(dbSeek(cChave))
					
					If SD1->(Found())
						RecLock("SD1",.F.)
							SD1->D1_NRDTTCE := nrDetalhe
						MsUnLock()
					EndIF
					
					SD1->(dbCloseArea())
				
				EndIF
			
				TRBSD1->(dbSkip())
			End
		EndIf
		
		TRBSD1->(dbCloseArea())
		
		// Se o detalhe não vier da SD1
		If !lDetSD1
		
			// Trata Classe e Grupo de Ítem
			cGrupoItem := '999' 	// Outros
			cClassItem := '99999'	// Outros
			
			lGrvDet := .F.
			
			// Busca Nr. do Detalhe
			If AllTrim(TRB->E2_NRDTTCE) == ''
	
				If nrDetalheM == 0
					nrDetalhe  := RetNrGasto(2)	// Retorna Próximo número - 1 = Gasto, 2 = Detalhe
					NrDetalheM := Val(nrDetalhe)
				Else
					nrDetalheM++
					nrDetalhe  := cValToChar(nrDetalheM)
				EndIF
				
				// Habilita gravação do NrDetalhe na SE2
				lGrvDet := .T.
	
			Else
				nrDetalhe := AllTrim(TRB->E2_NRDTTCE)
			EndIf
			
			// Adiciona Detalhe ao Array
			aAdd(aDadosDet,{;
				nrDetalhe,;
				cGrupoItem,;
				cClassItem,;
				StrTran(LTrim(Transform(TRB->E2_VALOR, "@E 999999999999.99")),",",".");			
			})
					
		EndIF

		// Se houver informações a gravar no banco
		If lGrvGasto .Or. lGrvDet

			// Grava nr. retornado no banco de dados
			cChave := TRB->E2_FILIAL+TRB->E2_PREFIXO+TRB->E2_NUM+TRB->E2_PARCELA+TRB->E2_TIPO+TRB->E2_FORNECE+TRB->E2_LOJA
			
			dbSelectArea("SE2")
			SE2->(dbSetOrder(1))
			SE2->(dbSeek(cChave))
			
			If SE2->(Found())
				RecLock("SE2",.F.)
				
				If lGrvGasto
					SE2->E2_XNRGAS 	:= nrGasto
				EndIF
				
				// Se for gravar o Detalhe e não vier da SD1
				If lGrvDet .And. !lDetSD1
					SE2->E2_NRDTTCE := nrDetalhe
				EndIf
				
				MsUnLock()
			EndIF
			
			SE2->(dbCloseArea())
		
		EndIf
		
		nLinDet := 0
		
		For nA := 1 To Len(aDadosDet)
		
			nLinDet++
			
			If AllTrim(TRB->E2_XCODTP) == ''
				cTpDocFis := '43' // Solicitação de Pagamento
			Else
				cTpDocFis := cValToChar(Val(TRB->E2_XCODTP))
			EndIf
			
			cLin := cIdPessoa  + "|"
			cLin += aDadosDet[nA][1] + "|"
			cLin += Substr(TRB->E2_VENCREA,1,4) + "|"
			cLin += nrGasto  + "|"
			cLin += Substr(TRB->E2_VENCREA,1,4) + "|"
			cLin += cValToChar(Val(TRB->ED_TPGAES)) + "|"
			cLin += AllTrim(cCPFOrdenador) + "|"
			cLin += cTpDocFis + "|"
			cLin += ValidaData(TRB->E2_EMISSAO) + "|" // Alterar data
			cLin += cValToChar(Val(TRB->E2_NUM))+ "|"
			cLin += cTpSerDFis + "|"
			cLin += cDsSerDFis + "|"
			cLin += cTpDocCred + "|"
			cLin += AllTrim(UPPER(TRB->A2_CGC)) + "|"
			cLin += cValToChar(Val(aDadosDet[nA][2])) + "|"
			cLin += cValToChar(Val(aDadosDet[nA][3])) + "|"
			cLin += aDadosDet[nA][4] + "|"
			
			If nLinDet < Len(aDadosDet)
				cLin += CRLF
			Else
				If nLinhas < nRegistros
					cLin += CRLF
				EndIf				
			EndIf
			
			// Gravação do arquivo. Testa por erros durante a gravação
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
					Exit
				EndIf
			EndIf
		
		Next nA

		TRB->(dbSkip())	
	EndDo

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
Static Function ContaBanc(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_TESOURARIA][nPos][4]
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
	 * Cód. Banco			3		Numérico	Z(3)9		idBanco						Sim			SA6->A6_COD
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
	//If nQuadr <> 1 .And. nQuadr <> 0
	
		cQuery += " AND SA6.A6_ZDTABER >= '" + DtoS(dDtIni) + "'"
	//EndIf
	cQuery += " ORDER BY SA6.A6_ZIDTCE"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)

	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	
	
	dbSelectArea('TRB')
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
Static Function DesCtaBanc(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_TESOURARIA][nPos][4]
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
	//If nQuadr <> 1 .And. nQuadr <> 0
		cQuery += " AND SA6.A6_DTBLOQ >= '" + DtoS(dDtIni) + "'"
	//EndIf
	cQuery += " ORDER BY SA6.A6_ZIDTCE"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)

	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)
		 
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
Static Function RDsCtaBanc(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_TESOURARIA][nPos][4]
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
	//If nQuadr <> 1 .And. nQuadr <> 0
		cQuery += " AND SA6.A6_ZDTREV >= '" + DtoS(dDtIni) + "'"
	//EndIf
	cQuery += " ORDER BY SA6.A6_ZIDTCE"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)
		 
	TRB->(dbGoTop())
	While TRB->(!EOF())

		IncProc() // Incrementa a régua
		
		nLinhas++
		nCont++
		
		cLin := cIdPessoa  + "|"
		cLin += cIdPessoa  + "|"
		cLin += cValToChar(Val(TRB->A6_ZIDTCE)) + "|" // Retira os zeros da esquerda
		cLin += ValidaData(TRB->A6_DTBLOQ) + "|" // Alterar data
		cLin += ValidaData(TRB->A6_ZDTREV) + "|" // Alterar data
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
Static Function SalCtaBanc(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_TESOURARIA][nPos][4]
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
! Programa 	! NrLicita  ! Autor !Gilson Lima 		 ! Data ! 06/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT de número, ano, modalidade e status da		 !
! 			! licitação														 !
+----------------------------------------------------------------------------*/
Static Function NrLicita(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_LICITACAO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
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
	 * Tabela NumeroLicitacao
	 *
	 * Captar dados referentes ao número, ano, modalidade e status da licitação para identificar o andamento do processo
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. da Licitacao.	4		Numérico	Z(3)9		nrLicitacao					Sim			CO1->CO1_CODEDT
	 * Ano Licitação	.	4		Numérico	9999		nrAnoLicitacao				Sim			Ano(CO1->CO1_DTABER)
	 * Modalidade Licitacao	2		Numérico	Z(1)9		idModalidadeLicitacao		Sim			CO1->CO1_MODALI/CO1_TIPO TabModalidadeLicitacao
	 * Entidade Orig. Licita3		Numérico	Z(2)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Num. Proc. Origem	10		Numérico	Z(9)9		nrProcessoOrigem			Sim			CO1->CO1_NUMPRO
	 * Num. Protoc. G. Est. 9		Numérico	Z(8)9		NrProtocoloGeralEstado		Não			?
	 * Data Protoc. Origem  10		Data		AAAA-MM-DD	dtProtocolo					Não			?
	 */
	 
	 cQuery := "SELECT CO1.CO1_CODEDT, CO1.CO1_DTABER, CO1.CO1_MODALI, CO1.CO1_TIPO, CO1.CO1_NUMPRO, CO1.CO1_XNUMPR, CO1.CO1_XDTPRO"
	 cQuery += " FROM " + RetSqlName("CO1") + " CO1"
	 cQuery += " WHERE CO1.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CO1.CO1_DTABER >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CO1.CO1_DTABER <= '" + DtoS(dDtFim) + "'"
	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++

		cIdModal := ''
				
		// Verifica Modalidade
		Do Case
			Case AllTrim(TRB->CO1_MODALI) == 'CV'
				cIdModal := '1'	// Convite
			Case AllTrim(TRB->CO1_MODALI) == 'TP'
				cIdModal := '2'	// Tomada de Preços
			Case AllTrim(TRB->CO1_MODALI) == 'CC'
				cIdModal := '3'	// Concorrência
			Case AllTrim(TRB->CO1_MODALI) == 'CS'
				cIdModal := '4'	// Concurso
			Case AllTrim(TRB->CO1_MODALI) == 'LL'
				cIdModal := '5'	// Leilão
			Case AllTrim(TRB->CO1_MODALI) == 'PG'
				If AllTrim(TRB->CO1_TIPO) == 'PP'
					cIdModal := '6'	// Pregao Presencial
				ElseIf AllTrim(TRB->CO1_TIPO) == 'PE'
					cIdModal := '7'	// Pregão Eletrônico
				EndIf
			Case AllTrim(TRB->CO1_MODALI) == 'DL'
				cIdModal := '8'	// Processo Dispensa
			Case AllTrim(TRB->CO1_MODALI) == 'IN'
				cIdModal := '9'	// Processo Inexigibilidade
			Otherwise
				cIdModal := '10'	// Regime Diferenciado de Contratações - RDC
		EndCase
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->CO1_CODEDT)) + "|"
		cLin += AllTrim(Substr(TRB->CO1_DTABER,1,4)) + "|"
		cLin += cIdModal + "|"
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->CO1_NUMPRO)) + "|"
		cLin += cValToChar(TRB->CO1_XNUMPR) + "|"
		cLin += ValidaData(TRB->CO1_XDTPRO) + "|"
		
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
! Programa 	! DadoLicita! Autor !Gilson Lima 		 ! Data ! 07/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Captar dados do ato convocatório (Edital ou Carta-convite)	 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function DadoLicita(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_LICITACAO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
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
	 * Tabela DadosLicitacao
	 *
	 * Captar dados do ato convocatório (Edital ou carta-convite)
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. da Licitacao.	4		Numérico	Z(3)9		nrLicitacao					Sim			CO1->CO1_CODEDT
	 * Ano Licitação	.	4		Numérico	9999		nrAnoLicitacao				Sim			Ano(CO1->CO1_DTABER)
	 * Modalidade Licitacao	2		Numérico	Z(1)9		idModalidadeLicitacao		Sim			CO1->CO1_MODALI/CO1_TIPO TabModalidadeLicitacao
	 * Entidade Orig. Licita3		Numérico	Z(2)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tipo Avaliação		2		Numérico	Z(1)9		idAvaliacaoLicitacao		Sim			CO1->CO1_TIPO tabAvaliacaoLicitacao
	 * Classif do Objeto 	1		Numérico	9			idClassificacaoObjLicitacao	Sim			CO1->CO1_ESPECI
	 * Descricao do Objeto  500		Caractere	X(500)		dsObjeto					Sim			CO1->CO1_OBS1 (Memo) - MSMM(CO1_CODEDT)
	 * Regime de Execução	2		Numérico	9			idRegimeExecucaoLicitacao	Sim			CO1->CO1_XREGEX
	 * Natureza Proc. Licita1		Numérico	1			idNaturezaLicitacao			Sim			CO1->CO1_XNATPR
	 * Data do Ato Covocat	10		Data		AAAA-MM-DD	dtAtoConvocatorio			Sim			?
	 * Data Prev Sessao Aber10		Data		AAAA-MM-DD	dtAbertura					Sim			?
	 * Permite Subcontrata	1		Caractere	X			flSubContratacao			Sim			?
	 * CPF Agente Publ Comp	15		Caractere	X(15)		nrCPF						Sim			?
	 * Part Comiss Licita	1		Caractere	X			flParticipacaoComissao		Sim			CO1->CO1_COMISS
	 * Benef Lei Complem	1		Numérico	9			idBeneficioMicroempresa		Sim			CO1->CO1_XBENME
	 */
	 
	 cQuery := "SELECT CO1.CO1_CODEDT, CO1.CO1_DTABER, CO1.CO1_MODALI, CO1.CO1_TIPO, CO1.CO1_ESPECI, CO1.CO1_XREGEX, CO1.CO1_XNATPR,"
	 cQuery += " CO1.CO1_COMISS, CO1.CO1_XBENME, CO1.CO1_AVAL, CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),CO1.CO1_OBS1)) As CO1_OBS1"
	 cQuery += " FROM " + RetSqlName("CO1") + " CO1"
	 cQuery += " WHERE CO1.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CO1.CO1_DTABER >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CO1.CO1_DTABER <= '" + DtoS(dDtFim) + "'"
	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
				
		// Verifica Modalidade
		cIdModal := ''

		Do Case
			Case AllTrim(TRB->CO1_MODALI) == 'CV'
				cIdModal := '1'	// Convite
			Case AllTrim(TRB->CO1_MODALI) == 'TP'
				cIdModal := '2'	// Tomada de Preços
			Case AllTrim(TRB->CO1_MODALI) == 'CC'
				cIdModal := '3'	// Concorrência
			Case AllTrim(TRB->CO1_MODALI) == 'CS'
				cIdModal := '4'	// Concurso
			Case AllTrim(TRB->CO1_MODALI) == 'LL'
				cIdModal := '5'	// Leilão
			Case AllTrim(TRB->CO1_MODALI) == 'PG'
				If AllTrim(TRB->CO1_TIPO) == 'PP'
					cIdModal := '6'	// Pregao Presencial
				ElseIf AllTrim(TRB->CO1_TIPO) == 'PE'
					cIdModal := '7'	// Pregão Eletrônico
				EndIf
			Case AllTrim(TRB->CO1_MODALI) == 'DL'
				cIdModal := '8'	// Processo Dispensa
			Case AllTrim(TRB->CO1_MODALI) == 'IN'
				cIdModal := '9'	// Processo Inexigibilidade
			Otherwise
				cIdModal := '10'	// Regime Diferenciado de Contratações - RDC
		EndCase
		
		// Tipo de Avaliação
		cTpAval := ''
		
		Do Case
			Case AllTrim(TRB->CO1_TIPO) == 'MP'
				If AllTrim(TRB->CO1_AVAL) != '1'
					cTpAval := '1'	// Menor Preço - Lote
				Else
					cTpAval := '2'	// Menor Preço - Item
				EndIf
			Case AllTrim(TRB->CO1_TIPO) == 'MT'
				If AllTrim(TRB->CO1_AVAL) != '1'
					cTpAval := '3'	// Melhor Técnica - Lote
				Else
					cTpAval := '4'	// Melhor Técnica - Item
				EndIf
			Case AllTrim(TRB->CO1_TIPO) $ ("TP|TC") 
				If AllTrim(TRB->CO1_AVAL) != '1'
					cTpAval := '5'	// Técnica e Preço - Lote
				Else
					cTpAval := '6'	// Técnica e Preço - Item
				EndIf
			Case AllTrim(TRB->CO1_TIPO) $ ("DI|DL|DE|DR|DV") 
				cTpAval := '10'	// Dispensa / Inexigibilidade
		EndCase

		// Classificação do Objeto
		cClassObj := ''
		
		Do Case
			Case AllTrim(TRB->CO1_ESPECI) == '2'
				cClassObj := '1'	// Compras e Serviços		
			Case AllTrim(TRB->CO1_ESPECI) == '1'
				cClassObj := '2'	// Obras e Serviços de Engenharia		
			Case AllTrim(TRB->CO1_ESPECI) == '3'
				cClassObj := '3'	// Alienação de Bens	
		EndCase	
		
		// Descrição do Objeto
		cDescrObj := ''
		cDescr := TRB->CO1_OBS1
		For nZ := 1 To MlCount(cDescr)
			cDescrObj += " " + AllTrim(MemoLine(cDescr,,nZ))
		Next nZ
		cDescrObj := Replace(cDescrObj,CHAR(10), ' ')
		cDescrObj := Replace(cDescrObj,CHAR(13),'')
		cDescrObj := AllTrim(cDescrObj)
		
		// Data do Ato Convocatório
		cDtConvoc := '0000-00-00'
		
		// Data Prevista para a Sessão de Abertura da Licitação
		cDtAbert := '0000-00-00'
		
		// Permite SubContratação?
		cPermSub := 'N'
		
		// Número CPF Agente Público Competente
		cCPF := '00000000000'
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->CO1_CODEDT)) + "|"
		cLin += AllTrim(Substr(TRB->CO1_DTABER,1,4)) + "|"
		cLin += cIdModal + "|"
		cLin += cEntOrig + "|"
		cLin += cTpAval + "|"
		cLin += cClassObj + "|"
		cLin += cDescrObj + "|"
		cLin += AllTrim(TRB->CO1_XREGEX) + "|"
		cLin += AllTrim(TRB->CO1_XNATPR) + "|"
		cLin += cDtConvoc + "|"
		cLin += cDtAbert + "|"
		cLin += cPermSub + "|"
		cLin += cCPF + "|"
		cLin += AllTrim(TRB->CO1_COMISS) + "|"
		cLin += AllTrim(TRB->CO1_XBENME ) + "|"
		
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
! Programa 	! MapaLicita! Autor !Gilson Lima 		 ! Data ! 08/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Captar os preços máximos e mínimos apresentados no ato		 !
! 			! convocatório. O valor mínimo aplica-se apneas a modalidade	 !
! 			! leilao														 !
+----------------------------------------------------------------------------*/
Static Function MapaLicita(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_LICITACAO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
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
	 * Tabela MapaLicitacao
	 *
	 * Captar os preços máximos e mínimos apresentados no ato convocatório. O valor mínimo aplica-se apenas para a modalidade leilão
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. da Licitacao.	4		Numérico	Z(3)9		nrLicitacao					Sim			CO1->CO1_CODEDT
	 * Ano Licitação	.	4		Numérico	9999		nrAnoLicitacao				Sim			Ano(CO1->CO1_DTABER)
	 * Modalidade Licitacao	2		Numérico	Z(1)9		idModalidadeLicitacao		Sim			CO1->CO1_MODALI/CO1_TIPO TabModalidadeLicitacao
	 * Entidade Orig. Licita3		Numérico	Z(2)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Número do Lote		5		Caractere	X(5)		nrLote						Sim			CO2->CO2_LOTE OU 1
	 * Número do Ítem		4		Numérico	Z(3)9		nrItem						Sim			CO2->CO2_ITEM
	 * Descrição do Ítem	1500	Caractere	X(1500)		dsItem						Sim			SB1->B1_DESC (xFilial+CO2_CODPRO)
	 * Quantidade do Ítem	14,3	Numérico	Z(10)9.999	qtItem						Sim			CO2->CO2_QUANT
	 * Unidade Medida Item	3		Numérico	Z(2)9		idUnidadeMedida				Sim			SB1->B1_UM (xFilial+CO2_CODPRO)
	 * Vl Mínimo Unit Item	18,4	Numérico	Z(13)9.9999 vlMinimoUnitarioItem		Não			CO2->CO2_XVLMI
	 * Vl Mínimo Total		16,2	Numérico	Z(13)9.99	vlMinimoTotal				Não			CO2->CO2_XVLMI * CO2->CO2_QUANT
	 * Vl Máximo Unit Item	18,4	Numérico	Z(13)9,9999 vlMaximoUnitarioItem		Não			CO2->CO2_VALEST
	 * Vl Máximo Total		16,2	Numérico	Z(13)9.99	vlMaximoTotal				Não			CO2->CO2_VALEST * CO2->CO2_QUANT
	 * Tipo Grupo do Item	3		Numérico	Z(2)9		idTipoGrupoItem				Sim			?
	 * Tipo Classe do Item	9		Numérico	Z(8)9		idTipoClasseItem			Sim			?
	 */
	 
	 cQuery := "SELECT CO1.CO1_CODEDT, CO1.CO1_DTABER, CO1.CO1_MODALI, CO1.CO1_TIPO," 
	 cQuery += " CO2.CO2_LOTE, CO2.CO2_ITEM, CO2.CODPRO, CO2.CO2_QUANT, CO2.CO2_XVLMI, CO2.CO2_VALEST,"
	 cQuery += " SB1.SB1_DESC, SB1.SB1_UM"
	 cQuery += " FROM " + RetSqlName("CO1") + " CO1"
	 cQuery += " LEFT JOIN " + RetSqlName("CO2") + " CO2"
	 cQuery += "      ON CO2.CO2_FILIAL = CO1.CO1_FILIAL
	 cQuery += "	 AND CO2.CO2_
	 
	 cQuery += " WHERE CO1.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CO1.CO1_DTABER >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CO1.CO1_DTABER <= '" + DtoS(dDtFim) + "'"
	 
	cQuery := "SELECT DISTINCT CN9.CN9_NUMERO AS NRCONTRATO, CN9.CN9_REVISA AS NRREVISAO, CN9.CN9_DTINIC AS DTINICONTRATO, CN9.CN9_DTREV AS DTREVISAO, CN9.CN9_VLATU AS VLATUAL, CN9.CN9_FILIAL AS FILIALCTR"
	cQuery += "     ,CN0.CN0_XXTAD AS IDTIPOADITIVO, CN0.CN0_XXOPA AS IDTIPOOPERACAO"
	cQuery += "     ,SA2.A2_TIPO AS TIPOCONTRATADA, SA2.A2_CGC AS DOCCONTRATADA"
	cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	cQuery += " LEFT JOIN " + RetSqlName("CNC") + " CNC"
	cQuery += "      ON CNC.CNC_FILIAL = CN9.CN9_FILIAL"
	cQuery += "     AND CNC.CNC_NUMERO = CN9.CN9_NUMERO"
	cQuery += "     AND CNC.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2"
	cQuery += "      ON SA2.A2_COD = CNC.CNC_CODIGO"
	cQuery += "     AND SA2.A2_LOJA = CNC.CNC_LOJA"
	cQuery += "     AND SA2.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN " + RetSqlName("CN0") + " CN0"
	cQuery += "      ON CN0.CN0_CODIGO = CN9.CN9_TIPREV"
	cQuery += "     AND CN0.D_E_L_E_T_ <> '*'"
	cQuery += "     AND LTRIM(CN0.CN0_XXTAP) = ''"
	cQuery += "	    AND CN0.CN0_XXTAD = '04'	
	cQuery += " WHERE CN9.CN9_REVISA <> '   '"
	cQuery += " AND CN9.D_E_L_E_T_ <> '*'"
	cQuery += " AND CN9.CN9_DTREV >= '" + DtoS(dDtIni) + "'"
	cQuery += " AND CN9.CN9_DTREV <= '" + DtoS(dDtFim) + "'"
	cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"
		 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
				
		// Verifica Modalidade
		cIdModal := ''

		Do Case
			Case AllTrim(TRB->CO1_MODALI) == 'CV'
				cIdModal := '1'	// Convite
			Case AllTrim(TRB->CO1_MODALI) == 'TP'
				cIdModal := '2'	// Tomada de Preços
			Case AllTrim(TRB->CO1_MODALI) == 'CC'
				cIdModal := '3'	// Concorrência
			Case AllTrim(TRB->CO1_MODALI) == 'CS'
				cIdModal := '4'	// Concurso
			Case AllTrim(TRB->CO1_MODALI) == 'LL'
				cIdModal := '5'	// Leilão
			Case AllTrim(TRB->CO1_MODALI) == 'PG'
				If AllTrim(TRB->CO1_TIPO) == 'PP'
					cIdModal := '6'	// Pregao Presencial
				ElseIf AllTrim(TRB->CO1_TIPO) == 'PE'
					cIdModal := '7'	// Pregão Eletrônico
				EndIf
			Case AllTrim(TRB->CO1_MODALI) == 'DL'
				cIdModal := '8'	// Processo Dispensa
			Case AllTrim(TRB->CO1_MODALI) == 'IN'
				cIdModal := '9'	// Processo Inexigibilidade
			Otherwise
				cIdModal := '10'	// Regime Diferenciado de Contratações - RDC
		EndCase
		
		// Tipo de Avaliação
		cTpAval := ''
		
		Do Case
			Case AllTrim(TRB->CO1_TIPO) == 'MP'
				If AllTrim(TRB->CO1_AVAL) != '1'
					cTpAval := '1'	// Menor Preço - Lote
				Else
					cTpAval := '2'	// Menor Preço - Item
				EndIf
			Case AllTrim(TRB->CO1_TIPO) == 'MT'
				If AllTrim(TRB->CO1_AVAL) != '1'
					cTpAval := '3'	// Melhor Técnica - Lote
				Else
					cTpAval := '4'	// Melhor Técnica - Item
				EndIf
			Case AllTrim(TRB->CO1_TIPO) $ ("TP|TC") 
				If AllTrim(TRB->CO1_AVAL) != '1'
					cTpAval := '5'	// Técnica e Preço - Lote
				Else
					cTpAval := '6'	// Técnica e Preço - Item
				EndIf
			Case AllTrim(TRB->CO1_TIPO) $ ("DI|DL|DE|DR|DV") 
				cTpAval := '10'	// Dispensa / Inexigibilidade
		EndCase

		// Classificação do Objeto
		cClassObj := ''
		
		Do Case
			Case AllTrim(TRB->CO1_ESPECI) == '2'
				cClassObj := '1'	// Compras e Serviços		
			Case AllTrim(TRB->CO1_ESPECI) == '1'
				cClassObj := '2'	// Obras e Serviços de Engenharia		
			Case AllTrim(TRB->CO1_ESPECI) == '3'
				cClassObj := '3'	// Alienação de Bens	
		EndCase	
		
		// Descrição do Objeto
		cDescrObj := ''
		cDescr := TRB->CO1_OBS1
		For nZ := 1 To MlCount(cDescr)
			cDescrObj += " " + AllTrim(MemoLine(cDescr,,nZ))
		Next nZ
		cDescrObj := Replace(cDescrObj,CHAR(10), ' ')
		cDescrObj := Replace(cDescrObj,CHAR(13),'')
		cDescrObj := AllTrim(cDescrObj)
		
		// Data do Ato Convocatório
		cDtConvoc := '0000-00-00'
		
		// Data Prevista para a Sessão de Abertura da Licitação
		cDtAbert := '0000-00-00'
		
		// Permite SubContratação?
		cPermSub := 'N'
		
		// Número CPF Agente Público Competente
		cCPF := '00000000000'
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->CO1_CODEDT)) + "|"
		cLin += AllTrim(Substr(TRB->CO1_DTABER,1,4)) + "|"
		cLin += cIdModal + "|"
		cLin += cEntOrig + "|"
		cLin += cTpAval + "|"
		cLin += cClassObj + "|"
		cLin += cDescrObj + "|"
		cLin += AllTrim(TRB->CO1_XREGEX) + "|"
		cLin += AllTrim(TRB->CO1_XNATPR) + "|"
		cLin += cDtConvoc + "|"
		cLin += cDtAbert + "|"
		cLin += cPermSub + "|"
		cLin += cCPF + "|"
		cLin += AllTrim(TRB->CO1_COMISS) + "|"
		cLin += AllTrim(TRB->CO1_XBENME ) + "|"
		
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
! Programa 	! ProcCompra! Autor !Gilson Lima 		 ! Data ! 27/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT de número do processo de compra que originou!
! 			! a contratação													 !
+----------------------------------------------------------------------------*/
Static Function ProcCompra(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	Local aProcess := {}
	
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
	 * Tabela ProcessoCompra
	 *
	 * Captar o número do processo de compra que originou a contratação
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Nr Processo Compra	10		Numérico	Z(9)9		nrProcessoCompra			Sim			CN9->CN9_NUMPR
	 * Ano Processo Compra	4		Numérico	9999		nrAnoProcessoCompra			Sim			Ano(CN9->CN9_XDTPRT)
	 * Dt Prot Proc Compra	10		Data		AAAA-MM-DD	dtProcessoCompra			Sim			CN9->CN9_XDTPRT
	 * Num Prot Geral Esta	9		Numérico	Z(8)9		nrProtocoloGeralEstado		Sim			CN9->CN9_NUMPR
	 * Dt Prot Geral Estado	10		Data		AAAA-MM-DD	dtProtocolo					Sim			CN9->CN9_XDTPRT
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMPR, CN9.CN9_XDTPRT"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " AND (CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc
	 cQuery += " OR CN9.CN9_TPCTO = '031')"		// ATAS DE REGISTRO DE PREÇO
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += " AND CN9.CN9_REVISA = '   '"
	 //cQuery += " AND CN9.CN9_NUMERO >= '0000006000'"
	 cQuery += " ORDER BY CN9.CN9_XDTPRT"
	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Trata Nr. do Processo
		cNrProc := AllTrim(TRB->CN9_NUMPR)
		cNrProc := StrTran(cNrProc,'.','')
		cNrProc := StrTran(cNrProc,',','')
		cNrProc := StrTran(cNrProc,'-','')
		cNrProc := StrTran(cNrProc,'/','')
		cNrProc := StrTran(cNrProc,' ','')
		
		lAdicPr := .T.
		
		For nZ := 1 To Len(aProcess)
		
			If AllTrim(cNrProc) == aProcess[nZ][1]
				lAdicPr := .F.
				Exit
			EndIf
		
		Next nZ
		
		IF lAdicPr
		
			aAdd(aProcess,{cNrProc})

			cLin := cIdPessoa + "|"
			cLin += cNrProc + "|"
			cLin += AllTrim(Substr(TRB->CN9_XDTPRT,1,4)) + "|"
			cLin += ValidaData(TRB->CN9_XDTPRT) + "|"
			cLin += cNrProc + "|"
			cLin += ValidaData(TRB->CN9_XDTPRT) + "|"
			
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
! Programa 	! AtaRegis  ! Autor !Gilson Lima 		 ! Data ! 26/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT de Captar o número ano e gerenciador de atas!
! 			! de registro de preços emitidas, bem como o nr proc e ano orig	 !
+----------------------------------------------------------------------------*/
Static Function AtaRegis(nPos)

	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
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
	 * Tabela AtaRegistroPreco
	 *
	 * Captar o número, ano e gerenciador das atas de registro de preços emitidas, bem como o número do processo
	 * e ano que as originou
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Ata Reg Preços	9		Numérico	Z(8)9		nrAtaRegistroPreco			Sim			CN9->CN9_XCDINS
	 * Ano Ata Reg Preços	4		Numérico	9999		nrAnoAtaRegistroPreco		Sim			Ano(CN9->CN9_DTINIC)
	 * Identif. PJ Origem	7		Numérico	Z(6)9		idGerenciador				Sim			Parâmetro
	 * Num. Proc. Compra	9		Numérico	Z(8)9		nrProcessoCompra			Sim			CN9->CN9_NUMPR
	 * Ano do Proc. Compra	4		Numérico	9999		nrAnoProcessoCompra			Sim			Ano(CN9->CN9_DTVIGE)
	 * Data Assinat Ata		10		Data		AAAA-MM-DD	dtAssinaturaAta				Sim			Data(CN9->CN9_DTASSI)
	 */
	 
	 cQuery := "SELECT CN9.CN9_XCDINS, CN9.CN9_DTINIC, CN9.CN9_NUMPR, CN9.CN9_DTASSI, CN9.CN9_XDTPRT"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " AND CN9.CN9_TPCTO = '031'"	// 031 = Ata Registro Preço
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Trata Nr. do Processo
		cNrProc := AllTrim(TRB->CN9_NUMPR)
		cNrProc := StrTran(cNrProc,'.','')
		cNrProc := StrTran(cNrProc,',','')
		cNrProc := StrTran(cNrProc,'-','')
		cNrProc := StrTran(cNrProc,'/','')
		cNrProc := StrTran(cNrProc,' ','')
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_XCDINS,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTASSI,1,4)) + "|"
		cLin += cEntOrig + "|" 
		cLin += cNrProc + "|"
		cLin += AllTrim(Substr(TRB->CN9_XDTPRT,1,4)) + "|"
		cLin += ValidaData(TRB->CN9_DTASSI) + "|"
		
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
! Programa 	! SitAta	! Autor !Gilson Lima 		 ! Data ! 01/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Informar o Andamento da ata de registro de preços				 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function SitAta(nPos)

	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
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
	 * Tabela SituacaoAtaRegistroPreco
	 *
	 * Informar o andamento da ata de registro de preços
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Ata Reg Preços	9		Numérico	Z(8)9		nrAtaRegistroPreco			Sim			CN9->CN9_XCDINS
	 * Ano Ata Reg Preços	4		Numérico	9999		nrAnoAtaRegistroPreco		Sim			Ano(CN9->CN9_DTINIC)
	 * Identif. PJ Origem	7		Numérico	Z(6)9		idGerenciador				Sim			Parâmetro
	 * Tipo Situaçao da Ata	2		Numérico	Z(1)2		idTipoSituacaoAta			Sim			DePara(CN9->CN9_SITUAC)
	 * Dt da Sitauação Ata	10		Data		AAAA-MM-DD	dtSituacao					Sim			ValidaData(CN9->CN9_DTULST)
	 */
	 
	 cQuery := "SELECT CN9.CN9_XCDINS, CN9.CN9_DTINIC, CN9.CN9_SITUAC, CN9.CN9_DTULST"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " AND CN9.CN9_TPCTO = '031'"	// 031 = Ata Registro Preço
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Trata Situação Ata
		If cValToChar(Val(TRB->CN9_SITUAC)) == '8'
			cSituAta := '3'
		Else
			cSituAta := '1'
		EndIf
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_XCDINS,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cEntOrig + "|" 
		cLin += cSituAta + "|"
		cLin += ValidaData(TRB->CN9_DTULST) + "|"
		
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
! Programa 	! NumInstrCT! Autor !Gilson Lima 		 ! Data ! 16/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT de Numero dos Instrumentos Contratuais		 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function NumInstrCT(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
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
	 * Tabela NumeroInstrumentoContratual
	 *
	 * Captar dados referentes ao número, ano, data e entidade origem do Contrato
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Num. Proc. Compra	9		Numérico	Z(8)9		nrProcessoCompra			Sim			CN9->CN9_NUMPR
	 * Ano do Proc. Compra	4		Numérico	9999		nrAnoProcessoCompra			Sim			Ano(CN9->CN9_XDTPRT)
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_DTINIC, CN9.CN9_NUMPR, CN9.CN9_XDTPRT"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " AND (CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc
	 cQuery += " OR CN9.CN9_TPCTO <= '031')"	// Ata de Registro de Preço
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += " AND CN9.CN9_NUMERO >= '0000006000'"
	 cQuery += " AND CN9.CN9_REVISA = '   '"
	 cQuery += " ORDER BY CN9.CN9_NUMERO"
	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Trata Nr. do Processo
		cNrProc := AllTrim(TRB->CN9_NUMPR)
		cNrProc := StrTran(cNrProc,'.','')
		cNrProc := StrTran(cNrProc,',','')
		cNrProc := StrTran(cNrProc,'-','')
		cNrProc := StrTran(cNrProc,'/','')
		cNrProc := StrTran(cNrProc,' ','')
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cNrProc + "|"
		cLin += AllTrim(Substr(TRB->CN9_XDTPRT,1,4)) + "|"
		
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
! Programa 	! CadInstrCT! Autor !Gilson Lima 		 ! Data ! 16/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Captar dados detalhados do instrumento contratual				 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function CadInstrCT(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cDescrObj := ''		
	Local cTpObjCtr := ''		
	Local cDtIniEx := '' 
	Local cDtFimEx := '' 
	Local cTpRegEx := ''
	Local cPrevSub := ''
	Local cPrevCes := ''
	Local cTpFornec := ''
	Local cFPagto := ''
	Local cTpMulta := ''
	Local cDescrMul := ''
	Local cTpGaran := ''
	Local cVlGaran := ''
	Local cVlMens := ''
	Local cVlTotal := ''
			
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
	 * Tabela CadastroInstrumentoContratual
	 *
	 * Captar dados detalhados do instrumento contratual
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Descr. Objeto		1500	Caractere	X(1500)		dsObjeto					Sim			CN9->CN9_CODOBJ -> TAB MEMO
	 * Tipo Obj. Contr.		2		Numerico	Z(1)9		idTipoObjetoContratual		Sim			CN9->CN9_TPCTO -> CN1->CN1_XTIPO
	 * Data Assinatura		10		Data		AAAA-MM-DD	dtAssinatura				Sim			CN9->CN9_DTASSI
	 * Data Início Vigenc.	10		Data		AAAA-MM-DD	dtInicioVigencia			Não			CN9->CN9_DTINIC
	 * Data Térm. Vigenc.	10		Data		AAAA-MM-DD	dtFimVigencia				Não			CN9->CN9_DTFIM
	 * Data Início Exec.	10		Data		AAAA-MM-DD	dtInicioExecucao			Não			CNA->CNA_DTINI (Pegar a menor data das planilhas do contrato)
	 * Data Term. Exec.		10		Data		AAAA-MM-DD	dtFimExecucao				Não			CNA->CNA_DTFIM (Pegar a maior data das planilhas do contrato)
	 * Tipo Reg. Execucao	2		Numérico	Z(1)9		idTipoRegimeExecucao...		Não			...InstrumentoContratual 
	 * Prev. de Subcontrat.	1		Caractere	X			flSubContratacao			Não			
	 * Prev. de Cessão Con.	1		Caractere	X			flCessaoContratacao			Não			
	 * Tipo de Fornecimento	1		Caractere	X			flFornecimentoImediato		Sim			CN9->CN9_XXTF
	 * Forma de Pagamento	2		Numerico	Z(1)9		idTipoFormaPagto...			Sim			CN9->CN9_CONDPG (001 = A Vista - Outros = A Prazo)
	 * Identif. Tp. Multa	2		Numerico	Z(1)9		idTipoMulta...				Não			
	 * Descr. Multa			1500	Caractere	X(1500)		dsMulta...					Não			
	 * Identif. Tipo Garant.2		Numerico	Z(1)9		idTipoGarantia...			Não			CN8->CN8_TPCALC (Se CN9->CN9_FLGCAU = 1)		
	 * Valor Seg. Garant.	16,2	Numerico	Z(13)9.99	vlGarantia					Não			CN8->CN8_VLEFET
	 * Valor Mensal Instr.	16,2	Numerico	Z(13)9.99	vlMensal...					Não			não
	 * Valor Total Instr.	16,2	Numerico	Z(13)9.99	vlTotal...					SIM			CN9->VLATU
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_DTINIC, CN9.CN9_DTFIM, CN9.CN9_CODOBJ,"
	 cQuery += " CN9.CN9_TPCTO, CN9.CN9_DTASSI, CN9.CN9_XXTF, CN9.CN9_CONDPG, CN9.CN9_VLATU, CN9.CN9_FLGCAU,"
	 cQuery += " CN9.CN9_XPRSUB, CN9.CN9_XPRCES, CN9.CN9_XTPMUL, CN9.CN9_XDSMUL"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += " AND (CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += " OR CN9.CN9_TPCTO = '031')"	// Ata REgistro PReço	 
	 cQuery += " AND CN9.CN9_NUMERO >= '0000006000'"
	 cQuery += " AND CN9.CN9_REVISA = '   '"
	 cQuery += " ORDER BY CN9_NUMERO" 
	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Busca a Descrição do Objeto - Função MSMM = retorna conteúdo da tabela SYP
		cDescrObj := AllTrim(Substr(MSMM(TRB->CN9_CODOBJ),1,1500))
		
		// Busca o Tipo de Obj Contratual na tabela SN1
		cTpObjCtr := cValToChar(Val(POSICIONE("CN1",1,xFilial("CN1")+TRB->CN9_TPCTO,"CN1_XTIPO")))
		
		// Tipo de Regime de Execução
		// Buscar de Licitações
		cTpRegEx := '1'
		
		// Forma de Pagamento
		If TRB->CN9_CONDPG == '001'
			cFPagto := '1' // À Vista
		Else
			cFPagto := '2' // À prazo
		EndIf
		
		// Tipo de Garantia
		If TRB->CN9_FLGCAU == '1'
			cTpGaran := cValToChar(Val(POSICIONE('CN8',2,xFilial('CN8')+TRB->CN9_NUMERO,"CN8_TPCAUC")))
		Else
			cTpGaran := '5' // Sem garantia
		EndIf
		
		// Valor Garantia
		If TRB->CN9_FLGCAU == '1'
			cVlGaran := StrTran(LTrim(Transform(POSICIONE('CN8',2,xFilial('CN8')+TRB->CN9_NUMERO,"CN8_VLEFET"), "@E 999999999999.99")),",",".")
		Else
			cVlGaran := '0.00'
		EndIf

		// Valor Mensal
		cVlMens := '0.00'
 
		// Valor Total
		cVlTotal := StrTran(LTrim(Transform(TRB->CN9_VLATU, "@E 999999999999.99")),",",".")
		
		// Valida data de Inicio que não pode ser menor que a data de Assinatura
		If TRB->CN9_DTINIC <= TRB->CN9_DTASSI
			dDtInic := DaySum(StoD(TRB->CN9_DTASSI),1)
			cDtIniEx:= DaySum(StoD(TRB->CN9_DTASSI),1)
		Else
			dDtInic := StoD(TRB->CN9_DTINIC)
			cDtIniEx := StoD(TRB->CN9_DTINIC)
		EndIF
		
		// Retorna Dt Início Execucao
		//cDtIniEx := ValidaData(RetExec(TRB->CN9_NUMERO,1)) // Anulado para atender os contratos importados que não possuem planilha
		cDtIniEx := ValidaData(DtoS(cDtIniEx))

		// Retorna Dt Fim Execucao
		//cDtFimEx := ValidaData(RetExec(TRB->CN9_NUMERO,2)) // Anulado para atender os contratos importados que não possuem planilha
		cDtFimEx := ValidaData(TRB->CN9_DTFIM)		

		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cDescrObj + "|"		
		cLin += cTpObjCtr + "|"		
		cLin += ValidaData(TRB->CN9_DTASSI) + "|" // Alterar data
		cLin += ValidaData(DtoS(dDtInic)) + "|" // Alterar data
		cLin += ValidaData(TRB->CN9_DTFIM) + "|" // Alterar data
		cLin += cDtIniEx + "|" 
		cLin += cDtFimEx + "|" 
		cLin += cTpRegEx + "|"
		cLin += AllTrim(TRB->CN9_XPRSUB) + "|"
		cLin += AllTrim(TRB->CN9_XPRCES) + "|"
		cLin += AllTrim(TRB->CN9_XXTF) + "|"
		cLin += cFPagto + "|"
		cLin += AllTrim(TRB->CN9_XTPMUL) + "|"
		cLin += AllTrim(TRB->CN9_XDSMUL) + "|"
		cLin += cTpGaran + "|"
		cLin += cVlGaran + "|"
		cLin += cVlMens + "|"
		cLin += cVlTotal + "|"
		
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
! Programa 	! ClaInstrCT! Autor !Gilson Lima 		 ! Data ! 22/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Informa Cláusulas dos Instrumentos Contratuais				 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function ClaInstrCT(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	Local nClausulas:= 19
	
	Local cClausula := '19' // Obrigação do contratado de manter, durante a execução do contrato, todas as condições de habilidade e qualificação...		
	Local cFlagCla  := 'S'		
			
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
	 * Tabela ClausulaNecessariaInstrumentoContratual
	 *
	 * Informa se o contrato possui as cláusulas necessárias
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tipo Cláusula Nec.   2	    Numérico	Z(1)9		idTipoClausulaNecessaria	Sim			cClausula
	 * Flag Cláusula Nec.	1		Caractere	X			flClausulaNecessaria		Sim			cFlagCla
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_DTINIC, CN9.CN9_DTFIM,"
	 cQuery += " CN9.CN9_XCL1, CN9.CN9_XCL2, CN9.CN9_XCL3, CN9.CN9_XCL4, CN9.CN9_XCL5, CN9.CN9_XCL6, CN9.CN9_XCL7, CN9.CN9_XCL8, CN9.CN9_XCL9, CN9.CN9_XCL10,"
	 cQuery += " CN9.CN9_XCL11, CN9.CN9_XCL12, CN9.CN9_XCL13, CN9.CN9_XCL14, CN9.CN9_XCL15, CN9.CN9_XCL16, CN9.CN9_XCL17, CN9.CN9_XCL18, CN9.CN9_XCL19"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 //cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 //cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += " AND CN9.CN9_REVISA = '   '"
	 cQuery += " AND (CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += " OR CN9.CN9_TPCTO = '031')"	// Ata REgistro PReço	 	 
	 cQuery += " AND CN9.CN9_NUMERO >= '0000006000'"
	 cQuery += " ORDER BY CN9.CN9_NUMERO" 
	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		For nB := 1 to nClausulas
			
			// Define o nome da variável a ser utilizada com macrosubstituição
			cNomVar := "TRB->CN9_XCL"+cValToChar(nB)
		
			cLin := cIdPessoa + "|"
			cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
			cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
			cLin += cTpInstrCtr + "|" 
			cLin += cEntOrig + "|"
			cLin += cValToChar(nB) + "|"		
			cLin += AllTrim(&cNomVar) + "|"		
			
			If nB < nClausulas
				cLin += CRLF
			ElseIf nLinhas < nRegistros
				cLin += CRLF
			EndIf
			
			// Gravação do arquivo. Testa por erros durante a gravação
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
					Exit
				EndIf
			EndIf		
			
		Next nB
				
		TRB->(dbSkip())	
	EndDo
	
	TRB->(dbCloseArea())

	// Fecha o arquivo texto
	fClose(nHdl)
	
	AADD(aMensOK,{cNmArq})	 
	 
Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! ParInstrCT! Autor !Gilson Lima 		 ! Data ! 22/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Dados da parte contratada e valor do contrato					 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function ParInstrCT(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela ParteContratada
	 *
	 * Captar dados que identificam a parte contratada e o valor do instrumento contratual que se refere a ela
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tipo Doc. Contratada 2	    Numérico	Z(1)9		idTipoDocContratada			Sim			SA2
	 * Nr Doc Contratada	15		Caractere	X(15)		nrDocContratada				Sim			SA2
	 * Vl Contratado		16,2	Numerico	Z(13)9.99	vlContratado				Sim			CN9->CN9_VLATU
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_DTINIC, CN9.CN9_DTFIM, CN9.CN9_VLATU, SA2.A2_TIPO, SA2.A2_CGC"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9, "
	 cQuery += RetSqlName("CNC") + " CNC,"
	 cQuery += RetSqlName("SA2") + " SA2"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CNC.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += " AND (CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += " OR CN9.CN9_TPCTO = '031')"	// Ata REgistro Preço	 
	 cQuery += " AND CN9.CN9_REVISA = '   '"
	 cQuery += " AND CN9.CN9_NUMERO >= '0000006000'"	 	 
	 cQuery += " AND CN9.CN9_NUMERO = CNC.CNC_NUMERO"
	 cQuery += " AND CN9.CN9_FILIAL = CNC.CNC_FILIAL"
	 cQuery += " AND CN9.CN9_REVISA = CNC.CNC_REVISA"
	 cQuery += " AND CNC.CNC_CODIGO = SA2.A2_COD"
	 cQuery += " AND CNC.CNC_LOJA = SA2.A2_LOJA"
	 cQuery += " ORDER BY CN9.CN9_NUMERO"
 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Tipo de Documento
		If TRB->A2_TIPO == 'J'
			cTpDoc := '1' // CNPJ
		Else
			cTpDoc := '2' // CPF
		EndIf
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpDoc + "|"
		cLin += AllTrim(TRB->A2_CGC) + "|"
		cLin += StrTran(LTrim(Transform(TRB->CN9_VLATU, "@E 999999999999.99")),",",".") + "|"
		
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
! Programa 	! AssInstrCt! Autor !Gilson Lima 		 ! Data ! 22/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Informa Assinantes dos Instrumentos Contratuais				 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function AssInstrCt(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela AssinanteInstrumentoContratual
	 *
	 * Informa Assinantes dos Instrumentos Contratuais
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tp Ass Contratada	2	    Numérico	Z(1)9		idTipoAssinante				Sim			CNC->CNC_XTASS
	 * Tp Doc Ass Contratada2	    Numérico	Z(1)9		idTipoDocAssinante			Sim			SZI
	 * Nr Doc Ass Contratada15		Caractere	X(15)		nrDocAssinante				Sim			SZI
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_DTINIC, CN9.CN9_DTFIM, CNC.CNC_XTASS, SZI.ZI_NRDOC, SZI.ZI_TIPODOC, SZIB.ZI_NRDOC AS DOCCONTRATANTE, SZIB.ZI_TIPODOC AS TPDOCCONTRATANTE"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " LEFT JOIN " + RetSqlName("SZI") + " SZIB"
	 cQuery += " 	ON SZIB.ZI_CODIGO = CN9.CN9_XCDRES"
	 cQuery += " LEFT JOIN "+ RetSqlName("CNC") + " CNC"
	 cQuery += " 	ON CN9.CN9_NUMERO = CNC.CNC_NUMERO"
	 cQuery += " 		AND CN9.CN9_FILIAL = CNC.CNC_FILIAL"
	 cQuery += " 		AND CN9.CN9_REVISA = CNC.CNC_REVISA"
	 cQuery += " 		AND CNC.D_E_L_E_T_ <> '*'"
	 cQuery += " LEFT JOIN " + RetSqlName("SZI") + " SZI"
	 cQuery += " 	ON CNC.CNC_XCDASS = SZI.ZI_CODIGO"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " 	AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " 	AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " 	AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += "    AND CN9.CN9_REVISA = '   '"
	 cQuery += "    AND (CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc
	 cQuery += "    OR CN9.CN9_TPCTO = '031')"	// Ata REgistro PReço	 	 
	 cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'"	 
	 cQuery += " ORDER BY CN9.CN9_NUMERO"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		
		// REPRESENTANTE DA CONTRATANTE
		cTpRepContr := '5'

		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpRepContr + "|"
		cLin += AllTrim(TRB->TPDOCCONTRATANTE) + "|"
		cLin += AllTrim(TRB->DOCCONTRATANTE) + "|"
		cLin += CRLF

		// Gravação do arquivo. Testa por erros durante a gravação
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
				Exit
			EndIf
		EndIf
		
		// REPRESENTANTE DA CONTRATADA		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->CNC_XTASS)) + "|"
		cLin += AllTrim(TRB->ZI_TIPODOC) + "|"
		cLin += AllTrim(TRB->ZI_NRDOC) + "|"
		
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
! Programa 	! ResInstrCt! Autor !Gilson Lima 		 ! Data ! 22/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Informa Responsaveis dos Instrumentos Contratuais				 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function ResInstrCt(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela ResponsavelInstrumentoContratual
	 *
	 * Informa Responsaveis dos Instrumentos Contratuais
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tp Resp Instr Contr	2	    Numérico	Z(1)9		idTipoResponsavelInstr...	Sim			CN9->CN9_XXTR
	 * Tp Doc Resp Instr C  2	    Numérico	Z(1)9		idTipoDocResponsavel		Sim			SZI
	 * Nr Doc Resp Instr C 15		Caractere	X(15)		nrDocResponsavel			Sim			SZI
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_DTINIC, CN9.CN9_DTFIM, CN9.CN9_XXTR, SZI.ZI_NRDOC, SZI.ZI_TIPODOC"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " LEFT JOIN " + RetSqlName("SZI") + " SZI"
	 cQuery += " 	ON CN9.CN9_XCDRES = SZI.ZI_CODIGO"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " 	AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " 	AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " 	AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += "    AND CN9.CN9_REVISA = '   '"
	 cQuery += "    AND (CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += " OR CN9.CN9_TPCTO = '031')"	// Ata REgistro PReço	 
	 cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'"	 	 
	 cQuery += " ORDER BY CN9.CN9_NUMERO"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
				
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->CN9_XXTR)) + "|"
		cLin += AllTrim(TRB->ZI_TIPODOC) + "|"
		cLin += AllTrim(TRB->ZI_NRDOC) + "|"
		
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
! Programa 	! SitInstrCt! Autor !Gilson Lima 		 ! Data ! 22/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Informar o andamento do instrumento contratual pactuado		 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function SitInstrCt(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela SituacaoInstrumentoContratual
	 *
	 * Informar o andamento do instrumento contratual pactuado
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tp Sit Instr Contrat	2	    Numérico	Z(1)9		idTipoSituacaoInstr...		Sim			CN9->CN9_SITUAC
	 * Data Sit Instr Contr 10		Data		AAAA-MM-DD	dtSituacao					Sim			CN9->CN9_DTULST
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_DTINIC, CN9.CN9_DTFIM, CN9.CN9_SITUAC, CN9.CN9_DTULST"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " 	AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " 	AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " 	AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += "    AND (CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += "     OR CN9.CN9_TPCTO = '031')"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += "    AND CN9.CN9_REVISA = '   '"
	 cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'"	 
	 cQuery += " ORDER BY CN9.CN9_NUMERO"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Situação do Contrato
		Do Case
			Case TRB->CN9_SITUAC == '02' // Em Elaboração
				cSituac := '1'	// Em Edição
			Case TRB->CN9_SITUAC == '04' // Em Aprovação
				cSituac := '2'	// Autorizado
			Case TRB->CN9_SITUAC $ '05_09' // Vigente
				cSituac := '3'	// Publicado / Registrado
			Case TRB->CN9_SITUAC == '06' // Paralizado
				cSituac := '4'	// Rescindido
			Case TRB->CN9_SITUAC == '08' // Finalizado
				cSituac := '5'	// Vencido/Expirado
			Case TRB->CN9_SITUAC == '01' // Cancelado
				cSituac := '6'	// Número descartado/Cancelado
		EndCase
				
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cSituac + "|"
		cLin += ValidaData(TRB->CN9_DTULST) + "|"
		
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
! Programa 	! ContrVenc ! Autor !Gilson Lima 		 ! Data ! 27/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT Vinculando o intrumento contratual com a	 !
! 			! respectiva licitação.											 !
+----------------------------------------------------------------------------*/
Static Function ContrVenc(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
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
	 * Tabela ContratadoXVencedorLicitacao
	 *
	 * Captar a vinculação do instrumento contratual com a respectiva licitação
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tipo Doc Contratada	2		Numérico	Z(1)9		idTipoDocContratada			Sim			
	 * Numero Doc Contratada15		Caractere	X(15)		nrDocContratada				Sim
	 * Identif PJ Respons	7		Numérico	Z(6)9		idPessoaLicitacao			Sim
	 * Nr Licitacao			4		Numérico	Z(3)9		nrLicitacao					Sim
	 * Ano Licitacao		4		Numérico	9999		nrAnoLicitacao				Sim
	 * Modal Licitacao		2		Numérico	Z(1)9		idModalidadeLicitacao		Sim	
	 * Entid Orig Licitacao	3		Numérico	Z(2)9		idEntidadeOrigem			Sim
	 * Tipo Doc Vencedor	2		Numérico	Z(1)9		IdTipoDocVencedor			Sim
	 * Num. Doc Vencedor	15		Caractere	X(15)		nrDocVencedor				Sim
	 * Numero Lote			5		Numerico	Z(4)9		nrLote						Sim
	 * Numero Item			5		Numerico	Z(4)9		nrItem						Sim
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_DTINIC, CN9.CN9_DTFIM, CN9.CN9_DTASSI, CN9.CN9_VLATU, CN9.CN9_XNMLIC, CN9.CN9_XDTLIC, CN9.CN9_XTMLIC, "
	 cQuery += " SA2.A2_TIPO, SA2.A2_CGC"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9, "
	 cQuery += RetSqlName("CNC") + " CNC,"
	 cQuery += RetSqlName("SA2") + " SA2"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CNC.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += " AND (CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += " OR CN9.CN9_TPCTO = '031')"	// Ata REgistro PReço	 	 
	 cQuery += " AND CN9.CN9_NUMERO >= '0000006000'"	 	 
	 cQuery += " AND CN9.CN9_NUMERO = CNC.CNC_NUMERO"
	 cQuery += " AND CN9.CN9_FILIAL = CNC.CNC_FILIAL"
	 cQuery += " AND CN9.CN9_REVISA = CNC.CNC_REVISA"
	 cQuery += " AND CN9.CN9_REVISA = '   '" // Só traz o que não for aditivo
	 cQuery += " AND CN9.CN9_DTASSI >= '" + cDtIniPer + "'"
	 cQuery += " AND CNC.CNC_CODIGO = SA2.A2_COD"
	 cQuery += " AND CNC.CNC_LOJA = SA2.A2_LOJA"
	 cQuery += " ORDER BY CN9.CN9_NUMERO"

	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++

		// Tipo de Documento
		If TRB->A2_TIPO == 'J'
			cTpDoc := '1' // CNPJ
		Else
			cTpDoc := '2' // CPF
		EndIf
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTASSI,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpDoc + "|"
		cLin += AllTrim(TRB->A2_CGC) + "|"
		cLin += cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->CN9_XNMLIC)) + "|"
		cLin += AllTrim(Substr(TRB->CN9_XDTLIC,1,4)) + "|"
		cLin += cValToChar(Val(TRB->CN9_XTMLIC)) + "|"
		cLin += cEntOrig + "|"
		cLin += cTpDoc + "|"
		cLin += AllTrim(TRB->A2_CGC) + "|"
		cLin += "1" + "|"
		cLin += "1" + "|"
		
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
! Programa 	! ContrAta  ! Autor !Gilson Lima 		 ! Data ! 09/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT Vinculando o intrumento contratual cuja	 !
! 			! origem diz respeito a uma ata de registro de preços cadastrada.!
+----------------------------------------------------------------------------*/
Static Function ContrAta(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
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
	 * Tabela ContratadoXAtaRegistroPreco
	 *
	 * Captar a vinculação do instrumento contratual com a respectiva licitação
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTASSI)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tipo Doc Contratada	2		Numérico	Z(1)9		idTipoDocContratada			Sim			
	 * Numero Doc Contratada15		Caractere	X(15)		nrDocContratada				Sim
	 * Identif PJ Respons	7		Numérico	Z(6)9		idPessoaAta					Sim
	 * Nr Ata				9		Numérico	Z(8)9		nrAtaRegistroPreco			Sim			CN9->CN9_
	 * Ano Ata				4		Numérico	Z(8)9		nrAnoAtaRegistroPreco		Sim			Ano(CN9->CN9_DTASSI)
	 * Identif. PJ Ger. Ata	7		Numérico	Z(6)9		idGerenciador				Sim			 
	 */	 
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_DTASSI, CN9.CN9_XCDINS, "
	 cQuery += " SA2.A2_TIPO, SA2.A2_CGC"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9, "
	 cQuery += RetSqlName("CNC") + " CNC,"
	 cQuery += RetSqlName("SA2") + " SA2"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CNC.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += " AND CN9.CN9_TPCTO = '031'"	// Ata Registro Preço	 
	 cQuery += " AND CN9.CN9_NUMERO >= '0000006000'"	 	 
	 cQuery += " AND CN9.CN9_NUMERO = CNC.CNC_NUMERO"
	 cQuery += " AND CN9.CN9_FILIAL = CNC.CNC_FILIAL"
	 cQuery += " AND CN9.CN9_REVISA = CNC.CNC_REVISA"
	 cQuery += " AND CN9.CN9_REVISA = '   '" // Só traz o que não for aditivo
	 cQuery += " AND CN9.CN9_DTASSI >= '" + cDtIniPer + "'"
	 cQuery += " AND CNC.CNC_CODIGO = SA2.A2_COD"
	 cQuery += " AND CNC.CNC_LOJA = SA2.A2_LOJA"
	 cQuery += " ORDER BY CN9.CN9_NUMERO"
	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++

		// Tipo de Documento
		If TRB->A2_TIPO == 'J'
			cTpDoc := '1' // CNPJ
		Else
			cTpDoc := '2' // CPF
		EndIf
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTASSI,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpDoc + "|"
		cLin += AllTrim(TRB->A2_CGC) + "|"
		cLin += cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->CN9_XCDINS)) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTASSI,1,4)) + "|"
		cLin += cEntOrig + "|"
		
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
! Programa 	! PublContr ! Autor !Gilson Lima 		 ! Data ! 29/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT com dados da publicação resumida, na 		 !
! 			! imprensa oficialdo Instr Contratual ou Ata REgistro Preço		 !
+----------------------------------------------------------------------------*/
Static Function PublContr(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
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
	 * Tabela PublicacaoInstrumentoContratual
	 *
	 * Captar dados da publicação resumida, na imprensa oficial, do Instrumento Contratual ou da Ata de Registro de Preços
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Nr Edicao no DOE		4		Numérico	9999		nrDiarioOficial				Sim			CN9_XEDOE
	 * Data Puclica DOE		10		Data		AAAA-MM-DD	dtPublicacaoInstrumentoContrSim			ValidaData(CN9_XPUBL)
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_DTINIC, CN9.CN9_XEDOE, CN9.CN9_XPUBL"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9 "
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += " AND (CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	
	 cQuery += " OR CN9.CN9_TPCTO = '031')" 
	 cQuery += " AND CN9.CN9_REVISA = '   '"
	 cQuery += " AND CN9.CN9_NUMERO >= '0000006000'"
	 cQuery += " ORDER BY CN9.CN9_NUMERO"

	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++

		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->CN9_XEDOE)) + "|"
		cLin += ValidaData(TRB->CN9_XPUBL) + "|"
		
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
! Programa 	! Apostilam ! Autor !Gilson Lima 		 ! Data ! 23/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Registrar os apostilamentos realizados no Instrumento			 !
! 			! contratual.													 !
+----------------------------------------------------------------------------*/
Static Function Apostilam(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela Apostilamento
	 *
	 * Registrar os apostilamentos realizados no Contrato
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num do Apostilamento 4		Numérico	Z(3)9		nrApostilamento				Sim			CN9->CN9_REVISA
	 * Num do Ano Apostilam 4		Numérico	9999		nrAnoApostilamento			Sim			Ano(CN9->CN9_DTREV)
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tipo Apostilamento	2	    Numérico	Z(1)9		idTipoApostilamento			Sim			CN0->CN0_XXTAP
	 * Data Apostilamento	10		Data		AAAA-MM-DD	dtApostilamento				Sim			CN9->CN9_DTREV
	 * Valor Apostilamento	16,2	Numérico	Z(13)9.99	vlApostilamento				Não			CN9->CN9_VLREAJ, CN9->CN9_VLADIT
	 * Nr CPF Responsavel	15		Caractere	X(15)		nrCPFResponsavel			Sim			SZI->ZI_NRDOC
	 * Descricao Motivo		250		Caractere	X(250)		dsMotivo					Não			CN9->CN9_CODJUS (SYP)
	 */
	 
	 cQuery := "SELECT CN9.CN9_REVISA, CN9.CN9_DTREV, CN9.CN9_TPCTO, CN9.CN9_NUMERO, CN9.CN9_CODJUS, CN9.CN9_VLREAJ,"
	 cQuery += " CN9.CN9_VLADIT, CN9.CN9_DTINIC, CN0.CN0_XXTAP, SZI.ZI_NRDOC"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9b"
	 cQuery += "    ON CN9b.CN9_NUMERO = CN9.CN9_NUMERO"
	 cQuery += "   AND CN9b.CN9_REVISA = '   '"
	 cQuery += "   AND CN9b.CN9_DTASSI >= '" + cDtIniPer + "'"
	 cQuery += "   AND CN9b.D_E_L_E_T_ <> '*'"
	 cQuery += " LEFT JOIN " + RetSqlName("SZI") + " SZI"
	 cQuery += "    ON SZI.ZI_CODIGO = CN9.CN9_XCDRES"
	 cQuery += " INNER JOIN "+ RetSqlName("CN0") + " CN0"
	 cQuery += "    ON CN0.CN0_CODIGO = CN9.CN9_TIPREV AND CN0.D_E_L_E_T_ <> '*' AND LTRIM(CN0.CN0_XXTAP) <> ''"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " 	AND CN9.CN9_REVISA <> '   '"
	 cQuery += " 	AND CN9.CN9_DTREV >= '" + DtoS(dDtIni) + "'"
	 cQuery += " 	AND CN9.CN9_DTREV <= '" + DtoS(dDtFim) + "'"
	 cQuery += "    AND CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'" 
	 cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Valor do Apostilamento
		cVlApostil := '0.00'
		
		// Descrição do Motivo
		cDsMotivo := AllTrim(Substr(MSMM(TRB->CN9_CODJUS),1,250))
				
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->CN9_REVISA)) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTREV,1,4)) + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->CN0_XXTAP)) + "|"
		cLin += ValidaData(TRB->CN9_DTREV) + "|"
		cLin += cVlApostil + "|"
		cLin += AllTrim(TRB->ZI_NRDOC) + "|"
		cLin += cDsMotivo + "|"
		
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
! Programa 	! NrAditivo ! Autor !Gilson Lima 		 ! Data ! 24/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Captar o número do termo aditivo do instrumento contratual	 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function NrAditivo(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela NumeroAditivoInstrumentoContratual
	 *
	 * Captar o número do termo aditivo do instrumento contratual
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num do Aditivo		9		Numérico	Z(8)9		nrAditivoInstrContr...		Sim			CN9->CN9_REVISA
	 * Num do Ano Aditivo	4		Numérico	9999		nrAnoAditivoInstrContr...	Sim			Ano(CN9->CN9_DTREV)
	 * Entidade Orig. Aditi.3		Numérico	Z(1)9		IdEntidadeOrigemAditivo		Sim			cEntOrig
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Origem Contr3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 */
	 
	 cQuery := "SELECT CN9.CN9_REVISA, CN9.CN9_DTREV, CN9.CN9_NUMERO, CN9.CN9_DTINIC"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9b"
	 cQuery += "    ON CN9b.CN9_NUMERO = CN9.CN9_NUMERO"
	 cQuery += "   AND CN9b.CN9_REVISA = '   '"	 
	 cQuery += "   AND CN9b.CN9_DTASSI >= '" + cDtIniPer + "'"
	 cQuery += "   AND CN9b.D_E_L_E_T_ <> '*'"
	 cQuery += " INNER JOIN "+ RetSqlName("CN0") + " CN0"
	 cQuery += "    ON CN0.CN0_CODIGO = CN9.CN9_TIPREV AND CN0.D_E_L_E_T_ <> '*' AND LTRIM(CN0.CN0_XXTAP) = ''"
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " 	AND CN9.CN9_REVISA <> '   '"
	 cQuery += " 	AND CN9.CN9_DTREV >= '" + DtoS(dDtIni) + "'"
	 cQuery += " 	AND CN9.CN9_DTREV <= '" + DtoS(dDtFim) + "'"
	 cQuery += "    AND CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'"
	 cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->CN9_REVISA)) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTREV,1,4)) + "|"
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		
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
! Programa 	! Aditivo   ! Autor !Gilson Lima 		 ! Data ! 24/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Captar dados básicos dos Termos Aditivos						 !
! 			!  																 !
+----------------------------------------------------------------------------*/
Static Function Aditivo(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela AditivoInstrumentoContratual
	 *
	 * Captar dados básicos dos Termos Aditivos
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num do Aditivo		9		Numérico	Z(8)9		nrAditivoInstrContr...		Sim			CN9->CN9_REVISA
	 * Num do Ano Aditivo	4		Numérico	9999		nrAnoAditivoInstrContr...	Sim			Ano(CN9->CN9_DTREV)
	 * Entidade Orig. Aditi.3		Numérico	Z(1)9		IdEntidadeOrigemAditivo		Sim			cEntOrig
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Origem Contr3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tp Doc Contratada	2		Numérico	Z(1)9		idTipoDocContratada			Sim			
	 * Nr Doc Contratada	15		Caractere	X(15)		nrDocContratada				Sim
	 * Tipo Aditivo			2		Numérico	Z(1)9		idTipoAditivoInstrContr...	Sim
	 * Tipo de Operacao		2		Numérico	Z(1)9		idTipoOperacaoAditivoInstr..Sim
	 * Tp Assinante Aditivo 2		Numérico	Z(1)9		idTipoAssinante				Sim
	 * Nr CPF Assinante		15		Caractere	X(15)		nrCPFAssinante				Sim
	 * Data Aditivo			10		Data		AAAA-MM-DD	dtAditivoInstrumentoContr...Sim
	 * Nr CPF Gestor Aditiv 15		Caractere	X(15)		nrCPFGestor					Sim
	 */
 
	cQuery := "SELECT DISTINCT CN9.CN9_NUMERO AS NRCONTRATO, CN9.CN9_REVISA AS NRREVISAO,CN9.CN9_DTASSI AS DTASSINATURA, CN9.CN9_DTINIC AS DTINICONTRATO, CN9.CN9_DTREV AS DTREVISAO"
	cQuery += "     ,CN0.CN0_XXTAD AS IDTIPOADITIVO, CN0.CN0_XXOPA AS IDTIPOOPERACAO"
	cQuery += "     ,SA2.A2_TIPO AS TIPOCONTRATADA, SA2.A2_CGC AS DOCCONTRATADA"
	cQuery += "     ,SZI1.ZI_NRDOC AS CPFGESTOR"
	cQuery += "     ,CNC.CNC_XTASS AS TIPOASSINANTE"
	cQuery += "     ,SZI2.ZI_NRDOC AS DOCASSINANTE"
	cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9b"
	 cQuery += "    ON CN9b.CN9_NUMERO = CN9.CN9_NUMERO"
	 cQuery += "   AND CN9b.CN9_REVISA = '   '"	 
	 cQuery += "   AND CN9b.CN9_DTASSI >= '" + cDtIniPer + "'"
	 cQuery += "   AND CN9b.D_E_L_E_T_ <> '*'"
	cQuery += " LEFT JOIN " + RetSqlName("CNC") + " CNC"
	cQuery += "      ON CNC.CNC_FILIAL = CN9.CN9_FILIAL"
	cQuery += "     AND CNC.CNC_NUMERO = CN9.CN9_NUMERO"
	cQuery += "     AND CNC.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2"
	cQuery += "      ON SA2.A2_COD = CNC.CNC_CODIGO"
	cQuery += "     AND SA2.A2_LOJA = CNC.CNC_LOJA"
	cQuery += "     AND SA2.D_E_L_E_T_ <> '*'"
	cQuery += " LEFT JOIN " + RetSqlName("SZI") + " SZI1"
	cQuery += "      ON SZI1.ZI_CODIGO = CN9.CN9_XCDRES"
	cQuery += "     AND SZI1.D_E_L_E_T_ <> '*'"
	cQuery += " LEFT JOIN " + RetSqlName("SZI") + " SZI2"
	cQuery += "      ON SZI2.ZI_CODIGO = CNC.CNC_XCDASS"
	cQuery += "     AND SZI2.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN " + RetSqlName("CN0") + " CN0"
	cQuery += "      ON CN0.CN0_CODIGO = CN9.CN9_TIPREV"
	cQuery += "     AND CN0.D_E_L_E_T_ <> '*'"
	cQuery += "     AND LTRIM(CN0.CN0_XXTAP) = ''"
	cQuery += " WHERE CN9.CN9_REVISA <> '   '"
	cQuery += " AND CN9.D_E_L_E_T_ <> '*'"
	cQuery += " AND CN9.CN9_DTREV >= '" + DtoS(dDtIni) + "'"
	cQuery += " AND CN9.CN9_DTREV <= '" + DtoS(dDtFim) + "'"
	cQuery += "    AND CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc
	cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'"
	cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Tipo de Documento da Contratada
		cTpDocCtr := IIF(AllTrim(TRB->TIPOCONTRATADA) == 'J', '1','2' ) // 1 = CNPJ, 2 = CPF
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->NRREVISAO)) + "|"
		cLin += AllTrim(Substr(TRB->DTREVISAO,1,4)) + "|"
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->NRCONTRATO)) + "|"
		cLin += AllTrim(Substr(TRB->DTINICONTRATO,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpDocCtr + "|"
		cLin += AllTrim(Substr(TRB->DOCCONTRATADA,1,15)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOADITIVO)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOOPERACAO)) + "|"
		cLin += cValToChar(Val(TRB->TIPOASSINANTE)) + "|"
		cLin += AllTrim(Substr(TRB->DOCASSINANTE,1,15)) + "|"
		cLin += ValidaData(TRB->DTREVISAO) + "|"
		cLin += AllTrim(Substr(TRB->CPFGESTOR,1,15)) + "|"
		
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
! Programa 	! AdtValor  ! Autor !Gilson Lima 		 ! Data ! 24/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Captar o conteúdo do termo aditivo do instrumento contratual	 !
! 			! quando o valor for alterado									 !
+----------------------------------------------------------------------------*/
Static Function AdtValor(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela AditivoValorInstrumentoContratual
	 *
	 * Captar o conteúdo do termo aditivo do instrumento contratual quando o valor for alterado
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num do Aditivo		9		Numérico	Z(8)9		nrAditivoInstrContr...		Sim			CN9->CN9_REVISA
	 * Num do Ano Aditivo	4		Numérico	9999		nrAnoAditivoInstrContr...	Sim			Ano(CN9->CN9_DTREV)
	 * Entidade Orig. Aditi.3		Numérico	Z(1)9		IdEntidadeOrigemAditivo		Sim			cEntOrig
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Origem Contr3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tp Doc Contratada	2		Numérico	Z(1)9		idTipoDocContratada			Sim			
	 * Nr Doc Contratada	15		Caractere	X(15)		nrDocContratada				Sim
	 * Tipo Aditivo			2		Numérico	Z(1)9		idTipoAditivoInstrContr...	Sim
	 * Tipo de Operacao		2		Numérico	Z(1)9		idTipoOperacaoAditivoInstr..Sim
	 * Valor do Aditivo		16,2	Numérico	Z(13)9.99	vlAditivo					Sim
	 * Valor Atual Contrato	16,2	Numérico	Z(13)9.99	vlAtualizadoInstrumContr... Sim
	 */
 
	cQuery := "SELECT DISTINCT CN9.CN9_NUMERO AS NRCONTRATO, CN9.CN9_REVISA AS NRREVISAO, CN9.CN9_DTINIC AS DTINICONTRATO, CN9.CN9_DTREV AS DTREVISAO, CN9.CN9_VLATU AS VLATUAL, CN9.CN9_FILIAL AS FILIALCTR"
	cQuery += "     ,CN0.CN0_XXTAD AS IDTIPOADITIVO, CN0.CN0_XXOPA AS IDTIPOOPERACAO"
	cQuery += "     ,SA2.A2_TIPO AS TIPOCONTRATADA, SA2.A2_CGC AS DOCCONTRATADA"
	cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9b"
	 cQuery += "    ON CN9b.CN9_NUMERO = CN9.CN9_NUMERO"
	 cQuery += "   AND CN9b.CN9_DTASSI >= '" + cDtIniPer + "'"
	 cQuery += "   AND CN9b.CN9_REVISA = '   '"	 
	 cQuery += "   AND CN9b.D_E_L_E_T_ <> '*'"
	cQuery += " LEFT JOIN " + RetSqlName("CNC") + " CNC"
	cQuery += "      ON CNC.CNC_FILIAL = CN9.CN9_FILIAL"
	cQuery += "     AND CNC.CNC_NUMERO = CN9.CN9_NUMERO"
	cQuery += "     AND CNC.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2"
	cQuery += "      ON SA2.A2_COD = CNC.CNC_CODIGO"
	cQuery += "     AND SA2.A2_LOJA = CNC.CNC_LOJA"
	cQuery += "     AND SA2.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN " + RetSqlName("CN0") + " CN0"
	cQuery += "      ON CN0.CN0_CODIGO = CN9.CN9_TIPREV"
	cQuery += "     AND CN0.D_E_L_E_T_ <> '*'"
	cQuery += "     AND LTRIM(CN0.CN0_XXTAP) = ''"
	cQuery += "	    AND CN0.CN0_XXTAD = '04'	
	cQuery += " WHERE CN9.CN9_REVISA <> '   '"
	cQuery += " AND CN9.D_E_L_E_T_ <> '*'"
	cQuery += " AND CN9.CN9_DTREV >= '" + DtoS(dDtIni) + "'"
	cQuery += " AND CN9.CN9_DTREV <= '" + DtoS(dDtFim) + "'"
	 cQuery += "    AND CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'" 	
	cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Tipo de Documento da Contratada
		cTpDocCtr := IIF(AllTrim(TRB->TIPOCONTRATADA) == 'J', '1','2' ) // 1 = CNPJ, 2 = CPF
		
		// Nr. Revisão Anterior
		If TRB->NRREVISAO == '001'
			cNrRevAnt := '   '
		Else
			cNrRevAnt := StrZero(Val(TRB->NRREVISAO)-1,3)
		EndIf
		
		// Valor do Aditivo
		nVlAnter   := POSICIONE("CN9",1,TRB->FILIALCTR+TRB->NRCONTRATO+cNrRevAnt,"CN9_VLATU")
		nVlAditivo := TRB->VLATUAL - nVlAnter
		cVlAditivo := StrTran(LTrim(Transform(nVlAditivo, "@E 999999999999.99")),",",".")
		
		// Valor Atual
		cVlAtual   := StrTran(LTrim(Transform(TRB->VLATUAL, "@E 999999999999.99")),",",".")
		
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->NRREVISAO)) + "|"
		cLin += AllTrim(Substr(TRB->DTREVISAO,1,4)) + "|"
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->NRCONTRATO)) + "|"
		cLin += AllTrim(Substr(TRB->DTINICONTRATO,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpDocCtr + "|"
		cLin += AllTrim(Substr(TRB->DOCCONTRATADA,1,15)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOADITIVO)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOOPERACAO)) + "|"
		cLin += cVlAditivo + "|"
		cLin += cVlAtual + "|"
		
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
! Programa 	! AdtData  ! Autor !Gilson Lima 		 ! Data ! 24/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Captar o conteúdo do termo aditivo do instrumento contratual	 !
! 			! quando houver a alteração dos prazos contratuais				 !
+----------------------------------------------------------------------------*/
Static Function AdtData(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela AditivoPrazoInstrumentoContratual
	 *
	 * Captar o conteúdo do termo aditivo do instrumento contratual quando houver a alteração dos prazos contratuais	
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num do Aditivo		9		Numérico	Z(8)9		nrAditivoInstrContr...		Sim			CN9->CN9_REVISA
	 * Num do Ano Aditivo	4		Numérico	9999		nrAnoAditivoInstrContr...	Sim			Ano(CN9->CN9_DTREV)
	 * Entidade Orig. Aditi.3		Numérico	Z(1)9		IdEntidadeOrigemAditivo		Sim			cEntOrig
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Origem Contr3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tp Doc Contratada	2		Numérico	Z(1)9		idTipoDocContratada			Sim			
	 * Nr Doc Contratada	15		Caractere	X(15)		nrDocContratada				Sim
	 * Tipo Aditivo			2		Numérico	Z(1)9		idTipoAditivoInstrContr...	Sim
	 * Tipo de Operacao		2		Numérico	Z(1)9		idTipoOperacaoAditivoInstr..Sim
	 * Nova Data do Fim Vig 10		Data		AAAA-MM-DD	dtFim						Sim
	 * Descrição do Motivo	250		Caractere	X(250)		dsMotivo					Sim
	 */
 
	cQuery := "SELECT DISTINCT CN9.CN9_NUMERO AS NRCONTRATO, CN9.CN9_REVISA AS NRREVISAO, CN9.CN9_DTINIC AS DTINICONTRATO, CN9.CN9_DTREV AS DTREVISAO, CN9.CN9_DTFIM AS DTFIM, CN9.CN9_CODJUS"
	cQuery += "     ,CN0.CN0_XXTAD AS IDTIPOADITIVO, CN0.CN0_XXOPA AS IDTIPOOPERACAO"
	cQuery += "     ,SA2.A2_TIPO AS TIPOCONTRATADA, SA2.A2_CGC AS DOCCONTRATADA"
	cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9b"
	 cQuery += "    ON CN9b.CN9_NUMERO = CN9.CN9_NUMERO"
	 cQuery += "   AND CN9b.CN9_REVISA = '   '"	 
	 cQuery += "   AND CN9b.CN9_DTASSI >= '" + cDtIniPer + "'"
	 cQuery += "   AND CN9b.D_E_L_E_T_ <> '*'"
	cQuery += " LEFT JOIN " + RetSqlName("CNC") + " CNC"
	cQuery += "      ON CNC.CNC_FILIAL = CN9.CN9_FILIAL"
	cQuery += "     AND CNC.CNC_NUMERO = CN9.CN9_NUMERO"
	cQuery += "     AND CNC.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2"
	cQuery += "      ON SA2.A2_COD = CNC.CNC_CODIGO"
	cQuery += "     AND SA2.A2_LOJA = CNC.CNC_LOJA"
	cQuery += "     AND SA2.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN " + RetSqlName("CN0") + " CN0"
	cQuery += "      ON CN0.CN0_CODIGO = CN9.CN9_TIPREV"
	cQuery += "     AND CN0.D_E_L_E_T_ <> '*'"
	cQuery += "     AND LTRIM(CN0.CN0_XXTAP) = ''"
	cQuery += "	    AND CN0.CN0_XXTAD = '01'	
	cQuery += " WHERE CN9.CN9_REVISA <> '   '"
	cQuery += " AND CN9.D_E_L_E_T_ <> '*'"
	cQuery += " AND CN9.CN9_DTREV >= '" + DtoS(dDtIni) + "'"
	cQuery += " AND CN9.CN9_DTREV <= '" + DtoS(dDtFim) + "'"
	 cQuery += "    AND CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'" 	
	cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Tipo de Documento da Contratada
		cTpDocCtr := IIF(AllTrim(TRB->TIPOCONTRATADA) == 'J', '1','2' ) // 1 = CNPJ, 2 = CPF
		
		// Justificativa
		cDsMotivo := AllTrim(Substr(MSMM(TRB->CN9_CODJUS),1,250))
				
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->NRREVISAO)) + "|"
		cLin += AllTrim(Substr(TRB->DTREVISAO,1,4)) + "|"
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->NRCONTRATO)) + "|"
		cLin += AllTrim(Substr(TRB->DTINICONTRATO,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpDocCtr + "|"
		cLin += AllTrim(Substr(TRB->DOCCONTRATADA,1,15)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOADITIVO)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOOPERACAO)) + "|"
		cLin += ValidaData(TRB->DTFIM) + "|"
		cLin += cDsMotivo + "|"
		
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
! Programa 	! AdtCessao ! Autor !Gilson Lima 		 ! Data ! 01/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Captar o conteúdo do termo aditivo do instrumento contratual	 !
! 			! quando ocorrer a cessão do intrumento contratual				 !
+----------------------------------------------------------------------------*/
Static Function AdtCessao(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela AditivoCessaoInstrumentoContratual
	 *
	 * Captar o conteúdo do termo aditivo do instrumento contratual quando ocorrer a cessão do instrumento contratual.	
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num do Aditivo		9		Numérico	Z(8)9		nrAditivoInstrContr...		Sim			CN9->CN9_REVISA
	 * Num do Ano Aditivo	4		Numérico	9999		nrAnoAditivoInstrContr...	Sim			Ano(CN9->CN9_DTREV)
	 * Entidade Orig. Aditi.3		Numérico	Z(1)9		IdEntidadeOrigemAditivo		Sim			cEntOrig
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Origem Contr3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tp Doc Contratada	2		Numérico	Z(1)9		idTipoDocContratada			Sim			Contrato s/ Revisão
	 * Nr Doc Contratada	15		Caractere	X(15)		nrDocContratada				Sim
	 * Tipo Aditivo			2		Numérico	Z(1)9		idTipoAditivoInstrContr...	Sim
	 * Tipo de Operacao		2		Numérico	Z(1)9		idTipoOperacaoAditivoInstr..Sim
	 * Tipo Doc Cessionaria 2		Numérico	Z(1)9		idTipoDocCessionaria		Sim
	 * Nr Doc Cessionaria	15		Caractere	X(15)		nrDocCessionaria			Sim
	 * Nr do CPF Repr Cess	15		Caractere	X(15)		nrCPFRepresentanteCessionar	Sim
	 */
 
	cQuery := "SELECT DISTINCT CN9.CN9_NUMERO AS NRCONTRATO, CN9.CN9_REVISA AS NRREVISAO, CN9.CN9_DTINIC AS DTINICONTRATO, CN9.CN9_DTREV AS DTREVISAO, CN9.CN9_DTFIM AS DTFIM, CN9.CN9_CODJUS"
	cQuery += "     ,CN0.CN0_XXTAD AS IDTIPOADITIVO, CN0.CN0_XXOPA AS IDTIPOOPERACAO"
	cQuery += "     ,SA2.A2_TIPO AS TIPOCONTRATADA, SA2.A2_CGC AS DOCCONTRATADA"
	cQuery += "     ,SA2B.A2_TIPO AS TIPOCONTRORIG, SA2B.A2_CGC AS DOCCONTRORIG"
	cQuery += "		,SZI.ZI_NRDOC"
	cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	cQuery += " LEFT JOIN " + RetSqlName("CN9") + " CN9B"
	cQuery += "      ON CN9B.CN9_FILIAL = CN9.CN9_FILIAL"
	cQuery += "     AND CN9B.CN9_NUMERO = CN9.CN9_NUMERO"
	 cQuery += "   AND CN9B.CN9_REVISA = '   '"	
	cQuery += "     AND CN9B.CN9_DTASSI >= '" + cDtIniPer + "'"		
	cQuery += "     AND CN9B.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("CNC") + " CNC"
	cQuery += "      ON CNC.CNC_FILIAL = CN9.CN9_FILIAL"
	cQuery += "     AND CNC.CNC_NUMERO = CN9.CN9_NUMERO"
	cQuery += "     AND CNC.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2"
	cQuery += "      ON SA2.A2_COD = CNC.CNC_CODIGO"
	cQuery += "     AND SA2.A2_LOJA = CNC.CNC_LOJA"
	cQuery += "     AND SA2.D_E_L_E_T_ <> '*'"
	cQuery += " LEFT JOIN " + RetSqlName("CNC") + " CNCB"
	cQuery += "      ON CNCB.CNC_FILIAL = CN9B.CN9_FILIAL"
	cQuery += "     AND CNCB.CNC_NUMERO = CN9B.CN9_NUMERO"
	cQuery += "     AND CNCB.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2B"
	cQuery += "      ON SA2B.A2_COD = CNCB.CNC_CODIGO"
	cQuery += "     AND SA2B.A2_LOJA = CNCB.CNC_LOJA"
	cQuery += "     AND SA2B.D_E_L_E_T_ <> '*'"
	cQuery += " LEFT JOIN " + RetSqlName("SZI") + " SZI"
	cQuery += "      ON SZI.ZI_CODIGO = CNCB.CNC_XCDASS"
	cQuery += " 	AND SZI.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN " + RetSqlName("CN0") + " CN0"
	cQuery += "      ON CN0.CN0_CODIGO = CN9.CN9_TIPREV"
	cQuery += "     AND CN0.D_E_L_E_T_ <> '*'"
	cQuery += "     AND LTRIM(CN0.CN0_XXTAP) = ''"
	cQuery += "	    AND CN0.CN0_XXTAD = '02'"	// Cessao Contratual	
	cQuery += " WHERE CN9.CN9_REVISA <> '   '"
	cQuery += " AND CN9.D_E_L_E_T_ <> '*'"
	cQuery += " AND CN9.CN9_DTREV >= '" + DtoS(dDtIni) + "'"
	cQuery += " AND CN9.CN9_DTREV <= '" + DtoS(dDtFim) + "'"
	 cQuery += "    AND CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'" 	
	cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Tipo de Documento da Contratada
		cTpDocCtr := IIF(AllTrim(TRB->TIPOCONTRATADA) == 'J', '1','2' ) // 1 = CNPJ, 2 = CPF

		// Tipo de Documento da Cessionaria
		cTpDocCess := IIF(AllTrim(TRB->TIPOCONTRORIG) == 'J', '1','2' ) // 1 = CNPJ, 2 = CPF
		
		// Justificativa
		cDsMotivo := AllTrim(Substr(MSMM(TRB->CN9_CODJUS),1,250))
				
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->NRREVISAO)) + "|"
		cLin += AllTrim(Substr(TRB->DTREVISAO,1,4)) + "|"
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->NRCONTRATO)) + "|"
		cLin += AllTrim(Substr(TRB->DTINICONTRATO,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpDocCess + "|"
		cLin += AllTrim(Substr(TRB->DOCCONTRORIG,1,15)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOADITIVO)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOOPERACAO)) + "|"
		cLin += cTpDocCtr + "|"
		cLin += AllTrim(Substr(TRB->DOCCONTRATADA,1,15)) + "|"
		cLin += AllTrim(Substr(TRB->ZI_NRDOC,1,15)) + "|"
		
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
! Programa 	! AdtSubC   ! Autor !Gilson Lima 		 ! Data ! 01/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Captar o conteúdo do termo aditivo do instrumento contratual	 !
! 			! quando ocorrer a subcontratacao do intrumento contratual		 !
+----------------------------------------------------------------------------*/
Static Function AdtSubC(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela AditivoSubcontratacaoInstrumentoContratual
	 *
	 * Captar o conteúdo do termo aditivo do instrumento contratual quando ocorrer a cessão do instrumento contratual.	
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num do Aditivo		9		Numérico	Z(8)9		nrAditivoInstrContr...		Sim			CN9->CN9_REVISA
	 * Num do Ano Aditivo	4		Numérico	9999		nrAnoAditivoInstrContr...	Sim			Ano(CN9->CN9_DTREV)
	 * Entidade Orig. Aditi.3		Numérico	Z(1)9		IdEntidadeOrigemAditivo		Sim			cEntOrig
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Origem Contr3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tp Doc Contratada	2		Numérico	Z(1)9		idTipoDocContratada			Sim			Contrato s/ Revisão
	 * Nr Doc Contratada	15		Caractere	X(15)		nrDocContratada				Sim
	 * Tipo Aditivo			2		Numérico	Z(1)9		idTipoAditivoInstrContr...	Sim
	 * Tipo de Operacao		2		Numérico	Z(1)9		idTipoOperacaoAditivoInstr..Sim
	 * Tipo Doc Cessionaria 2		Numérico	Z(1)9		idTipoDocCessionaria		Sim
	 * Nr Doc Cessionaria	15		Caractere	X(15)		nrDocCessionaria			Sim
	 * Nr do CPF Repr Cess	15		Caractere	X(15)		nrCPFRepresentanteCessionar	Sim
	 */
 
	cQuery := "SELECT DISTINCT CN9.CN9_NUMERO AS NRCONTRATO, CN9.CN9_REVISA AS NRREVISAO, CN9.CN9_DTINIC AS DTINICONTRATO, CN9.CN9_DTREV AS DTREVISAO, CN9.CN9_DTFIM AS DTFIM, CN9.CN9_CODJUS"
	cQuery += "     ,CN0.CN0_XXTAD AS IDTIPOADITIVO, CN0.CN0_XXOPA AS IDTIPOOPERACAO"
	cQuery += "     ,SA2.A2_TIPO AS TIPOCONTRATADA, SA2.A2_CGC AS DOCCONTRATADA"
	cQuery += "     ,SA2B.A2_TIPO AS TIPOCONTRORIG, SA2B.A2_CGC AS DOCCONTRORIG"
	cQuery += "		,SZI.ZI_NRDOC"
	cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	
	cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9B"
	cQuery += "      ON CN9B.CN9_FILIAL = CN9.CN9_FILIAL"
	cQuery += "     AND CN9B.CN9_NUMERO = CN9.CN9_NUMERO"
	 cQuery += "   AND CN9B.CN9_REVISA = '   '"	
	cQuery += "     AND CN9B.CN9_DTASSI >= '" + cDtIniPer + "'"	
	cQuery += "     AND CN9B.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("CNC") + " CNC"
	cQuery += "      ON CNC.CNC_FILIAL = CN9.CN9_FILIAL"
	cQuery += "     AND CNC.CNC_NUMERO = CN9.CN9_NUMERO"
	cQuery += "     AND CNC.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2"
	cQuery += "      ON SA2.A2_COD = CNC.CNC_CODIGO"
	cQuery += "     AND SA2.A2_LOJA = CNC.CNC_LOJA"
	cQuery += "     AND SA2.D_E_L_E_T_ <> '*'"
	cQuery += " LEFT JOIN " + RetSqlName("CNC") + " CNCB"
	cQuery += "      ON CNCB.CNC_FILIAL = CN9B.CN9_FILIAL"
	cQuery += "     AND CNCB.CNC_NUMERO = CN9B.CN9_NUMERO"
	cQuery += "     AND CNCB.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2B"
	cQuery += "      ON SA2B.A2_COD = CNCB.CNC_CODIGO"
	cQuery += "     AND SA2B.A2_LOJA = CNCB.CNC_LOJA"
	cQuery += "     AND SA2B.D_E_L_E_T_ <> '*'"
	cQuery += " LEFT JOIN " + RetSqlName("SZI") + " SZI"
	cQuery += "      ON SZI.ZI_CODIGO = CNCB.CNC_XCDASS"
	cQuery += " 	AND SZI.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN " + RetSqlName("CN0") + " CN0"
	cQuery += "      ON CN0.CN0_CODIGO = CN9.CN9_TIPREV"
	cQuery += "     AND CN0.D_E_L_E_T_ <> '*'"
	cQuery += "     AND LTRIM(CN0.CN0_XXTAP) = ''"
	cQuery += "	    AND CN0.CN0_XXTAD = '03'"	// Subcontratação	
	cQuery += " WHERE CN9.CN9_REVISA <> '   '"
	cQuery += " AND CN9.D_E_L_E_T_ <> '*'"
	cQuery += " AND CN9.CN9_DTREV >= '" + DtoS(dDtIni) + "'"
	cQuery += " AND CN9.CN9_DTREV <= '" + DtoS(dDtFim) + "'"
	 cQuery += "    AND CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'"	
	cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Tipo de Documento da Contratada
		cTpDocCtr := IIF(AllTrim(TRB->TIPOCONTRATADA) == 'J', '1','2' ) // 1 = CNPJ, 2 = CPF

		// Tipo de Documento da Cessionaria
		cTpDocCess := IIF(AllTrim(TRB->TIPOCONTRORIG) == 'J', '1','2' ) // 1 = CNPJ, 2 = CPF
		
		// Justificativa
		cDsMotivo := AllTrim(Substr(MSMM(TRB->CN9_CODJUS),1,250))
				
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->NRREVISAO)) + "|"
		cLin += AllTrim(Substr(TRB->DTREVISAO,1,4)) + "|"
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->NRCONTRATO)) + "|"
		cLin += AllTrim(Substr(TRB->DTINICONTRATO,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpDocCess + "|"
		cLin += AllTrim(Substr(TRB->DOCCONTRORIG,1,15)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOADITIVO)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOOPERACAO)) + "|"
		cLin += cTpDocCtr + "|"
		cLin += AllTrim(Substr(TRB->DOCCONTRATADA,1,15)) + "|"
		cLin += AllTrim(Substr(TRB->ZI_NRDOC,1,15)) + "|"
		
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
! Programa 	! AdtResc   ! Autor !Gilson Lima 		 ! Data ! 24/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Captar dados do termo aditivo do instrumento contratual, 		 !
! 			! quando ocorrer inexecução e/ou rescisão contratual			 !
+----------------------------------------------------------------------------*/
Static Function AdtResc(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela AditivoRescisaoInstrumentoContratual
	 *
	 * Captar dados do termo aditivo do instrumento contratual,	quando ocorrer inexecução e/ou rescisão contratual
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num do Aditivo		9		Numérico	Z(8)9		nrAditivoInstrContr...		Sim			CN9->CN9_REVISA
	 * Num do Ano Aditivo	4		Numérico	9999		nrAnoAditivoInstrContr...	Sim			Ano(CN9->CN9_DTREV)
	 * Entidade Orig. Aditi.3		Numérico	Z(1)9		IdEntidadeOrigemAditivo		Sim			cEntOrig
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Origem Contr3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tp Doc Contratada	2		Numérico	Z(1)9		idTipoDocContratada			Sim			
	 * Nr Doc Contratada	15		Caractere	X(15)		nrDocContratada				Sim
	 * Tipo Aditivo			2		Numérico	Z(1)9		idTipoAditivoInstrContr...	Sim
	 * Tipo de Operacao		2		Numérico	Z(1)9		idTipoOperacaoAditivoInstr..Sim
	 * Motivo Rescisao		2		Numérico	Z(1)9		idTipoMotivoRescisaoInstr...Sim
	 * Descrição do Motivo	250		Caractere	X(250)		dsMotivo					Não
	 */
 
	cQuery := "SELECT DISTINCT CN9.CN9_NUMERO AS NRCONTRATO, CN9.CN9_REVISA AS NRREVISAO, CN9.CN9_DTINIC AS DTINICONTRATO, CN9.CN9_DTREV AS DTREVISAO, CN9.CN9_DTFIM AS DTFIM, CN9.CN9_CODJUS, CN9.CN9_MOTPAR AS MOTPARALISA"
	cQuery += "     ,CN0.CN0_XXTAD AS IDTIPOADITIVO, CN0.CN0_XXOPA AS IDTIPOOPERACAO"
	cQuery += "     ,SA2.A2_TIPO AS TIPOCONTRATADA, SA2.A2_CGC AS DOCCONTRATADA"
	cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9b"
	 cQuery += "    ON CN9b.CN9_NUMERO = CN9.CN9_NUMERO"
	 cQuery += "   AND CN9b.CN9_REVISA = '   '"	 
	 cQuery += "   AND CN9b.CN9_DTASSI >= '" + cDtIniPer + "'"
	 cQuery += "   AND CN9b.D_E_L_E_T_ <> '*'"
	cQuery += " LEFT JOIN " + RetSqlName("CNC") + " CNC"
	cQuery += "      ON CNC.CNC_FILIAL = CN9.CN9_FILIAL"
	cQuery += "     AND CNC.CNC_NUMERO = CN9.CN9_NUMERO"
	cQuery += "     AND CNC.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2"
	cQuery += "      ON SA2.A2_COD = CNC.CNC_CODIGO"
	cQuery += "     AND SA2.A2_LOJA = CNC.CNC_LOJA"
	cQuery += "     AND SA2.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN " + RetSqlName("CN0") + " CN0"
	cQuery += "      ON CN0.CN0_CODIGO = CN9.CN9_TIPREV"
	cQuery += "     AND CN0.D_E_L_E_T_ <> '*'"
	cQuery += "     AND LTRIM(CN0.CN0_XXTAP) = ''"
	cQuery += "	    AND CN0.CN0_XXTAD = '05'	
	cQuery += " WHERE CN9.CN9_REVISA <> '   '"
	cQuery += " AND CN9.D_E_L_E_T_ <> '*'"
	cQuery += " AND CN9.CN9_DTREV >= '" + DtoS(dDtIni) + "'"
	cQuery += " AND CN9.CN9_DTREV <= '" + DtoS(dDtFim) + "'"
	 cQuery += "    AND CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'" 	
	cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Tipo de Documento da Contratada
		cTpDocCtr := IIF(AllTrim(TRB->TIPOCONTRATADA) == 'J', '1','2' ) // 1 = CNPJ, 2 = CPF
		
		// Justificativa
		cDsMotivo := AllTrim(Substr(MSMM(TRB->CN9_CODJUS),1,250))
				
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->NRREVISAO)) + "|"
		cLin += AllTrim(Substr(TRB->DTREVISAO,1,4)) + "|"
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->NRCONTRATO)) + "|"
		cLin += AllTrim(Substr(TRB->DTINICONTRATO,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpDocCtr + "|"
		cLin += AllTrim(Substr(TRB->DOCCONTRATADA,1,15)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOADITIVO)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOOPERACAO)) + "|"
		cLin += cValToChar(Val(TRB->MOTPARALISA)) + "|"
		cLin += cDsMotivo + "|"
		
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
! Programa 	! AdtOutros ! Autor !Gilson Lima 		 ! Data ! 27/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Captar dados de outros tipos de termo aditivo do instrumento	 !
! 			! instrumento contratual										 !
+----------------------------------------------------------------------------*/
Static Function AdtOutros(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
	Local cTpDoc := ''
	
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
	 * Tabela AditivoRescisaoInstrumentoContratual
	 *
	 * Captar dados do termo aditivo do instrumento contratual,	quando ocorrer inexecução e/ou rescisão contratual
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num do Aditivo		9		Numérico	Z(8)9		nrAditivoInstrContr...		Sim			CN9->CN9_REVISA
	 * Num do Ano Aditivo	4		Numérico	9999		nrAnoAditivoInstrContr...	Sim			Ano(CN9->CN9_DTREV)
	 * Entidade Orig. Aditi.3		Numérico	Z(1)9		IdEntidadeOrigemAditivo		Sim			cEntOrig
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Origem Contr3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Tp Doc Contratada	2		Numérico	Z(1)9		idTipoDocContratada			Sim			
	 * Nr Doc Contratada	15		Caractere	X(15)		nrDocContratada				Sim
	 * Tipo Aditivo			2		Numérico	Z(1)9		idTipoAditivoInstrContr...	Sim
	 * Tipo de Operacao		2		Numérico	Z(1)9		idTipoOperacaoAditivoInstr..Sim
	 * Descrição do Motivo	250		Caractere	X(250)		dsMotivo					Não
	 */
 
	cQuery := "SELECT DISTINCT CN9.CN9_NUMERO AS NRCONTRATO, CN9.CN9_REVISA AS NRREVISAO, CN9.CN9_DTINIC AS DTINICONTRATO, CN9.CN9_DTREV AS DTREVISAO, CN9.CN9_DTFIM AS DTFIM, CN9.CN9_CODJUS"
	cQuery += "     ,CN0.CN0_XXTAD AS IDTIPOADITIVO, CN0.CN0_XXOPA AS IDTIPOOPERACAO"
	cQuery += "     ,SA2.A2_TIPO AS TIPOCONTRATADA, SA2.A2_CGC AS DOCCONTRATADA"
	cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	 cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9b"
	 cQuery += "    ON CN9b.CN9_NUMERO = CN9.CN9_NUMERO"
	 cQuery += "   AND CN9b.CN9_REVISA = '   '"	 
	 cQuery += "   AND CN9b.CN9_DTASSI >= '" + cDtIniPer + "'"
	 cQuery += "   AND CN9b.D_E_L_E_T_ <> '*'"
	cQuery += " LEFT JOIN " + RetSqlName("CNC") + " CNC"
	cQuery += "      ON CNC.CNC_FILIAL = CN9.CN9_FILIAL"
	cQuery += "     AND CNC.CNC_NUMERO = CN9.CN9_NUMERO"
	cQuery += "     AND CNC.D_E_L_E_T_ <>'*'"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2"
	cQuery += "      ON SA2.A2_COD = CNC.CNC_CODIGO"
	cQuery += "     AND SA2.A2_LOJA = CNC.CNC_LOJA"
	cQuery += "     AND SA2.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN " + RetSqlName("CN0") + " CN0"
	cQuery += "      ON CN0.CN0_CODIGO = CN9.CN9_TIPREV"
	cQuery += "     AND CN0.D_E_L_E_T_ <> '*'"
	cQuery += "     AND LTRIM(CN0.CN0_XXTAP) = ''"
	cQuery += "	    AND CN0.CN0_XXTAD <> '01'	
	cQuery += "	    AND CN0.CN0_XXTAD <> '04'	
	cQuery += "	    AND CN0.CN0_XXTAD <> '05'	
	cQuery += " WHERE CN9.CN9_REVISA <> '   '"
	cQuery += " AND CN9.D_E_L_E_T_ <> '*'"
	cQuery += " AND CN9.CN9_DTREV >= '" + DtoS(dDtIni) + "'"
	cQuery += " AND CN9.CN9_DTREV <= '" + DtoS(dDtFim) + "'"
	 cQuery += "    AND CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += "    AND CN9.CN9_NUMERO >= '0000006000'"	 		
	cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"

	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++
		
		// Tipo de Documento da Contratada
		cTpDocCtr := IIF(AllTrim(TRB->TIPOCONTRATADA) == 'J', '1','2' ) // 1 = CNPJ, 2 = CPF
		
		// Justificativa
		cDsMotivo := AllTrim(Substr(MSMM(TRB->CN9_CODJUS),1,250))
				
		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->NRREVISAO)) + "|"
		cLin += AllTrim(Substr(TRB->DTREVISAO,1,4)) + "|"
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(TRB->NRCONTRATO)) + "|"
		cLin += AllTrim(Substr(TRB->DTINICONTRATO,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpDocCtr + "|"
		cLin += AllTrim(Substr(TRB->DOCCONTRATADA,1,15)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOADITIVO)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOOPERACAO)) + "|"
		cLin += cDsMotivo + "|"
		
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
! Programa 	! PublAdt	! Autor !Gilson Lima 		 ! Data ! 09/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT com dados da publicação resumida, na 		 !
! 			! imprensa oficial dos Aditivos		 !
+----------------------------------------------------------------------------*/
Static Function PublAdt(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
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
	 * Tabela PublicacaoAditivoInstrumentoContratual
	 *
	 * Captar dados da publicação dos extratos dos aditivos do instrumento contratual
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Nr Edicao no DOE		4		Numérico	9999		nrDiarioOficial				Sim			CN9_XEDOE
	 * Data Puclica DOE		10		Data		AAAA-MM-DD	dtPublicacaoInstrumentoContrSim			ValidaData(CN9_XPUBL)
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_REVISA, CN9.CN9_DTASSI, CN9.CN9_XEDOE, CN9.CN9_XPUBL, "
	 cQuery += " SA2.A2_TIPO, SA2.A2_CGC, "
	 cQuery += " CN0.CN0_XXTAD AS IDTIPOADITIVO, CN0.CN0_XXOPA AS IDTIPOOPERACAO"
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9, "
	 cQuery += RetSqlName("CN9") + " CN9b,"
	 cQuery += RetSqlName("CNC") + " CNC,"
	 cQuery += RetSqlName("SA2") + " SA2,"
	 cQuery += RetSqlName("CN0") + " CN0 "
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += " AND (CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	
	 cQuery += " OR CN9.CN9_TPCTO = '031')" 
	 cQuery += " AND CN9.CN9_REVISA <> '   '"
	 cQuery += " AND CN9.CN9_NUMERO >= '0000006000'"
	 cQuery += "   AND CN9b.CN9_NUMERO = CN9.CN9_NUMERO"
	 cQuery += "   AND CN9b.CN9_REVISA = '   '"	 
	 cQuery += "   AND CN9b.CN9_DTASSI >= '" + cDtIniPer + "'"
	 cQuery += "   AND CN9b.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CNC.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_NUMERO = CNC.CNC_NUMERO"
	 cQuery += " AND CN9.CN9_FILIAL = CNC.CNC_FILIAL"
	 cQuery += " AND CN9.CN9_REVISA = CNC.CNC_REVISA"
	 cQuery += " AND CNC.CNC_CODIGO = SA2.A2_COD"
	 cQuery += " AND CNC.CNC_LOJA = SA2.A2_LOJA"
	cQuery += "     AND CN0.CN0_CODIGO = CN9.CN9_TIPREV"
	cQuery += "     AND CN0.D_E_L_E_T_ <> '*'"
	cQuery += "     AND LTRIM(CN0.CN0_XXTAP) = ''"
	 cQuery += " ORDER BY CN9.CN9_NUMERO"

 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++

		// Tipo de Documento
		If TRB->A2_TIPO == 'J'
			cTpDoc := '1' // CNPJ
		Else
			cTpDoc := '2' // CPF
		EndIf

		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_REVISA,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTASSI,1,4)) + "|"
		cLin += cEntOrig + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTASSI,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cTpDoc + "|"
		cLin += AllTrim(TRB->A2_CGC) + "|"		
		cLin += cValToChar(Val(TRB->IDTIPOADITIVO)) + "|"
		cLin += cValToChar(Val(TRB->IDTIPOOPERACAO)) + "|"
		cLin += cValToChar(Val(TRB->CN9_XEDOE)) + "|"
		cLin += ValidaData(TRB->CN9_XPUBL) + "|"
		
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
! Programa 	! ContrLic ! Autor !Gilson Lima 		 ! Data ! 29/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera o arquivo TXT Vinculando o intrumento contratual com a	 !
! 			! respectiva licitação.											 !
+----------------------------------------------------------------------------*/
Static Function ContrLic(nPos)
	
	// Gera o arquivo texto
	Local cNmArq	:= aFuncoes[_POS_CONTRATO][nPos][4]
	Local cArqTxt	:= cNmDir+cNmArq
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	Local cQuery	:= ""
	
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
	 * Tabela InstrumentoContratualXLicitacao
	 *
	 * Captar a vinculação do instrumento contratual com a respectiva licitação
	 *
	 * Campos				Tamanho	Tipo		Formato		Nome						Obrigatorio	Protheus
	 * Identif. PJ TCE		7		Numérico	Z(6)9		idPessoa					Sim			Parâmetro
	 * Num. Instr. Contr.	10		Numérico	Z(9)9		nrInstrumentoContratual		Sim			CN9->CN9_NUMERO
	 * Ano Instr. Contr.	4		Numérico	9999		nrAnoInstrumentoContratual	Sim			Ano(CN9->CN9_DTINIC)
	 * Tipo Instr. Contr.	2		Numérico	Z(1)9		idTipoInstrumentoContratual	Sim			Sempre 1 = Contrato
	 * Entidade Orig. Instr.3		Numérico	Z(1)9		IdEntidadeOrigem			Sim			cEntOrig
	 * Identif PJ Respons	7		Numérico	Z(6)9		idPessoaLicitacao			Sim
	 * Nr Licitacao			4		Numérico	Z(3)9		nrLicitacao					Sim
	 * Ano Licitacao		4		Numérico	9999		nrAnoLicitacao				Sim
	 * Modal Licitacao		2		Numérico	Z(1)9		idModalidadeLicitacao		Sim	
	 * Entid Orig Licitacao	3		Numérico	Z(2)9		idEntidadeOrigem			Sim
	 */
	 
	 cQuery := "SELECT CN9.CN9_NUMERO, CN9.CN9_DTINIC, CN9.CN9_XNMLIC, CN9.CN9_XDTLIC, CN9.CN9_XTMLIC "
	 cQuery += " FROM " + RetSqlName("CN9") + " CN9 "
	 cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	 cQuery += " AND CN9.CN9_SITUAC <> '10'"	// Diferente de Revisado
	 cQuery += " AND CN9.CN9_DTASSI >= '" + DtoS(dDtIni) + "'"
	 cQuery += " AND CN9.CN9_DTASSI <= '" + DtoS(dDtFim) + "'"
	 cQuery += " AND CN9.CN9_TPCTO <= '029'"	// Maior que isso é contrato importado, Atas, etc	 
	 cQuery += " AND CN9.CN9_REVISA = '   '"
	 cQuery += " AND CN9.CN9_NUMERO >= '0000006000'"
	 cQuery += " AND CN9.CN9_DTASSI <= '20141231'"	 	 
	 cQuery += " ORDER BY CN9.CN9_NUMERO"

	 
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	// Número de registros a Processar
	nRegistros := Contar("TRB","!EOF()")
	ProcRegua(nRegistros)	

	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		IncProc() // Incrementa a régua
		nLinhas++

		cLin := cIdPessoa + "|"
		cLin += cValToChar(Val(Substr(TRB->CN9_NUMERO,1,10))) + "|"
		cLin += AllTrim(Substr(TRB->CN9_DTINIC,1,4)) + "|"
		cLin += cTpInstrCtr + "|" 
		cLin += cEntOrig + "|"
		cLin += cIdPessoa + "|"
		cLin += cValToChar(Val(TRB->CN9_XNMLIC)) + "|"
		cLin += AllTrim(Substr(TRB->CN9_XDTLIC,1,4)) + "|"
		cLin += cValToChar(Val(TRB->CN9_XTMLIC)) + "|"
		cLin += cEntOrig + "|"
		
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
! Programa 	!Funcao		! Autor !Gilson Lima 		 ! Data ! 16/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Funcao Temporária												 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function Funcao()
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
	
	cChave := xFilial("CC2")+cEst+Substr(cCodMun,1,5)
	
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
! Programa 	! RetExec	! Autor !Gilson Lima 		 ! Data ! 17/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Função para retornar início e fim de execução baseado nas pla- !
! 			! nilhas					 									 !
+----------------------------------------------------------------------------*/
Static Function RetExec(cNumCtr,nOpc)

	Local cData 	:= ''
	Local aArea		:= GetArea()
	Local cQuery	:= ''
	
	cQuery := "SELECT TOP(1) CNA.CNA_DTINI, CNA.CNA_DTFIM"
	cQuery += " FROM " + RetSqlName("CNA") + " CNA"
	cQuery += " WHERE CNA.D_E_L_E_T_ <> '*'"
	cQuery += " AND CNA.CNA_CONTRA = '" + cNumCtr + "'"
	
	If nOpc == 1 // 1 = Início
		cQuery += " ORDER BY CNA.CNA_DTINI"
	Else // Fim
		cQuery += " ORDER BY CNA.CNA_DTFIM DESC"
	EndIf
	 
	If Select('TRBCNA') <> 0
		dbSelectArea('TRBCNA')
		TRBCNA->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRBCNA',.F.,.F.)

	dbSelectArea('TRBCNA')

	If nOpc == 1
		cData := TRBCNA->CNA_DTINI
	Else
		cData := TRBCNA->CNA_DTFIM
	EndIF

	TRBCNA->(dbCloseArea())
	
	RestArea(aArea)
	
Return(cData)

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! RetNrGasto! Autor !Gilson Lima 		 ! Data ! 18/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Função para retornar próximo Nr. Gasto ou Detalhe do Gasto	 !
! 			!  							 									 !
+----------------------------------------------------------------------------*/
Static Function RetNrGasto(nOpc)

	Local aArea  := GetArea()
	Local cQuery := ''
	Local cNr	 := ''
	
	If nOpc == 1 // Gasto

		cQuery := "SELECT MAX(SE2.E2_XNRGAS) AS NRATUAL"
		cQuery += " FROM " + RetSqlName("SE2") + " SE2"
		cQuery += " WHERE SE2.D_E_L_E_T_ <> '*'"
	 
		If Select('TRBSE2') <> 0
			dbSelectArea('TRBSE2')
			TRBSE2->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRBSE2',.F.,.F.)
	
		dbSelectArea('TRBSE2')
		
		cNr := cValToChar(Val(TRBSE2->NRATUAL) + 1)
	
		TRBSE2->(dbCloseArea())
	Else
		
		// Retorna Número da SE2
		cQuery := "SELECT MAX(SE2.E2_NRDTTCE) AS NRATUAL"
		cQuery += " FROM " + RetSqlName("SE2") + " SE2"
		cQuery += " WHERE SE2.D_E_L_E_T_ <> '*'"
	 
		If Select('TRBSE2') <> 0
			dbSelectArea('TRBSE2')
			TRBSE2->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRBSE2',.F.,.F.)
	
		dbSelectArea('TRBSE2')
		
		nNrSE2 := Val(TRBSE2->NRATUAL)
	
		TRBSE2->(dbCloseArea())
	
		// Retorna Número da SD1
		cQuery := "SELECT MAX(SD1.D1_NRDTTCE) AS NRATUAL"
		cQuery += " FROM " + RetSqlName("SD1") + " SD1"
		cQuery += " WHERE SD1.D_E_L_E_T_ <> '*'"
	 
		If Select('TRBSD1A') <> 0
			dbSelectArea('TRBSD1A')
			TRBSD1A->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRBSD1A',.F.,.F.)
	
		dbSelectArea('TRBSD1A')
		
		nNrSD1 := Val(TRBSD1A->NRATUAL)
	
		TRBSD1A->(dbCloseArea())
		
		// Verifica o maior número e retorna
		
		If nNrSE2 >= nNrSD1
			cNr := cValToChar(nNrSE2 + 1)
		Else
			cNr := cValToChar(nNrSD1 + 1)
		EndIf
	
	EndIf
	
	RestArea(aArea)

Return(cNr)

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! RetIDQuad ! Autor !Gilson Lima 		 ! Data ! 18/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Função para retornar próximo Nr. ID do Quadro Deliberativo	 !
! 			!  							 									 !
+----------------------------------------------------------------------------*/
Static Function RetIDQuad()

	Local aArea  := GetArea()
	Local cQuery := ''
	Local cNr	 := ''

	cQuery := "SELECT MAX(SZJ.ZJ_IDTCE) AS NRATUAL"
	cQuery += " FROM " + RetSqlName("SZJ") + " SZJ"
	cQuery += " WHERE SZJ.D_E_L_E_T_ <> '*'"
 
	If Select('TRBSZJ') <> 0
		dbSelectArea('TRBSZJ')
		TRBSZJ->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRBSZJ',.F.,.F.)

	dbSelectArea('TRBSZJ')
	
	nNr := Val(TRBSZJ->NRATUAL) + 1

	TRBSZJ->(dbCloseArea())

	RestArea(aArea)

Return(nNr)