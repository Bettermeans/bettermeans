require 'spec_helper'

describe HomeController, '#index' do

  let(:user) { Factory.create(:user) }

  context 'when current user is logged in' do
    before do
      login_as(user)
    end

    it 'redirects to welcome/index' do
      get(:index)
      response.should redirect_to(:controller => 'welcome', :action => 'index')
    end
  end

  context 'when current user is not logged in' do
    it 'redirects to /front/index.html' do
      get(:index)
      response.should redirect_to '/front/index.html'
    end
  end

end
