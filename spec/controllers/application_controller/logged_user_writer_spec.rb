require 'spec_helper'

describe ApplicationController, '#logged_user=' do

  integrate_views(false)

  let(:user) { Factory.create(:user) }

  class LoggedUserWriterSpecController < ApplicationController
    def index
      if params[:fake_user]
        self.logged_user = 'not a user'
      else
        self.logged_user = User.find_by_id(params[:id])
      end
    end
  end

  controller_name :logged_user_writer_spec

  it 'resets the session, keeping the client_ip' do
    session[:blah] = 'foo'
    session[:client_ip] = 'whatevs'

    get(:index, :id => user.id)

    session[:blah].should be_nil
    session[:client_ip].should == 'whatevs'
  end

  it 'sets the session[:user_id] when the user is real' do
    get(:index, :id => user.id)

    session[:user_id].should == user.id
  end

  it 'sets the current user to anonymous when the user is nil' do
    get(:index, :id => 50123)

    Thread.current[:user].should == User.anonymous
  end

  it 'sets the current user to anonymous when the user is not a user' do
    get(:index, :fake_user => true)

    Thread.current[:user].should == User.anonymous
  end

end
