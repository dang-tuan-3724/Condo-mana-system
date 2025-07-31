class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :set_condos, if: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :role, :condo_id ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :role ])
  end
  private

  def user_not_authorized
    flash[:alert] = "Bạn không có quyền thực hiện hành động này."
    redirect_back(fallback_location: root_path)
  end

  def set_condos
    @condos = Condo.all
  end
end
