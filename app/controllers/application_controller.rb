class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pundit::Authorization
  before_action :authenticate_user! # Devise - requirements to log in
  before_action :load_notifications

  rescue_from Pundit::NotAuthorizedError do
    flash[:alert] = "Not authorized"
    redirect_to leagues_path
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Allow Rails to save display_name
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :display_name ])
  end

  def load_notifications
    return unless user_signed_in?
    @notifications = current_user.notifications.recent
  end
end
