# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

require 'redmine/scm/adapters/darcs_adapter'

class Repository::Darcs < Repository
  validates_presence_of :url

  def scm_adapter
    Redmine::Scm::Adapters::DarcsAdapter
  end
  
  def self.scm_name
    'Darcs'
  end
  
  def entry(path=nil, identifier=nil)
    patch = identifier.nil? ? nil : changesets.find_by_revision(identifier)
    scm.entry(path, patch.nil? ? nil : patch.scmid)
  end
  
  def entries(path=nil, identifier=nil)
    patch = identifier.nil? ? nil : changesets.find_by_revision(identifier)
    entries = scm.entries(path, patch.nil? ? nil : patch.scmid)
    if entries
      entries.each do |entry|
        # Search the DB for the entry's last change
        changeset = changesets.find_by_scmid(entry.lastrev.scmid) if entry.lastrev && !entry.lastrev.scmid.blank?
        if changeset
          entry.lastrev.identifier = changeset.revision
          entry.lastrev.name = changeset.revision
          entry.lastrev.time = changeset.committed_on
          entry.lastrev.author = changeset.committer
        end
      end
    end
    entries
  end
  
  def cat(path, identifier=nil)
    patch = identifier.nil? ? nil : changesets.find_by_revision(identifier.to_s)
    scm.cat(path, patch.nil? ? nil : patch.scmid)
  end
  
  def diff(path, rev, rev_to)
    patch_from = changesets.find_by_revision(rev)
    return nil if patch_from.nil?
    patch_to = changesets.find_by_revision(rev_to) if rev_to
    if path.blank?
      path = patch_from.changes.collect{|change| change.path}.join(' ')
    end
    patch_from ? scm.diff(path, patch_from.scmid, patch_to ? patch_to.scmid : nil) : nil
  end
  
  def fetch_changesets
    scm_info = scm.info
    if scm_info
      db_last_id = latest_changeset ? latest_changeset.scmid : nil
      next_rev = latest_changeset ? latest_changeset.revision.to_i + 1 : 1      
      # latest revision in the repository
      scm_revision = scm_info.lastrev.scmid      
      unless changesets.find_by_scmid(scm_revision)
        revisions = scm.revisions('', db_last_id, nil, :with_path => true)
        transaction do
          revisions.reverse_each do |revision|
            changeset = Changeset.create(:repository => self,
                                         :revision => next_rev,
                                         :scmid => revision.scmid,
                                         :committer => revision.author, 
                                         :committed_on => revision.time,
                                         :comments => revision.message)
                                         
            revision.paths.each do |change|
              Change.create(:changeset => changeset,
                            :action => change[:action],
                            :path => change[:path],
                            :from_path => change[:from_path],
                            :from_revision => change[:from_revision])
            end
            next_rev += 1
          end if revisions
        end
      end
    end
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

