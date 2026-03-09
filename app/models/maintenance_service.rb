class MaintenanceService < ApplicationRecord
  belongs_to :vehicle
  enum :status, { pending: 0, in_progress: 1, completed: 2 }
  enum :priority, { low: 0, medium: 1, high: 2 }

  validates :description, :status, :date, :cost_cents, :priority, presence: true
  validates :cost_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
