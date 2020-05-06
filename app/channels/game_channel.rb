# frozen_string_literal: true

class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_channel_user_#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
