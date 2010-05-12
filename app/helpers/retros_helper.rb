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
      number = number.round
      number > 0 ? "Self:&nbsp&nbsp; +#{number}" : number == 0 ? "Self:&nbsp&nbsp; No Bias" : "Self:&nbsp&nbsp; #{number}"
    end
  end

  def tame_magnitude(number)
    if number.nil?
      ""
    else
      number = number.round
      number == 0 ? "Other: No Bias" : "Other: #{number}"
    end
  end
  
  def accuracy_display(self_bias,magnitude)
    return "<br><br>Didn't vote" if self_bias.nil? && magnitude.nil?
    content = ""
    content << "<br><br>#{tame_bias(self_bias)}<br>#{tame_magnitude(magnitude)}"
  end
end
