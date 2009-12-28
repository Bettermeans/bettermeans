//Todos
//on resize window resize controls

var D; //all data

$('document').ready(function(){
	
	//load data
   $.get('dashdata', {project_id: projectID},
            function(data){
				$("#loading").hide();
				D = data;
				prepare_page();
    }, 'json');
    
});

function prepare_page(){
	resize();
	load_ui();
	
	//attach close events to panels?
	
}

// Loads all items in their perspective panels, and sets up panels
function load_ui(){
	for(var i = 0; i < D.length; i++ ){
		$("#pane1_items").append(D[i].subject);
		$("#pane1_items").append('<br />');
	}
}

//resize heights of container and panels
function resize(){
	var newheight = $(window).height() - $('#header').height() - $('#top-menu').height();
	$("#content").height(newheight - 35);
	$("#panel1_list").height(newheight - 57);
	$("#panels").show();
}
// 
// function go(){
// 	alert(D[2].subject);
// }