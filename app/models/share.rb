class Share < ActiveRecord::Base
  fields do
    project_id :integer , :null => false
    owner_id :integer 
    amount :float, :null => false
    expires :datetime, :default => :null
    variation :integer, :default => 2, :null => false
    issued_on :datetime, :default =>  Time.now
    created_on :datetime
    updated_on :datetime
  end
  
  #Constants
  VARIATION_FOUNDER = 1 #issue when enterprise starts. don't expire
  VARIATION_CREDIT = 2 #issued when credit is issued, expire
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :project
  
end