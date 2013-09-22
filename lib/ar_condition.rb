# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
#

class ARCondition
  attr_reader :conditions

  def initialize(condition=nil) # spec_me cover_me heckle_me
    @conditions = ['1=1']
    add(condition) if condition
  end

  def add(condition) # spec_me cover_me heckle_me
    if condition.is_a?(Array)
      @conditions.first << " AND (#{condition.first})"
      @conditions += condition[1..-1]
    elsif condition.is_a?(String)
      @conditions.first << " AND (#{condition})"
    else
      raise "Unsupported #{condition.class} condition: #{condition}"
    end
    self
  end

  def <<(condition) # spec_me cover_me heckle_me
    add(condition)
  end
end
