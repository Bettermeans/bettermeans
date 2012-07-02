class Issue < ActiveRecord::Base
  generator_for :subject, :method => :next_subject
  generator_for :author, :method => :next_author

  def self.next_subject
    @last_subject ||= 'Subject 0'
    @last_subject.succ!
    @last_subject
  end

  def self.next_author
    User.generate_with_protected!
  end

end

# == Schema Information
#
# Table name: issues
#
#  id                   :integer         not null, primary key
#  tracker_id           :integer         default(0), not null
#  project_id           :integer         default(0), not null
#  subject              :string(255)     default(""), not null
#  description          :text
#  due_date             :date
#  status_id            :integer         default(0), not null
#  assigned_to_id       :integer
#  priority_id          :integer         default(0), not null
#  author_id            :integer         default(0), not null
#  lock_version         :integer         default(0), not null
#  created_at           :datetime
#  updated_at           :datetime
#  start_date           :date
#  done_ratio           :integer         default(0), not null
#  estimated_hours      :float
#  expected_date        :date
#  points               :float
#  pri                  :integer         default(0)
#  accept               :integer         default(0)
#  reject               :integer         default(0)
#  accept_total         :integer         default(0)
#  agree                :integer         default(0)
#  disagree             :integer         default(0)
#  agree_total          :integer         default(0)
#  retro_id             :integer
#  accept_nonbind       :integer         default(0)
#  reject_nonbind       :integer         default(0)
#  accept_total_nonbind :integer         default(0)
#  agree_nonbind        :integer         default(0)
#  disagree_nonbind     :integer         default(0)
#  agree_total_nonbind  :integer         default(0)
#  points_nonbind       :integer         default(0)
#  pri_nonbind          :integer         default(0)
#  hourly_type_id       :integer
#  num_hours            :integer         default(0)
#

