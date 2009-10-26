# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class DocumentCategory < Enumeration
  has_many :documents, :foreign_key => 'category_id'

  OptionName = :enumeration_doc_categories
  # Backwards compatiblity.  Can be removed post-0.9
  OptName = 'DCAT'

  def option_name
    OptionName
  end

  def objects_count
    documents.count
  end

  def transfer_relations(to)
    documents.update_all("category_id = #{to.id}")
  end
end
