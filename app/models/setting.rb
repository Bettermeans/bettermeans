# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class Setting < ActiveRecord::Base
  
  APP_TITLE = "BetterMeans.com"
  
  TEXT_FORMATTING = "textile"

  MAXIMUM_CONCURRENT_REQUESTS = 4 #Maximum issues same pereson can own at the same time per workstream
  
  PAY_SCALES = {'Scale 1' => 100, 'Scale 2' => 50, 'Scale 3' => 20}
  PAY_SCALES_DEFAULT = 100
  
  DEFAULT_RETROSPECTIVE_LENGTH = 3 #Length in days for which a retrospective is open 
  RETRO_DAY_THRESHOLD = 21 # day threshold for  retrospective to start (days since last retrospective ended)
  # TIME_BETWEEN_CREDIT_DISTRIBUTIONS = 7 #Days between credit distributions
  DAY_FOR_CREDIT_DISTRIBUTION = "Saturday"
  
  NUMBER_OF_STARTABLE_PRIORITY_TIERS = 3 #number of highest tiers that are startable
  
  DAYS_FOR_ACTIVE_MEMBERSHIP = 14 #If a member does any activity on a project in the last X days, they're considered active
  
  DAYS_FOR_LATEST_NEWS = 45 #Number of days before a news item expires
  
  DAYS_FOR_RECENT_PROJECTS = 60 #Number of days workstreams appear if they were part of recent activity
  
  ACTIVITY_LINE_LENGTH = 90 #number of days for activity sparklines
  
  ACTIVITY_STREAM_LENGTH = 40 #number of actions to show before paginating


  #Factor by which dollars per point is multiplies e.g. a 5 point issue is worth $(POINT_FACTOR[5] * dpp)
  POINT_FACTOR = [0.2,1,2,4,6,9,12]
  
  #Reverse lookup. Converts credits to points
  CREDITS_TO_POINTS = [0,1,2,3,3,4,4,4,5,5,5,6,6,6,7,7,7,7,8,8,8,8,9,9,9,9,9,10,10,10,10,10,11,11,11,11,11,11,12,12,12,12,12,12,13,13,13,13,13,13,13,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,16,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17,17,18,18,18,18,18,18,18,18,18,19,19,19,19,19,19,19,19,19,19,20];
  
  #Percentage of share that need to agree on a share-majority motion before it passes
  SHARE_MAJORIY_MOTION_RATIO = 0.666666666 
  
  MOTIONS = {
    Motion::VARIATION_GENERAL => {
      "Title" => "General Motion",
      "Binding" => Motion::BINDING_MEMBER,
      "Visible" => Motion::VISIBLE_USER,
      "Type" => Motion::TYPE_MAJORITY,
      "Days" => 3
    },
    Motion::VARIATION_EXTRAORDINARY => {
      "Title" => "Extraordinary Motion",
      "Binding" => Motion::BINDING_USER,
      "Visible" => Motion::VISIBLE_USER,
      "Type" => Motion::TYPE_SHARE,
      "Days" => 10
    },
    Motion::VARIATION_NEW_MEMBER => {
      "Title" => "Motion to elect a new Member",
      "Binding" => Motion::BINDING_CORE,
      "Visible" => Motion::VISIBLE_CONTRIBUTER,
      "Type" => Motion::TYPE_CONSENSUS,
      "Days" => 5
    },
    Motion::VARIATION_FIRE_MEMBER => {
      "Title" => "Motion to remove an existing Member",
      "Binding" => Motion::BINDING_CORE,
      "Visible" => Motion::VISIBLE_CONTRIBUTER,
      "Type" => Motion::TYPE_CONSENSUS,
      "Days" => 5
    },
    Motion::VARIATION_NEW_CORE => {
      "Title" => "Motion to elect a new Core Team Member",
      "Binding" => Motion::BINDING_MEMBER,
      "Visible" => Motion::VISIBLE_CONTRIBUTER,
      "Type" => Motion::TYPE_CONSENSUS,
      "Days" => 5
    },
    Motion::VARIATION_FIRE_CORE => {
      "Title" => "Motion to remove an existing Core Team Member",
      "Binding" => Motion::BINDING_MEMBER,
      "Visible" => Motion::VISIBLE_CONTRIBUTER,
      "Type" => Motion::TYPE_CONSENSUS,
      "Days" => 5
    },
    # Motion::VARIATION_BOARD_PUBLIC => {
    #   "Title" => "Public Board Motion",
    #   "Binding" => Motion::BINDING_BOARD,
    #   "Visible" => Motion::VISIBLE_USER,
    #   "Type" => Motion::TYPE_CONSENSUS,
    #   "Days" => 5
    # },
    Motion::VARIATION_BOARD_PRIVATE => {
      "Title" => "Closed Board Motion",
      "Binding" => Motion::BINDING_BOARD,
      "Visible" => Motion::VISIBLE_BOARD,
      "Type" => Motion::TYPE_CONSENSUS,
      "Days" => 5
    }
    # ,
    # Motion::VARIATION_HOURLY_TYPE => {
    #   "Title" => "New Hourly Activity Type",
    #   "Binding" => Motion::BINDING_MEMBER,
    #   "Visible" => Motion::VISIBLE_USER,
    #   "Type" => Motion::TYPE_MAJORITY,
    #   "Days" => 3
    # }
}
  

  LAZY_MAJORITY_LENGTH = 3 #number of days before a lazy majority vote is counted
  
  LAZY_MAJORITY_NO_ACTIVITY_LENGTH = 1 #number of days an item needs to have no activity on before a lazy majority move is attempted on it
  
  #Reputation calculation constants
  
  #lenght of window for moving averages for reputation index average calculation. 
  #example: if this number is 20, the average before last will be weighed at 19/20, the one before that at 18/20, all scores past the 20th most recent scores will be weighed at 1/20 of their value in the totaly average
  LENGTH_OF_MOVING_AVERAGE = 20 
  
  DATE_FORMATS = [
	'%Y-%m-%d',
	'%d/%m/%Y',
	'%d.%m.%Y',
	'%d-%m-%Y',
	'%m/%d/%Y',
	'%d %b %Y',
	'%d %B %Y',
	'%b %d, %Y',
	'%B %d, %Y'
    ]
    
  TIME_FORMATS = [
    '%H:%M',
    '%I:%M %p'
    ]
    
  ENCODINGS = %w(US-ASCII
                  windows-1250
                  windows-1251
                  windows-1252
                  windows-1253
                  windows-1254
                  windows-1255
                  windows-1256
                  windows-1257
                  windows-1258
                  windows-31j
                  ISO-2022-JP
                  ISO-2022-KR
                  ISO-8859-1
                  ISO-8859-2
                  ISO-8859-3
                  ISO-8859-4
                  ISO-8859-5
                  ISO-8859-6
                  ISO-8859-7
                  ISO-8859-8
                  ISO-8859-9
                  ISO-8859-13
                  ISO-8859-15
                  KOI8-R
                  UTF-8
                  UTF-16
                  UTF-16BE
                  UTF-16LE
                  EUC-JP
                  Shift_JIS
                  GB18030
                  GBK
                  ISCII91
                  EUC-KR
                  Big5
                  Big5-HKSCS
                  TIS-620)
  
  cattr_accessor :available_settings
  @@available_settings = YAML::load(File.open("#{RAILS_ROOT}/config/settings.yml"))
  Redmine::Plugin.all.each do |plugin|
    next unless plugin.settings
    @@available_settings["plugin_#{plugin.id}"] = {'default' => plugin.settings[:default], 'serialized' => true}    
  end
  
  validates_uniqueness_of :name
  validates_inclusion_of :name, :in => @@available_settings.keys
  validates_numericality_of :value, :only_integer => true, :if => Proc.new { |setting| @@available_settings[setting.name]['format'] == 'int' }  

  # Hash used to cache setting values
  @cached_settings = {}
  @cached_cleared_on = Time.now
  
  def value
    v = read_attribute(:value)
    # Unserialize serialized settings
    v = YAML::load(v) if @@available_settings[name]['serialized'] && v.is_a?(String)
    v = v.to_sym if @@available_settings[name]['format'] == 'symbol' && !v.blank?
    v
  end
  
  def value=(v)
    v = v.to_yaml if v  && @@available_settings[name]['serialized']
    write_attribute(:value, v.to_s)
  end
  
  # Returns the value of the setting named name
  def self.[](name)
    v = @cached_settings[name]
    v ? v : (@cached_settings[name] = find_or_default(name).value)
  end
  
  def self.[]=(name, v)
    setting = find_or_default(name)
    setting.value = (v ? v : "")
    @cached_settings[name] = nil
    setting.save
    setting.value
  end
  
  # Defines getter and setter for each setting
  # Then setting values can be read using: Setting.some_setting_name
  # or set using Setting.some_setting_name = "some value"
  @@available_settings.each do |name, params|
    src = <<-END_SRC
    def self.#{name}
      self[:#{name}]
    end

    def self.#{name}?
      self[:#{name}].to_i > 0
    end

    def self.#{name}=(value)
      self[:#{name}] = value
    end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end
  
  # Helper that returns an array based on per_page_options setting
  def self.per_page_options_array
    per_page_options.split(%r{[\s,]}).collect(&:to_i).select {|n| n > 0}.sort
  end
  
  def self.openid?
    Object.const_defined?(:OpenID) && self[:openid].to_i > 0
  end
  
  # Checks if settings have changed since the values were read
  # and clears the cache hash if it's the case
  # Called once per request
  def self.check_cache
    settings_updated_at = Setting.maximum(:updated_at)
    if settings_updated_at && @cached_cleared_on <= settings_updated_at
      @cached_settings.clear
      @cached_cleared_on = Time.now
    end
  end
  
private
  # Returns the Setting instance for the setting named name
  # (record found in database or new record with default value)
  def self.find_or_default(name)
    name = name.to_s
    raise "There's no setting named #{name}" unless @@available_settings.has_key?(name)    
    setting = new(:name => name, :value => @@available_settings[name]['default']) if @@available_settings.has_key? name
    setting ||= find_by_name(name)
  end
end



# == Schema Information
#
# Table name: settings
#
#  id         :integer         not null, primary key
#  name       :string(255)     default(""), not null
#  value      :text
#  updated_on :datetime
#

