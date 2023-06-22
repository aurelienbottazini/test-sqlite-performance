Rails.application.routes.draw do
  get 'stats', to: 'stats#index'
  get 'visit', to: 'visit#index'
  get 'hello', to: 'hello#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'hello#index'
end
