# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

module AttachmentsHelper
  # Displays view/delete links to the attachments of the given object
  # Options:
  #   :author -- author names are not displayed if set to false
  def link_to_attachments(container, options = {})
    options.assert_valid_keys(:author)
    
    if container.attachments.any?
      options = {:deletable => container.attachments_deletable?, :author => true}.merge(options)
      render :partial => 'attachments/links', :locals => {:attachments => container.attachments, :options => options}
    end
  end

  def link_to_attachments_table(container, options = {})
    options.assert_valid_keys(:author)
    
    if container.attachments.any?
      options = {:deletable => container.attachments_deletable?, :author => true}.merge(options)
      render :partial => 'attachments/table', :locals => {:attachments => container.attachments, :options => options}
    end
  end
  
  def to_utf8(str)
    str
  end
end
