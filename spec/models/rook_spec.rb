require 'rails_helper'

RSpec.describe Rook, type: :model do
  describe 'valid_move? for the rook' do
    before(:each) do
      @rook = create(:rook, x_position: 2, y_position: 2)
    end

    it 'allows the rook to move multiple squares horizontally' do
      expect(@rook.valid_move?(7, 2)).to be true
    end

    it 'allows the rook to move multiple squares vertically' do
      expect(@rook.valid_move?(2, 4)).to be true
    end

    it 'should not allow the rook to move diagonally' do
      expect(@rook.valid_move?(1, 1)).to be false
    end

    it 'should not allow the rook to move like an L' do
      expect(@rook.valid_move?(3, 4)).to be false
    end

    it 'should not allow moves to tiles occupied with players piece' do
      game = create(:game)
      bishop = create(:rook, x_position: 4, y_position: 4, piece_number: 1, game_id: game.id)
      piece = create(:piece, x_position: 6, y_position: 6, piece_number: 3, game_id: game.id)

      expect(bishop.valid_move?(6, 6)).to eq false
    end

    it 'should not allow moves to original tile' do
      bishop = create(:rook, x_position: 4, y_position: 4, piece_number: 1)

      expect(bishop.valid_move?(4, 4)).to eq false
    end

    it 'checks for obstructions' do
      game = create(:game)
      rook = create(:rook, x_position: 2, y_position: 2, game_id: game.id)
      piece = create(:piece, x_position: 2, y_position: 3, game_id: game.id)

      expect(rook.valid_move?(2, 6)).to be false
    end
  end
end
