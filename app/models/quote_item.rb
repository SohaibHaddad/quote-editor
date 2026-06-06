class QuoteItem < ApplicationRecord
  belongs_to :quote

  validates :name, presence: true
  validates :unit_price_before_tax_in_cents, :quantity,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate,
    presence: true,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def unit_price_before_tax
    unit_price_before_tax_in_cents.to_d / 100
  end

  def price_before_tax
    unit_price_before_tax * quantity.to_d
  end

  def price_after_tax
    price_before_tax * (1 + tax_rate.to_d / 100)
  end
end
