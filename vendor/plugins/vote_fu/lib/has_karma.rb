# Has Karma

module PeteOnRails
  module VoteFu #:nodoc:
    module Karma #:nodoc:

      def self.included(base)
        base.extend ClassMethods
        class << base
          attr_accessor :karmatic_objects
        end
      end

      module ClassMethods
        def has_karma(voteable_type)
          self.class_eval <<-RUBY
            def karma_voteable
              #{voteable_type.to_s.classify}
            end
          RUBY
          include PeteOnRails::VoteFu::Karma::InstanceMethods
          extend  PeteOnRails::VoteFu::Karma::SingletonMethods
          if self.karmatic_objects.nil?
            self.karmatic_objects = [eval(voteable_type.to_s.classify)]
          else
            self.karmatic_objects.push(eval(voteable_type.to_s.classify))
          end
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        
        ## Not yet implemented. Don't use it!
        # Find the most popular users
        def find_most_karmic
          find(:all)
        end
                      
      end
      
      # This module contains instance methods
      module InstanceMethods
        def karma(options = {})
          #FIXME cannot have 2 models imapcting the karma simultaneously
          # count the total number of votes on all of the voteable objects that are related to this object
          #2009-01-30 GuillaumeNM The following line is not SQLite3 compatible, because boolean are stored as 'f' or 't', not '1', or '0'
          #self.karma_voteable.sum(:vote, options_for_karma(options))
          #self.karma_voteable.find(:all, options_for_karma(options)).length
          karma_value = 0
          self.class.karmatic_objects.each do |object|
            karma_value += object.find(:all, options_for_karma(object, options)).length
          end
          return karma_value
        end
        
        def options_for_karma (object, options = {})
            #GuillaumeNM : 2009-01-30 Adding condition for SQLite3
            logger.info "CLASS NAME = " + object.table_name
            conditions = ""
          case String(object.table_name)
          when "issues"
            logger.info "EXCEPTION FOR ISSUE TABLE ACTIVATED"
            conditions = ["u.id = ? AND vote = ? AND v.voteable_type = ?" , self[:id] , true, "issue"] #TODO this could be DRYER
            joins = ["inner join votes v on #{object.table_name}.id = v.voteable_id", "inner join #{self.class.table_name} u on u.id = issues.author_id"]
          when "messages"
            conditions = ["u.id = ? AND vote = ? AND v.voteable_type = ?" , self[:id] , true, "message"] #TODO this could be DRYER
            joins = ["inner join votes v on #{object.table_name}.id = v.voteable_id", "inner join #{self.class.table_name} u on u.id = messages.author_id"]
          when "journals"
            conditions = ["u.id = ? AND vote = ? AND v.voteable_type = ?" , self[:id] , true, "journal"] #TODO this could be DRYER
            joins = ["inner join votes v on #{object.table_name}.id = v.voteable_id", "inner join #{self.class.table_name} u on u.id = #{object.name.tableize}.#{self.class.name.foreign_key}"]
          end  
            { :joins => joins.join(" "), :conditions => conditions }.update(options)          
        end
        
      end
      
    end
  end
end
