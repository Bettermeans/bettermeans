require 'spec_helper'

describe ApplicationController, '#data_admin_logged_in?' do

  integrate_views(false)

  class DataAdminLoggedInPredicateSpecController < ApplicationController
    def index
      @admin_logged_in = data_admin_logged_in?
    end
  end

  controller_name :data_admin_logged_in_predicate_spec

  it 'returns false' do
    get(:index)
    assigns(:admin_logged_in).should be false
  end

end
