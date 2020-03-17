# frozen_string_literal: true

class Piece < ApplicationRecord
  belongs_to :game
  has_many :moves, dependent: :destroy

  def is_obstructed?(x, y)
    x_sorted_array = [x, x_position].sort
    y_sorted_array = [y, y_position].sort

    if players_own_piece_is_there?(x, y)
      return true
    elsif x - x_position == 0 then
      return horizontal_obstruction?(x, y, x_sorted_array, y_sorted_array)
    elsif y - y_position == 0 then
      return vertical_obstruction?(x, y, x_sorted_array, y_sorted_array)
    elsif (x - x_position).abs == (y - y_position).abs then
      return diagonal_obstruction?(x, y, x_sorted_array, y_sorted_array)
    else
      return true
    end
  end

  def horizontal_obstruction?(x, y, x_sorted_array, y_sorted_array)
    obstructions = game.pieces.find do |chess_piece|
      is_on_same_rank = x == chess_piece.x_position
      is_between_y = chess_piece.y_position.between?(y_sorted_array[0] + 1, y_sorted_array[1] - 1)
      is_on_same_rank && is_between_y
    end
    return obstructions.present?
  end

  def vertical_obstruction?(x, y, x_sorted_array, y_sorted_array)
    obstructions = game.pieces.find do |chess_piece|
      is_on_same_file = y == chess_piece.y_position
      is_between_x = chess_piece.x_position.between?(x_sorted_array[0] + 1, x_sorted_array[1] - 1)
      is_on_same_file && is_between_x
    end
    return obstructions.present?
  end

  def diagonal_obstruction?(x, y, x_sorted_array, y_sorted_array)
    obstructions = game.pieces.find do |chess_piece|
      is_eq_abs = (x - chess_piece.x_position).abs == (y - chess_piece.y_position).abs
      is_between_x = chess_piece.x_position.between?(x_sorted_array[0] + 1, x_sorted_array[1] - 1)
      is_between_y = chess_piece.y_position.between?(y_sorted_array[0] + 1, y_sorted_array[1] - 1)

      is_eq_abs && is_between_x && is_between_y
    end
    return obstructions.present?
  end

  def players_own_piece_is_there?(x, y)
    occupying_piece = Piece.where(x_position: x, y_position: y, game_id: game.id)
    if occupying_piece.any? then
      return occupying_piece.first.is_white? == is_white?
    else
      false
    end
  end

  def move_to!(x, y)
    occupying_piece = Piece.where(x_position: x, y_position: y, game_id: game.id)
    occupying_piece.first&.set_captured!

    if type == 'Pawn'
      last_piece_moved = game.pieces.order('updated_at').last

      if en_passant?(x, y) then
        last_piece_moved.set_captured!
      end
    end

    create_move(x, y)
    assign_attributes(x_position: x, y_position: y, moved: true)
    save
  end

  def en_passant?(x, y)
    last_move = game.pieces.order('updated_at').last.moves.order('updated_at').last
    return false if last_move.nil?
    return true  if pawn_moved_through_capture(x, y, last_move)
    return false
  end

  def pawn_moved_through_capture(x, y, last_move)
    pawn_moved_two = (last_move.start_x - last_move.final_x).abs == 2
    if last_move.start_piece == 5 && piece_number == 11 # White pawn moved past black pawn
      return pawn_moved_two && x == 2 && y == last_move.final_y
    elsif last_move.start_piece == 11 && piece_number == 5# Black pawn moved past white pawn
      return pawn_moved_two && x == 5 && y == last_move.final_y
    else
      return false
    end
  end

  def set_captured! # TODO: Maybe should add a column to table that states whether a piece is captured
    if is_white?
      assign_attributes(x_position: 9, y_position: 0)
    else
      assign_attributes(x_position: 8, y_position: 0)
    end

    save
  end

  def create_move(x, y)
    moves.create(game_id: game.id, user_id: user_id, start_piece: piece_number, start_x: x_position, start_y: y_position, final_x: x, final_y: y)
  end

  def user_id
    if is_white?
      return game.p1_id
    else
      return game.p2_id
    end
  end

  def can_take?(piece)
    return if piece == nil

    valid_move?(piece.x_position, piece.y_position) &&
      (is_white? != piece.is_white?)
  end

  def puts_self_in_check?(x, y)
    previous_attributes = attributes
    begin
      enemy = get_piece(x, y, game)
      if enemy.present?
        enemy_attributes = enemy.attributes
        enemy.update(x_position: 100, y_position: 100)
      end
      update(x_position: x, y_position: y)
      game.pieces.reload
      game.check?(is_white?)
    ensure
      enemy&.update(enemy_attributes)
      update(previous_attributes)
      game.pieces.reload
    end
  end

  def puts_enemy_in_check?(x, y)
    previous_attributes = attributes

    begin
      update(x_position: x, y_position: y)
      game.pieces.reload
      game.check?(!is_white?)
    ensure
      update(previous_attributes)
      game.pieces.reload
    end
  end

  def get_piece(x, y, game)
    game.pieces.where(x_position: x, y_position: y).first
  end

  def can_castle?(rook)
    x_sorted_array = [rook.x_position, x_position].sort
    y_sorted_array = [rook.y_position, y_position].sort

    if !players_turn_and_pieces?(rook) ||
       moved? ||
       game.pieces.where(x_position: rook.x_position, y_position: rook.y_position).first.moved? ||
       horizontal_obstruction?(rook.x_position, rook.y_position, x_sorted_array, y_sorted_array) ||
       opponent_pieces.any? { |piece| piece.can_take?(self) } ||
       rook.y_position == 0 && [1, 2].any? { |number| moves_into_check?(x_position, y_position - number) } ||
       rook.y_position == 7 && [1, 2].any? { |number| moves_into_check?(x_position, y_position + number) }
      return false
    end

    return true
  end

  def players_turn_and_pieces?(rook)
    last_piece_moved = game.pieces.order('updated_at').last.moves.order('updated_at').last
    if last_piece_moved.present?
      last_piece_moved_was_black = last_piece_moved.start_piece > 5
      return last_piece_moved_was_black && is_white? && rook.is_white? || !last_piece_moved_was_black && !is_white? && !rook.is_white?
    end
    return false
  end

  def moves_into_check?(x, y)
    return opponent_pieces.any? { |piece| piece.valid_move?(x, y) }
  end

  def opponent_pieces
    if is_white?
      game.pieces.where('piece_number > 5')
    else
      game.pieces.where('piece_number < 6')
    end
  end

  def castle!(rook)
    if is_white? and rook.y_position == 0
      rook.create_move(0, 3)
      rook.assign_attributes(y_position: 3, moved: true)
      rook.save
      create_move(0, 2)
      assign_attributes(y_position: 2, moved: true)
      save
    elsif is_white? and rook.y_position == 7
      rook.create_move(0, 5)
      rook.assign_attributes(y_position: 5, moved: true)
      rook.save
      create_move(0, 6)
      assign_attributes(y_position: 6, moved: true)
      save
    elsif !is_white? and rook.y_position == 0
      rook.create_move(7, 3)
      rook.assign_attributes(y_position: 3, moved: true)
      rook.save
      create_move(7, 2)
      assign_attributes(y_position: 2, moved: true)
      save
    else
      rook.create_move(7, 5)
      rook.assign_attributes(y_position: 5, moved: true)
      rook.save
      create_move(7, 6)
      assign_attributes(y_position: 6, moved: true)
      save
    end
  end
end
