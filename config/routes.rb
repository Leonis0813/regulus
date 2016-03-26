Rails.application.routes.draw do
  get '/' => 'confirmation#show'
  get '/rate' => 'rates#show'
  get '/tweet' => 'tweets#show'
  get '/article' => 'articles#show'
  get '/rate/update' => 'rates#update'
  get '/tweet/update' => 'tweets#update'
  get '/article/update' => 'articles#update'
end
