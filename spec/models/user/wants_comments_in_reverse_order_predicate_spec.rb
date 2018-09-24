require 'spec_helper'

describe User, '#wants_comments_in_reverse_order?' do

  let(:user) { User.new }

  it "returns true when the comments sorting preference is 'desc'" do
    user_preference = UserPreference.new
    user_preference[:comments_sorting] = 'desc'

    user.preference = user_preference
    user.wants_comments_in_reverse_order?.should == true
  end

  it "returns false when the comments sorting preference is not 'desc'" do
    user_preference = UserPreference.new
    user_preference[:comments_sorting] = 'blah'

    user.preference = user_preference
    user.wants_comments_in_reverse_order?.should == false
  end

end
