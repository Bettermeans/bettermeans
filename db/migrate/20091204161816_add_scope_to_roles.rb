class AddScopeToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :level, :integer, :default => 3

    r = Role.find(:first, :conditions => {:name => "Anonymous"})
    r.level = Role::LEVEL_PLATFORM
    r.save

    r = Role.find(:first, :conditions => {:name => "Non member"})
    r.level = Role::LEVEL_PLATFORM
    r.save
    
    r = Role.find(:first, :conditions => {:name => "Administrator"})
    r.level = Role::LEVEL_PROJECT
    r.save
    
    r = Role.find(:first, :conditions => {:name => "Core Team"})
    r.level = Role::LEVEL_PROJECT
    r.save
    
    r = Role.find(:first, :conditions => {:name => "Contributor"})
    r.level = Role::LEVEL_PROJECT
    r.save
    
    citizen = Role.create! :name => "Citizen", :builtin => Role::BUILTIN_CITIZEN, :level => Role::LEVEL_ENTERPRISE
    # citizen.permissions = citizen.setable_permissions.collect {|p| p.name}
    # 
    # citizen.save!

    founder = Role.create! :name => "Founder", :builtin => Role::BUILTIN_FOUNDER, :level => Role::LEVEL_ENTERPRISE
    # founder.permissions = founder.setable_permissions.collect {|p| p.name}
    # 
    # founder.save!
    
    
  end

  def self.down
    
    r = Role.find(:first, :conditions => {:name => "Citizen"})
    r.destroy
    
    r = Role.find(:first, :conditions => {:name => "Founder"})
    r.destroy
    
    remove_column :roles, :level
    
  end
end
