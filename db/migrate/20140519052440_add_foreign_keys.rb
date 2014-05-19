class AddForeignKeys < ActiveRecord::Migration

  def self.up
    # horrible hack because seeds.rb has been executed twice
    invalid_issues = Issue.find(:all).select { |i| i.status.nil? }
    status_count = IssueStatus.count
    invalid_issues.each do
      |i| i.update_attribute(:status_id, i.status_id + status_count)
    end
    add_foreign_key :issues, :issue_statuses, :column => :status_id

    invalid_issues = Issue.find(:all).select { |i| i.tracker.nil? }
    tracker_count = Tracker.count
    invalid_issues.each do |issue|
      issue.update_attribute(:tracker_id, issue.tracker_id + tracker_count)
    end
    add_foreign_key :issues, :trackers

    # projects_trackers doesn't have a primary key
    ActiveRecord::Base.connection.execute("
      ALTER TABLE projects_trackers ADD COLUMN id SERIAL;
      UPDATE projects_trackers SET id = DEFAULT;
      ALTER TABLE projects_trackers ADD PRIMARY KEY (id);
    ")
    # UPDATE projects_trackers SET id = nextval(pg_get_serial_sequence('projects_trackers','id'));
    invalid_pts = ProjectsTracker.find(:all).select { |i| i.tracker.nil? }
    invalid_pts.each do |pt|
      pt.update_attribute(:tracker_id, pt.tracker_id + tracker_count)
    end
    add_foreign_key :projects_trackers, :trackers

    invalid_workflows = Workflow.find(:all).select { |w| w.tracker.nil? }
    invalid_workflows.each do |workflow|
      new_tracker_id = workflow.tracker_id + tracker_count
      workflow.update_attribute(:tracker_id, new_tracker_id)
    end
    add_foreign_key :workflows, :trackers

    # doesn't appear that these columns is set to anything, yet
    add_foreign_key :workflows, :issue_statuses, :column => :old_status_id
    add_foreign_key :workflows, :issue_statuses, :column => :new_status_id

    invalid_mrs = MemberRole.find(:all).select { |mr| mr.role.nil? }
    role_count = Role.count
    invalid_mrs.each do |mr|
      mr.update_attribute(:role_id, mr.role_id + role_count)
    end
    add_foreign_key :member_roles, :roles

    # no foreign keys here yet either
    add_foreign_key :workflows, :roles

    invalid_invites = Invitation.find(:all).select { |i| i.role.nil? }
    invalid_invites.each do |invite|
      invite.update_attribute(:role_id, invite.role_id + role_count)
    end
    add_foreign_key :invitations, :roles

    invalid_users = User.find(:all).select { |u| u.plan.nil? }

    invalid_users.each do |user|
      user.update_attribute(:plan_id, user.plan_id + Plan.count)
    end
    add_foreign_key :users, :plans
  end

  def self.down
    remove_foreign_key :issues, :name => 'issues_status_id_fk'
    remove_foreign_key :issues, :trackers
    remove_foreign_key :projects_trackers, :trackers
    remove_foreign_key :workflows, :trackers
    remove_foreign_key :workflows, :name => 'workflows_old_status_id_fk'
    remove_foreign_key :workflows, :name => 'workflows_new_status_id_fk'
    remove_foreign_key :member_roles, :roles
    remove_foreign_key :workflows, :roles
    remove_foreign_key :invitations, :roles
    remove_foreign_key :users, :plans
    remove_column :projects_trackers, :id
  end

end
