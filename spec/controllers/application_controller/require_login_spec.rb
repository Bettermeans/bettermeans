require 'spec_helper'

describe ApplicationController, '#require_login' do

  class RequireLoginSpecController < ApplicationController
    before_filter :require_login
  end

  controller_name :require_login_spec

  context 'when the request is not a GET' do
    it 'redirects with only select params' do
      post(:index, :foo => :bar, :id => 15, :project_id => 52)
      back_url = controller.url_for({
        :controller => :require_login_spec,
        :action => :index,
        :id => 15,
        :project_id => 52,
      })
      response.should redirect_to({
        :controller => :account,
        :action => :login,
        :back_url => back_url,
      })
    end
  end

end
