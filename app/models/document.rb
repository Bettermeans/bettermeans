# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class Document < ActiveRecord::Base
  belongs_to :project
  acts_as_attachable :delete_permission => :manage_documents

  acts_as_searchable :columns => ['title', "#{table_name}.description"], :include => :project

  acts_as_event :title => Proc.new {|o| "#{l(:label_document)}: #{o.title}"},
                :author => Proc.new {|o| (a = o.attachments.find(:first, :order => "#{Attachment.table_name}.created_on ASC")) ? a.author : nil },
                :url => Proc.new {|o| {:controller => 'documents', :action => 'show', :id => o.id}}
  # acts_as_activity_provider :find_options => {:include => :project}
  
  validates_presence_of :project, :title
  validates_length_of :title, :maximum => 60
  
  def visible?(user=User.current)
    !user.nil? && user.allowed_to?(:view_documents, project)
  end
  
  def updated_on
    unless @updated_on
      a = attachments.find(:first, :order => 'created_on DESC')
      @updated_on = (a && a.created_on) || created_on
    end
    @updated_on
  end
  
  # Returns the mail adresses of users that should be notified
  def recipients
    notified = project.notified_users
    notified.reject! {|user| !visible?(user)}
    notified.collect(&:mail)
  end
end



# == Schema Information
#
# Table name: documents
#
#  id          :integer         not null, primary key
#  project_id  :integer         default(0), not null
#  title       :string(60)      default(""), not null
#  description :text
#  created_on  :datetime
#

