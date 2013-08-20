require 'spec_helper'

describe CreditsController do

  before :each do
    @request.env['HTTPS'] = 'on'
    controller.stub(:require_admin)
    @credit = Credit.new
  end

  describe '#show' do
    it 'finds a credit object' do
      Credit.should_receive(:find).with('52').and_return('fake credit')
      get(:show, :id => 52)
      assigns(:credit).should == 'fake credit'
    end
  end

  describe "#new" do
    it 'instantiates a new instance of credit' do
      get(:new)
      assigns(:credit).should be_an_instance_of(Credit)
      assigns(:credit).should be_new_record
    end
  end

  describe '#edit' do
    it 'finds a credit object' do
      Credit.should_receive(:find).with('52').and_return('fake credit')
      get(:edit, :id => 52)
      assigns(:credit).should == 'fake credit'
    end
  end

end
