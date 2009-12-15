class Role < ActiveRecord::Base
  generator_for :name, :method => :next_name

  def self.next_name
    @last_name ||= 'Role0'
    @last_name.succ!
  end
end

# == Schema Information
#
# Table name: roles
#
#  id          :integer         not null, primary key
#  name        :string(30)      default(""), not null
#  position    :integer         default(1)
#  assignable  :boolean         default(TRUE)
#  builtin     :integer         default(0), not null
#  permissions :text
#  level       :integer         default(3)
#

