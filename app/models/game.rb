# frozen_string_literal: true

class Game < ApplicationRecord
  belongs_to :creating_user, :class_name => 'User', :foreign_key => 'creating_user_id'
  belongs_to :invited_user, :class_name => 'User', :foreign_key => 'invited_user_id', optional: true
  belongs_to :winner, :class_name => 'User', :foreign_key => 'winner_id', optional: true
  has_many :moves, dependent: :destroy 
  has_many :comments, dependent: :destroy
  has_many :pieces, dependent: :destroy
  before_create :assign_default_player
  scope :available, -> { where(invited_user_id: nil) }

  def assign_default_player
    write_attribute(:p1_id, creating_user.id)
  end

  def randomly_assign_players(current_user)
    other_player = creating_user
    if rand(1..1000) <= 500
      update(p1_id: other_player.id, p2_id: current_user.id)
    else
      update(p1_id: current_user.id, p2_id: other_player.id)
    end
  end

  def opponent(current_user)
    current_user.id == p1_id ? player_two : player_one
  end

  def player_one
    return nil if p1_id.nil?
    return User.find(p1_id)
  end

  def player_two
    return nil if p2_id.nil?
    return User.find(p2_id)
  end

  def player_one=(u)
    write_attribute(:p1_id, u.id)
  end

  def player_two=(u)
    write_attribute(:p2_id, u.id)
  end

  def get_player_one 
    return player_one.nil? ? "No Player One" : player_one.email
  end

  def get_player_two
    return player_two.nil? ? "No Player Two" : player_two.email
  end

  def check?(white)
    king = pieces_for_color(white).select { |piece| piece.type == 'King' }.first
    return false unless king

    enemies = get_enemies(king)
    enemies.any? { |enemy| enemy.can_take?(king) }
  end

  def pieces_for_color(white)
    pieces.select { |piece| piece.is_white? == white }
  end

  def checkmate?(white)
    return false unless check?(white)
    return false if legal_moves(white) 
    true
  end

  def end_game(piece)
    if piece.is_white?
      update(winner_id: p1_id)
    else
      update(winner_id: p2_id)
    end
  end

  def populate_game
    # White Rooks
    pieces.create(x_position: 0, y_position: 0, piece_number: 0, type: 'Rook')
    pieces.create(x_position: 0, y_position: 7, piece_number: 0, type: 'Rook')
    # White Knights
    pieces.create(x_position: 0, y_position: 1, piece_number: 1, type: 'Knight')
    pieces.create(x_position: 0, y_position: 6, piece_number: 1, type: 'Knight')
    # White Bishops
    pieces.create(x_position: 0, y_position: 2, piece_number: 2, type: 'Bishop')
    pieces.create(x_position: 0, y_position: 5, piece_number: 2, type: 'Bishop')
    # White Queen
    pieces.create(x_position: 0, y_position: 3, piece_number: 3, type: 'Queen')
    # White King
    pieces.create(x_position: 0, y_position: 4, piece_number: 4, type: 'King')
    # White Pawns
    8.times do |y|
      pieces.create(x_position: 1, y_position: y, piece_number: 5, type: 'Pawn')
    end
    # Black Rooks
    pieces.create(x_position: 7, y_position: 0, piece_number: 6, type: 'Rook')
    pieces.create(x_position: 7, y_position: 7, piece_number: 6, type: 'Rook')
    # Black Knights
    pieces.create(x_position: 7, y_position: 1, piece_number: 7, type: 'Knight')
    pieces.create(x_position: 7, y_position: 6, piece_number: 7, type: 'Knight')
    # Black Bishops
    pieces.create(x_position: 7, y_position: 2, piece_number: 8, type: 'Bishop')
    pieces.create(x_position: 7, y_position: 5, piece_number: 8, type: 'Bishop')
    # Black Queen
    pieces.create(x_position: 7, y_position: 3, piece_number: 9, type: 'Queen')
    # Black King
    pieces.create(x_position: 7, y_position: 4, piece_number: 10, type: 'King')
    # Black Pawns
    8.times do |y|
      pieces.create(x_position: 6, y_position: y, piece_number: 11, type: 'Pawn')
    end
  end

  def can_claim_draw?(current_user)
    return true if stalemate?(current_user)
    return true if threefold_repetition?
    return true if fifty_move_rule?
    return false
  end

  def stalemate?(current_user)
    return false if state == 'Black King in Check.'
    return false if state == 'White King in Check.'
    return false if enough_pieces_remaining(current_user.id == p1_id)
    return false if legal_moves(current_user.id == p1_id)
    return true
  end

  def legal_moves(white)
    legal_moves = []
    playable_pieces(white).each do |piece|
      8.times do |x|
        8.times do |y|
          next if !piece.valid_move?(x,y)
          next if piece.puts_self_in_check?(x,y)
          legal_moves << piece
        end
      end
    end
    return legal_moves.present?
  end

  def enough_pieces_remaining(white) # A check to not do legal moves if the player has enough remaining pieces
    return playable_pieces(white).count > 3
  end

  def playable_pieces(white)
    playable_pieces = []
    pieces_for_color(white).each do |piece|
      next if piece.x_position == 8 || piece.x_position == 9
      playable_pieces << piece 
    end
    return playable_pieces
  end

  def threefold_repetition? # This one has me beat for now
    return false
  end

  def fifty_move_rule?
    return false if moves.count <= 100
    # The limit is 100 since a move in our app is only one player but in chess is for each player
    last_fifty_moves = moves.order(updated_at: :desc).limit(100) 
    return false if pawn_was_moved?(last_fifty_moves)
    return false if piece_was_captured?(last_fifty_moves)
    return true 
  end

  def pawn_was_moved?(last_fifty_moves)
    pawn_moves = last_fifty_moves.find do |move|
      move.start_piece == 5 || move.start_piece == 11
    end

    return pawn_moves.present?
  end

  def piece_was_captured?(last_fifty_moves)
    last_white_player_capture = pieces.where(x_position: 8).order('updated_at').last
    last_black_player_capture = pieces.where(x_position: 9).order('updated_at').last
    # The if statements are to catch if the game has zero captures. A highly unlikely scenario but easy to fix.
    if last_white_player_capture && last_black_player_capture
      return true if last_fifty_moves.last.updated_at < last_white_player_capture.updated_at 
      return true if last_fifty_moves.last.updated_at < last_black_player_capture.updated_at
      return false
    end
    if last_white_player_capture 
      return true if last_fifty_moves.last.updated_at < last_white_player_capture.updated_at
      return false
    end
    if last_black_player_capture
      return true if last_fifty_moves.last.updated_at < last_black_player_capture.updated_at
      return false
    end
    return false
  end
end
