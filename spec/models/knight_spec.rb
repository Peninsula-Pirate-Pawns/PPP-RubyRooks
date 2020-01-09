require 'rails_helper'

RSpec.describe Knight, type: :model do
  describe 'valid_move?' do
    context 'valid moves' do
      it 'allows a vertical move 2 up and 1 right' do
        knight = create(:knight, x_position: 0, y_position: 1, piece_number: 1)
        expect(knight.valid_move?(1, 3)).to eq true
      end

      it 'allows a vertical move 2 up and 1 left' do
        knight = create(:knight, x_position: 1, y_position: 1, piece_number: 1)
        expect(knight.valid_move?(0, 3)).to eq true
      end

      it 'allows a vertical move 2 down and 1 right' do
        knight = create(:knight, x_position: 0, y_position: 7, piece_number: 1)
        expect(knight.valid_move?(1, 5)).to eq true
      end

      it 'allows a vertical move 2 down and 1 left' do
        knight = create(:knight, x_position: 1, y_position: 7, piece_number: 1)
        expect(knight.valid_move?(0, 5)).to eq true
      end

      it 'allows a horizontal move 2 right and 1 up' do
        knight = create(:knight, x_position: 0, y_position: 1, piece_number: 1)
        expect(knight.valid_move?(2, 2)).to eq true
      end

      it 'allows a horizontal move 2 right and 1 down' do
        knight = create(:knight, x_position: 0, y_position: 1, piece_number: 1)
        expect(knight.valid_move?(2, 0)).to eq true
      end

      it 'allows a horizontal move 2 left and 1 up' do
        knight = create(:knight, x_position: 7, y_position: 1, piece_number: 1)
        expect(knight.valid_move?(5, 2)).to eq true
      end

      it 'allows a horizontal move 2 left and 1 down' do
        knight = create(:knight, x_position: 7, y_position: 1, piece_number: 1)
        expect(knight.valid_move?(5, 0)).to eq true
      end
    end

    context 'invalid moves' do
      it 'does not allow a vertical move up 3' do
        knight = create(:knight, x_position: 7, y_position: 1, piece_number: 1)
        expect(knight.valid_move?(7, 4)).to eq false
      end

      it 'does not allow a vertical down 2' do
        knight = create(:knight, x_position: 7, y_position: 6, piece_number: 1)
        expect(knight.valid_move?(7, 4)).to eq false
      end

      it 'does not allow a horizontal move right 3' do
        knight = create(:knight, x_position: 0, y_position: 1, piece_number: 1)
        expect(knight.valid_move?(3, 1)).to eq false
      end

      it 'does not allow a horizontal move left 3' do
        knight = create(:knight, x_position: 7, y_position: 1, piece_number: 1)
        expect(knight.valid_move?(4, 1)).to eq false
      end

      it 'does not allow a diagonal move up and right 3' do
        knight = create(:knight, x_position: 0, y_position: 0, piece_number: 1)
        expect(knight.valid_move?(3, 3)).to eq false
      end

      it 'does not allow a move to a tile occupied by players piece' do
        game = create(:game)
        knight = create(:knight, x_position: 7, y_position: 1, piece_number: 1, game_id: game.id)
        piece = create(:piece, x_position: 5, y_position: 0, piece_number: 3, game_id: game.id)

        expect(knight.valid_move?(6, 6)).to eq false
      end

      it 'does not allow a move to original tile' do
        knight = create(:knight, x_position: 7, y_position: 1, piece_number: 1)

        expect(knight.valid_move?(7, 1)).to eq false
      end
    end
  end
end
