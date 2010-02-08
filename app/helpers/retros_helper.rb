module RetrosHelper
  def render_title_date(end_date)
    if (end_date > DateTime.now)
      return "(ends in #{distance_of_time_in_words(Time.now,end_date)}"
    else
      return "(ended #{distance_of_time_in_words(Time.now,end_date)} ago"
    end
  end
end
