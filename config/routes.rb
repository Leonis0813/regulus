Rails.application.routes.draw do
  get '/' => 'confirmation#show'
  get '/rate' => 'ratess#update'
  get '/tweet' => 'tweets#update'
  get '/article' => 'articles#update'
end
