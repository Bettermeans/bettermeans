class View
  def initialize(session); @session = session; end
  
  protected
  
  attr_reader :session

  require "webrat"
  
  def xpath(dom, xpath); Webrat::XML.xpath_search(dom, xpath); end
end