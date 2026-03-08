class AddStatusToVehicle < ActiveRecord::Migration[7.2]
  def change
    add_column :vehicles, :status, :integer, default: 0
  end
end
