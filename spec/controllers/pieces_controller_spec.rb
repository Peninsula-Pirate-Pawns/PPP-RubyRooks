require 'rails_helper'

RSpec.describe PiecesController, type: :controller do
  describe 'pieces#update action' do
    before(:each) do
      @player1 = create(:user)
      @player2 = create(:user)
      @game = create(:game, name: 'Testerroni Pizza',
                     p1_id: @player1.id, p2_id: @player2.id,
                     creating_user_id: @player1.id, invited_user_id: @player2.id)
      @white_pawn = create(:pawn, x_position: 1, y_position: 0, piece_number: 5, game_id: @game.id)
      @black_pawn = create(:pawn, x_position: 6, y_position: 1, piece_number: 11, game_id: @game.id)
    end

    it 'should require users to be logged in' do
      game = create(:game)

      piece = create(:piece, game_id: game.id, piece_number: 5, x_position: 1, y_position: 7)

      patch :update, params: { id: piece.id, piece: {x_position: 3, y_position: 7}}
      expect(response).to redirect_to new_user_session_path
    end

    it 'should require two players' do
      user = create(:user)
      game = create(:game, creating_user_id: user.id)
      piece = create(:pawn, x_position: 1, y_position: 0, piece_number: 5, game_id: game.id)

      sign_in user

      put :update, params: { id: piece.id, x_position: 3, y_position: 0, format: :js }
      piece.reload
      expect(flash[:alert]).to eq ['No second player!']
      expect(piece.x_position).to eq 1
      expect(piece.y_position).to eq 0
    end

    it 'should not allow moves if game is in a state of draw' do
      player1 = create(:user)
      player2 = create(:user)
      game = create(:game, name: 'Testerroni Pizza',
        p1_id: player1.id, p2_id: player2.id,
        creating_user_id: player1.id, invited_user_id: player2.id, state: 'Draw')
      piece = create(:pawn, x_position: 1, y_position: 0, piece_number: 5, game_id: game.id)

      sign_in player1

      put :update, params: { id: piece.id, x_position: 3, y_position: 0, format: :js }
      piece.reload
      game.reload
      expect(flash[:alert]).to eq ['This game ended in a draw!']
      expect(piece.x_position).to eq 1
      expect(piece.y_position).to eq 0
      expect(game.state).to eq 'Draw'
    end

    it 'should not allow white players to move black pieces' do
      sign_in @player1

      put :update, params: { id: @black_pawn.id, x_position: 4, y_position: 1, format: :js }
      @black_pawn.reload
      expect(flash[:alert]).to eq ['Not your piece!']
      expect(@black_pawn.x_position).to eq 6
      expect(@black_pawn.y_position).to eq 1
    end

    it 'should not allow white players to move pieces on black players turn' do
      white_pawn = create(:pawn, x_position: 1, y_position: 2, piece_number: 5, game_id: @game.id)
      move = create(:move, game_id: @game.id, piece_id: white_pawn.id, start_piece: 5)

      sign_in @player1

      put :update, params: { id: @white_pawn.id, x_position: 3, y_position: 0, format: :js }
      @white_pawn.reload

      expect(@white_pawn.x_position).to eq 1
      expect(@white_pawn.y_position).to eq 0
    end

    it 'allows white players to move white pieces' do
      sign_in @player1

      put :update, params: { id: @white_pawn.id, x_position: 3, y_position: 0, format: :js }
      @white_pawn.reload
      expect(@white_pawn.x_position).to eq 3
      expect(@white_pawn.y_position).to eq 0
    end

    it 'checks for checkmate and ends the game for a white player' do
      black_king = create(:king, x_position: 4, y_position: 4, game_id: @game.id, piece_number: 10)
      white_queen = create(:queen, x_position: 1, y_position: 3, game_id: @game.id, piece_number: 3)
      white_rook1 = create(:rook, x_position: 0, y_position: 3, game_id: @game.id, piece_number: 0)
      white_rook2 = create(:rook, x_position: 6, y_position: 5, game_id: @game.id, piece_number: 0)
      white_rook3 = create(:rook, x_position: 3, y_position: 2, game_id: @game.id, piece_number: 0)
      white_rook4 = create(:rook, x_position: 5, y_position: 6, game_id: @game.id, piece_number: 0)

      sign_in @player1

      put :update, params: { id: white_queen.id, x_position: 3, y_position: 3, format: :js }
      white_queen.reload
      @game.reload
      expect(white_queen.x_position).to eq 3
      expect(white_queen.y_position).to eq 3
      expect(@game.winner).to eq @player1
    end

    it 'should not allow black players to move white pieces' do
      white_pawn = create(:pawn, x_position: 1, y_position: 2, piece_number: 5, game_id: @game.id)
      move = create(:move, game_id: @game.id, piece_id: white_pawn.id, start_piece: 5)

      sign_in @player2

      put :update, params: { id: @white_pawn.id, x_position: 3, y_position: 0, format: :js }

      expect(flash[:alert]).to eq ['Not your piece!']
      expect(@white_pawn.x_position).to eq 1
      expect(@white_pawn.y_position).to eq 0
    end

    it 'should not allow black players to move pieces on white players turn' do
      sign_in @player2

      put :update, params: { id: @black_pawn.id, x_position: 4, y_position: 1, format: :js }
      @black_pawn.reload
      expect(@black_pawn.x_position).to eq 6
      expect(@black_pawn.y_position).to eq 1
    end

    it 'allows black players to move black pieces' do
      white_pawn = create(:pawn, x_position: 1, y_position: 2, piece_number: 5, game_id: @game.id)
      move = create(:move, game_id: @game.id, piece_id: white_pawn.id, start_piece: 5)

      sign_in @player2

      put :update, params: { id: @black_pawn.id, x_position: 4, y_position: 1, format: :js }
      @black_pawn.reload
      expect(@black_pawn.x_position).to eq 4
      expect(@black_pawn.y_position).to eq 1
    end

    it 'checks for checkmate and ends the game for a black player' do
      white_king = create(:king, x_position: 0, y_position: 7, game_id: @game.id, piece_number: 4)
      black_queen = create(:queen, x_position: 6, y_position: 6, game_id: @game.id, piece_number: 9)
      black_rook = create(:rook, x_position: 1, y_position: 4, game_id: @game.id, piece_number: 6)
      white_pawn = create(:pawn, x_position: 1, y_position: 2, piece_number: 5, game_id: @game.id)
      move = create(:move, game_id: @game.id, piece_id: white_pawn.id, start_piece: 5)

      sign_in @player2

      put :update, params: { id: black_queen.id, x_position: 1, y_position: 6, format: :js }
      black_queen.reload
      @game.reload
      expect(black_queen.x_position).to eq 1
      expect(black_queen.y_position).to eq 6
      expect(@game.winner).to eq @player2
    end

    it 'puts game in check when black piece takes a white piece and puts white king in check' do
      white_king = create(:king, x_position: 0, y_position: 4, game_id: @game.id, piece_number: 4)
      white_pawn = create(:pawn, x_position: 0, y_position: 5, game_id: @game.id, piece_number: 5)
      black_rook = create(:rook, x_position: 0, y_position: 7, game_id: @game.id, piece_number: 6)

      sign_in @player2

      black_rook.move_to!(0, 5)
      white_pawn.reload
      black_rook.reload
      @game.reload

      expect(black_rook.x_position).to eq 0
      expect(black_rook.y_position).to eq 5
      expect(@game.check?(!black_rook.is_white?)).to eq true
    end
  end

  describe 'pieces#castle action' do
    it 'allows white player to castle queenside' do
      player1 = create(:user)
      player2 = create(:user)
      game = create(:game, name: 'Testerroni Pizza',
        p1_id: player1.id, p2_id: player2.id,
        creating_user_id: player1.id, invited_user_id: player2.id)

      sign_in player1

      white_king = create(:king, x_position: 0, y_position: 4, piece_number: 4, game_id: game.id)
      white_queenside_rook = create(:rook, x_position: 0, y_position: 0, piece_number: 0, game_id: game.id)

      get :castle, params: { piece_id: white_king.id, rook_id: white_queenside_rook.id}, xhr: true

      white_king.reload
      white_queenside_rook.reload

      expect(white_king.x_position).to eq 0
      expect(white_king.y_position).to eq 2
      expect(white_king.moved).to eq true
      expect(white_queenside_rook.x_position).to eq 0
      expect(white_queenside_rook.y_position).to eq 3
      expect(white_queenside_rook.moved).to eq true
    end
  end

  describe 'pieces#promotion' do
    it 'promotes a White Pawn to a White Queen' do
      game = create(:game)

      sign_in game.player_one

      white_pawn = create(:pawn, x_position: 7, y_position: 4, piece_number: 5, game_id: game.id)
      expect(white_pawn.promotable?).to eq true

      put :promotion, params: { piece_id: white_pawn.id, id: white_pawn.id, promotion: 'Queen',
                                x_position: white_pawn.x_position, y_position: white_pawn.y_position, format: :js }

      promoted_pawn = Piece.find(white_pawn.id)

      expect(promoted_pawn.type).to eq 'Queen'
      expect(promoted_pawn.id).to eq white_pawn.id
      expect(promoted_pawn.x_position).to eq 7
      expect(promoted_pawn.y_position).to eq 4
      expect(promoted_pawn.piece_number).to eq 3
      expect(promoted_pawn.valid_move?(0, 4)).to eq true
    end

    it 'promotes a White Pawn to a White Rook' do
      game = create(:game)

      sign_in game.player_one

      white_pawn = create(:pawn, x_position: 7, y_position: 4, piece_number: 5, game_id: game.id)
      expect(white_pawn.promotable?).to eq true

      put :promotion, params: { piece_id: white_pawn.id, id: white_pawn.id, promotion: 'Rook',
                                x_position: white_pawn.x_position, y_position: white_pawn.y_position, format: :js }

      promoted_pawn = Piece.find(white_pawn.id)

      expect(promoted_pawn.type).to eq 'Rook'
      expect(promoted_pawn.id).to eq white_pawn.id
      expect(promoted_pawn.x_position).to eq 7
      expect(promoted_pawn.y_position).to eq 4
      expect(promoted_pawn.piece_number).to eq 0
      expect(promoted_pawn.valid_move?(0, 4)).to eq true
    end

    it 'promotes a Black Pawn to a Black Knight' do
      game = create(:game)

      sign_in game.player_one

      black_pawn = create(:pawn, x_position: 0, y_position: 4, piece_number: 11, game_id: game.id)
      expect(black_pawn.promotable?).to eq true

      put :promotion, params: { piece_id: black_pawn.id, id: black_pawn.id, promotion: 'Knight',
                                x_position: black_pawn.x_position, y_position: black_pawn.y_position, format: :js }

      promoted_pawn = Piece.find(black_pawn.id)

      expect(promoted_pawn.type).to eq 'Knight'
      expect(promoted_pawn.id).to eq black_pawn.id
      expect(promoted_pawn.x_position).to eq 0
      expect(promoted_pawn.y_position).to eq 4
      expect(promoted_pawn.piece_number).to eq 7
      expect(promoted_pawn.valid_move?(1, 6)).to eq true
    end

    it 'promotes a Black Pawn to a Black Bishop' do
      game = create(:game)

      sign_in game.player_one

      black_pawn = create(:pawn, x_position: 0, y_position: 4, piece_number: 11, game_id: game.id)
      expect(black_pawn.promotable?).to eq true

      put :promotion, params: { piece_id: black_pawn.id, id: black_pawn.id, promotion: 'Bishop',
                                x_position: black_pawn.x_position, y_position: black_pawn.y_position, format: :js }

      promoted_pawn = Piece.find(black_pawn.id)

      expect(promoted_pawn.type).to eq 'Bishop'
      expect(promoted_pawn.id).to eq black_pawn.id
      expect(promoted_pawn.x_position).to eq 0
      expect(promoted_pawn.y_position).to eq 4
      expect(promoted_pawn.piece_number).to eq 8
      expect(promoted_pawn.valid_move?(3, 7)).to eq true
    end

    it 'puts White King in check upon Black Pawn promotion' do
      game = create(:game)

      sign_in game.player_one

      black_pawn = create(:pawn, x_position: 0, y_position: 4, piece_number: 11, game_id: game.id)
      white_king = create(:king, x_position: 2, y_position: 6, piece_number: 4, game_id: game.id)

      put :promotion, params: { piece_id: black_pawn.id, id: black_pawn.id, promotion: 'Bishop',
                                x_position: black_pawn.x_position, y_position: black_pawn.y_position, format: :js }

      promoted_pawn = Piece.find(black_pawn.id)

      expect(promoted_pawn.puts_enemy_in_check?(0, 4)).to eq true
    end

    it 'puts Black King in check upon White Pawn promotion' do
      game = create(:game)

      sign_in game.player_one

      white_pawn = create(:pawn, x_position: 0, y_position: 4, piece_number: 5, game_id: game.id)
      black_king = create(:king, x_position: 0, y_position: 6, piece_number: 10, game_id: game.id)

      put :promotion, params: { piece_id: white_pawn.id, id: white_pawn.id, promotion: 'Rook',
                                x_position: white_pawn.x_position, y_position: white_pawn.y_position, format: :js }

      promoted_pawn = Piece.find(white_pawn.id)

      expect(promoted_pawn.puts_enemy_in_check?(0, 4)).to eq true
    end
  end
end
