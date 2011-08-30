Otrs::Application.routes.draw do
  resources :tickets do
    resource :articles
  end
  resources :links
  resources :config_items
end
