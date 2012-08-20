require 'spec_helper'

describe AccountController do
  before :each do
    @request.env['HTTPS'] = 'on'
  end

  describe "#login" do

    context "on an http request" do
      it "redirects to https" do
        @request.env['HTTPS'] = nil
        get(:login)
        url = "https://#{@request.host}#{@request.request_uri}"
        response.should redirect_to url
      end
    end

    context "given an invitation token in the session" do
      context "with invitation token passed as a param" do
        it "assigns the params version to @invitation_token" do
          session[:invitation_token] = 'stuff'
          get(:login, :invitation_token => 'blah')
          assigns(:invitation_token).should == 'blah'
        end
      end

      context "without invitiation token passed as param" do
        it "assigns the session version to @invitation_token" do
          session[:invitation_token] = 'stuff'
          get(:login)
          assigns(:invitation_token).should == 'stuff'
        end
      end
    end

    context "when request is a GET" do
      it "logs out the user" do
        user = Factory.create(:user)
        User.current = user
        get(:login)
        User.current.should == User.anonymous
      end

      it "sets the session invitation_token" do
        get(:login, :invitation_token => 'blah')
        session[:invitation_token].should == 'blah'
      end

      it "renders the static layout" do
        get(:login)
        response.layout.should == 'layouts/static'
      end
    end

    context "when request is not a GET" do
      context "when openid" do
        it "authenticates via openid" do
          Setting.should_receive(:openid?).and_return(true)
          controller.should_receive(:using_open_id?).and_return(true)
          controller.should_receive(:open_id_authenticate).with('blah')
          post(:login, :openid_url => 'blah')
        end
      end

      context "when not openid" do
        it "authenticates via password" do
          controller.should_receive(:password_authentication).with('blah')
          post(:login, :invitation_token => 'blah')
        end
      end
    end

  end

end
