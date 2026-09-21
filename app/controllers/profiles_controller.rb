class ProfilesController < ApplicationController
  before_action :set_user

  def show
    @active_loans = @user.active_loans.includes(:device)
    @past_loans = @user.past_loans.includes(:device).limit(10)
  end

  def edit
  end

  def update
    # If password is being changed, verify current password
    if params[:user][:password].present?
      unless @user.authenticate(params[:user][:current_password])
        @user.errors.add(:current_password, "ist nicht korrekt")
        return render :edit, status: :unprocessable_entity
      end
    end

    if @user.update(profile_params)
      ActivityLog.create!(
        user: @user,
        action: "profile_update",
        record_type: "User",
        record_id: @user.id,
        details: "#{@user.name} hat sein Profil aktualisiert."
      )
      redirect_to profile_path, notice: "Profil erfolgreich aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    if params[:user][:password].present?
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    else
      params.require(:user).permit(:name, :email)
    end
  end
end
