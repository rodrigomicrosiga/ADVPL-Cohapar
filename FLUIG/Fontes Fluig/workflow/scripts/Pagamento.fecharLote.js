function fecharLote() {
	var ID_SERVICO = "KITPAGAMENTO";
	var NOME_CLASSE = "br.com.bravaecm.kitpagamentos.BRVKITPAGAMENTOSLocator";
	var lote = hAPI.getCardValue("lote");
	log.info(lote);
	var ccusto = hAPI.getCardValue("centroCusto");
	log.info(ccusto);
	log.info("Vai chamar WS Fechar lote:.....................");
	var locator = getLocatorServico(ID_SERVICO, NOME_CLASSE);
	var servicoSOAP = locator.getBRVKITPAGAMENTOSSOAP();
	// Passar parametro CMOVIMENTA LOTE = 'N' para o Protheus n?o movimentar o
	// processo.
	var retornoWS = servicoSOAP.FECHARLOTE(lote, ccusto, "N");
	return retornoWS;
}

function possuiTitulosReprovados() {
	log.info("VERIFICACAO DE TITULO REPROVADO");
	log.info("###################################");
	var possuiReprovados = hAPI.getCardValue("possui_reprovados");
	log.info(possuiReprovados);
	if (possuiReprovados == "true") {
		return true;
	} else {
		return false;
	}
}

function getLocatorServico(idServico, nmClasseLocator) {
	var servico = ServiceManager.getService(idServico);

	if (servico == null)
		throw java.lang.String.format("Servi?o '%s' n?o cadastrado!", idServico);

	var bean = servico.getBean();
	var locator = null;

	try {
		locator = bean.instantiate(nmClasseLocator);
	} catch (e) {
		throw java.lang.String.format("Erro ao obter inst?ncia da classe '%s' a partir do servi?o '%s': %s", nmClasseLocator, idServico, e);
	}

	return locator;
}

function enviarEmail(erro) {
	try {
		// Monta mapa com par?metros do template
		var parametros = new java.util.HashMap();
		parametros.put("NOME_KIT", getValue("WKDef") + " - Solicita??o: " + getValue("WKNumProces"));
		parametros.put("ERRO_INTEGRACAO", erro);
		// Este par?metro obrigat?rio e representa o assunto do e-mail
		parametros.put("subject", "[" + getValue("WKDef") + "]" + " Erro integra??o");
		// Monta lista de destinat?rios
		var destinatarios = new java.util.ArrayList();
		var matriculaDestinatario = hAPI.getAdvancedProperty("COLLEAGUE_ID_TI");
		var codTemplate = hAPI.getAdvancedProperty("ID_INTEGRATION_ERROR_MAIL_TEMPLATE");
		destinatarios.add(matriculaDestinatario);
		// Envia e-mail
		notifier.notify("integrator", codTemplate, parametros, destinatarios, "text/html");
	} catch (e) {
		log.info(e);
	}

}

function enviarPara(state, user) {
	var users = new java.util.ArrayList();
	if (user) {
		users.add(user);
	}

	hAPI.setAutomaticDecision(state, users, "Decis?o tomada automaticamente pelo ECM.");
	return false;
}

function isResponseOK(response) {
	log.info("RESPONSE:" + response);
	var retorno = new java.lang.String(response);
	var retornoSemEspacos = retorno.trim();
	return retornoSemEspacos == "OK";
}