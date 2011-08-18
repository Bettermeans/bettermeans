# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require 'zlib'

class WikiContent < ActiveRecord::Base
  set_locking_column :version
  belongs_to :page, :class_name => 'WikiPage', :foreign_key => 'page_id'
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  validates_presence_of :text
  validates_length_of :comments, :maximum => 255, :allow_nil => true
  
  acts_as_versioned
  
  def visible?(user=User.current)
    page.visible?(user)
  end
    
  def project
    page.project
  end
  
  # Returns the mail adresses of users that should be notified
  def recipients
    notified = project.notified_users
    notified.reject! {|user| !visible?(user) || user.pref[:no_emails]}
    notified.collect(&:mail)
  end
  
  class Version
    belongs_to :page, :class_name => '::WikiPage', :foreign_key => 'page_id'
    belongs_to :author, :class_name => '::User', :foreign_key => 'author_id'
    attr_protected :data

    acts_as_event :title => Proc.new {|o| "#{l(:label_wiki_edit)}: #{o.page.title} (##{o.version})"},
                  :description => :comments,
                  :datetime => :updated_at,
                  :type => 'wiki-page',
                  :url => Proc.new {|o| {:controller => 'wiki', :id => o.page.wiki.project_id, :page => o.page.title, :version => o.version}}
    # 
    # acts_as_activity_provider :type => 'wiki_edits',
    #                           :timestamp => "#{WikiContent.versioned_table_name}.updated_at",
    #                           :author_key => "#{WikiContent.versioned_table_name}.author_id",
    #                           :permission => :view_wiki_edits,
    #                           :find_options => {:select => "#{WikiContent.versioned_table_name}.updated_at, #{WikiContent.versioned_table_name}.comments, " +
    #                                                        "#{WikiContent.versioned_table_name}.#{WikiContent.version_column}, #{WikiPage.table_name}.title, " +
    #                                                        "#{WikiContent.versioned_table_name}.page_id, #{WikiContent.versioned_table_name}.author_id, " +
    #                                                        "#{WikiContent.versioned_table_name}.id",
    #                                             :joins => "LEFT JOIN #{WikiPage.table_name} ON #{WikiPage.table_name}.id = #{WikiContent.versioned_table_name}.page_id " +
    #                                                       "LEFT JOIN #{Wiki.table_name} ON #{Wiki.table_name}.id = #{WikiPage.table_name}.wiki_id " +
    #                                                       "LEFT JOIN #{Project.table_name} ON #{Project.table_name}.id = #{Wiki.table_name}.project_id"}

    def text=(plain)
      case Setting.wiki_compression
      when 'gzip'
      begin
        self.data = Zlib::Deflate.deflate(plain, Zlib::BEST_COMPRESSION)
        self.compression = 'gzip'
      rescue
        self.data = plain
        self.compression = ''
      end
      else
        self.data = plain
        self.compression = ''
      end
      plain
    end
    
    def text
      @text ||= case compression
      when 'gzip'
         Zlib::Inflate.inflate(data)
      else
        # uncompressed data
        data
      end      
    end
    
    def project
      page.project
    end
    
    # Returns the previous version or nil
    def previous
      @previous ||= WikiContent::Version.find(:first, 
                                              :order => 'version DESC',
                                              :include => :author,
                                              :conditions => ["wiki_content_id = ? AND version < ?", wiki_content_id, version])
    end
  end
end



# == Schema Information
#
# Table name: wiki_contents
#
#  id         :integer         not null, primary key
#  page_id    :integer         not null
#  author_id  :integer
#  text       :text
#  comments   :string(255)     default("")
#  updated_on :datetime        not null
#  version    :integer         not null
#

