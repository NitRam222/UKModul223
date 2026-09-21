class RegistrationsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_to root_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.role = "user" # Always force regular user on self-registration
    @user.active = true

    if @user.save
      reset_session
      session[:user_id] = @user.id

      ActivityLog.create!(
        user: @user,
        action: "register",
        record_type: "User",
        record_id: @user.id,
        details: "Neues Benutzerkonto für #{@user.name} (#{@user.email}) registriert."
      )

      redirect_to root_path, notice: "Konto erfolgreich erstellt! Willkommen bei GearShare, #{@user.name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
