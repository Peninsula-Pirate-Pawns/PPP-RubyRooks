# frozen_string_literal: true

class Game < ApplicationRecord
  belongs_to :creating_user, :class_name => 'User', :foreign_key => 'creating_user_id'
  belongs_to :invited_user, :class_name => 'User', :foreign_key => 'invited_user_id', optional: true
  belongs_to :first_move, :class_name => 'User', :foreign_key => 'first_move_id', optional: true
  belongs_to :winner, :class_name => 'User', :foreign_key => 'winner_id', optional: true
  has_many :moves
  has_many :comments
  has_many :pieces

  scope :available, -> { where(invited_user_id: nil) }

end
