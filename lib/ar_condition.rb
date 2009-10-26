# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

class ARCondition
  attr_reader :conditions
  
  def initialize(condition=nil)
    @conditions = ['1=1']
    add(condition) if condition
  end
  
  def add(condition)
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

  def <<(condition)
    add(condition)
  end
end
