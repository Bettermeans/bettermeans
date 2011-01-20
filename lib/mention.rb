# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class Mention
  def self.parse(object, mentioner_id)
    #loop through properties and only search for mentions in text fields
    object.attributes.each_value do |text|
      next if text.class.to_s != 'String'
      text = text.gsub(%r{([\s\(,\-\>]|^)(!)?(attachment|document|version|commit|source|export|message)?((#|r)(\d+)|(@)([a-zA-Z0-9._@]+)|(:)([^"\s<>][^\s<>]*?|"[^"]+?"))(?=(?=[[:punct:]]\W)|,|\s|<|$)}) do |m|
        leading, esc, prefix, sep, oid = $1, $2, $3, $5 || $7, $6 || $8
        if esc.nil?
          if sep == '@'
            send_mention(object,mentioner_id,oid,text)
          end
        end
      end
    end
  end
  
  def self.send_mention(object,mentioner_id, mentioned_login, mention_text)
    #Find user or abort
    user = User.find_by_login(mentioned_login)
    
    return if user.nil?
    
    #Find better sub-section of text that includes user login
    mention_text_subsection = mention_text
    
    #Send mention to issue
    object.send(:mention,mentioner_id,user.id,mention_text_subsection)
  end
  
end
