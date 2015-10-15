Rails.application.routes.draw do
  get '/' => 'confirmation#show'
  get '/currency' => 'currencies#update'
  get '/tweet' => 'tweets#update'
  get '/article' => 'articles#update'
end
