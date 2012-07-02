class Version < ActiveRecord::Base
  generator_for :name, :method => :next_name
  generator_for :status => 'open'

  def self.next_name
    @last_name ||= 'Version 1.0.0'
    @last_name.succ!
    @last_name
  end

end
# == Schema Information
#
# Table name: versions
#
#  id              :integer         not null, primary key
#  project_id      :integer         default(0), not null
#  name            :string(255)     default(""), not null
#  description     :string(255)     default("")
#  effective_date  :date
#  created_at      :datetime
#  updated_at      :datetime
#  wiki_page_title :string(255)
#  status          :string(255)     default("open")
#  sharing         :string(255)     default("none"), not null
#

