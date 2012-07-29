class Plan < ActiveRecord::Base
  FREE_CODE = 0

  def free?
    return self.code == FREE_CODE
  end
end
