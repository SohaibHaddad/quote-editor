class AddCascadeDeleteToQuoteItemsQuoteFk < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :quote_items, :quotes
    add_foreign_key :quote_items, :quotes, on_delete: :cascade
  end
end
