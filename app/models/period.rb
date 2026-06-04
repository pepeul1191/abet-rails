# app/models/period.rb
class Period < ApplicationRecord
  has_many :tasks, dependent: :restrict_with_exception

  validates :name, presence: true, length: { maximum: 10 }
  validates :init_date, presence: true
  validates :end_date, presence: true

  validate :end_date_after_init_date

  private

  def end_date_after_init_date
    return if init_date.blank? || end_date.blank?

    if end_date < init_date
      errors.add(:end_date, "debe ser posterior a la fecha de inicio")
    end
  end
end