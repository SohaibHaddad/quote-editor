FactoryBot.define do
  factory :user do
    association :partner
    sequence(:username) { |n| "user#{n}" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
