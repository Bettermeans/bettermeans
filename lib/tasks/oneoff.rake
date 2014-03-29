namespace :oneoff do

  desc 'reformat indirect_object_phrase on activity streams'
  task :format_phrases => :environment do
    ActivityStream.transaction do
      ActivityStream.all.each do |stream|
        next unless stream.indirect_object_phrase
        statuses = stream.indirect_object_phrase.scan(/<strong>(\w+)<\/strong>/).flatten.each(&:downcase)
        next unless statuses.any?
        raise "wut? #{statuses.inspect}" unless statuses.length == 2
        stream.indirect_object_phrase = statuses.join(':')
        stream.save!
      end
    end
  end

end
