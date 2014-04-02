namespace :oneoff do

  desc 'clean up verbs for activity streams'
  task :format_verbs => :environment do

    verb_map = {
      'changed their estimate for' => 'changed_estimate_for',
      'publicised' => 'publicized',
    }

    ActivityStream.transaction do
      ActivityStream.all.each do |stream|
        verb_map.each do |old, new|
          if stream.verb == old
            stream.verb = new
            stream.save!
          end
        end
      end
    end
  end

end
