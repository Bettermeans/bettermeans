# Redmine - project management software
# Copyright (C) 2009  Shereef Bishay
#

module Redmine #:nodoc:
  module CoreExtensions #:nodoc:
    module String #:nodoc:
      # Custom string inflections
      module Inflections
        def with_leading_slash
          starts_with?('/') ? self : "/#{ self }"
        end
      end
    end
  end
end
