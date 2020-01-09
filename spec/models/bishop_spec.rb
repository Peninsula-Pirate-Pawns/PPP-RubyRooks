require 'rails_helper'

RSpec.describe Bishop, type: :model do
  describe 'valid_move? for the bishop' do
    before(:each) do
      @bishop = create(:bishop, x_position: 4, y_position: 4)
    end

    it 'should test if diagonal moves are valid' do
      expect(@bishop.valid_move?(5, 5)).to eq true
    end

    it 'should allow diagonal movements greater than 1' do
      expect(@bishop.valid_move?(6,6)).to eq true
    end

    it 'should not allow horizontal movements' do
      expect(@bishop.valid_move?(6, 4)).to eq false
    end

    it 'should not allow vertical movements' do
      expect(@bishop.valid_move?(4, 6)).to eq false
    end

    it 'should not allow moves to tiles occupied with players piece' do
      game = create(:game)
      bishop = create(:bishop, x_position: 4, y_position: 4, piece_number: 2, game_id: game.id)
      piece = create(:piece, x_position: 6, y_position: 6, piece_number: 3, game_id: game.id)

      expect(bishop.valid_move?(6,6)).to eq false
    end

    it 'should not allow moves to original tile' do
      bishop = create(:bishop, x_position: 4, y_position: 4, piece_number: 2)

      expect(bishop.valid_move?(4,4)).to eq false
    end

    it 'checks for obstructions' do
      game = create(:game)
      rook = create(:rook, x_position: 4, y_position: 4, game_id: game.id)
      piece = create(:piece, x_position: 5, y_position: 5, game_id: game.id)

      expect(rook.valid_move?(6, 6)).to be false
    end
  end
end
