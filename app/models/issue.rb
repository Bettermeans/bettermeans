# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class Issue < ActiveRecord::Base

  belongs_to :project
  belongs_to :tracker
  belongs_to :status, :class_name => 'IssueStatus', :foreign_key => 'status_id'
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'
  belongs_to :retro
  belongs_to :hourly_type

  has_many :journals, :as => :journalized, :dependent => :destroy, :order => "#{Journal.table_name}.created_at ASC"

  has_many :relations_from, :class_name => 'IssueRelation', :foreign_key => 'issue_from_id', :dependent => :delete_all
  has_many :relations_to, :class_name => 'IssueRelation', :foreign_key => 'issue_to_id', :dependent => :delete_all

  has_many :issue_votes, :dependent => :delete_all
  has_many :todos, :dependent => :delete_all

  acts_as_attachable :after_remove => :attachment_removed
  acts_as_watchable
  acts_as_searchable :columns => ['subject', "#{table_name}.description", "#{Journal.table_name}.notes"],
                     :include => [:project, :journals],
                     # sort by id so that limited eager loading doesn't break with postgresql
                     :order_column => "#{table_name}.id"

  acts_as_taggable

  acts_as_event :title => Proc.new {|o| "#{o.tracker.name} ##{o.id} (#{o.status}): #{o.subject}"},
                :url => Proc.new {|o| {:controller => 'issues', :action => 'show', :id => o.id}},
                :type => Proc.new {|o| 'issue' + (o.closed? ? ' closed' : '') }

  delegate :rejected?, :accepted?, :to => :status
  delegate :gift?, :expense?, :hourly?, :feature?, :bug?, :chore?, :to => :tracker

  # ===============
  # = CSV support =
  # ===============
  comma do  # implicitly named :default
     id
     tracker :name
     project :name
     subject
     description
     status :name
     assigned_to :name
     author :name
     points
     pri
     accept
     reject
     agree
     disagree
     accept_nonbind
     reject_nonbind
     agree_nonbind
     disagree_nonbind
     agree_total_nonbind
     points_nonbind
     pri_nonbind
     hourly_type :name
     num_hours
     created_at
     updated_at
  end

  DONE_RATIO_OPTIONS = %w(issue_field issue_status)

  validates_presence_of :subject, :project, :tracker, :author, :status
  validates_length_of :subject, :maximum => 255

  named_scope :visible, lambda {|*args| { :include => :project,
                                          :conditions => Project.allowed_to_condition(args.first || User.current, :view_issues) } }

  named_scope :open, :conditions => ["#{IssueStatus.table_name}.is_closed = ?", false], :include => :status

  named_scope :open_status, lambda { { :conditions => {:status_id => IssueStatus.open_id}, :include => :status } }

  after_save :after_save

  # Returns true if usr or current user is allowed to view the issue
  def visible?(usr=nil) # spec_me cover_me heckle_me
    (usr || User.current).allowed_to?(:view_issues, self.project)
  end

  # Returns true if there are enough agreements in relation to the estimated points of the request
  def ready_for_open?
    points.present? && agree_total >= 1
  end

  # Returns true if there are enough disagreements in relation to the estimated points of the request
  def ready_for_canceled?
    agree_total < 0 && lazy_majority_passed?
  end

  def ready_for_accepted? # cover_me heckle_me
    accepted? || points.present? && accept_total > 0 && lazy_majority_passed?
  end

  def ready_for_rejected?
    rejected? || points.present? && accept_total < 0 && lazy_majority_passed?
  end

  def updated_status # cover_me heckle_me
    return IssueStatus.canceled if self.status == IssueStatus.canceled
    return IssueStatus.accepted if ready_for_accepted?
    return IssueStatus.rejected if ready_for_rejected?
    return IssueStatus.done if self.status == IssueStatus.done || (ready_for_open? && gift?)
    return IssueStatus.inprogress if self.status == IssueStatus.inprogress
    return IssueStatus.open if ready_for_open?
    return IssueStatus.canceled if ready_for_canceled?
    return IssueStatus.newstatus #default
  end

  def after_initialize # cover_me heckle_me
    if new_record?
      # set default values for new records only
      self.status ||= IssueStatus.default
    end
  end

  # Returns true if one or more people joined this issue
  def has_team? # cover_me heckle_me
    team_votes.length>1
  end

  def has_todos? # cover_me heckle_me
    todos.length>0
  end

  def team_votes # cover_me heckle_me
    issue_votes.select {|i| i.vote_type == IssueVote::JOIN_VOTE_TYPE}
  end

  def team_members # spec_me cover_me heckle_me
    IssueVote.find(:all, :conditions => ["issue_id=? AND vote_type=?",
                                                   self.id, IssueVote::JOIN_VOTE_TYPE], :order => "updated_at ASC").map(&:user)
  end

  def copy_from(arg) # spec_me cover_me heckle_me
    issue = arg.is_a?(Issue) ? arg : Issue.find(arg)
    self.attributes = issue.attributes.dup.except("id", "created_at", "updated_at")
    self.status = issue.status
    self
  end

  #returns true if issue can be started (in the correct priority tier)
  def startable? # cover_me heckle_me
    return false unless self.status_id == IssueStatus.open.id
    (pri && pri > project.issues.open_status.maximum("pri") - Setting::NUMBER_OF_STARTABLE_PRIORITY_TIERS) || points_from_credits == 0
  end


  #Creates a new issue and sets its status to open
  #Copies all issue votes except team ones and accept/reject ones
  def clone_recurring # spec_me cover_me heckle_me
    @new_issue = Issue.new
    @new_issue.attributes = self.attributes.dup.except("id", "created_at", "updated_at")
    @new_issue.status = IssueStatus.open
    @new_issue.save!
    self.issue_votes.each do |iv|
      next if iv.vote_type == IssueVote::JOIN_VOTE_TYPE || iv.vote_type == IssueVote::ACCEPT_VOTE_TYPE
      @new_iv = IssueVote.new
      @new_iv.attributes = iv.attributes.dup.except("id", "issue_id")
      @new_iv.issue_id = @new_issue.id
      @new_iv.save!
    end
  end

  # Moves/copies an issue to a new project and tracker
  # Returns the moved/copied issue on success, false on failure
  def move_to(new_project, new_tracker = nil, options = {}) # spec_me cover_me heckle_me
    options ||= {}
    issue = options[:copy] ? self.clone : self
    transaction do
      if new_project && issue.project_id != new_project.id
        # delete issue relations
        unless Setting.cross_project_issue_relations?
          issue.relations_from.clear
          issue.relations_to.clear
        end
        issue.project = new_project
      end
      if new_tracker
        issue.tracker = new_tracker
      end
      if options[:copy]
        issue.status = if options[:attributes] && options[:attributes][:status_id]
                         IssueStatus.find_by_id(options[:attributes][:status_id])
                       else
                         self.status
                       end
      end
      # Allow bulk setting of attributes on the issue
      if options[:attributes]
        issue.attributes = options[:attributes]
      end
      if !issue.save
        Issue.connection.rollback_db_transaction
        return false
      end
    end
    return issue
  end

  def tracker_id=(tid) # spec_me cover_me heckle_me
    self.tracker = nil
    write_attribute(:tracker_id, tid)
    result = write_attribute(:tracker_id, tid)
    result
  end

  def mention(mentioner_id, mentioned_id, mention_text) # spec_me cover_me heckle_me
    Notification.create :recipient_id => mentioned_id,
                        :variation => 'mention',
                        :params => {:mention_text => self.description,
                                    :url => {:controller => "issues", :action => "show", :id => self.id},
                                    :title => self.subject},
                        :sender_id => mentioner_id,
                        :source_id => self.id,
                        :source_type => "Issue"
  end

  def update_tags(tags) # spec_me cover_me heckle_me
    update_attribute(:tag_list, tags)
    update_attribute(:tags_copy, self.tags.map {|t|t.name}.join(","))
    update_last_item_stamp
  end

  # Overrides attributes= so that tracker_id gets assigned first
  def attributes_with_tracker_first=(new_attributes, *args) # spec_me cover_me heckle_me
    return if new_attributes.nil?
    new_tracker_id = new_attributes['tracker_id'] || new_attributes[:tracker_id]
    if new_tracker_id
      self.tracker_id = new_tracker_id
    end
    self.attributes_without_tracker_first = new_attributes, *args
  end
  alias_method_chain :attributes=, :tracker_first

  def estimated_hours=(h) # spec_me cover_me heckle_me
    write_attribute :estimated_hours, (h.is_a?(String) ? h.to_hours : h)
  end

  def init_journal(user, notes = "") # spec_me cover_me heckle_me
    @current_journal ||= Journal.new(:journalized => self, :user => user, :notes => notes)
    @issue_before_change = self.clone
    @issue_before_change.status = self.status

    # Make sure updated_at is updated when adding a note.
    updated_at_will_change!
    @current_journal

  end

  # Return true if the issue is closed, otherwise false
  def closed? # spec_me cover_me heckle_me
    self.status.is_closed?
  end

  # Return true if the issue is being reopened
  def reopened? # spec_me cover_me heckle_me
    if !new_record? && status_id_changed?
      status_was = IssueStatus.find_by_id(status_id_was)
      status_new = IssueStatus.find_by_id(status_id)
      if status_was && status_new && status_was.is_closed? && !status_new.is_closed?
        return true
      end
    end
    false
  end

  def editable? # spec_me cover_me heckle_me
    return !(status == IssueStatus.assigned   ||
             status == IssueStatus.done       ||
             status == IssueStatus.canceled   ||
             status == IssueStatus.archived)


  end

  # Returns true if the issue is overdue
  def overdue? # heckle_me
    !due_date.nil? && (due_date < DateTime.now) && !status.is_closed?
  end

  # Users the issue can be assigned to
  def assignable_users # heckle_me
    project.assignable_users
  end

  # Returns true if this issue is blocked by another issue that is still open
  def blocked? # spec_me cover_me heckle_me
    !relations_to.detect {|ir| ir.relation_type == 'blocks' && !ir.issue_from.closed?}.nil?
  end

  # Returns an array of status that user is able to apply
  def new_statuses_allowed_to(user) # spec_me cover_me heckle_me
    logger.info { "New statuses allowed" }
    statuses = status.find_new_statuses_allowed_to(user.roles_for_project(project), tracker)
    statuses << status unless statuses.empty?
    statuses = statuses.uniq.sort
    blocked? ? statuses.reject {|s| s.is_closed?} : statuses
  end

  # Returns the mail adresses of users that should be notified
  def recipients # spec_me cover_me heckle_me
    notified = project.notified_users
    # Author and assignee are always notified unless they have been locked
    notified << author if author && author.active?
    notified << assigned_to if assigned_to && assigned_to.active? unless self.tracker.gift?
    notified += team_members
    notified += journals.collect {|j| j.user}
    notified.uniq!
    # Remove users that can not view the issue
    notified.reject! {|user| !visible?(user) || user.pref[:no_emails]}

    notified.delete User.sysadmin
    notified.collect(&:mail)
  end

  def relations # spec_me cover_me heckle_me
    (relations_from + relations_to).sort
  end

  def all_dependent_issues # spec_me cover_me heckle_me
    dependencies = []
    relations_from.each do |relation|
      dependencies << relation.issue_to
      dependencies += relation.issue_to.all_dependent_issues
    end
    dependencies
  end

  # Returns an array of issues that duplicate this one
  def duplicates # spec_me cover_me heckle_me
    relations_to.select {|r| r.relation_type == IssueRelation::TYPE_DUPLICATES}.collect {|r| r.issue_from}
  end

  # Returns the due date or the target due date if any
  # Used on gantt chart
  def due_before # heckle_me
    due_date
  end

  # Returns the time scheduled for this issue.
  #
  # Example:
  #   Start Date: 2/26/09, End Date: 3/04/09
  #   duration => 6
  def duration # heckle_me
    (start_date && due_date) ? due_date - start_date : 0
  end

  def soonest_start # spec_me cover_me heckle_me
    @soonest_start ||= relations_to.collect{|relation| relation.successor_soonest_start}.compact.min
  end

  def to_s # spec_me cover_me heckle_me
    "#{tracker} ##{id}: #{subject}"
  end

  # Returns a string of css classes that apply to the issue
  def css_classes # spec_me cover_me heckle_me
    s = "issue status-#{status.position}"
    s << ' closed' if closed?
    s << ' overdue' if overdue?
    s << ' created-by-me' if User.current.logged? && author_id == User.current.id
    s << ' assigned-to-me' if User.current.logged? && assigned_to_id == User.current.id
    s
  end


  #returns true if this user is allowed to take (and/or offer) ownership for this particular issue
  def push_allowed?(user) # cover_me heckle_me
    return false if user.nil?
    return true if self.assigned_to == user #Any user who owns an issue can offer for people to take it, or can accept offers

    #True if user has push commitment, AND expected date has passed or doesn't exist AND it's assigned to nobody or assigned to same user
    user.allowed_to?(:push_commitment, self.project) && (self.expected_date.nil? || self.expected_date < Time.new.to_date) && (self.assigned_to.nil? || self.assigned_to == user)
  end

  def update_estimate_total(binding) # spec_me cover_me heckle_me
    if binding
      self.points =   IssueVote.average(:points, :conditions => " issue_id = #{self.id} AND  vote_type = #{IssueVote::ESTIMATE_VOTE_TYPE} AND isbinding= true AND points != -1")
    else
      self.points_nonbind =   IssueVote.average(:points, :conditions => " issue_id = #{self.id} AND  vote_type = #{IssueVote::ESTIMATE_VOTE_TYPE} AND isbinding= false AND points != -1")
    end
  end

  def update_pri_total(binding) # spec_me cover_me heckle_me
    if binding
      self.pri = IssueVote.sum(:points, :conditions => {:issue_id => self.id, :vote_type => IssueVote::PRI_VOTE_TYPE, :isbinding=> true})
    else
      self.pri_nonbind = IssueVote.sum(:points, :conditions => {:issue_id => self.id, :vote_type => IssueVote::PRI_VOTE_TYPE, :isbinding=> false})
    end
  end

  def update_agree_total(binding) # spec_me cover_me heckle_me
    if binding
      self.agree =   IssueVote.count(:conditions => {:issue_id => self.id, :vote_type => IssueVote::AGREE_VOTE_TYPE, :points => 1, :isbinding=> true})
      self.disagree =   IssueVote.sum(:points, :conditions => "issue_id = '#{self.id}' AND vote_type = '#{IssueVote::AGREE_VOTE_TYPE}' AND points < 0 AND isbinding='true'") * -1
      self.agree_total = self.agree - self.disagree
    else
      self.agree_nonbind =   IssueVote.count(:conditions => {:issue_id => self.id, :vote_type => IssueVote::AGREE_VOTE_TYPE, :points => 1, :isbinding=> false})
      self.disagree_nonbind =   IssueVote.sum(:points, :conditions => "issue_id = '#{self.id}' AND vote_type = '#{IssueVote::AGREE_VOTE_TYPE}' AND points < 0 AND isbinding='false'") * -1
      self.agree_total_nonbind = self.agree_nonbind - self.disagree_nonbind
    end
  end

  def update_accept_total(binding) # spec_me cover_me heckle_me
    if binding
      self.accept =   IssueVote.count(:conditions => {:issue_id => self.id, :vote_type => IssueVote::ACCEPT_VOTE_TYPE, :points => 1, :isbinding=> true})
      self.reject =   IssueVote.sum(:points, :conditions => "issue_id = '#{self.id}' AND vote_type = '#{IssueVote::ACCEPT_VOTE_TYPE}' AND points < 0 AND isbinding='true'") * -1
      self.accept_total = self.accept - self.reject
    else
      self.accept_nonbind =   IssueVote.count(:conditions => {:issue_id => self.id, :vote_type => IssueVote::ACCEPT_VOTE_TYPE, :points => 1, :isbinding=> false})
      self.reject_nonbind =   IssueVote.sum(:points, :conditions => "issue_id = '#{self.id}' AND vote_type = '#{IssueVote::ACCEPT_VOTE_TYPE}' AND points < 0 AND isbinding='false'") * -1
      self.accept_total_nonbind = self.accept_nonbind - self.reject_nonbind
    end
  end

  # refreshes issue status, returns true if status changed
  def update_status # spec_me cover_me heckle_me
    original = self.status
    @updated = self.updated_status

    if (original.id != @updated.id)
      admin = User.find(:first,:conditions => {:login => "admin"})
      journal = self.init_journal(admin)
      self.status = @updated
      self.retro_id = nil

      LogActivityStreams.write_single_activity_stream(User.sysadmin,:name,self,:subject,:changed,"update_to_#{@updated.name}", 0, @updated,{
                :indirect_object_name_method => :name,
                :indirect_object_phrase => "#{original.name}:#{@updated.name}"})

      if self.status == IssueStatus.accepted
        self.assigned_to.add_as_contributor_if_new(self.project) unless self.assigned_to.nil?
        if self.gift?
          self.retro_id = Retro::NOT_NEEDED_ID
          self.give_credits
        elsif self.expense?
          self.retro_id = Retro::NOT_NEEDED_ID
          self.give_credits
        elsif self.hourly?
          self.retro_id = Retro::GIVEN_BUT_NOT_PART_OF_RETRO
          self.give_credits
        else #if a non-gift/expense/hourly is accepted, set retro id to not started to prep for next retrospective
          if self.project.credits_enabled?
            self.retro_id = Retro::NOT_STARTED_ID
            self.project.start_retro_if_ready
          else
            self.retro_id = Retro::NOT_ENABLED_ID #credits not enabled, we don't care
          end
        end
      end

      save!
      return true
    else
      return false
    end
  end

  # sets number of points for an hourly item
  def set_points_from_hourly # spec_me cover_me heckle_me
    return unless self.hourly?

    if (hourly_type.hourly_rate_per_person * self.team_members.length) > hourly_type.hourly_cap
      self.points = hourly_type.hourly_cap * self.num_hours
    else
      self.points = self.num_hours * self.team_members.length * hourly_type.hourly_rate_per_person
    end
  end

  # issues credits for this one issue to the people it's assigned to
  def give_credits # spec_me cover_me heckle_me
    if self.gift?
      CreditDistribution.create(:user_id => self.assigned_to_id,
                                :project_id => self.project_id,
                                :retro_id => CreditDistribution::GIFT,
                                :amount => self.points) unless self.points == 0 || self.points.nil?
    elsif self.expense?
      CreditDistribution.create(:user_id => self.assigned_to_id,
                                :project_id => self.project_id,
                                :retro_id => CreditDistribution::EXPENSE,
                                :amount => self.points) unless self.points == 0 || self.points.nil?
    elsif self.hourly?
      credits_per_person_per_hour = 0

      if (hourly_type.hourly_rate_per_person * self.team_members.length) > hourly_type.hourly_cap
        credits_per_person_per_hour = hourly_type.hourly_cap / self.team_members.length
      else
        credits_per_person_per_hour = hourly_type.hourly_rate_per_person
      end

      credits_per_person = credits_per_person_per_hour * self.num_hours

      self.team_members.each do |member|
        CreditDistribution.create(:user_id => member.id,
                                  :project_id => self.project_id,
                                  :retro_id => CreditDistribution::HOURLY,
                                  :amount => credits_per_person) unless credits_per_person == 0 || self.points.nil?
      end
    end
  end

  #returns json object for consumption from dashboard
  def to_dashboard # spec_me cover_me heckle_me
    self.to_json(:include => {:journals => { :only => [:id, :notes, :created_at, :user_id], :include => {:user => { :only => [:firstname, :lastname, :login] }}},
                              :issue_votes => { :include => {:user => { :only => [:firstname, :lastname, :login] }}},
                              :status => {:only => :name},
                              :attachments => { :only => [:id, :filename]},
                              :todos => {:only => [:id, :subject, :completed_on, :owner_login]},
                              :tracker => {:only => [:name,:id]},
                              :author => {:only => [:firstname, :lastname, :login, :mail_hash]},
                              :assigned_to => { :only => [:firstname, :lastname, :login] }
                              },
                              :except => :tags)
  end

  #returns dollar amount based on points for this issue
  def dollar_amount # cover_me heckle_me
    return self.points
  end

  #returns number of "points" based on scale. used to calculate votes needed in lazy majority
  def points_from_credits # spec_me cover_me heckle_me
    normalized = (points/self.project.dpp).round
    return Setting::CREDITS_TO_POINTS[Setting::CREDITS_TO_POINTS.length - 1] if normalized > Setting::CREDITS_TO_POINTS.length #returns max if credits are more than max
    return Setting::CREDITS_TO_POINTS[normalized];
  end

  def size # spec_me cover_me heckle_me
    sum = 0.0
    attachments.each do |a|
      sum += a.filesize
    end

    sum = sum / 1000000000
    sum.round(3)
  end

  def after_create # spec_me cover_me heckle_me
    self.project.send_later :refresh_issue_count
  end

  def update_last_item_stamp # cover_me heckle_me
    self.project.send_later("update_last_item")
  end

  private

  def lazy_majority_passed?
    updated_at < DateTime.now - Setting::LAZY_MAJORITY_LENGTH
  end

  # Callback on attachment deletion
  def attachment_removed(obj) # cover_me heckle_me
    journal = init_journal(User.current)
    journal.details << JournalDetail.new(:property => 'attachment',
                                         :prop_key => obj.id,
                                         :old_value => obj.filename)
    journal.save!
  end

  def after_save # cover_me heckle_me
    # Reload is needed in order to get the right status
    reload

    # Update start/due dates of following issues
    relations_from.each(&:set_issue_to_dates)

    # Close duplicates if the issue was closed
    if @issue_before_change && !@issue_before_change.closed? && self.closed?
      duplicates.each do |duplicate|
        # Reload is need in case the duplicate was updated by a previous duplicate
        duplicate.reload
        # Don't re-close it if it's already closed
        next if duplicate.closed?
        # Same user and notes
        duplicate.init_journal(@current_journal.user, @current_journal.notes)
        duplicate.update_attribute :status, IssueStatus.archived
      end
    end

    update_last_item_stamp #TODO: should be before save!
    create_journal
  end

  # Saves the changes in a Journal
  # Called after_save
  def create_journal # cover_me heckle_me
    if @current_journal

      logger.info { "creating journal..." }
      # attributes changes
      (Issue.column_names - %w(id lock_version created_at updated_at pri accept reject accept_total agree disagree agree_total retro_id accept_nonbind reject_nonbind accept_total_nonbind agree_nonbind disagree_nonbind agree_total_nonbind points_nonbind pri_nonbind tags)).each {|c|
        @current_journal.details << JournalDetail.new(:property => 'attr',
                                                      :prop_key => c,
                                                      :old_value => @issue_before_change.send(c),
                                                      :value => send(c)) unless send(c)==@issue_before_change.send(c)
      }
      @current_journal.save!
    end
  end

end
