var CANCELADO = "C";
var REPROVADO = "R";
var APROVADO = "A";
var PENDENTE = "P";

var DATASET_LOTE = "brv_pag_protheus_titulos";
var dataset;
var datatable;
var ui_table;
var current_titulo;
var cabecalho_nota;
var linha_selecionada;
var linhas_alteradas = [];
var lote;
var ccusto;
var hash_id_tab_selecionada;

jQuery(document).ready(function() {

	/*
	 * trecho para testes, deve ser removido jQuery("#lote").val("20110503");
	 * jQuery("#centroCusto").val("10200"); jQuery("#dtLote").val("20110503
	 * 18:37"); /*fim trecho para testes, deve ser removido
	 */

	var dtLote = jQuery("#dtLote").val();
	var ano = dtLote.substring(0, 4);
	var mes = dtLote.substring(4, 6);
	var dia = dtLote.substring(6, 8);
	var hora = dtLote.substring(8);

	jQuery("#dataLote").val(dia + "/" + mes + "/" + ano + hora);

	jQuery("#nomeCusto").val();
	jQuery("#codUser").val();
	lote = jQuery("#lote").val();
	ccusto = jQuery("#centroCusto").val();

	var paramsDataset = {
		"datasetName" : DATASET_LOTE,
		"fields" : [ lote.toString(), ccusto.toString() ],
		"columnTitles" : {
			"situacao" : "Situação",
			"filial" : "Filial",
			"numero" : "Título",
			"tipo" : "Tipo",
			"natureza" : "Natureza",
			"fornecedor" : "Fornecedor",
			"parcela" : "Parcela",
			"vencimento" : "Vencimento",
			"valor" : "Valor"
		}
	};

	var hiddenColumns = [ "observacao", "prefixo", "emissao", "natureza", "parcela", "vencimento" ];

	try {
		var data = getDatasetAsObject(paramsDataset, hiddenColumns);
	} catch (e) {
		alert(e);
		return;
	}

	datatable = data.datatable;
	datatable.aoColumnDefs = [ {
		"fnRender" : function(table) {
			if (table.aData[0].toString() == APROVADO) {
				return "<img id=\"img1\" src=\"green_dot.png\">";
			} else if (table.aData[0].toString() == PENDENTE) {
				return "<img id=\"img1\" src=\"yellow_dot.png\">";
			} else if (table.aData[0].toString() == CANCELADO) {
				return "<img id=\"img1\" src=\"gray_dot.png\">";
			} else if (table.aData[0].toString() == REPROVADO) {
				return "<img id=\"img1\" src=\"red_dot.png\">";
			}
		},
		"aTargets" : [ 0 ]
	} ];

	dataset = data.dataset;
	configureDataTableMaster(datatable);

	criaAbas();
	jQuery("#abasDetalhes").hide();
	ui_table = renderGrid(datatable, "div_titulos");
	atualizaHiddenTitulos();
	atualizaHiddenPossuiTitulosReprovados();

});

function titulos_alterados_to_json_string() {
	var titulos_alterados = [];
	for (var i = 0; i < dataset.values.length; i++) {
		if (jQuery.inArray(i, linhas_alteradas) != -1) {
			var titulo = dataset.values[i];
			titulo.lote = lote;
			titulo.ccusto = ccusto;
			titulos_alterados.push(titulo);
		}
	}
	var t_string = JSON.stringify(titulos_alterados, null, null);
	return t_string;
}

function configureDataTable(datatable) {
	datatable.sDom = 'T';
	datatable.oTableTools = {
		"aButtons" : []
	};
}

function configureDataTableMaster(datatable) {
	datatable.sDom = 'T';
	datatable.oTableTools = {
		"aButtons" : [],
		"sRowSelect" : "single",
		"fnRowSelected" : function(linha) {
			selecionarTitulo(linha);
			linha_selecionada = linha.rowIndex - 1;
			renderSelectedTab();
		}
	};
}

function atualizaHiddenPossuiTitulosReprovados() {
	jQuery("#possui_reprovados").val("false");
	for (var i = 0; i < dataset.values.length; i++) {
		if (dataset.values[i].situacao == REPROVADO) {
			jQuery("#possui_reprovados").val("true");
			break;
		}
	}
}

function change_select_situacao() {
	atualizaControleLinhasAlteradas();
	atualizaCelulaDatatable(jQuery("#select_situacao").val().toString(), linha_selecionada, 0);
	atualizaDatasetSituacao(linha_selecionada);
	atualizaHiddenPossuiTitulosReprovados();
}

function change_text_observacao(valor) {
	atualizaControleLinhasAlteradas();
	atualizaDatasetObservacao(linha_selecionada, valor);
}

function criaAbas() {
	jQuery("#abasDetalhes").tabs({
		"create" : function(event, ui) {

		},
		"select" : function(event, ui) {
			hash_id_tab_selecionada = ui.tab.hash;
			renderSelectedTab();
		},
		"selected" : 0
	});
}

function atualizaControleLinhasAlteradas() {
	if (jQuery.inArray(linha_selecionada, linhas_alteradas) == -1) {
		linhas_alteradas.push(linha_selecionada);
	}
}

function renderSelectedTab() {
	if (hash_id_tab_selecionada == "#abaPedidoCompra") {
		configure_data_table_pedido_compra(current_titulo.filial, cabecalho_nota.numero_nota, cabecalho_nota.serie, cabecalho_nota.fornecedor);
	} else if (hash_id_tab_selecionada == "#abaSituacao") {
		configure_data_table_historico(current_titulo.filial, current_titulo.prefixo, cabecalho_nota.numero_nota, current_titulo.parcela,
				current_titulo.tipo, cabecalho_nota.fornecedor);
	}
}

function atualizaDatasetSituacao(linha) {
	var select_situacao = jQuery("#select_situacao");
	dataset.values[linha].situacao = select_situacao.val();
	atualizaHiddenTitulos();
}

function atualizaDatasetObservacao(linha, valor) {
	dataset.values[linha].observacao = valor;
	atualizaHiddenTitulos();
}

function atualizaHiddenTitulos() {
	var hidden_titulos = jQuery("#titulos_alterados_json");
	hidden_titulos.val(titulos_alterados_to_json_string());
}

function atualizaCelulaDatatable(value, row, col) {
	ui_table.fnUpdate(value.toString(), row, col);
}

function selecionarTitulo(row) {
	sincronizaDadosTitulo(row);
	cabecalho_nota = configure_cabecalho_nota(current_titulo.filial, current_titulo.prefixo, current_titulo.numero,current_titulo.fornecedor);
	configure_itens_nota(current_titulo.filial, cabecalho_nota.numero_nota, cabecalho_nota.serie, cabecalho_nota.fornecedor);
	jQuery("#abasDetalhes").show();
	/*
	 * jQuery("#iframe_imagem").attr('src',"/DocumentViewer/DocumentView?data=" +
	 * current_titulo.emissao + "&fornecedor=" + current_titulo.fornecedor +
	 * "&titulo=" + current_titulo.numero); Removido por não usar portal
	 */

}
function sincronizaDadosTitulo(row) {
	var select_situacao = jQuery("#select_situacao");
	var obs_titulo = jQuery("#obs_titulo");
	if (current_titulo) {
		current_titulo.observacao = obs_titulo.val();
		current_titulo.situacao = select_situacao.val();
	}

	// Titulo selecionado na lista
	current_titulo = dataset.values[row.rowIndex - 1];
	obs_titulo.val(current_titulo.observacao.toString());
	select_situacao.val(current_titulo.situacao.toString());

	/*
	 * Desabilita inputs no caso de Titulo cancelado ou na Atividade Ciencia do
	 * Financeiro
	 */
	var isCienciaFinanceiro = (jQuery("#workflowState").val() == "5");
	if (select_situacao.val() == CANCELADO || isCienciaFinanceiro) {
		obs_titulo.attr("disabled", "disabled");
		select_situacao.attr("disabled", "disabled");
		jQuery("#obs_gestor").removeAttr("disabled");
		jQuery("#select_fin").removeAttr("disabled");
	} else {
		obs_titulo.removeAttr("disabled");
		select_situacao.removeAttr("disabled");
		jQuery("#obs_gestor").attr("disabled", "disabled");
		jQuery("#select_fin").attr("disabled", "disabled");
	}
}
