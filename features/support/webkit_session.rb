class WebkitSession
  require 'capybara-webkit'  
  
  %w[link].each do |name|
    define_method "click_#{name}".to_sym do |what|
      click what
    end
  end
  
  def click(what) 
    the_thing = find_first(what)
        
    the_thing.click
  end
    
  def get(url) 
    instance.reset!
    clear_scope    
    instance.visit url
  end
  
  alias visit :get
  
  def response_body; instance.body; end  
  
  def fill_in(what, options = {:with => ""})
    field = find what
    
    fail("Could not find text field with id \"#{what}\"") unless field.size == 1
    
    field.first.set options[:with]
  end
  
  def click_button(what)
    field = find what
    
    fail("Could not find text field with id \"#{what}\"") unless field.size == 1
    
    field.first.click
  end  
  
  def find_first(what)
    result = find what
    
    fail "Unable to locate element <#{what}>" unless result
    fail "Too many results for <#{what}>. Expected 1, got <#{result.size}>." unless 
      result.size === 1
    
    result.first
  end
  
  def find(what)
    result = find_by_id_or_name what
    return result if result.size > 0
    
    result = find_by "value", what
    return result if result.size > 0
    
    result = find_by "text", what
    return result if result.size > 0
    
    result = find_by "innerText", what
    return result if result.size > 0
    
    fail "Unable to locate element <#{what}>" if result.nil?
  end  
  
  def find_by_id_or_name(what)
    result = find_by "id", what
    return result if result.size > 0
    find_by "name", what
  end  
    
  def url; instance.current_url; end
  
  def select; end
  
  def within(selector)
    scopes.push(Webrat::Scope.from_scope(self, current_scope, selector))
    ret = yield(current_scope)
    scopes.pop
    return ret
  end
  
  def xml_content_type?; false; end
  
  private

  def find_by(attribute, value)
    instance.find("//*[@#{attribute}='#{value}']" );
  end
  
  def instance; @instance ||= Capybara::Driver::Webkit.new nil; end
  
  def current_scope; scopes.last || page_scope; end
  def clear_scope; clear_page_scope; clear_dom_scope; end
  def clear_page_scope; @_page_scope = nil; end 
  def clear_dom_scope; @scopes = nil; end
  
  def page_scope
    @_page_scope ||= Webrat::Scope.from_page(self, Object.new, response_body)
  end
  
  def scopes; @scopes ||= []; end
end