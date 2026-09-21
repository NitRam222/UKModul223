class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?, :admin?
  before_action :require_login

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    current_user&.admin?
  end

  def require_login
    unless logged_in?
      session[:return_to] = request.fullpath if request.get?
      redirect_to login_path, alert: "Bitte melden Sie sich an, um fortzufahren."
    end
  end

  def require_admin
    unless admin?
      redirect_to root_path, alert: "Zugriff verweigert: Für diesen Bereich sind Administratorrechte erforderlich."
    end
  end

  def render_not_found
    redirect_to root_path, alert: "Der angeforderte Datensatz wurde nicht gefunden."
  end
end
