class Motion < ActiveRecord::Base  
  include ActionController::UrlWriter
  STATE_ACTIVE = 0
  STATE_PASSED = 1
  STATE_DEFEATED = 2
  STATE_CANCELED = 3
  
  TYPE_CONSENSUS = 1 #Any disagree defeats the motion
  TYPE_MAJORITY = 2 #Any block defeats the motion
  TYPE_SHARE = 3 #Majority vote, 1 share = 1 vote
  
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
  named_scope :viewable_by, lambda { |*level| 
    {:conditions => "visibility_level >= #{level}", :order => "updated_at DESC"}
  }
  
  before_create :set_values, :create_forum_topic
  after_create :announce
  after_save :close
  
  def active?
    self.state == STATE_ACTIVE
  end
  
  def ended?
    
    return true if Time.now > self.ends_on
    
    case self.motion_type
    when TYPE_CONSENSUS #if we don't have a disagreement, and have more than half binding agreement, we're a go
      if self.disagree == 0 && self.agree_total > self.project.role_and_above_count(self.binding_level).to_f / 2
        return true;
      end
    when TYPE_MAJORITY #if have majority binding agreement, and no blocking, we're a go
      if self.disagree < 500 && self.agree_total > self.project.role_and_above_count(self.binding_level).to_f / 2
          return true;
      end
    end

    return false
    
  end
  
  # true if variation requires a concerned user to be specified
  def concerns_someone?
    return (self.variation == VARIATION_NEW_MEMBER || self.variation == VARIATION_NEW_CORE || self.variation == VARIATION_FIRE_MEMBER || self.variation == VARIATION_FIRE_CORE)
  end
  
  #Checks if motion has reached end date, calculates vote and takes action
  def close
    return if !active?
    return if !ended?
    return if self.motion_votes.nil?
    
    case self.motion_type
    when TYPE_CONSENSUS
      if self.disagree > 0
        self.state = STATE_DEFEATED
      else
        self.state = STATE_PASSED
      end
    when TYPE_MAJORITY
      if self.disagree > 500 || self.agree_total < 1
          self.state = STATE_DEFEATED
        else
          self.state = STATE_PASSED
        end
    when TYPE_SHARE
      if (self.agree + (self.disagree * -1)) * Setting::SHARE_MAJORIY_MOTION_RATIO < self.agree
          self.state = STATE_DEFEATED
        else
          self.state = STATE_PASSED
        end
    end
    
    self.save
    announce_passed if self.state == STATE_PASSED
    execute_action if self.state == STATE_PASSED

  end
  
  def set_values
    self.title = Setting::MOTIONS[self.variation]["Title"]
    self.binding_level = Setting::MOTIONS[self.variation]["Binding"]
    self.visibility_level = Setting::MOTIONS[self.variation]["Visible"]
    self.motion_type = Setting::MOTIONS[self.variation]["Type"]
    self.ends_on = Time.new().advance :days => Setting::MOTIONS[self.variation]["Days"].to_f
    self.state = STATE_ACTIVE
    self.author = User.sysadmin if self.author.nil? 
    self.description = self.generate_description
  end
  
  def generate_description
    content = ""
     case self.variation
       when VARIATION_GENERAL
         self.description == "" ? self.title : self.description
       when VARIATION_EXTRAORDINARY
         self.description == "" ? self.title : self.description
       when VARIATION_NEW_MEMBER
         content << l(:text_member_nomination, :user => self.concerned_user.name, :enterprise => self.project.name)
       when VARIATION_NEW_CORE
         content << l(:text_core_member_nomination, :user => self.concerned_user.name, :enterprise => self.project.name)
       when VARIATION_FIRE_MEMBER
         content << l(:text_member_removal, :user => self.concerned_user.name, :enterprise => self.project.name)
       when VARIATION_FIRE_CORE
         content << l(:text_core_member_removal, :user => self.concerned_user.name, :enterprise => self.project.name)
       when VARIATION_BOARD_PUBLIC
         self.description == "" ? self.title : self.description
       when VARIATION_BOARD_PRIVATE
         self.description == "" ? self.title : self.description
       when VARIATION_HOURLY_TYPE
         self.description == "" ? self.title : self.description
     end
  end
  
  def self.eligible_users(variation,project_id)
    
    project = Project.find(project_id)
    @concerned_user_list = ""
    case variation
      when VARIATION_NEW_MEMBER
        @concerned_user_list = project.contributor_list
      when VARIATION_NEW_CORE
        @concerned_user_list = project.member_list
      when VARIATION_FIRE_MEMBER
        @concerned_user_list = project.member_list
      when VARIATION_FIRE_CORE
        @concerned_user_list = project.core_member_list
    end
    @concerned_user_list
  end
  
  def create_forum_topic
  
    main_board = Board.first(:conditions => {:project_id => self.project, :name => Setting.forum_name})

    motion_topic = Message.create! :board_id => main_board.id,
                 :subject => self.title,                      
                 :content => self.description,
                 :author_id => self.author_id
                 
    self.topic_id = motion_topic.id
    self.save
    
  end
  
  def visibility_level_description
    Role.first(:conditions => {:position => self.visibility_level}).name
  end
  
  def binding_level_description
    Role.first(:conditions => {:position => self.binding_level}).name
  end
  
  def execute_action
    return if self.state != STATE_PASSED
    case self.variation
      when VARIATION_GENERAL
      when VARIATION_EXTRAORDINARY
      when VARIATION_NEW_MEMBER
        return if !self.concerned_user.contributor_of?(self.project)
        self.concerned_user.add_as_member(self.project)
      when VARIATION_NEW_CORE
        return if !self.concerned_user.member_of?(self.project)
        self.concerned_user.add_as_core(self.project)
      when VARIATION_FIRE_MEMBER
        return if !self.concerned_user.member_of?(self.project)
        self.concerned_user.add_as_contributor(self.project)
      when VARIATION_FIRE_CORE
        return if !self.concerned_user.core_member_of?(self.project)
        self.concerned_user.add_as_member(self.project)
      when VARIATION_BOARD_PUBLIC
      when VARIATION_BOARD_PRIVATE
      when VARIATION_HOURLY_TYPE
    end
  end
  
  def announce
    admin = User.sysadmin
    
    self.project.all_members.each do |member|
      user = member.user
      Notification.create :recipient_id => user.id,
                          :variation => 'motion_started',
                          :params => {:motion_title => self.title, :motion_description => self.description, :enterprise_id => self.project.root.id}, 
                          :sender_id => self.author_id,
                          :source_id => self.id,
                          :source_type => "Motion",
                          :expiration => self.ends_on if user.allowed_to_see_motion?(self) unless self.concerned_user_id == user.id
    end
  end
  
  def announce_passed
    admin = User.sysadmin
    
    # def self.write_single_activity_stream(actor,actor_name,object,object_name,verb,activity, status, indirect_object, options)
    LogActivityStreams.write_single_activity_stream(User.sysadmin,:name,self,:title,:passed_a,:motions, 0, nil,{})
    
    News.create :project_id => self.project.id,
                :title => "Passed! #{self.title}",
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
#  params              :text
#  variation           :integer         default(0)
#  motion_type         :integer         default(2)
#  visibility_level    :integer         default(5)
#  binding_level       :integer         default(5)
#  state               :integer         default(0)
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

