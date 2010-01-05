class CreateQuoteTable < ActiveRecord::Migration
    def self.up
      create_table :quotes do |t|
        t.integer  :user_id
        t.string :author
        t.text :body
        t.datetime :created_on
        t.datetime :updated_on
      end
    end

    def self.down
      drop_table :quotes
    end
  end
