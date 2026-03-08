class Vehicle < ApplicationRecord
  validates :vin, :plate, :year, presence: true
end
