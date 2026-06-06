class AddStateToQuotes < ActiveRecord::Migration[8.1]
  def change
    add_column :quotes, :state, :integer, null: false, default: 0
    add_check_constraint :quotes, "state IN (0, 1)", name: "quotes_state_valid"
  end
end
