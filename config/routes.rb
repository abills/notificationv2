Notificationv2::Application.routes.draw do
  resources :groups

  resources :rules

  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users, :path_prefix => 'd'
  #resources :users
  #devise_for :users
  resources :users, :only => [:show, :index, :edit, :update]

end
