require 'spec_helper'

describe AccountController, '#lost_password' do

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
          User.authenticate(user.login, 'new_password').should == user
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
          User.authenticate(user.login, 'new_password').should_not be
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

      context "when the user is valid" do
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

    context "when the request is not a POST" do
      it "renders the lost_password template" do
        get(:lost_password)
        response.should render_template('lost_password')
      end
    end
  end

end
