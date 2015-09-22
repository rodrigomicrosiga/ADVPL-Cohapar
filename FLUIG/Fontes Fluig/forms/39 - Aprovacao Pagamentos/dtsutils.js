function getDatasetAsObject(p, hiddenColumns) {

	var dataset = buscarDataset(p.datasetName, p.fields, p.constraints, p.sortFields);

	var dsColumns = dataset.columns;
	var dsValues = dataset.values;

	var columns = [];
	var rows = [];

	var visibleColumns = dsColumns;
	if (hiddenColumns) {
		visibleColumns = jQuery.grep(dsColumns, function(value) {
			return jQuery.inArray(value.toString(), hiddenColumns) == -1;
		});
	}

	jQuery(visibleColumns).each(function() {
		if (p.columnTitles)
			var columnTitle = p.columnTitles[this];
		if (!columnTitle)
			columnTitle = this;
		var column = {
			"sTitle" : columnTitle,
			"sClass" : this
		};
		columns.push(column);
	});

	jQuery(dsValues).each(function() {
		var dsRow = this;
		var row = [];

		jQuery(visibleColumns).each(function() {
			row.push(dsRow[this]);
		});
		rows.push(row);
	});

	var datasetObj = {
		"aaData" : rows,
		"aoColumns" : columns,
		"bFilter" : false,
		"bInfo" : false,
		"bAutoWidth" : false,
		"bPaginate" : false,
		"bSort" : false,
		"bJQueryUI" : true,
		"oLanguage" : {
			"sProcessing" : "Processando...",
			"sLengthMenu" : "Mostrar _MENU_ registros",
			"sZeroRecords" : "Não foram encontrados resultados",
			"sInfo" : "Mostrando de _START_ até _END_ de _TOTAL_ registros",
			"sInfoEmpty" : "Mostrando de 0 até 0 de 0 registros",
			"sInfoFiltered" : "(filtrado de _MAX_ registros no total)",
			"sInfoPostFix" : "",
			"sSearch" : "Buscar:",
			"sUrl" : "",
			"oPaginate" : {
				"sFirst" : "Primeiro",
				"sPrevious" : "Anterior",
				"sNext" : "Seguinte",
				"sLast" : "Último"
			}
		}
	};

	return {
		"datatable" : datasetObj,
		"dataset" : dataset
	};
}

function buscarDataset(idDataset, fields, constraints, sortFields) {

	var dataset = DatasetFactory.getDataset(idDataset, fields, constraints, sortFields);

	if (!dataset)
		throw "Não foi possí­vel consultar o dataset '" + idDataset + "'";

	var dsColumns = dataset.columns;
	var dsValues = dataset.values;

	if (dsColumns.length == 1 && dsColumns[0] == "erro")
		throw dsValues[0].erro;

	return dataset;

}

function renderGrid(tableObj, containerId) {

	var TABLE_CLASS = "dataTableGrid";

	jQuery("#" + containerId).html(
			'<table cellpadding="0" cellspacing="0" border="0" class="' + TABLE_CLASS + '" id="tbl' + containerId + '"></table>');
	var grid = jQuery("#tbl" + containerId).dataTable(tableObj);

	return grid;

}