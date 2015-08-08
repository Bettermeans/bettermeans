require 'spec_helper'

describe ApplicationController, '#per_page_option' do

  integrate_views(false)

  class PerPageOptionSpecController < ApplicationController
    def index
      @per_page_option = per_page_option
    end
  end

  controller_name :per_page_option_spec

  before(:each) do
    Setting['per_page_options'] = '5,10,15,20'
  end

  context 'when params[:per_page] is in the allowed per page options' do
    it 'returns the integer value of params[:per_page]' do
      get(:index, :per_page => 15)
      assigns(:per_page_option).should == 15
    end

    it 'sets :per_page in the session' do
      get(:index, :per_page => 15)
      session[:per_page].should == 15
    end
  end

  it 'returns the default value when params[:per_page] is not in the list' do
    get(:index, :per_page => 52)
    assigns(:per_page_option).should == 5
  end

  it 'returns session[:per_page] when set' do
    session[:per_page] = 52
    get(:index)
    assigns(:per_page_option).should == 52
  end

  it 'returns the first pre-set per page option' do
    get(:index)
    assigns(:per_page_option).should == 5
  end

  it 'returns 25 when there is no pre-set per page option' do
    Setting['per_page_options'] = ''
    get(:index)
    assigns(:per_page_option).should == 25
  end
end
