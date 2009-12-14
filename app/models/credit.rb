class Credit < ActiveRecord::Base
  fields do
    project_id :integer , :null => false
    owner_id :integer , :null => false
    amount :float, :null => false
    issued_on :datetime, :default =>  Time.now
    created_on :datetime
    updated_on :datetime
  end
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :project
  
end