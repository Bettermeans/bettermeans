# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class IssuesController < ApplicationController
  def listen
    logger.info { "params #{params.inspect}" }
  end
end