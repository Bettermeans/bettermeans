# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
#

module JournalsHelper
  def render_notes(journal, editable, options={})
    # votingcontent = ''
    content = ''
    editable ||= false;
    links = []
    if !journal.notes.blank?

      # links << link_to_remote(l(:button_quote),
      #                         { :url => {:controller => 'issues', :action => 'reply', :id => journal.journalized, :journal_id => journal} },
      #                         :title => l(:button_quote),
      #                         :class => 'icon icon-comment') if options[:reply_links]


      links << link_to_in_place_notes_editor(l(:button_edit), "journal-#{journal.id}-notes",
                                                 { :controller => 'journals', :action => 'edit', :id => journal },
                                                    :title => l(:button_edit),
                                                    :class => 'icon icon-edit') if editable



    end

    content << content_tag('div', links.join(' '), :class => 'contextual') unless links.empty?
    # content << content_tag('div', votingcontent, :id => "votes_" + String(journal.id), :class => 'journalvote')
    content << textilizable(journal, :notes)
    css_classes = "wiki"
    css_classes << " editable" if editable
    css_classes << " gravatar-margin" if Setting.gravatar_enabled?
    content_tag('div', content, :id => "journal-#{journal.id}-notes", :class => css_classes)
  end

  def render_votes(journal, options={})
    votingcontent = ''
    #We show total votes regardless
    votingcontent << " " + String(journal.votes_for - journal.votes_against) + " points"

    # Voting on journal items
    unless journal.user_id == User.current.id ||
      !User.current.logged? ||
      User.current.voted_on?(journal)
      votingcontent << link_to_remote(image_tag('/images/aupgray.gif', :size => "15x14", :border => 0),
        {
        :url => user_journal_votes_path(User.current, journal, :vote => :true, :format => :js, :voteable_type => "journal"),
        :method => :post
        })
      votingcontent << link_to_remote(image_tag('/images/adowngray.gif', :size => "15x14", :border => 0),
        {
        :url => user_journal_votes_path(User.current, journal, :vote => :false, :format => :js, :voteable_type => "journal"),
        :method => :post
        })
    end

    content_tag('span', votingcontent, :id => "votes_" + String(journal.id), :class => 'journalvote')

  end


  def link_to_in_place_notes_editor(text, field_id, url, options={})
    onclick = "$.ajax({type: 'GET', url: '#{url_for(url)}'});return false;"
    link_to text, '#', options.merge(:onclick => onclick)
  end
end
