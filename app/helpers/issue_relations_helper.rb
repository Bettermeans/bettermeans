# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

module IssueRelationsHelper
  def collection_for_relation_type_select
    values = IssueRelation::TYPES
    values.keys.sort{|x,y| values[x][:order] <=> values[y][:order]}.collect{|k| [l(values[k][:name]), k]}
  end
end
