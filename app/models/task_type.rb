# app/models/task_type.rb
class TaskType < ApplicationRecord
  validates :name, presence: true, length: { maximum: 30 }
end