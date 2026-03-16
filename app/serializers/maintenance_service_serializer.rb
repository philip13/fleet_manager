class MaintenanceServiceSerializer < ActiveModel::Serializer
  attributes :id, :vehicle_id, :description, :status, :date,
             :cost_cents, :priority, :completed_at, :created_at, :updated_at
end
