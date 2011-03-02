AdminData::Config.set = {
  :is_allowed_to_view => lambda {|controller| controller.send('data_admin_logged_in?') },
  :is_allowed_to_update => lambda {|controller| controller.send('data_admin_logged_in?') },
}

