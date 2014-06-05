require 'spec_helper'

describe User, '#authenticate' do

  let(:user) { Factory.create(:user) }

  context 'when the user has an auth source' do
    it 'returns the auth source return' do
      auth_source = Factory.build(:auth_source)
      user.auth_source = auth_source
      auth_source.
        stub(:authenticate).
        with(user.login, user.password).
        and_return('blag')
      user.authenticate(user.password).should == 'blag'
    end
  end

  context 'when the user does not have an auth source' do
    context 'when the password matches' do
      it 'returns true' do
        user.authenticate(user.password).should == true
      end
    end

    context 'when the password does not match' do
      it 'returns false' do
        user.authenticate('bloo').should == false
      end
    end
  end

end
