module Admin
  class DevicesController < BaseController
    before_action :set_device, only: [:edit, :update, :destroy, :toggle_status]

    def index
      @categories = Device::CATEGORIES
      @selected_category = params[:category]
      @status_filter = params[:status]

      @devices = Device.all
      @devices = @devices.by_category(@selected_category) if @selected_category.present?

      case @status_filter
      when "active"
        @devices = @devices.where(active: true)
      when "inactive"
        @devices = @devices.where(active: false)
      when "borrowed"
        borrowed_ids = Loan.active.pluck(:device_id)
        @devices = @devices.where(id: borrowed_ids)
      when "available"
        borrowed_ids = Loan.active.pluck(:device_id)
        @devices = @devices.where(active: true).where.not(id: borrowed_ids)
      end

      @devices = @devices.search(params[:query]) if params[:query].present?
      @devices = @devices.order(:name).includes(:loans, loans: :user)
    end

    def new
      @device = Device.new(active: true)
    end

    def create
      @device = Device.new(device_params)

      if @device.save
        ActivityLog.create!(
          user: current_user,
          action: "device_create",
          record_type: "Device",
          record_id: @device.id,
          details: "Gerät '#{@device.name}' [#{@device.inventory_code}] neu erstellt."
        )
        redirect_to admin_devices_path, notice: "Gerät '#{@device.name}' wurde erfolgreich erstellt."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @device.update(device_params)
        ActivityLog.create!(
          user: current_user,
          action: "device_update",
          record_type: "Device",
          record_id: @device.id,
          details: "Gerät '#{@device.name}' [#{@device.inventory_code}] bearbeitet."
        )
        redirect_to admin_devices_path, notice: "Gerät '#{@device.name}' wurde erfolgreich aktualisiert."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @device.loans.any?
        redirect_to admin_devices_path, alert: "Geräte mit Ausleihhistorie können nicht gelöscht werden. Bitte deaktivieren Sie das Gerät stattdessen."
      else
        dev_name = @device.name
        dev_code = @device.inventory_code
        @device.destroy
        ActivityLog.create!(
          user: current_user,
          action: "device_destroy",
          record_type: "Device",
          record_id: nil,
          details: "Gerät '#{dev_name}' [#{dev_code}] wurde aus dem System gelöscht."
        )
        redirect_to admin_devices_path, notice: "Gerät '#{dev_name}' wurde erfolgreich gelöscht."
      end
    end

    def toggle_status
      if @device.active? && @device.current_loan.present?
        return redirect_to admin_devices_path, alert: "Das Gerät '#{@device.name}' ist aktuell noch ausgeliehen und kann erst nach erfolgter Rückgabe deaktiviert werden."
      end

      new_state = !@device.active?
      @device.update!(active: new_state)

      action_text = new_state ? "aktiviert" : "deaktiviert"
      ActivityLog.create!(
        user: current_user,
        action: "device_toggle",
        record_type: "Device",
        record_id: @device.id,
        details: "Gerät '#{@device.name}' wurde #{action_text}."
      )

      redirect_to admin_devices_path, notice: "Gerät '#{@device.name}' wurde erfolgreich #{action_text}."
    end

    private

    def set_device
      @device = Device.find(params[:id])
    end

    def device_params
      params.require(:device).permit(:name, :category, :inventory_code, :description, :active)
    end
  end
end
