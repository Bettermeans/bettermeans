$(document).ready(function() {
		// Read More Buttons
    $('a.readmore').append('<span class="hover"></span>');  
           // span whose opacity will animate when mouse hovers.  
           $('a.readmore').hover(  
     function() {  			 
			$('.hover', this).stop().animate({ 'opacity': 0 }, 300,'easeOutSine')},  
     function() {  
           $('.hover', this).stop().animate({ 'opacity': 1 }, 300, 'easeOutQuad') }); 
		   
		 // Pricing Buttons  
	 $('a.pricing-buttom').prepend('<a class="phover"></a>');  
           // span whose opacity will animate when mouse hovers.  
           $('a.pricing-buttom').hover(  
     function() {  
			 
			$('.phover', this).stop().animate({'opacity': 0 }, 300,'easeOutSine')},  
     function() {  
           $('.phover', this).stop().animate({'opacity': 1}, 300, 'easeOutQuad')});	   
		
		
		// The main menu
		 $('ul.sf-menu').superfish({ 
            delay:       1000,                            // one second delay on mouseout 
            animation:   {opacity:'show',height:'show'},  // fade-in and slide-down animation 
            speed:       'slow',                          // faster animation speed 
            autoArrows:  false,                           // disable generation of arrow mark-up 
            dropShadows: false                            // disable drop shadows 
        }); 
});