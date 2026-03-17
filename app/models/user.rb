class User < ApplicationRecord
  has_secure_password
  enum :role, { addmin: 0, user: 1 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
end
