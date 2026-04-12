class IdeaLikesController < ApplicationController
  before_action :set_idea

  def create
    @like = @idea.idea_likes.find_or_initialize_by(user: current_user)
    @like.save if @like.new_record?

    respond_to do |format|
      format.turbo_stream { render_like_turbo_stream }
      format.html { redirect_to @idea }
    end
  end

  def destroy
    @like = @idea.idea_likes.find_by(user: current_user)
    @like&.destroy

    respond_to do |format|
      format.turbo_stream { render_like_turbo_stream }
      format.html { redirect_to @idea }
    end
  end

  private

  def set_idea
    @idea = Idea.find(params[:idea_id])
  end

  def render_like_turbo_stream
    render turbo_stream: turbo_stream.replace(
      "idea-like-#{@idea.id}",
      partial: "ideas/like_button",
      locals: { idea: @idea, liked: @idea.liked_by?(current_user) }
    )
  end
end
