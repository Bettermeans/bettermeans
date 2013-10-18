class Plan < ActiveRecord::Base
  FREE_CODE = 0

  def free? # heckle_me
    return self.code == FREE_CODE
  end

  def self.free # heckle_me
    find_by_code(FREE_CODE)
  end
end
