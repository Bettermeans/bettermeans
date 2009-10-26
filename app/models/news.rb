# Redmine - project management software
# Copyright (C) 2006-2008  Shereef Bishay
#

class News < ActiveRecord::Base
  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  has_many :comments, :as => :commented, :dependent => :delete_all, :order => "created_on"
  
  validates_presence_of :title, :description
  validates_length_of :title, :maximum => 60
  validates_length_of :summary, :maximum => 255

  acts_as_searchable :columns => ['title', 'summary', "#{table_name}.description"], :include => :project
  acts_as_event :url => Proc.new {|o| {:controller => 'news', :action => 'show', :id => o.id}}
  acts_as_activity_provider :find_options => {:include => [:project, :author]},
                            :author_key => :author_id
  
  # returns latest news for projects visible by user
  def self.latest(user = User.current, count = 5)
    find(:all, :limit => count, :conditions => Project.allowed_to_condition(user, :view_news), :include => [ :author, :project ], :order => "#{News.table_name}.created_on DESC")	
  end
end
