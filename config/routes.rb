# == Route Map
#
require 'sidekiq/web'
# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  namespace :admin do
    get '/signup/:invite_code' => 'invites#new_invite', as: 'redeem_invitation'
    post '/signup/:invite_code' => 'invites#redeem_invite', as: 'redeem_invite'
    get '/opt_out/:code' => 'participants#opt_out', as: 'opt_out'
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
        member do
          get '/referrer' => 'participants#referrer', as: 'referrer'
          get '/recruitment' => 'participants#recruitment', as: 'recruitment'
        end
        collection do
          post '/verify' => 'participants#verify', as: 'verify'
          post '/check' => 'participants#check', as: 'check'
          post '/referrer_check' => 'participants#referrer_check', as: 'referrer_check'
          put '/amend' => 'participants#amend', as: 'amend'
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
    end
  end
  resources :survey_responses, only: [] do
    collection do
      get '/baselines' => 'survey_responses#baselines'
      get '/progress' => 'survey_responses#progress'
      get '/mobilizers' => 'survey_responses#mobilizers'
      get '/agencies' => 'survey_responses#agencies'
      get '/sources' => 'survey_responses#sources'
      get '/timeline' => 'survey_responses#timeline'
    end
  end
end
# rubocop:enable Metrics/BlockLength
