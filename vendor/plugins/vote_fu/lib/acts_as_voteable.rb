# ActsAsVoteable
module Juixe
  module Acts #:nodoc:
    module Voteable #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_voteable
          has_many :votes, :as => :voteable, :dependent => :nullify

          include Juixe::Acts::Voteable::InstanceMethods
          extend  Juixe::Acts::Voteable::SingletonMethods
        end        
      end
      
      # This module contains class methods
      module SingletonMethods
        
        # Calculate the vote counts for all voteables of my type.
        def tally(options = {})
          find(:all, options_for_tally(options.merge({:order =>"count DESC" })))
        end

        # 
        # Options:
        #  :start_at    - Restrict the votes to those created after a certain time
        #  :end_at      - Restrict the votes to those created before a certain time
        #  :conditions  - A piece of SQL conditions to add to the query
        #  :limit       - The maximum number of voteables to return
        #  :order       - A piece of SQL to order by. Eg 'votes.count desc' or 'voteable.created_at desc'
        #  :at_least    - Item must have at least X votes
        #  :at_most     - Item may not have more than X votes
        def options_for_tally (options = {})
            options.assert_valid_keys :start_at, :end_at, :conditions, :at_least, :at_most, :order, :limit

            scope = scope(:find)
            start_at = sanitize_sql(["#{Vote.table_name}.created_at >= ?", options.delete(:start_at)]) if options[:start_at]
            end_at = sanitize_sql(["#{Vote.table_name}.created_at <= ?", options.delete(:end_at)]) if options[:end_at]

            type_and_context = "#{Vote.table_name}.voteable_type = #{quote_value(base_class.name)}"

            conditions = [
              type_and_context,
              options[:conditions],
              start_at,
              end_at
            ]

            conditions = conditions.compact.join(' AND ')
            conditions = merge_conditions(conditions, scope[:conditions]) if scope

            joins = ["LEFT OUTER JOIN #{Vote.table_name} ON #{table_name}.#{primary_key} = #{Vote.table_name}.voteable_id"]
            joins << scope[:joins] if scope && scope[:joins]
            at_least  = sanitize_sql(["COUNT(#{Vote.table_name}.id) >= ?", options.delete(:at_least)]) if options[:at_least]
            at_most   = sanitize_sql(["COUNT(#{Vote.table_name}.id) <= ?", options.delete(:at_most)]) if options[:at_most]
            having    = [at_least, at_most].compact.join(' AND ')
            group_by  = "#{Vote.table_name}.voteable_id HAVING COUNT(#{Vote.table_name}.id) > 0"
            group_by << " AND #{having}" unless having.blank?

            { :select     => "#{table_name}.*, COUNT(#{Vote.table_name}.id) AS count", 
              :joins      => joins.join(" "),
              :conditions => conditions,
              :group      => group_by
            }.update(options)          
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        def votes_for
          Vote.count(:all, :conditions => [
            "voteable_id = ? AND voteable_type = ? AND vote = ?",
            id, self.class.name, true
          ])
        end
        
        def votes_against
          Vote.count(:all, :conditions => [
            "voteable_id = ? AND voteable_type = ? AND vote = ?",
            id, self.class.name, false
          ])
        end
        
        # Same as voteable.votes.size
        def votes_count
          self.votes.size
        end
        
        def voters_who_voted
          voters = []
          self.votes.each { |v|
            voters << v.voter
          }
          voters
        end
        
        def voted_by?(voter)
          rtn = false
          if voter
            self.votes.each { |v|
              rtn = true if (voter.id == v.voter_id && voter.class.name == v.voter_type)
            }
          end
          rtn
        end
        
        
      end
    end
  end
end
