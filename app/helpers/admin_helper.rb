# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

module AdminHelper
  def project_status_options_for_select(selected)
    options_for_select([[l(:label_all), ''], 
                        [l(:status_active), 1]], selected)
  end
  
  def css_project_classes(project)
    s = 'project'
    s << ' root' if project.root?
    s << ' child' if project.child?
    s << (project.leaf? ? ' leaf' : ' parent')
    s
  end
end
