# == Route Map
#

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :admin do
    resources :api_keys
    resources :participants
    resources :survey_responses
    resources :users
    resources :invites

    get '/send_invitation/:id' => 'invites#send_invitation', as: 'send_invitation'
    get '/signup/:invite_code' => 'invited_users#new', as: 'redeem_invitation'
    post '/signup/:invite_code' => 'invited_users#create', as: 'redeem_invite'

    root to: "participants#index"
  end
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :participants
    end
  end
  root "admin/participants#index"
end
