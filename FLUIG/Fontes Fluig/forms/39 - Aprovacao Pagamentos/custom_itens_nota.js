function configure_itens_nota(filial,nota,serie,fornecedor){
	var DATASET_ITENS_NOTA = "brv_pag_protheus_itens_nota";

	 var paramsDataset = {
	            "datasetName": DATASET_ITENS_NOTA,
	            "fields": [filial.toString(),nota.toString(),serie.toString(),fornecedor.toString()],
	            "columnTitles": {
	            	"item": "Item",
	            	"produto" : "Produto",
	                "descricao": "Descrição",
	                "unidade": "UN",
	                "quantidade": "Qtdade.",
	                "valor_unitario": "Valor unitário",
	                "valor_total": "Valor Total",
	                "valor_icms": "Valor ICMS",
	                "valor_ipi": "Valor IPI"
		            }
	        }; 
    
    try{
        var data = getDatasetAsObject(paramsDataset,null);
    }catch(e){
        alert(e);
        return;
    }
    
    var itens_nota_datatable = data.datatable;
    configureDataTable(itens_nota_datatable);
    renderGrid(itens_nota_datatable, "div_itens_nota");
    
    
}