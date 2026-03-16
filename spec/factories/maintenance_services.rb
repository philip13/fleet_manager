FactoryBot.define do
  factory :maintenance_service do
    vehicle { nil }
    description { "MyString" }
    status { 1 }
    date { "2026-03-08" }
    cost_cents { 1 }
    priority { 1 }
  end
end
