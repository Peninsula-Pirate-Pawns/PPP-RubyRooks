# frozen_string_literal: true

class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_channel_user_#{current_user.id}"
    stream_from 'game'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
