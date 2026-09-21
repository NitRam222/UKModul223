class Device < ApplicationRecord
  CATEGORIES = ["Laptop", "Kamera", "Zubehör", "Audio", "Tablet", "Sonstiges"].freeze

  has_many :loans, dependent: :restrict_with_error
  has_many :users, through: :loans

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :inventory_code, presence: true, uniqueness: { case_sensitive: false }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :search, ->(query) {
    if query.present?
      q = "%#{query.strip}%"
      where("name LIKE ? OR inventory_code LIKE ? OR description LIKE ? OR category LIKE ?", q, q, q, q)
    end
  }

  def current_loan
    loans.find_by(returned_at: nil)
  end

  def current_borrower
    current_loan&.user
  end

  def available?
    active? && current_loan.nil?
  end

  def status_label
    return "Inaktiv" unless active?
    return "Ausgeliehen" if current_loan.present?

    "Verfügbar"
  end

  def status_badge_class
    return "badge-secondary" unless active?
    return "badge-warning" if current_loan.present?

    "badge-success"
  end
end
