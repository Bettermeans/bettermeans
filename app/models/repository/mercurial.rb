# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

require 'redmine/scm/adapters/mercurial_adapter'

class Repository::Mercurial < Repository
  attr_protected :root_url
  validates_presence_of :url

  def scm_adapter
    Redmine::Scm::Adapters::MercurialAdapter
  end
  
  def self.scm_name
    'Mercurial'
  end
  
  def entries(path=nil, identifier=nil)
    entries=scm.entries(path, identifier)
    if entries
      entries.each do |entry|
        next unless entry.is_file?
        # Set the filesize unless browsing a specific revision
        if identifier.nil?
          full_path = File.join(root_url, entry.path)
          entry.size = File.stat(full_path).size if File.file?(full_path)
        end
        # Search the DB for the entry's last change
        change = changes.find(:first, :conditions => ["path = ?", scm.with_leading_slash(entry.path)], :order => "#{Changeset.table_name}.committed_on DESC")
        if change
          entry.lastrev.identifier = change.changeset.revision
          entry.lastrev.name = change.changeset.revision
          entry.lastrev.author = change.changeset.committer
          entry.lastrev.revision = change.revision
        end
      end
    end
    entries
  end

  def fetch_changesets
    scm_info = scm.info
    if scm_info
      # latest revision found in database
      db_revision = latest_changeset ? latest_changeset.revision.to_i : -1
      # latest revision in the repository
      latest_revision = scm_info.lastrev
      return if latest_revision.nil?
      scm_revision = latest_revision.identifier.to_i
      if db_revision < scm_revision
        logger.debug "Fetching changesets for repository #{url}" if logger && logger.debug?
        identifier_from = db_revision + 1
        while (identifier_from <= scm_revision)
          # loads changesets by batches of 100
          identifier_to = [identifier_from + 99, scm_revision].min
          revisions = scm.revisions('', identifier_from, identifier_to, :with_paths => true)
          transaction do
            revisions.each do |revision|
              changeset = Changeset.create(:repository => self,
                                           :revision => revision.identifier,
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
            end
          end unless revisions.nil?
          identifier_from = identifier_to + 1
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

