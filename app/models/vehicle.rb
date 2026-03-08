class Vehicle < ApplicationRecord
  enum :status, { active: 0, inactive: 1, in_maintenance: 2 }

  validates :vin, :plate, presence: true, uniqueness: { case_sensitive: false }
  validates :year, presence: true, numericality: { only_integer: true, in: 1990..2050 }
  validates :status, presence: true
end
