/*

  GalleryView - jQuery Content Gallery Plugin
  Author:     Jack Anderson
  Version:    1.1 (April 5, 2009)
  Documentation:   http://www.spaceforaname.com/jquery/galleryview/

  Please use this development script if you intend to make changes to the
  plugin code.  For production sites, please use jquery.galleryview-1.0.1-pack.js.

*/
(function($){
  $.fn.galleryView = function(options) {
    var opts = $.extend($.fn.galleryView.defaults,options);

    var id;
    var iterator = 0;
    var gallery_width;
    var gallery_height;
    var frame_margin = 10;
    var strip_width;
    var wrapper_width;
    var item_count = 0;
    var slide_method;
    var img_path;
    var paused = false;
    var frame_caption_size = 20;
    var frame_margin_top = 5;
    var pointer_width = 2;

    //Define jQuery objects for reuse
    var j_gallery;
    var j_filmstrip;
    var j_frames;
    var j_panels;
    var j_pointer;

/************************************************/
/*  Plugin Methods                */
/************************************************/
    function showItem(i) {
      //Disable next/prev buttons until transition is complete
      $('img.nav-next').unbind('click');
      $('img.nav-prev').unbind('click');
      j_frames.unbind('click');
      if(has_panels) {
        if(opts.fade_panels) {
          //Fade out all panels and fade in target panel
          j_panels.fadeOut(opts.transition_speed).eq(i%item_count).fadeIn(opts.transition_speed,function(){
            if(!has_filmstrip) {
              $('img.nav-prev').click(showPrevItem);
              $('img.nav-next').click(showNextItem);
            }
          });
        }
      }

      if(has_filmstrip) {
        //Slide either pointer or filmstrip, depending on transition method
        if(slide_method=='strip') {
          //Stop filmstrip if it's currently in motion
          j_filmstrip.stop();

          //Determine distance between pointer (eventual destination) and target frame
          var distance = getPos(j_frames[i]).left - (getPos(j_pointer[0]).left+2);
          var leftstr = (distance>=0?'-=':'+=')+Math.abs(distance)+'px';

          //Animate filmstrip and slide target frame under pointer
          //If target frame is a duplicate, jump back to 'original' frame
          j_filmstrip.animate({
            'left':leftstr
          },opts.transition_speed,opts.easing,function(){
            //Always ensure that there are a sufficient number of hidden frames on either
            //side of the filmstrip to avoid empty frames
            if(i>item_count) {
              i = i%item_count;
              iterator = i;
              j_filmstrip.css('left','-'+((opts.frame_width+frame_margin)*i)+'px');
            } else if (i<=(item_count-strip_size)) {
              i = (i%item_count)+item_count;
              iterator = i;
              j_filmstrip.css('left','-'+((opts.frame_width+frame_margin)*i)+'px');
            }

            if(!opts.fade_panels) {
              j_panels.hide().eq(i%item_count).show();
            }
            $('img.nav-prev').click(showPrevItem);
            $('img.nav-next').click(showNextItem);
            enableFrameClicking();
          });
        } else if(slide_method=='pointer') {
          //Stop pointer if it's currently in motion
          j_pointer.stop();
          //Get position of target frame
          var pos = getPos(j_frames[i]);
          //Slide the pointer over the target frame
          j_pointer.animate({
            'left':(pos.left-2+'px')
          },opts.transition_speed,opts.easing,function(){
            if(!opts.fade_panels) {
              j_panels.hide().eq(i%item_count).show();
            }
            $('img.nav-prev').click(showPrevItem);
            $('img.nav-next').click(showNextItem);
            enableFrameClicking();
          });
        }

        if($('a',j_frames[i])[0]) {
          j_pointer.unbind('click').click(function(){
            var a = $('a',j_frames[i]).eq(0);
            if(a.attr('target')=='_blank') {window.open(a.attr('href'));}
            else {location.href = a.attr('href');}
          });
        }
      }
    };
    function showNextItem() {
      $(document).stopTime("transition");
      if(++iterator==j_frames.length) {iterator=0;}
      showItem(iterator);
      $(document).everyTime(opts.transition_interval,"transition",function(){
        showNextItem();
      });
    };
    function showPrevItem() {
      $(document).stopTime("transition");
      if(--iterator<0) {iterator = item_count-1;}
      //alert(iterator);
      showItem(iterator);
      $(document).everyTime(opts.transition_interval,"transition",function(){
        showNextItem();
      });
    };
    function getPos(el) {
      var left = 0, top = 0;
      var el_id = el.id;
      if(el.offsetParent) {
        do {
          left += el.offsetLeft;
          top += el.offsetTop;
        } while(el = el.offsetParent);
      }
      //If we want the position of the gallery itself, return it
      if(el_id == id) {return {'left':left,'top':top};}
      //Otherwise, get position of element relative to gallery
      else {
        var gPos = getPos(j_gallery[0]);
        var gLeft = gPos.left;
        var gTop = gPos.top;

        return {'left':left-gLeft,'top':top-gTop};
      }
    };
    function enableFrameClicking() {
      j_frames.each(function(i){
        //If there isn't a link in this frame, set up frame to slide on click
        //Frames with links will handle themselves
        if($('a',this).length==0) {
          $(this).click(function(){
            $(document).stopTime("transition");
            showItem(i);
            iterator = i;
            $(document).everyTime(opts.transition_interval,"transition",function(){
              showNextItem();
            });
          });
        }
      });
    };

    function buildPanels() {
      //If there are panel captions, add overlay divs
      if($('.panel-overlay').length>0) {j_panels.append('<div class="overlay"></div>');}

      if(!has_filmstrip) {
        //Add navigation buttons
        $('<img />').addClass('nav-next').attr('src',img_path+opts.nav_theme+'/next.png').appendTo(j_gallery).css({
          'position':'absolute',
          'zIndex':'1100',
          'cursor':'pointer',
          'top':((opts.panel_height-22)/2)+'px',
          'right':'10px',
          'display':'none'
        }).click(showNextItem);
        $('<img />').addClass('nav-prev').attr('src',img_path+opts.nav_theme+'/prev.png').appendTo(j_gallery).css({
          'position':'absolute',
          'zIndex':'1100',
          'cursor':'pointer',
          'top':((opts.panel_height-22)/2)+'px',
          'left':'10px',
          'display':'none'
        }).click(showPrevItem);

        $('<img />').addClass('nav-overlay').attr('src',img_path+opts.nav_theme+'/panel-nav-next.png').appendTo(j_gallery).css({
          'position':'absolute',
          'zIndex':'1099',
          'top':((opts.panel_height-22)/2)-10+'px',
          'right':'0',
          'display':'none'
        });

        $('<img />').addClass('nav-overlay').attr('src',img_path+opts.nav_theme+'/panel-nav-prev.png').appendTo(j_gallery).css({
          'position':'absolute',
          'zIndex':'1099',
          'top':((opts.panel_height-22)/2)-10+'px',
          'left':'0',
          'display':'none'
        });
      }
      j_panels.css({
        'width':(opts.panel_width-parseInt(j_panels.css('paddingLeft').split('px')[0],10)-parseInt(j_panels.css('paddingRight').split('px')[0],10))+'px',
        'height':(opts.panel_height-parseInt(j_panels.css('paddingTop').split('px')[0],10)-parseInt(j_panels.css('paddingBottom').split('px')[0],10))+'px',
        'position':'absolute',
        'top':(opts.filmstrip_position=='top'?(opts.frame_height+frame_margin_top+(opts.show_captions?frame_caption_size:frame_margin_top))+'px':'0px'),
        'left':'0px',
        'overflow':'hidden',
        'background':'white',
        'display':'none'
      });
      $('.panel-overlay',j_panels).css({
        'position':'absolute',
        'zIndex':'999',
        'width':(opts.panel_width-20)+'px',
        'height':opts.overlay_height+'px',
        'top':(opts.overlay_position=='top'?'0':opts.panel_height-opts.overlay_height+'px'),
        'left':'0',
        'padding':'0 10px',
        'color':opts.overlay_text_color,
        'fontSize':opts.overlay_font_size
      });
      $('.panel-overlay a',j_panels).css({
        'color':opts.overlay_text_color,
        'textDecoration':'underline',
        'fontWeight':'bold'
      });
      $('.overlay',j_panels).css({
        'position':'absolute',
        'zIndex':'998',
        'width':opts.panel_width+'px',
        'height':opts.overlay_height+'px',
        'top':(opts.overlay_position=='top'?'0':opts.panel_height-opts.overlay_height+'px'),
        'left':'0',
        'background':opts.overlay_color,
        'opacity':opts.overlay_opacity
      });
      $('.panel iframe',j_panels).css({
        'width':opts.panel_width+'px',
        'height':(opts.panel_height-opts.overlay_height)+'px',
        'border':'0'
      });
    };

    function buildFilmstrip() {
      //Add wrapper to filmstrip to hide extra frames
      j_filmstrip.wrap('<div class="strip_wrapper"></div>');
      if(slide_method=='strip') {
        j_frames.clone().appendTo(j_filmstrip);
        j_frames.clone().appendTo(j_filmstrip);
        j_frames = $('li',j_filmstrip);
      }
      //If captions are enabled, add caption divs and fill with the image titles
      if(opts.show_captions) {
        j_frames.append('<div class="caption"></div>').each(function(i){
          $(this).find('.caption').html($(this).find('img').attr('title'));
        });
      }

      j_filmstrip.css({
        'listStyle':'none',
        'margin':'0',
        'padding':'0',
        'width':strip_width+'px',
        'position':'absolute',
        'zIndex':'900',
        'top':'0',
        'left':'0',
        'height':(opts.frame_height+10)+'px',
        'background':opts.background_color
      });
      j_frames.css({
        'float':'left',
        'position':'relative',
        'height':opts.frame_height+'px',
        'zIndex':'901',
        'marginTop':frame_margin_top+'px',
        'marginBottom':'0px',
        'marginRight':frame_margin+'px',
        'padding':'0',
        'cursor':'pointer'
      });
      $('img',j_frames).css({
        'border':'none'
      });
      $('.strip_wrapper',j_gallery).css({
        'position':'absolute',
        'top':(opts.filmstrip_position=='top'?'0px':opts.panel_height+'px'),
        'left':((gallery_width-wrapper_width)/2)+'px',
        'width':wrapper_width+'px',
        'height':(opts.frame_height+frame_margin_top+(opts.show_captions?frame_caption_size:frame_margin_top))+'px',
        'overflow':'hidden'
      });
      $('.caption',j_gallery).css({
        'position':'absolute',
        'top':opts.frame_height+'px',
        'left':'0',
        'margin':'0',
        'width':opts.frame_width+'px',
        'padding':'0',
        'color':opts.caption_text_color,
        'textAlign':'center',
        'fontSize':'10px',
        'height':frame_caption_size+'px',

        'lineHeight':frame_caption_size+'px'
      });
      var pointer = $('<div></div>');
      pointer.attr('id','pointer').appendTo(j_gallery).css({
         'position':'absolute',
         'zIndex':'1000',
         'cursor':'pointer',
         'top':getPos(j_frames[0]).top-(pointer_width/2)+'px',
         'left':getPos(j_frames[0]).left-(pointer_width/2)+'px',
         'height':opts.frame_height-pointer_width+'px',
         'width':opts.frame_width-pointer_width+'px',
         'border':(has_panels?pointer_width+'px solid '+(opts.nav_theme=='dark'?'black':'white'):'none')
      });
      j_pointer = $('#pointer',j_gallery);
      if(has_panels) {
        var pointerArrow = $('<img />');
        pointerArrow.attr('src',img_path+opts.nav_theme+'/pointer'+(opts.filmstrip_position=='top'?'-down':'')+'.png').appendTo($('#pointer')).css({
          'position':'absolute',
          'zIndex':'1001',
          'top':(opts.filmstrip_position=='bottom'?'-'+(10+pointer_width)+'px':opts.frame_height+'px'),
          'left':((opts.frame_width/2)-10)+'px'
        });
      }

      //If the filmstrip is animating, move the strip to the middle third
      if(slide_method=='strip') {
        j_filmstrip.css('left','-'+((opts.frame_width+frame_margin)*item_count)+'px');
        iterator = item_count;
      }
      //If there's a link under the pointer, enable clicking on the pointer
      if($('a',j_frames[iterator])[0]) {
        j_pointer.click(function(){
          var a = $('a',j_frames[iterator]).eq(0);
          if(a.attr('target')=='_blank') {window.open(a.attr('href'));}
          else {location.href = a.attr('href');}
        });
      }

      //Add navigation buttons
      $('<img />').addClass('nav-next').attr('src',img_path+opts.nav_theme+'/next.png').appendTo(j_gallery).css({
        'position':'absolute',
        'cursor':'pointer',
        'top':(opts.filmstrip_position=='top'?0:opts.panel_height)+frame_margin_top+((opts.frame_height-22)/2)+'px',
        'right':(gallery_width/2)-(wrapper_width/2)-10-22+'px'
      }).click(showNextItem);
      $('<img />').addClass('nav-prev').attr('src',img_path+opts.nav_theme+'/prev.png').appendTo(j_gallery).css({
        'position':'absolute',
        'cursor':'pointer',
        'top':(opts.filmstrip_position=='top'?0:opts.panel_height)+frame_margin_top+((opts.frame_height-22)/2)+'px',
        'left':(gallery_width/2)-(wrapper_width/2)-10-22+'px'
      }).click(showPrevItem);
    };

    //Check mouse to see if it is within the borders of the panel
    //More reliable than 'mouseover' event when elements overlay the panel
    function mouseIsOverPanels(x,y) {
      var pos = getPos(j_gallery[0]);
      var top = pos.top;
      var left = pos.left;
      return x > left && x < left+opts.panel_width && y > top && y < top+opts.panel_height;
    };

/************************************************/
/*  Main Plugin Code              */
/************************************************/
    return this.each(function() {
      j_gallery = $(this);
      //Determine path between current page and filmstrip images
      //Scan script tags and look for path to GalleryView plugin
      $('script').each(function(i){
        var s = $(this);
        if(s.attr('src') && s.attr('src').match(/jquery\.galleryview/)){
          img_path = s.attr('src').split('jquery.galleryview')[0]+'themes/';
        }
      });

      //Hide gallery to prevent Flash of Unstyled Content (FoUC) in IE
      j_gallery.css('visibility','hidden');

      //Assign elements to variables for reuse
      j_filmstrip = $('.filmstrip',j_gallery);
      j_frames = $('li',j_filmstrip);
      j_panels = $('.panel',j_gallery);

      id = j_gallery.attr('id');

      has_panels = j_panels.length > 0;
      has_filmstrip = j_frames.length > 0;

      if(!has_panels) opts.panel_height = 0;

      //Number of frames in filmstrip
      item_count = has_panels?j_panels.length:j_frames.length;

      //Number of frames that can display within the screen's width
      //64 = width of block for navigation button * 2
      //5 = minimum frame margin
      strip_size = has_panels?Math.floor((opts.panel_width-64)/(opts.frame_width+frame_margin)):Math.min(item_count,opts.filmstrip_size);


      /************************************************/
      /*  Determine transition method for filmstrip  */
      /************************************************/
          //If more items than strip size, slide filmstrip
          //Otherwise, slide pointer
          if(strip_size >= item_count) {
            slide_method = 'pointer';
            strip_size = item_count;
          }
          else {slide_method = 'strip';}

      /************************************************/
      /*  Determine dimensions of various elements  */
      /************************************************/

          //Width of gallery block
          gallery_width = has_panels?opts.panel_width:(strip_size*(opts.frame_width+frame_margin))-frame_margin+64;

          //Height of gallery block = screen + filmstrip + captions (optional)
          gallery_height = (has_panels?opts.panel_height:0)+(has_filmstrip?opts.frame_height+frame_margin_top+(opts.show_captions?frame_caption_size:frame_margin_top):0);

          //Width of filmstrip
          if(slide_method == 'pointer') {strip_width = (opts.frame_width*item_count)+(frame_margin*(item_count));}
          else {strip_width = (opts.frame_width*item_count*3)+(frame_margin*(item_count*3));}

          //Width of filmstrip wrapper (to hide overflow)
          wrapper_width = ((strip_size*opts.frame_width)+((strip_size-1)*frame_margin));

      /************************************************/
      /*  Apply CSS Styles              */
      /************************************************/
          j_gallery.css({
            'position':'relative',
            'margin':'0',
            'background':opts.background_color,
            'border':opts.border,
            'width':gallery_width+'px',
            'height':gallery_height+'px'
          });

      /************************************************/
      /*  Build filmstrip and/or panels        */
      /************************************************/
          if(has_filmstrip) {
            buildFilmstrip();
          }
          if(has_panels) {
            buildPanels();
          }


      /************************************************/
      /*  Add events to various elements        */
      /************************************************/
          if(has_filmstrip) enableFrameClicking();



            $().mousemove(function(e){
              if(mouseIsOverPanels(e.pageX,e.pageY)) {
                if(opts.pause_on_hover) {
                  $(document).oneTime(500,"animation_pause",function(){
                    $(document).stopTime("transition");
                    paused=true;
                  });
                }
                if(has_panels && !has_filmstrip) {
                  $('.nav-overlay').fadeIn('fast');
                  $('.nav-next').fadeIn('fast');
                  $('.nav-prev').fadeIn('fast');
                }
              } else {
                if(opts.pause_on_hover) {
                  $(document).stopTime("animation_pause");
                  if(paused) {
                    $(document).everyTime(opts.transition_interval,"transition",function(){
                      showNextItem();
                    });
                    paused = false;
                  }
                }
                if(has_panels && !has_filmstrip) {
                  $('.nav-overlay').fadeOut('fast');
                  $('.nav-next').fadeOut('fast');
                  $('.nav-prev').fadeOut('fast');
                }
              }
            });


      /************************************************/
      /*  Initiate Automated Animation        */
      /************************************************/
          //Show the first panel
          j_panels.eq(0).show();

          //If we have more than one item, begin automated transitions
          if(item_count > 1) {
            $(document).everyTime(opts.transition_interval,"transition",function(){
              showNextItem();
            });
          }

          //Make gallery visible now that work is complete
          j_gallery.css('visibility','visible');
    });
  };

  $.fn.galleryView.defaults = {
    panel_width: 400,
    panel_height: 300,
    frame_width: 80,
    frame_height: 80,
    filmstrip_size: 3,
    overlay_height: 70,
    overlay_font_size: '1em',
    transition_speed: 400,
    transition_interval: 6000,
    overlay_opacity: 0.6,
    overlay_color: 'black',
    background_color: 'black',
    overlay_text_color: 'white',
    caption_text_color: 'white',
    border: '1px solid black',
    nav_theme: 'light',
    easing: 'swing',
    filmstrip_position: 'bottom',
    overlay_position: 'bottom',
    show_captions: false,
    fade_panels: true,
    pause_on_hover: false
  };
})(jQuery);
