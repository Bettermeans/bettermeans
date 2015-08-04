require 'spec_helper'

describe ApplicationController, '#redirect_back_or_default' do

  class RedirectBackOrDefaultSpecController < ApplicationController
    def index
      redirect_back_or_default('foo')
    end
  end

  controller_name :redirect_back_or_default_spec

  it 'redirects to default when back_url is blank' do
    get(:index)
    response.should redirect_to('foo')
  end

  it 'redirects to default when back_url includes "/home/"' do
    get(:index, :back_url => 'foo/home/foo')
    response.should redirect_to('foo')
  end

  it 'redirects to default when back_url includes "/front/"' do
    get(:index, :back_url => 'foo/front/foo')
    response.should redirect_to('foo')
  end

  it 'redirects to default when back_url path includes "login"' do
    get(:index, :back_url => 'foo/loginfoo')
    response.should redirect_to('foo')
  end

  it 'redirects to default when back_url path includes "account/register"' do
    get(:index, :back_url => 'foo/account/registerfoo')
    response.should redirect_to('foo')
  end

  it 'redirects to default when back_url is not relative and different host' do
    get(:index, :back_url => 'https://www.google.com')
    response.should redirect_to('foo')
  end

  it 'redirects to default when back_url is not a valid URI' do
    get(:index, :back_url => '\flargh')
    response.should redirect_to('foo')
  end

  it 'redirects to relative back_url' do
    get(:index, :back_url => '/whatevs')
    response.should redirect_to('/whatevs')
  end

  it 'redirects to back_url when host matches request' do
    get(:index, :back_url => 'http://test.host/whatevs')
    response.should redirect_to('http://test.host/whatevs')
  end

end
