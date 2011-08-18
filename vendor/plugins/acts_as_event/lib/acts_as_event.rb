# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

module Redmine
  module Acts
    module Event
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_event(options = {})
          return if self.included_modules.include?(Redmine::Acts::Event::InstanceMethods)
          default_options = { :datetime => :created_at,
                              :title => :title,
                              :description => :description,
                              :author => :author,
                              :url => {:controller => 'welcome'},
                              :type => self.name.underscore.dasherize }
                              
          cattr_accessor :event_options
          self.event_options = default_options.merge(options)
          send :include, Redmine::Acts::Event::InstanceMethods
        end
      end

      module InstanceMethods
        def self.included(base)
          base.extend ClassMethods
        end
        
        %w(datetime title description author type).each do |attr|
          src = <<-END_SRC
            def event_#{attr}
              option = event_options[:#{attr}]
              if option.is_a?(Proc)
                option.call(self)
              elsif option.is_a?(Symbol)
                send(option)
              else
                option
              end
            end
          END_SRC
          class_eval src, __FILE__, __LINE__
        end
        
        def event_date
          event_datetime.to_date
        end
        
        def event_url(options = {})
          option = event_options[:url]
          (option.is_a?(Proc) ? option.call(self) : send(option)).merge(options)
        end

        module ClassMethods
        end
      end
    end
  end
end
