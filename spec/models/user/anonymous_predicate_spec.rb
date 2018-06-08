require 'spec_helper'

describe User, '#anonymous?' do

  let(:user) { User.new }

  context 'when logged? is false' do
    it 'returns true' do
      user.stub(:logged?).and_return(false)
      user.anonymous?.should be true
    end
  end

  context 'when logged? is true' do
    it 'returns false' do
      user.anonymous?.should be false
    end
  end

end
