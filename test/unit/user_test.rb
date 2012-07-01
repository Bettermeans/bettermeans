# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper.rb'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :members, :projects, :roles, :member_roles

  def setup
    @admin = User.find(1)
    @jsmith = User.find(2)
    @dlopper = User.find(3)
  end

  test 'object_daddy creation' do
    User.generate_with_protected!(:firstname => 'Testing connection')
    User.generate_with_protected!(:firstname => 'Testing connection')
    assert_equal 2, User.count(:all, :conditions => {:firstname => 'Testing connection'})
  end
  
  def test_truth
    assert_kind_of User, @jsmith
  end

  def test_create
    user = User.new(:firstname => "new", :lastname => "user", :mail => "newuser@somenet.foo")
    
    user.login = "jsmith"
    user.password, user.password_confirmation = "password", "password"
    # login uniqueness
    assert !user.save
    assert_equal 1, user.errors.count
  
    user.login = "newuser"
    user.password, user.password_confirmation = "passwd", "password"
    # password confirmation
    assert !user.save
    assert_equal 1, user.errors.count

    user.password, user.password_confirmation = "password", "password"
    assert user.save
  end
  
  def test_mail_uniqueness_should_not_be_case_sensitive
    u = User.new(:firstname => "new", :lastname => "user", :mail => "newuser@somenet.foo")
    u.login = 'newuser1'
    u.password, u.password_confirmation = "password", "password"
    assert u.save
    
    u = User.new(:firstname => "new", :lastname => "user", :mail => "newUser@Somenet.foo")
    u.login = 'newuser2'
    u.password, u.password_confirmation = "password", "password"
    assert !u.save
    assert_equal I18n.translate('activerecord.errors.messages.taken'), u.errors.on(:mail)
  end

  def test_update
    assert_equal "admin", @admin.login
    @admin.login = "john"
    assert @admin.save, @admin.errors.full_messages.join("; ")
    @admin.reload
    assert_equal "john", @admin.login
  end
  
  def test_destroy
    User.find(2).destroy
    assert_nil User.find_by_id(2)
    assert Member.find_all_by_user_id(2).empty?
  end
  
  def test_validate
    @admin.login = ""
    assert !@admin.save
    assert_equal 1, @admin.errors.count
  end
  
  def test_password
    user = User.try_to_login("admin", "admin")
    assert_kind_of User, user
    assert_equal "admin", user.login
    user.password = "hello"
    assert user.save
    
    user = User.try_to_login("admin", "hello")
    assert_kind_of User, user
    assert_equal "admin", user.login
    assert_equal User.hash_password("hello"), user.hashed_password    
  end
  
  def test_name_format
    assert_equal 'Smith, John', @jsmith.name(:lastname_coma_firstname)
    Setting.user_format = :firstname_lastname
    assert_equal 'John Smith', @jsmith.reload.name
    Setting.user_format = :username
    assert_equal 'jsmith', @jsmith.reload.name
  end
  
  def test_lock
    user = User.try_to_login("jsmith", "jsmith")
    assert_equal @jsmith, user
    
    @jsmith.status = User::STATUS_LOCKED
    assert @jsmith.save
    
    user = User.try_to_login("jsmith", "jsmith")
    assert_equal nil, user  
  end
  
  def test_create_anonymous
    AnonymousUser.delete_all
    anon = User.anonymous
    assert !anon.new_record?
    assert_kind_of AnonymousUser, anon
  end

  #should_have_one :rss_token

  def test_rss_key
    assert_nil @jsmith.rss_token
    key = @jsmith.rss_key
    assert_equal 40, key.length
    
    @jsmith.reload
    assert_equal key, @jsmith.rss_key
  end

  
  #should_have_one :api_token

  context "User#api_key" do
    should "generate a new one if the user doesn't have one" do
      user = User.generate_with_protected!(:api_token => nil)
      assert_nil user.api_token

      key = user.api_key
      assert_equal 40, key.length
      user.reload
      assert_equal key, user.api_key
    end

    should "return the existing api token value" do
      user = User.generate_with_protected!
      token = Token.generate!(:action => 'api')
      user.api_token = token
      assert user.save
      
      assert_equal token.value, user.api_key
    end
  end

  context "User#find_by_api_key" do
    should "return nil if no matching key is found" do
      assert_nil User.find_by_api_key('zzzzzzzzz')
    end

    should "return nil if the key is found for an inactive user" do
      user = User.generate_with_protected!(:status => User::STATUS_LOCKED)
      token = Token.generate!(:action => 'api')
      user.api_token = token
      user.save

      assert_nil User.find_by_api_key(token.value)
    end

    should "return the user if the key is found for an active user" do
      user = User.generate_with_protected!(:status => User::STATUS_ACTIVE)
      token = Token.generate!(:action => 'api')
      user.api_token = token
      user.save
      
      assert_equal user, User.find_by_api_key(token.value)
    end
  end

  def test_roles_for_project
    # user with a role
    roles = @jsmith.roles_for_project(Project.find(1))
    assert_kind_of Role, roles.first
    assert_equal "Manager", roles.first.name
    
    # user with no role
    assert_nil @dlopper.roles_for_project(Project.find(2)).detect {|role| role.community_member?}
  end
  
  def test_mail_notification_all
    @jsmith.mail_notification = true
    @jsmith.notified_project_ids = []
    @jsmith.save
    @jsmith.reload
    assert @jsmith.projects.first.recipients.include?(@jsmith.mail)
  end
  
  def test_mail_notification_selected
    @jsmith.mail_notification = false
    @jsmith.notified_project_ids = [1]
    @jsmith.save
    @jsmith.reload
    assert Project.find(1).recipients.include?(@jsmith.mail)
  end
  
  def test_mail_notification_none
    @jsmith.mail_notification = false
    @jsmith.notified_project_ids = []
    @jsmith.save
    @jsmith.reload
    assert !@jsmith.projects.first.recipients.include?(@jsmith.mail)
  end
  
  def test_comments_sorting_preference
    assert !@jsmith.wants_comments_in_reverse_order?
    @jsmith.pref.comments_sorting = 'asc'
    assert !@jsmith.wants_comments_in_reverse_order?
    @jsmith.pref.comments_sorting = 'desc'
    assert @jsmith.wants_comments_in_reverse_order?
  end
  
  def test_find_by_mail_should_be_case_insensitive
    u = User.find_by_mail('JSmith@somenet.foo')
    assert_not_nil u
    assert_equal 'jsmith@somenet.foo', u.mail
  end
  
  def test_random_password
    u = User.new
    u.random_password
    assert !u.password.blank?
    assert !u.password_confirmation.blank?
  end
  
  if Object.const_defined?(:OpenID)
    
  def test_setting_identity_url
    normalized_open_id_url = 'http://example.com/'
    u = User.new( :identity_url => 'http://example.com/' )
    assert_equal normalized_open_id_url, u.identity_url
  end

  def test_setting_identity_url_without_trailing_slash
    normalized_open_id_url = 'http://example.com/'
    u = User.new( :identity_url => 'http://example.com' )
    assert_equal normalized_open_id_url, u.identity_url
  end

  def test_setting_identity_url_without_protocol
    normalized_open_id_url = 'http://example.com/'
    u = User.new( :identity_url => 'example.com' )
    assert_equal normalized_open_id_url, u.identity_url
  end
    
  def test_setting_blank_identity_url
    u = User.new( :identity_url => 'example.com' )
    u.identity_url = ''
    assert u.identity_url.blank?
  end
    
  def test_setting_invalid_identity_url
    u = User.new( :identity_url => 'this is not an openid url' )
    assert u.identity_url.blank?
  end
  
  else
    puts "Skipping openid tests."
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

