class LeaguesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_league, only: [ :show, :destroy, :invite ]

  def index
    @leagues = League.all
    @league  = League.new
    @friends = current_user.friends
  end

  def show
    authorize @league
    @members = @league.league_memberships.includes(:user)
  end

  def invite
    authorize @league
    invitee = resolve_invitee(params[:identifier])
    if invitee.nil?
      redirect_to @league, alert: "User not found." and return
    end
    if LeagueMembership.exists?(user: invitee, league: @league)
      redirect_to @league, alert: "#{invitee.display_name} is already a member." and return
    end
    invite_to_league(invitee)
    redirect_to @league, notice: "#{invitee.display_name} was invited to the league."
  end

  def new
    @league  = League.new
    @friends = current_user.friends
  end

  def create
    @league = League.new(league_params)
    @league.owner = current_user

    raw_ids = params.dig(:league, :invitee_identifiers_raw).to_s
                    .split(",").map(&:strip).reject(&:blank?)
    invitees = raw_ids.map { |id| resolve_invitee(id) }
    unknown  = raw_ids.each_with_index.filter_map { |id, i| id if invitees[i].nil? }

    if unknown.any?
      @league.errors.add(:base, "Invitee identifier not found: #{unknown.join(', ')}")
      @friends = current_user.friends
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: { errors: @league.errors.full_messages }, status: :unprocessable_entity }
      end
      return
    end

    if @league.save
      invitees.each { |invitee| invite_to_league(invitee) if invitee != current_user }
      respond_to do |format|
        format.html { redirect_to @league, notice: "League was successfully created." }
        format.json { render json: { notice: "League \"#{@league.name}\" created successfully!", url: league_path(@league) } }
      end
    else
      @friends = current_user.friends
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: { errors: @league.errors.full_messages }, status: :unprocessable_entity }
      end
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
      respond_to do |format|
        format.html { flash.now[:alert] = "Invalid invite code."; render :join, status: :unprocessable_content }
        format.json { render json: { error: "Invalid invite code. Please check and try again." }, status: :unprocessable_entity }
      end
      return
    end

    membership = LeagueMembership.new(user: current_user, league: @league, role: :participant)
    portfolio  = Portfolio.new(user: current_user, league: @league, cash_balance: @league.starting_capital)

    if membership.save && portfolio.save
      respond_to do |format|
        format.html { redirect_to @league, notice: "You have joined the league!" }
        format.json { render json: { notice: "You have joined #{@league.name}!", url: league_path(@league) } }
      end
    else
      respond_to do |format|
        format.html { flash.now[:alert] = "Could not join league."; render :join, status: :unprocessable_content }
        format.json { render json: { error: "Could not join league. You may already be a member." }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_league
    @league = League.find(params[:id])
  end

  def league_params
    params.expect(league: [ :name, :description, :starting_capital, :starts_at, :ends_at ])
  end

  def resolve_invitee(identifier)
    return nil if identifier.blank?
    User.find_by(email: identifier) || User.find_by(display_name: identifier)
  end

  def invite_to_league(invitee)
    LeagueMembership.create!(user: invitee, league: @league, role: :participant)
    Portfolio.create!(user: invitee, league: @league, cash_balance: @league.starting_capital)
    Notification.create!(
      user:  invitee,
      kind:  :invitation,
      title: "You've been invited to #{@league.name}",
      body:  "#{current_user.display_name} has invited you to join the league \"#{@league.name}\"."
    )
    LeagueMailer.invite(invitee, @league).deliver_later
  end
end
