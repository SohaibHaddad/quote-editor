class CreateQuoteItems < ActiveRecord::Migration[8.1]
  def change
    create_table :quote_items do |t|
      t.string :name, null: false
      t.integer :quantity, null: false
      t.decimal :tax_rate, null: false
      t.decimal :price_before_tax, null: false

      t.timestamps
    end
  end
end
