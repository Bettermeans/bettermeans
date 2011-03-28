module MotionsHelper
  def render_title_date()
    end_date = @motion.ends_on
    if (!@motion.active?)
      logger.info { DateTime.now }
      logger.info { "message" }
      return "Voting ended #{distance_of_time_in_words(Time.now,end_date)} ago"
    else
      return "Voting ends in #{distance_of_time_in_words(Time.now,end_date)}"
    end
  end
end
