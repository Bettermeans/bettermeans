# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class WikiRedirect < ActiveRecord::Base
  belongs_to :wiki

  validates_presence_of :title, :redirects_to
  validates_length_of :title, :redirects_to, :maximum => 255
end

