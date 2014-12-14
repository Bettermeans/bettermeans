require 'spec_helper'

describe Invitation, '#accept' do

  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }
  let(:invitation) { Factory.create(:invitation, :project => project) }

  context 'when invitation project is not root' do
    let(:root_project) { Factory.create(:project) }
    before(:each) do
      project.set_parent!(root_project)
      invitation.accept(user)
    end

    it 'adds the user to the project' do
      project.all_members.first.user.should == user
    end

    it 'adds the user to the root project' do
      root_project.all_members.first.user.should == user
    end
  end
end
