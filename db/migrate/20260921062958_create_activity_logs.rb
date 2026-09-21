class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.references :user, null: true, foreign_key: true
      t.string :action, null: false
      t.string :record_type
      t.integer :record_id
      t.text :details

      t.timestamps
    end
    add_index :activity_logs, [:record_type, :record_id]
    add_index :activity_logs, :action
    add_index :activity_logs, :created_at
  end
end
