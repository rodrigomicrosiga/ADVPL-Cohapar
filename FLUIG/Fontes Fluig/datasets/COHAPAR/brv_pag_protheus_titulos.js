function createDataset(fields, constraints, sortingFields) {
	var MOEDA_REAIS = "R$ ";
	var ID_SERVICO = "KITPAGAMENTO";
	var NOME_CLASSE = "br.com.bravaecm.kitpagamentos.BRVKITPAGAMENTOSLocator";

	var locator = null;
	var servicoSOAP = null;
	var itens = null;
	var params = null;

	try {
		// fields = ([ "20150316", "A511001001 " ]);
		params = getObjetoParametros(fields);
		locator = getLocatorServico(ID_SERVICO, NOME_CLASSE);
		servicoSOAP = locator.getBRVKITPAGAMENTOSSOAP();
		itens = servicoSOAP.GETITENSLOTE(params.idLote, params.idCentroCusto).getTITENSLOTE();
		log.info("PASSOU titulo try 1 ");
	} catch (e) {
		return createDatasetErro("Erro ao consultar o Web service do Protheus: " + e);
	}

	var dataset = createColunasDataset();

	if (itens == null || itens.length < 1){
		log.info("PASSOU titulo 2 " );
		return dataset;
		log.info("PASSOU titulo 2.1 "+dataset.rownsCount );
	}
		
	var LOCALE_BRASIL = new java.util.Locale("pt", "BR");
	var FORMATOS_BRASIL = new java.text.DecimalFormatSymbols(LOCALE_BRASIL);
	var FORMATO_DATA = new java.text.SimpleDateFormat("dd/MM/yyyy");
	var FORMATO_DATA_EMISSAO = new java.text.SimpleDateFormat("yyyy-MM-dd");
	var formatoPreco = new java.text.DecimalFormat("#0.00");

	formatoPreco.setDecimalFormatSymbols(FORMATOS_BRASIL);

	for (var i = 0; i < itens.length; i++) {
		var item = itens[i];
		log.info("PASSOU titulo 3");
		dataset.addRow([ item.getSITUAC(), item.getFILIAL(), item.getNUMERO(), item.getTIPO(), item.getNATUREZ(), item.getFORNECE(),
				item.getPARCELA(), FORMATO_DATA.format(item.getVENCTO()), MOEDA_REAIS + formatoPreco.format(item.getVALOR()), item.getOBSERV(),
				item.getPREFIXO(), FORMATO_DATA_EMISSAO.format(item.getEMISSAO()) ]);

	}
	log.info("PASSOU titulo 4");
	return dataset;

}

function createColunasDataset() {

	var CAMPOS = [ "situacao", "filial", "numero", "tipo", "natureza", "fornecedor", "parcela", "vencimento", "valor", "observacao", "prefixo",
			"emissao" ];

	var dataset = DatasetFactory.newDataset();

	for (var i = 0; i < CAMPOS.length; i++)
		dataset.addColumn(CAMPOS[i]);

	return dataset;
}

function getObjetoParametros(arrayParametros) {

	if (arrayParametros == null || arrayParametros.length < 2)
		throw "Obrigat?rio informar id do Lote e Centro de Custo";

	var params = {
		idLote : arrayParametros[0],
		idCentroCusto : arrayParametros[1]
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

	log.error("[brv_pag_protheus_sc_titulos] " + erro);

	return dataset;

}
