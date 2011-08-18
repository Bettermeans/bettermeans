# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

class Wiki < ActiveRecord::Base
  belongs_to :project
  has_many :pages, :class_name => 'WikiPage', :dependent => :destroy, :order => 'title'
  has_many :redirects, :class_name => 'WikiRedirect', :dependent => :delete_all
  
  acts_as_watchable
  
  validates_presence_of :start_page
  validates_format_of :start_page, :with => /^[^,\.\/\?\;\|\:]*$/
  
  def visible?(user=User.current)
    !user.nil? && user.allowed_to?(:view_wiki_pages, project)
  end
  
  # find the page with the given title
  # if page doesn't exist, return a new page
  def find_or_new_page(title)
    title = start_page if title.blank?
    find_page(title) || WikiPage.new(:wiki => self, :title => Wiki.titleize(title))
  end
  
  # find the page with the given title
  def find_page(title, options = {})
    title = start_page if title.blank?
    title = Wiki.titleize(title)
    page = pages.find_by_title(title)
    if !page && !(options[:with_redirect] == false)
      # search for a redirect
      redirect = redirects.find_by_title(title)
      page = find_page(redirect.redirects_to, :with_redirect => false) if redirect
    end
    page
  end
  
  # Finds a page by title
  # The given string can be of one of the forms: "title" or "project:title"
  # Examples:
  #   Wiki.find_page("bar", project => foo)
  #   Wiki.find_page("foo:bar")
  def self.find_page(title, options = {})
    project = options[:project]
    if title.to_s =~ %r{^([^\:]+)\:(.*)$}
      project_identifier, title = $1, $2
      project = Project.find_by_identifier(project_identifier) || Project.find_by_name(project_identifier)
    end
    if project && project.wiki
      page = project.wiki.find_page(title)
      if page && page.content
        page
      end
    end
  end
  
  # turn a string into a valid page title
  def self.titleize(title)
    # replace spaces with _ and remove unwanted caracters
    title = title.gsub(/\s+/, '_').delete(',./?;|:') if title
    # upcase the first letter
    title = (title.slice(0..0).upcase + (title.slice(1..-1) || '')) if title
    title
  end  
end


# == Schema Information
#
# Table name: wikis
#
#  id         :integer         not null, primary key
#  project_id :integer         not null
#  start_page :string(255)     not null
#  status     :integer         default(1), not null
#

