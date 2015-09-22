function createDataset(fields, constraints, sortingFields) {
	var ID_SERVICO = "KITPAGAMENTO";
	var NOME_CLASSE = "br.com.bravaecm.kitpagamentos.BRVKITPAGAMENTOSLocator";
	var MOEDA_REAIS = "R$ ";
	var locator = null;
	var servicoSOAP = null;
	var itens = null;
	var params = null;

	try {
		// fields = ([ "01", "1", "888888", "1", "NF", "000010" ]);
		params = getObjetoParametros(fields);
		locator = getLocatorServico(ID_SERVICO, NOME_CLASSE);
		servicoSOAP = locator.getBRVKITPAGAMENTOSSOAP();
		itens = servicoSOAP.GETHISTAPR(params.filial, params.prefixo, params.titulo, params.parcela, params.tipo, params.fornecedor).getTHISTAPROV();
		log.info("PASSOU  passou historico");
	} catch (e) {
		return createDatasetErro("Erro ao consultar o Web service do Protheus: " + e);
	}

	var dataset = createColunasDataset();

	if (itens == null || itens.length < 1)
		return dataset;

	var FORMATO_DATA_RECEBIDA = new java.text.SimpleDateFormat("yyyyMMdd hh:mm");
	var FORMATO_DATA_DESTINO = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
	var LOCALE_BRASIL = new java.util.Locale("pt", "BR");
	var FORMATOS_BRASIL = new java.text.DecimalFormatSymbols(LOCALE_BRASIL);
	var formatoPreco = new java.text.DecimalFormat("#0.00");
	formatoPreco.setDecimalFormatSymbols(FORMATOS_BRASIL);

	for (var i = 0; i < itens.length; i++) {
		var item = itens[i];
		var dataRecebida = FORMATO_DATA_RECEBIDA.parse(item.getDATAAPR().toString());
		dataset.addRow([ item.getCCUSTO(), item.getRESPONS(), item.getRATEIO(), MOEDA_REAIS + formatoPreco.format(item.getVALOR()),
				FORMATO_DATA_DESTINO.format(dataRecebida), item.getSITUAC(), item.getOBSERV() ]);
	}

	return dataset;
}

function createColunasDataset() {

	var CAMPOS = [ "ccusto", "responsavel", "rateio", "valor", "data_aprovacao", "situacao", "observacao" ];

	var dataset = DatasetFactory.newDataset();

	for (var i = 0; i < CAMPOS.length; i++)
		dataset.addColumn(CAMPOS[i]);

	return dataset;
}

function getObjetoParametros(arrayParametros) {
	if (arrayParametros == null || arrayParametros.length < 6)
		throw "Obrigat?rio informar Filial, Prefixo , N?mero do Titulo, Parcela, Tipo e Fornecedor";

	var params = {
		filial : arrayParametros[0],
		prefixo : arrayParametros[1],
		titulo : arrayParametros[2],
		parcela : arrayParametros[3],
		tipo : arrayParametros[4],
		fornecedor : arrayParametros[5]
	};

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

	log.error("[brv_pag_protheus_historico] " + erro);

	return dataset;

}
