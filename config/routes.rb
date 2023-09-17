Rails.application.routes.draw do
  devise_for :users

  get 'weather-info', to: 'weather#weather_info'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'weather#weather_info'
end
