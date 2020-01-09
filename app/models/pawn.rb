# frozen_string_literal: true

class Pawn < Piece
  def valid_move?(new_x,new_y)
    if is_obstructed?(new_x, new_y)
      return false
    end

    if diagonal_capture(new_x, new_y)
      return true
    end

    x_distance = new_x - x_position
    y_distance = new_y - y_position

    if y_distance != 0
      return false
    end

    if is_white? and x_position == 1 # Allows two space move on first move of white pawn
      return x_distance == 2 || x_distance == 1 
    elsif !is_white? and x_position == 6 # Allows two space move on first move of black pawn
      return x_distance == -2 || x_distance == -1
    elsif is_white?
      return x_distance == 1 
    elsif !is_white?
      return x_distance == -1
    else
      return false
    end
  end

  def diagonal_capture(new_x,new_y)
    x_distance = new_x - x_position
    y_distance = new_y - y_position

    return false if y_distance.abs != 1

    if is_white? && x_distance == 1 || !is_white? && x_distance == -1
      targets = game.pieces.find do |piece|
        piece.x_position == new_x && piece.y_position == new_y
      end

      return targets.present?
    end
  end
end
