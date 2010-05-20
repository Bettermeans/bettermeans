# Redmine - project management software
# Copyright (C) 2006-2008  Shereef Bishay
#

module Redmine
  module WikiFormatting
    module Textile
      module Helper
      
        def initial_page_content(page)
          "h1. #{@page.pretty_title}"
        end
      
      end
    end
  end
end
