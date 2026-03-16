class CreateMaintenanceServices < ActiveRecord::Migration[7.2]
  def change
    create_table :maintenance_services do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.string :description
      t.integer :status, null: false, default: 0
      t.date :date
      t.integer :cost_cents, null: false, default: 0
      t.integer :priority, null: false, default: 0

      t.timestamps
    end
  end
end
