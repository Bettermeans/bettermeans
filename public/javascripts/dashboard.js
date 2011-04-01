var D = []; //all data
var R = []; //all retrospectives
var local_D = null;
// var local_R = null;
var MAX_REQUESTS_PER_PERSON = 4;
var TIMER_INTERVAL = 15000; //15 seconds
var INACTIVITY_THRESHOLD = 300000; //5 minutes
var timer_active = false;
var ITEMHASH = new Array(); //mapping between item IDs and their id in the D array
var keyboard_shortcuts = false;
var searching = false; //true when user is entering text in search box
var default_new_title = 'Enter Title Here';
var new_comment_text = 'Add new comment';
var new_todo_text = 'Add todo';
// var panel_height = $(window).height() - $('.gt-hd').height() - $('#help_section').height() + 28;// + $('.gt-footer').height() ;
var panel_height = $(window).height() - $('.gt-hd').height() + 28;// + $('.gt-footer').height() ;
var last_activity = new Date(); //tracks last activity of mouse or keyboard click. Used to turn off server polling
var last_data_pull = new Date(); //tracks last data recieved from server
var highest_pri = -9999;
var loaded_panels = 0; //keeps track of how many panels have had their data loaded
var local_store = null; //local persistant storage
var ok_to_save_local_data = false;
var complexity_description = ['Real Easy','.','.','Average','.','.','Super Hard'];
var new_attachments = []; //stores ids of attachments to a new item
var timer_started = false;

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

function start(){
	disable_refresh_button();
	arm_checkboxes();
	set_sub_toggle();	
	
	timer_active = false; //stop timer from starting until data loads
	$('.help-section-link').bind('click',function() {
	  resize();
	});
	
	$("#dash_key").mybubbletip('#help_key', {deltaDirection: 'right', bindShow: 'click'});
	
	$('#fast_search').watermark('watermark','Quick Filter');
	//Checking for single issue display
	if (show_issue_id){
		show_issue_full(show_issue_id);
		$("#load_dashboard").show();
		$("#loading").hide();
	}
	else if (show_retro_id){
		show_retro_full(show_retro_id);
		$("#load_dashboard").show();
		$("#loading").hide();
	}
	else{
		load_dashboard();
	}
}

//Chooses setting of sub workstream toggle button and adds events to it
function set_sub_toggle(){
	var include = $.cookie('include_sub' + currentUserId);
	if (include == null){
		include = 'true';
	}
	
	if (include == 'true'){
		$("#toggle_sub_on").click();
	}
	else{
		$("#toggle_sub_off").click();
	}
	
	$("#toggle_sub_on").click(function(){
		$.cookie('include_sub' + currentUserId, 'true', { expires: 365 });
		refresh_local_data();	
	});
	$("#toggle_sub_off").click(function(){
		$.cookie('include_sub' + currentUserId, 'false', { expires: 365 });
		refresh_local_data();	
	});
}

function load_dashboard(){
	//prepares ui for page
	prepare_page();
	load_dashboard_data();
	start_timer();
	
	$(document).keyup(function(e){
		last_activity = new Date();
		start_timer();
		if (searching){
			var text = $('#fast_search').val();
			search_for(text);
		}
	});

	$(document).click(function(e)
	{
		start_timer();
		last_activity = new Date();
	});

	$(document).focus(function(e)
	{
		start_timer();
		last_activity = new Date();
	});
	
}

//For IE explorer handling of xml
function parse_xml(xml){
	if (jQuery.browser.msie) {  
	    var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");  
	    xmlDoc.loadXML(xml);  
	    xml = xmlDoc;  
	  }  
	  return xml;
}


function load_dashboard_data(){
	$("#load_dashboard").hide();	
	$("#loading").hide();
	
	get_local_data();
	// if (local_R == null){
	// 	local_R = [];
	// }
	
	if (local_D != null){
		data_ready(local_D,'all');
		// if (credits_enabled){
		// 	retros_ready(local_R);
		// 	load_retros();
		// }
		ISSUE_COUNT = -1; //we are loading from local data, so we set the counter past 10 to refresh moved items
		timer_active = true;
		new_dash_data();
		local_D = null;
		// local_R = null;
	}
	else{
		D = [];
		R = [];
		keyboard_shortcuts = false;
		
		ISSUE_COUNT = 0;
		
		load_dashboard_data_for_statuses('10,11','new');
		load_dashboard_data_for_statuses('1,6','open');
		load_dashboard_data_for_statuses('4','inprogress');
		load_dashboard_data_for_statuses('8,14,13','done');
		load_dashboard_data_for_statuses('9','canceled'); 
		// load_dashboard_data_for_statuses('12','archived'); 
	}
	
	ok_to_save_local_data = true;
	
}

function refresh_local_data(){
	$("#loading_error").hide();
	timer_active = false;
	disable_refresh_button();
	clear_filters();
	try{
	store.set('D_' + projectId, null);
	store.set('R_' + projectId, null);
	store.set('lata_data_pull_' + projectId, null);
	}
	catch(err){
		return;
	}
	wipe_panels();
	display_panels();
	recalculate_widths();
	load_dashboard_data();
	// enable_refresh_button();
	
}

function save_local_data(){
	if (ok_to_save_local_data == false) {return false;}
	
	try{
		
		store.set('D_' + projectId,JSON.stringify(D));
		store.set('R_' + projectId,JSON.stringify(R));
		store.set('last_data_pull_' + projectId,last_data_pull);
		store.set('includes_sub_workstreams' + projectId, ($('#include_subworkstreams_checkbox').attr("checked") == true));
		return true;
	}
	catch(err){
		return false;
	}
}

function get_local_data(){
	try{
		
		includes_subs = store.get('includes_sub_workstreams' + projectId);
		
		//don't use local data if stored includes subs but requested data doesn't, or vise versa
		if (includes_subs != String($('#include_subworkstreams_checkbox').attr("checked") == true)){
			return false; 
		}
		
		local_D = JSON.parse(store.get('D_' + projectId));
		
		if (local_D == null) {return false;}
		
		// local_R = JSON.parse(store.get('R_' + projectId));
		// if (local_R == null) {local_R = [];}
		
		last_data_pull = new Date(store.get('last_data_pull_' + projectId));

		//refresh local data since latest code update that require data structure to be updated
		if (Date.parse(LAST_LOCAL_DB_CHANGE) > last_data_pull){
			return false;
		}
		else{
			return true;
		}
	}
	catch(err){
		return false;
	}
}

function load_dashboard_data_for_statuses(status_ids,name){
	var url = url_for({ controller: 'projects',
	                           action    : 'dashdata',
								id		: projectId
	                          });

	
	// var url = url + '?status_ids=1,4,6,8,10,11,13,14';
	url = url + '?status_ids=' + status_ids;
	
	if ($('#include_subworkstreams_checkbox').attr("checked") == true){
		url = url + "&include_subworkstreams=true";
	}
	
	
	$.ajax({
	   type: "GET",
	   dataType: "json",
	   contentType: "application/json",
	   cache:false,
		data:{},
	   // dataType: ($.browser.msie) ? "text" : "json",
	   url: url,
	   success:  	function(html){
			last_data_pull = new Date();
			ISSUE_COUNT = ISSUE_COUNT + html.length;
			data_ready(html,name);
		},
	   error: 	function (xhr, textStatus, errorThrown) {
		// alert(xhr.status);
		// typically only one of textStatus or errorThrown will have info
		// possible valuees for textstatus "timeout", "error", "notmodified" and "parsererror
		$("#loading").hide();
		$("#loading_error").show();
		},
		timeout: 30000 //30 seconds
	 });
}

	

// listens for any navigation keypress activity
// $(document).keypress(function(e)
// {
// 	if (!keyboard_shortcuts){return;};
// 	
// 	switch(e.which)
// 	{
// 		// user presses the "a"
// 		case 110:	new_item();
// 					break;	
// 				
// 	}
// });

function data_ready(html,name){
	last_item = D.length;
	D = D.concat(html);
	add_items_to_panels(last_item);
	sort_panels();
	if (name == 'all'){
		$('#new_close').addClass('closePanel').removeClass('closePanelLoading');
		$('#open_close').addClass('closePanel').removeClass('closePanelLoading');
		$('#inprogress_close').addClass('closePanel').removeClass('closePanelLoading');
		$('#done_close').addClass('closePanel').removeClass('closePanelLoading');
		loaded_panels = 6;
		enable_refresh_button();
		timer_active = true;
	}
	else{
		$('#' + name + '_close').addClass('closePanel').removeClass('closePanelLoading');
		loaded_panels = loaded_panels + 1;
	}
	update_panel_counts();
	prepare_item_lookup_array(); //TODO: move this somewhere else for efficiency. it should only run once
	// if (loaded_panels == 4 && credits_enabled){
	// 	load_retros();
	// 	timer_active = true;
	// }
	if (loaded_panels == 4){
		enable_refresh_button();
		timer_active = true;
	}
}

function replace_reloading_images_for_panels(){
	$('.closePanelLoading').addClass('closePanel').removeClass('closePanelLoading');
}


// function load_retros(){
// 	
// 		if (!credits_enabled){
// 			return false;
// 		}
// 		var url = url_for({ controller: 'projects',
// 								id		: projectId
// 			                          });
// 		url = url + '/retros/index_json';
// 			    		
// 		$.ajax({
// 		   type: "GET",
// 		   dataType: "json",
// 		   contentType: "application/json",
// 		   url: url,
// 		   success:  	function(html){
// 				retros_ready(html);
// 				enable_refresh_button();
// 			},
// 		   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
// 			// typically only one of textStatus or errorThrown will have info
// 			// possible valuees for textstatus "timeout", "error", "notmodified" and "parsererror
// 			$("#loading").hide();
// 			$("#loading_error").show();
// 			enable_refresh_button();
// 			},
// 			timeout: 30000 //30 seconds
// 		 });
// 		return true;
// }
// 
function enable_refresh_button(){
	$('#refresh_data').show();
}

function disable_refresh_button(){
	$('#refresh_data').hide();
}

function retros_ready(html,load_remaining_panels){
	R = html;
	insert_retros();	
}

function insert_retros(){
	$('.retrospective').remove();
	for(var i = 0; i < R.length; i++ ){
		add_retro(i,"top",false);	
	}
}

function add_retro(rdataId,position,scroll){
	var html = generate_retro(rdataId);
	var panelid = 'done';
	if (position=="bottom")
	{
		$("#" + panelid + '_end_of_list').append(html);
	}
	else if (position=="top")
	{
		$("#" + panelid+ '_end_of_list').prepend(html);
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


// function load_search(){
// 	html = '';
// 
// 	html = html + '	<table class="searchField">';
// 	html = html + '	<tbody>';
// 	html = html + '	<tr>';
// 	html = html + '	<td>';
// 	html = html + '	<a onclick="$(\'searchString\').focus(); return false;" href="#">';
// 	html = html + '	<img src="/images/search_left.png" alt="Search" title=""/>';
// 	html = html + '	</a>';
// 	html = html + '	</td>';
// 	html = html + '	<td class="field">';
// 	html = html + '	<input id="searchString" type="text" autocomplete="off" size="20" name="searchString" value=""/>';
// 	html = html + '	</td>';
// 	html = html + '	<td style="vertical-align:top;">';
// 	html = html + '	<img src="/images/search_right.png"/>';
// 	html = html + '	</td>';
// 	html = html + '	</tr>';
// 	html = html + '	</tbody>';
// 	html = html + '	</table>';
// 	
// 	$('#header').append(html);
// }


function prepare_page(){
	display_panels();
	resize();
	recalculate_widths();
	keyboard_shortcuts = true;	
	make_text_boxes_toggle_keyboard_shortcuts();
}

function start_timer(){
	if (timer_started == true){
		return;
	}
	else{
		timer_started = true;
	}
	
	$.timer(TIMER_INTERVAL, function (timer) {
		timer_beat(timer);
	});
}

function stop_timer(timer){
	timer_started = false;
	timer.stop();
}

function prepare_item_lookup_array(){
	for (var i=0; i<D.length;i++){
		ITEMHASH["item" + String(D[i].id)] = i;
	}
}


// Loads all items in their perspective panels, and sets up panels
function display_panels(){
	loaded_panels = 0;
	insert_panel(0,'new','Open',true);
	add_new_link();
	// insert_panel(0,'estimate','In Estimation',true);
	// insert_panel(0,'open','Open',true);
	insert_panel(0,'inprogress','In Progress',true);
	insert_panel(0,'done','Done',false);
	insert_panel(0,'canceled','Canceled',false);
	// insert_panel(0,'archived','Archived',false);
}

function wipe_panels(){
	$('.panel').remove();
	$('.dashboard-button-panel').remove();
}

function sort_panels(){
	// sort_panel('open');
	sort_panel('new');
	sort_panel('inprogress');
}

function add_items_to_panels(last_item){
	for(var i = last_item; i < D.length; i++ ){
			add_item(i,"bottom",false);	
	}
	
	adjust_button_container_widths();

}

function adjust_button_container_widths(){
	
	if (jQuery.browser.msie) {  
	
		$.each($('.itemCollapsedButtons'), function(){

		var $sum = 0;
	
		$(this).children().each(function()
		{
			if ($(this).is(":visible")){
			 	$sum += $(this).outerWidth();
			}
		});

		$(this).width($sum);

		});
	}
}

//Called after data is ready for a retrospective
function rdata_ready(html,rdataId){
	var retro = R[rdataId];
	var panelid = 'retro_' + retro.id;
	var i = D.length;
	
	$('#' + panelid + '_close').addClass('closePanel').removeClass('closePanelLoading');
	
	D = D.concat(html);
	if (retro.status_id == 1){
		var notice = generate_notice('<a class="date_label" title="Retrospective is now open" href="#" onclick="click_retro(' + i +',this.id);return false;">Retrospective is open &rArr;</a>', rdataId);
		$('#retro_' + retro.id + '_items').prepend(notice);
	}
	for(; i < D.length; i++ ){
		add_item(i,"bottom",false,panelid);	
	}
	update_panel_count(panelid,true);	
}


function show_item_fancybox(dataId){
	var itemId = D[dataId].id;
	var url = url_for({ controller: 'issues',
	                           action    : 'show',
								id		: itemId
	                          });
	
    url = url + '?dataId=' + dataId;
	
	
	show_fancybox(url,'loading data...');
}

function show_details_flyover(dataId,callingElement,delayshow){

	$('#flyover_' + dataId).remove();
	generate_details_flyover(dataId);		
	
	$('#' + callingElement).bubbletip($('#flyover_' + dataId), {
		deltaDirection: 'right',
		delayShow: delayshow,
		delayHide: 100,
		offsetLeft: 0
	});	
}

function show_estimate_flyover(dataId,callingElement){
	$('#flyover_estimate_' + dataId).remove();
	generate_estimate_flyover(dataId);		
		
	$('#' + callingElement).bubbletip($('#flyover_estimate_' + dataId), {
		deltaDirection: 'right',
		delayShow: 0,
		delayHide: 100,
		offsetLeft: 0
	});	
}

function show_points_flyover(dataId,callingElement){
	$('#flyover_points_' + dataId).remove();
	generate_points_flyover(dataId);		
		
	$('#' + callingElement).bubbletip($('#flyover_points_' + dataId), {
		deltaDirection: 'right',
		delayShow: 0,
		delayHide: 100,
		offsetLeft: 0
	});	
}

function hide_bubbletips(){
	$('.bubbletip').hide();
}


function show_pri_flyover(dataId,callingElement){

	$('#flyover_pri_' + dataId).remove();
	generate_pri_flyover(dataId);		
		
	$('#' + callingElement).bubbletip($('#flyover_pri_' + dataId), {
		deltaDirection: 'right',
		delayShow: 0,
		delayHide: 100,
		offsetLeft: 0
	});	
}

function show_agree_flyover(dataId,callingElement){

	$('#flyover_agree_' + dataId).remove();
	generate_agree_flyover(dataId);		

	$('#' + callingElement).bubbletip($('#flyover_agree_' + dataId), {
		deltaDirection: 'right',
		delayShow: 0,
		delayHide: 100,
		offsetLeft: 0
	});	
}

function show_accept_flyover(dataId,callingElement){

	$('#flyover_accept_' + dataId).remove();
	generate_accept_flyover(dataId);		
	
	//If flyover hasn't already been generated, then generate it!
	// if ($('#flyover_accept_' + dataId).length == 0){
	// 	generate_accept_flyover(dataId);		
	// }
		
	$('#' + callingElement).bubbletip($('#flyover_accept_' + dataId), {
		deltaDirection: 'right',
		delayShow: 0,
		delayHide: 100,
		offsetLeft: 0
	});	
}

function is_visible(item){
	if (item == null) {return false;}
	
	return true;
}

function is_startable(item){
	if (item.status.name == "Open"){
		return true;
		// return ((item.pri > (highest_pri - startable_priority_tiers))||(item.pri == 0));
	}
	else{
		return false;
	}
}

function add_item(dataId,position,scroll,panelid){
	
	if (!is_visible(D[dataId])) {return;}
	
	if (!panelid){
		//Deciding on wich panel for this item?
		switch (D[dataId].status.name){
		case 'New':
		panelid= 'new';
		break;
		case 'Estimate':
		panelid= 'new';
		break;
		case 'Open':
		panelid= 'new';
		break;
		case 'Committed':
		panelid = 'inprogress';
		break;
		case 'Done':
		panelid = 'done';
		break;
		case 'Accepted':
		panelid = 'done';
		break;
		case 'Rejected':
		panelid = 'done';
		break;
		case 'Canceled':
		panelid = 'canceled';
		break;
		case 'Archived':
		panelid = 'canceled';
		break;
		default : panelid = 'canceled';
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

function generate_estimate_flyover(dataId){
	var item = D[dataId];
	var i = 0; //counter
	var credits = item.points;
	
	var you_voted = "You haven't estimated yet";
	var title = '';
	var user_estimate = -100;
	var total_people_estimating = 0;
	
	for(i=0; i < item.issue_votes.length; i++){
		if (item.issue_votes[i].vote_type != 4) continue;
		total_people_estimating++ ;
		
		if (currentUserLogin == item.issue_votes[i].user.login){			
			
			var user_estimate_text = "";
			if (item.issue_votes[i].points == -1){
				user_estimate = item.issue_votes[i].points;
				user_estimate_text = "Don't know";
			}
			else if (credits_enabled){
				user_estimate = item.issue_votes[i].points;
				user_estimate_text = user_estimate + " credits";
			}
			else{
				user_estimate = convert_points_to_complexity(item.issue_votes[i].points); 
				user_estimate_text = user_estimate;
			}
			
			you_voted = "Your estimate " + user_estimate_text + " - " + humane_date(item.issue_votes[i].updated_at);
		}
	}
	
	//If user estimated, or item is in progress, we can see the average
	if (((item.status.name != 'New')&&(item.status.name != 'Estimate')&&(item.status.name != 'Open')) || (user_estimate != -100)){
		if (credits == null){
			title = 'No binding estimates yet';
		}
		else if (credits_enabled){
			title = 'Avg ' + Math.round(credits) + ' credits (' + total_people_estimating + ' people)';
		}
		else{
			title = 'Avg ' + credits_to_points(Math.round(credits),credit_base) + ' points (' + total_people_estimating + ' people)';
		}
	}
	else{
		title = "Vote to see Estimates";
	}	
	
	var history = '';
	//Show history if user estimated, or if item is no longer available for estimation
	if ((user_estimate != -100)||((item.status.name != 'New')&&(item.status.name != 'Estimate')&&(item.status.name != 'Open'))){
		for(i = 0; i < item.issue_votes.length; i++ ){
			if (item.issue_votes[i].vote_type != 4) continue;
			
			if (item.issue_votes[i].points == -1){
				history = history + 'Don\'t know - ' + item.issue_votes[i].user.firstname + ' ' + item.issue_votes[i].user.lastname;
			}
			else if (credits_enabled){
				history = history + item.issue_votes[i].points + ' cr - ' + item.issue_votes[i].user.firstname + ' ' + item.issue_votes[i].user.lastname;
			}
			else{
				history = history + credits_to_points(Math.round(item.issue_votes[i].points),credit_base) + ' points - ' + item.issue_votes[i].user.firstname + ' ' + item.issue_votes[i].user.lastname;
			}
			
			if (item.issue_votes[i].isbinding == false){
				history = history + ' (non-binding)';
			}
			history = history + '<br>';
		}	
		
	}
	
	var action_header = '';
	var buttons = '';
	
	// if (((item.status.name != 'New')&&(item.status.name != 'Estimate')&&(item.status.name != 'Open'))) {	
		user_estimate == -100 ? action_header = 'Make an estimate' : action_header = 'Change your estimate';

		buttons = buttons + generate_estimate_button(-1,-1, item.id, dataId, (user_estimate != -100));
		
		for(i = 0; i < point_factor.length; i++ ){
			buttons = buttons + generate_estimate_button(i,point_factor[i] * credit_base, item.id, dataId, (user_estimate != -100));
		}
		buttons = buttons + generate_custom_estimate_button(dataId,user_estimate);
	// }
	
	return generate_flyover(dataId,'estimate',title,you_voted,action_header,buttons,history);
	
}

function generate_points_flyover(dataId){
	var item = D[dataId];
	var i = 0; //counter
	var credits = item.points;
	
	var you_voted = "This is a read only value, and cannot be voted on.";
	
	var	title = item.points + ' credits';
	
	var history = '';
	
	var action_header = '';
	var buttons = '';
	
	return generate_flyover(dataId,'points',title,you_voted,action_header,buttons,history);
	
}


function prompt_for_number(message,default_data){
	var amount=prompt(message,default_data);
	if (amount == null || amount == '' || (!isNumeric(amount))) { 
		return prompt_for_number(message,default_data); 
	}
	
	else
	{ 
		return amount;
	}
}


function prompt_for_custom_estimate(dataId,points){
	var amount = prompt_for_number("Please enter expense amount in dollars:",points);
	send_item_action(dataId,'estimate','&points=' + amount);
}

	

function generate_custom_estimate_button(dataId,user_estimate){
	if (!credits_enabled){
		return '';
	}
	
	var points = 0;
	if (user_estimate > -1){
		points = user_estimate;
	}
	
	var html = '<div>';
	html = html + '<img src="/images/dice_No.png" width="18" height="18" alt="Custom Credits" class="dice" onclick="prompt_for_custom_estimate(' + dataId + ',' + points + ')">';	
	html = html + ' custom amount';
	html = html + '</div>';
	return html;
}

function convert_points_to_complexity(points){
	if (points == -1){
		return "Don't know";
	}
	
	if (points > complexity_description.length - 1){
		points = complexity_description.length - 1;
	}
	return complexity_description[points];
}


function generate_estimate_button(points,credits, itemId, dataId, comment){
	var label = '';
	if (credits == -1){
		label = "Don't know";
	}
	else if (credits_enabled){
		label = credits + ' Credits';
	}
	else{
		label = convert_points_to_complexity(points);
	}
	var html = '<div>';
	var onclick = 'click_estimate_from_flyover(' + dataId + ',this,\'' + '&points=' + credits + '\',' + comment + ');return false;';
	
	html = html + '<img src="/images/dice_' + Math.round(points) + '.png" width="18" height="18" alt="' + label + '" class="dice" onclick="' + onclick + '">';		
	
	
	html = html + ' ' + label;
	html = html + '</div>';
	return html;
}

function generate_pri_action(points, itemId, dataId){
	var html = '<div id="item_flyover_pri_button_' + dataId + '" class="clickable pri_button pri_button_action pri_button_' + pri_text(points).toLowerCase() + '" onclick="click_pri(' + dataId + ',this,' + points + ');return false;">' + pri_text(points) + '</div>';	
	return html;
}

function pri_text(points){
	switch (points){
	case 0:
		return "NEUTRAL";
		break;
	case 1:
		return "UP";
		break;
	case -1:
		return "DOWN";
		break;
	}
	return "ERROR: OUT OF RANGE";
}

function agree_text(points){
	switch (points){
	case 0:
		return "NEUTRAL";
		break;
	case 1:
		return "AGREE";
		break;
	case -1:
		return "DISAGREE";
		break;
	case -9999:
		return "BLOCK";
		break;
	}
	return "ERROR: OUT OF RANGE";
}

function accept_text(points){
	switch (points){
	case 0:
		return "NEUTRAL";
		break;
	case 1:
		return "ACCEPT";
		break;
	case -1:
		return "REJECT";
		break;
	case -9999:
		return "BLOCK";
		break;
	}
	return "ERROR: OUT OF RANGE";
}

function generate_pri_flyover(dataId){
	var item = D[dataId];
	
	var points;
	item.pri == null ? points = 0 : points = item.pri;
	
	var you_voted = '';
	var user_pri_id = 0;
	var total_people_prioritizing = 0;
	var i = 0; //counter variable
	
	for(i=0; i < item.issue_votes.length; i++){
		if (currentUserLogin == item.issue_votes[i].user.login){
			if (item.issue_votes[i].vote_type != 3) continue;
			total_people_prioritizing++ ;
			you_voted = "You prioritized " + pri_text(item.issue_votes[i].points) + " - " + humane_date(item.issue_votes[i].updated_at);
			user_pri_id = item.issue_votes[i].id;
		}
	}
	
	if (user_pri_id == 0){
		you_voted = "You haven't prioritized this item";
	}
	
	var title = 'Total ' + points + ' points (' + total_people_prioritizing + ' people)';
	var action_header = '';
	user_pri_id == 0 ? action_header = 'Prioritize' : action_header = 'Change your prioritization:';
	
	var buttons = '';
	buttons = buttons + generate_pri_action(1, item.id, dataId) + '<br>';
	buttons = buttons + generate_pri_action(0, item.id, dataId) + '<br>';
	buttons = buttons + generate_pri_action(-1, item.id, dataId);
	
	
	var history = '';
	if (!(item.issue_votes == null || item.issue_votes.length < 1)){
		for(i = 0; i < item.issue_votes.length; i++ ){
			if (item.issue_votes[i].vote_type != 3) continue;
			history = history + pri_text(item.issue_votes[i].points) + ' - ' + item.issue_votes[i].user.firstname + ' ' + item.issue_votes[i].user.lastname;
			if (item.issue_votes[i].isbinding == false){
				history = history + ' (non-binding)';
			}
			history = history + '<br>';
		}
	}
	
	
		
	return generate_flyover(dataId,'pri',title,you_voted,action_header,buttons,history);
}


function generate_flyover(dataId,type,title,you_voted,action_header,buttons,history){
	var html = '';
	
	html = html + '<div id="flyover_' + type + '_' + dataId + '" class="overlay" style="display:none;">';
	html = html + '	  <div style="border: 0pt none ; margin: 0pt;">';
	html = html + '	    <div class="overlayContentWrapper gt-Sfo flyover" style="width: 200px;">';
	html = html + '	      <div class="storyTitle">';
	html = html + title;
	html = html + '	      </div>';
	html = html + '	      <div class="sectionDivider">';
	html = html + '	      <div style="height: auto;">';
	html = html + '	        <div class="metaInfo">';
	html = html + '	          <div class="left">';
	html = html + you_voted;
	html = html + '	          </div>';
	html = html + '	          <div class="clear"></div>';
	html = html + '	        </div>';
	html = html + '	        <div class="gt-Ifc gt-Sd">';
	html = html + '	            <div class="section">';
	html = html + '	                <div class="header">';
	html = html + action_header;
	html = html + '	                </div>';
	html = html + '	                <table class="buttonsTable">';
	html = html + '	                  <tbody>';
	html = html + '	                    <tr class="buttonsTextRow">';
	html = html + '	                      <td class="buttonsText">';
	html = html + buttons;
	html = html + '	                      </td>';
	html = html + '	                    </tr>';
	html = html + '	                  </tbody>';
	html = html + '	                </table>';
	
	if (history != ''){
		html = html + '	  <div class="header">';
		html = html + '	    History';
		html = html + '	  </div>';
		html = html + '	  <table class="notesTable">';
		html = html + '	    <tbody>';
		html = html + '<tr class="noteInfoRow">';
		html = html + '<td class="noteInfo">';
		html = html + history;
	 	html = html + '</td>';
	  	html = html + '</tr>';
		html = html + '	    </tbody>';
		html = html + '	  </table>';
		html = html + '	<div class="clear"></div>';
		html = html + '	              </div>';
	}
	
	html = html + '	        </div>';
	html = html + '	      </div>';
	html = html + '	    </div>';
	html = html + '	  </div>';
	html = html + '	</div>';
		
	$('#flyovers').append(html);
	
	return html;
}

function generate_agree_flyover(dataId){
	var item = D[dataId];
	
	var agree_total;
	item.agree_total == null ? agree_total = 0 : agree_total = item.agree_total;
	
	var you_voted = '';
	var user_agree_id = -1;
	var total_people_agreeing = 0;
	var i = 0; //counter variable
	
	for(i=0; i < item.issue_votes.length; i++){
		if (currentUserLogin == item.issue_votes[i].user.login){
			if (item.issue_votes[i].vote_type != 1) continue;
			total_people_agreeing++ ;
			title = "You voted: " + agree_text(item.issue_votes[i].points);// + " - " + humane_date(item.issue_votes[i].updated_at);
			user_agree_id = i;
		}
	}
	
	if (user_agree_id == -1){
		title = "You haven't voted yet";
		you_voted = "Details are hidden until you vote to avoid group think";
	}
	else {
		you_voted = item.agree + ' agree / ' + item.disagree + ' disagree (binding)<br>';		
		you_voted = you_voted + item.agree_nonbind + ' agree / ' + item.disagree_nonbind + ' disagree (non-binding)<br>';		
	}
	
	var history = '';
	var action_header = '';
	var buttons = '';
	var points = 999;
	
	http://bettermeans.com/front/?page_id=318
	if (user_agree_id > -1){
		points = item.issue_votes[user_agree_id].points;
		
		for(i = 0; i < item.issue_votes.length; i++ ){
			if (item.issue_votes[i].vote_type != 1) continue;
			history = history + agree_text(item.issue_votes[i].points) + ' - ' + item.issue_votes[i].user.firstname + ' ' + item.issue_votes[i].user.lastname;
			if (item.issue_votes[i].isbinding == false){
				history = history + ' (non-binding)';
			}
			history = history + '<br>';
		}
	}
	

	if (!((item.status.name != 'New')&&(item.status.name != 'Estimate')&&(item.status.name != 'Open'))) {
		user_agree_id < 0 ? action_header = 'Vote' : action_header = 'Change your vote:';
		if (points != 1) {buttons = buttons + dash_button('agree',dataId,points == 1,{action:'agree',data:'&points=1'}) + '<br>';}
		if (points != 0) {buttons = buttons + dash_button('neutral',dataId,points == 0,{action:'agree',data:'&points=0'}) + '<br>';}
		if (points != -1) {buttons = buttons + dash_button('disagree',dataId,points == -1,{action:'agree',data:'&points=-1'}) + '<br>';}
		if (points != -9999) {buttons = buttons + dash_button('block',dataId,false,{action:'agree',data:'&points=-9999'}) + '<br>';}
	}
	
	return generate_flyover(dataId,'agree',title,you_voted,action_header,buttons,history);
}

function generate_accept_flyover(dataId){
	var item = D[dataId];
	
	var accept_total;
	item.accept_total == null ? accept_total = 0 : accept_total = item.accept_total;
	
	var you_voted = '';
	var user_accept_id = -1;
	var total_people_accepting = 0;
	var i = 0;
	
	for(i=0; i < item.issue_votes.length; i++){
		if (currentUserLogin == item.issue_votes[i].user.login){
			if (item.issue_votes[i].vote_type != 2) continue;
			total_people_accepting++ ;
			title = "You voted: " + accept_text(item.issue_votes[i].points);// + " - " + humane_date(item.issue_votes[i].updated_at);
			user_accept_id = i;
		}
	}
	
	if (user_accept_id == -1){
		title = "You haven't voted yet";
		you_voted = "Totals are hidden until you vote";
	}
	else {
		you_voted = item.accept + ' accept / ' + item.reject + ' reject (binding)<br>';		
		you_voted = you_voted + item.accept_nonbind + ' accept / ' + item.reject_nonbind + ' reject (non-binding)<br>';		
	}
	
	var history = '';
	var action_header = '';
	var buttons = '';
	var points = 999;
	
	
	if (user_accept_id > -1){
		points = item.issue_votes[user_accept_id].points;
		
		for(i = 0; i < item.issue_votes.length; i++ ){
			if (item.issue_votes[i].vote_type != 2) continue;
			history = history + accept_text(item.issue_votes[i].points) + ' - ' + item.issue_votes[i].user.firstname + ' ' + item.issue_votes[i].user.lastname;
			if (item.issue_votes[i].isbinding == false){
				history = history + ' (non-binding)';
			}
			history = history + '<br>';
		}
	}

	if (item.status.name == 'Done') {
		user_accept_id < 0 ? action_header = 'Vote' : action_header = 'Change your vote:';
		if (points != 1) {buttons = buttons + dash_button('accept',dataId,points == 1,{action:'accept',data:'&points=1'}) + '<br>';}
		if (points != 0) {buttons = buttons + dash_button('neutral',dataId,points == 0,{action:'accept',data:'&points=0'}) + '<br>';}
		if (points != -1) {buttons = buttons + dash_button('reject',dataId,points == -1,{action:'accept',data:'&points=-1'}) + '<br>';}
		if (points != -9999) {buttons = buttons + dash_button('block',dataId,false,{action:'accept',data:'&points=-9999'}) + '<br>';}
	}
		
	return generate_flyover(dataId,'accept',title,you_voted,action_header,buttons,history);
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
	html = html + '<span class="specialhighlight">' + h(item.description).replace(/\n/g,"<br>") + '</span>';
 	html = html + '</td>';
  	html = html + '</tr>';
	html = html + '	    </tbody>';
	html = html + '	  </table>';
	html = html + '	<div class="clear"></div>';
	return html;
	
}

function generate_comments_section(dataId){
	var html = '	          <div class="section" id="comments_container_' + dataId + '">';
	html = html + '	            <table class="storyDescriptionTable">';
	html = html + '	              <tbody>';
	html = html + '	                <tr>';
	html = html + generate_comments(dataId,false);
	html = html + '	                </tr>';
	html = html + '	                <tr>';
	html = html + '	                  <td colspan="5">';
	html = html + '	                    <div>';
	html = html + '	                      <textarea class = "textAreaFocus" id="new_comment_' + dataId + '" rows="1" cols="20" name="story[comment]"></textarea>     ';
	html = html + '	                    <div>';
	html = html + '	                    <input value="Post Comment" type="submit" id="post_comment_button_' + dataId + '" onclick="post_comment(' + dataId + '); return false;">';
	html = html + '	                        (Format using *<b>bold</b>* and _<i>italic</i>_ text.)';
	html = html + '	                      </div>';
	html = html + '	                    </div>';
	html = html + '	                  </td>';
	html = html + '	                </tr>';
	html = html + '	              </tbody>';
	html = html + '	            </table>';
	html = html + '	          </div>';
	return html;
}

//blank_if_no_comments: when true, nothing is returned if there aren't any comments, when false the header is returned
function generate_comments(dataId,blank_if_no_comments){
	var item = D[dataId];
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
						if (note_array[j][0]!='>'){note = note + note_array[j].replace(/\n/g,"<br>") + '\n';};
					}
				}
				else
				{
					note = item.journals[i].notes;
				}
				var last_comment = (i == (item.journals.length - 1));
				html = html + generate_comment(author,note,item.journals[i].created_at,item.id, (last_comment &&(currentUserId == item.journals[i].user_id)), item.journals[i].id,dataId);
			}
	}
	html = html + '	    </tbody>';
	html = html + '	  </table>';
	html = html + '	<div class="clear"></div>';
	return html;
	
}

function generate_comment(author,note,created_at,itemId,last_comment,journalId,dataId){
	var html = '';
	html = html + '<tr class="noteInfoRow">';
	html = html + '<td class="noteInfo" id="noteInfo_' + journalId + '">';
	html = html + '<span class="specialhighlight">' + author + '</span> <span class="italic">' + humane_date(created_at) + '</span>';
	if (last_comment){
		html = html + '&nbsp;&nbsp;<a href="" onclick="edit_comment(' + journalId + ',' + dataId + ');return false;">edit</a>';
	}
	html = html + '</td>';
	html = html + '</tr>';
    html = html + '<tr class="noteTextRow">';
	html = html + '<td class="noteText" id="noteText_' + journalId + '">';
	html = html + '	<span id="comment_' + journalId + '_text_container">' + h(note).replace(/\r\n/g,"<br>").replace(/\n/g,"<br>") + '</span>';
	html = html + '	<span id="comment_' + journalId + '_subject_submit_container"></span>';
	html = html + '</td>';
	html = html + '</tr>';
	return html;
	
}

//blank_if_no_todos: when true, nothing is returned if there aren't any todos, when false the header is returned
function generate_todos(dataId,blank_if_no_todos, item_editable){
	var item = D[dataId];
	
	
	var count = item.todos.length;
	
	if (count==0 && blank_if_no_todos){return '';};
	
	var html = '';
	html = html + '<div  id="todo_container_' + item.id + '">';
	html = html + '	  <div class="header">';
	html = html + '	    Todos <span id="task_' + dataId  + '_count" class="todoCount">(' + count + ')</span>';
	html = html + '	  </div>';
	html = html + '	  <table class="tasksTable" id="notesTable_todos_' + item.id + '">';
	// html = html + '	    <tbody>';
	
	var sorted = item.todos.sort(function(a, b) {
	   return (a.id < b.id) ? -1 : (a.id > b.id) ? 1 : 0;
	});
	
	for(var i = 0; i < sorted.length; i++ ){
		html = html + generate_todo(sorted[i].subject,sorted[i].completed_on, sorted[i].id,sorted[i].owner_login,dataId, item_editable);
	}
	// html = html + '	    </tbody>';
	html = html + '	  </table>';
	html = html + '	<div class="clear"></div>';
	html = html + '	  </div>';
	return html;
	
}

function generate_todo(subject,completed_on,todoId,owner_login,dataId, item_editable){
	var completed = '';
	var checked = '';
	var disabled = '';
	if (completed_on != null){
		completed = 'completed';
		checked = ' checked="true" ';
		}
	if (!item_editable){
		disabled = ' disabled="true" ';
	}
		
	var html = '';
	html = html + '<tr class="task_row" id="task_' + todoId  + '"  onmouseover="update_todo_buttons(' + todoId + ',true)"  onmouseout="update_todo_buttons(' + todoId + ',false)">';
	html = html + '	<td>';
	html = html + '	<input type="checkbox" value="" id="task_' + todoId  + '_complete" onclick="update_todo(' + todoId + ',' + dataId + ')" ' + checked + disabled + '/>';
	html = html + '	</td>';
	html = html + '<td  id="task_' + todoId  + '_subject" class="taskDescription ' + completed + '">';
	html = html + '	<span id="task_' + todoId + '_subject_text">';
	html = html + h(subject);
	if ((owner_login != '') && (owner_login!= null)){
		html = html + ' (' + owner_login + ')';
	}
	html = html + '	</span>';
	html = html + '	<input id="task_' + todoId + '_subject_input" style="display:none;" value="' + h(subject) + '" onblur="edit_todo_post('+ todoId +',' + dataId + ')">';
	html = html + '	<span id="task_' + todoId + '_subject_submit_container"></span>';
	html = html + '</td>';
	
	if (item_editable){
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
	}
	
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
	return false;
}
}

function edit_comment(journalId,dataId){
try{
		var button = ' <input id="comment_' + journalId + '_subject_submit" type="submit" onclick="edit_comment_post(' + journalId + ',' + dataId + ');return false;" value="done" class="right"/>';
		var cancel_button = ' <input id="comment_' + journalId + '_subject_submit" type="submit" onclick="edit_comment_cancel(' + journalId + ',' + dataId + ');return false;" value="cancel" class="right"/>';
		var input = '<textarea id="comment_' + journalId + '_subject_input" cols="20" rows="5"/>';
		$('#comment_' + journalId + '_text_container').hide();
		$('#comment_' + journalId + '_subject_submit_container').html(input + button + cancel_button);
		$('#comment_' + journalId + '_subject_input').show().focus();
		$('#comment_' + journalId + '_subject_input').html($('#comment_' + journalId + '_text_container').html().replace(/<br>/g, "\n"));		
		keyboard_shortcuts = false;
		
		return false;
	}
catch(err){
	return false;
}
}

function edit_comment_cancel(journalId,dataId){
	keyboard_shortcuts = true;
	$('#comment_' + journalId + '_text_container').show();
	$('#comment_' + journalId + '_subject_submit_container').html('');
}

function edit_comment_post(journalId,dataId){
try{
	keyboard_shortcuts = true;
	var new_text = $('#comment_' + journalId + '_subject_input').val(); //.replace(/<br>/g, "\n");
	
	$('#comment_' + journalId + '_text_container').html(h(new_text).replace(/\r\n/g,"<br>").replace(/\n/g,"<br>")).show();
	$('#comment_' + journalId + '_subject_submit_container').html('');
	
	var data = "commit=Update&id=" + journalId + "&issue_id=" + D[dataId].id + "&journal[notes]=" + encodeURIComponent(new_text);
	
	var url = url_for({ controller: 'journals',
	                           action    : 'edit_from_dashboard'
	                          });
	
	$.ajax({
	   type: "POST",
	   dataType: "json",
	   url: url,
	   data: data,
	   success: 	function(html){
			comment_added(html,dataId);
		},
	   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
		handle_error(XMLHttpRequest, textStatus, errorThrown, dataId, "post");
		},
		timeout: 30000 //30 seconds
	 });

	return false;
	}
catch(err){
	return false;
}
}


function edit_todo_post(todoId, dataId){
try{
	
	keyboard_shortcuts = true;
	
	
	$('#task_' + todoId + '_subject_text').html(h($('#task_' + todoId + '_subject_input').val())).show();
	$('#task_' + todoId + '_subject_input').hide();
	$('#task_' + todoId + '_subject_submit_container').html('');
	
	var item = D[dataId];	
	var data = "commit=Update&id=" + todoId + "&issue_id=" + item.id + "&todo[subject]=" + encodeURIComponent($('#task_' + todoId + '_subject_input').val());
	
	if ($('#task_' + todoId + '_complete').attr("checked") == true){
		$('#task_' + todoId  + '_subject').addClass('completed');
		data = data + '&todo[owner_login]=' + currentUserLogin;
		data = data + '&todo[owner_id]=' + currentUserId;
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

//Takes credits, and base, and turns them to points for display
function credits_to_points(credits,base){
	normalized = Math.round(credits/base);
	if (normalized > credits_to_points_array.length - 1 ){
		return credits_to_points_array[credits_to_points_array.length - 1];
	}
	return credits_to_points_array[normalized]; //TODO: fix this formula credits larger than 12
}

function has_current_user_estimated(item){
	
	//Checking wether or not current user estimated this item voted
	for(i=0; i < item.issue_votes.length; i++){
		if (item.issue_votes[i].vote_type != 4) continue;
		
		if (currentUserLogin == item.issue_votes[i].user.login){
			return true;
		}
	}
	return false;
}

function generate_item_estimate_button(dataId,points){
	var item = D[dataId];
	var html = '';
	var onclick = "";
	
	if (is_item_estimatable(item)){
		onclick = "show_estimate_flyover("+ dataId +",this.id);return false;";
	}
	else{
		onclick = "show_points_flyover("+ dataId +",this.id);return false;";
	}
	
	var current_user_voted = has_current_user_estimated(item);
	
	if (((item.status.name != 'New')&&(item.status.name != 'Estimate')&&(item.status.name != 'Open')) || (current_user_voted) || (!is_item_estimatable(item))){
		
		//If no binding points, then current user is non-binding and has voted so we show them a different symbol so they can track what they estimated, and what they didn't estimate
		if (points == "No" && current_user_voted){
			points = "wait";
		}
		html = html + '<img id="diceicon_' + dataId + '"  class="storyPoints hoverDiceIcon clickable" src="/images/dice_' + points + '.png" alt="' + points + ' credits" onclick=' + onclick + '>';		
	}
	else{
		html = html + '<img id="diceicon_' + dataId + '"  class="storyPoints hoverDiceIcon clickable" src="/images/dice_No.png" alt="Credits hidden until you estimate" onclick=' + onclick + '>';		
	}
	
	return html;
	
}

function add_new_link(){
	$("#new_list").prepend(generate_new_link());
}

function remove_new_link(){
	$("#item_new_link").remove();
}


function generate_new_link(){
	var html = '';
	
	html = html + '<div id="item_new_link" class="item">';
	html = html + '<div id="item_content_new_link" class="newlink hoverable" style="">';
	html = html + '<div class="itemCollapsedHeader">';

	html = html + '<div id="item_content_details_new_link" class="itemCollapsedTextNewLink" onDblclick="new_item();return false;" style="cursor: default;">'; 
	
	html = html + '<a href="#" onclick="new_item();return false;">Add New Item</a>';
	html = html + '</div>';
	html = html + '</div>';
	html = html + '</div>';
	html = html + '</div>';
	return html;
}


//Generates html for collapsed item
function generate_item(dataId){
	var item = D[dataId];
	var html = '';
	var points;
	item.points == null ? points = 'No' : points = credits_to_points(item.points,credit_base);
	
	html = html + '<div id="item_' + dataId + '" class="item points_' + points + ' pri_' + item.pri + '">';
	html = html + '<div id="item_content_' + dataId + '" class="' + item.status.name.replace(" ","-").toLowerCase() + ' hoverable" style="">';
	html = html + '<div class="itemCollapsedHeader">';
	html = html + '<div id="item_content_buttons_' + dataId + '" class="itemCollapsedButtons">';
	if (currentUserId != ANONYMOUS_USER_ID){ 
		html = html + buttons_for(dataId);
	}
	
	html = html + '</div>';

	html = html + '<div id="icons_' + dataId + '" class="icons">'; //The id of this div is used to lookup the item to generate the flyover
	html = html + '<img id="item_content_icons_editButton_' + dataId + '" class="toggleExpandedButton" src="/images/story_collapsed.png" title="Expand" alt="Expand" onclick="expand_item(' + dataId + ');return false;">';
	html = html + '<div id="icon_set_' + dataId + '" class="left">';
	if (is_cancelable(dataId)){
		html = html + dash_button('cancel',dataId,false,{label:'&nbsp;'});
	}
	
	// html = html + '<img id="featureicon_' + dataId + '" itemid="' + item.id + '" class="storyTypeIcon hoverDetailsIcon clickable" src="/images/' + item.tracker.name.toLowerCase() + '_icon.png" alt="' + item.tracker.name + '"  onclick=" show_item_fancybox('+ dataId +');return false;">'; 
	
	if (currentUserId != ANONYMOUS_USER_ID){ 
		html = html + generate_item_estimate_button(dataId,points);
	}
	
	// if (show_comment(item)){
	// html = html + '<img id="flyovericon_' + dataId + '"  class="flyoverIcon hoverCommentsIcon clickable" src="/images/story_flyover_icon.png" onclick="show_details_flyover('+ dataId +',this.id);return false;">'; 
	// }
	
	html = html + '</div>';
    
	html = html + '</div>';


	html = html + '<div id="item_content_details_' + dataId + '" class="itemCollapsedText" onDblclick="expand_item(' + dataId + ');return false;" style="cursor: default;">'; 
	html = html + '<span>'
	html = html + '<a href="#" class="dash-item-title" onclick="show_item_fancybox(' + dataId + ');return false;">' + h(item.subject) + '</a>';
	html = html + generate_tags(item.tags_copy);
	html = html + '</span><div class="clear"></div>';
	html = html + '</div>';
	html = html + '</div>';
	html = html + '</div>';
	html = html + '</div>';
	return html;
}

function generate_tags(tag_list){
	if (!tag_list){return '';}
	html = '';
	html = html + '<div class="tagsoutput tagsdash">';
	
	var tag_array = tag_list.split(',');
	for(var j = 0; j < tag_array.length; j++ ){
		html = html + '<span class="tag">';
		html = html + tag_array[j];
		html = html + '</span>';
	}
	
	// $.each(, function() {
	//     $('#' + name + '_start_of_list').append(this);
	//     });
	
	html = html + '</div>';
	return html;

	// issue.tag_list.each {|t| html = html + content_tag('span', t, :class => "tag")}
	//     content_tag('div', html, :class => "tagsoutput")
    
}

//Generates html for item header in lightbox
function generate_item_lightbox(dataId){
	var item = D[dataId];
	var html = '';
	var points;
	item.points == null ? points = 'No' : points = credits_to_points(item.points,credit_base);
	
	html = html + '<div id="item_lightbox_' + dataId + '" class="item_lightbox points_' + points + ' pri_' + item.pri + '">';
	html = html + '<div id="item_content_' + dataId + '" class="' + item.status.name.replace(" ","-").toLowerCase() + ' hoverable" style="">';
	html = html + '<div id="item_content_buttons_' + dataId + '" class="itemCollapsedButtons">';
	html = html + buttons_for(dataId);
	html = html + '</div>';

	html = html + '<div id="icons_' + dataId + '" class="icons">'; //The id of this div is used to lookup the item to generate the flyover
	html = html + '<h3 style="border:none;padding-left:11px">'; 

	html = html + generate_item_estimate_button(dataId,points);

	html = html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + h(item.subject);
	html = html + '&nbsp;<span id="icon_set_' + dataId + '">&nbsp;';
	html = html + '</span>';
	html = html + '</h3>';
	
	
    
	html = html + '</div>';

	// html = html + '<div class="left">';
	// html = html + '</div>';

	
	html = html + '</div>';
	html = html + '</div>';
	return html;
}

function update_lightbox_lock_version(dataId){
	$("#issue_lock_version").attr('value', D[dataId].lock_version);
}

function generate_retro(rdataId){
	var retro = R[rdataId];
	var html = '';
	html = html + '	<div id="retro_' + rdataId + '" class="item retrospective">';
	html = html + '	<div id="retro_' + rdataId + '_content" class="gt-Iih">';
	html = html + '	<table>';
	html = html + '	<tbody>';
	html = html + '	<tr>';
	html = html + '	<td style="white-space: nowrap; width: 1%; padding: 1px 0pt 1px 4px; color: rgb(255, 255, 255); background-color: rgb(69, 71, 72);">';
	html = html + '		<img id="done_itemList_' + retro.id + '_toggle_expanded_button" class="gt-IihToggleExpandedButton" src="/images/iteration_expander_closed.png" title="Expand" alt="Expand" style="height: 12px; width: 12px;" onclick="display_retro(' + rdataId + ');return false;"/>';
	html = html + '	</td>';
	html = html + '	<td style="white-space: nowrap; width: 1%; padding: 1px 0.5em 1px 0pt; color: white; background-color: rgb(69, 71, 72);">';
	html = html + '		<div id="done_itemList_' + rdataId + '_iteration_label" title="Retrospective ' + retro.id + '" style="width: 2em; text-align: right;">' + retro.id + '</div>';
	html = html + '	</td>';
	html = html + '	<td id="done_' + rdataId + '_date_label" style="white-space: nowrap; width: 99%; padding: 1px 0.5em; color: rgb(255, 255, 255);">';
	html = html + '	<span>';
	html = html + '	<a class="date_label" title="Retro: ' + dateFormat(retro.to_date,'dd mm yy') + ' (' + retro_status(retro) + ')" onclick="display_retro(' + rdataId + ');return false;">Retro: ' + dateFormat(retro.to_date,'dd mmm') + ' (' + retro_status(retro) + ')</a>';
	html = html + '	</span>';
	html = html + '	</td>';
	html = html + '	<td id="done_' + rdataId + '_details_points" style="white-space: nowrap; width: 1%; padding: 1px 0.5em; color: rgb(255, 255, 255);">';
	html = html + '		<span title="Credits completed: ' + retro.total_points + '">' + retro.total_points + ' credits</span>';
	html = html + '	</td>';
	html = html + '	</tr>';
	html = html + '	</tbody>';
	html = html + '	</table>';
	html = html + '	</div>';
	html = html + '	</div>';
	return html;	
}

// function retro_status(retro){
// 	if (retro.status_id == 1){
// 		return "open";
// 	}
// 	else{
// 		return "done";
// 	}
// }

function display_retro(rdataId){
	
	
	var retro = R[rdataId];
	
	$('#done_itemList_' + retro.id + '_toggle_expanded_button').attr('src','/images/iteration_expander_open.png');
	
	var url = 'retros/' + retro.id + '/dashdata';
	
	if ($('#include_subworkstreams_checkbox').attr("checked") == true){
		url = url + "&include_subworkstreams=true";
	}
	
	
	$.ajax({
	   type: "GET",
	   dataType: "json",
	   contentType: "application/json",
	   url: url,
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
	generate_and_append_panel(0,'retro_' + retro.id,'Retro ' + retro.id + ': ' + dateFormat(retro.from_date,'dd mmm yyyy') + ' to ' + dateFormat(retro.to_date,'dd mmm yyyy'),true);
	recalculate_widths();
	var html = '	<div class="item" id="new_retro_wrapper_' + rdataId + '"><div id="loading" class="loading"> Loading...</div></div>';
	$('#retro_' + retro.id + '_items').prepend(html);
	
	
}


function generate_notice(noticeHtml, noticeId){
	$('#notice_' + noticeId).remove();
	var html =  '';
	html = html + '	<div id="notice_' + noticeId + '" class="item panel_notice">';
	html = html + '	<div id="notice_' + noticeId + '_content" class="gt-Iih">';
	html = html + '	<table>';
	html = html + '	<tbody>';
	html = html + '	<tr>';
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

function is_cancelable(dataId){
	item = D[dataId];
	
	if (currentUserIsCore == 'true'){
		var today = new Date();
		var one_day=1000*60*60*24;
		var updated = new Date(item.updated_at).getTime();
		var days = (today.getTime() - updated)/one_day;
		if (days > 30){
			return true;
		}
	}
		
	if (currentUserId != item.author_id){
		return false;
	}
	else{
		for (var i = 0; i < item.issue_votes.length; i ++){
			if(item.issue_votes[i].user_id != currentUserId){
				return false;
			}
		}		
		for (var j = 0; j < item.journals.length; j ++){
			if((item.journals[j].user_id != currentUserId)&&(item.journals[j].user_id != adminUserId)){
				return false;
			}
		}		
	}
	return true;
}


function buttons_for(dataId,expanded){
	if (currentUserId == ANONYMOUS_USER_ID){ return "";}
	var item = D[dataId];
	var html = '';
    	
	switch (item.status.name){
	case 'New':
		html = html + pri_button(dataId);
		html = html + agree_buttons_root(dataId, true, expanded);
	break;
	case 'Estimate':
		html = html + pri_button(dataId);
		html = html + agree_buttons_root(dataId,true,expanded);
	break;
	case 'Open':
		html = html + pri_button(dataId);
		html = html + agree_buttons_root(dataId,true,expanded);
	break;
	case 'Committed':
		if (item.assigned_to_id == currentUserId){
			html = html + dash_button('finish',dataId);
			html = html + dash_button('release',dataId,false,{label:'giveup'});
		}
		else if (item.assigned_to != null){
			if (is_part_of_team(item)){
				html = html + dash_button('finish',dataId);
				html = html + dash_button('leave',dataId);
			}
			else if (is_item_joinable(item)){
				html = html + '<div id="committed_tally_' + dataId + '" class="action_button_tally">' + item.assigned_to.firstname + '</div>';
				html = html + dash_button('join',dataId);
			}
		}
	break;
	case 'Done':
		html = html + accept_buttons_root(dataId,expanded);
	break;
	case 'Accepted':
		html = html + '<div id="accepted_' + dataId + '" class="action_button action_button_accepted" onclick="click_accept_root(' + dataId + ',this,\'false\');return false;">Accepted</div>';

		if (item.retro_id && (item.retro_id > 0)){
			html = html + dash_button('retro',dataId,false,item.retro_id);
		}
	break;
	case 'Rejected':
		html = html + '<div id="rejected_' + dataId + '" class="action_button action_button_rejected" onclick="click_accept_root(' + dataId + ',this,\'false\');return false;">Rejected</div>';
		html = html + dash_button('start',dataId);
	break;
	case 'Archived':
		html = html + '<div id="accepted_' + dataId + '" class="action_button action_button_accepted" onclick="click_accept_root(' + dataId + ',this,\'false\');return false;">Accepted</div>';
		if (item.retro_id > 0){
			html = html + dash_button('retro',dataId,false,item.retro_id);
		}
	break;
	case 'Canceled':
		html = html + dash_button('restart',dataId);
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

function agree_buttons_root(dataId,include_start_button,expanded){
	var html = '';
	var item = D[dataId];
	
	var tally = 'agree?';
	var cssclass = 'root';
	var user_voted = 'false';
	var user_estimated = false;
	
	
	for(var i=0; i < item.issue_votes.length; i++){
		//bugbug: hardcoded issue vote (4)
		if ((currentUserLogin == item.issue_votes[i].user.login)&&(item.issue_votes[i].vote_type == 4)){
			user_estimated = true;
		}
		
		//bugbug: hardcoded issue vote (1)
		if ((currentUserLogin == item.issue_votes[i].user.login)&&(item.issue_votes[i].vote_type == 1)){
			user_voted = item.issue_votes[i].points;
			tally = '';

			if (item.disagree > 5000){
				include_start_button = false;
				tally = 'Blocked';
			}
			else{
				tally = (item.agree + item.agree_nonbind) + ' - ' + (item.disagree + item.disagree_nonbind);
			}
			switch(String(item.issue_votes[i].points))
			{
				case "1":	cssclass = 'agree';
							break;	
				case "0":	cssclass = 'neutral';
							break;	
				case "-1":	cssclass = 'disagree';
							break;	
				case "-9999": cssclass = 'block';
							break;	
			}
		}
	}
	
	if (include_start_button){
		html = html + dash_button('start',dataId,false); //add start button 
	}
	
	// if ((!user_estimated) && user_voted){
	// 	html = html + dash_button('estimate',dataId,false,{'label':'estimate?'}); //no room to show tally if estimate button is included
	// }
	var total_votes = item.agree + item.agree_nonbind - item.disagree - item.disagree_nonbind
	html = html + votes_button(dataId,total_votes, user_voted);
	
	return html;
}



// function agree_buttons_root(dataId,include_start_button,expanded){
// 	var html = '';
// 	var item = D[dataId];
// 	
// 	var tally = 'agree?';
// 	var cssclass = 'root';
// 	var user_voted = false;
// 	var user_estimated = false;
// 	
// 	
// 	for(var i=0; i < item.issue_votes.length; i++){
// 		//bugbug: hardcoded issue vote (4)
// 		if ((currentUserLogin == item.issue_votes[i].user.login)&&(item.issue_votes[i].vote_type == 4)){
// 			user_estimated = true;
// 		}
// 		
// 		//bugbug: hardcoded issue vote (1)
// 		if ((currentUserLogin == item.issue_votes[i].user.login)&&(item.issue_votes[i].vote_type == 1)){
// 			user_voted = true;
// 			tally = '';
// 
// 			if (item.disagree > 5000){
// 				include_start_button = false;
// 				tally = 'Blocked';
// 			}
// 			else{
// 				tally = (item.agree + item.agree_nonbind) + ' - ' + (item.disagree + item.disagree_nonbind);
// 			}
// 			switch(String(item.issue_votes[i].points))
// 			{
// 				case "1":	cssclass = 'agree';
// 							break;	
// 				case "0":	cssclass = 'neutral';
// 							break;	
// 				case "-1":	cssclass = 'disagree';
// 							break;	
// 				case "-9999": cssclass = 'block';
// 							break;	
// 			}
// 		}
// 	}
// 	
// 	if (include_start_button && user_estimated && user_voted){
// 		html = html + dash_button('start',dataId,false); //add start button if user estimated and voted
// 	}
// 	
// 	if ((!user_estimated) && user_voted){
// 		html = html + dash_button('estimate',dataId,false,{'label':'estimate?'}); //no room to show tally if estimate button is included
// 	}
// 	
// 	html = html + dash_button('agree_root',dataId,false,{label:tally,cssclass:cssclass});
// 	
// 	return html;
// }

function accept_buttons_root(dataId,include_start_button,expanded){
	
	var html = '';
	var item = D[dataId];
	
	var tally = 'accept?';
	
	if (item.reject > 5000){
		tally = 'Blocked';
	}
	else{
		tally = (item.accept + item.accept_nonbind) + ' - ' + (item.reject + item.reject_nonbind);
	}
	
	var cssclass = 'root';
	var user_voted = false;
	
	
	for(var i=0; i < item.issue_votes.length; i++){
		if ((currentUserLogin == item.issue_votes[i].user.login)&&(item.issue_votes[i].vote_type == 2)){
			user_voted = true;
			switch(String(item.issue_votes[i].points))
			{
				case "1":	cssclass = 'accept';
							break;	
				case "0":	cssclass = 'neutral';
							break;	
				case "-1":	cssclass = 'reject';
							break;	
				case "-9999": cssclass = 'block';
							break;	
			}
			
			break;
		}
	}	
	
	if (!user_voted){
		tally = "accept?";
	}
	
	html = dash_button('accept_root',dataId,false,{label:tally,cssclass:cssclass});
	
	if (item.assigned_to_id == currentUserId){
		html = html + dash_button('start',dataId,false,{label:'takeback', cssclass:'takeback'});
	}
	
	
	return html;
}


function pri_button(dataId){
	var item = D[dataId];
	for(var i=0; i < item.issue_votes.length; i++){
		if ((currentUserLogin == item.issue_votes[i].user.login)&&(item.issue_votes[i].vote_type == 3)){
			if (item.issue_votes[i].points == 1){
				return generate_pri_button(dataId,'up',(item.pri + item.pri_nonbind));
			}
			else if (item.issue_votes[i].points == -1){
				return generate_pri_button(dataId,'down',(item.pri + item.pri_nonbind));
			}
			else if (item.issue_votes[i].points == 0){
				return generate_pri_button(dataId,'neutral',(item.pri + item.pri_nonbind));
			}
		}
	}
	return generate_pri_button(dataId,'none',(item.pri + item.pri_nonbind));
}

function generate_pri_button(dataId,direction,pri){
	// var html = '<div id="pri_container_' + D[dataId].id + '" class="pri_container">';
	var ondblclick =  'hide_bubbletips();click_pri(' + dataId + ',this,1);hide_bubbletips();return false;';
	var html = '<div id="item_content_buttons_pri_button_' + dataId + '" class="clickable pri_button pri_button_' + direction + '" onclick="show_pri_flyover(' + dataId + ',this.id);return false;" onDblclick = ' + ondblclick + '>' + pri + '</div>';	
	// html = html + '</div>';
	return html;
}

function votes_button(dataId,votes_total,user_voted){
	var type = 'agree_root';
	var label = votes_total + ' vote';
	if (votes_total != 1){ label = label + 's'}else{ label = label + ' '};
	if (votes_total < -9000){ label = 'blocked'};
	var cssclass = '';
	var onclick = 'click_agree_root(' + dataId + ',this,\'\');return false;';

	if (user_voted == 'false'){
			var	onarrowclick =  'click_agree(' + dataId + ',this,\'&points=1\')";return false;';
	}
	else{
			var onarrowclick = 'click_agree_root(' + dataId + ',this,\'\');return false;';
	}


	html = '';
	html = html + '<div id="item_content_buttons_' + type + '_button_' + dataId + '" class="action_button action_button_votes" total_votes="' + votes_total + '">';
	html = html + '<a id="item_action_link_vote' + dataId + '" onclick="' + onarrowclick + '" class="vote_arrow"><img src="/images/upvote_' + user_voted + '.png"/></a>';
	
	html = html + '<a id="item_action_link_' + type + dataId + '" class="action_link_votes clickable" onclick="' + onclick + '">';
	html = html + label + '</a>';
	html = html + '</div>';
	return html;
}



//Generates a button type for item id
function dash_button(type,dataId,hide,options_param){
	  var options = options_param || {};
	  var label = typeof(options['label']) == 'undefined' ? 
	                                  type : 
	                                  options['label'];
	  var cssclass = typeof(options['cssclass']) == 'undefined' ? 
	                                  type : 
	                                  options['cssclass'];
	  var action = typeof(options['action']) == 'undefined' ? 
	                                  type : 
	                                  options['action'];
	  var data = typeof(options['data']) == 'undefined' ? 
	                                  '' : 
	                                  options['data'];
	var hide_style = '';
	var onclick = 'click_' + action + '(' + dataId + ',this,\'' + data + '\');return false;';
	var ondblclick = '';
	
	if (type == "agree_root"){
		ondblclick =  'click_agree(' + dataId + ',this,\'&points=1\')";return false;';
	}

	if (type == "accept_root"){
		ondblclick =  'click_accept(' + dataId + ',this,\'&points=1\')";return false;';
	}
	
	
	if (hide){ hide_style = "style=display:none;"; }
	html = '';
	html = html + '<div id="item_content_buttons_' + type + '_button_' + dataId + '" onclick="' + onclick + '" class="action_button action_button_' + cssclass + '" ' + hide_style + '>';
	html = html + '<a id="item_action_link_' + type + dataId + '" class="action_link clickable" onDblclick="' + ondblclick + '"  onclick="return false;">';
	html = html + label + '</a></div>';
	return html;
}

function click_start(dataId,source,data){
	//Login required	
	if (!is_user_logged_in()){return false;}

	if (($(".action_button_finish").get().length - 1) >= MAX_REQUESTS_PER_PERSON){
		$.jGrowl("Sorry, you're only allowed to own " + MAX_REQUESTS_PER_PERSON + " items at a time");
		return false;
	}

	if (credits_enabled && !has_current_user_estimated(D[dataId])){
		$.jGrowl("Sorry, you can't start an item before estimating it first. <br><br>Click on the dice with the question mark on it, to estimate the complexity/size of this item.");
		return false;
	}
	
	
	$('#' + source.id).parent().hide();
	send_item_action(dataId,'start');
	return false;
}

function click_reject(dataId,source,data){
	//Login required	
	if (!is_user_logged_in()){return;}

	$('#' + source.id).parent().hide();
	comment_prompt(dataId,source,data,'reject',true,"Please explain your rejection");
}


//This is the estimate button clicked from the dashboard
function click_estimate(dataId,source,data,comment){
	show_estimate_flyover(dataId,source.id);
}

//This is the actual die clicked from the estimate flyover
function click_estimate_from_flyover(dataId,source,data,comment){
	//Login required	
	if (!is_user_logged_in()){return;}

	// $('#' + source.id).parent().hide();
	if (comment == true){
		comment_prompt(dataId,source,data,'estimate',false,"Please explain why you're changing your estimate (optional)");
	}
	else{
		send_item_action(dataId,'estimate',data);
	}

}


function click_finish(dataId,source,data){
	//Login required	
	if (!is_user_logged_in()){return;}

	$('#' + source.id).parent().hide();
	comment_prompt(dataId,source,data,'finish',false,"Tell your team what was accomplished. Include links to help them see the work, and accept it.");
}

function click_restart(dataId,source,data){
	//Login required	
	if (!is_user_logged_in()){return;}

	$('#' + source.id).parent().hide();
	send_item_action(dataId,'restart');
}

// function click_estimate(dataId,source,data){
// 	$('#' + source.id).parent().hide();
// }

function click_agree(dataId,source,data){
	//Login required	
	if (!is_user_logged_in()){return;}

	// $('#item_content_buttons_' + dataId).hide();
	
	var item = D[dataId];
	var user_voted = 0;
	for(var i=0; i < item.issue_votes.length; i++){
		if ((currentUserLogin == item.issue_votes[i].user.login)&&(item.issue_votes[i].vote_type == 1)){
			user_voted = item.issue_votes[i].points;
		}
	}
	
	var user_new_voted = parseInt(data.split('=')[1])
	var votes_total = item.agree + item.agree_nonbind - item.disagree - item.disagree_nonbind - user_voted + user_new_voted
	$('#item_content_buttons_agree_root_button_' + dataId).html(votes_button(dataId, votes_total, user_new_voted));
	
	
	switch(data)
	{
		case "&points=1":	send_item_action(dataId,'agree',data);
					break;	
		case "&points=0":	send_item_action(dataId,'agree',data);
					break;	
		case "&points=-1":	comment_prompt(dataId,source,data,'agree',false, "Please explain why you disagree (optional)");
					break;	
		case "&points=-9999":	comment_prompt(dataId,source,data,'agree',true, "Please explain why you're blocking");
					break;	
	}
}

function click_agree_root(dataId,source,data){
	show_agree_flyover(dataId,source.id);
	return false;
}

function click_accept_root(dataId,source,data){
	show_accept_flyover(dataId,source.id);
	return false;
}

function click_accept(dataId,source,data){
	//Login required	
	if (!is_user_logged_in()){return;}

	$('#' + source.id).parent().hide();
	switch(data)
	{
		case "&points=1":	send_item_action(dataId,'accept',data);
					break;	
		case "&points=0":	send_item_action(dataId,'accept',data);
					break;	
		case "&points=-1":	comment_prompt(dataId,source,data,'accept',false,"Please explain your rejection (optional)");
					break;	
		case "&points=-9999":	comment_prompt(dataId,source,data,'accept',true,"Please explaing your blocking");
					break;	
	}
}

function click_release(dataId,source,data){
	//Login required	
	if (!is_user_logged_in()){return;}

	$('#' + source.id).parent().hide();
	send_item_action(dataId,'release');
}

function click_cancel(dataId,source,data){
	//Login required	
	if (!is_user_logged_in()){return;}

	$('#' + source.id).parent().hide();
	comment_prompt(dataId,source,data,'cancel',false,"Please explain why you're canceling");
}

function click_leave(dataId,source,data){
	//Login required	
	if (!is_user_logged_in()){return;}

	$('#' + source.id).parent().hide();
	send_item_action(dataId,'leave');
}

function click_join(dataId,source,data){
	//Login required	
	if (!is_user_logged_in()){return;}
	
	if(confirm("By joining an item, you are declaring that you want to help get it done.\n\n Are you sure you want to do this?")){
		$('#' + source.id).parent().hide();
		send_item_action(dataId,'join');
	}
}

function click_pri(dataId,source,points){
	//Login required	
	if (!is_user_logged_in()){return;}
	$(".bubbletip").hide();
	$('#pri_container_' + D[dataId].id).hide();
	send_item_action(dataId,'prioritize','&points=' + points);
}

function click_retro(dataId,source,data){
	//Login required	
	if (!is_user_logged_in()){return false;}
	
	var url = '/projects/' + projectId + '/retros/' + D[dataId].retro_id + '/show';
	
	show_fancybox(url,'generating retrospective data...');
	return false;
}

function submit_comment_prompt(dataId,data,action){
	var text = $("#prompt_comment_" + dataId).val();
	if ((text == null) || (text.length < 2)){
		alert('Comment is too short!');
	}
	else{
		// post_comment(dataId,true,action);
		data = data + '&notes=' + encodeURIComponent(text);
		send_item_action(dataId,action,data);
		$.fancybox.close();
	}
	return false;
}

function cancel_comment_prompt(dataId,source,data,action){
	$('#item_content_buttons_' + dataId).show();
	$('#' + source.id).parent().show(); 
	$.fancybox.close();
	return false;
}


function comment_prompt(dataId,source,data,action,required,message){
	
	var title = required ? 'required' : 'optional';

	var content = '';
	content = content + '<div id="comment_prompt"><h2>Comment</h2><br>';
	if (message){
		content = content + message + '<br><br>';
	}
        content = content + '<p><textarea id="prompt_comment_' + dataId + '" class="comment_prompt_text" rows="10" ></textarea></p><br>';
		content = content + '<p>';
        content = content + '<input type="submit" onclick="submit_comment_prompt(' + dataId + ',\'' + data + '\',\'' + action + '\')" value="Submit"></input>';
		if (!required){
        	content = content + '<input type="submit" onclick="send_item_action(' + dataId + ',\'' + action + '\',\'' + data + '\'); $.fancybox.close();return false;" value="No Comment"></input>';
		}
        content = content + '<input type="submit" onclick="cancel_comment_prompt(' + dataId + ',\'' + source + '\',\'' + data + '\',\'' + action + '\')" value="Cancel"></input>';
		content = content + '</p><br><br></div>';

	$.fancybox(
		{
				'content'			: content,
				'width'				: 'auto',
				'height'			: 'auto',
				'title'				: title,
						        'autoScale'     	: false,
						        'transitionIn'		: 'none',
				'transitionOut'		: 'none',
				'scrolling'			: 'no',
				'showCloseButton' : false,
				'modal' : true,
				'href'	: '#comment_prompt'
		});	
	
	$('#new_comment_' + dataId).focus();
	$( "#prompt_comment_" + dataId ).mentions(projectId); 
}



function filter_select(){
	var selection = $("#filter_select").val();
	$('#fast_search').val(''); //clearing fast search
	
	switch(selection)
	{
		case "1":	hide_inactive(1);
					break;	
		case "2":	hide_inactive(2);
					break;	
		case "3":	hide_inactive(3);
					break;	
		case "7":	hide_inactive(7);
					break;	
		case "14":	hide_inactive(14);
					break;	
		case "21":	hide_inactive(21);
					break;	
		case "30":	hide_inactive(30);
					break;	
		case "60":	hide_inactive(60);
					break;	
		case "90":	hide_inactive(90);
					break;	
		case "120":	hide_inactive(120);
					break;	
		case "150":	hide_inactive(150);
					break;	
		case "all":	hide_inactive(99999);
					break;						
		case "all_top":	hide_inactive(99999);
					break;						
		case "unagreed":	show_unvoted({'New':1,'Open':1,'Estimate':1}, 1);
					break;						
		case "unaccepted":	show_unvoted({'Done':1},2);
					break;						
		case "unprioritized":	show_unvoted({'New':1,'Open':1,'Estimate':1},3);
					break;						
		case "unestimated":	show_unvoted({'New':1,'Open':1,'Estimate':1},4);
					break;						
		case "prioritized":	show_voted({'New':1,'Open':1,'Estimate':1,'Done':1},3,1);
					break;						
		case "added_by_me":	show_added_by_me();
					break;						
		case "touched_by_me": show_hide_touched(true);
					break;						
		case "untouched_by_me":	show_hide_touched(false);
					break;						
		default: show_tag(selection);
			break;					
	}	
	
	if (selection != "all" && selection != "all_top"){
		$('#filtered_message').show();
		$('#filter_detail').html($("#filter_select :selected").text());
	}
	else
	{
		$('#filtered_message').hide();
	}
	update_panel_counts();
}

//Shows all items added by current user
function show_added_by_me(){
	
	for(var i = 0; i < D.length; i++ ){
		if (D[i].author_id == currentUserId){
			$("#item_" + i).show();
		}
		else{
			$("#item_" + i).hide();
		}
	}	
}

//Shows (or hides) all items touched by current user, if show is true it shows them, else it hides them
function show_hide_touched(show){
	for(var i = 0; i < D.length; i++ ){
		if (is_item_touched_by_user(D[i])){
			show ? $("#item_" + i).show() : $("#item_" + i).hide();
		}
		else{
			show ? $("#item_" + i).hide() : $("#item_" + i).show();
		}
	}	
}

//Hides all items except those with the tag
function show_tag(tag){
	
	for(var i = 0; i < D.length; i++ ){
		if (D[i].tags_copy == null){
			$("#item_" + i).hide();
		}
		else if (D[i].tags_copy.indexOf(tag) != -1){
			$("#item_" + i).show();
		}
		else{
			$("#item_" + i).hide();
		}
	}	
}


//Hides all items not active in the last *days*
function hide_inactive(days){
	var today = new Date();
	
	for(var i = 0; i < D.length; i++ ){
		if (new Date(D[i].updated_at) < new Date().setDate(today.getDate()-days)){
			$("#item_" + i).hide();
		}
		else{
			$("#item_" + i).show();
		}
	}	
}

//Shows only items that don't have vote_type by current user for statuses defined in statuses option array
function show_unvoted(statuses,vote_type){
	for(var i = 0; i < D.length; i++ ){
		if (statuses[D[i].status.name] == undefined){ 
			$("#item_" + i).hide();
		}
		else if (has_vote_type(D[i],vote_type)){
			$("#item_" + i).hide();
		}
		else{
			$("#item_" + i).show();
		}
	}	
}

//Shows only items that have vote_type by current user for statuses defined in statuses option array
function show_voted(statuses,vote_type,vote_value){
	for(var i = 0; i < D.length; i++ ){
		if (statuses[D[i].status.name] == undefined){ 
			$("#item_" + i).hide();
		}
		else if (has_vote_type(D[i],vote_type,vote_value)){
			$("#item_" + i).show();
		}
		else{
			$("#item_" + i).hide();
		}
	}	
}

//If vote_value is defined, function checks that item has been voted on by curent user with vote_value, otherwise, it just checks that it was voted on by current user
function has_vote_type(item,vote_type,vote_value){
	for(var i = 0; i < item.issue_votes.length ; i++ ){
		if (item.issue_votes[i].user_id != currentUserId){continue;}
		
		if (vote_value == undefined){
			if (item.issue_votes[i].vote_type == vote_type){return true;}			
		}
		else{
			if (item.issue_votes[i].vote_type == vote_type && item.issue_votes[i].points == vote_value){return true;}			
		}
	}
	return false;
}

//returns true if user has voted in any way on item
function is_item_touched_by_user(item){
	if (item.author_id == currentUserId){
		return true;
	}
	
	for(var i = 0; i < item.issue_votes.length ; i++ ){
		if (item.issue_votes[i].user_id == currentUserId){return true;}			
	}

	for(var j = 0; j < item.journals.length ; j++ ){
		if (item.journals[j].user_id == currentUserId){return true;}			
	}
	
	return false;
}

function search_for(text){
	text = text.toLowerCase();
	if (text.length > 1){
		for(var i = 0; i < D.length; i++ )
		{
			if ((text.length == 0) || (D[i].subject.toLowerCase().indexOf(text) > -1))
			{
				$("#item_" + i).show().removeHighlight();
				if (text.length > 0){
					$("#item_content_details_" + i).texthighlight(text);
				}
			}
			else if (D[i].description.toLowerCase().indexOf(text) > -1)
			{
				$("#item_" + i).show().removeHighlight();
			}
			else if (D[i].tags_copy != null && D[i].tags_copy.toLowerCase().indexOf(text) > -1)
			{
				$("#item_" + i).show().removeHighlight();
			}
			else 
			{
				$("#item_" + i).hide().removeHighlight();
			}			
			if (String(D[i].id) == text){
				$("#item_" + i).show();
			}
		}
	}
	
	if ((text.length == 1)&&($('#filtered_message').is(":visible"))){
		for(var x = 0; x < D.length; x++ )
		{
			$("#item_" + x).show().removeHighlight();
		}
	}
	
	if (text.length > 0){
		$('#filtered_message').show();
		$('#filter_detail').html('  "' + text + '"');
		update_panel_counts();
	}
	else{
		clear_filters();
	}

}

function search_for_old(text){
	text = text.toLowerCase();
	for(var i = 0; i < D.length; i++ )
	{
		var subject = D[i].subject.toLowerCase();
		if ((text.length == 0) || (subject.indexOf(text) > -1))
		{
			$("#item_" + i).show().removeHighlight();
			if (text.length > 0){
				$("#item_content_details_" + i).texthighlight(text);
			}
		}
		else 
		{
			$("#item_" + i).hide().removeHighlight();
		}
	}
	
	if (text.length > 0){
		$('#filtered_message').show();
		$('#filter_detail').html('  "' + text + '"');
		update_panel_counts();
	}
	else{
		clear_filters();
	}

}

function clear_filters(){
	$('#filtered_message').hide();
	$('#fast_search').val('');
	$('#fast_search').val(''); //clearing fast search
	$("#filter_select option[value='all_top']").attr('selected', 'selected');	//clearing select
	hide_inactive(99999);
	update_panel_counts();
		
	for(var i = 0; i < D.length; i++ )
	{
		$("#item_" + i).show().removeHighlight();
	}
	
}

function send_item_action(dataId,action,extradata){
	//Login required	
	if (!is_user_logged_in()){return;}
	
	var data = "commit=Create&lock_version=" + D[dataId].lock_version + extradata;

    var url = url_for({ controller: 'issues',
                           action    : action,
							id		: D[dataId].id
                          });

	$("#item_content_icons_editButton_" + dataId).remove();
	$("#icon_set_" + dataId).addClass('updating');
	
	
	$.ajax({
	   type: "POST",
	   dataType: "json",
	   url: url,
	   data: data,
	   success:  	function(html){
			item_actioned(html,dataId,action);
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
	for(var i = 0; i < item.journals.length; i++ ){
			if (item.journals[i].notes != '' && item.journals[i].notes != null){
				return true;
			}
		}
	return false;
}

//resize heights of container and panels
function resize(){
	// panel_height = $(window).height() - $('.gt-hd').height() - $('#help_section:visible').height() + 28;// + $('.gt-footer').height() ;
	// // panel_height = $(window).height() - $('.gt-hd').height() + 28;// + $('.gt-footer').height() ;
	// // $("#content").height(panel_height - 35);
	// $(".list").height(panel_height - 75);
	$("#panels").show();
	recalculate_widths();
}

function insert_panel(position, name, title, visible){
	var button_style = "";
	if (visible){button_style = 'style="display:none;"';}
	generate_and_append_panel(position,name,title, visible);
	
	// $('#panel_buttons').prepend('<input id="' + name + '_panel_toggle" value="' + title + ' (0)" type="submit" onclick="show_panel(\'' + name + '\');return false;" class="dashboard-button-panel" ' + button_style + '/>');
	var button = "";
	button = button + '<a id="' + name + '_panel_toggle" onclick="show_panel(\'' + name + '\');return false;" class="dashboard-button-panel" ' + button_style + '>';
	button = button + '<div id="' + name + '_panel_toggle_count" class="panel_button_top">' + title + ' (0)</div>';
	button = button + '</a>';
	$('#panel_buttons').prepend(button);
	
	$("#help_image_panel_" + name).mybubbletip('#help_panel_' + name, {deltaDirection: 'right', bindShow: 'click'});
}

function generate_and_append_panel(position,name,title, visible){
	var panel_style = null;
	if (!visible){panel_style = 'style="display:none;"';}

	var panelHtml = '';
	panelHtml = panelHtml + "	<td id='" + name + "_panel' class='panel' " + panel_style + "'>";
	panelHtml = panelHtml + "<div class='panelHeaderRight'></div>";
	panelHtml = panelHtml + "<div class='panelHeaderLeft'></div>";
	panelHtml = panelHtml + "<div id='panel_header_" + name +"'class='panelHeader'>";
	panelHtml = panelHtml + "  <a href='javascript:void(0)' class='closePanelLoading panelLink' id='" + name + "_close' title='Close panel' onclick='close_panel(\"" + name + "\");return false;'></a>";
	panelHtml = panelHtml + "  <span id='" + name +"_panel_title' class='panelTitle'>" + title + " (0)</span>";
	panelHtml = panelHtml + '  	<img id="help_image_panel_' + name + '" src="/images/help.png" class="help_question_mark">';
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
	update_panel_count('open');
	update_panel_count('inprogress');
	update_panel_count('done');
	update_panel_count('canceled');
	// update_panel_count('archived');
	
	adjust_button_container_widths();
	
}

function update_panel_count(name, skip_button){
	try{
		if ($("#" + name + '_panel').is(":visible")){
			count = $("#" + name + "_start_of_list > *:visible").length;
		}
		else{
			count = $("#" + name + "_start_of_list > *").length;
		}

		$("#" + name + '_panel_title').html($("#" + name + '_panel_title').html().replace(/\([0-9]*\)/,"(" + count + ")"));
		if (!skip_button){
			$("#" + name + '_panel_toggle_count').html($("#" + name + '_panel_toggle_count').html().replace(/\([0-9]*\)/,"(" + count + ")"));
		}
		return true;
	}
	catch(err){
		return false;
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
	$('#' + name + '_close').addClass('closePanel').removeClass('closePanelLoading');
}

// Sorts items in a plane by priority (highest first) followed by created date (oldest first)
function sort_panel(name){
		var listitems = $('#' + name + '_start_of_list').children().get();

 		//Setting highest_pri to priority of first item in open panel
		// if ((name == "open") && (listitems.length > 0)){
		// 	var first_item_id = listitems[0].id.replace(/item_/g,'');
		// 	// var first_item_data_id = ITEMHASH["item" + first_item_id];
		// 	//BUGBUG: listitems.length could be greater than 0 if it has only one item that's being edited
		// 	highest_pri = D[first_item_id].pri;
		// 	}
		
		listitems.sort(function(a, b) {
		   var compA = a.id.replace(/item_/g,'');
		   var compB = b.id.replace(/item_/g,'');
					
			// 		   if (name == "open"){
			// if (D[compA].pri > highest_pri) { highest_pri = D[compA].pri;}
			// 		   		if (D[compB].pri > highest_pri) { highest_pri = D[compB].pri;}
			// 		   }
		
		   if (compA == 'new_link') {
				return -1;
			}
			else if (compB == 'new_link') {
					return 1;
			}
			  else if (D[compA].agree_total > D[compB].agree_total) {
			return -1;
			} else if (D[compA].agree_total < D[compB].agree_total) {
				return 1;
			} else if (new Date(D[compA].created_at) > new Date(D[compB].created_at)) {
				return 1;
			} else {
				return -1;
			}
		});


		$('#' + name + '_start_of_list').children().remove();

		$.each(listitems, function() {
		    $('#' + name + '_start_of_list').append(this);
		    });
		
		// if (name == "open"){
		// 	show_start_buttons();
		// }
}

// function show_start_buttons(){
// 	$(".action_button_start").hide();
// 	for (var i=0; i < startable_priority_tiers; i++){
// 		$(".pri_" + (highest_pri - i)).find(".action_button_start").show();
// 	}
// 	$(".points_0").find(".action_button_start").show();
// }


function recalculate_widths(){
	var new_width = $('#main').width() / $('.panel:visible').length;
	$('.panel:visible').width(new_width);
	adjust_button_container_widths();
	
}

function expand_item(dataId){
	$('#item_' + dataId).replaceWith(generate_item_edit(dataId));
	
	//arming file upload
	$('#file_upload_' + dataId).fileUploadUI({
        uploadTable: $('#files_' + dataId),
        downloadTable: $('#files_' + dataId),
        buildUploadRow: function (files, index) {
            return $('<tr><td>' + files[index].name + '<\/td>' +
                    '<td class="file_upload_progress"><div><\/div><\/td>' +
                    '<td class="file_upload_cancel">' +
                    '<button class="ui-state-default ui-corner-all" title="Cancel">' +
                    '<span class="ui-icon ui-icon-cancel">Cancel<\/span>' +
                    '<\/button><\/td><\/tr>');
        },
        buildDownloadRow: function (attachment) {
            return $('<tr><td><a class="icon icon-attachment" href="/attachments/' + attachment.id + '/' + attachment.filename + '">' + attachment.filename + '</a> (' + attachment.filesize + ' Bytes)<\/td><\/tr>');
        }
    });
    
	$.fn.getGravatar.getUrl({
	        avatarContainer: '#gravatar_' + dataId,
	        avatarSize:27
			},
			D[dataId].author.mail_hash
	);

	$('#new_comment_' + dataId).watermark('watermark',new_comment_text);
	$('#new_comment_' + dataId).autogrow().mentions(projectId);
	$('#new_todo_' + dataId).watermark('watermark',new_todo_text);
	$('#edit_description_' + dataId).autogrow().mentions(projectId);
	$('#help_image_description_' + dataId).mybubbletip($('#help_description'), {
		deltaDirection: 'right',
		delayShow: 300,
		delayHide: 100,
		offsetLeft: 0,
		bindShow: 'click'
	});
	$('#help_image_requestid_' + dataId).mybubbletip($('#help_requestid'), {
		deltaDirection: 'right',
		delayShow: 300,
		delayHide: 100,
		offsetLeft: 0,
		bindShow: 'click'
	});
	$('#issue_tags_edit_' + dataId).tagsInput({
	   'autocomplete_url': 'http://localhost:3000/projects/' + projectId + '/all_tags',
	   'autocomplete':{selectFirst:true,width:'100px',autoFill:true},
	   'issue_id':D[dataId].id,
	   'height':'20px',
	   'width':$('#edit_title_input_' + dataId).width() - 30,
	   'defaultText':'add a tag'
	});
	
	make_text_boxes_toggle_keyboard_shortcuts();
	$('#item_' + dataId).parent().parent().scrollTo('#item_' + dataId, 500);

}

function collapse_item(dataId,check_for_save){
	//save subject and title if they changed
	// if(check_for_save){
	// 	if (($('#edit_title_input_' + dataId).val() != D[dataId].subject) || ($('#edit_description_' + dataId).val() != D[dataId].description)){
	// 		save_edit_item(dataId);
	// 		return false;
	// 	}
	// }
	
	$("#edit_item_" + dataId).replaceWith(generate_item(dataId));
	$("#item_content_" + dataId).effect("highlight", {mode: 'show'}, 5000);
	keyboard_shortcuts = true;
	// show_start_buttons();
	adjust_button_container_widths();
	return false;
}

function save_new_item(prioritize){
    if (($('#new_title_input').val() == default_new_title) || ($('#new_title_input').val() == ''))
    {
	alert('Please enter a title');
	return false;
    }


    var data = "commit=Create&project_id=" + projectId + 
        // "&issue[tracker_id]=" + $('#new_story_type').val() + 
        "&issue[subject]=" + encodeURIComponent($('#new_title_input').val()) + 
        "&issue[description]=" + encodeURIComponent($('#new_description').val()) +
        "&issue[tags_copy]=" + encodeURIComponent($('#new_tags').val()) + 
        "&estimate=" + $('#new_story_complexity').val() + 
        "&prioritize=" + prioritize;

	if (new_attachments.length > 0){
		data = data + "&attachments=" + new_attachments.join(",");
		new_attachments = [];
	}
    
    var url = url_for({ controller: 'issues',
                           action    : 'new'
                          });

	$("#new_item_wrapper").html('<div id="loading" class="loading"> Adding...</div>');
	
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
		remove_new_link();
		add_new_link();
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

    var data = "commit=Submit&lock_version=" + D[dataId].lock_version + 
        "&project_id=" + projectId + 
        "&id=" + D[dataId].id + 
        "&issue[subject]=" + encodeURIComponent($('#edit_title_input_' + dataId).val()) + 
        "&issue[description]=" + encodeURIComponent($('#edit_description_' + dataId).val());

    var url = url_for({ controller: 'issues',
                        action    : 'edit'
                      });

    $("#edit_item_" + dataId).replaceWith(generate_item(dataId));
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
	$("#item_new_link").show();
	
	keyboard_shortcuts = true;
	return false;
}

function item_added(item){
	$("#new_item_wrapper").remove();
	D.push(item); 
	ITEMHASH["item" + item.id] = D.length - 1;
	add_item(D.length-1,"top",false);
	keyboard_shortcuts = true;
	// show_start_buttons();
	update_panel_counts();
	remove_new_link();
	add_new_link();
	return false;
}

function item_actioned(item, dataId, action){
	
	collapse_item(dataId,false);
	var pre_status = D[dataId].status.name;
	
	var status_changed = (pre_status != item.status.name);

	// New and estimate status are the same as far as the dashboard is concerned
	if ((item.status.name == 'Estimate' && pre_status == 'New')||(item.status.name == 'New' && pre_status == 'Estimate')||(item.status.name == 'Open' && pre_status == 'New')||(item.status.name == 'New' && pre_status == 'Open'))
	{
		status_changed = false;
	}
	
	D[dataId] = item; 
	$('#item_lightbox_' + dataId).replaceWith(generate_item_lightbox(dataId));
	update_lightbox_lock_version(dataId);
	
	if (item.retro_id > 1){ //an item has moved into a retrospective, we remove it from the dashboard.
		$("#item_" + dataId).remove();
		// update_panel_counts();
	}
	else if ((!status_changed) || (item.status.name == 'Accepted' && action != "data_refresh") || (item.status.name == 'Rejected' && action != "data_refresh"))
	{
		$('#item_' + dataId).replaceWith(generate_item(dataId));
		// show_start_buttons();
		//tODO: highlight the right item here
	}
	else
	{
		$("#item_" + dataId).remove();
		add_item(dataId,"bottom",action != "data_refresh");
		// update_panel_counts();
	}	

	keyboard_shortcuts = true;
	
	$("#item_content_" + dataId).effect("highlight", {mode: 'show'}, 5000);
	
	//we don't sort panels on data refresh
	if (action != "data_refresh"){
		if (action == "add") {	
			sort_panel('new');
			$("#" + item.status.name.toLowerCase() + "_items").scrollTo('#item_' + dataId, 300);
		}
		
		// if (action == "open" || item.status.name == "Open" || pre_status == "Open") {sort_panel("open");}
		// if ((action == "deprioritize")||(action == "prioritize")||(item.status.name == "Open")) {	
		// 	sort_panel(item.status.name.toLowerCase());
		// 	$("#" + item.status.name.toLowerCase() + "_items").scrollTo('#item_' + dataId, 300);
		// }
		
		adjust_button_container_widths();
		save_local_data();
		update_panel_counts();
	}
	
	//show/hide startable button if item is open
	if (is_startable(item) == true){
		$("#item_content_buttons_start_button_" + dataId).show();
	}
	else{
		$("#item_content_buttons_start_button_" + dataId).hide();
	}
	
	return false;
}

function item_prioritized(item, dataId,action){
	//sort_panel(item.status.name);
	//TODO: put item in correct order on this list
	D[dataId] = item; 
	$('#' + item.id).addClass('pri_' + item.pri);
	$('#' + item.id).removeClass('pri_' + item.pri - 1);
	$('#' + item.id).removeClass('pri_' + item.pri + 1);
	
	return false;
}


function item_estimated(item, dataId){
	D[dataId] = item; 
	$("#item_" + dataId).replaceWith(generate_item(dataId));
	$('#item_lightbox_' + dataId).replaceWith(generate_item_lightbox(dataId));
	update_lightbox_lock_version(dataId);
	
	
	keyboard_shortcuts = true;
	return false;
}

function item_updated(item, dataId){
	D[dataId] = item; 
	$("#item_" + dataId).replaceWith(generate_item(dataId));
	$('#item_lightbox_' + dataId).replaceWith(generate_item_lightbox(dataId));
	update_lightbox_lock_version(dataId);
	
	
	keyboard_shortcuts = true;
	return false;
}

function comment_added(item, dataId){
	$("#post_comment_button_" + dataId).show();
	D[dataId] = item; 
	$('#comments_container_' + dataId).replaceWith(generate_comments_section(dataId,false));
	$('#new_comment_' + dataId).watermark('watermark',new_comment_text);
	$('#new_comment_' + dataId).autogrow().mentions(projectId);
}

function todo_added(item, dataId){
	D[dataId] = item; 
	$('#todo_container_' + item.id).html(generate_todos(dataId,false,true));
}

function todo_updated(item, dataId){
	D[dataId] = item; 
	// $('#todo_container_' + item.id).html(generate_todos(item,false));
}

function ensure_numericality_of_num_hours(num_hours) {
    if(num_hours == '') {
	alert('Please enter the estimated number of hours for this hourly item.');
	return false;
    }
    else if(isNaN(num_hours)) {
	alert('Please enter a number for the estimated number of hours');
	return false;
    }
    
    return true;
}

function isNumeric(form_value) 
{ 
    if (form_value.match(/^[-+]?\d+(\.\d+)?$/) == null) 
        return false; 
    else 
        return true; 
}

function sortoptions(sort)
{
	var $this = $(this);
	// sort
	$this.removeOption("0"); //removing loading
	$this.removeOption("1"); //removing administrator
	$this.removeOption(currentUserId); //removing self
	$this.sortOptions();
}

function generate_complexity_row(){
	var html = '';
	html = html + '	              <tr id="complexity_row">';
	html = html + '	                <td class="letContentExpand" colspan="1">';
	html = html + '	                  <div>';
	html = html + '	                    <select id="new_story_complexity" class="gt-SdField" name="new_story_complexity" >';
	html = html +                         generate_complexity_dropdown();
	html = html + '	                    </select>';
	html = html + '	                  </div>';
	html = html + '	                </td>';
	html = html + '	                <td class="gt-SdLabelIcon" colspan="1">';
	html = html + '	                  <div class="gt-SdLabelIcon">';
	html = html + '	                    <img src="/images/dice_NO.png" id="new_story_type_image" name="new_story_type_image">';
	html = html + '	                  </div>';
	html = html + '	                </td>';
	html = html + '	                <td class="helpIcon lastCell" colspan="1">';
	html = html + '	                  <div class="helpIcon" id="story_newStory_details_help_story_types">';
	html = html + '	                    <img id="help_image_complexity" src="/images/question_mark.gif"  class="help_question_mark">';
	html = html + '	                  </div>';
	html = html + '	                </td>';
	html = html + '	              </tr>';
	return html;
	
}


function generate_complexity_dropdown() {
    var html='';
	if (credits_enabled){
		html += '<option selected="true" value="">Credits (optional)</option>';
		
		for(var i = 0;i<7;i++) {
		
		credits = point_factor[i] * credit_base;
		html += '<option value="' +  credits + '">';
		html += credits + " credits";
		html += '</option>';
	    }   

		html += '<option value="-1">Don\'t know</option>';
	}
	else{
		html += '<option value="0">0 - Real easy</option>';
		html += '<option value="' + point_factor[1] * credit_base + '">1</option>';
		html += '<option value="' + point_factor[2] * credit_base + '">2</option>';
		html += '<option selected="true" value="' + point_factor[3] * credit_base + '">3 - Average complexity</option>';
		html += '<option value="' + point_factor[4] * credit_base + '">4</option>';
		html += '<option value="' + point_factor[5] * credit_base + '">5</option>';
		html += '<option value="' + point_factor[6] * credit_base + '">6 - Super hard</option>';
		html += '<option value="-1">Don\'t know</option>';
	}

    return html;
}


function new_item(){

new_attachments = [];

//Login required	
if (!is_user_logged_in()){return;}

keyboard_shortcuts = false;



$("#new_item_wrapper").remove();
html = '';	
html = html + '	<div class="item" id="new_item_wrapper">';
html = html + '	  <div class="storyItem unscheduled unestimatedText underEdit" id="icebox_itemList_storynewStory_content">';
// html = html + '	   <form action="#">';
html = html + '	    <div class="itemCollapsedHeader">';
html = html + '	      <div class="itemCollapsedInput">';
html = html + '	        <input id="new_title_input" class="titleInputField" name="title_input" value="" type="text">';
html = html + '	      </div>';
html = html + '	    </div>';
html = html + '	    <div>';
html = html + '	      <div id="new_details" class="gt-Sd">';
html = html + '	          <table class="gt-SdTable">';
html = html + '	            <tbody>';
html = html + generate_complexity_row();
html = html + '	              <tr>';
html = html + '	                <td class="letContentExpand" colspan="1">';
html = html + '	                  <div>';
html = html + '	        <input id="new_tags" class="issue-tags" name="new_tas" value="" type="text" size="30">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td class="gt-SdLabelIcon" colspan="1">';
html = html + '	                  <div class="gt-SdLabelIcon">';
html = html + '	                    <img src="/images/tag_blue.png" id="new_story_type_image" name="new_story_type_image">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td class="helpIcon lastCell" colspan="1">';
html = html + '	                  <div class="helpIcon" id="story_newStory_details_help_story_types">';
html = html + '	                    <img id="help_image_tags_new" src="/images/question_mark.gif"  class="help_question_mark">';
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
html = html + '	                      <img id="help_image_description_new" src="/images/question_mark.gif"  class="help_question_mark">';
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

html = html + '	                <tr><td colspan="5">';
html = html + '	                <table id="files_new" class="attachments"></table>';
html = html + '	                <form id="file_upload_new" action="/issues/0/attachments/create?container_type=Issue" method="POST" enctype="multipart/form-data">';
html = html + '	                <input type="file" name="file" multiple>';
html = html + '	                <button>Upload</button>';
html = html + '	                <a class="icon icon-attachment" href="#">Attach files</a>';
html = html + '	                </form>';
html = html + '	                </td></tr>';

html = html + '	              </tbody>';
html = html + '	            </table>';
html = html + '	          <table class="gt-SdTable">';
html = html + '	            <tbody>';
html = html + '	              <tr>';
html = html + '	                <td>';
html = html + '	                  <div class="gt-SdButton">';
html = html + '	                    <input id="new_save_button" value="Create" type="submit" onclick="save_new_item(false);return false;">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td>';
html = html + '	                  <div class="gt-SdButton">';
html = html + '	                    <input id="new_save_button" value="Create & Prioritize" type="submit" onclick="save_new_item(true);return false;">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td>';
html = html + '	                  <div class="gt-SdButton">';
html = html + '	                    <input id="new_cancel_button" value="Cancel" type="submit" onclick="cancel_new_item();return false;">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td>';
html = html + '	                </td>';
html = html + '	              </tr>';
html = html + '	            </tbody>';
html = html + '	          </table>';
html = html + '	          </div>';
html = html + '	      </div>';
html = html + '	    </div>';
// html = html + '    </form>';
html = html + '	  </div>';
html = html + '	</div>';


show_panel('new');
$("#item_new_link").hide();
$("#new_items").prepend(html);

$("#new_title_input").val(default_new_title).select();	
$("#new_description").autogrow().mentions(projectId);
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

$('#help_image_tags_new').mybubbletip($('#help_tags'), {
	deltaDirection: 'up',
	delayShow: 300,
	delayHide: 100,
	offsetTop: 0,
	bindShow: 'click'
});

if (credits_enabled){
	complexity_help_id = "#help_complexity_credits";
}
else{
	complexity_help_id = "#help_complexity_no_credits";
}

$('#help_image_complexity').mybubbletip($(complexity_help_id), {
	deltaDirection: 'up',
	delayShow: 300,
	delayHide: 100,
	offsetTop: 0,
	bindShow: 'click'
});

//arming file upload
$('#file_upload_new').fileUploadUI({
    uploadTable: $('#files_new'),
    downloadTable: $('#files_new'),
    buildUploadRow: function (files, index) {
        return $('<tr><td>' + files[index].name + '<\/td>' +
                '<td class="file_upload_progress"><div><\/div><\/td>' +
                '<td class="file_upload_cancel">' +
                '<button class="ui-state-default ui-corner-all" title="Cancel">' +
                '<span class="ui-icon ui-icon-cancel">Cancel<\/span>' +
                '<\/button><\/td><\/tr>');
    },
    buildDownloadRow: function (attachment) {
        return $('<tr><td><a class="icon icon-attachment" href="/attachments/' + attachment.id + '/' + attachment.filename + '">' + attachment.filename + '</a> (' + attachment.filesize + ' Bytes)<\/td><\/tr>');
    },
	onComplete: function (event, files, index, xhr, handler){
		new_attachments.push(handler.parseResponse(xhr).id);
	}
});

$("#new_items").scrollTo( '#new_item_wrapper', 800);

$('#new_tags').tagsInput({
   'autocomplete_url': 'http://localhost:3000/projects/' + projectId + '/all_tags',
   'autocomplete':{selectFirst:true,width:'100px',autoFill:true},
   'issue_id':null,
   'height':'20px',
   'width':$('#issue_tags_container').width(),
   'defaultText':'add a tag'
});


}

function is_item_editable(dataId) {
	if (!currentUserCanEditIssue){
		return false;
	}
  return !(D[dataId].status.name == 'Committed' ||
	   D[dataId].status.name == 'Done'      ||
	   D[dataId].status.name == 'Accepted'      ||
	   D[dataId].status.name == 'Rejected'      ||
	   D[dataId].status.name == 'Canceled'  ||
	   D[dataId].status.name == 'Archived');
}

function is_item_todos_editable(dataId) {
	if (!currentUserCanEditIssue){
		return false;
	}
  return !(
	   D[dataId].status.name == 'Done'      ||
	   D[dataId].status.name == 'Accepted'      ||
	   D[dataId].status.name == 'Rejected'      ||
	   D[dataId].status.name == 'Canceled'  ||
	   D[dataId].status.name == 'Archived');

}


function is_item_joinable(item) {
	return true;
}

function is_item_estimatable(item) {
  return true;
  return (!credits_enabled);
}


function is_tracker_editable(dataId) {
	return true;
}

function generate_expense_amount_editor(points,dataId){
	var html = '';
	html = html + '<div id="item_expense_amount_' + dataId + '">Amount $' + points;
	if (dataId == "new"){
		html = html + ' (<a href="" onclick="prompt_for_expense_amount(' + points + ', \'' + dataId + '\');return false;">edit</a>)';
	}
	html = html + '	        <input id="new_expense_amount_' + dataId + '" class="hidden" name="title_input" value="' + points + '" type="text">';
	html = html + '</div>';
	return html;
}

function generate_item_edit(dataId){  
  
var item_editable = is_item_editable(dataId);
var tracker_editable = is_tracker_editable(dataId);

// The subject and description input elements, and the issue type
// combo box are rendered readonly/disable if the item is not editable
var readonly = !item_editable ? "readonly" : "";
var disabled = !item_editable || !tracker_editable  ? "disabled" : "";
  
var html = '';	
html = html + '	<div class="item" id="edit_item_' + dataId + '">';
html = html + '	  <div class="storyItem underEdit" id="editItem_content_' + dataId + '">';
// html = html + '	   <form action="#">';
html = html + '	    <div class="itemCollapsedHeader">';
html = html + ' 		<img id="item_content_icons_editButton_' + dataId + '" class="toggleExpandedButton" src="/images/story_expanded.png" title="Collapse" alt="Collapse" onclick="collapse_item(' + dataId + ',true);return false;">';
html = html + '<div id="icon_set_' + dataId + '" class="left">&nbsp;</div>';
html = html + '	      <div class="itemCollapsedInput">';
html = html + '	        <input id="edit_title_input_' + dataId + '" class="titleInputField" name="title_input" value="' + h(D[dataId].subject) + '" type="text" ' + readonly + '>';
html = html + '	      </div>';
html = html + '	    </div>';
html = html + '	    <div>';
html = html + '	      <div id="edit_details_' + dataId + '" class="gt-Sd">';
html = html + '	          <table class="gt-SdTable">';
html = html + '	            <tbody>';
html = html + '	              <tr>';
if (item_editable){
	html = html + '	                <td>';
	html = html + '	                  <div class="gt-SdButton">';
	html = html + '	                    <input id="edit_save_button' + dataId + '" value="Save" type="submit" onclick="save_edit_item(' + dataId + ');return false;">';
	html = html + '	                  </div>';
	html = html + '	                </td>';
	html = html + '	                <td>';
	html = html + '	                  <div class="gt-SdButton">';
	html = html + '	                    <input id="edit_cancel_button' + dataId + '" value="Cancel" type="submit" onclick="collapse_item(' + dataId + ',false);return false;">';
	html = html + '	                  </div>';
	html = html + '	                </td>';	
}
html = html + '	                <td>';
html = html + '	                  <div class="gt-SdButton">';
html = html + '	                    <input id="edit_full_screen_button" value="Full Screen" type="submit" onclick="full_screen(' + dataId + ');return false;">';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td style="width:100%;">';
html = html + '	                  <div class="gt-SdActionButton">';
html = html + buttons_for(dataId,true);
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	              </tr>';
html = html + '	            </tbody>';
html = html + '	          </table>';
html = html + '	          <table class="gt-SdTable">';
html = html + '	            <tbody>';
html = html + '	              <tr>';
html = html + '	                <td class="letContentExpand" colspan="1">';
html = html + '	                  <div>';
html = html + '						<input type="text" id="issue_tags_edit_' + dataId + '" size="60" value="' + D[dataId].tags_copy + '"></input>';
html = html + '	                  </div>';
html = html + '	                </td>';
html = html + '	                <td class="helpIcon">';
// html = html + '	                    <img id="help_image_tag_' + dataId + '" src="/images/question_mark.gif" class="help_question_mark">';
html = html + '	                </td>';
html = html + '	                <td class="lastCell created_by">';
html = html + '        				<img id="gravatar_' + dataId +'" display="hidden" class="gravatar right" src=""/>';
html = html + 	                   D[dataId].author.firstname + ' ' + D[dataId].author.lastname + '&nbsp;';
html = html + '	                </td>';
html = html + '	              </tr>';
html = html + '	              <tr id="assigned_to_' + dataId + '">';
html = html + '	                <td class="letContentExpand" colspan="3">';
html = html + '	                <div id="assigned_to_text_' + dataId + '">';
html = html + '</div>';
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
html = html + '	                      <img id="help_image_description_' + dataId + '" src="/images/question_mark.gif"  class="help_question_mark">';
html = html + '	                    </div>';
html = html + '	                  </td>';
html = html + '	                </tr>';
html = html + '	                <tr>';
html = html + '	                  <td colspan="5">';
html = html + '	                    <div>';
html = html + '	                      <textarea class = "textAreaFocus" id="edit_description_' + dataId + '" rows="1" cols="20" name="story[description]" ' + readonly + '>' + h(D[dataId].description) + '</textarea>     ';
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
html = html + generate_comments_section(dataId);
html = html + generate_attachments_section(dataId);

// request id
html = html + '	          <div class="section">';
html = html + '	            <table class="storyDescriptionTable">';
html = html + '	              <tbody>';
html = html + '	                <tr>';
html = html + '	                  <td>';
html = html + '	  <div class="header">';
html = html + '	    Item ID: <span style="font-weight:normal;">' + D[dataId].id + '</span>';
html = html + '	                      <img id="help_image_requestid_' + dataId + '" src="/images/question_mark.gif"  class="help_question_mark">';
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
html = html + '	            <table>';
html = html + '	                <tr>';
html = html + '	                <td align="right">';

// html = html + '	                <a href="" onclick="full_screen(' + dataId + ',\'true\');return false;">Attach files</a>';

if (currentUserIsCore == 'true' || currentUserIsMember == 'true'){
html = html + '	                <a href="" onclick="full_screen(' + dataId + ');return false;">Relations</a>';
// html = html + '	                | <a href="" onclick="full_screen(' + dataId + ');return false;">Add Team Members</a>';
html = html + '	                | <a href="" onclick="full_screen(' + dataId + ');return false;">Move</a>';
}

html = html + '	                </td>';
html = html + '	                </tr>';
html = html + '	            </table>';
html = html + '	          </div>';

return html;
}


function generate_attachments_section(dataId){

	var html = '';
	html = html + '	          <div id="attachment_section_' + dataId + '" class="section">';
	html = html + '	            <table class="storyDescriptionTable">';
	html = html + '	              <tbody>';
	html = html + '	                <tr><td colspan="5">';
	html = html + '					  <div class="header">';
	html = html + '	   					 Attachments';
	html = html + '	 				 </div>';
	html = html + '	                </td></tr>';
	for(var i = 0; i < D[dataId].attachments.length; i++ ){
		attachment = D[dataId].attachments[i];
		html = html + '	                <tr><td colspan="5">';
		html = html + '	                <a class="icon icon-attachment" href="/attachments/' + attachment.id + '/' + attachment.filename + '">' + attachment.filename + '</a>';
		html = html + '	                </td></tr>';
	}
	html = html + '	                <tr><td colspan="5">';
	html = html + '	                <table id="files_' + dataId + '" class="attachments"></table>';
	html = html + '	                <form id="file_upload_' + dataId + '" action="/issues/' + D[dataId].id + '/attachments/create?container_type=Issue" method="POST" enctype="multipart/form-data">';
	html = html + '	                <input type="file" name="file" multiple>';
	html = html + '	                <button>Upload</button>';
	html = html + '	                <a class="icon icon-attachment" href="#">Attach files</a>';
	html = html + '	                </form>';
	html = html + '	                </td></tr>';
	html = html + '	              </tbody>';
	html = html + '	            </table>';
	html = html + '	          </div>';
	return html;
	
}


function generate_todo_section(dataId){

	var item_editable = is_item_todos_editable(dataId);
	
	var html = '';
	html = html + '	          <div id="todo_section_' + dataId + '" class="section">';
	html = html + '	   <form action="#">';
	html = html + '	            <table class="storyDescriptionTable">';
	html = html + '	              <tbody>';
	html = html + '	                <tr><td colspan="5">';
	html = html + generate_todos(dataId,false,item_editable);
	html = html + '	                </td></tr>';
	if (item_editable){
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
	}
	html = html + '	              </tbody>';
	html = html + '	            </table>';
	html = html + '	   </form>';
	html = html + '	          </div>';
	return html;
	
}

function generate_todo_section_lightbox(dataId){
	var item_editable = is_item_todos_editable(dataId);
	
	var html = '';
	html = html + '	          <div id="todo_section_' + dataId + '" class="section">';
	html = html + '	   <form action="#">';
	html = html + '	            <table id="todo_lightbox">';
	html = html + '	              <tbody>';
	html = html + '	                <tr><td colspan="5">';
	html = html + generate_todos(dataId,false, item_editable);
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

function post_comment(dataId,from_prompt,action){	
	
//Login required	
if (!is_user_logged_in()){return false;}

	
try{
	var text = "";
	
	
	if (from_prompt){
		text = $("#prompt_comment_" + dataId).val();
		
		//Try capturing comment from inner frame (in case of lightbox comment)
		if (text == null){
			text = $("#fancybox-frame").contents().find("#prompt_comment_" + dataId).val();
		}
	}
	else{
		text = $("#new_comment_" + dataId).val();
	}
	
	
	if ((text == null) || (text.length < 2) || (text == new_comment_text)){
		return false;
	}
	else
	{
		$("#post_comment_button_" + dataId).hide();
		var item = D[dataId];
		try{
			$("#notesTable_" + item.id).append(generate_comment(currentUser,text,'1 second ago','new'));
			$('#new_comment_' + dataId).val('');
		}
		catch(err){
			
		}
		
		$("#new_comment_" + dataId).height(35);
		
		
		var data = "commit=Create&issue_id=" + item.id + "&comment=" + encodeURIComponent(text);
		
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
			},
		   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
			$("#post_comment_button_" + dataId).show();
			handle_error(XMLHttpRequest, textStatus, errorThrown, dataId, "post");
			},
			timeout: 30000 //30 seconds
		 });

		return false;
	}
	}
catch(err){
	return false;
}
}

function post_todo(dataId){

//Login required	
if (!is_user_logged_in()){return false;}


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
		
		
		var data = "commit=Create&issue_id=" + item.id + "&todo[subject]=" + encodeURIComponent(text);
		data = data + '&todo[author_id]=' + currentUserId;
		
		
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
	return false;
}
}


function update_todo(todoId, dataId){
try{
		var item = D[dataId];	
		var data = "commit=Update&id=" + todoId + "&issue_id=" + item.id; // + "&todo[subject]=" + text;
		
		if ($('#task_' + todoId + '_complete').attr("checked") == true){
			$('#task_' + todoId  + '_subject').addClass('completed');
			$('#task_' + todoId  + '_subject_text').html($('#task_' + todoId  + '_subject_text').html() + ' (' + currentUserLogin + ')' );
			data = data + '&todo[completed_on]=' + Date();
			data = data + '&todo[owner_login]=' + currentUserLogin;
			data = data + '&todo[owner_id]=' + currentUserId;
			
		}
		else
		{
			$('#task_' + todoId  + '_subject').removeClass('completed');
			$('#task_' + todoId  + '_subject_text').html(h($('#task_' + todoId  + '_subject_input').val()));
			data = data + '&todo[completed_on]=';
			data = data + '&todo[owner_login]=';
			data = data + '&todo[owner_id]=';
			
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
	return false;
}
}

function update_todo_count(dataId){
	$('#task_' + dataId  + '_count').html('(' + D[dataId].todos.length + ')');
}

// function update_comment_count(dataId){
// 	$('#comment_' + D[dataId].id  + '_count').html('(' + $('.noteInfo_' + D[dataId].id).length + ')');	
// }


//View item history
function full_screen(dataId,update){
	show_issue_full(D[dataId].id,update);
	collapse_item(dataId,false);
}

//Full page view in fancy box of a single issue
function show_issue_full(itemId,update){
	
	var url = url_for({ controller: 'issues',
	                           action    : 'show',
								id		: itemId,
								update : update
	                          });


	if (update == 'true'){
		url = url + '?update=true';
	}
	
	show_fancybox(url,'loading data...');

	return false;
}

//Full page view in fancy box of a single retro
function show_retro_full(retroId){
	var url = '/projects/' + projectId + '/retros/' + retroId + '/show';
	show_fancybox(url,'generating retrospective data...');

	return false;
}

function timer_beat(timer){
	//check that I haven't been inactive for too long
	if (((new Date).getTime() - last_activity.getTime()) > INACTIVITY_THRESHOLD){
		stop_timer(timer);
	}
	else if (timer_active == true){
		new_dash_data();
	}
}

function new_dash_data(){
	if (timer_active == false){
		return;
	}
	else{
		timer_active = false;
	}
	
	replace_reloading_images_for_panels();
	
	var data = "seconds=" + (((new Date).getTime() - last_data_pull.getTime())/1000);
	
	data = data + "&issuecount=" + ISSUE_COUNT;
	
	if ($('#include_subworkstreams_checkbox').attr("checked") == true){
		data = data + "&include_subworkstreams=true";
	}
	

	var url = url_for({ controller: 'projects',
                           action    : 'new_dashdata',
							id		: projectId
                          });
	
	$.ajax({
	   type: "GET",
	   dataType: "json",	
	   contentType: "application/json",
	   url: url,
	   data: data,
	   success:  	function(html){
			$('#ajax-indicator').hide();
			last_data_pull = new Date();
			new_dash_data_response(html);
		},
	   error: 	function (XMLHttpRequest, textStatus, errorThrown) {
			$('#ajax-indicator').hide();
			last_data_pull = new Date();
			save_local_data();
			timer_active = true;
		},
		timeout: 30000 //30 seconds
	 });
}

function new_dash_data_response(data){
	timer_active = true;

	if ((data == null) || (data.length == 0)) {
		save_local_data();
		return;
	}
	
	//checking if this is a response with different item count
	if (data[0].tags_copy == undefined){
		
		// //we're getting a list of issue ids as a result of an issue moving that we didn't know about
		// 
		// ISSUE_COUNT = data.length;
		// 
		// for(var x=0; x < data.length; x++){
		// 	delete ITEMHASH["item" + String(data[x])];
		// 	delete ITEMHASH["item" + String(data[x])]; //handling duplicates
		// 	delete ITEMHASH["item" + String(data[x])]; //handling duplicates
		// }
		// 
		// for(var idt in ITEMHASH){
		// 	D.splice(ITEMHASH[idt],1);
		// 	$("#item_" + ITEMHASH[idt]).remove();
		// }
		// 
		// prepare_item_lookup_array();
		// save_local_data();
		return;
	}
	
	for(var i = 0; i < data.length; i++ ){
		
		var item = data[i];
		dataId = ITEMHASH["item" + String(item.id)];
		
		if (dataId == null){
			D.push(data[i]);
			ITEMHASH["item" + item.id] = D.length - 1;
			add_item(D.length-1,"bottom",false);	
		}
		else{		
			if (String(new Date(D[dataId].updated_at)) == String(new Date(item.updated_at))){
				continue;
			}
						
			
			if ($("#edit_item_" + dataId).length > 0){
				//item is being edited
				$.jGrowl("An item you are editing (#" + D[dataId].id + ") has been updated by another user. It's best to cancel your edits and re-open the item.", { sticky:true, header: 'Item conflict'});
				D[dataId] = item; 
				continue;
			}
			
			item_actioned(item, dataId,'data_refresh');
		}
	}
	
	// sort_panel('open');
	// sort_panel('inprogress');
	adjust_button_container_widths();
	update_panel_counts();
	save_local_data();
}

function is_user_logged_in(){
	if (currentUserId == ANONYMOUS_USER_ID){
		ask_for_login();
		return false;
	}
	else{
		return true;
	}
}

function ask_for_login(){
	$.jGrowl("<a href='/login'>Sorry, you need to be logged in first.<br> </a>" , { sticky:true, header: '<a href=\'/login\'>Login Required</a>'});
}


function handle_error (xhr, textStatus, errorThrown, dataId, action) {
	if (xhr.status == 401 && currentUserId == ANONYMOUS_USER_ID){
		ask_for_login();
		
		if (dataId){
			$('#item_' + dataId).replaceWith(generate_item(dataId));
		}
	}
	else if (dataId){
		$('#item_' + dataId).replaceWith(generate_item(dataId));
		$('#item_lightbox_' + dataId).replaceWith(generate_item_lightbox(dataId));
		update_lightbox_lock_version(dataId);
		
		
		// sort_panel('open');
		$('#featureicon_' + dataId).attr("src", "/images/error.png");
		$.jGrowl("Sorry, couldn't " + action + " item:<br>" + h(D[dataId].subject) , { header: 'Error', position: 'bottom-right' });
		
	}
	else{
		$("#new_item_wrapper").remove();
		$.jGrowl("Sorry, couldn't " + action + "<br>" + XMLHttpRequest, { header: 'Error', position: 'bottom-right' });
	}
	keyboard_shortcuts = true;
	
	// alert("Error: Couldn't " + action);
}
