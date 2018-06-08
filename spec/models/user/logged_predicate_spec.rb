require 'spec_helper'

describe User, '#logged?' do

  let(:user) { User.new }

  it 'returns true' do
    user.logged?.should be true
  end

end
