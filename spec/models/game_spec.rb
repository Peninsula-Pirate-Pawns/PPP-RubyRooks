# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  context 'creating a game' do
    it 'is valid' do
      user = create(:user)
      sign_in user
      expect(create(:game)).to be_valid
    end
  end

  context 'check? method' do
    describe 'white+black king and black+white rook' do
      before(:each) do
        user = create(:user)
        sign_in user
        @game = create(:game)
        @white_king = create(:king, x_position: 0, y_position: 0, piece_number: 3, game_id: @game.id)
        @black_king = create(:king, x_position: 7, y_position: 7, piece_number: 9, game_id: @game.id)
        @black_rook = create(:rook, x_position: 0, y_position: 4, piece_number: 6, game_id: @game.id)
        @white_rook = create(:rook, x_position: 6, y_position: 6, piece_number: 0, game_id: @game.id)
      end

      it 'should have game state in check (white king in check)' do
        @game.check?
      end

      it 'should have game state in check (black king in check)' do
        @white_rook.update(x_position: 6, y_position: 7)
        @game.check?
      end

      it 'should not have game state in check' do
        @black_rook.update(x_position: 1, y_position: 1)
        @game.check?
      end

      it 'should work with only one King on the board' do
        @white_king.destroy
        @white_rook.update(x_position: 6, y_position: 7)
        @game.check?
      end
    end
  end

end
