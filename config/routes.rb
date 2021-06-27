Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  get '/analyses' => 'analyses#manage'
  post '/analyses' => 'analyses#execute'
  put '/analyses/result' => 'analyses#upload_result'

  get '/predictions' => 'predictions#manage'
  post '/predictions' => 'predictions#execute'
  put '/predictions/settings' => 'predictions#settings'

  resources :evaluations, only: %i[index show], param: :evaluation_id
  post '/evaluations' => 'evaluations#execute'

  namespace :api, format: 'json' do
    resources :predictions, only: %i[index]
  end
end
