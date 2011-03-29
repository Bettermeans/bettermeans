require 'webrat'
require 'webrat/core/matchers'

class BrowseBettermeansView
  include Webrat::Locators 
  
  def initialize(response) 
    @response = response
    
    # TODO: For some reason, scope.dom contains duplicates
    @xpath = ".//div[@class='gt-content-box']/table/tbody/tr/td/" + 
        "div[@class='project-summary']"  
  end
  
  def latest_public_workstreams
    session.within "div.splitcontentleft" do |scope|                 
      xpath(scope.dom, @xpath)      
    end    
  end

  def most_active_public_workstreams
    session.within "div.splitcontentright" do |scope|             
      xpath(scope.dom, @xpath)      
    end 
  end
  
  private
  
  def session; @session ||= Webrat::Session.new adapter; end
  def adapter; Webrat.adapter_class.new @response; end
  def xpath(dom, xpath); Webrat::XML.xpath_search(dom, xpath); end
end