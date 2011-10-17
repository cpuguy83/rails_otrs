Otrs::Application.routes.draw do
  scope "otrs", :as => "otrs" do
    resources :tickets do
      resource :articles
    end
    resources :changes do
      resource :work_orders
    end
    resources :config_items
    resources :services
    resources :links
  end
  resources :ticket_queues
  resources :tickets
  resources :ticket_types
  resources :ticket_states
  resources :links
  resources :config_items
  resources :articles
  resources :changes
  resources :work_orders
  resources :services
end
