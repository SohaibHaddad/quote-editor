class Quote < ApplicationRecord
  belongs_to :partner
  belongs_to :created_by, class_name: "User"
  has_many :quote_items

  validates :name, presence: true

  def total_price_before_tax
    quote_items.sum(&:price_before_tax)
  end

  def total_price_after_tax
    quote_items.sum(&:price_after_tax)
  end

  def total_tax
    total_price_after_tax - total_price_before_tax
  end
end
