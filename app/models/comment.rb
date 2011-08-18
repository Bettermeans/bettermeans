# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class Comment < ActiveRecord::Base
  belongs_to :commented, :polymorphic => true, :counter_cache => true
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  validates_presence_of :commented, :author, :comments
  
  after_save :send_mentions
  
  def send_mentions
    Mention.parse(self, self.author_id)
  end
  
  def title
    case self.commented_type
    when "News"
      self.commented.title
    end
  end
  
  def mention(mentioner_id, mentioned_id, mention_text)
    Notification.create :recipient_id => mentioned_id,
                        :variation => 'mention',
                        :params => {:mention_text => self.comments, 
                                    :url => {:controller => self.commented_type.to_s.pluralize.downcase, :action => "show", :id => self.commented_id}, 
                                    :title => self.title}, 
                        :sender_id => mentioner_id,
                        :source_id => self.id,
                        :source_type => "Comment(#{self.commented_type})"
  end
end


# == Schema Information
#
# Table name: comments
#
#  id             :integer         not null, primary key
#  commented_type :string(30)      default(""), not null
#  commented_id   :integer         default(0), not null
#  author_id      :integer         default(0), not null
#  comments       :text
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

