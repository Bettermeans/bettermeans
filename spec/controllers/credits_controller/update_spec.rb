require 'spec_helper'

describe CreditsController, '#update' do

  before :each do
    controller.stub(:require_admin)
  end

  describe 'with valid params' do
    before(:each) do
      @mock_credit = mock_model(Credit, :update_attributes => true, :project_id => 5)
    end

    it 'finds a credit object' do
      Credit.should_receive(:find).with('52').and_return(@mock_credit)
      put(:update, :id => 52)
      assigns(:credit).should == @mock_credit
    end
  end

end
