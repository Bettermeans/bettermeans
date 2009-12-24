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
    {:conditions => ["LOWER(login) LIKE :s OR LOWER(firstname) LIKE :s OR LOWER(lastname) LIKE :s OR LOWER(mail) LIKE :s", {:s => s}],
     :order => 'type, login, lastname, firstname, mail'
    }
  } 
  
  
  def <=>(principal)
    if self.class.name == principal.class.name
      self.to_s.downcase <=> principal.to_s.downcase
    else
      # groups after users
      principal.class.name <=> self.class.name
    end
  end
end


# == Schema Information
#
# Table name: users
#
#  id                :integer         not null, primary key
#  login             :string(30)      default(""), not null
#  hashed_password   :string(40)      default(""), not null
#  firstname         :string(30)      default(""), not null
#  lastname          :string(30)      default(""), not null
#  mail              :string(60)      default(""), not null
#  mail_notification :boolean         default(TRUE), not null
#  admin             :boolean         default(FALSE), not null
#  status            :integer         default(1), not null
#  last_login_on     :datetime
#  language          :string(5)       default("")
#  auth_source_id    :integer
#  created_on        :datetime
#  updated_on        :datetime
#  type              :string(255)
#  identity_url      :string(255)
#

