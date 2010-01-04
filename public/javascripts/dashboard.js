//Todos
//scroll bary for flyover
//cleaner times/dates in flyover
//flyover should stay open if I hover over it
//max height for flyover
//help hover overs (question marks)
//order items by priority? or updated?
//little hover over question marks for each panel describing whay they are
//"my work" panel
//somewhere in the "new item" tool tip, let them know that pressing the 'n' key activates the new item (should also be a tooltip for the new request button)
//what are the types of requests? feature? chore? or do we hide this functionality for now? keep it simple!
//keyboard shortcut for each panel
//Scroll form to top of panel when editing
//Handle errors in javascript
//Order comments chronologically
//Animate panels
//BUGBUG: flyovers don't work in safari
//TODO: test in IE
//detect and insert bold and italic text (time to learn regular expresssion :)
//auto-expanding boxes for description and comments
//minifiy this file will be over 50k!
//watermark is not grey, still black
//test for javascript and warn if user has it off
//error handling for poor connectivity (couldn't load page! couldn't update item! couldn't save new item! couldn't save post!)


var D; //all data
var keyboard_shortcuts = false;
var default_new_title = 'Enter Title Here';
var new_comment_text = 'Add new comment';

$(window).bind('resize', function() {
	resize();
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

$.fn.watermark = function(css, text) {
		$(this).focus(function() {
			$(this).filter(function() {
				return $(this).val() == "" || $(this).val() == text;
			}).removeClass(css).val("");
		});

		$(this).blur(function() {
			$(this).filter(function() {
				return $(this).val() == "";
			}).addClass(css).val(text);
		});
		
		var input = $(this);
		$(this).closest("form").submit(function() {
			input.filter(function() {
				return $(this).val() == text;
			}).val("");
		});
		
		$(this).addClass(css).val(text);
};

$.fn.keyboard_sensitive = function() {
		$(this).focus(function() {
			keyboard_shortcuts = false;	
		});

		$(this).blur(function() {
			keyboard_shortcuts = true;	
		});
};


$('document').ready(function(){
	
		keyboard_shortcuts = false;
		
	
	   $.get('dashdata', {project_id: projectID},
	            function(data){
				$("#loading").hide();
				D = data;
				prepare_page();
	    }, 'json');
	
		load_buttons();
    
});

// listens for any navigation keypress activity
$(document).keypress(function(e)
{
	if (!keyboard_shortcuts){return;};
	
	switch(e.which)
	{
		// user presses the "a"
		case 110:	new_item();
					break;	
					
	}
});

//makes all text boxes sensitive to keyboard shortcuts
function make_text_boxes_toggle_keyboard_shortcuts(){
	$("input").keyboard_sensitive();
	$("textarea").keyboard_sensitive();
}


function load_buttons(){
	$('#main-menu').append('<input id="new_request" value="New Request" type="submit" onclick="new_item();return false;" class="dashboard-button" style="margin-left: 20px;"/>');
}



function prepare_page(){
	load_ui();
	resize();
	recalculate_widths();
	keyboard_shortcuts = true;	
	make_text_boxes_toggle_keyboard_shortcuts();
}

// Loads all items in their perspective panels, and sets up panels
function load_ui(){
	insert_panel(0,'new','New',true);
	insert_panel(0,'open','Open',true);
	insert_panel(0,'inprogress','In Progress',true);
	insert_panel(0,'done','Done',true);
	insert_panel(0,'canceled','Cancelled',false);
	insert_panel(0,'unknown','Unsorted',false);
	
	for(var i = 0; i < D.length; i++ ){
		add_item(i,"bottom");	
	}

	$("#new_items").append("<div class='endOfList></div>");
	$("#open_items").append("<div class='endOfList></div>");
	$("#inprogress_items").append("<div class='endOfList></div>");
	$("#done_items").append("<div class='endOfList></div>");
	$("#canceled_items").append("<div class='endOfList></div>");
	$("#unknown_items").append("<div class='endOfList></div>");
	
	add_hover_icon_events();	
}

function add_hover_icon_events(){
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

function add_item(dataId,position){
	var panelid = '';
	//Deciding on wich panel for this item?
	switch (D[dataId].status.name){
	case 'New':
	panelid= 'new_items';
	break;
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
	
	var html = generate_item(dataId);
	if (position=="bottom")
	{
		$("#" + panelid).append(html);
	}
	else
	{
		$("#" + panelid).prepend(html);
	}
}

function generate_flyover(dataId){
	var item = D[dataId];
	
	var points;
	item.points == null ? points = 'No' : points = item.points;
	
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
	html = html + '	            <img class="estimateIcon left" width="18" src="/images/dice_' + points + '.png" alt="Estimate: ' + points + ' points" title="Estimate: ' + points + ' points">';
	html = html + '	            <div class="left text">';
	html = html + '	              ' + points + ' pts';
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
	html = html + generate_comments(item,true);
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

	if (item.description == null || item.description.length < 3){return '';};
	
	var html = '';
	html = html + '	  <div class="header">';
	html = html + '	    Description';
	html = html + '	  </div>';
	html = html + '	  <table class="notesTable">';
	html = html + '	    <tbody>';
	html = html + '<tr class="noteInfoRow">';
	html = html + '<td class="noteInfo">';
	html = html + '<span class="specialhighlight">' + item.description + '</span>';
 	html = html + '</td>';
  	html = html + '</tr>';
	html = html + '	    </tbody>';
	html = html + '	  </table>';
	html = html + '	<div class="clear"></div>';
	return html;
	
}

//blank_if_no_comments: when true, nothing is returned if there aren't any comments, when false the header is returned
function generate_comments(item,blank_if_no_comments){

	var count = 0;
	for(var k = 0; k < item.journals.length; k++ ){
			if (item.journals[k].notes != '' && item.journals[k].notes != null){
				count++;
			}
	}
	
	if (count==0 && blank_if_no_comments){return '';};
	
	var html = '';
	html = html + '	  <div class="header">';
	html = html + '	    Comments <span class="commentCount">(' + count + ')</span>';
	html = html + '	  </div>';
	html = html + '	  <table class="notesTable" id="notesTable_' + item.id + '">';
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
				html = html + generate_comment(author,note,item.journals[i].created_on);
			}
	}
	html = html + '	    </tbody>';
	html = html + '	  </table>';
	html = html + '	<div class="clear"></div>';
	return html;
	
}

function generate_comment(author,note,created_on){
	var html = '';
	html = html + '<tr class="noteInfoRow">';
	html = html + '<td class="noteInfo">';
	html = html + '<span class="specialhighlight">' + author + '</span> <span class="italic">' + created_on + '</span>';
	html = html + '</td>';
	html = html + '</tr>';
    html = html + '<tr class="noteTextRow">';
	html = html + '<td class="noteText">';
	html = html + note;
	html = html + '</td>';
	html = html + '</tr>';
	return html;
	
}

//Generates html for collapsed item
function generate_item(dataId){
	var item = D[dataId];
	var html = '';
	var points;
	item.points == null ? points = 'No' : points = item.points;
	
	html = html + '<div id="item_' + dataId + '" class="item">';
	html = html + '<div id="item_content_' + dataId + '" class="' + item.status.name.replace(" ","-").toLowerCase() + ' hoverable" style="">';
	html = html + '<div class="storyPreviewHeader">';
	html = html + '<div id="item_content_buttons_' + dataId + '" class="storyPreviewButtons">';
	html = html + buttons_for(dataId);
	html = html + '</div>';

	html = html + '<div id="icons_' + dataId + '" class="icons">'; //The id of this div is used to lookup the item to generate the flyover
	html = html + '<img id="item_content_icons_editButton_' + dataId + '" class="toggleExpandedButton" src="/images/story_collapsed.png" title="Expand" alt="Expand" onclick="expand_item(' + dataId + ');return false;">';
	html = html + '<div id="icon_set_' + dataId + '" class="left">';
	html = html + '<img id="featureicon_' + dataId + '"  class="storyTypeIcon hoverIcon" src="/images/feature_icon.png" alt="Feature">';
	html = html + '<img id="diceicon_' + dataId + '"  class="storyPoints hoverIcon" src="/images/dice_' + points + '.png" alt="' + points + ' points">';
	
	if (show_comment(item)){
	html = html + '<img id="flyovericon_' + dataId + '"  class="flyoverIcon hoverIcon" src="/images/story_flyover_icon.png"/>';
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
	return '<img id="item_content_buttons_' + type + '_button_' + dataId + '" class="stateChangeButton notDblclickable" src="/images/' + type + '.png" onmouseover="this.src=\'/images/' + type + '_hover.png\'" onclick="click_' + type + '(' + dataId + ');return false;" onmouseout="this.src=\'/images/' + type + '.png\'">';
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
			if (item.journals[i].notes != '' && item.journals[i].notes != null){
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

function insert_panel(position, name, title, visible){
	var panel_style = "";
	var button_style = "";
	if (!visible){panel_style = 'style="display:none;"';}
	if (visible){button_style = 'style="display:none;"';}
	// visible ? panel_style = 'block' : panel_style = 'none';

	var panelHtml = '';
	panelHtml = panelHtml + "	<td id='" + name + "_panel' class='panel' " + panel_style + "'>";
	panelHtml = panelHtml + "<div class='panelHeaderRight'></div>";
	panelHtml = panelHtml + "<div class='panelHeaderLeft'></div>";
	panelHtml = panelHtml + "<div class='panelHeader'>";
	panelHtml = panelHtml + "  <a href='javascript:void(0)' class='closePanel panelLink' id='" + name + "_close' title='Close panel' onclick='close_panel(\"" + name + "\");return false;'></a>";
	panelHtml = panelHtml + "  <span class='panelTitle'>" + title + "</span>";
	panelHtml = panelHtml + "</div>";
	panelHtml = panelHtml + "<div id='" + name + "_list' class='list'>";
	panelHtml = panelHtml + "  <div id='" + name + "_items' class='items'>";
	panelHtml = panelHtml + "  </div>";
	panelHtml = panelHtml + "</div>";
	panelHtml = panelHtml + "</td>";
	$('#main-menu').append('<input id="' + name + '_panel_toggle" value="' + title + '" type="submit" onclick="show_panel(\'' + name + '\');return false;" class="dashboard-button" ' + button_style + '/>');
	$("#main_row").append(panelHtml);
}

function close_panel(name){
	$('#' + name + '_panel').hide();
	$('#' + name + '_panel_toggle').show();	
	recalculate_widths();
	if (name == "new"){keyboard_shortcuts = true;} //If we're closing the new panel, then we want keyboard shortcuts to be on again, in case they were off
}

function show_panel(name){
	$('#' + name + '_panel').show();
	$('#' + name + '_panel_toggle').hide();
	recalculate_widths();
}

function recalculate_widths(){
	new_width = $('#content').width() / $('.panel:visible').length;
	$('.panel:visible').width(new_width);
}

function expand_item(dataId){
	$('#item_' + dataId).html(generate_item_edit(dataId));
	$('#new_comment_' + dataId).watermark('watermark',new_comment_text);
	make_text_boxes_toggle_keyboard_shortcuts();
}

function collapse_item(dataId){
	$('#item_' + dataId).html(generate_item(dataId));
	add_hover_icon_events();	
}

function save_new_item(){
	if (($('#new_title_input').val() == default_new_title) || ($('#new_title_input').val() == ''))
	{
		alert('Please enter a title');
		return false;
	}
	var data = "commit=Create&project_id=" + projectID + "&issue[subject]=" + $('#new_title_input').val() + "&issue[description]=" + $('#new_description').val();

    var url = url_for({ controller: 'issues',
                           action    : 'new'
                          });

	$("#new_item_wrapper").html('<div id="loading"> Adding...</div>');

	$.post(url, 
		   data, 
		   	function(html){
				item_added(html);
			}, //TODO: handle errors here
			"json" //BUGBUG: is this a security risk?
	);
	
	return false;
}

function save_edit_item(dataId){
	if (($('#edit_title_input_' + dataId).val() == default_new_title) || ($('#edit_title_input_' + dataId).val() == ''))
	{
		alert('Please enter a title');
		return false;
	}	
	var data = "commit=Submit&project_id=" + projectID + "&id=" + D[dataId].id + "&issue[subject]=" + $('#edit_title_input_' + dataId).val() + "&issue[description]=" + $('#edit_description_' + dataId).val();

    var url = url_for({ controller: 'issues',
                           action    : 'edit'
                          });

	$("#edit_item_" + dataId).html(generate_item(dataId));
	$("#item_content_icons_editButton_" + dataId).remove();
	$("#icon_set_" + dataId).addClass('updating');

	$.post(url, 
		   data, 
		   	function(html){
				item_updated(html, dataId);
			}, //TODO: handle errors here
			"json" //BUGBUG: is this a security risk?
	);
	
	return false;
}

function cancel_new_item(dataId){
	$("#new_item_wrapper").remove();
	keyboard_shortcuts = true;
	return false;
}

function cancel_edit_item(dataId){
	$("#edit_item_" + dataId).html(generate_item(dataId));
	keyboard_shortcuts = true;
	return false;
}


function item_added(item){
	$("#new_item_wrapper").remove();
	D.push(item); 
	add_item(D.length-1,"top");
	add_hover_icon_events();
	keyboard_shortcuts = true;
	return false;
}

function item_updated(item, dataId){
	D[dataId] = item; 
	$("#edit_item_" + dataId).html(generate_item(dataId));
	add_hover_icon_events();
	keyboard_shortcuts = true;
	$('#flyover_' + dataId).remove(); //removing flyover because data in it is outdated
	return false;
}

function comment_added(item, dataId){
	D[dataId] = item; 
	$('#flyover_' + dataId).remove(); //removing flyover because data in it is outdated
}

function new_item(){
keyboard_shortcuts = false;
$("#new_item_wrapper").remove();
html = '';	
html = html + '	<div class="item" id="new_item_wrapper">';
html = html + '	  <div class="storyItem unscheduled unestimatedText underEdit" id="icebox_itemList_storynewStory_content">';
html = html + '	   <form action="#">';
html = html + '	    <div class="storyPreviewHeader">';
html = html + '	      <div class="storyPreviewInput">';
html = html + '	        <input id="new_title_input" class="titleInputField" name="title_input" value="" type="text">';
html = html + '	      </div>';
html = html + '	    </div>';
html = html + '	    <div>';
html = html + '	      <div id="new_details" class="storyDetails">';
html = html + '	          <table class="storyDetailsTable">';
html = html + '	            <tbody>';
html = html + '	              <tr>';
html = html + '	                <td>';
html = html + '	                  <div class="storyDetailsButton">';
html = html + '	                    <input id="new_save_button" value="Save" type="submit" onclick="save_new_item();return false;">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td>';
html = html + '	                  <div class="storyDetailsButton">';
html = html + '	                    <input id="new_cancel_button" value="Cancel" type="submit" onclick="cancel_new_item();return false;">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td>';
html = html + '	                  <div class="storyDetailsButton">';
html = html + '	                    <input disabled="disabled" id="new_delete_button" value="Delete" type="submit">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td>';
html = html + '	                  <div class="storyDetailsButton">';
html = html + '	                    <input disabled="disabled" id="new_view_history_button" value="View history" type="submit">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	              </tr>';
html = html + '	            </tbody>';
html = html + '	          </table>';
html = html + '	          <table class="storyDetailsTable">';
html = html + '	            <tbody>';
html = html + '	              <tr>';
html = html + '	                <td class="letContentExpand" colspan="1">';
html = html + '	                  <div>';
html = html + '	                    <select id="new_story_type" class="storyDetailsField" name="new_story_type">';
html = html + '	                      <option selected="true" value="feature">';
html = html + '	                        Feature';
html = html + '	                      </option>';
html = html + '	                      <option value="bug">';
html = html + '	                        Bug';
html = html + '	                      </option>';
html = html + '	                      <option value="chore">';
html = html + '	                        Chore';
html = html + '	                      </option>';
html = html + '	                      <option value="release">';
html = html + '	                        Release';
html = html + '	                      </option>';
html = html + '	                    </select>';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td class="storyDetailsLabelIcon" colspan="1">';
html = html + '	                  <div class="storyDetailsLabelIcon">';
html = html + '	                    <img src="/images/feature_icon.png" id="new_story_type_image" name="new_story_type_image">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td class="helpIcon lastCell" colspan="1">';
html = html + '	                  <div class="helpIcon" id="story_newStory_details_help_story_types">';
html = html + '	                    <img src="/images/question_mark.gif">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	              </tr>';
html = html + '	            </tbody>';
html = html + '	          </table>';
html = html + '	          <div class="section">';
html = html + '	            <table class="storyDescriptionTable">';
html = html + '	              <tbody>';
html = html + '	                <tr>';
html = html + '	                  <td class="header">';
html = html + '	                    <div>';
html = html + '	                      Description';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                  <td class="lastCell">';
html = html + '	                    <div class="helpIcon">';
html = html + '	                      <img src="/images/question_mark.gif">';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                </tr>';
html = html + '	                <tr>';
html = html + '	                  <td colspan="5">';
html = html + '	                    <div>';
html = html + '	                      <textarea class = "textAreaFocus" id="new_description" rows="3" cols="20" name="story[description]"></textarea>     ';
html = html + '	                    <div>';
html = html + '	                        (Format using *<b>bold</b>* and _<i>italic</i>_ text.)';
html = html + '	                      </div>';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                </tr>';
html = html + '	              </tbody>';
html = html + '	            </table>';
html = html + '	          </div>';
html = html + '	      </div>';
html = html + '	    </div>';
html = html + '    </form>';
html = html + '	  </div>';
html = html + '	</div>';

show_panel('new');
$("#new_items").prepend(html);
$("#new_title_input").val(default_new_title).select();	
make_text_boxes_toggle_keyboard_shortcuts();
}

function generate_item_edit(dataId){
html = '';	
html = html + '	<div class="item" id="edit_item_' + dataId + '">';
html = html + '	  <div class="storyItem underEdit" id="editItem_content_' + dataId + '">';
html = html + '	   <form action="#">';
html = html + '	    <div class="storyPreviewHeader">';
html = html + ' 		<img id="item_content_icons_editButton_' + dataId + '" class="toggleExpandedButton" src="/images/story_expanded.png" title="Collapse" alt="Collapse" onclick="collapse_item(' + dataId + ');return false;">';
html = html + '	      <div class="storyPreviewInput">';
html = html + '	        <input id="edit_title_input_' + dataId + '" class="titleInputField" name="title_input" value="' + D[dataId].subject + '" type="text">';
html = html + '	      </div>';
html = html + '	    </div>';
html = html + '	    <div>';
html = html + '	      <div id="edit_details_' + dataId + '" class="storyDetails">';
html = html + '	          <table class="storyDetailsTable">';
html = html + '	            <tbody>';
html = html + '	              <tr>';
html = html + '	                <td>';
html = html + '	                  <div class="storyDetailsButton">';
html = html + '	                    <input id="edit_save_button' + dataId + '" value="Save" type="submit" onclick="save_edit_item(' + dataId + ');return false;">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td>';
html = html + '	                  <div class="storyDetailsButton">';
html = html + '	                    <input id="edit_cancel_button' + dataId + '" value="Cancel" type="submit" onclick="cancel_edit_item(' + dataId + ');return false;">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td>';
html = html + '	                  <div class="storyDetailsButton">';
html = html + '	                    <input id="edit_view_history_button" value="View history" type="submit" onclick="view_history(' + dataId + ');return false;">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	              </tr>';
html = html + '	            </tbody>';
html = html + '	          </table>';
html = html + '	          <table class="storyDetailsTable">';
html = html + '	            <tbody>';
html = html + '	              <tr>';
html = html + '	                <td class="letContentExpand" colspan="1">';
html = html + '	                  <div>';
html = html + '	                    <select id="edit_story_type_' + dataId + '" class="storyDetailsField" name="edit_story_type">';
html = html + '	                      <option selected="true" value="feature">';
html = html + '	                        Feature';
html = html + '	                      </option>';
html = html + '	                      <option value="bug">';
html = html + '	                        Bug';
html = html + '	                      </option>';
html = html + '	                      <option value="chore">';
html = html + '	                        Chore';
html = html + '	                      </option>';
html = html + '	                      <option value="release">';
html = html + '	                        Release';
html = html + '	                      </option>';
html = html + '	                    </select>';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td class="storyDetailsLabelIcon" colspan="1">';
html = html + '	                  <div class="storyDetailsLabelIcon">';
html = html + '	                    <img src="/images/feature_icon.png" id="edit_story_type_image" name="edit_story_type_image">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td class="helpIcon lastCell" colspan="1">';
html = html + '	                  <div class="helpIcon" id="story_newStory_details_help_story_types' + dataId + '">';
html = html + '	                    <img src="/images/question_mark.gif">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	              </tr>';
html = html + '	            </tbody>';
html = html + '	          </table>';

html = html + '	          <div class="section">';
html = html + '	            <table class="storyDescriptionTable">';
html = html + '	              <tbody>';
html = html + '	                <tr>';
html = html + '	                  <td class="header">';
html = html + '	                    <div>';
html = html + '	                      Description';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                  <td class="lastCell">';
html = html + '	                    <div class="helpIcon">';
html = html + '	                      <img src="/images/question_mark.gif">';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                </tr>';
html = html + '	                <tr>';
html = html + '	                  <td colspan="5">';
html = html + '	                    <div>';
html = html + '	                      <textarea class = "textAreaFocus" id="edit_description_' + dataId + '" rows="3" cols="20" name="story[description]">' + D[dataId].description + '</textarea>     ';
html = html + '	                    <div>';
html = html + '	                        (Format using *<b>bold</b>* and _<i>italic</i>_ text.)';
html = html + '	                      </div>';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                </tr>';
html = html + '	              </tbody>';
html = html + '	            </table>';
html = html + '	          </div>';

//comments

html = html + '	          <div class="section">';
html = html + '	            <table class="storyDescriptionTable">';
html = html + '	              <tbody>';
html = html + '	                <tr>';
html = html + generate_comments(D[dataId],false);
html = html + '	                </tr>';
html = html + '	                <tr>';
html = html + '	                  <td colspan="5">';
html = html + '	                    <div>';
html = html + '	                      <textarea class = "textAreaFocus" id="new_comment_' + dataId + '" rows="3" cols="20" name="story[comment]"></textarea>     ';
html = html + '	                    <div>';
html = html + '	                    <input value="Post Comment" type="submit" onclick="post_comment(' + dataId + '); return false;">';
html = html + '	                        (Format using *<b>bold</b>* and _<i>italic</i>_ text.)';
html = html + '	                      </div>';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                </tr>';
html = html + '	              </tbody>';
html = html + '	            </table>';
html = html + '	          </div>';


html = html + '	      </div>';
html = html + '	    </div>';
html = html + '    </form>';
html = html + '	  </div>';
html = html + '	</div>';
return html;
}

function post_comment(dataId){
try{
	var text = $("#new_comment_" + dataId).val();
	if ((text == null) || (text.length < 2)|| (text == new_comment_text)){
		return false;
	}
	else
	{
		var item = D[dataId];
		$("#notesTable_" + item.id).append(generate_comment(currentUser,text.replace(/\n/g,"<br>"),Date())); //TODO: properly format this date
		$('#new_comment_' + dataId).val('');
		
		var data = "commit=Create&issue_id=" + item.id + "&comment=" + text;
		
		var url = url_for({ controller: 'comments',
	                           action    : 'create'
	                          });
	
		$.post(url, 
			   data, 
			   	function(html){
					comment_added(html,dataId);
				}, //TODO: handle errors here
				"json" //BUGBUG: is this a security risk?
		);
		return false;
	}
	}
catch(err){
	console.log(err);
	return false;
}
}

//View item history
function view_history(dataId){
	return false;
	
}


///HELPERS
function url_for(options){
  // THINKABOUTTHIS: Is it worth using Rails' routes for this instead?
  var url = '/' + options['controller'] ;
  if(options['action']!=null && options['action'].match(/index/)==null) url += '/' + options['action'];
  if(options['id']!=null) url += "/" + options['id'];
  
  // var keys = Object.keys(options).select(function(key){ return (key!="controller" && key!="action" && key!="id"); });    
  // if(keys.length>0) url += "?";
  // 
  // keys.each(function(key, index){
  //   url += key + "=" + options[key];
  //   if(index<keys.length-1) url += "&";
  // });da
  
  return url;
}
