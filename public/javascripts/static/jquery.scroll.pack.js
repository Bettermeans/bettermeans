/*-----------------------
* jQuery Plugin: Scroll to Top
* by Craig Wilson, Ph.Creative http://www.ph-creative.com
* 
* Copyright (c) 2009 Ph.Creative Ltd.
* Licensed under the MIT License http://www.opensource.org/licenses/mit-license.php
*
* Description: Adds an unobtrusive "Scroll to Top" link to your page with smooth scrolling.
* For usage instructions and version updates to go http://blog.ph-creative.com/post/jquery-plugin-scroll-to-top-v3.aspx
* 
* Version: 3.0, 29/10/2009
-----------------------*/
$(function(){$.fn.scrollToTop=function(options){if(options.speed){var speed=options.speed;}else{var speed="slow";}if(options.ease){var ease=options.ease;}else{var ease="jswing";}if(options.start){var start=options.start;}else{var start="0";}var scrollDiv=$(this);$(this).hide().removeAttr("href");if($(window).scrollTop()>start){$(this).fadeIn("slow");}$(window).scroll(function(){if($(window).scrollTop()>start){$(scrollDiv).fadeIn("slow");}else{$(scrollDiv).fadeOut("slow");}});$(this).click(function(event){$("html, body").animate({scrollTop:"0px"},speed,ease);});}});