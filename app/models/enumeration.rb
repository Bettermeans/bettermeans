# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class Enumeration < ActiveRecord::Base
  default_scope :order => "#{Enumeration.table_name}.position ASC"

  belongs_to :project

  acts_as_list :scope => 'type = \'#{type}\''
  acts_as_tree :order => 'position ASC'

  before_destroy :check_integrity

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:type, :project_id]
  validates_length_of :name, :maximum => 30

  named_scope :values, lambda {|type| { :conditions => { :type => type }, :order => 'position' } } do
    def default # spec_me cover_me heckle_me
      find(:first, :conditions => { :is_default => true })
    end
  end
  # End backwards compatiblity named_scopes

  named_scope :shared, :conditions => { :project_id => nil }
  named_scope :active, :conditions => { :active => true }

  def self.default # spec_me cover_me heckle_me
    # Creates a fake default scope so Enumeration.default will check
    # it's type.  STI subclasses will automatically add their own
    # types to the finder.
    if self.descends_from_active_record?
      find(:first, :conditions => { :is_default => true, :type => 'Enumeration' })
    else
      # STI classes are
      find(:first, :conditions => { :is_default => true })
    end
  end

  # Overloaded on concrete classes
  def option_name # spec_me cover_me heckle_me
    nil
  end

  # Backwards compatiblity.  Can be removed post-0.9
  def opt # spec_me cover_me heckle_me
    ActiveSupport::Deprecation.warn("Enumeration#opt is deprecated, use the STI classes now. (#{Redmine::Info.issue(3007)})")
    return OptName
  end

  def before_save # spec_me cover_me heckle_me
    if is_default? && is_default_changed?
      Enumeration.update_all("is_default = #{connection.quoted_false}", {:type => type})
    end
  end

  # Overloaded on concrete classes
  def objects_count # spec_me cover_me heckle_me
    0
  end

  def in_use? # spec_me cover_me heckle_me
    self.objects_count != 0
  end

  # Is this enumeration overiding a system level enumeration?
  def is_override? # spec_me cover_me heckle_me
    !self.parent.nil?
  end

  alias :destroy_without_reassign :destroy

  # Destroy the enumeration
  # If a enumeration is specified, objects are reassigned
  def destroy(reassign_to = nil) # spec_me cover_me heckle_me
    if reassign_to && reassign_to.is_a?(Enumeration)
      self.transfer_relations(reassign_to)
    end
    destroy_without_reassign
  end

  def <=>(enumeration) # spec_me cover_me heckle_me
    position <=> enumeration.position
  end

  def to_s; name end # spec_me cover_me heckle_me

  # Returns the Subclasses of Enumeration.  Each Subclass needs to be
  # required in development mode.
  #
  # Note: subclasses is protected in ActiveRecord
  def self.get_subclasses # spec_me cover_me heckle_me
    @@subclasses[Enumeration]
  end

  # Does the +new+ Hash override the previous Enumeration?
  def self.overridding_change?(new, previous) # spec_me cover_me heckle_me
    if (same_active_state?(new['active'], previous.active))
      return false
    else
      return true
    end
  end


  # Are the new and previous fields equal?
  def self.same_active_state?(new, previous) # spec_me cover_me heckle_me
    new = (new == "1" ? true : false)
    return new == previous
  end

  private

  def check_integrity # cover_me heckle_me
    raise "Can't delete enumeration" if self.in_use?
  end

end

