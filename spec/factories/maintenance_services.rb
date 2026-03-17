FactoryBot.define do
  factory :maintenance_service do
    association :vehicle
    description { Faker::Vehicle.standard_specs.sample }
    status      { :pending }
    priority    { :medium }
    date        { Faker::Date.between(from: 1.year.ago, to: Date.today) }
    cost_cents  { Faker::Number.between(from: 0, to: 500_000) }
    completed_at { nil }
  end
end
