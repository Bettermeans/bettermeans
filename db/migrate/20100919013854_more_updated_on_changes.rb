class MoreUpdatedOnChanges < ActiveRecord::Migration
  def self.up
    rename_column :wiki_content_versions, :updated_on, :updated_at
    
    remove_index "wiki_content_versions", :name => "index_wiki_content_versions_on_updated_on"
    add_index "wiki_content_versions", ["updated_at"], :name => "index_wiki_content_versions_on_updated_at"

    rename_column :wiki_contents, :updated_on, :updated_at
    
  end

  def self.down
  end
end
