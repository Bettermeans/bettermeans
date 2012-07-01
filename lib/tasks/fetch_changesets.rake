# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
#

desc 'Fetch changesets from the repositories'

namespace :redmine do
  task :fetch_changesets => :environment do
    Repository.fetch_changesets
  end
end
