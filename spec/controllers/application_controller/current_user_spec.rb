require 'spec_helper'

describe ApplicationController, '#current_user' do

  let(:user) { Factory.create(:user) }

  integrate_views(false)

  class CurrentUserSpecController < ApplicationController
    def index
    end
  end

  controller_name :current_user_spec

  it 'returns the currently logged in user' do
    session[:user_id] = user.id
    get(:index)
    controller.current_user.should == user
  end

end
