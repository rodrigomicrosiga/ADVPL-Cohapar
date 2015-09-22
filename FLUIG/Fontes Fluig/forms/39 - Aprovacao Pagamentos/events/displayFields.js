function displayFields(form) {

	log.info("[log] entrou no display");

	var nProcesso = getValue("WKNumProces");
	var nAtividade = getValue("WKNumState");
	var mUsuario = getValue("WKUser");
	var fModo = form.getFormMode();

	log.info("[log] 1");

	form.setShowDisabledFields(true);
	form.setHidePrintLink(true);
	form.setValue("workflowState", getValue("WKNumState"));

	log.info("[log] 2");

	var filter = new java.util.HashMap();

	log.info("[log] 2.1");

	filter.put("colleaguePK.colleagueId", form.getValue("codUser"));

	log.info("[log] 2.2");

	var colaborador = getDatasetValues('colleague', filter);

	log.info("[log] 3");

	// REGISTRA DADOS DO SISTEMA NO LOG
	log.info("[log] Workflow Solicitacao de Compras:  Evento displayFields");
	log.info("[log] Processo: " + nProcesso);
	log.info("[log] Atividade: " + nAtividade);
	log.info("[log] Usuario: " + mUsuario);
	log.info("[log] Modo: " + fModo);
	log.info("[log] Usuario Protheus: " + form.getValue("codUser"));

	if (nAtividade == 2) {
		log.info("[Log] >>>> Atividade: " + nAtividade);
		// form.setValue("nomeUser", "Usuario tal");
		form.setValue("nomeUser", colaborador.get(0).get("colleagueName"));
		log.info("[Log] >>>> Passou pela ativivade");
	}
}