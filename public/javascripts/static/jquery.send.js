jQuery(document).ready(function(){
	
	$('#contact-form').submit(function(){
	
		var action = $(this).attr('action');
		
		$("#message").slideUp(750,function() {
		$('#message').hide();
		
 		$('#contact-submit')
			.after('<img src="/images/ajax-loader.gif" class="loader" />')
			.attr('disabled','disabled');
		
		$.post(action, { 
			name: $('#name').val(),
			email: $('#email').val(),
			website: $('#website').val(),
			phone: $('#phone').val(),
			subject: $('#subject').val(),
			comments: $('#comments').val(),
			verify: $('#verify').val()
		},
			function(data){
				document.getElementById('message').innerHTML = data;
				$('#message').slideDown('slow');
				$('#contact-form img.loader').fadeOut('slow',function(){$(this).remove()});
				$('#contact-form #contact-submit').attr('disabled',''); 
				if(data.match('success') != null) $('#contact-form').slideUp('slow');
				
			}
		);
		
		});
		
		return false; 
	
	});
	
});