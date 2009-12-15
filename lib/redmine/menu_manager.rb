# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

module Redmine
  module MenuManager
    module MenuController
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        @@menu_items = Hash.new {|hash, key| hash[key] = {:default => key, :actions => {}}}
        mattr_accessor :menu_items
        
        # Set the menu item name for a controller or specific actions
        # Examples:
        #   * menu_item :tickets # => sets the menu name to :tickets for the whole controller
        #   * menu_item :tickets, :only => :list # => sets the menu name to :tickets for the 'list' action only
        #   * menu_item :tickets, :only => [:list, :show] # => sets the menu name to :tickets for 2 actions only
        #   
        # The default menu item name for a controller is controller_name by default
        # Eg. the default menu item name for ProjectsController is :projects
        def menu_item(id, options = {})
          if actions = options[:only]
            actions = [] << actions unless actions.is_a?(Array)
            actions.each {|a| menu_items[controller_name.to_sym][:actions][a.to_sym] = id}
          else
            menu_items[controller_name.to_sym][:default] = id
          end
        end
      end
      
      def menu_items
        self.class.menu_items
      end
      
      # Returns the menu item name according to the current action
      def current_menu_item
        @current_menu_item ||= menu_items[controller_name.to_sym][:actions][action_name.to_sym] ||
                                 menu_items[controller_name.to_sym][:default]
      end
      
      # Redirects user to the menu item of the given project
      # Returns false if user is not authorized
      def redirect_to_project_menu_item(project, name)
        item = Redmine::MenuManager.items(:project_menu).detect {|i| i.name.to_s == name.to_s}
        if item && User.current.allowed_to?(item.url, project) && (item.condition.nil? || item.condition.call(project))
          redirect_to({item.param => project}.merge(item.url))
          return true
        end
        false
      end
    end
    
    module MenuHelper
      # Returns the current menu item name
      def current_menu_item
        @controller.current_menu_item
      end
      
      # Renders the application main menu
      def render_main_menu(project)
        render_menu((project && !project.new_record?) ? :project_menu : :application_menu, project)
      end
      
      def render_menu(menu, project=nil)
        links = []
        menu_items_for(menu, project) do |item, caption, url, selected|
          links << content_tag('li', 
            link_to(h(caption), url, item.html_options(:selected => selected)))
        end
        links.empty? ? nil : content_tag('ul', links.join("\n"))
      end

      def menu_items_for(menu, project=nil)
        items = []
        Redmine::MenuManager.allowed_items(menu, User.current, project).each do |item|
          unless item.condition && !item.condition.call(project)
            url = case item.url
            when Hash
              project.nil? ? item.url : {item.param => project}.merge(item.url)
            when Symbol
              send(item.url)
            else
              item.url
            end
            caption = item.caption(project)
            # logger.info("Current vs. name: #{current_menu_item} :  #{item.name}")
            if block_given?
              yield item, caption, url, (current_menu_item == item.name)
            else
              items << [item, caption, url, (current_menu_item == item.name)]
            end
          end
        end
        return block_given? ? nil : items
      end
    end
    
    class << self
      def map(menu_name)
        @items ||= {}
        mapper = Mapper.new(menu_name.to_sym, @items)
        if block_given?
          yield mapper
        else
          mapper
        end
      end
      
      def items(menu_name)
        @items[menu_name.to_sym] || []
      end
      
      def allowed_items(menu_name, user, project)
        project ? items(menu_name).select {|item| user && user.allowed_to?(item.url, project)} : items(menu_name)
      end
    end
    
    class Mapper
      def initialize(menu, items)
        items[menu] ||= []
        @menu = menu
        @menu_items = items[menu]
      end
      
      @@last_items_count = Hash.new {|h,k| h[k] = 0}
      
      # Adds an item at the end of the menu. Available options:
      # * param: the parameter name that is used for the project id (default is :id)
      # * if: a Proc that is called before rendering the item, the item is displayed only if it returns true
      # * caption that can be:
      #   * a localized string Symbol
      #   * a String
      #   * a Proc that can take the project as argument
      # * before, after: specify where the menu item should be inserted (eg. :after => :activity)
      # * last: menu item will stay at the end (eg. :last => true)
      # * html_options: a hash of html options that are passed to link_to
      def push(name, url, options={})
        options = options.dup
        
        # menu item position
        if before = options.delete(:before)
          position = @menu_items.collect(&:name).index(before)
        elsif after = options.delete(:after)
          position = @menu_items.collect(&:name).index(after)
          position += 1 unless position.nil?
        elsif options.delete(:last)
          position = @menu_items.size
          @@last_items_count[@menu] += 1
        end
        # default position
        position ||= @menu_items.size - @@last_items_count[@menu]
        
        @menu_items.insert(position, MenuItem.new(name, url, options))
      end
      
      # Removes a menu item
      def delete(name)
        @menu_items.delete_if {|i| i.name == name}
      end
    end
    
    class MenuItem
      include Redmine::I18n
      attr_reader :name, :url, :param, :condition
      
      def initialize(name, url, options)
        raise "Invalid option :if for menu item '#{name}'" if options[:if] && !options[:if].respond_to?(:call)
        raise "Invalid option :html for menu item '#{name}'" if options[:html] && !options[:html].is_a?(Hash)
        @name = name
        @url = url
        @condition = options[:if]
        @param = options[:param] || :id
        @caption = options[:caption]
        @html_options = options[:html] || {}
        # Adds a unique class to each menu item based on its name
        @html_options[:class] = [@html_options[:class], @name.to_s.dasherize].compact.join(' ')
      end
      
      def caption(project=nil)
        if @caption.is_a?(Proc)
          c = @caption.call(project).to_s
          c = @name.to_s.humanize if c.blank?
          c
        else
          if @caption.nil?
            l_or_humanize(name, :prefix => 'label_')
          else
            @caption.is_a?(Symbol) ? l(@caption) : @caption
          end
        end
      end
      
      def html_options(options={})
        if options[:selected]
          o = @html_options.dup
          o[:class] += ' selected'
          o
        else
          @html_options
        end
      end
    end    
  end
end
