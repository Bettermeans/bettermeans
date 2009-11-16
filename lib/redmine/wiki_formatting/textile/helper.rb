# Redmine - project management software
# Copyright (C) 2006-2008  Shereef Bishay
#

module Redmine
  module WikiFormatting
    module Textile
      module Helper
        def wikitoolbar_for(field_id)
          # Is there a simple way to link to a public resource?
          url = "#{Redmine::Utils.relative_url_root}/help/wiki_syntax.html"
          
          help_link = l(:setting_text_formatting) + ': ' +
            link_to(l(:label_help), url,
                    :onclick => "window.open(\"#{ url }\", \"\", \"resizable=yes, location=no, width=300, height=640, menubar=no, status=no, scrollbars=yes\"); return false;")
      
          javascript_include_tag('jstoolbar/jstoolbar') +
            javascript_include_tag('jstoolbar/textile') +
            javascript_include_tag("jstoolbar/lang/jstoolbar-#{current_language.to_s.downcase}") +
          javascript_tag("var wikiToolbar = new jsToolBar($('#{field_id}')); wikiToolbar.setHelpLink('#{help_link}'); wikiToolbar.draw();")
        end
      
        def initial_page_content(page)
          "h1. #{@page.pretty_title}"
        end
      
        def heads_for_wiki_formatter
          stylesheet_link_tag 'jstoolbar'
        end
      end
    end
  end
end
