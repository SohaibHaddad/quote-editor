# Database fields:
# - id: integer
# - name: string
# - quote_id: integer
# - quantity: integer
# - tax_rate: decimal
# - unit_price_before_tax_in_cents: integer
# - created_at: datetime
# - updated_at: datetime
class QuoteItem < ApplicationRecord
  belongs_to :quote

  validates :name, presence: true
  validates :unit_price_before_tax_in_cents, :quantity,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate,
    presence: true,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Prices are stored as integer cents in `unit_price_before_tax_in_cents`
  # rather than decimal euros because floating-point numbers cannot represent
  # many decimal values exactly. For example, values like 0.1 or 12.34 may be
  # stored internally as approximations, which can introduce rounding errors in
  # totals, taxes, and comparisons. Using integer cents keeps money calculations
  # deterministic and avoids those precision issues.
  def unit_price_before_tax_euros
    return @unit_price_before_tax_euros if defined?(@unit_price_before_tax_euros)
    return if unit_price_before_tax_in_cents.nil?

    unit_price_before_tax.to_s("F")
  end

  def unit_price_before_tax_euros=(value)
    @unit_price_before_tax_euros = value

    normalized_value = value.to_s.strip.tr(",", ".")
    self.unit_price_before_tax_in_cents =
      if normalized_value.blank?
        nil
      else
        (BigDecimal(normalized_value) * 100).round.to_i
      end
  rescue ArgumentError
    self.unit_price_before_tax_in_cents = nil
  end

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
