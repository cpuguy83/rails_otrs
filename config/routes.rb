Otrs::Application.routes.draw do
  scope "otrs", :as => "otrs" do
    resources :tickets do
      resource :articles
    end
    resources :config_items
  end
  resources :tickets
  resources :links
  resources :config_items
  resources :articles
end
