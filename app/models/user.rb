# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook twitter google]

  has_many :created_games, :class_name => 'Game', :foreign_key => 'creating_user_id'
  has_many :invited_games, :class_name => 'Game', :foreign_key => 'invited_user_id'
  has_many :first_moves, :class_name => 'Game', :foreign_key => 'first_move_id'
  has_many :wins, :class_name => 'Game', :foreign_key => 'winner_id'
  has_many :comments
  has_many :moves

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      auth.provider == 'twitter' ? user.email = "#{auth.info.nickname}@twitter.com" : user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end
end
