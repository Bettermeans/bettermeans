class AddEnterpriseTable < ActiveRecord::Migration
  def self.up
    create_table :enterprises do |t|
      t.string   :name
      t.text     :description
      t.string   :homepage, :default => ""
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    add_column :projects, :enterprise_id, :integer
    add_index :projects, [:enterprise_id]
    
    #Adding the first enterprise, and pointing all projects to this enterprise
    Enterprise.create! :name=>"BetterMeans", :description=>"This is the human enterprise that runs the bettermenas platform"
    @id = Enterprise.find(:first).id
    
    Project.find(:all).each do |o|
       o.enterprise_id = @id
       o.save
    end    
    
  end

  def self.down
    remove_column :projects, :enterprise_id
    remove_index :projects, :name => :index_projects_on_enterprise_id
    
    drop_table :enterprises
  end
end
