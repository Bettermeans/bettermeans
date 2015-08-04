require 'spec_helper'

describe ApplicationController, '#invalid_authenticity_token' do

  class InvalidAuthenticityTokenSpecController < ApplicationController
    def index
      invalid_authenticity_token
    end
  end

  controller_name :invalid_authenticity_token_spec

  it 'redirects to back_url given one' do
    get(:index, :back_url => 'foo')
    response.should redirect_to('foo')
  end

  it 'redirects to home path' do
    get(:index)
    response.should redirect_to(home_path)
  end

end
