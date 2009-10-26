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
