class DynamicScriptsController < ApplicationController
  def dashboard    
    respond_to do |format|
      format.js { render :layout => false, :type => 'text/javascript'  }      
    end    
  end
end
