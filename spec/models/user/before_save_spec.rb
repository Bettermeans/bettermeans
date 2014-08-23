require 'spec_helper'

describe User, '#before_save' do

  let(:user) { Factory.build(:user) }

  before(:each) do
    User.stub(:hash_password).
         with("password").
         and_return("hashed")
  end

  context 'when password and mail are nil' do
    before { user.password = nil
             user.mail = nil }
    it 'should not hash password' do
      User.should_not_receive(:hash_password)
      user.before_save
    end

    it 'should not hash mail' do
      user.should_not_receive(:mail_hash=)
      user.before_save
    end
  end

  context 'when password exists and mail is nil' do
    before { user.password = 'password'
             user.mail = nil }
    it 'should hash password' do
      user.should_receive(:hashed_password=).with("hashed")
      user.before_save
    end

    it 'should not hash email' do
      user.should_not_receive(:mail_hash=)
      user.before_save
    end
  end

  context 'when both password and mail exist' do
    before { user.password = 'password'
             user.mail = 'mail'
             Digest::MD5.stub(:hexdigest).and_return("hex")
              }
    it 'should hash password' do
      user.should_receive(:hashed_password=).with("hashed")
      user.before_save
    end

    it 'should hash email' do
      user.should_receive(:mail_hash=).with("hex")
      user.before_save
    end
  end

end
