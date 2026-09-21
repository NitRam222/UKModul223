class ActivityLog < ApplicationRecord
  belongs_to :user, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) if action.present? }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }

  def action_label
    case action
    when "borrow"
      "Ausleihe"
    when "return"
      "Rückgabe"
    when "device_create"
      "Gerät erstellt"
    when "device_update"
      "Gerät bearbeitet"
    when "device_toggle"
      "Status geändert"
    when "user_role_change"
      "Rolle geändert"
    when "user_toggle"
      "Benutzerstatus geändert"
    when "login"
      "Anmeldung"
    when "register"
      "Registrierung"
    else
      action.humanize
    end
  end

  def action_badge_class
    case action
    when "borrow"
      "badge-primary"
    when "return"
      "badge-success"
    when "device_create", "register"
      "badge-info"
    when "device_toggle", "user_toggle"
      "badge-warning"
    when "device_update", "user_role_change"
      "badge-secondary"
    else
      "badge-secondary"
    end
  end
end
