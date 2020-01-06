# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    name { 'A-Game' }

    association :creating_user, factory: :user
  end

  factory :piece do
    x_position { 1 }
    y_position { 1 }

    association :game
  end

  factory :queen, parent: :piece, class: 'Queen' do
  end

  factory :knight, parent: :piece, class: 'Knight' do
  end

  factory :pawn, parent: :piece, class: 'Pawn' do
  end

  factory :pawn, parent: :piece, class: 'Bishop' do    
  end

  factory :user do
    sequence(:email, 1000) { |n| "person#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end
  
end
