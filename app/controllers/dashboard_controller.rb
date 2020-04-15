# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!, only: %i[index]

  def index
    @games = Game.all
    if current_user
      @created = Game.where(creating_user_id: current_user.id)
      @joined = Game.where(invited_user_id: current_user.id)
      @wins = current_user.wins
    end
  end
end
