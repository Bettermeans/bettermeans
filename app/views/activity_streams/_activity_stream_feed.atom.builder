
this_url = "http://#{request.host_with_port}/feeds/your_activities/#{@user.activity_stream_token}"

atom_feed(:url => this_url) do |feed|
  feed.title("#{ACTIVITY_STREAM_SERVICE_STRING}: Activity Stream for #{@user.send(ACTIVITY_STREAM_USER_MODEL_NAME)}")
  feed.updated(@activity_streams.first ? @activity_streams.first.created_at : Time.now.utc)

  for activity_stream in @activity_streams
    feed.entry(activity_stream.object ? 
              activity_stream.object : activity_stream) do |entry|
      entry.title(activity_stream.activity.humanize)
      entry.content(render(:partial => 'activity_streams/activity_stream.html.erb',
        :locals => {:activity_stream => activity_stream}),
        :type => 'html')

      entry.author do |author|
        author.name(activity_stream.actor ? activity_stream.actor.send(activity_stream.actor_name_method) : '(deleted)' )
      end
    end
  end
end
