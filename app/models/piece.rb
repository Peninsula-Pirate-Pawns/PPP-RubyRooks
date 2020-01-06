# frozen_string_literal: true

class Piece < ApplicationRecord
  belongs_to :game

  def is_obstructed?(x, y)
    x_sorted_array = [x, x_position].sort
    y_sorted_array = [y, y_position].sort
    obstructions = game.pieces.find do |chess_piece|
      next true if (x - chess_piece.x_position).abs == (y - chess_piece.y_position).abs &&
                   chess_piece.x_position.between?(x_sorted_array[0] + 1, x_sorted_array[1] - 1) &&
                   chess_piece.y_position.between?(y_sorted_array[0] + 1, y_sorted_array[1] - 1)
      next true if chess_piece.x_position.between?(x_sorted_array[0] + 1, x_sorted_array[1] - 1)
      chess_piece.y_position.between?(y_sorted_array[0] + 1, y_sorted_array[1] - 1)
    end
    return obstructions.present?
  end

  def move_to!(new_x, new_y)
    # Check if a piece is at this position
    if Piece.where(x_position: new_x, y_position: new_y, game_id: self.game.id)[0]
      occupying_piece = Piece.where(x_position: new_x, y_position: new_y, game_id: self.game.id)[0]

      # Check if the piece occupying the space is white(0-5) and the moving piece is black(6-11)
      if occupying_piece.piece_number > 5 && self.piece_number < 6
        occupying_piece.update(x_position: 8, y_position: 0)
        self.update(x_position: new_x, y_position: new_y)

      # Check if the piece occupying the space is black(6-11) and the moving piece is white(0-5)
      elsif occupying_piece.piece_number < 6 && self.piece_number > 5
        occupying_piece.update(x_position: 9, y_position: 0)
        self.update(x_position: new_x, y_position: new_y)
      else
        ActionDispatch::Flash.new(alert: 'You cannot move here.')
      end

    # If no piece in this position, update moving piece position to this position
    else
      self.update(x_position: new_x, y_position: new_y)
    end
  end

  

  def valid_move?
    if self.is_obstructed?(x, y) && @pieces_in_the_way.count > 1
      return false    
    elsif self.is_obstructed?(x, y) && @pieces_in_the_way.first.x_position != x && @pieces_in_the_way.first.y_position != y
      return false
    else
      true
    end
  end

end
