module Redmine
  module Info
    class << self
      def app_name; 'Redmine' end # spec_me cover_me heckle_me
      def url; 'http://www.redmine.org/' end # spec_me cover_me heckle_me
      def help_url; 'http://www.redmine.org/guide' end # spec_me cover_me heckle_me
      def versioned_name; "#{app_name} #{Redmine::VERSION}" end # spec_me cover_me heckle_me

      # Creates the url string to a specific Redmine issue
      def issue(issue_id) # spec_me cover_me heckle_me
        url + 'issues/' + issue_id.to_s
      end
    end
  end
end
