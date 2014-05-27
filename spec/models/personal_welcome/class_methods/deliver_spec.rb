require 'spec_helper'

describe PersonalWelcome, '.deliver' do

  let(:user) { Factory.create(:user) }
  let!(:project) { Factory.create(:project, :owner => user) }

  it 'creates a new personal welcome for each projects owner' do
    expect {
      PersonalWelcome.deliver
    }.to change(PersonalWelcome, :count).by(1)
    PersonalWelcome.last.user.should == user
  end

  context 'when a personal welcome already exists for a projects owner' do
    it 'does not create a new personal welcome' do
      PersonalWelcome.create(:user => user)
      expect {
        PersonalWelcome.deliver
      }.to_not change(PersonalWelcome, :count)
    end
  end

  context 'when a project was created more than a week ago' do
    it 'does not create a new personal welcome' do
      project.update_attributes!(:created_at => 1.month.ago)
      expect {
        PersonalWelcome.deliver
      }.to_not change(PersonalWelcome, :count)
    end
  end

end
