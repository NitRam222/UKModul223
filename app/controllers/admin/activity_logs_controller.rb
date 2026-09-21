module Admin
  class ActivityLogsController < BaseController
    def index
      @logs = ActivityLog.all
      @logs = @logs.by_action(params[:action_type]) if params[:action_type].present?
      @logs = @logs.by_user(params[:user_id]) if params[:user_id].present?

      @logs = @logs.includes(:user).recent.limit(100)
      @users = User.all.order(:name)
      @action_types = ActivityLog.distinct.pluck(:action).compact
    end
  end
end
