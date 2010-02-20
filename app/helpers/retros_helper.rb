module RetrosHelper
  def render_title_date()
    end_date = @retro.created_on.advance(:days => Setting::DEFAULT_RETROSPECTIVE_LENGTH)
    if (@retro.ended?)
      return "ended #{distance_of_time_in_words(Time.now,@retro.updated_on)} ago"
    else
      return "ends in #{distance_of_time_in_words(Time.now,end_date)}"
    end
  end
  
  def team_from_issue(issue)
    html = ''
    issue.team.each do |issue_vote| 
      html = html + link_to_user_from_id(issue_vote.user_id) + ", "
    end 
    html = truncate html, html.length-1
    
  end
end
