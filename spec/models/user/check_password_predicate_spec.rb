require 'spec_helper'

describe User, '#check_password?' do

  let(:user) { Factory.create(:user, :password => 'blahblah') }

  context 'when the given password matches' do
    it 'returns true' do
      user.check_password?('blahblah').should == true
    end
  end

  context 'when the given password does not match' do
    it 'returns false' do
      user.check_password?('blooblah').should == false
    end
  end

end
