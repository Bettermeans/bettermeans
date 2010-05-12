/* BetterMeans - Work 2.0
   Copyright (C) 2006-2008  Shereef Bishay */


function initialize(){
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
		});
}

function show_fancybox(url,message){
	////console.log("Fancybox for: " + url);
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
		});
	$('#fancybox-inner').prepend("<div id='fancy-loading' class='loading'>" + message + "</div>");
}

function checkAll (id, checked) {
	var els = Element.descendants(id);
	for (var i = 0; i < els.length; i++) {
    if (els[i].disabled==false) {
      els[i].checked = checked;
    }
	}
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
    var f = $$('div#content .tab-content');
	for(var i=0; i<f.length; i++){
		Element.hide(f[i]);
	}
    var f = $$('div.tabs a');
	for(var i=0; i<f.length; i++){
		Element.removeClassName(f[i], "selected");
	}
	Element.show('tab-content-' + name);
	Element.addClassName('tab-' + name, "selected");
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

function promptToRemote(text, param, url) {
    value = prompt(text + ':');
    if (value) {
        new Ajax.Request(url + '?' + param + '=' + encodeURIComponent(value), {asynchronous:true, evalScripts:true});
        return false;
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
  // });da
  
  return url;
}

//
// Html encode the strings by escaping the &, <, > and " characters
// with their equivalent html counter parts
//
function h(s) {
  var escaped = s;  
  
  escaped = escaped.replace(/&/g, "&amp;");
  escaped = escaped.replace(/</g, "&lt;");
  escaped = escaped.replace(/>/g, "&gt;");
  escaped = escaped.replace(/\"/g, "&quot;");

  return escaped;
}

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


			
			show_tip();



		//		return false;
			$('.bubbletip').bind('mouseover',function(){
				mouse_over_bubble = true;
			});
			
			$('.bubbletip').bind('mouseout', function() {
							mouse_over_bubble = true; //BUGBUG: change to false 
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