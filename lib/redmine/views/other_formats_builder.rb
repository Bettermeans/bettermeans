# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

module Redmine
  module Views
    class OtherFormatsBuilder
      def initialize(view) # spec_me cover_me heckle_me
        @view = view
      end

      def link_to(name, options={}) # spec_me cover_me heckle_me
        url = { :format => name.to_s.downcase }.merge(options.delete(:url) || {})
        caption = options.delete(:caption) || name
        html_options = { :class => name.to_s.downcase, :rel => 'nofollow' }.merge(options)
        @view.content_tag('span', @view.link_to(caption, url, html_options))
      end
    end
  end
end
