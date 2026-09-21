class DevicesController < ApplicationController
  def index
    @categories = Device::CATEGORIES
    @selected_category = params[:category]
    @search_query = params[:query]

    # For regular overview, display active devices (matching sketch #2)
    @devices = Device.active
                     .by_category(@selected_category)
                     .search(@search_query)
                     .order(:name)
                     .includes(:loans, loans: :user)

    @my_active_loan_ids = current_user.active_loans.pluck(:device_id)
  end

  def show
    @device = Device.find(params[:id])
    @current_loan = @device.current_loan
    @past_loans = @device.loans.returned.order(returned_at: :desc).limit(5)
  end
end
