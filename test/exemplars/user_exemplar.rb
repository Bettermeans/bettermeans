class User < Principal
  generator_for :login, :method => :next_login
  generator_for :mail, :method => :next_email
  generator_for :firstname, :method => :next_firstname
  generator_for :lastname, :method => :next_lastname

  def self.next_login
    @gen_login ||= 'user1'
    @gen_login.succ!
    @gen_login
  end

  def self.next_email
    @last_email ||= 'user1'
    @last_email.succ!
    "#{@last_email}@example.com"
  end

  def self.next_firstname
    @last_firstname ||= 'Bob'
    @last_firstname.succ!
    @last_firstname
  end

  def self.next_lastname
    @last_lastname ||= 'Doe'
    @last_lastname.succ!
    @last_lastname
  end
end










# == Schema Information
#
# Table name: users
#
#  id                    :integer         not null, primary key
#  login                 :string(30)      default(""), not null
#  hashed_password       :string(40)      default(""), not null
#  firstname             :string(30)      default(""), not null
#  lastname              :string(30)      default(""), not null
#  mail                  :string(60)      default(""), not null
#  mail_notification     :boolean         default(TRUE), not null
#  admin                 :boolean         default(FALSE), not null
#  status                :integer         default(1), not null
#  last_login_on         :datetime
#  language              :string(5)       default("")
#  auth_source_id        :integer
#  created_at            :datetime
#  updated_at            :datetime
#  type                  :string(255)
#  identity_url          :string(255)
#  activity_stream_token :string(255)
#  identifier            :string(255)
#  plan_id               :integer         default(1)
#  b_first_name          :string(255)
#  b_last_name           :string(255)
#  b_address1            :string(255)
#  b_zip                 :string(255)
#  b_country             :string(255)
#  b_phone               :string(255)
#  b_ip_address          :string(255)
#  b_cc_last_four        :string(255)
#  b_cc_type             :string(255)
#  b_cc_month            :integer
#  b_cc_year             :integer
#  mail_hash             :string(255)
#  trial_expires_on      :datetime
#

