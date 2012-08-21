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
              mock_invitation = mock()
              mock_invitation.stub(:new_mail=)
              mock_invitation.stub(:save)
              mock_invitation.stub(:accept)
              mock_invitation.stub(:mail).and_return('stuff@stuff.com')
              Invitation.stub(:find_by_token).and_return(mock_invitation)
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
              assigns(:user).mail.should =~ /noemail@bettermeans\.com/
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

        context "if the user is found" do
          it "sets the identifier for that user" do
            this_data = { :firstname => 'steve', :mail => 'stuff@stuff.com', :identifier => 'stuff' }
            user = Factory.build(:user, this_data)
            User.stub(:find_by_identifier).and_return(nil)
            User.should_receive(:find_by_mail).and_return(user)
            get(:rpx_token)
            user.reload.identifier.should == 'something'
          end
        end

        context "if the user is not found" do
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
                mock_invitation = mock()
                mock_invitation.stub(:new_mail=)
                mock_invitation.stub(:save)
                mock_invitation.stub(:accept)
                mock_invitation.stub(:mail).and_return('stuff@stuff.com')
                Invitation.stub(:find_by_token).and_return(mock_invitation)
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

          it "sets initializes a new user with the identifier given by RPX" do
            get(:rpx_token)
            assigns(:user).identifier.should == 'something'
          end
        end
      end
    end
  end

end
