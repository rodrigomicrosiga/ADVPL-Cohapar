function beforeTaskSave(colleagueId, nextSequenceId, userList) {
	log.info("BEFORE TASK SAVE");
	var state = getValue("WKNumState");
	var ID_WKF_ACTIVITY_ANALISAR_TITULOS = 2;
	var ID_WKF_ACTIVITY_FINANCEIRO = 5;
	// Atividade 2 - Analisar titulos
	if (state == ID_WKF_ACTIVITY_ANALISAR_TITULOS && possuiTitulosAlterados()) {
		log.info(" :: Atividade 2 - Analisar titulos: before Task Save - Vai gravar titulos no Protheus");
		try {
			var colleagueName = getColleagueName(colleagueId);
			var retornoWS = gravarLote(colleagueName);
			log.info("retornoWS:" + retornoWS);
		} catch (e) {
			log.info("Erro ao gravar lote");
			log.info(e);
			enviarEmail(e);
			throw "Problemas ao gravar lote no Protheus";
		}
		if (!isResponseOK(retornoWS)) {
			throw retornoWS;
		}
	} else if (state == ID_WKF_ACTIVITY_FINANCEIRO && getValue("WKCompletTask") != "true") {
		// Neste caso foi clicado no bot?o salvar, e n?o enviar
		throw "N?o ? poss?vel salvar a ficha nesta atividade, apenas enviar para atividade Fim";
	}
}

function getColleagueName(colleagueId) {
	var filter = new java.util.HashMap();
	filter.put("colleaguePK.colleagueId", colleagueId);
	var colaborador = getDatasetValues('colleague', filter);
	var name = colaborador.get(0).get("colleagueName");
	log.info(name);
	return name;
}

function possuiTitulosAlterados() {
	var titulos = getTitulosAlteradosJSONArray();
	return titulos != null && titulos.length() > 0;
}

function getTitulosAlteradosJSONArray() {
	var titulos_string = hAPI.getCardValue("titulos_alterados_json");
	log.info("hidden titulos... : titulos alterados");
	log.info(titulos_string);
	var param = "";
	if (titulos_string && titulos_string.trim() != "") {
		var jsonArray = new org.json.JSONArray(titulos_string);
		return jsonArray;
	}
	log.info("WS PARAM:");
	log.info(param);
	log.info("ENDOF WS PARAM:");
}

function gravarLote(colleagueName) {
	var jsonArray = getTitulosAlteradosJSONArray();
	var param = "";
	for (var i = 0; i < jsonArray.length(); i++) {
		var jsonObject = jsonArray.getJSONObject(i);
		param = param + getItemLote(colleagueName, jsonObject);
	}
	log.info("WS PARAM:");
	log.info(param);
	log.info("ENDOF WS PARAM:");
	return call_ws(param);
}

function getItemLote(colleagueName, jsonObject) {
	var SEP = "|";
	var user = colleagueName;
	var lote = jsonObject.get("lote");
	var ccusto = jsonObject.get("ccusto").trim();
	var filial = jsonObject.get("filial").trim();
	var prefixo = jsonObject.get("prefixo").trim();
	var numero = jsonObject.get("numero").trim();
	var parcela = jsonObject.get("parcela").trim();
	var tipo = jsonObject.get("tipo").trim();
	var fornecedor = jsonObject.get("fornecedor").trim();
	var situacao = jsonObject.get("situacao").trim();
	var observacao = jsonObject.get("observacao").trim() == "" ? " " : jsonObject.get("observacao");
	log.info("WS CALL - - GRAVA TITULO ##################################");
	log.info("user: " + user);
	log.info("lote: " + lote);
	log.info("ccusto:" + ccusto);
	log.info("filial: " + filial);
	log.info("prefixo:" + prefixo);
	log.info("numero:" + numero);
	log.info("parcela:" + parcela);
	log.info("tipo:" + tipo);
	log.info("fornecedor:" + fornecedor);
	log.info("situacao:" + situacao);
	log.info("observacao:" + observacao);

	var itemLote = user + SEP + lote + SEP + ccusto + SEP + filial + SEP + prefixo + SEP + numero + SEP + parcela + SEP + tipo + SEP + fornecedor
			+ SEP + situacao + SEP + observacao + SEP;

	return itemLote;
}

function call_ws(param) {
	var ID_SERVICO = "KITPAGAMENTO";
	log.info("[log] CALL_WS  ID_SERVICO ");
	var NOME_CLASSE = "br.com.bravaecm.kitpagamentos.BRVKITPAGAMENTOSLocator";
	log.info("[log] CALL_WS NOME_CLASSE ");
	var locator = getLocatorServico(ID_SERVICO, NOME_CLASSE);
	log.info("[log] CALL_WS LOCATOR ");
	var servicoSOAP = locator.getBRVKITPAGAMENTOSSOAP();
	log.info("[log] CALL_WS SERVICOSOAP ");
	return servicoSOAP.GRAVARLOTE(param);
	/*var sResult = servicoSOAP.GRAVARLOTE(param);
	
	var aResult = new String(sResult).split("|");
	var sStatus = aResult[0];
	log.info("[LOG] Retorno do sistema Protheus: " + sStatus);
	
	if(sStatus == "OK"){
		log.info("[LOG] O l?der da OS " + os + " foi alterado com sucesso no Sistema Protheus.");
	}else{
		log.info("[LOG] Ocorreu um erro ao alterar o l?dero no sistema Protheus.");
	}*/
}

function getLocatorServico(idServico, nmClasseLocator) {
	var servico = ServiceManager.getService(idServico);
	if (servico == null)
		throw java.lang.String.format("Servico '%s' n?o cadastrado!", idServico);

	var bean = servico.getBean();
	var locator = null;
	try {
		locator = bean.instantiate(nmClasseLocator);
	} catch (e) {
		throw java.lang.String.format("Erro ao obter inst?ncia da classe '%s' a partir do servi?o '%s': %s", nmClasseLocator, idServico, e);
	}

	return locator;
}