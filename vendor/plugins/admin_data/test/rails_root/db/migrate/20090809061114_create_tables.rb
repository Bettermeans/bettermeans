class CreateTables < ActiveRecord::Migration
  def self.up

    create_table(:articles, :primary_key => 'article_id') do |t|
      t.string :title ,           :null => false, :limit => 200
      t.text :body,               :null => false
      t.text :body_html,          :null => false
      t.text :short_desc
      t.string :status,           :default => 'draft', :limit => 50
      t.datetime :published_at,   :null => true
      t.boolean :approved
      t.integer :hits_count
      t.string :magazine_type
      t.timestamps
      t.integer :magazine_id # so that created_at and updated_at are not at the end
      t.text :data
    end

    create_table :tech_magazines do |t|
      t.timestamps
    end

    create_table :comments do |t|
      t.integer :article_id,      :null => false
      t.text :body,               :null => false
      t.text :body_html,          :null => false
      t.string :author_name,      :null => false
      t.string :author_website,   :null => true
      t.boolean :posted_by_admin, :default => false

      t.timestamps
    end

    create_table :cars do |t|
      t.integer :year
      t.string :brand
      t.timestamps
    end

    create_table :doors do |t|
      t.string :color
      t.integer :car_id
      t.timestamps
    end

    create_table :cities do |t|
      t.string :name
      t.string :permanent_name
      t.timestamps
    end

    create_table :engines do |t|
      t.integer :cylinders
      t.integer :car_id
      t.timestamps
    end

  end

  def self.down
    drop_table :comments
    drop_table :tech_magaznines
    drop_table :articles
    drop_table :cars
    drop_table :doors
    drop_table :cities
    drop_table :engines
  end

end
