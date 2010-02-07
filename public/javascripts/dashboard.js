// Add following code to any rhtml page using this code
// <%= javascript_include_tag  'dashboard' %>
// <%= stylesheet_link_tag 'dashboard' %>
// 
// 
// <script>
//   var projectID = '<%= @project.identifier %>';
//   var currentUser = '<%= User.current.name %>';
//   var currentUserLogin = '<%= User.current.login %>';
//   var currentUserId = '<%= User.current.id %>';
//   var currentUserIsCitizen = '<%= User.current.citizen_of?(@project) %>';
// 
// 	$('document').ready(function(){
// 	  load_dashboard();
// 	});

// </script>


var D; //all data
var R; //all retrospectives
var MAX_REQUESTS_PER_PERSON = 2;
var ITEMHASH = new Array(); //mapping between item IDs and their id in the D array
var keyboard_shortcuts = false;
var default_new_title = 'Enter Title Here';
var new_comment_text = 'Add new comment';
var new_todo_text = 'Add todo';
var panel_height = $(window).height() - 200;

$(window).bind('resize', function() {
	resize();
});

/*
* Auto-growing textareas; technique ripped from Facebook
*/
    $.fn.autogrow = function(options) {
        
        this.filter('textarea').each(function() {
            
            var $this = $(this),
                minHeight = $this.height(),
                lineHeight = $this.css('lineHeight');
            
            var shadow = $('<div></div>').css({
                position: 'absolute',
                top: -10000,
                left: -10000,
                width: $(this).width() - parseInt($this.css('paddingLeft'),10) - parseInt($this.css('paddingRight'),10),
                fontSize: $this.css('fontSize'),
                fontFamily: $this.css('fontFamily'),
                lineHeight: $this.css('lineHeight'),
                resize: 'none'
            }).appendTo(document.body);
            
            var update = function() {
    
                var times = function(string, number) {
                    for (var i = 0, r = ''; i < number; i ++) r += string;
                    return r;
                };
                
                var val = this.value.replace(/</g, '&lt;')
                                    .replace(/>/g, '&gt;')
                                    .replace(/&/g, '&amp;')
                                    .replace(/\n$/, '<br/>&nbsp;')
                                    .replace(/\n/g, '<br/>')
                                    .replace(/ {2,}/g, function(space) { return times('&nbsp;', space.length -1) + ' ' ;});
                
                shadow.html(val);
                $(this).css('height', Math.max(shadow.height() + 20, minHeight));
            
            };
            
            $(this).change(update).keyup(update).keydown(update);
            
            update.apply(this);
            
        });
        
        return this;
        
    };

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

$.fn.mybubbletip = function(tip, options) {
	
		var _this = $(this);
	
		var _options = {
			positionAt: 'element', // element | body | mouse
			positionAtElement: _this,
			offsetTop: 0,
			offsetLeft: 0,
			deltaPosition: 0,
			deltaDirection: 'up', // direction: up | down | left | right
			animationDuration: 250,
			animationEasing: 'swing', // linear | swing
			bindShow: 'mouseover', // mouseover | focus | click | etc.
			bindHide: 'mouseout', // mouseout | blur | etc.
			delayShow: 0,
			delayHide: 500
		};
		if (options) {
			_options = $.extend(_options, options);
		}
		
		$(this).bind(_options.bindShow,function() {
			$(this).bubbletip(tip,_options);
		});
};

$.fn.keyboard_sensitive = function() {
		$(this).focus(function() {
			keyboard_shortcuts = false;	
		});

		$(this).blur(function() {
			keyboard_shortcuts = true;	
		});
};


function load_dashboard(){
	keyboard_shortcuts = false;
	// $("#myfancy").fancybox({
	// 			'width'				: '75%',
	// 			'height'			: '75%',
	// 	        'autoScale'     	: false,
	// 	        'transitionIn'		: 'none',
	// 			'transitionOut'		: 'none',
	// 			'type'				: 'iframe'
	// 	});
	
	// $.fancybox({
	// 			'width'				: '75%',
	// 			'height'			: '75%',
	// 	        'autoScale'     	: false,
	// 	        'transitionIn'		: 'none',
	// 			'transitionOut'		: 'none',
	// 			'type'				: 'iframe',
	// 			'href'				: 'http://yahoo.com'
	// 	});
	
	
	$.ajax({
	   type: "GET",
	   dataType: "json",
	   url: 'dashdata',
	   success:  	function(html){
			data_ready(html);
		},
	   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
		// typically only one of textStatus or errorThrown will have info
		// possible valuees for textstatus "timeout", "error", "notmodified" and "parsererror
		$("#loading").hide();
		$("#quote").hide();
		$("#loading_error").show();
		},
		timeout: 30000 //30 seconds
	 });
	

   	load_buttons();
	// load_search();
}

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


function data_ready(html){
	$("#loading").hide();
	$("#quote").hide();
	D = html;
	prepare_page();
	// load_retros(); #No longer needed since retros are now 1 item per retro
}

function load_retros(){
		$.ajax({
		   type: "GET",
		   dataType: "json",
		   url: 'retros/index_json',
		   success:  	function(html){
				retros_ready(html);
			},
		   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
			// typically only one of textStatus or errorThrown will have info
			// possible valuees for textstatus "timeout", "error", "notmodified" and "parsererror
			$("#loading").hide();
			$("#quote").hide();
			$("#loading_error").show();
			},
			timeout: 30000 //30 seconds
		 });
}

function retros_ready(html){
	R = html;
	insert_retros();	
}

function insert_retros(){
	for(var i = 0; i < R.length; i++ ){
		add_retro(i,"bottom",false);	
	}
}

function add_retro(rdataId,position,scroll){
	var html = generate_retro(rdataId);
	var panelid = 'done';
	if (position=="bottom")
	{
		$("#" + panelid + '_start_of_list').append(html);
	}
	else if (position=="top")
	{
		$("#" + panelid+ '_start_of_list').prepend(html);
	}
	
	if (scroll)
	{
		$("#" + panelid + "_items").scrollTo('#item_' + dataId, 100);
	}	
}

//makes all text boxes sensitive to keyboard shortcuts
function make_text_boxes_toggle_keyboard_shortcuts(){
	$("input").keyboard_sensitive();
	$("textarea").keyboard_sensitive();
}


function load_buttons(){
	$('#main-menu').append('<input id="new_request" value="New Idea" type="submit" onclick="new_item();return false;" class="dashboard-button" style="margin-left: 20px;margin-right: 20px;font-weight:bold;"/>');
}

function load_search(){
	html = '';

	html = html + '	<table class="searchField">';
	html = html + '	<tbody>';
	html = html + '	<tr>';
	html = html + '	<td>';
	html = html + '	<a onclick="$(\'searchString\').focus(); return false;" href="#">';
	html = html + '	<img src="/images/search_left.png" alt="Search" title=""/>';
	html = html + '	</a>';
	html = html + '	</td>';
	html = html + '	<td class="field">';
	html = html + '	<input id="searchString" type="text" autocomplete="off" size="20" name="searchString" value=""/>';
	html = html + '	</td>';
	html = html + '	<td style="vertical-align:top;">';
	html = html + '	<img src="/images/search_right.png"/>';
	html = html + '	</td>';
	html = html + '	</tr>';
	html = html + '	</tbody>';
	html = html + '	</table>';
	
	$('#header').append(html);
}


function prepare_page(){
	load_ui();
	resize();
	recalculate_widths();
	keyboard_shortcuts = true;	
	make_text_boxes_toggle_keyboard_shortcuts();
}

function prepare_item_lookup_array(){
	for (var i=0; i<D.length;i++){
		ITEMHASH[D[i].id] = i;
	}
}


// Loads all items in their perspective panels, and sets up panels
function load_ui(){
	insert_panel(0,'new','New',true);
	insert_panel(0,'estimate','In Estimation',true);
	insert_panel(0,'open','Open',true);
	insert_panel(0,'inprogress','In Progress',true);
	insert_panel(0,'done','Done',true);
	insert_panel(0,'canceled','Canceled',false);
	insert_panel(0,'unknown','Unsorted',false);
	
	for(var i = 0; i < D.length; i++ ){
		add_item(i,"bottom",false);	
	}

	update_panel_counts();
	sort_panel('open');
	sort_panel('estimate');
	sort_panel('new');
	sort_panel('inprogress');
	add_hover_icon_events();	
	
}

//Called after data is ready for a retrospective
function rdata_ready(html,rdataId){
	retro = R[rdataId];
	var panelid = 'retro_' + retro.id;
	var i = D.length;
	D = D.concat(html);
	if (retro.status_id == 1){
		var notice = generate_notice('<a class="date_label" title="Retrospective is now open" href="retros/' + retro.id + '" target="_new">Retrospective is open &rArr;</a>');
		$("#" + panelid + '_start_of_list').append(notice);
	}
	for(; i < D.length; i++ ){
		add_item(i,"bottom",false,panelid);	
	}
	update_panel_count(panelid,true);
}

function add_hover_icon_events(){
	$(".hoverDetailsIcon").click(
	      function () {
			show_details_flyover(Number(this.id.split('_')[1].replace(/"/g,''),0),this.id);
	      }
	    );
	$(".hoverDiceIcon").click(
	      function () {
			show_estimate_flyover(Number(this.id.split('_')[1].replace(/"/g,'')),this.id);
	      }
	    );
	$(".hoverCommentsIcon").click(
	      function () {
			show_details_flyover(Number(this.id.split('_')[1].replace(/"/g,''),500),this.id);
	      }
	    );

}

function show_details_flyover(dataId,callingElement,delayshow){
//	$('.overlay').hide();

	//If flyover hasn't already been generated, then generate it!
	if ($('#flyover_' + dataId).length == 0){
		generate_details_flyover(dataId);		
		// $('#flyover_' + dataId).makeAbsolute(); //re-basing off of main window
	}
	
	$('#' + callingElement).bubbletip($('#flyover_' + dataId), {
		deltaDirection: 'right',
		delayShow: delayshow,
		delayHide: 100,
		offsetLeft: 0
	});	
}

function show_estimate_flyover(dataId,callingElement){
//	$('.overlay').hide();

	//If flyover hasn't already been generated, then generate it!
	if ($('#flyover_estimate_' + dataId).length == 0){
		generate_estimate_flyover(dataId);		
		// $('#flyover_' + dataId).makeAbsolute(); //re-basing off of main window
	}
		
	$('#' + callingElement).bubbletip($('#flyover_estimate_' + dataId), {
		deltaDirection: 'right',
		delayShow: 0,
		delayHide: 100,
		offsetLeft: 0
	});	
}

function add_item(dataId,position,scroll,panelid){
	if (!panelid){
		//Deciding on wich panel for this item?
		switch (D[dataId].status.name){
		case 'New':
		panelid= 'new';
		break;
		case 'Estimate':
		panelid= 'estimate';
		break;
		case 'Open':
		panelid= 'open';
		break;
		case 'Committed':
		panelid = 'inprogress';
		break;
		case 'Done':
		panelid = 'done';
		break;
		case 'Canceled':
		panelid = 'canceled';
		break;
		default : panelid = 'unknown';
		}
	}
	
	
	var html = generate_item(dataId);
	if (position=="bottom")
	{
		$("#" + panelid + '_start_of_list').append(html);
	}
	else if (position=="top")
	{
		$("#" + panelid+ '_start_of_list').prepend(html);
	}
	// else if (position=="pri"){
	// 	$("#" + panelid + "_items").children.each()
	// }
	
	if (scroll)
	{
		$("#" + panelid + "_items").scrollTo('#item_' + dataId, 100);
	}
	
}

function generate_details_flyover(dataId){
	var item = D[dataId];
	
	var points;
	item.points == null ? points = 'No' : points = Math.round(item.points);
	
	var html = '';
	
	html = html + '<div id="flyover_' + dataId + '" class="overlay" style="display:none;">';
	html = html + '<div style="border: 0pt none ; margin: 0pt;">';
	html = html + '<div class="overlayContentWrapper storyFlyover flyover" style="width: 475px; max-height:600px">';
	html = html + '<div class="storyTitle">';
	html = html + item.subject;
	html = html + '</div>';
	html = html + '	      <div class="sectionDivider">';
	html = html + '	      <div style="height: auto;">';
	html = html + '	        <div class="metaInfo">';
	html = html + '	          <div class="left">';
	html = html + 'Added by ' + item.author.firstname + ' ' + item.author.lastname + ' ' + humane_date(item.created_on);
	html = html + '	          </div>';
	html = html + '<div class="right infoSection">';
	html = html + '	            <img class="estimateIcon left" width="18" src="/images/dice_' + points + '.png" alt="Estimate: ' + points + ' points" title="Estimate: ' + points + ' points">';
	html = html + '	            <div class="left text">';
	html = html + '	              ' + points + ' pts';
	html = html + '	            </div>';
	html = html + '	            <div class="clear"></div>';
	html = html + '	          </div>';
	html = html + '	          <div class="right infoSection">';
	html = html + '	            <img class="left" src="/images/' + item.tracker.name.toLowerCase() + '_icon.png" alt="' + item.tracker.name + '">';
	html = html + '	            <div class="left text">';
	html = html + 	              item.tracker.name;
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
	html = html + generate_details_flyover_description(item);
	html = html + generate_comments(item,true);
	html = html + '</div>';
	html = html + '	        </div>';
	html = html + '	      </div>';
	html = html + '	    </div>';
	html = html + '	  </div>';
	html = html + '	</div>';
	
	$('#flyovers').append(html);
	
	return html;
}

function generate_estimate_flyover(dataId){
	var item = D[dataId];
	
	var points;
	item.points == null ? points = 'No' : points = Math.round(item.points);
	
	var you_voted = '';
	var user_estimate_id = 0;
	var total_people_estimating = 0;
	
	for(var i=0; i < item.issue_votes.length; i++){
		if (currentUserLogin == item.issue_votes[i].user.login){
			if (item.issue_votes[i].vote_type != 4) continue;
			total_people_estimating++ ;
			you_voted = "You estimated " + item.issue_votes[i].points + " on " + item.issue_votes[i].updated_on;
			user_estimate_id = item.issue_votes[i].id;
		}
	}
	
	if (user_estimate_id == 0){
		you_voted = "You haven't voted yet";
	}
	
	var html = '';
	
	html = html + '<div id="flyover_estimate_' + dataId + '" class="overlay" style="display:none;">';
	html = html + '	  <div style="border: 0pt none ; margin: 0pt;">';
	html = html + '	    <div class="overlayContentWrapper storyFlyover flyover" style="width: 200px;">';
	html = html + '	      <div class="storyTitle">';
	html = html + 'Avg ' + points + ' points (' + total_people_estimating + ' people)';
	html = html + '	      </div>';
	html = html + '	      <div class="sectionDivider">';
	html = html + '	      <div style="height: auto;">';
	html = html + '	        <div class="metaInfo">';
	html = html + '	          <div class="left">';
	html = html + you_voted;
	html = html + '	          </div>';
	html = html + '	          <div class="clear"></div>';
	html = html + '	        </div>';
	html = html + '	        <div class="flyoverContent storyDetails">';
	html = html + '	            <div class="section">';
	html = html + 					generate_estimate_flyover_history(item);
	html = html + 					generate_estimate_flyover_yourestimate(item,user_estimate_id,dataId);
	html = html + '	              </div>';
	html = html + '	        </div>';
	html = html + '	      </div>';
	html = html + '	    </div>';
	html = html + '	  </div>';
	html = html + '	</div>';
		
	$('#flyovers').append(html);
	
	return html;
}

function generate_estimate_flyover_history(item){
	if (item.issue_votes == null || item.issue_votes.length < 1){return '';};
	
	var html = '';
	var header = '';
	header = header + '	  <div class="header">';
	header = header + '	    History';
	header = header + '	  </div>';
	header = header + '	  <table class="notesTable">';
	header = header + '	    <tbody>';
	header = header + '<tr class="noteInfoRow">';
	header = header + '<td class="noteInfo">';
	
	for(var i = 0; i < item.issue_votes.length; i++ ){
		if (item.issue_votes[i].vote_type != 4) continue;
		html = html + item.issue_votes[i].points + ' pts - ' + item.issue_votes[i].user.firstname + ' ' + item.issue_votes[i].user.lastname + '<br>';
	}	
	if (html=='') return '';
	
	html = header + html;

 	html = html + '</td>';
  	html = html + '</tr>';
	html = html + '	    </tbody>';
	html = html + '	  </table>';
	html = html + '	<div class="clear"></div>';
	return html;
	
}

function generate_estimate_flyover_yourestimate(item,user_estimate_id,dataId){
	//TODO: check that I have permission to estimate!	
	
	if ((item.status.name != 'New')&&(item.status.name != 'Estimate')&&(item.status.name != 'Open')) return '';
	var header_text = '';
	user_estimate_id == 0 ? header_text = 'Make an estimate' : header_text = 'Change your estimate';
	var html = '';
	html = html + '	                <div class="header">';
	html = html + header_text;
	html = html + '	                </div>';
	html = html + '	                <table class="notesTable">';
	html = html + '	                  <tbody>';
	html = html + '	                    <tr class="noteTextRow">';
	html = html + '	                      <td class="noteText">';
	html = html + generate_estimate_button(0, item.id, user_estimate_id,dataId);
	html = html + generate_estimate_button(1, item.id, user_estimate_id,dataId);
	html = html + generate_estimate_button(2, item.id, user_estimate_id,dataId);
	html = html + generate_estimate_button(4, item.id, user_estimate_id,dataId);
	html = html + generate_estimate_button(6, item.id, user_estimate_id,dataId);
	html = html + '	                      </td>';
	html = html + '	                    </tr>';
	html = html + '	                  </tbody>';
	html = html + '	                </table>';
	return html;
	
}

function generate_estimate_button(points, itemId, user_estimate_id, dataId){
	html = '';
	html = html + '<img src="/images/dice_' + points + '.png" width="18" height="18" alt="' + points + ' Points" class="dice" onclick="send_item_action(' + dataId + ',\'estimate\',\'&points=' + points + '\')">';	
	return html;
}

function generate_details_flyover_description(item){

	if (item.description == null || item.description.length < 3){return '';};
	
	var html = '';
	html = html + '	  <div class="header">';
	html = html + '	    Description';
	html = html + '	  </div>';
	html = html + '	  <table class="notesTable">';
	html = html + '	    <tbody>';
	html = html + '<tr class="noteInfoRow">';
	html = html + '<td class="noteInfo">';
	html = html + '<span class="specialhighlight">' + item.description.replace(/\n/g,"<br>") + '</span>';
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
	html = html + '	    Comments <span id="comment_' + item.id  + '_count" class="commentCount">(' + count + ')</span>';
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
				html = html + generate_comment(author,note,item.journals[i].created_on,item.id);
			}
	}
	html = html + '	    </tbody>';
	html = html + '	  </table>';
	html = html + '	<div class="clear"></div>';
	return html;
	
}

function generate_comment(author,note,created_on,itemId){
	var html = '';
	html = html + '<tr class="noteInfoRow">';
	html = html + '<td class="noteInfo  noteInfo_' + itemId + '">';
	html = html + '<span class="specialhighlight">' + author + '</span> <span class="italic">' + humane_date(created_on) + '</span>';
	html = html + '</td>';
	html = html + '</tr>';
    html = html + '<tr class="noteTextRow">';
	html = html + '<td class="noteText">';
	html = html + note;
	html = html + '</td>';
	html = html + '</tr>';
	return html;
	
}

//blank_if_no_todos: when true, nothing is returned if there aren't any todos, when false the header is returned
function generate_todos(dataId,blank_if_no_todos){
	item = D[dataId];

	var count = item.todos.length;
	
	if (count==0 && blank_if_no_todos){return '';};
	
	var html = '';
	html = html + '<div  id="todo_container_' + item.id + '">';
	html = html + '	  <div class="header">';
	html = html + '	    Todos <span id="task_' + dataId  + '_count" class="todoCount">(' + count + ')</span>';
	html = html + '	  </div>';
	html = html + '	  <table class="tasksTable" id="notesTable_todos_' + item.id + '">';
	// html = html + '	    <tbody>';
	
	for(var i = 0; i < item.todos.length; i++ ){
		html = html + generate_todo(item.todos[i].subject,item.todos[i].completed_on, item.todos[i].id,dataId);
	}
	// html = html + '	    </tbody>';
	html = html + '	  </table>';
	html = html + '	<div class="clear"></div>';
	html = html + '	  </div>';
	return html;
	
}

function generate_todo(subject,completed_on,todoId,dataId){
	var completed = '';
	var checked = '';
	if (completed_on != null){
		completed = 'completed';
		checked = 'checked="true"';
		}
		
	var html = '';
	html = html + '<tr class="task_row" id="task_' + todoId  + '"  onmouseover="update_todo_buttons(' + todoId + ',true)"  onmouseout="update_todo_buttons(' + todoId + ',false)">';
	html = html + '	<td>';
	html = html + '	<input type="checkbox" value="" id="task_' + todoId  + '_complete" onclick="update_todo(' + todoId + ',' + dataId + ')" ' + checked + '/>';
	html = html + '	</td>';
	html = html + '<td  id="task_' + todoId  + '_subject" class="taskDescription ' + completed + '">';
	html = html + '	<span id="task_' + todoId + '_subject_text">';
	html = html + subject;
	html = html + '	</span>';
	html = html + '	<input id="task_' + todoId + '_subject_input" style="display:none;" value="' + subject + '" onblur="edit_todo_post('+ todoId +',' + dataId + ')">';
	html = html + '	<span id="task_' + todoId + '_subject_submit_container"></span>';
	html = html + '</td>';
	html = html + '	<td>';
	html = html + '	<a id="task_' + todoId  + '_edit" href="javascript:void(0);" style="opacity: 0;" onclick="edit_todo('+ todoId +',' + dataId + ')">';
	html = html + '	<img src="/images/task_edit.png"/>';
	html = html + '	</a>';
	html = html + '	</td>';
	html = html + '	<td>';
	html = html + '	<a id="task_' + todoId  + '_delete" href="javascript:void(0);" style="opacity: 0;" onclick="delete_todo('+ todoId +',' + dataId + ')">';
	html = html + '	<img src="/images/task_delete.png"/>';
	html = html + '	</a>';
	html = html + '	</td>';
	html = html + '</tr>';
	return html;
	
}

function edit_todo(todoId, dataId){
try{
		
		var button = ' <input id="task_' + todoId + '_subject_submit" style="display:none;" type="submit" onclick="edit_todo_post(' + todoId + ',' + dataId + ');return false;">	</input>';
		$('#task_' + todoId + '_edit').attr("style","opacity: 0");
		$('#task_' + todoId + '_subject_text').hide();
		$('#task_' + todoId + '_subject_submit_container').html(button);
		$('#task_' + todoId + '_subject_input').show().focus();
		
		keyboard_shortcuts = false;
		
		return false;
	}
catch(err){
	console.log(err);
	return false;
}
}


function edit_todo_post(todoId, dataId){
try{
	
	keyboard_shortcuts = true;
	
	
	$('#task_' + todoId + '_subject_text').html($('#task_' + todoId + '_subject_input').val()).show();
	$('#task_' + todoId + '_subject_input').hide();
	$('#task_' + todoId + '_subject_submit_container').html('');
	
	var item = D[dataId];	
	var data = "commit=Update&id=" + todoId + "&issue_id=" + item.id + "&todo[subject]=" + $('#task_' + todoId + '_subject_input').val() ;
	
	if ($('#task_' + todoId + '_complete').attr("checked") == true){
		$('#task_' + todoId  + '_subject').addClass('completed');
		data = data + '&todo[completed_on]=' + Date();
	}
	else
	{
		$('#task_' + todoId  + '_subject').removeClass('completed');
		data = data + '&todo[completed_on]=';
	}
	
	var url = url_for({ controller: 'todos',
                           action    : 'update'
                          });

	$.ajax({
	   type: "POST",
	   dataType: "json",
	   url: url,
	   data: data,
	   success: 	function(html){
			todo_updated(html,dataId);
		},
	   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
		handle_error(XMLHttpRequest, textStatus, errorThrown, dataId, "post");
		},
		timeout: 30000 //30 seconds
	 });

	return false;
	}
catch(err){
	console.log(err);
	return false;
}
}



function update_todo_buttons(todoId,show){
	if (show){
		$('#task_' + todoId + '_edit').attr("style","opacity: 100");
		$('#task_' + todoId + '_delete').attr("style","opacity: 100");
	}
	else{
		$('#task_' + todoId + '_edit').attr("style","opacity: 0");
		$('#task_' + todoId + '_delete').attr("style","opacity: 0");
	}
}


//Generates html for collapsed item
function generate_item(dataId){
	var item = D[dataId];
	var html = '';
	var points;
	item.points == null ? points = 'No' : points = Math.round(item.points);
	
	html = html + '<div id="item_' + dataId + '" class="item points_' + points + '">';
	html = html + '<div id="item_content_' + dataId + '" class="' + item.status.name.replace(" ","-").toLowerCase() + ' hoverable" style="">';
	html = html + '<div class="storyPreviewHeader">';
	html = html + '<div id="item_content_buttons_' + dataId + '" class="storyPreviewButtons">';
	html = html + buttons_for(dataId);
	html = html + '</div>';

	html = html + '<div id="icons_' + dataId + '" class="icons">'; //The id of this div is used to lookup the item to generate the flyover
	html = html + '<img id="item_content_icons_editButton_' + dataId + '" class="toggleExpandedButton" src="/images/story_collapsed.png" title="Expand" alt="Expand" onclick="expand_item(' + dataId + ');return false;">';
	html = html + '<div id="icon_set_' + dataId + '" class="left">';
	html = html + '<img id="featureicon_' + dataId + '"  class="storyTypeIcon hoverDetailsIcon clickable" src="/images/' + item.tracker.name.toLowerCase() + '_icon.png" alt="' + item.tracker.name + '">';
	html = html + '<img id="diceicon_' + dataId + '"  class="storyPoints hoverDiceIcon clickable" src="/images/dice_' + points + '.png" alt="' + points + ' points">';
	
	if (show_comment(item)){
	html = html + '<img id="flyovericon_' + dataId + '"  class="flyoverIcon hoverCommentsIcon clickable" src="/images/story_flyover_icon.png"/>';
	}
	
	html = html + '</div>';
    
	html = html + '</div>';


	html = html + '<div id="item_content_details_' + dataId + '" class="storyPreviewText" onDblclick="expand_item(' + dataId + ');return false;" style="cursor: default;">'; 
	
	html = html + item.subject;
	html = html + '</div>';
	html = html + '</div>';
	html = html + '</div>';
	html = html + '</div>';
	return html;
}

function generate_retro(rdataId){
	var retro = R[rdataId];
	var html = '';
	html = html + '	<div id="retro_' + rdataId + '" class="item">';
	html = html + '	<div id="retro_' + rdataId + '_content" class="iterationHeader">';
	html = html + '	<table>';
	html = html + '	<tbody>';
	html = html + '	<tr>';
	html = html + '	<td style="white-space: nowrap; width: 1%; padding: 1px 0pt 1px 4px; color: rgb(255, 255, 255); background-color: rgb(69, 71, 72);">';
	html = html + '		<img id="done_itemList_' + retro.id + '_toggle_expanded_button" class="iterationHeaderToggleExpandedButton" src="/images/iteration_expander_closed.png" title="Expand" alt="Expand" style="height: 12px; width: 12px;" onclick="display_retro(' + rdataId + ');return false;"/>';
	html = html + '	</td>';
	html = html + '	<td style="white-space: nowrap; width: 1%; padding: 1px 0.5em 1px 0pt; color: white; background-color: rgb(69, 71, 72);">';
	html = html + '		<div id="done_itemList_' + rdataId + '_iteration_label" title="Retrospective ' + retro.id + '" style="width: 2em; text-align: right;">' + retro.id + '</div>';
	html = html + '	</td>';
	html = html + '	<td id="done_' + rdataId + '_date_label" style="white-space: nowrap; width: 99%; padding: 1px 0.5em; color: rgb(255, 255, 255);">';
	html = html + '	<span>';
	html = html + '	<a class="date_label" title="' + dateFormat(retro.from_date,'dd mmm yyyy') + ' to ' + dateFormat(retro.to_date,'dd mmm yyyy') + '" onclick="display_retro(' + rdataId + ');return false;">' + dateFormat(retro.from_date,'dd mmm\'yy') + ' - ' + dateFormat(retro.to_date,'dd mmm\'yy') + '</a>';
	html = html + '	</span>';
	html = html + '	</td>';
	html = html + '	<td id="done_' + rdataId + '_details_points" style="white-space: nowrap; width: 1%; padding: 1px 0.5em; color: rgb(255, 255, 255);">';
	html = html + '		<span title="Points completed: 2">Pts: ' + retro.total_points + '</span>';
	html = html + '	</td>';
	// html = html + '	<td style="white-space: nowrap; width: 1%; padding: 1px 4px 1px 0.5em; color: rgb(153, 204, 255); cursor: pointer;">';
	// html = html + '		<span>';
	// html = html + '		<a class="teamStrengthIcon" title="Team strength for this iteration is at 100%. Click to change.">﻿</a>';
	// html = html + '		</span>';
	// html = html + '	</td>';
	html = html + '	</tr>';
	html = html + '	</tbody>';
	html = html + '	</table>';
	html = html + '	</div>';
	html = html + '	</div>';
	return html;	
}

function display_retro(rdataId){
	
	
	var retro = R[rdataId];
	
	$('#done_itemList_' + retro.id + '_toggle_expanded_button').attr('src','/images/iteration_expander_open.png')
	
	$.ajax({
	   type: "GET",
	   dataType: "json",
	   url: 'retros/' + retro.id + '/dashdata',
	   success:  	function(html){
			$('#new_retro_wrapper_' + rdataId).hide();
			rdata_ready(html,rdataId);
		},
	   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
			handle_error(XMLHttpRequest, textStatus, errorThrown, null,'load data');
		},
		timeout: 30000 //30 seconds
	 });
	
	
	$('#retro_' + retro.id + '_panel').remove();
	generate_and_append_panel(0,'retro_' + retro.id,dateFormat(retro.from_date,'dd mmm yyyy') + ' to ' + dateFormat(retro.to_date,'dd mmm yyyy'),true);
	recalculate_widths();
	var html = '	<div class="item" id="new_retro_wrapper_' + rdataId + '"><div id="loading"> Loading...</div></div>';
	$('#retro_' + retro.id + '_start_of_list').append(html);
	
	
}


function generate_notice(noticeHtml, noticeId){
	var html = '';
	html = html + '	<div id="notice_' + noticeId + '" class="item notice">';
	html = html + '	<div id="notice_' + noticeId + '_content" class="iterationHeader">';
	html = html + '	<table>';
	html = html + '	<tbody>';
	html = html + '	<tr>';
	// html = html + '	<td style="white-space: nowrap; width: 1%; padding: 1px 0pt 1px 4px; color: rgb(255, 255, 255); background-color: rgb(69, 71, 72);">';
	// html = html + '		<img id="done_itemList_' + noticeId + '_toggle_expanded_button" class="iterationHeaderToggleExpandedButton" src="/images/iteration_expander_closed.png" title="Expand" alt="Expand" style="height: 12px; width: 12px;"/>';
	// html = html + '	</td>';
	// html = html + '	<td style="white-space: nowrap; width: 1%; padding: 1px 0.5em 1px 0pt; color: white; background-color: rgb(69, 71, 72);">';
	// html = html + '		<div id="done_itemList_' + noticeId + '_iteration_label" title="Retrospective ' + retro.id + '" style="width: 2em; text-align: right;">' + retro.id + '</div>';
	// html = html + '	</td>';
	html = html + '	<td id="done_' + noticeId + '_date_label" style="white-space: nowrap; width: 99%; padding: 1px 0.5em; color: rgb(255, 255, 255);">';
	html = html + '	<span>';
	html = html + noticeHtml;
	html = html + '	</span>';
	html = html + '	</td>';
	html = html + '	</tr>';
	html = html + '	</tbody>';
	html = html + '	</table>';
	html = html + '	</div>';
	html = html + '	</div>';
	return html;	
}


function buttons_for(dataId){
	item = D[dataId];
	html = '';
	
	switch (item.status.name){
	case 'New':
		html = html + pri_button(dataId);
		html = html + agree_buttons(dataId);
	break;
	case 'Estimate':
		html = html + pri_button(dataId);
		html = html + agree_buttons(dataId);
		// html = html + button('estimate',dataId);
	break;
	case 'Open':
		html = html + pri_button(dataId);
		// console.log(item.points);
		item.points == 0 ? html = html + button('start',dataId,false) : html = html + button('start',dataId,true);

		if (currentUserIsCitizen == 'true'){
			var today = new Date();
			var one_day=1000*60*60*24;
			var updated = new Date(item.updated_on).getTime();
			var days = (today.getTime() - updated)/one_day;
			if (days > 30){
				html = html + button('cancel',dataId);
			}
		}		

	break;
	case 'Committed':
		if (item.assigned_to_id == currentUserId){
			html = html + button('release',dataId);
			html = html + button('finish',dataId);
		}
		else if (item.assigned_to != null){
			html = html + '<div id="committed_tally_' + dataId + '" class="action_button action_button_tally">' + item.assigned_to.login + '</div>';
		
			if (is_part_of_team(item)){
				html = html + button('leave',dataId);
			}
			else{
				html = html + button('join',dataId);
			}
		}
	break;
	case 'Done':
		if (item.retro_id){
			html = html + '<div id="accepted_' + dataId + '" class="action_button action_button_accepted">Accepted</div>';
			if (item.retro_id > 0){
				html = html + button('retro',dataId,false,item.retro_id);
			}
		}
		else if (currentUserIsCitizen == 'true'){
			html = html + accept_buttons(dataId);
		}
	break;
	case 'Canceled':
		html = html + button('restart',dataId);
	break;
	}
	
	return html;
	
}

//returns true if current user is on the team for this item
function is_part_of_team(item){
	//Determining wether or not user is already part of the team for this task
	var part_of_team = false;
	for(var i=0; i < item.issue_votes.length; i++){
		if ((currentUserLogin == item.issue_votes[i].user.login)&&(item.issue_votes[i].vote_type == 5)){
			part_of_team = true;
			break;
		}
	}	
	return part_of_team;
}

function agree_buttons(dataId){
	html = '';
	item = D[dataId];
	for(var i=0; i < item.issue_votes.length; i++){
		if ((currentUserLogin == item.issue_votes[i].user.login)&&(item.issue_votes[i].vote_type == 1)){
			tally = '';
			tally = tally + '<div id="agree_tally_' + dataId + '" class="action_button action_button_tally">';
			tally = tally + item.agree + ' - ' + item.disagree;
			tally = tally + '</div>';
			
			if (item.issue_votes[i].points==1) {
				return tally + button('against',dataId);
			} else {
				return tally + button('agree',dataId);
			}
		}
	}	
	html = html + button('against',dataId);
	html = html + button('agree',dataId);
	
	return html;
}

function accept_buttons(dataId){
	html = '';
	item = D[dataId];

	for(var i=0; i < item.issue_votes.length; i++){
		if ((currentUserLogin == item.issue_votes[i].user.login)&&(item.issue_votes[i].vote_type == 2)){
			tally = '';
			tally = tally + '<div id="accept_tally_' + dataId + '" class="action_button action_button_tally">';
			tally = tally + item.accept + ' - ' + item.reject;
			tally = tally + '</div>';
			
			if (item.issue_votes[i].points==1) {
				return tally + button('reject',dataId);
			} else {
				return tally + button('accept',dataId);
			}
		}
	}
	
	html = html + button('reject',dataId);
	html = html + button('accept',dataId);
	
	return html;
}


function pri_button(dataId){
	item = D[dataId];
	for(var i=0; i < item.issue_votes.length; i++){
		if ((currentUserLogin == item.issue_votes[i].user.login)&&(item.issue_votes[i].vote_type == 3)){
			return generate_pri_button(dataId,'down');
		}
	}
	return generate_pri_button(dataId,'up');
}

function generate_pri_button(dataId,direction){
	html = '<div id="pri_container_' + D[dataId].id + '" style="float:right;">';
	html = html + '<img src="/images/' + direction + '_arrow.png" id="item_content_buttons_pri_button_' + dataId + '" class="clickable pri_button" onclick="click_pri(' + dataId + ',\'' + direction + '\',this);return false;"/>';	
	html = html + '</div>';
	return html;
}

//Generates a button type for item id
function button(type,dataId,hide,options){
	var label = type;
	var hide_style = '';
	if (hide){ hide_style = "style=display:none;"; }
	if (type == 'release') label = 'giveup';
	html = '';
	html = html + '<div id="item_content_buttons_' + type + '_button_' + dataId + '" class="clickable action_button action_button_' + type + '" ' + hide_style + ' onclick="click_' + type + '(' + dataId + ',this, ' + options + ');return false;">';
	html = html + '<a href="/" id="item_action_link_' + type + dataId + '" class="action_link clickable">' + label + '</a>';
	html = html + '</div>';
	return html;
	// return '<img id="item_content_buttons_' + type + '_button_' + dataId + '" class="stateChangeButton notDblclickable" src="/images/' + type + '.png" onmouseover="this.src=\'/images/' + type + '_hover.png\'" onclick="click_' + type + '(' + dataId + ',this);return false;" onmouseout="this.src=\'/images/' + type + '.png\'">';
}

function click_start(dataId,source){
	if ($(".action_button_finish").get().length >= MAX_REQUESTS_PER_PERSON){
		$.jGrowl("Sorry, you're only allowed to own " + MAX_REQUESTS_PER_PERSON + " ideas at a time");
	}
	else{
		$('#' + source.id).parent().hide();
		send_item_action(dataId,'start');
	}
	return false;
}

function click_accept(dataId,source){
	$('#' + source.id).parent().hide();
	send_item_action(dataId,'accept');
}

function click_reject(dataId,source){
	$('#' + source.id).parent().hide();
	send_item_action(dataId,'reject');
}

function click_finish(dataId,source){
	$('#' + source.id).parent().hide();
	send_item_action(dataId,'finish');
}

function click_restart(dataId,source){
	$('#' + source.id).parent().hide();
	send_item_action(dataId,'restart');
}

function click_estimate(dataId,source){
	$('#' + source.id).parent().hide();
}

function click_agree(dataId,source){
	$('#' + source.id).parent().hide();
	send_item_action(dataId,'agree');
}

function click_against(dataId,source){
	$('#' + source.id).parent().hide();
	send_item_action(dataId,'disagree');
}

function click_release(dataId,source){
	$('#' + source.id).parent().hide();
	send_item_action(dataId,'release');
}

function click_cancel(dataId,source){
	$('#' + source.id).parent().hide();
	send_item_action(dataId,'cancel');
}

function click_leave(dataId,source){
	$('#' + source.id).parent().hide();
	send_item_action(dataId,'leave');
}

function click_join(dataId,source){
	$('#' + source.id).parent().hide();
	send_item_action(dataId,'join');
}

function click_pri(dataId,direction,source){
	if (direction == 'up'){
		$('#' + source.id).parent().html(generate_pri_button(dataId,'down'));
		send_item_action(dataId,'prioritize');
	}
	else{
		$('#' + source.id).parent().html(generate_pri_button(dataId,'up'));
		send_item_action(dataId,'deprioritize');
	}
}

function click_retro(dataId,source,options){
	alert(options);
}



function send_item_action(dataId,action,extradata){
	var data = "commit=Create&lock_version=" + D[dataId].lock_version + extradata;

    var url = url_for({ controller: 'issues',
                           action    : action,
							id		: D[dataId].id
                          });

	$("#item_content_icons_editButton_" + dataId).remove();
	$("#icon_set_" + dataId).addClass('updating');
	
	pre_status = D[dataId].status.name;
	
	$.ajax({
	   type: "POST",
	   dataType: "json",
	   url: url,
	   data: data,
	   success:  	function(html){
			status_changed = (pre_status != html.status.name);
			item_actioned(html,dataId,action,status_changed);
		},
	   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
		// typically only one of textStatus or errorThrown will have info
		// possible valuees for textstatus "timeout", "error", "notmodified" and "parsererror
		handle_error(XMLHttpRequest, textStatus, errorThrown, dataId,action);
		},
		timeout: 30000 //30 seconds
	 });
	
	$('.bubbletip').hide();
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
	panel_height = $(window).height() - $('#header').height() - $('#top-menu').height();
	$("#content").height(panel_height - 35);
	$(".list").height(panel_height - 75);
	$("#panels").show();
	recalculate_widths();
}

function insert_panel(position, name, title, visible){
	var button_style = "";
	if (visible){button_style = 'style="display:none;"';}
	generate_and_append_panel(position,name,title, visible);
	
	$('#main-menu').append('<input id="' + name + '_panel_toggle" value="' + title + ' (0)" type="submit" onclick="show_panel(\'' + name + '\');return false;" class="dashboard-button" ' + button_style + '/>');
	$("#help_image_panel_" + name).mybubbletip('#help_panel_' + name, {deltaDirection: 'right', bindShow: 'click'});
}

function generate_and_append_panel(position,name,title, visible){
	var panel_style = "";
	if (!visible){panel_style = 'style="display:none;"';}

	var panelHtml = '';
	panelHtml = panelHtml + "	<td id='" + name + "_panel' class='panel' " + panel_style + "'>";
	panelHtml = panelHtml + "<div class='panelHeaderRight'></div>";
	panelHtml = panelHtml + "<div class='panelHeaderLeft'></div>";
	panelHtml = panelHtml + "<div id='panel_header_" + name +"'class='panelHeader'>";
	panelHtml = panelHtml + "  <a href='javascript:void(0)' class='closePanel panelLink' id='" + name + "_close' title='Close panel' onclick='close_panel(\"" + name + "\");return false;'></a>";
	panelHtml = panelHtml + "  <span id='" + name +"_panel_title' class='panelTitle'>" + title + " (0)</span>";
	panelHtml = panelHtml + '  	<img id="help_image_panel_' + name + '" src="/images/question_mark.gif" class="clickable">';
	panelHtml = panelHtml + "</div>";
	panelHtml = panelHtml + "<div id='" + name + "_list' class='list'>";
	panelHtml = panelHtml + "  <div id='" + name + "_items' class='items'>";
	panelHtml = panelHtml + "	<div id='" + name + "_start_of_list' class='startOfList'></div>";
	panelHtml = panelHtml + "	<div id='" + name + "_end_of_list' class='endOfList'></div>";
	panelHtml = panelHtml + "  </div>";
	panelHtml = panelHtml + "</div>";
	panelHtml = panelHtml + "</td>";
	$("#main_row").append(panelHtml);	
	$("#content").height(panel_height - 35);
	$(".list").height(panel_height - 75);
}

function update_panel_counts(){
	update_panel_count('new');
	update_panel_count('estimate');
	update_panel_count('open');
	update_panel_count('inprogress');
	update_panel_count('done');
	update_panel_count('canceled');
	update_panel_count('unknown');
	
}

function update_panel_count(name, skip_button){
	count = $("#" + name + "_start_of_list > *").length;
	$("#" + name + '_panel_title').html($("#" + name + '_panel_title').html().replace(/\([0-9]*\)/,"(" + count + ")"));
	if (!skip_button){
		$("#" + name + '_panel_toggle').val($("#" + name + '_panel_toggle').val().replace(/\([0-9]*\)/,"(" + count + ")"));
	}
}

function close_panel(name){
	$('#' + name + '_panel').hide();
	$('#' + name + '_panel_toggle').show();	
	recalculate_widths();
	if (name == "new"){keyboard_shortcuts = true;} //If we're closing the new panel, then we want keyboard shortcuts to be on again, in case they were off
	if (name.indexOf("retro") == 0){ //If we're closing a retrospective panel, we untoggle the expander button
		retroId = name.split('_')[1];
		$('#done_itemList_' + retroId + '_toggle_expanded_button').attr('src','/images/iteration_expander_closed.png');		
	}
}

function show_panel(name){
	$('#' + name + '_panel').show();
	$('#' + name + '_panel_toggle').hide();
	recalculate_widths();
}

// Sorts items in a plane by priority (highest first) followed by created date (oldest first)
function sort_panel(name){
		var listitems = $('#' + name + '_start_of_list').children().get();

			listitems.sort(function(a, b) {
			   var compA = a.id.replace(/item_/g,'');
			   var compB = b.id.replace(/item_/g,'');
			   if (D[compA].pri > D[compB].pri) {
				return -1;
				} else if (D[compA].pri < D[compB].pri) {
					return 1;
				} else if (new Date(D[compA].created_on) > new Date(D[compB].created_on)) {
					return 1;
				} else {
					return -1;
				}
			});


		$('#' + name + '_start_of_list').children().remove();

		$.each(listitems, function() {
		    $('#' + name + '_start_of_list').append(this);
		    });
		
		if (name == "open"){
			$(".action_button_start:lt(5)").show();
			$(".action_button_start:gt(4)").hide();
			$(".points_0").find(".action_button_start").show();
		}
}


function recalculate_widths(){
	new_width = $('#content').width() / $('.panel:visible').length;
	$('.panel:visible').width(new_width);
}

function expand_item(dataId){
	$('#item_' + dataId).html(generate_item_edit(dataId));
	$('#edit_story_type_' + dataId).val(D[dataId].tracker.id);
	$('#new_comment_' + dataId).watermark('watermark',new_comment_text);
	$('#new_comment_' + dataId).autogrow();
	$('#new_todo_' + dataId).watermark('watermark',new_todo_text);
	$('#edit_description_' + dataId).autogrow();
	$('#help_image_description_' + dataId).mybubbletip($('#help_description'), {
		deltaDirection: 'right',
		delayShow: 300,
		delayHide: 100,
		offsetLeft: 0,
		bindShow: 'click'
	});
	$('#help_image_feature_' + dataId).mybubbletip($('#help_feature'), {
		deltaDirection: 'up',
		delayShow: 300,
		delayHide: 100,
		offsetTop: 0,
		bindShow: 'click'
	});
	$('#help_image_requestid_' + dataId).mybubbletip($('#help_requestid'), {
		deltaDirection: 'right',
		delayShow: 300,
		delayHide: 100,
		offsetLeft: 0,
		bindShow: 'click'
	});
	make_text_boxes_toggle_keyboard_shortcuts();
	$('#item_' + dataId).parent().parent().scrollTo('#item_' + dataId, 500);
	
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
	var data = "commit=Create&project_id=" + projectID + "&issue[tracker_id]=" + $('#new_story_type').val() + "&issue[subject]=" + $('#new_title_input').val() + "&issue[description]=" + $('#new_description').val();

    var url = url_for({ controller: 'issues',
                           action    : 'new'
                          });

	$("#new_item_wrapper").html('<div id="loading"> Adding...</div>');
	
	$.ajax({
	   type: "POST",
	   dataType: "json",
	   url: url,
	   data: data,
	   success:  	function(html){
					item_added(html);
		},
	   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
		// typically only one of textStatus or errorThrown will have info
		// possible valuees for textstatus "timeout", "error", "notmodified" and "parsererror
		handle_error(XMLHttpRequest, textStatus, errorThrown, false, "add");
		},
		timeout: 30000 //30 seconds
	 });
	

	return false;
}

function save_edit_item(dataId){
	if (($('#edit_title_input_' + dataId).val() == default_new_title) || ($('#edit_title_input_' + dataId).val() == ''))
	{
		alert('Please enter a title');
		return false;
	}	
	var data = "commit=Submit&lock_version=" + D[dataId].lock_version + "&project_id=" + projectID + "&id=" + D[dataId].id + "&issue[tracker_id]=" + $('#edit_story_type_' + dataId).val() + "&issue[subject]=" + $('#edit_title_input_' + dataId).val() + "&issue[description]=" + $('#edit_description_' + dataId).val();

    var url = url_for({ controller: 'issues',
                           action    : 'edit'
                          });

	$("#edit_item_" + dataId).html(generate_item(dataId));
	$("#item_content_icons_editButton_" + dataId).remove();
	$("#icon_set_" + dataId).addClass('updating');

	$.ajax({
	   type: "POST",
	   dataType: "json",
	   url: url,
	   data: data,
	   success:  	function(html){
			item_updated(html, dataId);
		},
	   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
		// typically only one of textStatus or errorThrown will have info
		// possible valuees for textstatus "timeout", "error", "notmodified" and "parsererror
		handle_error(XMLHttpRequest, textStatus, errorThrown, dataId, "edit");
		},
		timeout: 30000 //30 seconds
	 });
	
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
	add_item(D.length-1,"top",false);
	add_hover_icon_events();
	keyboard_shortcuts = true;
	update_panel_counts();
	return false;
}

function item_actioned(item, dataId,action, status_changed){
	D[dataId] = item; 
	if (!status_changed)
	{
		$('#item_' + dataId).html(generate_item(dataId));
	}
	else
	{
		$("#item_" + dataId).remove();
		add_item(dataId,"bottom",true);
		update_panel_counts();
		$("#item_content_details_" + dataId).effect("highlight", {mode:'show'}, 2000);
		$('#flyover_estimate_' + dataId).remove(); 
	}

	keyboard_shortcuts = true;
	add_hover_icon_events();	
	$('#flyover_' + dataId).remove(); //removing flyover because data in it is outdated
	if (action == "estimate") {$('#flyover_estimate_' + dataId).remove();}
	if ((action == "deprioritize")||(action == "prioritize")||(item.status.name == "Open")) {	
		sort_panel(item.status.name.toLowerCase());
		$("#item_content_details_" + dataId).effect("highlight", {mode:'show'}, 2000);
		add_hover_icon_events();	
	}
	
	return false;
}

function item_prioritized(item, dataId,action){
	//sort_panel(item.status.name);
	//TODO: put item in correct order on this list
	D[dataId] = item; 
	add_hover_icon_events();
	
	// $("#item_" + dataId).remove();
	// add_item(dataId,"bottom",true);
	// add_hover_icon_events();
	// keyboard_shortcuts = true;
	// $('#flyover_' + dataId).remove(); //removing flyover because data in it is outdated
	// update_panel_counts();
	// $("#item_content_details_" + dataId).effect("highlight", {mode:'show'}, 2000);
	return false;
}


function item_estimated(item, dataId){
	D[dataId] = item; 
	$("#item_" + dataId).html(generate_item(dataId));
	add_hover_icon_events();
	keyboard_shortcuts = true;
	$('#flyover_' + dataId).remove(); //removing flyover because data in it is outdated
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

function todo_added(item, dataId){
	D[dataId] = item; 
	$('#todo_container_' + item.id).html(generate_todos(dataId,false,null));
	$('#flyover_' + dataId).remove(); //removing flyover because data in it is outdated
}

function todo_updated(item, dataId){
	D[dataId] = item; 
	// $('#todo_container_' + item.id).html(generate_todos(item,false));
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
html = html + '	                    <input disabled="disabled" id="new_full_screen_button" value="Full Screen" type="submit" >';
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
html = html + '	                      <option selected="true" value="4">';
html = html + '	                        Feature';
html = html + '	                      </option>';
html = html + '	                      <option value="7">';
html = html + '	                        Chore';
html = html + '	                      </option>';
html = html + '	                      <option value="8">';
html = html + '	                        Bug';
html = html + '	                      </option>';
html = html + '	                    </select>';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td class="storyDetailsLabelIcon" colspan="1">';
html = html + '	                  <div class="storyDetailsLabelIcon">';
// html = html + '	                    <img src="/images/feature_icon.png" id="new_story_type_image" name="new_story_type_image">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td class="helpIcon lastCell" colspan="1">';
html = html + '	                  <div class="helpIcon" id="story_newStory_details_help_story_types">';
html = html + '	                    <img id="help_image_feature_new" src="/images/question_mark.gif"  class="clickable">';
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
html = html + '	                      <img id="help_image_description_new" src="/images/question_mark.gif"  class="clickable">';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                </tr>';
html = html + '	                <tr>';
html = html + '	                  <td colspan="5">';
html = html + '	                    <div>';
html = html + '	                      <textarea class = "textAreaFocus" id="new_description" rows="2" cols="20" name="story[description]"></textarea>     ';
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
$("#new_description").autogrow();
make_text_boxes_toggle_keyboard_shortcuts();

$('#help_image_description_new').mybubbletip($('#help_description'), {
	deltaDirection: 'right',
	delayShow: 300,
	delayHide: 100,
	offsetLeft: 0,
	bindShow: 'click'
});
$('#help_image_feature_new').mybubbletip($('#help_feature'), {
	deltaDirection: 'up',
	delayShow: 300,
	delayHide: 100,
	offsetTop: 0,
	bindShow: 'click'
});

$("#new_items").scrollTo( '#new_item_wrapper', 800);
}

function generate_item_edit(dataId){
html = '';	
html = html + '	<div class="item" id="edit_item_' + dataId + '">';
html = html + '	  <div class="storyItem underEdit" id="editItem_content_' + dataId + '">';
// html = html + '	   <form action="#">';
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
html = html + '	                    <input id="edit_full_screen_button" value="Full Screen" type="submit" onclick="full_screen(' + dataId + ');return false;">';
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
html = html + '	                      <option selected="true" value="4">';
html = html + '	                        Feature';
html = html + '	                      </option>';
html = html + '	                      <option value="7">';
html = html + '	                        Chore';
html = html + '	                      </option>';
html = html + '	                      <option value="8">';
html = html + '	                        Bug';
html = html + '	                      </option>';
html = html + '	                    </select>';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td class="storyDetailsLabelIcon" colspan="1">';
html = html + '	                  <div class="storyDetailsLabelIcon">';
// html = html + '	                    <img src="/images/feature_icon.png" id="edit_story_type_image" name="edit_story_type_image">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td class="helpIcon lastCell" colspan="1">';
html = html + '	                  <div class="helpIcon" id="story_newStory_details_help_story_types' + dataId + '">';
html = html + '	                    <img id="help_image_feature_' + dataId + '" src="/images/question_mark.gif" class="clickable">';
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
html = html + '	                    <div class="helpIcon_Description">';
html = html + '	                      <img id="help_image_description_' + dataId + '" src="/images/question_mark.gif"  class="clickable">';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                </tr>';
html = html + '	                <tr>';
html = html + '	                  <td colspan="5">';
html = html + '	                    <div>';
html = html + '	                      <textarea class = "textAreaFocus" id="edit_description_' + dataId + '" rows="1" cols="20" name="story[description]">' + D[dataId].description + '</textarea>     ';
html = html + '	                    <div>';
html = html + '	                        (Format using *<b>bold</b>* and _<i>italic</i>_ text.)';
html = html + '	                      </div>';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                </tr>';
html = html + '	              </tbody>';
html = html + '	            </table>';
html = html + '	          </div>';

//todos
html = html + generate_todo_section(dataId);
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
html = html + '	                      <textarea class = "textAreaFocus" id="new_comment_' + dataId + '" rows="1" cols="20" name="story[comment]"></textarea>     ';
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

// request id
html = html + '	                <tr><td>&nbsp;</td></tr>';
html = html + '	                <tr><td>';
html = html + '	  <div class="header">';
html = html + '	    Idea ID: <span style="font-weight:normal;">' + D[dataId].id + '</span>';
html = html + '	                      <img id="help_image_requestid_' + dataId + '" src="/images/question_mark.gif"  class="clickable">';
html = html + '	  </div>';
html = html + '	                  </td>';
html = html + '	                </tr>';
html = html + '	                <tr>';
html = html + '	                  <td colspan="5">';
html = html + '	                    <div>';
html = html + '	                      <input class="textAreaFocus" type="text" id="request_id_' + dataId + '" value="http://' + window.location.hostname + '/issues/' +  D[dataId].id + '" readonly>&nbsp;</input>     ';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                </tr>';
html = html + '	              </tbody>';
html = html + '	            </table>';
html = html + '	          </div>';

return html;
}

function generate_todo_section(dataId){
	var html = '';
	html = html + '	          <div id="todo_section_' + dataId + '" class="section">';
	html = html + '	   <form action="#">';
	html = html + '	            <table class="storyDescriptionTable">';
	html = html + '	              <tbody>';
	html = html + '	                <tr><td colspan="5">';
	html = html + generate_todos(dataId,false);
	html = html + '	                </td></tr>';
	html = html + '	                <tr>';
	html = html + '	                  <td colspan="5">';
	html = html + '	                    <div>';
	html = html + '	                      <input class= "tasksTextArea" id="new_todo_' + dataId + '"></input>     ';
	html = html + '	                      <div>';
	html = html + '	                         <input value="Add" type="submit" onclick="post_todo(' + dataId + '); return false;">';
	html = html + '	                      </div>';
	html = html + '	                    </div>';
	html = html + '	                  </td>';
	html = html + '	                </tr>';
	html = html + '	              </tbody>';
	html = html + '	            </table>';
	html = html + '	   </form>';
	html = html + '	          </div>';
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
		$("#notesTable_" + item.id).append(generate_comment(currentUser,text.replace(/\n/g,"<br>"),'1 second ago',D[dataId].id));
		$('#new_comment_' + dataId).val('');
		
		
		var data = "commit=Create&issue_id=" + item.id + "&comment=" + text;
		
		var url = url_for({ controller: 'comments',
	                           action    : 'create'
	                          });
	
		$.ajax({
		   type: "POST",
		   dataType: "json",
		   url: url,
		   data: data,
		   success: 	function(html){
				comment_added(html,dataId);
				update_comment_count(dataId);
			},
		   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
			  // typically only one of textStatus or errorThrown 
			  // will have info
			// possible valuees for textstatus "timeout", "error", "notmodified" and "parsererror
			handle_error(XMLHttpRequest, textStatus, errorThrown, dataId, "post");
			},
			timeout: 30000 //30 seconds
		 });

		return false;
	}
	}
catch(err){
	console.log(err);
	return false;
}
}

function post_todo(dataId){
try{
	var text = $("#new_todo_" + dataId).val();
	if ((text == null) || (text.length < 2)|| (text == new_todo_text)){
		return false;
	}
	else
	{
		var item = D[dataId];
		$("#notesTable_todos_" + item.id).append(generate_todo(text,null,null));
		$('#new_todo_' + dataId).val('');
		
		
		var data = "commit=Create&issue_id=" + item.id + "&todo[subject]=" + text;
		
		var url = url_for({ controller: 'todos',
	                           action    : 'create'
	                          });
	
		$.ajax({
		   type: "POST",
		   dataType: "json",
		   url: url,
		   data: data,
		   success: 	function(html){
				todo_added(html,dataId);
			},
		   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
			handle_error(XMLHttpRequest, textStatus, errorThrown, dataId, "post");
			},
			timeout: 30000 //30 seconds
		 });

		return false;
	}
	}
catch(err){
	console.log(err);
	return false;
}
}


function update_todo(todoId, dataId){
try{
		var item = D[dataId];	
		var data = "commit=Update&id=" + todoId + "&issue_id=" + item.id; // + "&todo[subject]=" + text;
		
		if ($('#task_' + todoId + '_complete').attr("checked") == true){
			$('#task_' + todoId  + '_subject').addClass('completed');
			data = data + '&todo[completed_on]=' + Date();
		}
		else
		{
			$('#task_' + todoId  + '_subject').removeClass('completed');
			data = data + '&todo[completed_on]=';
		}
		
		var url = url_for({ controller: 'todos',
	                           action    : 'update'
	                          });
	
		$.ajax({
		   type: "POST",
		   dataType: "json",
		   url: url,
		   data: data,
		   success: 	function(html){
				todo_updated(html,dataId);
				update_todo_count(dataId);
			},
		   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
			handle_error(XMLHttpRequest, textStatus, errorThrown, dataId, "post");
			},
			timeout: 30000 //30 seconds
		 });

		return false;
	}
catch(err){
	console.log(err);
	return false;
}
}

function delete_todo(todoId, dataId){
try{
		var item = D[dataId];	
		var data = "commit=Destroy&id=" + todoId + "&issue_id=" + item.id; // + "&todo[subject]=" + text;
		
		$('#task_' + todoId).remove();
		
		var url = url_for({ controller: 'todos',
	                           action    : 'destroy'
	                          });
	
		$.ajax({
		   type: "POST",
		   dataType: "json",
		   url: url,
		   data: data,
		   success: 	function(html){
				todo_updated(html,dataId);
				update_todo_count(dataId);
			},
		   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
			handle_error(XMLHttpRequest, textStatus, errorThrown, dataId, "post");
			},
			timeout: 30000 //30 seconds
		 });

		return false;
	}
catch(err){
	console.log(err);
	return false;
}
}

function update_todo_count(dataId){
	$('#task_' + dataId  + '_count').html('(' + D[dataId].todos.length + ')');
}

function update_comment_count(dataId){
	$('#comment_' + D[dataId].id  + '_count').html('(' + $('.noteInfo_' + D[dataId].id).length + ')');	
}


//View item history
function full_screen(dataId){
	var url = url_for({ controller: 'issues',
                           action    : 'show',
							id		: D[dataId].id
                          });
console.log(url);
	
	$.fancybox({
				'width'				: '75%',
				'height'			: '75%',
		        'autoScale'     	: false,
		        'transitionIn'		: 'none',
				'transitionOut'		: 'none',
				'type'				: 'iframe',
				'href'				: url
		});
	return false;
	
}



///HELPERS
function url_for(options){
  // THINKABOUTTHIS: Is it worth using Rails' routes for this instead?
  var url = '/' + options['controller'] ;
  if(options['id']!=null) url += "/" + options['id'];
	if(options['action']!=null && options['action'].match(/index/)==null) url += '/' + options['action'];
  
  // var keys = Object.keys(options).select(function(key){ return (key!="controller" && key!="action" && key!="id"); });    
  // if(keys.length>0) url += "?";
  // 
  // keys.each(function(key, index){
  //   url += key + "=" + options[key];
  //   if(index<keys.length-1) url += "&";
  // });da
  
  return url;
}

function handle_error (XMLHttpRequest, textStatus, errorThrown, dataId, action) {
	if (dataId){
		$('#item_' + dataId).html(generate_item(dataId));
		sort_panel('open');
		$('#featureicon_' + dataId).attr("src", "/images/error.png");
		$.jGrowl("Sorry, couldn't " + action + " idea:<br>" + D[dataId].subject , { header: 'Error', position: 'bottom-right' });
		
	}
	else{
		$("#new_item_wrapper").remove();
		$.jGrowl("Sorry, couldn't " + action + "<br>" + XMLHttpRequest, { header: 'Error', position: 'bottom-right' });
	}
	keyboard_shortcuts = true;
	add_hover_icon_events();	
	
	// alert("Error: Couldn't " + action);
}


function humane_date(date_str){
		
	date_str = date_str.split('-')[0];
      var time_formats = [
              [60, 'Just Now'],
              [90, '1 Minute'], // 60*1.5
              [3600, 'Minutes', 60], // 60*60, 60
              [5400, '1 Hour'], // 60*60*1.5
              [86400, 'Hours', 3600], // 60*60*24, 60*60
              [129600, '1 Day'], // 60*60*24*1.5
              [604800, 'Days', 86400], // 60*60*24*7, 60*60*24
              [907200, '1 Week'], // 60*60*24*7*1.5
              [2628000, 'Weeks', 604800], // 60*60*24*(365/12), 60*60*24*7
              [3942000, '1 Month'], // 60*60*24*(365/12)*1.5
              [31536000, 'Months', 2628000], // 60*60*24*365, 60*60*24*(365/12)
              [47304000, '1 Year'], // 60*60*24*365*1.5
              [3153600000, 'Years', 31536000], // 60*60*24*365*100, 60*60*24*365
              [4730400000, '1 Century'] // 60*60*24*365*100*1.5
      ];

      var time = ('' + date_str).replace(/-/g,"/").replace(/[TZ]/g," "),
              dt = new Date,
              seconds = ((dt - new Date(time) + (dt.getTimezoneOffset() * 60000)) / 1000),
              token = ' Ago',
          prepend = '',
              i = 0,
              format;

      if (seconds < 0) {
              seconds = Math.abs(seconds);
              token = '';
          prepend = 'In ';
      }

      while (format = time_formats[i++]) {
              if (seconds < format[0]) {
                      if (format.length == 2) {
                              return (i>1?prepend:'') + format[1] + (i > 1 ? token : ''); // Conditional so we don't return Just Now Ago
                      } else {
                              return prepend + Math.round(seconds / format[2]) + ' ' + format[1] + (i > 1 ? token : '');
                      }
              }
      }

      // overflow for centuries
      if(seconds > 4730400000)
              return Math.round(seconds / 4730400000) + ' Centuries' + token;

      return date_str;
  };



/*
 * bubbletip
 *
 * Copyright (c) 2009, UhLeeKa
 * Version: 
 *      1.0.4
 * Licensed under the GPL license:
 *     http://www.gnu.org/licenses/gpl.html
 * Author Website: 
 *     http://www.uhleeka.com
 * Description: 
 *     A bubble-styled tooltip extension
 *      - multiple tips on a page
 *      - multiple tips per jQuery element 
 *      - tips open outward in four directions:
 *         - up
 *         - down
 *         - left
 *         - right
 *      - tips can be: 
 *         - anchored to the triggering jQuery element
 *         - absolutely positioned
 *         - opened at the current mouse coordinates
 *         - anchored to a specified jQuery element
 *      - IE png transparency is handled via filters
 */
	var bindIndex = 0;
	var mouse_over_bubble = false;
	$.fn.extend({
		bubbletip: function(tip, options) {
			// check to see if the tip is a descendant of 
			// a table.bubbletip element and therefore
			// has already been instantiated as a bubbletip
			if ($('table.bubbletip #' + $(tip).id).length > 0) {
				return this;
			}

			var _this, _tip, _calc, _timeoutAnimate, _timeoutRefresh, _isActive, _isHiding, _wrapper, _bindIndex;

			_this = $(this);
			_tip = $(tip);
			_bindIndex = bindIndex++;  // for window.resize namespace binding
			
			var _options = {
				positionAt: 'element', // element | body | mouse
				positionAtElement: _this,
				offsetTop: 0,
				offsetLeft: 0,
				deltaPosition: 0,
				deltaDirection: 'up', // direction: up | down | left | right
				animationDuration: 250,
				animationEasing: 'swing', // linear | swing
				bindShow: 'mouseover', // mouseover | focus | click | etc.
				bindHide: 'mouseout', // mouseout | blur | etc.
				delayShow: 0,
				delayHide: 500
			};
			if (options) {
				_options = $.extend(_options, options);
			}
						

			// calculated values
			_calc = {
				top: 0,
				left: 0,
				delta: 0,
				mouseTop: 0,
				mouseLeft: 0,
				tipHeight: 0,
				bindShow: (_options.bindShow + ' ').replace(/ +/g, '.bubbletip' + _bindIndex),
				bindHide: (_options.bindHide + ' ').replace(/ +/g, '.bubbletip' + _bindIndex)
			};
			_timeoutAnimate = null;
			_timeoutRefresh = null;
			_isActive = false;
			_isHiding = false;

			// store the tip id for removeBubbletip
			if (!_this.data('bubbletip_tips')) {
				_this.data('bubbletip_tips', [[_tip.get(0).id, _calc.bindShow, _calc.bindHide, _bindIndex]]);
			} else {
				_this.data('bubbletip_tips', $.merge(_this.data('bubbletip_tips'), [[_tip.get(0).id, _calc.bindShow, _calc.bindHide, _bindIndex]]));
			}


			// validate _options
			if (!_options.positionAt.match(/^element|body|mouse$/i)) {
				_options.positionAt = 'element';
			}
			if (!_options.deltaDirection.match(/^up|down|left|right$/i)) {
				_options.deltaDirection = 'up';
			}

			// create the wrapper table element
			create_wrapper(false);

			_Calculate(true);

			// // handle window.resize
			// $(window).bind('resize.bubbletip' + _bindIndex, function() {
			// 	if (_timeoutRefresh) {
			// 		clearTimeout(_timeoutRefresh);
			// 	} else {
			// 		_wrapper.hide();
			// 	}
			// 	_timeoutRefresh = setTimeout(function() {
			// 		_Calculate(true);
			// 	}, 250);
			// });
			
			show_tip();

			// // handle mouseover and mouseout events
			// if (_options.bindShow == "mouseover")
			// {
			// 	show_tip();
			// }
			// else
			// {
			// 	$([_wrapper.get(0), this.get(0)]).bind(_calc.bindShow, function(e) {
			// 		show_tip();
			// 	});
			// }

		//		return false;
			$('.bubbletip').bind('mouseover',function(){
				mouse_over_bubble = true;
			});
			
			$('.bubbletip').bind('mouseout', function() {
							mouse_over_bubble = false;
			});
				
			$([_wrapper.get(0), this.get(0)]).bind(_calc.bindHide, function() {
							if (_timeoutAnimate) {
								clearTimeout(_timeoutAnimate);
							}
							_timeoutAnimate = setTimeout(function() {
								if (!mouse_over_bubble)
								{
									_HideWrapper();
									// _tip.appendTo('body');
									 // $('.bubbletip').remove();
									//removeBubbletip(tip);
								}
			
							}, _options.delayHide);
			
							return false;
						});
						
			function show_tip(){
				if (_timeoutAnimate) {
					clearTimeout(_timeoutAnimate);
				}
				_timeoutAnimate = setTimeout(function() {
					if (_isActive) {
						return;
					}
					_isActive = true;
					if (_isHiding) {
						_wrapper.stop(true, false);
					}

					var animation;

					if (_options.positionAt.match(/^element|body$/i)) {
						if (_options.deltaDirection.match(/^up|down$/i)) {
							if (!_isHiding) {
								_wrapper.css('top', parseInt(_calc.top + _calc.delta,10) + 'px');
							}
							animation = { 'opacity': 1, 'top': _calc.top + 'px' };
						} else {
							if (!_isHiding) {
								_wrapper.css('left', parseInt(_calc.left + _calc.delta,10) + 'px');
							}
							animation = { 'opacity': 1, 'left': _calc.left + 'px' };
						}
					} else {
						if (_options.deltaDirection.match(/^up|down$/i)) {
							if (!_isHiding) {
								_calc.mouseTop = e.pageY + _calc.top;
								_wrapper.css({ 'top': parseInt(_calc.mouseTop + _calc.delta,10) + 'px', 'left': parseInt(e.pageX - (_wrapper.width() / 2),10) + 'px' });
							}
							animation = { 'opacity': 1, 'top': _calc.mouseTop + 'px' };
						} else {
							if (!_isHiding) {
								_calc.mouseLeft = e.pageX + _calc.left;
								_wrapper.css({ 'left': parseInt(_calc.mouseLeft + _calc.delta,10) + 'px', 'top': parseInt(e.pageY - (_wrapper.height() / 2),10) + 'px' });
							}
							animation = { 'opacity': 1, 'left': _calc.left + 'px' };
						}
					}
					_isHiding = false;
					_wrapper.show();
					_wrapper.animate(animation, _options.animationDuration, _options.animationEasing, function() {
						_wrapper.css('opacity', '');
						_isActive = true;
						// $('.bubbletip').remove();
						
					});
				}, _options.delayShow);
				
			}
						
			function create_wrapper(noTip){
				if (noTip)
				{
					_wrapper = $('<table class="bubbletip" cellspacing="0" cellpadding="0"><tbody><tr><td class="bt-topleft"></td><td class="bt-top"></td><td class="bt-topright"></td></tr><tr><td class="bt-left"></td><td class="bt-content"></td><td class="bt-right"></td></tr><tr><td class="bt-bottomleft"></td><td class="bt-bottom"></td><td class="bt-bottomright"></td></tr></tbody></table>');
					
				}
				else
				{
					if (_options.deltaDirection.match(/^up$/i)) {
						_wrapper = $('<table class="bubbletip" cellspacing="0" cellpadding="0"><tbody><tr><td class="bt-topleft"></td><td class="bt-top"></td><td class="bt-topright"></td></tr><tr><td class="bt-left"></td><td class="bt-content"></td><td class="bt-right"></td></tr><tr><td class="bt-bottomleft"></td><td><table class="bt-bottom" cellspacing="0" cellpadding="0"><tr><th></th><td><div></div></td><th></th></tr></table></td><td class="bt-bottomright"></td></tr></tbody></table>');
					} else if (_options.deltaDirection.match(/^down$/i)) {
						_wrapper = $('<table class="bubbletip" cellspacing="0" cellpadding="0"><tbody><tr><td class="bt-topleft"></td><td><table class="bt-top" cellspacing="0" cellpadding="0"><tr><th></th><td><div></div></td><th></th></tr></table></td><td class="bt-topright"></td></tr><tr><td class="bt-left"></td><td class="bt-content"></td><td class="bt-right"></td></tr><tr><td class="bt-bottomleft"></td><td class="bt-bottom"></td><td class="bt-bottomright"></td></tr></tbody></table>');
					} else if (_options.deltaDirection.match(/^left$/i)) {
						_wrapper = $('<table class="bubbletip" cellspacing="0" cellpadding="0"><tbody><tr><td class="bt-topleft"></td><td class="bt-top"></td><td class="bt-topright"></td></tr><tr><td class="bt-left"></td><td class="bt-content"></td><td class="bt-right-tail"><div class="bt-right"></div><div class="bt-right-tail"></div><div class="bt-right"></div></td></tr><tr><td class="bt-bottomleft"></td><td class="bt-bottom"></td><td class="bt-bottomright"></td></tr></tbody></table>');
					} else if (_options.deltaDirection.match(/^right$/i)) {
						_wrapper = $('<table class="bubbletip" cellspacing="0" cellpadding="0"><tbody><tr><td class="bt-topleft"></td><td class="bt-top"></td><td class="bt-topright"></td></tr><tr><td class="bt-left-tail"><div class="bt-left"></div><div class="bt-left-tail"></div><div class="bt-left"></div></td><td class="bt-content"></td><td class="bt-right"></td></tr><tr><td class="bt-bottomleft"></td><td class="bt-bottom"></td><td class="bt-bottomright"></td></tr></tbody></table>');
					}
				}
				
				
				// append the wrapper to the document body
				_wrapper.appendTo('body');
				
				// apply IE filters to _wrapper elements
				if ((/msie/.test(navigator.userAgent.toLowerCase())) && (!/opera/.test(navigator.userAgent.toLowerCase()))) {
					$('*', _wrapper).each(function() {
						var image = $(this).css('background-image');
						if (image.match(/^url\(["']?(.*\.png)["']?\)$/i)) {
							image = RegExp.$1;
							$(this).css({
								'backgroundImage': 'none',
								'filter': 'progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=' + ($(this).css('backgroundRepeat') == 'no-repeat' ? 'crop' : 'scale') + ', src=\'' + image + '\')'
							}).each(function() {
								var position = $(this).css('position');
								if (position != 'absolute' && position != 'relative')
									$(this).css('position', 'relative');
							});
						}
					});
				}

				// move the tip element into the content section of the wrapper
				$('.bt-content', _wrapper).append(_tip);
				// show the tip (in case it is hidden) so that we can calculate its dimensions
				_tip.show();
				// handle left|right delta
				if (_options.deltaDirection.match(/^left|right$/i)) {
					// tail is 40px, so divide height by two and subtract 20px;
					_calc.tipHeight = parseInt(_tip.height() / 2,10);
					// handle odd integer height
					if ((_tip.height() % 2) == 1) {
						_calc.tipHeight++;
					}
					_calc.tipHeight = (_calc.tipHeight < 20) ? 1 : _calc.tipHeight - 20;
					if (_options.deltaDirection.match(/^left$/i)) {
						$('div.bt-right', _wrapper).css('height', _calc.tipHeight + 'px');
					} else {
						$('div.bt-left', _wrapper).css('height', _calc.tipHeight + 'px');
					}
				}
				// set the opacity of the wrapper to 0
				_wrapper.css('opacity', 0);
				// execute initial calculations
				
				
			}
						
			function _HideWrapper() {
				var animation;

				_isActive = false;
				_isHiding = true;
				if (_options.positionAt.match(/^element|body$/i)) {
					if (_options.deltaDirection.match(/^up|down$/i)) {
						animation = { 'opacity': 0, 'top': parseInt(_calc.top - _calc.delta,10) + 'px' };
					} else {
						animation = { 'opacity': 0, 'left': parseInt(_calc.left - _calc.delta,10) + 'px' };
					}
				} else {
					if (_options.deltaDirection.match(/^up|down$/i)) {
						animation = { 'opacity': 0, 'top': parseInt(_calc.mouseTop - _calc.delta,10) + 'px' };
					} else {
						animation = { 'opacity': 0, 'left': parseInt(_calc.mouseLeft - _calc.delta,10) + 'px' };
					}
				}
				_wrapper.animate(animation, _options.animationDuration, _options.animationEasing, function() {
					_wrapper.hide();
					_isHiding = false;
					_tip.appendTo('body');					
					_wrapper.addClass('oldbubble');
					$('.oldbubble').hide();
				});
			};

			function _Calculate(firstTime) {
				// calculate values
				if (_options.positionAt.match(/^element$/i)) {
					var offset = _options.positionAtElement.offset();
					if (_options.deltaDirection.match(/^up$/i)) {
						_calc.top = offset.top + _options.offsetTop - _wrapper.height();
						_calc.left = offset.left + _options.offsetLeft + ((_options.positionAtElement.width() - _wrapper.width()) / 2);
						_calc.delta = _options.deltaPosition;
					} else if (_options.deltaDirection.match(/^down$/i)) {
						_calc.top = offset.top + _options.positionAtElement.height() + _options.offsetTop;
						_calc.left = offset.left + _options.offsetLeft + ((_options.positionAtElement.width() - _wrapper.width()) / 2);
						_calc.delta = -_options.deltaPosition;
					} else if (_options.deltaDirection.match(/^left$/i)) {
						_calc.top = offset.top + _options.offsetTop + ((_options.positionAtElement.height() - _wrapper.height()) / 2);
						_calc.left = offset.left + _options.offsetLeft - _wrapper.width();
						_calc.delta = _options.deltaPosition;
					} else if (_options.deltaDirection.match(/^right$/i)) {
						_calc.top = offset.top + _options.offsetTop + ((_options.positionAtElement.height() - _wrapper.height()) / 2);
						_calc.left = offset.left + _options.positionAtElement.width() + _options.offsetLeft;
						_calc.delta = -_options.deltaPosition;
					}
				} else if (_options.positionAt.match(/^body$/i)) {
					if (_options.deltaDirection.match(/^up|left$/i)) {
						_calc.top = _options.offsetTop;
						_calc.left = _options.offsetLeft;
						// up or left
						_calc.delta = _options.deltaPosition;
					} else {
						if (_options.deltaDirection.match(/^down$/i)) {
							_calc.top = parseInt(_options.offsetTop + _wrapper.height(),10);
							_calc.left = _options.offsetLeft;
						} else {
							_calc.top = _options.offsetTop;
							_calc.left = parseInt(_options.offsetLeft + _wrapper.width(),10);
						}
						// down or right
						_calc.delta = -_options.deltaPosition;
					}
				} else if (_options.positionAt.match(/^mouse$/i)) {
					if (_options.deltaDirection.match(/^up|left$/i)) {
						if (_options.deltaDirection.match(/^up$/i)) {
							_calc.top = -(_options.offsetTop + _wrapper.height());
							_calc.left = _options.offsetLeft;
						} else if (_options.deltaDirection.match(/^left$/i)) {
							_calc.top = _options.offsetTop;
							_calc.left = -(_options.offsetLeft + _wrapper.width());
						}
						// up or left
						_calc.delta = _options.deltaPosition;
					} else {
						_calc.top = _options.offsetTop;
						_calc.left = _options.offsetLeft;
						// down or right
						_calc.delta = -_options.deltaPosition;
					}
				}
				
				//Flip
				//first handle corners
				
				// //bottom right
				// if (((_calc.left + _wrapper.width()) > $(window).width())&&((_calc.top + _wrapper.height()) > $(window).height())){
				// 	create_wrapper(true);
				//  	_calc.top = $(window).height() - _wrapper.height();
				// 	_calc.left = $(window).width() - _wrapper.width();
				// }
				// 
				// //bottom left
				// if ((_calc.left < 0)&&((_calc.top + _wrapper.height()) > $(window).height())){
				// 	create_wrapper(true);
				//  	_calc.top = $(window).height() - _wrapper.height();
				// 	_calc.left = 0;
				// }
				// 
				// //top right
				// if (((_calc.left + _wrapper.width()) > $(window).width())&&((_calc.top < 0))){
				// 	create_wrapper(true);
				//  	_calc.top = 0;
				// 	_calc.left = $(window).width() - _wrapper.width();
				// }
				// 
				// //top left
				// if ((_calc.left < 0)&&(_calc.top < 0 )){
				// 	create_wrapper(true);
				//  	_calc.top = 0;
				// 	_calc.left = 0;
				// }
				
				
				
				if (_calc.top < 0){
					_options.deltaDirection = "down";
					if (firstTime)
					{
						create_wrapper(false);
						_Calculate(false);
						return false;
					}
				}

				if (_calc.left < 0){
					_options.deltaDirection = "right";
					if (firstTime)
					{
						create_wrapper(false);
						_Calculate(false);
						return false;
					}
				}
				
				if ((_calc.left + _wrapper.width()) > $(window).width()){
					_options.deltaDirection = "left";
					if (firstTime)
					{
						create_wrapper(false);
						_Calculate(false);
						return false;
					}
				}

				if ((_calc.top + _wrapper.height()) > $(window).height()){
					_options.deltaDirection = "up";
					if (firstTime)
					{
						create_wrapper(false);
						_Calculate(false);
						return false;
					}
				}
				
				//Nudge edges
				if ((_calc.left + _wrapper.width()) > $(window).width()){
				 	create_wrapper(true);
				 	_calc.left = $(window).width() - _wrapper.width();
				}
				
				if ((_calc.top + _wrapper.height()) > $(window).height()){
				 	create_wrapper(true);
				  	_calc.top = $(window).height() - _wrapper.height();
				}

				if (_calc.left < 0){
				 	create_wrapper(true);
				  	_calc.left = 0;
				}

				if (_calc.top < 0){
				 	create_wrapper(true);
				  	_calc.top = 0;
				}
				


				
				// hide
				_wrapper.hide();
				_wrapper.addClass('oldbubble');
				$('.oldbubble').hide();
				
				// handle the wrapper (element|body) positioning
				if (_options.positionAt.match(/^element|body$/i)) {
					_wrapper.css({
						'position': 'absolute',
						'top': _calc.top + 'px',
						'left': _calc.left + 'px'
					});
				}
				
				return true;
			};
			return this;
		}// ,
		// 		removeBubbletip: function(tips) {
		// 				$('.bubbletip').remove();
		// 				var tipsActive;
		// 				var tipsToRemove = new Array();
		// 				var arr, i, ix;
		// 				var elem;
		// 			
		// 				tipsActive = $.makeArray($(this).data('bubbletip_tips'));
		// 			
		// 				// convert the parameter array of tip id's or elements to id's
		// 				arr = $.makeArray(tips);
		// 				for (i = 0; i < arr.length; i++) {
		// 					tipsToRemove.push($(arr[i]).get(0).id);
		// 				}
		// 			
		// 				for (i = 0; i < tipsActive.length; i++) {
		// 					ix = null;
		// 					if ((tipsToRemove.length == 0) || ((ix = $.inArray(tipsActive[i][0], tipsToRemove)) >= 0)) {
		// 						// remove all tips if there are none specified
		// 						// otherwise, remove only specified tips
		// 			
		// 						// find the surrounding table.bubbletip
		// 						elem = $('#' + tipsActive[i][0]).get(0).parentNode;
		// 						while (elem.tagName.toLowerCase() != 'table') {
		// 							elem = elem.parentNode;
		// 						}
		// 						// attach the tip element to body and hide
		// 						$(tipsActive[i][0]).appendTo('body').hide();
		// 						// remove the surrounding table.bubbletip
		// 						$(elem).remove();
		// 			
		// 						// unbind show/hide events
		// 						$(this).unbind(tipsActive[i][1]).unbind([i][2]);
		// 			
		// 						// unbind window.resize event
		// 						$(window).unbind('resize.bubbletip' + tipsActive[i][3]);
		// 					}
		// 				}
		// 			
		// 				return this;
		// 			}
	});


	/*
	 * Date Format 1.2.3
	 * (c) 2007-2009 Steven Levithan <stevenlevithan.com>
	 * MIT license
	 *
	 * Includes enhancements by Scott Trenda <scott.trenda.net>
	 * and Kris Kowal <cixar.com/~kris.kowal/>
	 *
	 * Accepts a date, a mask, or a date and a mask.
	 * Returns a formatted version of the given date.
	 * The date defaults to the current date/time.
	 * The mask defaults to dateFormat.masks.default.
	 */

	var dateFormat = function () {
		var	token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
			timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
			timezoneClip = /[^-+\dA-Z]/g,
			pad = function (val, len) {
				val = String(val);
				len = len || 2;
				while (val.length < len) val = "0" + val;
				return val;
			};

		// Regexes and supporting functions are cached through closure
		return function (date, mask, utc) {
			var dF = dateFormat;

			// You can't provide utc if you skip other args (use the "UTC:" mask prefix)
			if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
				mask = date;
				date = undefined;
			}

			// Passing date through Date applies Date.parse, if necessary
			date = date ? new Date(date) : new Date;
			if (isNaN(date)) throw SyntaxError("invalid date");

			mask = String(dF.masks[mask] || mask || dF.masks["default"]);

			// Allow setting the utc argument via the mask
			if (mask.slice(0, 4) == "UTC:") {
				mask = mask.slice(4);
				utc = true;
			}

			var	_ = utc ? "getUTC" : "get",
				d = date[_ + "Date"](),
				D = date[_ + "Day"](),
				m = date[_ + "Month"](),
				y = date[_ + "FullYear"](),
				H = date[_ + "Hours"](),
				M = date[_ + "Minutes"](),
				s = date[_ + "Seconds"](),
				L = date[_ + "Milliseconds"](),
				o = utc ? 0 : date.getTimezoneOffset(),
				flags = {
					d:    d,
					dd:   pad(d),
					ddd:  dF.i18n.dayNames[D],
					dddd: dF.i18n.dayNames[D + 7],
					m:    m + 1,
					mm:   pad(m + 1),
					mmm:  dF.i18n.monthNames[m],
					mmmm: dF.i18n.monthNames[m + 12],
					yy:   String(y).slice(2),
					yyyy: y,
					h:    H % 12 || 12,
					hh:   pad(H % 12 || 12),
					H:    H,
					HH:   pad(H),
					M:    M,
					MM:   pad(M),
					s:    s,
					ss:   pad(s),
					l:    pad(L, 3),
					L:    pad(L > 99 ? Math.round(L / 10) : L),
					t:    H < 12 ? "a"  : "p",
					tt:   H < 12 ? "am" : "pm",
					T:    H < 12 ? "A"  : "P",
					TT:   H < 12 ? "AM" : "PM",
					Z:    utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
					o:    (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
					S:    ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
				};

			return mask.replace(token, function ($0) {
				return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
			});
		};
	}();

	// Some common format strings
	dateFormat.masks = {
		"default":      "ddd mmm dd yyyy HH:MM:ss",
		shortDate:      "m/d/yy",
		mediumDate:     "mmm d, yyyy",
		longDate:       "mmmm d, yyyy",
		fullDate:       "dddd, mmmm d, yyyy",
		shortTime:      "h:MM TT",
		mediumTime:     "h:MM:ss TT",
		longTime:       "h:MM:ss TT Z",
		isoDate:        "yyyy-mm-dd",
		isoTime:        "HH:MM:ss",
		isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss",
		isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
	};

	// Internationalization strings
	dateFormat.i18n = {
		dayNames: [
			"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
			"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
		],
		monthNames: [
			"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
			"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
		]
	};
