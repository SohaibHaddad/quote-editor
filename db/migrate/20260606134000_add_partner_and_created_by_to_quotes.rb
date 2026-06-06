class AddPartnerAndCreatedByToQuotes < ActiveRecord::Migration[8.1]
  def change
    add_reference :quotes, :partner, null: false, foreign_key: true
    add_reference :quotes, :created_by, null: false, foreign_key: { to_table: :users }
  end
end
