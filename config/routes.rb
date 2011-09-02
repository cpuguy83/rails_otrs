Otrs::Application.routes.draw do
  scope "otrs", :as => "otrs" do
    resources :tickets do
      resource :articles
    end
  end
  resources :tickets
  resources :links
  resources :config_items
end
