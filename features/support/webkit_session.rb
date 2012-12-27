class WebkitSession
  require 'capybara-webkit'

  def initialize(driver=Capybara::Driver::Webkit.new(nil)) #todo: inject without default
    @driver = driver
    @scope_factory = WebratScopeFactory
  end

  %w[link button].each do |name|
    define_method "click_#{name}".to_sym do |what|
      click what
    end
  end

  def click(what)
    the_thing = find_first(what)

    the_thing.click
  end

  def get(url)
    driver.reset!
    clear_scope
    driver.visit url
  end

  alias visit :get

  def response_body; driver.body; end

  def fill_in(what, options = {:with => ""})
    field = find what

    fail("Could not find text field with id \"#{what}\"") unless field.size == 1

    field.first.set options[:with]
  end

  def find_first(what)
    result = find what

    fail "Unable to locate element <#{what}>" unless result
    fail "Too many elements found. Expected <1>. Got <#{result.size}>." unless
      result.size === 1

    result.first
  end

  def find(what)
    result = find_by_id_or_name what
    return result if result.size > 0

    result = find_by "value", what
    return result if result.size > 0

    fail "Unable to locate element <#{what}>" if result.nil?
  end

  def find_by_id_or_name(what)
    result = find_by "id", what
    return result if result.size > 0
    find_by "name", what
  end

  def url; driver.current_url; end

  def select; end

  def within(selector)
    scopes.push(@scope_factory.from_scope(self, current_scope, selector))
    ret = yield(current_scope)
    scopes.pop
    return ret
  end

  def xml_content_type?; false; end

  def current_dom; current_scope.dom; end

  private

  def driver; @driver end

  def find_by(attribute, value)
    driver.find("//*[@#{attribute}='#{value}']");
  end

  def current_scope; scopes.last || page_scope; end
  def clear_scope; clear_page_scope; clear_dom_scope; end
  def clear_page_scope; @_page_scope = nil; end
  def clear_dom_scope; @scopes = nil; end

  def page_scope
    @scope_factory.from_page(self, response_body)
  end

  def scopes; @scopes ||= []; end
end

class WebratScopeFactory
  def self.from_page(session, response_body)
    Webrat::Scope.from_page(session, Object.new, response_body)
  end

  def self.from_scope(session, scope, selector)
    Webrat::Scope.from_scope(session, scope, selector)
  end
end
