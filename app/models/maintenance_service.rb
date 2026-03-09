class MaintenanceService < ApplicationRecord
  belongs_to :vehicle

  validates :description, :status, :date, :cost_cents, :priority, presence: true
  validates :cost_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
