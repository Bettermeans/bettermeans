require 'spec_helper'

describe Motion, '.viewable_by' do

  it 'returns motions with visibility >= the given' do
    motion1 = Factory.create(:motion)
    motion2 = Factory.create(:motion)
    motion3 = Factory.create(:motion)
    motion1.update_attributes!(:visibility_level => 4)
    motion2.update_attributes!(:visibility_level => 5)
    motion3.update_attributes!(:visibility_level => 6)

    Motion.viewable_by(5).sort_by(&:id).should == [motion2, motion3]
  end

end
