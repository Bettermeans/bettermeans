module RetrosHelper
  def render_title_date()
    end_date = @retro.created_on.advance(:days => Setting::DEFAULT_RETROSPECTIVE_LENGTH)
    if (@retro.ended?)
      return "ended #{distance_of_time_in_words(Time.now,end_date)} ago"
    else
      return "ends in #{distance_of_time_in_words(Time.now,end_date)}"
    end
  end
  
  def team_from_issue(issue)
    issue.team.collect{|iv| link_to_user_from_id iv.user_id }.join(", ")
  end
  
  def tame_bias(number)
    if number.nil? 
      return ""
    else
      number > 0 ? "Self Bias: +#{number.round}%" : number == "None" ? number.round : "Self Bias: -#{number.round}%"
    end
  end

  def tame_magnitude(number)
    if number.nil?
      ""
    else
      number > 0 ? "Off by: #{number.round} points" : number == "No Bias" ? number.round : "Off by #{number.round} points"
    end
  end
end
