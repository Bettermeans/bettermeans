class RemoveIssueCategories < ActiveRecord::Migration
  def self.up
    drop_table :issue_categories
  end

  def self.down
    create_table "issue_categories", :force => true do |t|
      t.column "project_id", :integer, :default => 0, :null => false
      t.column "name", :string, :limit => 30, :default => "", :null => false
    end
    
    add_index "issue_categories", ["project_id"], :name => "issue_categories_project_id"
  end
end
