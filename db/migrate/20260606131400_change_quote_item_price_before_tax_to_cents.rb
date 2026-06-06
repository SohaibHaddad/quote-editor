class ChangeQuoteItemPriceBeforeTaxToCents < ActiveRecord::Migration[8.1]
  def up
    rename_column :quote_items, :price_before_tax, :unit_price_before_tax_in_cents
    change_column :quote_items, :unit_price_before_tax_in_cents, :integer
    change_column_null :quote_items, :unit_price_before_tax_in_cents, false
  end

  def down
    change_column_null :quote_items, :unit_price_before_tax_in_cents, true
    change_column :quote_items, :unit_price_before_tax_in_cents, :decimal
    rename_column :quote_items, :unit_price_before_tax_in_cents, :price_before_tax
  end
end
