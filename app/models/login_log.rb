# app/models/login_log.rb
class LoginLog < ApplicationRecord
  belongs_to :user

  validates :success, inclusion: { in: [true, false] }

  # opcional útil
  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }
end