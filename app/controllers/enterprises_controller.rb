class EnterprisesController < ApplicationController
  layout 'activescaffold'
  active_scaffold
  
  def conditions_for_collection
    'users.id <> -1'
  end
end