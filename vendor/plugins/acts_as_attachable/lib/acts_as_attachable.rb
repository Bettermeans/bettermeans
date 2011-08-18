# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license
#

module Redmine
  module Acts
    module Attachable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_attachable(options = {})
          cattr_accessor :attachable_options
          self.attachable_options = {}
          attachable_options[:view_permission] = options.delete(:view_permission) || "view_#{self.name.pluralize.underscore}".to_sym
          attachable_options[:delete_permission] = options.delete(:delete_permission) || "edit_#{self.name.pluralize.underscore}".to_sym
          
          has_many :attachments, options.merge(:as => :container,
                                               :order => "#{Attachment.table_name}.created_at",
                                               :dependent => :destroy)
          send :include, Redmine::Acts::Attachable::InstanceMethods
        end
      end

      module InstanceMethods
        def self.included(base)
          base.extend ClassMethods
        end
        
        def attachments_visible?(user=User.current)
          user.allowed_to?(self.class.attachable_options[:view_permission], self.project)
        end
        
        def attachments_deletable?(user=User.current)
          user.allowed_to?(self.class.attachable_options[:delete_permission], self.project)
        end
        
        module ClassMethods
        end
      end
    end
  end
end
