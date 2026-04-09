# app/models/user.rb
class User < ApplicationRecord
  # has_secure_password

  has_many :login_logs, dependent: :destroy

  validates :email, presence: true, uniqueness: true, length: { maximum: 40 }
end