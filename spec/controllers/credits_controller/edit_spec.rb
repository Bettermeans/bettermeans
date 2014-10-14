require 'spec_helper'

describe CreditsController, '#edit' do

  let(:admin_user) { Factory.create(:admin_user) }
  let(:credit) { Factory.create(:credit) }

  before(:each) { login_as(admin_user) }

  it 'finds a credit object' do
    get(:edit, :id => credit.id)
    assigns(:credit).should == credit
  end

end
