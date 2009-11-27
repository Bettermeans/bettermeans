# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

class Principal < ActiveRecord::Base
  set_table_name 'users'

  has_many :members, :foreign_key => 'user_id', :dependent => :destroy
  has_many :memberships, :class_name => 'Member', :foreign_key => 'user_id', :include => [ :project, :roles ], :conditions => "#{Project.table_name}.status=#{Project::STATUS_ACTIVE}", :order => "#{Project.table_name}.name"
  has_many :core_memberships, :class_name => 'Member', :foreign_key => 'user_id', :include => [ :project, :roles ], :conditions => "#{Project.table_name}.status=#{Project::STATUS_ACTIVE} AND #{Role.table_name}.builtin=#{Role::BUILTIN_CORE_MEMBER}", :order => "#{Project.table_name}.name"
  has_many :projects, :through => :memberships

  # Groups and active users
  named_scope :active, :conditions => "#{Principal.table_name}.type='Group' OR (#{Principal.table_name}.type='User' AND #{Principal.table_name}.status = 1)"
  
  named_scope :like, lambda {|q| 
    s = "%#{q.to_s.strip.downcase}%"
    {:conditions => ["LOWER(login) LIKE ? OR LOWER(firstname) LIKE ? OR LOWER(lastname) LIKE ?", s, s, s],
     :order => 'type, login, lastname, firstname'
    }
  } 
  
  
  def <=>(principal)
    self.to_s.downcase <=> principal.to_s.downcase
  end
end
