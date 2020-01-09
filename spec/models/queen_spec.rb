require 'rails_helper'

RSpec.describe Queen, type: :model do
  describe 'valid_move? for the queen' do
    before(:each) do
      @queen = create(:queen, x_position: 3, y_position: 4)
    end

    it 'allows the queen to move multiple spaces horizontally' do
      expect(@queen.valid_move?(7, 4)).to be true
    end

    it 'allows the queen to move multiple spaces horizontally' do
      expect(@queen.valid_move?(0, 4)).to be true
    end

    it 'allows the queen to move multiple spaces vertically' do
      expect(@queen.valid_move?(3, 7)).to be true
    end

    it 'allows the queen to move multiple spaces vertically' do
      expect(@queen.valid_move?(3, 0)).to be true
    end

    it 'allows the queen to move multiple spaces diagonally' do
      expect(@queen.valid_move?(7, 0)).to be true
    end

    it 'allows the queen to move multiple spaces diagonally' do
      expect(@queen.valid_move?(6, 7)).to be true
    end

    it 'allows the queen to move multiple spaces diagonally' do
      expect(@queen.valid_move?(0, 1)).to be true
    end

    it 'allows the queen to move multiple spaces diagonally' do
      expect(@queen.valid_move?(0, 7)).to be true
    end

    it 'does not allow an L shaped move' do
      expect(@queen.valid_move?(5, 3)).to be false
    end

    it 'does not allow a random move' do
      expect(@queen.valid_move?(5, 7)).to be false
    end

    it 'does not allow an obstructed move' do
      game = create(:game)
      queen = create(:queen, x_position: 3, y_position: 4, game_id: game.id)
      piece = create(:piece, x_position: 4, y_position: 5, game_id: game.id)

      expect(queen.valid_move?(6, 7)).to be false
    end

    it 'does not allow a move to the original location' do
      queen = create(:queen, x_position: 3, y_position: 4, piece_number: 3)

      expect(queen.valid_move?(3, 4)).to be false
    end

    it 'does not allow a move to the original location' do
      queen = create(:queen, x_position: 3, y_position: 4, piece_number: 3)

      expect(queen.valid_move?(3,4)).to be false
    end
  end
end
