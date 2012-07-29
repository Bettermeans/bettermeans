class Enterprise < ActiveRecord::Base
    has_one :root_project, :class_name => 'Project', :conditions => "parent_id is null"
    has_many :projects
    has_many :issues, :through => :projects
    has_many :members, :through => :projects
    has_many :users, :through => :members
    has_many :news, :through => :projects

    validates_presence_of :name
    validates_uniqueness_of :name
    validates_length_of :name, :maximum => 50
    validates_length_of :homepage, :maximum => 255

end

