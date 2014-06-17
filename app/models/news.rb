# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license
#

class News < ActiveRecord::Base
  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  has_many :comments, :as => :commented, :dependent => :delete_all, :order => "created_at"

  validates_presence_of :title, :description
  validates_length_of :title, :maximum => 60
  validates_length_of :summary, :maximum => 255

  after_save :send_mentions

  acts_as_searchable :columns => ['title', 'summary', "#{table_name}.description"], :include => :project

  acts_as_event :url => Proc.new {|o| {:controller => 'news', :action => 'show', :id => o.id}}

  def visible?(user=User.current) # heckle_me
    !user.nil? && user.allowed_to?(:view_news, project)
  end

  # Returns the mail adresses of users that should be notified
  def recipients # spec_me cover_me heckle_me
    notified = project.notified_users
    notified.reject! {|user| !visible?(user) || user.pref[:no_emails]}
    notified.collect(&:mail)
  end

  # returns latest news for projects visible by user
  def self.latest(user = User.current, count = 5) # spec_me cover_me heckle_me
    find(:all, :limit => count, :conditions => Project.allowed_to_condition(user, :view_news) + " (created_at > '#{Time.now.advance :days => (Setting::DAYS_FOR_LATEST_NEWS * -1)}')", :include => [ :author, :project ], :order => "#{News.table_name}.created_at DESC")
  end

  def send_mentions # heckle_me
    Mention.parse(self, self.author_id)
  end

  def mention(mentioner_id, mentioned_id, mention_text) # heckle_me
    Notification.create :recipient_id => mentioned_id,
                        :variation => 'mention',
                        :params => {:mention_text => self.description,
                                    :url => {:controller => "news", :action => "show", :id => self.id},
                                    :title => self.title},
                        :sender_id => mentioner_id,
                        :source_id => self.id,
                        :source_type => "News"
  end

end

