require File.join(File.dirname(__FILE__), "view")

class BrowseBettermeansView < View
  def initialize(session)    
    @xpath = ".//div[@class='gt-content-box']/table/tbody/tr/td/" + 
        "div[@class='project-summary']"  
    
    @title_xpath = "#{@xpath}/h4/a/text()"
        
    super session
  end
  
  def latest_public_workstreams    
    session.within "div.splitcontentleft" do |scope|
      xpath(scope.dom, @title_xpath).map {|_|_.content}      
    end    
  end

  def most_active_public_workstreams
    session.within "div.splitcontentright" do |scope|             
      xpath(scope.dom, @title_xpath).map {|_|_.content}      
    end 
  end
  
  def load_more_latest_public_workstreams
    session.within "div.splitcontentleft" do |scope|      
      click_link "latest_load_more"
    end 
  end
  
  def load_more_most_active_public_workstreams
    session.within "div.splitcontentright" do |scope|      
      click_link "latest_load_more"
    end 
  end
end