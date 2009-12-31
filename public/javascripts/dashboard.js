//Todos
//scroll bary for flyover
//cleaner times/dates in flyover
//flyover should stay open if I hover over it
//max height for flyover
//bugbug: flyover appears even 
//toggle buttons to turn panels on and off
//bugbug: flyover appears when i hover over expand item button


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

$.fn.makeAbsolute = function(rebase) {

    return this.each(function() {

        var el = $(this);

        var pos = el.position();

        el.css({ position: "absolute",

            marginLeft: 0, marginTop: 0,

            top: pos.top, left: pos.left });

        if (rebase)

            el.remove().appendTo("body");

    });

};

function prepare_page(){
	load_ui();
	resize();
	recalculate_widths();
}

// Loads all items in their perspective panels, and sets up panels
function load_ui(){
	insert_panel(0,'new','New');
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
		add_item(panelid,i);	
	}

	$("#fresh_items").append("<div class='endOfList></div>");
	$("#open_items").append("<div class='endOfList></div>");
	$("#inprogress_items").append("<div class='endOfList></div>");
	$("#done_items").append("<div class='endOfList></div>");
	$("#canceled_items").append("<div class='endOfList></div>");
	$("#unknown_items").append("<div class='endOfList></div>");
	
	$(".hoverIcon").hover(
	      function () {
			show_flyover(Number(this.id.split('_')[1].replace(/"/g,'')));
	      }, 
	      function () {
			hide_flyover(Number(this.id.split('_')[1].replace(/"/g,'')));
     	  }
	    );
	
	
}

function show_flyover(dataId){
	$('.overlay').hide();
	
	//If flyover hasn't already been generated, then generate it!
	if ($('#flyover_' + dataId).length == 0){
		generate_flyover(dataId);		
		$('#flyover_' + dataId).makeAbsolute(); //re-basing off of main window
	}
	
 	$('#flyover_' + dataId).show();

	var target_id = '#item_content_details_' + dataId;
	// target_id = "#wrapper";

	$('#flyover_' + dataId).position({
	    	my: "left top",
			at: "left top",
	    	of: target_id,
			offset: "80 9",
		    // offset: $('#item_' + dataId).position().left + ' ' + $('#item_' + dataId).position().top
		    collision: "fit flip"
		  	});
	
	
}

function hide_flyover(dataId){
	$('#flyover_' + dataId).hide();
}

function add_item(panelid, dataId){
	var html = generate_item(dataId);
	$("#" + panelid).append(html);
}

function generate_flyover(dataId){
	console.log('data id:' + dataId  + D);
	item = D[dataId];
	
	var html = '';
	
	html = html + '<div id="flyover_' + dataId + '" class="overlay" style="display:none;">';
	html = html + '<div style="border: 0pt none ; margin: 0pt;">';
	html = html + '<div class="overlayContentWrapper storyFlyover flyover" style="width: 475px;">';
	html = html + '<div class="storyTitle">';
	html = html + item.subject;
	html = html + '</div>';
	html = html + '	      <div class="sectionDivider">';
	html = html + '	      <div style="height: auto;">';
	html = html + '	        <div class="metaInfo">';
	html = html + '	          <div class="left">';
	html = html + 'Requested by ' + item.author.firstname + ' ' + item.author.lastname + ' on ' + item.created_on;
	html = html + '	          </div>';
	html = html + '<div class="right infoSection">';
	html = html + '	            <img class="estimateIcon left" width="18" src="/images/dice_' + item.points + '.png" alt="Estimate: ' + item.points + ' points" title="Estimate: ' + item.points + ' points">';
	html = html + '	            <div class="left text">';
	html = html + '	              ' + item.points + ' pts';
	html = html + '	            </div>';
	html = html + '	            <div class="clear"></div>';
	html = html + '	          </div>';
	html = html + '	          <div class="right infoSection">';
	html = html + '	            <img class="left" src="/images/feature_icon.png" alt="Feature">';
	html = html + '	            <div class="left text">';
	html = html + '	              Feature';
	html = html + '	            </div>';
	html = html + '	            <div class="clear"></div>';
	html = html + '	          </div>';
	html = html + '	          <div class="clear"></div>';
	html = html + '	        </div>';
	html = html + '	        <div class="flyoverContent storyDetails">';
	html = html + '	          <div class="storyId right">';
	html = html + '	            <span>ID:</span> <span>' + item.id + '</span>';
	html = html + '	          </div>';
	html = html + '	<div class="section">';
	html = html + generate_flyover_description(item);
	html = html + generate_flyover_comments(item);
	html = html + '&nbsp;</div>';
	html = html + '	        </div>';
	html = html + '	      </div>';
	html = html + '	    </div>';
	html = html + '	  </div>';
	html = html + '	</div>';
	
	$('#flyovers').append(html);
	
	return html;
}

function generate_flyover_description(item){

	if (item.description.length<3){return '';};
	
	var html = '';
	html = html + '	  <div class="header">';
	html = html + '	    Description';
	html = html + '	  </div>';
	html = html + '	  <table class="notesTable">';
	html = html + '	    <tbody>';
	html = html + '<tr class="noteInfoRow">';
	html = html + '<td class="noteInfo">';
	html = html + '<span class="highlight">' + item.description + '</span>';
 	html = html + '</td>';
  	html = html + '</tr>';
	html = html + '	    </tbody>';
	html = html + '	  </table>';
	html = html + '	<div class="clear"></div>';
	return html;
	
}

function generate_flyover_comments(item){

	var count = 0;
	for(var k = 0; k < item.journals.length; k++ ){
			if (item.journals[k].notes != ''){
				count++;
			}
	}
	
	if (count==0){return '';};
	
	var html = '';
	html = html + '	  <div class="header">';
	html = html + '	    Comments <span class="commentCount">(' + count + ')</span>';
	html = html + '	  </div>';
	html = html + '	  <table class="notesTable">';
	html = html + '	    <tbody>';
	
	for(var i = 0; i < item.journals.length; i++ ){
			if (item.journals[i].notes != '' && item.journals[i].notes != null){
						var author = item.journals[i].user.firstname + ' ' + item.journals[i].user.lastname;
						var note = '';
						if (item.journals[i].notes.indexOf('wrote:') > -1)
						{
							var note_array = item.journals[i].notes.split('\n');
							for(var j = 1; j < note_array.length; j++ ){
								if (note_array[j][0]!='>'){note = note + note_array[j] + '\n';};
							}
						}
						else
						{
							note = item.journals[i].notes.replace(/\r\n/g,"<br>");
						}
						html = html + '<tr class="noteInfoRow">';
				        html = html + '<td class="noteInfo">';
				        html = html + '<span class="highlight">' + author + '</span> <span class="italic">' + item.journals[i].created_on + '</span>';
				        html = html + '</td>';
				        html = html + '</tr>';
				        html = html + '<tr class="noteTextRow">';
				        html = html + '<td class="noteText">';
				        html = html + note;
				        html = html + '</td>';
				        html = html + '</tr>';
			}
	}
	html = html + '	    </tbody>';
	html = html + '	  </table>';
	html = html + '	<div class="clear"></div>';
	return html;
	
}



//Generates html for collapsed item
function generate_item(dataId){
	var item = D[dataId];
	var html = '';
	html = html + '<div id="item_' + dataId + '" class="item">';
	html = html + '<div id="item_content_' + dataId + '" class="' + item.status.name.replace(" ","-").toLowerCase() + ' hoverable" style="">';
	html = html + '<div class="storyPreviewHeader">';
	html = html + '<div id="item_content_buttons_' + dataId + '" class="storyPreviewButtons">';
	html = html + buttons_for(dataId);
	html = html + '</div>';

	html = html + '<div id=icons_"' + dataId + '" class="icons">'; //The id of this div is used to lookup the item to generate the flyover
	html = html + '<img id="item_content_icons_editButton_' + dataId + '" class="toggleExpandedButton" src="/images/story_collapsed.png" title="Expand" alt="Expand" onclick="expand_item(' + dataId + ');">';
	html = html + '<div class="left">';
	html = html + '<img id=featureicon_"' + dataId + '"  class="storyTypeIcon hoverIcon" src="/images/feature_icon.png" alt="Feature">';
	if (item.points != null){
	html = html + '<img id=diceicon_"' + dataId + '"  class="storyPoints hoverIcon" src="/images/dice_' + item.points + '.png" alt="' + item.points + ' points">';
	}
	
	if (show_comment(item)){
	html = html + '<img id=flyovericon_"' + dataId + '"  class="flyoverIcon hoverIcon" src="/images/story_flyover_icon.png"/>';
	}
	
	html = html + '</div>';
    
	html = html + '</div>';


	html = html + '<div id="item_content_details_' + dataId + '" class="storyPreviewText" style="cursor: move;">';
	
	html = html + item.subject;
	html = html + '</div>';
	html = html + '</div>';
	html = html + '</div>';
	html = html + '</div>';
	return html;
}

function buttons_for(dataId){
	html = '';
	switch (D[dataId].status.name){
	case 'Open':
		html = html + button('start',dataId);
	break;
	case 'Committed':
		html = html + button('finish',dataId);
	break;
	case 'Done':
		html = html + button('accept',dataId);
		html = html + button('reject',dataId);
	break;
	case 'Canceled':
		html = html + button('restart',dataId);
	break;
	}
	
	return html;
	
}

//Generates a button type for item id
function button(type,dataId){
	return '<img id="item_content_buttons_' + type + '_button_' + dataId + '" class="stateChangeButton notDblclickable" src="/images/' + type + '.png" onmouseover="this.src=\'/images/' + type + '_hover.png\'" onclick="click_' + type + '(' + dataId + ');" onmouseout="this.src=\'/images/' + type + '.png\'">';
}

function click_start(dataId){
	alert('clicked start for id:' + dataId);
}

function click_accept(dataId){
	alert('clicked accept for id:' + dataId);
}

function click_reject(dataId){
	alert('clicked reject for id:' + dataId);
}

function click_finish(dataId){
	alert('clicked finish for id:' + dataId);
}

function click_restart(dataId){
	alert('clicked restart for id:' + dataId);
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
	$(".list").height(newheight - 75);
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

function expand_item(dataId){
	$('#item_' + dataId).html('<img id="item_content_icons_editButton_' + dataId + '" class="toggleExpandedButton" src="/images/story_expanded.png" title="Collapse" alt="Collapse" onclick="collapse_item(' + dataId + ');">xxx');
}

function collapse_item(dataId){
	$('#item_' + dataId).html(generate_item(dataId));
}

// 
// function go(){
// 	alert(D[2].subject);
// }