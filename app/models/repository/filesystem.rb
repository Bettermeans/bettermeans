# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#
# FileSystem adapter
# File written by Paul Rivier, at Demotera.
#

require 'redmine/scm/adapters/filesystem_adapter'

class Repository::Filesystem < Repository
  attr_protected :root_url
  validates_presence_of :url

  def scm_adapter
    Redmine::Scm::Adapters::FilesystemAdapter
  end
  
  def self.scm_name
    'Filesystem'
  end
  
  def entries(path=nil, identifier=nil)
    scm.entries(path, identifier)
  end

  def fetch_changesets
    nil
  end
  
end


# == Schema Information
#
# Table name: repositories
#
#  id         :integer         not null, primary key
#  project_id :integer         default(0), not null
#  url        :string(255)     default(""), not null
#  login      :string(60)      default("")
#  password   :string(60)      default("")
#  root_url   :string(255)     default("")
#  type       :string(255)
#

