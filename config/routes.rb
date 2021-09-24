# == Route Map
#

Rails.application.routes.draw do
  namespace :admin do
    resources :api_keys
    resources :participants
    resources :survey_responses
    resources :users

    root to: "participants#index"
  end
  namespace :api do
    namespace :v1 do
      defaults format: :json do
        resources :participants
      end
    end
  end
  root "participants#index"
  resources :participants do
    resources :survey_responses
  end
  resources :api_keys, path: 'api-keys', only: %i[index create destroy]
end
