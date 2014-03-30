module HelperMethods

  def login_as(user)
    visit '/'
    click_link 'login'
    fill_in('username', :with => user.login)
    fill_in('password', :with => user.password)
    click_button('Login »')
  end

end

Spec::Runner.configuration.include(HelperMethods)
