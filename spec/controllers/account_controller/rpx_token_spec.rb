require 'spec_helper'

describe AccountController, '#rpx_token' do

  context "when token is invalid" do
    it "raises an error" do
      RPXNow.should_receive(:user_data).with('blah').and_return(nil)
      expect {
        get(:rpx_token, :token => 'blah')
      }.to raise_error("hackers?")
    end
  end

  context "when token is valid" do
    let(:user_data) {
      {
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
            controller.should_receive(:rand).exactly(8).times.with(25).and_return(5)
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
        context 'if the user is valid' do
          it "sets the identifier for that user" do
            user = Factory.create(:user)
            this_data = { :mail => user.mail, :identifier => 'stuff' }
            RPXNow.stub(:user_data).and_return(this_data.merge(:username => 'steve', :email => user.mail))
            User.stub(:find_by_identifier).and_return(nil)
            get(:rpx_token)
            user.reload.identifier.should == 'stuff'
          end
        end

        context 'if the user is invalid' do
          it "does not set the identifier for that user" do
            user = Factory.create(:user)
            user.update_attribute(:mail, 'invalid_mail')
            this_data = { :mail => user.mail, :identifier => 'stuff' }
            RPXNow.stub(:user_data).and_return(this_data.merge(:username => 'steve', :email => user.mail))
            User.stub(:find_by_identifier).and_return(nil)
            get(:rpx_token)
            user.reload.identifier.should be_nil
          end
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
            this_data = user_data.merge(:username => "'\"<> stuff", :name => "what what")
            RPXNow.stub(:user_data).and_return(this_data)
          end

          context "if a user does not exist for the *really* clean version" do
            it "assigns the *really* clean username as the user's login" do
              User.should_receive(:find_by_login).with("_____stuff").and_return(false)
              get(:rpx_token)
              assigns(:user).login.should == "_____stuff"
            end
          end

          context "if a user already exists for the *really* clean version" do
            it "assigns a cleaned up version of the name as their login" do
              User.stub(:find_by_login).and_return(true)
              User.should_receive(:find_by_login).with("what_what").and_return(false)
              get(:rpx_token)
              assigns(:user).login.should == "what_what"
            end
          end

          context "if a user already exists for both versions of the login" do
            it "assigns the user's email as their login" do
              User.stub(:find_by_login).and_return(true, true)
              get(:rpx_token)
              assigns(:user).login.should == "wah@wah.com"
            end
          end
        end

        context "when the invitation exists" do
          it "assigns invitation.new_mail as the user mail" do
            session[:invitation_token] = 'blah'
            invitation = Factory.create(:invitation)
            Invitation.stub(:find_by_token).and_return(invitation)
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

          it "adds the user in the session for debugging" do
            begin
              get(:rpx_token)
            rescue RuntimeError
            end
            session[:debug_user].should =~ /User/
          end

          it "adds the rpx data hash in the session for debugging" do
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

    context "when a user is found by the identifier" do
      context "when the invitation exists" do
        it "assigns invitation.new_mail as the user mail" do
          user = Factory.create(:user, :identifier => 'stuff')
          this_data = user_data.merge(:identifier => 'stuff')
          RPXNow.stub(:user_data).and_return(this_data)
          session[:invitation_token] = 'blah'
          invitation = Factory(:invitation, :new_mail => 'something')
          Invitation.stub(:find_by_token).and_return(invitation)
          get(:rpx_token)
          invitation.reload.new_mail.should == assigns(:user).mail
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
        assigns(:user).active?.should be true
      end

      it "authenticates with a reactivation message" do
        mock_invitation = mock(:update_attributes => nil)
        mock_invitation.should_receive(:accept).with(@user)
        Invitation.should_receive(:find_by_token).with('blah').twice.and_return(mock_invitation)
        get(:rpx_token)
        response.session[:flash][:notice].should =~ /reactivated/
      end
    end

    context "when user is active" do
      before :each do
        this_data = { :firstname => 'steve', :mail => 'stuff@stuff.com', :identifier => 'something' }
        @user = Factory.create(:user, this_data)
        session[:invitation_token] = 'blah'
      end

      it "authenticates without a message" do
        mock_invitation = mock(:update_attributes => nil)
        mock_invitation.should_receive(:accept).with(@user)
        Invitation.should_receive(:find_by_token).with('blah').twice.and_return(mock_invitation)
        get(:rpx_token)
      end
    end
  end
end

