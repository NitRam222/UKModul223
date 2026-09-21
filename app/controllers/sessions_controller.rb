class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password])
      unless user.active?
        flash.now[:alert] = "Ihr Benutzerkonto ist deaktiviert. Bitte kontaktieren Sie einen Administrator."
        return render :new, status: :forbidden
      end

      reset_session
      session[:user_id] = user.id

      ActivityLog.create!(
        user: user,
        action: "login",
        record_type: "User",
        record_id: user.id,
        details: "#{user.name} hat sich angemeldet."
      )

      destination = session.delete(:return_to) || root_path
      redirect_to destination, notice: "Willkommen zurück, #{user.name}!"
    else
      flash.now[:alert] = "Ungültige E-Mail-Adresse oder falsches Passwort."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user
      ActivityLog.create!(
        user: current_user,
        action: "logout",
        record_type: "User",
        record_id: current_user.id,
        details: "#{current_user.name} hat sich abgemeldet."
      )
    end

    reset_session
    redirect_to login_path, notice: "Sie wurden erfolgreich abgemeldet."
  end
end
