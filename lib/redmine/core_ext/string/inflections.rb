# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

module Redmine #:nodoc:
  module CoreExtensions #:nodoc:
    module String #:nodoc:
      # Custom string inflections
      module Inflections
        def with_leading_slash # spec_me cover_me heckle_me
          starts_with?('/') ? self : "/#{ self }"
        end
      end
    end
  end
end
