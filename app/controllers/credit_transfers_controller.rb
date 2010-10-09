# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

class CreditTransfersController < ApplicationController
  
  def index
    @credit_transfers = CreditTransfer.find(:all, :conditions => "sender_id = #{User.current.id} or recipient_id = #{User.current.id}", :include => [:sender, :recipient, :project],:order => "created_at DESC")
    project_id_array = Credit.find(:all,:conditions => {:settled_on => nil, :owner_id => User.current.id}).group_by(&:project_id).collect{|p| p[0]}
    @project_list = Project.find(:all, :conditions => "id IN (#{project_id_array.join(",")})").sort! {|x,y| x.name <=> y.name }
    if params[:selected_project_id]
      @selected_project_id = Integer(params[:selected_project_id])
    end
  end
  
  def create
    recipient = User.find(params[:credit_transfer][:recipient_id])
    project = Project.find(params[:credit_transfer][:project_id])
    
    total_transferred = Credit.transfer User.current, recipient, project, Float(params[:amount]), params[:note]

    respond_to do |format|
      flash.now[:notice] = "Successfully transferred #{total_transferred} credits to #{recipient.name}"
      format.html { redirect_to :action => "index" }
      flash.keep
    end
  rescue Exception => e
    flash.now[:error] = l(:text_failed_to_transfer) + e.message
    redirect_to :action => "index"
    flash.keep
  end
  
    
  
  def eligible_recipients
    @project = Project.find(params[:project_id])
    @total_credits = Credit.round(Credit.sum(:amount, :conditions => {:settled_on => nil, :owner_id => User.current.id, :project_id => @project.id}))
    @user_list = ""
    @user_list = @project.root.all_members
    
    #remove current user from list
    @user_list.delete_if { |a| a.user_id == User.current.id}
    
    render :layout => false
  end
  
  
end