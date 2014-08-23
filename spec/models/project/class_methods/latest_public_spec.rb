require 'spec_helper'

describe Project, '.latest_public' do

  it "only queries for root projects, i.e., projects that are not children of other projects" do
    fake_named_scope = mock("Fake named scope")
    fake_named_scope.stub(:find).with(any_args)

    Project.should_receive(:all_roots).once.and_return fake_named_scope
    # Project.should_not_receive(:all_children)

    Project.latest_public fake_admin
  end

  def fake_admin
    result = mock("A fake admin")
    # result.stub(:admin?).and_return true
    result
  end

end
