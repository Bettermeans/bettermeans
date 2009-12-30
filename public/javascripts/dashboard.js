//Todos
//on resize window resize controls

var D; //all data

$(window).bind('resize', function() {
	resize();
});

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
	load_ui();
	resize();
	recalculate_widths();
	//attach close events to panels?	
}

// Loads all items in their perspective panels, and sets up panels
function load_ui(){
	insert_panel(0,'open','Open');
	insert_panel(0,'inprogress','In Progress');
	insert_panel(0,'done','Done');
	insert_panel(0,'canceled','Cancelled');
	insert_panel(0,'unknown','Unsorted');
	
	for(var i = 0; i < D.length; i++ ){
		var panelid = '';
		//Deciding on wich panel for this item?
		switch (D[i].status.name){
		case 'Open':
		panelid= 'open_items';
		break;
		case 'Committed':
		panelid = 'inprogress_items';
		break;
		case 'Done':
		panelid = 'done_items';
		break;
		case 'Canceled':
		panelid = 'canceled_items';
		break;
		default : panelid = 'unknown_items';
		}
		add_item(panelid,D[i]);	
	}
	
	$("#open_items").append("<div class='endOfList></div>");
	$("#inprogress_items").append("<div class='endOfList></div>");
	$("#done_items").append("<div class='endOfList></div>");
	$("#canceled_items").append("<div class='endOfList></div>");
	$("#unknown_items").append("<div class='endOfList></div>");
	
}

function add_item(panelid, item){
	html = '';
	html = html + '<div id="item_' + item.id + '" class="item">';
	html = html + '<div id="item_content_' + item.id + '" class="' + item.status.name.replace(" ","-").toLowerCase() + ' hoverable" style="">';
	html = html + '<div class="storyPreviewHeader">';
	html = html + '<div id="item_content_buttons_' + item.id + '" class="storyPreviewButtons">';
	html = html + buttons_for(item);
	html = html + '</div>';

	html = html + '<div class="icons">';
	html = html + '<img id="item_content_icons_editButton_' + item.id + '" class="toggleExpandedButton" src="/images/story_collapsed.png" title="Expand" alt="Expand">';
	html = html + '<div class="left">';
	html = html + '<img class="storyTypeIcon" src="/images/feature_icon.png" alt="Feature">';
	if (item.points != null){
	html = html + '<img class="storyPoints" src="/images/dice_' + item.points + '.png" alt="' + item.points + ' points">';
	}
	
	if (show_comment(item)){
	html = html + '<img class="flyoverIcon" src="/images/story_flyover_icon.png"/>';
	}
	
	html = html + '</div>';
    
	html = html + '</div>';


	html = html + '<div id="item_content_details_' + item.id + '" class="storyPreviewText" style="cursor: move;">';
	
	html = html + item.subject;
	html = html + '</div>';
	html = html + '</div>';
	html = html + '</div>';
	html = html + '</div>';
	// $("#" + panelid).append(D[i].subject);
	$("#" + panelid).append(html);
	
	
}

function buttons_for(item){
	html = '';
	switch (item.status.name){
	case 'Open':
		html = html + button('start',item.id);
	break;
	case 'Committed':
		html = html + button('finish',item.id);
	break;
	case 'Done':
		html = html + button('accept',item.id);
		html = html + button('decline',item.id);
	break;
	case 'Canceled':
		html = html + button('restart',item.id);
	break;
	}
	
	return html;
	
}

//Generates a button type for item id
function button(type,itemId){
	return '<img id="item_content_buttons_' + type + '_button_' + itemId + '" class="stateChangeButton notDblclickable" src="/images/' + type + '.png" onmouseover="this.src=\'/images/' + type + '_hover.png\'" onclick="click_' + type + '(' + itemId + ');" onmouseout="this.src=\'/images/' + type + '.png\'">';
}

function click_start(itemId){
	alert('clicked start for id:' + itemId);
}

function click_accept(itemId){
	alert('clicked accept for id:' + itemId);
}

function click_decline(itemId){
	alert('clicked decline for id:' + itemId);
}

function click_finish(itemId){
	alert('clicked finish for id:' + itemId);
}

function click_restart(itemId){
	alert('clicked restart for id:' + itemId);
}

//returns true if item has a description or any journals that have notes
function show_comment(item){
	// if (item.description != ''){ 
	// 	return true;
	// }
	
	for(var i = 0; i < item.journals.length; i++ ){
			if (item.journals[i].notes != ''){
				return true;
			}
		}
	
	return false;
}

//resize heights of container and panels
function resize(){
	var newheight = $(window).height() - $('#header').height() - $('#top-menu').height();
	$("#content").height(newheight - 35);
	$(".list").height(newheight - 65);
	$("#panels").show();
}

function insert_panel(position, name, title){
	var panelHtml = '';
	panelHtml = panelHtml + "	<td id='" + name + "_panel' class='panel'>";
	panelHtml = panelHtml + "<div class='panelHeaderRight'></div>";
	panelHtml = panelHtml + "<div class='panelHeaderLeft'></div>";
	panelHtml = panelHtml + "<div class='panelHeader'>";
	panelHtml = panelHtml + "  <a href='javascript:void(0)' class='closePanel panelLink' id='" + name + "_close' title='Close panel' onclick='close_panel(\"" + name + "\")'></a>";
	panelHtml = panelHtml + "  <span class='panelTitle'>" + title + "</span>";
	panelHtml = panelHtml + "</div>";
	panelHtml = panelHtml + "<div id='" + name + "_list' class='list'>";
	panelHtml = panelHtml + "  <div id='" + name + "_items' class='items'>";
	panelHtml = panelHtml + "  </div>";
	panelHtml = panelHtml + "</div>";
	panelHtml = panelHtml + "</td>";
	$("#main_row").append(panelHtml);
}

function close_panel(name){
	$('#' + name + '_panel').hide();
	recalculate_widths();
}

function show_panel(name){
	$('#' + name + '_panel').show();
	recalculate_widths();
}

function recalculate_widths(){
	new_width = $('#content').width() / $('.panel:visible').length;
	// $('.panel:visible').animate({width: new_width},1500);
	$('.panel:visible').width(new_width);
}

// 
// function go(){
// 	alert(D[2].subject);
// }