require 'spec_helper'

describe ApplicationController, '#accept_key_auth_actions' do

  integrate_views(false)

  class AcceptKeyAuthActionsSpecController < ApplicationController
    def index
      @auth_actions = accept_key_auth_actions
    end
  end

  controller_name :accept_key_auth_actions_spec

  it 'returns the list of auth actions when defined' do
    controller.class.accept_key_auth(:foo)
    get(:index)
    assigns(:auth_actions).should == ['foo']
  end

  it 'returns an empty array when no actions are defined' do
    # adding it in the previous spec persists here
    controller.class.inheritable_attributes.delete('accept_key_auth_actions')
    get(:index)
    assigns(:auth_actions).should == []
  end

end
