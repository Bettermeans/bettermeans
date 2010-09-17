module UserStats 
  class Application < Sinatra::Base
  
    set :public, File.join(File.dirname(__FILE__), 'public')
    set :views, File.join(File.dirname(__FILE__), 'views')
    
    get '/__user_stats.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass :stylesheet
    end
    
    get '/__user_stats' do
      if permitted?
        @signups_today = User.count(:conditions => ["created_at > ?", 1.day.ago])
        @signups_this_week = User.count(:conditions => ["created_at > ?", 1.week.ago])
        @newest_users = User.all(:order => 'created_at DESC', :limit => 10)
        if current_user.respond_to?(:last_request_at)
          @active_today = User.count(:conditions => ["last_request_at > ?", 1.day.ago])
          @active_this_week = User.count(:conditions => ["last_request_at > ?", 1.week.ago])
          @last_active_users = User.all(:order => 'last_request_at DESC', :limit => 10)
        end
        haml :index
      else
        halt 401, "Not Permitted"
      end
    end
    
  private
    
    def current_user
      User.first(:conditions => {
        :persistence_token => env["rack.session"]["user_credentials"],
        :id => env["rack.session"]["user_credentials_id"]
      })
    end
    
    def permitted?
      current_user && 
      current_user.respond_to?(:can_view_user_stats?) &&
      current_user.can_view_user_stats?
    end
  end
end