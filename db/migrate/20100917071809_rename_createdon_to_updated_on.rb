class RenameCreatedonToUpdatedOn < ActiveRecord::Migration
  def self.up
    rename_column :attachments, :created_on, :created_at
    
    remove_index "attachments", :name =>  "index_attachments_on_created_on"
    add_index "attachments", ["created_at"], :name => "index_attachments_on_created_at"
    
    
    rename_column :comments, :created_on, :created_at
    rename_column :comments, :updated_on, :updated_at
    
    rename_column :credit_distributions, :created_on, :created_at
    rename_column :credit_distributions, :updated_on, :updated_at
    
    rename_column :credits, :created_on, :created_at
    rename_column :credits, :updated_on, :updated_at
    
    rename_column :documents, :created_on, :created_at
    
    rename_column :help_sections, :created_on, :created_at
    rename_column :help_sections, :updated_on, :updated_at
    
    rename_column :invitations, :created_on, :created_at
    rename_column :invitations, :updated_on, :updated_at
    
    rename_column :issue_votes, :created_on, :created_at
    rename_column :issue_votes, :updated_on, :updated_at
    
    rename_column :issues, :created_on, :created_at
    rename_column :issues, :updated_on, :updated_at
    
    remove_index "issues", :name => "index_issues_on_created_on"
    add_index "issues", ["created_at"], :name => "index_issues_on_created_at"
    
    rename_column :journals, :created_on, :created_at
    rename_column :journals, :updated_on, :updated_at
    
    remove_index "journals", :name => "index_journals_on_created_on"
    add_index "journals", ["created_at"], :name => "index_journals_on_created_at"
    
    rename_column :mail_handlers, :created_on, :created_at
    rename_column :mail_handlers, :updated_on, :updated_at
    
    rename_column :member_roles, :created_on, :created_at
    rename_column :member_roles, :updated_on, :updated_at
    
    rename_column :members, :created_on, :created_at
    
    rename_column :messages, :created_on, :created_at
    rename_column :messages, :updated_on, :updated_at
    
    remove_index "messages", :name =>  "index_messages_on_created_on"
    add_index "messages", ["created_at"], :name => "index_messages_on_created_at"
    
    rename_column :news, :created_on, :created_at
    remove_index "news", :name =>  "index_news_on_created_on"
    add_index "news", ["created_at"], :name => "index_news_on_created_at"
    
    rename_column :notifications, :created_on, :created_at
    rename_column :notifications, :updated_on, :updated_at
    
    rename_column :plans, :created_on, :created_at
    rename_column :plans, :updated_on, :updated_at
    
    rename_column :projects, :created_on, :created_at
    rename_column :projects, :updated_on, :updated_at
    
    rename_column :quotes, :created_on, :created_at
    rename_column :quotes, :updated_on, :updated_at
    
    rename_column :retro_ratings, :created_on, :created_at
    rename_column :retro_ratings, :updated_on, :updated_at
    
    rename_column :retros, :created_on, :created_at
    rename_column :retros, :updated_on, :updated_at

    rename_column :shares, :created_on, :created_at
    rename_column :shares, :updated_on, :updated_at
    
    rename_column :todos, :created_on, :created_at
    rename_column :todos, :updated_on, :updated_at
    
    rename_column :tokens, :created_on, :created_at
    
    rename_column :users, :created_on, :created_at
    rename_column :users, :updated_on, :updated_at
    
    rename_column :wiki_pages, :created_on, :created_at
    
    rename_column :wiki_redirects, :created_on, :created_at

    rename_column :settings, :updated_on, :updated_at

  end

  def self.down
    rename_column :attachments, :created_at, :created_on
    
    remove_index "attachments", :name =>  "index_attachments_on_created_at"
    add_index "attachments", ["created_on"], :name => "index_attachments_on_created_on"
    
    
    rename_column :comments, :created_at, :created_on
    rename_column :comments, :updated_at, :updated_on
    
    rename_column :credit_distributions, :created_at, :created_on
    rename_column :credit_distributions, :updated_at, :updated_on
    
    rename_column :credits, :created_at, :created_on
    rename_column :credits, :updated_at, :updated_on
    
    rename_column :documents, :created_at, :created_on
    
    rename_column :help_sections, :created_at, :created_on
    rename_column :help_sections, :updated_at, :updated_on
    
    rename_column :invitations, :created_at, :created_on
    rename_column :invitations, :updated_at, :updated_on
    
    rename_column :issue_votes, :created_at, :created_on
    rename_column :issue_votes, :updated_at, :updated_on
    
    rename_column :issues, :created_at, :created_on
    rename_column :issues, :updated_at, :updated_on
    
    remove_index "issues", :name => "index_issues_on_created_at"
    add_index "issues", ["created_on"], :name => "index_issues_on_created_on"
    
    rename_column :journals, :created_at, :created_on
    rename_column :journals, :updated_at, :updated_on
    
    remove_index "journals", :name => "index_journals_on_created_at"
    add_index "journals", ["created_on"], :name => "index_journals_on_created_on"
    
    rename_column :mail_handlers, :created_at, :created_on
    rename_column :mail_handlers, :updated_at, :updated_on
    
    rename_column :member_roles, :created_at, :created_on
    rename_column :member_roles, :updated_at, :updated_on
    
    rename_column :members, :created_at, :created_on
    
    rename_column :messages, :created_at, :created_on
    rename_column :messages, :updated_at, :updated_on
    
    remove_index "messages", :name =>  "index_messages_on_created_at"
    add_index "messages", ["created_on"], :name => "index_messages_on_created_on"
    
    rename_column :news, :created_at, :created_on
    remove_index "news", :name =>  "index_news_on_created_at"
    add_index "news", ["created_on"], :name => "index_news_on_created_on"
    
    rename_column :notifications, :created_at, :created_on
    rename_column :notifications, :updated_at, :updated_on
    
    rename_column :plans, :created_at, :created_on
    rename_column :plans, :updated_at, :updated_on
    
    rename_column :projects, :created_at, :created_on
    rename_column :projects, :updated_at, :updated_on
    
    rename_column :quotes, :created_at, :created_on
    rename_column :quotes, :updated_at, :updated_on
    
    rename_column :retro_ratings, :created_at, :created_on
    rename_column :retro_ratings, :updated_at, :updated_on
    
    rename_column :retros, :created_at, :created_on
    rename_column :retros, :updated_at, :updated_on

    rename_column :shares, :created_at, :created_on
    rename_column :shares, :updated_at, :updated_on
    
    rename_column :todos, :created_at, :created_on
    rename_column :todos, :updated_at, :updated_on
    
    rename_column :tokens, :created_at, :created_on
    
    rename_column :users, :created_at, :created_on
    rename_column :users, :updated_at, :updated_on
    
    rename_column :wiki_pages, :created_at, :created_on
    
    rename_column :wiki_redirects, :created_at, :created_on

    # rename_column :settings, :updated_at, :updated_on
    
  end
end
