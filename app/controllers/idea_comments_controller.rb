class IdeaCommentsController < ApplicationController
  def create
    @idea = Idea.find(params[:idea_id])
    @comment = @idea.idea_comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @idea, notice: "Comment posted."
    else
      redirect_to @idea, alert: "Comment cannot be blank."
    end
  end

  private

  def comment_params
    params.require(:idea_comment).permit(:body, :parent_id)
  end
end
