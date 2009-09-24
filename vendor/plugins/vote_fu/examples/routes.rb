
map.resources :users do |user|
  user.resources :votes
  user.resources :voteable do |mv|
    mv.resources :votes
  end
end