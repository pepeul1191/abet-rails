# app/models/user.rb
class User < ApplicationRecord
  # has_secure_password

  has_many :login_logs, dependent: :destroy

  # Validaciones
  validates :username, presence: true, uniqueness: true, length: { maximum: 20 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 40 }
  validates :image_url, length: { maximum: 255 }, allow_blank: true
  validates :active, inclusion: { in: [true, false] }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Métodos de instancia
  def activate!
    update(active: true)
  end

  def deactivate!
    update(active: false)
  end

  def active?
    active == true
  end

  def inactive?
    !active?
  end
end