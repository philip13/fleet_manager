class Vehicle < ApplicationRecord
  has_many :maintenance_services 
  enum :status, { active: 0, inactive: 1, in_maintenance: 2 }

  validates :vin, :plate, presence: true, uniqueness: { case_sensitive: false }
  validates :year, presence: true, numericality: { only_integer: true, in: 1990..2050 }
  validates :status, presence: true

  def sync_status!
    new_status = maintenance_services.where(status: [:pending, :in_progress]).exists? ? :in_maintenance : :active
    update(status: status)

    update_column(:status, Vehicle.statuses[new_status]) unless status == new_status.to_s
  end
end
