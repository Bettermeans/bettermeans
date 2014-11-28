require 'spec_helper'

describe ApplicationController, '#set_user_ip' do

  integrate_views(false)

  class SetUserIpSpecController < ApplicationController
    def index
    end
  end

  controller_name :set_user_ip_spec

  context 'when there is no :client_ip in the session' do
    it 'sets it from the request headers' do
      session[:client_ip] = nil
      @request.env['X-Real-Ip'] = 'what what'
      get(:index)
      session[:client_ip].should == 'what what'
    end
  end

  context 'when there is a :client_ip in the session' do
    it 'keeps the existing :client_ip' do
      session[:client_ip] = 'who who'
      @request.env['X-Real-Ip'] = 'what what'
      get(:index)
      session[:client_ip].should == 'who who'
    end
  end

end
