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
  
  serialize :params

  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :project
  has_many :motion_votes
  belongs_to :topic, :class_name => 'Message', :foreign_key => 'topic_id'
  
  # named_scope :active, :conditions => ["state = 0"]
  # Returns all active, non responded, non-expired notifications
  named_scope :allactive, :conditions => ["state = #{STATE_ACTIVE}", Time.new.to_date]
  
  def set_values
    self.title = Setting::MOTIONS[self.variation]["Title"]
    self.binding_level = Setting::MOTIONS[self.variation]["Binding"]
    self.visibility_level = Setting::MOTIONS[self.variation]["Visible"]
    self.motion_type = Setting::MOTIONS[self.variation]["Type"]
    self.ends_on = Time.new().advance :days => Setting::MOTIONS[self.variation]["Days"].to_f
  end
  
  def before_create
    self.author = User.sysadmin if self.author.nil? 
  
    main_board = Board.first(:conditions => {:project_id => self.project, :name => Setting.forum_name})

    motion_topic = Message.create! :board_id => main_board.id,
                 :subject => self.title,                      
                 :content => self.description,
                 :author_id => self.author_id
                 
    self.topic_id = motion_topic.id
    
  end

end







# == Schema Information
#
# Table name: motions
#
#  id               :integer         not null, primary key
#  project_id       :integer
#  title            :string(255)
#  description      :text
#  params           :text
#  variation        :integer         default(0)
#  motion_type      :integer         default(2)
#  visibility_level :integer         default(5)
#  binding_level    :integer         default(5)
#  state            :integer         default(0)
#  created_at       :datetime
#  updated_at       :datetime
#  ends_on          :date
#  topic_id         :integer
#

