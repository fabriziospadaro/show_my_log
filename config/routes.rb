require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  root to: 'log_managers#index'
  post 'log_managers/process_file' => 'log_managers#process_file', as: 'process_file'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
