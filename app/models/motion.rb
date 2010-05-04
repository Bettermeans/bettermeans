class Motion < ActiveRecord::Base  
  STATE_ACTIVE = 0
  STATE_PASSED = 1
  STATE_DEFEATED = 2
  STATE_CANCELED = 3
  
  TYPE_CONSENSUS = 1 #Any disagree defeats the motion
  TYPE_MAJORITY = 2 #Any block defeats the motion
  TYPE_CREDIT = 3 #Majority vote, 1 credit = 1 vote
  
  VISIBLE_BOARD = 1 #Only board can see this motion
  VISIBLE_CORE = 2 #Only core & board
  VISIBLE_MEMBER = 3 #All members, core and board
  VISIBLE_CONTRIBUTER = 4 #Everyone who is a part of the enterprise
  VISIBLE_USER = 5 #Everyone on the platform
  
  BINDING_BOARD = 1 #Only board votes are binding
  BINDING_CORE = 2 #Only core & board votes are binding
  BINDING_MEMBER = 3 #All members, core and board votes are binding
  BINDING_CONTRIBUTER = 4 #Everyone who is a part of the enterprise has a binding vote
  BINDING_USER = 5 #Everyone on the platform has a binding vote
  
  VARIATION_GENERAL = 0 #Miscellaneous issues
  VARIATION_EXTRAORDINARY = 1 #e.g. sell a company!
  VARIATION_NEW_MEMBER = 2
  VARIATION_NEW_CORE = 3
  VARIATION_FIRE_MEMBER = 4
  VARIATION_FIRE_CORE = 5
  VARIATION_BOARD_PUBLIC = 6
  VARIATION_BOARD_PRIVATE = 7
  VARIATION_HOURLY_TYPE = 8
  
  serialize :params

  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :concerned_user, :class_name => 'User', :foreign_key => 'concerned_user_id'
  belongs_to :project
  has_many :motion_votes
  belongs_to :topic, :class_name => 'Message', :foreign_key => 'topic_id'
  
  named_scope :allactive, :conditions => ["state = #{STATE_ACTIVE}", Time.new.to_date]
  
  before_create :set_values, :create_forum_topic
  after_create :announce
  
  def ended?
    !(self.state == STATE_ACTIVE)
  end
  
  def set_values
    self.title = Setting::MOTIONS[self.variation]["Title"]
    self.binding_level = Setting::MOTIONS[self.variation]["Binding"]
    self.visibility_level = Setting::MOTIONS[self.variation]["Visible"]
    self.motion_type = Setting::MOTIONS[self.variation]["Type"]
    self.ends_on = Time.new().advance :days => Setting::MOTIONS[self.variation]["Days"].to_f
    self.state = STATE_ACTIVE
    self.author = User.sysadmin if self.author.nil? 
  end
  
  def create_forum_topic
  
    main_board = Board.first(:conditions => {:project_id => self.project, :name => Setting.forum_name})

    motion_topic = Message.create! :board_id => main_board.id,
                 :subject => self.title,                      
                 :content => self.description,
                 :author_id => self.author_id
                 
    self.topic_id = motion_topic.id
    
  end
  
  def visibility_level_description
    Role.first(:conditions => {:position => self.visibility_level}).name
  end
  
  def binding_level_description
    Role.first(:conditions => {:position => self.binding_level}).name
  end
  
  def announce
    admin = User.sysadmin
    
    self.project.members.each do |member|
      user = member.user
      Notification.create :recipient_id => user.id,
                          :variation => 'motion_started',
                          :params => {:motion_title => self.title, :motion_description => self.description, :enterprise_id => self.project.root.id}, 
                          :sender_id => self.author_id,
                          :source_id => self.id,
                          :expiration => self.ends_on if user.allowed_to_see_motion?(self)
    end
  end
  
  def announce_passed
    admin = User.sysadmin
    
    News.create :project_id => self.project.id,
                :title => "New motion passed: #{self.title}",
                :summary => "#{self.title} has passed",
                :description => "#{self.description}",
                :author_id => admin
  end

end











# == Schema Information
#
# Table name: motions
#
#  id                  :integer         not null, primary key
#  project_id          :integer
#  title               :string(255)
#  description         :text
#  variation           :string(255)
#  params              :text
#  motion_type         :integer
#  state               :integer
#  created_at          :datetime
#  updated_at          :datetime
#  ends_on             :date
#  topic_id            :integer
#  author_id           :integer
#  agree               :integer         default(0)
#  disagree            :integer         default(0)
#  agree_total         :integer         default(0)
#  agree_nonbind       :integer         default(0)
#  disagree_nonbind    :integer         default(0)
#  agree_total_nonbind :integer         default(0)
#  concerned_user_id   :integer
#

