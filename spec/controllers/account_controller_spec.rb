require 'spec_helper'

describe AccountController,"#login" do

  it "should redirect to https on http request" do
    @request.env['HTTPS'] = nil
    get :login
    response.should redirect_to "https://" + @request.host + @request.request_uri
  end

end
