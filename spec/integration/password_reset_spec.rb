require 'integration/integration_helper'

feature 'password reset', :js => true do

  let(:user) { Factory.create(:user, :status => 1, :password => 'goodpass') }

  scenario 'a user can reset their password' do
    visit '/login'
    click_link 'Lost password'
    fill_in('Email *', :with => user.mail)
    click_button('Submit')
    # worker = Delayed::Worker.new(:max_priority => nil, :min_priority => nil, :quiet => true)
    # worker.send(:work_off)
    # ActionMailer::Base.deliveries.length.should == 1
  end

end
