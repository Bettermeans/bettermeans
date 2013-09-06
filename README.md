![status](https://secure.travis-ci.org/mockdeep/better.png?branch=master)
[![Code Climate](https://codeclimate.com/github/mockdeep/better.png)](https://codeclimate.com/github/mockdeep/better)
[![Dependency Status](https://gemnasium.com/mockdeep/better.png)](https://gemnasium.com/mockdeep/better)

live server hosted at: https://better.boon.gl

*** Use at your own risk!!! There are likely to be vulnerabilities in this app!!! ***

BetterMeans
-----------

BetterMeans is giving birth to a new kind of company. An Open Enterprise.

More details can be found at http://bettermeans.com and here http://bettermeans.org


Getting started
---------------

* `git clone git@github.com:Bettermeans/bettermeans.git`

* bundle install

* Rename `database.yml.example` to `database.yml`

* Run `rake db:create:all` and `rake db:schema:load`

* To load schema into test databse, run `rake db:test:prepare`

* To run specs, run `rake`

That's it. Now you're ready to change the world. Here's to making a dent in things together!


Dev notes
---------

Platform workstream: http://bettermeans.com/projects/2/dashboard

IRC: #bettermeans irc.feenode.net

mailinglist: bettermeans@librelist.org (or build in workstream forum)


Testing
-------

capybara-webkit depends on a WebKit implementation from Qt as explained in https://github.com/thoughtbot/capybara-webkit/wiki/Installing-QT


Translating
-----------

You can find language specific translation groups at: https://www.transifex.net/projects/p/bettermeans


Known issues
------------

Attachments doesn't work in dev environment

Logging in via the janrain plugin (e.g. google, twitter...etc) won't work in dev environment (if you need to work with this, drop me a message, there's an involved workaround)


License and legalese
--------------------

Our codebase is based largely on an early fork of Redmine.

Redmine is open source and released under the terms of the GNU General Public License v2 (GPL).
All redmine code is Copyright (C) 2006-2011  Jean-Philippe Lang
All non-redmine code is Copyright (C) Shereef Bishay, and is dual-licensed: you may use either the GNU General Public License v2 (GPL), or the MIT License (see http://www.opensource.org/licenses/mit-license.php).

Thanks for joining us! May our work be used for the greater good of everyone.
