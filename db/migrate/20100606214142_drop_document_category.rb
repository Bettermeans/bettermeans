class DropDocumentCategory < ActiveRecord::Migration
  def self.up
    remove_column :documents, :category_id
    remove_column :issues, :category_id
  end

  def self.down
    add_column :documents, :category_id, :integer
    add_column :issues, :category_id, :integer
  end
end
