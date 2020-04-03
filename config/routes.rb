# frozen_string_literal: true

Rails.application.routes.draw do
  get 'dashboard/index'
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  root 'games#index'

  resources :pieces, only: %i[show update] do
    get :castle
    get :reload
    put :promotion
  end

  resources :games, only: %i[index new create show] do
    get :update_invited_user, :surrender, :draw, :reload
  end

  mount ActionCable.server, at: '/cable'
end
