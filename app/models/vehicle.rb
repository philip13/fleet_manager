class Vehicle < ApplicationRecord
  enum :status, %i(active inactive in_maintenance)
  validates :vin, :plate, :year, :status, presence: true
  validates :year, numericality: { in: 1990..2050 }
end
