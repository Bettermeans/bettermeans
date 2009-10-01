if defined? ActiveSupport
  # Hack to force Rails version prior to 2.0 to use quoted JSON as per the JSON standard...
  if (defined?(ActiveSupport::JSON) && ActiveSupport::JSON.respond_to?(:unquote_hash_key_identifiers))
    ActiveSupport::JSON.unquote_hash_key_identifiers = false 
  end
end

if defined? ActionController
  module ActionController
    class Base
    
      def rescue_action_with_exceptional(exception)
        unless exception_will_be_handled_by_rescue_from?(exception)
          params_to_send = (respond_to? :filter_parameters) ? filter_parameters(params) : params
          Exceptional.handle(exception, self, request, params_to_send)
        end
        rescue_action_without_exceptional(exception)
      end

      def exception_will_be_handled_by_rescue_from?(exception)
        # don't report to exceptional if app has custom rescue_from for particular exception
        respond_to?(:handler_for_rescue) && handler_for_rescue(exception)
      end
    
      alias_method :rescue_action_without_exceptional, :rescue_action
      alias_method :rescue_action, :rescue_action_with_exceptional
      protected :rescue_action
    end
  end
end