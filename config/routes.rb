# == Route Map
#
require 'sidekiq/web'
# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  namespace :admin do
    get '/signup/:invite_code' => 'invites#new_invite', as: 'redeem_invitation'
    post '/signup/:invite_code' => 'invites#redeem_invite', as: 'redeem_invite'
  end

  constraints Clearance::Constraints::SignedIn.new(&:admin?) do
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
    mount Sidekiq::Web, at: '/admin/sidekiq', as: 'sidekiq'
    ActiveAdmin.routes(self)
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :participants do
        collection do
          post '/verify' => 'participants#verify', as: 'verify'
          put '/amend' => 'participants#amend', as: 'amend'
          post '/check' => 'participants#check_resume_code', as: 'check'
          put '/update_and_resend' => 'participants#update_and_resend', as: 'update_and_resend'
        end
      end
      resources :survey_responses do
        collection do
          put '/amend' => 'survey_responses#amend', as: 'amend'
          post '/safety' => 'survey_responses#safety', as: 'safety'
        end
      end
      resources :consents, only: [:create]
    end
  end

  root 'landing#index'
  resources :participants, only: [:index] do
    collection do
      get '/eligible_sgm_stats' => 'participants#eligible_sgm_stats'
      get '/ineligible_sgm_stats' => 'participants#ineligible_sgm_stats'
      get '/grouped' => 'participants#grouped'
      get '/blank_stats' => 'participants#blank_stats'
      get '/weekly_participants' => 'participants#weekly_participants'
      get '/sources' => 'participants#sources'
      get '/timeline' => 'participants#timeline'
    end
  end
  resources :survey_responses, only: [] do
    collection do
      get '/baselines' => 'survey_responses#baselines'
      get '/progress' => 'survey_responses#progress'
      get '/mobilizers' => 'survey_responses#mobilizers'
    end
  end
end
