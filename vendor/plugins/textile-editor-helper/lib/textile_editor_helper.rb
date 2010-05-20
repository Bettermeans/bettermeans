module ActionView
  module Helpers

    class FormBuilder
      def textile_editor(method, options = {})
        @template.textile_editor(@object_name, method, options.merge(:object => @object))
      end
    end
    
    module PrototypeHelper
    end
    
    module FormHelper
      # Returns a textarea opening and closing tag set tailored for accessing a specified attribute (identified by +method+)
      # on an object assigned to the template (identified by +object+). Additional options on the input tag can be passed as a
      # hash with +options+ and places the textile toolbar above it
      #
      # ==== Examples
      #   textile_editor(:post, :body, :cols => 20, :rows => 40)
      #   # => <textarea cols="20" rows="40" id="post_body" name="post[body]">
      #   #      #{@post.body}
      #   #    </textarea>
      #
      #   textile_editor(:comment, :text, :size => "20x30")
      #   # => <textarea cols="20" rows="30" id="comment_text" name="comment[text]">
      #   #      #{@comment.text}
      #   #    </textarea>
      #
      #   textile_editor(:application, :notes, :cols => 40, :rows => 15, :class => 'app_input')
      #   # => <textarea cols="40" rows="15" id="application_notes" name="application[notes]" class="app_input">
      #   #      #{@application.notes}
      #   #    </textarea>
      #
      #   textile_editor(:entry, :body, :size => "20x20", :disabled => 'disabled')
      #   # => <textarea cols="20" rows="20" id="entry_body" name="entry[body]" disabled="disabled">
      #   #      #{@entry.body}
      #   #    </textarea>
      def textile_editor(object_name, method, options = {})        
        editor_id = options[:id] || '%s_%s' % [object_name, method]
        mode      = options.delete(:simple) ? 'simple' : 'extended'
        (@textile_editor_ids ||= []) << [editor_id.to_s, mode.to_s]

        InstanceTag.new(object_name, method, self, options.delete(:object)).to_text_area_tag(options)
      end
      
      def textile_editor_options(options={})
        (@textile_editor_options ||= { :framework => :prototype }).merge! options
      end
      
      def textile_editor_support
        output = []
        output << stylesheet_link_tag('textile-editor') 
        output << javascript_include_tag('textile-editor')
        output.join("\n")
      end
      
      # registers a new button for the Textile Editor toolbar
      # Parameters:
      #   * +text+: text to display (contents of button tag, so HTML is valid as well)
      #   * +options+: options Hash as supported by +content_tag+ helper in Rails
      # 
      # Example:
      #   The following example adds a button labeled 'Greeting' which triggers an
      #   alert:
      # 
      #   <% textile_editor_button 'Greeting', :onclick => "alert('Hello!')" %> 
      #
      # *Note*: this method must be called before +textile_editor_initialize+
      def textile_editor_button(text, options={})
        return textile_editor_button_separator  if text == :separator
        button = content_tag(:button, text, options)
        button = "TextileEditor.buttons.push(\"%s\");" % escape_javascript(button)
        (@textile_editor_buttons ||= []) << button
      end

      def textile_editor_button_separator(options={})
        button = "TextileEditor.buttons.push(new TextileEditorButtonSeparator('%s'));" % (options[:simple] || '')
        (@textile_editor_buttons ||= []) << button
      end

      def textile_extract_dom_ids(*dom_ids)
        hash = dom_ids.last.is_a?(Hash) ? dom_ids.pop : {}
        hash.inject(dom_ids) do |ids, (object, fields)|
          ids + Array(fields).map { |field| "%s_%s" % [object, field] }
        end
      end
      
      # adds the necessary javascript include tags, stylesheet tags,
      # and load event with necessary javascript to active textile editor(s)
      # sample output:
      #    <link href="/stylesheets/textile-editor.css" media="screen" rel="Stylesheet" type="text/css" />
      #    <script src="/javascripts/textile-editor.js" type="text/javascript"></script>
      #    <script type="text/javascript">
      #    document.observe('dom:loaded', function() {
      #    TextileEditor.initialize('article_body', 'extended');
      #    TextileEditor.initialize('article_body_excerpt', 'simple');
      #    });
      #    </script>  
      # 
      # Note: in the case of this helper being called via AJAX, the output will be reduced:
      #    <script type="text/javascript">
      #    TextileEditor.initialize('article_body', 'extended');
      #    TextileEditor.initialize('article_body_excerpt', 'simple');
      #    </script>  
      # 
      # This means that the support files must be loaded outside of the AJAX request, either
      # via a call to this helper or the textile_editor_support() helper
      def textile_editor_initialize(*dom_ids)
        options = textile_editor_options.dup

        # extract options from last argument if it's a hash
        if dom_ids.last.is_a?(Hash)
          hash = dom_ids.last.dup
          options.merge! hash
          dom_ids.last.delete :framework
        end

        editor_ids = (@textile_editor_ids || []) + textile_extract_dom_ids(*dom_ids)
        editor_buttons = (@textile_editor_buttons || [])
        output = []
        output << textile_editor_support unless request.xhr?
        output << '<script type="text/javascript">'
        output << '/* <![CDATA[ */'
        
        if !request.xhr?
          case options[:framework]
          when :prototype
            output << %{document.observe('dom:loaded', function() \{}
          when :jquery
            output << %{$(document).ready(function() \{}
          end
        end      

        # output << %q{TextileEditor.framework = '%s';} % options[:framework].to_s
        output << editor_buttons.join("\n") if editor_buttons.any?
        editor_ids.each do |editor_id, mode|
          output << %q{TextileEditor.initialize('%s', '%s');} % [editor_id, mode || 'extended']
        end
        output << '});' unless request.xhr?

        output << '/* ]]> */'
        output << '</script>'
        output.join("\n")
      end
    end
    
    module FormTagHelper
      # Creates a text input area; use a textarea for longer text inputs such as blog posts or descriptions 
      # and includes the textile toolbar above it.
      # 
      # ==== Options
      # * <tt>:size</tt> - A string specifying the dimensions (columns by rows) of the textarea (e.g., "25x10").
      # * <tt>:rows</tt> - Specify the number of rows in the textarea
      # * <tt>:cols</tt> - Specify the number of columns in the textarea
      # * <tt>:disabled</tt> - If set to true, the user will not be able to use this input.
      # * Any other key creates standard HTML attributes for the tag.
      #
      # ==== Examples
      #   textile_editor_tag 'post'
      #   # => <textarea id="post" name="post"></textarea>
      #
      #   textile_editor_tag 'bio', @user.bio
      #   # => <textarea id="bio" name="bio">This is my biography.</textarea>
      #
      #   textile_editor_tag 'body', nil, :rows => 10, :cols => 25
      #   # => <textarea cols="25" id="body" name="body" rows="10"></textarea>
      #
      #   textile_editor_tag 'body', nil, :size => "25x10"
      #   # => <textarea name="body" id="body" cols="25" rows="10"></textarea>
      #
      #   textile_editor_tag 'description', "Description goes here.", :disabled => true
      #   # => <textarea disabled="disabled" id="description" name="description">Description goes here.</textarea>
      #
      #   textile_editor_tag 'comment', nil, :class => 'comment_input'
      #   # => <textarea class="comment_input" id="comment" name="comment"></textarea>
      def textile_editor_tag(name, content = nil, options = {})
        editor_id = options[:id] || name
        mode      = options.delete(:simple) ? 'simple' : 'extended'
        (@textile_editor_ids ||= []) << [editor_id.to_s, mode.to_s]
        
        text_area_tag(name, content, options)
      end
    end
    
  end
end

