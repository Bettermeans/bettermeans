class View
  def initialize(session); @session = session; end

  protected

  attr_reader :session

  def xpath(dom, xpath); dom.xpath(xpath); end
end
