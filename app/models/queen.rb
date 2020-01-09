class Queen < Piece
  def valid_move?(new_x, new_y)
    return false if is_obstructed?(new_x, new_y)

    x_distance = (new_x - x_position).abs
    y_distance = (new_y - y_position).abs

    if y_distance == 0 # Horizontal Check
      return true
    elsif x_distance == 0 # Vertical Check
      return true
    elsif x_distance == y_distance # Diagonal Check
      return true
    else
      return false
    end
  end
end
