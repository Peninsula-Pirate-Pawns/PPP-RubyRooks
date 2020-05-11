# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# For working with Pawn Promotion bugs
Game.create(id: 9000, name: 'Pawn Promotion Seed', creating_user_id: 1)

0.upto(7) do |num|
  Pawn.create(piece_number: 11, x_position: 1, y_position: num, game_id: 9000, type: 'Pawn', moved: true)
end

0.upto(7) do |num|
  Pawn.create(piece_number: 5, x_position: 6, y_position: num, game_id: 9000, type: 'Pawn', moved: true)
end

# For working with Pawn Promotion and Checkmate bug
Game.create(id: 9001, name: 'Pawn Promo + Checkmate Seed', creating_user_id: 1)
Pawn.create(piece_number: 11, x_position: 1, y_position: 0, game_id: 9001, type: 'Pawn', moved: true)
King.create(piece_number: 4, x_position: 0, y_position: 4, game_id: 9001, type: 'King', moved: true)
Pawn.create(piece_number: 5, x_position: 6, y_position: 7, game_id: 9001, type: 'Pawn', moved: true)
King.create(piece_number: 10, x_position: 7, y_position: 3, game_id: 9001, type: 'King', moved: true)
