class LeaguesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_league, only: [ :show, :destroy ]

  def index
    @leagues = League.all
  end

  def show
    authorize @league
  end

  def new
    @league = League.new
  end

  def create
    @league = League.new(league_params)
    @league.owner = current_user

    if @league.save
      redirect_to @league, notice: "League was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    authorize @league
    @league.destroy!
    redirect_to leagues_url, notice: "League was successfully destroyed."
  end

  def join
    return unless request.post?

    @league = League.find_by(invite_code: params[:invite_code])

    if @league.nil?
      flash.now[:alert] = "Invalid invite code."
      render :join, status: :unprocessable_content and return
    end

    membership = LeagueMembership.new(user: current_user, league: @league, role: :participant)
    portfolio  = Portfolio.new(user: current_user, league: @league, cash_balance: @league.starting_capital)

    if membership.save && portfolio.save
      redirect_to @league, notice: "You have joined the league!"
    else
      flash.now[:alert] = "Could not join league."
      render :join, status: :unprocessable_content
    end
  end

  private

  def set_league
    @league = League.find(params[:id])
  end

  def league_params
    params.expect(league: [ :name, :description, :starting_capital, :starts_at, :ends_at ])
  end
end
