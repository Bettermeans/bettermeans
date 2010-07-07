module ActivityStreamsHelper
  
  def render_journal_details(journal)
    html = "<ul>"
    for detail in journal.details
      html << "<li>#{show_detail(detail)}</li>"
    end
    html << "</ul>"
    
    content = ""
    content << textilizable(journal, :notes)
    css_classes = "wiki"
    css_classes << " gravatar-margin" if Setting.gravatar_enabled?
    
    html + content_tag('div', content, :id => "journal-#{journal.id}-notes", :class => css_classes)
    
  end
  
end