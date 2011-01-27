/* BetterMeans - Work 2.0
   Copyright (C) 2006-2008  Shereef Bishay */

var jumpbox_text = "";
var community_members = {}; //used by @mention autocomplete 

function initialize(){
	arm_fancybox();
	prep_jumpbox();
	break_long_words();
	bind_autocomplete_mentions();
}

function break_long_words(){
	$('.long-words').breakWords();
}

function arm_fancybox(){
	$("a.fancyframe").fancybox({
			'speedIn'		:	600, 
			'speedOut'		:	200, 
			'overlayShow'	:	false,
			'width'				: '90%',
			'height'			: '95%',
	        'autoScale'     	: false,
			// 	        'transitionIn'		: 'none',
			// 'transitionOut'		: 'none',
			'type'				: 'iframe'
		}).click(function(){
			$('#fancybox-frame').load(function(){
				 	$('#fancy-loading').hide();
					$("#fancybox-frame").contents().find("a[href*=/]").not("a[target*=top]").attr('target', '_blank');
				});
			$('#fancybox-inner').prepend("<div id='fancy-loading' class='loading'>loading...</div>");
		});
}

function prep_jumpbox(){
	jumpbox_text = $('#jumpbox :selected').text();
	$('#jumpbox :selected').text($.trim($('#jumpbox :selected').text()));
	adjust_jumpbox_width();
	
	$('#jumpbox').focus(function(){
		$('#jumpbox :selected').text(jumpbox_text);				
		//adjust_jumpbox_width();
		 $('#jumpbox').width('auto');
	});
	$('#jumpbox').focusout(function(){
		$('#jumpbox :selected').text($.trim($('#jumpbox :selected').text()));
		$('#jumpbox').css('background','#323232');
		adjust_jumpbox_width();
		
	});
	$('#jumpbox').change(function(){
		$('#jumpbox :selected').text($.trim($('#jumpbox :selected').text()));
		$('#jumpbox').css('background','#323232');
		adjust_jumpbox_width();
	});
}

function adjust_jumpbox_width(){
	jumpbox_width = $('#widthcalc').html($('#jumpbox :selected').text()).width();
	if (jumpbox_width > 10){
		$('#jumpbox').width(jumpbox_width + 35);
	}
}

function show_fancybox(url,message){
	$.fancybox({
					'width'				: '90%',
				'height'			: '95%',
		        'autoScale'     	: false,
		        'transitionIn'		: 'none',
				'transitionOut'		: 'none',
				'type'				: 'iframe',
				'href'				: url
		});
		
	$('#fancybox-frame').load(function(){
		 	$('#fancy-loading').hide();
			$("#fancybox-frame").contents().find("a[href*=/]").not("a[target*=top]").attr('target', '_blank');
		});
	$('#fancybox-inner').prepend("<div id='fancy-loading' class='loading'>" + message + "</div>");
}

function checkAll (id, checked) {
     $("form#" + id + " INPUT[type='checkbox']").attr('checked', checked);
}

function toggleCheckboxesBySelector(selector) {
	boxes = $$(selector);
	var all_checked = true;
	for (i = 0; i < boxes.length; i++) { if (boxes[i].checked == false) { all_checked = false; } }
	for (i = 0; i < boxes.length; i++) { boxes[i].checked = !all_checked; }
}

function showAndScrollTo(id, focus) {
	$('#' + id).show();
	if (focus!=null) { $('#' + focus).focus(); }
	$('#' + focus).parent().scrollTo('#' + focus);
}

function toggleRowGroup(el) {
	var tr = Element.up(el, 'tr');
	var n = Element.next(tr);
	tr.toggleClassName('open');
	while (n != undefined && !n.hasClassName('group')) {
		Element.toggle(n);
		n = Element.next(n);
	}
}

function toggleFieldset(el) {
	var fieldset = Element.up(el, 'fieldset');
	fieldset.toggleClassName('collapsed');
	Effect.toggle(fieldset.down('div'), 'slide', {duration:0.2});
}

var fileFieldCount = 1;

function addFileField() {
    if (fileFieldCount >= 10) return false;
    fileFieldCount++;
    var f = document.createElement("input");
    f.type = "file";
    f.name = "attachments[" + fileFieldCount + "][file]";
    f.size = 30;
    var d = document.createElement("input");
    d.type = "text";
    d.name = "attachments[" + fileFieldCount + "][description]";
    d.size = 60;
    
    p = document.getElementById("attachments_fields");
    p.appendChild(document.createElement("br"));
    p.appendChild(f);
    p.appendChild(d);
}

function showTab(name) {
	$('.tab-content').hide();
	$('.tab-top').removeClass("selected");
	$('#tab-content-' + name).show();
	$('#tab-' + name).addClass("selected");
	return false;
}

function moveTabRight(el) {
	var lis = Element.up(el, 'div.tabs').down('ul').childElements();
	var tabsWidth = 0;
	var i;
	for (i=0; i<lis.length; i++) {
		if (lis[i].visible()) {
			tabsWidth += lis[i].getWidth() + 6;
		}
	}
	if (tabsWidth < Element.up(el, 'div.tabs').getWidth() - 60) {
		return;
	}
	i=0;
	while (i<lis.length && !lis[i].visible()) {
		i++;
	}
	lis[i].hide();
}

function moveTabLeft(el) {
	var lis = Element.up(el, 'div.tabs').down('ul').childElements();
	var i = 0;
	while (i<lis.length && !lis[i].visible()) {
		i++;
	}
	if (i>0) {
		lis[i-1].show();
	}
}

function displayTabsButtons() {
	var lis;
	var tabsWidth = 0;
	var i;
	$$('div.tabs').each(function(el) {
		lis = el.down('ul').childElements();
		for (i=0; i<lis.length; i++) {
			if (lis[i].visible()) {
				tabsWidth += lis[i].getWidth() + 6;
			}
		}
		if ((tabsWidth < el.getWidth() - 60) && (lis[0].visible())) {
			el.down('div.tabs-buttons').hide();
		} else {
			el.down('div.tabs-buttons').show();
		}
	});
}

function setPredecessorFieldsVisibility() {
    relationType = $('relation_relation_type');
    if (relationType && (relationType.value == "precedes" || relationType.value == "follows")) {
        Element.show('predecessor_fields');
    } else {
        Element.hide('predecessor_fields');
    }
}

function collapseScmEntry(id) {
    var els = document.getElementsByClassName(id, 'browser');
	for (var i = 0; i < els.length; i++) {
	   if (els[i].hasClassName('open')) {
	       collapseScmEntry(els[i].id);
	   }
       Element.hide(els[i]);
    }
    $(id).removeClassName('open');
}

function expandScmEntry(id) {
    var els = document.getElementsByClassName(id, 'browser');
	for (var i = 0; i < els.length; i++) {
       Element.show(els[i]);
       if (els[i].hasClassName('loaded') && !els[i].hasClassName('collapsed')) {
            expandScmEntry(els[i].id);
       }
    }
    $(id).addClassName('open');
}

function scmEntryClick(id) {
    el = $(id);
    if (el.hasClassName('open')) {
        collapseScmEntry(id);
        el.addClassName('collapsed');
        return false;
    } else if (el.hasClassName('loaded')) {
        expandScmEntry(id);
        el.removeClassName('collapsed');
        return false;
    }
    if (el.hasClassName('loading')) {
        return false;
    }
    el.addClassName('loading');
    return true;
}

function scmEntryLoaded(id) {
    Element.addClassName(id, 'open');
    Element.addClassName(id, 'loaded');
    Element.removeClassName(id, 'loading');
}

function randomKey(size) {
	var chars = new Array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z');
	var key = '';
	for (i = 0; i < size; i++) {
  	key += chars[Math.floor(Math.random() * chars.length)];
	}
	return key;
}

//TODO: replace this with jquery alternative
// /* shows and hides ajax indicator */
// Ajax.Responders.register({
//     onCreate: function(){
//         if ($('ajax-indicator') && Ajax.activeRequestCount > 0) {
//             Element.show('ajax-indicator');
//         }
//     },
//     onComplete: function(){
//         if ($('ajax-indicator') && Ajax.activeRequestCount == 0) {
//             Element.hide('ajax-indicator');
//         }
//     }
// });

$(document).ajaxStart(function() {
              $('#ajax-indicator').show();
 });
$(document).ajaxStop(function() {
              $('#ajax-indicator').hide();
});

$(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined") return;
  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
  if (settings.type == 'GET') return; // Don't add anything to a get request let IE turn it into a POST.

  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});

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
  // });
  
  return url;
}

//
// Html encode the strings by escaping the &, <, > and " characters
// with their equivalent html counter parts
//
function h(s) {
  var escaped = s;  
  escaped = escaped.replace(/\r\n/g, "xxxxxx11");
  escaped = escaped.replace(/\n/g, "xxxxxx11");
  escaped = escaped.replace(/<br>/g, "xxxxxx11");
  escaped = escaped.replace(/&/g, "&amp;");
  escaped = escaped.replace(/</g, "&lt;");
  escaped = escaped.replace(/>/g, "&gt;");
  escaped = escaped.replace(/\"/g, "&quot;");
  escaped = escaped.replace(/xxxxxx11/g, "\r\n");

  return escaped;
}

function text_only(text){
	text = "<p>" + text + "</p>";
	text = $(text).text();
	return text;
}


function display_sparks(){
	$('.spark').each(function(){
	$(this).show();
	
	if(!$(this).attr('max')){
		return;
	}
	
	var max = parseFloat($(this).attr('max'));
	if (max > 15){
		max = 15;
	}
	if (max == 0){
		max = 1;
	}
	
	$(this).sparkline('html', {type: 'bar' , barColor: 'grey', chartRangeMax: max, height: 15});

	if ($(this).is(":visible")){
		$(this).removeAttr("max"); //so we don't sparkline it again		
	}

	
	// $(this).removeClass("spark");
	
	// if (isNaN(max)){
	// 		$(this).sparkline('html', {type: 'bar' , barColor: 'grey'});
	// 	}
	// 	else{
	// 		$(this).sparkline('html', {type: 'bar' , barColor: 'grey', height: max});
	// 	}
	});
}

//hides right column, and expands left one if right column is empty
// function hide_empty_right_column(){
// 	if ($('.gt-right-col').html().length < 100){
// 		$('.gt-right-col').hide();
// 		$('.gt-left-col').width('100%');
// 	}
// }

function humane_date(date_str){
		
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

      var dt = new Date,
          seconds = ((dt - new Date(date_str)) / 1000),
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


function promptToRemote(text, param, url) {
    value = prompt(text + ':');
    if (value) {
        new Ajax.Request(url + '?' + param + '=' + encodeURIComponent(value), {asynchronous:true, evalScripts:true});
        return false;
    }
}

//param must start with &
function send_remote(url,param,note){
	top.send_remote(url,param,note)
	// top.$.ajax({
	//    type: "POST",
	//    dataType: "json",
	//    url: url,
	//    data: '&note=' + note + param,
	// 	timeout: 30000 //30 seconds
	//  });
}

function comment_prompt_to_remote(dataId,title,message,param,url,required){

	var content = '';
	var note = "$('#prompt_comment_" + dataId + "').val()" ;
	content = content + '<div id="comment_prompt"><h2>' + title + '</h2><br>';
	if (message){
		content = content + message + '<br><br>';
	}
        content = content + '<p><textarea id="prompt_comment_' + dataId + '" class="comment_prompt_text" rows="10" ></textarea></p><br>';
		content = content + '<p>';
        content = content + '<input type="submit" onclick="$.fancybox.close();send_remote(\'' + url + '\',\'' + param + '\',' + note + ');" value="Submit"></input>';
		if (!required){
        	content = content + '<input type="submit" onclick="$.fancybox.close();send_remote(\'' + url + '\',\'' + param + '\',\'\');" value="No Comment"></input>';
		}
        content = content + '<input type="submit" onclick="$.fancybox.close();return false;" value="Cancel"></input>';
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

	$('#prompt_comment_' + dataId).focus();
}



$.fn.mybubbletip = function(tip, options) {

		var _this = $(this);

		var _options = {
			positionAt: 'element', // element | body | mouse
			positionAtElement: _this,
			offsetTop: 0,
			offsetLeft: 0,
			deltaPosition: 0,
			deltaDirection: 'up', // direction: up | down | left | right
			// animationDuration: 250,
			// animationEasing: 'swing', // linear | swing
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

(function($) {
	  $.fn.getGravatar = function(options) {
	    //debug(this);
	    // build main options before element iteration
	    var opts = $.extend({}, $.fn.getGravatar.defaults, options);
	    // iterate and reformat each matched element
	    return this.each(function() {
	      $this = $(this);
	      // build element specific options
  	      	var o = $.meta ? $.extend({}, opts, $this.data()) : opts;
			var t = "";
			//check to see if we're working with an text input first
			      if($this.is("input[type='text']")){
			//do an initial check of the value
			$.fn.getGravatar.getUrl(o, $this.val());

			//do our ajax call for the MD5 hash every time a key is released
			$this.keyup(function(){
			clearTimeout(t);
			var email = $this.val();
			t = setTimeout(function(){$.fn.getGravatar.getUrl(o, email);}, 500);
		});
		}
    });
  };
  //
  // define and expose our functions
  //
$.fn.getGravatar.getUrl = function(o, email){
//call the start function if in use
if(o.start) o.start($this);

//call MD5 function
id = email;
// id = $.fn.getGravatar.md5(email);
var gravatar_url = "https://secure.gravatar.com/avatar.php?gravatar_id="+id+"&size="+o.avatarSize;
//call our function to output the avatar to the container
    $.fn.getGravatar.output(o.avatarContainer, gravatar_url, o.stop);
}
  $.fn.getGravatar.output = function(avatarContainer, gravatar_url, stop) {
//replace the src of our avatar container with the gravatar url
$(avatarContainer).attr("src", gravatar_url);
$(avatarContainer).show();
if(stop) stop();
  };
  $.fn.getGravatar.md5 = function(str) {
      // Calculate the md5 hash of a string
      //
      // version: 909.322
      // discuss at: http://phpjs.org/functions/md5
      // + original by: Webtoolkit.info (http://www.webtoolkit.info/)
      // + namespaced by: Michael White (http://getsprink.com)
      // + tweaked by: Jack
      // + improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
      // + input by: Brett Zamir (http://brett-zamir.me)
      // + bugfixed by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
      // - depends on: utf8_encode
      // * example 1: md5('Kevin van Zonneveld');
      // * returns 1: '6e658d4bfcb59cc13f96c14450ac40b9'
      var xl;

      var rotateLeft = function (lValue, iShiftBits) {
          return (lValue<<iShiftBits) | (lValue>>>(32-iShiftBits));
      };

      var addUnsigned = function (lX,lY) {
          var lX4,lY4,lX8,lY8,lResult;
          lX8 = (lX & 0x80000000);
          lY8 = (lY & 0x80000000);
          lX4 = (lX & 0x40000000);
          lY4 = (lY & 0x40000000);
          lResult = (lX & 0x3FFFFFFF)+(lY & 0x3FFFFFFF);
          if (lX4 & lY4) {
              return (lResult ^ 0x80000000 ^ lX8 ^ lY8);
          }
          if (lX4 | lY4) {
              if (lResult & 0x40000000) {
                  return (lResult ^ 0xC0000000 ^ lX8 ^ lY8);
              } else {
                  return (lResult ^ 0x40000000 ^ lX8 ^ lY8);
              }
          } else {
              return (lResult ^ lX8 ^ lY8);
          }
      };

      var _F = function (x,y,z) { return (x & y) | ((~x) & z); };
      var _G = function (x,y,z) { return (x & z) | (y & (~z)); };
      var _H = function (x,y,z) { return (x ^ y ^ z); };
      var _I = function (x,y,z) { return (y ^ (x | (~z))); };

      var _FF = function (a,b,c,d,x,s,ac) {
          a = addUnsigned(a, addUnsigned(addUnsigned(_F(b, c, d), x), ac));
          return addUnsigned(rotateLeft(a, s), b);
      };

      var _GG = function (a,b,c,d,x,s,ac) {
          a = addUnsigned(a, addUnsigned(addUnsigned(_G(b, c, d), x), ac));
          return addUnsigned(rotateLeft(a, s), b);
      };

      var _HH = function (a,b,c,d,x,s,ac) {
          a = addUnsigned(a, addUnsigned(addUnsigned(_H(b, c, d), x), ac));
          return addUnsigned(rotateLeft(a, s), b);
      };

      var _II = function (a,b,c,d,x,s,ac) {
          a = addUnsigned(a, addUnsigned(addUnsigned(_I(b, c, d), x), ac));
          return addUnsigned(rotateLeft(a, s), b);
      };

      var convertToWordArray = function (str) {
          var lWordCount;
          var lMessageLength = str.length;
          var lNumberOfWords_temp1=lMessageLength + 8;
          var lNumberOfWords_temp2=(lNumberOfWords_temp1-(lNumberOfWords_temp1 % 64))/64;
          var lNumberOfWords = (lNumberOfWords_temp2+1)*16;
          var lWordArray=new Array(lNumberOfWords-1);
          var lBytePosition = 0;
          var lByteCount = 0;
          while ( lByteCount < lMessageLength ) {
              lWordCount = (lByteCount-(lByteCount % 4))/4;
              lBytePosition = (lByteCount % 4)*8;
              lWordArray[lWordCount] = (lWordArray[lWordCount] | (str.charCodeAt(lByteCount)<<lBytePosition));
              lByteCount++;
          }
          lWordCount = (lByteCount-(lByteCount % 4))/4;
          lBytePosition = (lByteCount % 4)*8;
          lWordArray[lWordCount] = lWordArray[lWordCount] | (0x80<<lBytePosition);
          lWordArray[lNumberOfWords-2] = lMessageLength<<3;
          lWordArray[lNumberOfWords-1] = lMessageLength>>>29;
          return lWordArray;
      };

      var wordToHex = function (lValue) {
          var wordToHexValue="",wordToHexValue_temp="",lByte,lCount;
          for (lCount = 0;lCount<=3;lCount++) {
              lByte = (lValue>>>(lCount*8)) & 255;
              wordToHexValue_temp = "0" + lByte.toString(16);
              wordToHexValue = wordToHexValue + wordToHexValue_temp.substr(wordToHexValue_temp.length-2,2);
          }
          return wordToHexValue;
      };

      var x=[],
          k,AA,BB,CC,DD,a,b,c,d,
          S11=7, S12=12, S13=17, S14=22,
          S21=5, S22=9 , S23=14, S24=20,
          S31=4, S32=11, S33=16, S34=23,
          S41=6, S42=10, S43=15, S44=21;

      str = $.fn.getGravatar.utf8_encode(str);
      x = convertToWordArray(str);
      a = 0x67452301; b = 0xEFCDAB89; c = 0x98BADCFE; d = 0x10325476;
  
      xl = x.length;
      for (k=0;k<xl;k+=16) {
          AA=a; BB=b; CC=c; DD=d;
          a=_FF(a,b,c,d,x[k+0], S11,0xD76AA478);
          d=_FF(d,a,b,c,x[k+1], S12,0xE8C7B756);
          c=_FF(c,d,a,b,x[k+2], S13,0x242070DB);
          b=_FF(b,c,d,a,x[k+3], S14,0xC1BDCEEE);
          a=_FF(a,b,c,d,x[k+4], S11,0xF57C0FAF);
          d=_FF(d,a,b,c,x[k+5], S12,0x4787C62A);
          c=_FF(c,d,a,b,x[k+6], S13,0xA8304613);
          b=_FF(b,c,d,a,x[k+7], S14,0xFD469501);
          a=_FF(a,b,c,d,x[k+8], S11,0x698098D8);
          d=_FF(d,a,b,c,x[k+9], S12,0x8B44F7AF);
          c=_FF(c,d,a,b,x[k+10],S13,0xFFFF5BB1);
          b=_FF(b,c,d,a,x[k+11],S14,0x895CD7BE);
          a=_FF(a,b,c,d,x[k+12],S11,0x6B901122);
          d=_FF(d,a,b,c,x[k+13],S12,0xFD987193);
          c=_FF(c,d,a,b,x[k+14],S13,0xA679438E);
          b=_FF(b,c,d,a,x[k+15],S14,0x49B40821);
          a=_GG(a,b,c,d,x[k+1], S21,0xF61E2562);
          d=_GG(d,a,b,c,x[k+6], S22,0xC040B340);
          c=_GG(c,d,a,b,x[k+11],S23,0x265E5A51);
          b=_GG(b,c,d,a,x[k+0], S24,0xE9B6C7AA);
          a=_GG(a,b,c,d,x[k+5], S21,0xD62F105D);
          d=_GG(d,a,b,c,x[k+10],S22,0x2441453);
          c=_GG(c,d,a,b,x[k+15],S23,0xD8A1E681);
          b=_GG(b,c,d,a,x[k+4], S24,0xE7D3FBC8);
          a=_GG(a,b,c,d,x[k+9], S21,0x21E1CDE6);
          d=_GG(d,a,b,c,x[k+14],S22,0xC33707D6);
          c=_GG(c,d,a,b,x[k+3], S23,0xF4D50D87);
          b=_GG(b,c,d,a,x[k+8], S24,0x455A14ED);
          a=_GG(a,b,c,d,x[k+13],S21,0xA9E3E905);
          d=_GG(d,a,b,c,x[k+2], S22,0xFCEFA3F8);
          c=_GG(c,d,a,b,x[k+7], S23,0x676F02D9);
          b=_GG(b,c,d,a,x[k+12],S24,0x8D2A4C8A);
          a=_HH(a,b,c,d,x[k+5], S31,0xFFFA3942);
          d=_HH(d,a,b,c,x[k+8], S32,0x8771F681);
          c=_HH(c,d,a,b,x[k+11],S33,0x6D9D6122);
          b=_HH(b,c,d,a,x[k+14],S34,0xFDE5380C);
          a=_HH(a,b,c,d,x[k+1], S31,0xA4BEEA44);
          d=_HH(d,a,b,c,x[k+4], S32,0x4BDECFA9);
          c=_HH(c,d,a,b,x[k+7], S33,0xF6BB4B60);
          b=_HH(b,c,d,a,x[k+10],S34,0xBEBFBC70);
          a=_HH(a,b,c,d,x[k+13],S31,0x289B7EC6);
          d=_HH(d,a,b,c,x[k+0], S32,0xEAA127FA);
          c=_HH(c,d,a,b,x[k+3], S33,0xD4EF3085);
          b=_HH(b,c,d,a,x[k+6], S34,0x4881D05);
          a=_HH(a,b,c,d,x[k+9], S31,0xD9D4D039);
          d=_HH(d,a,b,c,x[k+12],S32,0xE6DB99E5);
          c=_HH(c,d,a,b,x[k+15],S33,0x1FA27CF8);
          b=_HH(b,c,d,a,x[k+2], S34,0xC4AC5665);
          a=_II(a,b,c,d,x[k+0], S41,0xF4292244);
          d=_II(d,a,b,c,x[k+7], S42,0x432AFF97);
          c=_II(c,d,a,b,x[k+14],S43,0xAB9423A7);
          b=_II(b,c,d,a,x[k+5], S44,0xFC93A039);
          a=_II(a,b,c,d,x[k+12],S41,0x655B59C3);
          d=_II(d,a,b,c,x[k+3], S42,0x8F0CCC92);
          c=_II(c,d,a,b,x[k+10],S43,0xFFEFF47D);
          b=_II(b,c,d,a,x[k+1], S44,0x85845DD1);
          a=_II(a,b,c,d,x[k+8], S41,0x6FA87E4F);
          d=_II(d,a,b,c,x[k+15],S42,0xFE2CE6E0);
          c=_II(c,d,a,b,x[k+6], S43,0xA3014314);
          b=_II(b,c,d,a,x[k+13],S44,0x4E0811A1);
          a=_II(a,b,c,d,x[k+4], S41,0xF7537E82);
          d=_II(d,a,b,c,x[k+11],S42,0xBD3AF235);
          c=_II(c,d,a,b,x[k+2], S43,0x2AD7D2BB);
          b=_II(b,c,d,a,x[k+9], S44,0xEB86D391);
          a=addUnsigned(a,AA);
          b=addUnsigned(b,BB);
          c=addUnsigned(c,CC);
          d=addUnsigned(d,DD);
      }

      var temp = wordToHex(a)+wordToHex(b)+wordToHex(c)+wordToHex(d);

      return temp.toLowerCase();
  }
  $.fn.getGravatar.utf8_encode = function ( argString ) {
      // Encodes an ISO-8859-1 string to UTF-8
      //
      // version: 909.322
      // discuss at: http://phpjs.org/functions/utf8_encode
      // + original by: Webtoolkit.info (http://www.webtoolkit.info/)
      // + improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
      // + improved by: sowberry
      // + tweaked by: Jack
      // + bugfixed by: Onno Marsman
      // + improved by: Yves Sucaet
      // + bugfixed by: Onno Marsman
      // + bugfixed by: Ulrich
      // * example 1: utf8_encode('Kevin van Zonneveld');
      // * returns 1: 'Kevin van Zonneveld'
      var string = (argString+''); // .replace(/\r\n/g, "\n").replace(/\r/g, "\n");

      var utftext = "";
      var start, end;
      var stringl = 0;

      start = end = 0;
      stringl = string.length;
      for (var n = 0; n < stringl; n++) {
          var c1 = string.charCodeAt(n);
          var enc = null;

          if (c1 < 128) {
              end++;
          } else if (c1 > 127 && c1 < 2048) {
              enc = String.fromCharCode((c1 >> 6) | 192) + String.fromCharCode((c1 & 63) | 128);
          } else {
              enc = String.fromCharCode((c1 >> 12) | 224) + String.fromCharCode(((c1 >> 6) & 63) | 128) + String.fromCharCode((c1 & 63) | 128);
          }
          if (enc !== null) {
              if (end > start) {
                  utftext += string.substring(start, end);
              }
              utftext += enc;
              start = end = n+1;
          }
      }

      if (end > start) {
          utftext += string.substring(start, string.length);
      }

      return utftext;
  }
  //
  // plugin defaults
  //
  $.fn.getGravatar.defaults = {
    fallback: '',
avatarSize: 50,
avatarContainer: '#gravatar',
start: null,
stop: null
  };
})(jQuery);

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
				animationDuration: 0,
				// animationEasing: 'swing', // linear | swing
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


			
			show_tip();



		//		return false;
			$('.bubbletip').bind('mouseover',function(){
				mouse_over_bubble = true;
			});
			
			$('.bubbletip').bind('mouseout', function() {
							mouse_over_bubble = false; //BUGBUG: change to false 
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
				_wrapper.width(_tip.width() + 66);
				
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
					_tip.hide();	
					_wrapper.hide();			
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
				
				// if ((_calc.top + _wrapper.height()) > $(window).height()){
				//  	create_wrapper(true);
				//   	_calc.top = $(window).height() - _wrapper.height();
				// }

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

	jQuery.fn.texthighlight = function(pat) {
	 function innerHighlight(node, pat) {
	  var skip = 0;
	  if (node.nodeType == 3) {
	   var pos = node.data.toUpperCase().indexOf(pat);
	   if (pos >= 0) {
	    var spannode = document.createElement('span');
	    spannode.className = 'search-highlight';
	    var middlebit = node.splitText(pos);
	    var endbit = middlebit.splitText(pat.length);
	    var middleclone = middlebit.cloneNode(true);
	    spannode.appendChild(middleclone);
	    middlebit.parentNode.replaceChild(spannode, middlebit);
	    skip = 1;
	   }
	  }
	  else if (node.nodeType == 1 && node.childNodes && !/(script|style)/i.test(node.tagName)) {
	   for (var i = 0; i < node.childNodes.length; ++i) {
	    i += innerHighlight(node.childNodes[i], pat);
	   }
	  }
	  return skip;
	 }
	 return this.each(function() {
	  innerHighlight(this, pat.toUpperCase());
	 });
	};

	jQuery.fn.removeHighlight = function() {
	 return this.find("span.search-highlight").each(function() {
	  this.parentNode.firstChild.nodeName;
	  with (this.parentNode) {
	   replaceChild(this.firstChild, this);
	   normalize();
	  }
	 }).end();
	};


	jQuery.timer = function (interval, callback)
	 {
	 /**
	  *
	  * timer() provides a cleaner way to handle intervals  
	  *
	  *	@usage
	  * $.timer(interval, callback);
	  *
	  *
	  * @example
	  * $.timer(1000, function (timer) {
	  * 	alert("hello");
	  * 	timer.stop();
	  * });
	  * @desc Show an alert box after 1 second and stop
	  * 
	  * @example
	  * var second = false;
	  *	$.timer(1000, function (timer) {
	  *		if (!second) {
	  *			alert('First time!');
	  *			second = true;
	  *			timer.reset(3000);
	  *		}
	  *		else {
	  *			alert('Second time');
	  *			timer.stop();
	  *		}
	  *	});
	  * @desc Show an alert box after 1 second and show another after 3 seconds
	  *
	  * 
	  */

		var interval = interval || 100;

		if (!callback)
			return false;

		_timer = function (interval, callback) {
			this.stop = function () {
				clearInterval(self.id);
			};

			this.internalCallback = function () {
				callback(self);
			};

			this.reset = function (val) {
				if (self.id)
					clearInterval(self.id);

				var val = val || 100;
				this.id = setInterval(this.internalCallback, val);
			};

			this.interval = interval;
			this.id = setInterval(this.internalCallback, this.interval);

			var self = this;
		};

		return new _timer(interval, callback);
	 };
	
	
	/*
	*
	* Copyright (c) 2006-2008 Sam Collett (http://www.texotela.co.uk)
	* Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
	* and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
	*
	* Version 2.2.4
	* Demo: http://www.texotela.co.uk/code/jquery/select/
	*
	* $LastChangedDate: 2008-06-17 17:27:25 +0100 (Tue, 17 Jun 2008) $
	* $Rev: 5727 $
	*
	*/
	;(function(h){h.fn.addOption=function(){var j=function(a,f,c,g){var d=document.createElement("option");d.value=f,d.text=c;var b=a.options;var e=b.length;if(!a.cache){a.cache={};for(var i=0;i<e;i++){a.cache[b[i].value]=i}}if(typeof a.cache[f]=="undefined")a.cache[f]=e;a.options[a.cache[f]]=d;if(g){d.selected=true}};var k=arguments;if(k.length==0)return this;var l=true;var m=false;var n,o,p;if(typeof(k[0])=="object"){m=true;n=k[0]}if(k.length>=2){if(typeof(k[1])=="boolean")l=k[1];else if(typeof(k[2])=="boolean")l=k[2];if(!m){o=k[0];p=k[1]}}this.each(function(){if(this.nodeName.toLowerCase()!="select")return;if(m){for(var a in n){j(this,a,n[a],l)}}else{j(this,o,p,l)}});return this};h.fn.ajaxAddOption=function(c,g,d,b,e){if(typeof(c)!="string")return this;if(typeof(g)!="object")g={};if(typeof(d)!="boolean")d=true;this.each(function(){var f=this;h.getJSON(c,g,function(a){h(f).addOption(a,d);if(typeof b=="function"){if(typeof e=="object"){b.apply(f,e)}else{b.call(f)}}})});return this};h.fn.removeOption=function(){var d=arguments;if(d.length==0)return this;var b=typeof(d[0]);var e,i;if(b=="string"||b=="object"||b=="function"){e=d[0];if(e.constructor==Array){var j=e.length;for(var k=0;k<j;k++){this.removeOption(e[k],d[1])}return this}}else if(b=="number")i=d[0];else return this;this.each(function(){if(this.nodeName.toLowerCase()!="select")return;if(this.cache)this.cache=null;var a=false;var f=this.options;if(!!e){var c=f.length;for(var g=c-1;g>=0;g--){if(e.constructor==RegExp){if(f[g].value.match(e)){a=true}}else if(f[g].value==e){a=true}if(a&&d[1]===true)a=f[g].selected;if(a){f[g]=null}a=false}}else{if(d[1]===true){a=f[i].selected}else{a=true}if(a){this.remove(i)}}});return this};h.fn.sortOptions=function(e){var i=h(this).selectedValues();var j=typeof(e)=="undefined"?true:!!e;this.each(function(){if(this.nodeName.toLowerCase()!="select")return;var c=this.options;var g=c.length;var d=[];for(var b=0;b<g;b++){d[b]={v:c[b].value,t:c[b].text}}d.sort(function(a,f){o1t=a.t.toLowerCase(),o2t=f.t.toLowerCase();if(o1t==o2t)return 0;if(j){return o1t<o2t?-1:1}else{return o1t>o2t?-1:1}});for(var b=0;b<g;b++){c[b].text=d[b].t;c[b].value=d[b].v}}).selectOptions(i,true);return this};h.fn.selectOptions=function(g,d){var b=g;var e=typeof(g);if(e=="object"&&b.constructor==Array){var i=this;h.each(b,function(){i.selectOptions(this,d)})};var j=d||false;if(e!="string"&&e!="function"&&e!="object")return this;this.each(function(){if(this.nodeName.toLowerCase()!="select")return this;var a=this.options;var f=a.length;for(var c=0;c<f;c++){if(b.constructor==RegExp){if(a[c].value.match(b)){a[c].selected=true}else if(j){a[c].selected=false}}else{if(a[c].value==b){a[c].selected=true}else if(j){a[c].selected=false}}}});return this};h.fn.copyOptions=function(g,d){var b=d||"selected";if(h(g).size()==0)return this;this.each(function(){if(this.nodeName.toLowerCase()!="select")return this;var a=this.options;var f=a.length;for(var c=0;c<f;c++){if(b=="all"||(b=="selected"&&a[c].selected)){h(g).addOption(a[c].value,a[c].text)}}});return this};h.fn.containsOption=function(g,d){var b=false;var e=g;var i=typeof(e);var j=typeof(d);if(i!="string"&&i!="function"&&i!="object")return j=="function"?this:b;this.each(function(){if(this.nodeName.toLowerCase()!="select")return this;if(b&&j!="function")return false;var a=this.options;var f=a.length;for(var c=0;c<f;c++){if(e.constructor==RegExp){if(a[c].value.match(e)){b=true;if(j=="function")d.call(a[c],c)}}else{if(a[c].value==e){b=true;if(j=="function")d.call(a[c],c)}}}});return j=="function"?this:b};h.fn.selectedValues=function(){var a=[];this.selectedOptions().each(function(){a[a.length]=this.value});return a};h.fn.selectedTexts=function(){var a=[];this.selectedOptions().each(function(){a[a.length]=this.text});return a};h.fn.selectedOptions=function(){return this.find("option:selected")}})(jQuery);
	
	
	(function($) {
	  $.fn.breakWords = function() {
	    this.each(function() {
	      if(this.nodeType !== 1) { return; }

	      if(this.currentStyle && typeof this.currentStyle.wordBreak === 'string') {
	        //Lazy Function Definition Pattern, Peter's Blog
	        //From http://peter.michaux.ca/article/3556
	        this.runtimeStyle.wordBreak = 'break-all';
	      }
	      else if(document.createTreeWalker) {

	        //Faster Trim in Javascript, Flagrant Badassery
	        //http://blog.stevenlevithan.com/archives/faster-trim-javascript

	        var trim = function(str) {
	          str = str.replace(/^\s\s*/, '');
	          var ws = /\s/,
	          i = str.length;
	          while (ws.test(str.charAt(--i)));
	          return str.slice(0, i + 1);
	        };

	        //Lazy Function Definition Pattern, Peter's Blog
	        //From http://peter.michaux.ca/article/3556

	        //For Opera, Safari, and Firefox
	        var dWalker = document.createTreeWalker(this, NodeFilter.SHOW_TEXT, null, false);
	        var node,s,c = String.fromCharCode('8203');
	        while (dWalker.nextNode()) {
	          node = dWalker.currentNode;
	          //we need to trim String otherwise Firefox will display
	          //incorect text-indent with space characters
			  words = node.nodeValue.split(' ');
			  for (var i = 0; i < words.length; i++){
				if (words[i].length > 15){
					words[i] = trim(words[i].split('').join(c));
				}
			  }
	          node.nodeValue = words.join(' ');
	        }
	      }
	    });

	    return this;
	  };
	})(jQuery);
	
	function wbr(string,length){
		string =  string.replace(/(?:<[^>]+>)|(.{20})/g,'$&<wbr/>');
		return string.replace(/><wbr\/>/,'>');
	}
	

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


(function( $ ){
	
	//Auto complete code for @mentions
	//To attach to a textarea add this class: autocomplete-mentions and the script below
	// <script type="text/javascript">
	// projectId = <%= @project.id %>;
	// </script>
	//or just directly run $('#widget').mentions(projectId);
	//or add a property to the text area autocomplete-mentions-projectid="<%= as.project_id %>"
	// "autocomplete-mentions-projectid" => @project.id

	 function getCaretPosition(e) {    
	     if (typeof e.selectionStart == 'number') {
	         return e.selectionStart;
	     } else if (document.selection) {
	         var range = document.selection.createRange();
	         var rangeLength = range.text.length;
	         range.moveStart('character', -e.value.length);
	         return range.text.length - rangeLength;
	     }
	 };   

	 function setCaretPosition(e, start, end) {
	     if (e.createTextRange) {
	         var r = e.createTextRange();
	         r.moveStart('character', start);
	         r.moveEnd('character', (end || start));
	         r.select();
	     } else if (e.selectionStart) {
	         e.focus();
	         e.setSelectionRange(start, (end || start));
	     }
	 };

	 function getWordBeforeCaretPosition(e) {    
	     var s = e.value;
	     var i = getCaretPosition(e) - 1;
	     while (i >= 0 && s[i] != ' ') {
	         i = i - 1;
	     }             
	     return i + 1;    
	 };

	 function getWordBeforeCaret(e) {  
	   var p = getWordBeforeCaretPosition(e);
	   var c = getCaretPosition(e);  
	   return e.value.substring(p, c);    
	 };

	 function replaceWordBeforeCaret(e, word) {
	     var p = getWordBeforeCaretPosition(e);
	     var c = getCaretPosition(e);        
	     e.value = e.value.substring(0, p) + word + e.value.substring(c);
	     setCaretPosition(e, p + word.length);                     
	 };

  var methods = {
     init : function( options ) {
	
       return this.each(function(){

         var $this = $(this),
            data = $this.data('mentions');

		if (options < 0){
			var projectId = $this.attr("autocomplete-mentions-projectid");
		}
		else{
			var projectId = options;
		}
			$this.bind("keydown", function(event) {
		     if (event.keyCode === $.ui.keyCode.TAB && $(this).data("autocomplete").menu.active ) {
		       event.preventDefault();
		     }
		   	})
		   .autocomplete({
		     minLength: 0,
			 open: function(){
				$(".ui-menu").width('auto');
			},
		     source: function(request, response) {                 
		       var w = getWordBeforeCaret(this.element[0]);  
		       if (w[0] != '@') {
		         this.close();
		         return false;
		       }             

		   		if (typeof community_members[projectId] != "undefined") {
		   			//map the data into a response that will be understood by the autocomplete widget
		   			response($.ui.autocomplete.filter(community_members[projectId], w.substring(1, w.length)));
		   		}
		   		//get the data from the server
		   		else {
		   			$.ajax({
		   				url: "/projects/" + projectId + "/community_members_array",
		   				dataType: "json",
		   				success: function(data) {
		   					//cache the data for later
		   					community_members[projectId] = data;
		   					//map the data into a response that will be understood by the autocomplete widget
		       				response($.ui.autocomplete.filter(community_members[projectId], w.substring(1, w.length)));
		   				}
		   			});
		   		}
		   	},
			delay: 0,
		     position: {
		         my: "left top",
		         at: "right top"
		     },
		     focus: function() {
		       return false;
		     },           
		     search: function(event, ui) {
		       return true;
		     },
		     select: function(event, ui) {             
		       replaceWordBeforeCaret(this, '@' + ui.item.value + ' ');              
		       return false;                   
		     }
		   })
			.data( "autocomplete" )._renderItem = function( ul, item ) {
				return $( "<li></li>" )
					.data( "item.autocomplete", item )
					.append( "<img src='http://gravatar.com/avatar.php?gravatar_id=" + item.mail_hash + "&size=17/>")
					.append( "<a>" + item.label + "</a>" )
					// .append( "<img src='https://secure.gravatar.com/avatar.php?gravatar_id=" + item.mail_hash + "&size=17/>")
					// .append( "<a><img src='http://secure.gravatar.com/avatar.php?gravatar_id=" + item.mail_hash + "&size=17/>" + item.label + "</a>" )
					.appendTo( ul );
			};
		
		//Replace with code below to show gravatars in dropdown. Works only in firefox
		// .data("autocomplete")._renderItem = function( ul, item ) {
		// 		return $( "<li><a><img src='https://secure.gravatar.com/avatar.php?gravatar_id=" + item.mail_hash + "&size=17/>" + item.label + "</a></li>" )
		// 			.data( "item.autocomplete", item )
		// 			.appendTo( ul );
		// 	};
       });
     },
     destroy : function( ) {

       return this.each(function(){

         var $this = $(this),
             data = $this.data('mentions');

         // Namespacing FTW
         $(window).unbind('.mentions');
         data.mentions.remove();
         $this.removeData('mentions');

       })

     }
  };

  $.fn.mentions = function( projectId ) {
   	return methods['init'].apply( this, Array.prototype.slice.call( arguments, 0 ));
  };

})( jQuery );


function bind_autocomplete_mentions(){
	$("input[autocomplete-mentions-projectid]").mentions(-1); 
	$("textarea[autocomplete-mentions-projectid]").mentions(-1); 

	if (typeof projectId != "undefined"){
		$( ".autocomplete-mentions" ).mentions(projectId); 
	}
};

function help_popup(){
	$.fancybox({
	'content'			: $('#help_section_container').html(),
	'padding'		: 0,
	'margin'  : 0,
	'title'      : 'Help Tip'
	// 'transitionIn'	: 'elastic',
	// 'transitionOut'	: 'elastic',
	// 'scrolling' : 'no'
	});	
};
