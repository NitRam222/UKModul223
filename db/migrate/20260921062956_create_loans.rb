class CreateLoans < ActiveRecord::Migration[8.1]
  def change
    create_table :loans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :device, null: false, foreign_key: true
      t.datetime :borrowed_at, null: false
      t.datetime :returned_at
      t.text :notes

      t.timestamps
    end

    # Enforces the core business rule at the database level:
    # A device can have at most ONE active loan (returned_at IS NULL).
    add_index :loans, :device_id, unique: true, where: "returned_at IS NULL", name: "idx_unique_active_loan_per_device"
    add_index :loans, :returned_at
  end
end
