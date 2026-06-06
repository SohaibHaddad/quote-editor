class AddConstraintsToQuoteItems < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :quote_items,
      "unit_price_before_tax_in_cents >= 0",
      name: "quote_items_unit_price_before_tax_in_cents_non_negative"
    add_check_constraint :quote_items,
      "quantity >= 0",
      name: "quote_items_quantity_non_negative"
    add_check_constraint :quote_items,
      "tax_rate >= 0 AND tax_rate <= 100",
      name: "quote_items_tax_rate_percentage_range"
  end
end
