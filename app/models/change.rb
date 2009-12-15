# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class Change < ActiveRecord::Base
  belongs_to :changeset
  
  validates_presence_of :changeset_id, :action, :path
  
  def relative_path
    changeset.repository.relative_path(path)
  end
end


# == Schema Information
#
# Table name: changes
#
#  id            :integer         not null, primary key
#  changeset_id  :integer         not null
#  action        :string(1)       default(""), not null
#  path          :string(255)     default(""), not null
#  from_path     :string(255)
#  from_revision :string(255)
#  revision      :string(255)
#  branch        :string(255)
#

