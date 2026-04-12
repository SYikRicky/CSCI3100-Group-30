class MessagesController < ApplicationController
  def create
    friend = current_user.friends.find_by(id: params[:chatroom_id])
    if friend.nil?
      redirect_to chatrooms_path, alert: "Friend not found." and return
    end

    @message = current_user.sent_messages.build(message_params.merge(receiver: friend))

    if @message.save
      stream = Message.dm_stream_name(current_user, friend)
      Turbo::StreamsChannel.broadcast_append_to(
        stream,
        target: "chat-messages",
        partial: "messages/message",
        locals: { message: @message }
      )
      Turbo::StreamsChannel.broadcast_append_to(
        stream,
        target: "chat-widget-messages",
        partial: "messages/widget_message",
        locals: { message: @message }
      )
      respond_to do |format|
        format.turbo_stream { head :no_content }
        format.html { redirect_to chatrooms_path(friend_id: friend.id) }
      end
    else
      redirect_to chatrooms_path(friend_id: friend.id), alert: @message.errors.full_messages.to_sentence
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
