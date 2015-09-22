function configure_data_table_pedido_compra(filial,nota,serie,fornecedor){
	var DATASET_PREDIDOS = "brv_pag_protheus_pedidos";

	 var paramsDataset = {
	            "datasetName": DATASET_PREDIDOS,
	            "fields": [filial.toString(),nota.toString(),serie.toString(),fornecedor.toString()],
	            "columnTitles": { "pedido": "Pedido",
	                  "emissao": "Emissão",
	                  "item": "Item",
	                  "produto": "Produto",
	                  "descricao": "Descrição",
	                  "unidade": "UN",
	                  "quantidade" : "Qtde",
	                  "valor_unitario": "Valor Unitário",
	                  "valor_total" : "Valor Total",
	                  "centro_custo" : "Centro de Custo",
	                  "observacoes" : "Observações" 
	            }
	      };
   
   try{
       var data = getDatasetAsObject(paramsDataset,null);
   }catch(e){
       alert(e);
       return;
   }
   
   var datatable = data.datatable;
   configureDataTable(datatable);
   renderGrid(datatable, "div_pedidos");
}