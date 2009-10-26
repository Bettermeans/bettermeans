# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'
require 'pp'
class RepositoryCvsTest < ActiveSupport::TestCase
  fixtures :projects
  
  # No '..' in the repository path
  REPOSITORY_PATH = RAILS_ROOT.gsub(%r{config\/\.\.}, '') + '/tmp/test/cvs_repository'
  REPOSITORY_PATH.gsub!(/\//, "\\") if Redmine::Platform.mswin?
  # CVS module
  MODULE_NAME = 'test'
  
  def setup
    @project = Project.find(1)
    assert @repository = Repository::Cvs.create(:project => @project, 
                                                :root_url => REPOSITORY_PATH,
                                                :url => MODULE_NAME)
  end
  
  if File.directory?(REPOSITORY_PATH)  
    def test_fetch_changesets_from_scratch
      @repository.fetch_changesets
      @repository.reload
      
      assert_equal 5, @repository.changesets.count
      assert_equal 14, @repository.changes.count
      assert_not_nil @repository.changesets.find_by_comments('Two files changed')
    end
    
    def test_fetch_changesets_incremental
      @repository.fetch_changesets
      # Remove the 3 latest changesets
      @repository.changesets.find(:all, :order => 'committed_on DESC', :limit => 3).each(&:destroy)
      @repository.reload
      assert_equal 2, @repository.changesets.count
      
      @repository.fetch_changesets
      assert_equal 5, @repository.changesets.count
    end
    
    def test_deleted_files_should_not_be_listed
      entries = @repository.entries('sources')
      assert entries.detect {|e| e.name == 'watchers_controller.rb'}
      assert_nil entries.detect {|e| e.name == 'welcome_controller.rb'}
    end
  else
    puts "CVS test repository NOT FOUND. Skipping unit tests !!!"
    def test_fake; assert true end
  end
end
