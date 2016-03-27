
var campaign = function() {

	click_on_battalion();

	$("section").on("click", ".form_battalion", function(event) {
		$(this).hide();
		$(this).next().show();
	});

	$("section").on("click", ".unit a", function(event) {
		event.preventDefault();

		if ( parseInt($(this).attr("class")) > parseInt($("#gold").attr("class"))) {
			alert("You don't have enough gold");
		}
		else {
			$(this).bind('click', false);
			var anchor_url = $(this).attr("href");
			var unit_id = $(this).attr("id");
			var battalion_id = $(this).closest('div').attr("id");
			var gold = parseInt($("#gold").attr("class"));
			gold -= parseInt($(this).attr("class"));

			var request = $.ajax({
	      url: anchor_url,
	      method: "put",
	      data: {unit_id: unit_id, battalion_id: battalion_id},
	    });

	    request.done( function(data) {
	      $("#"+battalion_id).empty();
	      $("#"+battalion_id).append(data);
	      $("#gold").attr("class", gold.toString());
	      $("#gold").text("Gold: " + gold)
	    })	;
		}
	});

	$("section").on("click", ".building a", function(event) {
		event.preventDefault();

		if (parseInt($(this).attr("class").split(" ")[0]) > parseInt($("#gold").attr("class"))) {
			alert("You don't have enough gold");
		}
		else {
			$(this).bind('click', false);
			var anchor_url = $(this).attr("href");
			var building = $(this).attr("class").split(" ")[1];
			var cost = $(this).attr("class").split(" ")[0]
			var battalion_id = $(this).closest('div').attr("id");
			var gold = parseInt($("#gold").attr("class"));
			gold -= parseInt(cost);

			var request = $.ajax({
	      url: anchor_url,
	      method: "put",
	      data: {building: building, building_price: cost, battalion_id: battalion_id},
	    });

	    request.done( function(data) {
	      $("#"+battalion_id).empty();
	      $("#"+battalion_id).append(data);
	      $("#gold").attr("class", gold.toString());
	      $("#gold").text("Gold: " + gold)
	    });	
		}
	});
}

var click_on_battalion = function() {
	$("#map").on("click", ".icon", function() {
		if ($("main").attr("id").slice(-1) === $(this).attr("class").slice(-1)) {
			battalion_id = $(this).attr("id").substring(4, $(this).attr("id").length);
			$(".battalion").hide();
			$("#" + battalion_id).show();
			$("#selected").attr("id", "");
			$(this).parent().attr("id", "selected");
		}
	});

	$(".btn-direction").on("click", function() {
		if ($("#selected").length) {
			$(".btn-direction").prop('disabled', true);
			var battalion_id = $("#selected").find(".icon").attr("id").substring(4, $("#selected").find(".icon").attr("id").length);
			var direction = $(this).text();
			var url = $(this).attr("value");

			var request = $.ajax({
	      url: url,
	      method: "put",
	      data: {battalion_id: battalion_id, direction: direction},
	    });

	    request.done( function(data) {
	    	$("#map").empty();
	    	$("#map").append(data.map);
	    	$("#" + data.battalion_id).empty();
	    	$("#" + data.battalion_id).append(data.battalion);
	    	$(".battalion").hide();
				$("#" + data.battalion_id).show();
	      $("#selected").attr("id", "");
				$("#icon" + data.battalion_id).parent().attr("id", "selected");
				$(".btn-direction").prop('disabled', false);
	    });	
  	}
	});

}