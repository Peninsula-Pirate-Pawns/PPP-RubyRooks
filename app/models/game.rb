# frozen_string_literal: true

class Game < ApplicationRecord
  has_one :creating_user, :class_name => 'User'
  has_one :invited_user, :class_name => 'User'
  has_one :first_move, :class_name => 'User'
  has_one :winner, :class_name => 'User'
  has_many :moves
  has_many :comments
  has_many :pieces

  scope :available, -> { where(creating_user_id: nil).or.where(invited_user_id: nil)}

end
