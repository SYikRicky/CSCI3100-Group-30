class ChatroomsController < ApplicationController
  def index
    @friends = current_user.friends.order(:display_name, :email)
    @selected_friend = load_selected_friend
    @messages = if @selected_friend
      Message.conversation_between(current_user, @selected_friend).includes(:sender, :receiver).order(:created_at)
    else
      Message.none
    end
    @dm_stream = @selected_friend && Message.dm_stream_name(current_user, @selected_friend)
  end

  private

  def load_selected_friend
    return if params[:friend_id].blank?

    @friends.find_by(id: params[:friend_id])
  end
end
