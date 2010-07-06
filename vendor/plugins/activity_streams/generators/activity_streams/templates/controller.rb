#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# Template to generate the controllers
class <%= controller_name %>Controller < ApplicationController
  include <%= controller_name %>Module
  before_filter :login_required, :except => :feed
<% if controller_name == 'ActivityStreams' -%>
  before_filter :admin_required, :except => :feed
<% end -%>
end
