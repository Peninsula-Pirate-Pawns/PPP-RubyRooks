class King < Piece
  def valid_move?(new_x, new_y)
    x_distance = (x_position - new_x).abs
    y_distance = (y_position - new_y).abs

    (x_distance == 0 && y_distance == 1) ||
      (x_distance == 1 && y_distance == 0) ||
      (x_distance == 1 && y_distance == 1)
  end
end
