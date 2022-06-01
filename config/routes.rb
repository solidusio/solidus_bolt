# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :bolt, only: [:show, :edit, :update]
    resource :bolt_webhook, only: [:new, :create]
  end

  post '/webhooks/bolt', to: '/solidus_bolt/webhooks#update'
end
