require 'spec_helper'

describe AccountController do
  # TODO: can't do this yet, as successful_authentication is stubbed:
  # integrate_views

  describe '#logout' do
    let(:user) { Factory.create(:user) }

    before :each do
      controller.logged_user = user
      @token = Token.create(:user => user, :action => 'autologin')
      request.cookies["autologin"] = @token.value
      get(:logout)
    end

    it 'deletes the autologin cookie' do
      # for some reason both request.cookies and response.cookies are nil regardless
      controller.send(:cookies)[:autologin].should_not be
    end

    it 'deletes all autologin tokens for the given user' do
      Token.find_by_id(@token.id).should_not be
    end

    it 'sets the currently logged in user to nil' do
      controller.current_user.should be_anonymous
    end

    it 'redirects to the homepage' do
      response.should redirect_to home_url
    end
  end

  describe '#lost_password' do
    before :each do
      Setting.stub(:lost_password?).and_return(true)
    end

    context 'when lost_password setting is not set' do
      it 'redirects to home_url' do
        Setting.stub(:lost_password?).and_return(false)
        get(:lost_password)
        response.should redirect_to(home_url)
      end
    end

    context "when there is params[:token]" do
      let(:user) { Factory.create(:user) }
      let(:token) { Factory.create(:token, :user => user, :action => 'recovery') }

      context "if a Token doesn't exist for that param" do
        it "redirects to home_url" do
          get(:lost_password, :token => 'bad_token')
          response.should redirect_to(home_url)
        end
      end

      context "if a Token exists, but is expired" do
        it "redirects to home_url" do
          token.stub(:expired?).and_return(true)
          Token.stub(:find_by_action_and_value).and_return(token)
          get(:lost_password, :token => token.value)
          response.should redirect_to(home_url)
        end
      end

      context "if the request is a POST" do
        context 'when the token is not valid' do
          it 'redirects to home_url' do
            post(:lost_password, :token => 'trash')
            response.should redirect_to(home_url)
          end
        end

        context "if the user is valid" do
          before :each do
            post(:lost_password, :token => token.value,
                                 :new_password => 'new_password',
                                 :new_password_confirmation => 'new_password')
          end

          it "changes the user's password" do
            User.try_to_login(user.login, 'new_password').should == user
          end

          it "destroys the token" do
            Token.find_by_id(token.id).should_not be
          end

          it "flashes a success message" do
            response.session[:flash][:success].should =~ /updated/
          end

          it "renders the login page" do
            response.should render_template('login')
          end

          it "renders the static layout" do
            response.layout.should == 'layouts/static'
          end
        end

        context "if the user is not valid" do
          before :each do
            post(:lost_password, :token => token.value,
                                 :new_password => 'new_password',
                                 :new_password_confirmation => 'bad_password')
          end

          it "does not change the user" do
            User.try_to_login(user.login, 'new_password').should_not be
          end

          it "renders the password_recovery template" do
            response.should render_template('password_recovery')
          end
        end
      end

      it "renders the password recovery template" do
        get(:lost_password, :token => token.value)
        response.should render_template('account/password_recovery')
      end
    end

    context "when there is no params[:token]" do
      let(:user) { Factory.create(:user) }

      context "if the request is a POST" do
        context "when the mail is invalid" do
          before :each do
            post(:lost_password, :mail => 'bad_mail')
          end

          it "flashes an error message" do
            response.session[:flash][:error].should =~ /unknown/i
          end

          it "renders the lost_password template" do
            response.should render_template('lost_password')
          end
        end

        context "when the user uses an external auth source" do
          before :each do
            user.update_attribute(:auth_source_id, 5)
            post(:lost_password, :mail => user.mail)
          end

          it "flashes an error message" do
            response.session[:flash][:error].should =~ /impossible to change/i
          end

          it "renders the lost_password template" do
            response.should render_template('lost_password')
          end
        end

        context "if  the token is valid" do
          it "saves the token" do
            post(:lost_password, :mail => user.mail)
            user.tokens.find_by_action('recovery').should be
          end

          it "sends an email" do
            Mailer.should_receive(:send_later).with(:deliver_lost_password, instance_of(Token))
            post(:lost_password, :mail => user.mail)
          end

          it "flashes a success message" do
            post(:lost_password, :mail => user.mail)
            response.session[:flash][:success].should =~ /email.*sent/
          end

          it "renders the login page" do
            post(:lost_password, :mail => user.mail)
            response.should render_template('login')
          end

          it "renders the static layout" do
            post(:lost_password, :mail => user.mail)
            response.layout.should == 'layouts/static'
          end
        end
      end

      context "if the request is not a POST" do
        it "renders the lost_password template" do
          get(:lost_password)
          response.should render_template('lost_password')
        end
      end
    end
  end

  describe '#register' do
    context "when there is no self_registration setting or session[:auth_source_registration]" do
      it "redirects to home_url" do
        Setting.stub(:self_registration?).and_return(false)
        get(:register)
        response.should redirect_to(home_url)
      end
    end

    context "when there is a Setting.self_registration" do
      before :each do
        Setting.self_registration = 5
        get(:register)
      end

      it "renders the static layout" do
        response.layout.should == 'layouts/static'
      end

      it "renders the register template" do
        response.should render_template('register')
      end
    end

    context "when there is a session[:auth_source_registration]" do
      before :each do
        Setting.stub(:self_registration?).and_return(false)
        session[:auth_source_registration] = "stuff"
        get(:register)
      end

      it "renders the static layout" do
        response.layout.should == 'layouts/static'
      end

      it "renders the register template" do
        response.should render_template('register')
      end
    end

    context "when given params[:plan]" do
      it "sets the plan id to that of the given plan" do
        plan = Plan.find_by_code(1)
        get(:register, :plan => plan.code)
        assigns(:plan_id).should == plan.id
      end
    end

    context "when given params[:plan_id]" do
      it "sets the plan id to that id" do
        get(:register, :plan_id => "5")
        assigns(:plan_id).should == "5"
      end
    end

    context "when not given a param for plan" do
      it "sets the plan id to the id of the free plan" do
        get(:register)
        assigns(:plan_id).should == Plan.free.id
      end
    end

    context "when the request is GET" do
      it "sets the session[:auth_source_registration] to nil" do
        session[:auth_source_registration] = "something"
        get(:register)
        session[:auth_source_registration].should be_nil
      end

      it "logs out the current user" do
        user = Factory.create(:user)
        controller.logged_user = user
        get(:register)
        controller.current_user.should == User.anonymous
      end

      it "initializes a new user with the default language" do
        Setting.stub(:default_language).and_return('swahili')
        get(:register)
        assigns(:user).language.should == 'swahili'
      end

      context "when there's a params[:invitation_token]" do
        let(:invitation) { Factory.create(:invitation, :mail => 'b@b.com') }

        before :each do
          get(:register, :invitation_token => invitation.token)
        end

        it "sets the session[:invitation_token]" do
          session[:invitation_token].should == invitation.token
        end

        context "when an invitation is found" do
          it "sets the user's mail from the invitation" do
            assigns(:user).mail.should == 'b@b.com'
          end
        end

        it "flashes a message" do
          response.session[:flash][:notice].should =~ /activate your invitation.*invitation_token.*#{invitation.token}'>.*Login here/
        end
      end
    end

    context "when the request is not a GET" do
      let(:invitation) { Factory(:invitation, :mail => 'b@b.com') }

      it "initializes a new user with the given params" do
        post(:register, :user => { :mail => 'bill@bill.com' }, :invitation_token => invitation.token)
        assigns(:user).mail.should == 'bill@bill.com'
      end

      it "sets the user's plan to the one found before" do
        post(:register, :user => { :mail => 'bill@bill.com' }, :invitation_token => invitation.token)
        assigns(:user).plan.should == Plan.find(assigns(:plan_id))
      end

      context "if the user is not on the free plan" do
        it "sets the user's trial to expire 30 days from now" do
          this_time = Time.now
          Time.stub(:now).and_return(this_time)
          plan_id = Plan.find_by_code('1').id
          post(:register, :plan_id => plan_id, :user => { :mail => 'bill@bill.com' }, :invitation_token => invitation.token)
          assigns(:user).trial_expires_on.should == 30.days.from_now
        end
      end

      context "if the user is on the free plan" do
        it "does not set the user's trial to expire 30 days from now" do
          post(:register, :user => { :mail => 'bill@bill.com' }, :invitation_token => invitation.token)
          assigns(:user).trial_expires_on.should_not be
        end
      end

      it "sets the user not to be an admin" do
        post(:register, :user => { :mail => 'bill@bill.com' }, :invitation_token => invitation.token)
        assigns(:user).should_not be_admin
      end

      it "sets the user's status to registered" do
        post(:register, :user => { :mail => 'bill@bill.com' }, :invitation_token => invitation.token)
        assigns(:user).status.should == User::STATUS_REGISTERED
      end

      context "when there's a session[:auth_source_registration]" do
        before :each do
          session[:auth_source_registration] = { :login => 'stuff',
                                                 :auth_source_id => 15 }
        end

        it "sets the user's status to active" do
          post(:register, :user => { :mail => 'bill@bill.com', :firstname => 'bill' },
                          :invitation_token => invitation.token)
          assigns(:user).status.should == User::STATUS_ACTIVE
        end

        it "sets the user's login from the auth hash" do
          post(:register, :user => { :mail => 'bill@bill.com', :firstname => 'bill' },
                          :invitation_token => invitation.token)
          assigns(:user).login.should == 'stuff'
        end

        it "sets the user's auth_source_id from the auth hash" do
          post(:register, :user => { :mail => 'bill@bill.com', :firstname => 'bill' },
                          :invitation_token => invitation.token)
          assigns(:user).auth_source_id.should == 15
        end

        context "if the user is valid" do
          it "sets the session[:auth_source_registration] to nil" do
            post(:register, :user => { :mail => 'bill@bill.com', :firstname => 'bill' },
                            :invitation_token => invitation.token)
            session[:auth_source_registration].should_not be
          end

          it "sets the current user to the assigned user" do
            post(:register, :user => { :mail => 'bill@bill.com', :firstname => 'bill' },
                            :invitation_token => invitation.token)
            controller.current_user.should == assigns(:user)
          end

          it "tracks the login" do
            session[:client_ip] = 5
            Track.should_receive(:log).with(Track::LOGIN, 5)
            post(:register, :user => { :mail => 'bill@bill.com', :firstname => 'bill' },
                            :invitation_token => invitation.token)
          end

          it "redirects to my controller, action account" do
            post(:register, :user => { :mail => 'bill@bill.com', :firstname => 'bill' },
                            :invitation_token => invitation.token)
            response.should redirect_to({ :controller => 'my', :action => 'account' })
          end

          it "flashes a notice" do
            post(:register, :user => { :mail => 'bill@bill.com', :firstname => 'bill' },
                            :invitation_token => invitation.token)
            response.session[:flash][:notice].should =~ /activated/
          end
        end
      end

      context "when there is not a session[:auth_source_registration]" do
        let(:valid_params) {
          {
            :user => {
              :mail => 'bill@bill.com',
              :firstname => 'bill',
              :login => 'stuff'
            },
            :invitation_token => invitation.token
          }
        }

        let(:invalid_params) {
          {
            :user => {
              :mail => 'badmail',
              :firstname => 'bill',
              :login => 'stuff'
            },
            :invitation_token => invitation.token
          }
        }

        it "sets the user's login from the params hash" do
          post(:register, valid_params)
          assigns(:user).login.should == 'stuff'
        end

        it "sets the user's password and password confirmation from the hash" do
          post(:register,valid_params.merge(
            :password => 'blah', :password_confirmation => 'blah'
          ))
          assigns(:user).password.should == 'blah'
          assigns(:user).password_confirmation.should == 'blah'
        end

        context "when Setting.self_registration == '1'" do

          before(:each) do
            Setting.stub(:self_registration).and_return('1')
          end

          it 'sets new_mail on the invitation' do
            post(:register, valid_params)
            invitation.reload.new_mail.should == assigns(:user).mail
          end

          context 'when the invitation mail is the same as the user mail' do
            before(:each) do
              invitation.update_attributes(:mail => 'bill@bill.com')
            end

            context 'when the user is valid' do
              it 'sets the status on the user to active' do
                post(:register, valid_params)
                assigns(:user).status.should == User::STATUS_ACTIVE
              end

              it 'sets the last_login_on on the user' do
                time = Time.now
                Time.stub(:now).and_return(time)
                post(:register, valid_params)
                assigns(:user).last_login_on.should == time
              end

              it 'logs in the user' do
                post(:register, valid_params)
                controller.current_user.should == assigns(:user)
              end

              it 'logs the login' do
                session[:client_ip] = 'boogers'
                Track.should_receive(:log).with(Track::LOGIN, 'boogers')
                post(:register, valid_params)
              end

              it 'redirects to welcome#index' do
                post(:register, valid_params)
                response.should redirect_to(:controller => 'welcome', :action => 'index')
              end

              it 'sets a flash message' do
                post(:register, valid_params)
                flash[:success].should =~ /account has been activated/i
              end
            end

            context 'when the user is invalid' do
              before(:each) do
                invitation.update_attributes(:mail => 'badmail')
              end

              it 'renders the "register" template' do
                post(:register, invalid_params)
                response.should render_template('account/register')
              end

              it 'renders the "static" layout' do
                post(:register, invalid_params)
                response.layout.should == 'layouts/static'
              end
            end
          end

          context 'when the user and token are valid' do
            it 'saves a token for that user' do
              post(:register, valid_params)
              assigns(:user).tokens.first.action.should == 'register'
            end

            it 'sends an email' do
              Mailer.should_receive(:send_later).with(:deliver_register, instance_of(Token))
              post(:register, valid_params)
            end

            it 'flashes a success message' do
              flash.stub(:sweep)
              post(:register, valid_params)
              flash.now[:success].should =~ /account was successfully created/i
            end

            it 'renders the "login" template' do
              post(:register, valid_params)
              response.should render_template('account/login')
            end

            it 'renders the "static" layout' do
              post(:register, valid_params)
              response.layout.should == 'layouts/static'
            end
          end

          context 'when the user is invalid' do
            it 'renders the "register" template' do
              post(:register, invalid_params)
              response.should render_template('account/register')
            end

            it 'renders the "static" layout' do
              post(:register, invalid_params)
              response.layout.should == 'layouts/static'
            end
          end

          context 'when the token is invalid' do
            before(:each) do
              mock_token = mock(:save => false)
              Token.stub(:new).and_return(mock_token)
              post(:register, valid_params)
            end

            it 'renders the "register" template' do
              response.should render_template('account/register')
            end

            it 'renders the "static" layout' do
              response.layout.should == 'layouts/static'
            end
          end
        end

        context "when Setting.self_registration == '3'" do
          before(:each) do
            Setting.stub(:self_registration).and_return('3')
          end

          context 'when the user is valid' do
            it 'sets the status on the user to active' do
              post(:register, valid_params)
              assigns(:user).status.should == User::STATUS_ACTIVE
            end

            it 'sets the last_login_on on the user' do
              time = Time.now
              Time.stub(:now).and_return(time)
              post(:register, valid_params)
              assigns(:user).last_login_on.should == time
            end

            it 'logs in the user' do
              post(:register, valid_params)
              controller.current_user.should == assigns(:user)
            end

            it 'logs the login' do
              session[:client_ip] = 'boogers'
              Track.should_receive(:log).with(Track::LOGIN, 'boogers')
              post(:register, valid_params)
            end

            it 'redirects to welcome#index' do
              post(:register, valid_params)
              response.should redirect_to(:controller => 'welcome', :action => 'index')
            end

            it 'sets a flash message' do
              post(:register, valid_params)
              flash[:success].should =~ /account has been activated/i
            end
          end

          context 'when the user is invalid' do
            before(:each) do
              invitation.update_attributes(:mail => 'badmail')
            end

            it 'renders the "register" template' do
              post(:register, invalid_params)
              response.should render_template('account/register')
            end

            it 'renders the "static" layout' do
              post(:register, invalid_params)
              response.layout.should == 'layouts/static'
            end
          end

          it "registers automatically" do
            Setting.stub(:self_registration).and_return('3')
            mock_plan = mock("plan", :free? => false)
            mock_user = mock("user", :plan_id => 5, :plan => mock_plan, :trial_expires_on= => nil, :admin= => nil, :status= => nil, :login= => nil, :auth_source_id= => nil, :save => true, :password= => nil, :password_confirmation= => nil, :last_login_on= => nil)
            mock_user.should_receive(:plan_id=)
            User.stub(:new).and_return(mock_user)
            controller.should_receive(:redirect_to).with(:controller => 'welcome', :action => 'index')

            post(:register, :user => { :mail => 'bill@bill.com',
                                        :firstname => 'bill',
                                        :login => 'stuff' },
                            :invitation_token => invitation.token)
          end
        end

        context "when Setting.self_registration == anything else" do
          before(:each) do
            Setting.stub(:self_registration).and_return('pie')
          end

          context 'if the user is valid' do
            it 'sends a mail' do
              Mailer.should_receive(:send_later).
                with(:deliver_account_activation_request, instance_of(User))
              post(:register, valid_params)
            end

            it 'flashes a notice' do
              flash.stub(:sweep)
              post(:register, valid_params)
              flash[:notice].should =~ /account .*pending/i
            end

            it 'renders the "login" template' do
              post(:register, valid_params)
              response.should render_template('account/login')
            end

            it 'renders the "static" layout' do
              post(:register, valid_params)
              response.layout.should == 'layouts/static'
            end
          end
        end
      end
    end
  end

  describe '#activate' do
    context "if self_registration is not set" do
      it "redirects to home_url" do
        user = Factory.create(:user, :status => User::STATUS_REGISTERED)
        token = Token.create(:user => user, :action => 'register')
        Setting.stub(:self_registration?).and_return(false)
        get(:activate, :token => token.value)
        response.should redirect_to(home_url)
      end
    end

    context "if params[:token] is not present" do
      it "redirects to home_url" do
        user = Factory.create(:user, :status => User::STATUS_REGISTERED)
        token = Token.create(:user => user, :action => 'register')
        Setting.stub(:self_registration?).and_return(true)
        get(:activate)
        response.should redirect_to(home_url)
      end
    end

    context "if the token is not found" do
      it "redirects to home_url" do
        Setting.stub(:self_registration?).and_return(true)
        get(:activate, :token => 'blah')
        response.should redirect_to(home_url)
      end
    end

    context "if the token is found but expired" do
      it "redirects to home_url" do
        Setting.stub(:self_registration?).and_return(true)
        user = Factory.create(:user, :status => User::STATUS_REGISTERED)
        token = Token.create(:user => user, :action => 'register')
        token.stub(:expired?).and_return(true)
        Token.should_receive(:find_by_action_and_value).
          with('register', token.value).
          and_return(token)
        get(:activate, :token => token.value)
        response.should redirect_to(home_url)
      end
    end

    context "if the user is not registered" do
      it "redirects to home_url" do
        Setting.stub(:self_registration?).and_return(true)
        user = Factory.create(:user, :status => User::STATUS_ACTIVE)
        token = Token.create(:user => user, :action => 'register')
        get(:activate, :token => token.value)
        response.should redirect_to(home_url)
      end
    end

    context "if the user is valid" do
      let(:user) { Factory.create(:user, :status => User::STATUS_REGISTERED) }
      let(:token) { Token.create(:user => user, :action => 'register') }

      before :each do
        Setting.stub(:self_registration?).and_return(true)
      end

      it "changes the user's status to active" do
        get(:activate, :token => token.value)
        user.reload.status.should == User::STATUS_ACTIVE
      end

      it "destroys the token" do
        get(:activate, :token => token.value)
        Token.find_by_id(token.id).should_not be
      end

      it "authenticates the user" do
        controller.should_receive(:successful_authentication).with(user)
        get(:activate, :token => token.value)
      end
    end

    context "if the user is invalid" do
      let(:user) { Factory.create(:user, :status => User::STATUS_REGISTERED) }
      let(:token) { Token.create(:user => user, :action => 'register') }

      before :each do
        Setting.stub(:self_registration?).and_return(true)
        user.stub(:save).and_return(false)
        token.stub(:user).and_return(user)
        Token.stub(:find_by_action_and_value).and_return(token)
        get(:activate, :token => token.value)
      end

      it "renders the login page" do
        response.should render_template('login')
      end

      it "renders the static layout" do
        response.layout.should == 'layouts/static'
      end
    end
  end

  describe '#cancel' do
    let(:user) { Factory.create(:user, :mail => 'bob@bob.com') }

    before :each do
      User.stub(:current).and_return(user)
    end

    it "cancels the current user's account" do
      get(:cancel)
      user.reload.should be_canceled
    end

    it "renders an account canceled message" do
      get(:cancel)
      response.should render_template ''
      response.session[:flash][:notice].should =~ /canceled/
    end
  end

  # private method, no state
  describe '#password_authentication' do
    let(:user) { Factory.create(:user) }
    before :each do
      controller.stub(:render)
    end

    it "tries to login the user" do
      User.should_receive(:try_to_login).with('bill', 'bill_password')
      controller.stub(:params).and_return({ :username => 'bill', :password => 'bill_password' })
      controller.send(:password_authentication)
    end

    context "when the user does not login properly" do
      it "goes through the invalid credentials flow" do
        User.stub(:try_to_login)
        controller.should_receive(:render).with(:layout => 'static')
        controller.send(:password_authentication)
      end
    end

    context "when the user is a new record" do
      it "goes through the onthefly creation failed flow" do
        user.login = 'bill'
        user.auth_source_id = 15
        user.stub(:new_record?).and_return(true)
        User.stub(:try_to_login).and_return(user)
        controller.should_receive(:onthefly_creation_failed).with(user, { :login => 'bill', :auth_source_id => 15 })
        controller.send(:password_authentication)
      end
    end

    context "when the user is not active" do
      it "goes through the inactive_user flow" do
        user.stub(:active?).and_return(false)
        User.stub(:try_to_login).and_return(user)
        controller.should_receive(:inactive_user)
        controller.send(:password_authentication)
      end
    end

    context "otherwise" do
      context "when the user is active" do
        it "goes through the successful_authentication flow" do
          user.stub(:active?).and_return(true)
          User.stub(:try_to_login).and_return(user)
          controller.should_receive(:successful_authentication).with(user, 'token')
          controller.send(:password_authentication, 'token')
          controller.should_receive(:successful_authentication).with(user, nil)
          controller.send(:password_authentication)
        end
      end
    end
  end

end
