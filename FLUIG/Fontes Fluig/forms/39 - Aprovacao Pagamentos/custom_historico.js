function configure_data_table_historico(filial,prefixo,titulo,parcela,tipo,fornecedor){
	var DATASET_HISTORICO = "brv_pag_protheus_historico";
	 var paramsDataset = {
	            "datasetName": DATASET_HISTORICO,
	            "fields": [filial.toString(),prefixo.toString(),titulo.toString(),parcela.toString(),tipo.toString(),fornecedor.toString()],
	            "columnTitles": {
	            	"ccusto": "C Custo",
	            	"responsavel": "Responsável",
	            	"rateio": "% Rateio",
	            	"valor": "Valor",
	            	"data_aprovacao" : "Data",
	            	"situacao": "Sit. Aprovação",
	                "observacao": "Comentários"
		            }
	        }; 
   
   try{
       var data = getDatasetAsObject(paramsDataset,null);
   }catch(e){
       alert(e);
       return;
   }
   
   var historico_datatable = data.datatable;
   configureDataTable(historico_datatable);
   
   historico_datatable.aoColumnDefs = [ {
		"fnRender" : function(table) {
			if (table.aData[5].toString() == APROVADO) {
				return "<img id=\"img1\" src=\"green_dot.png\">";
			} else if (table.aData[5].toString() == PENDENTE) {
				return "<img id=\"img1\" src=\"yellow_dot.png\">";
			} else if (table.aData[5].toString() == CANCELADO) {
				return "<img id=\"img1\" src=\"gray_dot.png\">";
			} else if (table.aData[5].toString() == REPROVADO) {
				return "<img id=\"img1\" src=\"red_dot.png\">";
			}
		},
		"aTargets" : [ 5 ]
	} ];

	
   renderGrid(historico_datatable, "div_historico");
}