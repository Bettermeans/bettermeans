# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class RepositoryFilesystemTest < ActiveSupport::TestCase
  fixtures :projects
  
  # No '..' in the repository path
  REPOSITORY_PATH = RAILS_ROOT.gsub(%r{config\/\.\.}, '') + '/tmp/test/filesystem_repository'
  
  def setup
    @project = Project.find(1)
    Setting.enabled_scm << 'Filesystem' unless Setting.enabled_scm.include?('Filesystem')
    assert @repository = Repository::Filesystem.create(:project => @project, :url => REPOSITORY_PATH)
  end
  
  if File.directory?(REPOSITORY_PATH)  
    def test_fetch_changesets
      @repository.fetch_changesets
      @repository.reload
      
      assert_equal 0, @repository.changesets.count
      assert_equal 0, @repository.changes.count
    end
        
    def test_entries
      assert_equal 2, @repository.entries("", 2).size
      assert_equal 2, @repository.entries("dir", 3).size
    end

    def test_cat
      assert_equal "TEST CAT\n", @repository.scm.cat("test")
    end

  else
    puts "Filesystem test repository NOT FOUND. Skipping unit tests !!! See doc/RUNNING_TESTS."
    def test_fake; assert true end
  end
end
