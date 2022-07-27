# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :bolt, only: [:show, :edit, :update]
    resource :bolt_webhook, only: [:new, :create]
    resource :bolt_callback_urls, only: [:new, :update]
  end

  post '/webhooks/bolt', to: '/solidus_bolt/webhooks#update'
  post '/api/accounts/bolt', to: '/solidus_bolt/accounts#create'

  devise_scope :spree_user do
    get '/bolt_logout', to: '/spree/user_sessions#destroy', as: 'bolt_logout'
  end
end
