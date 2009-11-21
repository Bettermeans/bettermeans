class Enterprise < ActiveRecord::Base  
  fields do
      name  :string
      description  :text
      homepage :string , :default => ""
      timestamps
    end
    
    has_many :projects
    has_many :issues, :through => :projects
    has_many :members, :through => :projects
    has_many :users, :through => :members    
    has_many :news, :through => :projects
    
    validates_presence_of :name
    validates_uniqueness_of :name
    validates_length_of :name, :maximum => 50
    validates_length_of :homepage, :maximum => 255
        
    # belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
    
end
