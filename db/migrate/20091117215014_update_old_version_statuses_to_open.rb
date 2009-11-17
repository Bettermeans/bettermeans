class UpdateOldVersionStatusesToOpen < ActiveRecord::Migration
  def self.up
    Version.find(:all).each do |v|
       v.status = 'open'
       v.save
    end    
  end

  def self.down
  end
end
