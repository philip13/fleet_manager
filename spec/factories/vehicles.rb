require 'faker'

FactoryBot.define do
  factory :vehicle do
    sequence(:vin) { Faker::Vehicle.vin }
    sequence(:plate) { Faker::Vehicle.license_plate }
    brand { Faker::Vehicle.make }
    model { Faker::Vehicle.model }
    year { 2020 }
    status { "active" }
  end
end
