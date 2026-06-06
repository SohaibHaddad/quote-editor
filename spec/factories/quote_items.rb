FactoryBot.define do
  factory :quote_item do
    association :quote
    sequence(:name) { |n| "Item #{n}" }
    quantity { 2 }
    tax_rate { 20 }
    unit_price_before_tax_in_cents { 1250 }
  end
end
