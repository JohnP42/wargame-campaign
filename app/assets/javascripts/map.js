var map = function() {

	$("#create-map").on("submit", function(event) {
		event.preventDefault();
		newMap($("#width").val(), $("#height").val());
		
	});

	$("section").on("change", "#select-tile", function(event) {
		$("#show-tile").attr("class", $(this).val());
	});

	$("#map").on("click", "td", function(event) {
		$(this).attr("class", $("#select-tile").val());
	});

	$("#final_form").on("submit", function(event) {
		$("#map_tileset").val(mapToCode());
	});

}

var newMap = function(width, height){
	$("#map").empty();
	for(var y = 0; y < height; y++) {
		var row = $("<tr></tr>");
		for(var x = 0; x < width; x++) {
			row.append("<td width='32px' height='32px' class='tile0'></td>");
		}
		$("#map").append(row);
	}
}

var mapToCode = function(){
	var code = ""

	$("#map tr").each(function() {
		$(this).children("td").each(function() {
			code += $(this).attr("class").slice(-1);
		});
		code += "n"
	});

	return code;
}