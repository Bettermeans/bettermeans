# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class Mail < ActiveRecord::Base

  is_private_message

  
  # The :to accessor is used by the scaffolding,
  # uncomment it if using it or you can remove it if not
  attr_accessor :to
  
end

# == Schema Information
#
# Table name: mails
#
#  id                :integer         not null, primary key
#  sender_id         :integer
#  recipient_id      :integer
#  sender_deleted    :boolean         default(FALSE)
#  recipient_deleted :boolean         default(FALSE)
#  subject           :string(255)
#  body              :text
#  read_at           :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

