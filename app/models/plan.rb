class Plan < ActiveRecord::Base
  FREE_CODE = 0

  def free? # spec_me cover_me heckle_me
    return self.code == FREE_CODE
  end

  def self.free # spec_me cover_me heckle_me
    find_by_code(FREE_CODE)
  end
end
