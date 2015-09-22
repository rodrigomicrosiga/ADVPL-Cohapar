function createDataset(fields, constraints, sortingFields) {
	var MOEDA_REAIS = "R$ ";
	var ID_SERVICO = "KITPAGAMENTO";
	var NOME_CLASSE = "br.com.bravaecm.kitpagamentos.BRVKITPAGAMENTOSLocator";

	var locator = null;
	var servicoSOAP = null;
	var itens = null;
	var params = null;

	try {
		// fields = ([ "01", "999999999", "999", "000004" ]);
		params = getObjetoParametros(fields);
		locator = getLocatorServico(ID_SERVICO, NOME_CLASSE);
		servicoSOAP = locator.getBRVKITPAGAMENTOSSOAP();
		itens = servicoSOAP.GETITENSNOTA(params.filial, params.numero_nota, params.serie, params.fornecedor).getTITENSNOTA();
		log.info("PASSOU itens try 1");
	} catch (e) {
		return createDatasetErro("Erro ao consultar o Web service do Protheus: " + e);
	}

	var dataset = createColunasDataset();

	if (itens == null || itens.length < 1)
		return dataset;

	var LOCALE_BRASIL = new java.util.Locale("pt", "BR");
	var FORMATOS_BRASIL = new java.text.DecimalFormatSymbols(LOCALE_BRASIL);
	var formatoPreco = new java.text.DecimalFormat("#0.00");
	formatoPreco.setDecimalFormatSymbols(FORMATOS_BRASIL);

	for (var i = 0; i < itens.length; i++) {
		var item = itens[i];

		dataset.addRow([ item.getITEM(), item.getPRODUTO(), item.getDESCPROD(), item.getUNIDADE(), item.getQUANTDE(),
				MOEDA_REAIS + formatoPreco.format(item.getVALUNIT()), MOEDA_REAIS + formatoPreco.format(item.getVALTOTAL()),
				MOEDA_REAIS + formatoPreco.format(item.getVALICMS()), MOEDA_REAIS + formatoPreco.format(item.getVALIPI()) ]);

	}

	return dataset;

}

function createColunasDataset() {

	var CAMPOS = [ "item", "produto", "descricao", "unidade", "quantidade", "valor_unitario", "valor_total", "valor_icms", "valor_ipi" ];

	var dataset = DatasetFactory.newDataset();

	for (var i = 0; i < CAMPOS.length; i++)
		dataset.addColumn(CAMPOS[i]);

	return dataset;
}

function getObjetoParametros(arrayParametros) {

	if (arrayParametros == null || arrayParametros.length < 4)
		throw "Obrigat?rio informar Filial, N?mero da Nota, S?rie e C?digo do Fornecedor";

	var params = {
		filial : arrayParametros[0],
		numero_nota : arrayParametros[1],
		serie : arrayParametros[2],
		fornecedor : arrayParametros[3]
	};

	log.info("[LOG] ITENS >>>> FILIAL " + params.filial);
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

	log.error("[brv_pag_protheus_itens_nota] " + erro);

	return dataset;

}
