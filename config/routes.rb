Rails.application.routes.draw do
  get '/' => 'confirmation#show'
  get '/currency' => 'confirmation#update_currency'
  get '/tweet' => 'confirmation#update_tweet'
  get '/article' => 'confirmation#update_article'
end
