# coding: utf-8
module ActiveScaffold
  module Helpers
    # Helpers that assist with the rendering of a List Column
    module ListColumnHelpers
      def get_column_value(record, column)
        # check for an override helper
        value = if column_override? column
          # we only pass the record as the argument. we previously also passed the formatted_value,
          # but mike perham pointed out that prohibited the usage of overrides to improve on the
          # performance of our default formatting. see issue #138.
          send(column_override(column), record)
        # second, check if the dev has specified a valid list_ui for this column
        elsif column.list_ui and override_column_ui?(column.list_ui)
          send(override_column_ui(column.list_ui), column, record)

        elsif inplace_edit?(record, column)
          active_scaffold_inplace_edit(record, column)
        elsif column.column and override_column_ui?(column.column.type)
          send(override_column_ui(column.column.type), column, record)
        else
          format_column_value(record, column)
        end

        value = '&nbsp;' if value.nil? or (value.respond_to?(:empty?) and value.empty?) # fix for IE 6
        return value
      end
      
      # TODO: move empty_field_text and &nbsp; logic in here?
      # TODO: move active_scaffold_inplace_edit in here?
      # TODO: we need to distinguish between the automatic links *we* create and the ones that the dev specified. some logic may not apply if the dev specified the link.
      def render_list_column(text, column, record)
        if column.link
          link = column.link
          associated = record.send(column.association.name) if column.association
          url_options = params_for(:action => nil, :id => record.id, :link => text)
          url_options[:parent_controller] = params[:controller] if link.controller and link.controller.to_s != params[:controller]
          url_options[:id] = associated.id if associated and link.controller and link.controller.to_s != params[:controller]

          # setup automatic link
          if column.autolink? # link to nested scaffold or inline form
            link = action_link_to_inline_form(column, associated) if link.crud_type.nil? # automatic link to inline form (singular association)
            return text if link.crud_type.nil?
            if link.crud_type == :create
              url_options[:link] = as_(:create_new)
              url_options[:parent_id] = record.id
              url_options[:parent_column] = column.association.reverse
              url_options[:parent_model] = record.class.name # needed for polymorphic associations
              url_options.delete :id
            end
          end

          # check authorization
          if column.association
            associated_for_authorized = if associated.nil? || (associated.respond_to?(:empty?) && associated.empty?)
              column.association.klass
            elsif column.plural_association?
              associated.first
            else
              associated
            end
            authorized = associated_for_authorized.authorized_for?(:action => link.crud_type)
            authorized = authorized and record.authorized_for?(:action => :update, :column => column.name) if link.crud_type == :create
          else
            authorized = record.authorized_for?(:action => link.crud_type)
          end
          return "<a class='disabled'>#{text}</a>" unless authorized

          render_action_link(link, url_options)
        else
          text
        end
      end

      # setup the action link to inline form
      def action_link_to_inline_form(column, associated)
        link = column.link.clone
        if column_empty?(associated) # if association is empty, we only can link to create form
          if column.actions_for_association_links.include?(:new)
            link.action = 'new'
            link.crud_type = :create
          end
        elsif column.actions_for_association_links.include?(:edit)
          link.action = 'edit'
          link.crud_type = :update
        elsif column.actions_for_association_links.include?(:show)
          link.action = 'show'
          link.crud_type = :read
        end
        link
      end

      # There are two basic ways to clean a column's value: h() and sanitize(). The latter is useful
      # when the column contains *valid* html data, and you want to just disable any scripting. People
      # can always use field overrides to clean data one way or the other, but having this override
      # lets people decide which way it should happen by default.
      #
      # Why is it not a configuration option? Because it seems like a somewhat rare request. But it
      # could eventually be an option in config.list (and config.show, I guess).
      def clean_column_value(v)
        h(v)
      end

      ##
      ## Overrides
      ##
      def active_scaffold_column_text(column, record)
        truncate(clean_column_value(record.send(column.name)), :length => column.options[:truncate] || 50)
      end

      def active_scaffold_column_checkbox(column, record)
        column_value = record.send(column.name)
        checked = column_value.class.to_s.include?('Class') ? column_value : column_value == 1
        if column.inplace_edit and record.authorized_for?(:action => :update, :column => column.name)
          id_options = {:id => record.id.to_s, :action => 'update_column', :name => column.name.to_s}
          tag_options = {:tag => "span", :id => element_cell_id(id_options), :class => "in_place_editor_field"}
          script = remote_function(:method => 'POST', :url => {:controller => params_for[:controller], :action => "update_column", :column => column.name, :id => record.id.to_s, :value => !column_value, :eid => params[:eid]})
          content_tag(:span, check_box_tag(tag_options[:id], 1, checked, {:onclick => script}) , tag_options)
        else
          check_box_tag(nil, 1, checked, :disabled => true)
        end
      end

      def column_override(column)
        "#{column.name.to_s.gsub('?', '')}_column" # parse out any question marks (see issue 227)
      end

      def column_override?(column)
        respond_to?(column_override(column))
      end

      def override_column_ui?(list_ui)
        respond_to?(override_column_ui(list_ui))
      end

      # the naming convention for overriding column types with helpers
      def override_column_ui(list_ui)
        "active_scaffold_column_#{list_ui}"
      end

      ##
      ## Formatting
      ##

      def format_column_value(record, column)
        value = record.send(column.name)
        if value && column.association # cache association size before calling column_empty?
          associated_size = value.size if column.plural_association? and column.associated_number? # get count before cache association
          cache_association(value, column)
        end
        if column.association.nil? or column_empty?(value)
          format_value(value, column.options)
        else
          format_association_value(value, column, associated_size)
        end
      end
      
      def format_association_value(value, column, size)
        case column.association.macro
          when :has_one, :belongs_to
            format_value(value.to_label)
          when :has_many, :has_and_belongs_to_many
            if column.associated_limit.nil?
              firsts = value.collect { |v| v.to_label }
            else
              firsts = value.first(column.associated_limit)
              firsts.collect! { |v| v.to_label }
              firsts[column.associated_limit] = '…' if value.size > column.associated_limit
            end
            if column.associated_limit == 0
              size if column.associated_number?
            else
              joined_associated = format_value(firsts.join(', '))
              joined_associated << " (#{size})" if column.associated_number? and column.associated_limit and value.size > column.associated_limit
              joined_associated
            end
        end
      end
      
      def format_value(column_value, options = {})
        value = if column_empty?(column_value)
          active_scaffold_config.list.empty_field_text
        elsif column_value.is_a?(Time) || column_value.is_a?(Date)
          l(column_value, :format => options[:format] || :default)
        elsif [FalseClass, TrueClass].include?(column_value.class)
          as_(column_value.to_s.to_sym)
        else
          column_value.to_s
        end
        clean_column_value(value)
      end
      
      def cache_association(value, column)
        # we are not using eager loading, cache firsts records in order not to query the database in a future
        unless value.loaded?
          # load at least one record, is needed for column_empty? and checking permissions
          if column.associated_limit.nil?
            Rails.logger.warn "ActiveScaffold: Enable eager loading for #{column.name} association to reduce SQL queries"
          else
            value.target = value.find(:all, :limit => column.associated_limit + 1, :select => column.select_columns)
          end
        end
      end

      # ==========
      # = Inline Edit =
      # ==========
      
      def inplace_edit?(record, column)
        column.inplace_edit and record.authorized_for?(:action => :update, :column => column.name)
      end
      
      def inplace_edit_cloning?(column)
         column.inplace_edit != :ajax and (override_form_field?(column) or column.form_ui or (column.column and override_input?(column.column.type)))
      end
      
      def format_inplace_edit_column(record,column)
        value = record.send(column.name)
        if column.list_ui == :checkbox
          active_scaffold_column_checkbox(column, record)
        else
          format_column_value(record, column)
        end
      end
      
      def active_scaffold_inplace_edit(record, column)
        formatted_column = format_inplace_edit_column(record,column)
        id_options = {:id => record.id.to_s, :action => 'update_column', :name => column.name.to_s}
        tag_options = {:tag => "span", :id => element_cell_id(id_options), :class => "in_place_editor_field"}
        in_place_editor_options = {
          :url => {:controller => params_for[:controller], :action => "update_column", :column => column.name, :id => record.id.to_s},
          :with => params[:eid] ? "Form.serialize(form) + '&eid=#{params[:eid]}'" : nil,
          :click_to_edit_text => as_(:click_to_edit),
          :cancel_text => as_(:cancel),
          :loading_text => as_(:loading),
          :save_text => as_(:update),
          :saving_text => as_(:saving),
          :options => "{method: 'post'}",
          :script => true
        }

        if inplace_edit_cloning?(column)
          in_place_editor_options.merge!(
            :inplace_pattern_selector => "##{active_scaffold_column_header_id(column)} .#{inplace_edit_control_css_class}",
            :node_id_suffix => record.id.to_s,
            :form_customization => 'element.clonePatternField();'
          )
        elsif column.inplace_edit == :ajax
          url = url_for(:action => 'render_field', :id => record.id, :column => column.name, :update_column => column.name, :in_place_editing => true, :escape => false)
          in_place_editor_options[:form_customization] = "element.setFieldFromAjax('#{escape_javascript(url)}');"
        elsif column.column.try(:type) == :text
          in_place_editor_options[:rows] = column.options[:rows] || 5
        end

        in_place_editor_options.merge!(column.options)
        content_tag(:span, formatted_column, tag_options) + active_scaffold_in_place_editor(tag_options[:id], in_place_editor_options)
      end
      
      def inplace_edit_control(column)
        if inplace_edit?(active_scaffold_config.model, column) and inplace_edit_cloning?(column)
          @record = active_scaffold_config.model.new
          column = column.clone
          column.options = column.options.clone
          column.options.delete(:update_column)
          column.form_ui = :select if (column.association && column.form_ui.nil?)
          content_tag(:div, active_scaffold_input_for(column), {:style => "display:none;", :class => inplace_edit_control_css_class})
        end
      end
      
      def inplace_edit_control_css_class
        "as_inplace_pattern"
      end
      
      def active_scaffold_in_place_editor(field_id, options = {})
        function =  "new ActiveScaffold.InPlaceEditor("
        function << "'#{field_id}', "
        function << "'#{url_for(options[:url])}'"
    
        js_options = {}
    
        if protect_against_forgery?
          options[:with] ||= "Form.serialize(form)"
          options[:with] += " + '&authenticity_token=' + encodeURIComponent('#{form_authenticity_token}')"
        end
    
        js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
        js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
        js_options['okControl'] = %('#{options[:save_control_type]}') if options[:save_control_type]
        js_options['cancelControl'] = %('#{options[:cancel_control_type]}') if options[:cancel_control_type]
        js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
        js_options['savingText'] = %('#{options[:saving_text]}') if options[:saving_text]
        js_options['rows'] = options[:rows] if options[:rows]
        js_options['cols'] = options[:cols] if options[:cols]
        js_options['size'] = options[:size] if options[:size]
        js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
        js_options['externalControlOnly'] = "true" if options[:external_control_only]
        js_options['submitOnBlur'] = "'#{options[:submit_on_blur]}'" if options[:submit_on_blur]
        js_options['loadTextURL'] = "'#{url_for(options[:load_text_url])}'" if options[:load_text_url]        
        js_options['ajaxOptions'] = options[:options] if options[:options]
        js_options['htmlResponse'] = !options[:script] if options[:script]
        js_options['callback']   = "function(form) { return #{options[:with]} }" if options[:with]
        js_options['clickToEditText'] = %('#{options[:click_to_edit_text]}') if options[:click_to_edit_text]
        js_options['textBetweenControls'] = %('#{options[:text_between_controls]}') if options[:text_between_controls]
        js_options['highlightcolor'] = %('#{options[:highlight_color]}') if options[:highlight_color]
        js_options['highlightendcolor'] = %('#{options[:highlight_end_color]}') if options[:highlight_end_color]
        js_options['onFailure'] = "function(element, transport) { #{options[:failure]} }" if options[:failure]
        js_options['onComplete'] = "function(transport, element) { #{options[:complete]} }" if options[:complete]
        js_options['onEnterEditMode'] = "function(element) { #{options[:enter_editing]} }" if options[:enter_editing]
        js_options['onLeaveEditMode'] = "function(element) { #{options[:exit_editing]} }" if options[:exit_editing]
        js_options['onFormCustomization'] = "function(element, form) { #{options[:form_customization]} }" if options[:form_customization]
        js_options['inplacePatternSelector'] = %('#{options[:inplace_pattern_selector]}') if options[:inplace_pattern_selector]
        js_options['nodeIdSuffix'] = %('#{options[:node_id_suffix]}') if options[:node_id_suffix]
        function << (', ' + options_for_javascript(js_options)) unless js_options.empty?
        
        function << ')'
    
        javascript_tag(function)
      end

    end
  end
end
