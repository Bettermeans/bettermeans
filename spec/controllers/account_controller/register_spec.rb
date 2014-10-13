require 'spec_helper'

describe AccountController, '#register' do

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
      assigns(:user).admin?.should be false
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
          mock_plan = mock("plan", :free? => false)
          mock_user = mock("user", :plan_id => 5, :plan => mock_plan, :trial_expires_on= => nil, :admin= => nil, :status= => nil, :login= => nil, :auth_source_id= => nil, :save => true, :password= => nil, :password_confirmation= => nil, :last_login_on= => nil)
          mock_user.should_receive(:plan_id=)
          User.stub(:new).and_return(mock_user)
          user_params = {
            :mail => 'bill@bill.com',
            :firstname => 'bill',
            :login => 'stuff',
          }

          post_params = {
            :user => user_params,
            :invitation_token => invitation.token,
          }

          post(:register, post_params)
          response.should redirect_to(:controller => 'welcome', :action => 'index')
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
