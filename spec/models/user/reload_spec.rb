require 'spec_helper'

describe User, '#reload' do

  let(:user) { Factory.create(:user, :firstname => "Al", :lastname => "Ja") }

  it "resets the name" do
    user.firstname = "Sally"
    user.lastname = "Boo"
    user.name.should == "Sally Boo"
    user.reload
    user.name.should == "Al Ja"
  end

  it "resets attributes from the database" do
    user.firstname = "Sally"
    user.lastname = "Boo"
    user.reload
    user.firstname.should == "Al"
    user.lastname.should == "Ja"
  end
end
