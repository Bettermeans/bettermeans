# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

module WikiHelper
  
  def wiki_page_options_for_select(pages, selected = nil, parent = nil, level = 0)
    s = ''
    pages.select {|p| p.parent == parent}.each do |page|
      attrs = "value='#{page.id}'"
      attrs << " selected='selected'" if selected == page
      indent = (level > 0) ? ('&nbsp;' * level * 2 + '&#187; ') : nil
      
      s << "<option value='#{page.id}'>#{indent}#{h page.pretty_title}</option>\n" + 
             wiki_page_options_for_select(pages, selected, page, level + 1)
    end
    s
  end
  
  def html_diff(wdiff)
    words = wdiff.words.collect{|word| h(word)}
    words_add = 0
    words_del = 0
    dels = 0
    del_off = 0
    wdiff.diff.diffs.each do |diff|
      add_at = nil
      add_to = nil
      del_at = nil
      deleted = ""	    
      diff.each do |change|
        pos = change[1]
        if change[0] == "+"
          add_at = pos + dels unless add_at
          add_to = pos + dels
          words_add += 1
        else
          del_at = pos unless del_at
          deleted << ' ' + h(change[2])
          words_del	 += 1
        end
      end
      if add_at
        words[add_at] = '<span class="diff_in">' + words[add_at]
        words[add_to] = words[add_to] + '</span>'
      end
      if del_at
        words.insert del_at - del_off + dels + words_add, '<span class="diff_out">' + deleted + '</span>'
        dels += 1
        del_off += words_del
        words_del = 0
      end
    end
    simple_format_without_paragraph(words.join(' '))
  end
end
