class LeaguesController < ApplicationController
  
  before_action :authenticate_user!  # To force Leagues controller to require a user to be "logged in"
  
  def index
    # Phase 2 work
  end
end
