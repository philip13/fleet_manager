class AddCompletedAtOnMaintenanceService < ActiveRecord::Migration[7.2]
  def change
    add_column :maintenance_services, :completed_at, :datetime
  end
end
