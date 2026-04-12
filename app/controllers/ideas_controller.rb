class IdeasController < ApplicationController
  before_action :set_idea, only: [ :show, :destroy ]

  def index
    authorize Idea
    @ideas = policy_scope(Idea)

    @ideas = @ideas.where(stock_id: params[:stock_id]) if params[:stock_id].present?
    if params[:tag].present?
      @ideas = @ideas.joins(:idea_taggings).where(idea_taggings: { idea_tag_id: params[:tag] })
    end

    if params[:sort] == "popular"
      @ideas = @ideas.left_joins(:idea_likes)
                     .group(:id)
                     .order("COUNT(idea_likes.id) DESC, ideas.published_at DESC")
    else
      @ideas = @ideas.order(published_at: :desc)
    end

    @idea_tags = IdeaTag.order(:name)
    @stocks = Stock.order(:ticker)
  end

  def show
    authorize @idea
    @idea.increment!(:views_count)
    @comments = @idea.idea_comments.where(parent_id: nil).includes(:user, :replies).order(created_at: :asc)
    @new_comment = IdeaComment.new
  end

  def new
    @idea = Idea.new
    authorize @idea
    @stocks = Stock.order(:ticker)
    @idea_tags = IdeaTag.order(:name)
  end

  def create
    @idea = current_user.ideas.build(idea_params)
    @idea.published_at = Time.current
    authorize @idea

    if @idea.save
      redirect_to @idea, notice: "Idea was successfully published."
    else
      @stocks = Stock.order(:ticker)
      @idea_tags = IdeaTag.order(:name)
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    authorize @idea
    @idea.destroy!
    redirect_to ideas_url, notice: "Idea was successfully deleted."
  end

  private

  def set_idea
    @idea = Idea.find(params[:id])
  end

  def idea_params
    params.require(:idea).permit(:title, :body, :direction, :stock_id, idea_tag_ids: [])
  end
end
