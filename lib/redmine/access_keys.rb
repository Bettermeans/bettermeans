# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

module Redmine
  module AccessKeys
    ACCESSKEYS = {:edit => 'e',
                  :preview => 'r',
                  :quick_search => 'f',
                  :search => '4',
                  :new_issue => '7'
                 }.freeze unless const_defined?(:ACCESSKEYS)
                 
    def self.key_for(action)
      ACCESSKEYS[action]
    end
  end
end
