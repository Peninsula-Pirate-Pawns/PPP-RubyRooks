class PiecesController < ApplicationController
  before_action :authenticate_user!

  def update
    update_params

    flash.now[:alert] << 'Invalid move!' unless @piece.valid_move?(@x, @y)
    flash.now[:alert] << 'Not your piece!' unless current_player_controls_piece?(@piece)
    flash.now[:alert] << 'Not your turn!' unless current_players_turn?(@game)
    flash.now[:alert] << 'No second player!' unless game_has_two_players?(@game)
    flash.now[:alert] << 'This game ended in a draw!' if @game.state == 'Draw'
    if flash.now[:alert].empty?
      check_response = check_test(@piece, @x, @y)
      @piece.move_to!(@x, @y) 
      flash.now[:alert] << check_response if check_response
      check_response ? @game.write_attribute(:state, check_response) : @game.write_attribute(:state, nil)
      @game.save
    end
  end

  def castle
    piece = Piece.find(params[:piece_id])
    rook = Piece.find(params[:rook_id])
    piece.castle!(rook)
    redirect_to game_path(piece.game)
  end

  def promotion
    update_params

    return unless %w[Bishop Knight Queen Rook].include?(@promotion)

    white_promotions = { 'Bishop' => 2, 'Knight' => 1, 'Queen' => 3, 'Rook' => 0 }
    black_promotions = { 'Bishop' => 8, 'Knight' => 7, 'Queen' => 9, 'Rook' => 6 }

    @piece.is_white? ? number = white_promotions[@promotion] : number = black_promotions[@promotion]
    @piece.update(type: @promotion, piece_number: number)
  end

  private

  def piece_params
    params.require(:piece).permit(:x_position, :y_position)
  end

  def update_params
    @piece = Piece.find(params[:id])
    @game = Game.find(@piece.game_id)
    @x = params[:x_position].to_i
    @y = params[:y_position].to_i
    @promotion = params[:promotion]
    flash.now[:alert] = []
  end

  def current_player_controls_piece?(piece)
    piece.is_white? && piece.game.player_one == current_user ||
      !piece.is_white? && piece.game.player_two == current_user
  end

  def current_players_turn?(game)
    last_piece_moved = game.pieces.order('updated_at').last.moves.order('updated_at').last
    return true if last_piece_moved.nil? && game.player_one == current_user
    return false if last_piece_moved.nil?
    return true if game.player_one == current_user && last_piece_moved.start_piece > 5
    return true if game.player_two == current_user && last_piece_moved&.start_piece < 6
    return false
  end

  def game_has_two_players?(game)
    return !game.player_one.nil? && !game.player_two.nil?
  end

  def check_test(piece, x, y)
    return false if piece.can_take?(helpers.get_piece(x, y, piece.game)) && piece.type == 'King'
    return false if piece.can_take?(helpers.get_piece(x, y, piece.game)) && !piece.puts_self_in_check?(x, y)

    if piece.puts_self_in_check?(x, y)
      flash.now[:alert] << 'You cannot put/leave yourself in Check.'
      return false
    end

    return false unless piece.puts_enemy_in_check?(x, y)

    current_user.id == piece.game.p1_id ? 'Black King in Check.' : 'White King in Check.'
  end

  def can_castle? 
    piece = Piece.find(params[:piece_id])
    rook = Piece.find(params[:rook_id])
    if !piece.can_castle?(rook)
      redirect_to game_path(piece.game), alert: "You can not Castle at this time!"
    end

    if piece.is_white? && piece.game.player_one != current_user || !piece.is_white? && piece.game.player_two != current_user
      redirect_to game_path(piece.game), alert: "That is not your piece!"
    end
  end
end
