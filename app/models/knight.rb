# frozen_string_literal: true

class Knight < Piece
  def valid_move?(new_x, new_y)
    return false if players_own_piece_is_there?(new_x, new_y)
    
    x_distance = (new_x - x_position).abs
    y_distance = (new_y - y_position).abs

    x_distance == 1 && y_distance == 2 || x_distance == 2 && y_distance == 1
  end
end
