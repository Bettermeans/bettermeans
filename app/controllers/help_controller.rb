class HelpController < ApplicationController
  def show
    @help_key = params[:key]
  end
end
