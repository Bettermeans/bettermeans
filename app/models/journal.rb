# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class Journal < ActiveRecord::Base
  
  belongs_to :journalized, :polymorphic => true
  # added as a quick fix to allow eager loading of the polymorphic association
  # since always associated to an issue, for now
  belongs_to :issue, :foreign_key => :journalized_id
  
  belongs_to :user
  has_many :details, :class_name => "JournalDetail", :dependent => :delete_all
  attr_accessor :indice
      
  after_save :update_issue_timestamp, :send_mentions, :parse_relations
  
  def update_issue_timestamp
    issue.updated_at = DateTime.now
    issue.save
  end
  
  def send_mentions
    Mention.parse(self, self.user_id)
  end
  
  def mention(mentioner_id, mentioned_id, mention_text)
    Notification.create :recipient_id => mentioned_id,
                        :variation => 'mention',
                        :params => {:mention_text => self.notes, 
                                    :url => {:controller => self.journalized_type.to_s.pluralize.downcase, :action => "show", :id => self.journalized_id}, 
                                    :title => self.issue.subject}, 
                        :sender_id => mentioner_id,
                        :source_id => self.id,
                        :source_type => "Journal(#{self.journalized_type})"
  end
  
  def parse_relations
    self.send_later(:parse_relations_delayed)
  end
  
  #parses issue ids in body of journal, and adds related issues
  def parse_relations_delayed
    text = self.notes
    text = text.gsub(%r{([\s\(,\-\>]|^)(!)?(attachment|document|version|commit|source|export|message)?((#|r)(\d+)|(@)([a-zA-Z0-9._@]+)|(:)([^"\s<>][^\s<>]*?|"[^"]+?"))(?=(?=[[:punct:]]\W)|,|\s|<|$)}) do |m|
      leading, esc, prefix, sep, oid = $1, $2, $3, $5 || $7, $6 || $8
      link = nil
      if esc.nil?
        if sep == '#'
          @relation = IssueRelation.new
          @relation.issue_from_id = self.journalized_id
          @relation.issue_to_id = oid
          @relation.relation_type = IssueRelation::TYPE_RELATES
          @relation.save
        end
      end
    end
  end  
  
  def save(*args)
    # Do not save an empty journal
    (details.empty? && notes.blank?) ? false : super
  end
  
  # Returns the new status if the journal contains a status change, otherwise nil
  def new_status
    c = details.detect {|detail| detail.prop_key == 'status_id'}
    (c && c.value) ? IssueStatus.find_by_id(c.value.to_i) : nil
  end
  
  def new_value_for(prop)
    c = details.detect {|detail| detail.prop_key == prop}
    c ? c.value : nil
  end
  
  def editable_by?(usr)
    usr && usr.logged? && (usr.allowed_to?(:edit_issue_notes, project) || (self.user == usr && usr.allowed_to?(:edit_own_issue_notes, project)))
  end
  
  def project
    journalized.respond_to?(:project) ? journalized.project : nil
  end
  
  def attachments
    journalized.respond_to?(:attachments) ? journalized.attachments : nil
  end
end


# == Schema Information
#
# Table name: journals
#
#  id               :integer         not null, primary key
#  journalized_id   :integer         default(0), not null
#  journalized_type :string(30)      default(""), not null
#  user_id          :integer         default(0), not null
#  notes            :text
#  created_at       :datetime        not null
#  updated_at       :datetime
#

