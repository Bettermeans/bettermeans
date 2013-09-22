# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

module IssueRelationsHelper
  def collection_for_relation_type_select # spec_me cover_me heckle_me
    values = IssueRelation::TYPES
    values.keys.sort{|x,y| values[x][:order] <=> values[y][:order]}.collect{|k| [l(values[k][:name]), k]}
  end
end
