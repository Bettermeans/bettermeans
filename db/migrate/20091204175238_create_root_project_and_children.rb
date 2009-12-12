class CreateRootProjectAndChildren < ActiveRecord::Migration
  def self.up
    p = Project.create! :name => "BetterMeans", :description => "The root project for the bettermeans enterprise", :identifier => "bm", :enterprise_id => 1
    Project.find(:all).each do |pr|
       pr.move_to_child_of(p) unless pr.id == p.id
     end
   end

  def self.down
  end
end
