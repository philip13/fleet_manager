class MaintenanceService < ApplicationRecord
  belongs_to :vehicle
  enum :status, { pending: 0, in_progress: 1, completed: 2 }
  enum :priority, { low: 0, medium: 1, high: 2 }

  validates :description, :status, :date, :cost_cents, :priority, presence: true
  validates :cost_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :date_cannot_be_in_future
  validate :complete_date_must_be_present

  after_save :sync_vehicle_status
  after_destroy :sync_vehicle_status

  private

  def sync_vehicle_status
    vehicle.sync_status!
  end

  def date_cannot_be_in_future
    if date.present? && date > Date.today
      errors.add(:date, "can't be in the future")
    end
  end

  def complete_date_must_be_present
    if status == "completed" && completed_at.nil?
      errors.add(:completed_at, "can't be blank when service is completed")
    end
  end
end
