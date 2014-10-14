require 'spec_helper'

describe CreditsController do

  before :each do
    controller.stub(:require_admin)
  end

  it 'instantiates a new instance of credit' do
    get(:new)
    assigns(:credit).should be_an_instance_of(Credit)
    assigns(:credit).should be_new_record
  end

end
