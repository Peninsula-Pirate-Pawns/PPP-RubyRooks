require 'rails_helper'

RSpec.describe Piece, type: :model do
  context 'Validation test' do
    it 'is valid with valid attributes' do
      user = create(:user)
      sign_in user
      expect(create(:piece)).to be_valid
    end
  end

  describe 'piece is_obstructed? method' do
    before(:each) do
      @game = create(:game)
    end

    it 'returns true if obstructed vertically' do
      piece_one = create(:piece, x_position: 0, y_position: 4, game_id: @game.id)
      piece_two = create(:piece, x_position: 0, y_position: 5, game_id: @game.id)

      expect(piece_one.is_obstructed?(0, 6)).to eq true
    end

    it 'returns false if not obstructed vertically' do
      piece_one = create(:piece, x_position: 0, y_position: 4, game_id: @game.id)
      piece_two = create(:piece, x_position: 0, y_position: 7, game_id: @game.id)

      expect(piece_one.is_obstructed?(0, 6)).to eq false
    end

    it 'returns true if obstructed horizontally' do
      piece_one = create(:piece, x_position: 0, y_position: 4, game_id: @game.id)
      piece_two = create(:piece, x_position: 2, y_position: 4, game_id: @game.id)

      expect(piece_one.is_obstructed?(4, 4)).to eq true
    end

    it 'returns false if not obstructed horizontally' do
      piece_one = create(:piece, x_position: 0, y_position: 4, game_id: @game.id)
      piece_two = create(:piece, x_position: 2, y_position: 4, game_id: @game.id)

      expect(piece_one.is_obstructed?(1, 4)).to eq false
    end

    it 'returns true if obstructed diagonally' do
      piece_one = create(:piece, x_position: 1, y_position: 1, game_id: @game.id)
      piece_two = create(:piece, x_position: 2, y_position: 2, game_id: @game.id)

      expect(piece_one.is_obstructed?(3, 3)).to eq true
    end

    it 'returns false if not obstructed diagonally' do
      piece_one = create(:piece, x_position: 1, y_position: 1, game_id: @game.id)
      piece_two = create(:piece, x_position: 3, y_position: 3, game_id: @game.id)

      expect(piece_one.is_obstructed?(2, 2)).to eq false
    end

    it 'returns true if destination contains piece of the same color(white)' do
      piece_one = create(:piece, x_position: 1, y_position: 1, piece_number: 5, game_id: @game.id)
      piece_two = create(:piece, x_position: 2, y_position: 2, piece_number: 5, game_id: @game.id)

      expect(piece_one.is_obstructed?(2, 2)).to eq true
    end

    it 'returns true if destination contains piece of the same color(black)' do
      piece_one = create(:piece, x_position: 1, y_position: 1, piece_number: 11, game_id: @game.id)
      piece_two = create(:piece, x_position: 2, y_position: 2, piece_number: 11, game_id: @game.id)

      expect(piece_one.is_obstructed?(2, 2)).to eq true
    end

    it 'returns false if destination contains piece of the opposite color' do
      piece_one = create(:piece, x_position: 1, y_position: 1, piece_number: 5, game_id: @game.id)
      piece_two = create(:piece, x_position: 2, y_position: 2, piece_number: 11, game_id: @game.id)

      expect(piece_one.is_obstructed?(2, 2)).to eq false
    end

    it 'returns true if destination is the original location' do
      piece_one = create(:piece, x_position: 1, y_position: 1, piece_number: 5, game_id: @game.id)

      expect(piece_one.is_obstructed?(1, 1)).to eq true
    end
  end

  describe 'move_to!() method' do
    before(:each) do
      @game = create(:game)
    end

    it 'updates moving piece(white) position and occupying piece(black) position if they are different colors' do
      piece_one = create(:piece, x_position: 1, y_position: 1, piece_number: 1, game_id: @game.id)
      piece_two = create(:piece, x_position: 3, y_position: 3, piece_number: 7, game_id: @game.id)

      piece_one.move_to!(3, 3)
      piece_two.reload

      expect(piece_one.x_position).to eq 3
      expect(piece_one.y_position).to eq 3
      expect(piece_two.x_position).to eq 8
      expect(piece_two.y_position).to eq 0
    end

    it 'updates moving piece(black) position and occupying piece(white) position if they are different colors' do
      piece_one = create(:piece, x_position: 1, y_position: 1, piece_number: 7, game_id: @game.id)
      piece_two = create(:piece, x_position: 3, y_position: 3, piece_number: 1, game_id: @game.id)

      piece_one.move_to!(3, 3)
      piece_two.reload

      expect(piece_one.x_position).to eq 3
      expect(piece_one.y_position).to eq 3
      expect(piece_two.x_position).to eq 9
      expect(piece_two.y_position).to eq 0
    end

    it 'updates position if there is no occupying piece' do
      piece = create(:piece, x_position: 1, y_position: 1, piece_number: 0, game_id: @game.id)

      piece.move_to!(4, 4)

      expect(piece.x_position).to eq 4
      expect(piece.y_position).to eq 4
    end
  end
end
