class User < ApplicationRecord
  has_secure_password

  ROLES = %w[user admin].freeze

  has_many :loans, dependent: :destroy
  has_many :devices, through: :loans
  has_many :active_loans, -> { where(returned_at: nil).order(borrowed_at: :desc) }, class_name: "Loan"
  has_many :past_loans, -> { where.not(returned_at: nil).order(returned_at: :desc) }, class_name: "Loan"
  has_many :activity_logs, dependent: :nullify

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "muss eine gültige E-Mail-Adresse sein" }
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :password, length: { minimum: 6 }, allow_nil: true

  before_validation :normalize_email

  scope :active, -> { where(active: true) }
  scope :admins, -> { where(role: "admin") }
  scope :regular_users, -> { where(role: "user") }

  def admin?
    role == "admin"
  end

  def user?
    role == "user"
  end

  def role_name
    admin? ? "Administrator" : "Benutzer"
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
