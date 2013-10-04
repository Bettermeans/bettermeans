![status](https://secure.travis-ci.org/mockdeep/better.png?branch=master)
[![Code Climate](https://codeclimate.com/github/mockdeep/better.png)](https://codeclimate.com/github/mockdeep/better)
[![Dependency Status](https://gemnasium.com/mockdeep/better.png)](https://gemnasium.com/mockdeep/better)

live server hosted at: https://better.boon.gl

*** Use at your own risk!!! There are likely to be vulnerabilities in this
app!!! ***

Public workstream: https://better.boon.gl/projects/1

Pre-requisites
--------------

I recommend using rvm to manage your ruby versions:

* `rvm install 1.8.7-p374`

* `rvm rubygems 1.8.25`

Imagemagick is a dependency:

* `brew install imagemagick` [see here for errors installing rmagick](http://stackoverflow.com/a/13967303/372479)

Getting started
---------------

* `git clone git@github.com:Bettermeans/bettermeans.git`

* bundle install

* Rename `database.yml.example` to `database.yml`

* Run `rake db:create:all` and `rake db:schema:load`

* Then run `rake db:seed` to get some necessary seed data set up

* To load schema into test database, run `rake db:test:prepare`

* To run specs, run `rake`

Dev notes
---------

We're looking to get spec and heckle coverage up to 100%. You will find methods
throughout the code base tagged with `spec_me`, `cover_me`, and `heckle_me`.
These tags represent three levels of test quality in order of increasing
difficulty. Search through the codebase for places you can help like
`git grep spec_me`.

When the following conditions are met the tag can be removed:

### spec_me

This is pretty basic. All we need is a unit test hitting the method. For the
following method:

```ruby
def some_method
  if awesome?
    'awesome!'
  else
    'not awesome :('
  end
end
```

You might write a spec that looks like:

```ruby
describe '#some_method' do
  it 'returns "awesome!"' do
    some_method.should == 'awesome!'
  end
end
```

### cover_me

For code coverage you would need to expand the above test to include both
branches:

```ruby
describe '#some_method' do
  context 'when awesome' do
    it 'returns "awesome!"' do
      some_method.should == 'awesome!'
    end
  end

  context 'when not awesome' do
    it 'returns "not awesome :("' do
      awesome = false
      some_method.should == 'not awesome :('
    end
  end
end
```

You can check the coverage of tests by running `rake spec:rcov`. It generates
a coverage directory. Open `coverage/index.html` in your browser to view the
output.

### heckle_me

Heckle coverage is the hardest. Not only do you need cover the code, you need to
check for various permutations within it.
[Heckle](https://github.com/seattlerb/heckle) is a gem that performs mutations
on your code and runs your tests against the mutated code. If your tests don't
fail then your tests still need some work. Heckle lists out the changes it made
that did not cause your tests to fail.

You can run heckle
like this: `spec spec/models/user_spec.rb --heckle User#before_create`

Testing
-------

capybara-webkit depends on a WebKit implementation from Qt as explained in
https://github.com/thoughtbot/capybara-webkit/wiki/Installing-QT

Translating
-----------

You can find language specific translation groups at:
https://www.transifex.net/projects/p/bettermeans

Known issues
------------

Attachments doesn't work in dev environment

License and legalese
--------------------

Our codebase is based largely on an early fork of Redmine.

Redmine is open source and released under the terms of the GNU General Public License v2 (GPL).
All redmine code is Copyright (C) 2006-2011  Jean-Philippe Lang
All non-redmine code is Copyright (C) Shereef Bishay, and is dual-licensed: you may use either the GNU General Public License v2 (GPL), or the MIT License (see http://www.opensource.org/licenses/mit-license.php).
