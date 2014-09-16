require 'spec_helper'

describe IssuesController, '#datadump' do

  integrate_views

  let(:user) { Factory.create(:user) }

  before(:each) do
    login_as(user)
  end

  it 'assigns an array of issues associated with the user' do
    project1 = Factory.create(:project, :owner => user)
    project2 = Factory.create(:project, :owner => user)
    project3 = Factory.create(:project)

    issue1 = Factory.create(:issue, :project => project1)
    issue2 = Factory.create(:issue, :project => project2)
    issue3 = Factory.create(:issue, :project => project3)

    get(:datadump)

    assigns(:issues).sort_by(&:id).should == [issue1, issue2]
  end

end
