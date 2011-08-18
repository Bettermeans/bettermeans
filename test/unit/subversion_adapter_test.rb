# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
#

require 'mkmf'

require File.dirname(__FILE__) + '/../test_helper'

class SubversionAdapterTest < ActiveSupport::TestCase
  
  if find_executable0('svn')
    def test_client_version
      v = Redmine::Scm::Adapters::SubversionAdapter.client_version
      assert v.is_a?(Array)
    end
  else
    puts "Subversion binary NOT FOUND. Skipping unit tests !!!"
    def test_fake; assert true end
  end
end
