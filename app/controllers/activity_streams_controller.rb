#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# Template to generate the controllers
class ActivityStreamsController < ApplicationController
  include ActivityStreamsModule
  before_filter :require_login, :except => :feed
  # before_filter :require_admin, :except => :feed
end
