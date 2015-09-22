function configure_cabecalho_nota(filial,prefixo,titulo,fornecedor){
	var DATASET_CABECALHO_NOTA = "brv_pag_protheus_cabecalho_nota";

    var params = {
            "datasetName": DATASET_CABECALHO_NOTA,
            "fields": [filial,prefixo,titulo,fornecedor]
     }; 
    
    try{
    	var dataset_cabecalho = buscarDataset(params.datasetName, params.fields, params.constraints, params.sortFields);
    }catch(e){
        var message = e.message ? e.message : e;
        alert(message);
        return;
    }
    
    var numero_nota = ""; 
    var serie = "";
    var numfornecedor = "";
    
    if(dataset_cabecalho && dataset_cabecalho.values && dataset.values.length > 0){
    	 numero_nota = dataset_cabecalho.values[0].numero;
         serie = dataset_cabecalho.values[0].serie;
         numfornecedor = dataset_cabecalho.values[0].num_fornecedor;
        
        jQuery("#idDocumento").val(numero_nota);
        jQuery("#idSerie").val(serie);
        jQuery("#idUF").val(dataset_cabecalho.values[0].uf);
        jQuery("#idEspecie").val(dataset_cabecalho.values[0].especie);
        jQuery("#dtEmissao").val(dataset_cabecalho.values[0].emissao);
        jQuery("#nmFornecedor").val(dataset_cabecalho.values[0].fornecedor);
        jQuery("#vlTotalNota").val(dataset_cabecalho.values[0].valor_total);
        jQuery("#dsCondicaoPagamento").val(dataset_cabecalho.values[0].condicao);	
    }
    
    return {numero_nota: numero_nota, serie: serie, fornecedor: numfornecedor};
    
}