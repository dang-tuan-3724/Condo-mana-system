class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :set_condos, if: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :role, :condo_id ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :role ])
  end
  private
  def set_condos
    @condos = Condo.all
  end
end
