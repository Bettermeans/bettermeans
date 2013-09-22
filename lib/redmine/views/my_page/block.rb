# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

module Redmine
  module Views
    module MyPage
      module Block
        def self.additional_blocks # spec_me cover_me heckle_me
          @@additional_blocks ||= Dir.glob("#{RAILS_ROOT}/vendor/plugins/*/app/views/my/blocks/_*.{rhtml,erb}").inject({}) do |h,file|
            name = File.basename(file).split('.').first.gsub(/^_/, '')
            h[name] = name.to_sym
            h
          end
        end
      end
    end
  end
end
