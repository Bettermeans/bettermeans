# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class RepositorySubversionTest < ActiveSupport::TestCase
  fixtures :projects
  
  # No '..' in the repository path for svn
  REPOSITORY_PATH = RAILS_ROOT.gsub(%r{config\/\.\.}, '') + '/tmp/test/subversion_repository'
  
  def setup
    @project = Project.find(1)
    assert @repository = Repository::Subversion.create(:project => @project, :url => "file:///#{REPOSITORY_PATH}")
  end
  
  if File.directory?(REPOSITORY_PATH)  
    def test_fetch_changesets_from_scratch
      @repository.fetch_changesets
      @repository.reload
      
      assert_equal 10, @repository.changesets.count
      assert_equal 18, @repository.changes.count
      assert_equal 'Initial import.', @repository.changesets.find_by_revision('1').comments
    end
    
    def test_fetch_changesets_incremental
      @repository.fetch_changesets
      # Remove changesets with revision > 5
      @repository.changesets.find(:all).each {|c| c.destroy if c.revision.to_i > 5}
      @repository.reload
      assert_equal 5, @repository.changesets.count
      
      @repository.fetch_changesets
      assert_equal 10, @repository.changesets.count
    end
    
    def test_latest_changesets
      @repository.fetch_changesets
      
      # with limit
      changesets = @repository.latest_changesets('', nil, 2)
      assert_equal 2, changesets.size
      assert_equal @repository.latest_changesets('', nil).slice(0,2), changesets
      
      # with path
      changesets = @repository.latest_changesets('subversion_test/folder', nil)
      assert_equal ["10", "9", "7", "6", "5", "2"], changesets.collect(&:revision)
      
      # with path and revision
      changesets = @repository.latest_changesets('subversion_test/folder', 8)
      assert_equal ["7", "6", "5", "2"], changesets.collect(&:revision)
    end
  else
    puts "Subversion test repository NOT FOUND. Skipping unit tests !!!"
    def test_fake; assert true end
  end
end
