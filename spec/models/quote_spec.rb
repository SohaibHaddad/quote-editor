require "rails_helper"

RSpec.describe Quote, type: :model do
  it "is valid with the factory defaults" do
    expect(build(:quote)).to be_valid
  end

  it "belongs to a partner" do
    association = described_class.reflect_on_association(:partner)

    expect(association.macro).to eq(:belongs_to)
  end

  it "belongs to the creating user" do
    association = described_class.reflect_on_association(:created_by)

    expect(association.macro).to eq(:belongs_to)
    expect(association.options[:class_name]).to eq("User")
  end

  it "has many quote items with dependent destroy" do
    association = described_class.reflect_on_association(:quote_items)

    expect(association.macro).to eq(:has_many)
    expect(association.options[:dependent]).to eq(:destroy)
  end

  it "requires a name" do
    quote = build(:quote, name: nil)

    expect(quote).not_to be_valid
    expect(quote.errors[:name]).to include(I18n.t("errors.messages.blank"))
  end

  it "starts in draft" do
    expect(build(:quote)).to be_in_draft
  end

  it "can be validated when it has at least one item" do
    quote = create(:quote)
    create(:quote_item, quote: quote)

    expect(quote.can_validate_quote?).to be(true)
  end

  it "cannot be validated without items" do
    quote = create(:quote)

    expect(quote.can_validate_quote?).to be(false)
    expect(quote.validate_quote).to be(false)
    expect(quote.reload).to be_in_draft
  end

  it "transitions from draft to validated" do
    quote = create(:quote)
    create(:quote_item, quote: quote)

    expect(quote.validate_quote).to be(true)
    expect(quote.reload).to be_validated
  end

  it "does not allow transitioning back to draft" do
    quote = create(:quote, :validated)

    expect(quote).not_to respond_to(:return_to_draft)
  end

  it "computes total price before tax" do
    quote = create(:quote)
    create(:quote_item, quote: quote, unit_price_before_tax_in_cents: 1000, quantity: 2, tax_rate: 20)
    create(:quote_item, quote: quote, unit_price_before_tax_in_cents: 500, quantity: 1, tax_rate: 10)

    expect(quote.total_price_before_tax).to eq(25.to_d)
  end

  it "computes total price after tax" do
    quote = create(:quote)
    create(:quote_item, quote: quote, unit_price_before_tax_in_cents: 1000, quantity: 2, tax_rate: 20)
    create(:quote_item, quote: quote, unit_price_before_tax_in_cents: 500, quantity: 1, tax_rate: 10)

    expect(quote.total_price_after_tax).to eq(29.5.to_d)
  end

  it "computes total tax" do
    quote = create(:quote)
    create(:quote_item, quote: quote, unit_price_before_tax_in_cents: 1000, quantity: 2, tax_rate: 20)
    create(:quote_item, quote: quote, unit_price_before_tax_in_cents: 500, quantity: 1, tax_rate: 10)

    expect(quote.total_tax).to eq(4.5.to_d)
  end

  it "destroys associated quote items when deleted" do
    quote = create(:quote)
    create(:quote_item, quote: quote)

    expect { quote.destroy }.to change(QuoteItem, :count).by(-1)
  end
end
