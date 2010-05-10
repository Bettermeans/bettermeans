module DynamicScriptsHelper
  def dynamic_script_tag name, options = {}    
    options = { :controller => "dynamic_scripts", 
                :action     => name,
                :format     => "js",
                :only_path  => true,
              }.merge(options)

    "<script src='#{@controller.url_for(options)}' type='text/javascript'></script>"
  end
end
