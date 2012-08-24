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
      before :each do
        Setting.stub(:openid?).and_return(true)
        controller.stub(:using_open_id?).and_return(true)
      end

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

  describe '#rpx_token' do
    context "when token is invalid" do
      it "raises an error" do
        RPXNow.should_receive(:user_data).with('blah').and_return(nil)
        expect {
          get(:rpx_token, :token => 'blah')
        }.to raise_error("hackers?")
      end
    end

    context "when token is valid" do
      let(:user_data) { {
          :email => 'wah@wah.com',
          :identifier => 'something',
          :name => 'steve',
          :username => 'stevinator'
        }
      }
      before :each do
        RPXNow.stub(:user_data).and_return(user_data)
      end

      context "when there's a session[:invitation_token]" do
        before :each do
          session[:invitation_token] = 'blah'
        end

        it "looks up the invitation" do
          Invitation.should_receive(:find_by_token).with('blah').twice
          get(:rpx_token)
        end

        it "sets @invitation_token" do
          get(:rpx_token)
          assigns(:invitation_token).should == 'blah'
        end

        context "when there's no data[:email]" do
          context "when an invitation was found" do
            it "sets a new user instance with the invitation mail" do
              this_data = user_data
              this_data.delete(:email)
              RPXNow.stub(:user_data).and_return(this_data)
              invitation = Factory.create(:invitation, :mail => 'stuff@stuff.com')
              Invitation.stub(:find_by_token).and_return(invitation)
              this_data = { :firstname => 'steve', :mail => 'stuff@stuff.com', :identifier => 'something' }
              user = Factory.build(:user, this_data)
              User.should_receive(:new).with(this_data).and_return(user)
              get(:rpx_token)
            end
          end

          context "when an invitation was not found" do
            it "sets the mail to a random mail" do
              this_data = user_data
              this_data.delete(:email)
              RPXNow.stub(:user_data).and_return(this_data)
              get(:rpx_token)
              assigns(:user).mail.should =~ /\w+_noemail@bettermeans\.com/
            end
          end
        end
      end

      context "when a user is not found for the identifier" do
        it "tries to look up the user by mail" do
          User.stub(:find_by_identifier).and_return(nil)
          User.should_receive(:find_by_mail)
          get(:rpx_token)
        end

        context "if the user is found by mail" do
          it "sets the identifier for that user" do
            this_data = { :firstname => 'steve', :mail => 'stuff@stuff.com', :identifier => 'stuff' }
            user = Factory.build(:user, this_data)
            User.stub(:find_by_identifier).and_return(nil)
            User.should_receive(:find_by_mail).and_return(user)
            get(:rpx_token)
            user.reload.identifier.should == 'something'
          end
        end

        context "if the user is not found by mail" do
          context "if RPX provides a name" do
            it "initializes a user with firstname set to the given name" do
              get(:rpx_token)
              assigns(:user).firstname.should == 'steve'
            end
          end

          context "if RPX does not provide a name" do
            it "initializes a user with firstname set to the username" do
              this_data = user_data
              this_data.delete(:name)
              RPXNow.stub(:user_data).and_return(this_data)
              get(:rpx_token)
              assigns(:user).firstname.should == 'stevinator'
            end
          end

          context "if RPX provides an email" do
            it "initializes a user with mail set to the email" do
              get(:rpx_token)
              assigns(:user).mail.should == 'wah@wah.com'
            end
          end

          context "if RPX does not provide an email" do
            before :each do
              this_data = user_data
              this_data.delete(:email)
              RPXNow.stub(:user_data).and_return(this_data)
            end

            context "if an invitation was found" do
              it "initializes a user with mail set to the invitation_mail" do
                invitation = Factory.create(:invitation, :mail => 'stuff@stuff.com')
                Invitation.stub(:find_by_token).and_return(invitation)
                session[:invitation_token] = 'stuff'
                get(:rpx_token)
                assigns(:user).mail.should == 'stuff@stuff.com'
              end
            end

            context "if an invitation was not found" do
              it "initializes a user with mail set to a random email" do
                get(:rpx_token)
                assigns(:user).mail.should =~ /_noemail@bettermeans.com/
              end
            end
          end

          it "initializes a new user with the identifier given by RPX" do
            get(:rpx_token)
            assigns(:user).identifier.should == 'something'
          end

          context "when cleaning up the username" do
            before :each do
              this_data = user_data.merge(:username => "'\"<> stuff", :name => 'what what')
              RPXNow.stub(:user_data).and_return(this_data)
            end

            context "if a user does not exist for the *really* clean version" do
              it "assigns the *really* clean username as the user's login" do
                User.stub(:find_by_login).and_return(false)
                get(:rpx_token)
                assigns(:user).login.should == "_____stuff"
              end
            end

            context "if a user already exists for the *really* clean version" do
              it "assigns a cleaned up version of the name as their login" do
                User.stub(:find_by_login).and_return(true, false)
                get(:rpx_token)
                assigns(:user).login.should == "what_what"
              end
            end

            context "if a user already exists for both versions of the login" do
              it "assigns the users email as their login" do
                User.stub(:find_by_login).and_return(true, true)
                get(:rpx_token)
                assigns(:user).login.should == "wah@wah.com"
              end
            end
          end

          context "when the invitation exists" do
            it "assigns invitation.new_mail as the user mail" do
              session[:invitation_token] = 'blah'
              invitation = Factory(:invitation)
              Invitation.stub(:find_by_token).and_return(invitation)
              controller.stub(:successful_authentication)
              get(:rpx_token)
              invitation.reload.new_mail.should == assigns(:user).mail
            end
          end

          context "when the user does not validate" do
            before :each do
              this_data = user_data.merge(:username => "admin", :name => 'what what')
              RPXNow.stub(:user_data).and_return(this_data)
              User.stub(:find_by_login).and_return(false)
            end

            it "puts the user in the session for debugging" do
              begin
                get(:rpx_token)
              rescue RuntimeError
              end
              session[:debug_user].should =~ /User/
            end

            it "puts the rpx data hash in the session for debugging" do
              begin
                get(:rpx_token)
              rescue RuntimeError
              end
              session[:debug_data].should =~ /admin/
            end

            it "raises an error" do
              expect {
                get(:rpx_token)
              }.to raise_error("Couldn't create new account")
            end
          end
        end
      end

      context "when user is not active" do
        before :each do
          this_data = { :status => 2, :firstname => 'steve', :mail => 'stuff@stuff.com', :identifier => 'something' }
          @user = Factory.create(:user, this_data)
          session[:invitation_token] = 'blah'
        end

        it "reactivates the user" do
          get(:rpx_token)
          assigns(:user).should be_active
        end

        it "authenticates with a reactivation message" do
          controller.should_receive(:successful_authentication).with(@user, 'blah', /reactivated/)
          get(:rpx_token)
        end
      end

      context "when user is active" do
        before :each do
          this_data = { :firstname => 'steve', :mail => 'stuff@stuff.com', :identifier => 'something' }
          @user = Factory.create(:user, this_data)
          session[:invitation_token] = 'blah'
        end

        it "authenticates without a message" do
          controller.should_receive(:successful_authentication).with(@user, 'blah', nil)
          get(:rpx_token)
        end
      end
    end
  end

end
