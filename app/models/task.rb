class Task < ApplicationRecord
  belongs_to :user
  belongs_to :task_type
  belongs_to :period

  validates :name, presence: true, length: { maximum: 40 }
  validates :status, length: { maximum: 20 }, allow_blank: true
  validates :zip_path, length: { maximum: 255 }, allow_blank: true

  # helper para JSON de data
  def data_rows
    JSON.parse(self.data || "[]")
  rescue JSON::ParserError
    []
  end

  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }
end