# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

module SearchHelper
  def highlight_tokens(text, tokens)
    return text unless text && tokens && !tokens.empty?
    re_tokens = tokens.collect {|t| Regexp.escape(t)}
    regexp = Regexp.new "(#{re_tokens.join('|')})", Regexp::IGNORECASE    
    result = ''
    text.split(regexp).each_with_index do |words, i|
      if result.length > 1200
        # maximum length of the preview reached
        result << '...'
        break
      end
      words = words.mb_chars
      if i.even?
        result << h(words.length > 100 ? "#{words.slice(0..44)} ... #{words.slice(-45..-1)}" : words)
      else
        t = (tokens.index(words.downcase) || 0) % 4
        result << content_tag('span', h(words), :class => "highlight token-#{t}")
      end
    end
    result
  end
  
  def type_label(t)
    l("label_#{t.singularize}_plural")
  end
  
  def project_select_tag
    options = [[l(:label_project_all), 'all']]
    options << [l(:label_my_projects), 'my_projects'] unless User.current.memberships.empty?
    options << [l(:label_and_its_subprojects, @project.name), 'subprojects'] unless @project.nil? || @project.descendants.active.empty?
    options << [@project.name, ''] unless @project.nil?
    select_tag('scope', options_for_select(options, params[:scope].to_s)) if options.size > 1
  end
  
  def render_results_by_type(results_by_type)
    links = []
    # Sorts types by results count
    results_by_type.keys.sort {|a, b| results_by_type[b] <=> results_by_type[a]}.each do |t|
      c = results_by_type[t]
      next if c == 0
      text = "#{type_label(t)} (#{c})"
      links << link_to(text, :q => params[:q], :titles_only => params[:title_only], :all_words => params[:all_words], :scope => params[:scope], t => 1)
    end
    ('<ul>' + links.map {|link| content_tag('li', link)}.join(' ') + '</ul>') unless links.empty?
  end
end
