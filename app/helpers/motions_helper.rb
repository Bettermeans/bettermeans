module MotionsHelper
  def render_title_date()
    end_date = @motion.ends_on
    if (!@motion.active?)
      return "Voting ended #{distance_of_time_in_words(DateTime.now,end_date)} ago"
    else
      return "Voting ends in #{distance_of_time_in_words(DateTime.now,end_date)}"
    end
  end
end
