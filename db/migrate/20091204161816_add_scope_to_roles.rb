class AddScopeToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :scope, :integer, :default => 3

    r = Role.find(:first, :conditions => {:name => "Anonymous"})
    r.scope = Role::SCOPE_PLATFORM
    r.save

    r = Role.find(:first, :conditions => {:name => "Non member"})
    r.scope = Role::SCOPE_PLATFORM
    r.save
    
    r = Role.find(:first, :conditions => {:name => "Administrator"})
    r.scope = Role::SCOPE_PROJECT
    r.save
    
    r = Role.find(:first, :conditions => {:name => "Core Team"})
    r.scope = Role::SCOPE_PROJECT
    r.save
    
    r = Role.find(:first, :conditions => {:name => "Contributor"})
    r.scope = Role::SCOPE_PROJECT
    r.save
    
    citizen = Role.create! :name => "Citizen", :position => 1, :builtin => Role::BUILTIN_CITIZEN, :scope => Role::SCOPE_ENTERPRISE
    citizen.permissions = citizen.setable_permissions.collect {|p| p.name}
    
    citizen.save!

    founder = Role.create! :name => "Founder", :position => 1, :builtin => Role::BUILTIN_FOUNDER, :scope => Role::SCOPE_ENTERPRISE
    founder.permissions = founder.setable_permissions.collect {|p| p.name}
    
    founder.save!
    
    
  end

  def self.down
    remove_column :roles, :scope
  end
end
