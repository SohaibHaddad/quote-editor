Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]
  resources :quotes, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    # These custom cancel routes restore the inline Turbo rows in place.
    # Without them, the cancel buttons would navigate back to /quotes,
    # which reloads the page and resets the user's scroll position.
    # That scroll jump creates a poor user experience because the user loses
    # their place in the table after cancelling an inline action.
    get :cancel_new, on: :collection
    get :cancel_edit, on: :member
    
    patch :validate_quote, on: :member
    resources :quote_items, only: [:new, :create, :edit, :update, :destroy] do
      # These custom cancel routes restore the inline quote item rows in place.
      # Without them, the cancel buttons would navigate back to the quote show
      # page, which reloads the page and resets the user's scroll position.
      # That scroll jump creates a poor user experience because the user loses
      # their place in the items table after cancelling the inline form.
      get :cancel_new, on: :collection
      get :cancel_edit, on: :member
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "quotes#index"
end
