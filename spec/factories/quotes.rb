FactoryBot.define do
  factory :quote do
    partner
    created_by { association :user, partner: partner }
    sequence(:name) { |n| "Quote #{n}" }
    state { 0 }

    trait :validated do
      state { 1 }
    end
  end
end
