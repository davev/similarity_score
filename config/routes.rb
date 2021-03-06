Rails.application.routes.draw do

  root 'players#index'

  resources :players, only: [:index, :show] do
    get :random, on: :collection
  end

  get 'about' => 'pages#about'


  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
  end
  mount Sidekiq::Web => '/sidekiq'


end
