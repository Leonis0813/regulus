Rails.application.routes.draw do
  get '/analyses' => 'analyses#manage'
  post '/analyses' => 'analyses#execute'

  get '/predictions' => 'predictions#manage'
  post '/predictions' => 'predictions#execute'
  post '/predictions/settings' => 'predictions#settings'

  namespace :api, format: 'json' do
    resources :predictions, only: %i[index]
  end
end
