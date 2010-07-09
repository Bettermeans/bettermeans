class DowncaseAllLogins < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      u.login = u.login.downcase
      u.save
    end
  end

  def self.down
  end
end
