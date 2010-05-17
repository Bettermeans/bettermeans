$('document').ready(function(){
	
	if (retroStatus == 1){
		$(".closed").hide();		
		$(".open").show();		
	}
	else{
		$(".closed").show();
		$(".open").hide();		
	}
	
	if (belongs){
		$(".private").show();
	}
	else{
		$(".private").hide();
	}
	
	calculate_sum();
	
	$(".slider").slider({
		range: "min",
		value: 0,
		min: 0,
		max: 100,
		step: 2,
		slide: function(event, ui) {
			var user_id = $("#" + this.id).attr("user_id");
			$("#user_" + user_id + "_percentage").html(ui.value + '%');
			calculate_sum();
		}
	});
	
	$(".slider").each(function(){
	 	$("#" + this.id).slider('value',parseInt($("#" + this.id).attr("per")));
	});
});

function calculate_sum(){
	$('#success').hide();
	$('#saving').hide();
	var total = 0;
	$(".percentage_label").each(function() {
		total = total + parseInt($("#" + this.id).html().replace('%',''));
	});
	

	$('#total').html(total + '%');
	if ((total > 95)&&(total < 105)){
		$('#change_retro_link_save').show();
	}
	else{
		$('#change_retro_link_save').hide();
	}
}


function save_retro(retroId){
	$('#saving').show();
	
	var data = "commit=Create";
	var rater_id = currentUserId;
	var confidence = $("#slider_confidence").slider('value');
	var i=0;
	$('#change_retro_link_save').hide();
	
	$(".slider").each(function() {
		var ratee_id = $("#" + this.id).attr("user_id");
		if (ratee_id != "0"){
			var score = $("#" + this.id).slider('value');
			data = data + '&retro_ratings['+i+'][rater_id]=' + rater_id;
			data = data + '&retro_ratings['+i+'][ratee_id]=' + ratee_id;
			data = data + '&retro_ratings['+i+'][score]=' + score;
			data = data + '&retro_ratings['+i+'][retro_id]=' + retroId;
			data = data + '&retro_ratings['+i+'][confidence]=' + confidence;
			i++;
		}
	});
	

    var url = url_for({ controller: 'retro_ratings',
                           action    : 'create'
                          });
	
	$.ajax({
	   type: "POST",
	   dataType: "json",
	   url: url,
	   data: data,
	   success:  	function(html){
			saved();
		},
	   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
		// typically only one of textStatus or errorThrown will have info
		// possible valuees for textstatus "timeout", "error", "notmodified" and "parsererror
		$('#change_retro_link_save').show();
		$.jGrowl("Sorry, couldn't save!", { header: 'Error', position: 'bottom-right' });
		},
		timeout: 30000 //30 seconds
	 });
}

function saved(){
	$('#saving').hide();
	$('#success').show();
}