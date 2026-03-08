FactoryBot.define do
  factory :vehicle do
    sequence(:vin) { |n| "VIN#{n}" }
    sequence(:plate) { |n| "PLATE#{n}" }
    brand { "MyString" }
    model { "MyString" }
    year { 2020 }
    status { "active" }
  end
end
