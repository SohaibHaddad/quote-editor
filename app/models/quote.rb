# Database fields:
# - id: integer
# - name: string
# - partner_id: integer
# - created_by_id: integer
# - state: integer
# - created_at: datetime
# - updated_at: datetime
class Quote < ApplicationRecord
  belongs_to :partner
  # `created_by` tracks which user originally created the quote, but in this
  # simplified application every user belonging to the same partner can still
  # view, modify, and delete that partner's quotes.
  belongs_to :created_by, class_name: "User"
  has_many :quote_items, dependent: :destroy

  validates :name, presence: true

  state_machine :state, initial: :in_draft do
    state :in_draft, value: 0
    state :validated, value: 1

    # A quote can only transition from `in_draft` to `validated`.
    # Once validated, it is considered frozen from the user's point of view:
    # the UI and controllers block quote edits, quote deletion, and quote item
    # changes. This behavior is not enforced here at the model layer or at the
    # database level as a general immutability rule.
    event :validate_quote do
      transition in_draft: :validated, if: :has_quote_items?
    end
  end

  def total_price_before_tax
    total_price_before_tax_in_cents.to_d / 100
  end

  def total_price_after_tax
    total_price_after_tax_in_cents.to_d / 100
  end

  def total_tax
    total_tax_in_cents.to_d / 100
  end

  def total_price_before_tax_in_cents
    persisted_quote_items.sum(&:price_before_tax_in_cents)
  end

  def total_price_after_tax_in_cents
    persisted_quote_items.sum(&:price_after_tax_in_cents)
  end

  def total_tax_in_cents
    total_price_after_tax_in_cents - total_price_before_tax_in_cents
  end

  def has_quote_items?
    quote_items.exists?
  end

  private

  def persisted_quote_items
    quote_items.select(&:persisted?)
  end
end
