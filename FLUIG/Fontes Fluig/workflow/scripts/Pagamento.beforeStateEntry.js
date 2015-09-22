function beforeStateEntry(sequenceId) {

	var nProcesso = getValue("WKNumProces");
	var atividadeAtual = getValue("WKNumState");
	var proximaAtividade = sequenceId;

	log.info("[LOG] Evento: beforeStateEntry");
	log.info("[LOG] Processo: Pagamentos");
	log.info("[LOG] Codigo: " + nProcesso);
	log.info("[LOG] Atividade atual: " + atividadeAtual);
	log.info("[LOG] Proxima atividade: " + proximaAtividade);

	log.info("[log] BEFORE STATE ENTRY");

	var ROLE_FINANCEIRO = "Pool:Role:Financeiro";
	log.info("[log] ROLE_FINANCEIRO: " + ROLE_FINANCEIRO);
	log.info("[log] BEFORE STATE ENTRY 2");
	var FECHAR_LOTE = 3;
	var FIM_PROCESSO = 6;
	var CIENCIA_FINANCEIRO = 5;
	var retornoWS = "";
	if (sequenceId == FECHAR_LOTE && hAPI.getCardValue("select_fin") == "Fn") {
		log.info("BEFORE STATE ENTRY - IF 1");
		if (hAPI.getCardValue("skipToActivity") == null || hAPI.getCardValue("skipToActivity").trim() == "") {
			try {
				log.info("BEFORE STATE ENTRY - IF 2 - TRY/Catch");
				retornoWS = fecharLote();
				var possuiReprovados = possuiTitulosReprovados();
				if (isResponseOK(retornoWS)) {
					log.info("BEFORE STATE ENTRY - IF 2 - TRY/Catch - if 3");
					if (possuiReprovados) {
						log.info("BEFORE STATE ENTRY - IF 2 - TRY/Catch - if 4");
						return enviarPara(CIENCIA_FINANCEIRO, ROLE_FINANCEIRO);
					} else {
						return enviarPara(FIM_PROCESSO);
					}
				}
			} catch (e) {
				log.info("Problemas ao fechar o lote no Protheus." + e);
				enviarEmail(e);
				throw "Problemas ao fechar o lote no Protheus.";
			}
			if (!isResponseOK(retornoWS)) {
				throw retornoWS;
			}
		} else {
			// Movimenta??o via Protheus causada por fechamento de lote no
			// Portal ou Mobile
			var user = null;
			if (hAPI.getCardValue("skipToActivity").toString() == new java.lang.String(CIENCIA_FINANCEIRO)) {
				user = ROLE_FINANCEIRO;
			}
			enviarPara(hAPI.getCardValue("skipToActivity"), user);
		}
	}
}