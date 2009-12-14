class OpenIdAuthenticationNonces < ActiveRecord::Base
end

# == Schema Information
#
# Table name: open_id_authentication_nonces
#
#  id         :integer         not null, primary key
#  timestamp  :integer         not null
#  server_url :string(255)
#  salt       :string(255)     not null
#

