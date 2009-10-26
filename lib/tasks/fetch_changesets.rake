# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

desc 'Fetch changesets from the repositories'

namespace :redmine do
  task :fetch_changesets => :environment do
    Repository.fetch_changesets
  end
end
