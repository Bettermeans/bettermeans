# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class Mail < ActiveRecord::Base

  is_private_message

  # The :to accessor is used by the scaffolding,
  # uncomment it if using it or you can remove it if not
  attr_accessor :to

end
