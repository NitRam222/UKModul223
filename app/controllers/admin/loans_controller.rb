module Admin
  class LoansController < BaseController
    def index
      @filter = params[:filter] || "active"

      @loans = if @filter == "returned"
                 Loan.returned
               elsif @filter == "all"
                 Loan.all
               else
                 Loan.active
               end

      if params[:query].present?
        q = "%#{params[:query].strip}%"
        @loans = @loans.joins(:user, :device).where(
          "users.name LIKE ? OR users.email LIKE ? OR devices.name LIKE ? OR devices.inventory_code LIKE ?",
          q, q, q, q
        )
      end

      @loans = @loans.includes(:user, :device).order(borrowed_at: :desc)
    end

    def return_device
      loan = Loan.find(params[:id])

      begin
        loan.return!(current_user)
        redirect_to admin_loans_path, notice: "Gerät '#{loan.device.name}' (Ausleiher: #{loan.user.name}) wurde als zurückgegeben markiert."
      rescue Loan::LoanError => e
        redirect_to admin_loans_path, alert: e.message
      end
    end
  end
end
