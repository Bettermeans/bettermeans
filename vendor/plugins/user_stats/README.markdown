# UserStats

A Sinatra-based plugin template for displaying a user metrics dashboard in Rails applications.

This plugin provides a starting point for creating a dashboard to view user metrics for an application. Inspired by [other metrics dashboards](http://www.mindscape.co.nz/staff/johndaniel/index.php/2010/03/business-porn-the-company-dashboard/).

In its current form, it assumes you are using Authlogic with a `User` model and shows some basic information about recent sign ups and, if your `User` model has a `last_request_at` attribute, information about active users. Edit the plugin as necessary for your application.

## Installation

    $ script/plugin install git://github.com/alphabetum/user_stats.git

Add the following to `config/environment.rb`

    config.middleware.use "UserStats::Application"

UserStats depends on Haml and Sinatra:

    # config/environment.rb
    ...
    config.gem 'haml'
    config.gem 'sinatra'
    ...

or if using Bundler
    
    # Gemfile
    gem 'haml'
    gem 'sinatra'

Last, define a `User#can_view_user_stats?` instance method that returns a boolean indicating whether the user can view stats or not.

If you want to be able to reload the plugin's templates as you edit them, add the following to you development environment:

    # config/environments/development.rb
    config.reload_plugins = true

# Usage

Run `script/server` and point your browser to `http://localhost:3000/__user_stats`

# Screenshot

![User Stats](http://imgur.com/yBah7.png)

Copyright (c) 2010 William Melody, released under the MIT license
