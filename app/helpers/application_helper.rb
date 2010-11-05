# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#


require 'coderay'
require 'coderay/helpers/file_type'
require 'forwardable'
require 'cgi'

module ApplicationHelper
  include Redmine::WikiFormatting::Macros::Definitions
  include Redmine::I18n
  include GravatarHelper::PublicMethods

  extend Forwardable
  def_delegators :wiki_helper
    
  def help_section(name, popup=false)
    logger.info { "helping #{popup}" }
    return if User.current.anonymous?
    
    help_section = HelpSection.first(:conditions => {:user_id => User.current.id, :name => name})

    if help_section.nil?
      help_section = HelpSection.create(
      :user_id => User.current.id,
      :name => name,
      :show => true
      )
    end
    
    if popup 
      render :partial => 'help_sections/show_popup', :locals => {:help_section => help_section} if help_section.show #&& false
    else
      render :partial => 'help_sections/show', :locals => {:help_section => help_section} if help_section.show #&& false
    end
  end

  # Return true if user is authorized for controller/action, otherwise false
  def authorize_for(controller, action)
    User.current.allowed_to?({:controller => controller, :action => action}, @project)
  end

  # Display a link if user is authorized
  def link_to_if_authorized(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options, html_options, *parameters_for_method_reference) if authorize_for(options[:controller] || params[:controller], options[:action])
  end

  # Display a link if user is not logged in
  def link_to_if_anon(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options, html_options, *parameters_for_method_reference) if User.current == User.anonymous
  end

  # Display a link to remote if user is authorized
  def link_to_remote_if_authorized(name, options = {}, html_options = nil)
    url = options[:url] || {}
    link_to_remote(name, options, html_options) if authorize_for(url[:controller] || params[:controller], url[:action])
  end

  # Displays a link to user's account page if active
  def link_to_user(user, options={})
    if user.is_a?(User)
      name = h(user.name(options[:format]))
      if user.active?
        link_to name, :controller => 'users', :action => 'show', :id => user
      else
        name
      end
    else
      h(user.to_s)
    end
  end
  
  def link_to_user_or_you(user, options={})
    if user == User.current
      "You"
    else
      link_to_user(user,options)
    end
  end
  
  # Displays a link to project
  def link_to_project(project, options={})
    if project.is_a?(Project)
      name = h(project.name)
      link_to name, :controller => 'projects', :action => 'show', :id => project
    else
      h(project.to_s)
    end
  end
  
  
  def link_to_user_from_id(user_id, options={})
    link_to_user(User.find(user_id))
  end

  # Displays a link to +issue+ with its subject.
  # Examples:
  # 
  #   link_to_issue(issue)                        # => Defect #6: This is the subject
  #   link_to_issue(issue, :truncate => 6)        # => Defect #6: This i...
  #   link_to_issue(issue, :subject => false)     # => Defect #6
  #   link_to_issue(issue, :project => true)      # => Foo - Defect #6
  #
  def link_to_issue(issue, options={})
    title = nil
    subject = nil
    css_class = nil
    if options[:subject] == false
      title = truncate(issue.subject, :length => 60)
    else
      subject = issue.subject
      if options[:truncate]
        subject = truncate(subject, :length => options[:truncate])
      end
    end
    if options[:css_class]
      css_class = options[:css_class]
    else
      css_class = issue.css_classes
    end
    css_class = css_class + " fancyframe" #loads fancybox
    s = link_to "#{issue.tracker} ##{issue.id}", {:controller => "issues", :action => "show", :id => issue}, 
                                                 :class => css_class,
                                                 :title => title
    s << ": #{h subject}" if subject
    s = "#{h issue.project} - " + s if options[:project]
    s
  end
  
  def link_to_issue_from_id(issue_id, options={})
    link_to_issue(Issue.find(issue_id), options)
  end

  # Generates a link to an attachment.
  # Options:
  # * :text - Link text (default to attachment filename)
  # * :download - Force download (default: false)
  def link_to_attachment(attachment, options={})
    text = options.delete(:text) || attachment.filename
    action = options.delete(:download) ? 'download' : 'show'

    link_to(h(text), {:controller => 'attachments', :action => action, :id => attachment, :filename => attachment.filename }, options)
  end
  
  def current_user
    User.current
  end
  
  def logged_in?
    User.current.logged?
  end

  def toggle_link(name, id, options={})
    onclick = "$('##{id}').toggle(); "
    onclick << "$('##{options[:second_toggle]}').toggle(); " if options[:second_toggle]
    onclick << (options[:focus] ? "$('##{options[:focus]}').focus(); " : "this.blur(); ")
    onclick << "return false;"
    link_to(name, "#", options.merge({:onclick => onclick}))
  end

  def image_to_function(name, function, html_options = {})
    html_options.symbolize_keys!
    tag(:input, html_options.merge({
        :type => "image", :src => image_path(name),
        :onclick => (html_options[:onclick] ? "#{html_options[:onclick]}; " : "") + "#{function};"
        }))
  end

  def prompt_to_remote(name, text, param, url, html_options = {})
    html_options[:onclick] = "promptToRemote('#{text}', '#{param}', '#{url_for(url)}'); return false;"
    link_to name, {}, html_options
  end
  
  def format_activity_title(text)
    h(truncate_single_line(text, :length => 100))
  end
  
  def format_activity_day(date)
    date == Date.today ? l(:label_today).titleize : format_date(date)
  end
  
  def format_activity_description(text)
    make_expandable h(text.to_s.gsub(%r{[\r\n]*<(pre|code)>.*$}m, '...')).gsub(/[\r\n]+/, "<br />"), 300
  end
  
  def make_expandable(newhtml,length=400)
    return newhtml if newhtml.length < length
    id = rand(100000)
    string = newhtml
    h = truncate(string,length,"")
    h << "<a href='' onclick='$(\"##{id.to_s}\").replaceWith($(\"##{id.to_s}\").html());$(this).remove();return false;'> ...<strong>read more</strong></a>"
    h << "<div class='hidden' id=#{id.to_s}>"
    h << string[length..string.length]
    h << "</div>"
  end

  def due_date_distance_in_words(date)
    if date
      l((date < Date.today ? :label_roadmap_overdue : :label_roadmap_due_in), distance_of_date_in_words(Date.today, date))
    end
  end

  def render_page_hierarchy(pages, node=nil)
    content = ''
    if pages[node]
      content << "<ul class=\"pages-hierarchy\">\n"
      pages[node].each do |page|
        content << "<li>"
        content << link_to(h(page.pretty_title), {:controller => 'wiki', :action => 'index', :id => page.project, :page => page.title},
                           :title => (page.respond_to?(:updated_at) ? l(:label_updated_time, distance_of_time_in_words(Time.now, page.updated_at)) : nil))
        content << "\n" + render_page_hierarchy(pages, page.id) if pages[page.id]
        content << "</li>\n"
      end
      content << "</ul>\n"
    end
    content
  end
  
  # Renders flash messages
  def render_flash_messages
    s = ''
    flash.each do |k,v|
      s << content_tag('div', v, :class => "flash #{k}")
    end
    s
  end
  
  # Renders tabs and their content
  def render_tabs(tabs)
    if tabs.any?
      render :partial => 'common/tabs', :locals => {:tabs => tabs}
    else
      content_tag 'p', l(:label_no_data), :class => "nodata"
    end
  end
  
  # Renders the project quick-jump box
  def render_project_jump_box
    # Retrieve them now to avoid a COUNT query
    projects = User.current.projects.all
    current_project_in_list = false #when true, it means that dropdown already contains current project
    if projects.any?
      s_options = ""
      s_options << project_tree_options_for_select(projects, :selected => @project) do |p|
        current_project_in_list = true if @project && p.id == @project.id
        # { :value => url_for(:controller => 'projects', :action => 'show', :id => p, :jump => current_menu_item) }
        { :value => url_for(:controller => 'projects', :action => 'show', :id => p) }
      end
      
      if current_project_in_list || !@project
        s = '<select id="jumpbox" onchange="if (this.value != \'\') { window.location = this.value; }">' +
              "<option value=''>#{ l(:label_jump_to_a_project) }</option>" +
              '<option value="" disabled="disabled">---</option>'
      else
        s = '<select id="jumpbox" onchange="if (this.value != \'\') { window.location = this.value; }">' +
              "<option value='#{url_for(:controller => 'projects', :action => 'show', :id => @project)}' selected=\"yes\"> &#187; #{ @project.name }</option>" +
              '<option value="" disabled="disabled">---</option>'
      end
      s << s_options
      s << '</select>'
      s << '<span id="widthcalc" style="display:none;"></span>'
      # s << current_project_in_list.to_s
    elsif @project
      s = ' &#187; ' + @project.name
    else
      s = '<span id="logo_app"><a href="/" title="BetterMeans">BetterMeans</a></span>'
      
      # s = h(Setting::APP_TITLE)
    end
  end
  
  def project_tree_options_for_select(projects, options = {})
    s = ''
    project_tree(projects) do |project, level|
      name_prefix = (level > 0 ? ('&nbsp;' * 2 * level + '&#187; ') : '')
      tag_options = {:value => project.id, :selected => ((project == options[:selected]) ? 'selected' : nil)}
      tag_options.merge!(yield(project)) if block_given?
      s << content_tag('option', name_prefix + h(project), tag_options)
    end
    s
  end
  
  # Yields the given block for each project with its level in the tree
  def project_tree(projects, &block)
    ancestors = []
    projects.sort_by(&:lft).each do |project|
      while (ancestors.any? && !project.is_descendant_of?(ancestors.last)) 
        ancestors.pop
      end
      yield project, ancestors.size
      ancestors << project
    end
  end
  
  def show_detail(detail, no_html=false)
    case detail.property
    when 'attr'
      label = l(("field_" + detail.prop_key.to_s.gsub(/\_id$/, "")).to_sym)   
      case detail.prop_key
      when 'due_date', 'start_date'
        value = format_date(detail.value.to_date) if detail.value
        old_value = format_date(detail.old_value.to_date) if detail.old_value
      when 'project_id'
        p = Project.find_by_id(detail.value) and value = p.name if detail.value
        p = Project.find_by_id(detail.old_value) and old_value = p.name if detail.old_value
      when 'status_id'
        s = IssueStatus.find_by_id(detail.value) and value = s.name if detail.value
        s = IssueStatus.find_by_id(detail.old_value) and old_value = s.name if detail.old_value
      when 'tracker_id'
        t = Tracker.find_by_id(detail.value) and value = t.name if detail.value
        t = Tracker.find_by_id(detail.old_value) and old_value = t.name if detail.old_value
      when 'assigned_to_id'
        u = User.find_by_id(detail.value) and value = u.name if detail.value
        u = User.find_by_id(detail.old_value) and old_value = u.name if detail.old_value
      when 'priority_id'
        e = IssuePriority.find_by_id(detail.value) and value = e.name if detail.value
        e = IssuePriority.find_by_id(detail.old_value) and old_value = e.name if detail.old_value
      when 'estimated_hours'
        value = "%0.02f" % detail.value.to_f unless detail.value.blank?
        old_value = "%0.02f" % detail.old_value.to_f unless detail.old_value.blank?
      end
    when 'attachment'
      label = l(:label_attachment)
    end

    label ||= detail.prop_key
    value ||= detail.value
    old_value ||= detail.old_value
    
    unless no_html
      label = content_tag('strong', label)
      old_value = content_tag("i", h(old_value)) if detail.old_value
      old_value = content_tag("strike", old_value) if detail.old_value and (!detail.value or detail.value.empty?)
      if detail.property == 'attachment' && !value.blank? && a = Attachment.find_by_id(detail.prop_key)
        # Link to the attachment if it has not been removed
        value = link_to_attachment(a)
      else
        value = content_tag("i", h(value)) if value
      end
    end
    
    if !detail.value.blank?
      case detail.property
      when 'attr', 'cf'
        if !detail.old_value.blank?
          l(:text_journal_changed, :label => label, :old => old_value, :new => value)
        else
          l(:text_journal_set_to, :label => label, :value => value)
        end
      when 'attachment'
        l(:text_journal_added, :label => label, :value => value)
      end
    else
      l(:text_journal_deleted, :label => label, :old => old_value)
    end
  end
  
  def format_time_ago(updated_at)
    "#{distance_of_time_in_words(Time.now,local_time(updated_at))} ago"
  end
  
  
  def project_nested_ul(projects, &block)
    s = ''
    if projects.any?
      ancestors = []
      projects.sort_by(&:lft).each do |project|
        if (ancestors.empty? || project.is_descendant_of?(ancestors.last))
          s << "<ul>\n"
        else
          ancestors.pop
          s << "</li>"
          while (ancestors.any? && !project.is_descendant_of?(ancestors.last)) 
            ancestors.pop
            s << "</ul></li>\n"
          end
        end
        s << "<li>"
        s << yield(project).to_s
        ancestors << project
      end
      s << ("</li></ul>\n" * ancestors.size)
    end
    s
  end
  
  def users_check_box_tags(name, users)
    s = ''
    users.sort.each do |user|
      s << "<label>#{ check_box_tag name, user.id, false } #{h user}</label>\n"
    end
    s 
  end

  # Truncates and returns the string as a single line
  def truncate_single_line(string, *args)
    truncate(string.to_s, *args).gsub(%r{[\r\n]+}m, ' ')
  end

  def html_hours(text)
    text.gsub(%r{(\d+)\.(\d+)}, '<span class="hours hours-int">\1</span><span class="hours hours-dec">.\2</span>')
  end

  def authoring(created, author, options={})
    l(options[:label] || :label_added_time_by, :author => link_to_user(author), :age => time_tag(created))
  end

  
  def time_tag(time)
    text = distance_of_time_in_words(Time.now, time)
    if @project
      link_to(text, {:controller => 'projects', :action => 'activity', :id => @project, :from => time.to_date}, :title => format_time(time))
    else
      content_tag('acronym', text, :title => format_time(time))
    end
  end

  def since_tag(time)
    text = distance_of_time_in_words(Time.now, time).gsub(/about/,"")
    content_tag('acronym', text, :title => format_time(time))
  end

  def syntax_highlight(name, content)
    type = CodeRay::FileType[name]
    type ? CodeRay.scan(content, type).html : h(content)
  end

  def to_path_param(path)
    path.to_s.split(%r{[/\\]}).select {|p| !p.blank?}
  end

  def pagination_links_full(paginator, count=nil, options={})
    page_param = options.delete(:page_param) || :page
    url_param = params.dup
    # don't reuse query params if filters are present
    url_param.merge!(:fields => nil, :values => nil, :operators => nil) if url_param.delete(:set_filter)

    html = ''
    if paginator.current.previous
      html << link_to_remote_content_update('&#171; ' + l(:label_previous), url_param.merge(page_param => paginator.current.previous)) + ' '
    end

    html << (pagination_links_each(paginator, options) do |n|
      link_to_remote_content_update(n.to_s, url_param.merge(page_param => n))
    end || '')
    
    if paginator.current.next
      html << ' ' + link_to_remote_content_update((l(:label_next) + ' &#187;'), url_param.merge(page_param => paginator.current.next))
    end

    unless count.nil?
      html << [
        " (#{paginator.current.first_item}-#{paginator.current.last_item}/#{count})",
        per_page_links(paginator.items_per_page)
      ].compact.join(' | ')
    end

    html
  end
  
  def per_page_links(selected=nil)
    url_param = params.dup
    url_param.clear if url_param.has_key?(:set_filter)

    links = Setting.per_page_options_array.collect do |n|
      n == selected ? n : link_to_remote(n, {:update => "content",
                                             :url => params.dup.merge(:per_page => n),
                                             :method => :get},
                                            {:href => url_for(url_param.merge(:per_page => n))})
    end
    links.size > 1 ? l(:label_display_per_page, links.join(', ')) : nil
  end
  
  def reorder_links(name, url)
    link_to(image_tag('2uparrow.png',   :alt => l(:label_sort_highest)), url.merge({"#{name}[move_to]" => 'highest'}), :method => :post, :title => l(:label_sort_highest)) +
    link_to(image_tag('1uparrow.png',   :alt => l(:label_sort_higher)),  url.merge({"#{name}[move_to]" => 'higher'}),  :method => :post, :title => l(:label_sort_higher)) +
    link_to(image_tag('1downarrow.png', :alt => l(:label_sort_lower)),   url.merge({"#{name}[move_to]" => 'lower'}),   :method => :post, :title => l(:label_sort_lower)) +
    link_to(image_tag('2downarrow.png', :alt => l(:label_sort_lowest)),  url.merge({"#{name}[move_to]" => 'lowest'}),  :method => :post, :title => l(:label_sort_lowest))
  end

  def breadcrumb(*args)
    elements = args.flatten
    elements.any? ? content_tag('p', args.join(' &#187; ') + ' &#187; ', :class => 'breadcrumb') : nil
  end
  
  def other_formats_links(&block)
    concat('<p class="other-formats">' + l(:label_export_to))
    yield Redmine::Views::OtherFormatsBuilder.new(self)
    concat('</p>')
  end
  
  def page_header_title
    if @project.nil? 
      # h(Setting.app_title)
    elsif @project.new_record? #TODO: would be nice to have the project's parent name here if it's a new record
      unless @parent.nil?
        b = []
        ancestors = (@parent.root? ? [] : @parent.ancestors.visible)
        if ancestors.any?
          root = ancestors.shift
          b << link_to(h(root), {:controller => 'projects', :action => 'show', :id => root}, :class => 'root')
          if ancestors.size > 2
            b << '&#8230;'
            ancestors = ancestors[-2, 2]
          end
          b += ancestors.collect {|p| link_to(h(p), {:controller => 'projects', :action => 'show', :id => p}, :class => 'ancestor') }
        end
        b << link_to(h(@parent), {:controller => 'projects', :action => 'show', :id => @parent}, :class => 'ancestor')
        b << "New project workstream"
        b = b.join(' &#187; ')
        b
      else
        "New project workstream"
      end
    else
      b = []
      # b << link_to(h(@project.enterprise.name), {:controller => 'enterprises', :action => 'show', :id => @project.enterprise.id, :jump => current_menu_item}, :class => 'root')
    
      ancestors = (@project.root? ? [] : @project.ancestors.visible)
      if ancestors.any?
        root = ancestors.shift
        # b << link_to(h(root), {:controller => 'projects', :action => 'show', :id => root, :jump => current_menu_item}, :class => 'root')
        b << link_to(h(root), {:controller => 'projects', :action => 'show', :id => root}, :class => 'root')
        if ancestors.size > 2
          b << '&#8230;'
          ancestors = ancestors[-2, 2]
        end
        # b += ancestors.collect {|p| link_to(h(p), {:controller => 'projects', :action => 'show', :id => p, :jump => current_menu_item}, :class => 'ancestor') }
        b += ancestors.collect {|p| link_to(h(p), {:controller => 'projects', :action => 'show', :id => p}, :class => 'ancestor') }
      end
      # b << content_tag('span', h(@project), :id => "last_header")
      b = b.join(' &#187; ')
      
      # b << "&nbsp;&nbsp;" << link_to("jump", nil, :class => 'root', :onclick => "jump_to_workstream();return false();", :id => "last_header_button")
    end
  end

  def html_title(*args)
    if args.empty?
      title = []
      title << @project.name if @project
      title += @html_title if @html_title
      title << Setting.app_title
      title.select {|t| !t.blank? }.join(' - ')
    else
      @html_title ||= []
      @html_title += args
    end
  end

  def accesskey(s)
    Redmine::AccessKeys.key_for s
  end
  

  # Formats text according to system settings.
  # 2 ways to call this method:
  # * with a String: textilizable(text, options)
  # * with an object and one of its attribute: textilizable(issue, :description, options)
  def textilizable(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    case args.size
    when 1
      obj = options[:object]
      text = args.shift
    when 2
      obj = args.shift
      text = obj.send(args.shift).to_s
    else
      raise ArgumentError, 'invalid arguments to textilizable'
    end
    return '' if text.blank?

    only_path = options.delete(:only_path) == false ? false : true

    # when using an image link, try to use an attachment, if possible
    attachments = options[:attachments] || (obj && obj.respond_to?(:attachments) ? obj.attachments : nil)

    if attachments
      attachments = attachments.sort_by(&:created_at).reverse
      text = text.gsub(/!((\<|\=|\>)?(\([^\)]+\))?(\[[^\]]+\])?(\{[^\}]+\})?)(\S+\.(bmp|gif|jpg|jpeg|png))!/i) do |m|
        style = $1
        filename = $6.downcase
        # search for the picture in attachments
        if found = attachments.detect { |att| att.filename.downcase == filename }
          image_url = url_for :only_path => only_path, :controller => 'attachments', :action => 'download', :id => found
          desc = found.description.to_s.gsub(/^([^\(\)]*).*$/, "\\1")
          alt = desc.blank? ? nil : "(#{desc})"
          "!#{style}#{image_url}#{alt}!"
        else
          m
        end
      end
    end

    text = Redmine::WikiFormatting.to_html(Setting.text_formatting, text) { |macro, args| exec_macro(macro, obj, args) }

    # different methods for formatting wiki links
    case options[:wiki_links]
    when :local
      # used for local links to html files
      format_wiki_link = Proc.new {|project, title, anchor| "#{title}.html" }
    when :anchor
      # used for single-file wiki export
      format_wiki_link = Proc.new {|project, title, anchor| "##{title}" }
    else
      format_wiki_link = Proc.new {|project, title, anchor| url_for(:only_path => only_path, :controller => 'wiki', :action => 'index', :id => project, :page => title, :anchor => anchor) }
    end

    project = options[:project] || @project || (obj && obj.respond_to?(:project) ? obj.project : nil)

    # Wiki links
    #
    # Examples:
    #   [[mypage]]
    #   [[mypage|mytext]]
    # wiki links can refer other project wikis, using project name or identifier:
    #   [[project:]] -> wiki starting page
    #   [[project:|mytext]]
    #   [[project:mypage]]
    #   [[project:mypage|mytext]]
    text = text.gsub(/(!)?(\[\[([^\]\n\|]+)(\|([^\]\n\|]+))?\]\])/) do |m|
      link_project = project
      esc, all, page, title = $1, $2, $3, $5
      if esc.nil?
        if page =~ /^([^\:]+)\:(.*)$/
          link_project = Project.find_by_name($1) || Project.find_by_identifier($1)
          page = $2
          title ||= $1 if page.blank?
        end

        if link_project && link_project.wiki
          # extract anchor
          anchor = nil
          if page =~ /^(.+?)\#(.+)$/
            page, anchor = $1, $2
          end
          # check if page exists
          wiki_page = link_project.wiki.find_page(page)
          link_to((title || page), format_wiki_link.call(link_project, Wiki.titleize(page), anchor),
                                   :class => ('wiki-page' + (wiki_page ? '' : ' new')))
        else
          # project or wiki doesn't exist
          all
        end
      else
        all
      end
    end

    # Redmine links
    #
    # Examples:
    #   Issues:
    #     #52 -> Link to issue #52
    #   Documents:
    #     document#17 -> Link to document with id 17
    #     document:Greetings -> Link to the document with title "Greetings"
    #     document:"Some document" -> Link to the document with title "Some document"
    #   Versions:
    #     version#3 -> Link to version with id 3
    #     version:1.0.0 -> Link to version named "1.0.0"
    #     version:"1.0 beta 2" -> Link to version named "1.0 beta 2"
    #   Attachments:
    #     attachment:file.zip -> Link to the attachment of the current object named file.zip
    #   Source files:
    #     source:some/file -> Link to the file located at /some/file in the project's repository
    #     source:some/file@52 -> Link to the file's revision 52
    #     source:some/file#L120 -> Link to line 120 of the file
    #     source:some/file@52#L120 -> Link to line 120 of the file's revision 52
    #     export:some/file -> Force the download of the file
    #  Forum messages:
    #     message#1218 -> Link to message with id 1218
    text = text.gsub(%r{([\s\(,\-\>]|^)(!)?(attachment|document|version|commit|source|export|message)?((#|r)(\d+)|(:)([^"\s<>][^\s<>]*?|"[^"]+?"))(?=(?=[[:punct:]]\W)|,|\s|<|$)}) do |m|
      leading, esc, prefix, sep, oid = $1, $2, $3, $5 || $7, $6 || $8
      link = nil
      if esc.nil?
        if sep == '#'
          oid = oid.to_i
          case prefix
          when nil
            if issue = Issue.visible.find_by_id(oid, :include => :status)
              link = link_to("##{oid}", {:only_path => only_path, :controller => 'issues', :action => 'show', :id => oid},
                                        :class => issue.css_classes,
                                        :title => "#{truncate(issue.subject, :length => 100)} (#{issue.status.name})")
            end
          when 'document'
            if document = Document.find_by_id(oid, :include => [:project], :conditions => Project.visible_by(User.current))
              link = link_to h(document.title), {:only_path => only_path, :controller => 'documents', :action => 'show', :id => document},
                                                :class => 'document'
            end
          when 'message'
            if message = Message.find_by_id(oid, :include => [:parent, {:board => :project}], :conditions => Project.visible_by(User.current))
              link = link_to h(truncate(message.subject, :length => 60)), {:only_path => only_path,
                                                                :controller => 'messages',
                                                                :action => 'show',
                                                                :board_id => message.board,
                                                                :id => message.root,
                                                                :anchor => (message.parent ? "message-#{message.id}" : nil)},
                                                 :class => 'message'
            end
          end
        elsif sep == ':'
          # removes the double quotes if any
          name = oid.gsub(%r{^"(.*)"$}, "\\1")
          case prefix
          when 'document'
            if project && document = project.documents.find_by_title(name)
              link = link_to h(document.title), {:only_path => only_path, :controller => 'documents', :action => 'show', :id => document},
                                                :class => 'document'
            end
          when 'attachment'
            if attachments && attachment = attachments.detect {|a| a.filename == name }
              link = link_to h(attachment.filename), {:only_path => only_path, :controller => 'attachments', :action => 'download', :id => attachment},
                                                     :class => 'attachment'
            end
          end
        end
      end
      leading + (link || "#{prefix}#{sep}#{oid}")
    end

    text
  end

  # Same as Rails' simple_format helper without using paragraphs
  def simple_format_without_paragraph(text)
    text.to_s.
      gsub(/\r\n?/, "\n").                    # \r\n and \r -> \n
      gsub(/\n\n+/, "<br /><br />").          # 2+ newline  -> 2 br
      gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')  # 1 newline   -> br
  end

  def lang_options_for_select(blank=true)
    (blank ? [["(auto)", ""]] : []) +
      valid_languages.collect{|lang| [ ll(lang.to_s, :general_lang_name), lang.to_s]}.sort{|x,y| x.last <=> y.last }
  end
  
  def month_hash
    [
      ["01 - January",1],
      ["02 - February",2],
      ["03 - March",3],
      ["04 - April",4],
      ["05 - May",5],
      ["06 - June",6],
      ["07 - July",7],
      ["08 - August",8],
      ["09 - September",9],
      ["10 - October",10],
      ["11 - November",11],
      ["12 - December",12]
    ]
  end
  
  def privacy(project)
    image_tag("icon_privacy.png", {:id => "privacy-#{project.id}",:class => "private-workstream"}) unless project.is_public
  end
  
  def volunteering(project)
    image_tag("icon_volunteer.png", {:id => "volunteering-#{project.id}",:class => "volunteer-workstream"}) if project.volunteer
  end
  
  def year_hash
    [0,1,2,3,4,5,6,7,8,9,10].collect{|n| [(Date.today.year + n).to_s, Date.today.year + n]}
  end
  
  def unit_for(project)
    if project.volunteer?
      return '♥'
    else
      return '$'
    end
  end
  
  
  
  def country_hash
    {
      "Afghanistan" => "AF",
      "Albania" => "AL",
      "Algeria" => "DZ",
      "American Samoa" => "AS",
      "Andorra" => "AD",
      "Angola" => "AO",
      "Anguilla" => "AI",
      "Antigua and Barbuda" => "AG",
      "Argentina" => "AR",
      "Armenia" => "AM",
      "Aruba" => "AW",
      "Australia" => "AU",
      "Austria" => "AT",
      "Aland Islands" => "AX",
      "Azerbaijan" => "AZ",
      "Bahamas" => "BS",
      "Bahrain" => "BH",
      "Bangladesh" => "BD",
      "Barbados" => "BB",
      "Belarus" => "BY",
      "Belgium" => "BE",
      "Belize" => "BZ",
      "Benin" => "BJ",
      "Bermuda" => "BM",
      "Bhutan" => "BT",
      "Bolivia" => "BO",
      "Bosnia and Herzegovina" => "BA",
      "Botswana" => "BW",
      "Bouvet Island" => "BV",
      "Brazil" => "BR",
      "Brunei Darussalam" => "BN",
      "British Indian Ocean Territory" => "IO",
      "Bulgaria" => "BG",
      "Burkina Faso" => "BF",
      "Burundi" => "BI",
      "Cambodia" => "KH",
      "Cameroon" => "CM",
      "Canada" => "CA",
      "Cape Verde" => "CV",
      "Cayman Islands" => "KY",
      "Central African Republic" => "CF",
      "Chad" => "TD",
      "Chile" => "CL",
      "China" => "CN",
      "Christmas Island" => "CX",
      "Cocos (Keeling) Islands" => "CC",
      "Colombia" => "CO",
      "Comoros" => "KM",
      "Congo" => "CG",
      "Congo, the Democratic Republic of the" => "CD",
      "Cook Islands" => "CK",
      "Costa Rica" => "CR",
      "Cote D'Ivoire" => "CI",
      "Croatia" => "HR",
      "Cuba" => "CU",
      "Cyprus" => "CY",
      "Czech Republic" => "CZ",
      "Denmark" => "DK",
      "Djibouti" => "DJ",
      "Dominica" => "DM",
      "Dominican Republic" => "DO",
      "Ecuador" => "EC",
      "Egypt" => "EG",
      "El Salvador" => "SV",
      "Equatorial Guinea" => "GQ",
      "Eritrea" => "ER",
      "Estonia" => "EE",
      "Ethiopia" => "ET",
      "Falkland Islands (Malvinas)" => "FK",
      "Faroe Islands" => "FO",
      "Fiji" => "FJ",
      "Finland" => "FI",
      "France" => "FR",
      "French Guiana" => "GF",
      "French Polynesia" => "PF",
      "French Southern Territories" => "TF",
      "Gabon" => "GA",
      "Gambia" => "GM",
      "Georgia" => "GE",
      "Germany" => "DE",
      "Ghana" => "GH",
      "Gibraltar" => "GI",
      "Greece" => "GR",
      "Greenland" => "GL",
      "Grenada" => "GD",
      "Guadeloupe" => "GP",
      "Guam" => "GU",
      "Guatemala" => "GT",
      "Guinea" => "GN",
      "Guinea-Bissau" => "GW",
      "Guyana" => "GY",
      "Guernsey" => "GG",
      "Haiti" => "HT",
      "Holy See (Vatican City State)" => "VA",
      "Honduras" => "HN",
      "Hong Kong" => "HK",
      "Heard Island And Mcdonald Islands" => "HM",
      "Hungary" => "HU",
      "Iceland" => "IS",
      "India" => "IN",
      "Indonesia" => "ID",
      "Iran, Islamic Republic of" => "IR",
      "Iraq" => "IQ",
      "Ireland" => "IE",
      "Isle Of Man" => "IM",
      "Israel" => "IL",
      "Italy" => "IT",
      "Jamaica" => "JM",
      "Japan" => "JP",
      "Jersey" => "JE",
      "Jordan" => "JO",
      "Kazakhstan" => "KZ",
      "Kenya" => "KE",
      "Kiribati" => "KI",
      "Korea, Democratic People's Republic of" => "KP",
      "Korea, Republic of" => "KR",
      "Kuwait" => "KW",
      "Kyrgyzstan" => "KG",
      "Lao People's Democratic Republic" => "LA",
      "Latvia" => "LV",
      "Lebanon" => "LB",
      "Lesotho" => "LS",
      "Liberia" => "LR",
      "Libyan Arab Jamahiriya" => "LY",
      "Liechtenstein" => "LI",
      "Lithuania" => "LT",
      "Luxembourg" => "LU",
      "Macao" => "MO",
      "Macedonia, the Former Yugoslav Republic of" => "MK",
      "Madagascar" => "MG",
      "Malawi" => "MW",
      "Malaysia" => "MY",
      "Maldives" => "MV",
      "Mali" => "ML",
      "Malta" => "MT",
      "Marshall Islands" => "MH",
      "Martinique" => "MQ",
      "Mauritania" => "MR",
      "Mauritius" => "MU",
      "Mayotte" => "YT",
      "Mexico" => "MX",
      "Micronesia, Federated States of" => "FM",
      "Moldova, Republic of" => "MD",
      "Monaco" => "MC",
      "Mongolia" => "MN",
      "Montenegro" => "ME",
      "Montserrat" => "MS",
      "Morocco" => "MA",
      "Mozambique" => "MZ",
      "Myanmar" => "MM",
      "Namibia" => "NA",
      "Nauru" => "NR",
      "Nepal" => "NP",
      "Netherlands" => "NL",
      "Netherlands Antilles" => "AN",
      "New Caledonia" => "NC",
      "New Zealand" => "NZ",
      "Nicaragua" => "NI",
      "Niger" => "NE",
      "Nigeria" => "NG",
      "Niue" => "NU",
      "Norfolk Island" => "NF",
      "Northern Mariana Islands" => "MP",
      "Norway" => "NO",
      "Oman" => "OM",
      "Pakistan" => "PK",
      "Palau" => "PW",
      "Palestinian Territory, Occupied" => "PS",
      "Panama" => "PA",
      "Papua New Guinea" => "PG",
      "Paraguay" => "PY",
      "Peru" => "PE",
      "Philippines" => "PH",
      "Pitcairn" => "PN",
      "Poland" => "PL",
      "Portugal" => "PT",
      "Puerto Rico" => "PR",
      "Qatar" => "QA",
      "Reunion" => "RE",
      "Romania" => "RO",
      "Russian Federation" => "RU",
      "Rwanda" => "RW",
      "Saint Barthélemy" => "BL",
      "Saint Helena" => "SH",
      "Saint Kitts and Nevis" => "KN",
      "Saint Lucia" => "LC",
      "Saint Martin (French part)" => "MF",
      "Saint Pierre and Miquelon" => "PM",
      "Saint Vincent and the Grenadines" => "VC",
      "Samoa" => "WS",
      "San Marino" => "SM",
      "Sao Tome and Principe" => "ST",
      "Saudi Arabia" => "SA",
      "Senegal" => "SN",
      "Serbia" => "RS",
      "Seychelles" => "SC",
      "Sierra Leone" => "SL",
      "Singapore" => "SG",
      "Slovakia" => "SK",
      "Slovenia" => "SI",
      "Solomon Islands" => "SB",
      "Somalia" => "SO",
      "South Africa" => "ZA",
      "South Georgia and the South Sandwich Islands" => "GS",
      "Spain" => "ES",
      "Sri Lanka" => "LK",
      "Sudan" => "SD",
      "Suriname" => "SR",
      "Svalbard and Jan Mayen" => "SJ",
      "Swaziland" => "SZ",
      "Sweden" => "SE",
      "Switzerland" => "CH",
      "Syrian Arab Republic" => "SY",
      "Taiwan, Province of China" => "TW",
      "Tajikistan" => "TJ",
      "Tanzania, United Republic of" => "TZ",
      "Thailand" => "TH",
      "Timor Leste" => "TL",
      "Togo" => "TG",
      "Tokelau" => "TK",
      "Tonga" => "TO",
      "Trinidad and Tobago" => "TT",
      "Tunisia" => "TN",
      "Turkey" => "TR",
      "Turkmenistan" => "TM",
      "Turks and Caicos Islands" => "TC",
      "Tuvalu" => "TV",
      "Uganda" => "UG",
      "Ukraine" => "UA",
      "United Arab Emirates" => "AE",
      "United Kingdom" => "GB",
      "United States" => "US",
      "United States Minor Outlying Islands" => "UM",
      "Uruguay" => "UY",
      "Uzbekistan" => "UZ",
      "Vanuatu" => "VU",
      "Venezuela" => "VE",
      "Viet Nam" => "VN",
      "Virgin Islands, British" => "VG",
      "Virgin Islands, U.S." => "VI",
      "Wallis and Futuna" => "WF",
      "Western Sahara" => "EH",
      "Yemen" => "YE",
      "Zambia" => "ZM",
      "Zimbabwe" => "ZW"
    }
  end

  def label_tag_for(name, option_tags = nil, options = {})
    label_text = l(("field_"+field.to_s.gsub(/\_id$/, "")).to_sym) + (options.delete(:required) ? @template.content_tag("span", " *", :class => "required"): "")
    content_tag("label", label_text)
  end

  def labelled_tabular_form_for(name, object, options, &proc)
    options[:html] ||= {}
    options[:html][:class] = 'tabular' unless options[:html].has_key?(:class)
    form_for(name, object, options.merge({ :builder => TabularFormBuilder, :lang => current_language}), &proc)
  end

  def back_url_hidden_field_tag
    back_url = params[:back_url] || request.env['HTTP_REFERER']
    back_url = CGI.unescape(back_url.to_s)
    hidden_field_tag('back_url', CGI.escape(back_url)) unless back_url.blank?
  end

  def check_all_links(form_name)
    link_to_function(l(:button_check_all), "checkAll('#{form_name}', true)") +
    " | " +
    link_to_function(l(:button_uncheck_all), "checkAll('#{form_name}', false)")
  end

  def progress_bar(pcts, options={})
    pcts = [pcts, pcts] unless pcts.is_a?(Array)
    pcts = pcts.collect(&:round)
    pcts[1] = pcts[1] - pcts[0]
    pcts << (100 - pcts[1] - pcts[0])
    width = options[:width] || '100px;'
    legend = options[:legend] || ''
    content_tag('table',
      content_tag('tr',
        (pcts[0] > 0 ? content_tag('td', '', :style => "width: #{pcts[0]}%;", :class => 'closed') : '') +
        (pcts[1] > 0 ? content_tag('td', '', :style => "width: #{pcts[1]}%;", :class => 'done') : '') +
        (pcts[2] > 0 ? content_tag('td', '', :style => "width: #{pcts[2]}%;", :class => 'todo') : '')
      ), :class => 'progress', :style => "width: #{width};") +
      content_tag('p', legend, :class => 'pourcent')
  end

  def context_menu_link(name, url, options={})
    options[:class] ||= ''
    if options.delete(:selected)
      options[:class] << ' icon-checked disabled'
      options[:disabled] = true
    end
    if options.delete(:disabled)
      options.delete(:method)
      options.delete(:confirm)
      options.delete(:onclick)
      options[:class] << ' disabled'
      url = '#'
    end
    link_to name, url, options
  end
  
  def help_link(name, options={})
    options[:show_name] ||= false #When true, we show the text of the help key next to the link
    link_to(options[:show_name] ? l('help_' + name.to_s) : '', {:controller => 'help', :action => 'show', :key => name}, {:id =>'help_button_' + name.to_s, :class => 'lbOn icon icon-help'})
  end
  
  def help_bubble(name, options={})
    # html = content_tag(:div, l(name), :class => 'tip hidden', :id=>"tip_#{name}")
    # html << link_to(image_tag("question_mark.gif", :class=> "help_question_mark", :id=>"help_image_#{name}"), {:href => '#'}, {:onclick => "$('#help_image_#{name}').bubbletip('#tip_#{name}', {deltaDirection: 'right', bindShow: 'click'}); return false;"})

    html = link_to(image_tag("question_mark.gif", :class=> "help_question_mark", :id=>"help_image_#{name}"), {:href => '#'}, {:onclick => "$('#help_image_#{name}').bubbletip('#tip_#{name}', {deltaDirection: 'right', bindShow: 'click'}); return false;"})
    html << content_tag(:span, l(name), :class => 'tip hidden', :id=>"tip_#{name}")
    
    # <img id="help_image_panel_' + name + '" src="/images/question_mark.gif" class="help_question_mark">
    # <div id="help_panel_canceled" style="display:none;">
    #   <div class="tip" style="width:300px">
    #     <strong>Canceled Ideas</strong><br>
    #       If a request hasn't been prioritized by anyone and has been sitting in the queue for more than a month, anyone team member can cancel it.<br><br>
    #       Once a request has been canceled, anyone can re-open it, effectively pushing it back as a new item for reconsideration.
    #   </div>
    # </div>
  end

  def calendar_for(field_id)
    include_calendar_headers_tags
    image_tag("calendar.png", {:id => "#{field_id}_trigger",:class => "calendar-trigger"}) +
    javascript_tag("Calendar.setup({inputField : '#{field_id}', ifFormat : '%Y-%m-%d', button : '#{field_id}_trigger' });")
  end

  def include_calendar_headers_tags
    unless @calendar_headers_tags_included
      @calendar_headers_tags_included = true
      content_for :header_tags do
        start_of_week = case Setting.start_of_week.to_i
        when 1
          'Calendar._FD = 1;' # Monday
        when 7
          'Calendar._FD = 0;' # Sunday
        else
          '' # use language
        end
        
        javascript_include_tag('calendar/calendar') +
        javascript_include_tag("calendar/lang/calendar-#{current_language.to_s.downcase}.js") +
        javascript_tag(start_of_week) +  
        javascript_include_tag('calendar/calendar-setup') +
        stylesheet_link_tag('calendar')
      end
    end
  end

  def content_for(name, content = nil, &block)
    @has_content ||= {}
    @has_content[name] = true
    super(name, content, &block)
  end

  def has_content?(name)
    (@has_content && @has_content[name]) || false
  end

  # Returns the avatar image tag for the given +user+ if avatars are enabled
  # +user+ can be a User or a string that will be scanned for an email address (eg. 'joe <joe@foo.bar>')
  def avatar(user, options = { })
    # if Setting.gravatar_enabled?
      options.merge!({:ssl => Setting.protocol == 'https', :default => Setting.gravatar_default})
      email = nil
      if user.respond_to?(:mail)
        email = user.mail
      elsif user.to_s =~ %r{<(.+?)>}
        email = $1
      end
      return gravatar(email.to_s.downcase, options) unless email.blank? rescue nil
    # end
  end
  
  def render_journal_details(journal)
    html = ""
    html = "<ul>" if journal.details.count > 0
    for detail in journal.details
      html << "<li>#{show_detail(detail)}</li>"
    end
    html << "</ul>"  if journal.details.count > 0
    
    content = ""
    content << textilizable(journal, :notes)
    content = make_expandable content, 250
    css_classes = "wiki"
    css_classes << " gravatar-margin" if Setting.gravatar_enabled?
    
    html << content #_tag('div', content, :id => "journal-#{journal.id}-notes", :class => css_classes)
    
  end
  
  def link_to_activity(as)
    link_to name_for_activity_stream(as), url_for_activity_stream(as), {:class => class_for_activity_stream(as)}
  end
  
  def name_for_activity_stream(as)
    (as.tracker_name) ? "a #{as.tracker_name.downcase}" : l("label_#{as.object_type.downcase}")
  end
  
  def class_for_activity_stream(as)
     (as.object_type.match(/^Issue/)) ? "fancyframe" : "noframe"
  end
  
  def url_for_activity_stream(as)  
    case as.object_type.downcase
    when 'message'
      return {:controller => 'messages', :action => 'show', :board_id => 'guess', :id => as.object_id}
    when 'wikipage'
      return {:controller => 'wiki', :action => 'index', :id => as.project_id, :page => as.object_name}
    when 'memberrole'
      return {:controller => 'projects', :action => 'team', :id => as.project_id}
    when 'motion'
      return {:controller => 'motions', :action => 'show', :project_id => as.project_id, :id => as.object_id}
    else
      return {:controller => as.object_type.downcase.pluralize, :action => 'show', :id => as.object_id}
    end
  end
  
  def title_for_activity_stream(as)
    case as.object_type.downcase
    when 'memberrole'
      as.object ? "#{as.object.user.name} is now #{as.object.name}" : "New member role"
    else
      format_activity_title(as.object_name)
    end
  end
  
  def action_times(count)  
    count = count.to_i
    return nil if count < 2
    return " twice" if count == 2
    return " #{count.to_s} times" if count > 2 
  end
  
  
  
  def avatar_from_id(user_id, options = { })
    avatar(User.find(user_id), options)
  end
  
  def button(text, cssclass)
  	return "<div class='action_button_no_float action_button_#{cssclass}' onclick=\"$('.action_button_no_float').hide();\" ><span>#{text}</span></div>"
  end
  
  def tally_table(motion)
    content = "<table id='motion_votes_totals' class='gt-table'>"
    content << "<thead><tr>"
    content << "<th>&nbsp;</th><th>#{l :label_binding}</th><th>#{l :label_non_binding}</th>"
    content << "</tr></thead>"
    content << "<tr>"
    content << "<th>#{l(:label_agree)}</th><td>#{motion.agree}</td><td>#{motion.agree_nonbind}</td>"
    content << "</tr>"
    content << "<tr>"
    content << "<th>#{l(:label_disagree)}</th><td>#{motion.disagree}</td><td>#{motion.disagree_nonbind}</td>"
    content << "</tr>"
    content << "<tr>"
    content << "<th>#{l(:label_total)}</th><td>#{motion.agree_total}</td><td>#{motion.agree_total_nonbind}</td>"
    content << "</tr>"
    content << "</table>"
  end
  
  def tame_bias(number)
    if number.nil? 
      return ""
    else
      number = number.round
      number > 0 ? "Self:&nbsp&nbsp; +#{number}" : number == 0 ? "Self:&nbsp&nbsp; No Bias" : "Self:&nbsp&nbsp; #{number}"
    end
  end

  def tame_scale(number)
    if number.nil?
      ""
    else
      number = number.round
      number == 0 ? "Other: No Bias" : "Other: &plusmn;#{number}"
    end
  end
  
  #depending on credit's status, provides link to activate/deactivate a credit. Project id is the current project being viewed
  def credit_activation_link(credit, project_id, include_sub_workstreams)
    return '' if !credit.settled_on.nil?
    
    return link_to_remote(l(:button_deactivate),
                            { :url => {:controller => 'credits', :action => 'disable', :id => credit.id, :project_id => project_id, :with_subprojects => include_sub_workstreams} },
                            :class => 'icon icon-deactivate') if credit.enabled
                            
    return link_to_remote(l(:button_activate),
                            { :url => {:controller => 'credits', :action => 'enable', :id => credit.id, :project_id => project_id, :with_subprojects => include_sub_workstreams} },
                            :class => 'icon icon-activate') if !credit.enabled
  end
  
  def login_protocol()
    if ENV['RAILS_ENV'] == "development"
      'http'
    else
      'https'
    end
  end
  
  

  # def bar_report_tag(data, options = {}, raphael_options = {})
  #         @__raphael_report_tag_count ||= -1
  #         @__raphael_report_tag_count += 1
  #         default_dom_id = "#{data.model_name.downcase}_#{data.report_name}#{@__raphael_report_tag_count > 0 ? @__raphael_report_tag_count : ''}"
  #         options.reverse_merge!(Saulabs::Reportable::Config.raphael_options.slice(:width, :height, :format))
  #         options.reverse_merge!(:dom_id => default_dom_id)
  #         raphael_options.reverse_merge!(Saulabs::Reportable::Config.raphael_options.except(:width, :height, :format))
  #         %Q{<div id="#{options[:dom_id]}" style="width:#{options[:width]}px;height:#{options[:height]}px;"></div>
  # <script type="text\/javascript" charset="utf-8">
  # var graph = Raphael('#{options[:dom_id]}');
  # graph.g.barchart(
  # -10, 4, #{options[:width]}, #{options[:height]},
  # #{(0..data.size).to_a.to_json},
  # #{data.map { |d| d[1].send(options[:format]) }.to_json},
  #             #{raphael_options.to_json}
  #           ).hover(function() {
  #             this.disc = graph.g.disc(this.x, this.y, 3).attr({fill: "#{options[:hover_fill_color]}", stroke: '#{options[:hover_line_color]}' }).insertBefore(this);
  #             this.flag = graph.g.flag(this.x, this.y, this.value || "0", 0).insertBefore(this);
  #             if (this.x + this.flag.getBBox().width > this.paper.width) {
  #               this.flag.rotate(-180);
  #               this.flag.translate(-this.flag.getBBox().width, 0);
  #               this.flag.items[1].rotate(180);
  #               this.flag.items[1].translate(-5, 0);
  #             }
  #           }, function() {
  #             this.disc.remove();
  #             this.flag.remove();
  #           });
  #         </script>}
  # end
  
  private

  def wiki_helper
    helper = Redmine::WikiFormatting.helper_for(Setting.text_formatting)
    extend helper
    return self
  end
  
  def link_to_remote_content_update(text, url_params)
    link_to_remote(text,
      {:url => url_params, :method => :get, :update => 'content', :complete => 'window.scrollTo(0,0)'},
      {:href => url_for(:params => url_params)}
    )
  end
  
  
  
end
