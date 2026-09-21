class LoansController < ApplicationController
  def index
    @active_loans = current_user.active_loans.includes(:device)
    @past_loans = current_user.past_loans.includes(:device)
  end

  def create
    device = Device.find(params[:device_id])

    begin
      @loan = Loan.borrow!(
        user: current_user,
        device: device,
        notes: params[:notes]
      )
      redirect_to my_loans_path, notice: "Gerät '#{device.name}' erfolgreich ausgeliehen!"
    rescue Loan::LoanError => e
      redirect_to devices_path, alert: e.message
    end
  end

  def return_device
    loan = if admin?
             Loan.find_by(id: params[:id])
           else
             current_user.loans.find_by(id: params[:id])
           end

    unless loan
      return redirect_back fallback_location: my_loans_path, alert: "Ausleihe nicht gefunden oder Zugriff verweigert."
    end

    begin
      loan.return!(current_user)
      redirect_back fallback_location: my_loans_path, notice: "Gerät '#{loan.device.name}' erfolgreich zurückgegeben."
    rescue Loan::LoanError => e
      redirect_back fallback_location: my_loans_path, alert: e.message
    end
  end
end
