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

  describe '#update' do
    describe "with valid params" do
      before(:each) do
        @credit = mock_model(Credit, :update_attributes => true)
        Credit.stub!(:find).with("52").and_return(@credit)
      end

      it "finds a credit object" do
        Credit.should_receive(:find).with("52").and_return(@credit)
      end

      it "updates the credit object" do
        @credit.should_receive(:update_attributes).and_return(true)
      end
    end

    describe "with invalid params" do
    end
  end

end
