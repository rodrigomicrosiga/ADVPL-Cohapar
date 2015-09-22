function createDataset(fields, constraints, sortingFields) {
	var ID_SERVICO = "KITPAGAMENTO";
	var NOME_CLASSE = "br.com.bravaecm.kitpagamentos.BRVKITPAGAMENTOSLocator";
	var MOEDA_REAIS = "R$ ";
	var locator = null;
	var servicoSOAP = null;
	var itens = null;
	var params = null;

	try {
		//fields = ([ "01", "999", "999999999", "000010" ]);
		params = getObjetoParametros(fields);

		locator = getLocatorServico(ID_SERVICO, NOME_CLASSE);
		servicoSOAP = locator.getBRVKITPAGAMENTOSSOAP();

		itens = servicoSOAP.GETCABECNOTA(params.filial, params.prefixo, params.titulo, params.fornecedor).getTCABECNOTA();

		log.info("[log]PASSOU cabecalho 1");

	} catch (e) {
		return createDatasetErro("Erro ao consultar o Web service do Protheus: " + e);
	}

	var dataset = createColunasDataset();
	log.info("[log]PASSOU cabecalho 2");
	if (itens == null || itens.length < 1) {
		log.info("[log]PASSOU cabecalho return datat 3 " + dataset.rowsCount);
		return dataset;
		log.info("[log]PASSOU cabecalho return datat 4");
	}

	var FORMATO_DATA = new java.text.SimpleDateFormat("dd/MM/yyyy");
	var LOCALE_BRASIL = new java.util.Locale("pt", "BR");
	var FORMATOS_BRASIL = new java.text.DecimalFormatSymbols(LOCALE_BRASIL);
	var formatoPreco = new java.text.DecimalFormat("#0.00");
	formatoPreco.setDecimalFormatSymbols(FORMATOS_BRASIL);

	for (var i = 0; i < itens.length; i++) {
		var item = itens[i];
		log.info("[log]PASSOU cabecalho return4");
		dataset.addRow([ item.getNUMERO(), item.getSERIE(), item.getESPECIE(), item.getUF(), FORMATO_DATA.format(item.getEMISSAO()),
				item.getNOMEFOR(), item.getFORNECE(), MOEDA_REAIS + formatoPreco.format(item.getVALORTOT()), item.getCONDPAG() ]);
	}

	return dataset;

}

function createColunasDataset() {

	var CAMPOS = [ "numero", "serie", "especie", "uf", "emissao", "fornecedor", "num_fornecedor", "valor_total", "condicao" ];

	var dataset = DatasetFactory.newDataset();

	for (var i = 0; i < CAMPOS.length; i++)
		dataset.addColumn(CAMPOS[i]);

	return dataset;
}

function getObjetoParametros(arrayParametros) {

	if (arrayParametros == null || arrayParametros.length < 3)
		throw "Obrigat?rio informar Filial, Prefixo , N?mero do Titulo";

	var params = {
		filial : arrayParametros[0],
		prefixo : arrayParametros[1],
		titulo : arrayParametros[2],
		fornecedor : arrayParametros[3]
	};

	log.info("[log]CABECALHO >>>> FILIAL " + params.filial);
	log.info("[log]CABECALHO >>>> prefixo " + params.prefixo);
	log.info("[log]CABECALHO >>>> titulo " + params.titulo);
	log.info("[log]CABECALHO >>>> fornecedor " + params.fornecedor);
	return params;

}

function getLocatorServico(idServico, nmClasseLocator) {

	var servico = ServiceManager.getService(idServico);

	if (servico == null)
		throw java.lang.String.format("Servi?o n?o cadastrado!", idServico);

	var bean = servico.getBean();
	var locator = null;

	try {
		locator = bean.instantiate(nmClasseLocator);
	} catch (e) {
		throw java.lang.String.format("Erro ao obter inst?ncia da classe '%s' a partir do servi?o '%s': %s", nmClasseLocator, idServico, e);
	}

	return locator;
}

function createDatasetErro(erro) {
	var dataset = DatasetFactory.newDataset();
	dataset.addColumn("erro");
	dataset.addRow([ erro ]);

	log.error("[brv_pag_protheus_cabecalho_nota] " + erro);

	return dataset;

}
