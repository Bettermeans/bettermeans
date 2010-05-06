function show_item(){
	timer_active = false;
	D = [];
	D.push(item);
	$("#item_header").html(generate_item_lightbox(0));
	
	$("#todo_wrapper").replaceWith(generate_todo_section_lightbox(0));
}
