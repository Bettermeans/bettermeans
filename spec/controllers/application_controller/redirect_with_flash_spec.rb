require 'spec_helper'

describe ApplicationController, '#redirect_with_flash' do

  integrate_views(false)

  class RedirectWithFlashSpecController < ApplicationController
    def index
      redirect_with_flash(:foo, 'got stuff', signin_path)
    end
  end

  controller_name :redirect_with_flash_spec

  it 'sets a flash message' do
    get(:index)
    flash[:foo].should == 'got stuff'
  end

  it 'redirects to the given path' do
    get(:index)
    response.should redirect_to(signin_path)
  end

end
