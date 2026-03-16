FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password_digest { "password123" }
    role { 1 }
  end
end
