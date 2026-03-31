class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pundit::Authorization
  before_action :authenticate_user! # Devise - requirements to log in

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Allow Rails to save display_name
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:display_name])
  end
end
