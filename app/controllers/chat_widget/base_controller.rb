module ChatWidget
  class BaseController < ApplicationController
    def friends
      friends = current_user.friends.order(:display_name, :email)
      data = friends.map do |f|
        unread = current_user.received_messages.where(sender: f, read_at: nil).count
        { id: f.id, display_name: f.display_name, email: f.email, unread_count: unread }
      end
      render json: data
    end

    def conversation
      friend = current_user.friends.find_by(id: params[:friend_id])
      return render json: [], status: :not_found unless friend

      messages = Message.conversation_between(current_user, friend)
                        .includes(:sender)
                        .order(:created_at)
                        .last(50)

      stream_name = Message.dm_stream_name(current_user, friend)
      signed = Turbo::StreamsChannel.signed_stream_name(stream_name)

      render json: {
        signed_stream_name: signed,
        messages: messages.map { |m|
          { id: m.id, sender_name: m.sender.display_name,
            sender_id: m.sender_id, content: m.content,
            created_at: m.created_at.strftime("%Y-%m-%d %H:%M") }
        }
      }
    end

    def mark_read
      friend = current_user.friends.find_by(id: params[:friend_id])
      return head :not_found unless friend

      current_user.received_messages.where(sender: friend, read_at: nil)
                  .update_all(read_at: Time.current)
      remaining = current_user.received_messages.where(read_at: nil).count
      render json: { unread_count: remaining }
    end
  end
end
