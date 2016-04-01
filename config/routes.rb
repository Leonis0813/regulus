Rails.application.routes.draw do
  get '/', to: redirect('/rates')
  get '/rates' => 'rates#show'
  get '/tweets' => 'tweets#show'
  get '/articles' => 'articles#show'
  get '/rates/update' => 'rates#update'
  get '/tweets/update' => 'tweets#update'
  get '/articles/update' => 'articles#update'
end
