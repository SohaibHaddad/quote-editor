require "rails_helper"

RSpec.describe QuoteItem, type: :model do
  it "is valid with the factory defaults" do
    expect(build(:quote_item)).to be_valid
  end

  it "belongs to a quote" do
    association = described_class.reflect_on_association(:quote)

    expect(association.macro).to eq(:belongs_to)
  end

  it "requires a name" do
    quote_item = build(:quote_item, name: nil)

    expect(quote_item).not_to be_valid
    expect(quote_item.errors[:name]).to include(I18n.t("errors.messages.blank"))
  end

  it "requires non-negative quantity" do
    quote_item = build(:quote_item, quantity: -1)

    expect(quote_item).not_to be_valid
    expect(quote_item.errors[:quantity]).to include(I18n.t("errors.messages.greater_than_or_equal_to", count: 0))
  end

  it "requires unit price in cents to be non-negative" do
    quote_item = build(:quote_item, unit_price_before_tax_in_cents: -1)

    expect(quote_item).not_to be_valid
    expect(quote_item.errors[:unit_price_before_tax_in_cents]).to include(I18n.t("errors.messages.greater_than_or_equal_to", count: 0))
  end

  it "requires tax rate to be between 0 and 100" do
    quote_item = build(:quote_item, tax_rate: 100.1)

    expect(quote_item).not_to be_valid
    expect(quote_item.errors[:tax_rate]).to include(I18n.t("errors.messages.less_than_or_equal_to", count: 100))
  end

  it "converts decimal amount input to integer cents" do
    quote_item = build(:quote_item, unit_price_before_tax_in_cents: nil)
    quote_item.unit_price_before_tax_amount = "12.34"

    expect(quote_item.unit_price_before_tax_in_cents).to eq(1234)
  end

  it "accepts comma decimal input for amount conversion" do
    quote_item = build(:quote_item, unit_price_before_tax_in_cents: nil)
    quote_item.unit_price_before_tax_amount = "12,34"

    expect(quote_item.unit_price_before_tax_in_cents).to eq(1234)
  end

  it "returns decimal amount input from stored cents" do
    quote_item = build(:quote_item, unit_price_before_tax_in_cents: 1234)

    expect(quote_item.unit_price_before_tax_amount).to eq("12.34")
  end

  it "returns nil cents for invalid amount input" do
    quote_item = build(:quote_item, unit_price_before_tax_in_cents: 100)
    quote_item.unit_price_before_tax_amount = "abc"

    expect(quote_item.unit_price_before_tax_in_cents).to be_nil
  end

  it "computes unit price before tax as a decimal amount" do
    quote_item = build(:quote_item, unit_price_before_tax_in_cents: 1234)

    expect(quote_item.unit_price_before_tax).to eq(12.34.to_d)
  end

  it "computes price before tax from unit price and quantity" do
    quote_item = build(:quote_item, unit_price_before_tax_in_cents: 1234, quantity: 3)

    expect(quote_item.price_before_tax_in_cents).to eq(3702)
    expect(quote_item.price_before_tax).to eq(37.02.to_d)
  end

  it "computes price after tax from total before tax and tax rate" do
    quote_item = build(:quote_item, unit_price_before_tax_in_cents: 1000, quantity: 2, tax_rate: 20)

    expect(quote_item.price_after_tax_in_cents).to eq(2400)
    expect(quote_item.price_after_tax).to eq(24.to_d)
  end

  it "rounds tax-inclusive totals at the cents level" do
    quote_item = build(:quote_item, unit_price_before_tax_in_cents: 1234, quantity: 1, tax_rate: 20)

    expect(quote_item.price_after_tax_in_cents).to eq(1481)
    expect(quote_item.price_after_tax).to eq(14.81.to_d)
  end
end
