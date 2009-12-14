class IssueStatus < ActiveRecord::Base
  generator_for :name, :method => :next_name

  def self.next_name
    @last_name ||= 'Status 0'
    @last_name.succ!
    @last_name
  end
end

# == Schema Information
#
# Table name: issue_statuses
#
#  id         :integer         not null, primary key
#  name       :string(30)      default(""), not null
#  is_closed  :boolean         default(FALSE), not null
#  is_default :boolean         default(FALSE), not null
#  position   :integer         default(1)
#

