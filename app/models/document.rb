# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class Document < ActiveRecord::Base
  belongs_to :project
  belongs_to :category, :class_name => "DocumentCategory", :foreign_key => "category_id"
  acts_as_attachable :delete_permission => :manage_documents

  acts_as_searchable :columns => ['title', "#{table_name}.description"], :include => :project
  acts_as_event :title => Proc.new {|o| "#{l(:label_document)}: #{o.title}"},
                :author => Proc.new {|o| (a = o.attachments.find(:first, :order => "#{Attachment.table_name}.created_on ASC")) ? a.author : nil },
                :url => Proc.new {|o| {:controller => 'documents', :action => 'show', :id => o.id}}
  acts_as_activity_provider :find_options => {:include => :project}
  
  validates_presence_of :project, :title, :category
  validates_length_of :title, :maximum => 60
  
  def after_initialize
    if new_record?
      self.category ||= DocumentCategory.default
    end
  end
end
