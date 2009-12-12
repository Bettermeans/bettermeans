class UpdateRoleBuiltins < ActiveRecord::Migration
  def self.up
    r = Role.find(:first, :conditions => {:name => "Administrator"})
    r.builtin = Role::BUILTIN_ADMINISTRATOR
    r.save
    
    r = Role.find(:first, :conditions => {:name => "Core Team"})
    r.builtin = Role::BUILTIN_CORE_MEMBER
    r.save
    
    r = Role.find(:first, :conditions => {:name => "Contributor"})
    r.builtin = Role::BUILTIN_CONTRIBUTOR
    r.save
    
  end

  def self.down
  end
end
