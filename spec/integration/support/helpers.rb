module HelperMethods

  def request_login_as(user)
    visit '/'
    page.should have_content('login')
    click_link 'login'
    fill_in('username', :with => user.login)
    fill_in('password', :with => user.password)
    click_button('Login »')
    page.should have_content('MY WORKSTREAMS')
    page.should have_content('Sign out')
  end

end

Spec::Runner.configuration.include(HelperMethods)
