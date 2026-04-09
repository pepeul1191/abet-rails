# app/models/login_log.rb
class LoginLog < ApplicationRecord
  belongs_to :user

  validates :success, inclusion: { in: [true, false] }
end