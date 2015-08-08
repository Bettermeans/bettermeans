require 'spec_helper'

describe AccountController, "#login" do

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
      controller.logged_user = user
      controller.current_user.should == user
      session[:user_id] = user.id
      get(:login)
      controller.current_user.should == User.anonymous
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
    let(:new_user) { Factory.build(:user, :password => nil) }
    let(:user) { Factory.create(:user) }

    context "when openid" do

      before(:each) do
        Setting.stub(:openid?).and_return(true)
        controller.stub(:using_open_id?).and_return(true)
      end

      context 'when authentication succeeds' do
        before(:each) do
          registration = {
            'nickname' => 'my_nick',
            'email' => 'me@me.com',
            'fullname' => 'boogers mcgee'
          }

          mock_result = mock("result", :successful? => true)
          controller.should_receive(:authenticate_with_open_id).
            with('blah', :required => [:nickname, :fullname, :email], :return_to => signin_url).
            and_yield(mock_result, "identity_url", registration)
        end

        context 'when the user is a new record' do
          before(:each) do
            User.stub(:find_or_initialize_by_identity_url).and_return(new_user)
          end

          context 'when self_registration is not set' do
            it 'redirects to home_url' do
              Setting.stub(:self_registration?).and_return(false)
              post(:login, :openid_url => 'blah')
              response.should redirect_to(home_url)
            end
          end

          context 'when self_registration is set' do
            before(:each) do
              Setting.stub(:self_registration?).and_return(true)
              Setting.stub(:self_registration).and_return(5)
            end

            it 'sets the login on the user' do
              post(:login, :openid_url => 'blah')
              new_user.login.should == 'my_nick'
            end

            it 'sets the mail on the user' do
              post(:login, :openid_url => 'blah')
              new_user.mail.should == 'me@me.com'
            end

            it 'sets the firstname on the user' do
              post(:login, :openid_url => 'blah')
              new_user.firstname.should == 'boogers'
            end

            it 'sets the lastname on the user' do
              post(:login, :openid_url => 'blah')
              new_user.lastname.should == 'mcgee'
            end

            it 'sets the password on the user' do
              post(:login, :openid_url => 'blah')
              new_user.password.should_not be_nil
            end

            it 'sets the status on the user' do
              post(:login, :openid_url => 'blah')
              new_user.status.should == User::STATUS_REGISTERED
            end

            context 'when self registration is set to "1"' do
              before(:each) do
                Setting.stub(:self_registration).and_return('1')
              end

              context 'when the user is invalid' do
                before(:each) do
                  new_user.stub(:save).and_return(false)
                  post(:login, :openid_url => 'blah')
                end

                it 'sets an instance variable for the user' do
                  assigns(:user).should == new_user
                end

                it 'does not set session[:auth_source_registration]' do
                  session[:auth_source_registration].should be_nil
                end

                it 'renders the "register" template' do
                  response.should render_template('account/register')
                end
              end

              context 'when the token is invalid' do
                before(:each) do
                  mock_token = mock(:save => false)
                  Token.stub(:new).and_return(mock_token)
                  post(:login, :openid_url => 'blah')
                end

                it 'sets an instance variable for the user' do
                  assigns(:user).should == new_user
                end

                it 'does not set session[:auth_source_registration]' do
                  session[:auth_source_registration].should be_nil
                end

                it 'renders the "register" template' do
                  response.should render_template('account/register')
                end
              end

              context 'when the user and token are valid' do
                it 'saves a token for that user' do
                  post(:login, :openid_url => 'blah')
                  new_user.tokens.first.action.should == 'register'
                end

                it 'sends an email' do
                  Mailer.should_receive(:send_later).with(:deliver_register, instance_of(Token))
                  post(:login, :openid_url => 'blah')
                end

                it 'flashes a success message' do
                  flash.stub(:sweep)
                  post(:login, :openid_url => 'blah')
                  flash.now[:success].should =~ /account was successfully created/i
                end

                it 'renders the "login" template' do
                  post(:login, :openid_url => 'blah')
                  response.should render_template('account/login')
                end

                it 'renders the "static" layout' do
                  post(:login, :openid_url => 'blah')
                  response.layout.should == 'layouts/static'
                end
              end
            end

            context 'when self registration is set to "3"' do
              before(:each) do
                Setting.stub(:self_registration).and_return('3')
              end

              context 'when the user is valid' do
                it 'sets the status on the user to active' do
                  post(:login, :openid_url => 'blah')
                  new_user.status.should == User::STATUS_ACTIVE
                end

                it 'sets the last_login_on on the user' do
                  time = Time.now
                  Time.stub(:now).and_return(time)
                  post(:login, :openid_url => 'blah')
                  new_user.last_login_on.should == time
                end

                it 'logs in the user' do
                  post(:login, :openid_url => 'blah')
                  controller.current_user.should == new_user
                end

                it 'logs the login' do
                  session[:client_ip] = 'boogers'
                  Track.should_receive(:log).with(Track::LOGIN, 'boogers')
                  post(:login, :openid_url => 'blah')
                end

                it 'redirects to welcome#index' do
                  post(:login, :openid_url => 'blah')
                  response.should redirect_to(:controller => 'welcome', :action => 'index')
                end

                it 'sets a flash message' do
                  post(:login, :openid_url => 'blah')
                  flash[:success].should =~ /account has been activated/i
                end
              end

              context 'when the user is invalid' do
                before(:each) do
                  new_user.stub(:save).and_return(false)
                  post(:login, :openid_url => 'blah')
                end

                it 'sets an instance variable for the user' do
                  assigns(:user).should == new_user
                end

                it 'does not set session[:auth_source_registration]' do
                  session[:auth_source_registration].should be_nil
                end

                it 'renders the "register" template' do
                  response.should render_template('account/register')
                end
              end
            end

            context 'when self registration is set to anything else' do
              before(:each) do
                Setting.stub(:self_registration).and_return('whocares')
              end

              context 'when the user is valid' do
                it 'sends a mail' do
                  Mailer.should_receive(:send_later).with(:deliver_account_activation_request, new_user)
                  post(:login, :openid_url => 'blah')
                end

                it 'sets a flash notice' do
                  flash.stub(:sweep)
                  post(:login, :openid_url => 'blah')
                  flash[:notice].should =~ /account .* pending/i
                end

                it 'renders the "login" template' do
                  post(:login, :openid_url => 'blah')
                  response.should render_template('account/login')
                end

                it 'renders the "static" layout' do
                  post(:login, :openid_url => 'blah')
                  response.layout.should == 'layouts/static'
                end
              end

              context 'when the user is invalid' do
                before(:each) do
                  new_user.stub(:save).and_return(false)
                  post(:login, :openid_url => 'blah')
                end

                it 'sets an instance variable for the user' do
                  assigns(:user).should == new_user
                end

                it 'does not set session[:auth_source_registration]' do
                  session[:auth_source_registration].should be_nil
                end

                it 'renders the "register" template' do
                  response.should render_template('account/register')
                end
              end
            end
          end
        end

        context 'when the user is not a new record' do
          before(:each) do
            User.stub(:find_or_initialize_by_identity_url).and_return(user)
          end

          context 'when the user is active' do
            it 'tracks the login' do
              session[:client_ip] = 'myip'
              Track.should_receive(:log).with(Track::LOGIN, 'myip')
              post(:login, :openid_url => 'blah')
            end

            context 'when params[:autologin] and autologin is set' do
              before(:each) do
                Setting.stub(:autologin?).and_return(true)
              end

              it 'creates an autologin token' do
                post(:login, :openid_url => 'blah', :autologin => true)
                user.tokens.first.action.should == 'autologin'
              end

              it 'sets an autologin cookie' do
                fake_cookies = {}
                controller.stub(:cookies).and_return(fake_cookies)
                post(:login, :openid_url => 'blah', :autologin => true)
                value = user.tokens.first.value
                fake_cookies[:autologin][:value].should == value
                fake_cookies[:autologin][:expires].should be_close(1.year.from_now, 1)
              end
            end

            it 'redirects to welcome#index' do
              post(:login, :openid_url => 'blah')
              response.should redirect_to(:controller => 'welcome', :action => 'index')
            end
          end

          context 'when the user is not active' do
            before(:each) do
              user.stub(:active?).and_return(false)
            end

            it 'flashes a notice' do
              flash.stub(:sweep)
              post(:login, :openid_url => 'blah')
              flash[:notice].should =~ /account .* pending/i
            end

            it 'renders the "login" template' do
              post(:login, :openid_url => 'blah')
              response.should render_template('account/login')
            end

            it 'renders the "static" layout' do
              post(:login, :openid_url => 'blah')
              response.layout.should == 'layouts/static'
            end
          end
        end
      end
    end

    context "when not openid" do
      context 'when the user is not able to login' do
        before(:each) do
          User.stub(:authenticate).and_return(nil)
        end

        it 'flashes an error' do
          flash.stub(:sweep)
          post(:login, :invitation_token => 'blah')
          flash[:error].should =~ /invalid user or password/i
        end

        it 'renders the "login" template' do
          post(:login, :invitation_token => 'blah')
          response.should render_template('account/login')
        end

        it 'renders the "static" layout' do
          post(:login, :invitation_token => 'blah')
          response.layout.should == 'layouts/static'
        end
      end

      context 'when the user is a new record' do
        before(:each) do
          User.stub(:authenticate).and_return(new_user)
          new_user.auth_source_id = 5
          post(:login, :invitation_token => 'blah')
        end

        it 'sets an instance variable for the user' do
          assigns(:user).should == new_user
        end

        it 'sets the session[:auth_source_options]' do
          response.session['auth_source_registration'].should == { :login => new_user.login, :auth_source_id => 5 }
        end

        it 'renders the "register" template' do
          response.should render_template('account/register')
        end
      end

      context 'when the user is active' do
        before(:each) do
          User.stub(:authenticate).and_return(user)
        end

        it 'logs in the user' do
          post(:login, :invitation_token => 'blah')
          controller.current_user.should == user
        end

        it 'it logs the login' do
          session[:client_ip] = 'stuff'
          Track.should_receive(:log).with(Track::LOGIN, 'stuff')
          post(:login, :invitation_token => 'blah')
        end

        context 'if it finds an invitation' do
          it 'accepts the invitation' do
            mock_invite = mock
            mock_invite.should_receive(:accept).with(user)
            Invitation.stub(:find_by_token).with('blah').and_return(mock_invite)
            post(:login, :invitation_token => 'blah')
          end
        end

        context 'when params[:autologin] and autologin is set' do
          before(:each) do
            Setting.stub(:autologin?).and_return(true)
          end

          it 'creates an autologin token' do
            post(:login, :openid_url => 'blah', :autologin => true)
            user.tokens.first.action.should == 'autologin'
          end

          it 'sets an autologin cookie' do
            fake_cookies = {}
            controller.stub(:cookies).and_return(fake_cookies)
            post(:login, :openid_url => 'blah', :autologin => true)
            value = user.tokens.first.value
            fake_cookies[:autologin][:value].should == value
            fake_cookies[:autologin][:expires].should be_close(1.year.from_now, 1)
          end
        end

        it 'redirects to welcome#index' do
          post(:login, :invitation_token => 'blah')
          response.should redirect_to(:controller => 'welcome', :action => 'index')
        end
      end

      context 'otherwise' do
        before(:each) do
          user.stub(:active?).and_return(false)
          User.stub(:authenticate).and_return(user)
        end

        it 'flashes an error' do
          flash.stub(:sweep)
          post(:login, :invitation_token => 'blah')
          flash[:error].should =~ /account has not yet been activated/i
        end

        it 'renders 500 status' do
          post(:login, :invitation_token => 'blah')
          response.status.should == '500 Internal Server Error'
        end
      end
    end
  end

end
