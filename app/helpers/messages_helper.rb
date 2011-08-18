# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

module MessagesHelper

  def link_to_message(message)
    return '' unless message
    link_to h(truncate(message.subject, :length => 60)), :controller => 'messages',
                                           :action => 'show',
                                           :board_id => message.board_id,
                                           :id => message.root,
                                           :anchor => (message.parent_id ? "message-#{message.id}" : nil)
  end
end
