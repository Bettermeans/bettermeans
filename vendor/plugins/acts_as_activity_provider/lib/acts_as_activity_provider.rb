# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

module Redmine
  module Acts
    module ActivityProvider
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_activity_provider(options = {})
          # puts("#{options.inspect}")
          unless self.included_modules.include?(Redmine::Acts::ActivityProvider::InstanceMethods)
            cattr_accessor :activity_provider_options
            send :include, Redmine::Acts::ActivityProvider::InstanceMethods
          end

          options.assert_valid_keys(:type, :permission, :timestamp, :author_key, :find_options)
          self.activity_provider_options ||= {}
          
          # One model can provide different event types
          # We store these options in activity_provider_options hash
          event_type = options.delete(:type) || self.name.underscore.pluralize
          
          # puts("ADDING ACTIVITY PROVIDER: #{event_type}")
          
          options[:permission] = "view_#{self.name.underscore.pluralize}".to_sym unless options.has_key?(:permission)
          options[:timestamp] ||= "#{table_name}.created_on"
          options[:find_options] ||= {}
          options[:author_key] = "#{table_name}.#{options[:author_key]}" if options[:author_key].is_a?(Symbol)
          self.activity_provider_options[event_type] = options
          # puts("All events: #{Redmine::Activity.available_event_types}")
        end
      end

      module InstanceMethods
        def self.included(base)
          base.extend ClassMethods
        end
                
        module ClassMethods
          # Returns events of type event_type visible by user that occured between from and to
          def find_events(event_type, user, from, to, options)
            provider_options = activity_provider_options[event_type]
            raise "#{self.name} can not provide #{event_type} events." if provider_options.nil?
            
            scope_options = {}
            cond = ARCondition.new
            if from && to
              cond.add(["#{provider_options[:timestamp]} BETWEEN ? AND ?", from, to])
            end
            if options[:author]
              return [] if provider_options[:author_key].nil?
              cond.add(["#{provider_options[:author_key]} = ?", options[:author].id])
            end
            cond.add(Project.allowed_to_condition(user, provider_options[:permission], options)) if provider_options[:permission]
            scope_options[:conditions] = cond.conditions
            if options[:limit]
              # id and creation time should be in same order in most cases
              scope_options[:order] = "#{table_name}.id DESC"
              scope_options[:limit] = options[:limit]
            end
            
            with_scope(:find => scope_options) do
              find(:all, provider_options[:find_options].dup)
            end
          end
        end
      end
    end
  end
end
