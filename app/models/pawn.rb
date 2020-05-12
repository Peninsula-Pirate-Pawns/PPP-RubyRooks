# frozen_string_literal: true
class Pawn < Piece
  
  def valid_move?(x, y)
    delta_x = x - x_position
    delta_y = y - y_position
    return false if is_reverse?(x, y)
    return false if is_obstructed?(x, y)
    return true  if diagonal_capture?(x, y)
    return true  if en_passant?(x, y)
    return false if delta_y != 0 # restrict movement along the x-axis
    return false if tile_is_occupied?(x, y)
    return true  if can_move_two?(x, y)
    return true  if delta_x.abs == 1 
    return false
  end

  def is_reverse?(x, y)
    delta_x = x - x_position
    delta_y = y - y_position
    return delta_x < 0 if is_white?
    return delta_x > 0 if not is_white?
  end

  def diagonal_capture?(x, y)
    delta_x = x - x_position
    delta_y = y - y_position
    return false if delta_y.abs != 1
    if is_white? && delta_x == 1 || !is_white? && delta_x == -1
      targets = game.pieces.find do |piece|
        piece.x_position == x && piece.y_position == y
      end
      return targets.present?
    end 
  end

  def tile_is_occupied?(x, y)
    return opponent_pieces.any? { |piece| piece.x_position == x && piece.y_position == y }
  end

  def can_move_two?(x, y)
    delta_x = (x - x_position).abs
    delta_y = (y - y_position).abs
    return delta_x <= 2 if (is_white? and x_position == 1) or (not is_white? and x_position == 6)
    return false
  end

  def promotable?
    return true if is_white? && x_position == 7
    return true if !is_white? && x_position == 0

    false
  end
end
