module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:edit, :update, :toggle_role, :toggle_active]

    def index
      @users = User.all.order(:role, :name).includes(:active_loans)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        ActivityLog.create!(
          user: current_user,
          action: "user_update",
          record_type: "User",
          record_id: @user.id,
          details: "Benutzerdaten für #{@user.name} (#{@user.email}) aktualisiert."
        )
        redirect_to admin_users_path, notice: "Benutzer #{@user.name} erfolgreich aktualisiert."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def toggle_role
      if @user == current_user
        return redirect_to admin_users_path, alert: "Sie können Ihre eigene Administratorrolle nicht entziehen."
      end

      new_role = @user.admin? ? "user" : "admin"
      @user.update!(role: new_role)

      role_text = new_role == "admin" ? "zum Administrator ernannt" : "zum Standard-Benutzer herabgestuft"
      ActivityLog.create!(
        user: current_user,
        action: "user_role_change",
        record_type: "User",
        record_id: @user.id,
        details: "Benutzer #{@user.name} wurde #{role_text}."
      )

      redirect_to admin_users_path, notice: "Benutzer #{@user.name} wurde #{role_text}."
    end

    def toggle_active
      if @user == current_user
        return redirect_to admin_users_path, alert: "Sie können Ihr eigenes Benutzerkonto nicht deaktivieren."
      end

      if @user.active? && @user.active_loans.any?
        return redirect_to admin_users_path, alert: "Benutzer #{@user.name} hat noch aktive Ausleihen und kann nicht deaktiviert werden."
      end

      new_state = !@user.active?
      @user.update!(active: new_state)

      status_text = new_state ? "aktiviert" : "deaktiviert"
      ActivityLog.create!(
        user: current_user,
        action: "user_toggle",
        record_type: "User",
        record_id: @user.id,
        details: "Benutzer #{@user.name} wurde #{status_text}."
      )

      redirect_to admin_users_path, notice: "Benutzerkonto von #{@user.name} wurde #{status_text}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :role, :active)
    end
  end
end
