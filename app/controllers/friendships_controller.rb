class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @friends          = current_user.friends
    @pending_requests = current_user.pending_received_requests.includes(:user)
  end

  def create
    friend = User.find_by(email: params[:identifier]) ||
             User.find_by(display_name: params[:identifier])

    if friend.nil?
      redirect_to friendships_url, alert: "User not found." and return
    end

    friendship = Friendship.new(user: current_user, friend: friend)

    if friendship.save
      redirect_to friendships_url, notice: "Friend request sent to #{friend.display_name}."
    else
      redirect_to friendships_url, alert: friendship.errors.full_messages.to_sentence
    end
  end

  def update
    friendship = current_user.received_friendships.find(params[:id])
    friendship.accepted!
    redirect_to friendships_url, notice: "Friend request accepted."
  end

  def destroy
    friendship = Friendship.where(user: current_user)
                           .or(Friendship.where(friend: current_user))
                           .find(params[:id])
    friendship.destroy!
    redirect_to friendships_url, notice: "Friend removed."
  end
end
