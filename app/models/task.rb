# app/models/task.rb
class Task < ApplicationRecord
  self.table_name = "tasks"

  # Associations
  belongs_to :user
  belongs_to :task_type
  belongs_to :period

  # Validations
  validates :name, presence: true, length: { maximum: 40 }
  validates :user_id, presence: true
  validates :task_type_id, presence: true
  validates :period_id, presence: true

  # Optional validations (según tu lógica de negocio)
  validates :status, length: { maximum: 20 }, allow_nil: true
  validates :zip_path, length: { maximum: 255 }, allow_nil: true
end