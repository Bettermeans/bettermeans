# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license
#

module Redmine
  module WikiFormatting
    @@formatters = {}

    class << self
      def map
        yield self
      end

      def register(name, formatter, helper)
        raise ArgumentError, "format name '#{name}' is already taken" if @@formatters[name.to_sym]
        @@formatters[name.to_sym] = {:formatter => formatter, :helper => helper}
      end

      def formatter_for(name)
        entry = @@formatters[name.to_sym]
        (entry && entry[:formatter]) || Redmine::WikiFormatting::NullFormatter::Formatter
      end

      def helper_for(name)
        entry = @@formatters[name.to_sym]
        (entry && entry[:helper]) || Redmine::WikiFormatting::NullFormatter::Helper
      end

      def format_names
        @@formatters.keys.map
      end

      def to_html(format, text, options = {}, &block)
        formatter_for(format).new(text).to_html(&block)
      end
    end

    # Default formatter module
    module NullFormatter
      class Formatter
        include ActionView::Helpers::TagHelper
        include ActionView::Helpers::TextHelper
        include ActionView::Helpers::UrlHelper

        def initialize(text)
          @text = text
        end

        def to_html(*args)
          simple_format(auto_link(CGI::escapeHTML(@text)))
        end
      end

      module Helper
        def initial_page_content(page)
          page.pretty_title.to_s
        end
      end
    end
  end
end
