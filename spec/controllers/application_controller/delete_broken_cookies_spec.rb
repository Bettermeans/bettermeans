require 'spec_helper'

describe ApplicationController, '#delete_broken_cookies' do

  integrate_views(false)

  class TestController < ApplicationController
    def index
    end
  end

  controller_name :test

  context 'when the cookie is invalid' do
    before(:each) do
      cookies['_redmine_session'] = 'what what'
    end

    it 'deletes the cookie' do
      get(:index)
      cookies['_redmine_session'].should be_nil
    end

    it 'redirects to home_path' do
      get(:index)
      response.should redirect_to(home_path)
    end
  end

  context 'when the cookie is valid' do
    before(:each) do
      cookies['_redmine_session'] = 'valid -- cookie'
    end

    it 'continues rendering' do
      get(:index)
      response.should render_template('test/index')
    end
  end

  context 'when there is no cookie' do
    it 'continues rendering' do
      get(:index)
      response.should render_template('test/index')
    end
  end

end
