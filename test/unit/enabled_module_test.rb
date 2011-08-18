# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class EnabledModuleTest < ActiveSupport::TestCase
  fixtures :projects, :wikis
  
  def test_enabling_wiki_should_create_a_wiki
    CustomField.delete_all
    project = Project.create!(:name => 'Project with wiki', :identifier => 'wikiproject')
    assert_nil project.wiki
    project.enabled_module_names = ['wiki']
    project.reload
    assert_not_nil project.wiki
    assert_equal 'Wiki', project.wiki.start_page
  end
  
  def test_reenabling_wiki_should_not_create_another_wiki
    project = Project.find(1)
    assert_not_nil project.wiki
    project.enabled_module_names = []
    project.reload
    assert_no_difference 'Wiki.count' do
      project.enabled_module_names = ['wiki']
    end
    assert_not_nil project.wiki
  end
end


# == Schema Information
#
# Table name: enabled_modules
#
#  id         :integer         not null, primary key
#  project_id :integer
#  name       :string(255)     not null
#

