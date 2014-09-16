require 'spec_helper'

describe RecurlyNotificationsController, '#listen' do

  integrate_views

  let(:user) { Factory.create(:user) }
  let(:plan) { Factory.create(:plan, :code => 52) }
  let(:subscription_params) do
    {
      :subscription => { :plan => { :plan_code => plan.code } },
      :account => { :account_code => user.id },
    }
  end

  context 'when updated subscription notification' do
    before(:each) do
      post(:listen, :updated_subscription_notification => subscription_params)
    end

    it 'updates the plan on the user' do
      user.reload.plan.should == plan
    end

    it 'sets user to have active subscription' do
      user.reload.active_subscription.should be true
    end
  end

  context 'when new subscription notification' do
    before(:each) do
      post(:listen, :new_subscription_notification => subscription_params)
    end

    it 'updates the plan on the user' do
      user.reload.plan.should == plan
    end

    it 'sets user to have active subscription' do
      user.reload.active_subscription.should be true
    end
  end

  context 'when expired subscription notification' do
    before(:each) do
      post(:listen, :expired_subscription_notification => subscription_params)
    end

    it 'sets the user to free plan' do
      user.reload.plan.should == Plan.free
    end

    it 'sets user to not have active subscription' do
      user.reload.active_subscription.should be false
    end
  end

end
