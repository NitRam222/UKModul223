class Loan < ApplicationRecord
  class LoanError < StandardError; end

  belongs_to :user
  belongs_to :device

  validates :borrowed_at, presence: true
  validate :device_must_be_available_for_new_loan, on: :create
  validate :return_date_after_borrow_date, if: -> { returned_at.present? }

  scope :active, -> { where(returned_at: nil).order(borrowed_at: :desc) }
  scope :returned, -> { where.not(returned_at: nil).order(returned_at: :desc) }
  scope :recent, -> { order(borrowed_at: :desc) }

  def active?
    returned_at.nil?
  end

  def returned?
    returned_at.present?
  end

  # Transaktion mit pessimistischem Locking für konkurrierende Ausleihvorgänge
  def self.borrow!(user:, device:, notes: nil)
    Device.transaction do
      # Pessimistisches Locking auf das Device (SELECT FOR UPDATE)
      locked_device = Device.lock.find(device.id)

      unless locked_device.active?
        raise LoanError, "Das Gerät ist inaktiv und kann nicht ausgeliehen werden."
      end

      # Zentrale Fachregel: Höchstens eine aktive Ausleihe pro Gerät!
      if locked_device.loans.where(returned_at: nil).exists?
        raise LoanError, "Das Gerät wurde inzwischen von einem anderen Benutzer ausgeliehen."
      end

      loan = locked_device.loans.create!(
        user: user,
        borrowed_at: Time.current,
        notes: notes
      )

      ActivityLog.create!(
        user: user,
        action: "borrow",
        record_type: "Device",
        record_id: locked_device.id,
        details: "#{user.name} (#{user.email}) hat #{locked_device.name} [#{locked_device.inventory_code}] ausgeliehen."
      )

      loan
    end
  rescue ActiveRecord::RecordNotUnique
    raise LoanError, "Das Gerät wurde inzwischen von einem anderen Benutzer ausgeliehen."
  end

  # Transaktion mit Sperre für die Rückgabe
  def return!(by_user)
    with_lock do
      if returned?
        raise LoanError, "Dieses Gerät wurde bereits zurückgegeben."
      end

      unless by_user.admin? || by_user == user
        raise LoanError, "Sie dürfen nur Ihre eigenen Ausleihen zurückgeben."
      end

      update!(returned_at: Time.current)

      ActivityLog.create!(
        user: by_user,
        action: "return",
        record_type: "Device",
        record_id: device_id,
        details: "#{by_user.name} (#{by_user.email}) hat #{device.name} [#{device.inventory_code}] zurückgegeben."
      )

      self
    end
  end

  private

  def device_must_be_available_for_new_loan
    return unless device

    unless device.active?
      errors.add(:device, "ist inaktiv und kann nicht ausgeliehen werden")
      return
    end

    if device.loans.where(returned_at: nil).where.not(id: id).exists?
      errors.add(:device, "ist bereits ausgeliehen")
    end
  end

  def return_date_after_borrow_date
    return unless returned_at && borrowed_at

    if returned_at < borrowed_at
      errors.add(:returned_at, "kann nicht vor dem Ausleihdatum liegen")
    end
  end
end
