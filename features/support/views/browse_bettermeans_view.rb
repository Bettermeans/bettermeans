require File.join(File.dirname(__FILE__), "view")

class BrowseBettermeansView < View
  def initialize(session)    
    @xpath = ".//div[@class='gt-content-box']/table/tbody/tr/td/" + 
        "div[@class='project-summary']"  
    
    @title_xpath = "#{@xpath}/h4/a/text()"
        
    super session
  end
  
  def latest_public_workstreams    
    session.within "div.splitcontentright" do |scope|
      xpath(scope.dom, @title_xpath).map {|_|_.content}      
    end    
  end

  def most_active_public_workstreams
    session.within "div.splitcontentleft" do |scope|             
      xpath(scope.dom, @title_xpath).map {|_|_.content}      
    end 
  end
  
  def load_more_latest_public_workstreams
    click_link "latest_load_more"
  end
  
  def load_more_most_active_public_workstreams
    click_link "active_load_more"      
  end
  
  require 'features/support/garcon_dsl'
  include GarconDsl
  
  def wait_until_loaded
    wait.for(5.seconds).until { is_hidden? loading_screen }      
  end
  
  def loading_screen
    xpath(session.current_dom, "//*[@id='ajax-indicator']").first
  end
  
  private 
  
  def is_hidden?(element); element["style"] =~ /display\: none/; end
end