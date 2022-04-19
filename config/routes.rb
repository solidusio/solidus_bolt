# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :bolt, only: [:show, :edit, :update]
  end
end
