class Query < ActiveRecord::Base
  generator_for :name, :method => :next_name

  def self.next_name
    @last_name ||= 'Query 0'
    @last_name.succ!
    @last_name
  end
end

# == Schema Information
#
# Table name: queries
#
#  id            :integer         not null, primary key
#  project_id    :integer
#  name          :string(255)     default(""), not null
#  filters       :text
#  user_id       :integer         default(0), not null
#  is_public     :boolean         default(FALSE), not null
#  column_names  :text
#  sort_criteria :text
#  group_by      :string(255)
#

