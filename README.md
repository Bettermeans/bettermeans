[![status](https://secure.travis-ci.org/mockdeep/better.png?branch=master)](https://secure.travis-ci.org/mockdeep/better?branch=master)
[![Code Climate](https://codeclimate.com/github/mockdeep/better.png)](https://codeclimate.com/github/mockdeep/better)
[![Dependency Status](https://gemnasium.com/mockdeep/better.png)](https://gemnasium.com/mockdeep/better)

live server hosted at: https://better.boon.gl

*** Use at your own risk!!! There are likely to be vulnerabilities in this
app!!! ***

Support this project
--------------------
[![Pledgie](https://pledgie.com/campaigns/27557.png)](https://pledgie.com/campaigns/27557)
[![Gratipay](https://img.shields.io/gratipay/mockdeep.svg)](https://www.gratipay.com/mockdeep/)
[![Bountysource](https://www.bountysource.com/badge/tracker?tracker_id=416557)](https://www.bountysource.com/trackers/416557-mockdeep-better?utm_source=416557&utm_medium=shield&utm_campaign=TRACKER_BADGE)

Roadmap
-------
1. get code coverage up to 100% -> currently 45.49%
  - -> controllers
  - models
  - helpers
  - remove lib code to gems where possible
  - remove unused lib code where possible
  - libs
  - any stragglers
2. add spec files for every method (use "spec_me" tags, 1163 and counting)
3. mutation test every method (use "heckle_me" tags, 1649 left)
4. upgrade to Ruby 1.9
5. set up Rubocop and clean up code quality
6. integration test and move vendored gems to Gemfile
7. integrate rails_best_practices and clean up code
8. fix password hashing
9. run Brakeman and fix vulnerabilities
10. integrate jshint and clean up javascript
11. rename all references from Bettermeans to Better
12. upgrade to Rails 3.0, 3.1, 3.2
13. upgrade to Ruby 2.0, 2.1
14. upgrade to Rails 4.0, 4.1, 4.2
15. begin using and extending...

Contributing
------------

This project is long out of maintenance. I'm trying to bring it up to snuff in
my spare time, but as you can see from the commit history, progress is slow.
If you are interested in contributing, we are looking to add contributors to
the project. All experience levels are welcome. If you're just getting started
as a developer, please get in touch and I can help you get up and running.
Check the [dev notes](https://github.com/mockdeep/better#dev-notes) below for
details on the biggest area we could use help with: testing.

Pre-requisites
--------------

I recommend using rvm to manage your ruby versions: https://rvm.io/

```sh
# install ruby:
rvm install 1.8.7-p374

# set ruby version:
rvm use 1.8.7

# set the rubygems version:
rvm rubygems 1.8.25 --force

# install postgres:
# mac
brew install postgres
# debian linux
sudo apt-get install postgresql postgresql-client postgresql-contrib

# NOTE: only do this in development mode, as it puts your database in an
# insecure state.
# update the end of /etc/postgresql/9.1/main/pg_hba.conf to look like this:
# # TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
# # "local" is for Unix domain socket connections only
# local   all         all                               trust
# # IPv4 local connections:
# host    all         all         127.0.0.1/32          trust
# # IPv6 local connections:
# host    all         all         ::1/128               trust

# then run:
sudo /etc/init.d/postgresql restart

# set up a postgres user:
sudo su
su postgres
createuser -s -r <your username>
# and hit CTRL+D twice to exit back to your regular user account

# Imagemagick is also a dependency. You'll need an older version to be
# compatible with rmagick, which can be a bit of a pain on MacOS. See here for
# more details: http://stackoverflow.com/a/13967303/372479
# It's easier on Debian Linux:
sudo apt-get install imagemagick libmagickwand-dev

# and QT
# Mac:
brew install qt
# Debian Linux:
sudo apt-get install libqt4-dev libqtwebkit-dev
```

Getting started
---------------

First fork the repo using the link above, then:

```sh
# clone your copy:
git clone git@github.com:<your username>/better.git
cd better/

# Add this copy as upstream:
git remote add upstream https://github.com/mockdeep/better.git

# now install gems:
bundle install

# set up database config:
mv config/database.yml.example config/database.yml

# in development mode, for the simplest setup you should be able to remove the
# username and password options from `config/database.yml` for the development
# and test group

# You'll need to set up aws access keys in your environment. For testing only,
# you can set the keys to "trash" just to run the specs
export BETTER_S3_ACCESS_KEY_ID=trash
export BETTER_S3_SECRET_ACCESS_KEY=trash

# set up database:
rake db:create:all && rake db:schema:load

# seed data into the database:
rake db:seed

# set up the test database:
rake db:test:prepare

# and run the tests:
rake spec

# if all passes, then you should be good to go. Please open an issue if you
# have any problems. You can boot up your server on localhost with:
script/server
```

Production
----------

You'll need to set up the following in order to run on production. If you're
deploying to Heroku you can push environment variables using
`heroku config:add MY_VAR=whatevs`.

* A honeybadger.io API key: `BETTER_HONEYBADGER_API_KEY=<your key here>`
* S3 access keys:
  - `S3_ACCESS_KEY_ID=<your AWS S3 access key id>`
  - `S3_SECRET_ACCESS_KEY=<your AWS S3 secret access key`
* Sendgrid credentials:
  - `SENDGRID_DOMAIN=<the domain of your app>`
  - `SENDGRID_PASSWORD=<your sendgrid password>`
  - `SENDGRID_USERNAME=<your sendgrid username>`

Dev notes
---------

We're looking to get spec and mutation coverage up to 100%. You will find
methods throughout the code base tagged with `spec_me`, `cover_me`, and
`heckle_me`.  These tags represent three levels of test quality in order of
increasing difficulty. Choose your difficulty level and search through the
codebase for places you can help like `git grep spec_me`.

When the following conditions are met the tag can be removed:

### spec_me

This is pretty basic. All we need is a unit test hitting the method. For the
following method:

```ruby
class MyClass
  attr_accessor :awesome

  def initialize
    awesome = true
  end

  def some_method
    if awesome?
      'awesome!'
    else
      'not awesome :('
    end

    def awesome?
      !!awesome
    end
  end
end
```

You might write a spec that looks like:

```ruby
describe MyClass, '#some_method' do
  it 'returns "awesome!"' do
    MyClass.new.some_method.should == 'awesome!'
  end
end
```

### cover_me

For code coverage you would need to expand the above test to include both
branches:

```ruby
describe MyClass, '#some_method' do
  context 'when awesome' do
    it 'returns "awesome!"' do
      MyClass.new.some_method.should == 'awesome!'
    end
  end

  context 'when not awesome' do
    it 'returns "not awesome :("' do
      my_instance = MyClass.new
      my_instance.awesome = false
      my_instance.some_method.should == 'not awesome :('
    end
  end
end
```

You can check the coverage of tests by running `rake spec:rcov`. It generates
a coverage directory. Open `coverage/index.html` in your browser to view the
output and find a class that still needs test coverage.

### heckle_me

Heckle coverage is the hardest. Not only do you need cover the code, you need
to check for various permutations within it.
[Heckle](https://github.com/seattlerb/heckle) is a gem that performs mutations
on your code and runs your tests against the mutated code.  If your tests don't
fail then they still need some work. Heckle lists out the changes it made that
did not cause your tests to fail.

You can run heckle like this:

```sh
spec spec/models/board/visible_predicate_spec.rb --heckle Board#visible?
```

Translating
-----------

You can find language specific translation groups at:
https://www.transifex.net/projects/p/better/

Known issues
------------

Attachments doesn't work in dev environment

License and legalese
--------------------

This codebase is based largely on the project Bettermeans, which was itself
based on Redmine. Both Bettermeans and Redmine are open source and released
under the terms of the GNU General Public License v2 (GPL). Better is also
GPLv2.

All Redmine code is Copyright (C) 2006-2011  Jean-Philippe Lang

All Bettermeans code is Copyright (C) Shereef Bishay

All Better code is Copyright (C) Robert Fletcher
