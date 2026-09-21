class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.string :inventory_code, null: false
      t.text :description
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :devices, :inventory_code, unique: true
    add_index :devices, :category
    add_index :devices, :active
  end
end
