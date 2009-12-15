class OpenIdAuthenticationAssociation < ActiveRecord::Base
end

# == Schema Information
#
# Table name: open_id_authentication_associations
#
#  id         :integer         not null, primary key
#  issued     :integer
#  lifetime   :integer
#  handle     :string(255)
#  assoc_type :string(255)
#  server_url :binary
#  secret     :binary
#

