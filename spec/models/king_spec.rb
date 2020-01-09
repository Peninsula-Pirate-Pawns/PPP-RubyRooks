require 'rails_helper'

RSpec.describe King, type: :model do
  describe 'valid_move? for the king' do
    before(:each) do
      @king = create(:king, x_position: 4, y_position: 4)
    end

    it 'should test if horizontal moves are valid' do
      expect(@king.valid_move?(5, 4)).to eq true
    end

    it 'should test if vertical moves are valid' do
      expect(@king.valid_move?(4, 5)).to eq true
    end

    it 'should test if diagonal moves are valid' do
      expect(@king.valid_move?(5, 5)).to eq true
    end

    it 'should not allow horizontal movements greater than 1' do
      expect(@king.valid_move?(6, 4)).to eq false
    end

    it 'should not allow vertical movements greater than 1' do
      expect(@king.valid_move?(4, 6)).to eq false
    end

    it 'should not allow vertical movements greater than 1' do
      expect(@king.valid_move?(4, 2)).to eq false
    end

    it 'should not allow diagonal movements greater than 1' do
      expect(@king.valid_move?(6, 6)).to eq false
    end

    it 'should not allow move to tile with players piece' do
      game = create(:game)
      king = create(:king, x_position: 4, y_position: 4, piece_number: 4, game_id: game.id)
      piece = create(:king, x_position: 5, y_position: 5, piece_number: 5, game_id: game.id)

      expect(king.valid_move?(5,5)).to eq false
    end

    it 'should not allow move to original location' do
      king = create(:king, x_position: 4, y_position: 4, piece_number: 4)
      expect(king.valid_move?(4,4)).to eq false
    end
  end
end
