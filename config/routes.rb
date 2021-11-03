# == Route Map
#
require 'sidekiq/web'
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web, at: '/admin/sidekiq', as: 'sidekiq'
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
      resources :participants do
        collection do
          post '/verify' => 'participants#verify', as: 'verify'
          put '/amend' => 'participants#amend', as: 'amend'
        end
      end
    end
  end
  root "admin/participants#index"
end
