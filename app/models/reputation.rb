class Reputation < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  VARIATION_SELF_BIAS = 1
  VARIATION_SCALE_BIAS = 2

  def self.calculate_all
    calculate(VARIATION_SELF_BIAS)
    calculate(VARIATION_SCALE_BIAS)
  end

  def self.calculate(variation)
    User.active.each do |user|
      case variation
      when VARIATION_SELF_BIAS
        calculate_moving_average(variation,user.id)
      when VARIATION_SCALE_BIAS
        calculate_moving_average(variation,user.id)
      end
    end
  end

  #calculates a running weighted average of the reputation index
  #more recent averages are weighed more heavily.
  def self.calculate_moving_average(variation,user_id)
    User.find(user_id).projects.all_roots.each do |project|
      average = bias_moving_average(variation,user_id,project.id)
      create_or_update(variation,user_id,average,project.id) unless average.nil?
    end

    #Platform-wide average
    project_id = 0
    average = bias_moving_average(variation,user_id,project_id)
    create_or_update(variation,user_id,average,project_id) unless average.nil?

  end

  def self.create_or_update(variation,user_id,average,project_id)
    reputation = Reputation.first(:conditions => {:reputation_type => variation, :user_id => user_id, :project_id => project_id})
    if !reputation.nil?
      reputation.value = average
      reputation.save
    else
      Reputation.create :reputation_type => variation,
                        :user_id => user_id,
                        :project_id => project_id,
                        :value => average
    end
  end


  #Calculates a moving average for an assessment bias (in retrospectives that have their root project: project_id)
  #When project_id is 0, moving average is calculated across all projects
  def self.bias_moving_average(variation,user_id,project_id)
    rr_variation = nil
    case variation
    when VARIATION_SELF_BIAS
      rr_variation = RetroRating::SELF_BIAS
    when VARIATION_SCALE_BIAS
      rr_variation = RetroRating::SCALE_BIAS
    end

    score_total = 0
    weight_total = 0
    counter = Setting::LENGTH_OF_MOVING_AVERAGE

    RetroRating.all(:conditions => {:ratee_id => user_id, :rater_id => rr_variation}, :include => :retro, :order => "updated_at DESC").each do |rr|
      next if rr.retro.project.root.id != project_id && project_id != 0
      weight = rr.retro.total_points * (counter.to_f/Setting::LENGTH_OF_MOVING_AVERAGE)
      weight_total += weight
      score_total += rr.score * weight
      counter += -1 if counter > 1
    end

    weight_total == 0 ? nil : score_total / weight_total

  end

end

# == Schema Information
#
# Table name: reputations
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  project_id      :integer
#  reputation_type :integer
#  value           :float
#  params          :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

