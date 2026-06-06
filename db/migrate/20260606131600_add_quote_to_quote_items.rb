class AddQuoteToQuoteItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :quote_items, :quote, null: false, foreign_key: true
  end
end
