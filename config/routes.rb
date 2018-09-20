Rails.application.routes.draw do
  get '/analyses' => 'analyses#manage'
  post '/analyses' => 'analyses#execute'
end
