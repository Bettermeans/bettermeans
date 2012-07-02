module RetrosHelper
  def render_title_date()
    end_date = @retro.created_at.advance(:days => Setting::DEFAULT_RETROSPECTIVE_LENGTH)
    if (@retro.ended?)
      return "ended #{distance_of_time_in_words(Time.now,end_date)} ago"
    else
      return "ends in #{distance_of_time_in_words(Time.now,end_date)}"
    end
  end

  def team_from_issue(issue)
    issue.team_votes.collect{|iv| link_to_user_from_id iv.user_id }.join(", ")
  end

  def accuracy_display(self_bias,magnitude)
    return "<br>Didn't vote" if self_bias.nil? && magnitude.nil?
    content = ""
    content << "<br>#{tame_bias(self_bias)}<br>#{tame_scale(magnitude)}"
  end
end
