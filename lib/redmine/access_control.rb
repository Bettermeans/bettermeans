# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

module Redmine
  module AccessControl

    class << self
      def map # spec_me cover_me heckle_me
        mapper = Mapper.new
        yield mapper
        @permissions ||= []
        @permissions += mapper.mapped_permissions
      end

      def permissions # spec_me cover_me heckle_me
        @permissions
      end

      # Returns the permission of given name or nil if it wasn't found
      # Argument should be a symbol
      def permission(name) # spec_me cover_me heckle_me
        permissions.detect {|p| p.name == name}
      end

      # Returns the actions that are allowed by the permission of given name
      def allowed_actions(permission_name) # spec_me cover_me heckle_me
        perm = permission(permission_name)
        perm ? perm.actions : []
      end

      def public_permissions # spec_me cover_me heckle_me
        @public_permissions ||= @permissions.select {|p| p.public?}
      end

      def members_only_permissions # spec_me cover_me heckle_me
        @members_only_permissions ||= @permissions.select {|p| p.require_member?}
      end

      def loggedin_only_permissions # spec_me cover_me heckle_me
        @loggedin_only_permissions ||= @permissions.select {|p| p.require_loggedin?}
      end

      def available_project_modules # spec_me cover_me heckle_me
        @available_project_modules ||= @permissions.collect(&:project_module).uniq.compact
      end

      def modules_permissions(modules) # spec_me cover_me heckle_me
        @permissions.select {|p| p.project_module.nil? || modules.include?(p.project_module.to_s)}
      end
    end

    class Mapper
      def initialize # spec_me cover_me heckle_me
        @project_module = nil
      end

      def permission(name, hash, options={}) # spec_me cover_me heckle_me
        @permissions ||= []
        options.merge!(:project_module => @project_module)
        @permissions << Permission.new(name, hash, options)
      end

      def project_module(name, options={}) # spec_me cover_me heckle_me
        @project_module = name
        yield self
        @project_module = nil
      end

      def mapped_permissions # spec_me cover_me heckle_me
        @permissions
      end
    end

    class Permission
      attr_reader :name, :actions, :project_module

      def initialize(name, hash, options) # spec_me cover_me heckle_me
        @name = name
        @actions = []
        @public = options[:public] || false
        @require = options[:require]
        @project_module = options[:project_module]
        hash.each do |controller, actions|
          if actions.is_a? Array
            @actions << actions.collect {|action| "#{controller}/#{action}"}
          else
            @actions << "#{controller}/#{actions}"
          end
        end
        @actions.flatten!
      end

      def public? # spec_me cover_me heckle_me
        @public
      end

      def require_member? # spec_me cover_me heckle_me
        @require && @require == :member
      end

      def require_loggedin? # spec_me cover_me heckle_me
        @require && (@require == :member || @require == :loggedin)
      end
    end
  end
end
